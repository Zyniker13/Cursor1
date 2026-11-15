extends RefCounted

const SpareKey = preload("res://scripts/case_data.gd")
const RehearsalScore = preload("res://scripts/rehearsal_score.gd")
const GiltStamp = preload("res://scripts/gilt_stamp.gd")
const FerryBell = preload("res://scripts/ferry_bell.gd")
const WeatherSlate = preload("res://scripts/weather_slate.gd")
const LoomShuttle = preload("res://scripts/loom_shuttle.gd")
const HiveSmoker = preload("res://scripts/hive_smoker.gd")
const GlassPontil = preload("res://scripts/glass_pontil.gd")
const PressProof = preload("res://scripts/press_proof.gd")
const AssayCup = preload("res://scripts/assay_cup.gd")
const KilnChalk = preload("res://scripts/kiln_chalk.gd")
const TideLedger = preload("res://scripts/tide_ledger.gd")

const CASES: Array = [SpareKey, RehearsalScore, GiltStamp, FerryBell, WeatherSlate, LoomShuttle, HiveSmoker, GlassPontil, PressProof, AssayCup, KilnChalk, TideLedger]


static func all() -> Array:
	return CASES.duplicate()
