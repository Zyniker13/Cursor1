extends RefCounted

const SpareKey = preload("res://scripts/case_data.gd")
const RehearsalScore = preload("res://scripts/rehearsal_score.gd")
const GiltStamp = preload("res://scripts/gilt_stamp.gd")
const FerryBell = preload("res://scripts/ferry_bell.gd")
const WeatherSlate = preload("res://scripts/weather_slate.gd")

const CASES: Array = [SpareKey, RehearsalScore, GiltStamp, FerryBell, WeatherSlate]


static func all() -> Array:
	return CASES.duplicate()
