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
const NightBell = preload("res://scripts/night_bell.gd")
const SaltMark = preload("res://scripts/salt_mark.gd")
const WickTrim = preload("res://scripts/wick_trim.gd")
const GlassAnneal = preload("res://scripts/glass_anneal.gd")
const OrchardGraft = preload("res://scripts/orchard_graft.gd")
const DyeVat = preload("res://scripts/dye_vat.gd")
const TarKettle = preload("res://scripts/tar_kettle.gd")
const CorkPress = preload("res://scripts/cork_press.gd")
const NetLoft = preload("res://scripts/net_loft.gd")
const CaskHoop = preload("res://scripts/cask_hoop.gd")
const LinenFold = preload("res://scripts/linen_fold.gd")
const Dovetail = preload("res://scripts/dovetail.gd")
const Mortise = preload("res://scripts/mortise.gd")
const Rebate = preload("res://scripts/rebate.gd")

const CASES: Array = [SpareKey, RehearsalScore, GiltStamp, FerryBell, WeatherSlate, LoomShuttle, HiveSmoker, GlassPontil, PressProof, AssayCup, KilnChalk, TideLedger, NightBell, SaltMark, WickTrim, GlassAnneal, OrchardGraft, DyeVat, TarKettle, CorkPress, NetLoft, CaskHoop, LinenFold, Dovetail, Mortise, Rebate]


static func all() -> Array:
	return CASES.duplicate()
