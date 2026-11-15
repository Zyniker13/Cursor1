class_name LampPuzzles
extends RefCounted

const Rules = preload("res://rules/rules.gd")

## The east wing: eight puzzles taught in order. Each solution is a list of
## actions the rules accept. Tokens are R L U D, W for wait, and T0 / T1 for lamps.


static func count() -> int:
	return _all().size()


static func get_puzzle(index: int) -> Dictionary:
	return _all()[index]


static func initial_state(index: int) -> Dictionary:
	var puzzle: Dictionary = get_puzzle(index)
	return Rules.build(puzzle["rows"], puzzle["lamps"], puzzle["guards"])


static func parse_solution(spec: String) -> Array:
	var out: Array = []
	for token in spec.split(" ", false):
		match token:
			"R":
				out.append({"type": "move", "dx": 1, "dy": 0})
			"L":
				out.append({"type": "move", "dx": -1, "dy": 0})
			"U":
				out.append({"type": "move", "dx": 0, "dy": -1})
			"D":
				out.append({"type": "move", "dx": 0, "dy": 1})
			"W":
				out.append({"type": "wait"})
			_:
				if token.begins_with("T"):
					out.append({"type": "toggle", "lamp": int(token.substr(1))})
				else:
					push_error("bad solution token " + token)
	return out


static func _lamp(x: int, y: int, facing: String, radius: int) -> Dictionary:
	return {"x": x, "y": y, "facing": facing, "radius": radius, "lit": true}


static func _guard(x: int, y: int, rail: Array, vision: int = 2, rail_index: int = 0, rail_dir: int = 1) -> Dictionary:
	return {
		"x": x,
		"y": y,
		"vision": vision,
		"rail": rail,
		"rail_index": rail_index,
		"rail_dir": rail_dir,
	}


static func _puzzle(number: int, title: String, lesson: String, rows: PackedStringArray, lamps: Array, guards: Array, solution: String) -> Dictionary:
	return {
		"number": number,
		"title": title,
		"lesson": lesson,
		"rows": rows,
		"lamps": lamps,
		"guards": guards,
		"solution": parse_solution(solution),
	}


static func _all() -> Array:
	return [
		_puzzle(
			1,
			"East Cloister",
			"Walk only on dark tiles to the green exit. Lamps light a diamond you cannot enter; guards watch those lit tiles, and snuffing a lamp calls the nearest guard on the next turn.",
			PackedStringArray(["##########", "#S......X#", "##########"]),
			[],
			[],
			"R R R R R R R"
		),
		_puzzle(
			2,
			"The Lamp Hall",
			"Lit floor bars the hall. Stand beside the lamp and press F, or click the lamp, to snuff it.",
			PackedStringArray([
				"##########",
				"#........#",
				"#S......X#",
				"#........#",
				"##########",
			]),
			[_lamp(4, 2, "e", 2)],
			[],
			"R R T0 R R R R R"
		),
		_puzzle(
			3,
			"Summons",
			"Snuffing calls the nearest guard on the next turn. The arrow is the step he will take — leave the row before he walks it.",
			PackedStringArray([
				"##########",
				"#.......##",
				"#S......X#",
				"##########",
			]),
			[_lamp(7, 1, "e", 1)],
			[_guard(1, 1, [Vector2i(1, 1)])],
			"R U R R R R T0 R D R"
		),
		_puzzle(
			4,
			"The Broken Gallery",
			"A gap can be crossed only while its lamp stays lit. Snuff the other lamp and leave the gap's lamp burning.",
			PackedStringArray([
				"############",
				"#S......G.X#",
				"########.###",
				"############",
			]),
			[_lamp(4, 1, "e", 2), _lamp(8, 2, "n", 1)],
			[],
			"R R T0 R R R R R R R"
		),
		_puzzle(
			5,
			"Two Keepers",
			"Two guards. Only the nearest answers a snuff, so step off his path. The other keeps his rail — wait until he has left the crossing.",
			PackedStringArray([
				"############",
				"#S........X#",
				"#.#.###.####",
				"#...###.####",
				"###.########",
				"############",
			]),
			[_lamp(3, 2, "n", 2)],
			[
				_guard(3, 4, [Vector2i(3, 4)]),
				_guard(7, 3, [Vector2i(7, 1), Vector2i(7, 3)], 2, 0, 1),
			],
			"D D R R T0 U U R R R W R R R R"
		),
		_puzzle(
			6,
			"The Kept Flame",
			"The gap opens only while its lamp is lit. Snuff the hall lamp. The pocket beside the gap can snuff the other flame — leave that one burning.",
			PackedStringArray([
				"############",
				"#S......G.X#",
				"#.##.##..###",
				"#....#######",
				"############",
			]),
			[_lamp(4, 2, "n", 2), _lamp(8, 2, "e", 1)],
			[],
			"D D R R R T0 U U R R R R R R"
		),
		_puzzle(
			7,
			"The Arrow",
			"The arrow is the whole clue. It shows the guard's next step before you move. Do not arrive on the tile he is about to take.",
			PackedStringArray([
				"#########",
				"##S...X##",
				"####.####",
				"###..####",
				"###..####",
				"####.####",
				"#########",
			]),
			[_lamp(5, 3, "w", 2)],
			[_guard(4, 2, [Vector2i(4, 1), Vector2i(4, 5)], 2, 0, 1)],
			"W R R R R"
		),
		_puzzle(
			8,
			"The West Door",
			"Snuff the hall lamp, step into the alcove and wait while the called guard passes, then cross the lit gap.",
			PackedStringArray([
				"############",
				"#S.......GX#",
				"###.#####.##",
				"############",
			]),
			[_lamp(2, 1, "e", 1), _lamp(9, 2, "n", 1)],
			[_guard(6, 1, [Vector2i(6, 1)])],
			"T0 R R D W U R R R R R R R"
		),
	]
