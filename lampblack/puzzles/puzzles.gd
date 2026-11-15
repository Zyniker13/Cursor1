class_name LampPuzzles
extends RefCounted

const Rules = preload("res://rules/rules.gd")

## Six wings of the closed museum. Each solution is a list of actions the rules
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
