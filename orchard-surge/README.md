# Orchard Surge

A short run-based action game. Between nights you plant. Plants are both the guns and the lanterns. Unlit tiles hide pests; the pests are still there. Shroud moths stay hidden even in ordinary light. Rind moths stay hidden until a briar cracks them.

This is a vertical slice: one gardener, six plants, seven nights, fog. A run is a few minutes. There is no meta unlock tree.

## Run

Requires Godot 4.7 (4.x with the compatibility renderer should also open the project). From the repository root:

```
godot --path orchard-surge
```

The window is the whole game, 1120×1280, so the six plant cards sit beside the orchard. Restart advances the displayed seed. The first launch uses seed 1.

## Controls

- Move: `WASD` or arrow keys. Movement is real-time during a night and paused for the planting interval (8 seconds).
- Plant: `1` Pea, `2` Vine, `3` Lantern, `4` Gourd, `5` Wick, `6` Briar, then click an open orchard tile. You have 6 seeds for the run.
- `R` or the Restart button starts a new run.

Getting hit costs health. Health at 0 ends the run. Surviving night 7 wins. Nights 4 and 5 are shroud nights. Nights 6 and 7 are rind nights. Night 3 is still a larger group of the same ordinary moth.

## Tests

From the repository root. Godot exits non-zero if a check fails. The suite does not open a window.

```
godot --headless --path orchard-surge --script res://tests/run_tests.gd
```

The checks cover tooltip text against the sim constants, a stationary bot with no plants dying before night 3, a scripted lantern-and-pea bot clearing the first three nights, that same garden dying on the shroud night when the wick's light does not cover the gardener, a lantern-pea-and-wick bot clearing nights 1–5 and then dying on night 6 when no briar is planted, that garden dying on night 6 again when the briar is planted in the far corner, a lantern-pea-wick-and-briar bot clearing all seven nights on seed 42 (and the same bot on seeds 1, 7, 99, 256, and 2026), the wick shroud rule, the briar rind rule, fog visibility, and the "no plant strictly dominates" inequalities. The bot only calls `step` and reads public sim fields.

## Simulation

`sim/orchard_sim.gd` is a fixed 30 Hz simulation with no scene tree. Combat, light, planting, and damage all step there. `scenes/main.gd` only samples input, calls `step`, and draws. The same seed and the same commands reproduce the same run. Spawn edges are the only random draws, and they come from a seeded generator.

A tile is lit when its rectangle meets any plant’s light radius. That updates every tick. A pest on an unlit tile is flagged hidden and is not drawn. Hidden pests still move and can deal contact damage. Plants shoot the nearest visible pest inside their weapon range.

A shroud moth is the same pest with one extra rule. Ordinary light, including the lantern, does not reveal it and shots do not hurt it, splash included. A wick burns the shroud only while the moth’s tile meets that wick’s light. Outside that light the shroud closes again. Contact damage still lands, so a shroud you never burn will reach you and the night cannot end.

A rind moth is the same pest with a different lock. Ordinary light does not reveal it, and neither does a wick. Shots do not hurt it, splash included, until a briar cracks the tile it stands on. Outside that light the rind closes again. A moth that is both shroud and rind stays closed until the tile is in wick light and briar light at once. Either light alone leaves it shut. Contact damage still lands, so a rind you never crack will reach you and the night cannot end.

Pests are orchard moths. On death they break into motes of light. There is no gore. Art is Godot primitives plus the fog overlay. A revealed shroud moth is drawn as a darker body with a broken ember ring. A revealed rind moth is drawn as a bark body with a broken thorn ring. A moth that is both wears both rings.

## Plant stats

Numbers below are the catalog constants in `sim/plant_catalog.gd`. Fire and slow times are `ticks / 30`. Tooltip labels are built from this table.

| Plant | Damage | Fire | Light radius | Weapon range | Shot speed | Slow | Splash | Shroud | Rind |
| --- | ---: | ---: | ---: | ---: | ---: | --- | ---: | --- | --- |
| Pea | 4 | 0.20s (6 ticks) | 64px | 340px | 640px/s | none | none | none | none |
| Vine | 2 | 0.60s (18 ticks) | 84px | 300px | 360px/s | 0.40 speed for 2.00s | none | none | none |
| Lantern | 1 | 1.50s (45 ticks) | 220px | 52px | 220px/s | none | none | none | none |
| Gourd | 14 | 1.20s (36 ticks) | 132px | 300px | 300px/s | none | 64px | none | none |
| Wick | 3 | 0.40s (12 ticks) | 96px | 240px | 480px/s | none | none | burns | none |
| Briar | 5 | 0.50s (15 ticks) | 104px | 200px | 420px/s | none | none | none | cracks |

Roles: Pea is the fast weak shot with a small light. Vine slows pests, deals tiny damage, and has a small light. Lantern deals almost no damage and is the large light you see by. Gourd is the slow heavy burst with a medium light and a splash. Wick is the only shroud burner: modest shots and a tight coal light. Plant it where the night will reach you. A wick in a far corner does not burn shrouds on the gardener. Briar is the only rind cracker: a short shot and a tight thorn light. A briar in a far corner does not crack rind on the gardener, and a wick cannot do that job.

Lantern damage is the lowest, not the highest. Pea light is the smallest, not the largest. Gourd’s fire interval is slower than the pea and the vine. Wick’s light is smaller than the lantern, its damage is lower than the gourd, and it fires slower than the pea. Briar does not burn shroud. Its light is smaller than the lantern, its damage is lower than the gourd, and it fires slower than the pea.

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
| Moth HP | 12 |
| Moth speed | 42px/s |
| Moth radius | 11px |
| Seeds | 6 |
| Planting interval | 8.00s (240 ticks), before night 1 and between nights |
| Night 1 | 8 moths, spawn every 2.40s |
| Night 2 | 12 moths, spawn every 2.20s |
| Night 3 | 22 moths, spawn every 2.00s |
| Night 4 (Shroud) | 8 shroud moths, spawn every 2.60s |
| Night 5 (Ash) | 16 moths, every second one a shroud, spawn every 1.80s |
| Night 6 (Rind) | 10 rind moths, spawn every 2.40s |
| Night 7 (Gall) | 16 moths, every spawn a rind and every second also a shroud, spawn every 2.00s |

Shroud moths and rind moths use the same HP, speed, radius, and contact damage. Nights 1–3 are the original three waves and spawn no shrouds and no rind. Nights 4 and 5 spawn no rind. Night 6 spawns no shrouds.

## Limits

- Slice only: six plants, seven nights, shroud moths on nights 4, 5, and 7, rind moths on nights 6 and 7, no unlocks, no audio, no save.
- Plants cannot be uprooted or hurt.
- The gardener’s hurt cooldown prevents several moths from draining the whole health bar in one tick. Standing in them still kills you.
- A shroud moth that never enters wick light cannot be cleared. A rind moth that never enters briar light cannot be cleared. Kiting either one does not end the night.
- Visuals are shapes and a fog overlay, not painted sprites.
- The headless suite drives the sim and boots the scene. It is not a human playtest.
