extends SceneTree

const Sport = preload("res://scripts/sport.gd")
const SeriesScript = preload("res://scripts/series.gd")

var _failures: Array = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_failures = []
	_test_names()
	_test_determinism()
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
		for roster_key in ["player_roster", "opponent_roster"]:
			for player in clubs[roster_key]:
				var full_name := str(player["player_name"])
				_check(Sport.is_generated_name(full_name), "name is not a syllable join: " + full_name)
				generated += 1
	_check(generated == 40 * Sport.ROSTER_SIZE * 2, "unexpected generated name count")
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


func _test_determinism() -> void:
	print("TEST determinism")
	var first_clubs := Sport.create_clubs(42)
	var second_clubs := Sport.create_clubs(42)
	_check(_same_players(first_clubs["player_roster"], second_clubs["player_roster"]), "player roster drifted")
	_check(_same_players(first_clubs["opponent_roster"], second_clubs["opponent_roster"]), "opponent roster drifted")
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
	_check(left_scores.size() == 4 and right_scores.size() == 4, "scripted series did not play four weeks")
	for i in left_scores.size():
		_check(int(left_scores[i][0]) == int(right_scores[i][0]), "series player score drifted in week %d" % i)
		_check(int(left_scores[i][1]) == int(right_scores[i][1]), "series opponent score drifted in week %d" % i)


func _scripted_scores(series_seed: int) -> Array:
	var played := SeriesScript.new(series_seed)
	var scores: Array = []
	for _week in Sport.SERIES_WEEKS:
		var match_result: Dictionary = played.begin_match([0, 1, 2, 3], "aggressive", "lash")
		scores.append([int(match_result["player_score"]), int(match_result["opponent_score"])])
		played.commit_match()
	return scores


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
	var wins := {Sport.PLAYER_CLUB: 0, Sport.OPPONENT_CLUB: 0}
	var ties := 0
	for series_index in 200:
		var clubs: Dictionary = Sport.create_clubs(1000 + series_index)
		var rng := RandomNumberGenerator.new()
		rng.seed = 5000 + series_index
		var player_roster: Array = clubs["player_roster"]
		var opponent_roster: Array = clubs["opponent_roster"]
		for week in 4:
			var player_line: Array = Sport.random_lineup(rng, player_roster.size())
			var opponent_line: Array = Sport.random_lineup(rng, opponent_roster.size())
			_check(Sport.is_legal_lineup(player_roster.size(), player_line), "illegal player lineup")
			_check(Sport.is_legal_lineup(opponent_roster.size(), opponent_line), "illegal opponent lineup")
			var player_tactic: String = Sport.TACTICS[rng.randi_range(0, Sport.TACTICS.size() - 1)]
			var opponent_tactic: String = Sport.TACTICS[rng.randi_range(0, Sport.TACTICS.size() - 1)]
			var player_focus: String = Sport.STATS[rng.randi_range(0, Sport.STATS.size() - 1)]
			var opponent_focus: String = Sport.STATS[rng.randi_range(0, Sport.STATS.size() - 1)]
			var result: Dictionary
			if week % 2 == 0:
				result = Sport.simulate_match(
					8000 + series_index * 10 + week,
					_lineup_of(player_roster, player_line),
					_lineup_of(opponent_roster, opponent_line),
					player_tactic,
					opponent_tactic,
					Sport.PLAYER_CLUB,
					Sport.OPPONENT_CLUB
				)
				if int(result["home_score"]) > int(result["away_score"]):
					wins[Sport.PLAYER_CLUB] = int(wins[Sport.PLAYER_CLUB]) + 1
				elif int(result["away_score"]) > int(result["home_score"]):
					wins[Sport.OPPONENT_CLUB] = int(wins[Sport.OPPONENT_CLUB]) + 1
				else:
					ties += 1
			else:
				result = Sport.simulate_match(
					8000 + series_index * 10 + week,
					_lineup_of(opponent_roster, opponent_line),
					_lineup_of(player_roster, player_line),
					opponent_tactic,
					player_tactic,
					Sport.OPPONENT_CLUB,
					Sport.PLAYER_CLUB
				)
				if int(result["home_score"]) > int(result["away_score"]):
					wins[Sport.OPPONENT_CLUB] = int(wins[Sport.OPPONENT_CLUB]) + 1
				elif int(result["away_score"]) > int(result["home_score"]):
					wins[Sport.PLAYER_CLUB] = int(wins[Sport.PLAYER_CLUB]) + 1
				else:
					ties += 1
			_check(_score_matches_runs(result), "score/runs mismatch in series %d week %d" % [series_index, week])
			for pa in result["plate_appearances"]:
				_check(_outcome_runs_ok(pa), "bad outcome runs")
				_check(str(pa["explanation"]).find("\n") < 0, "explanation contains a newline")
			Sport.apply_training(player_roster, player_focus)
			Sport.apply_training(opponent_roster, opponent_focus)
			for roster in [player_roster, opponent_roster]:
				for player in roster:
					_check(Sport.is_generated_name(str(player["player_name"])), "trained roster has a bad name")
					for key in Sport.STATS:
						var value := Sport.get_stat(player, key)
						if value < Sport.STAT_FLOOR or value > Sport.STAT_CAP:
							_check(false, "stat %s left the cap at %d" % [key, value])
	var player_wins := int(wins[Sport.PLAYER_CLUB])
	var opponent_wins := int(wins[Sport.OPPONENT_CLUB])
	print("Fairness over 200 series: %s wins %d, %s wins %d, ties %d" % [
		Sport.PLAYER_CLUB, player_wins, Sport.OPPONENT_CLUB, opponent_wins, ties,
	])
	_check(player_wins > 0, Sport.PLAYER_CLUB + " never won a match")
	_check(opponent_wins > 0, Sport.OPPONENT_CLUB + " never won a match")
	_check(player_wins >= 20, Sport.PLAYER_CLUB + " won too rarely to be able to win in general")
	_check(opponent_wins >= 20, Sport.OPPONENT_CLUB + " won too rarely to be able to win in general")

	var sample: Dictionary = Sport.create_clubs(3)
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

	game.start_new_series(42)
	await process_frame
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

	game.start_new_series(7)
	for week in 4:
		_check(game.phase == "office", "week %d did not return to the office" % week)
		game.skip_button.pressed.emit()
		_check(game.phase == "result", "skip did not reach the result in week %d" % week)
		_check(game.watch_log.size() == Sport.PAS_PER_MATCH, "skip log length in week %d" % week)
		game.continue_button.pressed.emit()
	_check(game.phase == "board", "four-week series did not reach the board")
	_check(game.board_panel.visible, "board screen is hidden")
	_check(not game.office_panel.visible, "office still visible on the board")
	_check(not game.match_panel.visible, "match still visible on the board")
	var board_text := str(game.board_label.text)
	_check(board_text.contains("Board goal"), "board screen is missing the goal")
	_check(board_text.contains("Result: MET") or board_text.contains("Result: MISSED"), "board screen is missing the verdict")
	_check(board_text.contains("Week 1:"), "board screen is missing week 1")
	_check(board_text.contains("Week 4:"), "board screen is missing week 4")
	var wins := 0
	for result in game.series.results:
		if str(result["player_result"]) == "win":
			wins += 1
	_check(game.series.results.size() == 4, "series did not store four results")
	if wins >= Sport.GOAL_WINS:
		_check(board_text.contains("Result: MET"), "goal should be MET")
		_check(not board_text.contains("Result: MISSED"), "goal text contradicts MET")
	else:
		_check(board_text.contains("Result: MISSED"), "goal should be MISSED")
		_check(not board_text.contains("Result: MET"), "goal text contradicts MISSED")
	_check(board_text.contains("Player wins: %d" % wins), "board wins do not match the series")
	print("Scripted series result: %s" % ("MET" if wins >= Sport.GOAL_WINS else "MISSED"))
	print(board_text)

	var seed_before := int(game.series.seed)
	game.board_restart_button.pressed.emit()
	_check(game.phase == "office", "restart did not return to the office")
	_check(int(game.series.week) == 0, "restart did not reset the week")
	_check(game.series.results.is_empty(), "restart kept old results")
	_check(int(game.series.seed) == seed_before + 1, "restart did not advance the seed")

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
