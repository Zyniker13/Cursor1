# Lowball

A four-week management slice of an invented three-inning bat-and-ball sport. You run **Lumen Reedmice** against **Southspur Glass** in the town of **Lumen Quay**. Players are generated. The clubs, the town, and the names are fictional.

This is not a full league. Two clubs play each other for four match weeks. The board goal is on screen from the start: win at least 2 of those 4 matches.

The rules live in `scripts/sport.gd`. Short version:

- Three innings. Four batters a side. Each half-inning is four plate appearances, so both sides always bat.
- The field has Near, Mid, and Far zones, plus one mark. Lineup order is also the fielding assignment: slot 1 Near, slot 2 Mid, slot 3 Far, slot 4 Rover.
- Each player has six stats from 1 to 20: Lash, Eye, Legs, Glove, Arm, and Read. New players are rolled from 9 to 15.
- One tactic per match: Aggressive, Patient, or Field.
- One training focus per week. After the match, every player on the roster gains +1 in that stat, never above 20.
- Each plate appearance is a pure function of the stats, the tactics, the zone assignment, and a seeded generator. The same seed and the same lineup always produce the same at-bats. The watch line cites the stats and the roll that decided the out, the mark, or the score.

## Play

Godot 4 is required. From the repository root:

```bash
godot --path lowball
```

Before each week, set the batting order, one tactic, and one training focus. **Watch at 1x** shows one plate appearance per second on the field. **Skip to result** jumps to the final score. After four weeks the board says whether the goal was met. **Restart series** begins again with the next seed.

Mouse works on every button. Keyboard: Tab then Enter, or `1`–`4` to pick a lineup slot, Left/Right to change that batter, `T` tactic, `Y` training, `W` watch, `S` skip, `N` continue, `R` restart from the office or the board.

## Test

From the repository root. The process exits 0 when every test passes and non-zero when one fails.

```bash
godot --headless --path lowball -s res://scripts/tests.gd
```

The suite checks that one seed and lineup repeat the same score, that 200 random series leave both clubs able to win and keep every stat inside 1–20, that a scripted four-week series reaches the board-goal screen, that a watched match logs one explanation per plate appearance, and that generated names are only joins of the syllable list.
