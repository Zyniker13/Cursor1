extends SceneTree

const Sport = preload("res://scripts/sport.gd")
const SeriesScript = preload("res://scripts/series.gd")

const LINEUP: Array = [0, 1, 2, 3]
const ALT_LINEUP: Array = [5, 4, 3, 2]
const TACTIC := "aggressive"
const FOCUS := "lash"
# Seed 349 drills the lowest stat, finishes 1st, and beats Ashwharf Swifts:
# Lumen Reedmice 2, Ashwharf Swifts 11; then Ashwharf Swifts 3, Lumen Reedmice 7;
# then Lumen Reedmice 5, Ashwharf Swifts 1. The series is 2 wins to 1 win.
# A fixed Lash drill on that seed finishes 17th and does not reach the final.
# Seed 309 drills the lowest stat, finishes 10th, and does not reach the final.
const SWEEP_SEED := 349
const THIRD_SEED := 1055
const MISS_SEED := 2277
const TIE_SEED := 1322
const LOSS_SEED := 342

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


func _stat_order(roster: Array) -> String:
	var bag: Array = []
	for player in roster:
		var bits: Array = []
		for key in Sport.STATS:
			bits.append(str(Sport.get_stat(player, key)))
		bag.append("-".join(bits))
	return ",".join(bag)


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
	print("TEST nineteen clubs and thirty-eight-week schedule")
	_check(Sport.CLUB_COUNT == 19, "club count is not nineteen")
	_check(Sport.CLUB_NAMES.size() == 19, "club list is not nineteen clubs")
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
	_check(Sport.TWELFTH_CLUB == "Pellfen Terns", "twelfth club drifted")
	_check(Sport.THIRTEENTH_CLUB == "Southfen Coots", "thirteenth club drifted")
	_check(Sport.FOURTEENTH_CLUB == "Tidefen Grebes", "fourteenth club drifted")
	_check(Sport.FIFTEENTH_CLUB == "Brinefen Curlews", "fifteenth club drifted")
	_check(Sport.SIXTEENTH_CLUB == "Quayfen Knots", "sixteenth club drifted")
	_check(Sport.SEVENTEENTH_CLUB == "Millfen Ruffs", "seventeenth club drifted")
	_check(Sport.EIGHTEENTH_CLUB == "Wickfen Dunlins", "eighteenth club drifted")
	_check(Sport.NINETEENTH_CLUB == "Lockfen Snipes", "nineteenth club drifted")
	_check(Sport.PLAYER_INDEX == 0, "player index drifted")
	_check(str(Sport.CLUB_NAMES[3]) == Sport.FOURTH_CLUB, "Marrowgate Herons is missing from the club list")
	_check(str(Sport.CLUB_NAMES[4]) == Sport.FIFTH_CLUB, "Saltmere Kites is missing from the club list")
	_check(str(Sport.CLUB_NAMES[5]) == Sport.SIXTH_CLUB, "Ashfen Moths is missing from the club list")
	_check(str(Sport.CLUB_NAMES[6]) == Sport.SEVENTH_CLUB, "Reedfen Larks is missing from the club list")
	_check(str(Sport.CLUB_NAMES[7]) == Sport.EIGHTH_CLUB, "Cinderwharf Pikes is missing from the club list")
	_check(str(Sport.CLUB_NAMES[8]) == Sport.NINTH_CLUB, "Saltwharf Gulls is missing from the club list")
	_check(str(Sport.CLUB_NAMES[9]) == Sport.TENTH_CLUB, "Marrowfen Owls is missing from the club list")
	_check(str(Sport.CLUB_NAMES[10]) == Sport.ELEVENTH_CLUB, "Ashwharf Swifts is missing from the club list")
	_check(str(Sport.CLUB_NAMES[11]) == Sport.TWELFTH_CLUB, "Pellfen Terns is missing from the club list")
	_check(str(Sport.CLUB_NAMES[12]) == Sport.THIRTEENTH_CLUB, "Southfen Coots is missing from the club list")
	_check(str(Sport.CLUB_NAMES[13]) == Sport.FOURTEENTH_CLUB, "Tidefen Grebes is missing from the club list")
	_check(str(Sport.CLUB_NAMES[14]) == Sport.FIFTEENTH_CLUB, "Brinefen Curlews is missing from the club list")
	_check(str(Sport.CLUB_NAMES[15]) == Sport.SIXTEENTH_CLUB, "Quayfen Knots is missing from the club list")
	_check(str(Sport.CLUB_NAMES[16]) == Sport.SEVENTEENTH_CLUB, "Millfen Ruffs is missing from the club list")
	_check(str(Sport.CLUB_NAMES[17]) == Sport.EIGHTEENTH_CLUB, "Wickfen Dunlins is missing from the club list")
	_check(str(Sport.CLUB_NAMES[18]) == Sport.NINETEENTH_CLUB, "Lockfen Snipes is missing from the club list")
	_check(Sport.SERIES_WEEKS == 38, "series is not thirty-eight weeks")
	_check(Sport.MATCHES_PER_WEEK == 9, "a week does not hold nine matches")
	_check(Sport.BYES_EACH == 2, "a club does not have two byes")
	_check(Sport.GAMES_EACH == 36, "a club does not play thirty-six games")
	_check(Sport.ROUND_ROBIN.size() == 38, "schedule is not thirty-eight weeks")
	_check(Sport.FINAL_WINS_NEEDED == 2, "the final is not first to two wins")
	_check(Sport.WIN_POINTS == 2 and Sport.TIE_POINTS == 1, "points values drifted")
	_check(Sport.GOAL_TEXT == "Board goal: reach the final and win the series.", "goal text drifted")
	_check(Sport.FINAL_TEXT.contains("3rd through 19th"), "missing the final does not run through 19th")
	_check(Sport.FINAL_TIE_TEXT.contains("not a win for either side"), "tie rule is missing from the final text")
	_check(Sport.FINAL_TIE_TEXT.contains("series continues"), "the final text does not say how a tie continues")
	_check(Sport.FINAL_TEXT.contains("best-of-three"), "the final is not described as a best of three")
	_check(Sport.FINAL_TEXT.contains("game 1") and Sport.FINAL_TEXT.contains("game 3"), "home for game 1 and game 3 is missing")
	_check(Sport.SCHEDULE_TEXT.contains("double round-robin"), "schedule shape is not described")
	_check(Sport.SCHEDULE_TEXT.contains("nine matches"), "nine matches a week is not described")
	_check(Sport.SCHEDULE_TEXT.contains("one bye"), "one bye a week is not described")
	_check(Sport.SCHEDULE_TEXT.contains("two byes"), "two byes is not described")
	_check(not Sport.SCHEDULE_TEXT.contains("no bye"), "the schedule still says there is no bye")
	_check(not Sport.SCHEDULE_TEXT.contains("zero byes"), "the schedule still says zero byes")
	_check(not Sport.SCHEDULE_TEXT.contains("eight matches"), "the schedule still says eight matches")
	_check(not Sport.SCHEDULE_TEXT.contains("seven matches"), "the schedule still says seven matches")
	_check(not Sport.SCHEDULE_TEXT.contains("six matches"), "the schedule still says six matches")
	_check(not Sport.SCHEDULE_TEXT.contains("five matches"), "the schedule still says five matches")
	_check(Sport.SEED_RULE.contains("by 19"), "the series seed is not divided by 19")
	_check(Sport.SEED_RULE.contains("Ashfen Moths"), "the seed rule omits Ashfen Moths")
	_check(Sport.SEED_RULE.contains("Reedfen Larks"), "the seed rule omits Reedfen Larks")
	_check(Sport.SEED_RULE.contains("Cinderwharf Pikes"), "the seed rule omits Cinderwharf Pikes")
	_check(Sport.SEED_RULE.contains("Saltwharf Gulls"), "the seed rule omits Saltwharf Gulls")
	_check(Sport.SEED_RULE.contains("Marrowfen Owls"), "the seed rule omits Marrowfen Owls")
	_check(Sport.SEED_RULE.contains("Ashwharf Swifts"), "the seed rule omits Ashwharf Swifts")
	_check(Sport.SEED_RULE.contains("Pellfen Terns"), "the seed rule omits Pellfen Terns")
	_check(Sport.SEED_RULE.contains("Southfen Coots"), "the seed rule omits Southfen Coots")
	_check(Sport.SEED_RULE.contains("Tidefen Grebes"), "the seed rule omits Tidefen Grebes")
	_check(Sport.SEED_RULE.contains("Brinefen Curlews"), "the seed rule omits Brinefen Curlews")
	_check(Sport.SEED_RULE.contains("Quayfen Knots"), "the seed rule omits Quayfen Knots")
	_check(Sport.SEED_RULE.contains("Millfen Ruffs"), "the seed rule omits Millfen Ruffs")
	_check(Sport.SEED_RULE.contains("Wickfen Dunlins"), "the seed rule omits Wickfen Dunlins")
	_check(Sport.SEED_RULE.contains("Lockfen Snipes"), "the seed rule omits Lockfen Snipes")
	_check(Sport.SEED_RULE.contains("remainder 18"), "remainder 18 is missing from the seed rule")
	_check(Sport.TIE_RULE == "Ties in the table break by run difference, then by the existing series seed.", "tie rule text drifted")
	var pair_counts := {}
	var directed := {}
	var bye_weeks: Array = []
	var played_weeks: Array = []
	for _club in Sport.CLUB_COUNT:
		bye_weeks.append(0)
		played_weeks.append(0)
	var player_weeks: Array = []
	var player_byes: Array = []
	var appended: Array = [0, 1, 2, 3, 4, 5, 12, 14, 15, 13, 6, 7, 8, 9, 10, 11, 16, 17, 18]
	var appended_pairs: Array = []
	for slot in 9:
		appended_pairs.append([int(appended[slot]), int(appended[17 - slot])])
	_check(not (int(appended_pairs[0][0]) == 0 and int(appended_pairs[0][1]) == 11), "appending Lockfen Snipes was treated as week 1")
	_check(int(appended_pairs[0][0]) == 0 and int(appended_pairs[0][1]) == 17, "the appended ring did not pair Lumen Reedmice with Wickfen Dunlins")
	for week_index in Sport.SERIES_WEEKS:
		var cards: Array = Sport.week_fixtures(week_index)
		var bye := Sport.week_bye(week_index)
		_check(cards.size() == 9, "week %d does not list nine matches" % (week_index + 1))
		_check(bye >= 0 and bye < Sport.CLUB_COUNT, "week %d bye is out of range" % (week_index + 1))
		var seen := {}
		var player_on := false
		for card in cards:
			var home := int(card["home"])
			var away := int(card["away"])
			_check(home != away, "week %d lists a club against itself" % (week_index + 1))
			_check(home >= 0 and home < Sport.CLUB_COUNT and away >= 0 and away < Sport.CLUB_COUNT, "fixture index out of range")
			_check(str(card["home_club"]) == str(Sport.CLUB_NAMES[home]), "home club name drifted")
			_check(str(card["away_club"]) == str(Sport.CLUB_NAMES[away]), "away club name drifted")
			_check(int(card["bye"]) == bye and str(card["bye_club"]) == str(Sport.CLUB_NAMES[bye]), "week %d bye drifted" % (week_index + 1))
			_check(home != bye and away != bye, "week %d plays the club that is off" % (week_index + 1))
			seen[home] = true
			seen[away] = true
			if home == Sport.PLAYER_INDEX or away == Sport.PLAYER_INDEX:
				player_on = true
			played_weeks[home] = int(played_weeks[home]) + 1
			played_weeks[away] = int(played_weeks[away]) + 1
			var key := _pair_key(card)
			pair_counts[key] = int(pair_counts.get(key, 0)) + 1
			var arrow := "%d>%d" % [home, away]
			_check(not directed.has(arrow), "home and away repeated for %s" % arrow)
			directed[arrow] = true
		_check(not seen.has(bye), "week %d stored a match for the bye" % (week_index + 1))
		_check(seen.size() == Sport.CLUB_COUNT - 1, "week %d does not play the other eighteen clubs" % (week_index + 1))
		bye_weeks[bye] = int(bye_weeks[bye]) + 1
		if player_on:
			player_weeks.append(week_index + 1)
		if bye == Sport.PLAYER_INDEX:
			player_byes.append(week_index + 1)
	for count in played_weeks:
		_check(int(count) == Sport.GAMES_EACH, "a club does not play thirty-six games")
	for count in bye_weeks:
		_check(int(count) == Sport.BYES_EACH, "a club does not have two byes")
	_check(_same_indexes(player_byes, [2, 21]), "Lumen Reedmice are not off in week 2 and week 21")
	_check(player_weeks.has(1), "Lumen Reedmice do not play week 1")
	_check(not player_weeks.has(2) and not player_weeks.has(21), "Lumen Reedmice play on a bye week")
	_check(player_weeks.size() == Sport.GAMES_EACH, "Lumen Reedmice do not play thirty-six games")
	var pair_total := 0
	for a in Sport.CLUB_COUNT:
		for b in range(a + 1, Sport.CLUB_COUNT):
			var key := "%d-%d" % [a, b]
			_check(int(pair_counts.get(key, 0)) == 2, "pair %s is not played home and away" % key)
			_check(directed.has("%d>%d" % [a, b]) and directed.has("%d>%d" % [b, a]), "pair %s did not swap home" % key)
			pair_total += 1
	_check(pair_total == 171, "the nineteenth club is missing from the pair list")
	_check(int(pair_counts.get("0-18", 0)) == 2, "Lockfen Snipes does not meet Lumen Reedmice home and away")
	_check(int(pair_counts.get("0-17", 0)) == 2, "Wickfen Dunlins does not meet Lumen Reedmice home and away")
	_check(int(pair_counts.get("0-16", 0)) == 2, "Millfen Ruffs does not meet Lumen Reedmice home and away")
	_check(int(pair_counts.get("0-15", 0)) == 2, "Quayfen Knots does not meet Lumen Reedmice home and away")
	_check(int(pair_counts.get("0-14", 0)) == 2, "Brinefen Curlews does not meet Lumen Reedmice home and away")
	_check(int(pair_counts.get("0-13", 0)) == 2, "Tidefen Grebes does not meet Lumen Reedmice home and away")
	_check(int(pair_counts.get("0-12", 0)) == 2, "Southfen Coots does not meet Lumen Reedmice home and away")
	_check(int(pair_counts.get("0-11", 0)) == 2, "Pellfen Terns does not meet Lumen Reedmice home and away")
	var opening: Array = Sport.week_fixtures(0)
	_check(opening.size() == 9, "week 1 does not list nine matches")
	_check(str(opening[0]["home_club"]) == Sport.PLAYER_CLUB and str(opening[0]["away_club"]) == Sport.TWELFTH_CLUB, "week 1 does not list Lumen Reedmice at home to Pellfen Terns")
	_check(str(opening[1]["home_club"]) == Sport.OPPONENT_CLUB and str(opening[1]["away_club"]) == Sport.ELEVENTH_CLUB, "week 1 is missing Southspur Glass against Ashwharf Swifts")
	_check(str(opening[2]["home_club"]) == Sport.THIRD_CLUB and str(opening[2]["away_club"]) == Sport.TENTH_CLUB, "week 1 is missing Pellwick Cinders against Marrowfen Owls")
	_check(str(opening[3]["home_club"]) == Sport.FOURTH_CLUB and str(opening[3]["away_club"]) == Sport.NINTH_CLUB, "week 1 is missing Marrowgate Herons against Saltwharf Gulls")
	_check(str(opening[4]["home_club"]) == Sport.FIFTH_CLUB and str(opening[4]["away_club"]) == Sport.EIGHTH_CLUB, "week 1 is missing Saltmere Kites against Cinderwharf Pikes")
	_check(str(opening[5]["home_club"]) == Sport.SIXTH_CLUB and str(opening[5]["away_club"]) == Sport.SEVENTH_CLUB, "week 1 is missing Ashfen Moths against Reedfen Larks")
	_check(str(opening[6]["home_club"]) == Sport.THIRTEENTH_CLUB and str(opening[6]["away_club"]) == Sport.FOURTEENTH_CLUB, "week 1 does not list Southfen Coots at home to Tidefen Grebes")
	_check(str(opening[7]["home_club"]) == Sport.FIFTEENTH_CLUB and str(opening[7]["away_club"]) == Sport.SIXTEENTH_CLUB, "week 1 does not list Brinefen Curlews at home to Quayfen Knots")
	_check(str(opening[8]["home_club"]) == Sport.SEVENTEENTH_CLUB and str(opening[8]["away_club"]) == Sport.EIGHTEENTH_CLUB, "week 1 does not list Millfen Ruffs at home to Wickfen Dunlins")
	_check(int(opening[0]["bye"]) == 18 and str(opening[0]["bye_club"]) == Sport.NINETEENTH_CLUB, "week 1 bye is not Lockfen Snipes")
	_check(Sport.week_bye(1) == Sport.PLAYER_INDEX, "week 2 bye is not Lumen Reedmice")
	_check(Sport.week_bye(20) == Sport.PLAYER_INDEX, "week 21 bye is not Lumen Reedmice")
	var second: Array = Sport.week_fixtures(1)
	_check(str(second[0]["home_club"]) == Sport.OPPONENT_CLUB and str(second[0]["away_club"]) == Sport.NINETEENTH_CLUB, "week 2 does not follow Southspur Glass vs Lockfen Snipes")
	var ring: Array = Sport.RING.duplicate()
	_check(ring.size() == Sport.CLUB_COUNT, "the ring is not the nineteen clubs")
	var half := int(Sport.SERIES_WEEKS / 2)
	for week_index in half:
		var early: Array = Sport.week_fixtures(week_index)
		var late: Array = Sport.week_fixtures(week_index + half)
		_check(early.size() == 9 and late.size() == 9, "a half week dropped a match")
		for slot in 9:
			_check(int(early[slot]["home"]) == int(ring[slot]), "week %d is not paired from the outside in" % (week_index + 1))
			_check(int(early[slot]["away"]) == int(ring[17 - slot]), "week %d away side is not outside in" % (week_index + 1))
			_check(int(late[slot]["home"]) == int(early[slot]["away"]), "second half did not reverse home")
			_check(int(late[slot]["away"]) == int(early[slot]["home"]), "second half did not reverse away")
		_check(int(early[0]["bye"]) == int(ring[ring.size() - 1]), "week %d bye is not the last seat" % (week_index + 1))
		_check(int(late[0]["bye"]) == int(early[0]["bye"]), "week %d did not keep the same bye" % (week_index + half + 1))
		var first_club = ring[0]
		ring.remove_at(0)
		ring.append(first_club)
	var first_half := {}
	for week_index in half:
		for card in Sport.week_fixtures(week_index):
			var key := _pair_key(card)
			first_half[key] = int(first_half.get(key, 0)) + 1
	_check(first_half.size() == 171, "weeks 1-19 are not a full round-robin")
	for key in first_half:
		_check(int(first_half[key]) == 1, "weeks 1-19 repeat a pair")
	var dealt := Sport.create_clubs(42)
	var bag := _stat_bag(dealt["rosters"][0])
	for club_index in Sport.CLUB_COUNT:
		_check(bag == _stat_bag(dealt["rosters"][club_index]), "club %d was not dealt the same stat lines" % club_index)
	var kept := {
		0: "15-11-11-15-12-15,9-15-9-13-9-14,9-9-9-10-12-11,15-9-11-11-9-10,9-13-13-10-10-15,14-9-10-14-13-15",
		11: "15-9-11-11-9-10,15-11-11-15-12-15,9-13-13-10-10-15,9-15-9-13-9-14,14-9-10-14-13-15,9-9-9-10-12-11",
		12: "9-15-9-13-9-14,9-9-9-10-12-11,9-13-13-10-10-15,15-11-11-15-12-15,15-9-11-11-9-10,14-9-10-14-13-15",
		15: "9-9-9-10-12-11,15-11-11-15-12-15,9-13-13-10-10-15,9-15-9-13-9-14,15-9-11-11-9-10,14-9-10-14-13-15",
		16: "14-9-10-14-13-15,9-13-13-10-10-15,15-11-11-15-12-15,9-9-9-10-12-11,15-9-11-11-9-10,9-15-9-13-9-14",
		17: "9-13-13-10-10-15,14-9-10-14-13-15,9-15-9-13-9-14,15-11-11-15-12-15,15-9-11-11-9-10,9-9-9-10-12-11",
		18: "15-11-11-15-12-15,14-9-10-14-13-15,9-15-9-13-9-14,9-9-9-10-12-11,9-13-13-10-10-15,15-9-11-11-9-10",
	}
	for club_index in kept:
		_check(_stat_order(dealt["rosters"][club_index]) == str(kept[club_index]), "club %d did not keep its stat lines" % club_index)
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
	_check(Sport.seed_start(11) == 11, "seed 11 did not start with Pellfen Terns")
	_check(Sport.seed_start(12) == 12, "seed 12 did not start with Southfen Coots")
	_check(Sport.seed_start(13) == 13, "seed 13 did not start with Tidefen Grebes")
	_check(Sport.seed_start(14) == 14, "seed 14 did not start with Brinefen Curlews")
	_check(Sport.seed_start(15) == 15, "seed 15 did not start with Quayfen Knots")
	_check(Sport.seed_start(16) == 16, "seed 16 did not start with Millfen Ruffs")
	_check(Sport.seed_start(17) == 17, "seed 17 did not start with Wickfen Dunlins")
	_check(Sport.seed_start(18) == 18, "seed 18 did not start with Lockfen Snipes")
	_check(Sport.seed_start(19) == 0, "seed remainder drifted")
	_check(Sport.seed_start(-1) == 18, "a negative series seed broke the remainder")
	_check(
		Sport.seed_order_names(5) == "Ashfen Moths, Reedfen Larks, Cinderwharf Pikes, Saltwharf Gulls, Marrowfen Owls, Ashwharf Swifts, Pellfen Terns, Southfen Coots, Tidefen Grebes, Brinefen Curlews, Quayfen Knots, Millfen Ruffs, Wickfen Dunlins, Lockfen Snipes, Lumen Reedmice, Southspur Glass, Pellwick Cinders, Marrowgate Herons, Saltmere Kites",
		"seed order names drifted"
	)
	_check(
		Sport.seed_order_names(14) == "Brinefen Curlews, Quayfen Knots, Millfen Ruffs, Wickfen Dunlins, Lockfen Snipes, Lumen Reedmice, Southspur Glass, Pellwick Cinders, Marrowgate Herons, Saltmere Kites, Ashfen Moths, Reedfen Larks, Cinderwharf Pikes, Saltwharf Gulls, Marrowfen Owls, Ashwharf Swifts, Pellfen Terns, Southfen Coots, Tidefen Grebes",
		"Brinefen Curlews did not lead the seed order"
	)
	_check(
		Sport.seed_order_names(15) == "Quayfen Knots, Millfen Ruffs, Wickfen Dunlins, Lockfen Snipes, Lumen Reedmice, Southspur Glass, Pellwick Cinders, Marrowgate Herons, Saltmere Kites, Ashfen Moths, Reedfen Larks, Cinderwharf Pikes, Saltwharf Gulls, Marrowfen Owls, Ashwharf Swifts, Pellfen Terns, Southfen Coots, Tidefen Grebes, Brinefen Curlews",
		"Quayfen Knots did not lead the seed order"
	)
	_check(
		Sport.seed_order_names(16) == "Millfen Ruffs, Wickfen Dunlins, Lockfen Snipes, Lumen Reedmice, Southspur Glass, Pellwick Cinders, Marrowgate Herons, Saltmere Kites, Ashfen Moths, Reedfen Larks, Cinderwharf Pikes, Saltwharf Gulls, Marrowfen Owls, Ashwharf Swifts, Pellfen Terns, Southfen Coots, Tidefen Grebes, Brinefen Curlews, Quayfen Knots",
		"Millfen Ruffs did not lead the seed order"
	)
	_check(
		Sport.seed_order_names(17) == "Wickfen Dunlins, Lockfen Snipes, Lumen Reedmice, Southspur Glass, Pellwick Cinders, Marrowgate Herons, Saltmere Kites, Ashfen Moths, Reedfen Larks, Cinderwharf Pikes, Saltwharf Gulls, Marrowfen Owls, Ashwharf Swifts, Pellfen Terns, Southfen Coots, Tidefen Grebes, Brinefen Curlews, Quayfen Knots, Millfen Ruffs",
		"Wickfen Dunlins did not lead the seed order"
	)
	_check(
		Sport.seed_order_names(18) == "Lockfen Snipes, Lumen Reedmice, Southspur Glass, Pellwick Cinders, Marrowgate Herons, Saltmere Kites, Ashfen Moths, Reedfen Larks, Cinderwharf Pikes, Saltwharf Gulls, Marrowfen Owls, Ashwharf Swifts, Pellfen Terns, Southfen Coots, Tidefen Grebes, Brinefen Curlews, Quayfen Knots, Millfen Ruffs, Wickfen Dunlins",
		"Lockfen Snipes did not lead the seed order"
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
	_fill_rate(rated[11], 0, 1, -9)
	_fill_rate(rated[12], 0, 1, -10)
	_fill_rate(rated[13], 0, 1, -11)
	_fill_rate(rated[14], 0, 1, -12)
	_fill_rate(rated[15], 0, 1, -13)
	_fill_rate(rated[16], 0, 1, -14)
	_fill_rate(rated[17], 0, 1, -15)
	_fill_rate(rated[18], 0, 1, -16)
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
	_check(_same_indexes(seeded_order, [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 0, 1, 2, 3, 4]), "the series seed did not break a level table")
	Sport.apply_seed_ranks(seeded, 0)
	seeded_order = _ordered_indexes(seeded)
	_check(_same_indexes(seeded_order, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18]), "seed 0 order drifted")
	Sport.apply_seed_ranks(seeded, 4)
	seeded_order = _ordered_indexes(seeded)
	_check(_same_indexes(seeded_order, [4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 0, 1, 2, 3]), "seed 4 order drifted")
	Sport.apply_seed_ranks(seeded, 9)
	seeded_order = _ordered_indexes(seeded)
	_check(_same_indexes(seeded_order, [9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 0, 1, 2, 3, 4, 5, 6, 7, 8]), "seed 9 order drifted")
	Sport.apply_seed_ranks(seeded, 14)
	seeded_order = _ordered_indexes(seeded)
	_check(_same_indexes(seeded_order, [14, 15, 16, 17, 18, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]), "seed 14 order drifted")
	Sport.apply_seed_ranks(seeded, 15)
	seeded_order = _ordered_indexes(seeded)
	_check(_same_indexes(seeded_order, [15, 16, 17, 18, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]), "seed 15 order drifted")
	Sport.apply_seed_ranks(seeded, 16)
	seeded_order = _ordered_indexes(seeded)
	_check(_same_indexes(seeded_order, [16, 17, 18, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]), "seed 16 order drifted")
	Sport.apply_seed_ranks(seeded, 17)
	seeded_order = _ordered_indexes(seeded)
	_check(_same_indexes(seeded_order, [17, 18, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]), "seed 17 order drifted")


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


func _lowest_focus(roster: Array) -> String:
	return str(Sport.opponent_plan(roster, 0, 0)["training"])


func _script_focus(played, balance: bool) -> String:
	if balance:
		return _lowest_focus(played.player_roster)
	return FOCUS


func _collect_lines(series_seed: int, lineup: Array, balance: bool = false) -> Array:
	var played = SeriesScript.new(series_seed)
	var lines: Array = []
	for _week in Sport.SERIES_WEEKS:
		var started: Dictionary = played.begin_match(lineup, TACTIC, _script_focus(played, balance))
		for match_result in _matches_in_slot_order(started):
			_append_match(lines, match_result)
		played.commit_match()
	var guard := 0
	while played.reached_final() and not played.is_over() and guard < 8:
		var fin: Dictionary = played.begin_match(lineup, TACTIC, _script_focus(played, balance))
		_append_match(lines, fin)
		played.commit_match()
		guard += 1
	return lines


func _test_determinism() -> void:
	print("TEST determinism")
	var first_clubs := Sport.create_clubs(42)
	var second_clubs := Sport.create_clubs(42)
	_check((first_clubs["rosters"] as Array).size() == 19, "nineteenth club roster is missing")
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
	var sweep_a := _collect_lines(SWEEP_SEED, LINEUP, true)
	var sweep_b := _collect_lines(SWEEP_SEED, LINEUP, true)
	_check(sweep_a.size() == (regular_matches + 3) * Sport.PAS_PER_MATCH, "sweep at-bat count did not include every final game")
	_check(_same_lines(sweep_a, sweep_b), "the same seed and lineup did not repeat the at-bats, including the final")
	var third_a := _collect_lines(THIRD_SEED, LINEUP, true)
	var third_b := _collect_lines(THIRD_SEED, LINEUP, true)
	_check(third_a.size() == (regular_matches + 3) * Sport.PAS_PER_MATCH, "third-game at-bat count drifted")
	_check(_same_lines(third_a, third_b), "a series that reaches game 3 did not repeat its at-bats")
	var tie_a := _collect_lines(TIE_SEED, LINEUP, true)
	var tie_b := _collect_lines(TIE_SEED, LINEUP, true)
	_check(tie_a.size() == (regular_matches + 5) * Sport.PAS_PER_MATCH, "tied-final at-bat count drifted")
	_check(_same_lines(tie_a, tie_b), "a tied final game did not repeat its at-bats")
	var loss_a := _collect_lines(LOSS_SEED, LINEUP, true)
	var loss_b := _collect_lines(LOSS_SEED, LINEUP, true)
	_check(loss_a.size() == (regular_matches + 2) * Sport.PAS_PER_MATCH, "the lost series did not keep both final games")
	_check(_same_lines(loss_a, loss_b), "the extended final did not repeat its at-bats")
	var other_lineup := _collect_lines(SWEEP_SEED, ALT_LINEUP, true)
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
	_check(_same_lines(left_pair[5], right_pair[5]), "the fifth other match changed when the player's lineup changed")
	_check(_same_lines(left_pair[6], right_pair[6]), "the sixth other match changed when the player's lineup changed")
	_check(_same_lines(left_pair[7], right_pair[7]), "the seventh other match changed when the player's lineup changed")
	_check(_same_lines(left_pair[8], right_pair[8]), "the eighth other match changed when the player's lineup changed")
	var week_a := _week_bundle(SWEEP_SEED, 2, LINEUP, TACTIC)
	var week_b := _week_bundle(SWEEP_SEED, 2, ALT_LINEUP, "field")
	_check(str(week_a[9]) != "bye" and str(week_b[9]) != "bye", "week 3 was treated as a bye")
	_check(not _same_lines(week_a[0], week_b[0]), "week 3 ignored the lineup")
	_check(
		_same_lines(week_a[1], week_b[1]) and _same_lines(week_a[2], week_b[2]) and _same_lines(week_a[3], week_b[3]) and _same_lines(week_a[4], week_b[4]) and _same_lines(week_a[5], week_b[5]) and _same_lines(week_a[6], week_b[6]) and _same_lines(week_a[7], week_b[7]) and _same_lines(week_a[8], week_b[8]),
		"the other matches changed when the lineup changed"
	)
	_check(
		week_a[1].size() == Sport.PAS_PER_MATCH and week_a[8].size() == Sport.PAS_PER_MATCH,
		"week 3 did not record the other eight matches"
	)
	var second_week_a := _week_bundle(SWEEP_SEED, 1, LINEUP, TACTIC)
	var second_week_b := _week_bundle(SWEEP_SEED, 1, ALT_LINEUP, "field")
	_check(str(second_week_a[9]) == "bye" and str(second_week_b[9]) == "bye", "week 2 was not a bye for Lumen Reedmice")
	_check(_same_lines(second_week_a[0], second_week_b[0]), "week 2 followed match changed when the lineup changed")
	_check(
		_same_lines(second_week_a[1], second_week_b[1]) and _same_lines(second_week_a[2], second_week_b[2]) and _same_lines(second_week_a[3], second_week_b[3]) and _same_lines(second_week_a[4], second_week_b[4]) and _same_lines(second_week_a[5], second_week_b[5]) and _same_lines(second_week_a[6], second_week_b[6]) and _same_lines(second_week_a[7], second_week_b[7]) and _same_lines(second_week_a[8], second_week_b[8]),
		"week 2 changed a match when the lineup changed"
	)
	var week_17_a := _week_bundle(SWEEP_SEED, 16, LINEUP, TACTIC)
	var week_17_b := _week_bundle(SWEEP_SEED, 16, ALT_LINEUP, "field")
	_check(str(week_17_a[9]) != "bye" and str(week_17_b[9]) != "bye", "week 17 was treated as a bye")
	_check(not _same_lines(week_17_a[0], week_17_b[0]), "week 17 ignored Lumen Reedmice's lineup")
	_check(
		_same_lines(week_17_a[1], week_17_b[1]) and _same_lines(week_17_a[8], week_17_b[8]),
		"week 17 changed another match when the player's lineup changed"
	)
	var week_19_a := _week_bundle(SWEEP_SEED, 18, LINEUP, TACTIC)
	var week_19_b := _week_bundle(SWEEP_SEED, 18, ALT_LINEUP, "field")
	_check(str(week_19_a[9]) != "bye" and str(week_19_b[9]) != "bye", "week 19 was treated as a bye")
	_check(not _same_lines(week_19_a[0], week_19_b[0]), "week 19 ignored Lumen Reedmice's lineup")
	_check(
		_same_lines(week_19_a[1], week_19_b[1]) and _same_lines(week_19_a[8], week_19_b[8]),
		"week 19 changed another match when the player's lineup changed"
	)
	var week_21_a := _week_bundle(SWEEP_SEED, 20, LINEUP, TACTIC)
	var week_21_b := _week_bundle(SWEEP_SEED, 20, ALT_LINEUP, "field")
	_check(str(week_21_a[9]) == "bye" and str(week_21_b[9]) == "bye", "week 21 was not a bye for Lumen Reedmice")
	_check(_same_lines(week_21_a[0], week_21_b[0]), "week 21 followed match changed when the lineup changed")
	_check(
		_same_lines(week_21_a[1], week_21_b[1]) and _same_lines(week_21_a[8], week_21_b[8]),
		"week 21 changed a match when the lineup changed"
	)
	var lash_week := _player_week_lines(SWEEP_SEED, 2, "lash")
	var eye_week := _player_week_lines(SWEEP_SEED, 2, "eye")
	_check(not _same_lines(lash_week, eye_week), "training did not change a later week's at-bats")
	var played = SeriesScript.new(SWEEP_SEED)
	_play_regular(played, true)
	var fin: Dictionary = played.begin_match(LINEUP, TACTIC, _script_focus(played, true))
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
	var again: Dictionary = played.begin_match(ALT_LINEUP, TACTIC, _script_focus(played, true))
	_check(not _same_lines(_explanations(fin), _explanations(again)), "a different final lineup repeated game 1")
	var restored: Dictionary = played.begin_match(LINEUP, TACTIC, _script_focus(played, true))
	_check(_same_lines(_explanations(fin), _explanations(restored)), "repeating the final lineup did not repeat game 1")
	played.commit_match()
	var second: Dictionary = played.begin_match(LINEUP, TACTIC, _script_focus(played, true))
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
		_explanations(others[4]),
		_explanations(others[5]),
		_explanations(others[6]),
		_explanations(others[7]),
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
		_explanations(others[4]),
		_explanations(others[5]),
		_explanations(others[6]),
		_explanations(others[7]),
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


func _play_regular(played, balance: bool = false) -> void:
	for week_index in Sport.SERIES_WEEKS:
		var focus := _script_focus(played, balance)
		var before_focus := _sum_stat(played.player_roster, focus)
		var room := _room_below_cap(played.player_roster, focus)
		var started: Dictionary = played.begin_match(LINEUP, TACTIC, focus)
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
			_check(others.size() == Sport.MATCHES_PER_WEEK - 1, "week %d did not record the other eight matches" % (week_index + 1))
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
			_check(present.size() == Sport.CLUB_COUNT - 1, "week %d did not play the other eighteen clubs" % (week_index + 1))
		var committed: Dictionary = played.commit_match()
		_check(bool(committed.get("ok", false)), "week %d failed to record" % (week_index + 1))
		_check(not bool(committed.get("final", false)), "week %d was stored as a final game" % (week_index + 1))
		if balance:
			_check(
				_sum_stat(played.player_roster, focus) == before_focus + room,
				"week %d did not add 1 %s up to the cap" % [week_index + 1, focus]
			)


func _assert_schedule(played, label: String) -> void:
	var match_count := Sport.SERIES_WEEKS * Sport.MATCHES_PER_WEEK
	_check(played.results.size() == match_count, label + " did not play all three hundred forty-two matches")
	_check(int(played.week) == Sport.SERIES_WEEKS, label + " did not finish week 38")
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
	_check(player_games == Sport.GAMES_EACH, label + " did not give the player thirty-six matches")
	_check(bye_results == Sport.BYES_EACH, label + " did not mark both of the player's byes")
	_check(seen.has(Sport.NINETEENTH_CLUB), label + " left Lockfen Snipes off the schedule")
	_check(seen.has(Sport.EIGHTEENTH_CLUB), label + " left Wickfen Dunlins off the schedule")
	_check(seen.has(Sport.SEVENTEENTH_CLUB), label + " left Millfen Ruffs off the schedule")
	_check(seen.has(Sport.SIXTEENTH_CLUB), label + " left Quayfen Knots off the schedule")
	_check(seen.size() == Sport.CLUB_COUNT, label + " left a club out of the schedule")
	for count in played_count:
		_check(int(count) == Sport.GAMES_EACH, label + " did not give every club thirty-six games")
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
		_check(week_clubs.size() == Sport.CLUB_COUNT - 1, label + " week %d did not play eighteen clubs" % (week_index + 1))
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
	return _stat_list(roster, "eye")


func _stat_list(roster: Array, stat_name: String) -> Array:
	var values: Array = []
	for player in roster:
		values.append(Sport.get_stat(player, stat_name))
	return values


func _room_below_cap(roster: Array, stat_name: String) -> int:
	var room := 0
	for player in roster:
		if Sport.get_stat(player, stat_name) < Sport.STAT_CAP:
			room += 1
	return room


func _assert_plus(roster: Array, before: Array, stat_name: String, gain: int, message: String) -> void:
	for i in roster.size():
		_check(
			Sport.get_stat(roster[i], stat_name) == mini(int(before[i]) + gain, Sport.STAT_CAP),
			message
		)


func _play_final_game(played, home_index: int, outcome: String, player_score: int, opponent_score: int, balance: bool = false) -> Dictionary:
	var game_index: int = played.final_games.size()
	_check(played.final_home_index(game_index) == home_index, "final game %d home drifted" % (game_index + 1))
	var focus := _script_focus(played, balance)
	var before_focus := _sum_stat(played.player_roster, focus)
	var room := _room_below_cap(played.player_roster, focus)
	var started: Dictionary = played.begin_match(LINEUP, TACTIC, focus)
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
	if balance:
		_check(
			_sum_stat(played.player_roster, focus) == before_focus + room,
			"final game %d did not add 1 %s up to the cap" % [game_index + 1, focus]
		)
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
	_check(missed.is_over(), "scripted miss did not end after week 38")
	_check(missed.final_games.is_empty(), "scripted miss stored a final")
	_check(not missed.goal_met(), "missing the final met the goal")
	var miss_rows: Array = missed.table()
	var miss_order: Array = _ordered_indexes(miss_rows)
	_check(int(miss_order[0]) == 14 and int(miss_order[1]) == 4 and int(miss_order[2]) == 0, "the table did not place the player 3rd")
	_check(int(miss_rows[0]["points"]) == 39 and int(miss_rows[14]["points"]) == 46 and int(miss_rows[4]["points"]) == 40, "points per game did not place the player behind the top two")
	_check(int(miss_rows[0]["run_diff"]) == -9 and int(miss_rows[14]["run_diff"]) == 17 and int(miss_rows[4]["run_diff"]) == 14, "run difference did not keep the top two ahead")
	_check(int(miss_rows[0]["played"]) == Sport.GAMES_EACH, "a week was not recorded for Lumen Reedmice")
	var denied: Dictionary = missed.begin_match(LINEUP, TACTIC, FOCUS)
	_check(not bool(denied.get("ok", false)), "a match after a missed final was allowed")
	_assert_plus(missed.player_roster, missed_lash, "lash", Sport.SERIES_WEEKS, "thirty-eight weeks did not add 1 Lash up to the cap")
	for i in missed.player_roster.size():
		_check(Sport.get_stat(missed.player_roster[i], "eye") == int(missed_eye[i]), "lash training changed Eye")
	_check_opening_week()
	_check_outside_final(19765, 4)
	_check_outside_final(1744, 5)
	_check_outside_final(15065, 6)
	_check_outside_final(564, 7)
	_check_outside_final(674, 8)
	_check_outside_final(98, 9)
	_check_outside_final(2375, 10)
	_check_outside_final(807, 11)
	_check_outside_final(84, 12)
	_check_outside_final(75, 13)
	_check_outside_final(51, 14)
	_check_outside_final(20, 15)
	_check_outside_final(17, 16)
	_check_outside_final(0, 17)
	_check_outside_final(1, 18)
	_check_outside_final(2, 19)
	print("Scripted miss: finished 3rd, with later places also ending without a final")

	var sweep = SeriesScript.new(SWEEP_SEED)
	_play_regular(sweep, true)
	_assert_schedule(sweep, "winning final")
	_check(sweep.reached_final(), "winning script missed the final")
	_check(not sweep.is_over(), "winning script ended before the final")
	_check(sweep.place() == 1, "the winning script did not finish 1st")
	_check(int(sweep.finalist_indices()[0]) == Sport.PLAYER_INDEX, "Lumen Reedmice did not lead the league")
	_check(int(sweep.finalist_indices()[1]) == 10, "Ashwharf Swifts was not the second finalist")
	_play_final_game(sweep, Sport.PLAYER_INDEX, "loss", 2, 11, true)
	_check(not sweep.is_over(), "one loss ended the series")
	_check(int(sweep.series_win_counts()[Sport.PLAYER_INDEX]) == 0 and int(sweep.series_win_counts()[10]) == 1, "game 1 did not count as one loss")
	_check(str(sweep.final_games[0]["player_focus"]) == "read", "game 1 did not drill the lowest stat")
	_play_final_game(sweep, 10, "win", 7, 3, true)
	_check(not sweep.is_over(), "a 1-1 series did not reach game 3")
	_check(int(sweep.series_win_counts()[Sport.PLAYER_INDEX]) == 1 and int(sweep.series_win_counts()[10]) == 1, "the series was not 1-1")
	_check(str(sweep.final_games[1]["player_focus"]) == "legs", "game 2 did not drill the lowest stat")
	_play_final_game(sweep, Sport.PLAYER_INDEX, "win", 5, 1, true)
	_check(sweep.is_over(), "two wins did not end the series")
	_check(sweep.goal_met(), "winning the series missed the goal")
	_check(sweep.final_games.size() == 3, "the winning final stored the wrong number of games")
	_check(sweep.series_winner_index() == Sport.PLAYER_INDEX, "the series winner drifted")
	_check(int(sweep.series_win_counts()[Sport.PLAYER_INDEX]) == 2 and int(sweep.series_win_counts()[10]) == 1, "the series did not end 2-1")
	_check(str(sweep.final_games[2]["player_focus"]) == "glove", "game 3 did not drill the lowest stat")
	_check(_stats_in_range(sweep.rosters), "the winning series left a stat outside 1-20")
	var fixed = SeriesScript.new(SWEEP_SEED)
	_play_regular(fixed)
	_check(fixed.place() == 17, "a fixed Lash drill did not finish 17th")
	_check(not fixed.reached_final(), "a fixed Lash drill reached the final")
	_check(fixed.is_over() and not fixed.goal_met(), "a fixed Lash drill won the series")
	_check(fixed.final_games.is_empty(), "a fixed Lash drill stored a final")
	var former = SeriesScript.new(309)
	_play_regular(former, true)
	_check(former.place() == 10, "seed 309 did not finish 10th")
	_check(not former.reached_final(), "seed 309 reached the final")
	_check(former.is_over() and former.final_games.is_empty(), "seed 309 played a final")
	_check(int(former.table()[0]["points"]) == 36 and int(former.table()[0]["run_diff"]) == 9, "seed 309 table drifted")
	var former_order: Array = Sport.sorted_table(former.table())
	_check(str(former_order[0]["club"]) == "Millfen Ruffs" and str(former_order[1]["club"]) == "Cinderwharf Pikes", "seed 309 leaders drifted")
	print("Scripted final: beat Ashwharf Swifts 2-1 after 2-11, 7-3, and 5-1")

	var third = SeriesScript.new(THIRD_SEED)
	_play_regular(third, true)
	_assert_schedule(third, "third game")
	_check(third.reached_final(), "split series missed the final")
	_check(third.place() == 1, "split series did not finish 1st")
	_check(int(third.finalist_indices()[0]) == Sport.PLAYER_INDEX, "game 1 home was not the club ahead")
	_check(int(third.finalist_indices()[1]) == 3, "game 3 opponent was not Marrowgate Herons")
	_play_final_game(third, Sport.PLAYER_INDEX, "win", 2, 1, true)
	_check(not third.is_over(), "game 1 closed a split series")
	_play_final_game(third, 3, "loss", 4, 6, true)
	_check(not third.is_over(), "a 1-1 series did not reach game 3")
	_check(int(third.series_win_counts()[0]) == 1 and int(third.series_win_counts()[3]) == 1, "the split was not 1-1")
	_play_final_game(third, Sport.PLAYER_INDEX, "loss", 2, 3, true)
	_check(third.is_over() and not third.goal_met(), "losing game 3 did not end the series")
	_check(third.series_winner_index() == 3, "the series winner was not Marrowgate Herons")
	_check(third.final_games.size() == 3, "the split series did not play three games")
	_check(str(third.final_games[0]["player_focus"]) == "glove", "game 1 did not drill the lowest stat")
	_check(str(third.final_games[1]["player_focus"]) == "arm", "game 2 did not drill the lowest stat")
	_check(str(third.final_games[2]["player_focus"]) == "lash", "game 3 did not drill the lowest stat")
	_check(third.results.size() == Sport.SERIES_WEEKS * Sport.MATCHES_PER_WEEK, "game 3 changed the table length")
	print("Scripted final: reached game 3 at 1-1, then lost 2-3")

	var tied = SeriesScript.new(TIE_SEED)
	_play_regular(tied, true)
	_assert_schedule(tied, "tied final game")
	_check(tied.reached_final(), "tie script missed the final")
	_check(tied.place() == 2, "the tie script did not finish 2nd")
	_check(int(tied.finalist_indices()[0]) == 4, "Saltmere Kites did not lead the tie script")
	_check(int(tied.finalist_indices()[1]) == Sport.PLAYER_INDEX, "the tie script was not the second finalist")
	var tied_before: Array = tied.series_win_counts()
	_play_final_game(tied, 4, "tie", 5, 5, true)
	_check(not tied.is_over(), "a tied final game ended the series")
	_check(_same_indexes(tied_before, tied.series_win_counts()), "a tie counted as a win")
	_check(str(tied.final_games[0]["winner"]) == "tie", "the tied game was stored as a win")
	_check(str(tied.final_games[0]["player_focus"]) == "eye", "the tied final did not drill the lowest stat")
	_play_final_game(tied, Sport.PLAYER_INDEX, "win", 11, 9, true)
	_check(not tied.is_over(), "one win ended the series")
	_check(int(tied.series_win_counts()[Sport.PLAYER_INDEX]) == 1 and int(tied.series_win_counts()[4]) == 0, "game 2 did not count as one win")
	_play_final_game(tied, 4, "tie", 3, 3, true)
	_check(not tied.is_over(), "a later tie ended the series")
	_check(int(tied.series_win_counts()[Sport.PLAYER_INDEX]) == 1 and int(tied.series_win_counts()[4]) == 0, "a later tie counted as a win")
	_check(str(tied.final_games[2]["player_focus"]) == "read", "game 3 did not drill the lowest stat")
	_play_final_game(tied, Sport.PLAYER_INDEX, "loss", 4, 7, true)
	_check(not tied.is_over(), "a 1-1 series ended before two wins")
	_check(int(tied.series_win_counts()[Sport.PLAYER_INDEX]) == 1 and int(tied.series_win_counts()[4]) == 1, "the series was not 1-1")
	_play_final_game(tied, 4, "win", 6, 1, true)
	_check(tied.is_over() and tied.goal_met(), "the games after a tie did not decide the series")
	_check(int(tied.series_win_counts()[Sport.PLAYER_INDEX]) == 2, "the tie gave the series the wrong win total")
	_check(int(tied.series_win_counts()[4]) == 1, "the tie counted as a win for Saltmere Kites")
	_check(tied.series_winner_index() == Sport.PLAYER_INDEX, "the series winner was not Lumen Reedmice")
	_check(tied.final_games.size() == 5, "the ties did not keep the series open")
	print("Scripted final: game 1 tied 5-5 and the series continued")

	var lost = SeriesScript.new(LOSS_SEED)
	_play_regular(lost, true)
	_assert_schedule(lost, "lost series")
	_check(lost.reached_final(), "loss script missed the final")
	_check(lost.place() == 1, "loss script did not finish 1st")
	_check(int(lost.finalist_indices()[0]) == Sport.PLAYER_INDEX, "Lumen Reedmice did not lead the loss script")
	_check(int(lost.finalist_indices()[1]) == 12, "Southfen Coots were not the second finalist")
	_play_final_game(lost, Sport.PLAYER_INDEX, "loss", 2, 4, true)
	_check(not lost.is_over(), "one loss ended the series")
	_check(int(lost.series_win_counts()[0]) == 0 and int(lost.series_win_counts()[12]) == 1, "game 1 did not count as one loss")
	_check(str(lost.final_games[0]["player_focus"]) == "legs", "game 1 of the lost series did not drill the lowest stat")
	_play_final_game(lost, 12, "loss", 4, 5, true)
	_check(lost.is_over(), "two wins for the other club did not end the series")
	_check(not lost.goal_met(), "losing the series met the goal")
	_check(lost.series_winner_index() == 12, "the series winner was not Southfen Coots")
	_check(lost.final_games.size() == 2, "the lost series did not stop at two wins")
	_check(str(lost.final_games[1]["player_focus"]) == "glove", "game 2 of the lost series did not drill the lowest stat")
	_check(lost.results.size() == Sport.SERIES_WEEKS * Sport.MATCHES_PER_WEEK, "a lost series changed the table")
	print("Scripted final: lost the series in two games, 2-4 then 4-5")


func _roster_total(roster: Array) -> int:
	var total := 0
	for player in roster:
		for key in Sport.STATS:
			total += Sport.get_stat(player, key)
	return total


func _check_opening_week() -> void:
	var probe = SeriesScript.new(3)
	var coot_total := _roster_total(probe.rosters[12])
	var tern_total := _roster_total(probe.rosters[11])
	var grebe_total := _roster_total(probe.rosters[13])
	var curlew_total := _roster_total(probe.rosters[14])
	var knot_total := _roster_total(probe.rosters[15])
	var ruff_total := _roster_total(probe.rosters[16])
	var dunlin_total := _roster_total(probe.rosters[17])
	var snipe_total := _roster_total(probe.rosters[18])
	var player_before := _lash_list(probe.player_roster)
	var first: Dictionary = probe.begin_match(LINEUP, TACTIC, FOCUS)
	_check(bool(first.get("ok", false)), "week 1 did not start")
	_check(bool(first.get("player_played", false)), "week 1 left Lumen Reedmice off the field")
	_check(str(first.get("opponent_club", "")) == Sport.TWELFTH_CLUB, "week 1 opponent was not Pellfen Terns")
	_check((first["other_matches"] as Array).size() == 8, "week 1 did not record the other eight matches")
	_check(int(first.get("bye_index", -1)) == 18, "week 1 did not give Lockfen Snipes the bye")
	_check(str(first.get("bye_club", "")) == Sport.NINETEENTH_CLUB, "week 1 bye club drifted")
	var found_grebes := false
	var found_knots := false
	var found_dunlins := false
	for raw_other in first["other_matches"]:
		var other: Dictionary = raw_other
		if int(other["home_index"]) == 12 and int(other["away_index"]) == 13:
			found_grebes = true
		if int(other["home_index"]) == 14 and int(other["away_index"]) == 15:
			found_knots = true
		if int(other["home_index"]) == 16 and int(other["away_index"]) == 17:
			found_dunlins = true
	_check(found_grebes, "week 1 did not record Southfen Coots against Tidefen Grebes")
	_check(found_knots, "week 1 did not record Brinefen Curlews against Quayfen Knots")
	_check(found_dunlins, "week 1 did not record Millfen Ruffs against Wickfen Dunlins")
	probe.commit_match()
	_check(_roster_total(probe.rosters[12]) == coot_total + Sport.ROSTER_SIZE, "week 1 did not drill Southfen Coots")
	_check(_roster_total(probe.rosters[11]) == tern_total + Sport.ROSTER_SIZE, "week 1 did not drill Pellfen Terns")
	_check(_roster_total(probe.rosters[13]) == grebe_total + Sport.ROSTER_SIZE, "week 1 did not drill Tidefen Grebes")
	_check(_roster_total(probe.rosters[14]) == curlew_total + Sport.ROSTER_SIZE, "week 1 did not drill Brinefen Curlews")
	_check(_roster_total(probe.rosters[15]) == knot_total + Sport.ROSTER_SIZE, "week 1 did not drill Quayfen Knots")
	_check(_roster_total(probe.rosters[16]) == ruff_total + Sport.ROSTER_SIZE, "week 1 did not drill Millfen Ruffs")
	_check(_roster_total(probe.rosters[17]) == dunlin_total + Sport.ROSTER_SIZE, "week 1 did not drill Wickfen Dunlins")
	_check(_roster_total(probe.rosters[18]) == snipe_total + Sport.ROSTER_SIZE, "week 1 did not drill Lockfen Snipes")
	_check(int(probe.table()[16]["played"]) == 1, "week 1 did not record a match for Millfen Ruffs")
	_check(int(probe.table()[17]["played"]) == 1, "week 1 did not record a match for Wickfen Dunlins")
	_check(int(probe.table()[18]["played"]) == 0, "week 1 recorded a match for Lockfen Snipes")
	_check(int(probe.table()[12]["played"]) == 1, "week 1 did not record a match for Southfen Coots")
	_check(int(probe.table()[13]["played"]) == 1, "week 1 did not record a match for Tidefen Grebes")
	_check(int(probe.table()[14]["played"]) == 1, "week 1 did not record a match for Brinefen Curlews")
	_check(int(probe.table()[15]["played"]) == 1, "week 1 did not record a match for Quayfen Knots")
	_check(int(probe.table()[11]["played"]) == 1, "week 1 did not record a match for Pellfen Terns")
	_check(int(probe.table()[Sport.PLAYER_INDEX]["played"]) == 1, "week 1 did not record a match for Lumen Reedmice")
	_assert_plus(probe.player_roster, player_before, "lash", 1, "week 1 did not add 1 Lash")
	var lash_after := _lash_list(probe.player_roster)
	var second: Dictionary = probe.begin_match(LINEUP, TACTIC, FOCUS)
	_check(not bool(second.get("player_played", false)), "week 2 put Lumen Reedmice on the field")
	_check(str(second.get("player_result", "")) == "bye", "week 2 was not a bye for Lumen Reedmice")
	_check(int(second.get("bye_index", -1)) == Sport.PLAYER_INDEX, "week 2 did not record Lumen Reedmice's bye")
	_check(int(second["home_index"]) == 1 and int(second["away_index"]) == 18, "week 2 did not follow Southspur Glass against Lockfen Snipes")
	_check((second["other_matches"] as Array).size() == 8, "week 2 did not record the other eight matches")
	var involved := {}
	involved[int(second["home_index"])] = true
	involved[int(second["away_index"])] = true
	for raw_other in second["other_matches"]:
		var week_other: Dictionary = raw_other
		involved[int(week_other["home_index"])] = true
		involved[int(week_other["away_index"])] = true
	_check(not involved.has(Sport.PLAYER_INDEX), "week 2 stored a match for Lumen Reedmice")
	_check(involved.size() == Sport.CLUB_COUNT - 1, "week 2 did not play the other eighteen clubs")
	probe.commit_match()
	_check(int(probe.table()[Sport.PLAYER_INDEX]["played"]) == 1, "week 2 recorded a match for Lumen Reedmice")
	_assert_plus(probe.player_roster, lash_after, "lash", 1, "week 2 did not add 1 Lash")


func _check_outside_final(series_seed: int, expected_place: int) -> void:
	var played = SeriesScript.new(series_seed)
	_play_regular(played)
	_check(played.place() == expected_place, "seed %d did not finish outside the top two" % series_seed)
	_check(not played.reached_final(), "seed %d reached the final from outside the top two" % series_seed)
	_check(played.is_over(), "seed %d did not end after week 38" % series_seed)
	_check(played.final_games.is_empty(), "seed %d stored a final" % series_seed)
	_check(int(played.table()[Sport.PLAYER_INDEX]["played"]) == Sport.GAMES_EACH, "seed %d did not play thirty-six games" % series_seed)


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
	var twelfth_lash := _sum_stat(sample["rosters"][11], "lash")
	var thirteenth_lash := _sum_stat(sample["rosters"][12], "lash")
	var fourteenth_lash := _sum_stat(sample["rosters"][13], "lash")
	var fifteenth_lash := _sum_stat(sample["rosters"][14], "lash")
	var sixteenth_lash := _sum_stat(sample["rosters"][15], "lash")
	var seventeenth_lash := _sum_stat(sample["rosters"][16], "lash")
	var eighteenth_lash := _sum_stat(sample["rosters"][17], "lash")
	var nineteenth_lash := _sum_stat(sample["rosters"][18], "lash")
	var player_lash := _sum_stat(sample["rosters"][0], "lash")
	Sport.apply_training(sample["rosters"][0], "lash")
	_check(_sum_stat(sample["rosters"][0], "lash") == player_lash + Sport.ROSTER_SIZE, "training did not add 1 to each Lumen Reedmice player")
	_check(_sum_stat(sample["rosters"][5], "lash") == sixth_lash, "training the player changed Ashfen Moths")
	_check(_sum_stat(sample["rosters"][8], "lash") == ninth_lash, "training the player changed Saltwharf Gulls")
	_check(_sum_stat(sample["rosters"][9], "lash") == tenth_lash, "training the player changed Marrowfen Owls")
	_check(_sum_stat(sample["rosters"][10], "lash") == eleventh_lash, "training the player changed Ashwharf Swifts")
	_check(_sum_stat(sample["rosters"][11], "lash") == twelfth_lash, "training the player changed Pellfen Terns")
	_check(_sum_stat(sample["rosters"][12], "lash") == thirteenth_lash, "training the player changed Southfen Coots")
	_check(_sum_stat(sample["rosters"][13], "lash") == fourteenth_lash, "training the player changed Tidefen Grebes")
	_check(_sum_stat(sample["rosters"][14], "lash") == fifteenth_lash, "training the player changed Brinefen Curlews")
	_check(_sum_stat(sample["rosters"][15], "lash") == sixteenth_lash, "training the player changed Quayfen Knots")
	_check(_sum_stat(sample["rosters"][16], "lash") == seventeenth_lash, "training the player changed Millfen Ruffs")
	_check(_sum_stat(sample["rosters"][17], "lash") == eighteenth_lash, "training the player changed Wickfen Dunlins")
	_check(_sum_stat(sample["rosters"][18], "lash") == nineteenth_lash, "training the player changed Lockfen Snipes")
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


func _collect_buttons(node: Node, buttons: Array) -> void:
	if node is Button:
		buttons.append(node)
	for child in node.get_children():
		_collect_buttons(child, buttons)


func _eighth_overlaps_control(game, row: Rect2) -> bool:
	var buttons: Array = []
	_collect_buttons(game.office_panel, buttons)
	for raw in buttons:
		var button: Control = raw
		if not button.visible:
			continue
		if row.intersects(button.get_global_rect()):
			return true
	return false


func _check_week_rows_fit(game) -> void:
	var label: Label = game.schedule_label
	_check(not label.clip_text, "the schedule clips a match")
	var window_width := int(ProjectSettings.get_setting("display/window/size/viewport_width"))
	var window_height := int(ProjectSettings.get_setting("display/window/size/viewport_height"))
	_check(window_width == 1280 and window_height == 720, "the window is not 1280 by 720")
	var lines := str(label.text).split("\n")
	_check(lines.size() >= 10, "week 1 does not list nine matches and a bye")
	var index := 0
	var eighth_bottom := 0.0
	var eighth_rect := Rect2()
	for i in 8:
		var line := str(lines[i])
		var start := index
		var end := index + line.length() - 1
		var first: Rect2 = label.get_character_bounds(start)
		var last: Rect2 = label.get_character_bounds(end)
		_check(first.size.y > 0.0 and last.size.y > 0.0, "week 1 row %d has no glyphs" % (i + 1))
		_check(is_equal_approx(first.position.y, last.position.y), "week 1 row %d wrapped off the schedule" % (i + 1))
		_check(last.position.x + last.size.x <= label.size.x + 1.0, "week 1 row %d is clipped by the schedule" % (i + 1))
		var global_first: Rect2 = label.get_global_transform() * first
		var global_last: Rect2 = label.get_global_transform() * last
		var bottom := global_last.position.y + global_last.size.y
		var right := global_last.position.x + global_last.size.x
		_check(bottom <= float(window_height) and global_last.position.y >= 0.0, "week 1 row %d ends at %s and does not fit the %d window" % [i + 1, bottom, window_height])
		_check(right <= float(window_width) and global_last.position.x >= 0.0, "week 1 row %d runs off the window" % (i + 1))
		if i == 6:
			_check(line.contains("Southfen Coots vs Tidefen Grebes"), "the seventh match is not on its own line")
			_check(not line.contains("Quayfen Knots"), "the eighth match was pushed onto the seventh line")
			_check(not line.contains("Wickfen Dunlins"), "the ninth match was pushed onto the seventh line")
		if i == 7:
			_check(line.contains("Brinefen Curlews vs Quayfen Knots"), "the eighth match is not on its own line")
			_check(not line.contains("Wickfen Dunlins"), "the ninth match was pushed onto the eighth line")
			eighth_bottom = bottom
			eighth_rect = Rect2(global_first.position, Vector2(global_last.end.x - global_first.position.x, bottom - global_first.position.y))
		index += line.length() + 1
	_check(eighth_bottom > 0.0, "the eighth match has no glyph bounds")
	_check(not _eighth_overlaps_control(game, eighth_rect), "the eighth match overlaps a control")
	var ninth_line := str(lines[8])
	var ninth_last: Rect2 = label.get_character_bounds(index + ninth_line.length() - 1)
	var ninth_first: Rect2 = label.get_character_bounds(index)
	_check(ninth_first.size.y > 0.0 and ninth_last.size.y > 0.0, "the ninth match has no glyphs")
	_check(is_equal_approx(ninth_first.position.y, ninth_last.position.y), "the ninth match wrapped")
	_check(ninth_line.ends_with("Millfen Ruffs vs Wickfen Dunlins"), "the ninth match is not Millfen Ruffs vs Wickfen Dunlins")
	_check(not ninth_line.contains("bye"), "week 1 still lists a bye")
	var ninth_global: Rect2 = label.get_global_transform() * ninth_last
	var ninth_bottom := ninth_global.position.y + ninth_global.size.y
	var ninth_right := ninth_global.position.x + ninth_global.size.x
	var ninth_rect := Rect2((label.get_global_transform() * ninth_first).position, Vector2(ninth_global.end.x - (label.get_global_transform() * ninth_first).position.x, ninth_bottom - (label.get_global_transform() * ninth_first).position.y))
	_check(ninth_bottom > eighth_bottom, "the ninth match is not below the eighth match")
	_check(ninth_bottom <= float(window_height), "the ninth match ends at %s and does not fit the %d window" % [ninth_bottom, window_height])
	_check(ninth_right <= float(window_width) and ninth_global.position.x >= 0.0, "the ninth match runs off the window")
	_check(not _eighth_overlaps_control(game, ninth_rect), "the ninth match overlaps a control")
	index += ninth_line.length() + 1
	var bye_line := str(lines[9])
	var bye_last: Rect2 = label.get_character_bounds(index + bye_line.length() - 1)
	var bye_first: Rect2 = label.get_character_bounds(index)
	_check(bye_first.size.y > 0.0 and bye_last.size.y > 0.0, "the bye row has no glyphs")
	_check(is_equal_approx(bye_first.position.y, bye_last.position.y), "the bye row wrapped")
	_check(bye_line.ends_with("Lockfen Snipes bye"), "the bye row is not Lockfen Snipes")
	var bye_global: Rect2 = label.get_global_transform() * bye_last
	var bye_bottom := bye_global.position.y + bye_global.size.y
	var bye_right := bye_global.position.x + bye_global.size.x
	var bye_rect := Rect2((label.get_global_transform() * bye_first).position, Vector2(bye_global.end.x - (label.get_global_transform() * bye_first).position.x, bye_bottom - (label.get_global_transform() * bye_first).position.y))
	_check(bye_bottom > ninth_bottom, "the bye row is not below the ninth match")
	_check(bye_bottom <= float(window_height), "the bye row ends at %s and does not fit the %d window" % [bye_bottom, window_height])
	_check(bye_right <= float(window_width) and bye_global.position.x >= 0.0, "the bye row runs off the window")
	_check(not _eighth_overlaps_control(game, bye_rect), "the bye row overlaps a control")


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
	_check(str(game.shape_label.text).contains("nine matches"), where + " does not say each week has nine matches")
	_check(str(game.shape_label.text).contains("one bye"), where + " does not say each week has one bye")
	_check(str(game.shape_label.text).contains("two byes"), where + " does not say every club has two byes")
	_check(not str(game.shape_label.text).contains("no bye"), where + " still says there is no bye")
	_check(not str(game.shape_label.text).contains("zero byes"), where + " still says zero byes")
	_check(not str(game.shape_label.text).contains("eight matches"), where + " still says eight matches")
	_check(not str(game.shape_label.text).contains("seven matches"), where + " still says seven matches")
	_check(not str(game.shape_label.text).contains("six matches"), where + " still says six matches")
	var schedule := str(game.schedule_label.text)
	for club_name in Sport.CLUB_NAMES:
		_check(schedule.contains(str(club_name)), where + " schedule is missing " + str(club_name))
	for week_no in Sport.SERIES_WEEKS:
		_check(schedule.contains("Week %d" % (week_no + 1)), where + " schedule is missing week %d" % (week_no + 1))
	_check(schedule.contains(Sport.TWELFTH_CLUB), where + " schedule is missing Pellfen Terns")
	_check(schedule.contains(Sport.THIRTEENTH_CLUB), where + " schedule is missing Southfen Coots")
	_check(schedule.contains(Sport.FOURTEENTH_CLUB), where + " schedule is missing Tidefen Grebes")
	_check(schedule.contains(Sport.FIFTEENTH_CLUB), where + " schedule is missing Brinefen Curlews")
	_check(schedule.contains(Sport.SIXTEENTH_CLUB), where + " schedule is missing Quayfen Knots")
	_check(schedule.contains(Sport.SEVENTEENTH_CLUB), where + " schedule is missing Millfen Ruffs")
	_check(schedule.contains(Sport.EIGHTEENTH_CLUB), where + " schedule is missing Wickfen Dunlins")
	_check(schedule.contains(Sport.NINETEENTH_CLUB), where + " schedule is missing Lockfen Snipes")
	_check(_count_outcome_token(schedule, " bye") == Sport.SERIES_WEEKS, where + " does not list one bye a week")
	_check(_count_outcome_token(schedule, "Lumen Reedmice bye") == Sport.BYES_EACH, where + " does not give Lumen Reedmice two byes")
	if int(game.series.week) == 0:
		_check(schedule.contains("Lumen Reedmice vs Pellfen Terns"), where + " is missing the week 1 match")
		_check(schedule.contains("Southspur Glass vs Ashwharf Swifts"), where + " is missing the second week 1 match")
		_check(schedule.contains("Pellwick Cinders vs Marrowfen Owls"), where + " is missing the third week 1 match")
		_check(schedule.contains("Marrowgate Herons vs Saltwharf Gulls"), where + " is missing the fourth week 1 match")
		_check(schedule.contains("Saltmere Kites vs Cinderwharf Pikes"), where + " is missing the fifth week 1 match")
		_check(schedule.contains("Ashfen Moths vs Reedfen Larks"), where + " is missing the sixth week 1 match")
		_check(schedule.contains("Southfen Coots vs Tidefen Grebes"), where + " is missing Southfen Coots against Tidefen Grebes")
		_check(schedule.contains("Brinefen Curlews vs Quayfen Knots"), where + " is missing Brinefen Curlews against Quayfen Knots")
		_check(schedule.contains("Millfen Ruffs vs Wickfen Dunlins"), where + " is missing Millfen Ruffs against Wickfen Dunlins")
		_check(schedule.contains("Lockfen Snipes bye"), where + " week 1 does not give Lockfen Snipes the bye")
		_check(schedule.contains("Pellfen Terns vs Lumen Reedmice"), where + " is missing the return match")
		_check(schedule.contains("Lumen Reedmice vs Southspur Glass"), where + " is missing a home match")
		_check(schedule.contains("Tidefen Grebes vs Lumen Reedmice"), where + " is missing the Tidefen return")
		_check(schedule.contains("Lumen Reedmice vs Quayfen Knots"), where + " is missing Lumen Reedmice at home to Quayfen Knots")
		_check(schedule.contains("Quayfen Knots vs Lumen Reedmice"), where + " is missing Quayfen Knots at home to Lumen Reedmice")
		_check(_count_outcome_token(schedule, " vs ") == Sport.SERIES_WEEKS * Sport.MATCHES_PER_WEEK, where + " does not list nine matches every week")
		_check_week_rows_fit(game)
	var standings := str(game.standings_label.text)
	for club_name in Sport.CLUB_NAMES:
		_check(standings.contains(str(club_name)), where + " standings are missing " + str(club_name))
	_check(standings.contains(Sport.TIE_RULE), where + " standings are missing the tie rule")
	_check(standings.contains("run diff"), where + " standings are missing run difference")
	_check(
		standings.contains("Series seed order: %s." % Sport.seed_order_names(int(game.series.seed))),
		where + " standings are missing the series seed order"
	)


func _skip_regular(game, balance: bool = false) -> void:
	for week in Sport.SERIES_WEEKS:
		if balance:
			game.training = _lowest_focus(game.series.player_roster)
		_check(game.phase == "office", "week %d did not return to the office" % (week + 1))
		_check(int(game.series.week) == week, "office week counter is not %d" % (week + 1))
		_check(str(game.schedule_label.text).contains(Sport.THIRTEENTH_CLUB), "Southfen Coots left the office")
		_check(str(game.schedule_label.text).contains(Sport.FOURTEENTH_CLUB), "Tidefen Grebes left the office")
		_check(str(game.schedule_label.text).contains(Sport.FIFTEENTH_CLUB), "Brinefen Curlews left the office")
		_check(str(game.schedule_label.text).contains(Sport.SIXTEENTH_CLUB), "Quayfen Knots left the office")
		_check(str(game.schedule_label.text).contains(Sport.SEVENTEENTH_CLUB), "Millfen Ruffs left the office")
		_check(str(game.schedule_label.text).contains(Sport.NINETEENTH_CLUB), "Lockfen Snipes left the office")
		_check(_count_outcome_token(str(game.schedule_label.text), " bye") == Sport.SERIES_WEEKS, "week %d does not list one bye a week" % (week + 1))
		_check(_count_outcome_token(str(game.schedule_label.text), "Lumen Reedmice bye") == Sport.BYES_EACH, "Lumen Reedmice do not have two byes on the schedule")
		var bye_week: bool = not game.series.player_plays()
		_check(_count_outcome_token(str(game.opponent_label.text), "Other match:") == 8, "week %d did not list the other eight matches" % (week + 1))
		if bye_week:
			_check(str(game.record_label.text).contains("Bye week."), "week %d does not say it is a bye" % (week + 1))
			_check(str(game.fixture_title.text) == "Bye week", "week %d title is not a bye" % (week + 1))
			_check(str(game.opponent_label.text).contains("No match is recorded for"), "week %d does not name the club that is off" % (week + 1))
		else:
			_check(str(game.record_label.text).contains("You bat"), "week %d does not say which side bats" % (week + 1))
			_check(str(game.fixture_title.text) != "Bye week", "week %d title is a bye" % (week + 1))
		game.skip_button.pressed.emit()
		_check(game.phase == "result", "skip did not reach the result in week %d" % (week + 1))
		_check(game.watch_log.size() == Sport.PAS_PER_MATCH, "skip log length in week %d" % (week + 1))
		_check(_count_outcome_token(str(game.result_label.text), "Other match:") == 8, "the other eight matches were not shown in week %d" % (week + 1))
		if bye_week:
			_check(str(game.result_label.text).begins_with("Bye."), "week %d result is not a bye" % (week + 1))
			_check(str(game.result_label.text).contains("No match is recorded for"), "week %d result does not name the club that is off" % (week + 1))
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
	var focus_before := str(game.training)
	game._unhandled_input(_key(KEY_Y))
	_check(str(game.training) != focus_before, "Y did not change the final training focus")
	game.training_buttons[Sport.STATS.find(focus_before)].pressed.emit()
	_check(str(game.training) == focus_before, "the training button did not restore the final focus")


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
	_check(str(game.week_label.text) == "Week 1 of 38", "office does not open on a thirty-eight-week series")
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
	_check(game.series.results.size() == Sport.SERIES_WEEKS * Sport.MATCHES_PER_WEEK, "the miss did not store three hundred forty-two matches")
	_check(int(game.series.week) == 38, "the miss did not finish week 38")
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
	_check(board_text.contains("Week 38:"), "week 38 was not played")
	_check(not board_text.contains("Week 39:"), "an extra week was played")
	_check(board_text.contains(Sport.SIXTH_CLUB), "Ashfen Moths did not reach the board")
	_check(board_text.contains(Sport.ELEVENTH_CLUB), "Ashwharf Swifts did not reach the board")
	_check(board_text.contains(Sport.TWELFTH_CLUB), "Pellfen Terns did not reach the board")
	_check(board_text.contains(Sport.THIRTEENTH_CLUB), "Southfen Coots did not reach the board")
	_check(board_text.contains(Sport.FOURTEENTH_CLUB), "Tidefen Grebes did not reach the board")
	_check(board_text.contains(Sport.FIFTEENTH_CLUB), "Brinefen Curlews did not reach the board")
	_check(board_text.contains(Sport.SIXTEENTH_CLUB), "Quayfen Knots did not reach the board")
	_check(board_text.contains(Sport.SEVENTEENTH_CLUB), "Millfen Ruffs did not reach the board")
	_check(board_text.contains(Sport.EIGHTEENTH_CLUB), "Wickfen Dunlins did not reach the board")
	_check(board_text.contains(Sport.NINETEENTH_CLUB), "Lockfen Snipes did not reach the board")
	_check(_count_outcome_token(board_text, "You had the bye.") == Sport.BYES_EACH, "the board does not list both byes")
	_check(board_text.contains("Brinefen Curlews at home and Saltmere Kites away."), "the clubs ahead were not named")
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
	_check_office(game, "series final")
	_skip_regular(game, true)
	_check(game.phase == "office", "reaching the final skipped the final office")
	_check(game.series.in_final(), "winning script did not open the final")
	_check(str(game.fixture_title.text) == "Final game 1: Ashwharf Swifts", "final game 1 opponent was not shown")
	_check(str(game.record_label.text).contains("You bat second."), "the club ahead did not bat second on screen")
	_check(str(game.schedule_label.text).contains("> Final game 1   Lumen Reedmice vs Ashwharf Swifts"), "game 1 did not list Lumen Reedmice at home")
	var sweep_table := _snapshot(game.series)
	game.training = _lowest_focus(game.series.player_roster)
	await _watch_skip_final(game)
	_check(str(game.current_match["player_result"]) == "loss", "watched final game 1 was not a loss")
	_check(str(game.result_label.text).contains("The series continues to game 2."), "game 1 did not say the series continues")
	_check(str(game.result_label.text).contains("Neither club has two wins."), "game 1 does not say the series is still open")
	_check(str(game.result_label.text).contains("Ashwharf Swifts will be home and bat second."), "game 2 home was not named")
	game.continue_button.pressed.emit()
	_check(game.phase == "office", "game 1 sent the series to the board")
	_check(str(game.week_label.text) == "Final game 2", "the office did not open game 2")
	_check(str(game.record_label.text).contains("Series 0-1."), "game 1 did not count as one loss")
	_check(str(game.record_label.text).contains("You bat first."), "game 2 did not send the club ahead on the road")
	_check(str(game.schedule_label.text).contains("> Final game 2   Ashwharf Swifts vs Lumen Reedmice"), "game 2 did not list Ashwharf Swifts at home")
	_check(_same_snapshot(sweep_table, _snapshot(game.series)), "game 1 changed the table")
	game.training = _lowest_focus(game.series.player_roster)
	await _watch_skip_final(game)
	_check(str(game.current_match["player_result"]) == "win", "watched final game 2 was not a win")
	_check(str(game.result_label.text).contains("The series continues to game 3."), "game 2 did not continue the series")
	_check(str(game.result_label.text).contains("Lumen Reedmice will be home and bat second."), "game 3 home was not Lumen Reedmice")
	game.continue_button.pressed.emit()
	_check(str(game.week_label.text) == "Final game 3", "the office did not open game 3")
	_check(str(game.record_label.text).contains("Series 1-1."), "game 2 did not level the series")
	_check(str(game.record_label.text).contains("You bat second."), "game 3 did not give the club ahead the odd game at home")
	_check(_same_snapshot(sweep_table, _snapshot(game.series)), "game 2 changed the table")
	game.training = _lowest_focus(game.series.player_roster)
	var glove_before: Array = _stat_list(game.series.player_roster, "glove")
	await _watch_skip_final(game)
	_check(str(game.result_label.text).contains("Lumen Reedmice won the series, 2 wins to 1 win."), "game 3 did not award the series")
	game.continue_button.pressed.emit()
	_check(game.phase == "board", "winning the series did not reach the board")
	var win_board := str(game.board_label.text)
	_check(win_board.contains("Result: MET"), "winning the series should be MET")
	_check(not win_board.contains("Result: MISSED"), "goal text contradicts MET")
	_check(win_board.contains("reached the final and won the series, 2 wins to 1 win."), "board does not say the series was won")
	_check(win_board.contains("Final game 1:"), "board is missing final game 1")
	_check(win_board.contains("Final game 2:"), "board is missing final game 2")
	_check(win_board.contains("Final game 3:"), "board is missing final game 3")
	_check(not win_board.contains("Final game 4:"), "the board stored a fourth final game")
	_check(win_board.contains("The final does not change the table."), "board does not keep the table fixed")
	_check(win_board.contains("Week 38:"), "win board skipped week 38")
	_check(win_board.contains(Sport.SIXTH_CLUB), "Ashfen Moths left the win board")
	_check(win_board.contains(Sport.ELEVENTH_CLUB), "Ashwharf Swifts left the win board")
	_check(win_board.contains(Sport.TWELFTH_CLUB), "Pellfen Terns left the win board")
	_check(win_board.contains(Sport.THIRTEENTH_CLUB), "Southfen Coots left the win board")
	_check(win_board.contains(Sport.FOURTEENTH_CLUB), "Tidefen Grebes left the win board")
	_check(win_board.contains(Sport.FIFTEENTH_CLUB), "Brinefen Curlews left the win board")
	_check(win_board.contains(Sport.SIXTEENTH_CLUB), "Quayfen Knots left the win board")
	_check(win_board.contains(Sport.SEVENTEENTH_CLUB), "Millfen Ruffs left the win board")
	_check(win_board.contains(Sport.EIGHTEENTH_CLUB), "Wickfen Dunlins left the win board")
	_check(win_board.contains(Sport.NINETEENTH_CLUB), "Lockfen Snipes left the win board")
	_check(_count_outcome_token(win_board, "You had the bye.") == Sport.BYES_EACH, "the win board does not list both byes")
	_check(game.series.goal_met(), "the board goal was not met")
	_check(game.series.results.size() == Sport.SERIES_WEEKS * Sport.MATCHES_PER_WEEK, "the final was stored in the table")
	_check(game.series.final_games.size() == 3, "the board series did not play three games")
	_check(_stats_in_range(game.series.rosters), "the series left a stat outside 1-20")
	_assert_plus(game.series.player_roster, glove_before, "glove", 1, "game 3 training did not add 1 Glove")
	print("Scripted final from the office: lost game 1, then won games 2 and 3")

	game.start_new_series(TIE_SEED)
	_skip_regular(game, true)
	_check(game.series.in_final(), "tie script did not open the final")
	_check(str(game.fixture_title.text) == "Final game 1: Saltmere Kites", "tie script game 1 opponent was not shown")
	_check(str(game.record_label.text).contains("You bat first."), "game 1 did not send Lumen Reedmice on the road")
	game.training = _lowest_focus(game.series.player_roster)
	await _watch_skip_final(game)
	_check(str(game.current_match["winner"]) == "tie", "tie script game 1 was not a tie")
	_check(str(game.result_label.text).contains("A tie is not a win for either side."), "the result does not say a tie is not a win")
	_check(str(game.result_label.text).contains("The series continues to game 2."), "the result does not continue the series")
	_check(str(game.result_label.text).contains("Lumen Reedmice will be home and bat second."), "game 2 home was not Lumen Reedmice")
	game.continue_button.pressed.emit()
	_check(game.phase == "office", "a tie ended the season")
	_check(str(game.week_label.text) == "Final game 2", "the tie script skipped game 2")
	_check(str(game.goal_label.text).contains("Game 1 was a tie, so it was not a win for either side. The series continues."), "the office hid the tie")
	_check(str(game.record_label.text).contains("Series 0-0."), "the tie changed the series score")
	_check(str(game.record_label.text).contains("You bat second."), "game 2 did not give Lumen Reedmice the even game at home")
	game.training = _lowest_focus(game.series.player_roster)
	await _watch_skip_final(game)
	_check(str(game.current_match["player_result"]) == "win", "tie script game 2 drifted")
	_check(str(game.result_label.text).contains("The series continues to game 3."), "one win ended the series")
	_check(str(game.result_label.text).contains("Saltmere Kites will be home and bat second."), "game 3 home was not Saltmere Kites")
	game.continue_button.pressed.emit()
	_check(str(game.week_label.text) == "Final game 3", "the series did not open game 3")
	_check(str(game.record_label.text).contains("Series 1-0."), "game 2 did not count as one win")
	_check(str(game.record_label.text).contains("You bat first."), "game 3 did not send Lumen Reedmice on the road")
	game.training = _lowest_focus(game.series.player_roster)
	await _watch_skip_final(game)
	_check(str(game.current_match["winner"]) == "tie", "tie script game 3 was not a tie")
	_check(str(game.result_label.text).contains("A tie is not a win for either side."), "a later tie was treated as a win")
	_check(str(game.result_label.text).contains("The series continues to game 4."), "a later tie did not continue the series")
	_check(str(game.result_label.text).contains("Lumen Reedmice will be home and bat second."), "game 4 home was not Lumen Reedmice")
	game.continue_button.pressed.emit()
	_check(str(game.week_label.text) == "Final game 4", "the series did not open game 4")
	_check(str(game.record_label.text).contains("Series 1-0."), "game 3 counted the tie as a win")
	_check(str(game.record_label.text).contains("You bat second."), "game 4 did not give Lumen Reedmice the even game at home")
	game.training = _lowest_focus(game.series.player_roster)
	await _watch_skip_final(game)
	_check(str(game.current_match["player_result"]) == "loss", "tie script game 4 drifted")
	_check(str(game.result_label.text).contains("The series continues to game 5."), "a 1-1 series ended before two wins")
	_check(str(game.result_label.text).contains("Saltmere Kites will be home and bat second."), "game 5 home was not Saltmere Kites")
	game.continue_button.pressed.emit()
	_check(str(game.week_label.text) == "Final game 5", "the series did not open game 5")
	_check(str(game.record_label.text).contains("Series 1-1."), "game 4 did not level the series")
	_check(str(game.record_label.text).contains("You bat first."), "game 5 did not send Lumen Reedmice on the road")
	game.training = _lowest_focus(game.series.player_roster)
	await _watch_skip_final(game)
	_check(str(game.result_label.text).contains("Lumen Reedmice won the series, 2 wins to 1 win."), "the games after the ties did not decide the series")
	game.continue_button.pressed.emit()
	_check(game.phase == "board", "the series after a tie did not reach the board")
	_check(str(game.board_label.text).contains("Result: MET"), "winning after a tie should be MET")
	_check(str(game.board_label.text).contains("Game 1 was a tie."), "the board dropped the tie")
	_check(str(game.board_label.text).contains("Game 3 was a tie."), "the board dropped the later tie")
	_check(game.series.final_games.size() == 5, "the ties did not keep the series open")
	print("Scripted final from the office: ties continued the series")

	game.start_new_series(LOSS_SEED)
	_skip_regular(game, true)
	var loss_games := 0
	while game.phase == "office" and game.series.in_final() and loss_games < 8:
		game.training = _lowest_focus(game.series.player_roster)
		await _watch_skip_final(game)
		loss_games += 1
		var outcome := str(game.current_match.get("winner", ""))
		if outcome == "tie":
			_check(str(game.result_label.text).contains("A tie is not a win for either side."), "a later tie was treated as a win")
			_check(str(game.result_label.text).contains("The series continues"), "a later tie did not continue the series")
		game.continue_button.pressed.emit()
	_check(loss_games == 2, "the lost series did not stop at two wins")
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
