# Lowball

An eight-week round-robin of an invented three-inning bat-and-ball sport. You run **Lumen Reedmice** in **Lumen Quay**, with **Southspur Glass** and **Pellwick Cinders**. Players are generated. The clubs, the town, and the names are fictional.

One match is played each week. The club left out has the bye. Weeks 1–3 are a round-robin, weeks 4–6 repeat those pairings with home reversed, and weeks 7–8 start a third pass. The office lists the whole schedule and the table from the start. Home is listed first and bats second. Batting second gives no stat bonus.

The board goal is on screen from the start: finish with a better points-per-game than both other clubs. A win is 2 points and a tie is 1. An equal rate is not ahead. The clubs do not play the same number of games, which is why the goal uses the rate.

The rules live in `scripts/sport.gd`. Short version:

- Three innings. Four batters a side. Each half-inning is four plate appearances, so both sides always bat.
- The field has Near, Mid, and Far zones, plus one mark. Lineup order is also the fielding assignment: slot 1 Near, slot 2 Mid, slot 3 Far, slot 4 Rover.
- Each player has six stats from 1 to 20: Lash, Eye, Legs, Glove, Arm, and Read. New players are rolled from 9 to 15. The three clubs are dealt the same stat lines in different orders.
- One tactic per match: Aggressive, Patient, or Field. On a bye the tactic waits.
- One training focus per week. After the week, every player on every club gains +1 in that club's chosen stat, never above 20, including the club on a bye.
- Each plate appearance is a pure function of the stats, the tactics, the zone assignment, and a seeded generator. The same seed and the same lineup always produce the same at-bats. The watch line cites the stats and the roll that decided the out, the mark, or the score.

## Play

Godot 4 is required. From the repository root:

```bash
godot --path lowball
```

Before each week, set the batting order, one tactic, and one training focus. The schedule shows who plays and who has the bye. **Watch at 1x** shows one plate appearance per second on the field. **Skip to result** jumps to the final score. On a bye, those buttons follow the other match. After eight weeks the board says whether the goal was met. **Restart series** begins again with the next seed.

Mouse works on every button. Keyboard: Tab then Enter, or `1`–`4` to pick a lineup slot, Left/Right to change that batter, `T` tactic, `Y` training, `W` watch, `S` skip, `N` continue, `R` restart from the office or the board.

## Test

From the repository root. The process exits 0 when every test passes and non-zero when one fails.

```bash
godot --headless --path lowball -s res://scripts/tests.gd
```

The suite checks that one seed and lineup repeat the same at-bats, that 200 random series leave all three clubs able to win and keep every stat inside 1–20, that a scripted eight-week series reaches the board, that week 8 is played, that Pellwick Cinders appears, that a watched match logs one explanation per plate appearance, and that generated names are only joins of the syllable list.
