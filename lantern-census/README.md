# Lantern Census

A three-floor Godot 4 slice. The guild pays for the map you carry out. Oil is the turn budget. The cellar is the first floor. The cistern is the next one. The cloister is the third, with its own layout and its own census.

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
- The guild clerk turns in the sheet from a lift extract and shows the payout split into corridors, hazards, and that floor's ring.

Restart, on the town screen, clears the purse, every census, and puts the small flask back.

The single instruction line in town is:

> Arrows turn and step, Q and E strafe, M marks the tile you face, and Space waits out the warden's swing.

Town opens the floor select. It does not drop you straight down a shaft.

## Floor select

The Cellar, the Cistern, and the Cloister are listed separately. Each card says what that floor asks you to record, and whether its census is still open.

The small flask can reach every lift. A finished census on any floor needs the large flask.

A finished census — every payable tile marked truly, and no tile marked as something it is not — leaves the descent on **Return to floor select**. The select then says that floor's census is complete, shows the payout, and offers the other floors. **Back to town** returns to the street.

A lift extract that is not a finished census, a lamp-out, or an abandon uses **Return to town**. The clerk still pays a true partial sheet, and says the census is not finished.

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

Enter, Space, or Esc on the closing banner returns you. The field sheet beside the view is the census you are filling in. Blank squares are uninked. The swing ring and the hood are live overlays, not ink, and they are not paid.

Walking onto a blank floor inks it as a corridor. Walking onto a blank hazard inks it as a hazard. Bumping a blank wall inks the wall. A mark you set with M is kept if you step on that tile later. Walls can be inked, and the clerk does not pay for them. A true wall mark does not spoil a finished census. A mark that disagrees with the tile does.

## Oil, the warden, and the lamp

Every step, strafe, or wait drinks 1 oil. Turns and marks do not, and they do not move the warden's swing.

The warden stands on one tile and never moves. It telegraphs the tile it will hit, alternating between the open tile to its east and the open tile to its west, starting with the east tile. At the end of an oil-spending action, if you are standing on the telegraphed tile, the swing hits.

A hit burns 3 oil on top of the action's 1 oil. The hit does not end the descent while any oil remains. Oil at 0 puts the lamp out, ends the descent, and the sheet pays nothing. Stepping onto the lift extracts you even when that step spends your last oil.

Hazards do not burn extra oil. They are census tiles. Stepping on a blank one inks it. On the cistern those cracks are called seeps, and on the cloister they are called cinders; they use the same hazard rule.

## Payout

Paid only when you ride the lift. Abandoning or running the lamp out pays 0. The rates do not change between floors.

```
corridor_pay = 3 × (true corridor tiles marked corridor)
hazard_pay   = 8 × (true hazard tiles marked hazard)
loop_pay     = 15 if every tile of that floor's ring is marked corridor, else 0
total        = corridor_pay + hazard_pay + loop_pay
```

Corridor tiles are the open floors and the lift. The warden's own tile is not a corridor. A mark that does not match the floor adds nothing. A false hazard mark does not increase hazard pay or the total.

The census is accepted only when every corridor is marked corridor, every hazard is marked hazard, and every inked tile matches what is really there. Blank walls are allowed. The warden's tile stays blank. An accepted sheet is the finished census. Anything else is rejected, even when the lift still pays the true marks on it.

The small flask is 24 oil. The large flask is 120 oil and costs 40 coin.

## The Cellar

Hand-authored, 13 by 11. `S` start, `L` lift, `H` hazard, `E` warden.

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

Record every corridor, both hazard cracks, and the east square. The east square is the 2×2 ring at `(8,3)`, `(9,3)`, `(9,4)`, and `(8,4)`, with the origin at the top-left of the sheet and `y` increasing south.

The full sheet is `60 × 3 + 2 × 8 + 15 = 211` coin. The shortest path to the lift is 19 steps, so the small flask has a margin of 5. A checked route that steps on every payable tile without taking a swing, then reaches the lift, costs 101 oil.

## The Cistern

Hand-authored, 15 by 11. `S` start, `L` lift, `H` seep, `E` warden, `*` the pit. The pit is wall for the sheet and is drawn as cistern stone. Bumping it inks a wall.

```
###############
#S............#
#.###########.#
#.#.........#.#
#.#.***.....#.#
#.#.***.....#.#
#.#.***.....#.#
#.#.........#.#
#............L#
#..E..H..H.H..#
###############
```

Record every corridor, the three seep cracks, and the cistern ring around the pit. The seeps are `(6,9)`, `(9,9)`, and `(11,9)`. The warden stands at `(3,9)`. The ring is the 16-tile corridor cycle around the 3×3 pit at columns 4–6 and rows 4–6: the row `(3,3)`–`(7,3)`, the sides `(3,4)` `(7,4)` `(3,5)` `(7,5)` `(3,6)` `(7,6)`, and the row `(3,7)`–`(7,7)`.

The full sheet is `83 × 3 + 3 × 8 + 15 = 288` coin. The shortest path to the lift is 19 steps, so the small flask has a margin of 5. A checked route that steps on every payable tile without taking a swing, then reaches the lift, costs 106 oil. The large flask holds 120, so a careful survey fits and a wandering one can still run the lamp out.

## The Cloister

Hand-authored, 16 by 10. `S` start, `L` lift, `H` cinder, `E` warden, `+` the garth. The garth is wall for the sheet and is drawn as a closed garden. Bumping it inks a wall.

```
################
#S.............#
#.############.#
#.#.......####.#
#.#.+++++.####.#
#.#.+++++.####.#
#.#.......####.#
#..E..........L#
#.H.H.H.H......#
################
```

Record every corridor, the four cinder cracks, and the cloister walk around the garth. The cinders are `(2,8)`, `(4,8)`, `(6,8)`, and `(8,8)`. The warden stands at `(3,7)`. The walk is the 18-tile corridor cycle around the 5×2 garth at columns 4–8 and rows 4–5: the row `(3,3)`–`(9,3)`, the sides `(3,4)` `(9,4)` `(3,5)` `(9,5)`, and the row `(3,6)`–`(9,6)`.

The full sheet is `65 × 3 + 4 × 8 + 15 = 242` coin. The shortest path to the lift is 19 steps, so the small flask has a margin of 5. A checked route that steps on every payable tile without taking a swing, then reaches the lift, costs 88 oil. The large flask holds 120, so a careful survey fits and a wandering one can still run the lamp out.

## Presentation

All three floors use the same code-drawn raycaster, with billboards for the warden, the swing, the hazards, and the lift. There are no imported textures. Cistern walls are cooler, the pit is teal, and the seeps read as green cracks. Cloister walls are warm limestone, the garth is a dark garden, and the cinders read as ember cracks. The sheet, the town, and the floor select are drawn in code.

## Limitations

- Three floors, one warden on each. The warden does not patrol or chase.
- The same floor can be turned in again on a later extract. A finished census stays finished.
- Mouse look is optional and snaps by quarter turns. There is no sound.
- Walls are for the sheet, not for the payout.
- The automated checks cover the rules and all three floors, including that the cloister's true census is accepted and a wrong, short, or swapped sheet is rejected. They do not play the window, and this slice was not given a human playtest here.
