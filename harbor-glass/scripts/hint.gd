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
# An astragal has four facings. North, east, south, and west are different pieces. While its row is dry, the facing and the next clockwise direction pass straight through in the same direction and color without a bounce. The other two directions stop before the cell. While that row is flooded, every beam stops at the waterline.
# A scotia has four facings. North, east, south, and west are different pieces. While its row is dry, the facing and the next counterclockwise direction pass straight through in the same direction and color without a bounce. The other two directions stop before the cell. While that row is flooded, every beam stops at the waterline. A north scotia is not a north astragal.
# A torus has four facings. North, east, south, and west are different pieces. While its row is dry, the opposite of the facing and the next clockwise direction pass straight through in the same direction and color without a bounce. The other two directions stop before the cell. Facing north, the open directions are south and east. While that row is flooded, every beam stops at the waterline. A north torus is not a north scotia and not a north astragal.
# An ogee has four facings. North, east, south, and west are different pieces. While its row is dry, the opposite of the facing and the next counterclockwise direction pass straight through in the same direction and color without a bounce. The other two directions stop before the cell. Facing north, the open directions are south and west. While that row is flooded, every beam stops at the waterline. A north ogee is not a north torus, not a north scotia, and not a north astragal.
# An ovolo has four facings. North, east, south, and west are different pieces. While its row is dry, every direction except the facing passes straight through in the same direction and color without a bounce. The facing stops before the cell. Facing north, east, south, and west pass, and north stops. While that row is flooded, every beam stops at the waterline. A north ovolo is not a north ogee, not a north torus, not a north scotia, and not a north astragal.
# A cavetto has four facings. North, east, south, and west are different pieces. While its row is dry, every direction except the opposite of the facing passes straight through in the same direction and color without a bounce. The opposite direction stops before the cell. Facing north, north, east, and west pass, and south stops. While that row is flooded, every beam stops at the waterline. A north cavetto is not a north ovolo, not a north ogee, not a north torus, and not a north scotia.
# A fillet has four facings. North, east, south, and west are different pieces. While its row is dry, only the opposite of the facing passes straight through in the same direction and color without a bounce. The facing and both sides stop before the cell. Facing north, south passes, and north, east, and west stop. While that row is flooded, every beam stops at the waterline. A north fillet is not a north cavetto, not a north casement, and not a north ovolo.
# A corona has four facings. Opposite facings open the same axis. While its row is dry, the two directions perpendicular to the facing pass straight through in the same direction and color without a bounce. The facing and the opposite stop before the cell. Facing north, east and west pass, and north and south stop. Turned once from north, north and south pass. While that row is flooded, every beam stops at the waterline. A north corona is not a transom, not a mullion, and not a north jamb.
# A bead has four facings. Opposite facings are not the same piece. While its row is dry, only the next clockwise direction passes straight through in the same direction and color without a bounce. The other three directions stop before the cell. Facing north, only east passes. One click faces east and passes only south. While that row is flooded, every beam stops at the waterline. A north bead is not a north casement, not a north fillet, not a north corona, and not a north astragal.
# A quirk has four facings. Opposite facings are not the same piece. While its row is dry, only the next counterclockwise direction passes straight through in the same direction and color without a bounce. The other three directions stop before the cell. Facing north, only west passes. One click faces east and passes only north. While that row is flooded, every beam stops at the waterline. A north quirk is not a north bead, not a north casement, not a north fillet, not a north corona, and not a north scotia.
# A cyma has four facings. Opposite facings are not the same piece. While its row is dry, only the facing passes straight through in the same direction and color without a bounce. The other three directions stop before the cell. Facing north, only north passes. One click faces east and passes only east. While that row is flooded, every beam stops at the waterline. A north cyma is not a north quirk, not a north bead, not a north fillet, not a north astragal, and not a north scotia.
# A fascia has four facings. Opposite facings are not the same piece. While its row is dry, every direction except the next clockwise one passes straight through in the same direction and color without a bounce. That clockwise direction stops before the cell. Facing north, east stops and the other three pass. One click faces east and stops south. While that row is flooded, every beam stops at the waterline. A north fascia is not a north cyma, not a north ovolo, and not a north cavetto.
# A soffit has four facings. Opposite facings are not the same piece. While its row is dry, every direction except the next counterclockwise one passes straight through in the same direction and color without a bounce. That counterclockwise direction stops before the cell. Facing north, west stops and north, east, and south pass. One click faces east and stops north. While that row is flooded, every beam stops at the waterline. A north soffit is not a north fascia, not a north quirk, and not a north cyma.
# A drip has four facings. Opposite facings are not the same piece. While its row is dry, it uses the soffit's rule: every direction except the next counterclockwise one passes. Facing north, west stops and north, east, and south pass. One click faces east and, while dry, stops north. While that row is flooded, the dry rule flips: only the dry-stopped direction passes, and the other three stop at the waterline. A flooded north drip passes only west. A flooded soffit stops that beam.
# A beak has four facings. It is the clockwise mirror of a drip. While its row is dry, every direction except the next clockwise one passes. Facing north, east stops and north, south, and west pass. One click faces east and stops south. While that row is flooded, only that dry-stopped direction passes. A flooded north beak passes only east. A flooded drip passes only west. A flooded fascia stops every beam.
# A hood has four facings. Opposite facings are not the same piece. While its row is dry, every direction except the facing passes. Facing north, north stops and east, south, and west pass. One click faces east and stops east. While that row is flooded, only the facing passes. A flooded north hood passes only north. A flooded beak passes only east. A flooded drip passes only west. A dry cyma passes only the facing, so it misses the dry charts.
# A throat has four facings. Opposite facings are not the same piece. While its row is dry, every direction except the opposite of the facing passes. Facing north, south stops and north, east, and west pass. One click faces east and stops west. While that row is flooded, only that opposite passes. A flooded north throat passes only south. A flooded north hood passes only north. A dry cavetto stops south and stays shut under water.
# A larmier has four facings. Opposite facings share the open set. While its row is dry, the two directions perpendicular to the facing pass. Facing north, east and west pass, and north and south stop. One click faces east and passes north and south. While that row is flooded, only the facing and the opposite pass. A flooded north larmier passes only north and south. A flooded corona stops that axis. A flooded north throat passes only south.

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
