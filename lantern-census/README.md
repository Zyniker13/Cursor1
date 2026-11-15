# Lantern Census

A one-floor Godot 4 slice. The guild pays for the map you carry out. Oil is the turn budget.

## Play

Requires Godot 4.7 (the `godot` binary on `PATH`). From the repository root:

```
godot --path lantern-census
```

## Tests

Headless, and the process exits non-zero if a check fails. From the repository root:

```
godot --headless --path lantern-census -s res://tests/run_tests.gd
```

## Town

Two stops sit on one street.

- The outfitter sells one larger oil flask. The purse starts at 0, so the first descent cannot buy it and is played on the small flask.
- The guild clerk turns in the sheet from a lift extract and shows the payout split into corridors, hazards, and the east-square loop.

Restart, on the town screen, clears the purse and puts the small flask back.

The single instruction line in town is:

> Arrows turn and step, Q and E strafe, M marks the tile you face, and Space waits out the warden's swing.

## Controls

| Key | Action | Oil |
| --- | --- | --- |
| Left / A | Turn left | free |
| Right / D | Turn right | free |
| Up / W | Step forward | 1 |
| Down / S | Step back | 1 |
| Q | Strafe left | 1 |
| E | Strafe right | 1 |
| Space | Wait | 1 |
| M | Cycle the faced tile: wall, hazard, corridor, clear | free |
| Esc | Leave the floor with no payout | free |
| Hold right mouse and move | Turn (optional) | free |

Enter, Space, or Esc on the closing banner returns to town. The field sheet beside the view is the census you are filling in. Blank squares are uninked. The ring and the hood are live overlays, not ink, and they are not paid.

Walking onto a blank floor inks it as a corridor. Walking onto a blank hazard inks it as a hazard. Bumping a blank wall inks the wall. A mark you set with M is kept if you step on that tile later. Walls can be inked, and the clerk does not pay for them.

## Oil, the warden, and the lamp

Every step, strafe, or wait drinks 1 oil. Turns and marks do not, and they do not move the warden's swing.

The warden stands on one tile and never moves. It telegraphs the tile it will hit, alternating between the open tile to its east and the open tile to its west, starting with the east tile. At the end of an oil-spending action, if you are standing on the telegraphed tile, the swing hits.

A hit burns 3 oil on top of the action's 1 oil. The hit does not end the descent while any oil remains. Oil at 0 puts the lamp out, ends the descent, and the sheet pays nothing. Stepping onto the lift extracts you even when that step spends your last oil.

Hazards do not burn extra oil. They are census tiles. Stepping on a blank one inks it.

## Payout

Paid only when you ride the lift. Abandoning or running the lamp out pays 0.

```
corridor_pay = 3 × (true corridor tiles marked corridor)
hazard_pay   = 8 × (true hazard tiles marked hazard)
loop_pay     = 15 if all four east-square tiles are marked corridor, else 0
total        = corridor_pay + hazard_pay + loop_pay
```

Corridor tiles are the open floors and the lift. The warden's own tile is not a corridor. Hazard tiles are the two cracks. The east square is the 2×2 loop at `(8,3)`, `(9,3)`, `(9,4)`, and `(8,4)`, with the origin at the top-left of the sheet and `y` increasing south.

A mark that does not match the floor adds nothing. A false hazard mark does not increase hazard pay or the total. A full accurate sheet pays more than a sheet missing any corridor, any hazard, or the loop.

On this floor the full sheet is `60 × 3 + 2 × 8 + 15 = 211` coin. The small flask is 24 oil, which is the shortest path to the lift plus a margin of at least 4. The large flask is 120 oil and costs 40 coin.

## Floor

Hand-authored, 13 by 11. `S` start, `L` lift, `H` hazard, `E` warden, `#` wall.

```
#############
#S...#......#
#.##.#.####.#
#.#H...#..#.#
#.####.#..#.#
#...E..#....#
###.##.######
#...#......H#
#.###.#####.#
#.........L.#
#############
```

The view is a raycaster drawn in code, with billboards for the warden, the swing, the hazards, and the lift. There are no imported textures.

## Limitations

- One floor and one enemy. The warden does not patrol or chase.
- The same floor can be turned in again on a later extract.
- Mouse look is optional and snaps by quarter turns. There is no sound.
- Walls are for the sheet, not for the payout.
- A checked route that steps on every payable tile without taking a swing, then reaches the lift, costs 101 oil. The large flask holds 120, so a careful survey fits and a wandering one can still run the lamp out.
- The automated checks cover the rules and this floor's fairness. They do not play the window, and this slice was not given a human playtest here.
