extends RefCounted

const Sport = preload("res://scripts/sport.gd")

var seed: int = 0
var week: int = 0
var rosters: Array = []
var player_roster: Array = []
var results: Array = []
var pending: Dictionary = {}


func _init(series_seed: int) -> void:
	seed = series_seed
	week = 0
	results = []
	pending = {}
	var clubs := Sport.create_clubs(series_seed)
	rosters = clubs["rosters"]
	player_roster = rosters[Sport.PLAYER_INDEX]


func is_over() -> bool:
	return week >= Sport.SERIES_WEEKS


func fixture() -> Dictionary:
	return Sport.fixture(week)


func player_plays() -> bool:
	if is_over():
		return false
	var card := fixture()
	return int(card["home"]) == Sport.PLAYER_INDEX or int(card["away"]) == Sport.PLAYER_INDEX


func player_bats_second() -> bool:
	if not player_plays():
		return false
	return int(fixture()["home"]) == Sport.PLAYER_INDEX


func table() -> Array:
	return Sport.table_from_results(results)


func record() -> Dictionary:
	var row: Dictionary = table()[Sport.PLAYER_INDEX]
	return {
		"wins": int(row["wins"]),
		"losses": int(row["losses"]),
		"ties": int(row["ties"]),
		"points": int(row["points"]),
		"played": int(row["played"]),
	}


func goal_met() -> bool:
	return Sport.goal_reached(table())


func _club_plan(club_index: int) -> Dictionary:
	return Sport.opponent_plan(rosters[club_index], week, club_index)


func begin_match(lineup: Array, tactic: String, focus: String) -> Dictionary:
	if is_over():
		return {"ok": false, "error": "The series is already over."}
	if not Sport.STATS.has(focus):
		return {"ok": false, "error": "Pick a training focus."}
	var card := fixture()
	var home_i := int(card["home"])
	var away_i := int(card["away"])
	var playing := home_i == Sport.PLAYER_INDEX or away_i == Sport.PLAYER_INDEX
	if playing:
		if not Sport.is_legal_lineup(player_roster.size(), lineup):
			return {"ok": false, "error": "The lineup needs four different players."}
		if not Sport.TACTICS.has(tactic):
			return {"ok": false, "error": "Pick a tactic."}
	var home_indices: Array
	var away_indices: Array
	var home_tactic: String
	var away_tactic: String
	if home_i == Sport.PLAYER_INDEX:
		home_indices = lineup.duplicate()
		home_tactic = tactic
	else:
		var home_plan := _club_plan(home_i)
		home_indices = (home_plan["lineup"] as Array).duplicate()
		home_tactic = str(home_plan["tactic"])
	if away_i == Sport.PLAYER_INDEX:
		away_indices = lineup.duplicate()
		away_tactic = tactic
	else:
		var away_plan := _club_plan(away_i)
		away_indices = (away_plan["lineup"] as Array).duplicate()
		away_tactic = str(away_plan["tactic"])
	var played: Dictionary = Sport.simulate_match(
		Sport.match_seed_for(seed, week),
		Sport.lineup_players(rosters[home_i], home_indices),
		Sport.lineup_players(rosters[away_i], away_indices),
		home_tactic,
		away_tactic,
		str(card["home_club"]),
		str(card["away_club"])
	)
	played["ok"] = true
	played["week"] = week
	played["home_index"] = home_i
	played["away_index"] = away_i
	played["bye_index"] = int(card["bye"])
	played["bye_club"] = str(card["bye_club"])
	played["player_played"] = playing
	played["player_bats_second"] = playing and home_i == Sport.PLAYER_INDEX
	played["player_tactic"] = tactic
	played["player_lineup"] = lineup.duplicate()
	played["player_focus"] = focus
	played["home_tactic"] = home_tactic
	played["away_tactic"] = away_tactic
	played["home_lineup"] = home_indices
	played["away_lineup"] = away_indices
	var focuses: Array = []
	for club_index in Sport.CLUB_COUNT:
		if club_index == Sport.PLAYER_INDEX:
			focuses.append(focus)
		else:
			focuses.append(str(_club_plan(club_index)["training"]))
	played["focuses"] = focuses
	if playing:
		var opponent_i := away_i if home_i == Sport.PLAYER_INDEX else home_i
		played["opponent_index"] = opponent_i
		played["opponent_club"] = str(Sport.CLUB_NAMES[opponent_i])
		played["opponent_tactic"] = away_tactic if opponent_i == away_i else home_tactic
		played["opponent_lineup"] = away_indices if opponent_i == away_i else home_indices
		played["opponent_focus"] = str(focuses[opponent_i])
		if home_i == Sport.PLAYER_INDEX:
			played["player_score"] = int(played["home_score"])
			played["opponent_score"] = int(played["away_score"])
		else:
			played["player_score"] = int(played["away_score"])
			played["opponent_score"] = int(played["home_score"])
		if int(played["player_score"]) > int(played["opponent_score"]):
			played["player_result"] = "win"
		elif int(played["player_score"]) < int(played["opponent_score"]):
			played["player_result"] = "loss"
		else:
			played["player_result"] = "tie"
	else:
		played["opponent_club"] = ""
		played["opponent_tactic"] = ""
		played["opponent_focus"] = ""
		played["opponent_lineup"] = []
		played["player_result"] = "bye"
	pending = played
	return played


func commit_match() -> Dictionary:
	if pending.is_empty() or not bool(pending.get("ok", false)):
		return {"ok": false, "error": "No match is waiting to be recorded."}
	var focuses: Array = pending["focuses"]
	var notes: Array = []
	for club_index in Sport.CLUB_COUNT:
		notes.append(Sport.apply_training(rosters[club_index], str(focuses[club_index])))
	pending["training_notes"] = notes
	results.append(pending)
	pending = {}
	week += 1
	return {
		"ok": true,
		"week": week,
		"over": is_over(),
		"goal_met": goal_met() if is_over() else false,
	}
