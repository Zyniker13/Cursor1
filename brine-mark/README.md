# Brine Mark

Indirect colony sim, Salt Coast slice. One coast, one rain, one quota of covered salt. You paint the flats. Ants follow the mark under their feet. You do not select them.

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
| 1, 2, 3, 4 | Rake, stack, cover, trail |
| 0 | Erase |
| Space or Enter | Paint the cursor cell |
| R | Restart scenario |

Rake the shore beside the brine. Ants pile loose salt there. Stack moves loose salt into stacks. Cover keeps stacked salt when the rain arrives; loose salt is destroyed. Trail is how ants cross from the anthill to those marks. The rain countdown sits above the flats. After the rain, the summary names why the quota failed. Restart scenario clears the marks and runs Salt Coast again.

The slice population cap is 40. Flats, ants, and salt are drawn with Godot primitives.

## Tests

From this directory. Godot's exit code is non-zero when a check fails.

```bash
godot --headless --path . -s res://tests/run_tests.gd
```

The checks are:

- A scripted paint plan in `tests/plans.json` meets the covered-salt quota after the rain.
- An all-rake plan misses the quota, and the summary string names uncovered salt.
- Two runs of the same paint produce the same stored-salt number.
- Population stays at or under 40 in those runs.
- The rules API has no select-ant function.

Tick rules live at the top of `scripts/sim.gd`.

## Limits

One scenario, one rain, no save, no audio. Ants are simulated labor with a fixed job, not units you pick up. A cell holds one mark. The sim is deterministic when the paint map is the same on each tick and the anthill stays at its starting cell.
