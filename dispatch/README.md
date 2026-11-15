# Dispatch

A wiring puzzle. Route parcels across Building 1 and Building 2, then submit the belt. After a delivery, the game shows your cycles and block count beside par. Par is not a handwritten number: it is the result of simulating that puzzle's reference graph.

Blocks are drawn by Godot. There is no imported art.

## Run

From this directory, with Godot 4 on your PATH:

```
godot --path .
```

From the repo root:

```
godot --path dispatch
```

## Test

From this directory:

```
godot --headless --path . -s res://tests/run_tests.gd
```

The process exits non-zero if a test fails. These were written for Godot 4.7.

## Controls

Left-click an empty cell to place the selected block. Left-click a block of the same type to rotate it, or a different type to replace it. Right-click deletes. `R` rotates the block under the cursor, or the placement arrow if the cell is empty. `Delete` removes the block under the cursor. `Enter` submits. `Backspace` restarts the puzzle. Keys `1` through `8` select the first eight puzzles. `[` and `]` step to the previous or next puzzle. Puzzle 1 also prints the how-to on the board. Building 2 is routes 16 through 22, marked on the route row, and it opens after route 15.

## Simulation

Ticks are deterministic. A parcel sits on at most one cell. Sources and the dock are fixtures, not blocks, and they do not count toward the block total.

Each tick, in order:

1. A painter sets the color of a parcel standing on it. A counter increments once for that parcel and stamps the new value. A parcel is stamped only on the first tick it spends on that counter.
2. Every parcel picks a destination from the block under it.
3. Destinations that are illegal, contested by two parcels, or occupied by a parcel that is staying are cancelled. This repeats until it settles. Conveyors, painters, counters, splitters, and filters may step into a cell another parcel is leaving on the same tick.
4. The surviving moves happen together. A parcel that steps onto the dock is delivered, in order.
5. A splitter that actually sent a parcel switches to its other output.
6. Each source emits its next parcel into the cell it faces, if that cell is empty and in bounds.
7. The delivered sequence is compared with the order.

Cycles is the tick on which the last ordered parcel arrives. Block count is the number of blocks in the submitted graph. If a delivery does not match the next order line, the attempt fails. If nothing can move, emit, or release, the belt is stuck and the attempt fails. A layout that keeps moving without finishing, such as a loop, stops at tick 250 and fails.

An order line can require a color, a count, or both. A field that is left out accepts any value. Parcels start gray with count 0 unless the chute says otherwise.

Directions are 0 east, 1 south, 2 west, 3 north. On screen, +y is south, so turning a direction index forward is clockwise.

### Conveyor

Moves a parcel one step in its facing direction each tick, including into a cell that is being vacated.

### Latch

Holds a parcel, then releases it one step in its facing direction only when both are true:

1. The parcel has already spent one tick on the latch. It never leaves on the tick it arrives.
2. The destination cell contains no parcel at the start of the tick. A latch will not follow a parcel that is leaving in that same tick.

If the destination is occupied, the parcel stays. Once the opening tick has been waited, it leaves on the next tick that starts with an empty destination it is allowed to enter.

### Splitter

The facing direction is the first output. The clockwise direction is the second. Parcels alternate, starting with the facing output. The switch happens only when a parcel actually leaves.

### Painter

Sets the parcel's color, then moves it forward with the same rule as a conveyor. Painters are red, blue, or yellow.

### Counter

On the first tick a parcel spends on a counter, the counter adds one and writes that number onto the parcel, then moves the parcel forward like a conveyor. If that parcel leaves and later comes back, the counter stamps the next number over the old one.

### Filter

Sends a parcel of its own color along the arrow. Any other color leaves clockwise. The color is red, blue, or yellow, and the filter does not change the parcel. It moves every tick, including into a cell another parcel is leaving.

## Puzzles

1. First Mile introduces the conveyor. Send the parcel straight to the dock.
2. Around the Corner uses conveyors. The dock is around the corner.
3. Both of Them uses conveyors. Two parcels are due, in chute order.
4. Let It Pass introduces the latch. Hold the south parcel so the belts can merge.
5. Blue First introduces the splitter. Blue has to reach the dock before red.
6. Blue Tag introduces the painter. Paint the parcel blue.
7. Counted Three introduces the counter. Stamp counts 1, 2, and 3.
8. Night Sort uses the whole set. Paint one red and one blue, stamp them 1 then 2, and keep the merge clear.
9. Second Stamp sends a parcel around a counter so the second pass is stamped 2.
10. Fresh Coat sends red around and brings it back yellow, stamped 2.
11. One Then Three lets the first parcel leave as 1 and sends the next around to be stamped 3.
12. Blue Then Red paints the north parcel blue and holds the two reds so the stamps run 1, 2, 3.
13. The Long Way bricks in the top row. The parcel goes around the bottom and arrives yellow, stamped 2.
14. Blue After paints red before the split and blue on the loop, then delivers red 1 and blue 3.
15. Night Desk uses the whole set again. Deliver red 1, yellow 2, and blue 3.
16. Color Gate introduces the filter. Red takes the arrow. The two blues turn clockwise and arrive after it.
17. Side Coat paints the blues yellow on that south lane.
18. Stamp the Match sends red through the counter first, then the blues, so the stamps are 1, 2, and 3.
19. Hold the Blue keeps blue on a latch. Without the wait, blue and the next red lock at the counter.
20. Become Red paints the looping blue red, so the filter lets it out on the next pass. The deliveries are red 2 and red 3.
21. Two Tallies gives each color its own counter. Blues stay on the arrow. Reds turn off it.
22. Night Wing uses the splitter and the filter together. The second red is painted yellow, the first red goes through, and blue follows yellow into the counter.

## Limits

These are Building 1 and Building 2. There is no histogram, no sound, and no proof that par is the shortest possible route: par is the reference graph, and another graph can deliver the order with a different cycle count or block count. Playback of a run that hits the tick cap is shortened on screen; the simulation itself still runs to the cap.
