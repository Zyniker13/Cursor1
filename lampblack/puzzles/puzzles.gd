class_name LampPuzzles
extends RefCounted

const Rules = preload("res://rules/rules.gd")

## Thirty wings of the closed museum. Each solution is a list of actions the rules
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
	elif wing == "Shade Wing":
		wing_number = number - 80
	elif wing == "Screen Wing":
		wing_number = number - 86
	elif wing == "Glaze Wing":
		wing_number = number - 92
	elif wing == "Mica Wing":
		wing_number = number - 98
	elif wing == "Baize Wing":
		wing_number = number - 104
	elif wing == "Scrim Wing":
		wing_number = number - 110
	elif wing == "Gauze Wing":
		wing_number = number - 116
	elif wing == "Voile Wing":
		wing_number = number - 122
	elif wing == "Lawn Wing":
		wing_number = number - 128
	elif wing == "Muslin Wing":
		wing_number = number - 134
	elif wing == "Cambric Wing":
		wing_number = number - 140
	elif wing == "Holland Wing":
		wing_number = number - 146
	elif wing == "Buckram Wing":
		wing_number = number - 152
	elif wing == "Ticking Wing":
		wing_number = number - 158
	elif wing == "Denim Wing":
		wing_number = number - 164
	elif wing == "Canvas Wing":
		wing_number = number - 170
	elif wing == "Drill Wing":
		wing_number = number - 176
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
	puzzles.append_array(_shade_wing())
	puzzles.append_array(_screen_wing())
	puzzles.append_array(_glaze_wing())
	puzzles.append_array(_mica_wing())
	puzzles.append_array(_baize_wing())
	puzzles.append_array(_scrim_wing())
	puzzles.append_array(_gauze_wing())
	puzzles.append_array(_voile_wing())
	puzzles.append_array(_lawn_wing())
	puzzles.append_array(_muslin_wing())
	puzzles.append_array(_cambric_wing())
	puzzles.append_array(_holland_wing())
	puzzles.append_array(_buckram_wing())
	puzzles.append_array(_ticking_wing())
	puzzles.append_array(_denim_wing())
	puzzles.append_array(_canvas_wing())
	puzzles.append_array(_drill_wing())
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


static func _shade_wing() -> Array:
	return [
		_puzzle(
			81,
			"The First Shade",
			"This room is about the rule that light stops at a shade, so the gap beyond stays dark and you leave by that dark gap.",
			PackedStringArray([
				"############",
				"#..SHX.....#",
				"#..#.#.....#",
				"#..........#",
				"#..........#",
				"############",
			]),
			[_lamp(4, 2, "n", 2)],
			[_guard(4, 3, [Vector2i(4, 3)], 1)],
			"R R",
			"Shade Wing"
		),
		_puzzle(
			82,
			"The Dark Step",
			"This room is about the rule that you step onto the shade under the lamp without snuffing, and the shade stays dark.",
			PackedStringArray([
				"#########",
				"#.SHX...#",
				"#.#.#...#",
				"#.......#",
				"#########",
			]),
			[_lamp(3, 2, "n", 2)],
			[_guard(3, 3, [Vector2i(3, 3)], 1)],
			"R R",
			"Shade Wing"
		),
		_puzzle(
			83,
			"The Long Road",
			"This room is about the rule that a called guard cannot step on a shade, so he takes the longer floor road.",
			PackedStringArray([
				"#############",
				"#S....H....X#",
				"##.###.#.##.#",
				"#...........#",
				"#...........#",
				"#...........#",
				"#############",
			]),
			[_lamp(4, 1, "e", 0), _lamp(6, 3, "n", 3), _lamp(10, 5, "n", 0)],
			[_guard(10, 4, [Vector2i(10, 4)], 2)],
			"R R T0 R W W W W W W W W R R R R R R R",
			"Shade Wing"
		),
		_puzzle(
			84,
			"The Far Dark",
			"This room is about the rule that the tile past a shade stays dark and can be entered.",
			PackedStringArray([
				"############",
				"#..SH..X...#",
				"#..#.#.....#",
				"#..........#",
				"############",
			]),
			[_lamp(4, 2, "n", 2)],
			[_guard(4, 3, [Vector2i(4, 3)], 1)],
			"R R R R",
			"Shade Wing"
		),
		_puzzle(
			85,
			"The Second Lamp",
			"This room is about the rule that this room keeps its second lamp, and that lamp's light stops at the shade.",
			PackedStringArray([
				"#########",
				"#.#.....#",
				"#.SHX...#",
				"#.#.#...#",
				"#.......#",
				"#########",
			]),
			[_lamp(3, 1, "s", 2), _lamp(3, 3, "n", 2)],
			[_guard(3, 4, [Vector2i(3, 4)], 1)],
			"R T0 R",
			"Shade Wing"
		),
		_puzzle(
			86,
			"The Last Shade",
			"This room is about the rule that you leave by the dark gap the shade left.",
			PackedStringArray([
				"##########",
				"#..SHX...#",
				"#..#.#...#",
				"#........#",
				"##########",
			]),
			[_lamp(4, 2, "n", 2)],
			[_guard(6, 1, [Vector2i(6, 1)], 1), _guard(4, 3, [Vector2i(4, 3)], 1)],
			"R R",
			"Shade Wing"
		),
	]


static func _screen_wing() -> Array:
	return [
		_puzzle(
			87,
			"The First Screen",
			"This room is about the rule that a screen lets the lamp light the gap beyond and stops the guard's sight, so you cross that lit gap.",
			PackedStringArray([
				"###########",
				"#S..G....X#",
				"####E..##.#",
				"####.####.#",
				"#.........#",
				"###########",
			]),
			[_lamp(7, 1, "e", 0), _lamp(4, 3, "n", 2)],
			[_guard(4, 4, [Vector2i(4, 4)], 3)],
			"R R R R R T0 W W W W W R R R",
			"Screen Wing"
		),
		_puzzle(
			88,
			"The Lit Screen",
			"This room is about the rule that the screen is lit, so you snuff before you step onto it.",
			PackedStringArray([
				"########",
				"#.X....#",
				"#.G#...#",
				"#.E....#",
				"#..S...#",
				"#......#",
				"########",
			]),
			[_lamp(3, 3, "n", 2)],
			[_guard(2, 2, [Vector2i(2, 2)], 3)],
			"T0 L U T0 U U",
			"Screen Wing"
		),
		_puzzle(
			89,
			"The Closed Road",
			"This room is about the rule that a called guard cannot step on a screen, so he takes the longer floor road.",
			PackedStringArray([
				"#############",
				"#S...G.....X#",
				"#####E..###.#",
				"#####.#####.#",
				"#...........#",
				"#############",
			]),
			[_lamp(9, 1, "e", 0), _lamp(5, 3, "n", 2)],
			[_guard(5, 4, [Vector2i(5, 4)], 3)],
			"R R R R R R R T0 W W W W W W R R R",
			"Screen Wing"
		),
		_puzzle(
			90,
			"The Far Light",
			"This room is about the rule that the tile past a screen is lit and unwatched.",
			PackedStringArray([
				"################",
				"#S......G.....X#",
				"########E..###.#",
				"########.#####.#",
				"#..............#",
				"################",
			]),
			[_lamp(12, 1, "e", 0), _lamp(8, 3, "n", 2)],
			[_guard(8, 4, [Vector2i(8, 4)], 3)],
			"R R R R R R R R R R T0 W W W W W W R R R",
			"Screen Wing"
		),
		_puzzle(
			91,
			"The Second Lamp",
			"This room is about the rule that this room keeps its second lamp, and that lamp's light passes the screen.",
			PackedStringArray([
				"##########",
				"#........#",
				"###.####.#",
				"###E..##.#",
				"#S.G...X.#",
				"##########",
			]),
			[_lamp(6, 4, "e", 0), _lamp(3, 2, "s", 2)],
			[_guard(3, 1, [Vector2i(3, 1)], 3)],
			"R R R R T0 W W W W W W R R",
			"Screen Wing"
		),
		_puzzle(
			92,
			"The Last Screen",
			"This room is about the rule that you leave by the lit unwatched gap the screen left.",
			PackedStringArray([
				"##########",
				"#S.G...X.#",
				"###E..##.#",
				"###.####.#",
				"#........#",
				"##########",
			]),
			[_lamp(6, 1, "e", 0), _lamp(3, 3, "n", 2)],
			[_guard(3, 4, [Vector2i(3, 4)], 3)],
			"R R R R T0 W W W W W R R",
			"Screen Wing"
		),
	]


static func _glaze_wing() -> Array:
	return [
		_puzzle(
			93,
			"The Watched Gap",
			"This room is about the rule that the gap beyond the glaze is lit and watched.",
			PackedStringArray([
				"########",
				"##S##X.#",
				"#..G#..#",
				"#..Z...#",
				"#.#.#..#",
				"#......#",
				"########",
			]),
			[_lamp(3, 4, "n", 2)],
			[_guard(4, 3, [Vector2i(4, 3)], 3)],
			"D L D D D R R T0 U U R R U U",
			"Glaze Wing"
		),
		_puzzle(
			94,
			"The Lit Glaze",
			"This room is about the rule that the glaze is lit, so you snuff before you step onto it.",
			PackedStringArray([
				"########",
				"#.X....#",
				"#.G#...#",
				"#.Z....#",
				"#..S...#",
				"#......#",
				"########",
			]),
			[_lamp(3, 3, "n", 2)],
			[_guard(2, 2, [Vector2i(2, 2)], 3)],
			"T0 L U T0 U U",
			"Glaze Wing"
		),
		_puzzle(
			95,
			"The Open Sight",
			"This room is about the rule that the guard sees a lit tile through the glaze, and a wrong step there loses.",
			PackedStringArray([
				"#########",
				"##S##X..#",
				"#..G#...#",
				"#..Z....#",
				"#.#.#...#",
				"#.......#",
				"#########",
			]),
			[_lamp(3, 4, "n", 2)],
			[_guard(4, 3, [Vector2i(4, 3)], 3)],
			"D L D D D R R T0 U U R R U U",
			"Glaze Wing"
		),
		_puzzle(
			96,
			"The Closed Road",
			"This room is about the rule that a guard cannot enter the glaze, so he takes the longer road.",
			PackedStringArray([
				"########",
				"##S##X.#",
				"#..G#..#",
				"#..Z...#",
				"#.#.#..#",
				"#......#",
				"#......#",
				"########",
			]),
			[_lamp(3, 4, "n", 2)],
			[_guard(4, 3, [Vector2i(4, 3)], 3)],
			"D L D D D R R T0 U U R R U U",
			"Glaze Wing"
		),
		_puzzle(
			97,
			"The Second Lamp",
			"This room is about the rule that a second lamp's light passes the glaze, and the guard sees the gap beyond it.",
			PackedStringArray([
				"#########",
				"##S##X.##",
				"#..G#..##",
				"#..Z...##",
				"#.#.#..##",
				"#......##",
				"#########",
			]),
			[_lamp(6, 5, "e", 0), _lamp(3, 4, "n", 2)],
			[_guard(4, 3, [Vector2i(4, 3)], 3)],
			"D L D D D R R T1 U U R R U U",
			"Glaze Wing"
		),
		_puzzle(
			98,
			"The Last Glaze",
			"This room is about the rule that you leave without stepping on the lit glaze, because the gap beyond it is watched.",
			PackedStringArray([
				"#########",
				"###S##X.#",
				"#...G#..#",
				"#...Z...#",
				"#..#.#..#",
				"#.......#",
				"#########",
			]),
			[_lamp(4, 4, "n", 2)],
			[_guard(5, 3, [Vector2i(5, 3)], 3)],
			"D L D D D R R T0 U U R R U U",
			"Glaze Wing"
		),
	]


static func _mica_wing() -> Array:
	return [
		_puzzle(
			99,
			"The Dark Step",
			"This room is about the rule that you step onto the mica while the lamp is lit, and the gap beyond it is lit.",
			PackedStringArray([
				"##########",
				"#........#",
				"#...X....#",
				"#...G....#",
				"####M#####",
				"#...S....#",
				"#........#",
				"##########",
			]),
			[_lamp(4, 6, "n", 3)],
			[_guard(5, 6, [Vector2i(5, 6), Vector2i(8, 6)], 4)],
			"U U U",
			"Mica Wing"
		),
		_puzzle(
			100,
			"The Seen Gap",
			"This room is about the rule that the guard sees a lit tile through the dark mica, and the solution never takes that tile.",
			PackedStringArray([
				"#############",
				"#....###....#",
				"#....####...#",
				"#...##G###..#",
				"#.....MG.X..#",
				"#.....S###..#",
				"#...........#",
				"#...........#",
				"#############",
			]),
			[_lamp(4, 4, "n", 3)],
			[_guard(4, 4, [Vector2i(4, 4), Vector2i(4, 6)], 3)],
			"U R R R",
			"Mica Wing"
		),
		_puzzle(
			101,
			"The Passed Lamp",
			"This room is about the rule that a second lamp's light passes the mica, and the guard sees the gap.",
			PackedStringArray([
				"#############",
				"######G######",
				"#.....MG..X.#",
				"######G######",
				"#S..........#",
				"#...........#",
				"#############",
			]),
			[_lamp(2, 2, "e", 5), _lamp(3, 4, "e", 6)],
			[_guard(8, 4, [Vector2i(8, 4)], 6)],
			"R T1 R R D R U R U U U D R R R R",
			"Mica Wing"
		),
		_puzzle(
			102,
			"The Long Road",
			"This room is about the rule that a guard cannot enter the mica, so he takes the longer road.",
			PackedStringArray([
				"#############",
				"#.....G.....#",
				"#S....M....X#",
				"##.###.#.##.#",
				"#...........#",
				"#...........#",
				"#...........#",
				"#############",
			]),
			[_lamp(4, 2, "e", 0), _lamp(6, 4, "n", 3)],
			[_guard(10, 5, [Vector2i(10, 5)], 2)],
			"R R T0 R W W W W W W W W U R R D U R R R R R D",
			"Mica Wing"
		),
		_puzzle(
			103,
			"The Early Catch",
			"This room is about the rule that the early step onto the mica is legal, and a guard catches a scripted wrong step on the tile past it.",
			PackedStringArray([
				"##########",
				"#........#",
				"#...X....#",
				"#...G....#",
				"####M....#",
				"#...S....#",
				"#........#",
				"##########",
			]),
			[_lamp(4, 6, "n", 3)],
			[_guard(5, 6, [Vector2i(5, 6), Vector2i(8, 6)], 4)],
			"U U U",
			"Mica Wing"
		),
		_puzzle(
			104,
			"The Last Mica",
			"This room is about the rule that you leave by stepping on the dark mica, and the gap beyond it is watched.",
			PackedStringArray([
				"#############",
				"#.....G.....#",
				"#S....M....X#",
				"##.###.#.##.#",
				"#...........#",
				"#..........##",
				"#...........#",
				"#############",
			]),
			[_lamp(4, 2, "e", 0), _lamp(6, 4, "n", 3)],
			[_guard(8, 2, [Vector2i(8, 2)], 3)],
			"R R T0 R W W W U R R D U R R R R R D",
			"Mica Wing"
		),
	]


static func _baize_wing() -> Array:
	return [
		_puzzle(
			105,
			"The Dark Cloth",
			"This room is about the rule that you step onto the baize while the lamp is lit and the floor past it stays dark.",
			PackedStringArray([
				"##########",
				"#...X....#",
				"#........#",
				"####J#####",
				"#...S....#",
				"#........#",
				"##########",
			]),
			[_lamp(4, 5, "n", 3)],
			[_guard(6, 5, [Vector2i(6, 5), Vector2i(8, 5)], 5)],
			"U U U",
			"Baize Wing"
		),
		_puzzle(
			106,
			"The Seen Hem",
			"This room is about the rule that the guard sees a lit tile through the dark baize, and the solution never takes that tile.",
			PackedStringArray([
				"##########",
				"#...X....#",
				"#........#",
				"####J.####",
				"#...S#...#",
				"#........#",
				"##########",
			]),
			[_lamp(4, 5, "n", 3), _lamp(5, 3, "w", 0)],
			[_guard(4, 5, [Vector2i(4, 5)], 4)],
			"U U U",
			"Baize Wing"
		),
		_puzzle(
			107,
			"The Stopped Lamp",
			"This room is about the rule that a second lamp's light stops at the baize, so the floor past it stays dark.",
			PackedStringArray([
				"###########",
				"#....X....#",
				"#.........#",
				"#####J#####",
				"#....S....#",
				"#.........#",
				"###########",
			]),
			[_lamp(5, 2, "n", 1), _lamp(5, 5, "n", 3)],
			[_guard(8, 5, [Vector2i(8, 5)], 4)],
			"U T0 U U",
			"Baize Wing"
		),
		_puzzle(
			108,
			"The Long Cloth",
			"This room is about the rule that a guard cannot enter the baize, so he takes the longer road.",
			PackedStringArray([
				"#############",
				"#...........#",
				"#S....J....X#",
				"##.###.#.##.#",
				"#...........#",
				"#...........#",
				"#...........#",
				"#############",
			]),
			[_lamp(4, 2, "e", 0), _lamp(6, 4, "n", 3)],
			[_guard(9, 4, [Vector2i(9, 4)], 3)],
			"R R T0 R W W W W W W U R R D U R R R R R D",
			"Baize Wing"
		),
		_puzzle(
			109,
			"The Early Hem",
			"This room is about the rule that the early step onto the baize is legal, and a guard catches a scripted wrong step on the lit tile past it.",
			PackedStringArray([
				"###########",
				"#....X....#",
				"#.........#",
				"####J.#####",
				"#...S#....#",
				"#.........#",
				"###########",
			]),
			[_lamp(4, 5, "n", 3), _lamp(5, 3, "w", 0)],
			[_guard(4, 5, [Vector2i(4, 5)], 4)],
			"U U U R",
			"Baize Wing"
		),
		_puzzle(
			110,
			"The Last Baize",
			"This room is about the rule that you leave by stepping on the dark baize, and the floor beyond it stays dark.",
			PackedStringArray([
				"#############",
				"#...........#",
				"#S....J....X#",
				"##.###.#.##.#",
				"#...........#",
				"#..........##",
				"#...........#",
				"#############",
			]),
			[_lamp(4, 2, "e", 0), _lamp(6, 4, "n", 3)],
			[_guard(9, 5, [Vector2i(9, 5)], 4)],
			"R R T0 R W W W W W W W U R R D U R R R R R D",
			"Baize Wing"
		),
	]


static func _scrim_wing() -> Array:
	return [
		_puzzle(
			111,
			"The Lit Scrim",
			"This room is about the rule that the scrim is lit.",
			PackedStringArray([
				"##########",
				"#...X....#",
				"#...K....#",
				"#...S....#",
				"#........#",
				"##########",
			]),
			[_lamp(4, 4, "n", 3)],
			[_guard(4, 1, [Vector2i(4, 1)], 0)],
			"T0 U U",
			"Scrim Wing"
		),
		_puzzle(
			112,
			"The Seen Thread",
			"This room is about the rule that the guard sees a lit tile through the lit scrim.",
			PackedStringArray([
				"########",
				"#X.G...#",
				"##.K####",
				"#......#",
				"#......#",
				"#...S..#",
				"########",
			]),
			[_lamp(4, 4, "n", 3), _lamp(3, 1, "w", 0)],
			[_guard(5, 4, [Vector2i(5, 4)], 1), _guard(4, 2, [Vector2i(4, 2)], 3)],
			"T0 L U U U U L L",
			"Scrim Wing"
		),
		_puzzle(
			113,
			"The Halted Wick",
			"This room is about the rule that a second lamp's light stops at the scrim.",
			PackedStringArray([
				"###########",
				"#....X....#",
				"#.........#",
				"#.###K#####",
				"#.........#",
				"#S........#",
				"###########",
			]),
			[_lamp(9, 4, "w", 0), _lamp(5, 4, "n", 3)],
			[_guard(9, 5, [Vector2i(9, 5)], 2)],
			"U U U R R R R U",
			"Scrim Wing"
		),
		_puzzle(
			114,
			"The Closed Scrim",
			"This room is about the rule that a guard cannot enter the scrim.",
			PackedStringArray([
				"#########",
				"#S.K.X..#",
				"#######.#",
				"#.......#",
				"#########",
			]),
			[_lamp(3, 1, "e", 1)],
			[_guard(6, 1, [Vector2i(6, 1)], 2)],
			"R T0 R R R",
			"Scrim Wing"
		),
		_puzzle(
			115,
			"The Early Thread",
			"This room is about the rule that the early step onto the lit scrim fails.",
			PackedStringArray([
				"#########",
				"#..X....#",
				"#..K....#",
				"#..S....#",
				"#.......#",
				"#########",
			]),
			[_lamp(3, 4, "n", 3)],
			[_guard(3, 1, [Vector2i(3, 1)], 0)],
			"T0 U U",
			"Scrim Wing"
		),
		_puzzle(
			116,
			"The Last Scrim",
			"This room is about the rule that you leave by stepping on the dark scrim.",
			PackedStringArray([
				"##########",
				"#S.K..X..#",
				"########.#",
				"#........#",
				"##########",
			]),
			[_lamp(3, 1, "e", 2)],
			[_guard(8, 1, [Vector2i(8, 1)], 2)],
			"R T0 R R R R",
			"Scrim Wing"
		),
	]


static func _gauze_wing() -> Array:
	return [
		_puzzle(
			117,
			"The Lit Gauze",
			"This room is about the rule that the gauze is lit.",
			PackedStringArray([
				"#######",
				"#.....#",
				"#..X..#",
				"#..Q..#",
				"#..S..#",
				"#######",
			]),
			[_lamp(3, 3, "n", 2)],
			[_guard(5, 4, [Vector2i(5, 4)], 0)],
			"L U U R",
			"Gauze Wing"
		),
		_puzzle(
			118,
			"The Seen Mesh",
			"This room is about the rule that the guard sees a lit tile through the lit gauze.",
			PackedStringArray([
				"########",
				"#X.G...#",
				"##.Q####",
				"#......#",
				"#......#",
				"#...S..#",
				"########",
			]),
			[_lamp(4, 4, "n", 3), _lamp(3, 1, "w", 0)],
			[_guard(5, 4, [Vector2i(5, 4)], 1), _guard(4, 2, [Vector2i(4, 2)], 3)],
			"T0 L U U U U L L",
			"Gauze Wing"
		),
		_puzzle(
			119,
			"The Passed Flame",
			"This room is about the rule that a second lamp's light passes the gauze.",
			PackedStringArray([
				"########",
				"#.X....#",
				"#.G#...#",
				"#.Q....#",
				"#..S...#",
				"#......#",
				"########",
			]),
			[_lamp(6, 5, "w", 0), _lamp(3, 3, "n", 2)],
			[_guard(2, 2, [Vector2i(2, 2)], 3)],
			"T1 L U T1 U U",
			"Gauze Wing"
		),
		_puzzle(
			120,
			"The Open Gauze",
			"This room is about the rule that a guard cannot enter the gauze.",
			PackedStringArray([
				"#########",
				"#S.Q.X..#",
				"#######.#",
				"#.......#",
				"#########",
			]),
			[_lamp(3, 1, "e", 1)],
			[_guard(6, 1, [Vector2i(6, 1)], 2)],
			"R T0 R R R",
			"Gauze Wing"
		),
		_puzzle(
			121,
			"The Early Mesh",
			"This room is about the rule that the early step onto the lit gauze fails.",
			PackedStringArray([
				"#########",
				"#..X....#",
				"#..Q....#",
				"#..S....#",
				"#.......#",
				"#########",
			]),
			[_lamp(3, 4, "n", 3)],
			[_guard(3, 1, [Vector2i(3, 1)], 0)],
			"T0 U U",
			"Gauze Wing"
		),
		_puzzle(
			122,
			"The Last Gauze",
			"This room is about the rule that you leave by stepping on the dark gauze.",
			PackedStringArray([
				"##########",
				"#S.Q..X..#",
				"########.#",
				"#........#",
				"##########",
			]),
			[_lamp(3, 1, "e", 2)],
			[_guard(8, 1, [Vector2i(8, 1)], 2)],
			"R T0 R R R R",
			"Gauze Wing"
		),
	]


static func _voile_wing() -> Array:
	return [
		_puzzle(
			123,
			"The Lit Voile",
			"This room is about the rule that the voile is lit.",
			PackedStringArray([
				"#######",
				"#X....#",
				"#.....#",
				"#..V..#",
				"#..S..#",
				"#######",
			]),
			[_lamp(3, 3, "n", 2)],
			[_guard(5, 4, [Vector2i(5, 4)], 0)],
			"L U U U L",
			"Voile Wing"
		),
		_puzzle(
			124,
			"The Seen Weave",
			"This room is about the rule that the guard sees a lit tile through the lit voile.",
			PackedStringArray([
				"########",
				"#X.G...#",
				"##.V####",
				"#......#",
				"#......#",
				"#...S..#",
				"########",
			]),
			[_lamp(4, 4, "n", 3), _lamp(3, 1, "w", 0)],
			[_guard(5, 4, [Vector2i(5, 4)], 1), _guard(4, 2, [Vector2i(4, 2)], 3)],
			"T0 L U U U U L L",
			"Voile Wing"
		),
		_puzzle(
			125,
			"The Passed Spark",
			"This room is about the rule that a second lamp's light passes the voile.",
			PackedStringArray([
				"########",
				"#.X....#",
				"#.G#...#",
				"#.V....#",
				"#..S...#",
				"#......#",
				"########",
			]),
			[_lamp(6, 5, "w", 0), _lamp(3, 3, "n", 2)],
			[_guard(2, 2, [Vector2i(2, 2)], 3)],
			"T1 L U T1 U U",
			"Voile Wing"
		),
		_puzzle(
			126,
			"The Shut Voile",
			"This room is about the rule that a guard cannot enter the voile.",
			PackedStringArray([
				"#########",
				"#S.V.X..#",
				"#######.#",
				"#.......#",
				"#########",
			]),
			[_lamp(3, 1, "e", 1)],
			[_guard(6, 1, [Vector2i(6, 1)], 2)],
			"R R R R",
			"Voile Wing"
		),
		_puzzle(
			127,
			"The Early Step",
			"This room is about the rule that the early step onto the lit voile succeeds.",
			PackedStringArray([
				"#######",
				"#..X..#",
				"#..V..#",
				"#..S..#",
				"#.....#",
				"#######",
			]),
			[_lamp(5, 2, "w", 2)],
			[_guard(1, 4, [Vector2i(1, 4)], 0)],
			"U U",
			"Voile Wing"
		),
		_puzzle(
			128,
			"The Last Voile",
			"This room is about the rule that you leave by stepping on the dark voile.",
			PackedStringArray([
				"########",
				"#S.VX..#",
				"#......#",
				"#......#",
				"########",
			]),
			[_lamp(2, 1, "e", 2)],
			[_guard(6, 3, [Vector2i(6, 3)], 0)],
			"T0 R R R",
			"Voile Wing"
		),
	]


static func _lawn_wing() -> Array:
	return [
		_puzzle(
			129,
			"The Lit Lawn",
			"This room is about the rule that the lawn is lit.",
			PackedStringArray([
				"#######",
				"#X....#",
				"#..L..#",
				"#..S..#",
				"#.....#",
				"#######",
			]),
			[_lamp(4, 2, "w", 1)],
			[_guard(5, 4, [Vector2i(5, 4)], 0)],
			"L L U U",
			"Lawn Wing"
		),
		_puzzle(
			130,
			"The Seen Sward",
			"This room is about the rule that the guard sees a lit tile through the lit lawn.",
			PackedStringArray([
				"########",
				"#X.G...#",
				"##.L####",
				"#......#",
				"#......#",
				"#...S..#",
				"########",
			]),
			[_lamp(4, 4, "n", 3), _lamp(3, 1, "w", 0)],
			[_guard(5, 4, [Vector2i(5, 4)], 1), _guard(4, 2, [Vector2i(4, 2)], 3)],
			"T0 L U U U U L L",
			"Lawn Wing"
		),
		_puzzle(
			131,
			"The Halted Gleam",
			"This room is about the rule that a second lamp's light stops at the lawn.",
			PackedStringArray([
				"###########",
				"#....X....#",
				"#.........#",
				"#.###L#####",
				"#.........#",
				"#S........#",
				"###########",
			]),
			[_lamp(9, 4, "w", 0), _lamp(5, 4, "n", 3)],
			[_guard(9, 5, [Vector2i(9, 5)], 2)],
			"U U U R R R R U",
			"Lawn Wing"
		),
		_puzzle(
			132,
			"The Barred Lawn",
			"This room is about the rule that a guard cannot enter the lawn.",
			PackedStringArray([
				"#########",
				"#S.L.X..#",
				"#######.#",
				"#.......#",
				"#########",
			]),
			[_lamp(3, 1, "e", 1)],
			[_guard(6, 1, [Vector2i(6, 1)], 2)],
			"R R R R",
			"Lawn Wing"
		),
		_puzzle(
			133,
			"The Early Tread",
			"This room is about the rule that the early step onto the lit lawn succeeds.",
			PackedStringArray([
				"#######",
				"#..X..#",
				"#..L..#",
				"#..S..#",
				"#.....#",
				"#######",
			]),
			[_lamp(5, 2, "w", 2)],
			[_guard(1, 4, [Vector2i(1, 4)], 0)],
			"U U",
			"Lawn Wing"
		),
		_puzzle(
			134,
			"The Last Lawn",
			"This room is about the rule that you leave by stepping on the dark lawn.",
			PackedStringArray([
				"########",
				"#S.LX..#",
				"#......#",
				"#......#",
				"########",
			]),
			[_lamp(2, 1, "e", 2)],
			[_guard(6, 3, [Vector2i(6, 3)], 0)],
			"T0 R R R",
			"Lawn Wing"
		),
	]


static func _muslin_wing() -> Array:
	return [
		_puzzle(
			135,
			"The Lit Muslin",
			"This room is about the rule that the muslin is lit.",
			PackedStringArray([
				"#######",
				"#GN...#",
				"#...S.#",
				"#X....#",
				"#######",
			]),
			[_lamp(4, 1, "w", 3)],
			[_guard(1, 1, [Vector2i(1, 1)], 0)],
			"T0 L L L D",
			"Muslin Wing"
		),
		_puzzle(
			136,
			"The Seen Warp",
			"This room is about the rule that the guard sees a lit tile through the lit muslin.",
			PackedStringArray([
				"#######",
				"#GN...#",
				"#...S.#",
				"#.....#",
				"#X....#",
				"#######",
			]),
			[_lamp(4, 1, "w", 3)],
			[_guard(1, 1, [Vector2i(1, 1)], 3)],
			"T0 L L L D D",
			"Muslin Wing"
		),
		_puzzle(
			137,
			"The Halted Sheen",
			"This room is about the rule that a second lamp's light stops at the muslin.",
			PackedStringArray([
				"#######",
				"##.#.##",
				"#GN...#",
				"#...S.#",
				"#X....#",
				"#######",
			]),
			[_lamp(4, 2, "s", 2), _lamp(2, 1, "s", 2)],
			[_guard(1, 2, [Vector2i(1, 2)], 0)],
			"T0 L L L D",
			"Muslin Wing"
		),
		_puzzle(
			138,
			"The Open Muslin",
			"This room is about the rule that a guard can enter the muslin.",
			PackedStringArray([
				"########",
				"#GN....#",
				"#...S..#",
				"#X.....#",
				"########",
			]),
			[_lamp(4, 1, "w", 3)],
			[_guard(1, 1, [Vector2i(1, 1)], 0)],
			"T0 L L L D",
			"Muslin Wing"
		),
		_puzzle(
			139,
			"The Refused Entry",
			"This room is about the rule that the early step onto the lit muslin fails.",
			PackedStringArray([
				"#######",
				"#GN...#",
				"#.S...#",
				"#X....#",
				"#######",
			]),
			[_lamp(2, 3, "n", 2)],
			[_guard(1, 1, [Vector2i(1, 1)], 0)],
			"T0 L D",
			"Muslin Wing"
		),
		_puzzle(
			140,
			"The Last Muslin",
			"This room is about the rule that you leave by stepping on the dark muslin.",
			PackedStringArray([
				"###X###",
				"#GN...#",
				"#...S.#",
				"#######",
			]),
			[_lamp(4, 1, "w", 3)],
			[_guard(1, 1, [Vector2i(1, 1)], 0)],
			"T0 L L U R U",
			"Muslin Wing"
		),
	]


static func _cambric_wing() -> Array:
	return [
		_puzzle(
			141,
			"The Lit Cambric",
			"This room is about the rule that the cambric is lit.",
			PackedStringArray([
				"#######",
				"#GY...#",
				"#.S...#",
				"#X....#",
				"#######",
			]),
			[_lamp(3, 1, "s", 2)],
			[_guard(1, 1, [Vector2i(1, 1)], 0)],
			"U T0 D L D",
			"Cambric Wing"
		),
		_puzzle(
			142,
			"The Seen Weft",
			"This room is about the rule that the guard sees a lit tile through the lit cambric.",
			PackedStringArray([
				"#########",
				"#GY...#.#",
				"#.S...#Y#",
				"#X....#G#",
				"#########",
			]),
			[_lamp(3, 1, "s", 2), _lamp(7, 1, "s", 2)],
			[_guard(1, 1, [Vector2i(1, 1)], 0), _guard(7, 3, [Vector2i(7, 3)], 3)],
			"U T0 D L D",
			"Cambric Wing"
		),
		_puzzle(
			143,
			"The Halted Glow",
			"This room is about the rule that a second lamp's light stops at the cambric.",
			PackedStringArray([
				"#######",
				"##.#.##",
				"#GY...#",
				"#...S.#",
				"#X....#",
				"#######",
			]),
			[_lamp(4, 2, "s", 2), _lamp(2, 1, "s", 2)],
			[_guard(1, 2, [Vector2i(1, 2)], 0)],
			"T0 L L U D L D",
			"Cambric Wing"
		),
		_puzzle(
			144,
			"The Walked Cambric",
			"This room is about the rule that a guard can enter the cambric.",
			PackedStringArray([
				"########",
				"#GY....#",
				"#.S....#",
				"#X.....#",
				"########",
			]),
			[_lamp(3, 1, "s", 2)],
			[_guard(1, 1, [Vector2i(1, 1)], 0)],
			"U T0 D L D",
			"Cambric Wing"
		),
		_puzzle(
			145,
			"The Sure Landing",
			"This room is about the rule that the early step onto the lit cambric succeeds.",
			PackedStringArray([
				"#######",
				"#GY...#",
				"#.S...#",
				"#.....#",
				"#X....#",
				"#######",
			]),
			[_lamp(3, 1, "s", 2)],
			[_guard(1, 1, [Vector2i(1, 1)], 0)],
			"U T0 D L D D",
			"Cambric Wing"
		),
		_puzzle(
			146,
			"The Last Cambric",
			"This room is about the rule that you leave by stepping on the dark cambric.",
			PackedStringArray([
				"#######",
				"#GY...#",
				"#.S...#",
				"#X....#",
				"#.....#",
				"#######",
			]),
			[_lamp(3, 1, "s", 2)],
			[_guard(1, 1, [Vector2i(1, 1)], 0)],
			"U T0 D L R U D L D",
			"Cambric Wing"
		),
	]


static func _holland_wing() -> Array:
	return [
		_puzzle(
			147,
			"The Lit Holland",
			"This room is about the rule that the holland is lit.",
			PackedStringArray([
				"#########",
				"#GO.....#",
				"#.G#....#",
				"#.S.....#",
				"###....X#",
				"#########",
			]),
			[_lamp(3, 1, "w", 3)],
			[_guard(1, 1, [Vector2i(1, 1)], 0)],
			"U U T0 R R W D D D R R R",
			"Holland Wing"
		),
		_puzzle(
			148,
			"The Seen Grain",
			"This room is about the rule that the guard sees a lit tile through the lit holland.",
			PackedStringArray([
				"#########",
				"#GO.....#",
				"#.G#....#",
				"#.S.....#",
				"###....X#",
				"#########",
				"#.......#",
				"#..O....#",
				"#..G....#",
				"#########",
			]),
			[_lamp(3, 1, "w", 3), _lamp(3, 6, "s", 2)],
			[_guard(1, 1, [Vector2i(1, 1)], 0), _guard(3, 8, [Vector2i(3, 8)], 3)],
			"U U T0 R R W D D D R R R",
			"Holland Wing"
		),
		_puzzle(
			149,
			"The Passed Ray",
			"This room is about the rule that a second lamp's light passes through the holland.",
			PackedStringArray([
				"#########",
				"#########",
				"#GO.....#",
				"#.G#....#",
				"#.S.....#",
				"###....X#",
				"#########",
			]),
			[_lamp(3, 2, "w", 3)],
			[_guard(1, 2, [Vector2i(1, 2)], 0)],
			"U U T0 R R W D D D R R R",
			"Holland Wing"
		),
		_puzzle(
			150,
			"The Trod Holland",
			"This room is about the rule that a guard can enter the holland.",
			PackedStringArray([
				"##########",
				"#GO.....##",
				"#.G#....##",
				"#.S.....##",
				"###....X##",
				"##########",
			]),
			[_lamp(3, 1, "w", 3)],
			[_guard(1, 1, [Vector2i(1, 1)], 0)],
			"U U T0 R R W D D D R R R",
			"Holland Wing"
		),
		_puzzle(
			151,
			"The Firm Footing",
			"This room is about the rule that the early step onto the lit holland succeeds.",
			PackedStringArray([
				"#########",
				"#GO.....#",
				"#.G#....#",
				"#.S.....#",
				"###....X#",
				"#########",
				"#########",
			]),
			[_lamp(3, 1, "w", 3)],
			[_guard(1, 1, [Vector2i(1, 1)], 0)],
			"U U T0 R R W D D D R R R",
			"Holland Wing"
		),
		_puzzle(
			152,
			"The Last Holland",
			"This room is about the rule that you leave by stepping on the dark holland.",
			PackedStringArray([
				"#########",
				"#GO.....#",
				"#.G#....#",
				"#.S.....#",
				"###..O.X#",
				"#########",
			]),
			[_lamp(3, 1, "w", 3)],
			[_guard(1, 1, [Vector2i(1, 1)], 0)],
			"U U T0 R R W D D D R R R",
			"Holland Wing"
		),
	]


static func _buckram_wing() -> Array:
	return [
		_puzzle(
			153,
			"The Lit Buckram",
			"This room is about the rule that the buckram is lit.",
			PackedStringArray([
				"#########",
				"#GF.....#",
				"#..#....#",
				"#..GS...#",
				"#X......#",
				"#########",
			]),
			[_lamp(3, 1, "w", 3)],
			[_guard(1, 1, [Vector2i(1, 1)], 0)],
			"L R U U T0 D D D L L L",
			"Buckram Wing"
		),
		_puzzle(
			154,
			"The Seen Rib",
			"This room is about the rule that the guard sees a lit tile through the lit buckram.",
			PackedStringArray([
				"#########",
				"#GF.....#",
				"#..#....#",
				"#..GS...#",
				"#X......#",
				"#########",
				"#.......#",
				"#..F....#",
				"#..G....#",
				"#########",
			]),
			[_lamp(3, 1, "w", 3), _lamp(3, 6, "s", 2)],
			[_guard(1, 1, [Vector2i(1, 1)], 0), _guard(3, 8, [Vector2i(3, 8)], 3)],
			"L R U U T0 D D D L L L",
			"Buckram Wing"
		),
		_puzzle(
			155,
			"The Passed Beam",
			"This room is about the rule that a second lamp's light passes through the buckram.",
			PackedStringArray([
				"#########",
				"#########",
				"#GF.....#",
				"#..#....#",
				"#..GS...#",
				"#X......#",
				"#########",
			]),
			[_lamp(3, 2, "w", 3)],
			[_guard(1, 2, [Vector2i(1, 2)], 0)],
			"L R U U T0 D D D L L L",
			"Buckram Wing"
		),
		_puzzle(
			156,
			"The Open Buckram",
			"This room is about the rule that a guard can enter the buckram.",
			PackedStringArray([
				"##########",
				"#GF.....##",
				"#..#....##",
				"#..GS...##",
				"#X......##",
				"##########",
			]),
			[_lamp(3, 1, "w", 3)],
			[_guard(1, 1, [Vector2i(1, 1)], 0)],
			"L R U U T0 D D D L L L",
			"Buckram Wing"
		),
		_puzzle(
			157,
			"The Barred Step",
			"This room is about the rule that the early step onto the lit buckram fails.",
			PackedStringArray([
				"#########",
				"#GF.....#",
				"#..#....#",
				"#..GS...#",
				"#X......#",
				"#########",
				"#########",
			]),
			[_lamp(3, 1, "w", 3)],
			[_guard(1, 1, [Vector2i(1, 1)], 0)],
			"L R U U T0 D D D L L L",
			"Buckram Wing"
		),
		_puzzle(
			158,
			"The Last Buckram",
			"This room is about the rule that you leave by stepping on the dark buckram.",
			PackedStringArray([
				"#########",
				"#GF.....#",
				"#..#....#",
				"#..GS...#",
				"#X......#",
				"#.F.....#",
				"#########",
			]),
			[_lamp(3, 1, "w", 3)],
			[_guard(1, 1, [Vector2i(1, 1)], 0)],
			"L R U U T0 D D D L L D U L",
			"Buckram Wing"
		),
	]


static func _ticking_wing() -> Array:
	return [
		_puzzle(
			159,
			"The Lit Ticking",
			"This room is about the rule that the ticking is lit.",
			PackedStringArray([
				"#########",
				"#GT.....#",
				"#..#....#",
				"#..GS...#",
				"#X......#",
				"#########",
			]),
			[_lamp(3, 1, "w", 3)],
			[_guard(1, 1, [Vector2i(1, 1)], 0)],
			"L R U U T0 D D D L L L",
			"Ticking Wing"
		),
		_puzzle(
			160,
			"The Hidden Stripe",
			"This room is about the rule that the guard does not see a lit tile through the lit ticking.",
			PackedStringArray([
				"#########",
				"#GT.....#",
				"#..#....#",
				"#..GS...#",
				"#X......#",
				"#########",
				"#.......#",
				"#..T....#",
				"#..G....#",
				"#########",
			]),
			[_lamp(3, 1, "w", 3), _lamp(3, 6, "s", 2)],
			[_guard(1, 1, [Vector2i(1, 1)], 0), _guard(3, 8, [Vector2i(3, 8)], 3)],
			"L R U U T0 D D D L L L",
			"Ticking Wing"
		),
		_puzzle(
			161,
			"The Passed Stripe",
			"This room is about the rule that a second lamp's light passes through the ticking.",
			PackedStringArray([
				"#########",
				"#########",
				"#GT.....#",
				"#..#....#",
				"#..GS...#",
				"#X......#",
				"#########",
			]),
			[_lamp(3, 2, "w", 3)],
			[_guard(1, 2, [Vector2i(1, 2)], 0)],
			"L R U U T0 D D D L L L",
			"Ticking Wing"
		),
		_puzzle(
			162,
			"The Open Ticking",
			"This room is about the rule that a guard can enter the ticking.",
			PackedStringArray([
				"##########",
				"#GT.....##",
				"#..#....##",
				"#..GS...##",
				"#X......##",
				"##########",
			]),
			[_lamp(3, 1, "w", 3)],
			[_guard(1, 1, [Vector2i(1, 1)], 0)],
			"L R U U T0 D D D L L L",
			"Ticking Wing"
		),
		_puzzle(
			163,
			"The Clear Step",
			"This room is about the rule that the early step onto the lit ticking succeeds.",
			PackedStringArray([
				"#########",
				"#GT.....#",
				"#..#....#",
				"#..GS...#",
				"#X......#",
				"#########",
				"#########",
			]),
			[_lamp(3, 1, "w", 3)],
			[_guard(1, 1, [Vector2i(1, 1)], 0)],
			"L R U U T0 D D D L L L",
			"Ticking Wing"
		),
		_puzzle(
			164,
			"The Last Ticking",
			"This room is about the rule that you leave by stepping on the dark ticking.",
			PackedStringArray([
				"#########",
				"#GT.....#",
				"#..#....#",
				"#..GS...#",
				"#X......#",
				"#.T.....#",
				"#########",
			]),
			[_lamp(3, 1, "w", 3)],
			[_guard(1, 1, [Vector2i(1, 1)], 0)],
			"L R U U T0 D D D L L D U L",
			"Ticking Wing"
		),
	]


static func _denim_wing() -> Array:
	return [
		_puzzle(
			165,
			"The Lit Denim",
			"This room is about the rule that the denim is lit.",
			PackedStringArray([
				"#########",
				"#GD.....#",
				"#..#....#",
				"#..GS...#",
				"#X......#",
				"#########",
			]),
			[_lamp(3, 1, "w", 3)],
			[_guard(1, 1, [Vector2i(1, 1)], 0)],
			"L R U U T0 D D D L L L",
			"Denim Wing"
		),
		_puzzle(
			166,
			"The Seen Twill",
			"This room is about the rule that the guard sees a lit tile through the lit denim.",
			PackedStringArray([
				"#########",
				"#GD.....#",
				"#..#....#",
				"#..GS...#",
				"#X......#",
				"#########",
				"#.......#",
				"#..D....#",
				"#..G....#",
				"#########",
			]),
			[_lamp(3, 1, "w", 3), _lamp(3, 6, "s", 2)],
			[_guard(1, 1, [Vector2i(1, 1)], 0), _guard(3, 8, [Vector2i(3, 8)], 3)],
			"L R U U T0 D D D L L L",
			"Denim Wing"
		),
		_puzzle(
			167,
			"The Passed Seam",
			"This room is about the rule that a second lamp's light passes through the denim.",
			PackedStringArray([
				"#########",
				"#########",
				"#GD.....#",
				"#..#....#",
				"#..GS...#",
				"#X......#",
				"#########",
			]),
			[_lamp(3, 2, "w", 3)],
			[_guard(1, 2, [Vector2i(1, 2)], 0)],
			"L R U U T0 D D D L L L",
			"Denim Wing"
		),
		_puzzle(
			168,
			"The Open Denim",
			"This room is about the rule that a guard can enter the denim.",
			PackedStringArray([
				"##########",
				"#GD.....##",
				"#..#....##",
				"#..GS...##",
				"#X......##",
				"##########",
			]),
			[_lamp(3, 1, "w", 3)],
			[_guard(1, 1, [Vector2i(1, 1)], 0)],
			"L R U U T0 D D D L L L",
			"Denim Wing"
		),
		_puzzle(
			169,
			"The Sure Tread",
			"This room is about the rule that the early step onto the lit denim succeeds.",
			PackedStringArray([
				"#########",
				"#GD.....#",
				"#..#....#",
				"#..GS...#",
				"#X......#",
				"#########",
				"#########",
			]),
			[_lamp(3, 1, "w", 3)],
			[_guard(1, 1, [Vector2i(1, 1)], 0)],
			"L R U U T0 D D D L L L",
			"Denim Wing"
		),
		_puzzle(
			170,
			"The Last Denim",
			"This room is about the rule that you leave by stepping on the lit denim.",
			PackedStringArray([
				"#########",
				"#GD.....#",
				"#..#....#",
				"#.DGS...#",
				"#X......#",
				"#.D.....#",
				"#########",
			]),
			[_lamp(3, 1, "w", 3)],
			[_guard(1, 1, [Vector2i(1, 1)], 0)],
			"L L R R U U T0 D D D L L L",
			"Denim Wing"
		),
	]


static func _canvas_wing() -> Array:
	return [
		_puzzle(
			171,
			"The Lit Canvas",
			"This room is about the rule that the canvas is lit.",
			PackedStringArray([
				"#########",
				"#GU.....#",
				"#..#....#",
				"#..GS...#",
				"#X......#",
				"#########",
			]),
			[_lamp(3, 1, "w", 3)],
			[_guard(1, 1, [Vector2i(1, 1)], 0)],
			"L R U U T0 D D D L L L",
			"Canvas Wing"
		),
		_puzzle(
			172,
			"The Seen Sail",
			"This room is about the rule that the guard sees a lit tile through the lit canvas.",
			PackedStringArray([
				"#########",
				"#GU.....#",
				"#..#....#",
				"#..GS...#",
				"#X......#",
				"#########",
				"#.......#",
				"#..U....#",
				"#..G....#",
				"#########",
			]),
			[_lamp(3, 1, "w", 3), _lamp(3, 6, "s", 2)],
			[_guard(1, 1, [Vector2i(1, 1)], 0), _guard(3, 8, [Vector2i(3, 8)], 3)],
			"L R U U T0 D D D L L L",
			"Canvas Wing"
		),
		_puzzle(
			173,
			"The Passed Bolt",
			"This room is about the rule that a second lamp's light passes through the canvas.",
			PackedStringArray([
				"#########",
				"#########",
				"#GU.....#",
				"#..#....#",
				"#..GS...#",
				"#X......#",
				"#########",
			]),
			[_lamp(3, 2, "w", 3)],
			[_guard(1, 2, [Vector2i(1, 2)], 0)],
			"L R U U T0 D D D L L L",
			"Canvas Wing"
		),
		_puzzle(
			174,
			"The Open Canvas",
			"This room is about the rule that a guard can enter the canvas.",
			PackedStringArray([
				"##########",
				"#GU.....##",
				"#..#....##",
				"#..GS...##",
				"#X......##",
				"##########",
			]),
			[_lamp(3, 1, "w", 3)],
			[_guard(1, 1, [Vector2i(1, 1)], 0)],
			"L R U U T0 D D D L L L",
			"Canvas Wing"
		),
		_puzzle(
			175,
			"The Quenched Step",
			"This room is about the rule that the early step onto the lit canvas succeeds and puts it out.",
			PackedStringArray([
				"#########",
				"#GU.....#",
				"#..#....#",
				"#..GS...#",
				"#X......#",
				"#########",
				"#########",
			]),
			[_lamp(3, 1, "w", 3)],
			[_guard(1, 1, [Vector2i(1, 1)], 0)],
			"L R U U T0 D D D L L L",
			"Canvas Wing"
		),
		_puzzle(
			176,
			"The Last Canvas",
			"This room is about the rule that you leave by stepping on the canvas, and that step puts it out.",
			PackedStringArray([
				"#########",
				"#GU.....#",
				"#..#....#",
				"#.UGS...#",
				"#X......#",
				"#.U.....#",
				"#########",
			]),
			[_lamp(3, 1, "w", 3)],
			[_guard(1, 1, [Vector2i(1, 1)], 0)],
			"L L R R U U T0 D D D L L L",
			"Canvas Wing"
		),
	]


static func _drill_wing() -> Array:
	return [
		_puzzle(
			177,
			"The Lit Drill",
			"This room is about the rule that the drill is lit.",
			PackedStringArray([
				"#########",
				"#GW.....#",
				"#..#....#",
				"#..GS...#",
				"#X......#",
				"#########",
			]),
			[_lamp(3, 1, "w", 3)],
			[_guard(1, 1, [Vector2i(1, 1)], 0)],
			"L R U U T0 D D D L L L",
			"Drill Wing"
		),
		_puzzle(
			178,
			"The Hidden Drill",
			"This room is about the rule that the guard does not see a lit tile through the lit drill.",
			PackedStringArray([
				"#########",
				"#GW.....#",
				"#..#....#",
				"#..GS...#",
				"#X......#",
				"#########",
				"#.......#",
				"#..W....#",
				"#..G....#",
				"#########",
			]),
			[_lamp(3, 1, "w", 3), _lamp(3, 6, "s", 2)],
			[_guard(1, 1, [Vector2i(1, 1)], 0), _guard(3, 8, [Vector2i(3, 8)], 3)],
			"L R U U T0 D D D L L L",
			"Drill Wing"
		),
		_puzzle(
			179,
			"The Passed Weave",
			"This room is about the rule that a second lamp's light passes through the drill.",
			PackedStringArray([
				"#########",
				"#########",
				"#GW.....#",
				"#..#....#",
				"#..GS...#",
				"#X......#",
				"#########",
			]),
			[_lamp(3, 2, "w", 3)],
			[_guard(1, 2, [Vector2i(1, 2)], 0)],
			"L R U U T0 D D D L L L",
			"Drill Wing"
		),
		_puzzle(
			180,
			"The Open Drill",
			"This room is about the rule that a guard can enter the drill.",
			PackedStringArray([
				"##########",
				"#GW.....##",
				"#..#....##",
				"#..GS...##",
				"#X......##",
				"##########",
			]),
			[_lamp(3, 1, "w", 3)],
			[_guard(1, 1, [Vector2i(1, 1)], 0)],
			"L R U U T0 D D D L L L",
			"Drill Wing"
		),
		_puzzle(
			181,
			"The Spent Step",
			"This room is about the rule that the early step onto the lit drill succeeds and puts it out.",
			PackedStringArray([
				"#########",
				"#GW.....#",
				"#..#....#",
				"#..GS...#",
				"#X......#",
				"#########",
				"#########",
			]),
			[_lamp(3, 1, "w", 3)],
			[_guard(1, 1, [Vector2i(1, 1)], 0)],
			"L R U U T0 D D D L L L",
			"Drill Wing"
		),
		_puzzle(
			182,
			"The Last Drill",
			"This room is about the rule that you leave by stepping on the drill, and that step puts it out.",
			PackedStringArray([
				"#########",
				"#GW.....#",
				"#..#....#",
				"#.WGS...#",
				"#X......#",
				"#.W.....#",
				"#########",
			]),
			[_lamp(3, 1, "w", 3)],
			[_guard(1, 1, [Vector2i(1, 1)], 0)],
			"L L R R U U T0 D D D L L L",
			"Drill Wing"
		),
	]
