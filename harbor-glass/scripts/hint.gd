extends RefCounted
class_name HintBook

# Hints compare the live state to the authored solution. They return the id of
# one wrong piece (or "tide"), never a rotation, a socket name, or the full
# layout. A state that already matches the solution produces no mark.
# Mirror, tide mirror, and pane rotations are compared after normalizing
# 180-degree repeats, so an equivalent facing is not reported as wrong.

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
