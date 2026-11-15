# Lampblack

Turn-based stealth in a closed museum. This is the east wing: eight puzzles. You walk dark tiles, guards watch the lit ones, and there is no combat.

## Play

Requires Godot 4.3 or newer (tested on 4.7). From the repository root:

```
godot --path lampblack
```

### Controls

- Arrow keys move one tile. Click an adjacent tile to move there.
- `F` toggles the lamp you are facing. Click a lamp on an adjacent tile to toggle it.
- If a step is blocked, you turn to face that way and the turn is not spent, so you can aim `F`.
- `Space` waits. Click your own tile to wait.
- `U` undoes the last turn, including after a loss or a win. Undo restores your position and facing, every lamp, and every guard.
- `R` restarts the puzzle.
- `1` through `8` select a puzzle. The buttons along the bottom do the same.

Puzzle 1 states the rules in the banner. Gold diamonds are lamplight. Red diamonds are tiles a guard is watching. An arrow is that guard's next step.

## Rules

The authoritative text is the header of `rules/rules.gd`. Short version:

- You may enter dark floor and a dark exit. A gap can be entered only while it is lit. Lit floor is closed unless you step onto a tile a guard is actually watching, which loses.
- A lit lamp fills a Manhattan diamond in front of its facing. Walls block the light. The tile directly behind the lamp stays dark, which is where you stand to snuff it.
- Vision is a Manhattan diamond on currently lit tiles only. Dark tiles and walls block it.
- Snuffing a lamp calls the nearest guard (Manhattan distance to that lamp; lowest index wins a tie). The guard takes that step on the **next** turn, after your following action. The arrow shows the tile beforehand.
- A called guard walks toward the lamp and then holds. Other guards keep walking their rails.
- Standing on a watched tile, or on a guard's tile, loses. Reaching the exit wins, before the guards move.

## Tests

From the repository root:

```
godot --headless --path lampblack -s res://tests/run_tests.gd
```

The process exits `0` when every check passes and `1` when any check fails. The suite plays each puzzle's scripted solution, rejects a watched step, checks undo, and checks the tile the guard called in puzzle 3 will step to.

## The wing

1. East Cloister — a dark corridor, no guards, walk to the exit.
2. The Lamp Hall — one lamp's diamond blocks the hall until you snuff it.
3. Summons — snuffing calls a guard; leave the row he will walk.
4. The Broken Gallery — cross a gap by snuffing a different lamp and leaving the gap's lamp lit.
5. Two Keepers — only the nearest guard answers; wait while the other keeps his rail.
6. The Kept Flame — snuff the hall lamp and do not snuff the lamp that keeps the gap open.
7. The Arrow — the guard's next step is the whole puzzle.
8. The West Door — snuff, wait in the alcove, then cross the lit gap.

## Limits

This is the first wing only. There is no sound and no combat. A called guard holds on the lamp instead of resuming a patrol. Squares are drawn with Godot primitives; there is no art pack. The headless suite is the checked playthrough of the eight solutions.
