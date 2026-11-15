extends RefCounted

## Building 1. Directions: 0 east, 1 south, 2 west, 3 north.
## `unlocks` is the single new block this puzzle introduces, or "".

const INTRO: Array[String] = ["conveyor", "latch", "splitter", "painter", "counter"]


static func all() -> Array:
	return [
		_puzzle(
			1, "First Mile", "conveyor",
			"Send the parcel straight to the dock.",
			"Left-click places or rotates, right-click deletes, R rotates, Enter submits, Backspace restarts.",
			"A conveyor moves a parcel one step along its arrow each tick.",
			6, 3, [],
			[_source(0, 1, 0, ["gray"])],
			{"x": 5, "y": 1},
			[{"color": "gray"}],
			[_block("conveyor", 1, 1, 0), _block("conveyor", 2, 1, 0), _block("conveyor", 3, 1, 0), _block("conveyor", 4, 1, 0)]
		),
		_puzzle(
			2, "Around the Corner", "",
			"The dock is around the corner. Bend the belt.",
			"", "",
			6, 4, [_cell(1, 2), _cell(2, 2), _cell(3, 2)],
			[_source(0, 1, 0, ["gray"])],
			{"x": 4, "y": 3},
			[{"color": "gray"}],
			[
				_block("conveyor", 1, 1, 0), _block("conveyor", 2, 1, 0), _block("conveyor", 3, 1, 0),
				_block("conveyor", 4, 1, 1), _block("conveyor", 4, 2, 1),
			]
		),
		_puzzle(
			3, "Both of Them", "",
			"Two parcels are due, in the order they leave the chute.",
			"", "",
			6, 3, [],
			[_source(0, 1, 0, ["gray", "gray"])],
			{"x": 5, "y": 1},
			[{"color": "gray"}, {"color": "gray"}],
			[_block("conveyor", 1, 1, 0), _block("conveyor", 2, 1, 0), _block("conveyor", 3, 1, 0), _block("conveyor", 4, 1, 0)]
		),
		_puzzle(
			4, "Let It Pass", "latch",
			"Hold the south parcel so the two belts can merge.",
			"",
			"A latch waits one tick, then moves only into a cell that is already empty.",
			6, 3, [],
			[_source(0, 0, 0, ["gray"]), _source(0, 2, 0, ["gray"])],
			{"x": 5, "y": 1},
			[{"color": "gray"}, {"color": "gray"}],
			[
				_block("conveyor", 1, 0, 0), _block("conveyor", 2, 0, 1),
				_block("conveyor", 1, 2, 0), _block("latch", 2, 2, 3),
				_block("conveyor", 2, 1, 0), _block("conveyor", 3, 1, 0), _block("conveyor", 4, 1, 0),
			]
		),
		_puzzle(
			5, "Blue First", "splitter",
			"Blue has to reach the dock before red.",
			"",
			"A splitter sends the first parcel the way it faces, then the next parcel clockwise.",
			6, 3, [],
			[_source(0, 2, 0, ["red", "blue"])],
			{"x": 5, "y": 2},
			[{"color": "blue"}, {"color": "red"}],
			[
				_block("conveyor", 1, 2, 0), _block("splitter", 2, 2, 3),
				_block("conveyor", 2, 1, 3), _block("conveyor", 2, 0, 0),
				_block("conveyor", 3, 0, 0), _block("conveyor", 4, 0, 0),
				_block("conveyor", 5, 0, 1), _block("conveyor", 5, 1, 1),
				_block("conveyor", 3, 2, 0), _block("conveyor", 4, 2, 0),
			]
		),
		_puzzle(
			6, "Blue Tag", "painter",
			"Paint the parcel blue before it reaches the dock.",
			"",
			"A painter sets the color of a parcel passing over it.",
			6, 3, [],
			[_source(0, 1, 0, ["gray"])],
			{"x": 5, "y": 1},
			[{"color": "blue"}],
			[
				_block("conveyor", 1, 1, 0),
				_block("painter", 2, 1, 0, "blue"),
				_block("conveyor", 3, 1, 0), _block("conveyor", 4, 1, 0),
			]
		),
		_puzzle(
			7, "Counted Three", "counter",
			"Stamp the three parcels with counts 1, 2, and 3.",
			"",
			"A counter adds one and stamps that number on each parcel that passes.",
			6, 3, [],
			[_source(0, 1, 0, ["gray", "gray", "gray"])],
			{"x": 5, "y": 1},
			[{"count": 1}, {"count": 2}, {"count": 3}],
			[
				_block("conveyor", 1, 1, 0), _block("counter", 2, 1, 0),
				_block("conveyor", 3, 1, 0), _block("conveyor", 4, 1, 0),
			]
		),
		_puzzle(
			8, "Night Sort", "",
			"Paint one red and one blue, stamp them 1 then 2, and keep the merge clear.",
			"", "",
			8, 4, [],
			[_source(0, 1, 0, ["gray", "gray"])],
			{"x": 7, "y": 1},
			[{"color": "red", "count": 1}, {"color": "blue", "count": 2}],
			[
				_block("conveyor", 1, 1, 0), _block("splitter", 2, 1, 0),
				_block("conveyor", 3, 1, 0), _block("painter", 4, 1, 0, "red"),
				_block("conveyor", 5, 1, 0), _block("counter", 6, 1, 0),
				_block("conveyor", 2, 2, 0), _block("conveyor", 3, 2, 0),
				_block("painter", 4, 2, 0, "blue"), _block("conveyor", 5, 2, 0),
				_block("latch", 6, 2, 3),
			]
		),
		_puzzle(
			9, "Second Stamp", "",
			"Send the parcel around so the counter stamps it twice.",
			"",
			"Point the splitter up the return. The next send faces the dock, and the counter stamps 2.",
			4, 2, [],
			[_source(0, 1, 0, ["gray"])],
			{"x": 3, "y": 1},
			[{"count": 2}],
			[
				_block("counter", 1, 1, 0), _block("splitter", 2, 1, 3),
				_block("conveyor", 2, 0, 2), _block("conveyor", 1, 0, 1),
			]
		),
		_puzzle(
			10, "Fresh Coat", "",
			"The chute sends red. Bring it back yellow, stamped 2.",
			"",
			"Paint on the way back. The new color replaces red.",
			4, 2, [],
			[_source(3, 0, 2, ["red"])],
			{"x": 0, "y": 0},
			[{"color": "yellow", "count": 2}],
			[
				_block("counter", 2, 0, 2), _block("splitter", 1, 0, 1),
				_block("conveyor", 1, 1, 0), _block("painter", 2, 1, 3, "yellow"),
			]
		),
		_puzzle(
			11, "One Then Three", "",
			"Deliver counts 1 and 3.",
			"",
			"Let the first parcel leave. Send the next one around the counter.",
			4, 2, [],
			[_source(0, 0, 0, ["gray", "gray"])],
			{"x": 3, "y": 0},
			[{"count": 1}, {"count": 3}],
			[
				_block("counter", 1, 0, 0), _block("splitter", 2, 0, 0),
				_block("conveyor", 2, 1, 2), _block("conveyor", 1, 1, 3),
			]
		),
		_puzzle(
			12, "Blue Then Red", "",
			"Paint the north parcel blue. Stamp blue 1, then the reds 2 and 3.",
			"",
			"Hold the reds on a latch so they follow blue through the counter.",
			3, 3, [],
			[_source(0, 0, 0, ["gray"]), _source(0, 2, 0, ["red", "red"])],
			{"x": 2, "y": 1},
			[{"color": "blue", "count": 1}, {"color": "red", "count": 2}, {"color": "red", "count": 3}],
			[
				_block("painter", 1, 0, 1, "blue"),
				_block("counter", 1, 1, 0),
				_block("latch", 1, 2, 3),
			]
		),
		_puzzle(
			13, "The Long Way", "",
			"The top is bricked in. Bring the parcel around yellow, stamped 2.",
			"",
			"Come back under the bricks. The second pass is the one that reaches the dock.",
			4, 4,
			[_cell(0, 0), _cell(1, 0), _cell(2, 0), _cell(3, 0)],
			[_source(0, 1, 0, ["gray"])],
			{"x": 2, "y": 2},
			[{"color": "yellow", "count": 2}],
			[
				_block("counter", 1, 1, 0), _block("splitter", 2, 1, 0),
				_block("conveyor", 3, 1, 1), _block("conveyor", 3, 2, 1),
				_block("conveyor", 3, 3, 2), _block("conveyor", 2, 3, 2),
				_block("conveyor", 1, 3, 3), _block("painter", 1, 2, 3, "yellow"),
			]
		),
		_puzzle(
			14, "Blue After", "",
			"Deliver red 1, then blue 3.",
			"",
			"Paint red before the split. Paint blue on the loop, over the red.",
			5, 2, [],
			[_source(0, 0, 0, ["gray", "gray"])],
			{"x": 4, "y": 0},
			[{"color": "red", "count": 1}, {"color": "blue", "count": 3}],
			[
				_block("painter", 1, 0, 0, "red"), _block("counter", 2, 0, 0),
				_block("splitter", 3, 0, 0),
				_block("painter", 3, 1, 2, "blue"), _block("conveyor", 2, 1, 3),
			]
		),
		_puzzle(
			15, "Night Desk", "",
			"Deliver red 1, yellow 2, and blue 3.",
			"",
			"Hold yellow until red has left the counter. Blue follows yellow in.",
			5, 3, [],
			[_source(0, 1, 0, ["gray", "gray"]), _source(1, 0, 0, ["gray"])],
			{"x": 4, "y": 1},
			[{"color": "red", "count": 1}, {"color": "yellow", "count": 2}, {"color": "blue", "count": 3}],
			[
				_block("splitter", 1, 1, 0), _block("painter", 2, 1, 0, "red"),
				_block("counter", 3, 1, 0),
				_block("painter", 2, 0, 0, "yellow"), _block("latch", 3, 0, 1),
				_block("conveyor", 1, 2, 0), _block("painter", 2, 2, 0, "blue"),
				_block("conveyor", 3, 2, 3),
			]
		),
	]


static func unlocked_at(index: int) -> Array:
	var puzzles := all()
	var names: Array = []
	var last := mini(index, puzzles.size() - 1)
	for i in range(last + 1):
		var introduced := str(puzzles[i].get("unlocks", ""))
		if introduced != "" and not names.has(introduced):
			names.append(introduced)
	return names


static func _puzzle(id: int, title: String, unlocks: String, brief: String, how_to: String, hint: String, width: int, height: int, walls: Array, sources: Array, dock: Dictionary, order: Array, reference: Array) -> Dictionary:
	return {
		"id": id,
		"title": title,
		"unlocks": unlocks,
		"brief": brief,
		"how_to": how_to,
		"hint": hint,
		"width": width,
		"height": height,
		"walls": walls,
		"sources": sources,
		"dock": dock,
		"order": order,
		"reference": reference,
	}


static func _source(x: int, y: int, dir: int, colors: Array) -> Dictionary:
	var parcels: Array = []
	for color in colors:
		parcels.append({"color": str(color), "count": 0})
	return {"x": x, "y": y, "dir": dir, "parcels": parcels}


static func _block(type: String, x: int, y: int, dir: int, color: String = "") -> Dictionary:
	var block := {"type": type, "x": x, "y": y, "dir": dir}
	if color != "":
		block["color"] = color
	return block


static func _cell(x: int, y: int) -> Dictionary:
	return {"x": x, "y": y}
