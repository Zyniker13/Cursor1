extends RefCounted

const SpareKey = preload("res://scripts/case_data.gd")
const RehearsalScore = preload("res://scripts/rehearsal_score.gd")
const GiltStamp = preload("res://scripts/gilt_stamp.gd")

const CASES: Array = [SpareKey, RehearsalScore, GiltStamp]


static func all() -> Array:
	return CASES.duplicate()
