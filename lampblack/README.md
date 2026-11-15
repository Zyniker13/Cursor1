# Lampblack

Turn-based stealth in a closed museum. The east wing has eight puzzles, the west wing has six, the north wing has six, the south wing has six, the attic has six, the cellar has six, and the gallery has six. You walk dark tiles, guards watch the lit ones, and there is no combat.

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
- `1` through `8` select an east-wing puzzle. `Shift` plus `1` through `6` selects a west-wing puzzle. `Ctrl` plus `1` through `6` selects a north-wing puzzle. `Alt` plus `1` through `6` selects a south-wing puzzle. `F1` through `F6` select an attic puzzle. `F7` through `F12` select a cellar puzzle. Keypad `1` through keypad `6` select a gallery puzzle, and those keys are separate from the number row. The buttons along the bottom do the same, grouped by wing.

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

The process exits `0` when every check passes and `1` when any check fails. The suite plays each puzzle's scripted solution, rejects a watched step, checks undo, and checks the tile the guard called in puzzle 3 will step to. West-wing, north-wing, south-wing, attic, cellar, and gallery checks also play each new solution, undo it back to the start, and step onto a watched lit tile to confirm that step still loses.

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

## The attic

27. The Unlit Watch — a guard watches only lit tiles. The dark hall is inside his reach, and the lit doorway is a loss.
28. The Blind Wall — walls block vision. The gap beyond the wall is lit and in reach, but he cannot see it.
29. The Barred Gap — a called guard cannot cross a gap, so he takes the longer floor road.
30. The North Step — when two roads are the same length, he breaks the tie north, then east, then south, then west.
31. The Dark Eye — a guard standing in the dark can still look into an adjacent lit tile.
32. The Early Threshold — reaching the exit wins before the guards move.

## The cellar

33. The Open Corner — a lit lamp fills a Manhattan diamond. The door sits on the diagonal, outside that diamond, so it stays dark.
34. The Brick Shade — walls block light. The door is inside the diamond, and the wall between them keeps it dark.
35. The Quiet Wick — lighting a lamp does not call a guard. Light the wick, then cross the gap he never starts toward.
36. The Earlier Keeper — a distance tie calls the lower number. The south keeper answers. The east keeper never moves.
37. The Dim Lane — dark tiles block vision. The gap is lit and in reach, and the dark square between him and the gap cuts his sight.
38. The Still Post — a called guard holds on the lamp and does not resume his rail. Snuff the west wick, wait until he holds, then cross the gap.

## The gallery

39. The Rear Shade — the tile directly behind the lamp stays dark. Snuff from that square.
40. The Late Call — snuffing calls the nearest guard, who steps on the next turn. Leave the square he is about to take.
41. The Closed Hall — lit floor that no guard is watching is refused. Snuff it, then walk the hall.
42. The Lit Crossing — a gap can be entered only while it is lit. Light the wick, then cross.
43. The Keeper's Square — sharing a tile with a guard loses, even when that square is dark and unwatched. Walk around him.
44. The Outer Ring — a guard watches a Manhattan diamond of his vision radius. The lit door outside that diamond stays closed until you snuff it.

## Limits

There is no sound and no combat. A called guard holds on the lamp until a later snuff calls him again. Squares are drawn with Godot primitives; there is no art pack. The headless suite is the checked playthrough of all forty-four solutions.
