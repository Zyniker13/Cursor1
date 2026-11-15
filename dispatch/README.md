# Dispatch

A wiring puzzle. Route parcels across Building 1, Building 2, Building 3, Building 4, Building 5, Building 6, Building 7, Building 8, Building 9, Building 10, Building 11, Building 12, Building 13, Building 14, Building 15, and Building 16, then submit the belt. After a delivery, the game shows your cycles and block count beside par. Par is not a handwritten number: it is the result of simulating that puzzle's reference graph.

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

Left-click an empty cell to place the selected block. Left-click a block of the same type to rotate it, or a different type to replace it. Right-click deletes. `R` rotates the block under the cursor, or the placement arrow if the cell is empty. `Delete` removes the block under the cursor. `Enter` submits. `Backspace` restarts the puzzle. Keys `1` through `8` select the first eight puzzles. `[` and `]` step to the previous or next puzzle. Puzzle 1 also prints the how-to on the board. Building 2 is routes 16 through 22, Building 3 is routes 23 through 29, Building 4 is routes 30 through 36, Building 5 is routes 37 through 43, Building 6 is routes 44 through 50, Building 7 is routes 51 through 57, Building 8 is routes 58 through 64, Building 9 is routes 65 through 71, Building 10 is routes 72 through 78, Building 11 is routes 79 through 85, Building 12 is routes 86 through 92, Building 13 is routes 93 through 99, Building 14 is routes 100 through 106, Building 15 is routes 107 through 113, and Building 16 is routes 114 through 120. Each later building is marked on the route row. Building 2 opens after route 15, Building 3 opens after route 22, Building 4 opens after route 29, Building 5 opens after route 36, Building 6 opens after route 43, Building 7 opens after route 50, Building 8 opens after route 57, Building 9 opens after route 64, Building 10 opens after route 71, Building 11 opens after route 78, Building 12 opens after route 85, Building 13 opens after route 92, Building 14 opens after route 99, Building 15 opens after route 106, and Building 16 opens after route 113.

## Simulation

Ticks are deterministic. A parcel sits on at most one cell. Sources and the dock are fixtures, not blocks, and they do not count toward the block total.

Each tick, in order:

1. A bin removes any parcel standing on it. That parcel is not delivered and does not have to match an order line. A slide or a bridge that hops over the bin does not remove the hopping parcel, because that parcel never stands on the bin.
2. A painter sets the color of a parcel standing on it. A primer sets the color only when that parcel is gray. A counter increments once for that parcel and stamps the new value. A parcel is stamped only on the first tick it spends on that counter.
3. Every parcel picks a destination from the block under it. A turn, a hook, or a return that is changing a parcel's facing picks no destination. A pause on the tick a parcel arrives picks no destination. A chute on the tick a parcel arrives sets that parcel's facing to the chute's facing and picks no destination. A shunt on the tick a parcel arrives picks no destination and does not change the facing. A bias on the tick a parcel arrives picks no destination and does not change the facing. A vault on the tick a parcel arrives picks no destination and does not change the facing. A sling on the tick a parcel arrives picks no destination and does not change the facing. A cant on the tick a parcel arrives picks no destination and does not change the facing. A bin picks none.
4. Destinations that are illegal, contested by two parcels, or occupied by a parcel that is staying are cancelled. This repeats until it settles. Conveyors, painters, counters, splitters, filters, primers, bridges, turns, slides, hooks, returns, pauses, chutes, shunts, biases, vaults, slings, and cants may step into a cell another parcel is leaving on the same tick.
5. The surviving moves happen together. A parcel that steps onto the dock is delivered, in order.
6. A splitter that actually sent a parcel switches to its other output.
7. Each source emits its next parcel into the cell it faces, if that cell is empty and in bounds.
8. The delivered sequence is compared with the order.

Cycles is the tick on which the last ordered parcel arrives. Block count is the number of blocks in the submitted graph. If a delivery does not match the next order line, the attempt fails. If nothing can move, emit, release a latch, or step off a turn, a hook, a return, a pause, a chute, a shunt, a bias, a vault, a sling, or a cant, the belt is stuck and the attempt fails. A layout that keeps moving without finishing, such as a loop, stops at tick 250 and fails.

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

A parcel remembers the direction it is facing. It is born facing the chute that emitted it, and a block that moves it sets its facing to the direction of that move. A shunt or a bias does not: the side step leaves the facing unchanged. A vault does not either: the two-cell jump leaves the facing unchanged. A sling does not either: the two-cell jump to the right leaves the facing unchanged. A cant does not either: the two-cell jump to the left leaves the facing unchanged.

On the tick a parcel arrives, a turn rotates that facing one quarter clockwise and does not move the parcel. On the next tick the parcel steps one cell in the new facing. That step follows the same rule as a conveyor: the cell must be the dock or a block, and the turn may enter a cell another parcel is leaving. If the cell is blocked by a parcel that is staying, the turn waits and tries again without rotating a second time. Rotating the block does not change the quarter. A turn does not paint, stamp, or filter, and it does not skip a cell.

### Slide

Moves a parcel two cells in the parcel's current facing on the tick the parcel is standing on it, and does not rotate the parcel. The cell between is not entered, so it can be a brick, a belt, or a parcel. The landing follows the same rule as a conveyor: it must be the dock or a block, and a slide may land in a cell another parcel is leaving. If that landing is blocked by a parcel that is staying, the slide does not move the parcel and does not rotate it. It tries again on the next tick.

A slide is not a bridge. A bridge lands two cells along the block's arrow. A slide lands two cells along the parcel's facing, so a turn before a slide changes where it lands, and rotating the slide block does not. A slide does not paint, stamp, or filter.

### Bin

Removes a parcel that is standing on it at the start of the tick. The parcel does not move, and it is not delivered. It does not have to match an order line. The bin does not paint, stamp, rotate, or filter, and rotating the block does not change it. A parcel that only hops across the cell, on a slide or a bridge, never stands on the bin, so it is not removed. A parcel that walks onto the bin is removed on the next tick. A bin is a placed block and counts toward the block total. Sources and the dock stay fixtures. An extra parcel that reaches the dock still fails the attempt. Scrapping a parcel the order needs leaves the order short: the belt sticks, or the attempt hits the tick cap.

### Hook

A hook is a placed block and counts toward the block total. On the tick a parcel arrives, a hook rotates that parcel's facing one quarter counterclockwise and does not move the parcel. On the next tick the parcel steps one cell in the new facing. East becomes north, north becomes west, west becomes south, and south becomes east. That step follows the same rule as a conveyor: the cell must be the dock or a block, and the hook may enter a cell another parcel is leaving. If the cell is blocked by a parcel that is staying, the hook waits and tries again without rotating a second time. Rotating the hook block does not change the quarter. A hook does not paint, stamp, filter, or skip a cell. A hook is not a turn. One turn cannot leave the way one hook leaves.

### Return

A return is a placed block and counts toward the block total. It has no facing. Rotating the block does not change it. On the tick a parcel arrives, a return reverses that parcel's facing and does not move the parcel. East becomes west, west becomes east, north becomes south, and south becomes north. On the next tick the parcel steps one cell in that new facing, back along the way it arrived. That step follows the same rule as a conveyor: the cell must be the dock or a block, and the return may enter a cell another parcel is leaving. If the cell is blocked by a parcel that is staying, the return waits and tries again without reversing a second time. A return does not paint, stamp, filter, or skip a cell. A return is not a hook and it is not a turn. One hook leaves the parcel a quarter turn counterclockwise. One turn leaves it a quarter turn clockwise. Neither sends the parcel back along its arrival.

### Pause

A pause is a placed block and counts toward the block total. It has no facing. Rotating the block does not change it. On the tick a parcel arrives, a pause does not change that parcel's facing and does not move the parcel. East stays east, west stays west, north stays north, and south stays south. On the next tick the parcel steps one cell in the facing it already had. That step follows the same rule as a conveyor: the cell must be the dock or a block, and the pause may enter a cell another parcel is leaving. If the cell is blocked by a parcel that is staying, the pause waits and tries again without changing the facing. A pause does not paint, stamp, filter, or skip a cell. A pause is not a return, a hook, or a turn. A return sends the parcel back along its arrival. A hook leaves it a quarter turn counterclockwise. A turn leaves it a quarter turn clockwise. A conveyor would have stepped on the arrival tick. The pause waits one tick and then goes on in the facing the parcel already had.

### Chute

A chute is a placed block and counts toward the block total. It has a facing. Rotating the block changes the exit. On the tick a parcel arrives, a chute sets that parcel's facing to the chute's facing and does not move the parcel. East, south, west, or north, whichever way the chute points. On the next tick the parcel steps one cell in that facing. That step follows the same rule as a conveyor: the cell must be the dock or a block, and the chute may enter a cell another parcel is leaving. If the cell is blocked by a parcel that is staying, the chute waits and tries again without changing the facing a second time. A chute does not paint, stamp, filter, or skip a cell. A chute is not a pause, a return, a hook, a turn, or a conveyor. A pause has no facing and sends the parcel on in the facing it arrived with. A return sends it back. A hook leaves it a quarter turn counterclockwise. A turn leaves it a quarter turn clockwise. A conveyor would have stepped on the arrival tick. The chute writes its own facing onto the parcel, waits one tick, and then sends the parcel that way.

### Shunt

A shunt is a placed block and counts toward the block total. It has no facing. Rotating the block does not change it. On the tick a parcel arrives, a shunt does not change that parcel's facing and does not move the parcel. On the next tick the parcel steps one cell to its right. Right is the clockwise perpendicular: an east-facing parcel steps south, a south-facing parcel steps west, a west-facing parcel steps north, and a north-facing parcel steps east. That step does not change the facing. The parcel still faces the way it arrived. Other moving blocks set the facing to the direction of the move. A bias is the other exception: its side step also leaves the facing unchanged. That step follows the same rule as a conveyor: the cell must be the dock or a block, and the shunt may enter a cell another parcel is leaving. If the cell is blocked by a parcel that is staying, the shunt waits and tries the same side step again without changing the facing. A shunt does not paint, stamp, filter, or skip a cell. A shunt is not a turn, a pause, a chute, a hook, a return, or a conveyor. A turn changes the facing clockwise on the arrival tick and then steps in that new facing, so after the step the parcel faces the way it stepped. A shunt steps into the same cell and the parcel still faces the old way. A pause steps along the arrival facing. A chute writes its own facing and then steps along that facing. A hook leaves the parcel a quarter turn counterclockwise. A return reverses it. A conveyor would have stepped on the arrival tick.

### Bias

A bias is a placed block and counts toward the block total. It has no facing. Rotating the block does not change it. On the tick a parcel arrives, a bias does not change that parcel's facing and does not move the parcel. On the next tick the parcel steps one cell to its left. Left is the counterclockwise perpendicular: an east-facing parcel steps north, a north-facing parcel steps west, a west-facing parcel steps south, and a south-facing parcel steps east. That step does not change the facing. The parcel still faces the way it arrived. That step follows the same rule as a conveyor: the cell must be the dock or a block, and the bias may enter a cell another parcel is leaving. If the cell is blocked by a parcel that is staying, the bias waits and tries the same side step again without changing the facing. A bias does not paint, stamp, filter, or skip a cell. A bias is not a shunt, a turn, a pause, a chute, a hook, a return, or a conveyor. A shunt steps to the parcel's right, the clockwise perpendicular. A pause continues in the arrival facing. A turn rotates clockwise and then steps in the new facing. A hook rotates counterclockwise and then steps in the new facing. A chute writes its own facing. A return reverses the facing. A bias does none of those. A conveyor would have stepped on the arrival tick.

### Vault

A vault is a placed block and counts toward the block total. It has no facing. Rotating the block does not change it. On the tick a parcel arrives, a vault does not change that parcel's facing and does not move the parcel. On the next tick the parcel jumps two cells in the facing it already had. East jumps two cells east, north two cells north, west two cells west, and south two cells south. The cell immediately ahead is not entered. That cell does not need to be a block, and a parcel sitting there does not block the jump and is not moved. The landing cell must be in bounds and must be the dock or a block. That jump does not change the facing. The parcel still faces the way it arrived. The landing follows the same occupancy rule as a conveyor: the vault may land in a cell another parcel is leaving. If the landing is blocked by a parcel that is staying, or the landing is out of bounds, or the landing is neither the dock nor a block, the vault waits and tries the same jump again without changing the facing. A vault does not paint, stamp, filter, or take a one-cell step. A vault is not a bias, a shunt, a turn, a pause, a chute, a hook, a return, or a conveyor. A bias steps one cell to the parcel's left. A shunt steps one cell to the parcel's right. A pause steps one cell forward. A conveyor steps one cell on the arrival tick. A hook, a turn, a return, and a chute change the facing. None of them jump two cells.

### Sling

A sling is a placed block and counts toward the block total. It has no facing. Rotating the block does not change it. On the tick a parcel arrives, a sling does not change that parcel's facing and does not move the parcel. On the next tick the parcel jumps two cells to its right, the same side a shunt steps. Right is the clockwise perpendicular: an east-facing parcel jumps two cells south, a south-facing parcel jumps two cells west, a west-facing parcel jumps two cells north, and a north-facing parcel jumps two cells east. The cell immediately on that side is not entered. That cell does not need to be a block, and a parcel sitting there does not block the jump and is not moved. The landing cell must be in bounds and must be the dock or a block. The jump does not change the facing. The parcel still faces the way it arrived. The landing follows the same occupancy rule as a vault: the sling may land in a cell another parcel is leaving. If the landing is blocked by a parcel that is staying, or the landing is out of bounds, or the landing is neither the dock nor a block, the sling waits and tries the same jump again without changing the facing. A sling does not paint, stamp, filter, or take a one-cell step. A sling is not a vault, a slide, a bridge, a shunt, a bias, a pause, a chute, a turn, a hook, a return, or a conveyor. A shunt waits, then steps one cell to the right and enters that cell. A bias waits, then steps one cell to the left. A vault waits, then jumps two cells forward along the arrival facing, over the cell in front. A slide moves two cells forward and does not wait the way a vault does. A bridge sets a parcel down two steps along its arrow. A pause waits, then steps one cell forward. A chute writes its own facing, then steps one cell that way. A conveyor steps one cell on the arrival tick.

### Cant

A cant is a placed block and counts toward the block total. It has no facing. Rotating the block does not change it. On the tick a parcel arrives, a cant does not change that parcel's facing and does not move the parcel. On the next tick the parcel jumps two cells to its left, the same side a bias steps. Left is the counterclockwise perpendicular: an east-facing parcel jumps two cells north, a north-facing parcel jumps two cells west, a west-facing parcel jumps two cells south, and a south-facing parcel jumps two cells east. The cell immediately on that side is not entered. That cell does not need to be a block, and a parcel sitting there does not block the jump and is not moved. The landing cell must be in bounds and must be the dock or a block. The jump does not change the facing. The parcel still faces the way it arrived. The landing follows the same occupancy rule as a sling: the cant may land in a cell another parcel is leaving. If the landing is blocked by a parcel that is staying, or the landing is out of bounds, or the landing is neither the dock nor a block, the cant waits and tries the same jump again without changing the facing. A cant does not paint, stamp, filter, or take a one-cell step. A cant is not a sling, a bias, a shunt, a vault, a slide, a bridge, a pause, a chute, a turn, a hook, a return, or a conveyor. A sling waits, then jumps two cells to the right. The near right cell is not entered. A bias waits, then steps one cell to the left and enters that cell. A shunt waits, then steps one cell to the right. A vault waits, then jumps two cells forward along the arrival facing, over the cell in front. A slide moves two cells forward and does not wait the way a vault does. A bridge sets a parcel down two steps along its arrow. A pause waits, then steps one cell forward. A chute writes its own facing, then steps one cell that way. A conveyor steps one cell on the arrival tick.

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
58. Left Turn introduces the hook. One parcel hooks onto the dock. A turn in that cell misses the dock. Par is 3 cycles and 1 block.
59. Cut Left puts red onto a belt ahead of a later parcel. A turn sends red the other way. Par is 5 cycles and 2 blocks.
60. Bend Count lands the hook on a counter. The delivery is count 1. A turn misses the counter. Par is 4 cycles and 2 blocks.
61. Clear North puts red on the dock. A latch holds blue so the two do not claim that dock on the same tick. A turn sends red away from the dock. Par is 4 cycles and 3 blocks.
62. Two Lefts sends two parcels through one hook. They leave different ways because their facings differ. A turn sends each the other way. Par is 9 cycles and 9 blocks.
63. Second Hook loops the parcel through a counter, paints it yellow on the way back, and hooks it onto the dock. The delivery is yellow 2. Par is 9 cycles and 5 blocks.
64. Night Hook uses the filter, the hook, the primer, and the counter. Red hooks onto the counter for stamp 1. Gray takes the long belt, becomes yellow, and is stamped 2. Blue keeps its color and is stamped 3. Par is 11 cycles and 10 blocks.
65. About Face introduces the return. One parcel comes in facing east. The return sends it west onto the dock. A hook sends it north. A turn sends it south. Par is 4 cycles and 2 blocks.
66. Cut Back puts red back onto a belt ahead of a later parcel. A hook and a turn send red off that belt. Par is 6 cycles and 3 blocks.
67. Back Count lands the return on a counter. The delivery is count 1. A hook and a turn miss the counter. Par is 5 cycles and 3 blocks.
68. Clear Behind sends red back onto the dock. A latch holds blue so the two do not claim that dock on the same tick. A hook leaves red on the belt while blue takes the dock. A turn sends red south, and blue still takes the dock. Par is 5 cycles and 5 blocks.
69. Two Returns sends two parcels through one return. They leave back along their own arrivals, so they go opposite ways. A hook turns both a quarter counterclockwise. A turn turns both a quarter clockwise. Par is 10 cycles and 10 blocks.
70. Second Return loops the parcel through a counter, paints it yellow on the way back, and the return puts it on the dock. The delivery is yellow 2. Par is 10 cycles and 6 blocks.
71. Night Return uses the filter, the return, the primer, and the counter. Red returns onto the counter for stamp 1. Gray takes the long belt, becomes yellow, and is stamped 2. Blue keeps its color and is stamped 3. Par is 11 cycles and 11 blocks.
72. Still Step introduces the pause. One parcel comes in facing east. The pause sends it east onto the dock. A return sends it west. A hook sends it north. A turn sends it south. Par is 4 cycles and 2 blocks.
73. Let Pass holds the first parcel one tick so a later parcel takes the dock first, then the paused parcel follows. A return sends the first parcel backward. A conveyor lets the first parcel leave on the arrival tick and the order fails. Par is 4 cycles and 4 blocks.
74. Pause Count lands the pause on a counter. The delivery is count 1. A return and a hook miss the counter. Par is 4 cycles and 2 blocks.
75. Clear Ahead delays red so blue takes the dock first, then red arrives. A return sends red back. A hook and a turn send red off the belt. Par is 5 cycles and 6 blocks.
76. Two Pauses sends two parcels through one pause. They leave along the facings they arrived with. A return sends each back. A hook turns both a quarter counterclockwise. A turn turns both a quarter clockwise. Par is 11 cycles and 11 blocks.
77. Second Pause loops the parcel through a counter, paints it yellow on the way, and the pause puts it on the dock. The delivery is yellow 2. A return sends it back the other way. Par is 9 cycles and 5 blocks.
78. Night Pause uses the filter, the pause, the primer, and the counter. Red pauses onto the counter for stamp 1. Gray takes the long belt, becomes yellow, and is stamped 2. Blue keeps its color and is stamped 3. The pause keeps each parcel's facing. A return would reverse them. Par is 11 cycles and 10 blocks.
79. Aimed Step introduces the chute. One parcel comes in facing north. An east-facing chute sends it east onto the dock one tick later. A pause sends it north. A return sends it south. A hook sends it west. A turn also steps east, so the turn reaches the dock. Par is 4 cycles and 2 blocks.
80. Let Aim holds the first parcel one tick, then sends it along the chute's facing so a later parcel takes the dock first. A pause sends the first parcel along its arrival facing. A conveyor lets the first parcel leave on the arrival tick and the order fails. A turn also waits and steps east, so the turn clears. Par is 4 cycles and 4 blocks.
81. Chute Count faces the chute onto a counter. The delivery is count 1. A pause, a return, and a hook miss the counter. A turn also steps east onto the counter, so the turn clears. Par is 4 cycles and 2 blocks.
82. Clear the Lane delays red and sends it along the chute's facing so blue takes the dock first, then red arrives. A pause sends red along its arrival facing. A hook and a turn send red off the belt. A return sends red the same way as the chute, so the return also clears. Par is 5 cycles and 6 blocks.
83. Two Chutes sends two parcels through one east-facing chute. They both leave east, even though they arrived on different facings. A pause sends each along its own arrival. A hook turns both a quarter counterclockwise. A turn turns both a quarter clockwise. A return sends each back. An east-facing conveyor also delivers. Par is 7 cycles and 6 blocks.
84. Second Chute loops the parcel through a counter, paints it yellow on the way, and the chute puts it on the dock. The delivery is yellow 2. A pause sends it along the facing it arrived with, off the dock. Rotating the chute off the dock misses. A hook also turns onto the dock, so the hook clears. Par is 9 cycles and 5 blocks.
85. Night Chute uses the filter, the chute, the primer, and the counter. The chute's facing puts red onto the counter for stamp 1. Gray takes the long belt, becomes yellow, and is stamped 2. Blue keeps its color and is stamped 3. A pause keeps each parcel's arrival facing and misses. A return reverses them. A hook also turns red onto the counter, so the hook clears. An east-facing conveyor also delivers. Par is 13 cycles and 12 blocks.
86. Side Step introduces the shunt. One parcel comes in facing east. The shunt steps it south, and it still faces east, so the next pause sends it east onto the dock. A turn also steps south, then faces south, and that pause sends it south, off the dock. A pause in the shunt cell sends it east and never steps south. A chute facing east sends it east. A hook, a return, and a conveyor miss too. Par is 6 cycles and 3 blocks.
87. Let Side holds the first parcel one tick, then steps it to its right so a later parcel has taken the dock first. The first parcel's unchanged facing carries it onto the dock after that. A turn changes the facing, so the later step misses. A conveyor lets the first parcel leave on the arrival tick and the order fails. A pause sends the first parcel along its arrival facing. A chute, a hook, and a return miss too. Par is 8 cycles and 10 blocks.
88. Shunt Count steps the parcel south onto a pause and leaves it facing east. That pause carries it onto the counter. The delivery is count 1. A turn reaches the side cell but leaves facing south, so the pause misses the counter. A pause in the shunt cell never takes the side step. A chute facing east sends the parcel east and misses the counter. A hook, a return, and a conveyor miss too. Par is 7 cycles and 4 blocks.
89. Clear the Side delays red and steps it aside so blue takes the dock first, then red's unchanged facing brings red in. A turn steps aside but the new facing misses. A pause does not step aside, and red arrives before blue. A chute, a hook, a return, and a conveyor miss too. Par is 8 cycles and 10 blocks.
90. Two Shunts sends two parcels through one shunt. Each steps to its own right and keeps its own arrival facing, so they leave different ways. A turn turns both clockwise, so the later step follows the new facing. A chute sends both along the chute's facing. A pause sends each straight along its arrival. A hook, a return, and a conveyor miss too. Par is 18 cycles and 16 blocks.
91. Second Shunt loops the parcel through a counter, paints it yellow on the way, and the shunt's side step plus the kept facing puts it on the dock. The delivery is yellow 2. A turn reaches the side cell but the new facing misses the dock. A pause never takes the side step. A chute, a hook, a return, and a conveyor miss too. Par is 11 cycles and 6 blocks.
92. Night Shunt uses the filter, the shunt, the primer, and the counter. The side step, with the arrival facing kept, puts red onto the counter for stamp 1. Gray takes the long belt, becomes yellow, and is stamped 2. Blue keeps its color and is stamped 3. A turn changes the facing and misses. A pause keeps the facing but does not step aside. A chute writes its own facing and misses. A hook, a return, and a conveyor miss too. Par is 12 cycles and 12 blocks.
93. Side Left introduces the bias. One parcel comes in facing east. The bias steps it north, and it still faces east, so the next pause sends it east onto the dock. A shunt aims south and misses the dock. A hook also steps north, then faces north, and that pause sends it north, off the dock. A turn faces south. A pause in the bias cell sends it east and never steps north. A chute facing east sends it east. A return and a conveyor miss too. Par is 6 cycles and 3 blocks.
94. Let Left holds the first parcel one tick, then steps it to its left so a later parcel has taken the dock first. The first parcel's unchanged facing carries it onto the dock after that. A shunt aims the other way. A conveyor lets the first parcel leave on the arrival tick and the order fails. A pause sends the first parcel along its arrival facing. A hook, a chute, a turn, and a return miss too. Par is 8 cycles and 10 blocks.
95. Bias Count steps the parcel north onto a pause and leaves it facing east. That pause carries it onto the counter. The delivery is count 1. A shunt aims south and misses the counter. A hook reaches the side cell but leaves facing north, so the pause misses the counter. A turn faces south and misses the side cell. A pause in the bias cell never takes the side step. A chute facing east sends the parcel east and misses the counter. A return and a conveyor miss too. Par is 7 cycles and 4 blocks.
96. Clear the Left delays red and steps it aside so blue takes the dock first, then red's unchanged facing brings red in. A shunt aims the other way and misses. A pause does not step aside, and red arrives before blue. A hook steps aside but the new facing misses. A chute, a turn, a return, and a conveyor miss too. Par is 8 cycles and 10 blocks.
97. Two Biases sends two parcels through one bias. Each steps to its own left and keeps its own arrival facing, so they leave different ways. A shunt steps each to its own right. A chute sends both along the chute's facing. A pause sends each straight along its arrival. A hook, a turn, a return, and a conveyor miss too. Par is 18 cycles and 16 blocks.
98. Second Bias loops the parcel through a counter, paints it yellow on the way, and the bias's side step plus the kept facing puts it on the dock. The delivery is yellow 2. A shunt aims south and misses the dock. A hook reaches the side cell but the new facing misses the dock. A turn faces south and misses the side cell. A pause never takes the side step. A chute, a return, and a conveyor miss too. Par is 11 cycles and 6 blocks.
99. Night Bias uses the filter, the bias, the primer, and the counter. The side step, with the arrival facing kept, puts red onto the counter for stamp 1. Gray takes the long belt, becomes yellow, and is stamped 2. Blue keeps its color and is stamped 3. A shunt steps the other way and misses. A turn changes the facing and misses. A pause keeps the facing but does not step aside. A chute writes its own facing and misses. A hook, a return, and a conveyor miss too. Par is 13 cycles and 14 blocks.
100. Long Step introduces the vault. One parcel comes in facing east. The vault jumps it two cells east, and it still faces east, so the next pause sends it east onto the dock. A pause in the vault cell steps one cell and never reaches that pause. A bias steps north. A shunt steps south. A conveyor leaves on the arrival tick. A turn, a chute, a hook, and a return miss too. Par is 6 cycles and 3 blocks.
101. Let Long holds the first parcel one tick, then jumps it two cells forward so a later parcel has taken the dock first. The first parcel's unchanged facing carries it onto the dock after that. A conveyor lets the first parcel leave on the arrival tick and the order fails. A pause steps one cell. A bias and a shunt step aside. A turn, a chute, a hook, and a return miss too. Par is 8 cycles and 12 blocks.
102. Vault Count jumps the parcel two cells onto a pause and leaves it facing east. That pause carries it onto the counter. The delivery is count 1. A pause in the vault cell lands on the cell between and misses the counter. A bias and a shunt miss the line. A chute facing east sends the parcel one cell east. A turn, a hook, a return, and a conveyor miss too. Par is 6 cycles and 4 blocks.
103. Clear the Gap delays red and jumps it over the cell blue is using, so blue takes the dock first, then red's unchanged facing brings red in. A pause does not jump, and red arrives before blue. A bias and a shunt step aside and miss. A turn, a chute, a hook, a return, and a conveyor miss too. Par is 8 cycles and 11 blocks.
104. Two Vaults sends two parcels through one vault. Each jumps two cells in its own arrival facing and keeps that facing, so they leave different ways. A pause sends each one cell along its arrival. A chute sends both along the chute's facing. A bias steps each to its own left. A shunt steps each to its own right. A turn, a hook, a return, and a conveyor miss too. Par is 19 cycles and 19 blocks.
105. Second Vault loops the parcel through a counter, paints it yellow on the way, and the vault's jump plus the kept facing puts it on the dock. The delivery is yellow 2. A pause never jumps far enough. A bias and a shunt leave the line. A turn, a chute, a hook, a return, and a conveyor miss too. Par is 11 cycles and 6 blocks.
106. Night Vault uses the filter, the vault, the primer, and the counter. The two-cell jump, with the arrival facing kept, puts red onto the counter for stamp 1. Gray takes the long belt, becomes yellow, and is stamped 2. Blue keeps its color and is stamped 3. A pause keeps the facing but only steps one cell. A bias and a shunt step aside. A chute writes its own facing. A turn, a hook, a return, and a conveyor miss too. Par is 12 cycles and 11 blocks.
107. First Sling introduces the sling. One parcel comes in facing east. The sling jumps it two cells to its right and leaves it facing east, so the next pause sends it east onto the dock. The cell immediately to its right is empty of blocks. A shunt steps onto that missing cell and never reaches the pause. A vault jumps two cells east. A bias steps the other way. A pause steps one cell east. A slide and a bridge jump forward, not to the side. A conveyor leaves on the arrival tick. A turn, a chute, a hook, and a return miss too. Par is 6 cycles and 3 blocks.
108. Let Sling holds the parcel one tick, then jumps it two cells to its right. That wait is why it misses the parcel already in the way. It still faces the way it arrived, so the pause carries it onto the dock after the other parcel. A slide or a bridge leaves on the arrival tick and arrives in the wrong order. A shunt only steps one cell. A vault jumps forward. A bias steps the other way. A turn, a chute, a hook, a return, a pause, and a conveyor miss too. Par is 9 cycles and 15 blocks.
109. Sling Count jumps the parcel two cells to its right onto a pause and leaves the facing unchanged. The pause carries it onto the counter. The delivery is count 1. A shunt lands one cell short and misses the counter. A vault jumps forward off the line. A bias steps the other way. A chute writes its own facing. A pause, a slide, a bridge, a turn, a hook, a return, and a conveyor miss too. Par is 7 cycles and 5 blocks.
110. Clear the Side has a parcel sitting in the cell immediately to the right. The sling jumps over it. That parcel does not move and does not block the jump. A shunt cannot enter the occupied cell. A vault jumps forward instead of over that side cell. A bias steps the other way. A pause, a slide, a bridge, a turn, a chute, a hook, a return, and a conveyor miss too. Par is 6 cycles and 3 blocks.
111. Two Slings sends two parcels through one sling. Each jumps two cells to its own right and keeps its own arrival facing, so they leave different ways. A shunt sends each only one cell to its right. A vault sends each two cells forward along its facing. A chute sends both along the chute's facing. A bias steps each to its own left. A pause, a slide, a bridge, a turn, a hook, a return, and a conveyor miss too. Par is 16 cycles and 12 blocks.
112. Second Sling loops the parcel through the counter. Paint it yellow on the way. The sling's two-cell jump to the right, with the facing kept, puts it on the dock. The delivery is yellow 2. A shunt is one cell short. A vault jumps the wrong axis. A pause never jumps far enough. A bias leaves the line. A slide, a bridge, a turn, a chute, a hook, a return, and a conveyor miss too. Par is 11 cycles and 6 blocks.
113. Night Sling uses the filter, the sling, the primer, and the counter. The two-cell jump to the right, with the arrival facing kept, puts red onto the counter for stamp 1. Gray takes the long belt, becomes yellow, and is stamped 2. Blue keeps its color and is stamped 3. A shunt is one cell short. A vault jumps forward. A chute writes its own facing. A pause keeps the facing but only steps one cell. A bias, a slide, a bridge, a turn, a hook, a return, and a conveyor miss too. Par is 14 cycles and 13 blocks.
114. First Cant introduces the cant. One parcel comes in facing east. The cant jumps it two cells to its left and leaves it facing east, so the next pause sends it east onto the dock. The cell immediately to its left is empty of blocks. A bias steps onto that missing cell and never reaches the pause. A sling jumps two cells to the right. A vault jumps two cells east. A shunt steps the other way. A pause steps one cell east. A slide and a bridge jump forward, not to the side. A conveyor leaves on the arrival tick. A turn, a chute, a hook, and a return miss too. Par is 6 cycles and 3 blocks.
115. Let Cant holds the parcel one tick, then jumps it two cells to its left. That wait is why it misses the parcel already in the way. It still faces the way it arrived, so the pause carries it onto the dock after the other parcel. A slide or a bridge leaves on the arrival tick and arrives in the wrong order. A bias only steps one cell. A sling jumps the other way. A vault jumps forward. A shunt, a turn, a chute, a hook, a return, a pause, and a conveyor miss too. Par is 9 cycles and 15 blocks.
116. Cant Count jumps the parcel two cells to its left onto a pause and leaves the facing unchanged. The pause carries it onto the counter. The delivery is count 1. A bias lands one cell short and misses the counter. A sling jumps the other way. A vault jumps forward off the line. A chute writes its own facing. A shunt, a pause, a slide, a bridge, a turn, a hook, a return, and a conveyor miss too. Par is 7 cycles and 5 blocks.
117. Clear the Side has a parcel sitting in the cell immediately to the left. The cant jumps over it. That parcel does not move and does not block the jump. A bias cannot enter the occupied cell. A sling jumps the other way. A vault jumps forward instead of over that side cell. A shunt, a pause, a slide, a bridge, a turn, a chute, a hook, a return, and a conveyor miss too. Par is 6 cycles and 3 blocks.
118. Two Cants sends two parcels through one cant. Each jumps two cells to its own left and keeps its own arrival facing, so they leave different ways. A bias sends each only one cell to its left. A sling sends each two cells to its right. A vault sends each two cells forward along its facing. A chute sends both along the chute's facing. A shunt, a pause, a slide, a bridge, a turn, a hook, a return, and a conveyor miss too. Par is 16 cycles and 12 blocks.
119. Second Cant loops the parcel through the counter. Paint it yellow on the way. The cant's two-cell jump to the left, with the facing kept, puts it on the dock. The delivery is yellow 2. A bias is one cell short. A sling jumps the wrong side. A vault jumps the wrong axis. A pause never jumps far enough. A shunt, a slide, a bridge, a turn, a chute, a hook, a return, and a conveyor miss too. Par is 11 cycles and 6 blocks.
120. Night Cant uses the filter, the cant, the primer, and the counter. The two-cell jump to the left, with the arrival facing kept, puts red onto the counter for stamp 1. Gray takes the long belt, becomes yellow, and is stamped 2. Blue keeps its color and is stamped 3. A bias is one cell short. A sling jumps the other way. A vault jumps forward. A chute writes its own facing. A pause keeps the facing but only steps one cell. A shunt, a slide, a bridge, a turn, a hook, a return, and a conveyor miss too. Par is 15 cycles and 14 blocks.

## Limits

These are Building 1, Building 2, Building 3, Building 4, Building 5, Building 6, Building 7, Building 8, Building 9, Building 10, Building 11, Building 12, Building 13, Building 14, Building 15, and Building 16. There is no histogram, no sound, and no proof that par is the shortest possible route: par is the reference graph, and another graph can deliver the order with a different cycle count or block count. Playback of a run that hits the tick cap is shortened on screen; the simulation itself still runs to the cap.
