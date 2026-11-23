# Lowball

A forty-two-week double round-robin, then a best-of-three final, of an invented three-inning bat-and-ball sport. You run **Lumen Reedmice** in **Lumen Quay**, with **Southspur Glass**, **Pellwick Cinders**, **Marrowgate Herons**, **Saltmere Kites**, **Ashfen Moths**, **Reedfen Larks**, **Cinderwharf Pikes**, **Saltwharf Gulls**, **Marrowfen Owls**, **Ashwharf Swifts**, **Pellfen Terns**, **Southfen Coots**, **Tidefen Grebes**, **Brinefen Curlews**, **Quayfen Knots**, **Millfen Ruffs**, **Wickfen Dunlins**, **Lockfen Snipes**, **Quaywharf Godwits**, and **Tidewharf Whimbrels**. Players are generated. The clubs, the town, and the names are fictional.

Ten matches and one bye are listed each week for forty-two weeks. Twenty-one clubs is odd, so each week one club sits out. Weeks 1–21 are one circle. Appending Tidewharf Whimbrels to the twenty-club ring does not produce week 1, so that ring is not used. Rotating every seat, including the bye, is not the season. The seats are Lumen Reedmice, Southspur Glass, Pellwick Cinders, Marrowgate Herons, Saltmere Kites, Ashfen Moths, Southfen Coots, Brinefen Curlews, Millfen Ruffs, Lockfen Snipes, Quaywharf Godwits, Tidewharf Whimbrels, Wickfen Dunlins, Quayfen Knots, Tidefen Grebes, Reedfen Larks, Cinderwharf Pikes, Saltwharf Gulls, Marrowfen Owls, Ashwharf Swifts, Pellfen Terns, and a bye. The bye is the last seat and stays put. The other twenty-one seats, including the first, rotate one place left. For each seat from the outside in, the earlier seat is home and the later seat is away. The club paired with the bye sits out. Weeks 22–42 repeat those pairings with home and away reversed. Every club meets every other club once at home and once away, plays 40 games, and has two byes. Week 1 lists, in order: Southspur Glass at home to Pellfen Terns, Pellwick Cinders at home to Ashwharf Swifts, Marrowgate Herons at home to Marrowfen Owls, Saltmere Kites at home to Saltwharf Gulls, Ashfen Moths at home to Cinderwharf Pikes, Southfen Coots at home to Reedfen Larks, Brinefen Curlews at home to Tidefen Grebes, Millfen Ruffs at home to Quayfen Knots, Lockfen Snipes at home to Wickfen Dunlins, and Quaywharf Godwits at home to Tidewharf Whimbrels. Lumen Reedmice have the week 1 bye and play week 2. Lumen Reedmice stay in the first seat. The office lists the whole schedule and the table from the start. Home is listed first and bats second. Batting second gives no stat bonus. You watch or skip your match. The other nine matches that week are recorded with it. On a bye there is no match to watch. The other ten matches are recorded, and training still adds 1, capped at 20. Forty-two weeks means forty-two drills.

A win is 2 points and a tie is 1. After week 42 the clubs are ordered by points per game, then run difference, then the series seed. Rates are compared as fractions. An equal rate is not ahead. Divide the series seed by 21 and keep the remainder: 0 starts with Lumen Reedmice, 1 with Southspur Glass, 2 with Pellwick Cinders, 3 with Marrowgate Herons, 4 with Saltmere Kites, 5 with Ashfen Moths, 6 with Reedfen Larks, 7 with Cinderwharf Pikes, 8 with Saltwharf Gulls, 9 with Marrowfen Owls, 10 with Ashwharf Swifts, 11 with Pellfen Terns, 12 with Southfen Coots, 13 with Tidefen Grebes, 14 with Brinefen Curlews, 15 with Quayfen Knots, 16 with Millfen Ruffs, 17 with Wickfen Dunlins, 18 with Lockfen Snipes, 19 with Quaywharf Godwits, and 20 with Tidewharf Whimbrels. The order then walks that club list and wraps, and the earlier club is ahead.

The top two play a best-of-three final. The first club to two wins takes the series. Home alternates. The club that led after the league is home for game 1 and, if needed, game 3, and for every later odd-numbered game. The other finalist is home for the even-numbered games. A tie in a final game is not a win for either side. The series continues with another game until one club has two wins. The final does not change the table. If Lumen Reedmice finish 3rd through 21st, the season ends on the board and no final is played. If Lumen Reedmice are in the final, they are home for games 1 and 3 when they led the league, and the opponent is home for game 2.

The board goal is on screen from the start: reach that final and win the series. Missing the final, or losing the series, misses the goal.

The rules live in `scripts/sport.gd`. Short version:

- Three innings. Four batters a side. Each half-inning is four plate appearances, so both sides always bat.
- The field has Near, Mid, and Far zones, plus one mark. Lineup order is also the fielding assignment: slot 1 Near, slot 2 Mid, slot 3 Far, slot 4 Rover.
- Each player has six stats from 1 to 20: Lash, Eye, Legs, Glove, Arm, and Read. New players are rolled from 9 to 15. The twenty-one clubs are dealt the same stat lines in different orders. Tidewharf Whimbrels is one more shuffle after Quaywharf Godwits. The earlier twenty clubs keep the stat lines they already had.
- One tactic per match: Aggressive, Patient, or Field. The final uses it for every game.
- One training focus per week. After the week, every player on every club gains +1 in that club's chosen stat, never above 20. A bye week still drills. Forty-two weeks means forty-two drills. Each final game is one more drill when the final is played. The nineteen clubs left out of the final still drill. A missed final adds no further drill.
- Each plate appearance is a pure function of the stats, the tactics, the zone assignment, and a seeded generator. The same seed and the same lineup always produce the same at-bats, including every final game. The watch line cites the stats and the roll that decided the out, the mark, or the score.

## Play

Godot 4 is required. From the repository root:

```bash
godot --path lowball
```

Before each week, set the batting order, one tactic, and one training focus. The schedule shows the ten matches and the bye. **Watch at 1x** shows one plate appearance per second on the field. **Skip to result** jumps to the score. The other nine matches are recorded the same week and shown on the result. On a bye there is no match to watch. Watch and Skip record the other ten matches, and training still drills. If Lumen Reedmice reach the final, the same buttons, lineup, tactic, and training play every game of the series. **Restart series** begins again with the next seed.

Mouse works on every button. Keyboard: Tab then Enter, or `1`–`4` to pick a lineup slot, Left/Right to change that batter, `T` tactic, `Y` training, `W` watch, `S` skip, `N` continue, `R` restart from the office or the board.

## Test

From the repository root. The process exits 0 when every test passes and non-zero when one fails.

```bash
godot --headless --path lowball -s res://scripts/tests.gd
```

The suite still checks the twenty-club season: appending Quaywharf Godwits to the nineteen-club ring is not week 1, week 1 lists ten matches and ends with Lockfen Snipes at home to Quaywharf Godwits, every club has 38 games and zero byes, and seed 349 drills the lowest stat, finishes 1st, and beats Cinderwharf Pikes 2–11, 7–3, and 5–1. It also checks the twenty-one-club season: Tidewharf Whimbrels is on the schedule, appending the club to the twenty-club ring is not week 1, rotating every seat including the bye is not the season, week 1 lists ten matches and ends with Quaywharf Godwits at home to Tidewharf Whimbrels, Lumen Reedmice have the week 1 bye and play week 2, every club has 40 games and two byes, a bye week still drills, one seed and lineup repeat the same at-bats including the final games, stats stay inside 1–20, seed 651 drills the lowest stat, finishes 1st, and beats Ashfen Moths 4–2 and 5–3, a fixed Lash drill on that seed finishes 21st, a scripted series reaches a third game, a tied final game continues the series, a scripted miss ends with no final, a watched match logs one explanation per plate appearance, and generated names are only joins of the syllable list. The office stays 1280 by 720, and week 1's tenth match and the bye line both fit on screen.
