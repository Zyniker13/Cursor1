extends RefCounted
class_name HintBook

# Hints compare the live state to the authored solution. They return the id of
# one wrong piece (or "tide"), never a rotation, a socket name, or the full
# layout. A state that already matches the solution produces no mark.
# Mirror, tide mirror, and pane rotations are compared after normalizing
# 180-degree repeats, so an equivalent facing is not reported as wrong.
# A shutter has no facing. Dry stops the beam, and flooded water lets it pass.
# A stain has no facing. Its two states are red and blue, not a rotation.
# A vane has four facings. North, east, south, and west are different pieces.
# A well has no facing. Rotation is ignored, the same way a shutter ignores it.
# A siphon has no facing. Rotation is ignored, the same way a well ignores it.
# A sluice has four facings. North, east, south, and west are different pieces.
# A hint uses that facing. Dry, every facing stops the beam.
# A weir has four facings. North, east, south, and west are different pieces.
# A hint uses that facing. Dry, every facing stops the beam. Flood swaps red
# with blue and leaves along the facing. White stays white.
# A lintel has no facing, so rotation is ignored: while its row is dry a beam passes straight through in the same direction and color without a bounce, and while that row is flooded the beam stops at the waterline and does not enter.
# A mullion has no facing, so rotation is ignored: while its row is dry a north-south beam passes straight through in the same direction and color without a bounce, an east-west beam stops before the cell, and while that row is flooded every beam stops at the waterline.
# A transom has no facing, so rotation is ignored: while its row is dry an east-west beam passes straight through in the same direction and color without a bounce, a north-south beam stops before the cell, and while that row is flooded every beam stops at the waterline.
# A casement has four facings. North, east, south, and west are different pieces. While its row is dry, only a beam already traveling that way passes straight through in the same direction and color without a bounce. Every other direction stops before the cell. While that row is flooded, every beam stops at the waterline.
# A jamb has four facings. North, east, south, and west are different pieces. While its row is dry, north or south passes both north and south, and east or west passes both east and west, in the same direction and color without a bounce. The other axis stops before the cell. While that row is flooded, every beam stops at the waterline.

const Tracer := preload("res://scripts/beam_tracer.gd")

static func wrong_pieces(chart: Dictionary, state: Dictionary) -> PackedStringArray:
	var wrong := PackedStringArray()
	var pieces: Dictionary = state["pieces"]
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		var id := str(piece["id"])
		var cur: Dictionary = pieces[id]
		var kind := str(piece["kind"])
		var rot_diff := Tracer.norm_rot(kind, int(cur["rot"])) != Tracer.norm_rot(kind, int(piece["solution_rot"]))
		var sock_diff := str(cur["socket"]) != str(piece["solution_socket"])
		if rot_diff or sock_diff:
			wrong.append(id)
	if int(state["tide_index"]) != int(chart["solution_tide_index"]):
		wrong.append("tide")
	return wrong

static func first_wrong(chart: Dictionary, state: Dictionary) -> String:
	var wrong := wrong_pieces(chart, state)
	if wrong.is_empty():
		return ""
	return wrong[0]

# hints_left is the remaining budget. current_mark is the piece already shown.
# Asking again about the same piece does not spend another hint and does not
# reveal anything new. A matching solution returns an empty mark.
static func take_hint(chart: Dictionary, state: Dictionary, hints_left: int, current_mark: String) -> Dictionary:
	var wrong := wrong_pieces(chart, state)
	if wrong.is_empty():
		return {"hints_left": hints_left, "mark": "", "kind": "match"}
	var first := wrong[0]
	if current_mark != "" and first == current_mark:
		return {"hints_left": hints_left, "mark": current_mark, "kind": "same"}
	if hints_left <= 0:
		return {"hints_left": 0, "mark": current_mark, "kind": "empty"}
	return {"hints_left": hints_left - 1, "mark": first, "kind": "new"}
