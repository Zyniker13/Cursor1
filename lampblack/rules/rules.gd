class_name LampRules
extends RefCounted

## Lampblack rules.
##
## Turn order
## 1. The player takes one action: step to an adjacent tile, wait, or toggle an adjacent lamp.
## 2. If that toggle snuffed a lamp (lit became dark), the nearest guard is called.
##    Distance is Manhattan from the guard's tile to the lamp's tile. A tie goes to the
##    lowest guard index. The call does not change the step taken in step 3.
## 3. Every guard then moves one tile according to the alert that was already active
##    at the start of the turn, or along their rail if they are not alert and not holding.
## 4. The call from step 2 becomes the active alert after that movement. The arrow shows
##    the tile the called guard will step to on the next turn — "snuffing calls the
##    nearest guard toward that lamp on the next turn."
## 5. Stepping onto the exit wins immediately, before the guards move.
##    Sharing a tile with a guard, or standing on a watched tile, is a loss. That is
##    checked after the player's action and again after the guards move.
##
## Light
## A lit lamp illuminates a Manhattan diamond of its radius, clipped by walls.
## A tile is inside the diamond when its distance from the lamp is at most the radius
## and it is not strictly behind the lamp. "Behind" means the step from the lamp to the
## tile has a negative dot product with the lamp's facing (north, east, south, or west).
## Sideways tiles count. The tile directly behind the lamp stays dark, so the player
## can stand there and snuff it. Walls block the flood; they are never lit.
##
## Movement
## Dark floor and a dark exit may be entered. A gap may be entered only while it is lit.
## Lit floor that no guard is watching is refused. Stepping onto a watched tile is a loss,
## not a refusal — watched means the tile is lit and lies in a guard's vision.
##
## Vision
## Each guard watches a Manhattan diamond of their vision radius, and only on tiles that
## are currently lit. Walls and dark tiles block vision. A guard standing in the dark can
## still look into an adjacent lit tile. The guard's own tile is not marked watched;
## standing on the guard is a separate loss.
##
## Guards
## Alerted guards take one step along a shortest 4-neighbor path to the lamp they were
## called to. Neighbors are expanded north, east, south, then west, and that order breaks
## ties. They may walk on floor and exit tiles, lit or dark, but not through walls or gaps.
## When they step onto the lamp they hold there. They do not resume the rail unless a
## later snuff calls them.
## A guard who is not alert and not holding patrols their rail. The rail is a list of
## waypoints. rail_index is the waypoint they are walking toward, and rail_dir is +1 or -1.
## On reaching that waypoint they advance the index, reversing at either end. A rail with
## fewer than two waypoints means they stand still until called.
##
## Undo
## A snapshot taken before each accepted action restores the player's position and facing,
## every lamp's lit flag, and every guard's position, rail index, rail direction, alert
## target, and hold flag.

enum Tile { WALL, FLOOR, GAP, EXIT }
enum Result { OK, WIN, LOSS, ILLEGAL }

const DIRS := [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]
const FACING := {
	"n": Vector2i(0, -1),
	"e": Vector2i(1, 0),
	"s": Vector2i(0, 1),
	"w": Vector2i(-1, 0),
}


static func build(rows: PackedStringArray, lamps: Array, guards: Array) -> Dictionary:
	var height := rows.size()
	var width := rows[0].length()
	var tiles: Array = []
	tiles.resize(width * height)
	var player := {"x": 1, "y": 1, "fx": 1, "fy": 0}
	for y in height:
		var row: String = rows[y]
		if row.length() != width:
			push_error("ragged row %d" % y)
		for x in width:
			var ch := row.substr(x, 1)
			var kind := Tile.WALL
			match ch:
				"#":
					kind = Tile.WALL
				".":
					kind = Tile.FLOOR
				"G":
					kind = Tile.GAP
				"X":
					kind = Tile.EXIT
				"S":
					kind = Tile.FLOOR
					player = {"x": x, "y": y, "fx": 1, "fy": 0}
				_:
					push_error("bad tile '%s'" % ch)
			tiles[y * width + x] = kind
	var lamp_list: Array = []
	for i in lamps.size():
		var src: Dictionary = lamps[i]
		var face: Vector2i = FACING[src["facing"]]
		lamp_list.append({
			"id": i,
			"x": int(src["x"]),
			"y": int(src["y"]),
			"facing": src["facing"],
			"fx": face.x,
			"fy": face.y,
			"radius": int(src["radius"]),
			"lit": bool(src.get("lit", true)),
		})
	var guard_list: Array = []
	for i in guards.size():
		var src: Dictionary = guards[i]
		var rail: Array = []
		for point in src["rail"]:
			rail.append(Vector2i(point))
		guard_list.append({
			"id": i,
			"x": int(src["x"]),
			"y": int(src["y"]),
			"vision": int(src.get("vision", 2)),
			"rail": rail,
			"rail_index": int(src.get("rail_index", 0)),
			"rail_dir": int(src.get("rail_dir", 1)),
			"alert": false,
			"ax": 0,
			"ay": 0,
			"holding": false,
		})
	return {
		"w": width,
		"h": height,
		"tiles": tiles,
		"player": player,
		"lamps": lamp_list,
		"guards": guard_list,
	}


static func clone(state: Dictionary) -> Dictionary:
	return state.duplicate(true)


static func signature(state: Dictionary) -> String:
	var player: Dictionary = state["player"]
	var parts: PackedStringArray = PackedStringArray()
	parts.append("P:%d,%d,%d,%d" % [player["x"], player["y"], player["fx"], player["fy"]])
	for lamp in state["lamps"]:
		var lit_bit := 1 if lamp["lit"] else 0
		parts.append("L%d:%d,%d,%s,%d,%d" % [
			lamp["id"], lamp["x"], lamp["y"], lamp["facing"], lamp["radius"], lit_bit
		])
	for guard in state["guards"]:
		var rail_bits: PackedStringArray = PackedStringArray()
		for point in guard["rail"]:
			var cell: Vector2i = point
			rail_bits.append("%d,%d" % [cell.x, cell.y])
		var alert_bit := 1 if guard["alert"] else 0
		var hold_bit := 1 if guard["holding"] else 0
		parts.append("G%d:%d,%d,v%d,ri%d,rd%d,a%d,t%d,%d,h%d,rail%s" % [
			guard["id"], guard["x"], guard["y"], guard["vision"],
			guard["rail_index"], guard["rail_dir"],
			alert_bit, guard["ax"], guard["ay"],
			hold_bit, "+".join(rail_bits),
		])
	return "|".join(parts)


static func tile_at(state: Dictionary, x: int, y: int) -> int:
	if x < 0 or y < 0 or x >= state["w"] or y >= state["h"]:
		return -1
	return state["tiles"][y * state["w"] + x]


static func is_win(state: Dictionary) -> bool:
	var player: Dictionary = state["player"]
	return tile_at(state, player["x"], player["y"]) == Tile.EXIT


static func in_diamond(lamp: Dictionary, x: int, y: int) -> bool:
	var dx := x - int(lamp["x"])
	var dy := y - int(lamp["y"])
	if absi(dx) + absi(dy) > int(lamp["radius"]):
		return false
	if dx * int(lamp["fx"]) + dy * int(lamp["fy"]) < 0:
		return false
	return true


static func lamp_lights(state: Dictionary, lamp: Dictionary) -> Array:
	var lit: Array = []
	if not lamp["lit"]:
		return lit
	var seen := {}
	var queue: Array = []
	var origin := Vector2i(lamp["x"], lamp["y"])
	if tile_at(state, origin.x, origin.y) != Tile.WALL and tile_at(state, origin.x, origin.y) != -1 and in_diamond(lamp, origin.x, origin.y):
		seen[origin] = true
		queue.append(origin)
	for dir in DIRS:
		var nxt: Vector2i = origin + dir
		var kind := tile_at(state, nxt.x, nxt.y)
		if kind == -1 or kind == Tile.WALL:
			continue
		if not in_diamond(lamp, nxt.x, nxt.y):
			continue
		if seen.has(nxt):
			continue
		seen[nxt] = true
		queue.append(nxt)
	var head := 0
	while head < queue.size():
		var cell: Vector2i = queue[head]
		head += 1
		lit.append(cell)
		for dir in DIRS:
			var nxt: Vector2i = cell + dir
			if seen.has(nxt):
				continue
			var kind := tile_at(state, nxt.x, nxt.y)
			if kind == -1 or kind == Tile.WALL:
				continue
			if not in_diamond(lamp, nxt.x, nxt.y):
				continue
			seen[nxt] = true
			queue.append(nxt)
	return lit


static func light_map(state: Dictionary) -> Dictionary:
	var lit := {}
	for lamp in state["lamps"]:
		for cell in lamp_lights(state, lamp):
			lit[cell] = true
	return lit


static func watched_tiles(state: Dictionary, lit: Dictionary = {}) -> Dictionary:
	var lights := lit
	if lights.is_empty():
		lights = light_map(state)
	var watched := {}
	for guard in state["guards"]:
		var origin := Vector2i(guard["x"], guard["y"])
		var queue: Array = [{"cell": origin, "dist": 0}]
		var seen := {origin: true}
		var head := 0
		while head < queue.size():
			var item: Dictionary = queue[head]
			head += 1
			var cell: Vector2i = item["cell"]
			var dist: int = item["dist"]
			if dist > 0 and lights.has(cell):
				watched[cell] = true
			if dist >= int(guard["vision"]):
				continue
			var source_lit := dist == 0 or lights.has(cell)
			if not source_lit:
				continue
			for dir in DIRS:
				var nxt: Vector2i = cell + dir
				if seen.has(nxt):
					continue
				if tile_at(state, nxt.x, nxt.y) == -1 or tile_at(state, nxt.x, nxt.y) == Tile.WALL:
					continue
				if absi(nxt.x - origin.x) + absi(nxt.y - origin.y) > int(guard["vision"]):
					continue
				if not lights.has(nxt):
					continue
				seen[nxt] = true
				queue.append({"cell": nxt, "dist": dist + 1})
	return watched


static func is_player_watched(state: Dictionary) -> bool:
	var player: Dictionary = state["player"]
	return watched_tiles(state).has(Vector2i(player["x"], player["y"]))


static func shares_tile_with_guard(state: Dictionary) -> bool:
	var player: Dictionary = state["player"]
	for guard in state["guards"]:
		if guard["x"] == player["x"] and guard["y"] == player["y"]:
			return true
	return false


static func loss_reason(state: Dictionary, lit: Dictionary = {}) -> String:
	if shares_tile_with_guard(state):
		return "guard"
	var lights := lit if not lit.is_empty() else light_map(state)
	var player: Dictionary = state["player"]
	if watched_tiles(state, lights).has(Vector2i(player["x"], player["y"])):
		return "watched"
	return ""


static func guard_walkable(state: Dictionary, x: int, y: int) -> bool:
	var kind := tile_at(state, x, y)
	return kind == Tile.FLOOR or kind == Tile.EXIT


static func bfs_path(state: Dictionary, sx: int, sy: int, gx: int, gy: int) -> Dictionary:
	var start := Vector2i(sx, sy)
	var goal := Vector2i(gx, gy)
	if start == goal:
		return {"step": start, "path": [start]}
	var queue: Array = [start]
	var parent := {start: Vector2i(-999, -999)}
	var head := 0
	while head < queue.size():
		var cell: Vector2i = queue[head]
		head += 1
		for dir in DIRS:
			var nxt: Vector2i = cell + dir
			if parent.has(nxt):
				continue
			if not guard_walkable(state, nxt.x, nxt.y):
				continue
			parent[nxt] = cell
			if nxt == goal:
				var path: Array = [goal]
				var cursor := cell
				while cursor != Vector2i(-999, -999):
					path.append(cursor)
					cursor = parent[cursor]
				path.reverse()
				return {"step": path[1], "path": path}
			queue.append(nxt)
	return {"step": start, "path": [start]}


static func _advance_rail(guard: Dictionary) -> void:
	var rail: Array = guard["rail"]
	if rail.size() < 2:
		return
	var here := Vector2i(guard["x"], guard["y"])
	var target: Vector2i = rail[guard["rail_index"]]
	if here != target:
		return
	var nxt: int = int(guard["rail_index"]) + int(guard["rail_dir"])
	if nxt < 0 or nxt >= rail.size():
		guard["rail_dir"] = -int(guard["rail_dir"])
		nxt = int(guard["rail_index"]) + int(guard["rail_dir"])
	guard["rail_index"] = nxt


static func plan_guard(state: Dictionary, guard: Dictionary) -> Dictionary:
	var ng: Dictionary = guard.duplicate(true)
	var step := Vector2i(ng["x"], ng["y"])
	var path: Array = [step]
	if ng["alert"]:
		var target := Vector2i(ng["ax"], ng["ay"])
		if step == target:
			ng["alert"] = false
			ng["holding"] = true
			return {"guard": ng, "step": step, "path": path}
		var found := bfs_path(state, step.x, step.y, target.x, target.y)
		step = found["step"]
		path = found["path"]
		ng["x"] = step.x
		ng["y"] = step.y
		if step == target:
			ng["alert"] = false
			ng["holding"] = true
		return {"guard": ng, "step": step, "path": path}
	if ng["holding"] or ng["rail"].size() < 2:
		return {"guard": ng, "step": step, "path": path}
	_advance_rail(ng)
	var waypoint: Vector2i = ng["rail"][ng["rail_index"]]
	var found_rail := bfs_path(state, ng["x"], ng["y"], waypoint.x, waypoint.y)
	step = found_rail["step"]
	path = found_rail["path"]
	ng["x"] = step.x
	ng["y"] = step.y
	return {"guard": ng, "step": step, "path": path}


static func planned_step(state: Dictionary, guard_index: int) -> Vector2i:
	return plan_guard(state, state["guards"][guard_index])["step"]


static func planned_path(state: Dictionary, guard_index: int) -> Array:
	return plan_guard(state, state["guards"][guard_index])["path"]


static func nearest_guard(state: Dictionary, lamp: Dictionary) -> int:
	var best := -1
	var best_dist := 1 << 30
	for guard in state["guards"]:
		var dist := absi(int(guard["x"]) - int(lamp["x"])) + absi(int(guard["y"]) - int(lamp["y"]))
		if dist < best_dist or (dist == best_dist and (best == -1 or int(guard["id"]) < best)):
			best = int(guard["id"])
			best_dist = dist
	return best


static func apply(state: Dictionary, action: Dictionary, allow_toggle: bool = true) -> Dictionary:
	var kind := str(action.get("type", ""))
	if kind == "toggle" and not allow_toggle:
		return _finish(state, Result.ILLEGAL, -1, Vector2i(-1, -1), "toggle")
	var st := state.duplicate(true)
	var player: Dictionary = st["player"]
	var pending_guard := -1
	var pending_lamp := Vector2i.ZERO
	if kind == "wait":
		pass
	elif kind == "move":
		var dx := int(action["dx"])
		var dy := int(action["dy"])
		var nx := int(player["x"]) + dx
		var ny := int(player["y"]) + dy
		var dest := tile_at(st, nx, ny)
		if dest == -1 or dest == Tile.WALL:
			return _finish(state, Result.ILLEGAL, -1, Vector2i(-1, -1), "wall")
		var lit := light_map(st)
		var watch := watched_tiles(st, lit)
		if watch.has(Vector2i(nx, ny)):
			player["x"] = nx
			player["y"] = ny
			player["fx"] = dx
			player["fy"] = dy
			return _finish(st, Result.LOSS, -1, Vector2i(-1, -1), "watched")
		if dest == Tile.GAP:
			if not lit.has(Vector2i(nx, ny)):
				return _finish(state, Result.ILLEGAL, -1, Vector2i(-1, -1), "darkgap")
		elif dest == Tile.FLOOR or dest == Tile.EXIT:
			if lit.has(Vector2i(nx, ny)):
				return _finish(state, Result.ILLEGAL, -1, Vector2i(-1, -1), "lit")
		else:
			return _finish(state, Result.ILLEGAL, -1, Vector2i(-1, -1), "wall")
		for guard in st["guards"]:
			if guard["x"] == nx and guard["y"] == ny:
				player["x"] = nx
				player["y"] = ny
				player["fx"] = dx
				player["fy"] = dy
				return _finish(st, Result.LOSS, -1, Vector2i(-1, -1), "guard")
		player["x"] = nx
		player["y"] = ny
		player["fx"] = dx
		player["fy"] = dy
	elif kind == "toggle":
		var index := int(action["lamp"])
		var lamp_list: Array = st["lamps"]
		if index < 0 or index >= lamp_list.size():
			return _finish(state, Result.ILLEGAL, -1, Vector2i(-1, -1), "lamp")
		var lamp: Dictionary = lamp_list[index]
		if absi(int(lamp["x"]) - int(player["x"])) + absi(int(lamp["y"]) - int(player["y"])) != 1:
			return _finish(state, Result.ILLEGAL, -1, Vector2i(-1, -1), "range")
		var here := tile_at(st, player["x"], player["y"])
		if here != Tile.FLOOR and here != Tile.EXIT:
			return _finish(state, Result.ILLEGAL, -1, Vector2i(-1, -1), "range")
		var was_lit: bool = lamp["lit"]
		lamp["lit"] = not was_lit
		player["fx"] = int(lamp["x"]) - int(player["x"])
		player["fy"] = int(lamp["y"]) - int(player["y"])
		if was_lit:
			pending_guard = nearest_guard(st, lamp)
			pending_lamp = Vector2i(lamp["x"], lamp["y"])
	else:
		return _finish(state, Result.ILLEGAL, -1, Vector2i(-1, -1), "action")

	var lit_now := light_map(st)
	var why := loss_reason(st, lit_now)
	if why != "":
		return _finish(st, Result.LOSS, -1, Vector2i(-1, -1), why)
	if tile_at(st, player["x"], player["y"]) == Tile.EXIT:
		return _finish(st, Result.WIN, -1, Vector2i(-1, -1), "exit")

	for i in st["guards"].size():
		var planned := plan_guard(st, st["guards"][i])
		st["guards"][i] = planned["guard"]
	if pending_guard >= 0:
		var called: Dictionary = st["guards"][pending_guard]
		called["alert"] = true
		called["ax"] = pending_lamp.x
		called["ay"] = pending_lamp.y
		called["holding"] = false
	var step := Vector2i(-1, -1)
	if pending_guard >= 0:
		step = planned_step(st, pending_guard)
	lit_now = light_map(st)
	why = loss_reason(st, lit_now)
	if why != "":
		return _finish(st, Result.LOSS, pending_guard, step, why)
	return _finish(st, Result.OK, pending_guard, step, "")


static func _finish(state: Dictionary, result: int, called: int, step: Vector2i, reason: String) -> Dictionary:
	return {
		"state": state,
		"result": result,
		"called": called,
		"step": step,
		"reason": reason,
	}
