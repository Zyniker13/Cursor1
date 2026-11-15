# Lowball

A six-week management slice of an invented three-inning bat-and-ball sport. You run **Lumen Reedmice** in **Lumen Quay** against **Southspur Glass**, **Pellwick Cinders**, and **Marrowgate Herons**. Players are generated. The clubs, the town, and the names are fictional.

Four clubs play a double round-robin: two matches a week for six weeks, and every club plays every other club once at home and once away. Home bats second. There is no stat bonus for batting second. A win is 2 points and a tie is 1. The office shows the whole schedule from week 1.

After week 6 the table is ordered by points per game. An equal rate is not ahead. If the rate is level, the higher run difference is ahead. If that is level too, the series seed breaks the tie: divide the seed by 4 and keep the remainder. Remainder 0 starts with Lumen Reedmice, 1 with Southspur Glass, 2 with Pellwick Cinders, and 3 with Marrowgate Herons. The order follows that list and wraps.

The top two play one final. The club ahead is home and bats second. The final does not change the table. If Lumen Reedmice finish outside the top two, the season ends on the board with no final. The board goal, on screen from the start, is to reach the final and win it. A loss or a tie in the final misses it.

The rules live in `scripts/sport.gd`. Short version:

- Three innings. Four batters a side. Each half-inning is four plate appearances, so both sides always bat.
- The field has Near, Mid, and Far zones, plus one mark. Lineup order is also the fielding assignment: slot 1 Near, slot 2 Mid, slot 3 Far, slot 4 Rover.
- Each player has six stats from 1 to 20: Lash, Eye, Legs, Glove, Arm, and Read. New players are rolled from 9 to 15.
- One tactic per match: Aggressive, Patient, or Field.
- One training focus per week. After the match, every player on a club that played gains +1 in that stat, never above 20.
- Each plate appearance is a pure function of the stats, the tactics, the zone assignment, and a seeded generator. The same seed and the same lineup always produce the same at-bats. The watch line cites the stats and the roll that decided the out, the mark, or the score.

## Play

Godot 4 is required. From the repository root:

```bash
godot --path lowball
```

Before each week, set the batting order, one tactic, and one training focus. **Watch at 1x** shows one plate appearance per second on the field. **Skip to result** jumps to the score. The other match that week is recorded with yours. After six weeks, a top-two finish opens the final with the same lineup, tactic, training, watch, and skip controls. The board then says whether the goal was met. **Restart series** begins again with the next seed.

Mouse works on every button. Keyboard: Tab then Enter, or `1`–`4` to pick a lineup slot, Left/Right to change that batter, `T` tactic, `Y` training, `W` watch, `S` skip, `N` continue, `R` restart from the office or the board.

## Test

From the repository root. The process exits 0 when every test passes and non-zero when one fails.

```bash
godot --headless --path lowball -s res://scripts/tests.gd
```

The suite checks that the fourth club is on the schedule, that every fixture is played, that a scripted series reaches and wins the final, that a scripted series misses the final, that stats stay inside 1–20, and that one seed and lineup repeat the same at-bats.
