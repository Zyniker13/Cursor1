# Orchard Surge

A short run-based action game. Between waves you plant. Plants are both the guns and the lanterns. Unlit tiles hide pests; the pests are still there.

This is a vertical slice: one gardener, four plants, three waves, fog. A run is about two minutes. There is no meta unlock tree.

## Run

Requires Godot 4.7 (4.x with the compatibility renderer should also open the project). From the repository root:

```
godot --path orchard-surge
```

The window is the whole game. Restart advances the displayed seed. The first launch uses seed 1.

## Controls

- Move: `WASD` or arrow keys. Movement is real-time during a wave and paused for the planting interval (8 seconds).
- Plant: `1` Pea, `2` Vine, `3` Lantern, `4` Gourd, then click an open orchard tile. You have 6 seeds for the run.
- `R` or the Restart button starts a new run.

Getting hit costs health. Health at 0 ends the run. Surviving wave 3 wins. Wave 3 is a larger group of the same pest, not a boss.

## Tests

From the repository root. Godot exits non-zero if a check fails. The suite does not open a window.

```
godot --headless --path orchard-surge --script res://tests/run_tests.gd
```

The checks cover tooltip text against the sim constants, a stationary bot with no plants dying before wave 3, a scripted lantern-and-pea bot clearing all three waves on seed 42 (and the same bot on seeds 1, 7, 99, 256, and 2026), fog visibility, and the “no plant strictly dominates” inequalities. The bot only calls `step` and reads public sim fields.

## Simulation

`sim/orchard_sim.gd` is a fixed 30 Hz simulation with no scene tree. Combat, light, planting, and damage all step there. `scenes/main.gd` only samples input, calls `step`, and draws. The same seed and the same commands reproduce the same run. Spawn edges are the only random draws, and they come from a seeded generator.

A tile is lit when its rectangle meets any plant’s light radius. That updates every tick. A pest on an unlit tile is flagged hidden and is not drawn. Hidden pests still move and can deal contact damage. Plants shoot the nearest visible pest inside their weapon range.

Pests are orchard moths. On death they break into motes of light. There is no gore. Art is Godot primitives plus the fog overlay.

## Plant stats

Numbers below are the catalog constants in `sim/plant_catalog.gd`. Fire and slow times are `ticks / 30`. Tooltip labels are built from this table.

| Plant | Damage | Fire | Light radius | Weapon range | Shot speed | Slow | Splash |
| --- | ---: | ---: | ---: | ---: | ---: | --- | ---: |
| Pea | 4 | 0.20s (6 ticks) | 64px | 340px | 640px/s | none | none |
| Vine | 2 | 0.60s (18 ticks) | 84px | 300px | 360px/s | 0.40 speed for 2.00s | none |
| Lantern | 1 | 1.50s (45 ticks) | 220px | 52px | 220px/s | none | none |
| Gourd | 14 | 1.20s (36 ticks) | 132px | 300px | 300px/s | none | 64px |

Roles: Pea is the fast weak shot with a small light. Vine slows pests, deals tiny damage, and has a small light. Lantern deals almost no damage and is the large light you see by. Gourd is the slow heavy burst with a medium light and a splash.

Lantern damage is the lowest, not the highest. Pea light is the smallest, not the largest. Gourd’s fire interval is slower than the pea and the vine.

## World numbers

| Constant | Value |
| --- | --- |
| Tick | 1/30 s |
| Map | 15×11 tiles, 48px each |
| Orchard (plantable) | inner tiles, one tile in from the border |
| Player HP | 100 |
| Player speed | 130px/s |
| Player radius | 12px |
| Contact damage | 20 |
| Hurt cooldown | 0.40s (12 ticks), one hit at a time |
| Pest HP | 12 |
| Pest speed | 42px/s |
| Pest radius | 11px |
| Seeds | 6 |
| Planting interval | 8.00s (240 ticks), before wave 1 and between waves |
| Wave 1 | 8 pests, spawn every 2.40s |
| Wave 2 | 12 pests, spawn every 2.20s |
| Wave 3 | 22 pests, spawn every 2.00s |

## Limits

- Slice only: four plants, three waves, one pest type, no unlocks, no audio, no save.
- Plants cannot be uprooted or hurt.
- The gardener’s hurt cooldown prevents several moths from draining the whole health bar in one tick. Standing in them still kills you.
- Visuals are shapes and a fog overlay, not painted sprites.
- The headless suite drives the sim and boots the scene. It is not a human playtest.
