# Lampblack

Turn-based stealth in a closed museum. The east wing has eight puzzles, the west wing has six, the north wing has six, and the south wing has six. You walk dark tiles, guards watch the lit ones, and there is no combat.

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
- `1` through `8` select an east-wing puzzle. `Shift` plus `1` through `6` selects a west-wing puzzle. `Ctrl` plus `1` through `6` selects a north-wing puzzle. `Alt` plus `1` through `6` selects a south-wing puzzle. The buttons along the bottom do the same, grouped by wing.

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

The process exits `0` when every check passes and `1` when any check fails. The suite plays each puzzle's scripted solution, rejects a watched step, checks undo, and checks the tile the guard called in puzzle 3 will step to. West-wing, north-wing, and south-wing checks also play each new solution, undo it back to the start, and step onto a watched lit tile to confirm that step still loses.

## The east wing

1. East Cloister — a dark corridor, no guards, walk to the exit.
2. The Lamp Hall — one lamp's diamond blocks the hall until you snuff it.
3. Summons — snuffing calls a guard; leave the row he will walk.
4. The Broken Gallery — cross a gap by snuffing a different lamp and leaving the gap's lamp lit.
5. Two Keepers — only the nearest guard answers; wait while the other keeps his rail.
6. The Kept Flame — snuff the hall lamp and do not snuff the lamp that keeps the gap open.
7. The Arrow — the guard's next step is the whole puzzle.
8. The West Door — snuff, wait in the alcove, then cross the lit gap.

## The west wing

9. The Lit Door — the exit itself is lit. Cross the gap, snuff the door lamp, and step through before the called guard arrives.
10. The Lower Seal — two keepers stand the same distance from the lamp. The lower number answers; the other never steps down.
11. The Broken Sightline — snuff the lamp in the middle of a guard's view so a still-lit gap goes dark to him.
12. The Second Wick — snuff a lamp to cross its floor, then relight that same lamp so the gap opens. Lighting does not call a guard.
13. The Cellar Pace — a patrol keeps the lit hall shut. Snuff it and he still takes the step he owed, then leaves the rail and holds.
14. The Second Call — the first snuff makes him hold on the road. The second snuff calls him off it.

## The north wing

15. The Dark Behind — the flame faces the hall. Only the tile behind it is dark, and that is where you snuff it.
16. The Cut Beam — a wall cuts the diamond, so the door in front of the lamp is dark. The lit hall is watched.
17. The Cold Wick — the lamp starts out. Lighting it opens the gap and calls nobody. The square in front of that wick is watched once it catches.
18. The Nearer Keeper — the keepers stand at different distances. The nearer one answers; the one under the door never moves.
19. The Far Watch — the gap stays lit. Snuff the other wick to call him off it, then cross once his watch no longer reaches.
20. The Closing Door — the lamp stands on the door. Snuff it and step through on the next turn, before he holds the exit.

## The south wing

21. The Dark Half — a north-facing lamp leaves its whole south side dark. Snuff from there and cross the lamp tile before the keeper holds it.
22. The Passing Watch — the gap stays lit. Wait while the patrol stands on the near end, then cross. Stepping on while he is there is a loss.
23. The Owed Step — snuff while the owed rail step still falls short. The arrow then points at your tile, so leave it.
24. The Fading Watch — the lamp square is watched. The lit door is not, and it stays closed until you snuff.
25. The Covered Flame — the hall lamp lights the tile behind the door lamp. Snuff the hall, then the door, and take the door before he arrives.
26. The Far Answer — the far keeper is closer to the hall lamp, so he answers. Leave the gap lamp, which would call the keeper by the door.

## Limits

There is no sound and no combat. A called guard holds on the lamp until a later snuff calls him again. Squares are drawn with Godot primitives; there is no art pack. The headless suite is the checked playthrough of all twenty-six solutions.
