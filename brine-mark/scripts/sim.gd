extends RefCounted
class_name BrineSim

# Brine Mark slice — Salt Coast tick rules
#
# The player never selects an ant. They paint cells. Workers are simulated
# labor that follow the paint under their feet. This slice has one scenario:
# a wet season, then a short dry season. The full game's population cap is
# 200; this slice hard-caps at POP_CAP (40) and will not grow past it.
#
# Map
# - Grid is GRID_W by GRID_H. Column COAST_X (0) is brine. It is not paintable
#   and not walkable. In the dry season the brine has pulled back: the column
#   stays unwalkable, and shore rakes no longer touch water.
# - The anthill is the fixed cell ANTHILL (14, 5). It is walkable, not
#   paintable, and the only place workers spawn.
# - Every other cell accepts one mark: empty, rake, stack, cover, trail, or pan.
#
# Determinism
# - No randomness and no seed. Given the same paint map at each tick and this
#   starting anthill, the stored-salt result is identical.
# - Workers act in ascending id order. Flow fields are breadth-first. When
#   several cells are equally close, the first one reached wins. Expansion
#   order is north, west, east, south. Goals are seeded row-major (y, then x).
# - Salt transfers pick the neighbor with the largest pile. Ties break toward
#   the smaller y, then the smaller x.
#
# Seasons
# - Wet season: tick indexes 0 .. RAIN_TICK-1. Gatherers on brine-adjacent
#   rake cells pile loose salt. Pan cells are only ground to cross.
# - At tick RAIN_TICK the first rain falls. Loose salt is destroyed. Stacked
#   salt on a cover cell is hauled into the wet-season ledger and cleared
#   from the flats. Stacked salt outside cover is destroyed. The scenario
#   continues, and the season becomes dry.
# - Dry season: the next DRY_TICK work rounds. Rake cells are not goals, and
#   a gatherer standing on one does nothing. A pan cell is a gather goal:
#   one unit of work crystallizes 1 loose salt, up to LOOSE_CAP, with no need
#   to touch the brine. Stack and cover work as in the wet season.
# - At tick RAIN_TICK + DRY_TICK the second rain falls and the scenario ends.
#   Loose salt is destroyed again. Covered stacked salt stays on the map.
#   Stored salt is the wet-season haul plus covered salt still on the map.
#
# Tick (work rounds, then a rain at each season boundary)
# 1. If the second rain has already fallen, the tick does nothing.
# 2. Spawn. On tick indexes 1, 2, ... while the index is a positive multiple
#    of SPAWN_EVERY and the population is below POP_CAP, one worker is added
#    at the anthill. Its job is id % 3 and never changes:
#      0 gather — rake in the wet season, pan in the dry season
#      1 stack  — move loose salt into stacks
#      2 cover  — move stacked salt into cover
#    The new worker acts on the tick it spawns. The starting population is
#    INITIAL_POP, created before tick 0. Spawn refuses to exceed POP_CAP.
# 3. Goals, from the salt map and the season as the tick begins (later
#    workers see salt changes, but not new paths, until the next tick):
#      Gather, wet: rake cell in the shore column (x == 1) whose loose pile
#              is below LOOSE_CAP. Inland rake never makes salt.
#      Gather, dry: pan cell whose loose pile is below LOOSE_CAP.
#      Stack:  stack cell below STACK_CAP with loose salt on a 4-neighbor.
#      Cover:  cover cell below COVER_CAP with stacked salt on an adjacent
#              stack cell.
#    Trail cells are only ground to cross. They are not goals. Pan cells are
#    not goals during the wet season. Rake cells are not goals during the
#    dry season.
# 4. Each job builds a flow field: multi-source BFS from its goals through
#    walkable cells (any painted cell, plus the anthill). A goal's next step
#    is itself. Every other reached cell points one step toward the nearest
#    goal.
# 5. Each worker acts:
#      - Off the walkable network (the mark under them was erased): step to
#        the first walkable 4-neighbor in expansion order, else stay.
#      - On a flow cell whose next step is itself: do one unit of work.
#      - Otherwise: step to that next cell. Workers do not block each other.
#    Work, one unit, and only if the cell still qualifies:
#      Gather, wet: loose salt on this rake cell increases by 1, up to LOOSE_CAP.
#      Gather, dry: loose salt on this pan cell increases by 1, up to LOOSE_CAP.
#      Stack:  1 loose salt moves from the chosen neighbor onto this stack,
#              up to STACK_CAP.
#      Cover:  1 stacked salt moves from the chosen adjacent stack into this
#              cover cell, up to COVER_CAP.
# 6. If the population is above POP_CAP, the violation is counted. Spawning
#    is the only way workers are added, and it stops at the cap.
# 7. The tick index increases by 1. When it reaches RAIN_TICK, the first rain
#    falls immediately (the dry season's first work round is the next tick).
#    When it reaches RAIN_TICK + DRY_TICK, the second rain falls and the
#    scenario ends.
#
# Rain
# - Loose salt is destroyed on every cell. Loose salt never survives a rain.
# - First rain: stacked salt on a cover cell is hauled (added to the ledger)
#   and removed from the cell. That haul counts toward stored salt. The flats
#   start the dry season clear.
# - Second rain: stacked salt on a cover cell stays, folded into the covered
#   pile, and counts toward stored salt along with the ledger.
# - Stacked or covered salt outside a cover cell is destroyed.
# - Destruction is applied row-major. The same paint map yields the same
#   stored-salt number.
#
# Summary
# - Stored salt >= QUOTA: the rains passed. The line names the first-rain
#   haul and what the dry season held.
# - Stored salt == 0 and any salt was destroyed: the quota was missed because
#   uncovered salt was destroyed. An all-rake coast does this: workers pile
#   loose salt, nothing is stacked into cover, the first rain wrecks the
#   piles, and idle rakes add nothing once the brine pulls back.
# - Stored salt == 0 and nothing was destroyed: no salt was stored.
# - Stored salt is short of the quota but not zero: not enough covered salt
#   survived. If uncovered salt was also destroyed, the summary says so.
#
# Clock
# - The scene shows the current season's remaining ticks at TICK_HZ. The sim
#   itself counts ticks, not wall-clock time, so a headless run is the same
#   scenario as the window.

const EMPTY := 0
const RAKE := 1
const STACK := 2
const COVER := 3
const TRAIL := 4
const PAN := 5

const WET := 0
const DRY := 1

const GRID_W := 17
const GRID_H := 12
const COAST_X := 0
const ANTHILL := Vector2i(14, 5)

const POP_CAP := 40
const INITIAL_POP := 10
const SPAWN_EVERY := 10
const QUOTA := 12
const RAIN_TICK := 600
const DRY_TICK := 200
const TICK_HZ := 10

const LOOSE_CAP := 12
const STACK_CAP := 12
const COVER_CAP := 999

const JOB_GATHER := 0
const JOB_STACK := 1
const JOB_COVER := 2

# North, west, east, south. Equal-length paths keep the first of these.
const DIRS: Array = [Vector2i(0, -1), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, 1)]

var _paint: Dictionary = {}
var _loose: Dictionary = {}
var _stacked: Dictionary = {}
var _covered: Dictionary = {}
var _workers: Array = []

var _next_id: int = 0
var _tick_index: int = 0
var _season: int = WET
var _wet_haul: int = 0
var _rain_done: bool = false
var _max_population: int = 0
var _pop_cap_violations: int = 0
var _uncovered_destroyed: int = 0
var _summary: String = ""


class Worker:
	var id: int
	var x: int
	var y: int
	var job: int


func _init() -> void:
	restart()


func restart() -> void:
	_paint.clear()
	_loose.clear()
	_stacked.clear()
	_covered.clear()
	_workers.clear()
	_next_id = 0
	_tick_index = 0
	_season = WET
	_wet_haul = 0
	_rain_done = false
	_max_population = 0
	_pop_cap_violations = 0
	_uncovered_destroyed = 0
	_summary = ""
	var starter := mini(INITIAL_POP, POP_CAP)
	for _i in starter:
		_add_worker()


func paint_cell(x: int, y: int, mode: int) -> bool:
	if _rain_done:
		return false
	if not _paintable(x, y):
		return false
	if mode < EMPTY or mode > PAN:
		return false
	var cell := Vector2i(x, y)
	if mode == EMPTY:
		_paint.erase(cell)
	else:
		_paint[cell] = mode
	return true


func get_paint(x: int, y: int) -> int:
	return _paint_at(Vector2i(x, y))


func tick() -> void:
	if _rain_done:
		return
	var horizon := RAIN_TICK + DRY_TICK
	if _tick_index >= horizon:
		_resolve_second_rain()
		return
	_maybe_spawn()
	var flows := {
		JOB_GATHER: _build_flow(_gather_goals()),
		JOB_STACK: _build_flow(_stack_goals()),
		JOB_COVER: _build_flow(_cover_goals()),
	}
	for worker in _workers:
		_act(worker, flows[int(worker.job)])
	if _workers.size() > POP_CAP:
		_pop_cap_violations += 1
	_tick_index += 1
	if _tick_index == RAIN_TICK:
		_resolve_first_rain()
	elif _tick_index >= horizon:
		_resolve_second_rain()


func run_until_rain() -> void:
	var guard := 0
	var limit := RAIN_TICK + DRY_TICK + 2
	while not _rain_done and guard < limit:
		tick()
		guard += 1


func get_stored_salt() -> int:
	return _wet_haul + _covered_on_map()


func get_loose_salt() -> int:
	return _sum(_loose)


func get_stacked_salt() -> int:
	return _sum(_stacked)


func get_wet_haul() -> int:
	return _wet_haul


func get_season() -> int:
	return _season


func get_population() -> int:
	return _workers.size()


func get_max_population() -> int:
	return _max_population


func get_pop_cap_violations() -> int:
	return _pop_cap_violations


func get_uncovered_destroyed() -> int:
	return _uncovered_destroyed


func get_summary() -> String:
	return _summary


func get_ticks_until_rain() -> int:
	if _rain_done:
		return 0
	var horizon := RAIN_TICK + DRY_TICK if _season == DRY else RAIN_TICK
	return maxi(horizon - _tick_index, 0)


func is_over() -> bool:
	return _rain_done


func get_anthill() -> Vector2i:
	return ANTHILL


func get_cell_salt(x: int, y: int) -> Dictionary:
	var cell := Vector2i(x, y)
	return {
		"loose": _amount(_loose, cell),
		"stacked": _amount(_stacked, cell),
		"covered": _amount(_covered, cell),
	}


# Positions for drawing. This does not select a worker.
func get_ant_draw_positions() -> Array:
	var out: Array = []
	for worker in _workers:
		out.append({
			"id": int(worker.id),
			"x": int(worker.x),
			"y": int(worker.y),
			"job": int(worker.job),
		})
	return out


func rules_api() -> PackedStringArray:
	return PackedStringArray([
		"restart",
		"paint_cell",
		"get_paint",
		"tick",
		"run_until_rain",
		"get_stored_salt",
		"get_loose_salt",
		"get_stacked_salt",
		"get_wet_haul",
		"get_season",
		"get_population",
		"get_max_population",
		"get_pop_cap_violations",
		"get_uncovered_destroyed",
		"get_summary",
		"get_ticks_until_rain",
		"is_over",
		"get_anthill",
		"get_cell_salt",
		"get_ant_draw_positions",
		"rules_api",
	])


func _add_worker() -> void:
	if _workers.size() >= POP_CAP:
		return
	var worker := Worker.new()
	worker.id = _next_id
	worker.x = ANTHILL.x
	worker.y = ANTHILL.y
	worker.job = _next_id % 3
	_next_id += 1
	_workers.append(worker)
	if _workers.size() > _max_population:
		_max_population = _workers.size()


func _maybe_spawn() -> void:
	if _tick_index <= 0:
		return
	if _tick_index % SPAWN_EVERY != 0:
		return
	_add_worker()


func _paintable(x: int, y: int) -> bool:
	if x <= COAST_X or x >= GRID_W or y < 0 or y >= GRID_H:
		return false
	if Vector2i(x, y) == ANTHILL:
		return false
	return true


func _walkable(x: int, y: int) -> bool:
	if x < 0 or y < 0 or x >= GRID_W or y >= GRID_H:
		return false
	if x == COAST_X:
		return false
	if Vector2i(x, y) == ANTHILL:
		return true
	return _paint_at(Vector2i(x, y)) != EMPTY


func _paint_at(cell: Vector2i) -> int:
	return int(_paint.get(cell, EMPTY))


func _amount(store: Dictionary, cell: Vector2i) -> int:
	return int(store.get(cell, 0))


func _sum(store: Dictionary) -> int:
	var total := 0
	for value in store.values():
		total += int(value)
	return total


func _put(store: Dictionary, cell: Vector2i, amount: int) -> void:
	if amount <= 0:
		store.erase(cell)
	else:
		store[cell] = amount


func _covered_on_map() -> int:
	var total := 0
	for y in GRID_H:
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _paint_at(cell) == COVER:
				total += _amount(_covered, cell) + _amount(_stacked, cell)
	return total


func _brine_adjacent(cell: Vector2i) -> bool:
	return cell.x == COAST_X + 1 and cell.y >= 0 and cell.y < GRID_H


func _gather_goals() -> Array:
	var goals: Array = []
	for y in GRID_H:
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _season == DRY:
				if _paint_at(cell) != PAN:
					continue
			else:
				if _paint_at(cell) != RAKE or not _brine_adjacent(cell):
					continue
			if _amount(_loose, cell) >= LOOSE_CAP:
				continue
			goals.append(cell)
	return goals


func _stack_goals() -> Array:
	var goals: Array = []
	for y in GRID_H:
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _paint_at(cell) != STACK:
				continue
			if _amount(_stacked, cell) >= STACK_CAP:
				continue
			if _best_loose_neighbor(cell).x < 0:
				continue
			goals.append(cell)
	return goals


func _cover_goals() -> Array:
	var goals: Array = []
	for y in GRID_H:
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _paint_at(cell) != COVER:
				continue
			if _amount(_covered, cell) >= COVER_CAP:
				continue
			if _best_stack_neighbor(cell).x < 0:
				continue
			goals.append(cell)
	return goals


func _build_flow(goals: Array) -> Dictionary:
	var flow: Dictionary = {}
	var queue: Array = []
	for goal in goals:
		var cell: Vector2i = goal
		if flow.has(cell):
			continue
		if not _walkable(cell.x, cell.y):
			continue
		flow[cell] = cell
		queue.append(cell)
	var head := 0
	while head < queue.size():
		var current: Vector2i = queue[head]
		head += 1
		for direction in DIRS:
			var nxt: Vector2i = current + direction
			if flow.has(nxt):
				continue
			if not _walkable(nxt.x, nxt.y):
				continue
			flow[nxt] = current
			queue.append(nxt)
	return flow


func _act(worker: Worker, flow: Dictionary) -> void:
	if not _walkable(worker.x, worker.y):
		_step_stranded(worker)
		return
	var pos := Vector2i(worker.x, worker.y)
	if not flow.has(pos):
		return
	var nxt: Vector2i = flow[pos]
	if nxt == pos:
		_work(worker)
	else:
		worker.x = nxt.x
		worker.y = nxt.y


func _step_stranded(worker: Worker) -> void:
	for direction in DIRS:
		var nxt: Vector2i = Vector2i(worker.x, worker.y) + direction
		if _walkable(nxt.x, nxt.y):
			worker.x = nxt.x
			worker.y = nxt.y
			return


func _work(worker: Worker) -> void:
	var cell := Vector2i(worker.x, worker.y)
	if worker.job == JOB_GATHER:
		if _season == DRY:
			if _paint_at(cell) != PAN:
				return
		elif _paint_at(cell) != RAKE or not _brine_adjacent(cell):
			return
		var loose := _amount(_loose, cell)
		if loose >= LOOSE_CAP:
			return
		_put(_loose, cell, loose + 1)
	elif worker.job == JOB_STACK:
		if _paint_at(cell) != STACK:
			return
		var stacked := _amount(_stacked, cell)
		if stacked >= STACK_CAP:
			return
		var src := _best_loose_neighbor(cell)
		if src.x < 0:
			return
		_put(_loose, src, _amount(_loose, src) - 1)
		_put(_stacked, cell, stacked + 1)
	elif worker.job == JOB_COVER:
		if _paint_at(cell) != COVER:
			return
		var covered := _amount(_covered, cell)
		if covered >= COVER_CAP:
			return
		var src := _best_stack_neighbor(cell)
		if src.x < 0:
			return
		_put(_stacked, src, _amount(_stacked, src) - 1)
		_put(_covered, cell, covered + 1)


func _best_loose_neighbor(cell: Vector2i) -> Vector2i:
	var best := Vector2i(-1, -1)
	var best_amount := 0
	for direction in DIRS:
		var nxt: Vector2i = cell + direction
		var amount := _amount(_loose, nxt)
		if amount <= 0:
			continue
		if amount > best_amount or (amount == best_amount and _prefer(nxt, best)):
			best = nxt
			best_amount = amount
	return best


func _best_stack_neighbor(cell: Vector2i) -> Vector2i:
	var best := Vector2i(-1, -1)
	var best_amount := 0
	for direction in DIRS:
		var nxt: Vector2i = cell + direction
		if _paint_at(nxt) != STACK:
			continue
		var amount := _amount(_stacked, nxt)
		if amount <= 0:
			continue
		if amount > best_amount or (amount == best_amount and _prefer(nxt, best)):
			best = nxt
			best_amount = amount
	return best


func _prefer(candidate: Vector2i, incumbent: Vector2i) -> bool:
	if incumbent.x < 0:
		return true
	if candidate.y != incumbent.y:
		return candidate.y < incumbent.y
	return candidate.x < incumbent.x


func _resolve_first_rain() -> void:
	if _season != WET or _rain_done:
		return
	_wet_haul += _sweep_rain(true)
	_season = DRY


func _resolve_second_rain() -> void:
	if _rain_done:
		return
	_sweep_rain(false)
	_rain_done = true
	_summary = _make_summary()


func _sweep_rain(ship_covered: bool) -> int:
	var destroyed := 0
	var shipped := 0
	for y in GRID_H:
		for x in GRID_W:
			var cell := Vector2i(x, y)
			var loose := _amount(_loose, cell)
			var stacked := _amount(_stacked, cell)
			var covered := _amount(_covered, cell)
			destroyed += loose
			_loose.erase(cell)
			if _paint_at(cell) == COVER:
				var kept := stacked + covered
				if ship_covered:
					shipped += kept
					_stacked.erase(cell)
					_covered.erase(cell)
				elif stacked > 0:
					_put(_covered, cell, covered + stacked)
					_stacked.erase(cell)
			else:
				destroyed += stacked + covered
				_stacked.erase(cell)
				_covered.erase(cell)
	_uncovered_destroyed += destroyed
	return shipped


func _make_summary() -> String:
	var stored := get_stored_salt()
	var dry_held := stored - _wet_haul
	if stored >= QUOTA:
		return "The rains passed. Covered salt held: %d (quota %d). First rain hauled %d; dry season held %d." % [stored, QUOTA, _wet_haul, dry_held]
	if stored <= 0 and _uncovered_destroyed > 0:
		return "Quota missed: uncovered salt was destroyed by the rain (%d). Covered salt held: 0 (quota %d). Dry season held %d." % [_uncovered_destroyed, QUOTA, dry_held]
	if stored <= 0:
		return "Quota missed: no salt was stored before the rain. Covered salt held: 0 (quota %d). Dry season held %d." % [QUOTA, dry_held]
	var message := "Quota missed: not enough covered salt survived the rain. Covered salt held: %d (quota %d). First rain hauled %d; dry season held %d." % [stored, QUOTA, _wet_haul, dry_held]
	if _uncovered_destroyed > 0:
		message += " Uncovered salt was destroyed by the rain."
	return message
