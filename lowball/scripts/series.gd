extends RefCounted

const Sport = preload("res://scripts/sport.gd")

var seed: int = 0
var week: int = 0
var rosters: Array = []
var player_roster: Array = []
var results: Array = []
var pending: Dictionary = {}
var final_games: Array = []


func _init(series_seed: int) -> void:
	seed = series_seed
	week = 0
	results = []
	pending = {}
	final_games = []
	var clubs := Sport.create_clubs(series_seed)
	rosters = clubs["rosters"]
	player_roster = rosters[Sport.PLAYER_INDEX]


func is_over() -> bool:
	if week < Sport.SERIES_WEEKS:
		return false
	if not reached_final():
		return true
	return _has_series_winner()


func reached_final() -> bool:
	if week < Sport.SERIES_WEEKS:
		return false
	var pair := finalist_indices()
	return int(pair[0]) == Sport.PLAYER_INDEX or int(pair[1]) == Sport.PLAYER_INDEX


func in_final() -> bool:
	return week >= Sport.SERIES_WEEKS and reached_final() and not _has_series_winner()


func finalist_indices() -> Array:
	return Sport.finalist_pair(table())


func series_win_counts() -> Array:
	var counts: Array = []
	for _club in Sport.CLUB_COUNT:
		counts.append(0)
	for game in final_games:
		_add_final_win(counts, game)
	return counts


func _add_final_win(counts: Array, game: Dictionary) -> void:
	var winner := str(game.get("winner", "tie"))
	if winner == "home":
		var idx := int(game["home_index"])
		counts[idx] = int(counts[idx]) + 1
	elif winner == "away":
		var idx := int(game["away_index"])
		counts[idx] = int(counts[idx]) + 1


func _has_series_winner() -> bool:
	for count in series_win_counts():
		if int(count) >= Sport.FINAL_WINS_NEEDED:
			return true
	return false


func series_winner_index() -> int:
	var counts := series_win_counts()
	for club_index in counts.size():
		if int(counts[club_index]) >= Sport.FINAL_WINS_NEEDED:
			return club_index
	return -1


func final_game_index() -> int:
	return final_games.size()


func final_home_index(game_index: int) -> int:
	var pair := finalist_indices()
	var sides: Array = Sport.final_home_away(int(pair[0]), int(pair[1]), game_index)
	return int(sides[0])


func place() -> int:
	var ordered := Sport.sorted_table(table())
	for i in ordered.size():
		if int(ordered[i]["index"]) == Sport.PLAYER_INDEX:
			return i + 1
	return Sport.CLUB_COUNT


func fixture() -> Dictionary:
	if week >= Sport.SERIES_WEEKS:
		return _final_card()
	var cards := Sport.week_fixtures(week)
	for card in cards:
		if int(card["home"]) == Sport.PLAYER_INDEX or int(card["away"]) == Sport.PLAYER_INDEX:
			return card
	return cards[0]


func other_fixture() -> Dictionary:
	if week >= Sport.SERIES_WEEKS:
		return {}
	var mine := fixture()
	for card in Sport.week_fixtures(week):
		if int(card["home"]) != int(mine["home"]):
			return card
	return {}


func _final_card() -> Dictionary:
	var pair := finalist_indices()
	var game_index := final_games.size()
	var sides: Array = Sport.final_home_away(int(pair[0]), int(pair[1]), game_index)
	var home := int(sides[0])
	var away := int(sides[1])
	return {
		"home": home,
		"away": away,
		"home_club": str(Sport.CLUB_NAMES[home]),
		"away_club": str(Sport.CLUB_NAMES[away]),
		"is_final": true,
		"final_game": game_index + 1,
		"ahead": int(pair[0]),
	}


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
	var rows := Sport.table_from_results(results)
	Sport.apply_seed_ranks(rows, seed)
	return rows


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
	return series_winner_index() == Sport.PLAYER_INDEX


func _club_plan(club_index: int, plan_week: int) -> Dictionary:
	return Sport.opponent_plan(rosters[club_index], plan_week, club_index)


func _focuses_for(plan_week: int, focus: String) -> Array:
	var focuses: Array = []
	for club_index in Sport.CLUB_COUNT:
		if club_index == Sport.PLAYER_INDEX:
			focuses.append(focus)
		else:
			focuses.append(str(_club_plan(club_index, plan_week)["training"]))
	return focuses


func _simulate_card(
	card: Dictionary,
	lineup: Array,
	tactic: String,
	plan_week: int,
	seed_week: int,
	slot: int,
	focuses: Array
) -> Dictionary:
	var home_i := int(card["home"])
	var away_i := int(card["away"])
	var playing := home_i == Sport.PLAYER_INDEX or away_i == Sport.PLAYER_INDEX
	var home_indices: Array
	var away_indices: Array
	var home_tactic: String
	var away_tactic: String
	if home_i == Sport.PLAYER_INDEX:
		home_indices = lineup.duplicate()
		home_tactic = tactic
	else:
		var home_plan := _club_plan(home_i, plan_week)
		home_indices = (home_plan["lineup"] as Array).duplicate()
		home_tactic = str(home_plan["tactic"])
	if away_i == Sport.PLAYER_INDEX:
		away_indices = lineup.duplicate()
		away_tactic = tactic
	else:
		var away_plan := _club_plan(away_i, plan_week)
		away_indices = (away_plan["lineup"] as Array).duplicate()
		away_tactic = str(away_plan["tactic"])
	var played: Dictionary = Sport.simulate_match(
		Sport.match_seed_for(seed, seed_week, slot),
		Sport.lineup_players(rosters[home_i], home_indices),
		Sport.lineup_players(rosters[away_i], away_indices),
		home_tactic,
		away_tactic,
		str(card["home_club"]),
		str(card["away_club"])
	)
	played["ok"] = true
	played["week"] = week
	played["slot"] = slot
	played["seed_week"] = seed_week
	played["home_index"] = home_i
	played["away_index"] = away_i
	played["player_played"] = playing
	played["player_bats_second"] = playing and home_i == Sport.PLAYER_INDEX
	played["player_tactic"] = tactic if playing else ""
	played["player_lineup"] = lineup.duplicate() if playing else []
	played["player_focus"] = str(focuses[Sport.PLAYER_INDEX])
	played["home_tactic"] = home_tactic
	played["away_tactic"] = away_tactic
	played["home_lineup"] = home_indices
	played["away_lineup"] = away_indices
	played["focuses"] = focuses.duplicate()
	played["is_final"] = bool(card.get("is_final", false))
	played["final_game"] = int(card.get("final_game", 0))
	if card.has("bye"):
		played["bye_index"] = int(card["bye"])
		played["bye_club"] = str(card["bye_club"])
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
		played["player_result"] = "other"
		played["player_score"] = 0
		played["opponent_score"] = 0
	return played


func begin_match(lineup: Array, tactic: String, focus: String) -> Dictionary:
	if is_over():
		return {"ok": false, "error": "The series is already over."}
	if not Sport.STATS.has(focus):
		return {"ok": false, "error": "Pick a training focus."}
	var playing := player_plays()
	if playing or week >= Sport.SERIES_WEEKS:
		if not Sport.is_legal_lineup(player_roster.size(), lineup):
			return {"ok": false, "error": "The lineup needs four different players."}
		if not Sport.TACTICS.has(tactic):
			return {"ok": false, "error": "Pick a tactic."}
	if week >= Sport.SERIES_WEEKS:
		return _begin_final(lineup, tactic, focus)
	if playing:
		return _begin_week(lineup, tactic, focus)
	return _begin_bye(lineup, tactic, focus)


func _begin_bye(lineup: Array, tactic: String, focus: String) -> Dictionary:
	var cards := Sport.week_fixtures(week)
	var focuses := _focuses_for(week, focus)
	var played_cards: Array = []
	for slot in cards.size():
		var played := _simulate_card(cards[slot], lineup, tactic, week, week, slot, focuses)
		played["player_result"] = "bye"
		played_cards.append(played)
	if played_cards.size() < Sport.MATCHES_PER_WEEK:
		return {"ok": false, "error": "The bye week is missing a match."}
	var first: Dictionary = played_cards[0]
	first["other_match"] = played_cards[1]
	pending = first
	return first


func _begin_week(lineup: Array, tactic: String, focus: String) -> Dictionary:
	var cards := Sport.week_fixtures(week)
	var focuses := _focuses_for(week, focus)
	var player_match: Dictionary = {}
	var other_match: Dictionary = {}
	for slot in cards.size():
		var played := _simulate_card(cards[slot], lineup, tactic, week, week, slot, focuses)
		if bool(played["player_played"]):
			player_match = played
		else:
			other_match = played
	if player_match.is_empty():
		return {"ok": false, "error": "The week has no match for Lumen Reedmice."}
	player_match["other_match"] = other_match
	pending = player_match
	return player_match


func _begin_final(lineup: Array, tactic: String, focus: String) -> Dictionary:
	var game_index := final_games.size()
	var plan_week := Sport.SERIES_WEEKS + game_index
	var card := _final_card()
	var focuses := _focuses_for(plan_week, focus)
	var played := _simulate_card(card, lineup, tactic, plan_week, plan_week, 0, focuses)
	played["is_final"] = true
	played["final_game"] = game_index + 1
	pending = played
	return played


func _stored_regular(match: Dictionary) -> Dictionary:
	var copy := match.duplicate(false)
	copy.erase("other_match")
	return copy


func commit_match() -> Dictionary:
	if pending.is_empty() or not bool(pending.get("ok", false)):
		return {"ok": false, "error": "No match is waiting to be recorded."}
	var focuses: Array = pending["focuses"]
	var notes: Array = []
	for club_index in Sport.CLUB_COUNT:
		notes.append(Sport.apply_training(rosters[club_index], str(focuses[club_index])))
	pending["training_notes"] = notes
	if bool(pending.get("is_final", false)):
		final_games.append(pending)
		pending = {}
		var decided := is_over()
		return {
			"ok": true,
			"week": week,
			"over": decided,
			"goal_met": goal_met() if decided else false,
			"final": true,
		}
	var other: Dictionary = pending["other_match"]
	other["training_notes"] = notes
	var mine := _stored_regular(pending)
	var away := _stored_regular(other)
	if int(mine["slot"]) <= int(away["slot"]):
		results.append(mine)
		results.append(away)
	else:
		results.append(away)
		results.append(mine)
	pending = {}
	week += 1
	var over := is_over()
	return {
		"ok": true,
		"week": week,
		"over": over,
		"goal_met": goal_met() if over else false,
		"final": false,
	}
