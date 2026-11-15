# Brine Mark

Indirect colony sim, Salt Coast slice. One coast, a wet season, a short dry season, a cart beat, one quota of covered salt. You paint the flats. Ants follow the mark under their feet. You do not select them.

## Play

Requires Godot 4 (`godot` on `PATH`). This project was run with Godot 4.7.

From this directory:

```bash
godot --path .
```

Paint with the pointer: drag a mark, right-click to erase. The keyboard moves a cursor and sets the mark:

| Key | Action |
| --- | --- |
| Arrows or WASD | Move the cursor |
| 1, 2, 3, 4, 5, 6 | Rake, stack, cover, trail, pan, crib |
| 0 | Erase |
| Space or Enter | Paint the cursor cell |
| R | Restart scenario |

Rake the shore beside the brine during the wet season. Ants pile loose salt there. Stack moves loose salt into stacks. Cover keeps stacked salt when the rain arrives; loose salt is destroyed. The first rain banks whatever was covered and pulls the brine back. Shore rakes go idle. Pan marks crystallize loose salt on the drying flats until the second rain, and the same stack and cover marks move that salt under cover. Trail is how ants cross from the anthill to those marks. The countdown above the flats names the season and refills when the dry season starts. After the second rain, a cart beat opens and the countdown refills. Paint a crib. Workers carry the banked salt — the first-rain haul and whatever the dry season still holds under cover — into that crib. A crib is shut until the cart beat, so it does not change the earlier haul. A coast with no crib leaves the bank where it is. When the beat ends, the summary names the first haul, the dry-season haul, the cart if any salt moved, and why the quota failed if it did. Restart scenario clears the marks and runs Salt Coast again.

The slice population cap is 40. Flats, ants, and salt are drawn with Godot primitives.

## Tests

From this directory. Godot's exit code is non-zero when a check fails.

```bash
godot --headless --path . -s res://tests/run_tests.gd
```

The checks are:

- A scripted paint plan in `tests/plans.json` meets the covered-salt quota after both rains.
- An all-rake plan misses the quota, and the summary string names uncovered salt.
- A pan plan with no rakes stores nothing in the wet season and meets the quota in the dry season. It fails if pans do not crystallize, or if they crystallize while the brine is still in.
- A continued plan keeps the wet-season haul and adds at least another quota from pans.
- A plan that paints pans only after the first rain still meets the quota.
- The winning shore does not gain salt once the brine has pulled back.
- The winning shore and the dry-pan plan still store the same salt they did before the cart beat, and their summaries stay the same. Neither paints a crib.
- A plan that paints no crib fails the cart check. The bank does not move.
- The winning shore plus a crib keeps that same haul and moves the whole bank into the crib. Painting the crib when the cart beat opens moves the same amount.
- A dry-pan plan plus a crib keeps a wet haul of 0 and moves the dry-season bank off the covers into the crib.
- Two runs of the same paint produce the same stored-salt number and the same cart total.
- Population stays at or under 40 in those runs.
- The rules API has no select-ant function.

Tick rules live at the top of `scripts/sim.gd`.

## Limits

One scenario, two rains, one cart beat, no save, no audio. The dry season is 200 ticks (20 seconds) after the 600-tick wet season. The cart beat is 100 ticks (10 seconds) after the second rain. Ants are simulated labor with a fixed job, not units you pick up. A cell holds one mark. Nothing is rolled. The same paint on the same ticks always stores the same salt and carts the same amount, and the anthill stays at its starting cell.
