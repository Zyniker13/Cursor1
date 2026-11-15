extends RefCounted

const Rules = preload("res://scripts/foundry.gd")
const World = preload("res://scripts/world.gd")

var room: Dictionary
var placements: Array = []
var tray: Dictionary = {}
var blocked: Dictionary = {}


func _init(p_room: Dictionary) -> void:
	room = p_room
	blocked = World.blocked_cells(room)
	reset()


func reset() -> void:
	placements = []
	tray = {}
	for kind in room.budget.keys():
		tray[int(kind)] = int(room.budget[kind])
	for piece in room.initial:
		var kind := int(piece.kind)
		tray[kind] = int(tray.get(kind, 0)) - 1
		placements.append({
			"kind": kind,
			"x": int(piece.x),
			"y": int(piece.y),
			"dir": int(piece.dir),
		})


func remaining(kind: int) -> int:
	return int(tray.get(kind, 0))


func at(x: int, y: int):
	for piece in placements:
		if int(piece.x) == x and int(piece.y) == y:
			return piece
	return null


func can_place(kind: int, x: int, y: int) -> bool:
	if remaining(kind) <= 0:
		return false
	if x < 0 or y < 0 or x >= int(room.w) or y >= int(room.h):
		return false
	if blocked.has(Vector2i(x, y)):
		return false
	if at(x, y) != null:
		return false
	return true


func place(kind: int, x: int, y: int, dir: int) -> bool:
	if not can_place(kind, x, y):
		return false
	tray[kind] = remaining(kind) - 1
	placements.append({"kind": kind, "x": x, "y": y, "dir": dir & 3})
	return true


func pickup(x: int, y: int) -> bool:
	for index in placements.size():
		var piece: Dictionary = placements[index]
		if int(piece.x) == x and int(piece.y) == y:
			var kind := int(piece.kind)
			tray[kind] = remaining(kind) + 1
			placements.remove_at(index)
			return true
	return false


func rotate_at(x: int, y: int, clockwise: bool = true) -> bool:
	var piece = at(x, y)
	if piece == null:
		return false
	piece.dir = Rules.right(int(piece.dir)) if clockwise else Rules.left(int(piece.dir))
	return true
