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
const RATE_CARD := "A true corridor pays 3. A true hazard pays 8. The cellar's east square, the cistern ring, the cloister walk, the crypt ring, the ossuary ring, the reliquary ring, the undercroft ring, the well ring, the scriptorium ring, the binding ring, the chart room ring, and the bell loft ring each pay 15 only when every tile of that ring is marked corridor. A false mark pays nothing."

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
		_floor_list = [_make_cellar(), _make_cistern(), _make_cloister(), _make_crypt(), _make_ossuary(), _make_reliquary(), _make_undercroft(), _make_wellhouse(), _make_scriptorium(), _make_binding(), _make_chartroom(), _make_bellloft()]
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
