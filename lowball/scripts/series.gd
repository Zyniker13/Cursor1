extends RefCounted

const Sport = preload("res://scripts/sport.gd")

var seed: int = 0
var week: int = 0
var player_roster: Array = []
var opponent_roster: Array = []
var results: Array = []
var pending: Dictionary = {}


func _init(series_seed: int) -> void:
	seed = series_seed
	week = 0
	results = []
	pending = {}
	var clubs := Sport.create_clubs(series_seed)
	player_roster = clubs["player_roster"]
	opponent_roster = clubs["opponent_roster"]


func is_over() -> bool:
	return week >= Sport.SERIES_WEEKS


func player_bats_second() -> bool:
	return week % 2 == 0


func record() -> Dictionary:
	var wins := 0
	var losses := 0
	var ties := 0
	for result in results:
		var kind := str(result["player_result"])
		if kind == "win":
			wins += 1
		elif kind == "loss":
			losses += 1
		else:
			ties += 1
	return {"wins": wins, "losses": losses, "ties": ties}


func goal_met() -> bool:
	return int(record()["wins"]) >= Sport.GOAL_WINS


func begin_match(lineup: Array, tactic: String, focus: String) -> Dictionary:
	if is_over():
		return {"ok": false, "error": "The series is already over."}
	if not Sport.is_legal_lineup(player_roster.size(), lineup):
		return {"ok": false, "error": "The lineup needs four different players."}
	if not Sport.TACTICS.has(tactic):
		return {"ok": false, "error": "Pick a tactic."}
	if not Sport.STATS.has(focus):
		return {"ok": false, "error": "Pick a training focus."}
	var plan: Dictionary = Sport.opponent_plan(opponent_roster, week)
	var player_players: Array = Sport.lineup_players(player_roster, lineup)
	var opponent_players: Array = Sport.lineup_players(opponent_roster, plan["lineup"])
	var home_players: Array
	var away_players: Array
	var home_tactic: String
	var away_tactic: String
	var home_club: String
	var away_club: String
	var at_home := player_bats_second()
	if at_home:
		home_players = player_players
		away_players = opponent_players
		home_tactic = tactic
		away_tactic = str(plan["tactic"])
		home_club = Sport.PLAYER_CLUB
		away_club = Sport.OPPONENT_CLUB
	else:
		home_players = opponent_players
		away_players = player_players
		home_tactic = str(plan["tactic"])
		away_tactic = tactic
		home_club = Sport.OPPONENT_CLUB
		away_club = Sport.PLAYER_CLUB
	var played: Dictionary = Sport.simulate_match(
		Sport.match_seed_for(seed, week),
		home_players,
		away_players,
		home_tactic,
		away_tactic,
		home_club,
		away_club
	)
	played["ok"] = true
	played["week"] = week
	played["player_bats_second"] = at_home
	played["player_tactic"] = tactic
	played["opponent_tactic"] = str(plan["tactic"])
	played["player_lineup"] = lineup.duplicate()
	played["opponent_lineup"] = (plan["lineup"] as Array).duplicate()
	played["player_focus"] = focus
	played["opponent_focus"] = str(plan["training"])
	if at_home:
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
	pending = played
	return played


func commit_match() -> Dictionary:
	if pending.is_empty() or not bool(pending.get("ok", false)):
		return {"ok": false, "error": "No match is waiting to be recorded."}
	var focus := str(pending["player_focus"])
	var opponent_focus := str(pending["opponent_focus"])
	pending["player_training"] = Sport.apply_training(player_roster, focus)
	pending["opponent_training"] = Sport.apply_training(opponent_roster, opponent_focus)
	results.append(pending)
	pending = {}
	week += 1
	return {
		"ok": true,
		"week": week,
		"over": is_over(),
		"goal_met": goal_met() if is_over() else false,
	}
