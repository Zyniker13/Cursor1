extends RefCounted

# Lowball — sport model
#
# Lowball is an invented three-inning bat-and-ball sport. It is not baseball,
# cricket, or any real league. This slice has twenty-six fictional clubs in the
# town of Lumen Quay: Lumen Reedmice, Southspur Glass, Pellwick Cinders,
# Marrowgate Herons, Saltmere Kites, Ashfen Moths, Reedfen Larks, Cinderwharf
# Pikes, Saltwharf Gulls, Marrowfen Owls, Ashwharf Swifts, Pellfen Terns,
# Southfen Coots, Tidefen Grebes, Brinefen Curlews, Quayfen Knots, Millfen
# Ruffs, Wickfen Dunlins, Lockfen Snipes, Quaywharf Godwits, Tidewharf
# Whimbrels, Brinewharf Avocets, Saltwharf Curlews, Mudwharf Knots, Reefwharf
# Dunlins, and Barwharf Sanderlings. Players are generated.
# Nothing here is a real club, crest, or athlete.
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
#   * After the week, every player on the roster gains TRAINING_GAIN (+1) in
#     that stat. The result is clamped to STAT_CAP. Stats never fall below
#     STAT_FLOOR. A bye week in an odd season still drills. The office season
#     is fifty weeks with no bye, so fifty drills. The same focus each week
#     takes a generated stat to the cap of 20, and a stat already at 20 stays
#     at 20.
#   * Each final game, when Lumen Reedmice reach the final, is one more drill.
#     Every club drills after that game, including the clubs left out of the
#     final. A missed final adds no further drill. Training still stops at 20.
#
# Series
#   * The office season is twenty-six clubs: Barwharf Sanderlings joined the
#     circle. Twenty-six is even, so there is no bye. Fifty weeks, thirteen
#     matches a week. SERIES_WEEKS is 50, MATCHES_PER_WEEK is 13, BYES_EACH is
#     0, and GAMES_EACH is 50.
#     use_season(25) restores the twenty-five-club game: fifty weeks, twelve
#     matches and one bye a week, the Lumen Reedmice week-1 bye, Quaywharf
#     Godwits at home to Reefwharf Dunlins, and seed 417 still finishes 1st
#     and beats Saltwharf Gulls 9-5, 5-5, 6-8, 6-6, 3-3, 9-3.
#     use_season(24) restores the twenty-four-club game: forty-six weeks, twelve
#     matches, zero byes, ring
#     [0, 1, 2, 3, 4, 5, 12, 14, 16, 18, 19, 20, 21, 22, 23, 17, 15, 13, 6, 7, 8, 9, 10, 11],
#     Lockfen Snipes at home to Mudwharf Knots, and seed 493 still finishes 1st
#     and beats Saltwharf Gulls 4-3 and 6-5.
#     use_season(23) restores the twenty-three-club game: forty-six weeks,
#     eleven matches and one bye a week, the Lumen Reedmice week-1 bye,
#     Quaywharf Godwits at home to Saltwharf Curlews, and seed 557 still
#     finishes 1st and beats Saltmere Kites 2-8, 6-6, 9-3, 4-4, 6-4.
#     use_season(22) restores the twenty-two-club game: forty-two weeks, eleven
#     matches, zero byes, ring
#     [0, 1, 2, 3, 4, 5, 12, 14, 16, 18, 19, 20, 21, 17, 15, 13, 6, 7, 8, 9, 10, 11],
#     and seed 631 still finishes 1st and beats Cinderwharf Pikes 6-4, 3-6, 7-6.
#     use_season(21) restores the twenty-one-club game, including its week-1
#     list and the Lumen Reedmice bye, and seed 651 still beats Ashfen Moths
#     4-2 and 5-3. use_season(20) restores the twenty-club game and seed 349
#     still beats Cinderwharf Pikes 2-11, 7-3, 5-1.
#   * Twenty-one is odd, so the ring has a bye seat. The seats are
#     [0, 1, 2, 3, 4, 5, 12, 14, 16, 18, 19, 20, 17, 15, 13, 6, 7, 8, 9, 10, 11, bye].
#     Index 20, Tidewharf Whimbrels, sits immediately after Quaywharf Godwits
#     and immediately before Wickfen Dunlins. The bye is the last seat. Pair
#     from the outside in. The club paired with the bye sits out. The bye stays
#     put. The other twenty-one seats, including the first, rotate one place
#     left. Lumen Reedmice stay in the first seat, so week 1 is their bye.
#   * Rotating all twenty-two seats, including the bye, is not the season.
#     Appending Tidewharf Whimbrels to the twenty-club ring and pairing that
#     21-list from the outside in is not week 1. That appended list is
#     [0, 1, 2, 3, 4, 5, 12, 14, 16, 18, 19, 17, 15, 13, 6, 7, 8, 9, 10, 11, 20].
#   * The twenty-two-club ring extends that even pattern. The bye seat is
#     gone. Index 21, Brinewharf Avocets, sits immediately after Tidewharf
#     Whimbrels and immediately before Wickfen Dunlins. The seats are
#     [0, 1, 2, 3, 4, 5, 12, 14, 16, 18, 19, 20, 21, 17, 15, 13, 6, 7, 8, 9, 10, 11].
#     The last seat stays put. The other twenty-one seats, including the first,
#     rotate one place left. Pair from the outside in. Weeks 1-21 are one
#     circle. Weeks 22-42 repeat those pairings with home and away reversed.
#     Every club plays 42 games and has zero byes.
#   * Appending Brinewharf Avocets to the twenty-one-club ring, which still
#     ends in the bye, and pairing that list from the outside in is not week 1.
#     Rotating all twenty-two seats, including the last, is not the season.
#   * The twenty-three-club ring follows the odd bye pattern. Index 22,
#     Saltwharf Curlews, sits immediately after Brinewharf Avocets and
#     immediately before Wickfen Dunlins. The bye is the new last seat. The
#     seats are
#     [0, 1, 2, 3, 4, 5, 12, 14, 16, 18, 19, 20, 21, 22, 17, 15, 13, 6, 7, 8, 9, 10, 11, bye].
#     The bye stays put. The other twenty-three seats, including the first,
#     rotate one place left. Lumen Reedmice stay in the first seat, so week 1
#     is their bye. Pair from the outside in. Weeks 1-23 are one circle. Weeks
#     24-46 repeat those pairings with home and away reversed. Each week has
#     eleven matches and one bye. Every club plays 44 games and has two byes.
#   * Appending Saltwharf Curlews to the twenty-two-club ring and pairing that
#     23-list from the outside in is not week 1. Rotating all twenty-four
#     seats, including the bye, is not the season.
#   * The twenty-four-club ring extends the even pattern. The bye seat is
#     gone. Index 23, Mudwharf Knots, sits immediately after Saltwharf Curlews
#     and immediately before Wickfen Dunlins. The seats are
#     [0, 1, 2, 3, 4, 5, 12, 14, 16, 18, 19, 20, 21, 22, 23, 17, 15, 13, 6, 7, 8, 9, 10, 11].
#     The last seat stays put. The other twenty-three seats, including the
#     first, rotate one place left. Lumen Reedmice stay in the first seat.
#     Pair from the outside in. Weeks 1-23 are one circle. Weeks 24-46 repeat
#     those pairings with home and away reversed. Every club plays 46 games
#     and has zero byes.
#   * Appending Mudwharf Knots to the twenty-three-club ring, which still ends
#     in the bye, and pairing that list from the outside in is not week 1.
#     Rotating all twenty-four seats, including the last, is not the season.
#   * The twenty-five-club ring follows the odd bye pattern. Index 24,
#     Reefwharf Dunlins, sits immediately after Mudwharf Knots and immediately
#     before Wickfen Dunlins. The bye is the new last seat. The seats are
#     [0, 1, 2, 3, 4, 5, 12, 14, 16, 18, 19, 20, 21, 22, 23, 24, 17, 15, 13, 6, 7, 8, 9, 10, 11, bye].
#     The bye stays put. The other twenty-five seats, including the first,
#     rotate one place left. Lumen Reedmice stay in the first seat, so week 1
#     is their bye. Pair from the outside in. Weeks 1-25 are one circle. Weeks
#     26-50 repeat those pairings with home and away reversed. Each week has
#     twelve matches and one bye. Every club plays 48 games and has two byes.
#   * Appending Reefwharf Dunlins to the twenty-four-club ring and pairing that
#     25-list from the outside in is not week 1. Rotating all twenty-six seats,
#     including the bye, is not the season.
#   * The twenty-six-club ring extends the even pattern. The bye seat is gone.
#     Index 25, Barwharf Sanderlings, sits immediately after Reefwharf Dunlins
#     and immediately before Wickfen Dunlins. The seats are
#     [0, 1, 2, 3, 4, 5, 12, 14, 16, 18, 19, 20, 21, 22, 23, 24, 25, 17, 15, 13, 6, 7, 8, 9, 10, 11].
#     The last seat stays put. The other twenty-five seats, including the
#     first, rotate one place left. Lumen Reedmice stay in the first seat.
#     Pair from the outside in. Weeks 1-25 are one circle. Weeks 26-50 repeat
#     those pairings with home and away reversed. Each week has thirteen
#     matches and zero byes. Every club plays 50 games and has zero byes.
#   * Appending Barwharf Sanderlings to the twenty-five-club ring, which still
#     ends in the bye, and pairing that list from the outside in is not week 1.
#     Rotating all twenty-six seats, including the last, is not the season.
#   * The twenty-club ring, kept for use_season(20), is
#     [0, 1, 2, 3, 4, 5, 12, 14, 16, 18, 19, 17, 15, 13, 6, 7, 8, 9, 10, 11].
#     Its last seat stays. The other nineteen, including the first, rotate one
#     place left. Appending Quaywharf Godwits to the nineteen-club ring is not
#     that season. Weeks 20-38 reverse home and away.
#   * Weeks 1-21 of the twenty-one-club season are one circle. Weeks 22-42
#     repeat those pairings with home and away reversed. Every club plays every
#     other club once at home and once away (40 games) and has two byes.
#   * Week 1 is Southspur Glass vs Pellfen Terns, Pellwick Cinders vs Ashwharf
#     Swifts, Marrowgate Herons vs Marrowfen Owls, Saltmere Kites vs Saltwharf
#     Gulls, Ashfen Moths vs Cinderwharf Pikes, Southfen Coots vs Reedfen Larks,
#     Brinefen Curlews vs Tidefen Grebes, Millfen Ruffs vs Quayfen Knots,
#     Lockfen Snipes vs Wickfen Dunlins, and Quaywharf Godwits vs Tidewharf
#     Whimbrels. Lumen Reedmice have the bye and play week 2.
#   * The office season has no bye week. Training still adds 1, capped at 20.
#     Fifty weeks means fifty drills. On a bye week in an odd season there is
#     no match to watch. The other matches are recorded, and training still
#     drills.
#   * A win is WIN_POINTS (2) and a tie is TIE_POINTS (1).
#   * Table order is points per game, then run difference, then the series
#     seed. Rates are compared as fractions. An equal rate is not ahead.
#     Divide the series seed by the club count. Remainder 0 starts with Lumen
#     Reedmice. In the twenty-six-club season, remainder 25 starts with
#     Barwharf Sanderlings. In the twenty-five-club season, remainder 24 starts
#     with Reefwharf Dunlins. In the twenty-four-club season, remainder 23 starts with
#     Mudwharf Knots. In the twenty-three-club season, remainder 22 starts with
#     Saltwharf Curlews. In the twenty-two-club season, remainder 21 starts
#     with Brinewharf Avocets. In the twenty-one-club season, remainder 20
#     starts with Tidewharf Whimbrels. In the twenty-club game, remainder 19
#     starts with Quaywharf Godwits.
#   * After the league the top two play a best-of-three final. The club that
#     led is home for game 1, game 3, and every later odd game. The other
#     finalist is home for the even games. If Lumen Reedmice are in the final
#     and led the league, they are home for games 1 and 3. A tie is not a win.
#     The final does not change the table. If Lumen Reedmice finish 3rd through
#     last, the season ends with no final. GOAL_TEXT states the board goal.
#   * An AI club's tactic is TACTICS[(week + club index) % 3]. Final game N
#     uses week index SERIES_WEEKS + N (0-based). Training is the stat with
#     the lowest roster total.
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
const OPPONENT_CLUB := "Southspur Glass"
const THIRD_CLUB := "Pellwick Cinders"
const FOURTH_CLUB := "Marrowgate Herons"
const FIFTH_CLUB := "Saltmere Kites"
const SIXTH_CLUB := "Ashfen Moths"
const SEVENTH_CLUB := "Reedfen Larks"
const EIGHTH_CLUB := "Cinderwharf Pikes"
const NINTH_CLUB := "Saltwharf Gulls"
const TENTH_CLUB := "Marrowfen Owls"
const ELEVENTH_CLUB := "Ashwharf Swifts"
const TWELFTH_CLUB := "Pellfen Terns"
const THIRTEENTH_CLUB := "Southfen Coots"
const FOURTEENTH_CLUB := "Tidefen Grebes"
const FIFTEENTH_CLUB := "Brinefen Curlews"
const SIXTEENTH_CLUB := "Quayfen Knots"
const SEVENTEENTH_CLUB := "Millfen Ruffs"
const EIGHTEENTH_CLUB := "Wickfen Dunlins"
const NINETEENTH_CLUB := "Lockfen Snipes"
const TWENTIETH_CLUB := "Quaywharf Godwits"
const TWENTY_FIRST_CLUB := "Tidewharf Whimbrels"
const TWENTY_SECOND_CLUB := "Brinewharf Avocets"
const TWENTY_THIRD_CLUB := "Saltwharf Curlews"
const TWENTY_FOURTH_CLUB := "Mudwharf Knots"
const TWENTY_FIFTH_CLUB := "Reefwharf Dunlins"
const TWENTY_SIXTH_CLUB := "Barwharf Sanderlings"
const PLAYER_INDEX := 0
const BYE := -1


const STAT_FLOOR := 1
const STAT_CAP := 20
const GEN_MIN := 9
const GEN_MAX := 15
const TRAINING_GAIN := 1
const ROSTER_SIZE := 6
const LINEUP_SIZE := 4
const INNINGS := 3
const FINAL_WINS_NEEDED := 2

static var CLUB_COUNT: int = 26
static var SERIES_WEEKS: int = 50
static var MATCHES_PER_WEEK: int = 13
static var BYES_EACH: int = 0
static var GAMES_EACH: int = 50
static var RING: Array = []
static var APPENDED_RING: Array = []
static var CLUB_NAMES: Array = []
static var SCHEDULE_TEXT: String = ""
static var SEED_RULE: String = ""
static var FINAL_TEXT: String = ""
const PAS_PER_MATCH := INNINGS * 2 * LINEUP_SIZE
const WIN_POINTS := 2
const TIE_POINTS := 1

const GOAL_TEXT := "Board goal: reach the final and win the series."
const FINAL_TIE_TEXT := "A tie in a final game is not a win for either side. The series continues with another game until one club has two wins. The club that led after the league is home for game 1, game 3, and every later odd-numbered game. The other finalist is home for game 2 and every later even-numbered game."
const TIE_RULE := "Ties in the table break by run difference, then by the existing series seed."

const _NAMES_TWENTY: Array = ["Lumen Reedmice", "Southspur Glass", "Pellwick Cinders", "Marrowgate Herons", "Saltmere Kites", "Ashfen Moths", "Reedfen Larks", "Cinderwharf Pikes", "Saltwharf Gulls", "Marrowfen Owls", "Ashwharf Swifts", "Pellfen Terns", "Southfen Coots", "Tidefen Grebes", "Brinefen Curlews", "Quayfen Knots", "Millfen Ruffs", "Wickfen Dunlins", "Lockfen Snipes", "Quaywharf Godwits"]
const _NAMES_TWENTY_ONE: Array = ["Lumen Reedmice", "Southspur Glass", "Pellwick Cinders", "Marrowgate Herons", "Saltmere Kites", "Ashfen Moths", "Reedfen Larks", "Cinderwharf Pikes", "Saltwharf Gulls", "Marrowfen Owls", "Ashwharf Swifts", "Pellfen Terns", "Southfen Coots", "Tidefen Grebes", "Brinefen Curlews", "Quayfen Knots", "Millfen Ruffs", "Wickfen Dunlins", "Lockfen Snipes", "Quaywharf Godwits", "Tidewharf Whimbrels"]
const _NAMES_TWENTY_TWO: Array = ["Lumen Reedmice", "Southspur Glass", "Pellwick Cinders", "Marrowgate Herons", "Saltmere Kites", "Ashfen Moths", "Reedfen Larks", "Cinderwharf Pikes", "Saltwharf Gulls", "Marrowfen Owls", "Ashwharf Swifts", "Pellfen Terns", "Southfen Coots", "Tidefen Grebes", "Brinefen Curlews", "Quayfen Knots", "Millfen Ruffs", "Wickfen Dunlins", "Lockfen Snipes", "Quaywharf Godwits", "Tidewharf Whimbrels", "Brinewharf Avocets"]
const _NAMES_TWENTY_THREE: Array = ["Lumen Reedmice", "Southspur Glass", "Pellwick Cinders", "Marrowgate Herons", "Saltmere Kites", "Ashfen Moths", "Reedfen Larks", "Cinderwharf Pikes", "Saltwharf Gulls", "Marrowfen Owls", "Ashwharf Swifts", "Pellfen Terns", "Southfen Coots", "Tidefen Grebes", "Brinefen Curlews", "Quayfen Knots", "Millfen Ruffs", "Wickfen Dunlins", "Lockfen Snipes", "Quaywharf Godwits", "Tidewharf Whimbrels", "Brinewharf Avocets", "Saltwharf Curlews"]
const _NAMES_TWENTY_FOUR: Array = ["Lumen Reedmice", "Southspur Glass", "Pellwick Cinders", "Marrowgate Herons", "Saltmere Kites", "Ashfen Moths", "Reedfen Larks", "Cinderwharf Pikes", "Saltwharf Gulls", "Marrowfen Owls", "Ashwharf Swifts", "Pellfen Terns", "Southfen Coots", "Tidefen Grebes", "Brinefen Curlews", "Quayfen Knots", "Millfen Ruffs", "Wickfen Dunlins", "Lockfen Snipes", "Quaywharf Godwits", "Tidewharf Whimbrels", "Brinewharf Avocets", "Saltwharf Curlews", "Mudwharf Knots"]
const _NAMES_TWENTY_FIVE: Array = ["Lumen Reedmice", "Southspur Glass", "Pellwick Cinders", "Marrowgate Herons", "Saltmere Kites", "Ashfen Moths", "Reedfen Larks", "Cinderwharf Pikes", "Saltwharf Gulls", "Marrowfen Owls", "Ashwharf Swifts", "Pellfen Terns", "Southfen Coots", "Tidefen Grebes", "Brinefen Curlews", "Quayfen Knots", "Millfen Ruffs", "Wickfen Dunlins", "Lockfen Snipes", "Quaywharf Godwits", "Tidewharf Whimbrels", "Brinewharf Avocets", "Saltwharf Curlews", "Mudwharf Knots", "Reefwharf Dunlins"]
const _NAMES_TWENTY_SIX: Array = ["Lumen Reedmice", "Southspur Glass", "Pellwick Cinders", "Marrowgate Herons", "Saltmere Kites", "Ashfen Moths", "Reedfen Larks", "Cinderwharf Pikes", "Saltwharf Gulls", "Marrowfen Owls", "Ashwharf Swifts", "Pellfen Terns", "Southfen Coots", "Tidefen Grebes", "Brinefen Curlews", "Quayfen Knots", "Millfen Ruffs", "Wickfen Dunlins", "Lockfen Snipes", "Quaywharf Godwits", "Tidewharf Whimbrels", "Brinewharf Avocets", "Saltwharf Curlews", "Mudwharf Knots", "Reefwharf Dunlins", "Barwharf Sanderlings"]

const SEASONS := {
	20: {
		"weeks": 38,
		"matches": 10,
		"byes_each": 0,
		"ring": [0, 1, 2, 3, 4, 5, 12, 14, 16, 18, 19, 17, 15, 13, 6, 7, 8, 9, 10, 11],
		"appended": [0, 1, 2, 3, 4, 5, 12, 14, 16, 17, 15, 13, 6, 7, 8, 9, 10, 11, 18, 19],
		"names": _NAMES_TWENTY,
		"schedule": "Thirty-eight weeks. Each week has ten matches and no bye. A double round-robin: every club plays every other club once at home and once away, and every club has zero byes. Home is listed first and bats second.",
		"seed_rule": "Run difference is runs scored minus runs allowed. Divide the series seed by 20 and keep the remainder. Remainder 0 starts with Lumen Reedmice, remainder 1 with Southspur Glass, remainder 2 with Pellwick Cinders, remainder 3 with Marrowgate Herons, remainder 4 with Saltmere Kites, remainder 5 with Ashfen Moths, remainder 6 with Reedfen Larks, remainder 7 with Cinderwharf Pikes, remainder 8 with Saltwharf Gulls, remainder 9 with Marrowfen Owls, remainder 10 with Ashwharf Swifts, remainder 11 with Pellfen Terns, remainder 12 with Southfen Coots, remainder 13 with Tidefen Grebes, remainder 14 with Brinefen Curlews, remainder 15 with Quayfen Knots, remainder 16 with Millfen Ruffs, remainder 17 with Wickfen Dunlins, remainder 18 with Lockfen Snipes, and remainder 19 with Quaywharf Godwits. The order then walks that club list and wraps, and the earlier club is ahead.",
		"final_text": "After week 38 the top two clubs play a best-of-three final. The first club to two wins takes the series. The club that led after the league is home for game 1 and, if needed, game 3. Home alternates. A win is 2 points and a tie is 1. An equal rate is not ahead. If Lumen Reedmice finish 3rd through 20th, the season ends with no final. The final does not change the table.",
	},
	21: {
		"weeks": 42,
		"matches": 10,
		"byes_each": 2,
		"ring": [0, 1, 2, 3, 4, 5, 12, 14, 16, 18, 19, 20, 17, 15, 13, 6, 7, 8, 9, 10, 11, BYE],
		"appended": [0, 1, 2, 3, 4, 5, 12, 14, 16, 18, 19, 17, 15, 13, 6, 7, 8, 9, 10, 11, 20],
		"names": _NAMES_TWENTY_ONE,
		"schedule": "Forty-two weeks. Each week has ten matches and one bye. A double round-robin: every club plays every other club once at home and once away, and every club has two byes. Home is listed first and bats second.",
		"seed_rule": "Run difference is runs scored minus runs allowed. Divide the series seed by 21 and keep the remainder. Remainder 0 starts with Lumen Reedmice, remainder 1 with Southspur Glass, remainder 2 with Pellwick Cinders, remainder 3 with Marrowgate Herons, remainder 4 with Saltmere Kites, remainder 5 with Ashfen Moths, remainder 6 with Reedfen Larks, remainder 7 with Cinderwharf Pikes, remainder 8 with Saltwharf Gulls, remainder 9 with Marrowfen Owls, remainder 10 with Ashwharf Swifts, remainder 11 with Pellfen Terns, remainder 12 with Southfen Coots, remainder 13 with Tidefen Grebes, remainder 14 with Brinefen Curlews, remainder 15 with Quayfen Knots, remainder 16 with Millfen Ruffs, remainder 17 with Wickfen Dunlins, remainder 18 with Lockfen Snipes, remainder 19 with Quaywharf Godwits, and remainder 20 with Tidewharf Whimbrels. The order then walks that club list and wraps, and the earlier club is ahead.",
		"final_text": "After week 42 the top two clubs play a best-of-three final. The first club to two wins takes the series. The club that led after the league is home for game 1 and, if needed, game 3. Home alternates. A win is 2 points and a tie is 1. An equal rate is not ahead. If Lumen Reedmice finish 3rd through 21st, the season ends with no final. The final does not change the table.",
	},
	22: {
		"weeks": 42,
		"matches": 11,
		"byes_each": 0,
		"ring": [0, 1, 2, 3, 4, 5, 12, 14, 16, 18, 19, 20, 21, 17, 15, 13, 6, 7, 8, 9, 10, 11],
		"appended": [0, 1, 2, 3, 4, 5, 12, 14, 16, 18, 19, 20, 17, 15, 13, 6, 7, 8, 9, 10, 11, BYE, 21],
		"names": _NAMES_TWENTY_TWO,
		"schedule": "Forty-two weeks. Each week has eleven matches and no bye. A double round-robin: every club plays every other club once at home and once away, and every club has zero byes. Home is listed first and bats second.",
		"seed_rule": "Run difference is runs scored minus runs allowed. Divide the series seed by 22 and keep the remainder. Remainder 0 starts with Lumen Reedmice, remainder 1 with Southspur Glass, remainder 2 with Pellwick Cinders, remainder 3 with Marrowgate Herons, remainder 4 with Saltmere Kites, remainder 5 with Ashfen Moths, remainder 6 with Reedfen Larks, remainder 7 with Cinderwharf Pikes, remainder 8 with Saltwharf Gulls, remainder 9 with Marrowfen Owls, remainder 10 with Ashwharf Swifts, remainder 11 with Pellfen Terns, remainder 12 with Southfen Coots, remainder 13 with Tidefen Grebes, remainder 14 with Brinefen Curlews, remainder 15 with Quayfen Knots, remainder 16 with Millfen Ruffs, remainder 17 with Wickfen Dunlins, remainder 18 with Lockfen Snipes, remainder 19 with Quaywharf Godwits, remainder 20 with Tidewharf Whimbrels, and remainder 21 with Brinewharf Avocets. The order then walks that club list and wraps, and the earlier club is ahead.",
		"final_text": "After week 42 the top two clubs play a best-of-three final. The first club to two wins takes the series. The club that led after the league is home for game 1 and, if needed, game 3. Home alternates. A win is 2 points and a tie is 1. An equal rate is not ahead. If Lumen Reedmice finish 3rd through 22nd, the season ends with no final. The final does not change the table.",
	},
	23: {
		"weeks": 46,
		"matches": 11,
		"byes_each": 2,
		"ring": [0, 1, 2, 3, 4, 5, 12, 14, 16, 18, 19, 20, 21, 22, 17, 15, 13, 6, 7, 8, 9, 10, 11, BYE],
		"appended": [0, 1, 2, 3, 4, 5, 12, 14, 16, 18, 19, 20, 21, 17, 15, 13, 6, 7, 8, 9, 10, 11, 22],
		"names": _NAMES_TWENTY_THREE,
		"schedule": "Forty-six weeks. Each week has eleven matches and one bye. A double round-robin: every club plays every other club once at home and once away, and every club has two byes. Home is listed first and bats second.",
		"seed_rule": "Run difference is runs scored minus runs allowed. Divide the series seed by 23 and keep the remainder. Remainder 0 starts with Lumen Reedmice, remainder 1 with Southspur Glass, remainder 2 with Pellwick Cinders, remainder 3 with Marrowgate Herons, remainder 4 with Saltmere Kites, remainder 5 with Ashfen Moths, remainder 6 with Reedfen Larks, remainder 7 with Cinderwharf Pikes, remainder 8 with Saltwharf Gulls, remainder 9 with Marrowfen Owls, remainder 10 with Ashwharf Swifts, remainder 11 with Pellfen Terns, remainder 12 with Southfen Coots, remainder 13 with Tidefen Grebes, remainder 14 with Brinefen Curlews, remainder 15 with Quayfen Knots, remainder 16 with Millfen Ruffs, remainder 17 with Wickfen Dunlins, remainder 18 with Lockfen Snipes, remainder 19 with Quaywharf Godwits, remainder 20 with Tidewharf Whimbrels, remainder 21 with Brinewharf Avocets, and remainder 22 with Saltwharf Curlews. The order then walks that club list and wraps, and the earlier club is ahead.",
		"final_text": "After week 46 the top two clubs play a best-of-three final. The first club to two wins takes the series. The club that led after the league is home for game 1 and, if needed, game 3. Home alternates. A win is 2 points and a tie is 1. An equal rate is not ahead. If Lumen Reedmice finish 3rd through 23rd, the season ends with no final. The final does not change the table.",
	},
	24: {
		"weeks": 46,
		"matches": 12,
		"byes_each": 0,
		"ring": [0, 1, 2, 3, 4, 5, 12, 14, 16, 18, 19, 20, 21, 22, 23, 17, 15, 13, 6, 7, 8, 9, 10, 11],
		"appended": [0, 1, 2, 3, 4, 5, 12, 14, 16, 18, 19, 20, 21, 22, 17, 15, 13, 6, 7, 8, 9, 10, 11, BYE, 23],
		"names": _NAMES_TWENTY_FOUR,
		"schedule": "Forty-six weeks. Each week has twelve matches and no bye. A double round-robin: every club plays every other club once at home and once away, and every club has zero byes. Home is listed first and bats second.",
		"seed_rule": "Run difference is runs scored minus runs allowed. Divide the series seed by 24 and keep the remainder. Remainder 0 starts with Lumen Reedmice, remainder 1 with Southspur Glass, remainder 2 with Pellwick Cinders, remainder 3 with Marrowgate Herons, remainder 4 with Saltmere Kites, remainder 5 with Ashfen Moths, remainder 6 with Reedfen Larks, remainder 7 with Cinderwharf Pikes, remainder 8 with Saltwharf Gulls, remainder 9 with Marrowfen Owls, remainder 10 with Ashwharf Swifts, remainder 11 with Pellfen Terns, remainder 12 with Southfen Coots, remainder 13 with Tidefen Grebes, remainder 14 with Brinefen Curlews, remainder 15 with Quayfen Knots, remainder 16 with Millfen Ruffs, remainder 17 with Wickfen Dunlins, remainder 18 with Lockfen Snipes, remainder 19 with Quaywharf Godwits, remainder 20 with Tidewharf Whimbrels, remainder 21 with Brinewharf Avocets, remainder 22 with Saltwharf Curlews, and remainder 23 with Mudwharf Knots. The order then walks that club list and wraps, and the earlier club is ahead.",
		"final_text": "After week 46 the top two clubs play a best-of-three final. The first club to two wins takes the series. The club that led after the league is home for game 1 and, if needed, game 3. Home alternates. A win is 2 points and a tie is 1. An equal rate is not ahead. If Lumen Reedmice finish 3rd through 24th, the season ends with no final. The final does not change the table.",
	},
	25: {
		"weeks": 50,
		"matches": 12,
		"byes_each": 2,
		"ring": [0, 1, 2, 3, 4, 5, 12, 14, 16, 18, 19, 20, 21, 22, 23, 24, 17, 15, 13, 6, 7, 8, 9, 10, 11, BYE],
		"appended": [0, 1, 2, 3, 4, 5, 12, 14, 16, 18, 19, 20, 21, 22, 23, 17, 15, 13, 6, 7, 8, 9, 10, 11, 24],
		"names": _NAMES_TWENTY_FIVE,
		"schedule": "Fifty weeks. Each week has twelve matches and one bye. A double round-robin: every club plays every other club once at home and once away, and every club has two byes. Home is listed first and bats second.",
		"seed_rule": "Run difference is runs scored minus runs allowed. Divide the series seed by 25 and keep the remainder. Remainder 0 starts with Lumen Reedmice, remainder 1 with Southspur Glass, remainder 2 with Pellwick Cinders, remainder 3 with Marrowgate Herons, remainder 4 with Saltmere Kites, remainder 5 with Ashfen Moths, remainder 6 with Reedfen Larks, remainder 7 with Cinderwharf Pikes, remainder 8 with Saltwharf Gulls, remainder 9 with Marrowfen Owls, remainder 10 with Ashwharf Swifts, remainder 11 with Pellfen Terns, remainder 12 with Southfen Coots, remainder 13 with Tidefen Grebes, remainder 14 with Brinefen Curlews, remainder 15 with Quayfen Knots, remainder 16 with Millfen Ruffs, remainder 17 with Wickfen Dunlins, remainder 18 with Lockfen Snipes, remainder 19 with Quaywharf Godwits, remainder 20 with Tidewharf Whimbrels, remainder 21 with Brinewharf Avocets, remainder 22 with Saltwharf Curlews, remainder 23 with Mudwharf Knots, and remainder 24 with Reefwharf Dunlins. The order then walks that club list and wraps, and the earlier club is ahead.",
		"final_text": "After week 50 the top two clubs play a best-of-three final. The first club to two wins takes the series. The club that led after the league is home for game 1 and, if needed, game 3. Home alternates. A win is 2 points and a tie is 1. An equal rate is not ahead. If Lumen Reedmice finish 3rd through 25th, the season ends with no final. The final does not change the table.",
	},
	26: {
		"weeks": 50,
		"matches": 13,
		"byes_each": 0,
		"ring": [0, 1, 2, 3, 4, 5, 12, 14, 16, 18, 19, 20, 21, 22, 23, 24, 25, 17, 15, 13, 6, 7, 8, 9, 10, 11],
		"appended": [0, 1, 2, 3, 4, 5, 12, 14, 16, 18, 19, 20, 21, 22, 23, 24, 17, 15, 13, 6, 7, 8, 9, 10, 11, BYE, 25],
		"names": _NAMES_TWENTY_SIX,
		"schedule": "Fifty weeks. Each week has thirteen matches and no bye. A double round-robin: every club plays every other club once at home and once away, and every club has zero byes. Home is listed first and bats second.",
		"seed_rule": "Run difference is runs scored minus runs allowed. Divide the series seed by 26 and keep the remainder. Remainder 0 starts with Lumen Reedmice, remainder 1 with Southspur Glass, remainder 2 with Pellwick Cinders, remainder 3 with Marrowgate Herons, remainder 4 with Saltmere Kites, remainder 5 with Ashfen Moths, remainder 6 with Reedfen Larks, remainder 7 with Cinderwharf Pikes, remainder 8 with Saltwharf Gulls, remainder 9 with Marrowfen Owls, remainder 10 with Ashwharf Swifts, remainder 11 with Pellfen Terns, remainder 12 with Southfen Coots, remainder 13 with Tidefen Grebes, remainder 14 with Brinefen Curlews, remainder 15 with Quayfen Knots, remainder 16 with Millfen Ruffs, remainder 17 with Wickfen Dunlins, remainder 18 with Lockfen Snipes, remainder 19 with Quaywharf Godwits, remainder 20 with Tidewharf Whimbrels, remainder 21 with Brinewharf Avocets, remainder 22 with Saltwharf Curlews, remainder 23 with Mudwharf Knots, remainder 24 with Reefwharf Dunlins, and remainder 25 with Barwharf Sanderlings. The order then walks that club list and wraps, and the earlier club is ahead.",
		"final_text": "After week 50 the top two clubs play a best-of-three final. The first club to two wins takes the series. The club that led after the league is home for game 1 and, if needed, game 3. Home alternates. A win is 2 points and a tie is 1. An equal rate is not ahead. If Lumen Reedmice finish 3rd through 26th, the season ends with no final. The final does not change the table.",
	},
}


static func _static_init() -> void:
	use_season(26)


static func use_season(clubs: int) -> void:
	var spec: Dictionary = SEASONS[clubs]
	CLUB_COUNT = clubs
	SERIES_WEEKS = int(spec["weeks"])
	MATCHES_PER_WEEK = int(spec["matches"])
	BYES_EACH = int(spec["byes_each"])
	GAMES_EACH = SERIES_WEEKS - BYES_EACH
	RING = (spec["ring"] as Array).duplicate()
	APPENDED_RING = (spec["appended"] as Array).duplicate()
	CLUB_NAMES = (spec["names"] as Array).duplicate()
	SCHEDULE_TEXT = str(spec["schedule"])
	SEED_RULE = str(spec["seed_rule"])
	FINAL_TEXT = str(spec["final_text"])

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
	# Every club is dealt the same stat lines. Later clubs are shuffled copies
	# so no club is generated stronger than another, and none share objects.
	# Each later club is one more shuffle, so the earlier sheets stay put.
	# Quaywharf Godwits are the shuffle after Lockfen Snipes. Tidewharf Whimbrels
	# are one more shuffle after Quaywharf Godwits. Brinewharf Avocets are one
	# more shuffle after Tidewharf Whimbrels. Saltwharf Curlews are one more
	# shuffle after Brinewharf Avocets. Mudwharf Knots are one more shuffle
	# after Saltwharf Curlews. Reefwharf Dunlins are one more shuffle after
	# Mudwharf Knots. Barwharf Sanderlings are one more shuffle after Reefwharf
	# Dunlins. A smaller season stops before the extra shuffle, so the earlier
	# sheets stay put.
	var sheets: Array = [lines]
	for _club in CLUB_COUNT - 1:
		var copy_lines: Array = []
		for stats in lines:
			var copy := {}
			for key in STATS:
				copy[key] = int(stats[key])
			copy_lines.append(copy)
		_shuffle(rng, copy_lines)
		sheets.append(copy_lines)
	var used := {}
	var rosters: Array = []
	for _club in CLUB_COUNT:
		rosters.append([])
	for i in ROSTER_SIZE:
		for club_index in CLUB_COUNT:
			rosters[club_index].append(make_player(_unique_name(rng, used), sheets[club_index][i]))
	return {
		"town": TOWN,
		"clubs": CLUB_NAMES.duplicate(),
		"rosters": rosters,
		"player_club": PLAYER_CLUB,
		"opponent_club": OPPONENT_CLUB,
		"third_club": THIRD_CLUB,
		"fourth_club": FOURTH_CLUB,
		"fifth_club": FIFTH_CLUB,
		"sixth_club": SIXTH_CLUB,
		"seventh_club": SEVENTH_CLUB,
		"eighth_club": EIGHTH_CLUB,
		"ninth_club": NINTH_CLUB,
		"tenth_club": TENTH_CLUB,
		"eleventh_club": ELEVENTH_CLUB,
		"twelfth_club": TWELFTH_CLUB,
		"thirteenth_club": THIRTEENTH_CLUB,
		"fourteenth_club": FOURTEENTH_CLUB,
		"fifteenth_club": FIFTEENTH_CLUB,
		"sixteenth_club": SIXTEENTH_CLUB,
		"seventeenth_club": SEVENTEENTH_CLUB,
		"eighteenth_club": EIGHTEENTH_CLUB,
		"nineteenth_club": NINETEENTH_CLUB,
		"twentieth_club": TWENTIETH_CLUB,
		"twenty_first_club": TWENTY_FIRST_CLUB if CLUB_COUNT > 20 else "",
		"twenty_second_club": TWENTY_SECOND_CLUB if CLUB_COUNT > 21 else "",
		"twenty_third_club": TWENTY_THIRD_CLUB if CLUB_COUNT > 22 else "",
		"twenty_fourth_club": TWENTY_FOURTH_CLUB if CLUB_COUNT > 23 else "",
		"twenty_fifth_club": TWENTY_FIFTH_CLUB if CLUB_COUNT > 24 else "",
		"twenty_sixth_club": TWENTY_SIXTH_CLUB if CLUB_COUNT > 25 else "",
		"player_roster": rosters[0],
		"opponent_roster": rosters[1],
		"third_roster": rosters[2],
		"fourth_roster": rosters[3],
		"fifth_roster": rosters[4],
		"sixth_roster": rosters[5],
		"seventh_roster": rosters[6],
		"eighth_roster": rosters[7],
		"ninth_roster": rosters[8],
		"tenth_roster": rosters[9],
		"eleventh_roster": rosters[10],
		"twelfth_roster": rosters[11],
		"thirteenth_roster": rosters[12],
		"fourteenth_roster": rosters[13],
		"fifteenth_roster": rosters[14],
		"sixteenth_roster": rosters[15],
		"seventeenth_roster": rosters[16],
		"eighteenth_roster": rosters[17],
		"nineteenth_roster": rosters[18],
		"twentieth_roster": rosters[19],
		"twenty_first_roster": rosters[20] if rosters.size() > 20 else [],
		"twenty_second_roster": rosters[21] if rosters.size() > 21 else [],
		"twenty_third_roster": rosters[22] if rosters.size() > 22 else [],
		"twenty_fourth_roster": rosters[23] if rosters.size() > 23 else [],
		"twenty_fifth_roster": rosters[24] if rosters.size() > 24 else [],
		"twenty_sixth_roster": rosters[25] if rosters.size() > 25 else [],
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
	var tactic: String = TACTICS[(week + club_index) % TACTICS.size()]
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


# Hold the last seat. Left-rotate the other seats, including the first.
# The last seat is a club in an even circle and the bye in the twenty-one-club
# circle and in the twenty-five-club circle. The twenty-two-club,
# twenty-four-club, and twenty-six-club circles are even, so the last seat is
# Pellfen Terns and there is no bye. Rotating every seat, including the last,
# is not the season.
static func rotate_ring(ring: Array) -> void:
	var last = ring[ring.size() - 1]
	ring.remove_at(ring.size() - 1)
	var first = ring[0]
	ring.remove_at(0)
	ring.append(first)
	ring.append(last)


static func outside_in(ring: Array) -> Array:
	var pairs: Array = []
	var last := ring.size() - 1
	for i in int(ring.size() / 2):
		pairs.append([int(ring[i]), int(ring[last - i])])
	return pairs


static func _ring_for_week(week: int) -> Array:
	var ring: Array = RING.duplicate()
	var half := int(SERIES_WEEKS / 2)
	var turn := week % half
	for _step in turn:
		rotate_ring(ring)
	return ring


static func _playing_pairs(ring: Array) -> Array:
	var pairs: Array = []
	for pair in outside_in(ring):
		if int(pair[0]) == BYE or int(pair[1]) == BYE:
			continue
		pairs.append([int(pair[0]), int(pair[1])])
	return pairs


static func week_pairs(week: int) -> Array:
	var pairs := _playing_pairs(_ring_for_week(week))
	if week >= int(SERIES_WEEKS / 2):
		var flipped: Array = []
		for pair in pairs:
			flipped.append([int(pair[1]), int(pair[0])])
		return flipped
	return pairs


static func week_bye(week: int) -> int:
	for pair in outside_in(_ring_for_week(week)):
		if int(pair[0]) == BYE:
			return int(pair[1])
		if int(pair[1]) == BYE:
			return int(pair[0])
	return -1


static func week_fixtures(week: int) -> Array:
	var cards: Array = []
	var bye := week_bye(week)
	for pair in week_pairs(week):
		var home := int(pair[0])
		var away := int(pair[1])
		var card := {
			"home": home,
			"away": away,
			"slot": cards.size(),
			"home_club": str(CLUB_NAMES[home]),
			"away_club": str(CLUB_NAMES[away]),
		}
		if bye >= 0:
			card["bye"] = bye
			card["bye_club"] = str(CLUB_NAMES[bye])
		cards.append(card)
	return cards


static func empty_table() -> Array:
	var rows: Array = []
	for club_index in CLUB_COUNT:
		rows.append({
			"index": club_index,
			"club": str(CLUB_NAMES[club_index]),
			"wins": 0,
			"losses": 0,
			"ties": 0,
			"points": 0,
			"played": 0,
			"runs_for": 0,
			"runs_against": 0,
			"run_diff": 0,
			"seed_rank": club_index,
		})
	return rows


static func _add_runs(row: Dictionary, scored: int, allowed: int) -> void:
	row["runs_for"] = int(row.get("runs_for", 0)) + scored
	row["runs_against"] = int(row.get("runs_against", 0)) + allowed
	row["run_diff"] = int(row["runs_for"]) - int(row["runs_against"])


static func apply_result_to_table(rows: Array, home_index: int, away_index: int, home_score: int, away_score: int) -> void:
	var home: Dictionary = rows[home_index]
	var away: Dictionary = rows[away_index]
	home["played"] = int(home["played"]) + 1
	away["played"] = int(away["played"]) + 1
	if home_score > away_score:
		home["wins"] = int(home["wins"]) + 1
		home["points"] = int(home["points"]) + WIN_POINTS
		away["losses"] = int(away["losses"]) + 1
	elif away_score > home_score:
		away["wins"] = int(away["wins"]) + 1
		away["points"] = int(away["points"]) + WIN_POINTS
		home["losses"] = int(home["losses"]) + 1
	else:
		home["ties"] = int(home["ties"]) + 1
		away["ties"] = int(away["ties"]) + 1
		home["points"] = int(home["points"]) + TIE_POINTS
		away["points"] = int(away["points"]) + TIE_POINTS
	_add_runs(home, home_score, away_score)
	_add_runs(away, away_score, home_score)


static func table_from_results(results: Array) -> Array:
	var rows := empty_table()
	for result in results:
		if bool(result.get("is_final", false)):
			continue
		apply_result_to_table(
			rows,
			int(result["home_index"]),
			int(result["away_index"]),
			int(result["home_score"]),
			int(result["away_score"])
		)
	return rows


static func seed_start(series_seed: int) -> int:
	var start := series_seed % CLUB_COUNT
	if start < 0:
		start += CLUB_COUNT
	return start


# Club indexes, best seed tie-break first. This uses only the series seed.
static func seed_order(series_seed: int) -> Array:
	var start := seed_start(series_seed)
	var order: Array = []
	for step in CLUB_COUNT:
		order.append((start + step) % CLUB_COUNT)
	return order


static func seed_order_names(series_seed: int) -> String:
	var names: Array = []
	for club_index in seed_order(series_seed):
		names.append(str(CLUB_NAMES[int(club_index)]))
	return ", ".join(names)


static func apply_seed_ranks(rows: Array, series_seed: int) -> void:
	var order := seed_order(series_seed)
	for place in order.size():
		rows[int(order[place])]["seed_rank"] = place


# Positive when the first row has the better points-per-game.
# Clubs that have not played rank below clubs that have.
# An equal rate returns 0. It does not put either club ahead.
static func rate_compare(a: Dictionary, b: Dictionary) -> int:
	var a_played := int(a["played"])
	var b_played := int(b["played"])
	var a_points := int(a["points"])
	var b_points := int(b["points"])
	if a_played == 0 and b_played == 0:
		return 0
	if a_played == 0:
		return -1
	if b_played == 0:
		return 1
	return a_points * b_played - b_points * a_played


# Full table order: points per game, then run difference, then series seed.
# Positive when the first row is ahead.
static func compare_rows(a: Dictionary, b: Dictionary) -> int:
	var rate := rate_compare(a, b)
	if rate != 0:
		return rate
	var run_gap := int(a.get("run_diff", 0)) - int(b.get("run_diff", 0))
	if run_gap != 0:
		return run_gap
	var a_rank := int(a.get("seed_rank", a["index"]))
	var b_rank := int(b.get("seed_rank", b["index"]))
	if a_rank != b_rank:
		return b_rank - a_rank
	return int(b["index"]) - int(a["index"])


static func ranks_ahead(a: Dictionary, b: Dictionary) -> bool:
	return compare_rows(a, b) > 0


static func sorted_table(rows: Array) -> Array:
	var copy: Array = rows.duplicate(true)
	for i in copy.size():
		var best: int = i
		for j in range(i + 1, copy.size()):
			var cmp := compare_rows(copy[j], copy[best])
			if cmp > 0 or (cmp == 0 and int(copy[j]["index"]) < int(copy[best]["index"])):
				best = j
		if best != i:
			var tmp = copy[i]
			copy[i] = copy[best]
			copy[best] = tmp
	return copy


# Home index, then away index. Home is the club ahead in the table.
static func finalist_pair(rows: Array) -> Array:
	var ordered := sorted_table(rows)
	return [int(ordered[0]["index"]), int(ordered[1]["index"])]


# Strict points-per-game. An equal rate is not ahead. The board goal itself
# is reaching the final and winning the series; this helper is only the rate rule.
static func goal_reached(rows: Array) -> bool:
	var player: Dictionary = rows[PLAYER_INDEX]
	for club_index in CLUB_COUNT:
		if club_index == PLAYER_INDEX:
			continue
		if rate_compare(player, rows[club_index]) <= 0:
			return false
	return true


# Regular matches use week 0-37 and slot 0-8. Final game N (0-based) uses week
# SERIES_WEEKS + N and slot 0. The formula stays fixed so the same series seed
# still repeats every at-bat, including every final game.
static func match_seed_for(series_seed: int, week: int, slot: int = 0) -> int:
	return series_seed * 1009 + week * 10007 + slot * 131 + 3


# game_index is 0-based. Even indexes are game 1, game 3, and later odd games:
# the club that led after the league is home.
static func final_home_away(ahead: int, trailer: int, game_index: int) -> Array:
	if game_index % 2 == 0:
		return [ahead, trailer]
	return [trailer, ahead]


static func simulate_match(
	match_seed: int,
	home_lineup: Array,
	away_lineup: Array,
	home_tactic: String,
	away_tactic: String,
	home_club: String,
	away_club: String,
	explain: bool = true
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
				resolved["explanation"] = _explain(resolved) if explain else ""
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
