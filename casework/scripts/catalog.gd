extends RefCounted

const SpareKey = preload("res://scripts/case_data.gd")
const RehearsalScore = preload("res://scripts/rehearsal_score.gd")

const CASES: Array = [SpareKey, RehearsalScore]


static func all() -> Array:
	return CASES.duplicate()
