extends SceneTree

const Sport = preload("res://scripts/sport.gd")
const SeriesScript = preload("res://scripts/series.gd")

var _failures: Array = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_failures = []
	_test_names()
	_test_round_robin()
	_test_determinism()
	_test_week_eight()
	_test_table_order()
	_test_final()
	_test_fairness_and_cap()
	await _test_game_flow()
	if _failures.is_empty():
		print("ALL TESTS PASSED")
		quit(0)
	else:
		printerr("FAILED %d check(s)" % _failures.size())
		for msg in _failures:
			printerr(" - " + str(msg))
		quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		printerr("FAIL: " + message)


func _key(code: Key) -> InputEventKey:
	var event := InputEventKey.new()
	event.pressed = true
	event.echo = false
	event.keycode = code
	return event


func _lineup_of(roster: Array, indices: Array) -> Array:
	return Sport.lineup_players(roster, indices)


func _test_names() -> void:
	print("TEST names")
	_check(Sport.SYLLABLES.size() >= 8, "syllable list is too small")
	var seen := {}
	for syllable in Sport.SYLLABLES:
		var text := str(syllable)
		_check(text == text.to_lower(), "syllable is not lowercase: " + text)
		_check(text.length() == 3, "syllable is not 3 letters: " + text)
		_check(not seen.has(text), "duplicate syllable: " + text)
		seen[text] = true
		_check(text.find("c") < 0, "syllable contains c: " + text)
	var blocked := [
		"fuck", "shit", "cunt", "nigg", "fag", "rape", "porn", "sex", "ass", "tit",
		"cum", "dick", "cock", "pussy", "slut", "nazi", "kike", "spic", "chink",
		"whore", "damn", "hell", "piss", "crap", "anus", "anal", "penis", "vagina",
		"dyke", "twat", "wank", "homo", "kill", "hate", "hitler", "stalin", "bitch",
	]
	var athletes := [
		"jordan", "bryant", "mantle", "gehrig", "ripken", "rivera", "suzuki", "pujols",
		"harper", "lindor", "altuve", "freeman", "stanton", "shohei", "mickey", "willie",
		"jackie", "clemens", "maddux", "trout", "bonds", "ohtani", "messi",
	]
	for a in Sport.SYLLABLES:
		for b in Sport.SYLLABLES:
			var word: String = str(a) + str(b)
			for bad in blocked:
				_check(word.find(bad) < 0, "syllable join '%s' contains '%s'" % [word, bad])
			for athlete in athletes:
				_check(word != athlete, "syllable join matches athlete token " + athlete)
	var generated := 0
	for seed in 40:
		var clubs: Dictionary = Sport.create_clubs(seed)
		_check((clubs["rosters"] as Array).size() == Sport.CLUB_COUNT, "create_clubs dropped a club")
		for roster in clubs["rosters"]:
			for player in roster:
				var full_name := str(player["player_name"])
				_check(Sport.is_generated_name(full_name), "name is not a syllable join: " + full_name)
				generated += 1
	_check(generated == 40 * Sport.ROSTER_SIZE * Sport.CLUB_COUNT, "unexpected generated name count")
	_check(not Sport.is_generated_name("John Smith"), "plain name was accepted")
	_check(not Sport.is_generated_name("Bridax"), "one-word name was accepted")
	_check(not Sport.is_generated_name("Bridax Fexnel Extra"), "three-word name was accepted")


func _same_players(left: Array, right: Array) -> bool:
	if left.size() != right.size():
		return false
	for i in left.size():
		if str(left[i]["player_name"]) != str(right[i]["player_name"]):
			return false
		for key in Sport.STATS:
			if Sport.get_stat(left[i], key) != Sport.get_stat(right[i], key):
				return false
	return true


func _play_fixed(clubs: Dictionary) -> Dictionary:
	var indices := [0, 1, 2, 3]
	return Sport.simulate_match(
		12345,
		_lineup_of(clubs["player_roster"], indices),
		_lineup_of(clubs["opponent_roster"], indices),
		"patient",
		"field",
		Sport.PLAYER_CLUB,
		Sport.OPPONENT_CLUB
	)


func _stat_bag(roster: Array) -> String:
	var bag: Array = []
	for player in roster:
		var bits: Array = []
		for key in Sport.STATS:
			bits.append(str(Sport.get_stat(player, key)))
		bag.append("-".join(bits))
	bag.sort()
	return ",".join(bag)


func _sum_stat(roster: Array, key: String) -> int:
	var total := 0
	for player in roster:
		total += Sport.get_stat(player, key)
	return total


func _pair_key(card: Dictionary) -> String:
	var home := int(card["home"])
	var away := int(card["away"])
	return "%d-%d" % [mini(home, away), maxi(home, away)]


func _test_round_robin() -> void:
	print("TEST round-robin")
	_check(Sport.CLUB_COUNT == 3, "club count is not three")
	_check(Sport.CLUB_NAMES.size() == 3, "club list is not three clubs")
	_check(Sport.THIRD_CLUB == "Pellwick Cinders", "third club should be Pellwick Cinders")
	_check(str(Sport.CLUB_NAMES[2]) == Sport.THIRD_CLUB, "third club is missing from the club list")
	_check(Sport.ROUND_ROBIN.size() == Sport.SERIES_WEEKS, "schedule is not eight weeks")
	_check(Sport.ROUND_ROBIN.size() == 8, "week 8 is not on the schedule")
	_check(Sport.SCHEDULE_TEXT.contains("round-robin"), "schedule shape is not described")
	var pair_counts := {}
	for week_index in Sport.SERIES_WEEKS:
		var card := Sport.fixture(week_index)
		var home := int(card["home"])
		var away := int(card["away"])
		var bye := int(card["bye"])
		_check(home != away and home != bye and away != bye, "fixture clubs are not distinct in week %d" % (week_index + 1))
		_check(home >= 0 and home < 3 and away >= 0 and away < 3 and bye >= 0 and bye < 3, "fixture index out of range")
		_check(str(card["bye_club"]) == str(Sport.CLUB_NAMES[bye]), "bye club name drifted")
		var key := _pair_key(card)
		pair_counts[key] = int(pair_counts.get(key, 0)) + 1
	_check(int(pair_counts.get("0-1", 0)) > 0, "the player never meets Southspur Glass")
	_check(int(pair_counts.get("0-2", 0)) > 0, "the player never meets the third club")
	_check(int(pair_counts.get("1-2", 0)) > 0, "the other two clubs never meet")
	var first_cycle := {}
	for week_index in 3:
		first_cycle[_pair_key(Sport.fixture(week_index))] = true
	_check(first_cycle.size() == 3, "weeks 1-3 are not a full round-robin")
	var second_cycle := {}
	for week_index in range(3, 6):
		second_cycle[_pair_key(Sport.fixture(week_index))] = true
	_check(second_cycle.size() == 3, "weeks 4-6 are not a full round-robin")
	for week_index in 3:
		var early := Sport.fixture(week_index)
		var late := Sport.fixture(week_index + 3)
		_check(int(early["home"]) == int(late["away"]) and int(early["away"]) == int(late["home"]), "second cycle did not reverse home")
	for week_index in 2:
		var early := Sport.fixture(week_index)
		var extra := Sport.fixture(week_index + 6)
		_check(int(early["home"]) == int(extra["home"]) and int(early["away"]) == int(extra["away"]), "weeks 7-8 do not continue the cycle")
	var dealt := Sport.create_clubs(42)
	var bag := _stat_bag(dealt["rosters"][0])
	_check(bag == _stat_bag(dealt["rosters"][1]), "Southspur Glass was not dealt the same stat lines")
	_check(bag == _stat_bag(dealt["rosters"][2]), "the third club was not dealt the same stat lines")
	var tied := Sport.empty_table()
	Sport.apply_result_to_table(tied, 0, 1, 3, 1)
	Sport.apply_result_to_table(tied, 2, 1, 2, 0)
	_check(int(tied[0]["points"]) == 2 and int(tied[2]["points"]) == 2, "a win did not award 2 points")
	_check(not Sport.goal_reached(tied), "an equal points-per-game met the goal")
	Sport.apply_result_to_table(tied, 0, 2, 4, 0)
	_check(Sport.goal_reached(tied), "a better points-per-game missed the goal")
	var tie_rows := Sport.empty_table()
	Sport.apply_result_to_table(tie_rows, 0, 1, 2, 2)
	_check(int(tie_rows[0]["points"]) == 1 and int(tie_rows[1]["points"]) == 1, "a tie did not award 1 point to each club")
	_check(int(tie_rows[0]["ties"]) == 1 and int(tie_rows[1]["ties"]) == 1, "a tie was not recorded")


func _test_determinism() -> void:
	print("TEST determinism")
	var first_clubs := Sport.create_clubs(42)
	var second_clubs := Sport.create_clubs(42)
	_check((first_clubs["rosters"] as Array).size() == 3, "third club roster is missing")
	for club_index in Sport.CLUB_COUNT:
		_check(
			_same_players(first_clubs["rosters"][club_index], second_clubs["rosters"][club_index]),
			"roster %d drifted" % club_index
		)
	var first := _play_fixed(Sport.create_clubs(42))
	var second := _play_fixed(Sport.create_clubs(42))
	_check(int(first["home_score"]) == int(second["home_score"]), "home score changed for the same seed")
	_check(int(first["away_score"]) == int(second["away_score"]), "away score changed for the same seed")
	_check(str(first["winner"]) == str(second["winner"]), "winner changed for the same seed")
	var first_pas: Array = first["plate_appearances"]
	var second_pas: Array = second["plate_appearances"]
	_check(first_pas.size() == Sport.PAS_PER_MATCH, "plate appearance count is not 24")
	_check(first_pas.size() == second_pas.size(), "plate appearance count drifted")
	for i in first_pas.size():
		_check(str(first_pas[i]["explanation"]) == str(second_pas[i]["explanation"]), "explanation drifted at %d" % i)
		_check(str(first_pas[i]["outcome"]) == str(second_pas[i]["outcome"]), "outcome drifted at %d" % i)
		_check(int(first_pas[i]["runs"]) == int(second_pas[i]["runs"]), "runs drifted at %d" % i)
	_check(_score_matches_runs(first), "runs do not add up to the score")
	var left_scores := _scripted_scores(11)
	var right_scores := _scripted_scores(11)
	_check(left_scores.size() == 8 and right_scores.size() == 8, "week 8 was not played")
	_check(left_scores.size() == Sport.SERIES_WEEKS and right_scores.size() == Sport.SERIES_WEEKS, "scripted series length drifted from the series constant")
	var saw_third := false
	for i in left_scores.size():
		_check(int(left_scores[i][0]) == int(right_scores[i][0]), "series home score drifted in week %d" % i)
		_check(int(left_scores[i][1]) == int(right_scores[i][1]), "series away score drifted in week %d" % i)
		_check(str(left_scores[i][2]) == str(right_scores[i][2]), "home club drifted in week %d" % i)
		_check(str(left_scores[i][3]) == str(right_scores[i][3]), "away club drifted in week %d" % i)
		if str(left_scores[i][2]) == Sport.THIRD_CLUB or str(left_scores[i][3]) == Sport.THIRD_CLUB:
			saw_third = true
	_check(saw_third, "third club did not appear in the scripted series")
	var same_a := _series_lines(11, [0, 1, 2, 3])
	var same_b := _series_lines(11, [0, 1, 2, 3])
	_check(same_a.size() == Sport.SERIES_WEEKS * Sport.PAS_PER_MATCH, "series at-bat count drifted")
	var same_at_bats := same_a.size() == same_b.size()
	if same_at_bats:
		for i in same_a.size():
			if str(same_a[i]) != str(same_b[i]):
				same_at_bats = false
				break
	_check(same_at_bats, "same seed and lineup did not repeat the at-bats")
	var other_lineup := _series_lines(11, [5, 4, 3, 2])
	var lineup_differs := false
	for i in mini(same_a.size(), other_lineup.size()):
		if str(same_a[i]) != str(other_lineup[i]):
			lineup_differs = true
			break
	_check(lineup_differs, "a different lineup repeated the same at-bats")
	var bye_a := _week_lines(9, 2, [0, 1, 2, 3], "aggressive")
	var bye_b := _week_lines(9, 2, [5, 4, 3, 1], "field")
	_check(bye_a.size() == Sport.PAS_PER_MATCH, "bye week was not a full match")
	var bye_same := bye_a.size() == bye_b.size()
	if bye_same:
		for i in bye_a.size():
			if str(bye_a[i]) != str(bye_b[i]):
				bye_same = false
				break
	_check(bye_same, "bye week changed when the unused lineup changed")


func _test_week_eight() -> void:
	print("TEST week 8 is played")
	_check(Sport.SERIES_WEEKS == 8, "series is not 8 match weeks")
	_check(
		Sport.GOAL_TEXT == "Board goal: reach the final and win it.",
		"goal text does not state the final"
	)
	_check(
		Sport.TIE_RULE == "Ties in the table break by run difference, then by the existing series seed.",
		"tie rule text drifted"
	)
	_check(Sport.WIN_POINTS == 2 and Sport.TIE_POINTS == 1, "points values drifted")
	var played := SeriesScript.new(11)
	_check(played.rosters.size() == 3, "third club roster is missing from the series")
	var lash_before: Array = []
	var eye_before: Array = []
	for player in played.player_roster:
		lash_before.append(Sport.get_stat(player, "lash"))
		eye_before.append(Sport.get_stat(player, "eye"))
	for week_index in 7:
		var started: Dictionary = played.begin_match([0, 1, 2, 3], "aggressive", "lash")
		_check(bool(started.get("ok", false)), "week %d did not start" % (week_index + 1))
		_check(int(started.get("week", -1)) == week_index, "week %d was not the match that was played" % (week_index + 1))
		_check((started["plate_appearances"] as Array).size() == Sport.PAS_PER_MATCH, "week %d was not played" % (week_index + 1))
		var on_bye := week_index == 2 or week_index == 5
		_check(bool(started["player_played"]) != on_bye, "week %d had the wrong side on the field" % (week_index + 1))
		var committed: Dictionary = played.commit_match()
		_check(bool(committed.get("ok", false)), "week %d did not record" % (week_index + 1))
		_check(not played.is_over(), "series ended before week 8")
		_check(int(played.week) == week_index + 1, "week counter skipped ahead of week 8")
	for i in played.player_roster.size():
		_check(
			Sport.get_stat(played.player_roster[i], "lash") == mini(int(lash_before[i]) + 7, Sport.STAT_CAP),
			"training did not add 1 per week up to the cap"
		)
		_check(Sport.get_stat(played.player_roster[i], "eye") == int(eye_before[i]), "training changed a stat that was not the focus")
	var eighth: Dictionary = played.begin_match([0, 1, 2, 3], "patient", "eye")
	_check(bool(eighth.get("ok", false)), "week 8 did not start")
	_check(int(eighth.get("week", -1)) == 7, "week 8 match is not the eighth week")
	_check(bool(eighth.get("player_played", false)), "week 8 was not played")
	_check(eighth.has("player_score") and eighth.has("opponent_score"), "week 8 did not produce a score")
	_check(str(eighth["home_club"]) == Sport.THIRD_CLUB or str(eighth["away_club"]) == Sport.THIRD_CLUB, "week 8 does not include the third club")
	_check((eighth["plate_appearances"] as Array).size() == Sport.PAS_PER_MATCH, "week 8 did not play a full match")
	var done: Dictionary = played.commit_match()
	_check(bool(done.get("ok", false)), "week 8 did not record")
	_check(not bool(done.get("final", false)), "week 8 was stored as the final")
	_check(int(played.week) == 8, "week counter is not 8 after week 8")
	_check(played.results.size() == 8, "week 8 result was not stored")
	_check(int(played.results[7]["week"]) == 7, "stored week 8 is not the eighth match")
	var saw_third := false
	for result in played.results:
		if str(result["home_club"]) == Sport.THIRD_CLUB or str(result["away_club"]) == Sport.THIRD_CLUB or str(result.get("bye_club", "")) == Sport.THIRD_CLUB:
			saw_third = true
		for key in Sport.STATS:
			for roster in played.rosters:
				for player in roster:
					var value := Sport.get_stat(player, key)
					if value < Sport.STAT_FLOOR or value > Sport.STAT_CAP:
						_check(false, "stat %s left 1-20 at %d" % [key, value])
	_check(saw_third, "third club did not appear in the played series")
	for i in played.player_roster.size():
		_check(
			Sport.get_stat(played.player_roster[i], "eye") == mini(int(eye_before[i]) + 1, Sport.STAT_CAP),
			"week 8 training did not add 1 Eye"
		)
		_check(
			Sport.get_stat(played.player_roster[i], "lash") == mini(int(lash_before[i]) + 7, Sport.STAT_CAP),
			"week 8 training changed Lash"
		)
	if played.reached_final():
		_check(not played.is_over(), "a finalist series ended when week 8 was recorded")
		_check(not bool(done.get("over", false)), "week 8 closed a series that reached the final")
		var final_try: Dictionary = played.begin_match([0, 1, 2, 3], "field", "arm")
		_check(bool(final_try.get("ok", false)), "the final did not start after week 8")
		_check(bool(final_try.get("is_final", false)), "the match after week 8 was not the final")
		_check((final_try["plate_appearances"] as Array).size() == Sport.PAS_PER_MATCH, "the final was not a full match")
	else:
		_check(played.is_over(), "missing the final did not end the series after week 8")
		_check(bool(done.get("over", false)), "week 8 did not end a series that missed the final")
		var blocked: Dictionary = played.begin_match([0, 1, 2, 3], "field", "arm")
		_check(not bool(blocked.get("ok", false)), "a match after a missed final was allowed")


func _scripted_scores(series_seed: int) -> Array:
	var played := SeriesScript.new(series_seed)
	var scores: Array = []
	for week_index in Sport.SERIES_WEEKS:
		var match_result: Dictionary = played.begin_match([0, 1, 2, 3], "aggressive", "lash")
		if not bool(match_result.get("ok", false)):
			_check(false, "scripted week %d did not start" % (week_index + 1))
			return scores
		scores.append([
			int(match_result["home_score"]),
			int(match_result["away_score"]),
			str(match_result["home_club"]),
			str(match_result["away_club"]),
		])
		var committed: Dictionary = played.commit_match()
		if not bool(committed.get("ok", false)):
			_check(false, "scripted week %d did not record" % (week_index + 1))
			return scores
	return scores


func _series_lines(series_seed: int, lineup: Array) -> Array:
	var played := SeriesScript.new(series_seed)
	var lines: Array = []
	for _week in Sport.SERIES_WEEKS:
		var match_result: Dictionary = played.begin_match(lineup, "aggressive", "lash")
		for pa in match_result["plate_appearances"]:
			lines.append(str(pa["explanation"]))
		played.commit_match()
	return lines


func _week_lines(series_seed: int, target_week: int, lineup: Array, tactic: String) -> Array:
	var played := SeriesScript.new(series_seed)
	var lines: Array = []
	for week_index in target_week + 1:
		var match_result: Dictionary = played.begin_match(lineup, tactic, "lash")
		if week_index == target_week:
			for pa in match_result["plate_appearances"]:
				lines.append(str(pa["explanation"]))
		played.commit_match()
	return lines


func _score_matches_runs(result: Dictionary) -> bool:
	var home := 0
	var away := 0
	for pa in result["plate_appearances"]:
		if str(pa["batting_club"]) == str(result["home_club"]):
			home += int(pa["runs"])
		else:
			away += int(pa["runs"])
	return home == int(result["home_score"]) and away == int(result["away_score"])


func _outcome_runs_ok(pa: Dictionary) -> bool:
	var outcome := str(pa["outcome"])
	var runs := int(pa["runs"])
	if outcome == "out":
		return runs == 0
	if outcome == "mark":
		return runs == 0 or runs == 1
	if outcome == "score":
		return runs == 1 or runs == 2
	return false


func _test_fairness_and_cap() -> void:
	print("TEST fairness and training cap")
	var wins := {}
	for club_name in Sport.CLUB_NAMES:
		wins[str(club_name)] = 0
	var ties := 0
	var pairs := [[0, 1], [0, 2], [1, 2]]
	for series_index in 200:
		var clubs: Dictionary = Sport.create_clubs(1000 + series_index)
		var rng := RandomNumberGenerator.new()
		rng.seed = 5000 + series_index
		var rosters: Array = clubs["rosters"]
		for week in Sport.SERIES_WEEKS:
			var pair: Array = pairs[week % pairs.size()]
			var home_i := int(pair[0])
			var away_i := int(pair[1])
			if week % 2 == 1:
				home_i = int(pair[1])
				away_i = int(pair[0])
			var home_roster: Array = rosters[home_i]
			var away_roster: Array = rosters[away_i]
			var home_line: Array = Sport.random_lineup(rng, home_roster.size())
			var away_line: Array = Sport.random_lineup(rng, away_roster.size())
			_check(Sport.is_legal_lineup(home_roster.size(), home_line), "illegal home lineup")
			_check(Sport.is_legal_lineup(away_roster.size(), away_line), "illegal away lineup")
			var home_tactic: String = Sport.TACTICS[rng.randi_range(0, Sport.TACTICS.size() - 1)]
			var away_tactic: String = Sport.TACTICS[rng.randi_range(0, Sport.TACTICS.size() - 1)]
			var home_focus: String = Sport.STATS[rng.randi_range(0, Sport.STATS.size() - 1)]
			var away_focus: String = Sport.STATS[rng.randi_range(0, Sport.STATS.size() - 1)]
			var bye_focus: String = Sport.STATS[rng.randi_range(0, Sport.STATS.size() - 1)]
			var result: Dictionary = Sport.simulate_match(
				8000 + series_index * 10 + week,
				_lineup_of(home_roster, home_line),
				_lineup_of(away_roster, away_line),
				home_tactic,
				away_tactic,
				str(Sport.CLUB_NAMES[home_i]),
				str(Sport.CLUB_NAMES[away_i])
			)
			if int(result["home_score"]) > int(result["away_score"]):
				wins[str(Sport.CLUB_NAMES[home_i])] = int(wins[str(Sport.CLUB_NAMES[home_i])]) + 1
			elif int(result["away_score"]) > int(result["home_score"]):
				wins[str(Sport.CLUB_NAMES[away_i])] = int(wins[str(Sport.CLUB_NAMES[away_i])]) + 1
			else:
				ties += 1
			_check(_score_matches_runs(result), "score/runs mismatch in series %d week %d" % [series_index, week])
			for pa in result["plate_appearances"]:
				_check(_outcome_runs_ok(pa), "bad outcome runs")
				_check(str(pa["explanation"]).find("\n") < 0, "explanation contains a newline")
			Sport.apply_training(home_roster, home_focus)
			Sport.apply_training(away_roster, away_focus)
			Sport.apply_training(rosters[3 - home_i - away_i], bye_focus)
			for roster in rosters:
				for player in roster:
					_check(Sport.is_generated_name(str(player["player_name"])), "trained roster has a bad name")
					for key in Sport.STATS:
						var value := Sport.get_stat(player, key)
						if value < Sport.STAT_FLOOR or value > Sport.STAT_CAP:
							_check(false, "stat %s left the cap at %d" % [key, value])
	print("Fairness over 200 series, ties %d" % ties)
	for club_name in Sport.CLUB_NAMES:
		var club_wins := int(wins[str(club_name)])
		print("%s wins %d" % [str(club_name), club_wins])
		_check(club_wins > 0, str(club_name) + " never won a match")
		_check(club_wins >= 20, str(club_name) + " won too rarely to be able to win in general")

	var sample: Dictionary = Sport.create_clubs(3)
	var third_lash := _sum_stat(sample["rosters"][2], "lash")
	var player_lash := _sum_stat(sample["rosters"][0], "lash")
	Sport.apply_training(sample["rosters"][0], "lash")
	_check(_sum_stat(sample["rosters"][0], "lash") == player_lash + Sport.ROSTER_SIZE, "training did not add 1 to each Lumen Reedmice player")
	_check(_sum_stat(sample["rosters"][2], "lash") == third_lash, "training the player changed the third club")
	var player: Dictionary = sample["player_roster"][0]
	var untouched := Sport.get_stat(player, "eye")
	Sport.set_stat(player, "lash", Sport.STAT_CAP + 5)
	_check(Sport.get_stat(player, "lash") == Sport.STAT_CAP, "set_stat did not clamp the cap")
	Sport.apply_training([player], "lash")
	_check(Sport.get_stat(player, "lash") == Sport.STAT_CAP, "training pushed Lash past the cap")
	_check(Sport.get_stat(player, "eye") == untouched, "training changed a stat that was not the focus")
	Sport.set_stat(player, "legs", 10)
	Sport.apply_training([player], "legs")
	_check(Sport.get_stat(player, "legs") == 11, "training did not raise Legs by 1")
	Sport.set_stat(player, "glove", Sport.STAT_FLOOR - 3)
	_check(Sport.get_stat(player, "glove") == Sport.STAT_FLOOR, "set_stat did not clamp the floor")


func _count_outcome_token(line: String, token: String) -> int:
	var count := 0
	var from := 0
	while true:
		var found := line.find(token, from)
		if found < 0:
			return count
		count += 1
		from = found + token.length()
	return count


func _line_explains(line: String, batter: String) -> bool:
	if line.strip_edges() == "":
		return false
	if line.find("\n") >= 0:
		return false
	if not line.contains(batter):
		return false
	var stat_hit := false
	for word in ["Lash", "Eye", "Legs", "Glove", "Arm", "Read"]:
		if line.contains(word):
			stat_hit = true
	if not stat_hit:
		return false
	var digit := false
	for i in line.length():
		var ch := line.unicode_at(i)
		if ch >= 48 and ch <= 57:
			digit = true
			break
	if not digit:
		return false
	var zone_hit := line.contains("Near") or line.contains("Mid") or line.contains("Far")
	if not zone_hit:
		return false
	var tokens := 0
	tokens += _count_outcome_token(line, "Out.")
	tokens += _count_outcome_token(line, "Mark.")
	tokens += _count_outcome_token(line, "Score.")
	return tokens == 1


func _fill_rate(row: Dictionary, points: int, played_games: int, run_diff: int) -> void:
	row["points"] = points
	row["played"] = played_games
	row["run_diff"] = run_diff


func _ordered_indexes(rows: Array) -> Array:
	var ordered: Array = Sport.sorted_table(rows)
	var indexes: Array = []
	for row in ordered:
		indexes.append(int(row["index"]))
	return indexes


func _test_table_order() -> void:
	print("TEST table tie break")
	_check(Sport.seed_start(0) == 0, "seed 0 did not start with Lumen Reedmice")
	_check(Sport.seed_start(1) == 1, "seed 1 did not start with Southspur Glass")
	_check(Sport.seed_start(2) == 2, "seed 2 did not start with Pellwick Cinders")
	_check(Sport.seed_start(5) == 2, "seed remainder drifted")
	_check(Sport.seed_start(-1) == 2, "a negative series seed broke the remainder")
	_check(Sport.seed_order_names(1) == "Southspur Glass, Pellwick Cinders, Lumen Reedmice", "seed order names drifted")
	var rated := Sport.empty_table()
	_fill_rate(rated[0], 2, 1, 1)
	_fill_rate(rated[1], 4, 2, 9)
	_fill_rate(rated[2], 0, 2, 20)
	_check(Sport.rate_compare(rated[0], rated[1]) == 0, "an equal rate ranked a club ahead")
	_check(not Sport.goal_reached(rated), "an equal points-per-game met the rate rule")
	_check(Sport.compare_rows(rated[1], rated[0]) > 0, "higher run difference did not break the tie")
	_check(Sport.compare_rows(rated[0], rated[2]) > 0, "a better rate lost to run difference")
	var rated_pair: Array = Sport.finalist_pair(rated)
	_check(int(rated_pair[0]) == 1 and int(rated_pair[1]) == 0, "finalists ignored rate then run difference")
	var seeded := Sport.empty_table()
	for row in seeded:
		_fill_rate(row, 2, 2, 0)
	Sport.apply_seed_ranks(seeded, 1)
	var seeded_order: Array = _ordered_indexes(seeded)
	_check(int(seeded_order[0]) == 1 and int(seeded_order[1]) == 2 and int(seeded_order[2]) == 0, "the series seed did not break a level table")
	Sport.apply_seed_ranks(seeded, 2)
	seeded_order = _ordered_indexes(seeded)
	_check(int(seeded_order[0]) == 2 and int(seeded_order[1]) == 0 and int(seeded_order[2]) == 1, "seed 2 order drifted")


func _play_regular(played, tactic: String, focus: String) -> void:
	for week_index in Sport.SERIES_WEEKS:
		var started: Dictionary = played.begin_match([0, 1, 2, 3], tactic, focus)
		_check(bool(started.get("ok", false)), "scripted week %d failed to start" % (week_index + 1))
		var committed: Dictionary = played.commit_match()
		_check(bool(committed.get("ok", false)), "scripted week %d failed to record" % (week_index + 1))


func _explanations(match_result: Dictionary) -> Array:
	var lines: Array = []
	for pa in match_result["plate_appearances"]:
		lines.append(str(pa["explanation"]))
	return lines


func _same_lines(left: Array, right: Array) -> bool:
	if left.size() != right.size():
		return false
	for i in left.size():
		if str(left[i]) != str(right[i]):
			return false
	return true


func _final_lines(series_seed: int, final_lineup: Array) -> Array:
	var played := SeriesScript.new(series_seed)
	_play_regular(played, "aggressive", "lash")
	if not played.reached_final():
		return []
	var fin: Dictionary = played.begin_match(final_lineup, "aggressive", "lash")
	if not bool(fin.get("ok", false)):
		return []
	return _explanations(fin)


func _stats_in_range(rosters: Array) -> bool:
	for roster in rosters:
		for player in roster:
			for key in Sport.STATS:
				var value := Sport.get_stat(player, key)
				if value < Sport.STAT_FLOOR or value > Sport.STAT_CAP:
					return false
	return true


func _test_final() -> void:
	print("TEST final")
	var missed := SeriesScript.new(14)
	_play_regular(missed, "aggressive", "lash")
	_check(missed.results.size() == 8, "miss script did not play week 8")
	_check(int(missed.results[7]["week"]) == 7, "miss script week 8 is not the eighth match")
	_check((missed.results[7]["plate_appearances"] as Array).size() == Sport.PAS_PER_MATCH, "miss script week 8 was not a full match")
	_check(not missed.reached_final(), "scripted miss reached the final")
	_check(missed.is_over(), "scripted miss did not end after week 8")
	_check(missed.final_result.is_empty(), "scripted miss stored a final")
	_check(not missed.goal_met(), "scripted miss met the goal")
	var blocked: Dictionary = missed.begin_match([0, 1, 2, 3], "aggressive", "lash")
	_check(not bool(blocked.get("ok", false)), "scripted miss was allowed to play a final")
	_check(_stats_in_range(missed.rosters), "scripted miss left a stat outside 1-20")
	var missed_third := false
	for result in missed.results:
		if str(result["home_club"]) == Sport.THIRD_CLUB or str(result["away_club"]) == Sport.THIRD_CLUB:
			missed_third = true
	_check(missed_third, "third club did not appear in the scripted miss")

	var first_lines := _final_lines(0, [0, 1, 2, 3])
	var second_lines := _final_lines(0, [0, 1, 2, 3])
	var other_lines := _final_lines(0, [5, 4, 3, 2])
	_check(first_lines.size() == Sport.PAS_PER_MATCH, "winning script did not play a final")
	_check(_same_lines(first_lines, second_lines), "the same seed and lineup did not repeat the final at-bats")
	_check(not _same_lines(first_lines, other_lines), "a different final lineup repeated the same at-bats")

	var won := SeriesScript.new(0)
	_play_regular(won, "aggressive", "lash")
	_check(won.results.size() == 8, "win script did not play week 8")
	_check((won.results[7]["plate_appearances"] as Array).size() == Sport.PAS_PER_MATCH, "win script week 8 was not a full match")
	_check(str(won.results[7]["home_club"]) == Sport.THIRD_CLUB or str(won.results[7]["away_club"]) == Sport.THIRD_CLUB, "third club missed week 8 of the win script")
	_check(won.reached_final(), "scripted win missed the final")
	_check(not won.is_over(), "scripted win ended before the final")
	var points_before: Array = []
	var diff_before: Array = []
	for row in won.table():
		points_before.append(int(row["points"]))
		diff_before.append(int(row["run_diff"]))
	var lash_before: Array = []
	var eye_before: Array = []
	for player in won.player_roster:
		lash_before.append(Sport.get_stat(player, "lash"))
		eye_before.append(Sport.get_stat(player, "eye"))
	var fin: Dictionary = won.begin_match([0, 1, 2, 3], "aggressive", "lash")
	_check(bool(fin.get("ok", false)), "scripted final did not start")
	_check(bool(fin.get("is_final", false)), "scripted final was a regular week")
	_check(int(fin["seed"]) == Sport.match_seed_for(0, 8), "final seed drifted")
	_check(str(fin["player_result"]) == "win", "scripted final was not a win")
	_check(int(fin["player_score"]) == 11 and int(fin["opponent_score"]) == 8, "scripted final score drifted")
	_check(str(fin["opponent_club"]) == Sport.OPPONENT_CLUB, "scripted final opponent drifted")
	_check(bool(fin["player_bats_second"]), "the club ahead did not bat second")
	_check(str(fin["home_club"]) == Sport.PLAYER_CLUB, "home was not listed as the club ahead")
	var ordered: Array = Sport.sorted_table(won.table())
	_check(int(ordered[0]["index"]) == int(fin["home_index"]), "final home is not the club ahead in the table")
	_check(int(ordered[1]["index"]) == int(fin["away_index"]), "final away is not the second club")
	var replay: Dictionary = Sport.simulate_match(
		Sport.match_seed_for(0, 8),
		Sport.lineup_players(won.rosters[int(fin["home_index"])], fin["home_lineup"]),
		Sport.lineup_players(won.rosters[int(fin["away_index"])], fin["away_lineup"]),
		str(fin["home_tactic"]),
		str(fin["away_tactic"]),
		str(fin["home_club"]),
		str(fin["away_club"])
	)
	_check(_same_lines(_explanations(fin), _explanations(replay)), "final at-bats were not the pure match function")
	_check(_same_lines(_explanations(fin), first_lines), "final at-bats drifted from the repeated seed")
	var recorded: Dictionary = won.commit_match()
	_check(bool(recorded.get("ok", false)), "scripted final did not record")
	_check(bool(recorded.get("final", false)), "scripted final was recorded as a regular week")
	_check(won.is_over(), "series stayed open after the final")
	_check(won.goal_met(), "winning the final missed the goal")
	_check(won.results.size() == 8, "the final was added to the round-robin table")
	_check(int(won.week) == 8, "the final advanced the week counter")
	for i in won.table().size():
		_check(int(won.table()[i]["points"]) == int(points_before[i]), "the final changed table points")
		_check(int(won.table()[i]["run_diff"]) == int(diff_before[i]), "the final changed run difference")
	for i in won.player_roster.size():
		_check(
			Sport.get_stat(won.player_roster[i], "lash") == mini(int(lash_before[i]) + 1, Sport.STAT_CAP),
			"final training did not add 1 Lash up to the cap"
		)
		_check(Sport.get_stat(won.player_roster[i], "eye") == int(eye_before[i]), "final training changed Eye")
	_check(_stats_in_range(won.rosters), "scripted win left a stat outside 1-20")
	print("Scripted final: Lumen Reedmice %d, %s %d" % [int(fin["player_score"]), str(fin["opponent_club"]), int(fin["opponent_score"])])

	var lost := SeriesScript.new(8)
	_play_regular(lost, "aggressive", "lash")
	_check(lost.reached_final(), "loss script missed the final")
	var loss_match: Dictionary = lost.begin_match([0, 1, 2, 3], "aggressive", "lash")
	_check(str(loss_match.get("player_result", "")) == "loss", "loss script did not lose the final")
	var loss_done: Dictionary = lost.commit_match()
	_check(bool(loss_done.get("over", false)), "a played final did not end the series")
	_check(not lost.goal_met(), "losing the final met the goal")
	_check(not lost.final_result.is_empty(), "a played final was dropped")
	_check(lost.results.size() == 8, "a played final changed the round-robin length")


func _check_round_robin_office(game, where: String) -> void:
	_check(game.phase == "office", where + " is not the office")
	_check(game.office_panel.visible, where + " hides the office")
	_check(game.goal_label.visible, where + " hides the goal")
	_check(str(game.goal_label.text).contains("reach the final and win it"), where + " is missing the new board goal")
	_check(game.rule_label.visible, where + " hides the final rule")
	_check(str(game.rule_label.text).contains("best points-per-game"), where + " is missing how the finalists are chosen")
	_check(str(game.rule_label.text).contains("A win is 2 points and a tie is 1."), where + " is missing the points rule")
	_check(str(game.rule_label.text).contains("An equal rate is not ahead."), where + " is missing the equal-rate rule")
	_check(str(game.rule_label.text).contains(Sport.TIE_RULE), where + " is missing the tie rule")
	_check(str(game.rule_label.text).contains(Sport.SEED_RULE), where + " is missing the seed rule")
	_check(game.schedule_label.visible, where + " hides the round-robin")
	_check(str(game.shape_label.text).contains("round-robin"), where + " is missing the schedule shape")
	var schedule := str(game.schedule_label.text)
	for club_name in Sport.CLUB_NAMES:
		_check(schedule.contains(str(club_name)), where + " schedule is missing " + str(club_name))
	for week_no in Sport.SERIES_WEEKS:
		_check(schedule.contains("Week %d" % (week_no + 1)), where + " schedule is missing week %d" % (week_no + 1))
	var standings := str(game.standings_label.text)
	_check(standings.contains(Sport.THIRD_CLUB), where + " standings are missing the third club")
	_check(standings.contains(Sport.TIE_RULE), where + " standings are missing the tie rule")
	_check(standings.contains("run diff"), where + " standings are missing run difference")
	_check(
		standings.contains("Series seed order: %s." % Sport.seed_order_names(int(game.series.seed))),
		where + " standings are missing the series seed order"
	)


func _test_game_flow() -> void:
	print("TEST game flow")
	var packed: PackedScene = load("res://scenes/main.tscn")
	_check(packed != null, "main scene failed to load")
	if packed == null:
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	_check(game.get_script() != null, "game script failed to parse")
	if game.get_script() == null:
		game.queue_free()
		return
	_check_round_robin_office(game, "open")

	game.start_new_series(42)
	await process_frame
	_check_round_robin_office(game, "start")
	_check(str(game.week_label.text) == "Week 1 of 8", "office does not open on an eight-week series")
	_check(str(game.tactic) == "aggressive", "default tactic is not aggressive")
	_check(str(game.training) == "lash", "default training is not lash")
	_check(is_equal_approx(float(game.ticker.wait_time), 1.0), "watch is not one plate appearance per second")
	game.watch_button.pressed.emit()
	_check(game.phase == "watch", "watch did not start")
	await process_frame
	_check(game.field_board.size.y >= 200.0, "match field did not lay out")
	_check(game.watch_log.size() == 1, "watch did not show the first plate appearance")
	game.fast_forward_watch()
	var appearances: Array = game.current_match["plate_appearances"]
	_check(appearances.size() == Sport.PAS_PER_MATCH, "fixed match plate count")
	_check(game.watch_log.size() == appearances.size(), "watch log is not one line per plate appearance")
	_check(game.phase == "watch", "fast forward left the watch")
	for i in appearances.size():
		var line := str(game.watch_log[i])
		var pa: Dictionary = appearances[i]
		_check(line == str(pa["explanation"]), "watch log line %d does not match the plate appearance" % i)
		_check(_line_explains(line, str(pa["batter_name"])), "watch line %d is not an explanation: %s" % [i, line])
	_check(str(game.explanation_label.text) == str(game.watch_log[game.watch_log.size() - 1]), "explanation label is not the latest watch line")
	_check(str(game.log_label.text).contains(str(game.watch_log[0])), "on-screen watch log is missing the first line")
	_check(str(game.log_label.text).contains(str(game.watch_log[appearances.size() - 1])), "on-screen watch log is missing the last line")

	game.start_new_series(14)
	_check_round_robin_office(game, "scripted miss")
	for week in 8:
		_check(game.phase == "office", "week %d did not return to the office" % (week + 1))
		_check(int(game.series.week) == week, "office week counter is not %d before that match" % (week + 1))
		_check(str(game.schedule_label.text).contains(Sport.THIRD_CLUB), "third club left the office in week %d" % (week + 1))
		if not game.series.player_plays():
			_check(str(game.record_label.text).contains("Bye"), "bye week is not marked on the office")
			_check(str(game.opponent_label.text).contains("Bye"), "bye fixture is not explained")
		game.skip_button.pressed.emit()
		_check(game.phase == "result", "skip did not reach the result in week %d" % (week + 1))
		_check(game.watch_log.size() == Sport.PAS_PER_MATCH, "skip log length in week %d" % (week + 1))
		game.continue_button.pressed.emit()
		if week < 7:
			_check(game.phase == "office", "series reached the board before week 8 was played")
	_check(game.phase == "board", "a missed final did not end on the board")
	_check(game.board_panel.visible, "board screen is hidden")
	_check(not game.office_panel.visible, "office still visible on the board")
	_check(not game.match_panel.visible, "match still visible on the board")
	var board_text := str(game.board_label.text)
	_check(board_text.contains("reach the final and win it"), "board screen is missing the new goal")
	_check(board_text.contains(Sport.TIE_RULE), "board screen is missing the tie rule")
	_check(board_text.contains(Sport.SEED_RULE), "board screen is missing the seed rule")
	_check(board_text.contains(Sport.THIRD_CLUB), "third club did not reach the board")
	_check(board_text.contains("Result: MISSED"), "a missed final should be MISSED")
	_check(not board_text.contains("Result: MET"), "goal text contradicts MISSED")
	_check(board_text.contains("The final: not played."), "a missed final was played on the board")
	_check(board_text.contains("missed it"), "board does not say the final was missed")
	_check(board_text.contains("without a final"), "board does not end the season without a final")
	_check(board_text.contains("Week 1:"), "board screen is missing week 1")
	_check(board_text.contains("Week 8:"), "week 8 was not played")
	_check(game.series.results.size() == 8, "series did not store the week 8 result")
	_check(int(game.series.results[7]["week"]) == 7, "week 8 result is missing from the series")
	_check(int(game.series.week) == 8, "week counter did not finish on week 8")
	_check((game.series.results[7]["plate_appearances"] as Array).size() == Sport.PAS_PER_MATCH, "week 8 was not a full match")
	_check(not game.series.reached_final(), "scripted board series reached the final")
	_check(game.series.final_result.is_empty(), "scripted board series stored a final")
	var bye_weeks := 0
	for result in game.series.results:
		if not bool(result["player_played"]):
			bye_weeks += 1
	_check(bye_weeks == 2, "the round-robin did not give the player two byes")
	var rec: Dictionary = game.series.record()
	_check(not game.series.goal_met(), "a missed final met the goal")
	_check(board_text.contains("Your points: %d from %d" % [int(rec["points"]), int(rec["played"])]), "board points do not match the series")
	print("Scripted miss result: MISSED")
	print(board_text)

	var seed_before := int(game.series.seed)
	game.board_restart_button.pressed.emit()
	_check(game.phase == "office", "restart did not return to the office")
	_check(int(game.series.week) == 0, "restart did not reset the week")
	_check(game.series.results.is_empty(), "restart kept old results")
	_check(int(game.series.seed) == seed_before + 1, "restart did not advance the seed")

	game.start_new_series(0)
	_check_round_robin_office(game, "scripted win")
	for week in 8:
		_check(game.phase == "office", "win script week %d did not return to the office" % (week + 1))
		game.skip_button.pressed.emit()
		_check(game.phase == "result", "win script skip missed the result in week %d" % (week + 1))
		game.continue_button.pressed.emit()
	_check(game.phase == "office", "reaching the final skipped the final office")
	_check(game.series.in_final(), "win script did not open the final")
	_check(str(game.week_label.text) == "Final", "final office is not labeled Final")
	_check(str(game.goal_label.text).contains("reach the final and win it"), "final office lost the board goal")
	_check(str(game.rule_label.text).contains(Sport.TIE_RULE), "final office lost the tie rule")
	_check(str(game.fixture_title.text) == "Final: Southspur Glass", "final opponent was not shown")
	_check(str(game.record_label.text).contains("You bat second."), "the club ahead did not bat second on screen")
	_check(str(game.schedule_label.text).contains("Final   Lumen Reedmice vs Southspur Glass"), "final schedule did not list home first")
	_check_round_robin_office(game, "final office")
	var slot_before := int(game.lineup[0])
	game._unhandled_input(_key(KEY_RIGHT))
	_check(int(game.lineup[0]) != slot_before, "Right did not change the final lineup")
	_check(Sport.is_legal_lineup(Sport.ROSTER_SIZE, game.lineup), "final lineup became illegal")
	game._unhandled_input(_key(KEY_LEFT))
	_check(int(game.lineup[0]) == slot_before, "Left did not restore the final lineup")
	game._unhandled_input(_key(KEY_T))
	_check(str(game.tactic) == "patient", "T did not change the final tactic")
	game._unhandled_input(_key(KEY_T))
	game._unhandled_input(_key(KEY_T))
	_check(str(game.tactic) == "aggressive", "T did not cycle the final tactic back")
	game._unhandled_input(_key(KEY_Y))
	_check(str(game.training) == "eye", "Y did not change the final training focus")
	game.training_buttons[0].pressed.emit()
	_check(str(game.training) == "lash", "the training button did not restore the final focus")
	_check(is_equal_approx(float(game.ticker.wait_time), 1.0), "final watch is not one plate appearance per second")
	game.watch_button.pressed.emit()
	_check(game.phase == "watch", "final watch did not start")
	await process_frame
	_check(game.field_board.size.y >= 200.0, "final field did not lay out")
	_check(game.watch_log.size() == 1, "final watch did not show the first plate appearance")
	game.match_skip_button.pressed.emit()
	_check(game.phase == "result", "final skip did not reach the result")
	var final_appearances: Array = game.current_match["plate_appearances"]
	_check(final_appearances.size() == Sport.PAS_PER_MATCH, "final plate count")
	_check(game.watch_log.size() == final_appearances.size(), "final watch log is not one line per plate appearance")
	for i in final_appearances.size():
		_check(str(game.watch_log[i]) == str(final_appearances[i]["explanation"]), "final watch line %d drifted" % i)
	_check(str(game.result_label.text).begins_with("The final:"), "final result screen is not the final")
	_check(str(game.current_match["player_result"]) == "win", "watched final was not a win")
	var lash_before: Array = []
	for player in game.series.player_roster:
		lash_before.append(Sport.get_stat(player, "lash"))
	game.continue_button.pressed.emit()
	_check(game.phase == "board", "winning the final did not reach the board")
	var win_board := str(game.board_label.text)
	_check(win_board.contains("Result: MET"), "winning the final should be MET")
	_check(not win_board.contains("Result: MISSED"), "goal text contradicts MET")
	_check(win_board.contains("The final:"), "board is missing the final score")
	_check(not win_board.contains("not played"), "a played final was marked not played")
	_check(win_board.contains("reached the final and won it"), "board does not say the final was won")
	_check(win_board.contains(Sport.TIE_RULE), "win board is missing the tie rule")
	_check(win_board.contains("Week 8:"), "win board skipped week 8")
	_check(win_board.contains(Sport.THIRD_CLUB), "third club left the win board")
	_check(game.series.goal_met(), "the board goal was not met after the final win")
	_check(game.series.results.size() == 8, "the final was stored as a ninth week")
	_check(_stats_in_range(game.series.rosters), "final left a stat outside 1-20")
	for i in game.series.player_roster.size():
		_check(
			Sport.get_stat(game.series.player_roster[i], "lash") == mini(int(lash_before[i]) + 1, Sport.STAT_CAP),
			"final training did not add 1 on the board"
		)
	print("Scripted final from the office: MET")
	print(win_board)

	game.start_new_series(3)
	var before_slot := int(game.lineup[0])
	game._unhandled_input(_key(KEY_RIGHT))
	_check(int(game.lineup[0]) != before_slot, "Right did not change the lineup slot")
	_check(Sport.is_legal_lineup(Sport.ROSTER_SIZE, game.lineup), "keyboard lineup became illegal")
	game._unhandled_input(_key(KEY_T))
	_check(str(game.tactic) == "patient", "T did not cycle the tactic")
	game._unhandled_input(_key(KEY_Y))
	_check(str(game.training) == "eye", "Y did not cycle the training focus")
	game._unhandled_input(_key(KEY_2))
	_check(int(game.selected_slot) == 1, "key 2 did not select slot 2")
	game.roster_buttons[5].pressed.emit()
	_check(int(game.lineup[1]) == 5, "roster button did not assign the selected slot")
	game._unhandled_input(_key(KEY_S))
	_check(game.phase == "result", "S did not skip to the result")
	game._unhandled_input(_key(KEY_N))
	_check(game.phase == "office", "N did not continue to the next office")
	_check(int(game.series.week) == 1, "continue did not advance the week")
	game.queue_free()
	await process_frame
