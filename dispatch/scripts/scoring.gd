extends RefCounted

## Scoreboard text. Par cycles and par blocks come only from simulating the
## puzzle's reference graph. This is the string the game shows after a submit.

const Sim = preload("res://scripts/sim.gd")


static func compute_par(puzzle: Dictionary) -> Dictionary:
	var result: Dictionary = Sim.run(puzzle, puzzle["reference"])
	return {
		"cycles": int(result["cycles"]),
		"blocks": int(result["blocks"]),
		"success": bool(result["success"]),
	}


static func present(puzzle: Dictionary, player_result: Dictionary) -> String:
	if not bool(player_result.get("success", false)):
		return "FAILED\n\n%s" % _reason(str(player_result.get("reason", "")))
	var par := compute_par(puzzle)
	return "DELIVERED\n\nCycles %d\nPar cycles %d\n\nBlocks %d\nPar blocks %d" % [
		int(player_result["cycles"]),
		int(par["cycles"]),
		int(player_result["blocks"]),
		int(par["blocks"]),
	]


static func _reason(code: String) -> String:
	match code:
		"tick_cap":
			return "The parcels looped until the tick cap."
		"stuck":
			return "The belt is stuck and the order is incomplete."
		"wrong_delivery":
			return "A parcel arrived that does not match the order."
		"invalid":
			return "That layout cannot run."
		_:
			return "The order was not delivered."
