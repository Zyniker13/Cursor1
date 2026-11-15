extends SceneTree

const Sport = preload("res://scripts/sport.gd")
const SeriesScript = preload("res://scripts/series.gd")

var _failures: Array = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_failures = []
	_test_names()
	_test_fourth_club_and_schedule()
	_test_tie_break()
	_test_full_schedule_played()
	_test_scripted_final()
	_test_determinism()
	_test_stats_and_cap()
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


func _paint(series, player_value: int, other_value: int) -> void:
	for club_index in series.rosters.size():
		var value := player_value if club_index == Sport.PLAYER_INDEX else other_value
		for player in series.rosters[club_index]:
			for key in Sport.STATS:
				Sport.set_stat(player, key, value)


func _play_week(series, lineup: Array, tactic: String, focus: String) -> Dictionary:
	var started: Dictionary = series.begin_match(lineup, tactic, focus)
	_check(bool(started.get("ok", false)), str(started.get("error", "match did not start")))
	if bool(started.get("ok", false)):
		series.commit_match()
	return started


func _stat_signature(roster: Array) -> String:
	var parts: Array = []
	for player in roster:
		var bits: Array = []
		for key in Sport.STATS:
			bits.append(str(Sport.get_stat(player, key)))
		parts.append(",".join(bits))
	parts.sort()
	return "|".join(parts)


func _table_signature(table: Array) -> String:
	var parts: Array = []
	for row in table:
		parts.append("%d:%d:%d:%d:%d" % [
			int(row["club"]), int(row["points"]), int(row["played"]), int(row["run_diff"]), int(row["wins"]),
		])
	return "|".join(parts)


func _stats_in_range(roster: Array, label: String) -> void:
	for player in roster:
		_check(Sport.is_generated_name(str(player["player_name"])), label + " has a bad name")
		for key in Sport.STATS:
			var value := Sport.get_stat(player, key)
			if value < Sport.STAT_FLOOR or value > Sport.STAT_CAP:
				_check(false, "%s stat %s left 1-20 at %d" % [label, key, value])


func _collect_at_bats(series_seed: int, paint_player: int, paint_other: int) -> Array:
	var played := SeriesScript.new(series_seed)
	if paint_player > 0:
		_paint(played, paint_player, paint_other)
	var lines: Array = []
	while not played.is_over():
		var started: Dictionary = played.begin_match([0, 1, 2, 3], "aggressive", "lash")
		if not bool(started.get("ok", false)):
			lines.append("ERROR")
			break
		for pa in started["plate_appearances"]:
			lines.append(str(pa["explanation"]))
		var other: Dictionary = started.get("other", {})
		if not other.is_empty():
			for pa in other["plate_appearances"]:
				lines.append(str(pa["explanation"]))
		played.commit_match()
	return lines


func _same_at_bats(left: Array, right: Array, label: String) -> void:
	_check(left.size() == right.size(), label + " at-bat count drifted")
	if left.size() != right.size():
		return
	for i in left.size():
		if str(left[i]) != str(right[i]):
			_check(false, "%s at-bat drifted at %d" % [label, i])
			return


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
		var used := {}
		_check((clubs["rosters"] as Array).size() == 4, "create_clubs did not return four rosters")
		for roster in clubs["rosters"]:
			for player in roster:
				var full_name := str(player["player_name"])
				_check(Sport.is_generated_name(full_name), "name is not a syllable join: " + full_name)
				_check(not used.has(full_name), "duplicate name in a series: " + full_name)
				used[full_name] = true
				generated += 1
				for key in Sport.STATS:
					var value := Sport.get_stat(player, key)
					_check(value >= Sport.GEN_MIN and value <= Sport.GEN_MAX, "generated stat out of 9-15")
	_check(generated == 40 * Sport.ROSTER_SIZE * Sport.CLUBS.size(), "unexpected generated name count")
	_check(not Sport.is_generated_name("John Smith"), "plain name was accepted")
	_check(not Sport.is_generated_name("Bridax"), "one-word name was accepted")
	_check(not Sport.is_generated_name("Bridax Fexnel Extra"), "three-word name was accepted")


func _test_fourth_club_and_schedule() -> void:
	print("TEST fourth club and schedule shape")
	_check(Sport.CLUBS.size() == 4, "expected four clubs")
	_check(Sport.HERONS_CLUB == "Marrowgate Herons", "fourth club name drifted")
	_check(Sport.CLUBS.has(Sport.PLAYER_CLUB), "player club missing")
	_check(Sport.CLUBS.has(Sport.GLASS_CLUB), "Southspur Glass missing")
	_check(Sport.CLUBS.has(Sport.CINDERS_CLUB), "Pellwick Cinders missing")
	_check(Sport.CLUBS.has(Sport.HERONS_CLUB), "fourth club missing from the club list")
	_check(Sport.SERIES_WEEKS == 6, "a four-club double round-robin is six weeks")
	_check(Sport.MATCHES_PER_WEEK == 2, "a four-club round needs two matches a week")
	_check(Sport.SCHEDULE.size() == Sport.SERIES_WEEKS, "schedule length drifted")
	_check(
		Sport.GOAL_TEXT == "Board goal: reach the final and win it. A loss or a tie in the final misses it.",
		"board goal text drifted"
	)
	var schedule := Sport.schedule_text([])
	_check(schedule.contains("Two matches a week"), "schedule does not say two matches a week")
	_check(schedule.contains("Week 1: Lumen Reedmice at Southspur Glass. Pellwick Cinders at Marrowgate Herons."), "week 1 fixtures drifted")
	_check(schedule.contains("Week 6: Marrowgate Herons at Lumen Reedmice. Pellwick Cinders at Southspur Glass."), "week 6 fixtures drifted")
	_check(schedule.contains(Sport.HERONS_CLUB), "schedule omits the fourth club")
	for week in Sport.SERIES_WEEKS:
		_check(schedule.contains("Week %d:" % (week + 1)), "schedule is missing week %d" % (week + 1))
	var pair_count := {}
	var directed := {}
	for week in Sport.SERIES_WEEKS:
		var pairs: Array = Sport.SCHEDULE[week]
		_check(pairs.size() == Sport.MATCHES_PER_WEEK, "week %d does not have two matches" % (week + 1))
		var seen_clubs := {}
		for pair in pairs:
			var away := int(pair[0])
			var home := int(pair[1])
			_check(away != home, "a club is scheduled against itself")
			_check(not seen_clubs.has(away) and not seen_clubs.has(home), "a club plays twice in week %d" % (week + 1))
			seen_clubs[away] = true
			seen_clubs[home] = true
			var key := "%d-%d" % [mini(away, home), maxi(away, home)]
			pair_count[key] = int(pair_count.get(key, 0)) + 1
			var arrow := "%d@%d" % [away, home]
			_check(not directed.has(arrow), "directed fixture repeated: " + arrow)
			directed[arrow] = true
		_check(seen_clubs.size() == 4, "week %d leaves a club out" % (week + 1))
	_check(pair_count.size() == 6, "the schedule is not every pairing")
	for key in pair_count.keys():
		_check(int(pair_count[key]) == 2, "pairing %s is not home and away" % str(key))
	_check(int(Sport.player_fixture(0)[0]) == Sport.PLAYER_INDEX, "week 1 does not send the player away")
	_check(int(Sport.player_fixture(3)[1]) == Sport.PLAYER_INDEX, "the return fixture does not bring the player home")
	var clubs: Dictionary = Sport.create_clubs(42)
	var first_sig := _stat_signature(clubs["rosters"][0])
	for roster in clubs["rosters"]:
		_check(_stat_signature(roster) == first_sig, "clubs were not given the same stat lines")
	var again: Dictionary = Sport.create_clubs(42)
	for i in Sport.CLUBS.size():
		_check(_same_players(clubs["rosters"][i], again["rosters"][i]), "roster %d drifted" % i)


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


func _test_tie_break() -> void:
	print("TEST tie-break")
	_check(Sport.seed_order(0)[0] == 0, "remainder 0 does not start with Lumen Reedmice")
	_check(Sport.seed_order(1)[0] == 1, "remainder 1 does not start with Southspur Glass")
	_check(Sport.seed_order(2)[0] == 2, "remainder 2 does not start with Pellwick Cinders")
	_check(Sport.seed_order(3)[0] == 3, "remainder 3 does not start with the fourth club")
	_check(str(Sport.CLUBS[int(Sport.seed_order(3)[0])]) == Sport.HERONS_CLUB, "fourth club is not the seed-3 starter")
	_check(Sport.seed_order(4)[0] == 0, "seed order did not wrap every four")
	_check(Sport.seed_order(-1)[0] == 3, "negative seed did not wrap to the fourth club")
	var order3: Array = Sport.seed_order(3)
	_check(int(order3[0]) == 3 and int(order3[1]) == 0 and int(order3[2]) == 1 and int(order3[3]) == 2, "remainder 3 order is not Herons, Reedmice, Glass, Cinders")
	var tied := [
		{"away": 0, "home": 1, "away_score": 3, "home_score": 3, "week": 0},
		{"away": 2, "home": 3, "away_score": 3, "home_score": 3, "week": 0},
	]
	var by_zero: Array = Sport.standings(tied, 0)
	_check(int(by_zero[0]["club"]) == 0, "level clubs did not follow remainder 0")
	_check(int(by_zero[3]["club"]) == 3, "fourth club was not last when the seed starts at Reedmice")
	_check(int(by_zero[0]["points"]) == Sport.TIE_POINTS, "a tie was not worth 1 point")
	var by_three: Array = Sport.standings(tied, 3)
	_check(int(by_three[0]["club"]) == 3, "remainder 3 did not put the fourth club first on a full tie")
	_check(int(by_three[3]["club"]) == 2, "remainder 3 order did not finish with Pellwick Cinders")
	var split := [
		{"away": 3, "home": 1, "away_score": 6, "home_score": 1, "week": 0},
		{"away": 0, "home": 2, "away_score": 2, "home_score": 1, "week": 0},
	]
	var by_diff: Array = Sport.standings(split, 0)
	_check(int(by_diff[0]["club"]) == 3, "higher run difference did not outrank the seed leader")
	_check(int(by_diff[1]["club"]) == 0, "the lower run difference should be second when rates match")
	_check(Sport.rate_compare(4, 4, 2, 2) == 0, "equal points-per-game rates were not level")
	var many := {"club": 0, "points": 4, "played": 4, "run_diff": 0}
	var few := {"club": 3, "points": 2, "played": 2, "run_diff": 0}
	_check(not Sport.stands_ahead(many, few, 3), "an equal rate let the higher point total finish ahead")
	_check(Sport.stands_ahead(few, many, 3), "seed remainder 3 did not put the fourth club ahead of an equal rate")
	var high_rate := {"club": 2, "points": 4, "played": 2, "run_diff": -3}
	var high_diff := {"club": 0, "points": 2, "played": 2, "run_diff": 9}
	_check(Sport.stands_ahead(high_rate, high_diff, 0), "points per game lost to run difference")
	_check(not Sport.stands_ahead(high_diff, high_rate, 0), "a worse rate was treated as ahead")
	var win_rows: Array = Sport.standings([
		{"away": 0, "home": 3, "away_score": 2, "home_score": 0, "week": 0},
	], 0)
	var reedmice: Dictionary = {}
	for row in win_rows:
		if int(row["club"]) == 0:
			reedmice = row
	_check(int(reedmice["points"]) == Sport.WIN_POINTS, "a win was not worth 2 points")
	_check(int(reedmice["run_diff"]) == 2, "run difference did not count the win")


func _test_full_schedule_played() -> void:
	print("TEST full schedule is played")
	var played := SeriesScript.new(11)
	var expected := {}
	for week in Sport.SERIES_WEEKS:
		for pair in Sport.SCHEDULE[week]:
			expected["%d:%d:%d" % [week, int(pair[0]), int(pair[1])]] = true
		var started: Dictionary = played.begin_match([0, 1, 2, 3], "patient", "eye")
		_check(bool(started.get("ok", false)), "week %d did not start" % (week + 1))
		_check(int(started.get("week", -1)) == week, "week %d was not the match that was played" % (week + 1))
		_check((started["plate_appearances"] as Array).size() == Sport.PAS_PER_MATCH, "player match was short in week %d" % (week + 1))
		var other: Dictionary = started.get("other", {})
		_check(not other.is_empty(), "week %d did not play the other match" % (week + 1))
		_check((other["plate_appearances"] as Array).size() == Sport.PAS_PER_MATCH, "the other match was short in week %d" % (week + 1))
		_check(_score_matches_runs(started), "player runs did not add up in week %d" % (week + 1))
		_check(_score_matches_runs(other), "other runs did not add up in week %d" % (week + 1))
		var committed: Dictionary = played.commit_match()
		_check(bool(committed.get("ok", false)), "week %d did not record" % (week + 1))
		if week < Sport.SERIES_WEEKS - 1:
			_check(not played.is_over(), "season ended before the schedule was played")
	_check(played.matches.size() == Sport.regular_match_count(), "the full schedule was not stored")
	_check(played.player_matches().size() == Sport.SERIES_WEEKS, "the player did not play every week")
	var seen := {}
	var clubs_seen := {}
	for fixture in played.matches:
		var key := "%d:%d:%d" % [int(fixture["week"]), int(fixture["away"]), int(fixture["home"])]
		_check(not seen.has(key), "fixture repeated: " + key)
		_check(expected.has(key), "fixture was not on the schedule: " + key)
		seen[key] = true
		clubs_seen[int(fixture["away"])] = true
		clubs_seen[int(fixture["home"])] = true
		for pa in fixture["plate_appearances"]:
			_check(_outcome_runs_ok(pa), "bad outcome runs")
	_check(seen.size() == expected.size(), "a scheduled fixture was never played")
	_check(clubs_seen.size() == 4, "a club never appeared in the played schedule")
	var faced := {}
	for fixture in played.player_matches():
		faced[str(fixture["opponent_club"])] = true
	_check(faced.has(Sport.HERONS_CLUB), "the player never played the fourth club")
	_check(faced.has(Sport.GLASS_CLUB), "the player never played Southspur Glass")
	_check(faced.has(Sport.CINDERS_CLUB), "the player never played Pellwick Cinders")
	var filled := Sport.schedule_text(played.matches)
	_check(filled.contains(Sport.HERONS_CLUB), "played schedule text dropped the fourth club")
	_check(not filled.contains("Week 1: Lumen Reedmice at Southspur Glass. Pellwick Cinders at Marrowgate Herons."), "week 1 was still listed as unplayed")


func _test_scripted_final() -> void:
	print("TEST scripted final")
	var winner := SeriesScript.new(21)
	_paint(winner, 20, 1)
	for _week in Sport.SERIES_WEEKS:
		_play_week(winner, [0, 1, 2, 3], "aggressive", "lash")
	_check(winner.qualified_for_final(), "a dominant series did not reach the final")
	_check(not winner.is_over(), "the season ended without offering the final")
	_check(Sport.rank_of(winner.standings(), Sport.PLAYER_INDEX) == 1, "the dominant club was not first")
	_check(int(winner.record()["wins"]) == Sport.SERIES_WEEKS, "the dominant club did not win every week")
	var before := _table_signature(winner.standings())
	var before_points := int(winner.standings()[0]["points"])
	_check(before_points == Sport.SERIES_WEEKS * Sport.WIN_POINTS, "six wins were not 12 points")
	_check(winner.player_bats_second(), "the club ahead was not home in the final")
	var final_started: Dictionary = winner.begin_match([0, 1, 2, 3], "aggressive", "lash")
	_check(bool(final_started.get("final", false)), "the extra match was not the final")
	_check(str(final_started.get("player_result", "")) == "win", "the dominant club did not win the final")
	_check((final_started["plate_appearances"] as Array).size() == Sport.PAS_PER_MATCH, "the final was not a full match")
	var other: Dictionary = final_started.get("other", {})
	_check(other.is_empty(), "the final also played a second match")
	winner.commit_match()
	_check(winner.is_over(), "the season stayed open after the final")
	_check(winner.goal_met(), "winning the final did not meet the board goal")
	_check(_table_signature(winner.standings()) == before, "the final changed the table")
	_check(int(winner.standings()[0]["points"]) == before_points, "the final changed the leader's points")
	_check(winner.matches.size() == Sport.regular_match_count(), "the final was written into the table matches")
	for player in winner.player_roster:
		for key in Sport.STATS:
			_check(Sport.get_stat(player, key) == Sport.STAT_CAP, "dominant stats did not stay capped at 20")
	var second := int(winner.standings()[1]["club"])
	var third := int(winner.standings()[2]["club"])
	var fourth := int(winner.standings()[3]["club"])
	for key in Sport.STATS:
		var expected := 3 if key == "lash" else 2
		_check(Sport.get_stat(winner.rosters[second][0], key) == expected, "finalist training did not apply in the final")
		_check(Sport.get_stat(winner.rosters[third][0], key) == 2, "a club outside the final trained during it")
		_check(Sport.get_stat(winner.rosters[fourth][0], key) == 2, "fourth place trained during the final")
	var blocked: Dictionary = winner.begin_match([0, 1, 2, 3], "field", "arm")
	_check(not bool(blocked.get("ok", false)), "a match after the final was allowed")
	winner.final_match["player_result"] = "tie"
	_check(not winner.goal_met(), "a tie in the final met the goal")
	winner.final_match["player_result"] = "loss"
	_check(not winner.goal_met(), "a loss in the final met the goal")
	winner.final_match["player_result"] = "win"
	_check(winner.goal_met(), "restoring the win did not meet the goal")

	var loser := SeriesScript.new(22)
	_paint(loser, 20, 1)
	for _week in Sport.SERIES_WEEKS:
		_play_week(loser, [0, 1, 2, 3], "aggressive", "lash")
	var table_before_loss := _table_signature(loser.standings())
	_check(loser.qualified_for_final(), "the loss script did not reach the final")
	_paint(loser, 1, 20)
	var lost: Dictionary = loser.begin_match([0, 1, 2, 3], "patient", "eye")
	_check(str(lost.get("player_result", "")) == "loss", "a weakened finalist did not lose the final")
	loser.commit_match()
	_check(loser.is_over(), "a lost final did not end the season")
	_check(not loser.goal_met(), "losing the final still met the goal")
	_check(_table_signature(loser.standings()) == table_before_loss, "a lost final changed the table")

	var miss := SeriesScript.new(23)
	_paint(miss, 1, 20)
	for _week in Sport.SERIES_WEEKS:
		var started: Dictionary = _play_week(miss, [0, 1, 2, 3], "field", "glove")
		_check(str(started.get("player_result", "")) == "loss", "the miss script won a match")
	_check(miss.is_over(), "missing the final left the season open")
	_check(miss.final_match.is_empty(), "a missed final was still played")
	_check(not miss.goal_met(), "missing the final met the goal")
	_check(Sport.rank_of(miss.standings(), Sport.PLAYER_INDEX) == 4, "the miss script was not last")
	_check(int(miss.record()["wins"]) == 0, "the miss script recorded a win")
	_check(int(miss.record()["losses"]) == Sport.SERIES_WEEKS, "the miss script did not lose every week")
	_check(miss.matches.size() == Sport.regular_match_count(), "the miss script did not play the full schedule")
	_check(Sport.get_stat(miss.player_roster[0], "glove") == 7, "six drills did not add 6 to a floor stat")
	_check(Sport.get_stat(miss.player_roster[0], "lash") == 1, "training changed a stat that was not the focus")
	_check(Sport.get_stat(miss.rosters[1][0], "lash") == Sport.STAT_CAP, "opponent training pushed a capped stat")
	var after_miss: Dictionary = miss.begin_match([0, 1, 2, 3], "aggressive", "lash")
	_check(not bool(after_miss.get("ok", false)), "a final was offered to a club that missed it")


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


func _test_determinism() -> void:
	print("TEST determinism")
	var natural_a := _collect_at_bats(11, 0, 0)
	var natural_b := _collect_at_bats(11, 0, 0)
	_check(natural_a.size() >= Sport.regular_match_count() * Sport.PAS_PER_MATCH, "natural series did not record the schedule's at-bats")
	_same_at_bats(natural_a, natural_b, "natural seed")
	var final_a := _collect_at_bats(21, 20, 1)
	var final_b := _collect_at_bats(21, 20, 1)
	_check(final_a.size() == (Sport.regular_match_count() + 1) * Sport.PAS_PER_MATCH, "winning series did not repeat the final's at-bats")
	_same_at_bats(final_a, final_b, "winning seed")
	var miss_a := _collect_at_bats(23, 1, 20)
	var miss_b := _collect_at_bats(23, 1, 20)
	_check(miss_a.size() == Sport.regular_match_count() * Sport.PAS_PER_MATCH, "missed final still produced final at-bats")
	_same_at_bats(miss_a, miss_b, "missing seed")
	_check(natural_a[0] != final_a[0] or natural_a.size() != final_a.size(), "different seeds produced the same opening at-bats and length")


func _test_stats_and_cap() -> void:
	print("TEST stats stay inside 1-20")
	var reached := 0
	var won := 0
	var missed := 0
	var club_wins := [0, 0, 0, 0]
	for series_index in 40:
		var played := SeriesScript.new(100 + series_index)
		while not played.is_over():
			var week_index := int(played.week)
			if week_index >= Sport.SERIES_WEEKS:
				week_index = Sport.SERIES_WEEKS
			var plan: Dictionary = Sport.opponent_plan(played.player_roster, week_index, Sport.PLAYER_INDEX)
			var started: Dictionary = played.begin_match(plan["lineup"], str(plan["tactic"]), str(plan["training"]))
			_check(bool(started.get("ok", false)), "smart series %d did not start" % series_index)
			if not bool(started.get("ok", false)):
				break
			_check(_score_matches_runs(started), "score/runs mismatch in smart series %d" % series_index)
			for pa in started["plate_appearances"]:
				_check(_outcome_runs_ok(pa), "bad outcome runs")
				_check(str(pa["explanation"]).find("\n") < 0, "explanation contains a newline")
			played.commit_match()
			for roster in played.rosters:
				_stats_in_range(roster, "smart series %d" % series_index)
		for fixture in played.matches:
			var home := int(fixture["home"])
			var away := int(fixture["away"])
			if int(fixture["home_score"]) > int(fixture["away_score"]):
				club_wins[home] += 1
			elif int(fixture["away_score"]) > int(fixture["home_score"]):
				club_wins[away] += 1
		var place := Sport.rank_of(played.standings(), Sport.PLAYER_INDEX)
		if played.final_match.is_empty():
			missed += 1
			_check(place >= 3, "a club outside the top two was offered a final")
			_check(not played.goal_met(), "a missed final was marked met")
		else:
			reached += 1
			_check(place <= 2, "a final was played from outside the top two")
			_check(bool(played.final_match["player_bats_second"]) == (place == 1), "final home side did not follow the table")
			if played.goal_met():
				won += 1
	print("Smart series over 40 seeds: reached %d, won the final %d, missed %d" % [reached, won, missed])
	print("Club wins: %s %d, %s %d, %s %d, %s %d" % [
		Sport.CLUBS[0], club_wins[0], Sport.CLUBS[1], club_wins[1], Sport.CLUBS[2], club_wins[2], Sport.CLUBS[3], club_wins[3],
	])
	_check(reached > 0, "no equal series reached the final")
	_check(missed > 0, "no equal series missed the final")
	for i in Sport.CLUBS.size():
		_check(club_wins[i] > 0, Sport.CLUBS[i] + " never won a match")
	var sample: Dictionary = Sport.create_clubs(3)
	var player: Dictionary = sample["rosters"][0][0]
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
	Sport.set_stat(player, "arm", 15)
	for _step in 8:
		Sport.apply_training([player], "arm")
	_check(Sport.get_stat(player, "arm") == Sport.STAT_CAP, "repeated training did not stop at 20")


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


func _test_game_flow() -> void:
	print("TEST game flow")
	var packed: PackedScene = load("res://scenes/main.tscn")
	_check(packed != null, "main scene failed to load")
	if packed == null:
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	_check(game.phase == "office", "game did not open on the office")
	_check(game.office_panel.visible, "office is hidden when the game opens")
	_check(game.schedule_label.visible, "schedule is hidden when the game opens")
	_check(str(game.goal_label.text).contains("reach the final and win it"), "board goal is not on screen from the start")
	_check(str(game.week_label.text) == "Week 1 of 6", "office does not open on week 1")
	var opening_schedule := str(game.schedule_label.text)
	_check(opening_schedule.contains("Two matches a week"), "office schedule does not say two matches a week")
	_check(opening_schedule.contains("Week 1: Lumen Reedmice at Southspur Glass. Pellwick Cinders at Marrowgate Herons."), "week 1 schedule is not on the office")
	_check(opening_schedule.contains(Sport.HERONS_CLUB), "fourth club is missing from the office schedule")
	_check(opening_schedule.contains("Week 6:"), "the office schedule is not the full season")
	_check(str(game.tie_label.text) == Sport.tie_break_text(int(game.series.seed)), "tie-break is not stated from week 1")
	_check(str(game.tie_label.text).contains(Sport.HERONS_CLUB), "tie-break omits the fourth club")
	_check(str(game.table_label.text).contains(Sport.HERONS_CLUB), "table omits the fourth club")
	_check(str(game.table_label.text).contains(Sport.PLAYER_CLUB), "table omits the player")

	game.start_new_series(42)
	await process_frame
	_check(str(game.goal_label.text).contains("reach the final and win it"), "board goal left the office")
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
		_check(_line_explains(line, str(pa["batter_name"])), "watch line %d is not an explanation" % i)
	_check(str(game.explanation_label.text) == str(game.watch_log[game.watch_log.size() - 1]), "explanation label is not the latest watch line")

	game.start_new_series(3)
	var before_eye := Sport.get_stat(game.series.player_roster[0], "eye")
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
	_check(str(game.result_label.text).contains("Also this week"), "skip result hid the other match")
	_check(str(game.result_label.text).contains(Sport.HERONS_CLUB), "week 1 result hid the fourth club")
	game._unhandled_input(_key(KEY_N))
	_check(game.phase == "office", "N did not continue to the next office")
	_check(int(game.series.week) == 1, "continue did not advance the week")
	_check(Sport.get_stat(game.series.player_roster[0], "eye") == before_eye + 1, "training did not add 1")

	game.start_new_series(21)
	_paint(game.series, 20, 1)
	for week in Sport.SERIES_WEEKS:
		_check(game.phase == "office", "week %d did not return to the office" % (week + 1))
		_check(int(game.series.week) == week, "office week counter drifted")
		if week == 2:
			_check(str(game.opponent_heading.text) == Sport.HERONS_CLUB, "week 3 opponent is not the fourth club")
		game.skip_button.pressed.emit()
		_check(game.phase == "result", "skip did not reach the result in week %d" % (week + 1))
		game.continue_button.pressed.emit()
	_check(game.phase == "office", "reaching the final skipped the final office")
	_check(str(game.week_label.text) == "Final", "the final office is not labeled")
	_check(game.schedule_label.visible, "schedule left the office before the final")
	_check(str(game.goal_label.text).contains("reach the final and win it"), "goal left the final office")
	_check(game.series.player_bats_second(), "final office did not bat the leader second")
	_check(str(game.record_label.text).contains("Finished 1st"), "final office did not show first place")
	Sport.set_stat(game.series.player_roster[0], "read", 19)
	game._set_training("read")
	game._unhandled_input(_key(KEY_T))
	_check(str(game.tactic) == "patient", "tactic did not change for the final")
	var final_slot := int(game.lineup[0])
	game._unhandled_input(_key(KEY_RIGHT))
	_check(int(game.lineup[0]) != final_slot, "lineup did not change for the final")
	var table_before: String = _table_signature(game.series.standings())
	game.watch_button.pressed.emit()
	_check(game.phase == "watch", "watch did not start for the final")
	_check(bool(game.current_match.get("final", false)), "watched match was not the final")
	_check(str(game.current_match.get("player_tactic", "")) == "patient", "final watch ignored the tactic")
	_check(str(game.current_match.get("player_focus", "")) == "read", "final watch ignored training")
	_check(int(game.current_match["player_lineup"][0]) == int(game.lineup[0]), "final watch ignored the lineup")
	_check(game.watch_log.size() == 1, "final watch did not show a plate appearance")
	game.press_skip()
	_check(game.phase == "result", "skip did not finish the final")
	_check(str(game.result_label.text).contains("The final does not change the table."), "final result hid the table rule")
	_check(str(game.result_label.text).contains("You batted second"), "final result hid the batting order")
	game.continue_button.pressed.emit()
	_check(game.phase == "board", "winning the final did not reach the board")
	_check(game.series.goal_met(), "the board goal was not met")
	_check(Sport.get_stat(game.series.player_roster[0], "read") == 20, "final training did not stop at 20")
	_check(_table_signature(game.series.standings()) == table_before, "the played final changed the table")
	var board_text := str(game.board_label.text)
	_check(board_text.contains("reach the final and win it"), "board is missing the goal")
	_check(board_text.contains("Result: MET"), "a won final was not MET")
	_check(not board_text.contains("Result: MISSED"), "won final text contradicts MET")
	_check(board_text.contains(Sport.HERONS_CLUB), "board table is missing the fourth club")
	_check(board_text.contains("Week 6:"), "board is missing the last scheduled week")
	_check(board_text.contains("The final does not change the table."), "board did not keep the final off the table")

	game.start_new_series(23)
	_paint(game.series, 1, 20)
	for week in Sport.SERIES_WEEKS:
		_check(game.phase == "office", "miss week %d left the office early" % (week + 1))
		game.skip_button.pressed.emit()
		_check(game.phase == "result", "miss week %d did not reach a result" % (week + 1))
		game.continue_button.pressed.emit()
	_check(game.phase == "board", "missing the final did not end on the board")
	_check(not game.office_panel.visible, "office stayed open after a missed final")
	_check(game.series.final_match.is_empty(), "a missed final was played from the office")
	_check(not game.series.goal_met(), "missing the final met the goal")
	_check(game.series.matches.size() == Sport.regular_match_count(), "miss path did not play the full schedule")
	_check(Sport.rank_of(game.series.standings(), Sport.PLAYER_INDEX) == 4, "miss path was not fourth")
	var miss_board := str(game.board_label.text)
	_check(miss_board.contains("Result: MISSED"), "missed final was not MISSED")
	_check(not miss_board.contains("Result: MET"), "missed final text contradicts MISSED")
	_check(miss_board.contains("No final."), "board did not say the season ended with no final")
	_check(miss_board.contains("4th"), "board did not give the finish")
	_check(miss_board.contains(Sport.HERONS_CLUB), "missed board dropped the fourth club")
	for roster in game.series.rosters:
		_stats_in_range(roster, "miss path")

	var seed_before := int(game.series.seed)
	game.board_restart_button.pressed.emit()
	_check(game.phase == "office", "restart did not return to the office")
	_check(int(game.series.week) == 0, "restart did not reset the week")
	_check(game.series.matches.is_empty(), "restart kept old results")
	_check(int(game.series.seed) == seed_before + 1, "restart did not advance the seed")
	_check(str(game.schedule_label.text).contains("Week 1:"), "restart hid the schedule")
	game.queue_free()
	await process_frame
