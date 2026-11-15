# Lampblack

Turn-based stealth in a closed museum. The east wing has eight puzzles, the west wing has six, the north wing has six, the south wing has six, the attic has six, the cellar has six, the gallery has six, the court has six, the nave has six, the cloister has six, the porch has six, and the oriel has six. You walk dark tiles, guards watch the lit ones, and there is no combat.

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
- `1` through `8` select an east-wing puzzle. `Shift` plus `1` through `6` selects a west-wing puzzle. `Ctrl` plus `1` through `6` selects a north-wing puzzle. `Alt` plus `1` through `6` selects a south-wing puzzle. `F1` through `F6` select an attic puzzle. `F7` through `F12` select a cellar puzzle. Keypad `1` through keypad `6` select a gallery puzzle, and those keys are separate from the number row. `Shift` plus `F1` through `F6` selects a court puzzle when Alt is not also held. `Alt` plus `F1` through `F6` selects a nave puzzle when Shift is not also held. `Ctrl` plus `Shift` plus `F1` through `F6` selects a porch puzzle, and only when Alt is not also held. `Alt` plus `Shift` plus `F1` through `F6` selects an oriel puzzle, and only when Ctrl is not also held. `Ctrl` plus `F1` through `F6` without Shift stays the cloister, and only when Alt is not also held. `Shift` plus `F1` through `F6` without Alt stays the court. Plain `F1` through `F6` stay the attic. `Alt` plus `F1` through `F6` without Shift stay the nave. `Ctrl` plus `Shift` plus `F1` through `F6` without Alt stay the porch. `Ctrl` plus a number key stays the north wing. The buttons along the bottom do the same, grouped by wing.

Puzzle 1 states the rules in the banner. Gold diamonds are lamplight. Red diamonds are tiles a guard is watching. An arrow is that guard's next step.

## Rules

The authoritative text is the header of `rules/rules.gd`. Short version:

- You may enter dark floor and a dark exit. A gap can be entered only while it is lit. Lit floor is closed unless you step onto a tile a guard is actually watching, which loses.
- A lit lamp fills a Manhattan diamond in front of its facing. Walls block the light. The tile directly behind the lamp stays dark, which is where you stand to snuff it.
- Vision is a Manhattan diamond on currently lit tiles only. Dark tiles and walls block it. A sill blocks it too, even when the sill is lit, so a guard cannot see through a sill. A pane does not block it, so a guard sees lit tiles beyond a pane.
- A plate is floor. You may step onto it while it is dark. A lit plate is closed, the same as other lit floor, until the lamp covering it is snuffed.
- A bell is floor. You may step onto it while it is dark. A lit bell is closed, the same as other lit floor, until the lamp covering it is snuffed. The bell is drawn as an iron cup, separate from the brass disc of a plate.
- A grate is floor you may enter. It is never lit, even when a lamp's diamond covers its tile. Light does not stop at it: tiles past the grate still light. Because the grate itself stays dark, standing on it is not a loss, and it blocks vision the same way any dark floor does. A guard cannot enter a grate. Pathing treats it as closed, the same as a wall, so a called guard walks around it. A grate does not call a guard. A plate still calls only the nearest guard. A bell still calls every guard who can reach it, and a grate is not a path. A lit floor tile beside a grate is still refused. The grate is drawn as iron bars, separate from the iron cup of a bell and the brass disc of a plate.
- A sill is floor you may enter. A lamp lights it. Standing on a lit sill is a loss, the same as any lit floor, and a lit sill that no guard is watching is refused until that lamp is snuffed. Light stops at the sill: tiles past it stay dark even when the lamp's diamond would have reached them. That is the difference from a grate, which stays dark and lets light through. A guard cannot see through a sill. A guard cannot enter a sill. Pathing treats it as closed, the same as a wall, so a called guard walks around it. A sill calls nobody. It is never a hold. A plate still calls only the nearest guard. A bell still calls every guard who can reach it, and a sill is not a path. The sill is drawn as stone, separate from the iron bars of a grate, the iron cup of a bell, and the brass disc of a plate.
- A pane is not floor. You cannot enter it. A guard cannot enter it. Pathing treats it as closed, the same as a wall. Light does not stop at a pane. A lamp's diamond continues through it, and tiles past it light. The pane itself is never lit and is never dark floor, because nobody can stand on it. Vision does not stop at a pane. A guard sees lit tiles beyond it. A pane calls nobody. It is never a hold. A plate still calls only the nearest guard. A bell still calls every guard who can reach it, and a pane is not a path. A pane is not a wall, a sill, a grate, a plate, or a bell. A wall blocks the light and the sight. A sill is floor, is lit, and stops both the light and the sight. A grate is floor you may enter, stays dark, lets the light through, and blocks sight because it is dark. A pane lets both the light and the sight through, and neither you nor a guard can step on it. The pane is drawn as a pale sheet, separate from the stone of a sill, the iron bars of a grate, the iron cup of a bell, and the brass disc of a plate.
- Snuffing a lamp calls the nearest guard (Manhattan distance to that lamp; lowest index wins a tie). The guard takes that step on the **next** turn, after your following action. The arrow shows the tile beforehand.
- The turn you step onto a plate calls the nearest guard by that same rule, toward the plate. Waiting while you are already on it does not call again. Leaving and stepping back on does. Lighting a lamp still calls nobody.
- The turn you step onto a bell calls every guard who has a floor path to that bell. Each called guard takes the arrow step on the next turn, then walks to the bell and holds. Waiting while you are already on it does not call again. Leaving and stepping back on does. A snuff still calls only the nearest guard. A plate still calls only the nearest guard. Lighting a lamp still calls nobody. A bell pulls a guard off an existing hold. A guard with no floor path to the bell is not called and keeps the rail. A grate is not a floor path. A sill is not a floor path. A pane is not a floor path.
- A called guard walks toward the lamp, plate, or bell and then holds. Other guards keep walking their rails.
- Standing on a watched tile, or on a guard's tile, loses. Reaching the exit wins, before the guards move.

## Tests

From the repository root:

```
godot --headless --path lampblack -s res://tests/run_tests.gd
```

The process exits `0` when every check passes and `1` when any check fails. The suite plays each puzzle's scripted solution, rejects a watched step, checks undo, and checks the tile the guard called in puzzle 3 will step to. West-wing, north-wing, south-wing, attic, cellar, gallery, court, nave, and cloister checks also play each new solution, undo it back to the start, and step onto a watched lit tile to confirm that step still loses. Court checks also cover a plate that does not call twice while you wait, a return that calls again, a lit plate that is refused, and the nearer keeper answering. Nave checks also cover a bell that does not call twice while you wait, a return that calls again, a lit bell that is refused, the far keeper answering, a plate that still calls only the nearest guard, and a snuff that still calls only the nearest guard. Cloister checks also cover a grate under a lamp that can be entered, a tile past the grate that is still lit, a guard who does not see through the grate, a guard who paths around a grate, a bell that still calls every reachable guard, and a plate that still calls only the nearest guard. Porch checks also play each new solution, undo it back to the start, and step onto a watched lit sill to confirm that step still loses. They also cover a sill under a lamp that is refused while lit, a tile past the sill that stays dark, a guard who does not see through the sill, a guard who paths around a sill, a bell that still calls every reachable guard, and a plate that still calls only the nearest guard. Oriel checks also play each new solution, undo it back to the start, and step onto a watched lit tile to confirm that step still loses. They also cover a pane that lets light and sight through, a pane nobody can step on, a wall or a sill in that cell that stops the light, a grate that lets the light through, a guard who paths around a pane, a bell that still calls every reachable guard, and a plate that still calls only the nearest guard. Where a wall, a sill, or a grate in the pane's cell still clears a scripted solution, the check records that clear.

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

## The court

45. The First Plate — stepping onto a plate calls the nearest guard. Leave the square he is about to take.
46. The Quiet Wait — waiting on the plate does not call him again. Step off and back on, and the second call catches the return.
47. The Far Keeper — the plate calls the nearer guard. The farther one does not move.
48. The Lit Plate — the plate starts lit, so it is refused until that lamp is snuffed. The snuff calls him, and the later step onto the dark plate calls him again.
49. The Plate Gap — the gap beyond the plate stays lit. The plate pulls the keeper off it, then you cross while its lamp is still burning.
50. The Last Hold — the called guard walks to the plate and holds. Wait until he holds, then cross the lit gap to the exit his rail used to cover.

## The nave

51. The First Bell — stepping onto a bell calls every guard. Leave the square the nearest one is about to take.
52. The Quiet Bell — waiting on the bell does not call again. Step off and back on, and the second ring catches the return.
53. The Far Bell — both keepers answer, including the far one.
54. The Lit Bell — the bell starts lit, so it is refused until that lamp is snuffed. The snuff calls only the nearest guard. The later step onto the dark bell calls every guard.
55. The Bell Gap — the gap beyond the bell stays lit. The bell pulls the keepers off it, then you cross while its lamp is still burning.
56. The Last Ring — the called guards walk to the bell and hold. Wait until they hold, then cross the lit gap to the exit their rails used to cover.

## The cloister

57. The First Grate — the hall is lit, and the grate in it stays dark, so you cross. Leave the square the keeper is about to take.
58. The Passed Light — light crosses the grate and still lights the door beyond. That door stays closed until you snuff it.
59. The Dark Cut — the dark grate blocks the guard's sight of the lit gap beyond it. Snuff is not required for the gap if his sight no longer reaches, but the gap still has to be lit to enter.
60. The Long Road — the called guard cannot step on the grate, so he takes the longer floor road. You cross before he arrives.
61. The Lit Edge — the tile beside the grate is lit and refused. The grate itself is enterable. Snuff the edge, then leave.
62. The Last Grate — cross the grates, then the lit gap, once the keeper's road around the grate has taken him off the door.

## The porch

63. The First Sill — the sill under the lamp is lit and refused. Snuff it, then cross. The tile past the sill was already dark.
64. The Stopped Light — light stops at the sill, so the door beyond stays dark and can be entered. A grate in that cell would light the door.
65. The Seen Gap — the sill does not hide the lit gap beside it. The guard still sees that gap. Snuff the gap.
66. The Closed Walk — the called guard cannot step on the sill, so he takes the longer floor road. You cross before he arrives.
67. The Dark Past — the tile past the sill is dark even under the lamp's reach. Enter it. The sill itself is lit and refused until it is snuffed.
68. The Last Sill — snuff the sill, cross it once it is dark, and leave by the door that the stopped light left dark.

## The oriel

69. The First Pane — the pane lets the lamp light the gap beyond. A wall or a sill in that cell leaves the gap dark. You cannot step on the pane. A grate in that cell still clears the solution.
70. The Seen Room — the guard sees the lit floor beyond the pane, so stepping onto it loses. Snuff the lamp, then cross the floor the pane had left lit. A wall, a sill, or a grate in that cell still clears that snuffed crossing.
71. The Closed Sheet — the called guard cannot step on the pane, so he takes the longer floor road. You cross before he arrives. Light still passes the pane. A grate in that cell still clears the solution.
72. The Dark Beside — the tile beside the pane that the lamp does not reach stays dark and can be entered. The tile past the pane is lit because the pane lets the light through. A sill or a wall in the pane's cell leaves that far tile dark. A grate in that cell still clears the solution.
73. The Long Sight — the guard sees through the pane onto the lit gap, so the gap is watched until you snuff. Light it again with the room's second lamp, then cross. A wall or a sill leaves the gap dark. A grate in that cell still clears the solution.
74. The Last Pane — leave by the gap the pane left lit. You never step on the pane. A sill or a wall leaves that gap dark. A grate lets the light through and still clears the solution, and it hides the watched step this room still loses if you take it before the snuff.

## Limits

There is no sound and no combat. A called guard holds on the lamp, the plate, or the bell until a later snuff, plate, or bell calls him again. A grate is never a hold: guards cannot enter it, and stepping on it calls nobody. A sill is never a hold: guards cannot enter it, and stepping on it calls nobody. A pane is never a hold: nobody can enter it, and it calls nobody. Squares are drawn with Godot primitives; there is no art pack. The headless suite is the checked playthrough of all seventy-four solutions.
