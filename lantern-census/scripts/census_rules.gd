class_name CensusRules
extends RefCounted

## Shared rules for the hand-authored floors of Lantern Census.
##
## Oil is the turn budget. A successful step, strafe, or wait drinks MOVE_OIL.
## Turning and marking are free and do not advance the warden.
##
## The warden occupies one tile and telegraphs the tile its swing will hit.
## After any oil-spending action, if the player is standing on that tile the
## swing hits and burns HIT_OIL more. A hit does not end the descent by itself.
## Oil at 0 ends the descent (the lamp goes out) and the sheet pays nothing.
## Stepping onto the lift extracts you even if that step spends the last oil.
##
## Payout, only after a lift extract, is the same on every floor:
##   corridor_pay = CORRIDOR_VALUE * true corridor tiles marked corridor
##   hazard_pay   = HAZARD_VALUE   * true hazard tiles marked hazard
##   loop_pay     = LOOP_VALUE if every tile of that floor's ring is marked corridor, else 0
##   total        = corridor_pay + hazard_pay + loop_pay
## A mark that does not match the floor adds nothing. A false hazard mark
## does not increase hazard pay or the total.
##
## The cellar's ring is the east square. The cistern's ring is the walk
## around the pit. The cloister's ring is the walk around the garth.
## The crypt's ring is the walk around the tomb. The ossuary's ring is
## the walk around the bone stack. The reliquary's ring is the walk
## around the case. The undercroft's ring is the walk around the trough.
## The well house's ring is the walk around the shaft.
## The scriptorium's ring is the walk around the desk.
## The binding's ring is the walk around the press.
## The chart room's ring is the walk around the table.
## The bell loft's ring is the walk around the bell.
## The clock room's ring is the walk around the clock.
## The font's ring is the walk around the font.
## The apse's ring is the walk around the apse.
## The choir's ring is the walk around the choir.
## The rood's ring is the walk around the rood.
## The crossing's ring is the walk around the crossing.
## The transept's ring is the walk around the transept.
## The ambulatory's ring is the walk around the ambulatory.
## The chevet's ring is the walk around the chevet.
## The retrochoir's ring is the walk around the retrochoir.
## The lady chapel's ring is the walk around the lady chapel.
## The feretory's ring is the walk around the feretory.
## The chantry's ring is the same walk, left where the feretory put it.
## The sacristy's ring is that same walk, left where the chantry left it.
## The pyx's ring is that same walk, left where the sacristy left it.
## The aumbry's ring is that same walk, left where the pyx left it.
## The piscina's ring is that same walk, left where the aumbry left it.
## The sedilia's ring is that same walk, left where the piscina left it.
## The credence's ring is that same walk, left where the sedilia left it.
## The reredos leaves that walk except at (9,10), which is closed. The ring
## steps through (8,11), (9,11), and the lift so every ring tile is a corridor.
## The predella also steps around (8,10), through (7,11).
## The dossal also steps around (10,10), through (11,11) and the lift.
## The retable keeps that walk. (10,10), (8,10), and (9,10) stay closed.
## The tester keeps that walk. There is no new closure.
## The riddel keeps that walk. There is no new closure.
## The frontal keeps that walk except at (7,10), which is closed.
## The ring steps through (6,11), which was already open.
## The pall keeps that walk except at (21,4), which is closed.
## (21,4) has no already-open detour, so the recorded walk is open between (21,3) and (21,5).
## The herse keeps that walk except at (21,5), which is closed.
## (21,5) has no already-open detour, so the recorded walk is open between (21,3) and (21,6).
## The catafalque keeps that walk except at (21,6), which is closed.
## (21,6) has no already-open detour, so the recorded walk is open between (21,3) and (21,7).
## The bier keeps that walk except at (21,7), which is closed.
## (21,7) has no already-open detour, so the recorded walk is open between (21,3) and (21,8).
## The cerecloth keeps that walk except at (21,8), which is closed.
## (21,8) has no already-open detour, so the recorded walk is open between (21,3) and (21,9).
## The hearse keeps that walk except at (21,9), which is closed.
## (21,9) has no already-open detour, so the recorded walk is open between (21,3) and (21,10).
## The shroud keeps that walk except at (21,10), which is closed.
## Closing (21,10) keeps the 19-step survey at 120 oil, so no new cell is opened.
## (22,10), (21,11), and (21,9) are walls, and the walk continues through (20,10).
## The recorded walk is open between (21,3) and (20,10).
## The pyre keeps that walk except at (20,10), which is closed.
## Closing (20,10) keeps the 19-step survey at 120 oil, so no new cell is opened.
## (21,10), (20,11), and (20,9) are walls, and the walk continues through (19,10).
## The recorded walk is open between (21,3) and (19,10).
## The cenotaph keeps that walk except at (19,10), which is closed.
## Closing (19,10) alone surveys at 176 oil: (19,11) is open floor and
## (19,12) is a crack, so (19,10) is a pass-through. Opening (18,11)
## restores the same 19 steps. The new crack at (43,15) stays a leaf,
## so the survey is 122 oil. (20,11) and (20,9) stay walls.
## The recorded walk drops (19,10) and is open between (21,3) and (18,10).
## The winding keeps that walk except at (18,10), which is closed.
## Closing (18,10) alone surveys at 178 oil: (18,11) and (17,10) are open,
## so (18,10) is a pass-through. Opening (17,11) restores the same 19 steps.
## The new crack at (44,15) stays a leaf, so the survey is 124 oil.
## No one-, two-, or three-cell opening returns that survey to 122
## while the path stays 19 steps. (18,11) stays open.
## (19,10), (20,10), and (21,4) through (21,10) stay closed.
## The recorded walk drops (18,10) and is open between (21,3) and (17,10).
## The charnel keeps that walk except at (17,10), which is closed.
## Closing (17,10) alone surveys at 180 oil: (17,11) and (16,10) are open,
## so (17,10) is a pass-through. Opening (16,11) restores the same 19 steps.
## The new crack at (45,15) stays a leaf, so the survey is 126 oil.
## No one-, two-, or three-cell opening returns a lower survey
## while the path stays 19 steps. (17,11) and (18,11) stay open.
## (18,10), (19,10), (20,10), and (21,4) through (21,10) stay closed.
## The recorded walk drops (17,10) and is open between (21,3) and (16,10).
## The sepulchre keeps that walk except at (16,10), which is closed.
## Closing (16,10) alone surveys at 182 oil: (16,11) and (15,10) are open,
## so (16,10) is a pass-through. Opening (15,11) restores the same 19 steps.
## The new crack at (46,15) stays a leaf, so the survey is 128 oil.
## No one-, two-, or three-cell opening returns a lower survey
## while the path stays 19 steps. (16,11), (17,11), and (18,11) stay open.
## (17,10), (18,10), (19,10), (20,10), and (21,4) through (21,10) stay closed.
## The recorded walk drops (16,10) and is open between (21,3) and (15,10).
## The vault keeps that walk except at (15,10), which is closed.
## Closing (15,10) alone surveys at 184 oil: (15,11) and (14,10) are open,
## so (15,10) is a pass-through. Opening (14,11) restores the same 19 steps.
## The new crack at (47,15) stays a leaf, so the survey is 130 oil.
## No one-, two-, or three-cell opening returns a lower survey
## while the path stays 19 steps. (15,11), (16,11), (17,11), and (18,11) stay open.
## (16,10), (17,10), (18,10), (19,10), (20,10), and (21,4) through (21,10) stay closed.
## The recorded walk drops (15,10) and is open between (21,3) and (14,10).
## The cairn keeps that walk except at (14,10), which is closed.
## Closing (14,10) alone surveys at 186 oil: (14,11) and (13,10) are open,
## so (14,10) is a pass-through. Opening (13,11) restores the same 19 steps.
## The new crack at (48,15) stays a leaf, so the survey is 132 oil.
## No one-, two-, or three-cell opening returns a lower survey
## while the path stays 19 steps. (14,11), (15,11), (16,11), (17,11), and (18,11) stay open.
## (15,10), (16,10), (17,10), (18,10), (19,10), (20,10), and (21,4) through (21,10) stay closed.
## The recorded walk drops (14,10) and is open between (21,3) and (13,10).
## The columbarium keeps that walk except at (13,10), which is closed.
## Closing (13,10) alone surveys at 188 oil: (13,11) and (12,10) are open,
## so (13,10) is a pass-through. Opening (12,11) restores the same 19 steps.
## The new crack at (49,15) stays a leaf, so the survey is 134 oil.
## No one-, two-, or three-cell opening returns a lower survey
## while the path stays 19 steps. (13,11), (14,11), (15,11), (16,11), (17,11), and (18,11) stay open.
## (14,10) through (21,10) and (21,4) through (21,10) stay closed.
## The recorded walk drops (13,10) and is open between (21,3) and (12,10).
## The loculus keeps that walk except at (12,10), which is closed.
## (11,11) is already open, so the tour steps (12,11), (11,11), (11,10)
## and closing (12,10) does not raise the survey. No new cell is opened.
## The new crack at (50,15) stays a leaf, so the survey is 136 oil.
## No one-, two-, or three-cell opening returns a lower survey
## while the path stays 19 steps. (12,11) stays the one-cell detour and stays off the ring.
## (13,10) through (21,10) and (21,4) through (21,10) stay closed.
## The recorded walk drops (12,10) and is open between (21,3) and (11,10).
## The arcosolium keeps that walk except at (11,10), which is closed.
## (11,10) is a dead end off (11,11). Closing it keeps the 19-step path
## and lowers the survey from the crack-only 138 to 136. No new cell is opened.
## The new crack at (51,15) stays a leaf. Adding only that crack surveys at 138 oil.
## No one-, two-, or three-cell opening returns a lower survey
## while the path stays 19 steps. (12,11) stays the one-cell detour and stays off the ring.
## (11,10) through (21,10) and (21,4) through (21,10) stay closed.
## The recorded walk drops (11,10) and is open between (21,3) and (11,11).
## A census is accepted only when every corridor and hazard is marked truly
## and no tile is marked as something it is not.

const SMALL_FLASK_OIL := 24
const LARGE_FLASK_OIL := 120
const LARGE_FLASK_COST := 40
const MOVE_OIL := 1
const HIT_OIL := 3
const CORRIDOR_VALUE := 3
const HAZARD_VALUE := 8
const LOOP_VALUE := 15

const TOWN_LINE := "Arrows turn and step, Q and E strafe, M marks the tile you face, and Space waits out the warden's swing."
const RATE_CARD := "A true corridor pays 3. A true hazard pays 8. The cellar's east square, the cistern ring, the cloister walk, the crypt ring, the ossuary ring, the reliquary ring, the undercroft ring, the well ring, the scriptorium ring, the binding ring, the chart room ring, the bell loft ring, the clock room ring, the font ring, the apse ring, the choir ring, the rood ring, the crossing ring, the transept ring, the ambulatory ring, the chevet ring, the retrochoir ring, the lady chapel ring, the feretory ring, the chantry ring, the sacristy ring, the pyx ring, the aumbry ring, the piscina ring, the sedilia ring, the credence ring, the reredos ring, the predella ring, the dossal ring, the retable ring, the tester ring, the riddel ring, the frontal ring, the pall ring, the herse ring, the catafalque ring, the bier ring, the cerecloth ring, the hearse ring, the shroud ring, the pyre ring, the cenotaph ring, the winding ring, the charnel ring, the sepulchre ring, the vault ring, the cairn ring, the columbarium ring, the loculus ring, and the arcosolium ring each pay 15 only when every tile of that ring is marked corridor. A false mark pays nothing."

const CELLAR_RECORD := "Record every corridor, both hazard cracks, and the east square."
const CISTERN_RECORD := "Record every corridor, the three seep cracks, and the cistern ring around the pit."
const CLOISTER_RECORD := "Record every corridor, the four cinder cracks, and the cloister walk around the garth."
const CRYPT_RECORD := "Record every corridor, the five ash cracks, and the crypt ring around the tomb."
const OSSUARY_RECORD := "Record every corridor, the six chalk cracks, and the ossuary ring around the stack."
const RELIQUARY_RECORD := "Record every corridor, the seven nail cracks, and the reliquary ring around the case."
const UNDERCROFT_RECORD := "Record every corridor, the eight salt cracks, and the undercroft ring around the trough."
const WELL_RECORD := "Record every corridor, the nine well cracks, and the well ring around the shaft."
const SCRIPTORIUM_RECORD := "Record every corridor, the ten ink cracks, and the scriptorium ring around the desk."
const BINDING_RECORD := "Record every corridor, the eleven glue cracks, and the binding ring around the press."
const CHART_RECORD := "Record every corridor, the twelve chart cracks, and the chart room ring around the table."
const BELL_RECORD := "Record every corridor, the thirteen bell cracks, and the bell loft ring around the bell."
const CLOCK_RECORD := "Record every corridor, the fourteen clock cracks, and the ring around the clock."
const FONT_RECORD := "Record every corridor, the fifteen font cracks, and the ring around the font."
const APSE_RECORD := "Record every corridor, the sixteen apse cracks, and the ring around the apse."
const CHOIR_RECORD := "Record every corridor, the seventeen choir cracks, and the ring around the choir."
const ROOD_RECORD := "Record every corridor, the eighteen rood cracks, and the ring around the rood."
const CROSSING_RECORD := "Record every corridor, the nineteen crossing cracks, and the ring around the crossing."
const TRANSEPT_RECORD := "Record every corridor, the nineteen transept cracks, and the ring around the transept."
const AMBULATORY_RECORD := "Record every corridor, the twenty ambulatory cracks, and the ring around the ambulatory."
const CHEVET_RECORD := "Record every corridor, the twenty-one chevet cracks, and the ring around the chevet."
const RETROCHOIR_RECORD := "Record every corridor, the twenty-two retrochoir cracks, and the ring around the retrochoir."
const LADY_CHAPEL_RECORD := "Record every corridor, the twenty-three lady-chapel cracks, and the ring around the lady chapel."
const FERETORY_RECORD := "Record every corridor, the twenty-four feretory cracks, and the ring around the feretory."
const CHANTRY_RECORD := "Record every corridor, the twenty-five chantry cracks, and the ring around the chantry."
const SACRISTY_RECORD := "Record every corridor, the twenty-six sacristy cracks, and the ring around the sacristy."
const PYX_RECORD := "Record every corridor, the twenty-seven pyx cracks, and the ring around the pyx."
const AUMBRY_RECORD := "Record every corridor, the twenty-eight aumbry cracks, and the ring around the aumbry."
const PISCINA_RECORD := "Record every corridor, the twenty-nine piscina cracks, and the ring around the piscina."
const SEDILIA_RECORD := "Record every corridor, the thirty sedilia cracks, and the ring around the sedilia."
const CREDENCE_RECORD := "Record every corridor, the thirty-one credence cracks, and the ring around the credence."
const REREDOS_RECORD := "Record every corridor, the thirty-two reredos cracks, and the ring around the reredos."
const PREDELLA_RECORD := "Record every corridor, the thirty-three predella cracks, and the ring around the predella."
const DOSSAL_RECORD := "Record every corridor, the thirty-four dossal cracks, and the ring around the dossal."
const RETABLE_RECORD := "Record every corridor, the thirty-five retable cracks, and the ring around the retable."
const TESTER_RECORD := "Record every corridor, the thirty-six tester cracks, and the ring around the tester."
const RIDDEL_RECORD := "Record every corridor, the thirty-seven riddel cracks, and the ring around the riddel."
const FRONTAL_RECORD := "Record every corridor, the thirty-eight frontal cracks, and the ring around the frontal."
const PALL_RECORD := "Record every corridor, the thirty-nine pall cracks, and the ring around the pall."
const HERSE_RECORD := "Record every corridor, the forty herse cracks, and the ring around the herse."
const CATAFALQUE_RECORD := "Record every corridor, the forty-one catafalque cracks, and the ring around the catafalque."
const BIER_RECORD := "Record every corridor, the forty-two bier cracks, and the ring around the bier."
const CERECLOTH_RECORD := "Record every corridor, the forty-three cerecloth cracks, and the ring around the cerecloth."
const HEARSE_RECORD := "Record every corridor, the forty-four hearse cracks, and the ring around the hearse."
const SHROUD_RECORD := "Record every corridor, the forty-five shroud cracks, and the ring around the shroud."
const PYRE_RECORD := "Record every corridor, the forty-six pyre cracks, and the ring around the pyre."
const CENOTAPH_RECORD := "Record every corridor, the forty-seven cenotaph cracks, and the ring around the cenotaph."
const WINDING_RECORD := "Record every corridor, the forty-eight winding cracks, and the ring around the winding."
const CHARNEL_RECORD := "Record every corridor, the forty-nine charnel cracks, and the ring around the charnel."
const SEPULCHRE_RECORD := "Record every corridor, the fifty sepulchre cracks, and the ring around the sepulchre."
const VAULT_RECORD := "Record every corridor, the fifty-one vault cracks, and the ring around the vault."
const CAIRN_RECORD := "Record every corridor, the fifty-two cairn cracks, and the ring around the cairn."
const COLUMBARIUM_RECORD := "Record every corridor, the fifty-three columbarium cracks, and the ring around the columbarium."
const LOCULUS_RECORD := "Record every corridor, the fifty-four loculus cracks, and the ring around the loculus."
const ARCOSOLIUM_RECORD := "Record every corridor, the fifty-five arcosolium cracks, and the ring around the arcosolium."

const CELLAR_ROWS: PackedStringArray = [
	"#############",
	"#S...#......#",
	"#.##.#.####.#",
	"#.#H...#..#.#",
	"#.####.#..#.#",
	"#...E..#....#",
	"###.##.######",
	"#...#......H#",
	"#.###.#####.#",
	"#.........L.#",
	"#############",
]

# The pit is the 3x3 block of '*' at columns 4-6, rows 4-6.
# The paid ring is the 16-tile corridor cycle around that pit.
const CISTERN_ROWS: PackedStringArray = [
	"###############",
	"#S............#",
	"#.###########.#",
	"#.#.........#.#",
	"#.#.***.....#.#",
	"#.#.***.....#.#",
	"#.#.***.....#.#",
	"#.#.........#.#",
	"#............L#",
	"#..E..H..H.H..#",
	"###############",
]

# The garth is the 5x2 block of '+' at columns 4-8, rows 4-5.
# The paid walk is the 18-tile corridor cycle around that garth.
const CLOISTER_ROWS: PackedStringArray = [
	"################",
	"#S.............#",
	"#.############.#",
	"#.#.......####.#",
	"#.#.+++++.####.#",
	"#.#.+++++.####.#",
	"#.#.......####.#",
	"#..E..........L#",
	"#.H.H.H.H......#",
	"################",
]

# The tomb is the 4x4 block of '=' at columns 4-7, rows 3-6.
# The paid ring is the 20-tile corridor cycle around that tomb.
# Columns at x=2 and x=10, rows 3-6, are ordinary walls.
const CRYPT_ROWS: PackedStringArray = [
	"###############",
	"#S............#",
	"#.............#",
	"#.#.====..#...#",
	"#.#.====..#...#",
	"#.#.====..#...#",
	"#.#.====..#...#",
	"#.............#",
	"#............L#",
	"#H.H.H..E..H.H#",
	"###############",
]

# The stack is the 6x3 block of 'x' at columns 4-9, rows 3-5.
# The paid ring is the 22-tile corridor cycle around that stack.
const OSSUARY_ROWS: PackedStringArray = [
	"#################",
	"#S..............#",
	"###........####.#",
	"###.xxxxxx.####.#",
	"###.xxxxxx.####.#",
	"###.xxxxxx.####.#",
	"###........####L#",
	"###........####.#",
	"#H.H.H..E..H.H.H#",
	"#################",
]

# The case is the 3x5 block of 'R' at columns 5-7, rows 3-7.
# The paid ring is the 20-tile corridor cycle around that case.
# The piers beside the case and the lift shaft are ordinary walls.
const RELIQUARY_ROWS: PackedStringArray = [
	"################",
	"#S##############",
	"#..............#",
	"##.#.RRR.#####.#",
	"##...RRR.###H..#",
	"##H#.RRR.###...#",
	"##.#.RRR.###H..#",
	"##.#.RRR.#####L#",
	"##H......#######",
	"##.......#######",
	"##.H..E.H..H..##",
	"################",
]

# The trough is the 3x7 block of 'B' at columns 6-8, rows 3-9.
# The paid ring is the 24-tile corridor cycle around that trough.
# The ribs beside the trough and the south drain are ordinary walls.
const UNDERCROFT_ROWS: PackedStringArray = [
	"###############",
	"#S............#",
	"#####.....###.#",
	"#####.BBB.###H#",
	"#.H.#.BBB.###.#",
	"#H....BBB.###H#",
	"#.H.#.BBB.###.#",
	"#####.BBB.###H#",
	"#####.BBB....L#",
	"#####.BBB.#####",
	"#####.....#####",
	"#####H.E.H#####",
	"###############",
]

# The shaft is the 5x6 block of 'W' at columns 5-9, rows 3-8.
# The paid ring is the 26-tile corridor cycle around that shaft.
# The north gallery and the east stair are ordinary floors. The piers are walls.
const WELL_ROWS: PackedStringArray = [
	"#################",
	"#S..............#",
	"####.......####.#",
	"####.WWWWW.H###.#",
	"###H.WWWWW.####.#",
	"####.WWWWW.H###.#",
	"###H.WWWWW.####L#",
	"####.WWWWW.H#####",
	"###H.WWWWW.######",
	"####.......H#####",
	"######HEH########",
	"#################",
]

# The desk is an L. The head is the 4x4 block of 'D' at columns 6-9, rows 3-6.
# The stem is the 2x4 block of 'D' at columns 6-7, rows 7-10.
# The paid ring is the 28-tile corridor cycle around that desk.
# The west aisle and the east run are ordinary floors. The piers are walls.
const SCRIPTORIUM_ROWS: PackedStringArray = [
	"##################",
	"#S....############",
	"#####......#######",
	"##..H.DDDD.H######",
	"#...#.DDDD.#######",
	"##..H.DDDD......L#",
	"##..H.DDDD.#######",
	"##..#.DD...#######",
	"##..H.DD.H########",
	"##..#.DD.#########",
	"##..H.DD.H########",
	"#####....#########",
	"#####HEH##########",
	"##################",
]

# The press is the 3x5 block of 'P' at columns 5-7, rows 3-7.
# The paid ring is the 20-tile corridor cycle around that press.
# The west aisle and the south landing are ordinary floors. The piers are walls.
const BINDING_ROWS: PackedStringArray = [
	"################",
	"#S.............#",
	"#.#......#####.#",
	"#.#..PPP.#####.#",
	"#.#..PPP.#####.#",
	"#....PPP.#####.#",
	"#.#..PPP.#####.#",
	"#.#..PPP.#####L#",
	"#.#......#####.#",
	"#.#..H..H..###.#",
	"#..E..H..H..#..#",
	"#H.H.H.H.H.H.H##",
	"################",
]

# The table is the 2x8 bar of 'T' at columns 9-10, rows 2-9.
# The paid ring is the 24-tile corridor cycle around that table.
# The west aisle and the south landing are ordinary floors. The piers are walls.
const CHART_ROWS: PackedStringArray = [
	"#################",
	"#S..............#",
	"#.######.TT.##..#",
	"#H######.TT.##H.#",
	"#.######.TT.##..#",
	"#H######.TT.##..#",
	"#.######.TT.##HL#",
	"#H######.TT.##..#",
	"#.######.TT.##H.#",
	"#H.......TT.....#",
	"#..HEH.H....H.H.#",
]

# The bell is the 4x4 block of 'Y' at columns 6-9, rows 4-7.
# The paid ring is the 20-tile corridor cycle around that bell.
# The west aisle and the north landing are ordinary floors. The piers are walls.
const BELL_ROWS: PackedStringArray = [
	"###############",
	"#S............#",
	"#.###########.#",
	"#H###......##.#",
	"#.###.YYYY.##.#",
	"#H###.YYYY.##.#",
	"#.###.YYYY.##.#",
	"#H###.YYYY.##.#",
	"#.###........L#",
	"#H###........H#",
	"#.###.......H.#",
	"#H.H.H.HEH.H.H#",
	"#.#############",
	"###############",
]

# The clock is the 5x4 block of 'K' at columns 6-10, rows 4-7.
# The paid ring is the 22-tile corridor cycle around that clock.
# The west aisle and the north landing are ordinary floors. The piers are walls.
const CLOCK_ROWS: PackedStringArray = [
	"################",
	"#S.............#",
	"#.############.#",
	"#H###.......##.#",
	"#.###.KKKKK.##.#",
	"#H###.KKKKK.##.#",
	"#.###.KKKKK.##.#",
	"#H###.KKKKK.##.#",
	"#.###.........H#",
	"#H###.........H#",
	"#.###....L...HH#",
	"#H.H.H.H..E.H.H#",
	"#.##############",
	"#.##############",
	"################",
]

# The font is the 4x6 block of 'N' at columns 7-10, rows 4-9.
# The paid ring is the 24-tile corridor cycle around that font.
# The west aisle and the north landing are ordinary floors. The piers are walls.
const FONT_ROWS: PackedStringArray = [
	"#################",
	"#S..............#",
	"#.#############.#",
	"#H####......###.#",
	"#.####.NNNN.###.#",
	"#H####.NNNN.###.#",
	"#.####.NNNN.###.#",
	"#H####.NNNN.###.#",
	"#.####.NNNN.###H#",
	"#H####.NNNN.###H#",
	"#.####......###.#",
	"#H........L...HH#",
	"#..H.H.H.E...H.H#",
	"#H###############",
	"#.###############",
	"#################",
]

# The apse is the 5x6 block of 'A' at columns 7-11, rows 4-9.
# The paid ring is the 26-tile corridor cycle around that apse.
# The west aisle and the north landing are ordinary floors. The piers are walls.
const APSE_ROWS: PackedStringArray = [
	"##################",
	"#S...............#",
	"#.##############.#",
	"#H####.......###.#",
	"#.####.AAAAA.###.#",
	"#H####.AAAAA.###H#",
	"#.####.AAAAA.###.#",
	"#H####.AAAAA.###.#",
	"#.####.AAAAA.###H#",
	"#H####.AAAAA.###H#",
	"#.####.......###.#",
	"#H........L....HH#",
	"#..H.H.H.E....H.H#",
	"#H################",
	"#.################",
	"##################",
	"##################",
]

# The choir is the 6x6 block of 'C' at columns 7-12, rows 4-9.
# The paid ring is the 28-tile corridor cycle around that choir.
# The west aisle and the north landing are ordinary floors. The piers are walls.
const CHOIR_ROWS: PackedStringArray = [
	"###################",
	"#S................#",
	"#.###############.#",
	"#H####........###H#",
	"#.####.CCCCCC.###.#",
	"#H####.CCCCCC.###H#",
	"#.####.CCCCCC.###H#",
	"#H####.CCCCCC.###.#",
	"#.####.CCCCCC.###H#",
	"#H####.CCCCCC.###H#",
	"#.####........###.#",
	"#H........L......H#",
	"#..H.H.H.E.....H.H#",
	"#H#################",
	"#.#################",
	"###################",
	"###################",
	"###################",
]

# The rood is the 7x6 block of 'R' at columns 7-13, rows 4-9.
# The paid ring is the 30-tile corridor cycle around that rood.
# The west aisle and the north landing are ordinary floors. The piers are walls.
# (15,11), (16,11), and (17,11) are closed into the east pier so the survey fits in 120 oil.
const ROOD_ROWS: PackedStringArray = [
	"####################",
	"#S.................#",
	"#.################.#",
	"#H####.........###H#",
	"#.####.RRRRRRR.###.#",
	"#H####.RRRRRRR.###H#",
	"#.####.RRRRRRR.###H#",
	"#H####.RRRRRRR.###H#",
	"#.####.RRRRRRR.###H#",
	"#H####.RRRRRRR.###H#",
	"#.####.........###.#",
	"#H........L....###H#",
	"#..H.H.H.E......H.H#",
	"#H##################",
	"#.##################",
	"####################",
	"####################",
	"####################",
	"####################",
]

# The crossing is the 8x6 block of 'X' at columns 7-14, rows 4-9.
# The paid ring is the 32-tile corridor cycle around that crossing.
# The west aisle and the north landing are ordinary floors. The piers are walls.
# (11,11) through (18,11) are closed into the east pier so the survey fits in 120 oil.
const CROSSING_ROWS: PackedStringArray = [
	"#####################",
	"#S..................#",
	"#.#################.#",
	"#H####..........###H#",
	"#.####.XXXXXXXX.###H#",
	"#H####.XXXXXXXX.###H#",
	"#.####.XXXXXXXX.###H#",
	"#H####.XXXXXXXX.###H#",
	"#.####.XXXXXXXX.###H#",
	"#H####.XXXXXXXX.###H#",
	"#.####..........###.#",
	"#H........L########H#",
	"#..H.H.H.E.......H.H#",
	"#H###################",
	"#.###################",
	"#####################",
	"#####################",
	"#####################",
	"#####################",
	"#####################",
]

# The transept is the 9x6 block of 'V' at columns 7-15, rows 4-9.
# The paid ring is the 34-tile corridor cycle around that transept.
# The west aisle down to the lift path, and the north landing, are ordinary floors. The piers are walls.
# (11,11) through (19,11) are closed into the east pier. Left open, that landing
# surveys at 134 oil. (1,12), (1,13), and (1,14) are ordinary walls. (1,13) is
# no longer a crack. The swing-free survey costs 120 oil.
const TRANSEPT_ROWS: PackedStringArray = [
	"######################",
	"#S...................#",
	"#.##################.#",
	"#H####...........###H#",
	"#.####.VVVVVVVVV.###H#",
	"#H####.VVVVVVVVV.###H#",
	"#.####.VVVVVVVVV.###H#",
	"#H####.VVVVVVVVV.###H#",
	"#.####.VVVVVVVVV.###H#",
	"#H####.VVVVVVVVV.###H#",
	"#.####...........###H#",
	"#H........L#########H#",
	"##.H.H.H.E........H.H#",
	"######################",
	"######################",
	"######################",
	"######################",
	"######################",
	"######################",
	"######################",
	"######################",
]

# The ambulatory is the 10x6 block of 'U' at columns 7-16, rows 4-9.
# The paid ring is the 36-tile corridor cycle around that ambulatory.
# The west aisle down to the lift path is ordinary floor. The piers are walls.
# (11,11) through (20,11) are closed into the east pier. The north landing
# from (4,1) through (21,1) is closed as well. Left open, that landing
# surveyed at 124 oil. (1,12), (1,13), and (1,14) stay ordinary walls.
# (20,10) is pier wall; the crack sits on the new east wall at (21,10).
# The swing-free survey costs 120 oil.
const AMBULATORY_ROWS: PackedStringArray = [
	"#######################",
	"#S..###################",
	"#.###################H#",
	"#H####............###H#",
	"#.####.UUUUUUUUUU.###H#",
	"#H####.UUUUUUUUUU.###H#",
	"#.####.UUUUUUUUUU.###H#",
	"#H####.UUUUUUUUUU.###H#",
	"#.####.UUUUUUUUUU.###H#",
	"#H####.UUUUUUUUUU.###H#",
	"#.####............###H#",
	"#H........L##########H#",
	"##.H.H.H.E.........H.H#",
	"#######################",
	"#######################",
	"#######################",
	"#######################",
	"#######################",
	"#######################",
	"#######################",
	"#######################",
]

# The chevet is the 11x6 block of 'Q' at columns 7-17, rows 4-9.
# The paid ring is the 38-tile corridor cycle around that chevet.
# Q was unused on every earlier floor. The sheet grows the ambulatory one
# column to the east. Cracks that sat on x=21 move to x=22. The new crack
# is (22,13). (11,11) through (21,11) are closed into the east pier, and
# (4,1) through (22,1) are closed on the north landing. With that pier solid
# beside the chevet, a swing-free survey costs 126 oil. (19,3), (20,3), and
# (21,3) stay open as the north passage from the ring to the east cracks, so
# the survey costs 120. No further ordinary floor is closed. (1,12), (1,13),
# and (1,14) stay ordinary walls. (2,1) and (3,1) stay open floor.
const CHEVET_ROWS: PackedStringArray = [
	"########################",
	"#S..####################",
	"#.####################H#",
	"#H####................H#",
	"#.####.QQQQQQQQQQQ.###H#",
	"#H####.QQQQQQQQQQQ.###H#",
	"#.####.QQQQQQQQQQQ.###H#",
	"#H####.QQQQQQQQQQQ.###H#",
	"#.####.QQQQQQQQQQQ.###H#",
	"#H####.QQQQQQQQQQQ.###H#",
	"#.####.............###H#",
	"#H........L###########H#",
	"##.H.H.H.E.........H..H#",
	"######################H#",
	"########################",
	"########################",
	"########################",
	"########################",
	"########################",
	"########################",
	"########################",
]


# The retrochoir is the 12x6 block of 'O' at columns 7-18, rows 4-9.
# The paid ring is the 40-tile corridor cycle around that retrochoir.
# O was unused on every earlier floor. P is the binding press, so it stays unused.
# The sheet grows the chevet one column to the east. Cracks that sat on x=22
# move to x=23. The new crack is (23,14). (11,11) through (22,11) are closed
# into the east pier, and (4,1) through (23,1) are closed on the north landing.
# (19,3), (20,3), and (21,3) stay open. With (22,3) still wall, a swing-free
# survey costs 136 oil. (22,3) stays open as one more passage cell, which
# brings the survey to 126. The ordinary floors (2,12) and (11,12) through
# (18,12) are closed as well, so the survey costs 120. (1,12), (1,13), and
# (1,14) stay ordinary walls. (2,1) and (3,1) stay open floor. (19,12) stays
# a crack.
const RETROCHOIR_ROWS: PackedStringArray = [
	"#########################",
	"#S..#####################",
	"#.#####################H#",
	"#H####.................H#",
	"#.####.OOOOOOOOOOOO.###H#",
	"#H####.OOOOOOOOOOOO.###H#",
	"#.####.OOOOOOOOOOOO.###H#",
	"#H####.OOOOOOOOOOOO.###H#",
	"#.####.OOOOOOOOOOOO.###H#",
	"#H####.OOOOOOOOOOOO.###H#",
	"#.####..............###H#",
	"#H........L############H#",
	"###H.H.H.E.########H...H#",
	"#######################H#",
	"#######################H#",
	"#########################",
	"#########################",
	"#########################",
	"#########################",
	"#########################",
	"#########################",
]

# The lady chapel is the 13x6 block of 'M' at columns 7-19, rows 4-9.
# The paid ring is the 42-tile corridor cycle around that chapel.
# M is the next unused letter. The church floors walk backward through unused
# letters (X, V, U, Q, O). N is the font, so M is next. O is the retrochoir,
# P is the binding press, and Q is the chevet.
# The sheet grows the retrochoir one column to the east. Cracks that sat on
# x=23 move to x=24. (19,12) stays. The new crack is (24,15). (11,11) through
# (23,11) start closed into the east pier, and (4,1) through (24,1) are closed
# on the north landing. (2,1) and (3,1) stay open. (19,3) through (22,3) stay
# open. With (23,3) still wall and the south gallery open, a swing-free survey
# costs 142 oil. (23,3) stays open as the next passage cell, which brings the
# survey to 132. Closing (2,12) and (11,12) through (18,12) brings it to 126.
# No other ordinary floor lowers that while the pier stays solid. (19,11) is
# opened so the gallery meets the south ring, which brings the survey to 116.
# (4,12) is then closed, so the survey costs 120. (1,12), (1,13), and (1,14)
# stay ordinary walls. Start, lift, and warden stay on (1,1), (10,11), and (9,12).
const LADY_CHAPEL_ROWS: PackedStringArray = [
	"##########################",
	"#S..######################",
	"#.######################H#",
	"#H####..................H#",
	"#.####.MMMMMMMMMMMMM.###H#",
	"#H####.MMMMMMMMMMMMM.###H#",
	"#.####.MMMMMMMMMMMMM.###H#",
	"#H####.MMMMMMMMMMMMM.###H#",
	"#.####.MMMMMMMMMMMMM.###H#",
	"#H####.MMMMMMMMMMMMM.###H#",
	"#.####...............###H#",
	"#H........L########.####H#",
	"###H#H.H.E.########H....H#",
	"########################H#",
	"########################H#",
	"########################H#",
	"##########################",
	"##########################",
	"##########################",
	"##########################",
	"##########################",
]

# The feretory is the 14x6 block of 'J' at columns 7-20, rows 4-9.
# The paid ring is the 44-tile corridor cycle around that feretory.
# J is the next free letter walking backward from M. L is the lift and K is
# the clock, so neither is free. M stays the lady chapel. O is the retrochoir,
# P is the binding press, Q is the chevet, and N is the font.
# The sheet grows the lady chapel one column to the east. Cracks that sat on
# x=24 move to x=25. (19,12) stays. The new crack is (25,16). (4,1) through
# (25,1) are closed on the north landing. (2,1) stays open. (19,3) through
# (23,3) stay open, and (24,3) is the new passage from the ring to the east
# cracks. With the lady chapel's south-gallery closures and the pier door
# carried forward, a swing-free survey costs 126 oil. Closing the next unused
# south-gallery cell (6,12) raises it to 128, so (6,12) stays open. Opening
# (4,12) brings the survey to 122. Closing (3,1) brings it to 120. (1,12),
# (1,13), and (1,14) stay ordinary walls. Start, lift, and warden stay on
# (1,1), (10,11), and (9,12).
const FERETORY_ROWS: PackedStringArray = [
	"###########################",
	"#S.########################",
	"#.#######################H#",
	"#H####...................H#",
	"#.####.JJJJJJJJJJJJJJ.###H#",
	"#H####.JJJJJJJJJJJJJJ.###H#",
	"#.####.JJJJJJJJJJJJJJ.###H#",
	"#H####.JJJJJJJJJJJJJJ.###H#",
	"#.####.JJJJJJJJJJJJJJ.###H#",
	"#H####.JJJJJJJJJJJJJJ.###H#",
	"#.####................###H#",
	"#H........L########.#####H#",
	"###H.H.H.E.########H.....H#",
	"#########################H#",
	"#########################H#",
	"#########################H#",
	"#########################H#",
	"###########################",
	"###########################",
	"###########################",
	"###########################",
]

# The chantry is the 14x6 block of 'I' at columns 7-20, rows 4-9.
# The paid ring is the same 44-tile corridor cycle the feretory walks.
# I is the next free letter walking backward from J. H is a crack, so it is
# not free. J stays the feretory. L is the lift, K is the clock, M is the
# lady chapel, O is the retrochoir, P is the binding press, Q is the chevet,
# and N is the font.
# The sheet grows the feretory one column to the east. The shrine, the ring,
# the warden, the lift, the start, and the 19-step path stay on their cells.
# Cracks that sat on x=25 stay on x=25. The new crack is (26,16), on the new
# column, immediately east of (25,16). With the feretory's closures carried
# forward, including (6,12) open, (4,12) open, and (3,1) closed, and with
# (2,1) still open, a swing-free survey costs 122 oil. Closing (6,12) raises
# that survey to 126, so (6,12) stays open. No new cell brings the survey to
# 120. Closing a ring tile or the warden's east swing would, and would break
# the sheet. (2,1) is closed so the survey costs 120. (1,12), (1,13), and
# (1,14) stay ordinary walls. Start, lift, and warden stay on (1,1), (10,11),
# and (9,12).
const CHANTRY_ROWS: PackedStringArray = [
	"############################",
	"#S##########################",
	"#.#######################H##",
	"#H####...................H##",
	"#.####.IIIIIIIIIIIIII.###H##",
	"#H####.IIIIIIIIIIIIII.###H##",
	"#.####.IIIIIIIIIIIIII.###H##",
	"#H####.IIIIIIIIIIIIII.###H##",
	"#.####.IIIIIIIIIIIIII.###H##",
	"#H####.IIIIIIIIIIIIII.###H##",
	"#.####................###H##",
	"#H........L########.#####H##",
	"###H.H.H.E.########H.....H##",
	"#########################H##",
	"#########################H##",
	"#########################H##",
	"#########################HH#",
	"############################",
	"############################",
	"############################",
	"############################",
]

# The sacristy is the 14x6 block of 'G' at columns 7-20, rows 4-9.
# The paid ring is the same 44-tile corridor cycle the chantry walks.
# G is the next free letter walking backward from I. H is a crack, so it is
# not free. I stays the chantry. J stays the feretory. L is the lift, K is
# the clock, M is the lady chapel, O is the retrochoir, P is the binding
# press, Q is the chevet, and N is the font. S and E are the start and the
# warden.
# The sheet grows the chantry one column to the east. The screen, the ring,
# the warden, the lift, the start, and the 19-step path stay on their cells.
# Cracks that sat on the chantry stay, except the dead-end (3,12). The new
# crack is (27,16), on the new column, immediately east of (26,16). With the
# chantry's closures carried forward, that single new crack surveys at 122
# oil. No new cell on the added column brings the survey to 120. Closing
# (6,12) or (4,12) raises it, and reopening (2,1) raises it. Closing a ring
# tile or the warden's east swing would bring it to 120 and would break the
# sheet. Closing (3,12) alone returns the survey to 120 but drops the crack
# count. (26,15) is opened as a crack between (25,15) and (26,16), which adds
# the crack back without lengthening the survey, so (3,12) is closed and
# (26,15) is the seam. (1,12), (1,13), and (1,14) stay ordinary walls. Start,
# lift, and warden stay on (1,1), (10,11), and (9,12).
const SACRISTY_ROWS: PackedStringArray = [
	"#############################",
	"#S###########################",
	"#.#######################H###",
	"#H####...................H###",
	"#.####.GGGGGGGGGGGGGG.###H###",
	"#H####.GGGGGGGGGGGGGG.###H###",
	"#.####.GGGGGGGGGGGGGG.###H###",
	"#H####.GGGGGGGGGGGGGG.###H###",
	"#.####.GGGGGGGGGGGGGG.###H###",
	"#H####.GGGGGGGGGGGGGG.###H###",
	"#.####................###H###",
	"#H........L########.#####H###",
	"####.H.H.E.########H.....H###",
	"#########################H###",
	"#########################H###",
	"#########################HH##",
	"#########################HHH#",
	"#############################",
	"#############################",
	"#############################",
	"#############################",
]

# The pyx is the 14x6 block of 'F' at columns 7-20, rows 4-9.
# The paid ring is the same 44-tile corridor cycle the sacristy walks.
# F is the next free letter walking backward from G. H is a crack, so it is
# not free. G stays the sacristy. I stays the chantry. J stays the feretory.
# L is the lift, K is the clock, M is the lady chapel, O is the retrochoir,
# P is the binding press, Q is the chevet, and N is the font. S and E are the
# start and the warden.
# The sheet grows the sacristy one column to the east. The press, the ring,
# the warden, the lift, the start, and the 19-step path stay on their cells.
# The sacristy's closures stay: (3,12) closed, (26,15) a crack, (2,1) and
# (3,1) closed, (6,12) and (4,12) open. The new crack is (28,16), on the new
# column, immediately east of (27,16). With those closures carried forward,
# that single new crack surveys at 122 oil. No new cell brings the survey to
# 120. Closing (6,12) raises it to 126. Closing (4,12) would bring it to 120,
# and so would closing a ring tile or the warden's east swing. (4,12), the
# ring, and the east swing stay open, because another way reaches 120.
# Reopening (2,1) raises the survey. Closing the dead-end crack (25,2) returns
# the survey to 120 and drops the count to 26. (27,15) is opened as a crack
# between (26,15) and (27,16), which adds the crack back without lengthening
# the survey. (1,12), (1,13), and (1,14) stay ordinary walls. Start, lift, and
# warden stay on (1,1), (10,11), and (9,12).
const PYX_ROWS: PackedStringArray = [
	"##############################",
	"#S############################",
	"#.############################",
	"#H####...................H####",
	"#.####.FFFFFFFFFFFFFF.###H####",
	"#H####.FFFFFFFFFFFFFF.###H####",
	"#.####.FFFFFFFFFFFFFF.###H####",
	"#H####.FFFFFFFFFFFFFF.###H####",
	"#.####.FFFFFFFFFFFFFF.###H####",
	"#H####.FFFFFFFFFFFFFF.###H####",
	"#.####................###H####",
	"#H........L########.#####H####",
	"####.H.H.E.########H.....H####",
	"#########################H####",
	"#########################H####",
	"#########################HHH##",
	"#########################HHHH#",
	"##############################",
	"##############################",
	"##############################",
	"##############################",
]

# The aumbry is the 14x6 block of 'Z' at columns 7-20, rows 4-9.
# The paid ring is the same 44-tile corridor cycle the pyx walks.
# Z is the next free letter walking backward from F. H is a crack, so it
# is not free. E is the warden. D is the scriptorium desk, C is the choir,
# B is the undercroft trough, and A is the apse. F stays the pyx. G stays
# the sacristy. I stays the chantry. J stays the feretory.
# The sheet grows the pyx one column to the east. The pyx, the ring, the
# warden, the lift, the start, and the 19-step path stay on their cells.
# The pyx's closures stay, except (4,12). (25,2) stays closed. (27,15),
# (26,15), and (28,16) stay cracks. (3,12) and (2,1) stay closed. (6,12)
# stays open. The new crack is (29,16), on the new column, immediately east
# of (28,16). With those closures carried forward, that single new crack
# surveys at 122 oil. No new cell brings the survey to 120. Closing (6,12)
# raises it to 126. Reopening (2,1) raises it. Closing a ring tile or the
# warden's east swing would bring it to 120 and would break the sheet.
# Every other legal cell fails, so (4,12) is closed and the survey is 120.
# (1,12), (1,13), and (1,14) stay ordinary walls. Start, lift, and warden
# stay on (1,1), (10,11), and (9,12).
const AUMBRY_ROWS: PackedStringArray = [
	"###############################",
	"#S#############################",
	"#.#############################",
	"#H####...................H#####",
	"#.####.ZZZZZZZZZZZZZZ.###H#####",
	"#H####.ZZZZZZZZZZZZZZ.###H#####",
	"#.####.ZZZZZZZZZZZZZZ.###H#####",
	"#H####.ZZZZZZZZZZZZZZ.###H#####",
	"#.####.ZZZZZZZZZZZZZZ.###H#####",
	"#H####.ZZZZZZZZZZZZZZ.###H#####",
	"#.####................###H#####",
	"#H........L########.#####H#####",
	"#####H.H.E.########H.....H#####",
	"#########################H#####",
	"#########################H#####",
	"#########################HHH###",
	"#########################HHHHH#",
	"###############################",
	"###############################",
	"###############################",
	"###############################",
]

# The piscina is the 14x6 block of '@' at columns 7-20, rows 4-9.
# The paid ring is the same 44-tile corridor cycle the aumbry walks.
# Y is the bell, so it is not free. Walking backward from Z, every letter
# is already bound: Z is the aumbry, X the crossing, W the well, V the
# transept, U the ambulatory, T the chart, S the start, R the reliquary
# and the rood, Q the chevet, P the binding, O the retrochoir, N the font,
# M the lady chapel, L the lift, K the clock, J the feretory, I the chantry,
# H a crack, G the sacristy, F the pyx, E the warden, D the scriptorium,
# C the choir, B the undercroft, and A the apse. The next free single
# survey glyph, walking backward past A, is '@'.
# The sheet grows the aumbry one column to the east. The aumbry, the ring,
# the warden, the lift, the start, and the 19-step path stay on their cells.
# The aumbry's closures stay. (4,12), (25,2), (3,12), (2,1), and (3,1) stay
# closed. (6,12) stays open. (29,16), (28,16), (27,15), and (26,15) stay
# cracks. The new crack is (30,16), on the new column, immediately east of
# (29,16). With those closures carried forward, that single new crack
# surveys at 122 oil. No new cell brings the survey to 120. Closing (6,12)
# raises it to 126. Reopening (2,1) or (4,12) raises it. Closing a ring tile
# or the warden's east swing would bring it to 120 and would break the sheet.
# Every other previously open cell surveys at 132 or more. The west swing
# surveys at 121. Closing the dead-end crack (5,12) returns the survey to
# 120 and drops the count to 28 cracks. Opening (28,15) as a crack puts the
# count back to 29 without adding oil, so (5,12) is closed and (28,15) is
# the seam. (1,12), (1,13), and (1,14) stay ordinary walls. Start, lift, and
# warden stay on (1,1), (10,11), and (9,12).
const PISCINA_ROWS: PackedStringArray = [
	"################################",
	"#S##############################",
	"#.##############################",
	"#H####...................H######",
	"#.####.@@@@@@@@@@@@@@.###H######",
	"#H####.@@@@@@@@@@@@@@.###H######",
	"#.####.@@@@@@@@@@@@@@.###H######",
	"#H####.@@@@@@@@@@@@@@.###H######",
	"#.####.@@@@@@@@@@@@@@.###H######",
	"#H####.@@@@@@@@@@@@@@.###H######",
	"#.####................###H######",
	"#H........L########.#####H######",
	"######.H.E.########H.....H######",
	"#########################H######",
	"#########################H######",
	"#########################HHHH###",
	"#########################HHHHHH#",
	"################################",
	"################################",
	"################################",
	"################################",
]

# The sedilia is the 14x6 block of '?' at columns 7-20, rows 4-9.
# The paid ring is the same 44-tile corridor cycle the piscina walks.
# '?' is the next free glyph walking backward from '@'. '@' is the piscina.
# H is a crack. Every letter A-Z is already bound, and '@' is bound.
# The sheet grows the piscina one column to the east. The piscina, the ring,
# the warden, the lift, the start, and the 19-step path stay on their cells.
# The piscina's closures stay. (5,12), (4,12), (25,2), (3,12), (2,1), and
# (3,1) stay closed. (30,16), (29,16), (28,16), (28,15), (27,15), and (26,15)
# stay cracks. The new crack is (31,16), on the new column, immediately east
# of (30,16). With those closures carried forward, that single new crack
# surveys at 122 oil. No new cell brings the survey to 120. Reopening (2,1)
# or (5,12) surveys at 124. Reopening (4,12) surveys at 132. Closing a ring
# tile or the warden's east swing would bring the survey to 120 and would
# break the sheet. The west swing surveys at 121. Every other previously
# open cell surveys at 132. Closing (6,12) is the only remaining cell that
# returns the survey to 120, and it keeps all thirty cracks, so (6,12) is
# closed. (1,12), (1,13), and (1,14) stay ordinary walls. Start, lift, and
# warden stay on (1,1), (10,11), and (9,12).
const SEDILIA_ROWS: PackedStringArray = [
	"#################################",
	"#S###############################",
	"#.###############################",
	"#H####...................H#######",
	"#.####.??????????????.###H#######",
	"#H####.??????????????.###H#######",
	"#.####.??????????????.###H#######",
	"#H####.??????????????.###H#######",
	"#.####.??????????????.###H#######",
	"#H####.??????????????.###H#######",
	"#.####................###H#######",
	"#H........L########.#####H#######",
	"#######H.E.########H.....H#######",
	"#########################H#######",
	"#########################H#######",
	"#########################HHHH####",
	"#########################HHHHHHH#",
	"#################################",
	"#################################",
	"#################################",
	"#################################",
]


# The credence is the 14x6 block of '>' at columns 7-20, rows 4-9.
# The paid ring is the same 44-tile corridor cycle the sedilia walks.
# '>' is the next free glyph walking backward from '?'. '?' is the sedilia
# and '@' is the piscina. H is a crack. '=' is the crypt, so it is not free.
# The sheet grows the sedilia one column to the east. The sedilia, the ring,
# the warden, the lift, the start, and the 19-step path stay on their cells.
# The sedilia's closures stay. (6,12), (5,12), (4,12), (25,2), (3,12), (2,1),
# and (3,1) stay closed. (31,16), (30,16), (29,16), (28,16), (28,15), (27,15),
# and (26,15) stay cracks. The new crack is (32,16), on the new column,
# immediately east of (31,16). No crack is closed. With those closures carried
# forward, that single new crack surveys at 122 oil, with 70 corridors and
# 31 cracks. No other previously open cell brings the survey to 120. Reopening
# (2,1) or (6,12) surveys at 124. Reopening (5,12) surveys at 130. Reopening
# (4,12) surveys at 132. The west swing surveys at 121. Closing (22,3) surveys
# at 132. A ring tile would bring the survey to 120 and would break the paid
# ring, so the ring stays open. The east swing (10,12) is the remaining cell
# that returns the survey to 120 and keeps every crack, so (10,12) is closed.
# (1,12), (1,13), and (1,14) stay ordinary walls. Start, lift, and warden stay
# on (1,1), (10,11), and (9,12).
const CREDENCE_ROWS: PackedStringArray = [
	"##################################",
	"#S################################",
	"#.################################",
	"#H####...................H########",
	"#.####.>>>>>>>>>>>>>>.###H########",
	"#H####.>>>>>>>>>>>>>>.###H########",
	"#.####.>>>>>>>>>>>>>>.###H########",
	"#H####.>>>>>>>>>>>>>>.###H########",
	"#.####.>>>>>>>>>>>>>>.###H########",
	"#H####.>>>>>>>>>>>>>>.###H########",
	"#.####................###H########",
	"#H........L########.#####H########",
	"#######H.E#########H.....H########",
	"#########################H########",
	"#########################H########",
	"#########################HHHH#####",
	"#########################HHHHHHHH#",
	"##################################",
	"##################################",
	"##################################",
	"##################################",
]

# The reredos is the 14x6 block of '<' at columns 7-20, rows 4-9.
# '<' is the next free glyph walking backward from '>'. '>' is the credence,
# '?' is the sedilia, and '@' is the piscina. '=' is the crypt, so it is not free.
# '<' is unused, and an unknown glyph inks as one wall.
# The sheet grows the credence one column to the east. The credence, the ring,
# the warden, the lift, the start, and the 19-step path stay on their cells.
# The credence's closures stay. (10,12), (6,12), (5,12), (4,12), (25,2), (3,12),
# (2,1), and (3,1) stay closed. (32,16), (31,16), (30,16), (29,16), (28,16),
# (28,15), (27,15), and (26,15) stay cracks. The new crack is (33,16), on the
# new column, immediately east of (32,16). No crack is closed. With those
# closures carried forward, that single new crack surveys at 122 oil, with
# 69 corridors and 32 cracks. No new cell brings the survey to 120. Reopening
# (2,1) or (6,12) or (10,12) surveys at 124. Reopening (5,12) surveys at 130.
# Reopening (4,12) surveys at 132. The west swing surveys at 121. Closing
# (22,3) surveys at 132. The only cells that return the survey to 120 are the
# ring tiles (21,4), (7,10), and (9,10). (21,4) and (7,10) stay open. (9,10)
# is closed so the survey is 120. The ring leaves that one cell and steps
# through (8,11), (9,11), and the lift, so the ring still pays.
# (1,12), (1,13), and (1,14) stay ordinary walls. Start, lift, and warden stay
# on (1,1), (10,11), and (9,12).
const REREDOS_ROWS: PackedStringArray = [
	"###################################",
	"#S#################################",
	"#.#################################",
	"#H####...................H#########",
	"#.####.<<<<<<<<<<<<<<.###H#########",
	"#H####.<<<<<<<<<<<<<<.###H#########",
	"#.####.<<<<<<<<<<<<<<.###H#########",
	"#H####.<<<<<<<<<<<<<<.###H#########",
	"#.####.<<<<<<<<<<<<<<.###H#########",
	"#H####.<<<<<<<<<<<<<<.###H#########",
	"#.####...#............###H#########",
	"#H........L########.#####H#########",
	"#######H.E#########H.....H#########",
	"#########################H#########",
	"#########################H#########",
	"#########################HHHH######",
	"#########################HHHHHHHHH#",
	"###################################",
	"###################################",
	"###################################",
	"###################################",
]

# The predella is the 14x6 block of '[' at columns 7-20, rows 4-9.
# '[' is the next free glyph after '<'. '<' is the reredos, '>' is the
# credence, '?' is the sedilia, and '=' is the crypt. '[' is unused, and an
# unknown glyph inks as one wall.
# The sheet grows the reredos one column east. That new column stays wall.
# The reredos, the warden, the lift, the start, and the 19-step path stay on
# their cells. (10,12), (6,12), (5,12), (4,12), (25,2), (3,12), (2,1), (3,1),
# and (9,10) stay closed. (8,12) stays open. (33,16) stays a crack. The new
# crack is (29,15), immediately east of (28,15). A crack on the new column,
# such as (34,16), surveys at 122 oil with 68 corridors and 33 cracks. Closing
# (8,10), the only ring tile that can be stepped around on corridors that are
# already open, leaves that survey at 122. (21,4) would return it to 120, and
# (21,4) stays open. (10,10) and (20,10) also return particular cracks to 120,
# and each of those closures breaks the surrounding cycle, so the ring cannot
# step around them. (29,15) is visited by the existing tour without raising
# the oil, so the crack alone surveys at 120 with 68 corridors and 33 cracks.
# Closing (8,10) keeps that survey at 120. The ring leaves (8,10) and steps
# through (7,11), and it still leaves (9,10). (21,4) and (7,10) stay open.
# (1,12), (1,13), and (1,14) stay ordinary walls.
const PREDELLA_ROWS: PackedStringArray = [
	"####################################",
	"#S##################################",
	"#.##################################",
	"#H####...................H##########",
	"#.####.[[[[[[[[[[[[[[.###H##########",
	"#H####.[[[[[[[[[[[[[[.###H##########",
	"#.####.[[[[[[[[[[[[[[.###H##########",
	"#H####.[[[[[[[[[[[[[[.###H##########",
	"#.####.[[[[[[[[[[[[[[.###H##########",
	"#H####.[[[[[[[[[[[[[[.###H##########",
	"#.####..##............###H##########",
	"#H........L########.#####H##########",
	"#######H.E#########H.....H##########",
	"#########################H##########",
	"#########################H##########",
	"#########################HHHHH######",
	"#########################HHHHHHHHH##",
	"####################################",
	"####################################",
	"####################################",
	"####################################",
]

# The dossal is the 14x6 block of '{' at columns 7-20, rows 4-9.
# '{' is the next free glyph after '['. '[' is the predella, '<' is the
# reredos, '>' is the credence, '?' is the sedilia, and '=' is the crypt.
# '{' is unused, and an unknown glyph inks as one wall.
# The sheet grows the predella one column east. That new column stays wall.
# The predella, the warden, the lift, the start, and the 19-step path stay on
# their cells. (10,12), (6,12), (5,12), (4,12), (25,2), (3,12), (2,1), (3,1),
# (9,10), and (8,10) stay closed. (8,12) stays open. (29,15) and (33,16) stay
# cracks. The new crack is (30,15), immediately east of (29,15). No off-tour
# crack can be returned to 120 by a ring closure the ring can step around
# while (21,4) and (7,10) stay open. (7,10) is the only ring tile with a
# corridor detour already open, through (6,11). Closing it on a new-column
# crack such as (34,16) surveys at 120, and (7,10) stays open. (21,4) would
# also return that crack to 120, and it stays open. Closing (10,10) and
# opening (11,11) lets the ring step around (10,10) through (11,11) and the
# lift, and that pair does not change the oil. (30,15) is visited by the
# existing tour, so the crack alone surveys at 120 with 67 corridors and 34
# cracks. The closure and the opening keep that survey at 120. An off-tour
# crack such as (34,16), with (10,10) closed and (11,11) open, stays at 122.
# (24,13) and (26,14) are also absorbed by the tour and stay walls. The ring
# still steps around (8,10) through (7,11) and around (9,10) through (8,11),
# (9,11), and the lift. (21,4) and (7,10) stay open. (1,12), (1,13), and
# (1,14) stay ordinary walls.
const DOSSAL_ROWS: PackedStringArray = [
	"#####################################",
	"#S###################################",
	"#.###################################",
	"#H####...................H###########",
	"#.####.{{{{{{{{{{{{{{.###H###########",
	"#H####.{{{{{{{{{{{{{{.###H###########",
	"#.####.{{{{{{{{{{{{{{.###H###########",
	"#H####.{{{{{{{{{{{{{{.###H###########",
	"#.####.{{{{{{{{{{{{{{.###H###########",
	"#H####.{{{{{{{{{{{{{{.###H###########",
	"#.####..###...........###H###########",
	"#H........L.#######.#####H###########",
	"#######H.E#########H.....H###########",
	"#########################H###########",
	"#########################H###########",
	"#########################HHHHHH######",
	"#########################HHHHHHHHH###",
	"#####################################",
	"#####################################",
	"#####################################",
	"#####################################",
]

# The retable is the 14x6 block of ']' at columns 7-20, rows 4-9.
# ']' is the next free glyph after '{'. '{' is the dossal, '[' is the
# predella, '<' is the reredos, '>' is the credence, '?' is the sedilia,
# and '=' is the crypt. ']' is unused, and an unknown glyph inks as one wall.
# The sheet grows the dossal one column east. That new column stays wall.
# The dossal, the warden, the lift, the start, and the 19-step path stay on
# their cells. (10,10) stays closed and (11,11) stays open, so the ring still
# steps around (10,10) through (11,11) and the lift. (8,10) and (9,10) stay
# closed. (8,12) stays open. (10,12) stays closed. (21,4) and (7,10) stay
# open. (30,15) and (33,16) stay cracks. The new crack is (31,15), the wall
# immediately east of (30,15). The existing tour already visits it, so adding
# only that crack surveys at 120 oil with 67 corridors and 35 cracks.
# (24,13) and (26,14) do the same and stay walls. An off-tour crack such as
# (34,16) surveys at 122 while (21,4) and (7,10) stay open. Closing either of
# those would return that survey to 120, and both stay open. (1,12), (1,13),
# and (1,14) stay ordinary walls.
const RETABLE_ROWS: PackedStringArray = [
	"######################################",
	"#S####################################",
	"#.####################################",
	"#H####...................H############",
	"#.####.]]]]]]]]]]]]]].###H############",
	"#H####.]]]]]]]]]]]]]].###H############",
	"#.####.]]]]]]]]]]]]]].###H############",
	"#H####.]]]]]]]]]]]]]].###H############",
	"#.####.]]]]]]]]]]]]]].###H############",
	"#H####.]]]]]]]]]]]]]].###H############",
	"#.####..###...........###H############",
	"#H........L.#######.#####H############",
	"#######H.E#########H.....H############",
	"#########################H############",
	"#########################H############",
	"#########################HHHHHHH######",
	"#########################HHHHHHHHH####",
	"######################################",
	"######################################",
	"######################################",
	"######################################",
]

# The tester is the 14x6 block of '}' at columns 7-20, rows 4-9.
# '}' is the next free glyph after ']'. ']' is the retable, '{' is the
# dossal, '[' is the predella, '<' is the reredos, '>' is the credence,
# '?' is the sedilia, and '=' is the crypt. '}' is unused, and an unknown
# glyph inks as one wall.
# The sheet grows the retable one column east. That new column stays wall.
# The retable, the warden, the lift, the start, and the 19-step path stay on
# their cells. (10,10) stays closed and (11,11) stays open, so the ring still
# steps around (10,10) through (11,11) and the lift. (8,10) and (9,10) stay
# closed. (8,12) stays open. (10,12) stays closed. (21,4) and (7,10) stay
# open. There is no new closure. (31,15) and (33,16) stay cracks. The new
# crack is (32,15), the wall immediately east of (31,15). The existing tour
# already visits it, so adding only that crack surveys at 120 oil with 67
# corridors and 36 cracks. (24,13) and (26,14) do the same and stay walls.
# An off-tour crack such as (34,16) surveys at 122 while (21,4) and (7,10)
# stay open. Closing either of those would return that survey to 120, and
# both stay open. (1,12), (1,13), and (1,14) stay ordinary walls.
const TESTER_ROWS: PackedStringArray = [
	"#######################################",
	"#S#####################################",
	"#.#####################################",
	"#H####...................H#############",
	"#.####.}}}}}}}}}}}}}}.###H#############",
	"#H####.}}}}}}}}}}}}}}.###H#############",
	"#.####.}}}}}}}}}}}}}}.###H#############",
	"#H####.}}}}}}}}}}}}}}.###H#############",
	"#.####.}}}}}}}}}}}}}}.###H#############",
	"#H####.}}}}}}}}}}}}}}.###H#############",
	"#.####..###...........###H#############",
	"#H........L.#######.#####H#############",
	"#######H.E#########H.....H#############",
	"#########################H#############",
	"#########################H#############",
	"#########################HHHHHHHH######",
	"#########################HHHHHHHHH#####",
	"#######################################",
	"#######################################",
	"#######################################",
	"#######################################",
]

# The riddel is the 14x6 block of '~' at columns 7-20, rows 4-9.
# '~' is the next free glyph after '}'. '}' is the tester, ']' is the
# retable, '{' is the dossal, '[' is the predella, '<' is the reredos,
# '>' is the credence, '?' is the sedilia, and '=' is the crypt. '~' is
# unused, and an unknown glyph inks as one wall.
# The sheet grows the tester one column east. That new column stays wall.
# The tester, the warden, the lift, the start, and the 19-step path stay on
# their cells. (10,10) stays closed and (11,11) stays open, so the ring still
# steps around (10,10) through (11,11) and the lift. (8,10) and (9,10) stay
# closed. (8,12) stays open. (10,12) stays closed. (21,4) and (7,10) stay
# open. There is no new closure. (32,15) and (33,16) stay cracks. The new
# crack is (33,15), the wall immediately east of (32,15). The existing tour
# already visits it, so adding only that crack surveys at 120 oil with 67
# corridors and 37 cracks. (24,13) and (26,14) do the same and stay walls.
# An off-tour crack such as (34,16) surveys at 122 while (21,4) and (7,10)
# stay open. Closing either of those would return that survey to 120, and
# both stay open. (1,12), (1,13), and (1,14) stay ordinary walls.
const RIDDEL_ROWS: PackedStringArray = [
	"########################################",
	"#S######################################",
	"#.######################################",
	"#H####...................H##############",
	"#.####.~~~~~~~~~~~~~~.###H##############",
	"#H####.~~~~~~~~~~~~~~.###H##############",
	"#.####.~~~~~~~~~~~~~~.###H##############",
	"#H####.~~~~~~~~~~~~~~.###H##############",
	"#.####.~~~~~~~~~~~~~~.###H##############",
	"#H####.~~~~~~~~~~~~~~.###H##############",
	"#.####..###...........###H##############",
	"#H........L.#######.#####H##############",
	"#######H.E#########H.....H##############",
	"#########################H##############",
	"#########################H##############",
	"#########################HHHHHHHHH######",
	"#########################HHHHHHHHH######",
	"########################################",
	"########################################",
	"########################################",
	"########################################",
]

# The frontal is the 14x6 block of '!' at columns 7-20, rows 4-9.
# '!' is the next free glyph after '~'. Space is the next code point, and
# it is unused, but it is not a distinct mark. '!' is unused, and an unknown
# glyph inks as one wall. '~' is the riddel, '}' is the tester, ']' is the
# retable, '{' is the dossal, '[' is the predella, '<' is the reredos,
# '>' is the credence, '?' is the sedilia, and '=' is the crypt.
# The sheet grows the riddel one column east. That new column stays wall.
# The warden, the lift, the start, and the 19-step path stay on their cells.
# (34,15) is the wall immediately east of (33,15). It is not on the existing
# tour: adding only that crack surveys at 122 oil. There is no on-tour wall
# east of (33,15). (24,13), (26,14), and (8,10) are the remaining on-tour
# walls and stay walls. Closing (7,10) returns that survey to 120. (6,11) is
# already open, so the ring steps around (7,10) through (6,11). (21,4) stays
# open. Closing (21,4) would also return the survey to 120, and it has no
# corridor detour. (10,10) stays closed and (11,11) stays open. (8,10) and
# (9,10) stay closed. (8,12) stays open. (10,12) stays closed. An off-tour
# crack such as (34,16) surveys at 122 while (21,4) and (7,10) stay open.
# (33,15) and (33,16) stay cracks. (1,12), (1,13), and (1,14) stay ordinary walls.
const FRONTAL_ROWS: PackedStringArray = [
	"#########################################",
	"#S#######################################",
	"#.#######################################",
	"#H####...................H###############",
	"#.####.!!!!!!!!!!!!!!.###H###############",
	"#H####.!!!!!!!!!!!!!!.###H###############",
	"#.####.!!!!!!!!!!!!!!.###H###############",
	"#H####.!!!!!!!!!!!!!!.###H###############",
	"#.####.!!!!!!!!!!!!!!.###H###############",
	"#H####.!!!!!!!!!!!!!!.###H###############",
	"#.####.####...........###H###############",
	"#H........L.#######.#####H###############",
	"#######H.E#########H.....H###############",
	"#########################H###############",
	"#########################H###############",
	"#########################HHHHHHHHHH######",
	"#########################HHHHHHHHH#######",
	"#########################################",
	"#########################################",
	"#########################################",
	"#########################################",
]

# The pall is the 14x6 block of '"' at columns 7-20, rows 4-9.
# '"' is the next mark after '!'. Space was the code point before '!' and was
# skipped because it is not a distinct mark. '"' is unused, and an unknown
# glyph inks as one wall. '!' is the frontal.
# The sheet grows the frontal one column east. That new column stays wall.
# The warden, the lift, the start, and the 19-step path stay on their cells.
# (35,15) is the wall immediately east of (34,15). It is not on the tour:
# adding only that crack surveys at 122 oil. Closing (21,4) returns the survey
# to 120 oil and the same 19 steps. It is the only such cell. (21,4) cannot
# stay open. (20,4) is the pall and (22,4) is a wall, so there is no
# already-open corridor detour. The recorded walk is the frontal ring without
# (21,4), open between (21,3) and (21,5). (6,11) stays open. (10,10) stays
# closed and (11,11) stays open. (7,10), (8,10), and (9,10) stay closed.
# (8,12) stays open. (10,12) stays closed.
const PALL_ROWS: PackedStringArray = [
	'##########################################',
	'#S########################################',
	'#.########################################',
	'#H####...................H################',
	'#.####.""""""""""""""####H################',
	'#H####."""""""""""""".###H################',
	'#.####."""""""""""""".###H################',
	'#H####."""""""""""""".###H################',
	'#.####."""""""""""""".###H################',
	'#H####."""""""""""""".###H################',
	'#.####.####...........###H################',
	'#H........L.#######.#####H################',
	'#######H.E#########H.....H################',
	'#########################H################',
	'#########################H################',
	'#########################HHHHHHHHHHH######',
	'#########################HHHHHHHHH########',
	'##########################################',
	'##########################################',
	'##########################################',
	'##########################################',
]

# The herse is the 14x6 block of '$' at columns 7-20, rows 4-9.
# '#' is the wall mark and is already used. '$' is the next mark, it is unused,
# and an unknown glyph inks as one wall. '"' is the pall.
# The sheet grows the pall one cell east. That new column stays wall.
# The warden, the lift, the start, and the 19-step path stay on their cells.
# (36,15) is the wall immediately east of (35,15). It is not on the tour:
# adding only that crack surveys at 122 oil. (21,4) stays closed. Closing
# (21,5) returns the survey to 120 oil and the same 19 steps. It is the only
# such cell. (21,4) and (22,5) are walls and (20,5) is the pall, so there is
# no already-open corridor detour. The recorded walk drops (21,5) and is open
# between (21,3) and (21,6). (6,11) stays open. (10,10) stays closed and
# (11,11) stays open.
const HERSE_ROWS: PackedStringArray = [
	"###########################################",
	"#S#########################################",
	"#.#########################################",
	"#H####...................H#################",
	"#.####.$$$$$$$$$$$$$$####H#################",
	"#H####.$$$$$$$$$$$$$$####H#################",
	"#.####.$$$$$$$$$$$$$$.###H#################",
	"#H####.$$$$$$$$$$$$$$.###H#################",
	"#.####.$$$$$$$$$$$$$$.###H#################",
	"#H####.$$$$$$$$$$$$$$.###H#################",
	"#.####.####...........###H#################",
	"#H........L.#######.#####H#################",
	"#######H.E#########H.....H#################",
	"#########################H#################",
	"#########################H#################",
	"#########################HHHHHHHHHHHH######",
	"#########################HHHHHHHHH#########",
	"###########################################",
	"###########################################",
	"###########################################",
	"###########################################",
]

# The catafalque is the 14x6 block of '%' at columns 7-20, rows 4-9.
# '%' is unused, and an unknown glyph inks as one wall. '$' is the herse.
# The sheet grows the herse one cell east. That new column stays wall.
# The warden, the lift, the start, and the 19-step path stay on their cells.
# (37,15) is the wall immediately east of (36,15). It is not on the tour:
# adding only that crack surveys at 122 oil. (21,5) and (21,4) stay closed.
# Closing (21,6) returns the survey to 120 oil and the same 19 steps. It is
# the only such cell. (21,5) and (22,6) are walls and (20,6) is the herse, so
# there is no already-open corridor detour. The recorded walk drops (21,6)
# and is open between (21,3) and (21,7). (6,11) stays open. (10,10) stays
# closed and (11,11) stays open.
const CATAFALQUE_ROWS: PackedStringArray = [
	"############################################",
	"#S##########################################",
	"#.##########################################",
	"#H####...................H##################",
	"#.####.%%%%%%%%%%%%%%####H##################",
	"#H####.%%%%%%%%%%%%%%####H##################",
	"#.####.%%%%%%%%%%%%%%####H##################",
	"#H####.%%%%%%%%%%%%%%.###H##################",
	"#.####.%%%%%%%%%%%%%%.###H##################",
	"#H####.%%%%%%%%%%%%%%.###H##################",
	"#.####.####...........###H##################",
	"#H........L.#######.#####H##################",
	"#######H.E#########H.....H##################",
	"#########################H##################",
	"#########################H##################",
	"#########################HHHHHHHHHHHHH######",
	"#########################HHHHHHHHH##########",
	"############################################",
	"############################################",
	"############################################",
	"############################################",
]

# The bier is the 14x6 block of '&' at columns 7-20, rows 4-9.
# '&' is unused, and an unknown glyph inks as one wall. '%' is the catafalque.
# The sheet grows the catafalque one cell east. That new column stays wall.
# The warden, the lift, the start, and the 19-step path stay on their cells.
# (38,15) is the wall immediately east of (37,15). It is not on the tour:
# adding only that crack surveys at 122 oil. (21,6), (21,5), and (21,4) stay
# closed. Closing (21,7) returns the survey to 120 oil and the same 19 steps.
# It is the only such cell. (21,6) and (22,7) are walls and (20,7) is the
# catafalque, so there is no already-open corridor detour. The recorded walk
# drops (21,7) and is open between (21,3) and (21,8). (6,11) stays open.
# (10,10) stays closed and (11,11) stays open.
const BIER_ROWS: PackedStringArray = [
	"#############################################",
	"#S###########################################",
	"#.###########################################",
	"#H####...................H###################",
	"#.####.&&&&&&&&&&&&&&####H###################",
	"#H####.&&&&&&&&&&&&&&####H###################",
	"#.####.&&&&&&&&&&&&&&####H###################",
	"#H####.&&&&&&&&&&&&&&####H###################",
	"#.####.&&&&&&&&&&&&&&.###H###################",
	"#H####.&&&&&&&&&&&&&&.###H###################",
	"#.####.####...........###H###################",
	"#H........L.#######.#####H###################",
	"#######H.E#########H.....H###################",
	"#########################H###################",
	"#########################H###################",
	"#########################HHHHHHHHHHHHHH######",
	"#########################HHHHHHHHH###########",
	"#############################################",
	"#############################################",
	"#############################################",
	"#############################################",
]

# The cerecloth is the 14x6 block of "'" at columns 7-20, rows 4-9.
# "'" is unused, and an unknown glyph inks as one wall. '&' is the bier.
# The sheet grows the bier one cell east. That new column stays wall.
# The warden, the lift, the start, and the 19-step path stay on their cells.
# (39,15) is the wall immediately east of (38,15). It is not on the tour:
# adding only that crack surveys at 122 oil. (21,7), (21,6), (21,5), and
# (21,4) stay closed. Closing (21,8) returns the survey to 120 oil and the
# same 19 steps. It is the only such cell. (21,7) and (22,8) are walls and
# (20,8) is the bier, so there is no already-open corridor detour. The
# recorded walk drops (21,8) and is open between (21,3) and (21,9). (6,11)
# stays open. (10,10) stays closed and (11,11) stays open.
const CERECLOTH_ROWS: PackedStringArray = [
	"##############################################",
	"#S############################################",
	"#.############################################",
	"#H####...................H####################",
	"#.####.''''''''''''''####H####################",
	"#H####.''''''''''''''####H####################",
	"#.####.''''''''''''''####H####################",
	"#H####.''''''''''''''####H####################",
	"#.####.''''''''''''''####H####################",
	"#H####.''''''''''''''.###H####################",
	"#.####.####...........###H####################",
	"#H........L.#######.#####H####################",
	"#######H.E#########H.....H####################",
	"#########################H####################",
	"#########################H####################",
	"#########################HHHHHHHHHHHHHHH######",
	"#########################HHHHHHHHH############",
	"##############################################",
	"##############################################",
	"##############################################",
	"##############################################",
]

# The hearse is the 14x6 block of '(' at columns 7-20, rows 4-9.
# '(' is unused, and an unknown glyph inks as one wall. "'" is the cerecloth.
# The sheet grows the cerecloth one cell east. That new column stays wall.
# The warden, the lift, the start, and the 19-step path stay on their cells.
# (40,15) is the wall immediately east of (39,15). It is not on the tour:
# adding only that crack surveys at 122 oil. (21,8), (21,7), (21,6), (21,5),
# and (21,4) stay closed. Closing (21,9) returns the survey to 120 oil and the
# same 19 steps. It is the only such cell. (21,8) and (22,9) are walls and
# (20,9) is the cerecloth, so there is no already-open corridor detour. The
# recorded walk drops (21,9) and is open between (21,3) and (21,10). (6,11)
# stays open. (10,10) stays closed and (11,11) stays open.
const HEARSE_ROWS: PackedStringArray = [
	"###############################################",
	"#S#############################################",
	"#.#############################################",
	"#H####...................H#####################",
	"#.####.((((((((((((((####H#####################",
	"#H####.((((((((((((((####H#####################",
	"#.####.((((((((((((((####H#####################",
	"#H####.((((((((((((((####H#####################",
	"#.####.((((((((((((((####H#####################",
	"#H####.((((((((((((((####H#####################",
	"#.####.####...........###H#####################",
	"#H........L.#######.#####H#####################",
	"#######H.E#########H.....H#####################",
	"#########################H#####################",
	"#########################H#####################",
	"#########################HHHHHHHHHHHHHHHH######",
	"#########################HHHHHHHHH#############",
	"###############################################",
	"###############################################",
	"###############################################",
	"###############################################",
]

# The shroud is the 14x6 block of ')' at columns 7-20, rows 4-9.
# ')' is unused, and an unknown glyph inks as one wall. '(' is the hearse.
# The sheet grows the hearse one cell east. That new column stays wall.
# The warden, the lift, the start, and the 19-step path stay on their cells.
# (41,15) is the wall immediately east of (40,15). It is not on the tour:
# adding only that crack surveys at 122 oil. (21,9) through (21,4) stay closed.
# Closing (21,10) returns the survey to 120 oil and the same 19 steps. No new
# cell is opened. (22,10), (21,11), and (21,9) are walls. The recorded walk
# drops (21,10) and continues through the already-open (20,10). It is open
# between (21,3) and (20,10). (6,11) stays open. (10,10) stays closed and
# (11,11) stays open.
const SHROUD_ROWS: PackedStringArray = [
	"################################################",
	"#S##############################################",
	"#.##############################################",
	"#H####...................H######################",
	"#.####.))))))))))))))####H######################",
	"#H####.))))))))))))))####H######################",
	"#.####.))))))))))))))####H######################",
	"#H####.))))))))))))))####H######################",
	"#.####.))))))))))))))####H######################",
	"#H####.))))))))))))))####H######################",
	"#.####.####..........####H######################",
	"#H........L.#######.#####H######################",
	"#######H.E#########H.....H######################",
	"#########################H######################",
	"#########################H######################",
	"#########################HHHHHHHHHHHHHHHHH######",
	"#########################HHHHHHHHH##############",
	"################################################",
	"################################################",
	"################################################",
	"################################################",
]

# The pyre is the 14x6 block of ',' at columns 7-20, rows 4-9.
# '*' is the cistern pit and '+' is the cloister garth, so both are taken.
# ',' is unused, and an unknown glyph inks as one wall. ')' is the shroud.
# '(' is the hearse. The sheet grows the shroud one cell east. That new column stays wall.
# The warden, the lift, the start, and the 19-step path stay on their cells.
# (42,15) is the wall immediately east of (41,15). It is not on the tour:
# adding only that crack surveys at 122 oil. (21,10) through (21,4) stay closed.
# (21,11) and (22,10) stay walls. Closing (20,10) returns the survey to 120 oil
# and the same 19 steps. No new cell is opened. (21,10), (20,11), and (20,9)
# are walls. The recorded walk drops (20,10) and continues through the
# already-open (19,10). It is open between (21,3) and (19,10). (6,11) stays
# open. (10,10) stays closed and (11,11) stays open.
const PYRE_ROWS: PackedStringArray = [
	"#################################################",
	"#S###############################################",
	"#.###############################################",
	"#H####...................H#######################",
	"#.####.,,,,,,,,,,,,,,####H#######################",
	"#H####.,,,,,,,,,,,,,,####H#######################",
	"#.####.,,,,,,,,,,,,,,####H#######################",
	"#H####.,,,,,,,,,,,,,,####H#######################",
	"#.####.,,,,,,,,,,,,,,####H#######################",
	"#H####.,,,,,,,,,,,,,,####H#######################",
	"#.####.####.........#####H#######################",
	"#H........L.#######.#####H#######################",
	"#######H.E#########H.....H#######################",
	"#########################H#######################",
	"#########################H#######################",
	"#########################HHHHHHHHHHHHHHHHHH######",
	"#########################HHHHHHHHH###############",
	"#################################################",
	"#################################################",
	"#################################################",
	"#################################################",
]


# The cenotaph is the 14x6 block of ';' at columns 7-20, rows 4-9.
# '.' is the corridor mark, so it cannot ink a wall. ';' is unused and inks as one wall.
# ',' stays the pyre. '*' stays the cistern pit. '+' stays the cloister garth.
# ')' stays the shroud. '(' stays the hearse. The sheet grows the pyre one cell east.
# That new column stays wall. The warden, the lift, the start, and the 19-step path stay.
# (43,15) is the wall immediately east of (42,15). It is not on the tour:
# adding only that crack surveys at 122 oil. (21,10) through (21,4) stay closed.
# (20,10) stays closed. (21,11) and (22,10) stay walls. (20,11) and (20,9) stay walls.
# Closing (19,10) alone surveys at 176 oil, because (19,11) is open and (19,12) is a crack.
# Opening (18,11) is the smallest detour that restores the same 19 steps.
# The survey is 122 oil: the new crack is still a leaf, and the detour matches the closed cell.
# The recorded walk drops (19,10) and is open between (21,3) and (18,10).
# (6,11) stays open. (10,10) stays closed and (11,11) stays open.
const CENOTAPH_ROWS: PackedStringArray = [
	"##################################################",
	"#S################################################",
	"#.################################################",
	"#H####...................H########################",
	"#.####.;;;;;;;;;;;;;;####H########################",
	"#H####.;;;;;;;;;;;;;;####H########################",
	"#.####.;;;;;;;;;;;;;;####H########################",
	"#H####.;;;;;;;;;;;;;;####H########################",
	"#.####.;;;;;;;;;;;;;;####H########################",
	"#H####.;;;;;;;;;;;;;;####H########################",
	"#.####.####........######H########################",
	"#H........L.######..#####H########################",
	"#######H.E#########H.....H########################",
	"#########################H########################",
	"#########################H########################",
	"#########################HHHHHHHHHHHHHHHHHHH######",
	"#########################HHHHHHHHH################",
	"##################################################",
	"##################################################",
	"##################################################",
	"##################################################",
]


# The winding is the 14x6 block of ':' at columns 7-20, rows 4-9.
# ';' stays the cenotaph. ':' is unused and inks as one wall.
# '.' stays the corridor mark. ',' stays the pyre. The sheet grows the cenotaph one cell east.
# That new column stays wall. The warden, the lift, the start, and the 19-step path stay.
# (44,15) is the wall immediately east of (43,15). It is not on the tour:
# adding only that crack surveys at 124 oil. (21,10) through (21,4) stay closed.
# (20,10) and (19,10) stay closed. (21,11) and (22,10) stay walls. (18,11) stays open.
# Closing (18,10) alone surveys at 178 oil, because (18,11) and (17,10) are open.
# Opening (17,11) is the smallest detour that restores the same 19 steps.
# The survey is 124 oil: the new crack is still a leaf, and no one-, two-, or three-cell
# opening cancels that oil while the path stays 19 steps.
# The recorded walk drops (18,10) and is open between (21,3) and (17,10).
# (6,11) stays open. (10,10) stays closed and (11,11) stays open.
const WINDING_ROWS: PackedStringArray = [
	"###################################################",
	"#S#################################################",
	"#.#################################################",
	"#H####...................H#########################",
	"#.####.::::::::::::::####H#########################",
	"#H####.::::::::::::::####H#########################",
	"#.####.::::::::::::::####H#########################",
	"#H####.::::::::::::::####H#########################",
	"#.####.::::::::::::::####H#########################",
	"#H####.::::::::::::::####H#########################",
	"#.####.####.......#######H#########################",
	"#H........L.#####...#####H#########################",
	"#######H.E#########H.....H#########################",
	"#########################H#########################",
	"#########################H#########################",
	"#########################HHHHHHHHHHHHHHHHHHHH######",
	"#########################HHHHHHHHH#################",
	"###################################################",
	"###################################################",
	"###################################################",
	"###################################################",
]


# The charnel is the 14x6 block of '-' at columns 7-20, rows 4-9.
# Apostrophe stays the cerecloth. Quotation mark stays the pall. Hyphen is unused and inks as one wall.
# ':' stays the winding. ';' stays the cenotaph. The sheet grows the winding one cell east.
# That new column stays wall. The warden, the lift, the start, and the 19-step path stay.
# (45,15) is the wall immediately east of (44,15). It is not on the tour:
# adding only that crack surveys at 126 oil. (21,10) through (21,4) stay closed.
# (20,10), (19,10), and (18,10) stay closed. (21,11) and (22,10) stay walls.
# (17,11) and (18,11) stay open.
# Closing (17,10) alone surveys at 180 oil, because (17,11) and (16,10) are open.
# Opening (16,11) is the one-cell detour that restores the same 19 steps.
# The survey is 126 oil: the new crack is still a leaf, and no one-, two-, or three-cell
# opening reaches a lower survey while the path stays 19 steps.
# The recorded walk drops (17,10) and is open between (21,3) and (16,10).
# (6,11) stays open. (10,10) stays closed and (11,11) stays open.
const CHARNEL_ROWS: PackedStringArray = [
	'####################################################',
	'#S##################################################',
	'#.##################################################',
	'#H####...................H##########################',
	'#.####.--------------####H##########################',
	'#H####.--------------####H##########################',
	'#.####.--------------####H##########################',
	'#H####.--------------####H##########################',
	'#.####.--------------####H##########################',
	'#H####.--------------####H##########################',
	'#.####.####......########H##########################',
	'#H........L.####....#####H##########################',
	'#######H.E#########H.....H##########################',
	'#########################H##########################',
	'#########################H##########################',
	'#########################HHHHHHHHHHHHHHHHHHHHH######',
	'#########################HHHHHHHHH##################',
	'####################################################',
	'####################################################',
	'####################################################',
	'####################################################',
]


# The sepulchre is the 14x6 block of '_' at columns 7-20, rows 4-9.
# '.' is the corridor mark and inks as floor. '_' is unused and inks as one wall.
# '-' stays the charnel. '+' stays the cloister garth. The sheet grows the charnel one cell east.
# That new column stays wall. The warden, the lift, the start, and the 19-step path stay.
# (46,15) is the wall immediately east of (45,15). It is not on the tour:
# adding only that crack surveys at 128 oil. (21,10) through (21,4) stay closed.
# (20,10), (19,10), (18,10), and (17,10) stay closed. (21,11) and (22,10) stay walls.
# (16,11), (17,11), and (18,11) stay open.
# Closing (16,10) alone surveys at 182 oil, because (16,11) and (15,10) are open.
# Opening (15,11) is the one-cell detour that restores the same 19 steps.
# The survey is 128 oil: the new crack is still a leaf, and no one-, two-, or three-cell
# opening reaches a lower survey while the path stays 19 steps.
# The recorded walk drops (16,10) and is open between (21,3) and (15,10).
# (6,11) stays open. (10,10) stays closed and (11,11) stays open.
const SEPULCHRE_ROWS: PackedStringArray = [
	"#####################################################",
	"#S###################################################",
	"#.###################################################",
	"#H####...................H###########################",
	"#.####.______________####H###########################",
	"#H####.______________####H###########################",
	"#.####.______________####H###########################",
	"#H####.______________####H###########################",
	"#.####.______________####H###########################",
	"#H####.______________####H###########################",
	"#.####.####.....#########H###########################",
	"#H........L.###.....#####H###########################",
	"#######H.E#########H.....H###########################",
	"#########################H###########################",
	"#########################H###########################",
	"#########################HHHHHHHHHHHHHHHHHHHHHH######",
	"#########################HHHHHHHHH###################",
	"#####################################################",
	"#####################################################",
	"#####################################################",
	"#####################################################",
]


# The vault is the 14x6 block of '^' at columns 7-20, rows 4-9.
# '=' stays the crypt. '~' stays the riddel. '^' is unused and inks as one wall.
# '_' stays the sepulchre. The sheet grows the sepulchre one cell east.
# That new column stays wall. The warden, the lift, the start, and the 19-step path stay.
# (47,15) is the wall immediately east of (46,15). It is not on the tour:
# adding only that crack surveys at 130 oil. (21,10) through (21,4) stay closed.
# (20,10), (19,10), (18,10), (17,10), and (16,10) stay closed. (21,11) and (22,10) stay walls.
# (15,11), (16,11), (17,11), and (18,11) stay open.
# Closing (15,10) alone surveys at 184 oil, because (15,11) and (14,10) are open.
# Opening (14,11) is the one-cell detour that restores the same 19 steps.
# The survey is 130 oil: the new crack is still a leaf, and no one-, two-, or three-cell
# opening reaches a lower survey while the path stays 19 steps.
# The recorded walk drops (15,10) and is open between (21,3) and (14,10).
# (6,11) stays open. (10,10) stays closed and (11,11) stays open.
const VAULT_ROWS: PackedStringArray = [
	"######################################################",
	"#S####################################################",
	"#.####################################################",
	"#H####...................H############################",
	"#.####.^^^^^^^^^^^^^^####H############################",
	"#H####.^^^^^^^^^^^^^^####H############################",
	"#.####.^^^^^^^^^^^^^^####H############################",
	"#H####.^^^^^^^^^^^^^^####H############################",
	"#.####.^^^^^^^^^^^^^^####H############################",
	"#H####.^^^^^^^^^^^^^^####H############################",
	"#.####.####....##########H############################",
	"#H........L.##......#####H############################",
	"#######H.E#########H.....H############################",
	"#########################H############################",
	"#########################H############################",
	"#########################HHHHHHHHHHHHHHHHHHHHHHH######",
	"#########################HHHHHHHHH####################",
	"######################################################",
	"######################################################",
	"######################################################",
	"######################################################",
]


# The cairn is the 14x6 block of '/' at columns 7-20, rows 4-9.
# '*' stays the cistern pit. '&' stays the bier. '%' stays the catafalque.
# '/' is the next unused glyph and inks as one wall. '^' stays the vault.
# The sheet grows the vault one cell east. That new column stays wall.
# The warden, the lift, the start, and the 19-step path stay.
# (48,15) is the wall immediately east of (47,15). It is not on the tour:
# adding only that crack surveys at 132 oil. (21,10) through (21,4) stay closed.
# (20,10), (19,10), (18,10), (17,10), (16,10), and (15,10) stay closed.
# (21,11) and (22,10) stay walls.
# (14,11), (15,11), (16,11), (17,11), and (18,11) stay open.
# Closing (14,10) alone surveys at 186 oil, because (14,11) and (13,10) are open.
# Opening (13,11) is the one-cell detour that restores the same 19 steps.
# The survey is 132 oil: the new crack is still a leaf, and no one-, two-, or three-cell
# opening reaches a lower survey while the path stays 19 steps.
# The recorded walk drops (14,10) and is open between (21,3) and (13,10).
# (6,11) stays open. (10,10) stays closed and (11,11) stays open.
const CAIRN_ROWS: PackedStringArray = [
	"#######################################################",
	"#S#####################################################",
	"#.#####################################################",
	"#H####...................H#############################",
	"#.####.//////////////####H#############################",
	"#H####.//////////////####H#############################",
	"#.####.//////////////####H#############################",
	"#H####.//////////////####H#############################",
	"#.####.//////////////####H#############################",
	"#H####.//////////////####H#############################",
	"#.####.####...###########H#############################",
	"#H........L.#.......#####H#############################",
	"#######H.E#########H.....H#############################",
	"#########################H#############################",
	"#########################H#############################",
	"#########################HHHHHHHHHHHHHHHHHHHHHHHH######",
	"#########################HHHHHHHHH#####################",
	"#######################################################",
	"#######################################################",
	"#######################################################",
	"#######################################################",
]


# The columbarium is the 14x6 block of backslashes at columns 7-20, rows 4-9.
# '/' stays the cairn. '+' stays the cloister garth. The loculus uses '|'.
# The backslash selects nothing elsewhere and inks as one wall.
# The sheet grows the cairn one cell east. That new column stays wall.
# The warden, the lift, the start, and the 19-step path stay.
# (49,15) is the wall immediately east of (48,15). It is not on the tour:
# adding only that crack surveys at 134 oil. (21,10) through (21,4) stay closed.
# (20,10) through (14,10) stay closed. (13,10) is closed on this floor.
# (21,11) and (22,10) stay walls.
# (12,11) is the opened detour. (13,11) through (18,11) stay open.
# Closing (13,10) alone surveys at 188 oil, because (13,11) and (12,10) are open.
# Opening (12,11) is the one-cell detour that restores the same 19 steps.
# The survey is 134 oil: the new crack is still a leaf, and no one-, two-, or three-cell
# opening reaches a lower survey while the path stays 19 steps.
# The recorded walk drops (13,10) and is open between (21,3) and (12,10).
# (6,11) stays open. (10,10) stays closed and (11,11) stays open.
const COLUMBARIUM_ROWS: PackedStringArray = [
	"########################################################",
	"#S######################################################",
	"#.######################################################",
	"#H####...................H##############################",
	"#.####.\\\\\\\\\\\\\\\\\\\\\\\\\\\\####H##############################",
	"#H####.\\\\\\\\\\\\\\\\\\\\\\\\\\\\####H##############################",
	"#.####.\\\\\\\\\\\\\\\\\\\\\\\\\\\\####H##############################",
	"#H####.\\\\\\\\\\\\\\\\\\\\\\\\\\\\####H##############################",
	"#.####.\\\\\\\\\\\\\\\\\\\\\\\\\\\\####H##############################",
	"#H####.\\\\\\\\\\\\\\\\\\\\\\\\\\\\####H##############################",
	"#.####.####..############H##############################",
	"#H........L.........#####H##############################",
	"#######H.E#########H.....H##############################",
	"#########################H##############################",
	"#########################H##############################",
	"#########################HHHHHHHHHHHHHHHHHHHHHHHHH######",
	"#########################HHHHHHHHH######################",
	"########################################################",
	"########################################################",
	"########################################################",
	"########################################################",
]


# The loculus is the 14x6 block of vertical bars at columns 7-20, rows 4-9.
# '\' stays the columbarium. '/' stays the cairn. '+' stays the cloister garth.
# The vertical bar selects nothing elsewhere and inks as one wall.
# The sheet grows the columbarium one cell east. That new column stays wall.
# The warden, the lift, the start, and the 19-step path stay.
# (50,15) is the wall immediately east of (49,15). It is not on the tour:
# adding only that crack surveys at 136 oil. (21,10) through (21,4) stay closed.
# (20,10) through (13,10) stay closed. (12,10) is closed on this floor.
# (21,11) and (22,10) stay walls.
# (11,11) is already open, so closing (12,10) does not need a new detour.
# (12,11) stays the one-cell detour and stays off the ring. (13,11) through (18,11) stay open.
# Closing (12,10) alone surveys at 136 oil, the same as the crack alone, because (11,11) and (12,11) are open.
# The survey is 136 oil: the new crack is still a leaf, and no one-, two-, or three-cell
# opening reaches a lower survey while the path stays 19 steps.
# The recorded walk drops (12,10) and is open between (21,3) and (11,10).
# (6,11) stays open. (10,10) stays closed and (11,11) stays open.
const LOCULUS_ROWS: PackedStringArray = [
	"#########################################################",
	"#S#######################################################",
	"#.#######################################################",
	"#H####...................H###############################",
	"#.####.||||||||||||||####H###############################",
	"#H####.||||||||||||||####H###############################",
	"#.####.||||||||||||||####H###############################",
	"#H####.||||||||||||||####H###############################",
	"#.####.||||||||||||||####H###############################",
	"#H####.||||||||||||||####H###############################",
	"#.####.####.#############H###############################",
	"#H........L.........#####H###############################",
	"#######H.E#########H.....H###############################",
	"#########################H###############################",
	"#########################H###############################",
	"#########################HHHHHHHHHHHHHHHHHHHHHHHHHH######",
	"#########################HHHHHHHHH#######################",
	"#########################################################",
	"#########################################################",
	"#########################################################",
	"#########################################################",
]



# The arcosolium is the 14x6 block of backticks at columns 7-20, rows 4-9.
# '|' stays the loculus. '\' stays the columbarium. '/' stays the cairn. '+' stays the cloister garth.
# ':' selects the winding. ';' selects the cenotaph. '=' selects the tomb.
# The backtick selects nothing elsewhere and inks as one wall.
# The sheet grows the loculus one cell east. That new column stays wall.
# The warden, the lift, the start, and the 19-step path stay.
# (51,15) is the wall immediately east of (50,15). It is not on the tour:
# adding only that crack surveys at 138 oil. (21,10) through (21,4) stay closed.
# (20,10) through (12,10) stay closed. (11,10) is closed on this floor.
# (21,11) and (22,10) stay walls.
# (11,10) is a dead end south of the loculus feature and north of (11,11).
# Closing it does not lengthen the 19-step path and opens no new cell.
# (12,11) stays the one-cell detour and stays off the ring. (13,11) through (18,11) stay open.
# Closing (11,10) surveys at 136 oil. The crack alone, with (11,10) still open, surveys at 138.
# The survey is 136 oil: the new crack is still a leaf, and no one-, two-, or three-cell
# opening reaches a lower survey while the path stays 19 steps.
# The recorded walk drops (11,10) and is open between (21,3) and (11,11).
# (6,11) stays open. (10,10) stays closed and (11,11) stays open.
const ARCOSOLIUM_ROWS: PackedStringArray = [
	"##########################################################",
	"#S########################################################",
	"#.########################################################",
	"#H####...................H################################",
	"#.####.``````````````####H################################",
	"#H####.``````````````####H################################",
	"#.####.``````````````####H################################",
	"#H####.``````````````####H################################",
	"#.####.``````````````####H################################",
	"#H####.``````````````####H################################",
	"#.####.##################H################################",
	"#H........L.........#####H################################",
	"#######H.E#########H.....H################################",
	"#########################H################################",
	"#########################H################################",
	"#########################HHHHHHHHHHHHHHHHHHHHHHHHHHH######",
	"#########################HHHHHHHHH########################",
	"##########################################################",
	"##########################################################",
	"##########################################################",
	"##########################################################",
]


enum Tile { WALL, FLOOR, HAZARD, LIFT }
enum Mark { NONE, CORRIDOR, WALL, HAZARD }
enum EndReason { NONE, EXTRACTED, LAMP_OUT, ABANDONED }
enum Action { TURN_LEFT, TURN_RIGHT, FORWARD, BACK, STRAFE_LEFT, STRAFE_RIGHT, WAIT, MARK }

class Floor extends RefCounted:
	var id: String
	var title: String
	var rows: PackedStringArray
	var loop_name: String
	var loop: Array
	var record: String

class RunState extends RefCounted:
	var floor: Floor
	var pos: Vector2i
	var facing: int
	var oil: int
	var flask_capacity: int
	var marks: Dictionary
	var telegraph_index: int
	var end_reason: int
	var last_hit: bool
	var settled: bool

class Campaign extends RefCounted:
	var purse: int
	var flask_oil: int
	var upgraded: bool
	var last_bill: Dictionary
	var last_outcome: String
	var last_floor_id: String
	var completed: Dictionary


static var _floor_list: Array = []


static func floors() -> Array:
	if _floor_list.is_empty():
		_floor_list = [_make_cellar(), _make_cistern(), _make_cloister(), _make_crypt(), _make_ossuary(), _make_reliquary(), _make_undercroft(), _make_wellhouse(), _make_scriptorium(), _make_binding(), _make_chartroom(), _make_bellloft(), _make_clockroom(), _make_font(), _make_apse(), _make_choir(), _make_rood(), _make_crossing(), _make_transept(), _make_ambulatory(), _make_chevet(), _make_retrochoir(), _make_ladychapel(), _make_feretory(), _make_chantry(), _make_sacristy(), _make_pyx(), _make_aumbry(), _make_piscina(), _make_sedilia(), _make_credence(), _make_reredos(), _make_predella(), _make_dossal(), _make_retable(), _make_tester(), _make_riddel(), _make_frontal(), _make_pall(), _make_herse(), _make_catafalque(), _make_bier(), _make_cerecloth(), _make_hearse(), _make_shroud(), _make_pyre(), _make_cenotaph(), _make_winding(), _make_charnel(), _make_sepulchre(), _make_vault(), _make_cairn(), _make_columbarium(), _make_loculus(), _make_arcosolium()]
	return _floor_list


static func default_floor() -> Floor:
	return floors()[0]


static func floor_named(id: String) -> Floor:
	for floor in floors():
		if floor.id == id:
			return floor
	return null


static func _use(floor: Floor) -> Floor:
	if floor == null:
		return default_floor()
	return floor


static func _make_cellar() -> Floor:
	var floor := Floor.new()
	floor.id = "cellar"
	floor.title = "The Cellar"
	floor.rows = CELLAR_ROWS
	floor.loop_name = "East square"
	floor.loop = [Vector2i(8, 3), Vector2i(9, 3), Vector2i(9, 4), Vector2i(8, 4)]
	floor.record = CELLAR_RECORD
	return floor


static func _make_cistern() -> Floor:
	var floor := Floor.new()
	floor.id = "cistern"
	floor.title = "The Cistern"
	floor.rows = CISTERN_ROWS
	floor.loop_name = "Cistern ring"
	var ring: Array = []
	for x in range(3, 8):
		ring.append(Vector2i(x, 3))
	for y in range(4, 7):
		ring.append(Vector2i(3, y))
		ring.append(Vector2i(7, y))
	for x in range(3, 8):
		ring.append(Vector2i(x, 7))
	floor.loop = ring
	floor.record = CISTERN_RECORD
	return floor


static func _make_cloister() -> Floor:
	var floor := Floor.new()
	floor.id = "cloister"
	floor.title = "The Cloister"
	floor.rows = CLOISTER_ROWS
	floor.loop_name = "Cloister walk"
	var ring: Array = []
	for x in range(3, 10):
		ring.append(Vector2i(x, 3))
	for y in range(4, 6):
		ring.append(Vector2i(3, y))
		ring.append(Vector2i(9, y))
	for x in range(3, 10):
		ring.append(Vector2i(x, 6))
	floor.loop = ring
	floor.record = CLOISTER_RECORD
	return floor


static func _make_crypt() -> Floor:
	var floor := Floor.new()
	floor.id = "crypt"
	floor.title = "The Crypt"
	floor.rows = CRYPT_ROWS
	floor.loop_name = "Crypt ring"
	var ring: Array = []
	for x in range(3, 9):
		ring.append(Vector2i(x, 2))
	for y in range(3, 7):
		ring.append(Vector2i(3, y))
		ring.append(Vector2i(8, y))
	for x in range(3, 9):
		ring.append(Vector2i(x, 7))
	floor.loop = ring
	floor.record = CRYPT_RECORD
	return floor


static func _make_ossuary() -> Floor:
	var floor := Floor.new()
	floor.id = "ossuary"
	floor.title = "The Ossuary"
	floor.rows = OSSUARY_ROWS
	floor.loop_name = "Ossuary ring"
	var ring: Array = []
	for x in range(3, 11):
		ring.append(Vector2i(x, 2))
	for y in range(3, 6):
		ring.append(Vector2i(3, y))
		ring.append(Vector2i(10, y))
	for x in range(3, 11):
		ring.append(Vector2i(x, 6))
	floor.loop = ring
	floor.record = OSSUARY_RECORD
	return floor


static func _make_reliquary() -> Floor:
	var floor := Floor.new()
	floor.id = "reliquary"
	floor.title = "The Reliquary"
	floor.rows = RELIQUARY_ROWS
	floor.loop_name = "Reliquary ring"
	var ring: Array = []
	for x in range(4, 9):
		ring.append(Vector2i(x, 2))
	for y in range(3, 8):
		ring.append(Vector2i(4, y))
		ring.append(Vector2i(8, y))
	for x in range(4, 9):
		ring.append(Vector2i(x, 8))
	floor.loop = ring
	floor.record = RELIQUARY_RECORD
	return floor


static func _make_undercroft() -> Floor:
	var floor := Floor.new()
	floor.id = "undercroft"
	floor.title = "The Undercroft"
	floor.rows = UNDERCROFT_ROWS
	floor.loop_name = "Undercroft ring"
	var ring: Array = []
	for x in range(5, 10):
		ring.append(Vector2i(x, 2))
	for y in range(3, 10):
		ring.append(Vector2i(5, y))
		ring.append(Vector2i(9, y))
	for x in range(5, 10):
		ring.append(Vector2i(x, 10))
	floor.loop = ring
	floor.record = UNDERCROFT_RECORD
	return floor


static func _make_wellhouse() -> Floor:
	var floor := Floor.new()
	floor.id = "wellhouse"
	floor.title = "The Well House"
	floor.rows = WELL_ROWS
	floor.loop_name = "Well ring"
	var ring: Array = []
	for x in range(4, 11):
		ring.append(Vector2i(x, 2))
	for y in range(3, 9):
		ring.append(Vector2i(4, y))
		ring.append(Vector2i(10, y))
	for x in range(4, 11):
		ring.append(Vector2i(x, 9))
	floor.loop = ring
	floor.record = WELL_RECORD
	return floor


static func _make_scriptorium() -> Floor:
	var floor := Floor.new()
	floor.id = "scriptorium"
	floor.title = "The Scriptorium"
	floor.rows = SCRIPTORIUM_ROWS
	floor.loop_name = "Scriptorium ring"
	var ring: Array = []
	for x in range(5, 11):
		ring.append(Vector2i(x, 2))
	for y in range(3, 8):
		ring.append(Vector2i(10, y))
	ring.append(Vector2i(9, 7))
	for y in range(7, 11):
		ring.append(Vector2i(8, y))
	for x in range(8, 4, -1):
		ring.append(Vector2i(x, 11))
	for y in range(10, 2, -1):
		ring.append(Vector2i(5, y))
	floor.loop = ring
	floor.record = SCRIPTORIUM_RECORD
	return floor


static func _make_binding() -> Floor:
	var floor := Floor.new()
	floor.id = "binding"
	floor.title = "The Binding"
	floor.rows = BINDING_ROWS
	floor.loop_name = "Binding ring"
	var ring: Array = []
	for x in range(4, 9):
		ring.append(Vector2i(x, 2))
	for y in range(3, 8):
		ring.append(Vector2i(4, y))
		ring.append(Vector2i(8, y))
	for x in range(4, 9):
		ring.append(Vector2i(x, 8))
	floor.loop = ring
	floor.record = BINDING_RECORD
	return floor


static func _make_chartroom() -> Floor:
	var floor := Floor.new()
	floor.id = "chartroom"
	floor.title = "The Chart Room"
	floor.rows = CHART_ROWS
	floor.loop_name = "Chart room ring"
	var ring: Array = []
	for x in range(8, 12):
		ring.append(Vector2i(x, 1))
	for y in range(2, 10):
		ring.append(Vector2i(8, y))
		ring.append(Vector2i(11, y))
	for x in range(8, 12):
		ring.append(Vector2i(x, 10))
	floor.loop = ring
	floor.record = CHART_RECORD
	return floor


static func _make_bellloft() -> Floor:
	var floor := Floor.new()
	floor.id = "bellloft"
	floor.title = "The Bell Loft"
	floor.rows = BELL_ROWS
	floor.loop_name = "Bell loft ring"
	var ring: Array = []
	for x in range(5, 11):
		ring.append(Vector2i(x, 3))
	for y in range(4, 8):
		ring.append(Vector2i(5, y))
		ring.append(Vector2i(10, y))
	for x in range(5, 11):
		ring.append(Vector2i(x, 8))
	floor.loop = ring
	floor.record = BELL_RECORD
	return floor


static func _make_clockroom() -> Floor:
	var floor := Floor.new()
	floor.id = "clockroom"
	floor.title = "The Clock Room"
	floor.rows = CLOCK_ROWS
	floor.loop_name = "Clock room ring"
	var ring: Array = []
	for x in range(5, 12):
		ring.append(Vector2i(x, 3))
	for y in range(4, 8):
		ring.append(Vector2i(5, y))
		ring.append(Vector2i(11, y))
	for x in range(5, 12):
		ring.append(Vector2i(x, 8))
	floor.loop = ring
	floor.record = CLOCK_RECORD
	return floor


static func _make_font() -> Floor:
	var floor := Floor.new()
	floor.id = "font"
	floor.title = "The Font"
	floor.rows = FONT_ROWS
	floor.loop_name = "Font ring"
	var ring: Array = []
	for x in range(6, 12):
		ring.append(Vector2i(x, 3))
	for y in range(4, 10):
		ring.append(Vector2i(6, y))
		ring.append(Vector2i(11, y))
	for x in range(6, 12):
		ring.append(Vector2i(x, 10))
	floor.loop = ring
	floor.record = FONT_RECORD
	return floor


static func _make_apse() -> Floor:
	var floor := Floor.new()
	floor.id = "apse"
	floor.title = "The Apse"
	floor.rows = APSE_ROWS
	floor.loop_name = "Apse ring"
	var ring: Array = []
	for x in range(6, 13):
		ring.append(Vector2i(x, 3))
	for y in range(4, 10):
		ring.append(Vector2i(6, y))
		ring.append(Vector2i(12, y))
	for x in range(6, 13):
		ring.append(Vector2i(x, 10))
	floor.loop = ring
	floor.record = APSE_RECORD
	return floor


static func _make_choir() -> Floor:
	var floor := Floor.new()
	floor.id = "choir"
	floor.title = "The Choir"
	floor.rows = CHOIR_ROWS
	floor.loop_name = "Choir ring"
	var ring: Array = []
	for x in range(6, 14):
		ring.append(Vector2i(x, 3))
	for y in range(4, 10):
		ring.append(Vector2i(6, y))
		ring.append(Vector2i(13, y))
	for x in range(6, 14):
		ring.append(Vector2i(x, 10))
	floor.loop = ring
	floor.record = CHOIR_RECORD
	return floor


static func _make_rood() -> Floor:
	var floor := Floor.new()
	floor.id = "rood"
	floor.title = "The Rood"
	floor.rows = ROOD_ROWS
	floor.loop_name = "Rood ring"
	var ring: Array = []
	for x in range(6, 15):
		ring.append(Vector2i(x, 3))
	for y in range(4, 10):
		ring.append(Vector2i(6, y))
		ring.append(Vector2i(14, y))
	for x in range(6, 15):
		ring.append(Vector2i(x, 10))
	floor.loop = ring
	floor.record = ROOD_RECORD
	return floor


static func _make_crossing() -> Floor:
	var floor := Floor.new()
	floor.id = "crossing"
	floor.title = "The Crossing"
	floor.rows = CROSSING_ROWS
	floor.loop_name = "Crossing ring"
	var ring: Array = []
	for x in range(6, 16):
		ring.append(Vector2i(x, 3))
	for y in range(4, 10):
		ring.append(Vector2i(6, y))
		ring.append(Vector2i(15, y))
	for x in range(6, 16):
		ring.append(Vector2i(x, 10))
	floor.loop = ring
	floor.record = CROSSING_RECORD
	return floor


static func _make_transept() -> Floor:
	var floor := Floor.new()
	floor.id = "transept"
	floor.title = "The Transept"
	floor.rows = TRANSEPT_ROWS
	floor.loop_name = "Transept ring"
	var ring: Array = []
	for x in range(6, 17):
		ring.append(Vector2i(x, 3))
	for y in range(4, 10):
		ring.append(Vector2i(6, y))
		ring.append(Vector2i(16, y))
	for x in range(6, 17):
		ring.append(Vector2i(x, 10))
	floor.loop = ring
	floor.record = TRANSEPT_RECORD
	return floor


static func _make_ambulatory() -> Floor:
	var floor := Floor.new()
	floor.id = "ambulatory"
	floor.title = "The Ambulatory"
	floor.rows = AMBULATORY_ROWS
	floor.loop_name = "Ambulatory ring"
	var ring: Array = []
	for x in range(6, 18):
		ring.append(Vector2i(x, 3))
	for y in range(4, 10):
		ring.append(Vector2i(6, y))
		ring.append(Vector2i(17, y))
	for x in range(6, 18):
		ring.append(Vector2i(x, 10))
	floor.loop = ring
	floor.record = AMBULATORY_RECORD
	return floor


static func _make_chevet() -> Floor:
	var floor := Floor.new()
	floor.id = "chevet"
	floor.title = "The Chevet"
	floor.rows = CHEVET_ROWS
	floor.loop_name = "Chevet ring"
	var ring: Array = []
	for x in range(6, 19):
		ring.append(Vector2i(x, 3))
	for y in range(4, 10):
		ring.append(Vector2i(6, y))
		ring.append(Vector2i(18, y))
	for x in range(6, 19):
		ring.append(Vector2i(x, 10))
	floor.loop = ring
	floor.record = CHEVET_RECORD
	return floor



static func _make_retrochoir() -> Floor:
	var floor := Floor.new()
	floor.id = "retrochoir"
	floor.title = "The Retrochoir"
	floor.rows = RETROCHOIR_ROWS
	floor.loop_name = "Retrochoir ring"
	var ring: Array = []
	for x in range(6, 20):
		ring.append(Vector2i(x, 3))
	for y in range(4, 10):
		ring.append(Vector2i(6, y))
		ring.append(Vector2i(19, y))
	for x in range(6, 20):
		ring.append(Vector2i(x, 10))
	floor.loop = ring
	floor.record = RETROCHOIR_RECORD
	return floor


static func _make_ladychapel() -> Floor:
	var floor := Floor.new()
	floor.id = "ladychapel"
	floor.title = "The Lady Chapel"
	floor.rows = LADY_CHAPEL_ROWS
	floor.loop_name = "Lady chapel ring"
	var ring: Array = []
	for x in range(6, 21):
		ring.append(Vector2i(x, 3))
	for y in range(4, 10):
		ring.append(Vector2i(6, y))
		ring.append(Vector2i(20, y))
	for x in range(6, 21):
		ring.append(Vector2i(x, 10))
	floor.loop = ring
	floor.record = LADY_CHAPEL_RECORD
	return floor


static func _make_feretory() -> Floor:
	var floor := Floor.new()
	floor.id = "feretory"
	floor.title = "The Feretory"
	floor.rows = FERETORY_ROWS
	floor.loop_name = "Feretory ring"
	var ring: Array = []
	for x in range(6, 22):
		ring.append(Vector2i(x, 3))
	for y in range(4, 10):
		ring.append(Vector2i(6, y))
		ring.append(Vector2i(21, y))
	for x in range(6, 22):
		ring.append(Vector2i(x, 10))
	floor.loop = ring
	floor.record = FERETORY_RECORD
	return floor


static func _make_chantry() -> Floor:
	var floor := Floor.new()
	floor.id = "chantry"
	floor.title = "The Chantry"
	floor.rows = CHANTRY_ROWS
	floor.loop_name = "Chantry ring"
	var ring: Array = []
	for x in range(6, 22):
		ring.append(Vector2i(x, 3))
	for y in range(4, 10):
		ring.append(Vector2i(6, y))
		ring.append(Vector2i(21, y))
	for x in range(6, 22):
		ring.append(Vector2i(x, 10))
	floor.loop = ring
	floor.record = CHANTRY_RECORD
	return floor


static func _make_sacristy() -> Floor:
	var floor := Floor.new()
	floor.id = "sacristy"
	floor.title = "The Sacristy"
	floor.rows = SACRISTY_ROWS
	floor.loop_name = "Sacristy ring"
	var ring: Array = []
	for x in range(6, 22):
		ring.append(Vector2i(x, 3))
	for y in range(4, 10):
		ring.append(Vector2i(6, y))
		ring.append(Vector2i(21, y))
	for x in range(6, 22):
		ring.append(Vector2i(x, 10))
	floor.loop = ring
	floor.record = SACRISTY_RECORD
	return floor

static func _make_pyx() -> Floor:
	var floor := Floor.new()
	floor.id = "pyx"
	floor.title = "The Pyx Chamber"
	floor.rows = PYX_ROWS
	floor.loop_name = "Pyx ring"
	var ring: Array = []
	for x in range(6, 22):
		ring.append(Vector2i(x, 3))
	for y in range(4, 10):
		ring.append(Vector2i(6, y))
		ring.append(Vector2i(21, y))
	for x in range(6, 22):
		ring.append(Vector2i(x, 10))
	floor.loop = ring
	floor.record = PYX_RECORD
	return floor

static func _make_aumbry() -> Floor:
	var floor := Floor.new()
	floor.id = "aumbry"
	floor.title = "The Aumbry"
	floor.rows = AUMBRY_ROWS
	floor.loop_name = "Aumbry ring"
	var ring: Array = []
	for x in range(6, 22):
		ring.append(Vector2i(x, 3))
	for y in range(4, 10):
		ring.append(Vector2i(6, y))
		ring.append(Vector2i(21, y))
	for x in range(6, 22):
		ring.append(Vector2i(x, 10))
	floor.loop = ring
	floor.record = AUMBRY_RECORD
	return floor

static func _make_piscina() -> Floor:
	var floor := Floor.new()
	floor.id = "piscina"
	floor.title = "The Piscina"
	floor.rows = PISCINA_ROWS
	floor.loop_name = "Piscina ring"
	var ring: Array = []
	for x in range(6, 22):
		ring.append(Vector2i(x, 3))
	for y in range(4, 10):
		ring.append(Vector2i(6, y))
		ring.append(Vector2i(21, y))
	for x in range(6, 22):
		ring.append(Vector2i(x, 10))
	floor.loop = ring
	floor.record = PISCINA_RECORD
	return floor

static func _make_sedilia() -> Floor:
	var floor := Floor.new()
	floor.id = "sedilia"
	floor.title = "The Sedilia"
	floor.rows = SEDILIA_ROWS
	floor.loop_name = "Sedilia ring"
	var ring: Array = []
	for x in range(6, 22):
		ring.append(Vector2i(x, 3))
	for y in range(4, 10):
		ring.append(Vector2i(6, y))
		ring.append(Vector2i(21, y))
	for x in range(6, 22):
		ring.append(Vector2i(x, 10))
	floor.loop = ring
	floor.record = SEDILIA_RECORD
	return floor

static func _make_credence() -> Floor:
	var floor := Floor.new()
	floor.id = "credence"
	floor.title = "The Credence"
	floor.rows = CREDENCE_ROWS
	floor.loop_name = "Credence ring"
	var ring: Array = []
	for x in range(6, 22):
		ring.append(Vector2i(x, 3))
	for y in range(4, 10):
		ring.append(Vector2i(6, y))
		ring.append(Vector2i(21, y))
	for x in range(6, 22):
		ring.append(Vector2i(x, 10))
	floor.loop = ring
	floor.record = CREDENCE_RECORD
	return floor


static func _make_reredos() -> Floor:
	var floor := Floor.new()
	floor.id = "reredos"
	floor.title = "The Reredos"
	floor.rows = REREDOS_ROWS
	floor.loop_name = "Reredos ring"
	var ring: Array = []
	for x in range(6, 22):
		ring.append(Vector2i(x, 3))
	for y in range(4, 10):
		ring.append(Vector2i(6, y))
		ring.append(Vector2i(21, y))
	for x in range(6, 9):
		ring.append(Vector2i(x, 10))
	ring.append(Vector2i(8, 11))
	ring.append(Vector2i(9, 11))
	ring.append(Vector2i(10, 11))
	for x in range(10, 22):
		ring.append(Vector2i(x, 10))
	floor.loop = ring
	floor.record = REREDOS_RECORD
	return floor


static func _make_predella() -> Floor:
	var floor := Floor.new()
	floor.id = "predella"
	floor.title = "The Predella"
	floor.rows = PREDELLA_ROWS
	floor.loop_name = "Predella ring"
	var ring: Array = []
	for x in range(6, 22):
		ring.append(Vector2i(x, 3))
	for y in range(4, 10):
		ring.append(Vector2i(21, y))
	for x in range(21, 9, -1):
		ring.append(Vector2i(x, 10))
	ring.append(Vector2i(10, 11))
	ring.append(Vector2i(9, 11))
	ring.append(Vector2i(8, 11))
	ring.append(Vector2i(7, 11))
	ring.append(Vector2i(7, 10))
	ring.append(Vector2i(6, 10))
	for y in range(9, 3, -1):
		ring.append(Vector2i(6, y))
	floor.loop = ring
	floor.record = PREDELLA_RECORD
	return floor



static func _make_dossal() -> Floor:
	var floor := Floor.new()
	floor.id = "dossal"
	floor.title = "The Dossal"
	floor.rows = DOSSAL_ROWS
	floor.loop_name = "Dossal ring"
	var ring: Array = []
	for x in range(6, 22):
		ring.append(Vector2i(x, 3))
	for y in range(4, 10):
		ring.append(Vector2i(21, y))
	for x in range(21, 10, -1):
		ring.append(Vector2i(x, 10))
	ring.append(Vector2i(11, 11))
	ring.append(Vector2i(10, 11))
	ring.append(Vector2i(9, 11))
	ring.append(Vector2i(8, 11))
	ring.append(Vector2i(7, 11))
	ring.append(Vector2i(7, 10))
	ring.append(Vector2i(6, 10))
	for y in range(9, 3, -1):
		ring.append(Vector2i(6, y))
	floor.loop = ring
	floor.record = DOSSAL_RECORD
	return floor



static func _make_retable() -> Floor:
	var floor := Floor.new()
	floor.id = "retable"
	floor.title = "The Retable"
	floor.rows = RETABLE_ROWS
	floor.loop_name = "Retable ring"
	var ring: Array = []
	for x in range(6, 22):
		ring.append(Vector2i(x, 3))
	for y in range(4, 10):
		ring.append(Vector2i(21, y))
	for x in range(21, 10, -1):
		ring.append(Vector2i(x, 10))
	ring.append(Vector2i(11, 11))
	ring.append(Vector2i(10, 11))
	ring.append(Vector2i(9, 11))
	ring.append(Vector2i(8, 11))
	ring.append(Vector2i(7, 11))
	ring.append(Vector2i(7, 10))
	ring.append(Vector2i(6, 10))
	for y in range(9, 3, -1):
		ring.append(Vector2i(6, y))
	floor.loop = ring
	floor.record = RETABLE_RECORD
	return floor



static func _make_tester() -> Floor:
	var floor := Floor.new()
	floor.id = "tester"
	floor.title = "The Tester"
	floor.rows = TESTER_ROWS
	floor.loop_name = "Tester ring"
	var ring: Array = []
	for x in range(6, 22):
		ring.append(Vector2i(x, 3))
	for y in range(4, 10):
		ring.append(Vector2i(21, y))
	for x in range(21, 10, -1):
		ring.append(Vector2i(x, 10))
	ring.append(Vector2i(11, 11))
	ring.append(Vector2i(10, 11))
	ring.append(Vector2i(9, 11))
	ring.append(Vector2i(8, 11))
	ring.append(Vector2i(7, 11))
	ring.append(Vector2i(7, 10))
	ring.append(Vector2i(6, 10))
	for y in range(9, 3, -1):
		ring.append(Vector2i(6, y))
	floor.loop = ring
	floor.record = TESTER_RECORD
	return floor



static func _make_riddel() -> Floor:
	var floor := Floor.new()
	floor.id = "riddel"
	floor.title = "The Riddel"
	floor.rows = RIDDEL_ROWS
	floor.loop_name = "Riddel ring"
	var ring: Array = []
	for x in range(6, 22):
		ring.append(Vector2i(x, 3))
	for y in range(4, 10):
		ring.append(Vector2i(21, y))
	for x in range(21, 10, -1):
		ring.append(Vector2i(x, 10))
	ring.append(Vector2i(11, 11))
	ring.append(Vector2i(10, 11))
	ring.append(Vector2i(9, 11))
	ring.append(Vector2i(8, 11))
	ring.append(Vector2i(7, 11))
	ring.append(Vector2i(7, 10))
	ring.append(Vector2i(6, 10))
	for y in range(9, 3, -1):
		ring.append(Vector2i(6, y))
	floor.loop = ring
	floor.record = RIDDEL_RECORD
	return floor



static func _make_frontal() -> Floor:
	var floor := Floor.new()
	floor.id = "frontal"
	floor.title = "The Frontal"
	floor.rows = FRONTAL_ROWS
	floor.loop_name = "Frontal ring"
	var ring: Array = []
	for x in range(6, 22):
		ring.append(Vector2i(x, 3))
	for y in range(4, 10):
		ring.append(Vector2i(21, y))
	for x in range(21, 10, -1):
		ring.append(Vector2i(x, 10))
	ring.append(Vector2i(11, 11))
	ring.append(Vector2i(10, 11))
	ring.append(Vector2i(9, 11))
	ring.append(Vector2i(8, 11))
	ring.append(Vector2i(7, 11))
	ring.append(Vector2i(6, 11))
	ring.append(Vector2i(6, 10))
	for y in range(9, 3, -1):
		ring.append(Vector2i(6, y))
	floor.loop = ring
	floor.record = FRONTAL_RECORD
	return floor



static func _make_pall() -> Floor:
	var floor := Floor.new()
	floor.id = "pall"
	floor.title = "The Pall"
	floor.rows = PALL_ROWS
	floor.loop_name = "Pall ring"
	var ring: Array = []
	for x in range(6, 22):
		ring.append(Vector2i(x, 3))
	for y in range(5, 10):
		ring.append(Vector2i(21, y))
	for x in range(21, 10, -1):
		ring.append(Vector2i(x, 10))
	ring.append(Vector2i(11, 11))
	ring.append(Vector2i(10, 11))
	ring.append(Vector2i(9, 11))
	ring.append(Vector2i(8, 11))
	ring.append(Vector2i(7, 11))
	ring.append(Vector2i(6, 11))
	ring.append(Vector2i(6, 10))
	for y in range(9, 3, -1):
		ring.append(Vector2i(6, y))
	floor.loop = ring
	floor.record = PALL_RECORD
	return floor



static func _make_herse() -> Floor:
	var floor := Floor.new()
	floor.id = "herse"
	floor.title = "The Herse"
	floor.rows = HERSE_ROWS
	floor.loop_name = "Herse ring"
	var ring: Array = []
	for x in range(6, 22):
		ring.append(Vector2i(x, 3))
	for y in range(6, 10):
		ring.append(Vector2i(21, y))
	for x in range(21, 10, -1):
		ring.append(Vector2i(x, 10))
	ring.append(Vector2i(11, 11))
	ring.append(Vector2i(10, 11))
	ring.append(Vector2i(9, 11))
	ring.append(Vector2i(8, 11))
	ring.append(Vector2i(7, 11))
	ring.append(Vector2i(6, 11))
	ring.append(Vector2i(6, 10))
	for y in range(9, 3, -1):
		ring.append(Vector2i(6, y))
	floor.loop = ring
	floor.record = HERSE_RECORD
	return floor



static func _make_catafalque() -> Floor:
	var floor := Floor.new()
	floor.id = "catafalque"
	floor.title = "The Catafalque"
	floor.rows = CATAFALQUE_ROWS
	floor.loop_name = "Catafalque ring"
	var ring: Array = []
	for x in range(6, 22):
		ring.append(Vector2i(x, 3))
	for y in range(7, 10):
		ring.append(Vector2i(21, y))
	for x in range(21, 10, -1):
		ring.append(Vector2i(x, 10))
	ring.append(Vector2i(11, 11))
	ring.append(Vector2i(10, 11))
	ring.append(Vector2i(9, 11))
	ring.append(Vector2i(8, 11))
	ring.append(Vector2i(7, 11))
	ring.append(Vector2i(6, 11))
	ring.append(Vector2i(6, 10))
	for y in range(9, 3, -1):
		ring.append(Vector2i(6, y))
	floor.loop = ring
	floor.record = CATAFALQUE_RECORD
	return floor



static func _make_bier() -> Floor:
	var floor := Floor.new()
	floor.id = "bier"
	floor.title = "The Bier"
	floor.rows = BIER_ROWS
	floor.loop_name = "Bier ring"
	var ring: Array = []
	for x in range(6, 22):
		ring.append(Vector2i(x, 3))
	for y in range(8, 10):
		ring.append(Vector2i(21, y))
	for x in range(21, 10, -1):
		ring.append(Vector2i(x, 10))
	ring.append(Vector2i(11, 11))
	ring.append(Vector2i(10, 11))
	ring.append(Vector2i(9, 11))
	ring.append(Vector2i(8, 11))
	ring.append(Vector2i(7, 11))
	ring.append(Vector2i(6, 11))
	ring.append(Vector2i(6, 10))
	for y in range(9, 3, -1):
		ring.append(Vector2i(6, y))
	floor.loop = ring
	floor.record = BIER_RECORD
	return floor



static func _make_cerecloth() -> Floor:
	var floor := Floor.new()
	floor.id = "cerecloth"
	floor.title = "The Cerecloth"
	floor.rows = CERECLOTH_ROWS
	floor.loop_name = "Cerecloth ring"
	var ring: Array = []
	for x in range(6, 22):
		ring.append(Vector2i(x, 3))
	for y in range(9, 10):
		ring.append(Vector2i(21, y))
	for x in range(21, 10, -1):
		ring.append(Vector2i(x, 10))
	ring.append(Vector2i(11, 11))
	ring.append(Vector2i(10, 11))
	ring.append(Vector2i(9, 11))
	ring.append(Vector2i(8, 11))
	ring.append(Vector2i(7, 11))
	ring.append(Vector2i(6, 11))
	ring.append(Vector2i(6, 10))
	for y in range(9, 3, -1):
		ring.append(Vector2i(6, y))
	floor.loop = ring
	floor.record = CERECLOTH_RECORD
	return floor



static func _make_hearse() -> Floor:
	var floor := Floor.new()
	floor.id = "hearse"
	floor.title = "The Hearse"
	floor.rows = HEARSE_ROWS
	floor.loop_name = "Hearse ring"
	var ring: Array = []
	for x in range(6, 22):
		ring.append(Vector2i(x, 3))
	for x in range(21, 10, -1):
		ring.append(Vector2i(x, 10))
	ring.append(Vector2i(11, 11))
	ring.append(Vector2i(10, 11))
	ring.append(Vector2i(9, 11))
	ring.append(Vector2i(8, 11))
	ring.append(Vector2i(7, 11))
	ring.append(Vector2i(6, 11))
	ring.append(Vector2i(6, 10))
	for y in range(9, 3, -1):
		ring.append(Vector2i(6, y))
	floor.loop = ring
	floor.record = HEARSE_RECORD
	return floor



static func _make_shroud() -> Floor:
	var floor := Floor.new()
	floor.id = "shroud"
	floor.title = "The Shroud"
	floor.rows = SHROUD_ROWS
	floor.loop_name = "Shroud ring"
	var ring: Array = []
	for x in range(6, 22):
		ring.append(Vector2i(x, 3))
	for x in range(20, 10, -1):
		ring.append(Vector2i(x, 10))
	ring.append(Vector2i(11, 11))
	ring.append(Vector2i(10, 11))
	ring.append(Vector2i(9, 11))
	ring.append(Vector2i(8, 11))
	ring.append(Vector2i(7, 11))
	ring.append(Vector2i(6, 11))
	ring.append(Vector2i(6, 10))
	for y in range(9, 3, -1):
		ring.append(Vector2i(6, y))
	floor.loop = ring
	floor.record = SHROUD_RECORD
	return floor



static func _make_pyre() -> Floor:
	var floor := Floor.new()
	floor.id = "pyre"
	floor.title = "The Pyre"
	floor.rows = PYRE_ROWS
	floor.loop_name = "Pyre ring"
	var ring: Array = []
	for x in range(6, 22):
		ring.append(Vector2i(x, 3))
	for x in range(19, 10, -1):
		ring.append(Vector2i(x, 10))
	ring.append(Vector2i(11, 11))
	ring.append(Vector2i(10, 11))
	ring.append(Vector2i(9, 11))
	ring.append(Vector2i(8, 11))
	ring.append(Vector2i(7, 11))
	ring.append(Vector2i(6, 11))
	ring.append(Vector2i(6, 10))
	for y in range(9, 3, -1):
		ring.append(Vector2i(6, y))
	floor.loop = ring
	floor.record = PYRE_RECORD
	return floor



static func _make_cenotaph() -> Floor:
	var floor := Floor.new()
	floor.id = "cenotaph"
	floor.title = "The Cenotaph"
	floor.rows = CENOTAPH_ROWS
	floor.loop_name = "Cenotaph ring"
	var ring: Array = []
	for x in range(6, 22):
		ring.append(Vector2i(x, 3))
	for x in range(18, 10, -1):
		ring.append(Vector2i(x, 10))
	ring.append(Vector2i(11, 11))
	ring.append(Vector2i(10, 11))
	ring.append(Vector2i(9, 11))
	ring.append(Vector2i(8, 11))
	ring.append(Vector2i(7, 11))
	ring.append(Vector2i(6, 11))
	ring.append(Vector2i(6, 10))
	for y in range(9, 3, -1):
		ring.append(Vector2i(6, y))
	floor.loop = ring
	floor.record = CENOTAPH_RECORD
	return floor



static func _make_winding() -> Floor:
	var floor := Floor.new()
	floor.id = "winding"
	floor.title = "The Winding"
	floor.rows = WINDING_ROWS
	floor.loop_name = "Winding ring"
	var ring: Array = []
	for x in range(6, 22):
		ring.append(Vector2i(x, 3))
	for x in range(17, 10, -1):
		ring.append(Vector2i(x, 10))
	ring.append(Vector2i(11, 11))
	ring.append(Vector2i(10, 11))
	ring.append(Vector2i(9, 11))
	ring.append(Vector2i(8, 11))
	ring.append(Vector2i(7, 11))
	ring.append(Vector2i(6, 11))
	ring.append(Vector2i(6, 10))
	for y in range(9, 3, -1):
		ring.append(Vector2i(6, y))
	floor.loop = ring
	floor.record = WINDING_RECORD
	return floor



static func _make_charnel() -> Floor:
	var floor := Floor.new()
	floor.id = "charnel"
	floor.title = "The Charnel"
	floor.rows = CHARNEL_ROWS
	floor.loop_name = "Charnel ring"
	var ring: Array = []
	for x in range(6, 22):
		ring.append(Vector2i(x, 3))
	for x in range(16, 10, -1):
		ring.append(Vector2i(x, 10))
	ring.append(Vector2i(11, 11))
	ring.append(Vector2i(10, 11))
	ring.append(Vector2i(9, 11))
	ring.append(Vector2i(8, 11))
	ring.append(Vector2i(7, 11))
	ring.append(Vector2i(6, 11))
	ring.append(Vector2i(6, 10))
	for y in range(9, 3, -1):
		ring.append(Vector2i(6, y))
	floor.loop = ring
	floor.record = CHARNEL_RECORD
	return floor



static func _make_sepulchre() -> Floor:
	var floor := Floor.new()
	floor.id = "sepulchre"
	floor.title = "The Sepulchre"
	floor.rows = SEPULCHRE_ROWS
	floor.loop_name = "Sepulchre ring"
	var ring: Array = []
	for x in range(6, 22):
		ring.append(Vector2i(x, 3))
	for x in range(15, 10, -1):
		ring.append(Vector2i(x, 10))
	ring.append(Vector2i(11, 11))
	ring.append(Vector2i(10, 11))
	ring.append(Vector2i(9, 11))
	ring.append(Vector2i(8, 11))
	ring.append(Vector2i(7, 11))
	ring.append(Vector2i(6, 11))
	ring.append(Vector2i(6, 10))
	for y in range(9, 3, -1):
		ring.append(Vector2i(6, y))
	floor.loop = ring
	floor.record = SEPULCHRE_RECORD
	return floor



static func _make_vault() -> Floor:
	var floor := Floor.new()
	floor.id = "vault"
	floor.title = "The Vault"
	floor.rows = VAULT_ROWS
	floor.loop_name = "Vault ring"
	var ring: Array = []
	for x in range(6, 22):
		ring.append(Vector2i(x, 3))
	for x in range(14, 10, -1):
		ring.append(Vector2i(x, 10))
	ring.append(Vector2i(11, 11))
	ring.append(Vector2i(10, 11))
	ring.append(Vector2i(9, 11))
	ring.append(Vector2i(8, 11))
	ring.append(Vector2i(7, 11))
	ring.append(Vector2i(6, 11))
	ring.append(Vector2i(6, 10))
	for y in range(9, 3, -1):
		ring.append(Vector2i(6, y))
	floor.loop = ring
	floor.record = VAULT_RECORD
	return floor



static func _make_cairn() -> Floor:
	var floor := Floor.new()
	floor.id = "cairn"
	floor.title = "The Cairn"
	floor.rows = CAIRN_ROWS
	floor.loop_name = "Cairn ring"
	var ring: Array = []
	for x in range(6, 22):
		ring.append(Vector2i(x, 3))
	for x in range(13, 10, -1):
		ring.append(Vector2i(x, 10))
	ring.append(Vector2i(11, 11))
	ring.append(Vector2i(10, 11))
	ring.append(Vector2i(9, 11))
	ring.append(Vector2i(8, 11))
	ring.append(Vector2i(7, 11))
	ring.append(Vector2i(6, 11))
	ring.append(Vector2i(6, 10))
	for y in range(9, 3, -1):
		ring.append(Vector2i(6, y))
	floor.loop = ring
	floor.record = CAIRN_RECORD
	return floor



static func _make_columbarium() -> Floor:
	var floor := Floor.new()
	floor.id = "columbarium"
	floor.title = "The Columbarium"
	floor.rows = COLUMBARIUM_ROWS
	floor.loop_name = "Columbarium ring"
	var ring: Array = []
	for x in range(6, 22):
		ring.append(Vector2i(x, 3))
	for x in range(12, 10, -1):
		ring.append(Vector2i(x, 10))
	ring.append(Vector2i(11, 11))
	ring.append(Vector2i(10, 11))
	ring.append(Vector2i(9, 11))
	ring.append(Vector2i(8, 11))
	ring.append(Vector2i(7, 11))
	ring.append(Vector2i(6, 11))
	ring.append(Vector2i(6, 10))
	for y in range(9, 3, -1):
		ring.append(Vector2i(6, y))
	floor.loop = ring
	floor.record = COLUMBARIUM_RECORD
	return floor



static func _make_loculus() -> Floor:
	var floor := Floor.new()
	floor.id = "loculus"
	floor.title = "The Loculus"
	floor.rows = LOCULUS_ROWS
	floor.loop_name = "Loculus ring"
	var ring: Array = []
	for x in range(6, 22):
		ring.append(Vector2i(x, 3))
	for x in range(11, 10, -1):
		ring.append(Vector2i(x, 10))
	ring.append(Vector2i(11, 11))
	ring.append(Vector2i(10, 11))
	ring.append(Vector2i(9, 11))
	ring.append(Vector2i(8, 11))
	ring.append(Vector2i(7, 11))
	ring.append(Vector2i(6, 11))
	ring.append(Vector2i(6, 10))
	for y in range(9, 3, -1):
		ring.append(Vector2i(6, y))
	floor.loop = ring
	floor.record = LOCULUS_RECORD
	return floor



static func _make_arcosolium() -> Floor:
	var floor := Floor.new()
	floor.id = "arcosolium"
	floor.title = "The Arcosolium"
	floor.rows = ARCOSOLIUM_ROWS
	floor.loop_name = "Arcosolium ring"
	var ring: Array = []
	for x in range(6, 22):
		ring.append(Vector2i(x, 3))
	ring.append(Vector2i(11, 11))
	ring.append(Vector2i(10, 11))
	ring.append(Vector2i(9, 11))
	ring.append(Vector2i(8, 11))
	ring.append(Vector2i(7, 11))
	ring.append(Vector2i(6, 11))
	ring.append(Vector2i(6, 10))
	for y in range(9, 3, -1):
		ring.append(Vector2i(6, y))
	floor.loop = ring
	floor.record = ARCOSOLIUM_RECORD
	return floor


static func width(floor: Floor = null) -> int:
	return _use(floor).rows[0].length()


static func height(floor: Floor = null) -> int:
	return _use(floor).rows.size()


static func in_bounds(p: Vector2i, floor: Floor = null) -> bool:
	var rows := _use(floor).rows
	return p.y >= 0 and p.y < rows.size() and p.x >= 0 and p.x < rows[p.y].length()


static func glyph_at(p: Vector2i, floor: Floor = null) -> String:
	var plan := _use(floor)
	if not in_bounds(p, plan):
		return "#"
	return plan.rows[p.y][p.x]


static func tile_at(p: Vector2i, floor: Floor = null) -> int:
	var ch := glyph_at(p, floor)
	if ch == "#" or ch == "*" or ch == "+":
		return Tile.WALL
	if ch == "H":
		return Tile.HAZARD
	if ch == "L":
		return Tile.LIFT
	if ch == "." or ch == "S" or ch == "E":
		return Tile.FLOOR
	return Tile.WALL


static func find_char(ch: String, floor: Floor = null) -> Vector2i:
	var rows := _use(floor).rows
	for y in rows.size():
		var x := rows[y].find(ch)
		if x >= 0:
			return Vector2i(x, y)
	return Vector2i(-1, -1)


static func start_pos(floor: Floor = null) -> Vector2i:
	return find_char("S", floor)


static func lift_pos(floor: Floor = null) -> Vector2i:
	return find_char("L", floor)


static func enemy_pos(floor: Floor = null) -> Vector2i:
	return find_char("E", floor)


static func cardinals() -> Array:
	return [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]


static func dir_vector(facing: int) -> Vector2i:
	match posmod(facing, 4):
		0:
			return Vector2i(0, -1)
		1:
			return Vector2i(1, 0)
		2:
			return Vector2i(0, 1)
		_:
			return Vector2i(-1, 0)


static func facing_from_vector(d: Vector2i) -> int:
	if d == Vector2i(0, -1):
		return 0
	if d == Vector2i(1, 0):
		return 1
	if d == Vector2i(0, 1):
		return 2
	return 3


static func swing_tiles(floor: Floor = null) -> Array:
	var enemy := enemy_pos(floor)
	return [enemy + Vector2i(1, 0), enemy + Vector2i(-1, 0)]


static func telegraph_tile(index: int, floor: Floor = null) -> Vector2i:
	var swings := swing_tiles(floor)
	return swings[posmod(index, swings.size())]


static func loop_cells(floor: Floor = null) -> Array:
	return _use(floor).loop.duplicate()


static func is_walkable(p: Vector2i, floor: Floor = null) -> bool:
	var plan := _use(floor)
	if p == enemy_pos(plan):
		return false
	var t := tile_at(p, plan)
	return t == Tile.FLOOR or t == Tile.HAZARD or t == Tile.LIFT


static func is_corridor_cell(p: Vector2i, floor: Floor = null) -> bool:
	var plan := _use(floor)
	if p == enemy_pos(plan):
		return false
	var t := tile_at(p, plan)
	return t == Tile.FLOOR or t == Tile.LIFT


static func corridor_cells(floor: Floor = null) -> Array:
	var plan := _use(floor)
	var cells: Array = []
	for y in height(plan):
		for x in width(plan):
			var p := Vector2i(x, y)
			if is_corridor_cell(p, plan):
				cells.append(p)
	return cells


static func hazard_cells(floor: Floor = null) -> Array:
	var plan := _use(floor)
	var cells: Array = []
	for y in height(plan):
		for x in width(plan):
			var p := Vector2i(x, y)
			if tile_at(p, plan) == Tile.HAZARD:
				cells.append(p)
	return cells


static func walkable_approach(tile: Vector2i, floor: Floor = null) -> Vector2i:
	var plan := _use(floor)
	for d in cardinals():
		var n: Vector2i = tile + d
		if is_walkable(n, plan):
			return n
	return Vector2i(-1, -1)


static func new_campaign() -> Campaign:
	var c := Campaign.new()
	c.purse = 0
	c.flask_oil = SMALL_FLASK_OIL
	c.upgraded = false
	c.last_outcome = "fresh"
	c.last_floor_id = ""
	c.completed = {}
	c.last_bill = payout({})
	return c


static func can_buy(c: Campaign) -> bool:
	return not c.upgraded and c.purse >= LARGE_FLASK_COST


static func buy_flask(c: Campaign) -> bool:
	if not can_buy(c):
		return false
	c.purse -= LARGE_FLASK_COST
	c.flask_oil = LARGE_FLASK_OIL
	c.upgraded = true
	return true


static func new_run(flask_oil: int, floor: Floor = null) -> RunState:
	var plan := _use(floor)
	var state := RunState.new()
	state.floor = plan
	state.pos = start_pos(plan)
	state.facing = facing_from_vector(Vector2i(1, 0))
	state.oil = flask_oil
	state.flask_capacity = flask_oil
	state.marks = {}
	state.marks[state.pos] = Mark.CORRIDOR
	state.telegraph_index = 0
	state.end_reason = EndReason.NONE
	state.last_hit = false
	state.settled = false
	return state


static func accurate_sheet(floor: Floor = null) -> Dictionary:
	var plan := _use(floor)
	var marks := {}
	for cell in corridor_cells(plan):
		marks[cell] = Mark.CORRIDOR
	for cell in hazard_cells(plan):
		marks[cell] = Mark.HAZARD
	return marks


static func true_mark(p: Vector2i, floor: Floor = null) -> int:
	var plan := _use(floor)
	if p == enemy_pos(plan):
		return Mark.NONE
	match tile_at(p, plan):
		Tile.HAZARD:
			return Mark.HAZARD
		Tile.FLOOR, Tile.LIFT:
			return Mark.CORRIDOR
		_:
			return Mark.WALL


static func census_accepted(marks: Dictionary, floor: Floor = null) -> bool:
	var plan := _use(floor)
	for cell in corridor_cells(plan):
		if int(marks.get(cell, Mark.NONE)) != Mark.CORRIDOR:
			return false
	for cell in hazard_cells(plan):
		if int(marks.get(cell, Mark.NONE)) != Mark.HAZARD:
			return false
	for key in marks.keys():
		var p: Vector2i = key
		if not in_bounds(p, plan):
			return false
		var mark := int(marks[key])
		if mark == Mark.NONE:
			continue
		if mark != true_mark(p, plan):
			return false
	for cell in loop_cells(plan):
		if int(marks.get(cell, Mark.NONE)) != Mark.CORRIDOR:
			return false
	return true


static func payout(marks: Dictionary, floor: Floor = null) -> Dictionary:
	var plan := _use(floor)
	var corridor_total := corridor_cells(plan)
	var hazard_total := hazard_cells(plan)
	var corridors := 0
	for cell in corridor_total:
		if int(marks.get(cell, Mark.NONE)) == Mark.CORRIDOR:
			corridors += 1
	var hazards := 0
	for cell in hazard_total:
		if int(marks.get(cell, Mark.NONE)) == Mark.HAZARD:
			hazards += 1
	var loop_complete := true
	for cell in loop_cells(plan):
		if int(marks.get(cell, Mark.NONE)) != Mark.CORRIDOR:
			loop_complete = false
			break
	var corridor_pay := corridors * CORRIDOR_VALUE
	var hazard_pay := hazards * HAZARD_VALUE
	var loop_pay := LOOP_VALUE if loop_complete else 0
	return {
		"corridors": corridors,
		"corridor_total": corridor_total.size(),
		"corridor_rate": CORRIDOR_VALUE,
		"corridor_pay": corridor_pay,
		"hazards": hazards,
		"hazard_total": hazard_total.size(),
		"hazard_rate": HAZARD_VALUE,
		"hazard_pay": hazard_pay,
		"loop": 1 if loop_complete else 0,
		"loop_name": plan.loop_name,
		"loop_rate": LOOP_VALUE,
		"loop_pay": loop_pay,
		"total": corridor_pay + hazard_pay + loop_pay,
	}


static func format_bill(bill: Dictionary) -> String:
	var lines := PackedStringArray()
	lines.append("Corridors    %d/%d    %d" % [bill.corridors, bill.corridor_total, bill.corridor_pay])
	lines.append("Hazards      %d/%d     %d" % [bill.hazards, bill.hazard_total, bill.hazard_pay])
	lines.append("%s  %d/1     %d" % [bill.loop_name, bill.loop, bill.loop_pay])
	lines.append("Total              %d" % bill.total)
	return "\n".join(lines)


static func outcome_line(campaign: Campaign) -> String:
	var title := ""
	if campaign.last_floor_id != "":
		var floor := floor_named(campaign.last_floor_id)
		if floor != null:
			title = floor.title
	match campaign.last_outcome:
		"complete":
			return "%s census is complete. The payout below was added to your purse." % title
		"paid":
			if title == "":
				return "Sheet turned in. The payout below was added to your purse."
			return "%s sheet was turned in. The payout below was added to your purse. That census is not finished." % title
		"dark":
			return "The lamp went out. A lost sheet pays nothing."
		"abandoned":
			return "You came back without the lift. The clerk pays nothing."
		_:
			return "No sheet has been turned in yet."


static func settle(campaign: Campaign, state: RunState) -> Dictionary:
	if state.settled:
		return campaign.last_bill
	state.settled = true
	if state.floor != null:
		campaign.last_floor_id = state.floor.id
	if state.end_reason == EndReason.EXTRACTED:
		var paid := payout(state.marks, state.floor)
		campaign.purse += int(paid.total)
		campaign.last_bill = paid
		if census_accepted(state.marks, state.floor):
			campaign.completed[state.floor.id] = true
			campaign.last_outcome = "complete"
		else:
			campaign.last_outcome = "paid"
		return paid
	var lost := payout({}, state.floor)
	campaign.last_bill = lost
	if state.end_reason == EndReason.ABANDONED:
		campaign.last_outcome = "abandoned"
	else:
		campaign.last_outcome = "dark"
	return lost


static func mark_name(mark: int) -> String:
	match mark:
		Mark.WALL:
			return "wall"
		Mark.HAZARD:
			return "hazard"
		Mark.CORRIDOR:
			return "corridor"
		_:
			return "blank"


static func cycle_mark(current: int) -> int:
	match current:
		Mark.NONE:
			return Mark.WALL
		Mark.WALL:
			return Mark.HAZARD
		Mark.HAZARD:
			return Mark.CORRIDOR
		_:
			return Mark.NONE


static func strike_line(state: RunState) -> String:
	var delta := telegraph_tile(state.telegraph_index, state.floor) - state.pos
	var fwd := dir_vector(state.facing)
	var back := dir_vector(state.facing + 2)
	var right := dir_vector(state.facing + 1)
	var left := dir_vector(state.facing + 3)
	if delta == Vector2i.ZERO:
		return "The warden's swing will hit the tile you are standing on."
	if delta == fwd:
		return "The warden's swing will hit the tile ahead."
	if delta == back:
		return "The warden's swing will hit the tile behind you."
	if delta == left:
		return "The warden's swing will hit the tile to your left."
	if delta == right:
		return "The warden's swing will hit the tile to your right."
	return "The warden's swing is the red ring on your sheet. It is live light, not ink."


static func ahead_line(state: RunState) -> String:
	var plan := state.floor
	var n: Vector2i = state.pos + dir_vector(state.facing)
	if n == enemy_pos(plan):
		return "Ahead: the warden blocks that tile."
	if n == telegraph_tile(state.telegraph_index, plan) and is_walkable(n, plan):
		return "Ahead: the telegraphed swing. Stepping in burns %d extra oil." % HIT_OIL
	match tile_at(n, plan):
		Tile.WALL:
			if glyph_at(n, plan) == "*":
				return "Ahead: the cistern pit. It inks as a wall."
			if glyph_at(n, plan) == "+":
				return "Ahead: the garth. It inks as a wall."
			if glyph_at(n, plan) == "=":
				return "Ahead: the tomb. It inks as a wall."
			if glyph_at(n, plan) == "x":
				return "Ahead: the bone stack. It inks as a wall."
			if glyph_at(n, plan) == "R":
				if plan != null and plan.id == "rood":
					return "Ahead: the rood. It inks as a wall."
				return "Ahead: the reliquary case. It inks as a wall."
			if glyph_at(n, plan) == "B":
				return "Ahead: the brine trough. It inks as a wall."
			if glyph_at(n, plan) == "W":
				return "Ahead: the well shaft. It inks as a wall."
			if glyph_at(n, plan) == "D":
				return "Ahead: the copying desk. It inks as a wall."
			if glyph_at(n, plan) == "P":
				return "Ahead: the press. It inks as a wall."
			if glyph_at(n, plan) == "T":
				return "Ahead: the chart table. It inks as a wall."
			if glyph_at(n, plan) == "Y":
				return "Ahead: the bell. It inks as a wall."
			if glyph_at(n, plan) == "K":
				return "Ahead: the clock. It inks as a wall."
			if glyph_at(n, plan) == "N":
				return "Ahead: the font. It inks as a wall."
			if glyph_at(n, plan) == "A":
				return "Ahead: the apse. It inks as a wall."
			if glyph_at(n, plan) == "C":
				return "Ahead: the choir. It inks as a wall."
			if glyph_at(n, plan) == "X":
				return "Ahead: the crossing. It inks as a wall."
			if glyph_at(n, plan) == "V":
				return "Ahead: the transept. It inks as a wall."
			if glyph_at(n, plan) == "U":
				return "Ahead: the ambulatory. It inks as a wall."
			if glyph_at(n, plan) == "Q":
				return "Ahead: the chevet. It inks as a wall."
			if glyph_at(n, plan) == "O":
				return "Ahead: the retrochoir. It inks as a wall."
			if glyph_at(n, plan) == "M":
				return "Ahead: the lady chapel. It inks as a wall."
			if glyph_at(n, plan) == "J":
				return "Ahead: the feretory. It inks as a wall."
			if glyph_at(n, plan) == "I":
				return "Ahead: the chantry. It inks as a wall."
			if glyph_at(n, plan) == "G":
				return "Ahead: the sacristy. It inks as a wall."
			if glyph_at(n, plan) == "F":
				return "Ahead: the pyx. It inks as a wall."
			if glyph_at(n, plan) == "Z":
				return "Ahead: the aumbry. It inks as a wall."
			if glyph_at(n, plan) == "@":
				return "Ahead: the piscina. It inks as a wall."
			if glyph_at(n, plan) == "?":
				return "Ahead: the sedilia. It inks as a wall."
			if glyph_at(n, plan) == ">":
				return "Ahead: the credence. It inks as a wall."
			if glyph_at(n, plan) == "<":
				return "Ahead: the reredos. It inks as a wall."
			if glyph_at(n, plan) == "[":
				return "Ahead: the predella. It inks as a wall."
			if glyph_at(n, plan) == "{":
				return "Ahead: the dossal. It inks as a wall."
			if glyph_at(n, plan) == "]":
				return "Ahead: the retable. It inks as a wall."
			if glyph_at(n, plan) == "}":
				return "Ahead: the tester. It inks as a wall."
			if glyph_at(n, plan) == "~":
				return "Ahead: the riddel. It inks as a wall."
			if glyph_at(n, plan) == "!":
				return "Ahead: the frontal. It inks as a wall."
			if glyph_at(n, plan) == "\"":
				return "Ahead: the pall. It inks as a wall."
			if glyph_at(n, plan) == "$":
				return "Ahead: the herse. It inks as a wall."
			if glyph_at(n, plan) == "%":
				return "Ahead: the catafalque. It inks as a wall."
			if glyph_at(n, plan) == "&":
				return "Ahead: the bier. It inks as a wall."
			if glyph_at(n, plan) == "'":
				return "Ahead: the cerecloth. It inks as a wall."
			if glyph_at(n, plan) == "(":
				return "Ahead: the hearse. It inks as a wall."
			if glyph_at(n, plan) == ")":
				return "Ahead: the shroud. It inks as a wall."
			if glyph_at(n, plan) == ",":
				return "Ahead: the pyre. It inks as a wall."
			if glyph_at(n, plan) == ";":
				return "Ahead: the cenotaph. It inks as a wall."
			if glyph_at(n, plan) == ":":
				return "Ahead: the winding. It inks as a wall."
			if glyph_at(n, plan) == "-":
				return "Ahead: the charnel. It inks as a wall."
			if glyph_at(n, plan) == "_":
				return "Ahead: the sepulchre. It inks as a wall."
			if glyph_at(n, plan) == "^":
				return "Ahead: the vault. It inks as a wall."
			if glyph_at(n, plan) == "/":
				return "Ahead: the cairn. It inks as a wall."
			if glyph_at(n, plan) == "\\":
				return "Ahead: the columbarium. It inks as a wall."
			if glyph_at(n, plan) == "|":
				return "Ahead: the loculus. It inks as a wall."
			if glyph_at(n, plan) == "`":
				return "Ahead: the arcosolium. It inks as a wall."
			return "Ahead: wall."
		Tile.HAZARD:
			if plan != null and plan.id == "cistern":
				return "Ahead: a seep crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "cloister":
				return "Ahead: a cinder crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "crypt":
				return "Ahead: an ash crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "ossuary":
				return "Ahead: a chalk crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "reliquary":
				return "Ahead: a nail crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "undercroft":
				return "Ahead: a salt crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "wellhouse":
				return "Ahead: a well crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "scriptorium":
				return "Ahead: an ink crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "binding":
				return "Ahead: a glue crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "chartroom":
				return "Ahead: a chart crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "bellloft":
				return "Ahead: a bell crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "clockroom":
				return "Ahead: a clock crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "font":
				return "Ahead: a font crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "apse":
				return "Ahead: an apse crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "choir":
				return "Ahead: a choir crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "rood":
				return "Ahead: a rood crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "crossing":
				return "Ahead: a crossing crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "transept":
				return "Ahead: a transept crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "ambulatory":
				return "Ahead: an ambulatory crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "chevet":
				return "Ahead: a chevet crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "retrochoir":
				return "Ahead: a retrochoir crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "ladychapel":
				return "Ahead: a lady-chapel crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "feretory":
				return "Ahead: a feretory crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "chantry":
				return "Ahead: a chantry crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "sacristy":
				return "Ahead: a sacristy crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "pyx":
				return "Ahead: a pyx crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "aumbry":
				return "Ahead: an aumbry crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "piscina":
				return "Ahead: a piscina crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "sedilia":
				return "Ahead: a sedilia crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "credence":
				return "Ahead: a credence crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "reredos":
				return "Ahead: a reredos crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "predella":
				return "Ahead: a predella crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "dossal":
				return "Ahead: a dossal crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "retable":
				return "Ahead: a retable crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "tester":
				return "Ahead: a tester crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "riddel":
				return "Ahead: a riddel crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "frontal":
				return "Ahead: a frontal crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "pall":
				return "Ahead: a pall crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "herse":
				return "Ahead: a herse crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "catafalque":
				return "Ahead: a catafalque crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "bier":
				return "Ahead: a bier crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "cerecloth":
				return "Ahead: a cerecloth crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "hearse":
				return "Ahead: a hearse crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "shroud":
				return "Ahead: a shroud crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "pyre":
				return "Ahead: a pyre crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "cenotaph":
				return "Ahead: a cenotaph crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "winding":
				return "Ahead: a winding crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "charnel":
				return "Ahead: a charnel crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "sepulchre":
				return "Ahead: a sepulchre crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "vault":
				return "Ahead: a vault crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "cairn":
				return "Ahead: a cairn crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "columbarium":
				return "Ahead: a columbarium crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "loculus":
				return "Ahead: a loculus crack. Stepping inks it and costs no extra oil."
			if plan != null and plan.id == "arcosolium":
				return "Ahead: an arcosolium crack. Stepping inks it and costs no extra oil."
			return "Ahead: a hazard crack. Stepping inks it and costs no extra oil."
		Tile.LIFT:
			return "Ahead: the lift. Stepping on carries the sheet out."
		_:
			return "Ahead: open floor."


static func act(state: RunState, action: int) -> Dictionary:
	if state.end_reason != EndReason.NONE:
		return _pack(state, false, false, false, 0, false, "The descent is over.")
	match action:
		Action.TURN_LEFT:
			state.facing = posmod(state.facing + 3, 4)
			return _pack(state, true, false, false, 0, false, "You turn left.")
		Action.TURN_RIGHT:
			state.facing = posmod(state.facing + 1, 4)
			return _pack(state, true, false, false, 0, false, "You turn right.")
		Action.FORWARD:
			return step(state, dir_vector(state.facing))
		Action.BACK:
			return step(state, dir_vector(state.facing + 2))
		Action.STRAFE_LEFT:
			return step(state, dir_vector(state.facing + 3))
		Action.STRAFE_RIGHT:
			return step(state, dir_vector(state.facing + 1))
		Action.WAIT:
			return step(state, Vector2i.ZERO)
		Action.MARK:
			return mark_faced(state)
		_:
			return _pack(state, false, false, false, 0, false, "")


static func mark_faced(state: RunState) -> Dictionary:
	if state.end_reason != EndReason.NONE:
		return _pack(state, false, false, false, 0, false, "The descent is over.")
	var target := state.pos + dir_vector(state.facing)
	if not in_bounds(target, state.floor):
		return _pack(state, false, false, false, 0, false, "Nothing there to mark.")
	var current := int(state.marks.get(target, Mark.NONE))
	var nxt := cycle_mark(current)
	if nxt == Mark.NONE:
		state.marks.erase(target)
	else:
		state.marks[target] = nxt
	return _pack(state, true, false, false, 0, false, "Faced ink is now %s." % mark_name(nxt))


static func step(state: RunState, dir: Vector2i) -> Dictionary:
	var plan := state.floor
	if state.end_reason != EndReason.NONE:
		return _pack(state, false, false, false, 0, false, "The descent is over.")
	if state.oil <= 0:
		state.oil = 0
		state.end_reason = EndReason.LAMP_OUT
		return _pack(state, false, false, false, 0, false, "The lamp is out.")
	if dir == Vector2i.ZERO:
		state.oil -= MOVE_OIL
		var waited_hit := _resolve_strike(state)
		_finish_if_dark(state, false)
		var wait_message := "You wait for the swing to pass."
		if waited_hit and state.end_reason == EndReason.LAMP_OUT:
			wait_message = "The swing snuffs the lamp."
		elif waited_hit:
			wait_message = "The swing catches the lamp."
		elif state.end_reason == EndReason.LAMP_OUT:
			wait_message = "The lamp drinks the last of its oil."
		return _pack(state, true, false, waited_hit, MOVE_OIL + (HIT_OIL if waited_hit else 0), false, wait_message)

	var target := state.pos + dir
	if not is_walkable(target, plan):
		if tile_at(target, plan) == Tile.WALL:
			_observe(state, target)
			if glyph_at(target, plan) == "*":
				return _pack(state, false, false, false, 0, true, "You tap the cistern pit and ink it if the square was blank.")
			if glyph_at(target, plan) == "+":
				return _pack(state, false, false, false, 0, true, "You tap the garth and ink it if the square was blank.")
			if glyph_at(target, plan) == "=":
				return _pack(state, false, false, false, 0, true, "You tap the tomb and ink it if the square was blank.")
			if glyph_at(target, plan) == "x":
				return _pack(state, false, false, false, 0, true, "You tap the bone stack and ink it if the square was blank.")
			if glyph_at(target, plan) == "R":
				if plan != null and plan.id == "rood":
					return _pack(state, false, false, false, 0, true, "You tap the rood and ink it if the square was blank.")
				return _pack(state, false, false, false, 0, true, "You tap the reliquary case and ink it if the square was blank.")
			if glyph_at(target, plan) == "B":
				return _pack(state, false, false, false, 0, true, "You tap the brine trough and ink it if the square was blank.")
			if glyph_at(target, plan) == "W":
				return _pack(state, false, false, false, 0, true, "You tap the well shaft and ink it if the square was blank.")
			if glyph_at(target, plan) == "D":
				return _pack(state, false, false, false, 0, true, "You tap the copying desk and ink it if the square was blank.")
			if glyph_at(target, plan) == "P":
				return _pack(state, false, false, false, 0, true, "You tap the press and ink it if the square was blank.")
			if glyph_at(target, plan) == "T":
				return _pack(state, false, false, false, 0, true, "You tap the chart table and ink it if the square was blank.")
			if glyph_at(target, plan) == "Y":
				return _pack(state, false, false, false, 0, true, "You tap the bell and ink it if the square was blank.")
			if glyph_at(target, plan) == "K":
				return _pack(state, false, false, false, 0, true, "You tap the clock and ink it if the square was blank.")
			if glyph_at(target, plan) == "N":
				return _pack(state, false, false, false, 0, true, "You tap the font and ink it if the square was blank.")
			if glyph_at(target, plan) == "A":
				return _pack(state, false, false, false, 0, true, "You tap the apse and ink it if the square was blank.")
			if glyph_at(target, plan) == "C":
				return _pack(state, false, false, false, 0, true, "You tap the choir and ink it if the square was blank.")
			if glyph_at(target, plan) == "X":
				return _pack(state, false, false, false, 0, true, "You tap the crossing and ink it if the square was blank.")
			if glyph_at(target, plan) == "V":
				return _pack(state, false, false, false, 0, true, "You tap the transept and ink it if the square was blank.")
			if glyph_at(target, plan) == "U":
				return _pack(state, false, false, false, 0, true, "You tap the ambulatory and ink it if the square was blank.")
			if glyph_at(target, plan) == "Q":
				return _pack(state, false, false, false, 0, true, "You tap the chevet and ink it if the square was blank.")
			if glyph_at(target, plan) == "O":
				return _pack(state, false, false, false, 0, true, "You tap the retrochoir and ink it if the square was blank.")
			if glyph_at(target, plan) == "M":
				return _pack(state, false, false, false, 0, true, "You tap the lady chapel and ink it if the square was blank.")
			if glyph_at(target, plan) == "J":
				return _pack(state, false, false, false, 0, true, "You tap the feretory and ink it if the square was blank.")
			if glyph_at(target, plan) == "I":
				return _pack(state, false, false, false, 0, true, "You tap the chantry and ink it if the square was blank.")
			if glyph_at(target, plan) == "G":
				return _pack(state, false, false, false, 0, true, "You tap the sacristy and ink it if the square was blank.")
			if glyph_at(target, plan) == "F":
				return _pack(state, false, false, false, 0, true, "You tap the pyx and ink it if the square was blank.")
			if glyph_at(target, plan) == "Z":
				return _pack(state, false, false, false, 0, true, "You tap the aumbry and ink it if the square was blank.")
			if glyph_at(target, plan) == "@":
				return _pack(state, false, false, false, 0, true, "You tap the piscina and ink it if the square was blank.")
			if glyph_at(target, plan) == "?":
				return _pack(state, false, false, false, 0, true, "You tap the sedilia and ink it if the square was blank.")
			if glyph_at(target, plan) == ">":
				return _pack(state, false, false, false, 0, true, "You tap the credence and ink it if the square was blank.")
			if glyph_at(target, plan) == "<":
				return _pack(state, false, false, false, 0, true, "You tap the reredos and ink it if the square was blank.")
			if glyph_at(target, plan) == "[":
				return _pack(state, false, false, false, 0, true, "You tap the predella and ink it if the square was blank.")
			if glyph_at(target, plan) == "{":
				return _pack(state, false, false, false, 0, true, "You tap the dossal and ink it if the square was blank.")
			if glyph_at(target, plan) == "]":
				return _pack(state, false, false, false, 0, true, "You tap the retable and ink it if the square was blank.")
			if glyph_at(target, plan) == "}":
				return _pack(state, false, false, false, 0, true, "You tap the tester and ink it if the square was blank.")
			if glyph_at(target, plan) == "~":
				return _pack(state, false, false, false, 0, true, "You tap the riddel and ink it if the square was blank.")
			if glyph_at(target, plan) == "!":
				return _pack(state, false, false, false, 0, true, "You tap the frontal and ink it if the square was blank.")
			if glyph_at(target, plan) == "\"":
				return _pack(state, false, false, false, 0, true, "You tap the pall and ink it if the square was blank.")
			if glyph_at(target, plan) == "$":
				return _pack(state, false, false, false, 0, true, "You tap the herse and ink it if the square was blank.")
			if glyph_at(target, plan) == "%":
				return _pack(state, false, false, false, 0, true, "You tap the catafalque and ink it if the square was blank.")
			if glyph_at(target, plan) == "&":
				return _pack(state, false, false, false, 0, true, "You tap the bier and ink it if the square was blank.")
			if glyph_at(target, plan) == "'":
				return _pack(state, false, false, false, 0, true, "You tap the cerecloth and ink it if the square was blank.")
			if glyph_at(target, plan) == "(":
				return _pack(state, false, false, false, 0, true, "You tap the hearse and ink it if the square was blank.")
			if glyph_at(target, plan) == ")":
				return _pack(state, false, false, false, 0, true, "You tap the shroud and ink it if the square was blank.")
			if glyph_at(target, plan) == ",":
				return _pack(state, false, false, false, 0, true, "You tap the pyre and ink it if the square was blank.")
			if glyph_at(target, plan) == ";":
				return _pack(state, false, false, false, 0, true, "You tap the cenotaph and ink it if the square was blank.")
			if glyph_at(target, plan) == ":":
				return _pack(state, false, false, false, 0, true, "You tap the winding and ink it if the square was blank.")
			if glyph_at(target, plan) == "-":
				return _pack(state, false, false, false, 0, true, "You tap the charnel and ink it if the square was blank.")
			if glyph_at(target, plan) == "_":
				return _pack(state, false, false, false, 0, true, "You tap the sepulchre and ink it if the square was blank.")
			if glyph_at(target, plan) == "^":
				return _pack(state, false, false, false, 0, true, "You tap the vault and ink it if the square was blank.")
			if glyph_at(target, plan) == "/":
				return _pack(state, false, false, false, 0, true, "You tap the cairn and ink it if the square was blank.")
			if glyph_at(target, plan) == "\\":
				return _pack(state, false, false, false, 0, true, "You tap the columbarium and ink it if the square was blank.")
			if glyph_at(target, plan) == "|":
				return _pack(state, false, false, false, 0, true, "You tap the loculus and ink it if the square was blank.")
			if glyph_at(target, plan) == "`":
				return _pack(state, false, false, false, 0, true, "You tap the arcosolium and ink it if the square was blank.")
			return _pack(state, false, false, false, 0, true, "You tap a wall and ink it if the square was blank.")
		if target == enemy_pos(plan):
			return _pack(state, false, false, false, 0, true, "The warden occupies that tile.")
		return _pack(state, false, false, false, 0, true, "You cannot step there.")

	state.pos = target
	state.oil -= MOVE_OIL
	_observe(state, target)
	var on_lift := tile_at(target, plan) == Tile.LIFT
	var hit := _resolve_strike(state)
	_finish_if_dark(state, on_lift)
	var message := "You step."
	if on_lift:
		message = "The lift takes you and the sheet up."
	elif hit and state.end_reason == EndReason.LAMP_OUT:
		message = "The swing snuffs the lamp."
	elif hit:
		message = "The swing catches the lamp."
	elif state.end_reason == EndReason.LAMP_OUT:
		message = "The lamp drinks the last of its oil."
	elif tile_at(target, plan) == Tile.HAZARD:
		if plan != null and plan.id == "cistern":
			message = "You cross a seep crack. It is inked if the square was blank."
		elif plan != null and plan.id == "cloister":
			message = "You cross a cinder crack. It is inked if the square was blank."
		elif plan != null and plan.id == "crypt":
			message = "You cross an ash crack. It is inked if the square was blank."
		elif plan != null and plan.id == "ossuary":
			message = "You cross a chalk crack. It is inked if the square was blank."
		elif plan != null and plan.id == "reliquary":
			message = "You cross a nail crack. It is inked if the square was blank."
		elif plan != null and plan.id == "undercroft":
			message = "You cross a salt crack. It is inked if the square was blank."
		elif plan != null and plan.id == "wellhouse":
			message = "You cross a well crack. It is inked if the square was blank."
		elif plan != null and plan.id == "scriptorium":
			message = "You cross an ink crack. It is inked if the square was blank."
		elif plan != null and plan.id == "binding":
			message = "You cross a glue crack. It is inked if the square was blank."
		elif plan != null and plan.id == "chartroom":
			message = "You cross a chart crack. It is inked if the square was blank."
		elif plan != null and plan.id == "bellloft":
			message = "You cross a bell crack. It is inked if the square was blank."
		elif plan != null and plan.id == "clockroom":
			message = "You cross a clock crack. It is inked if the square was blank."
		elif plan != null and plan.id == "font":
			message = "You cross a font crack. It is inked if the square was blank."
		elif plan != null and plan.id == "apse":
			message = "You cross an apse crack. It is inked if the square was blank."
		elif plan != null and plan.id == "choir":
			message = "You cross a choir crack. It is inked if the square was blank."
		elif plan != null and plan.id == "rood":
			message = "You cross a rood crack. It is inked if the square was blank."
		elif plan != null and plan.id == "crossing":
			message = "You cross a crossing crack. It is inked if the square was blank."
		elif plan != null and plan.id == "transept":
			message = "You cross a transept crack. It is inked if the square was blank."
		elif plan != null and plan.id == "ambulatory":
			message = "You cross an ambulatory crack. It is inked if the square was blank."
		elif plan != null and plan.id == "chevet":
			message = "You cross a chevet crack. It is inked if the square was blank."
		elif plan != null and plan.id == "retrochoir":
			message = "You cross a retrochoir crack. It is inked if the square was blank."
		elif plan != null and plan.id == "ladychapel":
			message = "You cross a lady-chapel crack. It is inked if the square was blank."
		elif plan != null and plan.id == "feretory":
			message = "You cross a feretory crack. It is inked if the square was blank."
		elif plan != null and plan.id == "chantry":
			message = "You cross a chantry crack. It is inked if the square was blank."
		elif plan != null and plan.id == "sacristy":
			message = "You cross a sacristy crack. It is inked if the square was blank."
		elif plan != null and plan.id == "pyx":
			message = "You cross a pyx crack. It is inked if the square was blank."
		elif plan != null and plan.id == "aumbry":
			message = "You cross an aumbry crack. It is inked if the square was blank."
		elif plan != null and plan.id == "piscina":
			message = "You cross a piscina crack. It is inked if the square was blank."
		elif plan != null and plan.id == "sedilia":
			message = "You cross a sedilia crack. It is inked if the square was blank."
		elif plan != null and plan.id == "credence":
			message = "You cross a credence crack. It is inked if the square was blank."
		elif plan != null and plan.id == "reredos":
			message = "You cross a reredos crack. It is inked if the square was blank."
		elif plan != null and plan.id == "predella":
			message = "You cross a predella crack. It is inked if the square was blank."
		elif plan != null and plan.id == "dossal":
			message = "You cross a dossal crack. It is inked if the square was blank."
		elif plan != null and plan.id == "retable":
			message = "You cross a retable crack. It is inked if the square was blank."
		elif plan != null and plan.id == "tester":
			message = "You cross a tester crack. It is inked if the square was blank."
		elif plan != null and plan.id == "riddel":
			message = "You cross a riddel crack. It is inked if the square was blank."
		elif plan != null and plan.id == "frontal":
			message = "You cross a frontal crack. It is inked if the square was blank."
		elif plan != null and plan.id == "pall":
			message = "You cross a pall crack. It is inked if the square was blank."
		elif plan != null and plan.id == "herse":
			message = "You cross a herse crack. It is inked if the square was blank."
		elif plan != null and plan.id == "catafalque":
			message = "You cross a catafalque crack. It is inked if the square was blank."
		elif plan != null and plan.id == "bier":
			message = "You cross a bier crack. It is inked if the square was blank."
		elif plan != null and plan.id == "cerecloth":
			message = "You cross a cerecloth crack. It is inked if the square was blank."
		elif plan != null and plan.id == "hearse":
			message = "You cross a hearse crack. It is inked if the square was blank."
		elif plan != null and plan.id == "shroud":
			message = "You cross a shroud crack. It is inked if the square was blank."
		elif plan != null and plan.id == "pyre":
			message = "You cross a pyre crack. It is inked if the square was blank."
		elif plan != null and plan.id == "cenotaph":
			message = "You cross a cenotaph crack. It is inked if the square was blank."
		elif plan != null and plan.id == "winding":
			message = "You cross a winding crack. It is inked if the square was blank."
		elif plan != null and plan.id == "charnel":
			message = "You cross a charnel crack. It is inked if the square was blank."
		elif plan != null and plan.id == "sepulchre":
			message = "You cross a sepulchre crack. It is inked if the square was blank."
		elif plan != null and plan.id == "vault":
			message = "You cross a vault crack. It is inked if the square was blank."
		elif plan != null and plan.id == "cairn":
			message = "You cross a cairn crack. It is inked if the square was blank."
		elif plan != null and plan.id == "columbarium":
			message = "You cross a columbarium crack. It is inked if the square was blank."
		elif plan != null and plan.id == "loculus":
			message = "You cross a loculus crack. It is inked if the square was blank."
		elif plan != null and plan.id == "arcosolium":
			message = "You cross an arcosolium crack. It is inked if the square was blank."
		else:
			message = "You cross a hazard crack. It is inked if the square was blank."
	return _pack(state, true, true, hit, MOVE_OIL + (HIT_OIL if hit else 0), false, message)


static func abandon(state: RunState) -> void:
	if state.end_reason == EndReason.NONE:
		state.end_reason = EndReason.ABANDONED


static func shortest_path_cells(floor: Floor = null) -> Array:
	var plan := _use(floor)
	var start := start_pos(plan)
	var goal := lift_pos(plan)
	var q: Array = [start]
	var head := 0
	var parent := {}
	parent[start] = start
	while head < q.size():
		var pos: Vector2i = q[head]
		head += 1
		if pos == goal:
			break
		for d in cardinals():
			var nxt: Vector2i = pos + d
			if parent.has(nxt) or not is_walkable(nxt, plan):
				continue
			parent[nxt] = pos
			q.append(nxt)
	if not parent.has(goal):
		return []
	var cells: Array = []
	var cur: Vector2i = goal
	while cur != start:
		cells.append(cur)
		cur = parent[cur]
	cells.append(start)
	cells.reverse()
	return cells


static func shortest_path_steps(floor: Floor = null) -> int:
	var cells := shortest_path_cells(floor)
	if cells.is_empty():
		return -1
	return cells.size() - 1


static func scripted_safe_actions(floor: Floor = null) -> Array:
	var plan := _use(floor)
	var goals := {}
	goals[lift_pos(plan)] = true
	var found: Dictionary = search_safe(start_pos(plan), 0, goals, plan)
	if not bool(found.get("ok", false)):
		return []
	return found.actions


static func safe_survey_steps(floor: Floor = null) -> int:
	var plan := _use(floor)
	var needed := {}
	for cell in corridor_cells(plan):
		needed[cell] = true
	for cell in hazard_cells(plan):
		needed[cell] = true
	var pos := start_pos(plan)
	var ti := 0
	needed.erase(pos)
	var steps := 0
	var guard := 0
	while not needed.is_empty():
		guard += 1
		if guard > 400:
			return -1
		var found: Dictionary = search_safe(pos, ti, needed, plan)
		if not bool(found.get("ok", false)):
			return -1
		var walked: Dictionary = _apply_actions(pos, ti, found.actions, plan)
		pos = walked.pos
		ti = int(walked.ti)
		steps += int(walked.steps)
		for cell in walked.visited:
			needed.erase(cell)
	if pos != lift_pos(plan):
		var goals := {}
		goals[lift_pos(plan)] = true
		var home: Dictionary = search_safe(pos, ti, goals, plan)
		if not bool(home.get("ok", false)):
			return -1
		steps += home.actions.size()
	return steps


static func search_safe(start: Vector2i, ti: int, goals: Dictionary, floor: Floor = null) -> Dictionary:
	var plan := _use(floor)
	if goals.has(start):
		return {"ok": true, "actions": [], "pos": start, "ti": ti}
	var swings := swing_tiles(plan)
	var start_key := Vector3i(start.x, start.y, ti)
	var q: Array = [start_key]
	var head := 0
	var parent := {}
	parent[start_key] = start_key
	var action_for := {}
	while head < q.size():
		var key: Vector3i = q[head]
		head += 1
		var pos := Vector2i(key.x, key.y)
		var turn := key.z
		var tele: Vector2i = swings[turn]
		var options: Array = cardinals()
		options.append(Vector2i.ZERO)
		for d in options:
			var nxt: Vector2i = pos if d == Vector2i.ZERO else pos + d
			if d != Vector2i.ZERO and not is_walkable(nxt, plan):
				continue
			if nxt == tele:
				continue
			var nti := (turn + 1) % swings.size()
			var nk := Vector3i(nxt.x, nxt.y, nti)
			if parent.has(nk):
				continue
			parent[nk] = key
			action_for[nk] = d
			if goals.has(nxt):
				return {
					"ok": true,
					"actions": _reconstruct(nk, parent, action_for, start_key),
					"pos": nxt,
					"ti": nti,
				}
			q.append(nk)
	return {"ok": false, "actions": [], "pos": start, "ti": ti}


static func _reconstruct(goal_key: Vector3i, parent: Dictionary, action_for: Dictionary, start_key: Vector3i) -> Array:
	var actions: Array = []
	var key := goal_key
	while key != start_key:
		actions.append(action_for[key])
		key = parent[key]
	actions.reverse()
	return actions


static func _apply_actions(pos: Vector2i, ti: int, actions: Array, floor: Floor = null) -> Dictionary:
	var visited: Array = []
	var swings := swing_tiles(floor)
	for d in actions:
		if d != Vector2i.ZERO:
			pos += d
		ti = (ti + 1) % swings.size()
		visited.append(pos)
	return {"pos": pos, "ti": ti, "steps": actions.size(), "visited": visited}


static func _observe(state: RunState, p: Vector2i) -> void:
	if int(state.marks.get(p, Mark.NONE)) != Mark.NONE:
		return
	match tile_at(p, state.floor):
		Tile.HAZARD:
			state.marks[p] = Mark.HAZARD
		Tile.FLOOR, Tile.LIFT:
			state.marks[p] = Mark.CORRIDOR
		Tile.WALL:
			state.marks[p] = Mark.WALL


static func _resolve_strike(state: RunState) -> bool:
	var hit := state.pos == telegraph_tile(state.telegraph_index, state.floor)
	state.last_hit = hit
	if hit:
		state.oil -= HIT_OIL
		if state.oil < 0:
			state.oil = 0
	var swings := swing_tiles(state.floor)
	state.telegraph_index = (state.telegraph_index + 1) % swings.size()
	return hit


static func _finish_if_dark(state: RunState, on_lift: bool) -> void:
	if on_lift:
		state.end_reason = EndReason.EXTRACTED
		return
	if state.oil <= 0:
		state.oil = 0
		state.end_reason = EndReason.LAMP_OUT


static func _pack(state: RunState, ok: bool, moved: bool, hit: bool, oil_spent: int, bumped: bool, message: String) -> Dictionary:
	return {
		"ok": ok,
		"moved": moved,
		"hit": hit,
		"oil_spent": oil_spent,
		"bumped": bumped,
		"ended": state.end_reason != EndReason.NONE,
		"extracted": state.end_reason == EndReason.EXTRACTED,
		"message": message,
	}
