# Lowball

A thirty-week double round-robin, then a best-of-three final, of an invented three-inning bat-and-ball sport. You run **Lumen Reedmice** in **Lumen Quay**, with **Southspur Glass**, **Pellwick Cinders**, **Marrowgate Herons**, **Saltmere Kites**, **Ashfen Moths**, **Reedfen Larks**, **Cinderwharf Pikes**, **Saltwharf Gulls**, **Marrowfen Owls**, **Ashwharf Swifts**, **Pellfen Terns**, **Southfen Coots**, **Tidefen Grebes**, and **Brinefen Curlews**. Players are generated. The clubs, the town, and the names are fictional.

Seven matches and one bye are listed each week for thirty weeks. Weeks 1–15 are one circle. The ring starts as Lumen Reedmice, Southspur Glass, Pellwick Cinders, Marrowgate Herons, Saltmere Kites, Ashfen Moths, Southfen Coots, Tidefen Grebes, Reedfen Larks, Cinderwharf Pikes, Saltwharf Gulls, Marrowfen Owls, Ashwharf Swifts, Pellfen Terns, and Brinefen Curlews. The last club has the bye, and the other fourteen are paired from the outside in. Then the whole ring rotates one place left, including the first seat. Weeks 16–30 repeat those pairings with home and away reversed and the same bye. Every club meets every other club once at home and once away, plays 28 games, and has exactly two byes. Week 1 keeps the fourteen-club opening and gives Brinefen Curlews the bye. Lumen Reedmice sit out week 2 and week 17. The office lists the whole schedule, including the bye, and the table from the start. Home is listed first and bats second. Batting second gives no stat bonus. You watch or skip your match. The other six matches that week are recorded with it. On a bye, Watch and Skip follow the first listed match, the other six are recorded with it, and the club that is off has no match stored. Training still adds 1, capped at 20, every week, including on a bye. Thirty weeks means thirty drills.

A win is 2 points and a tie is 1. After week 30 the clubs are ordered by points per game, then run difference, then the series seed. Rates are compared as fractions. An equal rate is not ahead. Divide the series seed by 15 and keep the remainder: 0 starts with Lumen Reedmice, 1 with Southspur Glass, 2 with Pellwick Cinders, 3 with Marrowgate Herons, 4 with Saltmere Kites, 5 with Ashfen Moths, 6 with Reedfen Larks, 7 with Cinderwharf Pikes, 8 with Saltwharf Gulls, 9 with Marrowfen Owls, 10 with Ashwharf Swifts, 11 with Pellfen Terns, 12 with Southfen Coots, 13 with Tidefen Grebes, and 14 with Brinefen Curlews. The order then walks that club list and wraps, and the earlier club is ahead.

The top two play a best-of-three final. The first club to two wins takes the series. Home alternates. The club that led after the league is home for game 1 and, if needed, game 3, and for every later odd-numbered game. The other finalist is home for the even-numbered games. A tie in a final game is not a win for either side. The series continues with another game until one club has two wins. The final does not change the table. If Lumen Reedmice finish 3rd through 15th, the season ends on the board and no final is played.

The board goal is on screen from the start: reach that final and win the series. Missing the final, or losing the series, misses the goal.

The rules live in `scripts/sport.gd`. Short version:

- Three innings. Four batters a side. Each half-inning is four plate appearances, so both sides always bat.
- The field has Near, Mid, and Far zones, plus one mark. Lineup order is also the fielding assignment: slot 1 Near, slot 2 Mid, slot 3 Far, slot 4 Rover.
- Each player has six stats from 1 to 20: Lash, Eye, Legs, Glove, Arm, and Read. New players are rolled from 9 to 15. The fifteen clubs are dealt the same stat lines in different orders. Brinefen Curlews is one more shuffle after Tidefen Grebes.
- One tactic per match: Aggressive, Patient, or Field. The final uses it for every game.
- One training focus per week. After the week, every player on every club gains +1 in that club's chosen stat, never above 20, including on a bye. Thirty weeks means thirty drills. Each final game is one more drill when the final is played. A missed final adds no further drill.
- Each plate appearance is a pure function of the stats, the tactics, the zone assignment, and a seeded generator. The same seed and the same lineup always produce the same at-bats, including every final game. The watch line cites the stats and the roll that decided the out, the mark, or the score.

## Play

Godot 4 is required. From the repository root:

```bash
godot --path lowball
```

Before each week, set the batting order, one tactic, and one training focus. The schedule shows the seven matches and the bye. **Watch at 1x** shows one plate appearance per second on the field. **Skip to result** jumps to the score. The other six matches are recorded the same week and shown on the result. On a bye, Watch and Skip follow the first listed match. If Lumen Reedmice reach the final, the same buttons, lineup, tactic, and training play every game of the series. **Restart series** begins again with the next seed.

Mouse works on every button. Keyboard: Tab then Enter, or `1`–`4` to pick a lineup slot, Left/Right to change that batter, `T` tactic, `Y` training, `W` watch, `S` skip, `N` continue, `R` restart from the office or the board.

## Test

From the repository root. The process exits 0 when every test passes and non-zero when one fails.

```bash
godot --headless --path lowball -s res://scripts/tests.gd
```

The suite checks that Brinefen Curlews is on the schedule, that every week has seven matches and one bye, that week 1 pairs Lumen Reedmice with Pellfen Terns, Southspur Glass with Ashwharf Swifts, Pellwick Cinders with Marrowfen Owls, Marrowgate Herons with Saltwharf Gulls, Saltmere Kites with Cinderwharf Pikes, Ashfen Moths with Reedfen Larks, and Southfen Coots with Tidefen Grebes, and that Brinefen Curlews has the bye, that Lumen Reedmice sit out week 2 and week 17, that every club has 28 games and two byes, that one seed and lineup repeat the same at-bats including the final games, that stats stay inside 1–20, that a scripted series wins the final, that a scripted series reaches a third game, that a tied final game continues the series, that a scripted miss ends with no final, that a watched match logs one explanation per plate appearance, and that generated names are only joins of the syllable list.
