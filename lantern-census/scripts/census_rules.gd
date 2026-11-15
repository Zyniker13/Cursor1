class_name CensusRules
extends RefCounted

## Rules for one hand-authored floor of Lantern Census.
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
## Payout, only after a lift extract:
##   corridor_pay = CORRIDOR_VALUE * true corridor tiles marked corridor
##   hazard_pay   = HAZARD_VALUE   * true hazard tiles marked hazard
##   loop_pay     = LOOP_VALUE if every east-square tile is marked corridor, else 0
##   total        = corridor_pay + hazard_pay + loop_pay
## A mark that does not match the floor adds nothing. A false hazard mark
## does not increase hazard pay or the total.

const SMALL_FLASK_OIL := 24
const LARGE_FLASK_OIL := 120
const LARGE_FLASK_COST := 40
const MOVE_OIL := 1
const HIT_OIL := 3
const CORRIDOR_VALUE := 3
const HAZARD_VALUE := 8
const LOOP_VALUE := 15

const TOWN_LINE := "Arrows turn and step, Q and E strafe, M marks the tile you face, and Space waits out the warden's swing."
const RATE_CARD := "A true corridor pays 3. A true hazard pays 8. The east square pays 15 only when all four of its tiles are marked corridor. A false mark pays nothing."

const ROWS: PackedStringArray = [
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

enum Tile { WALL, FLOOR, HAZARD, LIFT }
enum Mark { NONE, CORRIDOR, WALL, HAZARD }
enum EndReason { NONE, EXTRACTED, LAMP_OUT, ABANDONED }
enum Action { TURN_LEFT, TURN_RIGHT, FORWARD, BACK, STRAFE_LEFT, STRAFE_RIGHT, WAIT, MARK }

class RunState extends RefCounted:
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


static func width() -> int:
	return ROWS[0].length()


static func height() -> int:
	return ROWS.size()


static func in_bounds(p: Vector2i) -> bool:
	return p.y >= 0 and p.y < ROWS.size() and p.x >= 0 and p.x < ROWS[p.y].length()


static func tile_at(p: Vector2i) -> int:
	if not in_bounds(p):
		return Tile.WALL
	var ch := ROWS[p.y][p.x]
	match ch:
		"#":
			return Tile.WALL
		"H":
			return Tile.HAZARD
		"L":
			return Tile.LIFT
		".":
			return Tile.FLOOR
		"S":
			return Tile.FLOOR
		"E":
			return Tile.FLOOR
		_:
			return Tile.WALL


static func find_char(ch: String) -> Vector2i:
	for y in ROWS.size():
		var x := ROWS[y].find(ch)
		if x >= 0:
			return Vector2i(x, y)
	return Vector2i(-1, -1)


static func start_pos() -> Vector2i:
	return find_char("S")


static func lift_pos() -> Vector2i:
	return find_char("L")


static func enemy_pos() -> Vector2i:
	return find_char("E")


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


static func swing_tiles() -> Array:
	var enemy := enemy_pos()
	return [enemy + Vector2i(1, 0), enemy + Vector2i(-1, 0)]


static func telegraph_tile(index: int) -> Vector2i:
	var swings := swing_tiles()
	return swings[posmod(index, swings.size())]


static func loop_cells() -> Array:
	# East square, the only closed loop the clerk pays for.
	return [Vector2i(8, 3), Vector2i(9, 3), Vector2i(9, 4), Vector2i(8, 4)]


static func is_walkable(p: Vector2i) -> bool:
	if p == enemy_pos():
		return false
	var t := tile_at(p)
	return t == Tile.FLOOR or t == Tile.HAZARD or t == Tile.LIFT


static func is_corridor_cell(p: Vector2i) -> bool:
	if p == enemy_pos():
		return false
	var t := tile_at(p)
	return t == Tile.FLOOR or t == Tile.LIFT


static func corridor_cells() -> Array:
	var cells: Array = []
	for y in height():
		for x in width():
			var p := Vector2i(x, y)
			if is_corridor_cell(p):
				cells.append(p)
	return cells


static func hazard_cells() -> Array:
	var cells: Array = []
	for y in height():
		for x in width():
			var p := Vector2i(x, y)
			if tile_at(p) == Tile.HAZARD:
				cells.append(p)
	return cells


static func walkable_approach(tile: Vector2i) -> Vector2i:
	for d in cardinals():
		var n: Vector2i = tile + d
		if is_walkable(n):
			return n
	return Vector2i(-1, -1)


static func new_campaign() -> Campaign:
	var c := Campaign.new()
	c.purse = 0
	c.flask_oil = SMALL_FLASK_OIL
	c.upgraded = false
	c.last_outcome = "fresh"
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


static func new_run(flask_oil: int) -> RunState:
	var state := RunState.new()
	state.pos = start_pos()
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


static func accurate_sheet() -> Dictionary:
	var marks := {}
	for cell in corridor_cells():
		marks[cell] = Mark.CORRIDOR
	for cell in hazard_cells():
		marks[cell] = Mark.HAZARD
	return marks


static func payout(marks: Dictionary) -> Dictionary:
	var corridor_total := corridor_cells()
	var hazard_total := hazard_cells()
	var corridors := 0
	for cell in corridor_total:
		if int(marks.get(cell, Mark.NONE)) == Mark.CORRIDOR:
			corridors += 1
	var hazards := 0
	for cell in hazard_total:
		if int(marks.get(cell, Mark.NONE)) == Mark.HAZARD:
			hazards += 1
	var loop_complete := true
	for cell in loop_cells():
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
		"loop_name": "East square",
		"loop_rate": LOOP_VALUE,
		"loop_pay": loop_pay,
		"total": corridor_pay + hazard_pay + loop_pay,
	}


static func format_bill(bill: Dictionary) -> String:
	var lines := PackedStringArray()
	lines.append("Corridors    %d/%d    %d" % [bill.corridors, bill.corridor_total, bill.corridor_pay])
	lines.append("Hazards      %d/%d     %d" % [bill.hazards, bill.hazard_total, bill.hazard_pay])
	lines.append("East square  %d/1     %d" % [bill.loop, bill.loop_pay])
	lines.append("Total              %d" % bill.total)
	return "\n".join(lines)


static func settle(campaign: Campaign, state: RunState) -> Dictionary:
	if state.settled:
		return campaign.last_bill
	state.settled = true
	if state.end_reason == EndReason.EXTRACTED:
		var paid := payout(state.marks)
		campaign.purse += int(paid.total)
		campaign.last_bill = paid
		campaign.last_outcome = "paid"
		return paid
	var lost := payout({})
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
	var delta := telegraph_tile(state.telegraph_index) - state.pos
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
	return "The warden's swing is the ring on your sheet. The ring is live light, not ink."


static func ahead_line(state: RunState) -> String:
	var n: Vector2i = state.pos + dir_vector(state.facing)
	if n == enemy_pos():
		return "Ahead: the warden blocks that tile."
	if n == telegraph_tile(state.telegraph_index) and is_walkable(n):
		return "Ahead: the telegraphed swing. Stepping in burns %d extra oil." % HIT_OIL
	match tile_at(n):
		Tile.WALL:
			return "Ahead: wall."
		Tile.HAZARD:
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
	if not in_bounds(target):
		return _pack(state, false, false, false, 0, false, "Nothing there to mark.")
	var current := int(state.marks.get(target, Mark.NONE))
	var nxt := cycle_mark(current)
	if nxt == Mark.NONE:
		state.marks.erase(target)
	else:
		state.marks[target] = nxt
	return _pack(state, true, false, false, 0, false, "Faced ink is now %s." % mark_name(nxt))


static func step(state: RunState, dir: Vector2i) -> Dictionary:
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
	if not is_walkable(target):
		if tile_at(target) == Tile.WALL:
			_observe(state, target)
			return _pack(state, false, false, false, 0, true, "You tap a wall and ink it if the square was blank.")
		if target == enemy_pos():
			return _pack(state, false, false, false, 0, true, "The warden occupies that tile.")
		return _pack(state, false, false, false, 0, true, "You cannot step there.")

	state.pos = target
	state.oil -= MOVE_OIL
	_observe(state, target)
	var on_lift := tile_at(target) == Tile.LIFT
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
	elif tile_at(target) == Tile.HAZARD:
		message = "You cross a hazard crack. It is inked if the square was blank."
	return _pack(state, true, true, hit, MOVE_OIL + (HIT_OIL if hit else 0), false, message)


static func abandon(state: RunState) -> void:
	if state.end_reason == EndReason.NONE:
		state.end_reason = EndReason.ABANDONED


static func shortest_path_cells() -> Array:
	var start := start_pos()
	var goal := lift_pos()
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
			if parent.has(nxt) or not is_walkable(nxt):
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


static func shortest_path_steps() -> int:
	var cells := shortest_path_cells()
	if cells.is_empty():
		return -1
	return cells.size() - 1


static func scripted_safe_actions() -> Array:
	var goals := {}
	goals[lift_pos()] = true
	var found: Dictionary = search_safe(start_pos(), 0, goals)
	if not bool(found.get("ok", false)):
		return []
	return found.actions


static func safe_survey_steps() -> int:
	var needed := {}
	for cell in corridor_cells():
		needed[cell] = true
	for cell in hazard_cells():
		needed[cell] = true
	var pos := start_pos()
	var ti := 0
	needed.erase(pos)
	var steps := 0
	var guard := 0
	while not needed.is_empty():
		guard += 1
		if guard > 400:
			return -1
		var found: Dictionary = search_safe(pos, ti, needed)
		if not bool(found.get("ok", false)):
			return -1
		var walked: Dictionary = _apply_actions(pos, ti, found.actions)
		pos = walked.pos
		ti = int(walked.ti)
		steps += int(walked.steps)
		for cell in walked.visited:
			needed.erase(cell)
	if pos != lift_pos():
		var goals := {}
		goals[lift_pos()] = true
		var home: Dictionary = search_safe(pos, ti, goals)
		if not bool(home.get("ok", false)):
			return -1
		steps += home.actions.size()
	return steps


static func search_safe(start: Vector2i, ti: int, goals: Dictionary) -> Dictionary:
	if goals.has(start):
		return {"ok": true, "actions": [], "pos": start, "ti": ti}
	var swings := swing_tiles()
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
			if d != Vector2i.ZERO and not is_walkable(nxt):
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


static func _apply_actions(pos: Vector2i, ti: int, actions: Array) -> Dictionary:
	var visited: Array = []
	var swings := swing_tiles()
	for d in actions:
		if d != Vector2i.ZERO:
			pos += d
		ti = (ti + 1) % swings.size()
		visited.append(pos)
	return {"pos": pos, "ti": ti, "steps": actions.size(), "visited": visited}


static func _observe(state: RunState, p: Vector2i) -> void:
	if int(state.marks.get(p, Mark.NONE)) != Mark.NONE:
		return
	match tile_at(p):
		Tile.HAZARD:
			state.marks[p] = Mark.HAZARD
		Tile.FLOOR, Tile.LIFT:
			state.marks[p] = Mark.CORRIDOR
		Tile.WALL:
			state.marks[p] = Mark.WALL


static func _resolve_strike(state: RunState) -> bool:
	var hit := state.pos == telegraph_tile(state.telegraph_index)
	state.last_hit = hit
	if hit:
		state.oil -= HIT_OIL
		if state.oil < 0:
			state.oil = 0
	var swings := swing_tiles()
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
