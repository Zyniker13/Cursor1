class_name LampPuzzles
extends RefCounted

const Rules = preload("res://rules/rules.gd")

## Thirteen wings of the closed museum. Each solution is a list of actions the rules
## accept. Tokens are R L U D, W for wait, and T0 / T1 for lamps.


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


static func _lamp(x: int, y: int, facing: String, radius: int, lit: bool = true) -> Dictionary:
	return {"x": x, "y": y, "facing": facing, "radius": radius, "lit": lit}


static func _guard(x: int, y: int, rail: Array, vision: int = 2, rail_index: int = 0, rail_dir: int = 1) -> Dictionary:
	return {
		"x": x,
		"y": y,
		"vision": vision,
		"rail": rail,
		"rail_index": rail_index,
		"rail_dir": rail_dir,
	}


static func _puzzle(number: int, title: String, lesson: String, rows: PackedStringArray, lamps: Array, guards: Array, solution: String, wing: String = "East Wing") -> Dictionary:
	var wing_number := number
	if wing == "West Wing":
		wing_number = number - 8
	elif wing == "North Wing":
		wing_number = number - 14
	elif wing == "South Wing":
		wing_number = number - 20
	elif wing == "Attic Wing":
		wing_number = number - 26
	elif wing == "Cellar Wing":
		wing_number = number - 32
	elif wing == "Gallery Wing":
		wing_number = number - 38
	elif wing == "Court Wing":
		wing_number = number - 44
	elif wing == "Nave Wing":
		wing_number = number - 50
	elif wing == "Cloister Wing":
		wing_number = number - 56
	elif wing == "Porch Wing":
		wing_number = number - 62
	elif wing == "Oriel Wing":
		wing_number = number - 68
	elif wing == "Veil Wing":
		wing_number = number - 74
	return {
		"number": number,
		"wing": wing,
		"wing_number": wing_number,
		"title": title,
		"lesson": lesson,
		"rows": rows,
		"lamps": lamps,
		"guards": guards,
		"solution": parse_solution(solution),
	}


static func wings() -> Array:
	var result: Array = []
	var lookup := {}
	var all := _all()
	for i in all.size():
		var name: String = str(all[i]["wing"])
		if not lookup.has(name):
			lookup[name] = result.size()
			result.append({"name": name, "first": i, "count": 0})
		var slot: int = int(lookup[name])
		result[slot]["count"] = int(result[slot]["count"]) + 1
	return result


static func _all() -> Array:
	var puzzles: Array = []
	puzzles.append_array(_east_wing())
	puzzles.append_array(_west_wing())
	puzzles.append_array(_north_wing())
	puzzles.append_array(_south_wing())
	puzzles.append_array(_attic_wing())
	puzzles.append_array(_cellar_wing())
	puzzles.append_array(_gallery_wing())
	puzzles.append_array(_court_wing())
	puzzles.append_array(_nave_wing())
	puzzles.append_array(_cloister_wing())
	puzzles.append_array(_porch_wing())
	puzzles.append_array(_oriel_wing())
	puzzles.append_array(_veil_wing())
	return puzzles


static func _east_wing() -> Array:
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


static func _west_wing() -> Array:
	return [
		_puzzle(
			9,
			"The Lit Door",
			"The exit is locked by light, the same as floor. Cross the gap while its lamp burns, then snuff the lamp on the door and step through. He starts toward that lamp on the next turn.",
			PackedStringArray([
				"##############",
				"#S......G...X#",
				"########.#..##",
				"########.#..##",
				"########....##",
				"##############",
			]),
			[_lamp(8, 2, "n", 1), _lamp(11, 1, "e", 1)],
			[_guard(11, 4, [Vector2i(11, 4)], 2)],
			"R R R R R R R R R T1 R R",
			"West Wing"
		),
		_puzzle(
			10,
			"The Lower Seal",
			"Both keepers stand the same distance from the lamp. A tie goes to the lower number, so only the west keeper answers. Walk the hall. The east keeper never steps down.",
			PackedStringArray([
				"##########",
				"#........#",
				"#S......X#",
				"#........#",
				"##########",
			]),
			[_lamp(4, 2, "e", 1)],
			[
				_guard(2, 3, [Vector2i(2, 3)], 2),
				_guard(6, 1, [Vector2i(6, 1)], 2),
			],
			"R R T0 R R R R R",
			"West Wing"
		),
		_puzzle(
			11,
			"The Broken Sightline",
			"He sees the lit gap through the lamp between you. Snuff that lamp and the dark tiles cut his view. Leave the gap's own lamp burning, then cross.",
			PackedStringArray([
				"##########",
				"#........#",
				"#......###",
				"#S....G.X#",
				"######.###",
				"##########",
			]),
			[_lamp(5, 2, "e", 1), _lamp(6, 4, "n", 1)],
			[_guard(6, 1, [Vector2i(6, 1)], 3)],
			"U R R R T0 R D R R R",
			"West Wing"
		),
		_puzzle(
			12,
			"The Second Wick",
			"Snuff the lamp to walk the floor it lights, then relight it from the side so the gap opens. Lighting a lamp does not call anyone. The guard you already called is still coming.",
			PackedStringArray([
				"##########",
				"#S.......#",
				"#.....####",
				"#......###",
				"#####G####",
				"#####.X###",
				"##########",
			]),
			[_lamp(4, 3, "s", 2)],
			[_guard(8, 1, [Vector2i(8, 1)], 1)],
			"R R R D T0 R D T0 D D R",
			"West Wing"
		),
		_puzzle(
			13,
			"The Cellar Pace",
			"He paces into the cellar and back, so the lit hall never clears. Snuff the lamp: on that turn he still takes the step he owed, then returns to the lamp and holds. Take the dark row.",
			PackedStringArray([
				"##########",
				"#S.......#",
				"#.......X#",
				"####.#####",
				"#........#",
				"##########",
			]),
			[_lamp(2, 2, "e", 2)],
			[_guard(4, 1, [Vector2i(4, 1), Vector2i(4, 4)], 2, 0, 1)],
			"D T0 U R R R R R R R D",
			"West Wing"
		),
		_puzzle(
			14,
			"The Second Call",
			"Snuff the hall lamp and he holds on it, blocking the road. Snuff the lower lamp to call him off. He steps into the left column, so move along the bottom, then take the empty road.",
			PackedStringArray([
				"########",
				"#S######",
				"#.######",
				"#.....X#",
				"#.##.###",
				"#......#",
				"########",
			]),
			[_lamp(2, 3, "e", 1), _lamp(2, 5, "e", 1)],
			[_guard(4, 3, [Vector2i(4, 3)], 2)],
			"D D T0 D D T1 R R R U U R R",
			"West Wing"
		),
	]


static func _north_wing() -> Array:
	return [
		_puzzle(
			15,
			"The Dark Behind",
			"The flame faces the hall, so the tiles in front of it and beside it are lit floor. The single tile behind the lamp stays dark. Snuff it from there. The north gallery is walled off from the door.",
			PackedStringArray([
				"#########",
				"#S......#",
				"#.#######",
				"#......X#",
				"#.#######",
				"#.......#",
				"#########",
			]),
			[_lamp(3, 3, "e", 4)],
			[],
			"D D R T0 R R R R R",
			"North Wing"
		),
		_puzzle(
			16,
			"The Cut Beam",
			"A wall cuts the beam, so the door in front of the lamp is dark even though it sits inside the diamond. He is watching the lit hall. Walk the north gallery and come through the opening the light never reaches.",
			PackedStringArray([
				"############",
				"#S.........#",
				"#..........#",
				"######.#####",
				"#..X.......#",
				"############",
			]),
			[_lamp(2, 2, "s", 3)],
			[_guard(4, 2, [Vector2i(4, 2)])],
			"R R R R R D D D L L L",
			"North Wing"
		),
		_puzzle(
			17,
			"The Cold Wick",
			"This lamp starts cold, and the gap stays shut until you light it. Lighting calls no one. Light it from the tile behind the flame — the square in front of the wick becomes lit under his eyes. The lower walk goes around that light to the gap.",
			PackedStringArray([
				"##########",
				"#S....G.X#",
				"#......#.#",
				"#......#.#",
				"#......#.#",
				"##########",
			]),
			[_lamp(4, 1, "e", 2, false)],
			[_guard(5, 2, [Vector2i(5, 2)], 1)],
			"R R T0 D D D R R R U U U R R",
			"North Wing"
		),
		_puzzle(
			18,
			"The Nearer Keeper",
			"The two keepers are not the same distance from the lamp. The nearer one answers and climbs to it. The keeper under the door is farther, so he never moves. Snuff the lamp and walk on before the near one holds that tile.",
			PackedStringArray([
				"############",
				"#S........X#",
				"#..........#",
				"####..######",
				"#..........#",
				"#..........#",
				"############",
			]),
			[_lamp(4, 2, "e", 2)],
			[
				_guard(4, 4, [Vector2i(4, 4)]),
				_guard(10, 4, [Vector2i(10, 4)]),
			],
			"R R D T0 R R R R R R R U",
			"North Wing"
		),
		_puzzle(
			19,
			"The Far Watch",
			"The gap is lit, and he is watching it. Leave the lamp above the gap burning. Snuff the west wick to call him — his next step is your tile, so step aside. When he holds on that wick, cross the gap.",
			PackedStringArray([
				"###########",
				"#S...#....#",
				"#...#.....#",
				"#....G...X#",
				"#....#....#",
				"#....#....#",
				"###########",
			]),
			[_lamp(2, 3, "w", 1), _lamp(5, 2, "s", 1)],
			[_guard(4, 3, [Vector2i(4, 3)])],
			"R R D D T0 D R U R R R R R",
			"North Wing"
		),
		_puzzle(
			20,
			"The Closing Door",
			"The lamp stands on the door, so the door is lit and he is watching it. Snuff it from the dark tile behind the flame. His next step is onto that door. Take it before he does. If you wait, he holds the exit.",
			PackedStringArray([
				"#######",
				"#S....#",
				"#...X.#",
				"#.....#",
				"#######",
			]),
			[_lamp(4, 2, "e", 1)],
			[_guard(4, 3, [Vector2i(4, 3)])],
			"D R R T0 R",
			"North Wing"
		),
	]


static func _south_wing() -> Array:
	return [
		_puzzle(
			21,
			"The Dark Half",
			"The lamp faces north, so the whole south side of its diamond stays dark, not only the single tile behind the flame. The door sits in the lit half, and he is watching the lamp itself. Snuff it from the south. Cross that tile and take the door before he holds it.",
			PackedStringArray([
				"###########",
				"#.........#",
				"#.........#",
				"#........X#",
				"#S........#",
				"###########",
			]),
			[_lamp(5, 3, "n", 4)],
			[_guard(5, 1, [Vector2i(5, 1)])],
			"R R R R T0 U R R R R",
			"South Wing"
		),
		_puzzle(
			22,
			"The Passing Watch",
			"The gap stays lit. He walks from the far end of his route to the near end, and only the near end puts the gap in his eyes. Step up beside it and wait while he stands there. Cross after he turns back. Step onto the gap while he is on the near end and that is a loss.",
			PackedStringArray([
				"###########",
				"#S..G...X.#",
				"#.........#",
				"###.....###",
				"###########",
			]),
			[_lamp(4, 2, "n", 1)],
			[_guard(6, 3, [Vector2i(4, 3), Vector2i(6, 3)])],
			"R R W R R R R R",
			"South Wing"
		),
		_puzzle(
			23,
			"The Owed Step",
			"He is walking the dark column toward the lamp. Snuff it while his owed step still falls short of you. That step is not replaced by the call. The arrow then points at your tile, so leave it and take the door. Wait first, and the owed step lands on you.",
			PackedStringArray([
				"#########",
				"#.......#",
				"##S...X.#",
				"#.......#",
				"#.......#",
				"#.......#",
				"#########",
			]),
			[_lamp(4, 2, "e", 2)],
			[_guard(3, 5, [Vector2i(3, 1), Vector2i(3, 5)])],
			"R T0 R R R",
			"South Wing"
		),
		_puzzle(
			24,
			"The Fading Watch",
			"He sees the lamp's square and not the rest of the hall. That square is a loss. The door is lit too, but he is not watching it, and lit floor is still closed. Snuff the lamp from the dark side and walk the hall. He climbs to the lamp and holds behind you.",
			PackedStringArray([
				"##########",
				"#S......X#",
				"####.#####",
				"####.#####",
				"####.#####",
				"##########",
			]),
			[_lamp(4, 1, "e", 4)],
			[_guard(4, 4, [Vector2i(4, 4)], 3)],
			"R R T0 R R R R R",
			"South Wing"
		),
		_puzzle(
			25,
			"The Covered Flame",
			"The tile behind the door lamp is lit by the hall lamp, so you cannot touch the door until the hall is dark. Snuff the hall and walk through before the keeper holds that square. Then snuff the door. The second snuff calls him toward it. Take the dark door before he arrives.",
			PackedStringArray([
				"###########",
				"#S......X.#",
				"###.#######",
				"#.........#",
				"###########",
			]),
			[_lamp(3, 1, "e", 2), _lamp(6, 1, "e", 2)],
			[_guard(3, 3, [Vector2i(3, 3)])],
			"R T0 R R R T1 R R R",
			"South Wing"
		),
		_puzzle(
			26,
			"The Far Answer",
			"Two lamps, two keepers. The gap lamp is closer to the keeper by the door, so leave it burning and he never moves. The hall lamp is closer to the far keeper. Snuff that one, walk the hall he is about to hold, and cross the gap.",
			PackedStringArray([
				"############",
				"#S......G.X#",
				"#..........#",
				"#..........#",
				"############",
			]),
			[_lamp(4, 1, "e", 2), _lamp(8, 2, "n", 1)],
			[
				_guard(4, 3, [Vector2i(4, 3)]),
				_guard(10, 3, [Vector2i(10, 3)]),
			],
			"R R T0 R R R R R R R",
			"South Wing"
		),
	]


static func _attic_wing() -> Array:
	return [
		_puzzle(
			27,
			"The Unlit Watch",
			"This room is about the rule that a guard watches only lit tiles. His reach crosses the dark hall, and that floor is safe. The lit square in the doorway is in his eyes. Step onto it and you lose.",
			PackedStringArray([
				"###########",
				"#S.......X#",
				"#.........#",
				"####.######",
				"#.........#",
				"#.........#",
				"###########",
			]),
			[_lamp(4, 4, "n", 2)],
			[_guard(4, 5, [Vector2i(4, 5)], 5)],
			"R R R R R R R R",
			"Attic Wing"
		),
		_puzzle(
			28,
			"The Blind Wall",
			"This room is about the rule that walls block vision. He stands on the lamp, and the lit near side of the wall is in his eyes. The gap beyond that wall is lit and inside his reach, but the wall cuts his sight. Snuff the lamp from the dark square beside him and cross. Step into the near light and you lose.",
			PackedStringArray([
				"############",
				"#S..#..#####",
				"#...#..#####",
				"#...#.GX####",
				"#...#..#####",
				"#...#..#####",
				"#..........#",
				"############",
			]),
			[_lamp(2, 3, "e", 3), _lamp(6, 2, "s", 1)],
			[_guard(2, 3, [Vector2i(2, 3)], 6)],
			"D D T0 D R R D D R R U U U R R",
			"Attic Wing"
		),
		_puzzle(
			29,
			"The Barred Gap",
			"This room is about the rule that a called guard cannot cross a gap. Snuff the hall lamp. The short road to it is the gap, so he takes the long floor around. Cross while the gap is still outside his eyes. Wait, and he comes close enough to watch it.",
			PackedStringArray([
				"#############",
				"#S....G....X#",
				"##.###.#.##.#",
				"#...........#",
				"#...........#",
				"#...........#",
				"#############",
			]),
			[_lamp(4, 1, "e", 1), _lamp(6, 2, "n", 1)],
			[_guard(10, 4, [Vector2i(10, 4)], 2)],
			"R R T0 R R R R R R R R",
			"Attic Wing"
		),
		_puzzle(
			30,
			"The North Step",
			"This room is about the rule that a called guard breaks ties north, then east, then south, then west. The lamp is northwest of him. North and west are the same length, and the arrow goes north. Snuff it and take the hall. The lit square south of him is watched.",
			PackedStringArray([
				"#########",
				"#S......#",
				"#.......#",
				"#.......#",
				"#......X#",
				"#.......#",
				"#########",
			]),
			[_lamp(2, 2, "e", 1), _lamp(4, 5, "e", 1)],
			[_guard(4, 4, [Vector2i(4, 4)], 3)],
			"D T0 R R D R R R R D",
			"Attic Wing"
		),
		_puzzle(
			31,
			"The Dark Eye",
			"This room is about the rule that a guard standing in the dark can still look into an adjacent lit tile. His own square stays dark. The lit square up the hall is a loss. Snuff the lamp from the dark tile behind the flame, then walk through before he holds it.",
			PackedStringArray([
				"###########",
				"#S........#",
				"#.......X.#",
				"#.........#",
				"###########",
			]),
			[_lamp(4, 2, "e", 2)],
			[_guard(3, 3, [Vector2i(3, 3)], 3)],
			"R R D T0 R R R R R",
			"Attic Wing"
		),
		_puzzle(
			32,
			"The Early Threshold",
			"This room is about the rule that reaching the exit wins before the guards move. He is two steps from the door, and so are you. Take it and you are out before his step lands. The lit square south of you is in his eyes.",
			PackedStringArray([
				"#######",
				"#..S.X#",
				"#.....#",
				"#.....#",
				"#######",
			]),
			[_lamp(3, 3, "n", 1)],
			[_guard(5, 3, [Vector2i(5, 1), Vector2i(5, 3)], 3)],
			"R R",
			"Attic Wing"
		),
	]


static func _cellar_wing() -> Array:
	return [
		_puzzle(
			33,
			"The Open Corner",
			"This room is about the rule that a lit lamp fills a Manhattan diamond. The door sits on the lamp's diagonal, outside that diamond, so it stays dark. The square south of the lamp is lit, and he is watching it.",
			PackedStringArray([
				"#########",
				"#S...X..#",
				"#.......#",
				"#.......#",
				"#.......#",
				"#########",
			]),
			[_lamp(4, 2, "e", 1)],
			[_guard(5, 3, [Vector2i(5, 3)], 2)],
			"D D D R R R R R U U U L",
			"Cellar Wing"
		),
		_puzzle(
			34,
			"The Brick Shade",
			"This room is about the rule that walls block light. The door sits inside the lamp's diamond, and the wall between them keeps it dark. Walk the dark row under that wall. The lit square west of the keeper is in his eyes.",
			PackedStringArray([
				"############",
				"#S...#.....#",
				"#...#.X....#",
				"#....#.....#",
				"#....#.....#",
				"#....#.....#",
				"#..........#",
				"############",
			]),
			[_lamp(3, 2, "e", 3)],
			[_guard(4, 1, [Vector2i(4, 1)], 2)],
			"D D D D D R R R R R U U U U",
			"Cellar Wing"
		),
		_puzzle(
			35,
			"The Quiet Wick",
			"This room is about the rule that lighting a lamp does not call a guard. The gap is dark until you light the wick from the square beside it. He stays where he stands. The lit square north of the gap is in his eyes.",
			PackedStringArray([
				"############",
				"#..........#",
				"#..........#",
				"#S.........#",
				"#.....G..X.#",
				"#..........#",
				"############",
			]),
			[_lamp(5, 3, "e", 2, false)],
			[_guard(7, 2, [Vector2i(7, 2)], 2)],
			"R R R R D T0 R R R R",
			"Cellar Wing"
		),
		_puzzle(
			36,
			"The Earlier Keeper",
			"This room is about the rule that a distance tie calls the lower number. Both keepers stand the same distance from the lamp. The south keeper answers and climbs to it. The east keeper never moves. The lit square beside the south keeper is a loss.",
			PackedStringArray([
				"############",
				"#S.........#",
				"#..........#",
				"#.........X#",
				"#..........#",
				"#..........#",
				"############",
			]),
			[_lamp(6, 2, "e", 2)],
			[
				_guard(6, 5, [Vector2i(6, 5)], 2),
				_guard(8, 3, [Vector2i(8, 3)], 2),
			],
			"R R R R D T0 R R R R R D",
			"Cellar Wing"
		),
		_puzzle(
			37,
			"The Dim Lane",
			"This room is about the rule that dark tiles block vision. The gap is lit and inside his reach. The dark square between him and the gap cuts his sight, so you can cross. The lit square beside him is a loss.",
			PackedStringArray([
				"#########",
				"#....X..#",
				"#S...G..#",
				"#.......#",
				"#.......#",
				"#########",
			]),
			[_lamp(6, 2, "w", 1), _lamp(4, 4, "w", 1)],
			[_guard(3, 3, [Vector2i(3, 3)], 3)],
			"R R R R U",
			"Cellar Wing"
		),
		_puzzle(
			38,
			"The Still Post",
			"This room is about the rule that a called guard holds on the lamp and does not resume his rail. He watches the gap from both ends of his walk. Snuff the west wick and wait. He leaves the walk and holds on that wick. Cross the gap, which stays lit. Step onto it while he is still on the walk and you lose.",
			PackedStringArray([
				"#############",
				"#S........###",
				"#........G.X#",
				"#.........###",
				"#...........#",
				"#...........#",
				"#############",
			]),
			[_lamp(2, 4, "e", 1), _lamp(9, 3, "n", 1)],
			[_guard(8, 3, [Vector2i(8, 3), Vector2i(8, 4)], 3)],
			"D D D T0 W W W W W W W U U U R R R R R R R R D R R",
			"Cellar Wing"
		),
	]


static func _gallery_wing() -> Array:
	return [
		_puzzle(
			39,
			"The Rear Shade",
			"This room is about the rule that the tile directly behind the lamp stays dark. The flame faces east, so the hall in front of it and the squares beside it are lit. Stand on the one dark square behind the flame and snuff it, then take the north door. The lit square south of that flame is in his eyes.",
			PackedStringArray([
				"###########",
				"#S......X.#",
				"#.........#",
				"#.........#",
				"#.........#",
				"###########",
			]),
			[_lamp(5, 2, "e", 2)],
			[_guard(6, 4, [Vector2i(6, 4)], 2)],
			"R R R D T0 U R R R R",
			"Gallery Wing"
		),
		_puzzle(
			40,
			"The Late Call",
			"This room is about the rule that snuffing calls the nearest guard toward that lamp on the next turn. He does not move on the snuff itself. His next step is the square you are standing on, so leave it and take the door. The far keeper is farther from the lamp, and he never starts. The door is lit and watched until you snuff.",
			PackedStringArray([
				"############",
				"#S.........#",
				"#..........#",
				"#......X...#",
				"#..........#",
				"############",
			]),
			[_lamp(8, 3, "w", 1)],
			[
				_guard(9, 4, [Vector2i(9, 4)], 3),
				_guard(1, 4, [Vector2i(1, 4)], 2),
			],
			"R R R R R R R R D D T0 L L",
			"Gallery Wing"
		),
		_puzzle(
			41,
			"The Closed Hall",
			"This room is about the rule that lit floor that no guard is watching is refused. The hall to the door is lit, and he cannot see it, so the step is closed rather than a loss. Snuff the hall from the dark square behind the flame and walk through. The lit square in the lower room is in his eyes.",
			PackedStringArray([
				"############",
				"#S........X#",
				"##.#########",
				"#..........#",
				"#..........#",
				"############",
			]),
			[_lamp(3, 1, "e", 7), _lamp(7, 4, "w", 1)],
			[_guard(8, 4, [Vector2i(8, 4)], 2)],
			"R T0 R R R R R R R R",
			"Gallery Wing"
		),
		_puzzle(
			42,
			"The Lit Crossing",
			"This room is about the rule that a gap may be entered only while it is lit. The gap starts dark. Light the wick beside it — lighting calls no one — and cross. Leave the lower lamp burning. The lit square west of that keeper is a loss.",
			PackedStringArray([
				"############",
				"#S.........#",
				"#.....G....#",
				"#........X.#",
				"#..........#",
				"############",
			]),
			[_lamp(5, 2, "e", 1, false), _lamp(8, 4, "n", 1)],
			[_guard(9, 4, [Vector2i(9, 4)], 2)],
			"R R R R D D T0 R U U R R R D D",
			"Gallery Wing"
		),
		_puzzle(
			43,
			"The Keeper's Square",
			"This room is about the rule that sharing a tile with a guard is a loss. He stands on a dark square, and that square is not watched. Step onto him and you lose. Walk the south row around him to the door. The lit square south of him is in his eyes.",
			PackedStringArray([
				"###########",
				"#S......X.#",
				"#.........#",
				"#.........#",
				"###########",
			]),
			[_lamp(5, 2, "n", 1)],
			[_guard(4, 1, [Vector2i(4, 1)], 2)],
			"D D R R R R R R R U U",
			"Gallery Wing"
		),
		_puzzle(
			44,
			"The Outer Ring",
			"This room is about the rule that each guard watches a Manhattan diamond of their vision radius. The square beside him is inside that diamond and lit, so it is a loss. The door is lit too, but it sits outside his vision, so the floor is closed until you snuff the lamp. Snuff it from behind the flame and take the north row.",
			PackedStringArray([
				"##########",
				"#S.......#",
				"#......X.#",
				"#........#",
				"#........#",
				"##########",
			]),
			[_lamp(5, 2, "e", 2)],
			[_guard(5, 3, [Vector2i(5, 3)], 1)],
			"D R R R T0 U R R R D",
			"Gallery Wing"
		),
	]


static func _court_wing() -> Array:
	return [
		_puzzle(
			45,
			"The First Plate",
			"This room is about the rule that the turn you step onto a plate calls the nearest guard. He takes that step on the next turn, then walks to the plate and holds, and the arrow shows the tile beforehand. A plate is floor you may enter while it is dark; a lit plate stays closed. Step on the plate and leave the square he is about to take. Stay, and he steps onto you.",
			PackedStringArray([
				"######",
				"#S####",
				"#.PX.#",
				"#....#",
				"#....#",
				"######",
			]),
			[_lamp(1, 4, "e", 1)],
			[_guard(2, 3, [Vector2i(2, 3)], 2)],
			"D R R",
			"Court Wing"
		),
		_puzzle(
			46,
			"The Quiet Wait",
			"This room is about the rule that waiting on a plate does not call the guard a second time. Step on the plate, wait once, then leave for the door. Step off and back on, and that second call catches the square you return through.",
			PackedStringArray([
				"##########",
				"#X..P...S#",
				"###......#",
				"#........#",
				"##########",
			]),
			[_lamp(8, 3, "s", 1)],
			[_guard(6, 3, [Vector2i(6, 3)], 2)],
			"L L L L W L L L",
			"Court Wing"
		),
		_puzzle(
			47,
			"The Far Keeper",
			"This room is about the rule that a plate calls the nearer guard. Distance is Manhattan, and the lowest number would win a tie. The far keeper does not move. The lit square in the lower room is in the near keeper's eyes.",
			PackedStringArray([
				"##############",
				"#S.P........X#",
				"#............#",
				"#............#",
				"##############",
			]),
			[_lamp(2, 3, "s", 1)],
			[
				_guard(12, 2, [Vector2i(12, 2)], 2),
				_guard(2, 2, [Vector2i(2, 2)], 2),
			],
			"R R R R R R R R R R R",
			"Court Wing"
		),
		_puzzle(
			48,
			"The Lit Plate",
			"This room is about the rule that a lit plate is refused until the lamp covering it is snuffed. The snuff calls the keeper. The later step onto the dark plate calls him again. Crossing while the plate is still lit is refused. The lit square in the lower east is in his eyes.",
			PackedStringArray([
				"############",
				"#S.P....X###",
				"#.#.######.#",
				"#..........#",
				"############",
			]),
			[_lamp(3, 2, "n", 1), _lamp(10, 3, "e", 0)],
			[_guard(10, 2, [Vector2i(10, 2)], 2)],
			"D D R R T0 U U R R R R R",
			"Court Wing"
		),
		_puzzle(
			49,
			"The Plate Gap",
			"This room is about the rule that stepping on a plate calls the nearest guard toward that plate. The gap beyond stays lit. Step on the plate and he leaves the gap, then cross while its lamp is still burning. Cross while he is still watching and you lose.",
			PackedStringArray([
				"##########",
				"#S....G.X#",
				"#..P.....#",
				"#........#",
				"##########",
			]),
			[_lamp(6, 2, "n", 1)],
			[_guard(6, 2, [Vector2i(6, 2)], 1)],
			"R R D U R R R R R",
			"Court Wing"
		),
		_puzzle(
			50,
			"The Last Hold",
			"This room is about the rule that a called guard walks to the plate and holds. He does not resume his rail. Step off the plate and wait until he holds, then cross the lit gap to the exit his rail used to cover. If he resumed the rail, that gap would be watched.",
			PackedStringArray([
				"#############",
				"#S........###",
				"#........G.X#",
				"#.........###",
				"#.P.........#",
				"#...........#",
				"#############",
			]),
			[_lamp(9, 3, "n", 1)],
			[_guard(8, 3, [Vector2i(8, 3), Vector2i(8, 4)], 3)],
			"D D D R L W W W W W W U U R R R R R R R R R R",
			"Court Wing"
		),
	]


static func _nave_wing() -> Array:
	return [
		_puzzle(
			51,
			"The First Bell",
			"This room is about the rule that the turn you step onto a bell calls every guard who can reach it toward that bell, each takes the arrow step on the next turn and then holds there, and you leave the square the nearest one is about to take.",
			PackedStringArray([
				"######",
				"#S####",
				"#.BX.#",
				"#....#",
				"#....#",
				"######",
			]),
			[_lamp(1, 4, "e", 1)],
			[
				_guard(2, 3, [Vector2i(2, 3)], 2),
				_guard(4, 4, [Vector2i(4, 4)], 2),
			],
			"D R R",
			"Nave Wing"
		),
		_puzzle(
			52,
			"The Quiet Bell",
			"This room is about the rule that waiting on a bell does not call the guards a second time. Step on the bell, wait once, then leave for the door. Step off and back on, and that second ring catches the square you return through.",
			PackedStringArray([
				"##########",
				"#X..B...S#",
				"###......#",
				"#........#",
				"##########",
			]),
			[_lamp(8, 3, "s", 1)],
			[_guard(6, 3, [Vector2i(6, 3)], 2)],
			"L L L L W L L L",
			"Nave Wing"
		),
		_puzzle(
			53,
			"The Far Bell",
			"This room is about the rule that a bell calls every keeper, including the far one. Distance would have mattered for a plate, which calls only the nearer guard. Both keepers answer the bell. The lit square beside the lamp is in the near keeper's eyes.",
			PackedStringArray([
				"##############",
				"#S.B........X#",
				"#....#########",
				"#............#",
				"##############",
			]),
			[_lamp(1, 2, "s", 1)],
			[
				_guard(3, 2, [Vector2i(3, 2)], 2),
				_guard(12, 3, [Vector2i(12, 3)], 2),
			],
			"R R R R R R R R R R R",
			"Nave Wing"
		),
		_puzzle(
			54,
			"The Lit Bell",
			"This room is about the rule that a lit bell is refused until the lamp covering it is snuffed. The snuff calls only the nearest guard. The later step onto the dark bell calls every guard. Crossing while the bell is still lit is refused.",
			PackedStringArray([
				"############",
				"#S.B....X###",
				"#.#.######.#",
				"#..........#",
				"##.........#",
				"############",
			]),
			[_lamp(3, 2, "n", 1), _lamp(10, 3, "e", 0)],
			[
				_guard(4, 4, [Vector2i(4, 4)], 2),
				_guard(10, 2, [Vector2i(10, 2)], 2),
			],
			"D D R R T0 U U R R R R R",
			"Nave Wing"
		),
		_puzzle(
			55,
			"The Bell Gap",
			"This room is about the rule that stepping on a bell calls every guard toward that bell. The gap beyond stays lit. Step on the bell and the keepers leave it, then cross while its lamp is still burning. Cross while they are still watching and you lose.",
			PackedStringArray([
				"###########",
				"#S....G..X#",
				"#..B......#",
				"#.........#",
				"###########",
			]),
			[_lamp(6, 2, "n", 1)],
			[
				_guard(6, 2, [Vector2i(6, 2)], 1),
				_guard(7, 1, [Vector2i(7, 1)], 1),
			],
			"R R D U R R R R R R",
			"Nave Wing"
		),
		_puzzle(
			56,
			"The Last Ring",
			"This room is about the rule that called guards walk to the bell and hold. They do not resume their rails. Step off the bell and wait until both hold, then cross the lit gap to the exit their rails used to cover. If either resumed his rail, that gap would be watched.",
			PackedStringArray([
				"#############",
				"#S........###",
				"#........G.X#",
				"#.........###",
				"#.B.........#",
				"#...........#",
				"#############",
			]),
			[_lamp(9, 3, "n", 1)],
			[
				_guard(8, 3, [Vector2i(8, 3), Vector2i(8, 4)], 3),
				_guard(9, 3, [Vector2i(9, 3), Vector2i(9, 4)], 3),
			],
			"D D D R L W W W W W W W U U R R R R R R R R R R",
			"Nave Wing"
		),
	]


static func _cloister_wing() -> Array:
	return [
		_puzzle(
			57,
			"The First Grate",
			"This room is about the rule that a grate is floor you may enter and it stays dark even when a lamp covers its tile, so you cross the lit hall on the grate and leave the square the keeper is about to take.",
			PackedStringArray([
				"#########",
				"#.SRRR.X#",
				"#.......#",
				"#.......#",
				"#########",
			]),
			[_lamp(4, 2, "n", 2)],
			[_guard(2, 2, [Vector2i(2, 2), Vector2i(2, 1)], 2)],
			"R R R R R",
			"Cloister Wing"
		),
		_puzzle(
			58,
			"The Passed Light",
			"This room is about the rule that light does not stop at a grate and still lights the door beyond it. The grate itself stays dark. That door stays closed until you snuff it.",
			PackedStringArray([
				"############",
				"#...########",
				"#S.R......X#",
				"############",
			]),
			[_lamp(2, 2, "e", 8)],
			[_guard(3, 1, [Vector2i(3, 1)], 2)],
			"T0 R R R R R R R R R",
			"Cloister Wing"
		),
		_puzzle(
			59,
			"The Dark Cut",
			"This room is about the rule that a dark grate blocks a guard's sight the same way dark floor does. The lit gap beyond the grate is not in his eyes, so you cross it without snuffing, but the gap still has to be lit to enter.",
			PackedStringArray([
				"###########",
				"#S..RRG.X.#",
				"#.###.#####",
				"#.........#",
				"###########",
			]),
			[_lamp(5, 3, "n", 3)],
			[_guard(5, 2, [Vector2i(5, 2)], 4)],
			"R R R R R R R",
			"Cloister Wing"
		),
		_puzzle(
			60,
			"The Long Road",
			"This room is about the rule that a called guard cannot enter a grate, so he takes the longer floor road. You cross the grate before he arrives.",
			PackedStringArray([
				"#############",
				"#S....R....X#",
				"##.###.#.##.#",
				"#...........#",
				"#...........#",
				"#...........#",
				"#############",
			]),
			[_lamp(4, 1, "e", 1), _lamp(9, 4, "w", 1)],
			[_guard(10, 4, [Vector2i(10, 4)], 2)],
			"R R T0 R R R R R R R R",
			"Cloister Wing"
		),
		_puzzle(
			61,
			"The Lit Edge",
			"This room is about the rule that a lit floor tile beside a grate is still refused. The grate itself is enterable. Snuff the edge, then leave.",
			PackedStringArray([
				"##########",
				"#S..R...X#",
				"##.#######",
				"#........#",
				"##########",
			]),
			[_lamp(5, 1, "w", 1), _lamp(5, 3, "w", 1)],
			[_guard(6, 3, [Vector2i(6, 3)], 3)],
			"R R R T0 R R R R",
			"Cloister Wing"
		),
		_puzzle(
			62,
			"The Last Grate",
			"This room is about the rule that a called guard's road treats a grate as closed. Cross the grates, then the lit gap, once his road around the grate has taken him off the door.",
			PackedStringArray([
				"#############",
				"#S...RR...GX#",
				"##.###.#.##.#",
				"#...........#",
				"#...........#",
				"#...........#",
				"#############",
			]),
			[_lamp(4, 1, "e", 1), _lamp(10, 2, "e", 1)],
			[_guard(10, 2, [Vector2i(10, 2)], 1)],
			"R R T0 R R R R R R R R",
			"Cloister Wing"
		),
	]


static func _porch_wing() -> Array:
	return [
		_puzzle(
			63,
			"The First Sill",
			"This room is about the rule that a sill under a lamp is lit and refused until you snuff it, so you cross, and the tile past that sill was already dark.",
			PackedStringArray([
				"############",
				"#S..I.....X#",
				"#.##########",
				"#I.........#",
				"#..........#",
				"############",
			]),
			[_lamp(3, 1, "e", 6), _lamp(1, 4, "n", 1)],
			[_guard(2, 4, [Vector2i(2, 4)], 2)],
			"R T0 R R R R R R R R",
			"Porch Wing"
		),
		_puzzle(
			64,
			"The Stopped Light",
			"This room is about the rule that light stops at a sill, so the door beyond it stays dark and can be entered. A grate in that cell would light the door.",
			PackedStringArray([
				"###########",
				"#S..X.....#",
				"#..#I.....#",
				"#.........#",
				"#.......I.#",
				"###########",
			]),
			[_lamp(4, 3, "n", 2), _lamp(8, 3, "s", 1)],
			[_guard(9, 4, [Vector2i(9, 4)], 2)],
			"R R R",
			"Porch Wing"
		),
		_puzzle(
			65,
			"The Seen Gap",
			"This room is about the rule that a sill does not hide the lit gap beside it, so the guard still sees that gap. Snuff the lamp in his sight and cross while the gap stays lit.",
			PackedStringArray([
				"###########",
				"#.........#",
				"#......####",
				"#S....GI.X#",
				"#.####.#.##",
				"#I........#",
				"###########",
			]),
			[_lamp(5, 2, "e", 3), _lamp(6, 4, "n", 1), _lamp(2, 5, "w", 1)],
			[_guard(6, 1, [Vector2i(6, 1)], 4), _guard(3, 5, [Vector2i(3, 5)], 2)],
			"U R R R T0 R D R R R R",
			"Porch Wing"
		),
		_puzzle(
			66,
			"The Closed Walk",
			"This room is about the rule that a called guard cannot enter a sill, so he takes the longer floor road, and you cross before he arrives.",
			PackedStringArray([
				"#############",
				"#S....I....X#",
				"##.###.#.##.#",
				"#...........#",
				"#.......I...#",
				"#...........#",
				"#############",
			]),
			[_lamp(4, 1, "e", 1), _lamp(9, 4, "w", 1)],
			[_guard(10, 4, [Vector2i(10, 4)], 2)],
			"R R T0 R R R R R R R R",
			"Porch Wing"
		),
		_puzzle(
			67,
			"The Dark Past",
			"This room is about the rule that the tile past a sill stays dark even under the lamp's reach, and the lit sill itself is refused until it is snuffed.",
			PackedStringArray([
				"##############",
				"#S..I........#",
				"#I#########.##",
				"#...........X#",
				"##############",
			]),
			[_lamp(3, 1, "e", 8), _lamp(1, 3, "n", 1)],
			[_guard(2, 3, [Vector2i(2, 3)], 2)],
			"R T0 R R R R R R R R R D D R",
			"Porch Wing"
		),
		_puzzle(
			68,
			"The Last Sill",
			"This room is about the rule that a snuffed sill can be crossed once it is dark, and the door beyond stays dark because the light stopped.",
			PackedStringArray([
				"############",
				"#S..I.X....#",
				"#I##########",
				"#..........#",
				"############",
			]),
			[_lamp(3, 1, "e", 4), _lamp(1, 3, "n", 1)],
			[_guard(2, 3, [Vector2i(2, 3)], 2)],
			"R T0 R R R R",
			"Porch Wing"
		),
	]


static func _oriel_wing() -> Array:
	return [
		_puzzle(
			69,
			"The First Pane",
			"This room is about the rule that a pane lets the lamp light the gap beyond it, and you cannot step on the pane.",
			PackedStringArray([
				"#############",
				"#S..G......X#",
				"#..#A#......#",
				"#...........#",
				"#...........#",
				"#############",
			]),
			[_lamp(4, 3, "n", 2), _lamp(9, 4, "n", 1)],
			[_guard(9, 4, [Vector2i(9, 4)], 2)],
			"R R R R R R R R R R",
			"Oriel Wing"
		),
		_puzzle(
			70,
			"The Seen Room",
			"This room is about the rule that a guard sees the lit floor beyond a pane, so that floor is watched. Snuff the lamp, then cross the floor the pane had left lit.",
			PackedStringArray([
				"##############",
				"#............#",
				"#.S.A.......X#",
				"#............#",
				"#............#",
				"#............#",
				"##############",
			]),
			[_lamp(3, 2, "e", 2)],
			[_guard(4, 1, [Vector2i(4, 1)], 2)],
			"T0 D R R R U R R R R R R R",
			"Oriel Wing"
		),
		_puzzle(
			71,
			"The Closed Sheet",
			"This room is about the rule that a called guard cannot step on a pane, so he takes the longer floor road, and you cross before he arrives.",
			PackedStringArray([
				"#########",
				"#S..G..X#",
				"#...A...#",
				"#.#...#.#",
				"#.......#",
				"#########",
			]),
			[_lamp(2, 2, "e", 1), _lamp(4, 3, "n", 2)],
			[_guard(5, 2, [Vector2i(5, 2)], 2)],
			"D T0 R L R U R R R R R",
			"Oriel Wing"
		),
		_puzzle(
			72,
			"The Dark Beside",
			"This room is about the rule that the tile beside a pane stays dark when the lamp does not reach it, and the tile past the pane is lit because the pane lets the light through.",
			PackedStringArray([
				"###########",
				"#.........#",
				"#.S.......#",
				"#..A......#",
				"#..G.....X#",
				"#.........#",
				"###########",
			]),
			[_lamp(3, 2, "e", 2), _lamp(8, 1, "w", 1)],
			[_guard(9, 1, [Vector2i(9, 1)], 2)],
			"D D R R R R R R R",
			"Oriel Wing"
		),
		_puzzle(
			73,
			"The Long Sight",
			"This room is about the rule that a guard sees through a pane onto a lit gap, so the gap is watched until you snuff it and light it again.",
			PackedStringArray([
				"###########",
				"#...G....X#",
				"#...A######",
				"#.........#",
				"#.........#",
				"#...S.....#",
				"###########",
			]),
			[_lamp(4, 4, "n", 3), _lamp(4, 3, "e", 2, false)],
			[_guard(4, 3, [Vector2i(4, 3)], 2)],
			"T0 L U U T1 U U R R R R R R",
			"Oriel Wing"
		),
		_puzzle(
			74,
			"The Last Pane",
			"This room is about the rule that you leave by the gap a pane left lit, and you never step on the pane.",
			PackedStringArray([
				"###########",
				"#S..G....X#",
				"#...A######",
				"#.........#",
				"#.........#",
				"#.........#",
				"###########",
			]),
			[_lamp(4, 4, "n", 3), _lamp(1, 2, "s", 1)],
			[_guard(4, 3, [Vector2i(4, 3)], 2)],
			"T1 R R W R R R R R R",
			"Oriel Wing"
		),
	]


static func _veil_wing() -> Array:
	return [
		_puzzle(
			75,
			"The First Cloth",
			"This room is about the rule that a curtain lets the lamp light the gap beyond and stops the guard's sight.",
			PackedStringArray([
				"########",
				"#S.G..X#",
				"###C####",
				"#......#",
				"#......#",
				"########",
			]),
			[_lamp(3, 3, "n", 2)],
			[_guard(3, 4, [Vector2i(3, 4)], 3)],
			"R R R R R",
			"Veil Wing"
		),
		_puzzle(
			76,
			"The Seen Cloth",
			"This room is about the rule that the curtain cell itself is lit, so snuff before you step onto it.",
			PackedStringArray([
				"########",
				"#.SC..X#",
				"#......#",
				"#......#",
				"########",
			]),
			[_lamp(3, 2, "n", 1)],
			[_guard(5, 2, [Vector2i(5, 2)], 3)],
			"L D D R R T0 U U R R R",
			"Veil Wing"
		),
		_puzzle(
			77,
			"The Short Road",
			"This room is about the rule that the called guard's shortest floor path goes through the curtain.",
			PackedStringArray([
				"########",
				"#......#",
				"#.####.#",
				"#.#.S..#",
				"#.#C...#",
				"#.#.G..#",
				"#...X..#",
				"########",
			]),
			[_lamp(3, 3, "w", 0), _lamp(3, 5, "n", 1)],
			[_guard(3, 6, [Vector2i(3, 6)], 4)],
			"T0 W W W W W W D D D",
			"Veil Wing"
		),
		_puzzle(
			78,
			"The Dark Beside",
			"This room is about the rule that the tile beside the curtain stays dark and the tile past it is lit.",
			PackedStringArray([
				"########",
				"#......#",
				"#.S....#",
				"#..C...#",
				"#..G..X#",
				"########",
			]),
			[_lamp(3, 2, "e", 2)],
			[_guard(3, 1, [Vector2i(3, 1)], 3)],
			"D D R R R R",
			"Veil Wing"
		),
		_puzzle(
			79,
			"The Second Lamp",
			"This room is about the rule that the room keeps its second lamp and that light has to pass the curtain.",
			PackedStringArray([
				"########",
				"#X.G...#",
				"###C...#",
				"#..S...#",
				"#......#",
				"#......#",
				"########",
			]),
			[_lamp(5, 2, "n", 2), _lamp(3, 3, "n", 2, false)],
			[_guard(6, 5, [Vector2i(6, 5)], 4)],
			"R R T0 L L U D D T1 R R R U U U L L L L L",
			"Veil Wing"
		),
		_puzzle(
			80,
			"The Last Cloth",
			"This room is about the rule that you leave by the gap the curtain left lit and unwatched.",
			PackedStringArray([
				"########",
				"#S.G..X#",
				"#..C...#",
				"#......#",
				"#......#",
				"########",
			]),
			[_lamp(3, 4, "n", 3)],
			[_guard(3, 3, [Vector2i(3, 3)], 2)],
			"R R R R R",
			"Veil Wing"
		),
	]
