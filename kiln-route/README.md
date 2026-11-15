# Kiln Route

Kiln Route is a foundry puzzle. Each room hands you a tray of machines and a quota. The route clears when the quota is met inside one simulated minute. Pieces can always be picked back up.

This project is the first two wings: 16 rooms, not the full 48. Clearing room 8 unlocks room 9.

Art is drawn by Godot (rects, polygons, lines, and arcs). There are no imported sprites.

## Run

Requires Godot 4.3 or newer (developed on 4.7.2). From the repository root:

```
godot --path kiln-route
```

## Controls

- 1 belt, 2 kiln, 3 press, 4 filter, 5 splitter, 6 roller, 7 weir (only pieces in the tray can be selected)
- R or E rotates clockwise, Q rotates counter-clockwise. R rotates the piece under the cursor when there is one, otherwise it rotates the piece you are about to place. Right-click does the same.
- Left-click an empty floor cell to place the selected piece. Left-click a placed piece to pick it up and return it to the tray.
- Space or Enter runs the minute. While it is running, Space or F skips to the result. The Run button does the same.
- Backspace restarts the room, including any piece the room started with.
- `[` and `]` change rooms. Room 1 is open. Clearing a room unlocks the next. Switching rooms keeps the layout you were building.
- Pickup works during and after a run: it stops the animation and returns the piece. Placing is ignored while the minute is playing.

Clears are stored in Godot's `user://kiln_route.cfg`.

## Rules

Materials are ore, ingot, and plate.

Every room simulates exactly **120 ticks**. That is one simulated minute at 2 ticks per second. Playback on screen is faster so the minute can be watched, and skipping ahead still evaluates those same 120 ticks. Playback speed does not change the result.

There is no random number generator. The recorded seed is always **0**. The same room, the same pieces, and the same machine memory always produce the same deliveries.

### Tick

Each tick, in order:

1. Kiln and press timers count down by one. A timer that reaches 0 makes its product ready to leave (an ingot from a kiln, a plate from a press).
2. Pieces that already have something to send try to send it. Cells are scanned from top to bottom, then left to right. The scan repeats until nothing moves. Each item moves at most once, so a line of belts all advance one cell in the same tick no matter which way they face. If two items want the same cell, the one whose current cell comes first in that scan wins and the other waits.
3. Sources emit, in the order they are listed in the room. A new item appears after movement and does not move again until the next tick.

A source fires on tick 1 and then every `period` ticks. If the cell in front refuses the item, the source holds that one item and does not create another until it leaves. It does not catch up missed cycles. If two sources push into the same cell on the same tick, the earlier source in the room list wins and the other holds its item.

An item that would enter a cell outside the room, a wall, empty floor, a full piece, or a piece that refuses that material or that entry side stays where it is. Nothing is destroyed except by a waste chute, which accepts every material and does not count toward the quota. A quota sink accepts only the materials listed on it and refuses the rest; the refused item waits on the previous piece.

### Machines

Facing is east, south, west, or north. North is up. "Right" means 90 degrees clockwise on the board.

- **Belt.** Holds one item. Each tick it tries to push that item one cell forward. It accepts an item from behind or from either side. It refuses an item moving into its front (an arrival direction opposite its facing).
- **Filter.** Holds one item. Accepts only from behind, which means the item is moving in the facing direction. Ore leaves forward. Ingots and plates leave to the right. If that exit cannot accept the item, the item waits. The filter does not send ore to the side or metal forward.
- **Kiln.** Accepts one ore from behind while idle, and refuses every other material. The ore is consumed on entry. `KILN_DELAY` is 2: an ore that enters on tick 1 can leave as an ingot on tick 3. While the timer is running, or while the ingot cannot leave, the kiln accepts nothing. The ingot leaves forward.
- **Press.** Accepts ingots from behind and refuses every other material. It stores the first ingot. The second ingot is consumed with the first, and one plate is ready `PRESS_DELAY` (1) tick later. Ingots that enter on ticks 1 and 2 from a source aimed straight into the press can leave as a plate on tick 3. While the plate is waiting to leave, or during that delay, the press accepts nothing. The plate leaves forward.
- **Splitter.** Holds one item. Accepts only from behind. The first item it successfully sends goes forward, the next goes to the right, then it repeats. The alternation advances only when the item actually leaves. If the chosen exit is blocked, the item waits and the splitter does not try the other exit.
- **Roller.** Holds one item. Accepts any material, but only from behind. It pushes that item forward. It refuses a side entry and a head-on entry. A refused item stays where it was. A roller does not sort and does not split.
- **Weir.** Holds one item. Accepts any material, but only from behind. It tries to push the item forward. If that cell refuses, it tries the right side. If both refuse, the item waits. The next item tries forward again. A weir does not alternate, and a successful spill does not change that preference.

### Budget and clearing

The tray is the piece budget. Placing a piece you do not have is refused. A run clears the room only when, after exactly 120 ticks, every quota count has been reached **and** the placed pieces are within the budget. A layout that meets the quota by spending an extra piece is rejected. The authored solution for each room uses the tray exactly.

## Rooms

1. **Haul** — belts carry ore to the bin.
2. **Smelt** — a kiln turns ore into ingots. The bin refuses ore.
3. **Stamp** — a press turns two ingots into one plate.
4. **Sort** — a filter sends ore into a waste chute and ingots into the bin.
5. **Divide** — a splitter feeds two kilns. One kiln cannot reach the quota.
6. **Pinch** — the tray has two belts, not the three a spaced line wants, so two machines have to touch.
7. **Relight** — the kiln starts on the wrong cell. Leaving it there misses the quota; pick it up and put it on the route.
8. **Two Orders** — the bin wants both ingots and plates, and the tray has no spare piece. One kiln has to feed both.
9. **Straight** — a roller refuses ore crossing an ingot lane. A belt in that cell stalls the bin.
10. **Spill** — a weir keeps the forward kiln full and spills the rest to a second kiln. One kiln misses the quota.
11. **Keep** — aim the filter so ore goes to the bin and ingots fall into the waste chute.
12. **Detour** — a wall closes the middle row. The belts have to turn and go around it.
13. **Refine** — the filter scraps raw ingots and feeds ore to the kiln. The bin counts the kiln's ingots.
14. **Miscast** — the roller starts off the lane. Pick it up and seat it on the crossing.
15. **Hearth** — spill a second kiln into the same press. One kiln cannot stamp the quota.
16. **Balance** — the roller guards the ingot line, then a splitter feeds both the ingot bin and the press.

## Tests

From the repository root:

```
godot --headless --path kiln-route --script res://tests/run_tests.gd
```

The script exits 0 when every check passes and 1 otherwise. The last line is `passed=N failed=M`.

The suite checks:

- Each room's initial layout misses the quota. The authored solution meets it in 120 ticks without exceeding the tray.
- A layout that meets the quota with an extra piece is rejected, and the tray itself refuses that extra piece.
- Flooding one machine from different inputs (two schedules into one belt, two patterns into one splitter, two rates into one kiln) is deterministic: the same seed and state produce the same deliveries, and the different floods do not collapse to one output.
- Pickup returns a placed belt to the tray, including a kiln the room started with, and pickup during a run does the same through the game object.
- The documented belt, kiln, press, filter, splitter, roller, and weir timings, including that a blocked splitter does not flip and that a weir tries forward again after a spill.

## Limitations

- Two wings, 16 rooms. There is no overworld and no further wing yet. The full route is still 48 rooms.
- No audio, no gamepad, and no drag-paint.
- Items wait when blocked. They are not deleted, except by a waste chute.
- A splitter does not skip a blocked exit.
- Progress is a local Godot user file, not an account.
