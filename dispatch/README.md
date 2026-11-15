# Dispatch

A wiring puzzle. Route parcels across Building 1, Building 2, Building 3, Building 4, Building 5, Building 6, and Building 7, then submit the belt. After a delivery, the game shows your cycles and block count beside par. Par is not a handwritten number: it is the result of simulating that puzzle's reference graph.

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

Left-click an empty cell to place the selected block. Left-click a block of the same type to rotate it, or a different type to replace it. Right-click deletes. `R` rotates the block under the cursor, or the placement arrow if the cell is empty. `Delete` removes the block under the cursor. `Enter` submits. `Backspace` restarts the puzzle. Keys `1` through `8` select the first eight puzzles. `[` and `]` step to the previous or next puzzle. Puzzle 1 also prints the how-to on the board. Building 2 is routes 16 through 22, Building 3 is routes 23 through 29, Building 4 is routes 30 through 36, Building 5 is routes 37 through 43, Building 6 is routes 44 through 50, and Building 7 is routes 51 through 57. Each later building is marked on the route row. Building 2 opens after route 15, Building 3 opens after route 22, Building 4 opens after route 29, Building 5 opens after route 36, Building 6 opens after route 43, and Building 7 opens after route 50.

## Simulation

Ticks are deterministic. A parcel sits on at most one cell. Sources and the dock are fixtures, not blocks, and they do not count toward the block total.

Each tick, in order:

1. A bin removes any parcel standing on it. That parcel is not delivered and does not have to match an order line. A slide or a bridge that hops over the bin does not remove the hopping parcel, because that parcel never stands on the bin.
2. A painter sets the color of a parcel standing on it. A primer sets the color only when that parcel is gray. A counter increments once for that parcel and stamps the new value. A parcel is stamped only on the first tick it spends on that counter.
3. Every parcel picks a destination from the block under it. A turn that is rotating a parcel picks no destination. A bin picks none.
4. Destinations that are illegal, contested by two parcels, or occupied by a parcel that is staying are cancelled. This repeats until it settles. Conveyors, painters, counters, splitters, filters, primers, bridges, turns, and slides may step into a cell another parcel is leaving on the same tick.
5. The surviving moves happen together. A parcel that steps onto the dock is delivered, in order.
6. A splitter that actually sent a parcel switches to its other output.
7. Each source emits its next parcel into the cell it faces, if that cell is empty and in bounds.
8. The delivered sequence is compared with the order.

Cycles is the tick on which the last ordered parcel arrives. Block count is the number of blocks in the submitted graph. If a delivery does not match the next order line, the attempt fails. If nothing can move, emit, release a latch, or step off a turn, the belt is stuck and the attempt fails. A layout that keeps moving without finishing, such as a loop, stops at tick 250 and fails.

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

### Primer

Paints a gray parcel its color, then moves the parcel forward with the same rule as a conveyor. A parcel that already has a color keeps that color. Primers are red, blue, or yellow.

### Bridge

Sets a parcel down two steps along its arrow. The cell in between is not entered, so it can be a brick, a belt, or a parcel. The far cell follows the same rule as a conveyor: it must be the dock or a block, and a bridge may land in a cell another parcel is leaving.

### Turn

A parcel remembers the direction it is facing. It is born facing the chute that emitted it, and a block that moves it sets its facing to the direction of that move.

On the tick a parcel arrives, a turn rotates that facing one quarter clockwise and does not move the parcel. On the next tick the parcel steps one cell in the new facing. That step follows the same rule as a conveyor: the cell must be the dock or a block, and the turn may enter a cell another parcel is leaving. If the cell is blocked by a parcel that is staying, the turn waits and tries again without rotating a second time. Rotating the block does not change the quarter. A turn does not paint, stamp, or filter, and it does not skip a cell.

### Slide

Moves a parcel two cells in the parcel's current facing on the tick the parcel is standing on it, and does not rotate the parcel. The cell between is not entered, so it can be a brick, a belt, or a parcel. The landing follows the same rule as a conveyor: it must be the dock or a block, and a slide may land in a cell another parcel is leaving. If that landing is blocked by a parcel that is staying, the slide does not move the parcel and does not rotate it. It tries again on the next tick.

A slide is not a bridge. A bridge lands two cells along the block's arrow. A slide lands two cells along the parcel's facing, so a turn before a slide changes where it lands, and rotating the slide block does not. A slide does not paint, stamp, or filter.

### Bin

Removes a parcel that is standing on it at the start of the tick. The parcel does not move, and it is not delivered. It does not have to match an order line. The bin does not paint, stamp, rotate, or filter, and rotating the block does not change it. A parcel that only hops across the cell, on a slide or a bridge, never stands on the bin, so it is not removed. A parcel that walks onto the bin is removed on the next tick. A bin is a placed block and counts toward the block total. Sources and the dock stay fixtures. An extra parcel that reaches the dock still fails the attempt. Scrapping a parcel the order needs leaves the order short: the belt sticks, or the attempt hits the tick cap.

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
23. Spare the Red introduces the primer. Gray becomes blue. Red crosses the same block and stays red.
24. Middle Yellow paints only the gray yellow, then stamps red 1, yellow 2, and blue 3.
25. Hold the South sends red through the filter. Gray is primed yellow on the south belt, and a latch holds that belt so red arrives first. Blue keeps its color.
26. Red Ahead primes gray red so the filter pulls it ahead of blue.
27. Shared Coat merges a red chute and a gray chute. The latch lets red through the primer first. Gray becomes yellow and is stamped 2.
28. Stamp Blue First primes gray red, lets blue through the filter into the counter, and brings red back for stamp 2.
29. Night Coat uses the filter, the primer, and the latch. Red is stamped 1, gray becomes yellow and is stamped 2, and blue is held for stamp 3.
30. Over the Brick introduces the bridge. The parcel hops the brick and lands on the dock.
31. Lane Cross jumps red over blue's belt. Blue has to go around, because the dock is the cell red lands on.
32. Count Across drops both parcels on the counter beyond the brick. The counter stamps 1, then 2.
33. Hold Under jumps red over a latch and onto the dock. Blue waits there, then follows. Without the latch, both parcels claim the dock and the belt jams.
34. Skip the Coat sends blue over the brick. Gray turns off the splitter and takes the yellow painter. A coat on the bridge path would paint blue too.
35. Twice Yellow loops the parcel through the counter, paints it yellow on the way back, and bridges the brick in front of the dock. The delivery is yellow 2.
36. Night Span uses the filter, the bridge, the primer, and the counter. Red hops the brick onto the counter for stamp 1. Gray becomes yellow on the south belt and is stamped 2. Blue keeps its color and is stamped 3.
37. Quarter Turn introduces the turn. The parcel rotates one quarter clockwise and stays put on that tick, then steps onto the dock.
38. Cut In turns red onto the blue belt as a parcel leaves, so red arrives ahead of the last blue. A latch misses the gap because the chute refills the cell.
39. Bend Stamp turns the parcel onto the counter. The stamp is the tick after it lands, and the delivery is count 1.
40. Clear the Dock turns red onto the dock. A latch holds blue so the two do not claim that dock on the same tick.
41. Two Rights sends blue and red through one turn. Blue is facing west and leaves north. Red is facing east and leaves south.
42. Second Bend loops the parcel through the counter, paints it yellow on the way back, and turns it onto the dock. The delivery is yellow 2.
43. Night Turn uses the filter, the turn, the primer, and the counter. Red turns south onto the counter for stamp 1. Gray takes the long belt, becomes yellow, and is stamped 2. Blue keeps its color and is stamped 3.
44. Long Step introduces the slide. The parcel slides two cells in its facing, over the brick, onto the dock.
45. Bent Slide turns the parcel south, then slides it over the brick. A bridge aimed along the chute would miss the dock, because the landing follows the new facing.
46. Far Stamp turns both parcels south and slides them over the brick onto the counter. The stamps are 1, then 2.
47. Over the Latch slides red over the waiting blue and onto the dock. Blue leaves once that dock is clear. Without the latch, both parcels claim the dock and the belt jams.
48. Two Spans sends blue and red through one slide. Blue is facing west and reaches the blue filter. Red is facing east and reaches the red filter, then the long belt. One bridge arrow cannot feed both filters.
49. Second Slide loops the parcel through the counter, paints it yellow on the way back, and slides it over the brick. The delivery is yellow 2.
50. Night Slide uses the filter, the turn, the slide, the latch, the primer, and the counter. Red turns south and slides over the brick onto the counter for stamp 1. The latch holds the south belt. Gray becomes yellow and is stamped 2. Blue keeps its color and is stamped 3.
51. Drop the Spare introduces the bin. Two parcels leave. Blue is due. Red goes into the bin. Delivering red fails the order.
52. Red Away sends blue along the filter's arrow and turns red aside. Red still needs a bin, or it reaches the dock. With nowhere to stand, red stays on the filter and blue never moves.
53. Skip the Middle bins the blue between two reds before the counter. The reds leave stamped 1 and 2. If blue is stamped, the dock sees red 1 and then blue 2.
54. Over the Bin slides blue across the bin onto the belt. Blue never stands on the bin, so the hop does not scrap it. Red walks onto the bin and is removed. Carrying red onward delivers red first.
55. After the Latch holds red, then bins it. Without the bin, red stays on the splitter and blue never leaves. A belt, slide, or bridge in that cell carries red to the dock first.
56. Keep the Coat bins blue. Gray is primed yellow and stamped 1. Blue never takes that coat or that stamp.
57. Night Bin uses the filter, the primer, the counter, the latch, and the bin. Red is stamped 1. Gray is primed yellow and stamped 2. Blue is binned and must not arrive.

## Limits

These are Building 1, Building 2, Building 3, Building 4, Building 5, Building 6, and Building 7. There is no histogram, no sound, and no proof that par is the shortest possible route: par is the reference graph, and another graph can deliver the order with a different cycle count or block count. Playback of a run that hits the tick cap is shortened on screen; the simulation itself still runs to the cap.
