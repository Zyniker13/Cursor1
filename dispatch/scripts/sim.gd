extends RefCounted

## Deterministic tick simulation for Dispatch.
## Directions: 0 east, 1 south, 2 west, 3 north (clockwise on screen, +y is south).

const DIRS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(0, -1)
]
const DIR_NAMES: Array[String] = ["East", "South", "West", "North"]
const TYPES: Array[String] = ["conveyor", "latch", "splitter", "painter", "counter", "filter", "primer", "bridge", "turn", "slide", "bin", "hook", "return", "pause", "chute", "shunt", "bias", "vault", "sling", "cant", "balk", "loft", "keel", "sheer", "strake", "wale", "garboard", "stealer", "rabbet", "futtock", "keelson", "stemson", "apron", "deadwood", "gripe", "forefoot", "knighthead", "hawse", "breasthook", "cathead", "gammon", "bobstay", "bumpkin", "dolphin", "martingale", "jibboom", "whisker", "cranse", "bees", "sprit", "bumkin", "vangs", "clew", "sheet", "tack", "cleat", "belay", "bitt", "bollard"]
const PAINTS: Array[String] = ["red", "blue", "yellow"]
const TICK_CAP := 250


static func run(puzzle: Dictionary, graph: Array) -> Dictionary:
	var width := int(puzzle["width"])
	var height := int(puzzle["height"])
	var dock := Vector2i(int(puzzle["dock"]["x"]), int(puzzle["dock"]["y"]))
	var walls := {}
	for wall in puzzle.get("walls", []):
		walls[_key(int(wall["x"]), int(wall["y"]))] = true
	var source_cells := {}
	var sources: Array = []
	for source in puzzle["sources"]:
		var queue: Array = []
		for spec in source["parcels"]:
			queue.append({
				"color": str(spec.get("color", "gray")),
				"count": int(spec.get("count", 0)),
			})
		var sx := int(source["x"])
		var sy := int(source["y"])
		source_cells[_key(sx, sy)] = true
		sources.append({
			"x": sx,
			"y": sy,
			"dir": int(source["dir"]),
			"queue": queue,
		})

	var blocks := {}
	var seen := {}
	for raw in graph:
		var typ := str(raw.get("type", ""))
		if not TYPES.has(typ):
			return _finish(false, 0, graph.size(), "invalid", 0, [], [])
		var x := int(raw.get("x", -1))
		var y := int(raw.get("y", -1))
		var dir := int(raw.get("dir", -1))
		if dir < 0 or dir > 3:
			return _finish(false, 0, graph.size(), "invalid", 0, [], [])
		var key := _key(x, y)
		if seen.has(key):
			return _finish(false, 0, graph.size(), "invalid", 0, [], [])
		seen[key] = true
		if not _in_bounds(x, y, width, height):
			return _finish(false, 0, graph.size(), "invalid", 0, [], [])
		if walls.has(key) or source_cells.has(key) or Vector2i(x, y) == dock:
			return _finish(false, 0, graph.size(), "invalid", 0, [], [])
		var color := str(raw.get("color", ""))
		if (typ == "painter" or typ == "filter" or typ == "primer") and not PAINTS.has(color):
			return _finish(false, 0, graph.size(), "invalid", 0, [], [])
		blocks[key] = {
			"type": typ,
			"x": x,
			"y": y,
			"dir": dir,
			"color": color,
			"phase": 0,
			"value": 0,
		}

	var order: Array = puzzle["order"]
	var parcels: Array = []
	var delivered: Array = []
	var frames: Array = []
	var next_id := 1
	frames.append(_snapshot(0, parcels, delivered, blocks))

	var end_tick := 0
	for tick in range(1, TICK_CAP + 1):
		end_tick = tick
		var kept: Array = []
		for parcel in parcels:
			var stood = blocks.get(_key(int(parcel["x"]), int(parcel["y"])))
			if stood != null and str(stood["type"]) == "bin":
				continue
			kept.append(parcel)
		parcels = kept
		for parcel in parcels:
			var block = blocks.get(_key(int(parcel["x"]), int(parcel["y"])))
			if block == null:
				continue
			if str(block["type"]) == "painter":
				parcel["color"] = str(block["color"])
			elif str(block["type"]) == "primer" and str(parcel["color"]) == "gray":
				parcel["color"] = str(block["color"])
			elif str(block["type"]) == "counter" and not bool(parcel["counted"]):
				block["value"] = int(block["value"]) + 1
				parcel["count"] = int(block["value"])
				parcel["counted"] = true

		var occupied := {}
		for parcel in parcels:
			occupied[_key(int(parcel["x"]), int(parcel["y"]))] = parcel
		for parcel in parcels:
			parcel["intent"] = null
			var block = blocks.get(_key(int(parcel["x"]), int(parcel["y"])))
			if block == null:
				continue
			var typ := str(block["type"])
			if typ == "latch":
				if int(parcel["hold"]) < 1:
					continue
				var dest := Vector2i(int(parcel["x"]), int(parcel["y"])) + DIRS[int(block["dir"])]
				if occupied.has(_key(dest.x, dest.y)):
					continue
				if not _enterable(dest, dock, width, height, walls, source_cells, blocks):
					continue
				parcel["intent"] = dest
			elif typ == "splitter":
				var out := int(block["dir"])
				if int(block["phase"]) != 0:
					out = (out + 1) % 4
				parcel["intent"] = Vector2i(int(parcel["x"]), int(parcel["y"])) + DIRS[out]
			elif typ == "filter":
				var out := int(block["dir"])
				if str(parcel["color"]) != str(block["color"]):
					out = (out + 1) % 4
				parcel["intent"] = Vector2i(int(parcel["x"]), int(parcel["y"])) + DIRS[out]
			elif typ == "bridge":
				var step: Vector2i = DIRS[int(block["dir"])]
				parcel["intent"] = Vector2i(int(parcel["x"]), int(parcel["y"])) + step * 2
			elif typ == "slide":
				var step: Vector2i = DIRS[int(parcel["dir"])]
				parcel["intent"] = Vector2i(int(parcel["x"]), int(parcel["y"])) + step * 2
			elif typ == "turn" or typ == "hook" or typ == "return" or typ == "pause" or typ == "chute" or typ == "shunt" or typ == "bias" or typ == "vault" or typ == "sling" or typ == "cant" or typ == "balk" or typ == "loft" or typ == "keel" or typ == "sheer" or typ == "strake" or typ == "wale" or typ == "garboard" or typ == "stealer" or typ == "rabbet" or typ == "futtock" or typ == "keelson" or typ == "stemson" or typ == "apron" or typ == "deadwood" or typ == "gripe" or typ == "forefoot" or typ == "knighthead" or typ == "hawse" or typ == "breasthook" or typ == "cathead" or typ == "gammon" or typ == "bobstay" or typ == "bumpkin" or typ == "dolphin" or typ == "martingale" or typ == "jibboom" or typ == "whisker" or typ == "cranse" or typ == "bees" or typ == "sprit" or typ == "bumkin" or typ == "vangs" or typ == "clew" or typ == "sheet" or typ == "tack" or typ == "cleat" or typ == "belay" or typ == "bitt" or typ == "bollard":
				if int(parcel["hold"]) < 1:
					if typ == "chute":
						parcel["dir"] = int(block["dir"])
					elif typ != "shunt" and typ != "pause" and typ != "bias" and typ != "vault" and typ != "sling" and typ != "cant" and typ != "balk" and typ != "loft" and typ != "keel" and typ != "sheer" and typ != "strake" and typ != "wale" and typ != "garboard" and typ != "stealer" and typ != "rabbet" and typ != "futtock" and typ != "keelson" and typ != "stemson" and typ != "apron" and typ != "deadwood" and typ != "gripe" and typ != "forefoot" and typ != "knighthead" and typ != "hawse" and typ != "breasthook" and typ != "cathead" and typ != "gammon" and typ != "bobstay" and typ != "bumpkin" and typ != "dolphin" and typ != "martingale" and typ != "jibboom" and typ != "whisker" and typ != "cranse" and typ != "bees" and typ != "sprit" and typ != "bumkin" and typ != "vangs" and typ != "clew" and typ != "sheet" and typ != "tack" and typ != "cleat" and typ != "belay" and typ != "bitt" and typ != "bollard":
						var quarter := 0
						if typ == "turn":
							quarter = 1
						elif typ == "hook":
							quarter = 3
						elif typ == "return":
							quarter = 2
						if quarter != 0:
							parcel["dir"] = (int(parcel["dir"]) + quarter) % 4
				else:
					var step_dir := int(parcel["dir"])
					var span := 1
					if typ == "shunt" or typ == "wale":
						step_dir = (step_dir + 1) % 4
					elif typ == "bias" or typ == "garboard":
						step_dir = (step_dir + 3) % 4
					elif typ == "vault":
						span = 2
					elif typ == "loft":
						span = 3
					elif typ == "futtock":
						span = 4
					elif typ == "keelson":
						span = 5
					elif typ == "stemson":
						span = 6
					elif typ == "apron":
						span = 7
					elif typ == "deadwood":
						span = 8
					elif typ == "gripe":
						span = 9
					elif typ == "forefoot":
						span = 10
					elif typ == "knighthead":
						span = 11
					elif typ == "hawse":
						span = 12
					elif typ == "breasthook":
						span = 13
					elif typ == "cathead":
						span = 14
					elif typ == "gammon":
						span = 15
					elif typ == "bobstay":
						span = 16
					elif typ == "bumpkin":
						span = 17
					elif typ == "dolphin":
						span = 18
					elif typ == "martingale":
						span = 19
					elif typ == "jibboom":
						span = 20
					elif typ == "whisker":
						span = 21
					elif typ == "cranse":
						span = 22
					elif typ == "bees":
						span = 23
					elif typ == "sprit":
						span = 24
					elif typ == "bumkin":
						span = 25
					elif typ == "vangs":
						span = 26
					elif typ == "clew":
						span = 27
					elif typ == "sheet":
						span = 28
					elif typ == "tack":
						span = 29
					elif typ == "cleat":
						span = 30
					elif typ == "belay":
						span = 31
					elif typ == "bitt":
						span = 32
					elif typ == "bollard":
						span = 33
					elif typ == "sling":
						step_dir = (step_dir + 1) % 4
						span = 2
					elif typ == "cant":
						step_dir = (step_dir + 3) % 4
						span = 2
					elif typ == "balk":
						step_dir = (step_dir + 2) % 4
						span = 2
					elif typ == "keel":
						step_dir = (step_dir + 2) % 4
						span = 3
					elif typ == "sheer":
						step_dir = (step_dir + 1) % 4
						span = 3
					elif typ == "strake":
						step_dir = (step_dir + 3) % 4
						span = 2
					elif typ == "stealer":
						step_dir = (step_dir + 3) % 4
						span = 3
					elif typ == "rabbet":
						step_dir = (step_dir + 2) % 4
					parcel["intent"] = Vector2i(int(parcel["x"]), int(parcel["y"])) + DIRS[step_dir] * span
			elif typ == "bin":
				pass
			else:
				parcel["intent"] = Vector2i(int(parcel["x"]), int(parcel["y"])) + DIRS[int(block["dir"])]

		var guard := 0
		while true:
			guard += 1
			if guard > 64:
				for parcel in parcels:
					parcel["intent"] = null
				break
			var changed := false
			var groups := {}
			for parcel in parcels:
				if parcel["intent"] == null:
					continue
				var dest: Vector2i = parcel["intent"]
				var gk := _key(dest.x, dest.y)
				if not groups.has(gk):
					groups[gk] = []
				var bucket: Array = groups[gk]
				bucket.append(parcel)
			for gk in groups.keys():
				var group: Array = groups[gk]
				var dest: Vector2i = group[0]["intent"]
				var cancel := false
				if group.size() >= 2 or not _enterable(dest, dock, width, height, walls, source_cells, blocks):
					cancel = true
				else:
					var occ = occupied.get(gk)
					if occ != null and occ["intent"] == null:
						cancel = true
				if cancel:
					for parcel in group:
						if parcel["intent"] != null:
							parcel["intent"] = null
							changed = true
			if not changed:
				break

		var moved := false
		var ejected := {}
		var still: Array = []
		for parcel in parcels:
			if parcel["intent"] == null:
				parcel["hold"] = int(parcel["hold"]) + 1
				still.append(parcel)
				continue
			var origin := Vector2i(int(parcel["x"]), int(parcel["y"]))
			var dest: Vector2i = parcel["intent"]
			var block = blocks.get(_key(origin.x, origin.y))
			if block != null and str(block["type"]) == "splitter":
				ejected[_key(origin.x, origin.y)] = true
			moved = true
			var travel := _dir_of(dest - origin)
			if travel >= 0 and not (block != null and (str(block["type"]) == "shunt" or str(block["type"]) == "bias" or str(block["type"]) == "vault" or str(block["type"]) == "sling" or str(block["type"]) == "cant" or str(block["type"]) == "balk" or str(block["type"]) == "loft" or str(block["type"]) == "keel" or str(block["type"]) == "sheer" or str(block["type"]) == "strake" or str(block["type"]) == "wale" or str(block["type"]) == "garboard" or str(block["type"]) == "stealer" or str(block["type"]) == "rabbet" or str(block["type"]) == "futtock" or str(block["type"]) == "keelson" or str(block["type"]) == "stemson" or str(block["type"]) == "apron" or str(block["type"]) == "deadwood" or str(block["type"]) == "gripe" or str(block["type"]) == "forefoot" or str(block["type"]) == "knighthead" or str(block["type"]) == "hawse" or str(block["type"]) == "breasthook" or str(block["type"]) == "cathead" or str(block["type"]) == "gammon" or str(block["type"]) == "bobstay" or str(block["type"]) == "bumpkin" or str(block["type"]) == "dolphin" or str(block["type"]) == "martingale" or str(block["type"]) == "jibboom" or str(block["type"]) == "whisker" or str(block["type"]) == "cranse" or str(block["type"]) == "bees" or str(block["type"]) == "sprit" or str(block["type"]) == "bumkin" or str(block["type"]) == "vangs" or str(block["type"]) == "clew" or str(block["type"]) == "sheet" or str(block["type"]) == "tack" or str(block["type"]) == "cleat" or str(block["type"]) == "belay" or str(block["type"]) == "bitt" or str(block["type"]) == "bollard")):
				parcel["dir"] = travel
			if dest == dock:
				delivered.append({
					"color": str(parcel["color"]),
					"count": int(parcel["count"]),
				})
			else:
				parcel["x"] = dest.x
				parcel["y"] = dest.y
				parcel["hold"] = 0
				parcel["counted"] = false
				parcel["intent"] = null
				still.append(parcel)
		parcels = still
		for key in ejected.keys():
			blocks[key]["phase"] = 1 - int(blocks[key]["phase"])

		var emitted := false
		for source in sources:
			var queue: Array = source["queue"]
			if queue.is_empty():
				continue
			var dest: Vector2i = Vector2i(int(source["x"]), int(source["y"])) + DIRS[int(source["dir"])]
			if _find_at(parcels, dest) != null:
				continue
			if not _spawnable(dest, dock, width, height, walls, source_cells):
				continue
			var spec: Dictionary = queue.pop_front()
			parcels.append({
				"id": next_id,
				"x": dest.x,
				"y": dest.y,
				"color": str(spec["color"]),
				"count": int(spec["count"]),
				"hold": 0,
				"counted": false,
				"intent": null,
				"dir": int(source["dir"]),
			})
			next_id += 1
			emitted = true

		frames.append(_snapshot(tick, parcels, delivered, blocks))

		if not _prefix_ok(delivered, order):
			return _finish(false, 0, graph.size(), "wrong_delivery", end_tick, delivered, frames)
		if delivered.size() == order.size() and order.size() > 0:
			return _finish(true, tick, graph.size(), "", end_tick, delivered, frames)

		var latch_pending := false
		var turn_pending := false
		for parcel in parcels:
			var block = blocks.get(_key(int(parcel["x"]), int(parcel["y"])))
			if block == null:
				continue
			var typ := str(block["type"])
			var ahead := Vector2i(int(parcel["x"]), int(parcel["y"]))
			if typ == "latch" and int(parcel["hold"]) >= 1:
				ahead += DIRS[int(block["dir"])]
				if _find_at(parcels, ahead) == null and _enterable(ahead, dock, width, height, walls, source_cells, blocks):
					latch_pending = true
			elif (typ == "turn" or typ == "hook" or typ == "return" or typ == "pause" or typ == "chute" or typ == "shunt" or typ == "bias" or typ == "vault" or typ == "sling" or typ == "cant" or typ == "balk" or typ == "loft" or typ == "keel" or typ == "sheer" or typ == "strake" or typ == "wale" or typ == "garboard" or typ == "stealer" or typ == "rabbet" or typ == "futtock" or typ == "keelson" or typ == "stemson" or typ == "apron" or typ == "deadwood" or typ == "gripe" or typ == "forefoot" or typ == "knighthead" or typ == "hawse" or typ == "breasthook" or typ == "cathead" or typ == "gammon" or typ == "bobstay" or typ == "bumpkin" or typ == "dolphin" or typ == "martingale" or typ == "jibboom" or typ == "whisker" or typ == "cranse" or typ == "bees" or typ == "sprit" or typ == "bumkin" or typ == "vangs" or typ == "clew" or typ == "sheet" or typ == "tack" or typ == "cleat" or typ == "belay" or typ == "bitt" or typ == "bollard") and int(parcel["hold"]) >= 1:
				var step_dir := int(parcel["dir"])
				var span := 1
				if typ == "shunt" or typ == "wale":
					step_dir = (step_dir + 1) % 4
				elif typ == "bias" or typ == "garboard":
					step_dir = (step_dir + 3) % 4
				elif typ == "vault":
					span = 2
				elif typ == "loft":
					span = 3
				elif typ == "futtock":
					span = 4
				elif typ == "keelson":
					span = 5
				elif typ == "stemson":
					span = 6
				elif typ == "apron":
					span = 7
				elif typ == "deadwood":
					span = 8
				elif typ == "gripe":
					span = 9
				elif typ == "forefoot":
					span = 10
				elif typ == "knighthead":
					span = 11
				elif typ == "hawse":
					span = 12
				elif typ == "breasthook":
					span = 13
				elif typ == "cathead":
					span = 14
				elif typ == "gammon":
					span = 15
				elif typ == "bobstay":
					span = 16
				elif typ == "bumpkin":
					span = 17
				elif typ == "dolphin":
					span = 18
				elif typ == "martingale":
					span = 19
				elif typ == "jibboom":
					span = 20
				elif typ == "whisker":
					span = 21
				elif typ == "cranse":
					span = 22
				elif typ == "bees":
					span = 23
				elif typ == "sprit":
					span = 24
				elif typ == "bumkin":
					span = 25
				elif typ == "vangs":
					span = 26
				elif typ == "clew":
					span = 27
				elif typ == "sheet":
					span = 28
				elif typ == "tack":
					span = 29
				elif typ == "cleat":
					span = 30
				elif typ == "belay":
					span = 31
				elif typ == "bitt":
					span = 32
				elif typ == "bollard":
					span = 33
				elif typ == "sling":
					step_dir = (step_dir + 1) % 4
					span = 2
				elif typ == "cant":
					step_dir = (step_dir + 3) % 4
					span = 2
				elif typ == "balk":
					step_dir = (step_dir + 2) % 4
					span = 2
				elif typ == "keel":
					step_dir = (step_dir + 2) % 4
					span = 3
				elif typ == "sheer":
					step_dir = (step_dir + 1) % 4
					span = 3
				elif typ == "strake":
					step_dir = (step_dir + 3) % 4
					span = 2
				elif typ == "stealer":
					step_dir = (step_dir + 3) % 4
					span = 3
				elif typ == "rabbet":
					step_dir = (step_dir + 2) % 4
				ahead += DIRS[step_dir] * span
				if _find_at(parcels, ahead) != null or _enterable(ahead, dock, width, height, walls, source_cells, blocks):
					turn_pending = true
		if tick >= TICK_CAP:
			return _finish(false, 0, graph.size(), "tick_cap", end_tick, delivered, frames)
		if not moved and not emitted and not latch_pending and not turn_pending:
			return _finish(false, 0, graph.size(), "stuck", end_tick, delivered, frames)

	return _finish(false, 0, graph.size(), "tick_cap", end_tick, delivered, frames)


static func _finish(success: bool, cycles: int, blocks: int, reason: String, ticks: int, delivered: Array, frames: Array) -> Dictionary:
	return {
		"success": success,
		"cycles": cycles,
		"blocks": blocks,
		"reason": reason,
		"ticks": ticks,
		"delivered": delivered,
		"frames": frames,
	}


static func _snapshot(tick: int, parcels: Array, delivered: Array, blocks: Dictionary) -> Dictionary:
	var ps: Array = []
	for parcel in parcels:
		ps.append({
			"id": int(parcel["id"]),
			"x": int(parcel["x"]),
			"y": int(parcel["y"]),
			"color": str(parcel["color"]),
			"count": int(parcel["count"]),
			"dir": int(parcel["dir"]),
		})
	var markers: Array = []
	for key in blocks.keys():
		var block: Dictionary = blocks[key]
		if str(block["type"]) == "splitter":
			markers.append({
				"x": int(block["x"]),
				"y": int(block["y"]),
				"kind": "splitter",
				"phase": int(block["phase"]),
			})
		elif str(block["type"]) == "counter":
			markers.append({
				"x": int(block["x"]),
				"y": int(block["y"]),
				"kind": "counter",
				"value": int(block["value"]),
			})
	return {
		"tick": tick,
		"parcels": ps,
		"delivered": delivered.duplicate(true),
		"markers": markers,
	}


static func _prefix_ok(delivered: Array, order: Array) -> bool:
	if delivered.size() > order.size():
		return false
	for i in delivered.size():
		if not _matches(delivered[i], order[i]):
			return false
	return true


static func _matches(parcel: Dictionary, spec: Dictionary) -> bool:
	if spec.has("color") and str(spec["color"]) != str(parcel["color"]):
		return false
	if spec.has("count") and int(spec["count"]) != int(parcel["count"]):
		return false
	return true


static func _enterable(dest: Vector2i, dock: Vector2i, width: int, height: int, walls: Dictionary, source_cells: Dictionary, blocks: Dictionary) -> bool:
	if dest == dock:
		return true
	if not _in_bounds(dest.x, dest.y, width, height):
		return false
	var key := _key(dest.x, dest.y)
	if walls.has(key) or source_cells.has(key):
		return false
	return blocks.has(key)


static func _spawnable(dest: Vector2i, dock: Vector2i, width: int, height: int, walls: Dictionary, source_cells: Dictionary) -> bool:
	if dest == dock:
		return false
	if not _in_bounds(dest.x, dest.y, width, height):
		return false
	var key := _key(dest.x, dest.y)
	return not walls.has(key) and not source_cells.has(key)


static func _find_at(parcels: Array, pos: Vector2i):
	for parcel in parcels:
		if int(parcel["x"]) == pos.x and int(parcel["y"]) == pos.y:
			return parcel
	return null


static func _dir_of(delta: Vector2i) -> int:
	if delta.x > 0 and delta.y == 0:
		return 0
	if delta.y > 0 and delta.x == 0:
		return 1
	if delta.x < 0 and delta.y == 0:
		return 2
	if delta.y < 0 and delta.x == 0:
		return 3
	return -1


static func _in_bounds(x: int, y: int, width: int, height: int) -> bool:
	return x >= 0 and y >= 0 and x < width and y < height


static func _key(x: int, y: int) -> String:
	return "%d,%d" % [x, y]
