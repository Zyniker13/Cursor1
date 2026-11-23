# Lowball

A forty-six-week double round-robin, then a best-of-three final, of an invented three-inning bat-and-ball sport. You run **Lumen Reedmice** in **Lumen Quay**, with **Southspur Glass**, **Pellwick Cinders**, **Marrowgate Herons**, **Saltmere Kites**, **Ashfen Moths**, **Reedfen Larks**, **Cinderwharf Pikes**, **Saltwharf Gulls**, **Marrowfen Owls**, **Ashwharf Swifts**, **Pellfen Terns**, **Southfen Coots**, **Tidefen Grebes**, **Brinefen Curlews**, **Quayfen Knots**, **Millfen Ruffs**, **Wickfen Dunlins**, **Lockfen Snipes**, **Quaywharf Godwits**, **Tidewharf Whimbrels**, **Brinewharf Avocets**, **Saltwharf Curlews**, and **Mudwharf Knots**. Players are generated. The clubs, the town, and the names are fictional.

Twelve matches are listed each week for forty-six weeks. Twenty-four clubs is even, so nobody has a bye. Weeks 1–23 are one circle. The ring keeps the even pattern from the twenty-two-club and twenty-club seasons: the last seat stays put, and the other seats, including the first, rotate one place left. Appending Mudwharf Knots to the twenty-three-club ring, which still ends in the bye, does not produce week 1. Rotating every seat, including the last, is not the season. The seats are Lumen Reedmice, Southspur Glass, Pellwick Cinders, Marrowgate Herons, Saltmere Kites, Ashfen Moths, Southfen Coots, Brinefen Curlews, Millfen Ruffs, Lockfen Snipes, Quaywharf Godwits, Tidewharf Whimbrels, Brinewharf Avocets, Saltwharf Curlews, Mudwharf Knots, Wickfen Dunlins, Quayfen Knots, Tidefen Grebes, Reedfen Larks, Cinderwharf Pikes, Saltwharf Gulls, Marrowfen Owls, Ashwharf Swifts, and Pellfen Terns. Pellfen Terns stay in the last seat. Lumen Reedmice stay in the first seat. For each seat from the outside in, the earlier seat is home and the later seat is away. Weeks 24–46 repeat those pairings with home and away reversed. Every club meets every other club once at home and once away, plays 46 games, and has zero byes. Week 1 lists, in order: Lumen Reedmice at home to Pellfen Terns, Southspur Glass at home to Ashwharf Swifts, Pellwick Cinders at home to Marrowfen Owls, Marrowgate Herons at home to Saltwharf Gulls, Saltmere Kites at home to Cinderwharf Pikes, Ashfen Moths at home to Reedfen Larks, Southfen Coots at home to Tidefen Grebes, Brinefen Curlews at home to Quayfen Knots, Millfen Ruffs at home to Wickfen Dunlins, Lockfen Snipes at home to Mudwharf Knots, Quaywharf Godwits at home to Saltwharf Curlews, and Tidewharf Whimbrels at home to Brinewharf Avocets. The office lists the whole schedule and the table from the start. Home is listed first and bats second. Batting second gives no stat bonus. You watch or skip your match. The other eleven matches that week are recorded with it. There is no bye week. Training still adds 1, capped at 20, every week. Forty-six weeks means forty-six drills.

A win is 2 points and a tie is 1. After week 46 the clubs are ordered by points per game, then run difference, then the series seed. Rates are compared as fractions. An equal rate is not ahead. Divide the series seed by 24 and keep the remainder: 0 starts with Lumen Reedmice, 1 with Southspur Glass, 2 with Pellwick Cinders, 3 with Marrowgate Herons, 4 with Saltmere Kites, 5 with Ashfen Moths, 6 with Reedfen Larks, 7 with Cinderwharf Pikes, 8 with Saltwharf Gulls, 9 with Marrowfen Owls, 10 with Ashwharf Swifts, 11 with Pellfen Terns, 12 with Southfen Coots, 13 with Tidefen Grebes, 14 with Brinefen Curlews, 15 with Quayfen Knots, 16 with Millfen Ruffs, 17 with Wickfen Dunlins, 18 with Lockfen Snipes, 19 with Quaywharf Godwits, 20 with Tidewharf Whimbrels, 21 with Brinewharf Avocets, 22 with Saltwharf Curlews, and 23 with Mudwharf Knots. The order then walks that club list and wraps, and the earlier club is ahead.

The top two play a best-of-three final. The first club to two wins takes the series. Home alternates. The club that led after the league is home for game 1 and, if needed, game 3, and for every later odd-numbered game. The other finalist is home for the even-numbered games. A tie in a final game is not a win for either side. The series continues with another game until one club has two wins. The final does not change the table. If Lumen Reedmice finish 3rd through 24th, the season ends on the board and no final is played. If Lumen Reedmice are in the final and led the league, they are home for games 1 and 3, and the opponent is home for game 2.

The board goal is on screen from the start: reach that final and win the series. Missing the final, or losing the series, misses the goal.

The rules live in `scripts/sport.gd`. Short version:

- Three innings. Four batters a side. Each half-inning is four plate appearances, so both sides always bat.
- The field has Near, Mid, and Far zones, plus one mark. Lineup order is also the fielding assignment: slot 1 Near, slot 2 Mid, slot 3 Far, slot 4 Rover.
- Each player has six stats from 1 to 20: Lash, Eye, Legs, Glove, Arm, and Read. New players are rolled from 9 to 15. The twenty-four clubs are dealt the same stat lines in different orders. Mudwharf Knots is one more shuffle after Saltwharf Curlews. The earlier twenty-three clubs keep the stat lines they already had.
- One tactic per match: Aggressive, Patient, or Field. The final uses it for every game.
- One training focus per week. After the week, every player on every club gains +1 in that club's chosen stat, never above 20. Forty-six weeks means forty-six drills, and none of them is a bye. Each final game is one more drill when the final is played. The twenty-two clubs left out of the final still drill. A missed final adds no further drill.
- Each plate appearance is a pure function of the stats, the tactics, the zone assignment, and a seeded generator. The same seed and the same lineup always produce the same at-bats, including every final game. The watch line cites the stats and the roll that decided the out, the mark, or the score.

## Play

Godot 4 is required. From the repository root:

```bash
godot --path lowball
```

Before each week, set the batting order, one tactic, and one training focus. The schedule shows the twelve matches. **Watch at 1x** shows one plate appearance per second on the field. **Skip to result** jumps to the score. The other eleven matches are recorded the same week and shown on the result. There is no bye. Watch and Skip follow Lumen Reedmice's own match. If Lumen Reedmice reach the final, the same buttons, lineup, tactic, and training play every game of the series. **Restart series** begins again with the next seed.

Mouse works on every button. Keyboard: Tab then Enter, or `1`–`4` to pick a lineup slot, Left/Right to change that batter, `T` tactic, `Y` training, `W` watch, `S` skip, `N` continue, `R` restart from the office or the board.

## Test

From the repository root. The process exits 0 when every test passes and non-zero when one fails.

```bash
godot --headless --path lowball -s res://scripts/tests.gd
```

The suite still checks the twenty-club season: seed 349 drills the lowest stat, finishes 1st, and beats Cinderwharf Pikes 2–11, 7–3, and 5–1. It still checks the twenty-one-club season: week 1 lists Southspur Glass at home to Pellfen Terns through Quaywharf Godwits at home to Tidewharf Whimbrels, Lumen Reedmice have the week 1 bye, and seed 651 drills the lowest stat, finishes 1st, and beats Ashfen Moths 4–2 and 5–3. It still checks the twenty-two-club ring and seed 631, which drills the lowest stat, finishes 1st, and beats Cinderwharf Pikes 6–4, 3–6, and 7–6, with a fixed Lash drill finishing 22nd. It still checks the twenty-three-club ring, the Lumen Reedmice week-1 bye, Quaywharf Godwits at home to Saltwharf Curlews, and seed 557, which drills the lowest stat, finishes 1st, and beats Saltmere Kites 2–8, 6–6, 9–3, 4–4, and 6–4, with a fixed Lash drill finishing 23rd. It also checks the twenty-four-club season: Mudwharf Knots is on the schedule, appending the club to the twenty-three-club bye ring is not week 1, rotating every seat including the last is not the season, week 1 sends Lockfen Snipes at home to Mudwharf Knots, every club has 46 games and zero byes, and seed 493 drills the lowest stat, finishes 1st, and beats Saltwharf Gulls 4–3 and 6–5. The office stays 1280 by 720, and the twelfth match fits on screen.
