extends RefCounted

const Sport = preload("res://scripts/sport.gd")

var seed: int = 0
var week: int = 0
var rosters: Array = []
var player_roster: Array = []
var opponent_roster: Array = []
var matches: Array = []
var final_match: Dictionary = {}
var pending: Dictionary = {}


func _init(series_seed: int) -> void:
	seed = series_seed
	week = 0
	matches = []
	final_match = {}
	pending = {}
	var clubs := Sport.create_clubs(series_seed)
	rosters = clubs["rosters"]
	player_roster = rosters[Sport.PLAYER_INDEX]
	_bind_opponent()


func regular_complete() -> bool:
	return matches.size() >= Sport.regular_match_count()


func qualified_for_final() -> bool:
	if not regular_complete():
		return false
	return Sport.rank_of(standings(), Sport.PLAYER_INDEX) <= 2


func in_final() -> bool:
	return week >= Sport.SERIES_WEEKS and final_match.is_empty() and qualified_for_final()


func is_over() -> bool:
	if not regular_complete():
		return false
	if not qualified_for_final():
		return true
	return not final_match.is_empty()


func standings() -> Array:
	return Sport.standings(matches, seed)


func current_fixture() -> Dictionary:
	if week >= Sport.SERIES_WEEKS:
		if in_final():
			return _final_fixture()
		return {"away": -1, "home": -1}
	var pair: Array = Sport.player_fixture(week)
	return {"away": int(pair[0]), "home": int(pair[1])}


func _final_fixture() -> Dictionary:
	var table := standings()
	var first := int(table[0]["club"])
	var second := int(table[1]["club"])
	return {"away": second, "home": first}


func opponent_index() -> int:
	var fixture := current_fixture()
	if int(fixture["away"]) < 0:
		return -1
	if int(fixture["away"]) == Sport.PLAYER_INDEX:
		return int(fixture["home"])
	return int(fixture["away"])


func _bind_opponent() -> void:
	var index := opponent_index()
	if index < 0:
		opponent_roster = []
		return
	opponent_roster = rosters[index]


func player_bats_second() -> bool:
	var fixture := current_fixture()
	return int(fixture["home"]) == Sport.PLAYER_INDEX


func player_matches() -> Array:
	var found: Array = []
	for fixture in matches:
		if int(fixture["away"]) == Sport.PLAYER_INDEX or int(fixture["home"]) == Sport.PLAYER_INDEX:
			found.append(fixture)
	return found


func record() -> Dictionary:
	var wins := 0
	var losses := 0
	var ties := 0
	for fixture in player_matches():
		var kind := str(fixture["player_result"])
		if kind == "win":
			wins += 1
		elif kind == "loss":
			losses += 1
		else:
			ties += 1
	return {"wins": wins, "losses": losses, "ties": ties}


func goal_met() -> bool:
	if final_match.is_empty():
		return false
	return str(final_match.get("player_result", "")) == "win"


func begin_match(lineup: Array, tactic: String, focus: String) -> Dictionary:
	if is_over():
		return {"ok": false, "error": "The series is already over."}
	if not Sport.is_legal_lineup(player_roster.size(), lineup):
		return {"ok": false, "error": "The lineup needs four different players."}
	if not Sport.TACTICS.has(tactic):
		return {"ok": false, "error": "Pick a tactic."}
	if not Sport.STATS.has(focus):
		return {"ok": false, "error": "Pick a training focus."}
	var week_index := week
	var fixture := current_fixture()
	if week >= Sport.SERIES_WEEKS:
		week_index = Sport.SERIES_WEEKS
	var player_match := _play_fixture(week_index, fixture, lineup, tactic, focus, true)
	var other := {}
	if week < Sport.SERIES_WEEKS:
		var pair: Array = Sport.other_fixture(week)
		other = _play_fixture(week, {"away": int(pair[0]), "home": int(pair[1])}, lineup, tactic, focus, false)
	player_match["ok"] = true
	player_match["other"] = other
	pending = player_match
	return player_match


func _play_fixture(
	week_index: int,
	fixture: Dictionary,
	lineup: Array,
	tactic: String,
	focus: String,
	player_involved: bool
) -> Dictionary:
	var away_i := int(fixture["away"])
	var home_i := int(fixture["home"])
	var away_plan: Dictionary = Sport.opponent_plan(rosters[away_i], week_index, away_i)
	var home_plan: Dictionary = Sport.opponent_plan(rosters[home_i], week_index, home_i)
	var away_lineup: Array = away_plan["lineup"]
	var home_lineup: Array = home_plan["lineup"]
	var away_tactic := str(away_plan["tactic"])
	var home_tactic := str(home_plan["tactic"])
	var away_focus := str(away_plan["training"])
	var home_focus := str(home_plan["training"])
	if player_involved and away_i == Sport.PLAYER_INDEX:
		away_lineup = lineup
		away_tactic = tactic
		away_focus = focus
	if player_involved and home_i == Sport.PLAYER_INDEX:
		home_lineup = lineup
		home_tactic = tactic
		home_focus = focus
	var slot := 0
	if week_index < Sport.SERIES_WEEKS:
		slot = Sport.fixture_slot(week_index, away_i, home_i)
	var played: Dictionary = Sport.simulate_match(
		Sport.match_seed_for(seed, week_index, slot),
		Sport.lineup_players(rosters[home_i], home_lineup),
		Sport.lineup_players(rosters[away_i], away_lineup),
		home_tactic,
		away_tactic,
		str(Sport.CLUBS[home_i]),
		str(Sport.CLUBS[away_i])
	)
	played["week"] = week_index
	played["away"] = away_i
	played["home"] = home_i
	played["away_lineup"] = away_lineup.duplicate()
	played["home_lineup"] = home_lineup.duplicate()
	played["away_tactic"] = away_tactic
	played["home_tactic"] = home_tactic
	played["away_focus"] = away_focus
	played["home_focus"] = home_focus
	played["final"] = week_index >= Sport.SERIES_WEEKS
	if away_i == Sport.PLAYER_INDEX or home_i == Sport.PLAYER_INDEX:
		var at_home := home_i == Sport.PLAYER_INDEX
		var foe := away_i if at_home else home_i
		played["player_bats_second"] = at_home
		played["player_tactic"] = home_tactic if at_home else away_tactic
		played["opponent_tactic"] = away_tactic if at_home else home_tactic
		played["player_lineup"] = (home_lineup if at_home else away_lineup).duplicate()
		played["opponent_lineup"] = (away_lineup if at_home else home_lineup).duplicate()
		played["player_focus"] = home_focus if at_home else away_focus
		played["opponent_focus"] = away_focus if at_home else home_focus
		played["opponent_club"] = str(Sport.CLUBS[foe])
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
	return played


func _note_focus(fixture: Dictionary, focuses: Dictionary) -> void:
	focuses[int(fixture["away"])] = str(fixture["away_focus"])
	focuses[int(fixture["home"])] = str(fixture["home_focus"])


func commit_match() -> Dictionary:
	if pending.is_empty() or not bool(pending.get("ok", false)):
		return {"ok": false, "error": "No match is waiting to be recorded."}
	var other: Dictionary = {}
	if pending.has("other") and not (pending["other"] as Dictionary).is_empty():
		other = pending["other"]
	var stored: Dictionary = pending.duplicate(true)
	stored.erase("other")
	stored.erase("ok")
	var is_final := bool(stored.get("final", false))
	var focuses := {}
	_note_focus(stored, focuses)
	if not other.is_empty():
		_note_focus(other, focuses)
	if is_final:
		final_match = stored
	else:
		matches.append(stored)
		matches.append(other.duplicate(true))
		week += 1
	for club_index in Sport.CLUBS.size():
		if focuses.has(club_index):
			Sport.apply_training(rosters[club_index], str(focuses[club_index]))
	pending = {}
	_bind_opponent()
	return {
		"ok": true,
		"week": week,
		"over": is_over(),
		"goal_met": goal_met() if is_over() else false,
	}
