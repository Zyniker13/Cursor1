extends RefCounted

## Buildings 1 through 5. Directions: 0 east, 1 south, 2 west, 3 north.
## `unlocks` is the single new block this puzzle introduces, or "".

const INTRO: Array[String] = ["conveyor", "latch", "splitter", "painter", "counter", "filter", "primer", "bridge", "turn"]


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
		_puzzle(
			16, "Color Gate", "filter",
			"Red has to reach the dock before the two blues.",
			"",
			"A filter sends its color straight. Any other color turns clockwise.",
			5, 3, [],
			[_source(0, 0, 0, ["blue", "blue", "red"])],
			{"x": 4, "y": 0},
			[{"color": "red"}, {"color": "blue"}, {"color": "blue"}],
			[
				_block("filter", 1, 0, 0, "red"),
				_block("conveyor", 2, 0, 0), _block("conveyor", 3, 0, 0),
				_block("conveyor", 1, 1, 1),
				_block("conveyor", 1, 2, 0), _block("conveyor", 2, 2, 0), _block("conveyor", 3, 2, 0),
				_block("conveyor", 4, 2, 3), _block("conveyor", 4, 1, 3),
			]
		),
		_puzzle(
			17, "Side Coat", "",
			"Deliver red, then both blues painted yellow.",
			"",
			"Blues miss the filter. Paint them on the south lane.",
			5, 3, [],
			[_source(0, 0, 0, ["blue", "blue", "red"])],
			{"x": 4, "y": 0},
			[{"color": "red"}, {"color": "yellow"}, {"color": "yellow"}],
			[
				_block("filter", 1, 0, 0, "red"),
				_block("conveyor", 2, 0, 0), _block("conveyor", 3, 0, 0),
				_block("conveyor", 1, 1, 1),
				_block("conveyor", 1, 2, 0), _block("painter", 2, 2, 0, "yellow"),
				_block("conveyor", 3, 2, 0),
				_block("conveyor", 4, 2, 3), _block("conveyor", 4, 1, 3),
			]
		),
		_puzzle(
			18, "Stamp the Match", "",
			"Stamp red 1, then the blues 2 and 3.",
			"",
			"Red takes the arrow into the counter. Blues come up behind it.",
			5, 3, [],
			[_source(0, 0, 0, ["blue", "blue", "red"])],
			{"x": 4, "y": 0},
			[{"color": "red", "count": 1}, {"color": "blue", "count": 2}, {"color": "blue", "count": 3}],
			[
				_block("filter", 1, 0, 0, "red"),
				_block("conveyor", 2, 0, 0), _block("counter", 3, 0, 0),
				_block("conveyor", 1, 1, 1),
				_block("conveyor", 1, 2, 0), _block("conveyor", 2, 2, 0),
				_block("conveyor", 3, 2, 3), _block("conveyor", 3, 1, 3),
			]
		),
		_puzzle(
			19, "Hold the Blue", "",
			"Stamp the reds 1 and 2. Blue is last.",
			"",
			"Hold blue on the latch so the reds can take the counter.",
			5, 3, [],
			[_source(0, 1, 0, ["blue", "red", "red"])],
			{"x": 4, "y": 1},
			[{"color": "red", "count": 1}, {"color": "red", "count": 2}, {"color": "blue", "count": 3}],
			[
				_block("filter", 1, 1, 0, "red"),
				_block("conveyor", 2, 1, 0), _block("counter", 3, 1, 0),
				_block("conveyor", 1, 2, 0), _block("conveyor", 2, 2, 0),
				_block("latch", 3, 2, 3),
			]
		),
		_puzzle(
			20, "Become Red", "",
			"Deliver red 2, then red 3.",
			"",
			"Blue misses the filter. Paint it red on the way back.",
			4, 2, [],
			[_source(0, 0, 0, ["blue", "red"])],
			{"x": 3, "y": 0},
			[{"color": "red", "count": 2}, {"color": "red", "count": 3}],
			[
				_block("counter", 1, 0, 0), _block("filter", 2, 0, 0, "red"),
				_block("painter", 2, 1, 2, "red"), _block("conveyor", 1, 1, 3),
			]
		),
		_puzzle(
			21, "Two Tallies", "",
			"Deliver blue 1, blue 2, red 1, and red 2.",
			"",
			"Give each color its own counter. Blues take the arrow.",
			5, 2, [],
			[_source(0, 0, 0, ["blue", "blue", "red", "red"])],
			{"x": 4, "y": 0},
			[{"color": "blue", "count": 1}, {"color": "blue", "count": 2}, {"color": "red", "count": 1}, {"color": "red", "count": 2}],
			[
				_block("filter", 1, 0, 0, "blue"),
				_block("counter", 2, 0, 0), _block("conveyor", 3, 0, 0),
				_block("conveyor", 1, 1, 0), _block("counter", 2, 1, 0),
				_block("conveyor", 3, 1, 3),
			]
		),
		_puzzle(
			22, "Night Wing", "",
			"Deliver red 1, yellow 2, and blue 3.",
			"",
			"Paint the second red yellow. Let blue follow it into the counter.",
			5, 2, [],
			[_source(0, 0, 0, ["red", "red", "blue"])],
			{"x": 4, "y": 0},
			[{"color": "red", "count": 1}, {"color": "yellow", "count": 2}, {"color": "blue", "count": 3}],
			[
				_block("splitter", 1, 0, 0), _block("filter", 2, 0, 0, "red"),
				_block("counter", 3, 0, 0),
				_block("painter", 1, 1, 0, "yellow"), _block("conveyor", 2, 1, 0),
				_block("conveyor", 3, 1, 3),
			]
		),
		_puzzle(
			23, "Spare the Red", "primer",
			"Paint the gray parcel blue. The red parcel has to stay red.",
			"",
			"A primer paints gray and leaves a color that is already there.",
			6, 3, [],
			[_source(0, 1, 0, ["gray", "red"])],
			{"x": 5, "y": 1},
			[{"color": "blue"}, {"color": "red"}],
			[
				_block("conveyor", 1, 1, 0), _block("primer", 2, 1, 0, "blue"),
				_block("conveyor", 3, 1, 0), _block("conveyor", 4, 1, 0),
			]
		),
		_puzzle(
			24, "Middle Yellow", "",
			"Stamp red 1, yellow 2, and blue 3. Only the middle parcel is gray.",
			"",
			"Paint only the gray. The counter stamps them in chute order.",
			6, 3, [],
			[_source(0, 1, 0, ["red", "gray", "blue"])],
			{"x": 5, "y": 1},
			[{"color": "red", "count": 1}, {"color": "yellow", "count": 2}, {"color": "blue", "count": 3}],
			[
				_block("primer", 1, 1, 0, "yellow"), _block("counter", 2, 1, 0),
				_block("conveyor", 3, 1, 0), _block("conveyor", 4, 1, 0),
			]
		),
		_puzzle(
			25, "Hold the South", "",
			"Deliver red, then yellow, then blue. Blue keeps its color.",
			"",
			"Red takes the filter. Paint gray on the south belt, and hold that belt so red arrives first.",
			4, 2, [],
			[_source(0, 0, 0, ["gray", "blue", "red"])],
			{"x": 3, "y": 0},
			[{"color": "red"}, {"color": "yellow"}, {"color": "blue"}],
			[
				_block("filter", 1, 0, 0, "red"), _block("conveyor", 2, 0, 0),
				_block("primer", 1, 1, 0, "yellow"), _block("latch", 2, 1, 0),
				_block("conveyor", 3, 1, 3),
			]
		),
		_puzzle(
			26, "Red Ahead", "",
			"Deliver red, then blue. The chute sends blue first.",
			"",
			"Prime the gray red so the filter lets it through. Blue turns off and comes up at the dock.",
			4, 2, [],
			[_source(0, 0, 0, ["blue", "gray"])],
			{"x": 3, "y": 0},
			[{"color": "red"}, {"color": "blue"}],
			[
				_block("primer", 1, 0, 0, "red"), _block("filter", 2, 0, 0, "red"),
				_block("conveyor", 2, 1, 0), _block("conveyor", 3, 1, 3),
			]
		),
		_puzzle(
			27, "Shared Coat", "",
			"Stamp red 1, then yellow 2. Red is already red.",
			"",
			"Hold the gray on the latch. The primer paints gray and leaves red alone.",
			4, 3, [],
			[_source(0, 0, 0, ["red"]), _source(0, 2, 0, ["gray"])],
			{"x": 3, "y": 1},
			[{"color": "red", "count": 1}, {"color": "yellow", "count": 2}],
			[
				_block("conveyor", 1, 0, 1), _block("latch", 1, 2, 3),
				_block("primer", 1, 1, 0, "yellow"), _block("counter", 2, 1, 0),
			]
		),
		_puzzle(
			28, "Stamp Blue First", "",
			"Deliver blue 1, then red 2.",
			"",
			"Prime gray red, then let blue through the filter into the counter. Red comes back behind it.",
			5, 2, [],
			[_source(0, 0, 0, ["gray", "blue"])],
			{"x": 4, "y": 0},
			[{"color": "blue", "count": 1}, {"color": "red", "count": 2}],
			[
				_block("primer", 1, 0, 0, "red"), _block("filter", 2, 0, 0, "blue"),
				_block("counter", 3, 0, 0),
				_block("conveyor", 2, 1, 0), _block("conveyor", 3, 1, 3),
			]
		),
		_puzzle(
			29, "Night Coat", "",
			"Deliver red 1, yellow 2, and blue 3.",
			"",
			"Red takes the filter into the counter. Paint gray yellow on the south belt and hold blue behind it.",
			5, 3, [],
			[_source(0, 1, 0, ["gray", "blue", "red"])],
			{"x": 4, "y": 1},
			[{"color": "red", "count": 1}, {"color": "yellow", "count": 2}, {"color": "blue", "count": 3}],
			[
				_block("filter", 1, 1, 0, "red"), _block("conveyor", 2, 1, 0),
				_block("counter", 3, 1, 0),
				_block("conveyor", 1, 2, 0), _block("primer", 2, 2, 0, "yellow"),
				_block("latch", 3, 2, 3),
			]
		),
		_puzzle(
			30, "Over the Brick", "bridge",
			"The belt is bricked in. Carry the parcel over the brick to the dock.",
			"",
			"A bridge sets a parcel down two steps along its arrow, over the cell in front.",
			4, 3,
			[
				_cell(0, 0), _cell(1, 0), _cell(2, 0), _cell(3, 0),
				_cell(0, 2), _cell(1, 2), _cell(2, 2), _cell(3, 2),
				_cell(2, 1),
			],
			[_source(0, 1, 0, ["gray"])],
			{"x": 3, "y": 1},
			[{"color": "gray"}],
			[_block("bridge", 1, 1, 0)]
		),
		_puzzle(
			31, "Lane Cross", "",
			"Deliver red, then blue. Blue's belt crosses under the jump.",
			"",
			"Bridge red onto the dock. Blue cannot take that cell, so send blue around.",
			4, 3,
			[_cell(0, 0), _cell(1, 0), _cell(3, 0), _cell(0, 2), _cell(1, 2)],
			[_source(0, 1, 0, ["red"]), _source(2, 0, 1, ["blue"])],
			{"x": 3, "y": 1},
			[{"color": "red"}, {"color": "blue"}],
			[
				_block("bridge", 1, 1, 0),
				_block("conveyor", 2, 1, 1),
				_block("conveyor", 2, 2, 0), _block("conveyor", 3, 2, 3),
			]
		),
		_puzzle(
			32, "Count Across", "",
			"Stamp the two parcels 1, then 2. The counter is past the brick.",
			"",
			"Bridge onto the counter. It stamps a parcel on the tick after the parcel lands.",
			6, 3,
			[
				_cell(0, 0), _cell(1, 0), _cell(2, 0), _cell(3, 0), _cell(4, 0), _cell(5, 0),
				_cell(0, 1), _cell(3, 1),
				_cell(0, 2), _cell(1, 2), _cell(2, 2), _cell(3, 2), _cell(4, 2), _cell(5, 2),
			],
			[_source(1, 1, 0, ["gray", "gray"])],
			{"x": 5, "y": 1},
			[{"count": 1}, {"count": 2}],
			[
				_block("bridge", 2, 1, 0),
				_block("counter", 4, 1, 0),
			]
		),
		_puzzle(
			33, "Hold Under", "",
			"Deliver red, then blue. Blue waits under the jump.",
			"",
			"Bridge red over the latch and onto the dock. Blue leaves once that dock is clear.",
			3, 3, [],
			[_source(1, 0, 0, ["red"]), _source(1, 1, 0, ["blue"])],
			{"x": 2, "y": 2},
			[{"color": "red"}, {"color": "blue"}],
			[
				_block("bridge", 2, 0, 1),
				_block("latch", 2, 1, 1),
			]
		),
		_puzzle(
			34, "Skip the Coat", "",
			"Deliver blue, then yellow. Only the gray parcel should be painted.",
			"",
			"Send blue over the brick. Gray turns off the splitter and takes the yellow painter.",
			5, 2, [_cell(3, 0), _cell(0, 1)],
			[_source(0, 0, 0, ["blue", "gray"])],
			{"x": 4, "y": 0},
			[{"color": "blue"}, {"color": "yellow"}],
			[
				_block("splitter", 1, 0, 0), _block("bridge", 2, 0, 0),
				_block("conveyor", 1, 1, 0), _block("painter", 2, 1, 0, "yellow"),
				_block("conveyor", 3, 1, 0), _block("conveyor", 4, 1, 3),
			]
		),
		_puzzle(
			35, "Twice Yellow", "",
			"Deliver the parcel yellow, stamped 2. A brick sits in front of the dock.",
			"",
			"Loop it through the counter. Paint it on the way back, then bridge over the brick.",
			6, 2,
			[_cell(0, 0), _cell(3, 0), _cell(4, 0), _cell(5, 0), _cell(4, 1)],
			[_source(0, 1, 0, ["gray"])],
			{"x": 5, "y": 1},
			[{"color": "yellow", "count": 2}],
			[
				_block("counter", 1, 1, 0), _block("splitter", 2, 1, 3),
				_block("painter", 2, 0, 2, "yellow"), _block("conveyor", 1, 0, 1),
				_block("bridge", 3, 1, 0),
			]
		),
		_puzzle(
			36, "Night Span", "",
			"Deliver red 1, yellow 2, and blue 3.",
			"",
			"Red takes the filter and bridges the brick onto the counter. Paint gray yellow on the south belt. Blue keeps its color and follows.",
			6, 3, [_cell(3, 1)],
			[_source(0, 1, 0, ["gray", "blue", "red"])],
			{"x": 5, "y": 1},
			[{"color": "red", "count": 1}, {"color": "yellow", "count": 2}, {"color": "blue", "count": 3}],
			[
				_block("filter", 1, 1, 0, "red"), _block("bridge", 2, 1, 0),
				_block("counter", 4, 1, 0),
				_block("conveyor", 1, 2, 0), _block("primer", 2, 2, 0, "yellow"),
				_block("conveyor", 3, 2, 0), _block("conveyor", 4, 2, 3),
			]
		),
		_puzzle(
			37, "Quarter Turn", "turn",
			"The dock is clockwise from the belt. Turn the parcel toward it.",
			"",
			"A turn rotates the parcel one quarter clockwise and does not move it on that tick. It steps off in the new facing on the next tick.",
			3, 2,
			[_cell(2, 0), _cell(0, 1), _cell(2, 1)],
			[_source(0, 0, 0, ["gray"])],
			{"x": 1, "y": 1},
			[{"color": "gray"}],
			[_block("turn", 1, 0, 0)]
		),
		_puzzle(
			38, "Cut In", "",
			"Deliver two blues, then red, then the last blue.",
			"",
			"Turn red clockwise onto the belt as a blue leaves. The chute refills that cell, so a latch never finds it empty.",
			4, 3,
			[
				_cell(0, 0), _cell(3, 0), _cell(0, 1), _cell(1, 1),
				_cell(0, 2), _cell(1, 2), _cell(3, 2),
			],
			[_source(1, 0, 0, ["red"]), _source(2, 2, 3, ["blue", "blue", "blue"])],
			{"x": 3, "y": 1},
			[{"color": "blue"}, {"color": "blue"}, {"color": "red"}, {"color": "blue"}],
			[
				_block("turn", 2, 0, 0),
				_block("conveyor", 2, 1, 0),
			]
		),
		_puzzle(
			39, "Bend Stamp", "",
			"Stamp the parcel 1. The counter is one quarter clockwise.",
			"",
			"Turn onto the counter. It stamps a parcel on the tick after the parcel lands.",
			3, 3,
			[_cell(0, 0), _cell(1, 0), _cell(2, 0), _cell(2, 1), _cell(0, 2)],
			[_source(0, 1, 0, ["gray"])],
			{"x": 2, "y": 2},
			[{"count": 1}],
			[
				_block("turn", 1, 1, 0),
				_block("counter", 1, 2, 0),
			]
		),
		_puzzle(
			40, "Clear the Dock", "",
			"Deliver red, then blue.",
			"",
			"Turn red clockwise onto the dock. The latch holds blue so they do not claim that dock on the same tick.",
			4, 2,
			[_cell(2, 0), _cell(0, 1)],
			[_source(0, 0, 0, ["red"]), _source(3, 0, 1, ["blue"])],
			{"x": 1, "y": 1},
			[{"color": "red"}, {"color": "blue"}],
			[
				_block("turn", 1, 0, 0),
				_block("conveyor", 2, 1, 2),
				_block("latch", 3, 1, 2),
			]
		),
		_puzzle(
			41, "Two Rights", "",
			"Deliver blue, then red. One turn has to send them different ways.",
			"",
			"Blue is facing west, so the turn sends it north. Red is facing east, so the turn sends it south.",
			6, 4,
			[
				_cell(0, 0), _cell(1, 0), _cell(2, 0), _cell(3, 0), _cell(4, 0), _cell(5, 0),
				_cell(0, 1), _cell(1, 1), _cell(2, 1),
				_cell(0, 3), _cell(1, 3), _cell(2, 3),
			],
			[_source(0, 2, 0, ["red"]), _source(4, 2, 2, ["blue"])],
			{"x": 5, "y": 1},
			[{"color": "blue"}, {"color": "red"}],
			[
				_block("conveyor", 1, 2, 0), _block("conveyor", 2, 2, 0), _block("turn", 3, 2, 0),
				_block("conveyor", 3, 1, 0), _block("conveyor", 4, 1, 0),
				_block("conveyor", 3, 3, 0), _block("conveyor", 4, 3, 0),
				_block("conveyor", 5, 3, 3), _block("conveyor", 5, 2, 3),
			]
		),
		_puzzle(
			42, "Second Bend", "",
			"Deliver the parcel yellow, stamped 2.",
			"",
			"Loop it through the counter. Paint it yellow on the way back. The second send faces the turn, which points it at the dock.",
			5, 3,
			[
				_cell(0, 0), _cell(3, 0), _cell(4, 0),
				_cell(4, 1),
				_cell(0, 2), _cell(1, 2), _cell(2, 2), _cell(4, 2),
			],
			[_source(0, 1, 0, ["gray"])],
			{"x": 3, "y": 2},
			[{"color": "yellow", "count": 2}],
			[
				_block("counter", 1, 1, 0), _block("splitter", 2, 1, 3),
				_block("painter", 2, 0, 2, "yellow"), _block("conveyor", 1, 0, 1),
				_block("turn", 3, 1, 0),
			]
		),
		_puzzle(
			43, "Night Turn", "",
			"Deliver red 1, yellow 2, and blue 3.",
			"",
			"Red takes the filter and turns south onto the counter. Gray takes the long belt and is primed yellow. Blue keeps its color and follows.",
			4, 4,
			[
				_cell(0, 0), _cell(1, 0), _cell(2, 0), _cell(3, 0),
				_cell(3, 1), _cell(3, 3),
			],
			[_source(0, 1, 0, ["gray", "blue", "red"])],
			{"x": 3, "y": 2},
			[{"color": "red", "count": 1}, {"color": "yellow", "count": 2}, {"color": "blue", "count": 3}],
			[
				_block("filter", 1, 1, 0, "red"), _block("turn", 2, 1, 0),
				_block("conveyor", 1, 2, 2), _block("conveyor", 0, 2, 1), _block("conveyor", 0, 3, 0),
				_block("primer", 1, 3, 0, "yellow"), _block("conveyor", 2, 3, 3),
				_block("counter", 2, 2, 0),
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
		"building": 5 if id >= 37 else 4 if id >= 30 else 3 if id >= 23 else 2 if id >= 16 else 1,
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
