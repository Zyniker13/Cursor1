extends RefCounted
class_name Palette

# Night quay, warm lantern glass, clear water. Flat colors only.

const NIGHT := Color("071018")
const PANEL := Color("101820")
const PANEL_EDGE := Color("314556")
const STONE := Color("1b2631")
const STONE_ALT := Color("243140")
const GRID_LINE := Color("3a4d5e")
const GLASS := Color("d7e8ee")
const GLASS_DIM := Color("8eafba")
const GLASS_EDGE := Color("f4fbff")
const LANTERN := Color("ffb15a")
const LANTERN_HOT := Color("ffe4bc")
const BEAM_WHITE := Color("ffe6c2")
const BEAM_RED := Color("ff5a6a")
const BEAM_BLUE := Color("74c6ff")
const WOOD := Color("8d6848")
const WOOD_DARK := Color("5a4030")
const HULL := Color("121a24")
const HULL_EDGE := Color("a9bdd0")
const SELECT := Color("ffe08a")
const HINT := Color("ffcf70")
const TEXT := Color("e8eef2")
const MUTED := Color("93a4b3")
const WATER_DEEP := Color("0c3044")
const FOAM := Color("d7f1f8")
const TIDE := Color("9fd7e4")
const TIDE_DEEP := Color("1a6d84")
const GOOD := Color("c5ead0")
const WARN := Color("ffb4a8")
const SET_GLASS := Color("9bb0b8")
const PILE := Color("2a241e")
const PILE_EDGE := Color("6b5c4c")

static func beam(color: String) -> Color:
	match color:
		"red":
			return BEAM_RED
		"blue":
			return BEAM_BLUE
		_:
			return BEAM_WHITE
