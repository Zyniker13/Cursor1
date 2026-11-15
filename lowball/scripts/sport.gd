extends RefCounted

# Lowball — sport model
#
# Lowball is an invented three-inning bat-and-ball sport. It is not baseball,
# cricket, or any real league. This slice has four fictional clubs in the town
# of Lumen Quay: Lumen Reedmice (the player), Southspur Glass, Pellwick
# Cinders, and Marrowgate Herons. Players are generated. Nothing here is a
# real club, crest, or athlete.
#
# A match
#   * 3 innings. Each inning has a top half and a bottom half.
#   * The away side bats in the top, the home side in the bottom.
#   * Both sides always bat. A half-inning is exactly 4 plate appearances,
#     one per lineup slot, in order. 24 plate appearances per match.
#   * There is one mark (a single runner). It clears at the end of the half.
#   * No stat bonus for batting second. "Home" only means batting in the bottom.
#
# Lineup slots do two jobs
#   * Slot 0 bats first and fields the Near zone.
#   * Slot 1 bats second and fields the Mid zone.
#   * Slot 2 bats third and fields the Far zone.
#   * Slot 3 bats fourth and is the Rover (the throw on a close play).
#
# Six permanent stats, each an integer from STAT_FLOOR (1) to STAT_CAP (20)
#   * Lash  — driving the ball
#   * Eye   — placing the ball
#   * Legs  — beating a throw
#   * Glove — taking a placed ball
#   * Arm   — taking a driven ball, and the rover's throw
#   * Read  — the small edge in the margin
# Generated players roll each stat from GEN_MIN (9) to GEN_MAX (15).
#
# Training
#   * Before a week the club picks one stat as the focus.
#   * After that week's matches, every player on a club that played gains
#     TRAINING_GAIN (+1) in that stat. The result is clamped to STAT_CAP.
#     Stats never fall below STAT_FLOOR. A stat already at 20 stays at 20.
#
# Season
#   * Four clubs. A round is two matches, so every club plays every week.
#   * Six weeks. That is a double round-robin: every club plays every other
#     club once at home and once away. Home bats second. There is no stat
#     bonus for batting second.
#   * The player's match is the one they watch or skip. The other match that
#     week is played with the same pre-training stats and recorded with it.
#   * A win is 2 points. A tie is 1. A loss is 0.
#   * After week 6 the table is ordered by points per game. Rates are compared
#     as fractions (points × opponent games). An equal rate is not ahead.
#   * If the rate is level, the higher run difference is ahead.
#   * If that is level too, the series seed breaks the tie. Divide the seed
#     by 4 and keep the remainder. Remainder 0 starts with Lumen Reedmice,
#     1 with Southspur Glass, 2 with Pellwick Cinders, and 3 with Marrowgate
#     Herons. The order then follows that list and wraps.
#   * The top two play one final. The club ahead is home and bats second.
#     The final does not change the table. Both finalists can still train.
#   * If Lumen Reedmice finish 3rd or 4th, the season ends with no final.
#   * The board goal, shown from the start, is to reach the final and win it.
#     A loss or a tie in the final misses it. GOAL_TEXT states that goal.
#
# Tactics (one per club per match, used on offense and on defense)
#   * Aggressive: Lash +3 and Eye -2 for the zone weights. The drive contests
#     the zone fielder's Arm using Lash +3. Score line 10, mark line 0.
#   * Patient: Eye +3 and Lash -2 for the zone weights. The placement contests
#     the zone fielder's Glove using Eye +3. Score line 14, mark line -8.
#   * Field: defense Arm +3, Glove +1, rover Arm +1. Batting uses the integer
#     blend (Lash + Eye) / 2 against the defender's (Glove + Arm) / 2, and
#     Read drops by 1. Score line 6, mark line -4.
#   Zone weights use the shifted Lash and Eye. The contact rating uses only
#   the stat named above (Aggressive does not put the Eye penalty into the
#   drive, and Patient does not put the Lash penalty into the placement).
#
# Zone weights (each at least ZONE_MIN)
#   * Near = max(8, 20 + Eye - Lash)
#   * Mid  = 20
#   * Far  = max(8, 20 + Lash - Eye)
#   A zone roll picks one. High Lash leans Far. High Eye leans Near.
#
# Plate appearance (pure function)
#   Seed a RandomNumberGenerator with the match seed. For every plate
#   appearance, in order, draw three integers and no others:
#     1. zone roll, uniform on 0 .. weight total - 1
#     2. roll (luck), uniform on 0 .. 29
#     3. throw roll, uniform on 0 .. 19
#   The throw roll is drawn even when the play is not close.
#   Let bat be the batting rating and de the defender rating described above.
#   margin = (bat - de) * 2 + (bat_read - fielder_read) + roll - 15
#   * margin >= score line → Score. The throw is not used.
#   * margin >= mark line  → close. Mark if Legs + throw roll >= rover Arm + 10,
#     otherwise Out.
#   * otherwise → Out. The throw is not used.
#   Mark state, per half-inning, starts empty:
#   * Out: no run. The mark stays.
#   * Mark, none on: no run. A mark is placed.
#   * Mark, one on: 1 run. The old mark scores and the batter is the new mark.
#   * Score, none on: 1 run. No mark remains.
#   * Score, one on: 2 runs. The mark scores too and the base is empty.
#   Same seed, same stats, same tactics, same lineup order → the same
#   plate appearances, including the explanation strings.
#
# Names
#   Given name and family name are each two entries from SYLLABLES joined
#   with no extra letters. The list was reviewed for slurs, profanity, and
#   well-known athlete names: every syllable is three letters, none contains
#   "c", and the closed joins were checked against a blocklist (see tests).

const TOWN := "Lumen Quay"
const PLAYER_CLUB := "Lumen Reedmice"
const GLASS_CLUB := "Southspur Glass"
const CINDERS_CLUB := "Pellwick Cinders"
const HERONS_CLUB := "Marrowgate Herons"
const CLUBS: Array = [PLAYER_CLUB, GLASS_CLUB, CINDERS_CLUB, HERONS_CLUB]
const PLAYER_INDEX := 0

const STAT_FLOOR := 1
const STAT_CAP := 20
const GEN_MIN := 9
const GEN_MAX := 15
const TRAINING_GAIN := 1
const ROSTER_SIZE := 6
const LINEUP_SIZE := 4
const INNINGS := 3
const SERIES_WEEKS := 6
const MATCHES_PER_WEEK := 2
const WIN_POINTS := 2
const TIE_POINTS := 1
const PAS_PER_MATCH := INNINGS * 2 * LINEUP_SIZE

const GOAL_TEXT := "Board goal: reach the final and win it. A loss or a tie in the final misses it."

# Each week is two fixtures. Each fixture is [away_index, home_index].
# Home bats second. Six weeks is every pairing home and away.
const SCHEDULE: Array = [
	[[0, 1], [2, 3]],
	[[0, 2], [1, 3]],
	[[0, 3], [1, 2]],
	[[1, 0], [3, 2]],
	[[2, 0], [3, 1]],
	[[3, 0], [2, 1]],
]

const STATS: Array = ["lash", "eye", "legs", "glove", "arm", "read"]
const TACTICS: Array = ["aggressive", "patient", "field"]
const SLOT_ROLE: Array = ["Near", "Mid", "Far", "Rover"]

const STAT_LABEL := {
	"lash": "Lash",
	"eye": "Eye",
	"legs": "Legs",
	"glove": "Glove",
	"arm": "Arm",
	"read": "Read",
}
const TACTIC_LABEL := {
	"aggressive": "Aggressive",
	"patient": "Patient",
	"field": "Field",
}
const ZONE_LABEL := {
	"near": "Near",
	"mid": "Mid",
	"far": "Far",
}

const SYLLABLES: Array = [
	"bri", "dax", "fex", "gar", "hol", "jex", "kor", "lum",
	"mav", "nel", "pim", "quo", "rel", "sen", "tiv", "uln",
	"vex", "wyl", "yor", "zek",
]

const ZONE_MIN := 8
const ZONE_BASE := 20
const TACTIC_BUMP := 3
const FIELD_ARM := 3
const FIELD_GLOVE := 1
const FIELD_ROVER := 1
const LUCK_SPAN := 30
const LUCK_CENTER := 15
const THROW_SPAN := 20
const THROW_BIAS := 10
const SCORE_AT := {"aggressive": 10, "patient": 14, "field": 6}
const MARK_AT := {"aggressive": 0, "patient": -8, "field": -4}


static func get_stat(player: Dictionary, key: String) -> int:
	return int(player[key])


static func set_stat(player: Dictionary, key: String, value: int) -> void:
	player[key] = clampi(value, STAT_FLOOR, STAT_CAP)


static func make_player(player_name: String, stats: Dictionary) -> Dictionary:
	var player := {
		"player_name": player_name,
		"lash": 1,
		"eye": 1,
		"legs": 1,
		"glove": 1,
		"arm": 1,
		"read": 1,
	}
	for key in STATS:
		set_stat(player, key, int(stats[key]))
	return player


static func family_name(full_name: String) -> String:
	var parts := full_name.split(" ")
	if parts.is_empty():
		return full_name
	return str(parts[parts.size() - 1])


static func is_generated_name(full_name: String) -> bool:
	var parts := full_name.split(" ")
	if parts.size() != 2:
		return false
	return _is_syllable_word(str(parts[0])) and _is_syllable_word(str(parts[1]))


static func _is_syllable_word(word: String) -> bool:
	var lower := word.to_lower()
	if lower.length() != 6:
		return false
	return SYLLABLES.has(lower.substr(0, 3)) and SYLLABLES.has(lower.substr(3, 3))


static func _syllable_word(rng: RandomNumberGenerator) -> String:
	var first: String = SYLLABLES[rng.randi_range(0, SYLLABLES.size() - 1)]
	var second: String = SYLLABLES[rng.randi_range(0, SYLLABLES.size() - 1)]
	return first.substr(0, 1).to_upper() + first.substr(1) + second


static func _join_syllables(a: int, b: int) -> String:
	var first: String = SYLLABLES[a]
	var second: String = SYLLABLES[b]
	return first.substr(0, 1).to_upper() + first.substr(1) + second


static func _unique_name(rng: RandomNumberGenerator, used: Dictionary) -> String:
	for _attempt in 64:
		var candidate := _syllable_word(rng) + " " + _syllable_word(rng)
		if not used.has(candidate):
			used[candidate] = true
			return candidate
	var count := SYLLABLES.size()
	for a in count:
		for b in count:
			for c in count:
				for d in count:
					var candidate := _join_syllables(a, b) + " " + _join_syllables(c, d)
					if not used.has(candidate):
						used[candidate] = true
						return candidate
	return _join_syllables(0, 0) + " " + _join_syllables(0, 1)


static func _shuffle(rng: RandomNumberGenerator, items: Array) -> void:
	for i in range(items.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = items[i]
		items[i] = items[j]
		items[j] = tmp


static func create_clubs(series_seed: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = series_seed
	var lines: Array = []
	for _n in ROSTER_SIZE:
		var stats := {}
		for key in STATS:
			stats[key] = rng.randi_range(GEN_MIN, GEN_MAX)
		lines.append(stats)
	var club_lines: Array = []
	for club_index in CLUBS.size():
		var copy_lines: Array = []
		for stats in lines:
			var copy := {}
			for key in STATS:
				copy[key] = int(stats[key])
			copy_lines.append(copy)
		if club_index != PLAYER_INDEX:
			_shuffle(rng, copy_lines)
		club_lines.append(copy_lines)
	var used := {}
	var rosters: Array = []
	for club_index in CLUBS.size():
		var roster: Array = []
		for i in ROSTER_SIZE:
			roster.append(make_player(_unique_name(rng, used), club_lines[club_index][i]))
		rosters.append(roster)
	return {
		"town": TOWN,
		"clubs": CLUBS.duplicate(),
		"player_club": PLAYER_CLUB,
		"rosters": rosters,
	}


static func is_legal_lineup(roster_size: int, indices: Array) -> bool:
	if indices.size() != LINEUP_SIZE:
		return false
	var seen := {}
	for raw in indices:
		var i := int(raw)
		if i < 0 or i >= roster_size:
			return false
		if seen.has(i):
			return false
		seen[i] = true
	return true


static func random_lineup(rng: RandomNumberGenerator, roster_size: int) -> Array:
	var available: Array = []
	for i in roster_size:
		available.append(i)
	var lineup: Array = []
	for _k in LINEUP_SIZE:
		var j := rng.randi_range(0, available.size() - 1)
		lineup.append(int(available[j]))
		available.remove_at(j)
	return lineup


static func lineup_players(roster: Array, indices: Array) -> Array:
	var picked: Array = []
	for raw in indices:
		picked.append(roster[int(raw)])
	return picked


static func apply_training(roster: Array, focus: String) -> Array:
	var notes: Array = []
	if not STATS.has(focus):
		return notes
	for player in roster:
		var before := get_stat(player, focus)
		var after := clampi(before + TRAINING_GAIN, STAT_FLOOR, STAT_CAP)
		set_stat(player, focus, after)
		notes.append({
			"name": str(player["player_name"]),
			"stat": focus,
			"before": before,
			"after": after,
		})
	return notes


static func preview_training(roster: Array, focus: String) -> Array:
	var notes: Array = []
	if not STATS.has(focus):
		return notes
	for player in roster:
		var before := get_stat(player, focus)
		var after := clampi(before + TRAINING_GAIN, STAT_FLOOR, STAT_CAP)
		notes.append({
			"name": str(player["player_name"]),
			"stat": focus,
			"before": before,
			"after": after,
		})
	return notes


static func _tactic_key(player: Dictionary, tactic: String) -> int:
	if tactic == "aggressive":
		return get_stat(player, "lash") * 4 + get_stat(player, "legs") * 2 + get_stat(player, "read")
	if tactic == "patient":
		return get_stat(player, "eye") * 4 + get_stat(player, "legs") * 2 + get_stat(player, "read")
	return get_stat(player, "glove") * 3 + get_stat(player, "arm") * 3 + get_stat(player, "read") * 2


static func _better_index(roster: Array, i: int, j: int, tactic: String) -> bool:
	var left := _tactic_key(roster[i], tactic)
	var right := _tactic_key(roster[j], tactic)
	if left != right:
		return left > right
	return i < j


static func opponent_plan(roster: Array, week: int, club_index: int = 0) -> Dictionary:
	var tactic: String = TACTICS[posmod(week + club_index, TACTICS.size())]
	var order: Array = []
	for i in roster.size():
		order.append(i)
	for a in order.size():
		var best: int = a
		for b in range(a + 1, order.size()):
			if _better_index(roster, int(order[b]), int(order[best]), tactic):
				best = b
		var tmp = order[a]
		order[a] = order[best]
		order[best] = tmp
	var lineup: Array = []
	for n in LINEUP_SIZE:
		lineup.append(int(order[n]))
	var focus: String = STATS[0]
	var best_sum := 1 << 30
	for key in STATS:
		var total := 0
		for player in roster:
			total += get_stat(player, key)
		if total < best_sum:
			best_sum = total
			focus = key
	return {"tactic": tactic, "lineup": lineup, "training": focus}


static func match_seed_for(series_seed: int, week: int, fixture: int = 0) -> int:
	return series_seed * 1009 + week * 17 + fixture * 131 + 3


static func regular_match_count() -> int:
	return SERIES_WEEKS * MATCHES_PER_WEEK


static func player_fixture(week: int) -> Array:
	for pair in SCHEDULE[week]:
		if int(pair[0]) == PLAYER_INDEX or int(pair[1]) == PLAYER_INDEX:
			return pair
	return []


static func other_fixture(week: int) -> Array:
	for pair in SCHEDULE[week]:
		if int(pair[0]) != PLAYER_INDEX and int(pair[1]) != PLAYER_INDEX:
			return pair
	return []


static func fixture_slot(week: int, away: int, home: int) -> int:
	var pairs: Array = SCHEDULE[week]
	for i in pairs.size():
		if int(pairs[i][0]) == away and int(pairs[i][1]) == home:
			return i
	return 0


static func seed_order(series_seed: int) -> Array:
	var start := posmod(series_seed, CLUBS.size())
	var order: Array = []
	for step in CLUBS.size():
		order.append((start + step) % CLUBS.size())
	return order


static func club_seed_rank(series_seed: int, club_index: int) -> int:
	return seed_order(series_seed).find(club_index)


# 1 when A has a strictly better points-per-game rate, -1 when B does, 0 when level.
# Unplayed clubs share a level rate. A played club is ahead of an unplayed one.
static func rate_compare(points_a: int, played_a: int, points_b: int, played_b: int) -> int:
	if played_a <= 0 and played_b <= 0:
		return 0
	if played_a <= 0:
		return -1
	if played_b <= 0:
		return 1
	var left := points_a * played_b
	var right := points_b * played_a
	if left == right:
		return 0
	if left > right:
		return 1
	return -1


static func stands_ahead(a: Dictionary, b: Dictionary, series_seed: int) -> bool:
	var rate := rate_compare(int(a["points"]), int(a["played"]), int(b["points"]), int(b["played"]))
	if rate != 0:
		return rate > 0
	if int(a["run_diff"]) != int(b["run_diff"]):
		return int(a["run_diff"]) > int(b["run_diff"])
	return club_seed_rank(series_seed, int(a["club"])) < club_seed_rank(series_seed, int(b["club"]))


static func standings(played: Array, series_seed: int) -> Array:
	var rows: Array = []
	for i in CLUBS.size():
		rows.append({
			"club": i,
			"played": 0,
			"wins": 0,
			"losses": 0,
			"ties": 0,
			"points": 0,
			"runs_for": 0,
			"runs_against": 0,
			"run_diff": 0,
		})
	for fixture in played:
		var home := int(fixture["home"])
		var away := int(fixture["away"])
		var home_score := int(fixture["home_score"])
		var away_score := int(fixture["away_score"])
		rows[home]["played"] = int(rows[home]["played"]) + 1
		rows[away]["played"] = int(rows[away]["played"]) + 1
		rows[home]["runs_for"] = int(rows[home]["runs_for"]) + home_score
		rows[home]["runs_against"] = int(rows[home]["runs_against"]) + away_score
		rows[away]["runs_for"] = int(rows[away]["runs_for"]) + away_score
		rows[away]["runs_against"] = int(rows[away]["runs_against"]) + home_score
		if home_score > away_score:
			rows[home]["wins"] = int(rows[home]["wins"]) + 1
			rows[home]["points"] = int(rows[home]["points"]) + WIN_POINTS
			rows[away]["losses"] = int(rows[away]["losses"]) + 1
		elif away_score > home_score:
			rows[away]["wins"] = int(rows[away]["wins"]) + 1
			rows[away]["points"] = int(rows[away]["points"]) + WIN_POINTS
			rows[home]["losses"] = int(rows[home]["losses"]) + 1
		else:
			rows[home]["ties"] = int(rows[home]["ties"]) + 1
			rows[away]["ties"] = int(rows[away]["ties"]) + 1
			rows[home]["points"] = int(rows[home]["points"]) + TIE_POINTS
			rows[away]["points"] = int(rows[away]["points"]) + TIE_POINTS
	for row in rows:
		row["run_diff"] = int(row["runs_for"]) - int(row["runs_against"])
	var ordered: Array = []
	for row in rows:
		ordered.append(row)
	for a in ordered.size():
		var best: int = a
		for b in range(a + 1, ordered.size()):
			if stands_ahead(ordered[b], ordered[best], series_seed):
				best = b
		var tmp = ordered[a]
		ordered[a] = ordered[best]
		ordered[best] = tmp
	return ordered


static func rank_of(ordered: Array, club_index: int) -> int:
	for i in ordered.size():
		if int(ordered[i]["club"]) == club_index:
			return i + 1
	return ordered.size() + 1


static func _stored_fixture(played: Array, week: int, away: int, home: int) -> Dictionary:
	for fixture in played:
		if int(fixture.get("week", -1)) != week:
			continue
		if int(fixture.get("away", -2)) == away and int(fixture.get("home", -2)) == home:
			return fixture
	return {}


static func schedule_text(played: Array) -> String:
	var lines: Array = []
	lines.append("Season schedule. Two matches a week for %d weeks. Every club plays every other club home and away." % SERIES_WEEKS)
	for week in SERIES_WEEKS:
		var bits: Array = []
		for pair in SCHEDULE[week]:
			var away := int(pair[0])
			var home := int(pair[1])
			var found := _stored_fixture(played, week, away, home)
			if found.is_empty():
				bits.append("%s at %s" % [CLUBS[away], CLUBS[home]])
			else:
				bits.append("%s %d at %s %d" % [
					CLUBS[away], int(found["away_score"]), CLUBS[home], int(found["home_score"]),
				])
		lines.append("Week %d: %s." % [week + 1, ". ".join(bits)])
	lines.append("Final: the top two. The club ahead is home and bats second. If %s finish outside the top two, the season ends with no final." % PLAYER_CLUB)
	return "\n".join(lines)


static func tie_break_text(series_seed: int) -> String:
	var names: Array = []
	for index in seed_order(series_seed):
		names.append(str(CLUBS[int(index)]))
	return "Tie-break: points per game, a win is %d and a tie is %d. An equal rate is not ahead. If the rate is level, the higher run difference is ahead. If that is level too, this seed order decides: %s." % [
		WIN_POINTS, TIE_POINTS, ", ".join(names),
	]


static func _signed(value: int) -> String:
	if value > 0:
		return "+%d" % value
	return str(value)


static func table_text(ordered: Array) -> String:
	var lines: Array = []
	lines.append("Table. Ordered by points per game. The final does not change it.")
	for i in ordered.size():
		var row: Dictionary = ordered[i]
		var played_count := int(row["played"])
		var rate := "—"
		if played_count > 0:
			rate = "%d/%d" % [int(row["points"]), played_count]
		lines.append("%d. %s    %d pts    %d played    %s per game    run difference %s" % [
			i + 1,
			CLUBS[int(row["club"])],
			int(row["points"]),
			played_count,
			rate,
			_signed(int(row["run_diff"])),
		])
	return "\n".join(lines)


static func simulate_match(
	match_seed: int,
	home_lineup: Array,
	away_lineup: Array,
	home_tactic: String,
	away_tactic: String,
	home_club: String,
	away_club: String
) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = match_seed
	var home_score := 0
	var away_score := 0
	var plate_appearances: Array = []
	for inning in range(1, INNINGS + 1):
		for half_index in 2:
			var top := half_index == 0
			var batting: Array = away_lineup if top else home_lineup
			var fielding: Array = home_lineup if top else away_lineup
			var bat_tactic: String = away_tactic if top else home_tactic
			var def_tactic: String = home_tactic if top else away_tactic
			var bat_club: String = away_club if top else home_club
			var def_club: String = home_club if top else away_club
			var half_name := "top" if top else "bottom"
			var mark := false
			for slot in LINEUP_SIZE:
				var resolved := _resolve_plate(
					rng,
					batting[slot],
					fielding,
					bat_tactic,
					def_tactic,
					mark
				)
				var runs := int(resolved["runs"])
				if top:
					away_score += runs
				else:
					home_score += runs
				mark = bool(resolved["mark_after"])
				resolved["inning"] = inning
				resolved["half"] = half_name
				resolved["slot"] = slot
				resolved["batting_club"] = bat_club
				resolved["fielding_club"] = def_club
				resolved["batting_tactic"] = bat_tactic
				resolved["fielding_tactic"] = def_tactic
				resolved["home_score"] = home_score
				resolved["away_score"] = away_score
				resolved["index"] = plate_appearances.size()
				resolved["explanation"] = _explain(resolved)
				plate_appearances.append(resolved)
	var winner := "tie"
	if home_score > away_score:
		winner = "home"
	elif away_score > home_score:
		winner = "away"
	var explanations: Array = []
	var home_names: Array = []
	var away_names: Array = []
	for player in home_lineup:
		home_names.append(str(player["player_name"]))
	for player in away_lineup:
		away_names.append(str(player["player_name"]))
	for pa in plate_appearances:
		explanations.append(str(pa["explanation"]))
	return {
		"seed": match_seed,
		"home_club": home_club,
		"away_club": away_club,
		"home_tactic": home_tactic,
		"away_tactic": away_tactic,
		"home_score": home_score,
		"away_score": away_score,
		"winner": winner,
		"home_names": home_names,
		"away_names": away_names,
		"plate_appearances": plate_appearances,
		"explanations": explanations,
	}


static func _resolve_plate(
	rng: RandomNumberGenerator,
	batter: Dictionary,
	fielding: Array,
	bat_tactic: String,
	def_tactic: String,
	mark_before: bool
) -> Dictionary:
	var base_lash := get_stat(batter, "lash")
	var base_eye := get_stat(batter, "eye")
	var base_legs := get_stat(batter, "legs")
	var base_read := get_stat(batter, "read")
	var zone_lash := base_lash
	var zone_eye := base_eye
	if bat_tactic == "aggressive":
		zone_lash += TACTIC_BUMP
		zone_eye -= 2
	elif bat_tactic == "patient":
		zone_eye += TACTIC_BUMP
		zone_lash -= 2
	var near_w := maxi(ZONE_MIN, ZONE_BASE + zone_eye - zone_lash)
	var far_w := maxi(ZONE_MIN, ZONE_BASE + zone_lash - zone_eye)
	var mid_w := ZONE_BASE
	var total_w := near_w + mid_w + far_w
	var zone_roll := rng.randi_range(0, total_w - 1)
	var zone := "near"
	var zone_index := 0
	if zone_roll >= near_w and zone_roll < near_w + mid_w:
		zone = "mid"
		zone_index = 1
	elif zone_roll >= near_w + mid_w:
		zone = "far"
		zone_index = 2
	var fielder: Dictionary = fielding[zone_index]
	var rover: Dictionary = fielding[LINEUP_SIZE - 1]
	var base_glove := get_stat(fielder, "glove")
	var base_arm := get_stat(fielder, "arm")
	var fielder_read := get_stat(fielder, "read")
	var glove := base_glove
	var arm := base_arm
	if def_tactic == "field":
		glove += FIELD_GLOVE
		arm += FIELD_ARM
	var bat_rating := 0
	var def_rating := 0
	var bat_read := base_read
	if bat_tactic == "aggressive":
		bat_rating = base_lash + TACTIC_BUMP
		def_rating = arm
	elif bat_tactic == "patient":
		bat_rating = base_eye + TACTIC_BUMP
		def_rating = glove
	else:
		bat_rating = int((base_lash + base_eye) / 2.0)
		def_rating = int((glove + arm) / 2.0)
		bat_read = base_read - 1
	var luck := rng.randi_range(0, LUCK_SPAN - 1)
	var throw_roll := rng.randi_range(0, THROW_SPAN - 1)
	var margin := (bat_rating - def_rating) * 2 + (bat_read - fielder_read) + luck - LUCK_CENTER
	var score_at := int(SCORE_AT[bat_tactic])
	var mark_at := int(MARK_AT[bat_tactic])
	var rover_arm := get_stat(rover, "arm")
	if def_tactic == "field":
		rover_arm += FIELD_ROVER
	var outcome := "out"
	var throw_checked := false
	if margin >= score_at:
		outcome = "score"
	elif margin >= mark_at:
		throw_checked = true
		if base_legs + throw_roll >= rover_arm + THROW_BIAS:
			outcome = "mark"
		else:
			outcome = "out"
	var runs := 0
	var mark_after := mark_before
	if outcome == "mark":
		if mark_before:
			runs = 1
		mark_after = true
	elif outcome == "score":
		runs = 2 if mark_before else 1
		mark_after = false
	return {
		"batter_name": str(batter["player_name"]),
		"fielder_name": str(fielder["player_name"]),
		"rover_name": str(rover["player_name"]),
		"zone": zone,
		"outcome": outcome,
		"runs": runs,
		"mark_before": mark_before,
		"mark_after": mark_after,
		"throw_checked": throw_checked,
		"zone_lash": zone_lash,
		"zone_eye": zone_eye,
		"base_lash": base_lash,
		"base_eye": base_eye,
		"base_read": base_read,
		"base_legs": base_legs,
		"batter_glove": get_stat(batter, "glove"),
		"batter_arm": get_stat(batter, "arm"),
		"base_glove": base_glove,
		"base_arm": base_arm,
		"bat_rating": bat_rating,
		"def_rating": def_rating,
		"bat_read": bat_read,
		"fielder_read": fielder_read,
		"luck": luck,
		"margin": margin,
		"score_at": score_at,
		"mark_at": mark_at,
		"rover_arm": rover_arm,
		"def_field": def_tactic == "field",
	}


static func _explain(ctx: Dictionary) -> String:
	var parts: Array = []
	parts.append(
		"Inning %d %s: %s, %s, to the %s zone (Lash %d, Eye %d)." % [
			int(ctx["inning"]),
			str(ctx["half"]),
			str(ctx["batter_name"]),
			TACTIC_LABEL[str(ctx["batting_tactic"])],
			ZONE_LABEL[str(ctx["zone"])],
			int(ctx["zone_lash"]),
			int(ctx["zone_eye"]),
		]
	)
	var tactic := str(ctx["batting_tactic"])
	var fielder := str(ctx["fielder_name"])
	if tactic == "aggressive":
		if bool(ctx["def_field"]):
			parts.append(
				"Aggressive lifts Lash from %d to %d against %s's Arm %d (Field lifted it from %d)." % [
					int(ctx["base_lash"]), int(ctx["bat_rating"]), fielder, int(ctx["def_rating"]), int(ctx["base_arm"]),
				]
			)
		else:
			parts.append(
				"Aggressive lifts Lash from %d to %d against %s's Arm %d." % [
					int(ctx["base_lash"]), int(ctx["bat_rating"]), fielder, int(ctx["def_rating"]),
				]
			)
	elif tactic == "patient":
		if bool(ctx["def_field"]):
			parts.append(
				"Patient lifts Eye from %d to %d against %s's Glove %d (Field lifted it from %d)." % [
					int(ctx["base_eye"]), int(ctx["bat_rating"]), fielder, int(ctx["def_rating"]), int(ctx["base_glove"]),
				]
			)
		else:
			parts.append(
				"Patient lifts Eye from %d to %d against %s's Glove %d." % [
					int(ctx["base_eye"]), int(ctx["bat_rating"]), fielder, int(ctx["def_rating"]),
				]
			)
	else:
		var blend_before := int((int(ctx["base_glove"]) + int(ctx["base_arm"])) / 2.0)
		if bool(ctx["def_field"]):
			parts.append(
				"Field drops Read from %d to %d. Lash/Eye blend %d against %s's Glove/Arm blend %d (Field lifted it from %d)." % [
					int(ctx["base_read"]), int(ctx["bat_read"]), int(ctx["bat_rating"]), fielder, int(ctx["def_rating"]), blend_before,
				]
			)
		else:
			parts.append(
				"Field drops Read from %d to %d. Lash/Eye blend %d against %s's Glove/Arm blend %d." % [
					int(ctx["base_read"]), int(ctx["bat_read"]), int(ctx["bat_rating"]), fielder, int(ctx["def_rating"]),
				]
			)
	parts.append(
		"Read %d plays against %s's Read %d. Roll %d sets the margin at %d." % [
			int(ctx["bat_read"]), fielder, int(ctx["fielder_read"]), int(ctx["luck"]), int(ctx["margin"]),
		]
	)
	var outcome := str(ctx["outcome"])
	if bool(ctx["throw_checked"]):
		var beat: bool = outcome == "mark"
		if beat:
			parts.append(
				"Margin %d is in the close band from the mark line %d to the score line %d, so Legs %d beat %s's Arm %d." % [
					int(ctx["margin"]), int(ctx["mark_at"]), int(ctx["score_at"]),
					int(ctx["base_legs"]), str(ctx["rover_name"]), int(ctx["rover_arm"]),
				]
			)
		else:
			parts.append(
				"Margin %d is in the close band from the mark line %d to the score line %d, so Legs %d lose to %s's Arm %d." % [
					int(ctx["margin"]), int(ctx["mark_at"]), int(ctx["score_at"]),
					int(ctx["base_legs"]), str(ctx["rover_name"]), int(ctx["rover_arm"]),
				]
			)
	elif outcome == "out":
		parts.append(
			"Margin %d is short of the mark line %d." % [int(ctx["margin"]), int(ctx["mark_at"])]
		)
	else:
		parts.append(
			"Margin %d meets the score line %d." % [int(ctx["margin"]), int(ctx["score_at"])]
		)
	parts.append(_result_sentence(ctx))
	return " ".join(parts)


static func _result_sentence(ctx: Dictionary) -> String:
	var outcome := str(ctx["outcome"])
	var runs := int(ctx["runs"])
	if outcome == "out":
		return "Out."
	if outcome == "mark":
		if runs == 1:
			return "Mark. The existing mark scores. 1 run."
		return "Mark. No run."
	if runs == 2:
		return "Score. The mark scores too. 2 runs."
	return "Score. 1 run."
