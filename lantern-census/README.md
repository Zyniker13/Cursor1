# Lantern Census

An eighteen-floor Godot 4 slice. The guild pays for the map you carry out. Oil is the turn budget. The cellar is the first floor. The cistern is the next one. The cloister is the third. The crypt is the fourth. The ossuary is the fifth. The reliquary is the sixth. The undercroft is the seventh. The well house is the eighth. The scriptorium is the ninth. The binding is the tenth. The chart room is the eleventh. The bell loft is the twelfth. The clock room is the thirteenth. The font is the fourteenth. The apse is the fifteenth. The choir is the sixteenth. The rood is the seventeenth. The crossing is the eighteenth, with its own layout and its own census.

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

The Cellar, the Cistern, the Cloister, the Crypt, the Ossuary, the Reliquary, the Undercroft, the Well House, the Scriptorium, the Binding, the Chart Room, the Bell Loft, the Clock Room, the Font, the Apse, the Choir, the Rood, and the Crossing are listed separately. Each card says what that floor asks you to record, and whether its census is still open.

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

Hazards do not burn extra oil. They are census tiles. Stepping on a blank one inks it. On the cistern those cracks are called seeps, on the cloister they are called cinders, on the crypt they are called ash cracks, on the ossuary they are called chalk cracks, on the reliquary they are called nail cracks, on the undercroft they are called salt cracks, on the well house they are called well cracks, on the scriptorium they are called ink cracks, on the binding they are called glue cracks, on the chart room they are called chart cracks, on the bell loft they are called bell cracks, on the clock room they are called clock cracks, on the font they are called font cracks, on the apse they are called apse cracks, on the choir they are called choir cracks, on the rood they are called rood cracks, and on the crossing they are called crossing cracks; they use the same hazard rule.

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

## The Crypt

Hand-authored, 15 by 11. `S` start, `L` lift, `H` ash, `E` warden, `=` the tomb. The tomb is wall for the sheet and is drawn as a pale slab. Bumping it inks a wall. The piers beside the tomb are ordinary walls.

```
###############
#S............#
#.............#
#.#.====..#...#
#.#.====..#...#
#.#.====..#...#
#.#.====..#...#
#.............#
#............L#
#H.H.H..E..H.H#
###############
```

Record every corridor, the five ash cracks, and the crypt ring around the tomb. The ashes are `(1,9)`, `(3,9)`, `(5,9)`, `(11,9)`, and `(13,9)`. The warden stands at `(8,9)`. The ring is the 20-tile corridor cycle around the 4×4 tomb at columns 4–7 and rows 3–6: the row `(3,2)`–`(8,2)`, the sides `(3,3)` `(8,3)` `(3,4)` `(8,4)` `(3,5)` `(8,5)` `(3,6)` `(8,6)`, and the row `(3,7)`–`(8,7)`.

The full sheet is `87 × 3 + 5 × 8 + 15 = 316` coin. The shortest path to the lift is 19 steps, so the small flask has a margin of 5. A checked route that steps on every payable tile without taking a swing, then reaches the lift, costs 112 oil. The large flask holds 120, so a careful survey fits and a wandering one can still run the lamp out.

## The Ossuary

Hand-authored, 17 by 10. `S` start, `L` lift, `H` chalk, `E` warden, `x` the stack. The stack is wall for the sheet and is drawn as aged bone. Bumping it inks a wall. The piers beside the stack are ordinary walls.

```
#################
#S..............#
###........####.#
###.xxxxxx.####.#
###.xxxxxx.####.#
###.xxxxxx.####.#
###........####L#
###........####.#
#H.H.H..E..H.H.H#
#################
```

Record every corridor, the six chalk cracks, and the ossuary ring around the stack. The chalk cracks are `(1,8)`, `(3,8)`, `(5,8)`, `(11,8)`, `(13,8)`, and `(15,8)`. The warden stands at `(8,8)`. The ring is the 22-tile corridor cycle around the 6×3 stack at columns 4–9 and rows 3–5: the row `(3,2)`–`(10,2)`, the sides `(3,3)` `(10,3)` `(3,4)` `(10,4)` `(3,5)` `(10,5)`, and the row `(3,6)`–`(10,6)`.

The full sheet is `59 × 3 + 6 × 8 + 15 = 240` coin. The shortest path to the lift is 19 steps, so the small flask has a margin of 5. A checked route that steps on every payable tile without taking a swing, then reaches the lift, costs 82 oil. The large flask holds 120, so a careful survey fits and a wandering one can still run the lamp out.

## The Reliquary

Hand-authored, 16 by 12. `S` start, `L` lift, `H` nail, `E` warden, `R` the case. The case is wall for the sheet and is drawn as gilt wood. Bumping it inks a wall. The piers beside the case and the lift shaft are ordinary walls. The landing is one tile; it opens south into the nave.

```
################
#S##############
#..............#
##.#.RRR.#####.#
##...RRR.###H..#
##H#.RRR.###...#
##.#.RRR.###H..#
##.#.RRR.#####L#
##H......#######
##.......#######
##.H..E.H..H..##
################
```

Record every corridor, the seven nail cracks, and the reliquary ring around the case. The nail cracks are `(12,4)`, `(2,5)`, `(12,6)`, `(2,8)`, `(3,10)`, `(8,10)`, and `(11,10)`. The warden stands at `(6,10)`. The ring is the 20-tile corridor cycle around the 3×5 case at columns 5–7 and rows 3–7: the row `(4,2)`–`(8,2)`, the sides `(4,3)` `(8,3)` `(4,4)` `(8,4)` `(4,5)` `(8,5)` `(4,6)` `(8,6)` `(4,7)` `(8,7)`, and the row `(4,8)`–`(8,8)`.

The full sheet is `60 × 3 + 7 × 8 + 15 = 251` coin. The shortest path to the lift is 19 steps, so the small flask has a margin of 5. A checked route that steps on every payable tile without taking a swing, then reaches the lift, costs 114 oil. The large flask holds 120, so a careful survey fits and a wandering one can still run the lamp out.

## The Undercroft

Hand-authored, 15 by 13. `S` start, `L` lift, `H` salt, `E` warden, `B` the trough. The trough is wall for the sheet and is drawn as a brine trough. Bumping it inks a wall. The ribs beside the trough and the south drain are ordinary walls. The north gallery is one tile deep. Three salt cracks sit in the west niche, three on the east stair, and two in the drain.

```
###############
#S............#
#####.....###.#
#####.BBB.###H#
#.H.#.BBB.###.#
#H....BBB.###H#
#.H.#.BBB.###.#
#####.BBB.###H#
#####.BBB....L#
#####.BBB.#####
#####.....#####
#####H.E.H#####
###############
```

Record every corridor, the eight salt cracks, and the undercroft ring around the trough. The salt cracks are `(13,3)`, `(2,4)`, `(1,5)`, `(13,5)`, `(2,6)`, `(13,7)`, `(5,11)`, and `(9,11)`. The warden stands at `(7,11)`. The ring is the 24-tile corridor cycle around the 3×7 trough at columns 6–8 and rows 3–9: the row `(5,2)`–`(9,2)`, the sides `(5,3)` `(9,3)` `(5,4)` `(9,4)` `(5,5)` `(9,5)` `(5,6)` `(9,6)` `(5,7)` `(9,7)` `(5,8)` `(9,8)` `(5,9)` `(9,9)`, and the row `(5,10)`–`(9,10)`.

The full sheet is `53 × 3 + 8 × 8 + 15 = 238` coin. The shortest path to the lift is 19 steps, so the small flask has a margin of 5. A checked route that steps on every payable tile without taking a swing, then reaches the lift, costs 95 oil. The large flask holds 120, so a careful survey fits and a wandering one can still run the lamp out.

## The Well House

Hand-authored, 17 by 12. `S` start, `L` lift, `H` well crack, `E` warden, `W` the shaft. The shaft is wall for the sheet and is drawn as dark water. Bumping it inks a wall. The north gallery and the east stair are open floor. The piers beside the shaft are ordinary walls.

```
#################
#S..............#
####.......####.#
####.WWWWW.H###.#
###H.WWWWW.####.#
####.WWWWW.H###.#
###H.WWWWW.####L#
####.WWWWW.H#####
###H.WWWWW.######
####.......H#####
######HEH########
#################
```

Record every corridor, the nine well cracks, and the well ring around the shaft. The well cracks are `(11,3)`, `(3,4)`, `(11,5)`, `(3,6)`, `(11,7)`, `(3,8)`, `(11,9)`, `(6,10)`, and `(8,10)`. The warden stands at `(7,10)`. The ring is the 26-tile corridor cycle around the 5×6 shaft at columns 5–9 and rows 3–8: the row `(4,2)`–`(10,2)`, the sides `(4,3)` `(10,3)` `(4,4)` `(10,4)` `(4,5)` `(10,5)` `(4,6)` `(10,6)` `(4,7)` `(10,7)` `(4,8)` `(10,8)`, and the row `(4,9)`–`(10,9)`.

The full sheet is `46 × 3 + 9 × 8 + 15 = 225` coin. The shortest path to the lift is 19 steps, so the small flask has a margin of 5. A checked route that steps on every payable tile without taking a swing, then reaches the lift, costs 110 oil. The large flask holds 120, so a careful survey fits and a wandering one can still run the lamp out.

## The Scriptorium

Hand-authored, 18 by 14. `S` start, `L` lift, `H` ink crack, `E` warden, `D` the desk. The desk is wall for the sheet and is drawn as pale vellum. Bumping it inks a wall. The west aisle and the east run are open floor. The piers are ordinary walls.

```
##################
#S....############
#####......#######
##..H.DDDD.H######
#...#.DDDD.#######
##..H.DDDD......L#
##..H.DDDD.#######
##..#.DD...#######
##..H.DD.H########
##..#.DD.#########
##..H.DD.H########
#####....#########
#####HEH##########
##################
```

Record every corridor, the ten ink cracks, and the scriptorium ring around the desk. The ink cracks are `(4,3)`, `(11,3)`, `(4,5)`, `(4,6)`, `(4,8)`, `(9,8)`, `(4,10)`, `(9,10)`, `(5,12)`, and `(7,12)`. The warden stands at `(6,12)`. The desk is an L: a 4×4 head at columns 6–9 and rows 3–6, and a 2×4 stem at columns 6–7 and rows 7–10. The ring is the 28-tile corridor cycle around that desk: the row `(5,2)`–`(10,2)`, the head's east side `(10,3)` `(10,4)` `(10,5)` `(10,6)` `(10,7)`, the inner corner `(9,7)`, the stem's east side `(8,7)` `(8,8)` `(8,9)` `(8,10)`, the row `(5,11)`–`(8,11)`, and the west side `(5,3)` `(5,4)` `(5,5)` `(5,6)` `(5,7)` `(5,8)` `(5,9)` `(5,10)`.

The full sheet is `56 × 3 + 10 × 8 + 15 = 263` coin. The shortest path to the lift is 19 steps, so the small flask has a margin of 5. A checked route that steps on every payable tile without taking a swing, then reaches the lift, costs 108 oil. The large flask holds 120, so a careful survey fits and a wandering one can still run the lamp out.

## The Binding

Hand-authored, 16 by 13. `S` start, `L` lift, `H` glue crack, `E` warden, `P` the press. The press is wall for the sheet and is drawn as dark iron. Bumping it inks a wall. The west aisle and the south landing are open floor. The piers are ordinary walls.

```
################
#S.............#
#.#......#####.#
#.#..PPP.#####.#
#.#..PPP.#####.#
#....PPP.#####.#
#.#..PPP.#####.#
#.#..PPP.#####L#
#.#......#####.#
#.#..H..H..###.#
#..E..H..H..#..#
#H.H.H.H.H.H.H##
################
```

Record every corridor, the eleven glue cracks, and the binding ring around the press. The glue cracks are `(5,9)`, `(8,9)`, `(6,10)`, `(9,10)`, `(1,11)`, `(3,11)`, `(5,11)`, `(7,11)`, `(9,11)`, `(11,11)`, and `(13,11)`. The warden stands at `(3,10)`. The press is one solid 3×5 rectangle at columns 5–7 and rows 3–7. The ring is the 20-tile corridor cycle around that press: the row `(4,2)`–`(8,2)`, the sides `(4,3)` `(8,3)` `(4,4)` `(8,4)` `(4,5)` `(8,5)` `(4,6)` `(8,6)` `(4,7)` `(8,7)`, and the row `(4,8)`–`(8,8)`.

The full sheet is `80 × 3 + 11 × 8 + 15 = 343` coin. The shortest path to the lift is 19 steps, so the small flask has a margin of 5. A checked route that steps on every payable tile without taking a swing, then reaches the lift, costs 114 oil. The large flask holds 120, so a careful survey fits and a wandering one can still run the lamp out.

## The Chart Room

Hand-authored, 17 by 11. `S` start, `L` lift, `H` chart crack, `E` warden, `T` the table. The table is wall for the sheet and is drawn as pale chart paper. Bumping it inks a wall. The west aisle and the south landing are open floor. The piers are ordinary walls.

```
#################
#S..............#
#.######.TT.##..#
#H######.TT.##H.#
#.######.TT.##..#
#H######.TT.##..#
#.######.TT.##HL#
#H######.TT.##..#
#.######.TT.##H.#
#H.......TT.....#
#..HEH.H....H.H.#
```

Record every corridor, the twelve chart cracks, and the chart room ring around the table. The chart cracks are `(1,3)`, `(14,3)`, `(1,5)`, `(14,6)`, `(1,7)`, `(14,8)`, `(1,9)`, `(3,10)`, `(5,10)`, `(7,10)`, `(12,10)`, and `(14,10)`. The warden stands at `(4,10)`. The table is one solid 2×8 bar at columns 9–10 and rows 2–9. The ring is the 24-tile corridor cycle around that table: `(8,1)`, `(9,1)`, `(10,1)`, `(11,1)`, `(8,2)`, `(11,2)`, `(8,3)`, `(11,3)`, `(8,4)`, `(11,4)`, `(8,5)`, `(11,5)`, `(8,6)`, `(11,6)`, `(8,7)`, `(11,7)`, `(8,8)`, `(11,8)`, `(8,9)`, `(11,9)`, `(8,10)`, `(9,10)`, `(10,10)`, and `(11,10)`.

The full sheet is `65 × 3 + 12 × 8 + 15 = 306` coin. The shortest path to the lift is 19 steps, so the small flask has a margin of 5. A checked route that steps on every payable tile without taking a swing, then reaches the lift, costs 114 oil. The large flask holds 120, so a careful survey fits and a wandering one can still run the lamp out.

## The Bell Loft

Hand-authored, 15 by 14. `S` start, `L` lift, `H` bell crack, `E` warden, `Y` the bell. The bell is wall for the sheet and is drawn as bronze. Bumping it inks a wall. The west aisle and the north landing are open floor. The piers are ordinary walls.

```
###############
#S............#
#.###########.#
#H###......##.#
#.###.YYYY.##.#
#H###.YYYY.##.#
#.###.YYYY.##.#
#H###.YYYY.##.#
#.###........L#
#H###........H#
#.###.......H.#
#H.H.H.HEH.H.H#
#.#############
###############
```

Record every corridor, the thirteen bell cracks, and the bell loft ring around the bell. The bell cracks are `(1,3)`, `(1,5)`, `(1,7)`, `(1,9)`, `(13,9)`, `(12,10)`, `(1,11)`, `(3,11)`, `(5,11)`, `(7,11)`, `(9,11)`, `(11,11)`, and `(13,11)`. The warden stands at `(8,11)`. The bell is one solid 4×4 square at columns 6–9 and rows 4–7. The ring is the 20-tile corridor cycle around that bell: `(5,3)`, `(6,3)`, `(7,3)`, `(8,3)`, `(9,3)`, `(10,3)`, `(5,4)`, `(10,4)`, `(5,5)`, `(10,5)`, `(5,6)`, `(10,6)`, `(5,7)`, `(10,7)`, `(5,8)`, `(6,8)`, `(7,8)`, `(8,8)`, `(9,8)`, and `(10,8)`.

The full sheet is `69 × 3 + 13 × 8 + 15 = 326` coin. The shortest path to the lift is 19 steps, so the small flask has a margin of 5. A checked route that steps on every payable tile without taking a swing, then reaches the lift, costs 108 oil. The large flask holds 120, so a careful survey fits and a wandering one can still run the lamp out.

## The Clock Room

Hand-authored, 16 by 15. `S` start, `L` lift, `H` clock crack, `E` warden, `K` the clock. The clock is wall for the sheet and is drawn as a pale clock face. Bumping it inks a wall. Walls are dark timber. Clock cracks read as brass seams. The west aisle and the north landing are open floor. The piers are ordinary walls.

```
################
#S.............#
#.############.#
#H###.......##.#
#.###.KKKKK.##.#
#H###.KKKKK.##.#
#.###.KKKKK.##.#
#H###.KKKKK.##.#
#.###.........H#
#H###.........H#
#.###....L...HH#
#H.H.H.H..E.H.H#
#.##############
#.##############
################
```

Record every corridor, the fourteen clock cracks, and the ring around the clock. The clock cracks are `(1,3)`, `(1,5)`, `(1,7)`, `(14,8)`, `(1,9)`, `(14,9)`, `(13,10)`, `(14,10)`, `(1,11)`, `(3,11)`, `(5,11)`, `(7,11)`, `(12,11)`, and `(14,11)`. The warden stands at `(10,11)`, with open corridor immediately west at `(9,11)` and east at `(11,11)`. The clock is one solid 5×4 rectangle at columns 6–10 and rows 4–7. The ring is the 22-tile corridor cycle around that clock: `(5,3)` through `(11,3)`, the sides `(5,4)` `(11,4)` `(5,5)` `(11,5)` `(5,6)` `(11,6)` `(5,7)` `(11,7)`, and `(5,8)` through `(11,8)`.

The full sheet is `75 × 3 + 14 × 8 + 15 = 352` coin. The shortest path to the lift is 19 steps, so the small flask has a margin of 5. A checked route that steps on every payable tile without taking a swing, then reaches the lift, costs 110 oil. The large flask holds 120, so a careful survey fits and a wandering one can still run the lamp out.

## The Font

Hand-authored, 17 by 16. `S` start, `L` lift, `H` font crack, `E` warden, `N` the font. The font is wall for the sheet and is drawn as a dark stone basin. Bumping it inks a wall. Walls are damp plaster. Font cracks read as pale lime seams. The west aisle and the north landing are open floor. The piers are ordinary walls.

```
#################
#S..............#
#.#############.#
#H####......###.#
#.####.NNNN.###.#
#H####.NNNN.###.#
#.####.NNNN.###.#
#H####.NNNN.###.#
#.####.NNNN.###H#
#H####.NNNN.###H#
#.####......###.#
#H........L...HH#
#..H.H.H.E...H.H#
#H###############
#.###############
#################
```

Record every corridor, the fifteen font cracks, and the ring around the font. The font cracks are `(1,3)`, `(1,5)`, `(1,7)`, `(15,8)`, `(1,9)`, `(15,9)`, `(1,11)`, `(14,11)`, `(15,11)`, `(3,12)`, `(5,12)`, `(7,12)`, `(13,12)`, `(15,12)`, and `(1,13)`. The warden stands at `(9,12)`, with open corridor immediately west at `(8,12)` and east at `(10,12)`. The font is one solid 4×6 rectangle at columns 7–10 and rows 4–9. The ring is the 24-tile corridor cycle around that font: `(6,3)` through `(11,3)`, the sides `(6,4)` `(11,4)` `(6,5)` `(11,5)` `(6,6)` `(11,6)` `(6,7)` `(11,7)` `(6,8)` `(11,8)` `(6,9)` `(11,9)`, and `(6,10)` through `(11,10)`.

The full sheet is `73 × 3 + 15 × 8 + 15 = 354` coin. The shortest path to the lift is 19 steps, so the small flask has a margin of 5. A checked route that steps on every payable tile without taking a swing, then reaches the lift, costs 110 oil. The large flask holds 120, so a careful survey fits and a wandering one can still run the lamp out.

## The Apse

Hand-authored, 18 by 17. `S` start, `L` lift, `H` apse crack, `E` warden, `A` the apse. The apse is wall for the sheet and is drawn as pale cut stone, distinct from the font's dark basin. Bumping it inks a wall. Walls are cut limestone. Apse cracks read as gilt seams. The west aisle and the north landing are open floor. The piers are ordinary walls.

```
##################
#S...............#
#.##############.#
#H####.......###.#
#.####.AAAAA.###.#
#H####.AAAAA.###H#
#.####.AAAAA.###.#
#H####.AAAAA.###.#
#.####.AAAAA.###H#
#H####.AAAAA.###H#
#.####.......###.#
#H........L....HH#
#..H.H.H.E....H.H#
#H################
#.################
##################
##################
```

Record every corridor, the sixteen apse cracks, and the ring around the apse. The apse cracks are `(1,3)`, `(1,5)`, `(16,5)`, `(1,7)`, `(16,8)`, `(1,9)`, `(16,9)`, `(1,11)`, `(15,11)`, `(16,11)`, `(3,12)`, `(5,12)`, `(7,12)`, `(14,12)`, `(16,12)`, and `(1,13)`. The warden stands at `(9,12)`, with open corridor immediately west at `(8,12)` and east at `(10,12)`. The apse is one solid 5×6 rectangle at columns 7–11 and rows 4–9. The ring is the 26-tile corridor cycle around that apse: `(6,3)` through `(12,3)`, the sides `(6,4)` `(12,4)` `(6,5)` `(12,5)` `(6,6)` `(12,6)` `(6,7)` `(12,7)` `(6,8)` `(12,8)` `(6,9)` `(12,9)`, and `(6,10)` through `(12,10)`. Every ring tile is ordinary floor.

The full sheet is `77 × 3 + 16 × 8 + 15 = 374` coin. The shortest path to the lift is 19 steps, so the small flask has a margin of 5. A checked route that steps on every payable tile without taking a swing, then reaches the lift, costs 114 oil. The large flask holds 120, so a careful survey fits and a wandering one can still run the lamp out.

## The Choir

Hand-authored, 19 by 18. `S` start, `L` lift, `H` choir crack, `E` warden, `C` the choir. The choir is wall for the sheet and is drawn as pale timber stalls, distinct from the apse's cut stone and the font's dark basin. Bumping it inks a wall. Walls are dark oak. Choir cracks read as wax seams. The west aisle and the north landing are open floor. The piers are ordinary walls.

```
###################
#S................#
#.###############.#
#H####........###H#
#.####.CCCCCC.###.#
#H####.CCCCCC.###H#
#.####.CCCCCC.###H#
#H####.CCCCCC.###.#
#.####.CCCCCC.###H#
#H####.CCCCCC.###H#
#.####........###.#
#H........L......H#
#..H.H.H.E.....H.H#
#H#################
#.#################
###################
###################
###################
```

Record every corridor, the seventeen choir cracks, and the ring around the choir. The choir cracks are `(1,3)`, `(17,3)`, `(1,5)`, `(17,5)`, `(17,6)`, `(1,7)`, `(17,8)`, `(1,9)`, `(17,9)`, `(1,11)`, `(17,11)`, `(3,12)`, `(5,12)`, `(7,12)`, `(15,12)`, `(17,12)`, and `(1,13)`. The warden stands at `(9,12)`, with open corridor immediately west at `(8,12)` and east at `(10,12)`. The choir is one solid 6×6 rectangle at columns 7–12 and rows 4–9. The ring is the 28-tile corridor cycle around that choir: `(6,3)` through `(13,3)`, the sides `(6,4)` `(13,4)` `(6,5)` `(13,5)` `(6,6)` `(13,6)` `(6,7)` `(13,7)` `(6,8)` `(13,8)` `(6,9)` `(13,9)`, and `(6,10)` through `(13,10)`. Every ring tile is ordinary floor.

The full sheet is `81 × 3 + 17 × 8 + 15 = 394` coin. The shortest path to the lift is 19 steps, so the small flask has a margin of 5. A checked route that steps on every payable tile without taking a swing, then reaches the lift, costs 120 oil. The large flask holds 120, so a careful survey fits and a wandering one can still run the lamp out.

## The Rood

Hand-authored, 20 by 19. `S` start, `L` lift, `H` rood crack, `E` warden, `R` the rood. The rood is wall for the sheet and is drawn as a dark timber screen, distinct from the choir's pale stalls, the apse's cut stone, and the font's dark basin. Bumping it inks a wall. Walls are soot stone. Rood cracks read as iron seams. The west aisle and the north landing are open floor. The piers are ordinary walls.

The landing east of the lift was open through column 17. Those three floor tiles, `(15,11)`, `(16,11)`, and `(17,11)`, are closed into the east pier so a swing-free survey fits in the large flask. The rood, the ring, the eighteen cracks, the warden, the lift, the start, and the 19-step path are unchanged.

```
####################
#S.................#
#.################.#
#H####.........###H#
#.####.RRRRRRR.###.#
#H####.RRRRRRR.###H#
#.####.RRRRRRR.###H#
#H####.RRRRRRR.###H#
#.####.RRRRRRR.###H#
#H####.RRRRRRR.###H#
#.####.........###.#
#H........L....###H#
#..H.H.H.E......H.H#
#H##################
#.##################
####################
####################
####################
####################
```

Record every corridor, the eighteen rood cracks, and the ring around the rood. The rood cracks are `(1,3)`, `(18,3)`, `(1,5)`, `(18,5)`, `(18,6)`, `(1,7)`, `(18,7)`, `(18,8)`, `(1,9)`, `(18,9)`, `(1,11)`, `(18,11)`, `(3,12)`, `(5,12)`, `(7,12)`, `(16,12)`, `(18,12)`, and `(1,13)`. The warden stands at `(9,12)`, with open corridor immediately west at `(8,12)` and east at `(10,12)`. The lift is at `(10,11)`. The start is at `(1,1)`. The rood is one solid 7×6 rectangle at columns 7–13 and rows 4–9. The ring is the 30-tile corridor cycle around that rood: `(6,3)` through `(14,3)`, the sides `(6,4)` `(14,4)` `(6,5)` `(14,5)` `(6,6)` `(14,6)` `(6,7)` `(14,7)` `(6,8)` `(14,8)` `(6,9)` `(14,9)`, and `(6,10)` through `(14,10)`. Every ring tile is ordinary floor.

The full sheet is `82 × 3 + 18 × 8 + 15 = 405` coin. The shortest path to the lift is 19 steps, so the small flask has a margin of 5. A checked route that steps on every payable tile without taking a swing, then reaches the lift, costs 120 oil. The large flask holds 120, so a careful survey fits and a wandering one can still run the lamp out.

## The Crossing

Hand-authored, 21 by 20. `S` start, `L` lift, `H` crossing crack, `E` warden, `X` the crossing. The crossing is wall for the sheet and is drawn as a dark stone crossing, distinct from the rood's timber screen, the choir's pale stalls, and the apse's cut stone. Bumping it inks a wall. Walls are soot limestone. Crossing cracks read as iron seams. The west aisle and the north landing are open floor. The piers are ordinary walls.

The landing east of the lift was open through column 18. Those eight floor tiles, `(11,11)`, `(12,11)`, `(13,11)`, `(14,11)`, `(15,11)`, `(16,11)`, `(17,11)`, and `(18,11)`, are closed into the east pier so a swing-free survey fits in the large flask. Left open, that landing surveyed at 130 oil. The crossing, the ring, the nineteen cracks, the warden, the lift, the start, and the 19-step path are unchanged.

```
#####################
#S..................#
#.#################.#
#H####..........###H#
#.####.XXXXXXXX.###H#
#H####.XXXXXXXX.###H#
#.####.XXXXXXXX.###H#
#H####.XXXXXXXX.###H#
#.####.XXXXXXXX.###H#
#H####.XXXXXXXX.###H#
#.####..........###.#
#H........L########H#
#..H.H.H.E.......H.H#
#H###################
#.###################
#####################
#####################
#####################
#####################
#####################
```

Record every corridor, the nineteen crossing cracks, and the ring around the crossing. The crossing cracks are `(1,3)`, `(19,3)`, `(19,4)`, `(1,5)`, `(19,5)`, `(19,6)`, `(1,7)`, `(19,7)`, `(19,8)`, `(1,9)`, `(19,9)`, `(1,11)`, `(19,11)`, `(3,12)`, `(5,12)`, `(7,12)`, `(17,12)`, `(19,12)`, and `(1,13)`. The warden stands at `(9,12)`, with open corridor immediately west at `(8,12)` and east at `(10,12)`. The lift is at `(10,11)`. The start is at `(1,1)`. The crossing is one solid 8×6 rectangle at columns 7–14 and rows 4–9. The ring is the 32-tile corridor cycle around that crossing: `(6,3)` through `(15,3)`, the sides `(6,4)` `(15,4)` `(6,5)` `(15,5)` `(6,6)` `(15,6)` `(6,7)` `(15,7)` `(6,8)` `(15,8)` `(6,9)` `(15,9)`, and `(6,10)` through `(15,10)`. Every ring tile is ordinary floor.

The full sheet is `81 × 3 + 19 × 8 + 15 = 410` coin. The shortest path to the lift is 19 steps, so the small flask has a margin of 5. A checked route that steps on every payable tile without taking a swing, then reaches the lift, costs 120 oil. The large flask holds 120, so a careful survey fits and a wandering one can still run the lamp out.

## Presentation

All eighteen floors use the same code-drawn raycaster, with billboards for the warden, the swing, the hazards, and the lift. There are no imported textures. Cistern walls are cooler, the pit is teal, and the seeps read as green cracks. Cloister walls are warm limestone, the garth is a dark garden, and the cinders read as ember cracks. Crypt walls are violet stone, the tomb is a pale slab, and the ash reads as gray cracks. Ossuary walls are dry bone-stone, the stack is aged ivory, and the chalk reads as pale cracks. Reliquary walls are lacquered timber, the case is gilt wood, and the nails read as copper cracks. Undercroft walls are damp stone, the trough is dark brine, and the salt reads as pale crystals. Well house walls are dry yard stone, the shaft is dark water, and the well cracks read as wet blue seams. Scriptorium walls are lamp-lit oak, the desk is pale vellum, and the ink cracks read as blue-black seams. Binding walls are laid paper, the press is dark iron, and the glue cracks read as amber seams. Chart room walls are ink blue, the table is pale chart paper, and the chart cracks read as rust-red seams. Bell loft walls are soot, the bell is bronze, and the bell cracks read as amber seams. Clock room walls are dark timber, the clock is a pale clock face, and the clock cracks read as brass seams. Font walls are damp plaster, the font is a dark stone basin, and the font cracks read as pale lime seams. Apse walls are cut limestone, the apse is pale cut stone, and the apse cracks read as gilt seams. Choir walls are dark oak, the choir is pale timber stalls, and the choir cracks read as wax seams. Rood walls are soot stone, the rood is a dark timber screen, and the rood cracks read as iron seams. Crossing walls are soot limestone, the crossing is dark stone, and the crossing cracks read as iron seams. The sheet, the town, and the floor select are drawn in code.

## Limitations

- Eighteen floors, one warden on each. The warden does not patrol or chase.
- The same floor can be turned in again on a later extract. A finished census stays finished.
- Mouse look is optional and snaps by quarter turns. There is no sound.
- Walls are for the sheet, not for the payout.
- The automated checks cover the rules and all eighteen floors, including that the crossing's true census is accepted and a wrong, short, or swapped sheet is rejected. They do not play the window, and this slice was not given a human playtest here.
