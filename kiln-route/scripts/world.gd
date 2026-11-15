extends RefCounted

## Deterministic foundry grid. See kiln-route/README.md for the tick contract.
##
## Each tick:
## 1. Count down kiln and press timers. A timer that hits zero readies its product.
## 2. Deliver existing outputs. Scan cells top-to-bottom, left-to-right, repeating
##    until nothing moves. Each item moves at most one cell per tick.
## 3. Sources emit, in room order. New items do not move again until the next tick.
## A twin does not forward in step 2 on its own. When a matching item arrives,
## the waiter moves one cell forward inside that accept, during step 2 or step 3.
## The arrival stays. Neither item moves a second cell on that tick.
## A pass is the same, except the arrival may be a different material.
## A slip does not forward in step 2 on its own. The first item stays. When a
## later item arrives from behind, that arrival moves one cell forward inside
## the accept and the first item remains the waiter.
## A shed is the same, except the arrival moves one cell to the left.

const Rules = preload("res://scripts/foundry.gd")

var width := 0
var height := 0
var quota: Dictionary = {}
var budget: Dictionary = {}
var seed := 0
var error := ""
var tick := 0
var discarded := 0
var counts := {}
var trace: Array = []
var walls := {}
var chutes := {}
var sinks := {}
var sources: Array = []
var machines := {}

class Machine:
	var kind := 0
	var dir := 0
	var hold := -1
	var moved := false
	var timer := 0
	var buffer := 0
	var output_ready := false
	var phase := 0
	## Second lane on a bridge. -1 is empty. Other machines leave it empty.
	var cross := -1
	var cross_moved := false
	## True while a twin, a pass, a slip, or a shed is resolving an arrival, so a loop cannot re-enter.
	var pairing := false

class Source:
	var pos := Vector2i.ZERO
	var dir := 0
	var pattern: Array = []
	var period := 1
	var cursor := 0
	var cooldown := 0
	var pending := -1


static func blocked_cells(room: Dictionary) -> Dictionary:
	var blocked := {}
	for src in room.get("sources", []):
		blocked[Vector2i(int(src.x), int(src.y))] = true
	for sink in room.get("sinks", []):
		blocked[Vector2i(int(sink.x), int(sink.y))] = true
	for chute in room.get("chutes", []):
		blocked[Vector2i(int(chute.x), int(chute.y))] = true
	for wall in room.get("walls", []):
		blocked[Vector2i(int(wall.x), int(wall.y))] = true
	return blocked


static func quota_met(counts: Dictionary, quota: Dictionary) -> bool:
	for mat in quota.keys():
		if int(counts.get(int(mat), 0)) < int(quota[mat]):
			return false
	return true


static func piece_counts(placements: Array) -> Dictionary:
	var used := {}
	for piece in placements:
		var kind := int(piece.kind)
		used[kind] = int(used.get(kind, 0)) + 1
	return used


static func budget_met(placements: Array, budget: Dictionary) -> bool:
	var used := piece_counts(placements)
	for kind in used.keys():
		if int(used[kind]) > int(budget.get(int(kind), 0)):
			return false
	return true


static func budget_exact(placements: Array, budget: Dictionary) -> bool:
	var used := piece_counts(placements)
	for kind in budget.keys():
		if int(used.get(int(kind), 0)) != int(budget[kind]):
			return false
	for kind in used.keys():
		if not budget.has(int(kind)):
			return false
	return true


static func describe(counts: Dictionary, quota: Dictionary) -> String:
	var mats: Array = quota.keys()
	mats.sort()
	var parts: PackedStringArray = []
	for mat in mats:
		parts.append("%s %d/%d" % [
			Rules.MAT_NAME[int(mat)],
			int(counts.get(int(mat), 0)),
			int(quota[mat]),
		])
	return "  ".join(parts)


static func simulate(room: Dictionary, placements: Array, ticks: int = -1) -> Dictionary:
	var world = load("res://scripts/world.gd").new()
	world.setup(room, placements)
	var limit := Rules.SIM_TICKS if ticks < 0 else ticks
	if world.error == "":
		for _step_index in limit:
			world.step()
			if world.error != "":
				break
	return world.summarize(placements)


func setup(room: Dictionary, placements: Array) -> void:
	width = int(room.w)
	height = int(room.h)
	quota = room.quota
	budget = room.budget
	seed = Rules.SEED
	error = ""
	tick = 0
	discarded = 0
	trace = []
	counts = {
		Rules.Mat.ORE: 0,
		Rules.Mat.INGOT: 0,
		Rules.Mat.PLATE: 0,
	}
	walls = {}
	chutes = {}
	sinks = {}
	sources = []
	machines = {}
	for wall in room.get("walls", []):
		walls[Vector2i(int(wall.x), int(wall.y))] = true
	for chute in room.get("chutes", []):
		chutes[Vector2i(int(chute.x), int(chute.y))] = true
	for sink in room.get("sinks", []):
		var accepts := {}
		for mat in sink.accepts:
			accepts[int(mat)] = true
		sinks[Vector2i(int(sink.x), int(sink.y))] = accepts
	for src in room.get("sources", []):
		var source := Source.new()
		source.pos = Vector2i(int(src.x), int(src.y))
		source.dir = int(src.dir)
		source.pattern = src.pattern.duplicate()
		source.period = maxi(1, int(src.period))
		sources.append(source)
	var seen := {}
	var blocked := blocked_cells(room)
	for piece in placements:
		var pos := Vector2i(int(piece.x), int(piece.y))
		if pos.x < 0 or pos.y < 0 or pos.x >= width or pos.y >= height:
			error = "placement off the board at %s" % str(pos)
			return
		if blocked.has(pos):
			error = "placement on a fixed cell at %s" % str(pos)
			return
		if seen.has(pos):
			error = "two pieces on %s" % str(pos)
			return
		var kind := int(piece.kind)
		if kind < 0 or kind >= Rules.KIND_NAME.size():
			error = "unknown piece at %s" % str(pos)
			return
		seen[pos] = true
		var machine := Machine.new()
		machine.kind = kind
		machine.dir = int(piece.dir) & 3
		machines[pos] = machine


func summarize(placements: Array) -> Dictionary:
	var quota_ok := error == "" and quota_met(counts, quota)
	var within_budget := budget_met(placements, budget)
	return {
		"world": self,
		"error": error,
		"counts": counts.duplicate(),
		"trace": trace.duplicate(),
		"discarded": discarded,
		"quota_ok": quota_ok,
		"budget_ok": within_budget,
		"success": quota_ok and within_budget,
		"ticks": tick,
		"seed": seed,
		"text": describe(counts, quota),
		"sig": "%d,%d,%d" % [
			int(counts.get(Rules.Mat.ORE, 0)),
			int(counts.get(Rules.Mat.INGOT, 0)),
			int(counts.get(Rules.Mat.PLATE, 0)),
		],
	}


func step() -> void:
	tick += 1
	var cells := _sorted_cells()
	for pos in cells:
		var machine: Machine = machines[pos]
		machine.moved = false
		machine.cross_moved = false
		if machine.timer > 0:
			machine.timer -= 1
			if machine.timer == 0:
				machine.output_ready = true
	var passes := 0
	while true:
		passes += 1
		if passes > 64:
			error = "simulation did not settle"
			return
		var moved_any := false
		for pos in cells:
			if _try_output(pos):
				moved_any = true
		if not moved_any:
			break
	_emit_sources()


func debug_state() -> String:
	var lines: PackedStringArray = []
	lines.append("tick=%d discarded=%d error=%s counts=%s" % [tick, discarded, error, str(counts)])
	var packed := PackedStringArray()
	for entry in trace:
		packed.append(str(entry))
	lines.append("trace=%s" % "|".join(packed))
	for index in sources.size():
		var source: Source = sources[index]
		lines.append("source%d (%d,%d) pending=%d cooldown=%d cursor=%d" % [
			index, source.pos.x, source.pos.y, source.pending, source.cooldown, source.cursor,
		])
	for pos in _sorted_cells():
		var machine: Machine = machines[pos]
		lines.append("(%d,%d) %s %s hold=%d cross=%d moved=%s cross_moved=%s timer=%d buf=%d ready=%s phase=%d" % [
			pos.x,
			pos.y,
			Rules.KIND_NAME[machine.kind],
			Rules.DIR_NAME[machine.dir],
			machine.hold,
			machine.cross,
			str(machine.moved),
			str(machine.cross_moved),
			machine.timer,
			machine.buffer,
			str(machine.output_ready),
			machine.phase,
		])
	return "\n".join(lines)


func _sorted_cells() -> Array:
	var cells: Array = machines.keys()
	cells.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		var ka := a.y * 1000 + a.x
		var kb := b.y * 1000 + b.x
		return ka < kb
	)
	return cells


func _holder(kind: int) -> bool:
	return (
		kind == Rules.Kind.BELT
		or kind == Rules.Kind.FILTER
		or kind == Rules.Kind.SPLITTER
		or kind == Rules.Kind.ROLLER
		or kind == Rules.Kind.WEIR
		or kind == Rules.Kind.GRATE
		or kind == Rules.Kind.HOOK
		or kind == Rules.Kind.ARM
		or kind == Rules.Kind.DROP
		or kind == Rules.Kind.LIFT
		or kind == Rules.Kind.DWELL
	)


func _try_output(pos: Vector2i) -> bool:
	var machine: Machine = machines[pos]
	var mat := -1
	var out_dir := machine.dir
	if machine.kind == Rules.Kind.BRIDGE:
		return _try_bridge(pos, machine)
	if _holder(machine.kind):
		if machine.hold < 0 or machine.moved:
			return false
		mat = machine.hold
		if machine.kind == Rules.Kind.FILTER:
			out_dir = machine.dir if mat == Rules.Mat.ORE else Rules.right(machine.dir)
		elif machine.kind == Rules.Kind.GRATE:
			out_dir = machine.dir if mat == Rules.Mat.PLATE else Rules.right(machine.dir)
		elif machine.kind == Rules.Kind.HOOK:
			# Left only. A blocked exit waits; the item does not spill forward.
			out_dir = Rules.left(machine.dir)
		elif machine.kind == Rules.Kind.ARM:
			# Forward only. A blocked exit waits; the item does not send left.
			out_dir = machine.dir
		elif machine.kind == Rules.Kind.DROP:
			# Right only. A blocked exit waits; the item does not send forward.
			out_dir = Rules.right(machine.dir)
		elif machine.kind == Rules.Kind.LIFT:
			# Back only. A blocked exit waits; the item does not send right.
			out_dir = Rules.opposite(machine.dir)
		elif machine.kind == Rules.Kind.DWELL:
			# The arrival tick only stores the item. The next tick spends the
			# extra hold. After that the item leaves forward, or waits if blocked.
			if machine.phase > 0:
				machine.phase -= 1
				machine.moved = true
				return false
			out_dir = machine.dir
		elif machine.kind == Rules.Kind.SPLITTER:
			out_dir = machine.dir if machine.phase == 0 else Rules.right(machine.dir)
		elif machine.kind == Rules.Kind.WEIR:
			return _try_weir(pos, machine, mat)
	elif machine.kind == Rules.Kind.KILN:
		if not machine.output_ready:
			return false
		mat = Rules.Mat.INGOT
	elif machine.kind == Rules.Kind.PRESS:
		if not machine.output_ready:
			return false
		mat = Rules.Mat.PLATE
	else:
		return false
	var dest := pos + Rules.vec(out_dir)
	if not _accept(dest, mat, out_dir):
		return false
	if _holder(machine.kind):
		machine.hold = -1
		machine.moved = false
		if machine.kind == Rules.Kind.SPLITTER:
			machine.phase = 1 - machine.phase
	else:
		machine.output_ready = false
	return true


## Forward first, then clockwise. Both tries are in this output pass.
## A refused forward cell is unchanged, so the side try is safe.
## The preference does not stick: the next item tries forward again.
func _try_weir(pos: Vector2i, machine: Machine, mat: int) -> bool:
	if _accept(pos + Rules.vec(machine.dir), mat, machine.dir):
		machine.hold = -1
		machine.moved = false
		return true
	var turn := Rules.right(machine.dir)
	if _accept(pos + Rules.vec(turn), mat, turn):
		machine.hold = -1
		machine.moved = false
		return true
	return false


## The forward lane leaves first, then the cross lane.
## Each item stays on the lane it entered. A blocked exit does not spill.
func _try_bridge(pos: Vector2i, machine: Machine) -> bool:
	var sent := false
	if machine.hold >= 0 and not machine.moved:
		if _accept(pos + Rules.vec(machine.dir), machine.hold, machine.dir):
			machine.hold = -1
			machine.moved = false
			sent = true
	var turn := Rules.right(machine.dir)
	if machine.cross >= 0 and not machine.cross_moved:
		if _accept(pos + Rules.vec(turn), machine.cross, turn):
			machine.cross = -1
			machine.cross_moved = false
			sent = true
	return sent


func _can_take(machine: Machine, mat: int, arrival: int) -> bool:
	if machine.kind == Rules.Kind.BELT:
		return machine.hold < 0 and arrival != Rules.opposite(machine.dir)
	if (
		machine.kind == Rules.Kind.FILTER
		or machine.kind == Rules.Kind.SPLITTER
		or machine.kind == Rules.Kind.ROLLER
		or machine.kind == Rules.Kind.WEIR
		or machine.kind == Rules.Kind.GRATE
		or machine.kind == Rules.Kind.HOOK
	):
		return machine.hold < 0 and arrival == machine.dir
	if machine.kind == Rules.Kind.ARM:
		# From the left only: the item is moving toward the arm's right.
		return machine.hold < 0 and arrival == Rules.right(machine.dir)
	if machine.kind == Rules.Kind.DROP:
		# From above only: the front, the item moving against the facing.
		return machine.hold < 0 and arrival == Rules.opposite(machine.dir)
	if machine.kind == Rules.Kind.LIFT:
		# From below only: the right side, the item moving toward the lift's left.
		# Pointed east, that cell is south. Pointed north, the right side is east.
		return machine.hold < 0 and arrival == Rules.left(machine.dir)
	if machine.kind == Rules.Kind.DWELL:
		# From behind only. A side entry and a head-on entry stay where they were.
		return machine.hold < 0 and arrival == machine.dir
	if (
		machine.kind == Rules.Kind.TWIN
		or machine.kind == Rules.Kind.PASS
		or machine.kind == Rules.Kind.SLIP
		or machine.kind == Rules.Kind.SHED
	):
		# Pairing is handled in _accept. A twin, a pass, a slip, or a shed may already be holding.
		return false
	if machine.kind == Rules.Kind.BRIDGE:
		if arrival == machine.dir:
			return machine.hold < 0
		if arrival == Rules.right(machine.dir):
			return machine.cross < 0
		return false
	if machine.kind == Rules.Kind.KILN:
		return (
			mat == Rules.Mat.ORE
			and arrival == machine.dir
			and machine.timer == 0
			and not machine.output_ready
		)
	if machine.kind == Rules.Kind.PRESS:
		return (
			mat == Rules.Mat.INGOT
			and arrival == machine.dir
			and machine.timer == 0
			and not machine.output_ready
			and machine.buffer < 2
		)
	return false


func _accept(dest: Vector2i, mat: int, arrival: int) -> bool:
	if dest.x < 0 or dest.y < 0 or dest.x >= width or dest.y >= height:
		return false
	if walls.has(dest):
		return false
	if chutes.has(dest):
		discarded += 1
		return true
	if sinks.has(dest):
		var accepts: Dictionary = sinks[dest]
		if not accepts.has(mat):
			return false
		counts[mat] = int(counts[mat]) + 1
		trace.append("%d:%d,%d:%d" % [tick, dest.x, dest.y, mat])
		return true
	if not machines.has(dest):
		return false
	var machine: Machine = machines[dest]
	if machine.kind == Rules.Kind.TWIN:
		return _accept_twin(dest, machine, mat, arrival)
	if machine.kind == Rules.Kind.PASS:
		return _accept_pass(dest, machine, mat, arrival)
	if machine.kind == Rules.Kind.SLIP:
		return _accept_slip(dest, machine, mat, arrival)
	if machine.kind == Rules.Kind.SHED:
		return _accept_shed(dest, machine, mat, arrival)
	if not _can_take(machine, mat, arrival):
		return false
	if _holder(machine.kind):
		machine.hold = mat
		machine.moved = true
		if machine.kind == Rules.Kind.DWELL:
			# One tick beyond a belt: the next output pass only clears this hold.
			machine.phase = Rules.DWELL_HOLD
	elif machine.kind == Rules.Kind.BRIDGE:
		if arrival == machine.dir:
			machine.hold = mat
			machine.moved = true
		else:
			machine.cross = mat
			machine.cross_moved = true
	elif machine.kind == Rules.Kind.KILN:
		machine.timer = Rules.KILN_DELAY
	elif machine.kind == Rules.Kind.PRESS:
		machine.buffer += 1
		if machine.buffer >= 2:
			machine.buffer = 0
			machine.timer = Rules.PRESS_DELAY
	else:
		return false
	return true


## Behind only. The first item waits until a later item of the same material
## arrives. On that tick the waiter moves one cell forward and the arrival
## becomes the new waiter. A different material is refused. A blocked forward
## cell refuses the arrival and leaves the waiter in place. A lone item never
## leaves, including on the next tick and the tick after that.
func _accept_twin(pos: Vector2i, machine: Machine, mat: int, arrival: int) -> bool:
	if arrival != machine.dir:
		return false
	if machine.hold < 0:
		machine.hold = mat
		machine.moved = true
		return true
	if machine.hold != mat or machine.moved or machine.pairing:
		return false
	machine.pairing = true
	var sent: bool = _accept(pos + Rules.vec(machine.dir), machine.hold, machine.dir)
	machine.pairing = false
	if not sent:
		return false
	machine.hold = mat
	machine.moved = true
	return true


## Behind only. The first item waits until a later item arrives from behind.
## That later item may be a different material. On that tick the waiter moves
## one cell forward and the arrival becomes the new waiter. A blocked forward
## cell refuses the arrival and leaves the waiter in place. A lone item never
## leaves, including on the next tick and the tick after that. The pass does
## not spill, rotate, alternate, or send left, right, or back.
func _accept_pass(pos: Vector2i, machine: Machine, mat: int, arrival: int) -> bool:
	if arrival != machine.dir:
		return false
	if machine.hold < 0:
		machine.hold = mat
		machine.moved = true
		return true
	if machine.moved or machine.pairing:
		return false
	machine.pairing = true
	var sent: bool = _accept(pos + Rules.vec(machine.dir), machine.hold, machine.dir)
	machine.pairing = false
	if not sent:
		return false
	machine.hold = mat
	machine.moved = true
	return true


## Behind only. The first item waits and never leaves on its own. A later item
## from behind may be a different material. On that tick the arrival moves one
## cell forward and the waiting item stays. The arrival does not replace it.
## A blocked forward cell refuses the arrival and leaves the waiter in place.
## A lone item never leaves, including on the next tick and the tick after that.
## The slip does not spill, rotate, alternate, or send left, right, or back.
func _accept_slip(pos: Vector2i, machine: Machine, mat: int, arrival: int) -> bool:
	if arrival != machine.dir:
		return false
	if machine.hold < 0:
		machine.hold = mat
		machine.moved = true
		return true
	if machine.moved or machine.pairing:
		return false
	machine.pairing = true
	var sent: bool = _accept(pos + Rules.vec(machine.dir), mat, machine.dir)
	machine.pairing = false
	if not sent:
		return false
	machine.moved = true
	return true


## Behind only. The first item waits and never leaves on its own. A later item
## from behind may be a different material. On that tick the arrival moves one
## cell to the left and the waiting item stays. The arrival does not replace it.
## A blocked left cell refuses the arrival and leaves the waiter in place.
## A lone item never leaves, including on the next tick and the tick after that.
## The shed does not spill, rotate, alternate, or send forward, right, or back.
func _accept_shed(pos: Vector2i, machine: Machine, mat: int, arrival: int) -> bool:
	if arrival != machine.dir:
		return false
	if machine.hold < 0:
		machine.hold = mat
		machine.moved = true
		return true
	if machine.moved or machine.pairing:
		return false
	var turn := Rules.left(machine.dir)
	machine.pairing = true
	var sent: bool = _accept(pos + Rules.vec(turn), mat, turn)
	machine.pairing = false
	if not sent:
		return false
	machine.moved = true
	return true


func _emit_sources() -> void:
	for source in sources:
		var emitter: Source = source
		if emitter.pending < 0:
			if emitter.cooldown > 0:
				emitter.cooldown -= 1
				continue
			emitter.pending = int(emitter.pattern[emitter.cursor])
			emitter.cursor = (emitter.cursor + 1) % emitter.pattern.size()
		var dest := emitter.pos + Rules.vec(emitter.dir)
		if _accept(dest, emitter.pending, emitter.dir):
			emitter.pending = -1
			emitter.cooldown = emitter.period - 1
