# Orchard Surge

A short run-based action game. Between nights you plant. Plants are both the guns and the lanterns. Unlit tiles hide pests; the pests are still there. Shroud moths stay hidden even in ordinary light. Rind moths stay hidden until a briar cracks them. Pitch moths stay sealed until a flare melts them. Frost moths stay sealed until a hearth thaws them. Web moths stay sealed until a shear cuts them. Glass moths stay sealed until a chime cracks them. Scale moths stay sealed until a rasp strips them. Mail moths stay sealed until a maul cracks them. Hide moths stay sealed until a bill splits them.

This is a vertical slice: one gardener, thirteen plants, twenty-one nights, fog. A run is a few minutes. There is no meta unlock tree.

## Run

Requires Godot 4.7 (4.x with the compatibility renderer should also open the project). From the repository root:

```
godot --path orchard-surge
```

The window is the whole game, 1120×4270, so the thirteen plant cards sit beside the orchard. Restart advances the displayed seed. The first launch uses seed 1.

## Controls

- Move: `WASD` or arrow keys. Movement is real-time during a night and paused for the planting interval (8 seconds).
- Plant: `1` Pea, `2` Vine, `3` Lantern, `4` Gourd, `5` Wick, `6` Briar, `7` Flare, `8` Hearth, `9` Shear, `0` Chime, `B` Rasp, `C` Maul, `E` Bill, then click an open orchard tile. Digits 1–9 were already plants, so the chime uses the remaining digit, `0`. Digits are full, and `A`, `S`, `D`, `W` move while `R` restarts, so the rasp uses `B`, the next free letter. `B` is taken, and those same controls are still held, so the maul uses `C`, the next free letter. `C` is taken, and those same controls are still held, so the bill uses `E`, the next free letter. You have 11 seeds for the run.
- `R` or the Restart button starts a new run.

Getting hit costs health. Health at 0 ends the run. Surviving night 21 wins. Nights 4 and 5 are shroud nights. Nights 6 and 7 are rind nights. Nights 8 and 9 are pitch nights. Nights 10 and 11 are frost nights. Nights 12 and 13 are web nights. Nights 14 and 15 are glass nights. Nights 16 and 17 are scale nights. Nights 18 and 19 are mail nights. Nights 20 and 21 are hide nights. Night 3 is still a larger group of the same ordinary moth.

## Tests

From the repository root. Godot exits non-zero if a check fails. The suite does not open a window.

```
godot --headless --path orchard-surge --script res://tests/run_tests.gd
```

The checks cover tooltip text against the sim constants, a stationary bot with no plants dying before night 3, a scripted lantern-and-pea bot clearing the first three nights, that same garden dying on the shroud night when the wick's light does not cover the gardener, a lantern-pea-and-wick bot clearing nights 1–5 and then dying on night 6 when no briar is planted, that garden dying on night 6 again when the briar is planted in the far corner, a lantern-pea-wick-and-briar bot still clearing night 7 and then dying on night 8 when no flare is planted, that garden dying on night 8 again when the flare is planted in the far corner, a lantern-pea-wick-briar-and-flare bot still clearing night 9 and then dying on night 10 when no hearth is planted, that garden dying on night 10 or 11 again when the hearth is planted in the far corner, a lantern-pea-wick-briar-flare-and-hearth bot still clearing night 11 and then dying on night 12 when no shear is planted, that garden dying on night 12 or 13 again when the shear is planted in the far corner, a lantern-pea-wick-briar-flare-hearth-and-shear bot still clearing night 13 and then dying on night 14 when no chime is planted, that garden dying on night 14 again when the chime is planted in the far corner, a lantern-pea-wick-briar-flare-hearth-shear-and-chime bot still clearing night 15 and then dying on night 16 when no rasp is planted, that garden dying on night 16 again when the rasp is planted in the far corner, a lantern-pea-wick-briar-flare-hearth-shear-chime-and-rasp bot still clearing night 17 and then dying on night 18 when no maul is planted, that garden dying on night 18 again when the maul is planted in the far corner, a lantern-pea-wick-briar-flare-hearth-shear-chime-rasp-and-maul bot still clearing night 19 and then dying on night 20 when no bill is planted, that garden dying on night 20 again when the bill is planted in the far corner, a lantern-pea-wick-briar-flare-hearth-shear-chime-rasp-maul-and-bill bot clearing all twenty-one nights on seed 42 (and the same bot on seeds 1, 7, 99, 256, and 2026), the wick shroud rule, the briar rind rule, the flare pitch rule, the hearth frost rule, the shear web rule, the chime glass rule, the rasp scale rule, the maul mail rule, the bill hide rule, fog visibility, and the "no plant strictly dominates" inequalities. The bot only calls `step` and reads public sim fields.

## Simulation

`sim/orchard_sim.gd` is a fixed 30 Hz simulation with no scene tree. Combat, light, planting, and damage all step there. `scenes/main.gd` only samples input, calls `step`, and draws. The same seed and the same commands reproduce the same run. Spawn edges are the only random draws, and they come from a seeded generator.

A tile is lit when its rectangle meets any plant’s light radius. That updates every tick. A pest on an unlit tile is flagged hidden and is not drawn. Hidden pests still move and can deal contact damage. Plants shoot the nearest visible pest inside their weapon range.

A shroud moth is the same pest with one extra rule. Ordinary light, including the lantern, does not reveal it and shots do not hurt it, splash included. A wick burns the shroud only while the moth’s tile meets that wick’s light. Outside that light the shroud closes again. Contact damage still lands, so a shroud you never burn will reach you and the night cannot end.

A rind moth is the same pest with a different lock. Ordinary light does not reveal it, and neither does a wick. Shots do not hurt it, splash included, until a briar cracks the tile it stands on. Outside that light the rind closes again. A moth that is both shroud and rind stays closed until the tile is in wick light and briar light at once. Either light alone leaves it shut. Contact damage still lands, so a rind you never crack will reach you and the night cannot end.

A pitch moth is the same pest with a third lock. Ordinary light does not reveal it, and neither does a wick or a briar. Shots do not hurt it, splash included, until a flare melts the tile it stands on. Outside that light the pitch seals again. A moth that carries more than one lock stays closed until every lock is open on that tile. Contact damage still lands, so a pitch you never melt will reach you and the night cannot end.

A frost moth is the same pest with a fourth lock. Ordinary light does not reveal it, and neither does a wick, a briar, or a flare. Shots do not hurt it, splash included, until a hearth thaws the tile it stands on. Outside that light the frost closes again. A moth that carries more than one lock stays closed until every lock is open on that tile. Contact damage still lands, so a frost you never thaw will reach you and the night cannot end.

A web moth is the same pest with a fifth lock. Ordinary light does not reveal it, and neither does a wick, a briar, a flare, or a hearth. Shots do not hurt it, splash included, until a shear cuts the tile it stands on. Outside that light the web closes again. A moth that carries more than one lock stays closed until every lock is open on that tile. Contact damage still lands, so a web you never cut will reach you and the night cannot end.

A glass moth is the same pest with a sixth lock. Ordinary light does not reveal it, and neither does a wick, a briar, a flare, a hearth, or a shear. Shots do not hurt it, splash included, until a chime cracks the tile it stands on. Outside that light the glass seals again. A moth that carries more than one lock stays closed until every lock is open on that tile. Contact damage still lands, so a glass you never crack will reach you and the night cannot end.

A scale moth is the same pest with a seventh lock. Ordinary light does not reveal it, and neither does a wick, a briar, a flare, a hearth, a shear, or a chime. Shots do not hurt it, splash included, until a rasp strips the tile it stands on. Outside that light the scale seals again. A moth that carries more than one lock stays closed until every lock is open on that tile. Contact damage still lands, so a scale you never strip will reach you and the night cannot end.

A mail moth is the same pest with an eighth lock. Ordinary light does not reveal it, and neither does a wick, a briar, a flare, a hearth, a shear, a chime, or a rasp. Shots do not hurt it, splash included, until a maul cracks the tile it stands on. Outside that light the mail seals again. A moth that carries more than one lock stays closed until every lock is open on that tile. Contact damage still lands, so a mail you never crack will reach you and the night cannot end.

A hide moth is the same pest with a ninth lock. Ordinary light does not reveal it, and neither does a wick, a briar, a flare, a hearth, a shear, a chime, a rasp, or a maul. Shots do not hurt it, splash included, until a bill splits the tile it stands on. Outside that light the hide seals again. A moth that carries more than one lock stays closed until every lock is open on that tile. Contact damage still lands, so a hide you never split will reach you and the night cannot end.

Pests are orchard moths. On death they break into motes of light. There is no gore. Art is Godot primitives plus the fog overlay. A revealed shroud moth is drawn as a darker body with a broken ember ring. A revealed rind moth is drawn as a bark body with a broken thorn ring. A revealed pitch moth is drawn as a tar body with a broken gold ring. A revealed frost moth is drawn as an ice body with a broken pale ring. A revealed web moth is drawn as a thread body with a broken silk ring. A revealed glass moth is drawn as a pane body with a broken glass ring. A revealed scale moth is drawn as a plate body with a broken scale ring. A revealed mail moth is drawn as an iron body with a broken mail ring. A revealed hide moth is drawn as a leather body with a broken hide ring. A moth that carries more than one lock wears each of those rings.

## Plant stats

Numbers below are the catalog constants in `sim/plant_catalog.gd`. Fire and slow times are `ticks / 30`. Tooltip labels are built from this table.

| Plant | Damage | Fire | Light radius | Weapon range | Shot speed | Slow | Splash | Shroud | Rind | Pitch | Frost | Web | Glass | Scale | Mail | Hide |
| --- | ---: | ---: | ---: | ---: | ---: | --- | ---: | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Pea | 4 | 0.20s (6 ticks) | 64px | 340px | 640px/s | none | none | none | none | none | none | none | none | none | none | none |
| Vine | 2 | 0.60s (18 ticks) | 84px | 300px | 360px/s | 0.40 speed for 2.00s | none | none | none | none | none | none | none | none | none | none |
| Lantern | 1 | 1.50s (45 ticks) | 220px | 52px | 220px/s | none | none | none | none | none | none | none | none | none | none | none |
| Gourd | 14 | 1.20s (36 ticks) | 132px | 300px | 300px/s | none | 64px | none | none | none | none | none | none | none | none | none |
| Wick | 3 | 0.40s (12 ticks) | 96px | 240px | 480px/s | none | none | burns | none | none | none | none | none | none | none | none |
| Briar | 5 | 0.50s (15 ticks) | 104px | 200px | 420px/s | none | none | none | cracks | none | none | none | none | none | none | none |
| Flare | 6 | 0.30s (9 ticks) | 112px | 220px | 460px/s | none | none | none | none | melts | none | none | none | none | none | none |
| Hearth | 4 | 0.70s (21 ticks) | 128px | 180px | 400px/s | none | none | none | none | none | thaws | none | none | none | none | none |
| Shear | 5 | 0.80s (24 ticks) | 144px | 160px | 380px/s | none | none | none | none | none | none | cuts | none | none | none | none |
| Chime | 3 | 0.90s (27 ticks) | 160px | 140px | 360px/s | none | none | none | none | none | none | none | cracks | none | none | none |
| Rasp | 4 | 1.00s (30 ticks) | 176px | 120px | 340px/s | none | none | none | none | none | none | none | none | strips | none | none |
| Maul | 5 | 1.10s (33 ticks) | 192px | 100px | 320px/s | none | none | none | none | none | none | none | none | none | cracks | none |
| Bill | 3 | 1.20s (36 ticks) | 208px | 80px | 300px/s | none | none | none | none | none | none | none | none | none | none | splits |

Roles: Pea is the fast weak shot with a small light. Vine slows pests, deals tiny damage, and has a small light. Lantern deals almost no damage and is the large light you see by. Gourd is the slow heavy burst with a medium light and a splash. Wick is the only shroud burner: modest shots and a tight coal light. Plant it where the night will reach you. A wick in a far corner does not burn shrouds on the gardener. Briar is the only rind cracker: a short shot and a tight thorn light. A briar in a far corner does not crack rind on the gardener, and a wick cannot do that job. Flare is the only pitch melter: a short shot and a tight resin light. A flare in a far corner does not melt pitch on the gardener, and neither a wick nor a briar can do that job. Hearth is the only frost thaw: modest shots and a tight coal-blue light. A hearth in a far corner does not thaw frost on the gardener, and neither a wick, a briar, nor a flare can do that job. Shear is the only web cutter: modest shots and a tight thread light. A shear in a far corner does not cut web on the gardener, and neither a wick, a briar, a flare, nor a hearth can do that job. Chime is the only glass cracker: modest shots and a tight pane light. The clearing garden plants it at tile (8, 6), beside the pea and the shear, so that light reaches the gardener. A chime at (1, 1), the far corner, does not crack glass on the gardener, and neither a wick, a briar, a flare, a hearth, nor a shear can do that job. Rasp is the only scale stripper: modest shots and a tight file light. The clearing garden plants it at tile (9, 5), east of the pea, so that light reaches the gardener and the tiles where the other locks already open. A rasp at (1, 1), the far corner, does not strip scale on the gardener, and neither a wick, a briar, a flare, a hearth, a shear, nor a chime can do that job. Maul is the only mail cracker: modest shots and a tight iron light. The clearing garden plants it at tile (9, 6), south of the rasp and east of the chime, so that light reaches the gardener and the tiles where the other locks already open. A maul at (1, 1), the far corner, does not crack mail on the gardener, and neither a wick, a briar, a flare, a hearth, a shear, a chime, nor a rasp can do that job. Bill is the only hide splitter: modest shots and a tight hook light. The clearing garden plants it at tile (8, 4), north of the pea and east of the flare, so that light reaches the gardener and the tiles where the other locks already open. A bill at (1, 1), the far corner, does not split hide on the gardener, and neither a wick, a briar, a flare, a hearth, a shear, a chime, a rasp, nor a maul can do that job.

Lantern damage is the lowest, not the highest. Pea light is the smallest, not the largest. Gourd’s fire interval is slower than the pea and the vine. Wick’s light is smaller than the lantern, its damage is lower than the gourd, and it fires slower than the pea. Briar does not burn shroud. Its light is smaller than the lantern, its damage is lower than the gourd, and it fires slower than the pea. Flare does not burn shroud and does not crack rind. Its light is smaller than the lantern, its damage is lower than the gourd, and it fires slower than the pea. Hearth does not burn shroud, does not crack rind, and does not melt pitch. Its light is smaller than the lantern, its damage is lower than the gourd, and it fires slower than the pea. Shear does not burn shroud, does not crack rind, does not melt pitch, and does not thaw frost. Its light is smaller than the lantern, its damage is lower than the gourd, and it fires slower than the pea. Chime does not burn shroud, does not crack rind, does not melt pitch, does not thaw frost, and does not cut web. Its light is smaller than the lantern, its damage is lower than the gourd, and it fires slower than the pea. Rasp does not burn shroud, does not crack rind, does not melt pitch, does not thaw frost, does not cut web, and does not crack glass. Its light is smaller than the lantern, its damage is lower than the gourd, and it fires slower than the pea. Maul does not burn shroud, does not crack rind, does not melt pitch, does not thaw frost, does not cut web, does not crack glass, and does not strip scale. Its light is smaller than the lantern, its damage is lower than the gourd, and it fires slower than the pea. Bill does not burn shroud, does not crack rind, does not melt pitch, does not thaw frost, does not cut web, does not crack glass, does not strip scale, and does not crack mail. Its light is smaller than the lantern, its damage is lower than the gourd, and it fires slower than the pea.

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
| Seeds | 11 |
| Planting interval | 8.00s (240 ticks), before night 1 and between nights |
| Night 1 | 8 moths, spawn every 2.40s |
| Night 2 | 12 moths, spawn every 2.20s |
| Night 3 | 22 moths, spawn every 2.00s |
| Night 4 (Shroud) | 8 shroud moths, spawn every 2.60s |
| Night 5 (Ash) | 16 moths, every second one a shroud, spawn every 1.80s |
| Night 6 (Rind) | 10 rind moths, spawn every 2.40s |
| Night 7 (Gall) | 16 moths, every spawn a rind and every second also a shroud, spawn every 2.00s |
| Night 8 (Pitch) | 10 pitch moths, spawn every 2.40s |
| Night 9 (Tar) | 16 moths, every spawn a pitch and a rind, and every second also a shroud, spawn every 2.00s |
| Night 10 (Frost) | 10 frost moths, spawn every 2.40s |
| Night 11 (Rime) | 16 moths, every spawn a frost, a pitch, and a rind, and every second also a shroud, spawn every 2.00s |
| Night 12 (Web) | 10 web moths, spawn every 2.40s |
| Night 13 (Snare) | 16 moths, every spawn a web, a frost, a pitch, and a rind, and every second also a shroud, spawn every 2.00s |
| Night 14 (Glass) | 10 glass moths, spawn every 2.40s |
| Night 15 (Pane) | 16 moths, every spawn a glass, a web, a frost, a pitch, and a rind, and every second also a shroud, spawn every 2.00s |
| Night 16 (Scale) | 10 scale moths, spawn every 2.40s |
| Night 17 (Plate) | 16 moths, every spawn a scale, a glass, a web, a frost, a pitch, and a rind, and every second also a shroud, spawn every 2.00s |
| Night 18 (Mail) | 10 mail moths, spawn every 2.40s |
| Night 19 (Armor) | 16 moths, every spawn a mail, a scale, a glass, a web, a frost, a pitch, and a rind, and every second also a shroud, spawn every 2.00s |
| Night 20 (Hide) | 10 hide moths, spawn every 2.40s |
| Night 21 (Coat) | 16 moths, every spawn a hide, a mail, a scale, a glass, a web, a frost, a pitch, and a rind, and every second also a shroud, spawn every 2.00s |

Shroud moths, rind moths, pitch moths, frost moths, web moths, glass moths, scale moths, mail moths, and hide moths use the same HP, speed, radius, and contact damage. Nights 1–3 are the original three waves and spawn no shrouds, no rind, no pitch, no frost, no web, no glass, no scale, no mail, and no hide. Nights 4 and 5 spawn no rind, no pitch, no frost, no web, no glass, no scale, no mail, and no hide. Night 6 spawns no shrouds, no pitch, no frost, no web, no glass, no scale, no mail, and no hide. Night 7 spawns no pitch, no frost, no web, no glass, no scale, no mail, and no hide. Night 8 spawns no shrouds, no rind, no frost, no web, no glass, no scale, no mail, and no hide. Night 9 spawns no frost, no web, no glass, no scale, no mail, and no hide. Night 10 spawns no shrouds, no rind, no pitch, no web, no glass, no scale, no mail, and no hide. Night 11 spawns no web, no glass, no scale, no mail, and no hide. Night 12 spawns no shrouds, no rind, no pitch, no frost, no glass, no scale, no mail, and no hide. Night 13 spawns no glass, no scale, no mail, and no hide. Night 14 spawns no shrouds, no rind, no pitch, no frost, no web, no scale, no mail, and no hide. Night 15 spawns no scale, no mail, and no hide. Night 16 spawns no shrouds, no rind, no pitch, no frost, no web, no glass, no mail, and no hide. Night 17 spawns no mail and no hide. Night 18 spawns no shrouds, no rind, no pitch, no frost, no web, no glass, no scale, and no hide. Night 19 spawns no hide. Night 20 spawns no shrouds, no rind, no pitch, no frost, no web, no glass, no scale, and no mail.

## Limits

- Slice only: thirteen plants, twenty-one nights, shroud moths on nights 4, 5, 7, 9, 11, 13, 15, 17, 19, and 21, rind moths on nights 6, 7, 9, 11, 13, 15, 17, 19, and 21, pitch moths on nights 8, 9, 11, 13, 15, 17, 19, and 21, frost moths on nights 10, 11, 13, 15, 17, 19, and 21, web moths on nights 12, 13, 15, 17, 19, and 21, glass moths on nights 14, 15, 17, 19, and 21, scale moths on nights 16, 17, 19, and 21, mail moths on nights 18, 19, and 21, hide moths on nights 20 and 21, no unlocks, no audio, no save.
- Plants cannot be uprooted or hurt.
- The gardener’s hurt cooldown prevents several moths from draining the whole health bar in one tick. Standing in them still kills you.
- A shroud moth that never enters wick light cannot be cleared. A rind moth that never enters briar light cannot be cleared. A pitch moth that never enters flare light cannot be cleared. A frost moth that never enters hearth light cannot be cleared. A web moth that never enters shear light cannot be cleared. A glass moth that never enters chime light cannot be cleared. A scale moth that never enters rasp light cannot be cleared. A mail moth that never enters maul light cannot be cleared. A hide moth that never enters bill light cannot be cleared. Kiting any of them does not end the night.
- Visuals are shapes and a fog overlay, not painted sprites.
- The headless suite drives the sim and boots the scene. It is not a human playtest.
