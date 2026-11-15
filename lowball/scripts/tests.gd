extends SceneTree

const Sport = preload("res://scripts/sport.gd")
const SeriesScript = preload("res://scripts/series.gd")

const LINEUP: Array = [0, 1, 2, 3]
const ALT_LINEUP: Array = [5, 4, 3, 2]
const TACTIC := "aggressive"
const FOCUS := "lash"
const SWEEP_SEED := 37
const THIRD_SEED := 0
const MISS_SEED := 24
const TIE_SEED := 64
const LOSS_SEED := 98

var _failures: Array = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_failures = []
	_test_names()
	_test_round_robin()
	_test_table_order()
	_test_determinism()
	_test_scripted_series()
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
	print("TEST eleven clubs and twenty-two-week schedule")
	_check(Sport.CLUB_COUNT == 11, "club count is not eleven")
	_check(Sport.CLUB_NAMES.size() == 11, "club list is not eleven clubs")
	_check(Sport.PLAYER_CLUB == "Lumen Reedmice", "player club drifted")
	_check(Sport.OPPONENT_CLUB == "Southspur Glass", "second club drifted")
	_check(Sport.THIRD_CLUB == "Pellwick Cinders", "third club drifted")
	_check(Sport.FOURTH_CLUB == "Marrowgate Herons", "fourth club drifted")
	_check(Sport.FIFTH_CLUB == "Saltmere Kites", "fifth club drifted")
	_check(Sport.SIXTH_CLUB == "Ashfen Moths", "sixth club drifted")
	_check(Sport.SEVENTH_CLUB == "Reedfen Larks", "seventh club drifted")
	_check(Sport.EIGHTH_CLUB == "Cinderwharf Pikes", "eighth club drifted")
	_check(Sport.NINTH_CLUB == "Saltwharf Gulls", "ninth club drifted")
	_check(Sport.TENTH_CLUB == "Marrowfen Owls", "tenth club drifted")
	_check(Sport.ELEVENTH_CLUB == "Ashwharf Swifts", "eleventh club drifted")
	_check(str(Sport.CLUB_NAMES[3]) == Sport.FOURTH_CLUB, "Marrowgate Herons is missing from the club list")
	_check(str(Sport.CLUB_NAMES[4]) == Sport.FIFTH_CLUB, "Saltmere Kites is missing from the club list")
	_check(str(Sport.CLUB_NAMES[5]) == Sport.SIXTH_CLUB, "Ashfen Moths is missing from the club list")
	_check(str(Sport.CLUB_NAMES[6]) == Sport.SEVENTH_CLUB, "Reedfen Larks is missing from the club list")
	_check(str(Sport.CLUB_NAMES[7]) == Sport.EIGHTH_CLUB, "Cinderwharf Pikes is missing from the club list")
	_check(str(Sport.CLUB_NAMES[8]) == Sport.NINTH_CLUB, "Saltwharf Gulls is missing from the club list")
	_check(str(Sport.CLUB_NAMES[9]) == Sport.TENTH_CLUB, "Marrowfen Owls is missing from the club list")
	_check(str(Sport.CLUB_NAMES[10]) == Sport.ELEVENTH_CLUB, "Ashwharf Swifts is missing from the club list")
	_check(Sport.SERIES_WEEKS == 22, "series is not twenty-two weeks")
	_check(Sport.MATCHES_PER_WEEK == 5, "a week does not hold five matches")
	_check(Sport.BYES_EACH == 2, "a club does not have two byes")
	_check(Sport.GAMES_EACH == 20, "a club does not play twenty games")
	_check(Sport.ROUND_ROBIN.size() == 22, "schedule is not twenty-two weeks")
	_check(Sport.FINAL_WINS_NEEDED == 2, "the final is not first to two wins")
	_check(Sport.WIN_POINTS == 2 and Sport.TIE_POINTS == 1, "points values drifted")
	_check(Sport.GOAL_TEXT == "Board goal: reach the final and win the series.", "goal text drifted")
	_check(Sport.FINAL_TEXT.contains("3rd through 11th"), "missing the final does not run through 11th")
	_check(Sport.FINAL_TIE_TEXT.contains("not a win for either side"), "tie rule is missing from the final text")
	_check(Sport.FINAL_TIE_TEXT.contains("series continues"), "the final text does not say how a tie continues")
	_check(Sport.FINAL_TEXT.contains("best-of-three"), "the final is not described as a best of three")
	_check(Sport.FINAL_TEXT.contains("game 1") and Sport.FINAL_TEXT.contains("game 3"), "home for game 1 and game 3 is missing")
	_check(Sport.SCHEDULE_TEXT.contains("double round-robin"), "schedule shape is not described")
	_check(Sport.SCHEDULE_TEXT.contains("five matches"), "five matches a week is not described")
	_check(Sport.SCHEDULE_TEXT.contains("one bye"), "one bye a week is not described")
	_check(not Sport.SCHEDULE_TEXT.contains("no bye"), "the schedule still says there is no bye")
	_check(Sport.SEED_RULE.contains("by 11"), "the series seed is not divided by 11")
	_check(Sport.SEED_RULE.contains("Ashfen Moths"), "the seed rule omits Ashfen Moths")
	_check(Sport.SEED_RULE.contains("Reedfen Larks"), "the seed rule omits Reedfen Larks")
	_check(Sport.SEED_RULE.contains("Cinderwharf Pikes"), "the seed rule omits Cinderwharf Pikes")
	_check(Sport.SEED_RULE.contains("Saltwharf Gulls"), "the seed rule omits Saltwharf Gulls")
	_check(Sport.SEED_RULE.contains("Marrowfen Owls"), "the seed rule omits Marrowfen Owls")
	_check(Sport.SEED_RULE.contains("Ashwharf Swifts"), "the seed rule omits Ashwharf Swifts")
	_check(Sport.TIE_RULE == "Ties in the table break by run difference, then by the existing series seed.", "tie rule text drifted")
	var pair_counts := {}
	var directed := {}
	var played_weeks: Array = []
	var bye_weeks: Array = []
	for _club in Sport.CLUB_COUNT:
		played_weeks.append(0)
		bye_weeks.append(0)
	var player_byes: Array = []
	for week_index in Sport.SERIES_WEEKS:
		var cards: Array = Sport.week_fixtures(week_index)
		_check(cards.size() == 5, "week %d does not list five matches" % (week_index + 1))
		var seen := {}
		var bye := int(cards[0]["bye"])
		_check(bye == Sport.week_bye(week_index), "week %d bye drifted" % (week_index + 1))
		for card in cards:
			var home := int(card["home"])
			var away := int(card["away"])
			_check(home != away, "week %d lists a club against itself" % (week_index + 1))
			_check(home != bye and away != bye, "week %d plays the club that is off" % (week_index + 1))
			_check(home >= 0 and home < Sport.CLUB_COUNT and away >= 0 and away < Sport.CLUB_COUNT, "fixture index out of range")
			_check(str(card["home_club"]) == str(Sport.CLUB_NAMES[home]), "home club name drifted")
			_check(str(card["away_club"]) == str(Sport.CLUB_NAMES[away]), "away club name drifted")
			_check(int(card["bye"]) == bye and str(card["bye_club"]) == str(Sport.CLUB_NAMES[bye]), "week %d bye is not listed" % (week_index + 1))
			seen[home] = true
			seen[away] = true
			played_weeks[home] = int(played_weeks[home]) + 1
			played_weeks[away] = int(played_weeks[away]) + 1
			var key := _pair_key(card)
			pair_counts[key] = int(pair_counts.get(key, 0)) + 1
			var arrow := "%d>%d" % [home, away]
			_check(not directed.has(arrow), "home and away repeated for %s" % arrow)
			directed[arrow] = true
		_check(seen.size() == Sport.CLUB_COUNT - 1, "week %d does not leave exactly one club off" % (week_index + 1))
		_check(not seen.has(bye), "week %d stored a match for the bye" % (week_index + 1))
		bye_weeks[bye] = int(bye_weeks[bye]) + 1
		if bye == Sport.PLAYER_INDEX:
			player_byes.append(week_index + 1)
	for count in played_weeks:
		_check(int(count) == Sport.GAMES_EACH, "a club does not play twenty games")
	for count in bye_weeks:
		_check(int(count) == Sport.BYES_EACH, "a club does not have two byes")
	_check(_same_indexes(player_byes, [2, 13]), "Lumen Reedmice are not off in week 2 and week 13")
	var pair_total := 0
	for a in Sport.CLUB_COUNT:
		for b in range(a + 1, Sport.CLUB_COUNT):
			var key := "%d-%d" % [a, b]
			_check(int(pair_counts.get(key, 0)) == 2, "pair %s is not played home and away" % key)
			_check(directed.has("%d>%d" % [a, b]) and directed.has("%d>%d" % [b, a]), "pair %s did not swap home" % key)
			pair_total += 1
	_check(pair_total == 55, "the eleventh club is missing from the pair list")
	_check(int(pair_counts.get("0-10", 0)) == 2, "Ashwharf Swifts does not meet Lumen Reedmice home and away")
	_check(int(pair_counts.get("0-9", 0)) == 2, "Marrowfen Owls does not meet Lumen Reedmice home and away")
	var opening: Array = Sport.week_fixtures(0)
	_check(int(opening[0]["bye"]) == 10 and str(opening[0]["bye_club"]) == Sport.ELEVENTH_CLUB, "week 1 does not give Ashwharf Swifts the bye")
	_check(str(opening[0]["home_club"]) == Sport.PLAYER_CLUB and str(opening[0]["away_club"]) == Sport.TENTH_CLUB, "week 1 does not list Lumen Reedmice at home to Marrowfen Owls")
	_check(str(opening[1]["home_club"]) == Sport.OPPONENT_CLUB and str(opening[1]["away_club"]) == Sport.NINTH_CLUB, "week 1 is missing Southspur Glass against Saltwharf Gulls")
	_check(str(opening[2]["home_club"]) == Sport.THIRD_CLUB and str(opening[2]["away_club"]) == Sport.EIGHTH_CLUB, "week 1 is missing Pellwick Cinders against Cinderwharf Pikes")
	_check(str(opening[3]["home_club"]) == Sport.FOURTH_CLUB and str(opening[3]["away_club"]) == Sport.SEVENTH_CLUB, "week 1 is missing Marrowgate Herons against Reedfen Larks")
	_check(str(opening[4]["home_club"]) == Sport.FIFTH_CLUB and str(opening[4]["away_club"]) == Sport.SIXTH_CLUB, "week 1 is missing Saltmere Kites against Ashfen Moths")
	var ring: Array = []
	for club_index in Sport.CLUB_COUNT:
		ring.append(club_index)
	for week_index in Sport.CLUB_COUNT:
		var circle_bye := int(ring[ring.size() - 1])
		_check(Sport.week_bye(week_index) == circle_bye, "week %d bye is not the last club on the circle" % (week_index + 1))
		_check(Sport.week_bye(week_index + Sport.CLUB_COUNT) == circle_bye, "week %d did not keep the same bye" % (week_index + 1 + Sport.CLUB_COUNT))
		var early: Array = Sport.week_fixtures(week_index)
		var late: Array = Sport.week_fixtures(week_index + Sport.CLUB_COUNT)
		var playing_count := ring.size() - 1
		_check(early.size() == 5 and late.size() == 5, "a half week dropped a match")
		for slot in 5:
			_check(int(early[slot]["home"]) == int(ring[slot]), "week %d is not paired from the outside in" % (week_index + 1))
			_check(int(early[slot]["away"]) == int(ring[playing_count - 1 - slot]), "week %d away side is not outside in" % (week_index + 1))
			_check(int(late[slot]["home"]) == int(early[slot]["away"]), "second half did not reverse home")
			_check(int(late[slot]["away"]) == int(early[slot]["home"]), "second half did not reverse away")
			_check(int(late[slot]["bye"]) == circle_bye, "second half changed the bye")
		var first_club = ring[0]
		ring.remove_at(0)
		ring.append(first_club)
	var first_half := {}
	for week_index in Sport.CLUB_COUNT:
		for card in Sport.week_fixtures(week_index):
			var key := _pair_key(card)
			first_half[key] = int(first_half.get(key, 0)) + 1
	_check(first_half.size() == 55, "weeks 1-11 are not a full round-robin")
	for key in first_half:
		_check(int(first_half[key]) == 1, "weeks 1-11 repeat a pair")
	var dealt := Sport.create_clubs(42)
	var bag := _stat_bag(dealt["rosters"][0])
	for club_index in Sport.CLUB_COUNT:
		_check(bag == _stat_bag(dealt["rosters"][club_index]), "club %d was not dealt the same stat lines" % club_index)
	var tied := Sport.empty_table()
	Sport.apply_result_to_table(tied, 0, 1, 3, 1)
	Sport.apply_result_to_table(tied, 2, 3, 2, 0)
	_check(int(tied[0]["points"]) == 2 and int(tied[2]["points"]) == 2, "a win did not award 2 points")
	_check(not Sport.goal_reached(tied), "an equal points-per-game met the rate rule")
	Sport.apply_result_to_table(tied, 0, 2, 4, 0)
	_check(Sport.goal_reached(tied), "a better points-per-game missed the rate rule")
	var tie_rows := Sport.empty_table()
	Sport.apply_result_to_table(tie_rows, 0, 1, 2, 2)
	_check(int(tie_rows[0]["points"]) == 1 and int(tie_rows[1]["points"]) == 1, "a tie did not award 1 point to each club")
	var sides: Array = Sport.final_home_away(0, 3, 0)
	_check(int(sides[0]) == 0 and int(sides[1]) == 3, "game 1 did not give home to the club ahead")
	sides = Sport.final_home_away(0, 3, 1)
	_check(int(sides[0]) == 3 and int(sides[1]) == 0, "game 2 did not alternate home")
	sides = Sport.final_home_away(0, 3, 2)
	_check(int(sides[0]) == 0 and int(sides[1]) == 3, "game 3 did not return home to the club ahead")
	sides = Sport.final_home_away(0, 3, 3)
	_check(int(sides[0]) == 3 and int(sides[1]) == 0, "a later even game did not alternate home")


func _ordered_indexes(rows: Array) -> Array:
	var ordered: Array = Sport.sorted_table(rows)
	var indexes: Array = []
	for row in ordered:
		indexes.append(int(row["index"]))
	return indexes


func _fill_rate(row: Dictionary, points: int, played_games: int, run_diff: int) -> void:
	row["points"] = points
	row["played"] = played_games
	row["run_diff"] = run_diff


func _same_indexes(left: Array, right: Array) -> bool:
	if left.size() != right.size():
		return false
	for i in left.size():
		if int(left[i]) != int(right[i]):
			return false
	return true


func _test_table_order() -> void:
	print("TEST table tie break")
	_check(Sport.seed_start(0) == 0, "seed 0 did not start with Lumen Reedmice")
	_check(Sport.seed_start(1) == 1, "seed 1 did not start with Southspur Glass")
	_check(Sport.seed_start(2) == 2, "seed 2 did not start with Pellwick Cinders")
	_check(Sport.seed_start(3) == 3, "seed 3 did not start with Marrowgate Herons")
	_check(Sport.seed_start(4) == 4, "seed 4 did not start with Saltmere Kites")
	_check(Sport.seed_start(5) == 5, "seed 5 did not start with Ashfen Moths")
	_check(Sport.seed_start(6) == 6, "seed 6 did not start with Reedfen Larks")
	_check(Sport.seed_start(7) == 7, "seed 7 did not start with Cinderwharf Pikes")
	_check(Sport.seed_start(8) == 8, "seed 8 did not start with Saltwharf Gulls")
	_check(Sport.seed_start(9) == 9, "seed 9 did not start with Marrowfen Owls")
	_check(Sport.seed_start(10) == 10, "seed 10 did not start with Ashwharf Swifts")
	_check(Sport.seed_start(11) == 0, "seed remainder drifted")
	_check(Sport.seed_start(-1) == 10, "a negative series seed broke the remainder")
	_check(
		Sport.seed_order_names(5) == "Ashfen Moths, Reedfen Larks, Cinderwharf Pikes, Saltwharf Gulls, Marrowfen Owls, Ashwharf Swifts, Lumen Reedmice, Southspur Glass, Pellwick Cinders, Marrowgate Herons, Saltmere Kites",
		"seed order names drifted"
	)
	_check(
		Sport.seed_order_names(10) == "Ashwharf Swifts, Lumen Reedmice, Southspur Glass, Pellwick Cinders, Marrowgate Herons, Saltmere Kites, Ashfen Moths, Reedfen Larks, Cinderwharf Pikes, Saltwharf Gulls, Marrowfen Owls",
		"Ashwharf Swifts did not lead the seed order"
	)
	var rated := Sport.empty_table()
	_fill_rate(rated[0], 2, 1, 1)
	_fill_rate(rated[1], 4, 2, 9)
	_fill_rate(rated[2], 0, 2, 20)
	_fill_rate(rated[3], 1, 1, 0)
	_fill_rate(rated[4], 0, 1, -3)
	_fill_rate(rated[5], 1, 2, 4)
	_fill_rate(rated[6], 3, 2, 1)
	_fill_rate(rated[7], 1, 1, 8)
	_fill_rate(rated[8], 0, 1, -5)
	_fill_rate(rated[9], 0, 1, -6)
	_fill_rate(rated[10], 0, 1, -8)
	_check(Sport.rate_compare(rated[0], rated[1]) == 0, "an equal rate ranked a club ahead")
	_check(not Sport.goal_reached(rated), "an equal points-per-game met the rate rule")
	_check(Sport.compare_rows(rated[1], rated[0]) > 0, "higher run difference did not break the tie")
	_check(Sport.compare_rows(rated[0], rated[3]) > 0, "a better rate lost to a worse rate")
	var rated_pair: Array = Sport.finalist_pair(rated)
	_check(int(rated_pair[0]) == 1 and int(rated_pair[1]) == 0, "finalists ignored rate then run difference")
	var seeded := Sport.empty_table()
	for row in seeded:
		_fill_rate(row, 4, 4, 0)
	Sport.apply_seed_ranks(seeded, 5)
	var seeded_order: Array = _ordered_indexes(seeded)
	_check(_same_indexes(seeded_order, [5, 6, 7, 8, 9, 10, 0, 1, 2, 3, 4]), "the series seed did not break a level table")
	Sport.apply_seed_ranks(seeded, 0)
	seeded_order = _ordered_indexes(seeded)
	_check(_same_indexes(seeded_order, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]), "seed 0 order drifted")
	Sport.apply_seed_ranks(seeded, 4)
	seeded_order = _ordered_indexes(seeded)
	_check(_same_indexes(seeded_order, [4, 5, 6, 7, 8, 9, 10, 0, 1, 2, 3]), "seed 4 order drifted")
	Sport.apply_seed_ranks(seeded, 9)
	seeded_order = _ordered_indexes(seeded)
	_check(_same_indexes(seeded_order, [9, 10, 0, 1, 2, 3, 4, 5, 6, 7, 8]), "seed 9 order drifted")
	Sport.apply_seed_ranks(seeded, 10)
	seeded_order = _ordered_indexes(seeded)
	_check(_same_indexes(seeded_order, [10, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9]), "seed 10 order drifted")


func _explanations(match_result: Dictionary) -> Array:
	var lines: Array = []
	for pa in match_result["plate_appearances"]:
		lines.append(str(pa["explanation"]))
	return lines


func _matches_in_slot_order(started: Dictionary) -> Array:
	var matches: Array = []
	for _slot in Sport.MATCHES_PER_WEEK:
		matches.append({})
	matches[int(started["slot"])] = started
	for raw_other in started["other_matches"]:
		var other: Dictionary = raw_other
		matches[int(other["slot"])] = other
	return matches


func _same_lines(left: Array, right: Array) -> bool:
	if left.size() != right.size():
		return false
	for i in left.size():
		if str(left[i]) != str(right[i]):
			return false
	return true


func _append_match(lines: Array, match_result: Dictionary) -> void:
	for pa in match_result["plate_appearances"]:
		lines.append(str(pa["explanation"]))


func _collect_lines(series_seed: int, lineup: Array) -> Array:
	var played = SeriesScript.new(series_seed)
	var lines: Array = []
	for _week in Sport.SERIES_WEEKS:
		var started: Dictionary = played.begin_match(lineup, TACTIC, FOCUS)
		for match_result in _matches_in_slot_order(started):
			_append_match(lines, match_result)
		played.commit_match()
	var guard := 0
	while played.reached_final() and not played.is_over() and guard < 8:
		var fin: Dictionary = played.begin_match(lineup, TACTIC, FOCUS)
		_append_match(lines, fin)
		played.commit_match()
		guard += 1
	return lines


func _test_determinism() -> void:
	print("TEST determinism")
	var first_clubs := Sport.create_clubs(42)
	var second_clubs := Sport.create_clubs(42)
	_check((first_clubs["rosters"] as Array).size() == 11, "eleventh club roster is missing")
	for club_index in Sport.CLUB_COUNT:
		_check(
			_same_players(first_clubs["rosters"][club_index], second_clubs["rosters"][club_index]),
			"roster %d drifted" % club_index
		)
	var fixed_a := _play_fixed(Sport.create_clubs(42))
	var fixed_b := _play_fixed(Sport.create_clubs(42))
	_check(_same_lines(_explanations(fixed_a), _explanations(fixed_b)), "one match did not repeat its at-bats")
	_check(_explanations(fixed_a).size() == Sport.PAS_PER_MATCH, "plate appearance count is not 24")
	var regular_matches := Sport.SERIES_WEEKS * Sport.MATCHES_PER_WEEK
	var sweep_a := _collect_lines(SWEEP_SEED, LINEUP)
	var sweep_b := _collect_lines(SWEEP_SEED, LINEUP)
	_check(sweep_a.size() == (regular_matches + 2) * Sport.PAS_PER_MATCH, "sweep at-bat count did not include both final games")
	_check(_same_lines(sweep_a, sweep_b), "the same seed and lineup did not repeat the at-bats, including the final")
	var third_a := _collect_lines(THIRD_SEED, LINEUP)
	var third_b := _collect_lines(THIRD_SEED, LINEUP)
	_check(third_a.size() == (regular_matches + 3) * Sport.PAS_PER_MATCH, "third-game at-bat count drifted")
	_check(_same_lines(third_a, third_b), "a series that reaches game 3 did not repeat its at-bats")
	var tie_a := _collect_lines(TIE_SEED, LINEUP)
	var tie_b := _collect_lines(TIE_SEED, LINEUP)
	_check(tie_a.size() == (regular_matches + 3) * Sport.PAS_PER_MATCH, "tied-final at-bat count drifted")
	_check(_same_lines(tie_a, tie_b), "a tied final game did not repeat its at-bats")
	var loss_a := _collect_lines(LOSS_SEED, LINEUP)
	var loss_b := _collect_lines(LOSS_SEED, LINEUP)
	_check(loss_a.size() == (regular_matches + 5) * Sport.PAS_PER_MATCH, "a series past game 3 did not keep every final at-bat")
	_check(_same_lines(loss_a, loss_b), "the extended final did not repeat its at-bats")
	var other_lineup := _collect_lines(SWEEP_SEED, ALT_LINEUP)
	var lineup_differs := sweep_a.size() != other_lineup.size()
	if not lineup_differs:
		for i in sweep_a.size():
			if str(sweep_a[i]) != str(other_lineup[i]):
				lineup_differs = true
				break
	_check(lineup_differs, "a different lineup repeated the same at-bats")
	var left_pair := _opening_pair(LINEUP, TACTIC)
	var right_pair := _opening_pair(ALT_LINEUP, "field")
	_check(not _same_lines(left_pair[0], right_pair[0]), "the player's match ignored the lineup")
	_check(_same_lines(left_pair[1], right_pair[1]), "the first other match changed when the player's lineup changed")
	_check(_same_lines(left_pair[2], right_pair[2]), "the second other match changed when the player's lineup changed")
	_check(_same_lines(left_pair[3], right_pair[3]), "the third other match changed when the player's lineup changed")
	_check(_same_lines(left_pair[4], right_pair[4]), "the fourth other match changed when the player's lineup changed")
	var week_a := _week_bundle(SWEEP_SEED, 2, LINEUP, TACTIC)
	var week_b := _week_bundle(SWEEP_SEED, 2, ALT_LINEUP, "field")
	_check(str(week_a[5]) != "bye" and str(week_b[5]) != "bye", "week 3 was treated as a bye")
	_check(not _same_lines(week_a[0], week_b[0]), "week 3 ignored the lineup")
	_check(
		_same_lines(week_a[1], week_b[1]) and _same_lines(week_a[2], week_b[2]) and _same_lines(week_a[3], week_b[3]) and _same_lines(week_a[4], week_b[4]),
		"the other matches changed when the lineup changed"
	)
	_check(
		week_a[1].size() == Sport.PAS_PER_MATCH and week_a[4].size() == Sport.PAS_PER_MATCH,
		"week 3 did not record the other four matches"
	)
	var second_week_a := _week_bundle(SWEEP_SEED, 1, LINEUP, TACTIC)
	var second_week_b := _week_bundle(SWEEP_SEED, 1, ALT_LINEUP, "field")
	_check(str(second_week_a[5]) == "bye" and str(second_week_b[5]) == "bye", "week 2 was not a bye for Lumen Reedmice")
	_check(
		_same_lines(second_week_a[0], second_week_b[0]) and _same_lines(second_week_a[1], second_week_b[1]) and _same_lines(second_week_a[2], second_week_b[2]) and _same_lines(second_week_a[3], second_week_b[3]) and _same_lines(second_week_a[4], second_week_b[4]),
		"week 2 changed a match when the player's lineup changed"
	)
	var lash_week := _player_week_lines(SWEEP_SEED, 2, "lash")
	var eye_week := _player_week_lines(SWEEP_SEED, 2, "eye")
	_check(not _same_lines(lash_week, eye_week), "training did not change a later week's at-bats")
	var played = SeriesScript.new(SWEEP_SEED)
	_play_regular(played)
	var fin: Dictionary = played.begin_match(LINEUP, TACTIC, FOCUS)
	var replay: Dictionary = Sport.simulate_match(
		int(fin["seed"]),
		Sport.lineup_players(played.rosters[int(fin["home_index"])], fin["home_lineup"]),
		Sport.lineup_players(played.rosters[int(fin["away_index"])], fin["away_lineup"]),
		str(fin["home_tactic"]),
		str(fin["away_tactic"]),
		str(fin["home_club"]),
		str(fin["away_club"])
	)
	_check(_same_lines(_explanations(fin), _explanations(replay)), "final game 1 was not the pure match function")
	_check(int(fin["seed"]) == Sport.match_seed_for(SWEEP_SEED, Sport.SERIES_WEEKS, 0), "final game 1 seed drifted")
	var again: Dictionary = played.begin_match(ALT_LINEUP, TACTIC, FOCUS)
	_check(not _same_lines(_explanations(fin), _explanations(again)), "a different final lineup repeated game 1")
	var restored: Dictionary = played.begin_match(LINEUP, TACTIC, FOCUS)
	_check(_same_lines(_explanations(fin), _explanations(restored)), "repeating the final lineup did not repeat game 1")
	played.commit_match()
	var second: Dictionary = played.begin_match(LINEUP, TACTIC, FOCUS)
	var second_replay: Dictionary = Sport.simulate_match(
		int(second["seed"]),
		Sport.lineup_players(played.rosters[int(second["home_index"])], second["home_lineup"]),
		Sport.lineup_players(played.rosters[int(second["away_index"])], second["away_lineup"]),
		str(second["home_tactic"]),
		str(second["away_tactic"]),
		str(second["home_club"]),
		str(second["away_club"])
	)
	_check(_same_lines(_explanations(second), _explanations(second_replay)), "final game 2 was not the pure match function")
	_check(int(second["seed"]) == Sport.match_seed_for(SWEEP_SEED, Sport.SERIES_WEEKS + 1, 0), "final game 2 seed drifted")
	_check(int(fin["seed"]) != int(second["seed"]), "final games shared one seed")


func _play_fixed(clubs: Dictionary) -> Dictionary:
	return Sport.simulate_match(
		12345,
		_lineup_of(clubs["player_roster"], LINEUP),
		_lineup_of(clubs["opponent_roster"], LINEUP),
		"patient",
		"field",
		Sport.PLAYER_CLUB,
		Sport.OPPONENT_CLUB
	)


func _opening_pair(lineup: Array, tactic: String) -> Array:
	var played = SeriesScript.new(SWEEP_SEED)
	var started: Dictionary = played.begin_match(lineup, tactic, FOCUS)
	var others: Array = started["other_matches"]
	return [
		_explanations(started),
		_explanations(others[0]),
		_explanations(others[1]),
		_explanations(others[2]),
		_explanations(others[3]),
	]


func _week_bundle(series_seed: int, target_week: int, lineup: Array, tactic: String) -> Array:
	var played = SeriesScript.new(series_seed)
	var started: Dictionary = {}
	for week_index in target_week + 1:
		started = played.begin_match(lineup, tactic, FOCUS)
		if week_index < target_week:
			played.commit_match()
	var others: Array = started["other_matches"]
	return [
		_explanations(started),
		_explanations(others[0]),
		_explanations(others[1]),
		_explanations(others[2]),
		_explanations(others[3]),
		str(started.get("player_result", "")),
	]


func _player_week_lines(series_seed: int, target_week: int, first_focus: String) -> Array:
	var played = SeriesScript.new(series_seed)
	var lines: Array = []
	for week_index in target_week + 1:
		var focus := FOCUS if week_index > 0 else first_focus
		var started: Dictionary = played.begin_match(LINEUP, TACTIC, focus)
		if week_index == target_week:
			_append_match(lines, started)
		played.commit_match()
	return lines


func _play_regular(played) -> void:
	for week_index in Sport.SERIES_WEEKS:
		var started: Dictionary = played.begin_match(LINEUP, TACTIC, FOCUS)
		_check(bool(started.get("ok", false)), "week %d failed to start" % (week_index + 1))
		if not bool(started.get("ok", false)):
			return
		_check((started["plate_appearances"] as Array).size() == Sport.PAS_PER_MATCH, "week %d was not a full match" % (week_index + 1))
		var bye := Sport.week_bye(week_index)
		var player_off := bye == Sport.PLAYER_INDEX
		_check(bool(started.get("player_played", false)) != player_off, "week %d watched the wrong match" % (week_index + 1))
		_check(int(started.get("bye_index", -1)) == bye, "week %d did not record who was off" % (week_index + 1))
		_check(str(started.get("bye_club", "")) == str(Sport.CLUB_NAMES[bye]), "week %d bye club drifted" % (week_index + 1))
		if player_off:
			_check(str(started.get("player_result", "")) == "bye", "week %d did not mark the player's bye" % (week_index + 1))
			var cards: Array = Sport.week_fixtures(week_index)
			_check(int(started["home_index"]) == int(cards[0]["home"]) and int(started["away_index"]) == int(cards[0]["away"]), "week %d did not follow the first match" % (week_index + 1))
		_check(started.has("other_matches"), "week %d did not play the other matches" % (week_index + 1))
		if started.has("other_matches"):
			var others: Array = started["other_matches"]
			_check(others.size() == Sport.MATCHES_PER_WEEK - 1, "week %d did not record the other four matches" % (week_index + 1))
			var seeds := {int(started["seed"]): true}
			var present := {}
			present[int(started["home_index"])] = true
			present[int(started["away_index"])] = true
			for raw_other in others:
				var other: Dictionary = raw_other
				_check(
					(other["plate_appearances"] as Array).size() == Sport.PAS_PER_MATCH,
					"an other match in week %d was not a full match" % (week_index + 1)
				)
				_check(not seeds.has(int(other["seed"])), "two matches in week %d shared a seed" % (week_index + 1))
				seeds[int(other["seed"])] = true
				_check(not bool(other["player_played"]), "an other match in week %d was the player's match" % (week_index + 1))
				_check(int(other.get("bye_index", -1)) == bye, "week %d stored the wrong bye on another match" % (week_index + 1))
				present[int(other["home_index"])] = true
				present[int(other["away_index"])] = true
			_check(not present.has(bye), "week %d stored a match for the club that is off" % (week_index + 1))
			_check(present.size() == Sport.CLUB_COUNT - 1, "week %d did not play the other ten clubs" % (week_index + 1))
		var committed: Dictionary = played.commit_match()
		_check(bool(committed.get("ok", false)), "week %d failed to record" % (week_index + 1))
		_check(not bool(committed.get("final", false)), "week %d was stored as a final game" % (week_index + 1))


func _assert_schedule(played, label: String) -> void:
	var match_count := Sport.SERIES_WEEKS * Sport.MATCHES_PER_WEEK
	_check(played.results.size() == match_count, label + " did not play all one hundred ten matches")
	_check(int(played.week) == Sport.SERIES_WEEKS, label + " did not finish week 22")
	var seen := {}
	var player_games := 0
	var bye_results := 0
	var played_count: Array = []
	for _club in Sport.CLUB_COUNT:
		played_count.append(0)
	for result in played.results:
		_check((result["plate_appearances"] as Array).size() == Sport.PAS_PER_MATCH, label + " stored a short match")
		_check(not bool(result.get("is_final", false)), label + " stored a final game in the table")
		_check(result.has("bye_index") and result.has("bye_club"), label + " dropped the bye")
		_check(int(result["home_index"]) != int(result["bye_index"]) and int(result["away_index"]) != int(result["bye_index"]), label + " stored a match for the club that was off")
		seen[str(result["home_club"])] = true
		seen[str(result["away_club"])] = true
		played_count[int(result["home_index"])] = int(played_count[int(result["home_index"])]) + 1
		played_count[int(result["away_index"])] = int(played_count[int(result["away_index"])]) + 1
		if bool(result["player_played"]):
			player_games += 1
		if str(result.get("player_result", "")) == "bye":
			bye_results += 1
	_check(player_games == Sport.GAMES_EACH, label + " did not give the player twenty matches")
	_check(bye_results == Sport.BYES_EACH, label + " did not mark both of the player's byes")
	_check(seen.has(Sport.ELEVENTH_CLUB), label + " left Ashwharf Swifts off the schedule")
	_check(seen.has(Sport.TENTH_CLUB), label + " left Marrowfen Owls off the schedule")
	_check(seen.size() == Sport.CLUB_COUNT, label + " left a club out of the schedule")
	for count in played_count:
		_check(int(count) == Sport.GAMES_EACH, label + " did not give every club twenty games")
	for week_index in Sport.SERIES_WEEKS:
		var week_clubs := {}
		var player_slots := 0
		var bye_slots := 0
		var cards: Array = Sport.week_fixtures(week_index)
		var bye := Sport.week_bye(week_index)
		for slot in Sport.MATCHES_PER_WEEK:
			var result: Dictionary = played.results[week_index * Sport.MATCHES_PER_WEEK + slot]
			_check(int(result["week"]) == week_index, label + " week %d was stored on the wrong week" % (week_index + 1))
			_check(int(result["slot"]) == slot, label + " week %d stored a match out of order" % (week_index + 1))
			_check(int(result["home_index"]) == int(cards[slot]["home"]), label + " week %d home drifted" % (week_index + 1))
			_check(int(result["away_index"]) == int(cards[slot]["away"]), label + " week %d away drifted" % (week_index + 1))
			_check(int(result["bye_index"]) == bye, label + " week %d bye drifted" % (week_index + 1))
			week_clubs[int(result["home_index"])] = true
			week_clubs[int(result["away_index"])] = true
			if bool(result["player_played"]):
				player_slots += 1
			if str(result.get("player_result", "")) == "bye":
				bye_slots += 1
		if bye == Sport.PLAYER_INDEX:
			_check(player_slots == 0, label + " week %d stored a match for Lumen Reedmice" % (week_index + 1))
			_check(bye_slots == 1, label + " week %d did not mark the bye on the followed match" % (week_index + 1))
		else:
			_check(player_slots == 1, label + " week %d did not record exactly one Lumen Reedmice match" % (week_index + 1))
			_check(bye_slots == 0, label + " week %d marked a bye for Lumen Reedmice" % (week_index + 1))
		_check(not week_clubs.has(bye), label + " week %d stored a match for the club that was off" % (week_index + 1))
		_check(week_clubs.size() == Sport.CLUB_COUNT - 1, label + " week %d did not play ten clubs" % (week_index + 1))
	_check(_stats_in_range(played.rosters), label + " left a stat outside 1-20")


func _snapshot(played) -> Array:
	var snap: Array = []
	for row in played.table():
		snap.append([int(row["points"]), int(row["run_diff"]), int(row["played"])])
	return snap


func _same_snapshot(left: Array, right: Array) -> bool:
	if left.size() != right.size():
		return false
	for i in left.size():
		var a: Array = left[i]
		var b: Array = right[i]
		if int(a[0]) != int(b[0]) or int(a[1]) != int(b[1]) or int(a[2]) != int(b[2]):
			return false
	return true


func _lash_list(roster: Array) -> Array:
	var values: Array = []
	for player in roster:
		values.append(Sport.get_stat(player, "lash"))
	return values


func _eye_list(roster: Array) -> Array:
	var values: Array = []
	for player in roster:
		values.append(Sport.get_stat(player, "eye"))
	return values


func _assert_plus(roster: Array, before: Array, stat_name: String, gain: int, message: String) -> void:
	for i in roster.size():
		_check(
			Sport.get_stat(roster[i], stat_name) == mini(int(before[i]) + gain, Sport.STAT_CAP),
			message
		)


func _play_final_game(played, home_index: int, outcome: String, player_score: int, opponent_score: int) -> Dictionary:
	var game_index: int = played.final_games.size()
	_check(played.final_home_index(game_index) == home_index, "final game %d home drifted" % (game_index + 1))
	var started: Dictionary = played.begin_match(LINEUP, TACTIC, FOCUS)
	_check(bool(started.get("ok", false)), "final game %d did not start" % (game_index + 1))
	if not bool(started.get("ok", false)):
		return started
	_check(bool(started.get("is_final", false)), "final game %d was a regular week" % (game_index + 1))
	_check(int(started.get("final_game", 0)) == game_index + 1, "final game number drifted")
	_check((started["plate_appearances"] as Array).size() == Sport.PAS_PER_MATCH, "final game %d was not a full match" % (game_index + 1))
	_check(int(started["home_index"]) == home_index, "final game %d was played at the wrong home" % (game_index + 1))
	_check(str(started.get("player_result", "")) == outcome, "final game %d result drifted" % (game_index + 1))
	_check(int(started["player_score"]) == player_score and int(started["opponent_score"]) == opponent_score, "final game %d score drifted" % (game_index + 1))
	var before := _snapshot(played)
	var committed: Dictionary = played.commit_match()
	_check(bool(committed.get("ok", false)) and bool(committed.get("final", false)), "final game %d did not record" % (game_index + 1))
	_check(_same_snapshot(before, _snapshot(played)), "final game %d changed the table" % (game_index + 1))
	_check(played.results.size() == Sport.SERIES_WEEKS * Sport.MATCHES_PER_WEEK, "final game %d was added to the table" % (game_index + 1))
	return started


func _test_scripted_series() -> void:
	print("TEST scripted series")
	var blocked = SeriesScript.new(MISS_SEED)
	var bad: Dictionary = blocked.begin_match([0, 0, 1, 2], TACTIC, FOCUS)
	_check(not bool(bad.get("ok", false)), "an illegal lineup was accepted")
	_check(blocked.results.is_empty(), "a rejected lineup recorded a match")

	var missed = SeriesScript.new(MISS_SEED)
	var missed_lash := _lash_list(missed.player_roster)
	var missed_eye := _eye_list(missed.player_roster)
	_play_regular(missed)
	_assert_schedule(missed, "scripted miss")
	_check(missed.place() == 3, "scripted miss did not finish 3rd")
	_check(not missed.reached_final(), "scripted miss reached the final")
	_check(missed.is_over(), "scripted miss did not end after week 22")
	_check(missed.final_games.is_empty(), "scripted miss stored a final")
	_check(not missed.goal_met(), "missing the final met the goal")
	var miss_rows: Array = missed.table()
	var miss_order: Array = _ordered_indexes(miss_rows)
	_check(int(miss_order[0]) == 3 and int(miss_order[1]) == 5 and int(miss_order[2]) == 0, "the table did not place the player 3rd")
	_check(int(miss_rows[0]["points"]) == 23 and int(miss_rows[5]["points"]) == 24, "points per game did not place the player behind Ashfen Moths")
	_check(int(miss_rows[3]["points"]) == 25, "Marrowgate Herons did not lead the missed season")
	_check(int(miss_rows[0]["run_diff"]) == 24 and int(miss_rows[3]["run_diff"]) == 2, "run difference did not stay behind points per game")
	_check(int(miss_rows[0]["played"]) == Sport.GAMES_EACH, "a week was not recorded for Lumen Reedmice")
	var denied: Dictionary = missed.begin_match(LINEUP, TACTIC, FOCUS)
	_check(not bool(denied.get("ok", false)), "a match after a missed final was allowed")
	_assert_plus(missed.player_roster, missed_lash, "lash", Sport.SERIES_WEEKS, "twenty-two weeks did not add 1 Lash up to the cap")
	for i in missed.player_roster.size():
		_check(Sport.get_stat(missed.player_roster[i], "eye") == int(missed_eye[i]), "lash training changed Eye")
	_check_opening_week()
	_check_outside_final(11, 4)
	_check_outside_final(2, 5)
	_check_outside_final(39, 6)
	_check_outside_final(7, 7)
	_check_outside_final(6, 8)
	_check_outside_final(3, 9)
	_check_outside_final(9, 10)
	_check_outside_final(14, 11)
	print("Scripted miss: finished 3rd, with 4th through 11th also ending without a final")

	var sweep = SeriesScript.new(SWEEP_SEED)
	var sweep_lash := _lash_list(sweep.player_roster)
	var sweep_eye := _eye_list(sweep.player_roster)
	_play_regular(sweep)
	_assert_schedule(sweep, "two-game final")
	_check(sweep.reached_final(), "two-game script missed the final")
	_check(not sweep.is_over(), "two-game script ended before the final")
	_check(sweep.place() == 2, "the two-game script did not finish 2nd")
	_check(int(sweep.finalist_indices()[0]) == 2, "Pellwick Cinders did not lead the league")
	_check(int(sweep.finalist_indices()[1]) == Sport.PLAYER_INDEX, "the player was not the second finalist")
	_play_final_game(sweep, 2, "win", 10, 9)
	_check(not sweep.is_over(), "one win ended the series")
	_check(int(sweep.series_win_counts()[Sport.PLAYER_INDEX]) == 1, "game 1 did not count as one win")
	_check(not sweep.goal_met(), "one final win met the goal")
	_play_final_game(sweep, Sport.PLAYER_INDEX, "win", 10, 9)
	_check(sweep.is_over(), "two wins did not end the series")
	_check(sweep.goal_met(), "winning the series in two games missed the goal")
	_check(sweep.final_games.size() == 2, "the two-game final stored the wrong number of games")
	_check(sweep.series_winner_index() == Sport.PLAYER_INDEX, "the series winner drifted")
	_assert_plus(sweep.player_roster, sweep_lash, "lash", Sport.SERIES_WEEKS + 2, "the two final games did not each add 1 Lash up to the cap")
	for i in sweep.player_roster.size():
		_check(Sport.get_stat(sweep.player_roster[i], "eye") == int(sweep_eye[i]), "final training changed Eye")
	print("Scripted final: won in two games, 10-9 then 10-9")

	var third = SeriesScript.new(THIRD_SEED)
	_play_regular(third)
	_assert_schedule(third, "third game")
	_check(third.reached_final(), "split series missed the final")
	_check(third.place() == 1, "split series did not finish 1st")
	_check(int(third.finalist_indices()[0]) == Sport.PLAYER_INDEX, "game 1 home was not the club ahead")
	_check(int(third.finalist_indices()[1]) == 5, "game 3 opponent was not Ashfen Moths")
	_play_final_game(third, Sport.PLAYER_INDEX, "win", 10, 9)
	_check(not third.is_over(), "game 1 closed a split series")
	_play_final_game(third, 5, "loss", 5, 8)
	_check(not third.is_over(), "a 1-1 series did not reach game 3")
	_check(int(third.series_win_counts()[0]) == 1 and int(third.series_win_counts()[5]) == 1, "the split was not 1-1")
	_play_final_game(third, Sport.PLAYER_INDEX, "loss", 2, 11)
	_check(third.is_over() and not third.goal_met(), "losing game 3 did not end the series")
	_check(third.series_winner_index() == 5, "the series winner was not Ashfen Moths")
	_check(third.final_games.size() == 3, "the split series did not play three games")
	_check(third.results.size() == Sport.SERIES_WEEKS * Sport.MATCHES_PER_WEEK, "game 3 changed the table length")
	print("Scripted final: reached game 3 at 1-1, then lost 2-11")

	var tied = SeriesScript.new(TIE_SEED)
	_play_regular(tied)
	_assert_schedule(tied, "tied final game")
	_check(tied.reached_final(), "tie script missed the final")
	_check(int(tied.finalist_indices()[0]) == Sport.PLAYER_INDEX, "the tie script was not the club ahead")
	_check(int(tied.finalist_indices()[1]) == 8, "the tie script opponent was not Saltwharf Gulls")
	var wins_before: Array = tied.series_win_counts()
	_play_final_game(tied, Sport.PLAYER_INDEX, "tie", 9, 9)
	_check(not tied.is_over(), "a tied final game ended the series")
	_check(_same_indexes(wins_before, tied.series_win_counts()), "a tie counted as a win")
	_check(str(tied.final_games[0]["winner"]) == "tie", "the tied game was stored as a win")
	_play_final_game(tied, 8, "loss", 7, 9)
	_check(not tied.is_over(), "one loss ended the series")
	_play_final_game(tied, Sport.PLAYER_INDEX, "loss", 4, 8)
	_check(tied.is_over() and not tied.goal_met(), "the games after a tie did not decide the series")
	_check(int(tied.series_win_counts()[Sport.PLAYER_INDEX]) == 0, "the tie gave Lumen Reedmice a win")
	_check(int(tied.series_win_counts()[8]) == 2, "the tie series did not end at two wins for Saltwharf Gulls")
	print("Scripted final: game 1 tied 9-9 and the series continued")

	var lost = SeriesScript.new(LOSS_SEED)
	_play_regular(lost)
	_assert_schedule(lost, "lost series")
	_check(lost.reached_final(), "loss script missed the final")
	_check(int(lost.finalist_indices()[0]) == Sport.PLAYER_INDEX, "loss script home was not the club ahead")
	_check(int(lost.finalist_indices()[1]) == 9, "loss script opponent was not Marrowfen Owls")
	_play_final_game(lost, Sport.PLAYER_INDEX, "tie", 8, 8)
	_check(not lost.is_over(), "the tie in game 1 ended the series")
	_check(int(lost.series_win_counts()[0]) == 0 and int(lost.series_win_counts()[9]) == 0, "game 1 tie counted as a win")
	_play_final_game(lost, 9, "tie", 6, 6)
	_check(not lost.is_over(), "the tie in game 2 ended the series")
	_check(int(lost.series_win_counts()[0]) == 0 and int(lost.series_win_counts()[9]) == 0, "game 2 tie counted as a win")
	_play_final_game(lost, Sport.PLAYER_INDEX, "loss", 6, 8)
	_check(not lost.is_over(), "one loss ended the series")
	_play_final_game(lost, 9, "tie", 10, 10)
	_check(not lost.is_over(), "a later tie ended the series")
	_check(int(lost.series_win_counts()[0]) == 0 and int(lost.series_win_counts()[9]) == 1, "the later tie changed the series score")
	_play_final_game(lost, Sport.PLAYER_INDEX, "loss", 4, 11)
	_check(lost.is_over(), "two wins for the other club did not end the series")
	_check(not lost.goal_met(), "losing the series met the goal")
	_check(lost.series_winner_index() == 9, "the series winner was not Marrowfen Owls")
	_check(lost.final_games.size() == 5, "the ties did not extend the series")
	_check(str(lost.final_games[0]["winner"]) == "tie" and str(lost.final_games[1]["winner"]) == "tie", "the opening ties were stored as wins")
	_check(lost.results.size() == Sport.SERIES_WEEKS * Sport.MATCHES_PER_WEEK, "a lost series changed the table")
	print("Scripted final: lost the series after ties extended it")


func _roster_total(roster: Array) -> int:
	var total := 0
	for player in roster:
		for key in Sport.STATS:
			total += Sport.get_stat(player, key)
	return total


func _check_opening_week() -> void:
	var probe = SeriesScript.new(3)
	var owl_total := _roster_total(probe.rosters[9])
	var swift_total := _roster_total(probe.rosters[10])
	var player_before := _lash_list(probe.player_roster)
	var first: Dictionary = probe.begin_match(LINEUP, TACTIC, FOCUS)
	_check(bool(first.get("ok", false)), "week 1 did not start")
	_check(bool(first.get("player_played", false)), "week 1 left Lumen Reedmice off the field")
	_check(str(first.get("opponent_club", "")) == Sport.TENTH_CLUB, "week 1 opponent was not Marrowfen Owls")
	_check((first["other_matches"] as Array).size() == 4, "week 1 did not record the other four matches")
	_check(int(first.get("bye_index", -1)) == 10, "week 1 bye was not Ashwharf Swifts")
	_check(str(first.get("bye_club", "")) == Sport.ELEVENTH_CLUB, "week 1 bye club drifted")
	probe.commit_match()
	_check(_roster_total(probe.rosters[9]) == owl_total + Sport.ROSTER_SIZE, "week 1 did not drill Marrowfen Owls")
	_check(_roster_total(probe.rosters[10]) == swift_total + Sport.ROSTER_SIZE, "week 1 did not drill Ashwharf Swifts on their bye")
	_check(int(probe.table()[9]["played"]) == 1, "week 1 did not record a match for Marrowfen Owls")
	_check(int(probe.table()[10]["played"]) == 0, "week 1 stored a match for Ashwharf Swifts")
	_check(int(probe.table()[Sport.PLAYER_INDEX]["played"]) == 1, "week 1 did not record a match for Lumen Reedmice")
	_assert_plus(probe.player_roster, player_before, "lash", 1, "week 1 did not add 1 Lash")
	for row in probe.table():
		var expected := 0 if int(row["index"]) == 10 else 1
		_check(int(row["played"]) == expected, "week 1 recorded the wrong clubs")
	var lash_after := _lash_list(probe.player_roster)
	var second: Dictionary = probe.begin_match(LINEUP, TACTIC, FOCUS)
	_check(str(second.get("player_result", "")) == "bye", "week 2 was not a bye")
	_check(not bool(second.get("player_played", false)), "week 2 put Lumen Reedmice on the field")
	_check(int(second.get("bye_index", -1)) == Sport.PLAYER_INDEX, "week 2 bye was not Lumen Reedmice")
	_check((second["other_matches"] as Array).size() == 4, "week 2 did not record the other four matches")
	var involved := {}
	involved[int(second["home_index"])] = true
	involved[int(second["away_index"])] = true
	for raw_other in second["other_matches"]:
		var other: Dictionary = raw_other
		involved[int(other["home_index"])] = true
		involved[int(other["away_index"])] = true
	_check(not involved.has(Sport.PLAYER_INDEX), "week 2 stored a match for Lumen Reedmice")
	_check(involved.size() == Sport.CLUB_COUNT - 1, "week 2 did not play the other ten clubs")
	probe.commit_match()
	_check(int(probe.table()[Sport.PLAYER_INDEX]["played"]) == 1, "week 2 stored a match for Lumen Reedmice")
	_assert_plus(probe.player_roster, lash_after, "lash", 1, "the bye week did not add 1 Lash")


func _check_outside_final(series_seed: int, expected_place: int) -> void:
	var played = SeriesScript.new(series_seed)
	_play_regular(played)
	_check(played.place() == expected_place, "seed %d did not finish outside the top two" % series_seed)
	_check(not played.reached_final(), "seed %d reached the final from outside the top two" % series_seed)
	_check(played.is_over(), "seed %d did not end after week 22" % series_seed)
	_check(played.final_games.is_empty(), "seed %d stored a final" % series_seed)
	_check(int(played.table()[Sport.PLAYER_INDEX]["played"]) == Sport.GAMES_EACH, "seed %d did not play twenty games" % series_seed)


func _stats_in_range(rosters: Array) -> bool:
	for roster in rosters:
		for player in roster:
			for key in Sport.STATS:
				var value := Sport.get_stat(player, key)
				if value < Sport.STAT_FLOOR or value > Sport.STAT_CAP:
					return false
	return true


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
	for series_index in 200:
		var clubs: Dictionary = Sport.create_clubs(1000 + series_index)
		var rng := RandomNumberGenerator.new()
		rng.seed = 5000 + series_index
		var rosters: Array = clubs["rosters"]
		for week in Sport.SERIES_WEEKS:
			for pair in Sport.ROUND_ROBIN[week]:
				var home_i := int(pair[0])
				var away_i := int(pair[1])
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
				var result: Dictionary = Sport.simulate_match(
					8000 + series_index * 256 + week * 10 + home_i,
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
				_check(_score_matches_runs(result), "score/runs mismatch in series %d" % series_index)
				for pa in result["plate_appearances"]:
					_check(_outcome_runs_ok(pa), "bad outcome runs")
					_check(str(pa["explanation"]).find("\n") < 0, "explanation contains a newline")
				Sport.apply_training(home_roster, home_focus)
				Sport.apply_training(away_roster, away_focus)
			for roster in rosters:
				for player in roster:
					_check(Sport.is_generated_name(str(player["player_name"])), "trained roster has a bad name")
					for key in Sport.STATS:
						var value := Sport.get_stat(player, key)
						if value < Sport.STAT_FLOOR or value > Sport.STAT_CAP:
							_check(false, "stat %s left 1-20 at %d" % [key, value])
	print("Fairness over 200 series, ties %d" % ties)
	for club_name in Sport.CLUB_NAMES:
		var club_wins := int(wins[str(club_name)])
		print("%s wins %d" % [str(club_name), club_wins])
		_check(club_wins > 0, str(club_name) + " never won a match")
		_check(club_wins >= 20, str(club_name) + " won too rarely to be able to win in general")

	var sample: Dictionary = Sport.create_clubs(3)
	var sixth_lash := _sum_stat(sample["rosters"][5], "lash")
	var ninth_lash := _sum_stat(sample["rosters"][8], "lash")
	var tenth_lash := _sum_stat(sample["rosters"][9], "lash")
	var eleventh_lash := _sum_stat(sample["rosters"][10], "lash")
	var player_lash := _sum_stat(sample["rosters"][0], "lash")
	Sport.apply_training(sample["rosters"][0], "lash")
	_check(_sum_stat(sample["rosters"][0], "lash") == player_lash + Sport.ROSTER_SIZE, "training did not add 1 to each Lumen Reedmice player")
	_check(_sum_stat(sample["rosters"][5], "lash") == sixth_lash, "training the player changed Ashfen Moths")
	_check(_sum_stat(sample["rosters"][8], "lash") == ninth_lash, "training the player changed Saltwharf Gulls")
	_check(_sum_stat(sample["rosters"][9], "lash") == tenth_lash, "training the player changed Marrowfen Owls")
	_check(_sum_stat(sample["rosters"][10], "lash") == eleventh_lash, "training the player changed Ashwharf Swifts")
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


func _check_office(game, where: String) -> void:
	_check(game.phase == "office", where + " is not the office")
	_check(game.office_panel.visible, where + " hides the office")
	_check(str(game.goal_label.text).contains("reach the final and win the series"), where + " is missing the series goal")
	_check(str(game.rule_label.text).contains(Sport.FINAL_TEXT), where + " is missing the final rule")
	_check(str(game.rule_label.text).contains(Sport.FINAL_TIE_TEXT), where + " is missing the tie rule")
	_check(str(game.rule_label.text).contains("not a win for either side"), where + " does not say a tie is not a win")
	_check(str(game.rule_label.text).contains("series continues"), where + " does not say how the series continues")
	_check(str(game.rule_label.text).contains(Sport.TIE_RULE), where + " is missing the table tie rule")
	_check(str(game.rule_label.text).contains(Sport.SEED_RULE), where + " is missing the seed rule")
	_check(str(game.shape_label.text).contains("double round-robin"), where + " is missing the schedule shape")
	_check(str(game.shape_label.text).contains("five matches"), where + " does not say each week has five matches")
	_check(str(game.shape_label.text).contains("one bye"), where + " does not say each week has one bye")
	var schedule := str(game.schedule_label.text)
	for club_name in Sport.CLUB_NAMES:
		_check(schedule.contains(str(club_name)), where + " schedule is missing " + str(club_name))
	for week_no in Sport.SERIES_WEEKS:
		_check(schedule.contains("Week %d" % (week_no + 1)), where + " schedule is missing week %d" % (week_no + 1))
	_check(schedule.contains(Sport.NINTH_CLUB), where + " schedule is missing Saltwharf Gulls")
	_check(schedule.contains(Sport.TENTH_CLUB), where + " schedule is missing Marrowfen Owls")
	_check(schedule.contains(Sport.ELEVENTH_CLUB), where + " schedule is missing Ashwharf Swifts")
	_check(_count_outcome_token(schedule, " bye") == Sport.SERIES_WEEKS, where + " does not list one bye every week")
	if int(game.series.week) == 0:
		_check(schedule.contains("Lumen Reedmice vs Marrowfen Owls"), where + " is missing the week 1 match")
		_check(schedule.contains("Southspur Glass vs Saltwharf Gulls"), where + " is missing the second week 1 match")
		_check(schedule.contains("Pellwick Cinders vs Cinderwharf Pikes"), where + " is missing the third week 1 match")
		_check(schedule.contains("Marrowgate Herons vs Reedfen Larks"), where + " is missing the fourth week 1 match")
		_check(schedule.contains("Saltmere Kites vs Ashfen Moths"), where + " is missing the fifth week 1 match")
		_check(schedule.contains("Ashwharf Swifts bye"), where + " does not list the week 1 bye")
		_check(schedule.contains("Marrowfen Owls vs Lumen Reedmice"), where + " is missing the return match")
		_check(schedule.contains("Lumen Reedmice vs Southspur Glass"), where + " is missing a home match")
		_check(_count_outcome_token(schedule, "Lumen Reedmice bye") == 2, where + " does not list both weeks Lumen Reedmice are off")
		_check(_count_outcome_token(schedule, " vs ") == Sport.SERIES_WEEKS * Sport.MATCHES_PER_WEEK, where + " does not list five matches every week")
	var standings := str(game.standings_label.text)
	for club_name in Sport.CLUB_NAMES:
		_check(standings.contains(str(club_name)), where + " standings are missing " + str(club_name))
	_check(standings.contains(Sport.TIE_RULE), where + " standings are missing the tie rule")
	_check(standings.contains("run diff"), where + " standings are missing run difference")
	_check(
		standings.contains("Series seed order: %s." % Sport.seed_order_names(int(game.series.seed))),
		where + " standings are missing the series seed order"
	)


func _skip_regular(game) -> void:
	for week in Sport.SERIES_WEEKS:
		_check(game.phase == "office", "week %d did not return to the office" % (week + 1))
		_check(int(game.series.week) == week, "office week counter is not %d" % (week + 1))
		_check(str(game.schedule_label.text).contains(Sport.TENTH_CLUB), "Marrowfen Owls left the office")
		_check(str(game.schedule_label.text).contains(Sport.ELEVENTH_CLUB), "Ashwharf Swifts left the office")
		_check(str(game.schedule_label.text).contains(" bye"), "week %d dropped the bye from the schedule" % (week + 1))
		_check(_count_outcome_token(str(game.opponent_label.text), "Other match:") == 4, "week %d did not list the other four matches" % (week + 1))
		var player_off: bool = not game.series.player_plays()
		if player_off:
			_check(week + 1 == 2 or week + 1 == 13, "Lumen Reedmice were off in week %d" % (week + 1))
			_check(str(game.record_label.text).contains("Bye week."), "week %d is not marked as a bye" % (week + 1))
			_check(str(game.fixture_title.text) == "Bye week", "week %d title is not the bye" % (week + 1))
			_check(str(game.opponent_label.text).contains("No match is recorded for Lumen Reedmice."), "week %d does not say the player has no match" % (week + 1))
		else:
			_check(str(game.record_label.text).contains("You bat"), "week %d does not say which side bats" % (week + 1))
			_check(not str(game.record_label.text).contains("Bye"), "week %d is marked as a bye" % (week + 1))
		game.skip_button.pressed.emit()
		_check(game.phase == "result", "skip did not reach the result in week %d" % (week + 1))
		_check(game.watch_log.size() == Sport.PAS_PER_MATCH, "skip log length in week %d" % (week + 1))
		_check(_count_outcome_token(str(game.result_label.text), "Other match:") == 4, "the other four matches were not shown in week %d" % (week + 1))
		if player_off:
			_check(str(game.result_label.text).begins_with("Bye."), "week %d result is not a bye" % (week + 1))
			_check(str(game.result_label.text).contains("No match is recorded for Lumen Reedmice."), "week %d result stored the player's match" % (week + 1))
		else:
			_check(not str(game.result_label.text).begins_with("Bye."), "week %d result is a bye" % (week + 1))
		game.continue_button.pressed.emit()


func _exercise_final_choices(game) -> void:
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


func _watch_skip_final(game) -> void:
	var game_no := int(game.series.final_game_index()) + 1
	_check(str(game.week_label.text) == "Final game %d" % game_no, "final office is not labeled with the game number")
	_check(str(game.goal_label.text).contains("win the series"), "final office lost the series goal")
	_check(str(game.rule_label.text).contains("not a win for either side"), "final office lost the tie rule")
	_check(str(game.tactic_help.text).contains("series continues"), "final office does not say how a tie continues")
	_check(is_equal_approx(float(game.ticker.wait_time), 1.0), "final watch is not one plate appearance per second")
	_exercise_final_choices(game)
	game.watch_button.pressed.emit()
	_check(game.phase == "watch", "final watch did not start")
	await process_frame
	_check(game.watch_log.size() == 1, "final watch did not show the first plate appearance")
	_check(game.field_board.size.y >= 200.0, "final field did not lay out")
	game.match_skip_button.pressed.emit()
	_check(game.phase == "result", "final skip did not reach the result")
	var appearances: Array = game.current_match["plate_appearances"]
	_check(appearances.size() == Sport.PAS_PER_MATCH, "final plate count")
	_check(game.watch_log.size() == appearances.size(), "final watch log is not one line per plate appearance")
	for i in appearances.size():
		_check(str(game.watch_log[i]) == str(appearances[i]["explanation"]), "final watch line %d drifted" % i)
	_check(str(game.result_label.text).begins_with("Final game %d:" % game_no), "final result is not labeled with the game")


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
	_check_office(game, "open")

	game.start_new_series(42)
	await process_frame
	_check_office(game, "start")
	_check(str(game.week_label.text) == "Week 1 of 22", "office does not open on a twenty-two-week series")
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

	game.start_new_series(MISS_SEED)
	_check_office(game, "scripted miss")
	_skip_regular(game)
	_check(game.phase == "board", "a missed final did not end on the board")
	_check(game.series.results.size() == Sport.SERIES_WEEKS * Sport.MATCHES_PER_WEEK, "the miss did not store one hundred ten matches")
	_check(int(game.series.week) == 22, "the miss did not finish week 22")
	_check(not game.series.reached_final(), "the miss reached the final")
	_check(game.series.final_games.is_empty(), "the miss stored a final")
	var board_text := str(game.board_label.text)
	_check(board_text.contains("reach the final and win the series"), "board is missing the series goal")
	_check(board_text.contains(Sport.FINAL_TIE_TEXT), "board is missing the tie rule")
	_check(board_text.contains("Result: MISSED"), "a missed final should be MISSED")
	_check(not board_text.contains("Result: MET"), "goal text contradicts MISSED")
	_check(board_text.contains("The final: not played."), "a missed final was played on the board")
	_check(board_text.contains("finished 3rd"), "the board does not give the finishing place")
	_check(board_text.contains("without a final"), "the board does not end the season without a final")
	_check(board_text.contains("Week 22:"), "week 22 was not played")
	_check(not board_text.contains("Week 23:"), "an extra week was played")
	_check(board_text.contains(Sport.SIXTH_CLUB), "Ashfen Moths did not reach the board")
	_check(board_text.contains(Sport.ELEVENTH_CLUB), "Ashwharf Swifts did not reach the board")
	_check(_count_outcome_token(board_text, "You had the bye.") == 2, "the board did not list both byes")
	_check(board_text.contains("Marrowgate Herons at home and Ashfen Moths away."), "the clubs ahead were not named")
	_check(not game.series.goal_met(), "a missed final met the goal")
	print("Scripted miss from the office: MISSED")
	var seed_before := int(game.series.seed)
	game.board_restart_button.pressed.emit()
	_check(game.phase == "office", "restart did not return to the office")
	_check(int(game.series.week) == 0, "restart did not reset the week")
	_check(game.series.results.is_empty(), "restart kept old results")
	_check(game.series.final_games.is_empty(), "restart kept a final")
	_check(int(game.series.seed) == seed_before + 1, "restart did not advance the seed")

	game.start_new_series(SWEEP_SEED)
	_check_office(game, "two-game final")
	_skip_regular(game)
	_check(game.phase == "office", "reaching the final skipped the final office")
	_check(game.series.in_final(), "two-game script did not open the final")
	_check(str(game.fixture_title.text) == "Final game 1: Pellwick Cinders", "final game 1 opponent was not shown")
	_check(str(game.record_label.text).contains("You bat first."), "the second finalist did not bat first on screen")
	_check(str(game.schedule_label.text).contains("> Final game 1   Pellwick Cinders vs Lumen Reedmice"), "game 1 did not list the club ahead at home")
	var sweep_table := _snapshot(game.series)
	await _watch_skip_final(game)
	_check(str(game.current_match["player_result"]) == "win", "watched final game 1 was not a win")
	_check(str(game.result_label.text).contains("The series continues to game 2."), "game 1 did not say the series continues")
	_check(str(game.result_label.text).contains("Lumen Reedmice will be home and bat second."), "game 2 home was not named")
	game.continue_button.pressed.emit()
	_check(game.phase == "office", "game 1 sent the series to the board")
	_check(str(game.week_label.text) == "Final game 2", "the office did not open game 2")
	_check(str(game.record_label.text).contains("You bat second."), "game 2 did not give the odd-game visitor the even game at home")
	_check(str(game.schedule_label.text).contains("> Final game 2   Lumen Reedmice vs Pellwick Cinders"), "game 2 did not list Lumen Reedmice at home")
	_check(_same_snapshot(sweep_table, _snapshot(game.series)), "game 1 changed the table")
	await _watch_skip_final(game)
	_check(str(game.result_label.text).contains("Lumen Reedmice won the series, 2 wins to 0 wins."), "game 2 did not award the series")
	var lash_before: Array = _lash_list(game.series.player_roster)
	game.continue_button.pressed.emit()
	_check(game.phase == "board", "winning the series did not reach the board")
	var win_board := str(game.board_label.text)
	_check(win_board.contains("Result: MET"), "winning the series should be MET")
	_check(not win_board.contains("Result: MISSED"), "goal text contradicts MET")
	_check(win_board.contains("reached the final and won the series, 2 wins to 0 wins."), "board does not say the series was won")
	_check(win_board.contains("Final game 1:"), "board is missing final game 1")
	_check(win_board.contains("Final game 2:"), "board is missing final game 2")
	_check(win_board.contains("The final does not change the table."), "board does not keep the table fixed")
	_check(win_board.contains("Week 22:"), "win board skipped week 22")
	_check(win_board.contains(Sport.SIXTH_CLUB), "Ashfen Moths left the win board")
	_check(win_board.contains(Sport.ELEVENTH_CLUB), "Ashwharf Swifts left the win board")
	_check(win_board.contains("You had the bye."), "the win board dropped the bye")
	_check(game.series.goal_met(), "the board goal was not met")
	_check(game.series.results.size() == Sport.SERIES_WEEKS * Sport.MATCHES_PER_WEEK, "the final was stored in the table")
	_check(game.series.final_games.size() == 2, "the board series did not stop at two wins")
	_check(_stats_in_range(game.series.rosters), "the series left a stat outside 1-20")
	_assert_plus(game.series.player_roster, lash_before, "lash", 1, "game 2 training did not add 1 Lash")
	print("Scripted final from the office: won in two games")

	game.start_new_series(TIE_SEED)
	_skip_regular(game)
	_check(game.series.in_final(), "tie script did not open the final")
	await _watch_skip_final(game)
	_check(str(game.current_match["winner"]) == "tie", "tie script game 1 was not a tie")
	_check(str(game.result_label.text).contains("A tie is not a win for either side."), "the result does not say a tie is not a win")
	_check(str(game.result_label.text).contains("The series continues to game 2."), "the result does not continue the series")
	_check(str(game.result_label.text).contains("Saltwharf Gulls will be home and bat second."), "game 2 home was not Saltwharf Gulls")
	game.continue_button.pressed.emit()
	_check(game.phase == "office", "a tie ended the season")
	_check(str(game.week_label.text) == "Final game 2", "the tie script skipped game 2")
	_check(str(game.goal_label.text).contains("Game 1 was a tie, so it was not a win for either side. The series continues."), "the office hid the tie")
	_check(str(game.record_label.text).contains("Series 0-0."), "the tie changed the series score")
	_check(str(game.record_label.text).contains("You bat first."), "game 2 did not send the club ahead on the road")
	await _watch_skip_final(game)
	_check(str(game.current_match["player_result"]) == "loss", "tie script game 2 drifted")
	_check(str(game.result_label.text).contains("The series continues to game 3."), "one loss ended the series")
	_check(str(game.result_label.text).contains("Lumen Reedmice will be home and bat second."), "game 3 home was not the club ahead")
	game.continue_button.pressed.emit()
	_check(str(game.week_label.text) == "Final game 3", "the series did not open game 3")
	_check(str(game.record_label.text).contains("Series 0-1."), "game 2 did not count as one loss")
	_check(str(game.record_label.text).contains("You bat second."), "game 3 did not return home to the club ahead")
	await _watch_skip_final(game)
	_check(str(game.result_label.text).contains("Lumen Reedmice lost the series, 0 wins to 2 wins."), "the games after the tie did not decide the series")
	game.continue_button.pressed.emit()
	_check(game.phase == "board", "the series after a tie did not reach the board")
	_check(str(game.board_label.text).contains("Result: MISSED"), "losing after a tie should be MISSED")
	_check(str(game.board_label.text).contains("Game 1 was a tie."), "the board dropped the tie")
	_check(game.series.final_games.size() == 3, "the tie did not force a third game")
	print("Scripted final from the office: tie continued into game 3")

	game.start_new_series(LOSS_SEED)
	_skip_regular(game)
	var loss_games := 0
	while game.phase == "office" and game.series.in_final() and loss_games < 8:
		await _watch_skip_final(game)
		loss_games += 1
		var outcome := str(game.current_match.get("winner", ""))
		if outcome == "tie":
			_check(str(game.result_label.text).contains("A tie is not a win for either side."), "a later tie was treated as a win")
			_check(str(game.result_label.text).contains("The series continues"), "a later tie did not continue the series")
		game.continue_button.pressed.emit()
	_check(loss_games == 5, "the lost series did not play every game through the ties")
	_check(game.phase == "board", "losing the series did not reach the board")
	var loss_board := str(game.board_label.text)
	_check(loss_board.contains("Result: MISSED"), "losing the series should be MISSED")
	_check(loss_board.contains("reached the final and lost the series, 0 wins to 2 wins."), "the board does not say the series was lost")
	_check(not game.series.goal_met(), "losing the series met the goal")
	_check(game.series.results.size() == Sport.SERIES_WEEKS * Sport.MATCHES_PER_WEEK, "the lost series changed the table")
	_check(_stats_in_range(game.series.rosters), "the lost series left a stat outside 1-20")
	print("Scripted final from the office: lost the series")

	game.start_new_series(7)
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
