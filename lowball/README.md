# Lowball

An eight-week round-robin, then one final, of an invented three-inning bat-and-ball sport. You run **Lumen Reedmice** in **Lumen Quay**, with **Southspur Glass** and **Pellwick Cinders**. Players are generated. The clubs, the town, and the names are fictional.

One match is played each week. The club left out has the bye. Weeks 1–3 are a round-robin, weeks 4–6 repeat those pairings with home reversed, and weeks 7–8 start a third pass. The office lists the whole schedule and the table from the start. Home is listed first and bats second. Batting second gives no stat bonus.

After week 8, the two clubs with the best points-per-game play one final. The club ahead in the table is home. A win is 2 points and a tie is 1. An equal rate is not ahead. Ties in the table break by run difference, then by the existing series seed. Run difference is runs scored minus runs allowed. Divide the series seed by 3 and keep the remainder: 0 starts with Lumen Reedmice, 1 with Southspur Glass, and 2 with Pellwick Cinders. The order then walks that club list and wraps, and the earlier club is ahead. The final does not change the table.

The board goal is on screen from the start: reach that final and win it. If Lumen Reedmice miss the final, the season ends on the board and no final is played.

The rules live in `scripts/sport.gd`. Short version:

- Three innings. Four batters a side. Each half-inning is four plate appearances, so both sides always bat.
- The field has Near, Mid, and Far zones, plus one mark. Lineup order is also the fielding assignment: slot 1 Near, slot 2 Mid, slot 3 Far, slot 4 Rover.
- Each player has six stats from 1 to 20: Lash, Eye, Legs, Glove, Arm, and Read. New players are rolled from 9 to 15. The three clubs are dealt the same stat lines in different orders.
- One tactic per match: Aggressive, Patient, or Field. On a bye the tactic waits. The final uses it.
- One training focus per week. After the week, every player on every club gains +1 in that club's chosen stat, never above 20, including the club on a bye. The final is one more drill when it is played.
- Each plate appearance is a pure function of the stats, the tactics, the zone assignment, and a seeded generator. The same seed and the same lineup always produce the same at-bats. The watch line cites the stats and the roll that decided the out, the mark, or the score.

## Play

Godot 4 is required. From the repository root:

```bash
godot --path lowball
```

Before each week, set the batting order, one tactic, and one training focus. The schedule shows who plays and who has the bye. **Watch at 1x** shows one plate appearance per second on the field. **Skip to result** jumps to the final score. On a bye, those buttons follow the other match. If Lumen Reedmice reach the final, the same buttons, lineup, tactic, and training play that match. **Restart series** begins again with the next seed.

Mouse works on every button. Keyboard: Tab then Enter, or `1`–`4` to pick a lineup slot, Left/Right to change that batter, `T` tactic, `Y` training, `W` watch, `S` skip, `N` continue, `R` restart from the office or the board.

## Test

From the repository root. The process exits 0 when every test passes and non-zero when one fails.

```bash
godot --headless --path lowball -s res://scripts/tests.gd
```

The suite checks that one seed and lineup repeat the same at-bats, that 200 random series leave all three clubs able to win and keep every stat inside 1–20, that week 8 is played, that Pellwick Cinders appears, that a scripted series reaches and wins the final, that a scripted series misses the final, that a watched match logs one explanation per plate appearance, and that generated names are only joins of the syllable list.
