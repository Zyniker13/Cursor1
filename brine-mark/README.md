# Brine Mark

Indirect colony sim, Salt Coast slice. One coast, a wet season, a short dry season, a cart beat, a ship beat, a market beat, a yard beat, a bunk beat, a loft beat, a gate beat, a wage beat, a relief beat, a watch beat, a lamp beat, one quota of covered salt. You paint the flats. Ants follow the mark under their feet. You do not select them.

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
| 1, 2, 3, 4, 5, 6, 7, 8, 9 | Rake, stack, cover, trail, pan, crib, ship, stall, yard |
| 0 | Bunk |
| B | Loft |
| C | Gate |
| E | Wage |
| F | Relief |
| G | Watch |
| H | Lamp |
| Space or Enter | Paint the cursor cell |
| R | Restart scenario |

Rake the shore beside the brine during the wet season. Ants pile loose salt there. Stack moves loose salt into stacks. Cover keeps stacked salt when the rain arrives; loose salt is destroyed. The first rain banks whatever was covered and pulls the brine back. Shore rakes go idle. Pan marks crystallize loose salt on the drying flats until the second rain, and the same stack and cover marks move that salt under cover. Trail is how ants cross from the anthill to those marks. The countdown above the flats names the season and refills when the dry season starts. After the second rain, a cart beat opens and the countdown refills. Paint a crib. Workers carry the banked salt — the first-rain haul and whatever the dry season still holds under cover — into that crib. A crib is shut until the cart beat, so it does not change the earlier haul. A coast with no crib leaves the bank where it is. After the cart beat, a ship beat opens and the countdown refills. Paint a ship. Workers load the salt sitting in the crib onto that ship. A ship is shut until the ship beat, so it does not change the wet haul, the dry haul, or the cart. A crib with no ship keeps the salt. After the ship beat, a market beat opens and the countdown refills. Paint a stall. Workers sell the salt already on the ship, one unit at a time, at one coin per unit. A stall is shut until the market beat, so it does not change the wet haul, the dry haul, the cart, or the shipment. A ship with no stall keeps the salt, and the coin total stays 0. After the market beat, a yard beat opens and the countdown refills. Paint a yard. Workers bank the coins already earned, one coin at a time. A yard is shut until the yard beat, so it does not change the wet haul, the dry haul, the cart, the shipment, or the earned coins. A purse with no yard stays at the stall, and the yard total stays 0. After the yard beat, a bunk beat opens and the countdown refills. Paint a bunk one cell north of the yard. Workers hire from the coins already banked, in a fixed order, at 100 coins for one hire. A bunk is shut until the bunk beat, so it does not change the wet haul, the dry haul, the cart, the shipment, or the earned coins. One bunk hires every full hundred and leaves the remainder in the yard. A purse with no bunk hires nobody, and the earned coin total is still reported. After the bunk beat, a loft beat opens and the countdown refills. Paint a loft one cell north of the bunk. Workers move the hires already recorded, one hire at a time, in a fixed order. A loft is shut until the loft beat, so it does not change the wet haul, the dry haul, the cart, the shipment, the earned coins, the hires, or the yard remainder. One loft takes the whole crew. A bunk with no loft keeps the hires, and the loft total stays 0. After the loft beat, a gate beat opens and the countdown refills. Paint a gate one cell north of the loft. Workers let the hires already recorded through, one hire at a time, in the same fixed order. A gate is shut until the gate beat, so it does not change the wet haul, the dry haul, the cart, the shipment, the earned coins, the hires, or the yard remainder. The gate lets 10 through and then stops, even if the countdown has time left. Hires past that cap stay in the loft. A loft with no gate keeps the hires, and the gate total stays 0. After the gate beat, a wage beat opens and the countdown refills. Paint a wage one cell north of the gate. `E` is the next free letter: `D` stays a move key. Workers pay the hires who already passed, one hire at a time, in the same order they passed the gate, at 4 coins a hire taken from the coins left in the yard. A wage is shut until the wage beat, so it does not change the wet haul, the dry haul, the cart, the shipment, the earned coins, or the hires. If the yard holds fewer than 4 coins, that hire stays unpaid, the remaining coins stay, and later work does nothing. Hires still in the loft are not paid. A gate with no wage pays nobody, and the yard remainder stays. After the wage beat, a relief beat opens and the countdown refills. Paint a relief one cell north of the wage. `F` is the next free letter: it is not a terrain key and not a move key. Workers post the hires who were already paid, one hire at a time, in the same order they were paid. A relief is shut until the relief beat, so it does not change the wet haul, the dry haul, the cart, the shipment, the earned coins, the hires, or the coins left in the yard. The relief posts 6 and then stops, even if the countdown has time left and paid hires remain. Hires who were not paid are not posted. That includes hires still in the loft and hires who passed the gate but were not paid. A wage with no relief posts nobody, and the paid hires stay on the wage. After the relief beat, a watch beat opens and the countdown refills. Paint a watch one cell north of the relief. `G` is the next free letter: it is not a terrain key and not a move key. Workers stand the hires who were already posted, one hire at a time, in the same order they were posted. A watch is shut until the watch beat, so it does not change the wet haul, the dry haul, the cart, the shipment, the earned coins, the hires, the coins left in the yard, or the posted count. The watch stands 4 and then stops, even if the countdown has time left and posted hires remain. Hires who were not posted are not stood. That includes hires still in the loft, hires who passed the gate but were not paid, and hires who were paid but were not posted. A relief with no watch stands nobody, and the posted hires stay on the relief. A watch with nobody posted stands nobody. After the watch beat, a lamp beat opens and the countdown refills. Paint a lamp one cell north of the watch. `H` is the next free letter: it is not a terrain key and not a move key. Workers light the hires who were already stood, one hire at a time, in the same order they were stood. A lamp is shut until the lamp beat, so it does not change the wet haul, the dry haul, the cart, the shipment, the earned coins, the hires, the coins left in the yard, the posted count, or the stood count. The lamp lights 3 and then stops, even if the countdown has time left and stood hires remain. Hires who were not stood are not lit. That includes hires still in the loft, hires who passed the gate but were not paid, hires who were paid but were not posted, and hires who were posted but were not stood. A watch with no lamp lights nobody, and the stood hires stay on the watch. A lamp with nobody stood lights nobody. When the beats end, the summary names the first haul, the dry-season haul, the cart if any salt moved, the shipment if any salt left the crib, the coins if any salt sold, the yard if any coins were banked, the hires if any coins were spent, the loft if any hires moved, the gate if any hires passed, the wage if any of those hires were paid, the relief if any of those paid hires were posted, the watch if any of those posted hires were stood, the lamp if any of those stood hires were lit, and why the quota failed if it did. Restart scenario clears the marks and runs Salt Coast again.

The slice population cap is 40. Flats, ants, salt, and the lamp are drawn with Godot primitives.

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
- The winning shore, the dry-pan plan, and the cart plans still report the same wet haul, dry haul, and carted salt.
- A plan that fills the crib and paints no ship fails the ship check. The salt stays in the crib.
- The carted shore plus one ship north of the crib keeps that wet haul, dry haul, and cart, and loads the whole crib onto the ship. Painting the ship when the ship beat opens loads the same amount.
- A dry-pan plan plus a crib and a ship keeps a wet haul of 0 and loads the dry-season crib onto the ship.
- The winning shore, the dry pans, the cart plans, and the ship plans still report the same wet haul, dry haul, carted salt, and shipped salt.
- A plan that ships salt and paints no stall fails the market check. The salt stays on the ship and the coin total stays 0.
- The shipped shore plus one stall north of the ship keeps that wet haul, dry haul, cart, and shipment, and sells the whole cargo for 2997 coins. Painting the stall when the market beat opens sells the same amount.
- A dry-pan plan plus a crib, a ship, and a stall keeps a wet haul of 0 and sells the dry-season cargo for 1032 coins.
- The winning shore, the dry pans, the cart plans, the ship plans, and the market plans still report the same wet haul, dry haul, carted salt, shipped salt, and earned coins.
- A plan that earns coins and paints no yard fails the yard check. The yard total stays 0, and the earned coin total is still reported.
- The sold shore plus one yard north of the stall keeps that wet haul, dry haul, cart, shipment, and earned coins, and banks the whole purse for 2997. Painting the yard when the yard beat opens banks the same amount.
- A dry-pan plan plus a crib, a ship, a stall, and a yard keeps a wet haul of 0 and banks the dry-season purse for 1032.
- The winning shore, the dry pans, the cart plans, the ship plans, and the market plans still report the same wet haul, dry haul, carted salt, shipped salt, and earned coins.
- A plan that banks coins and paints no bunk fails the bunk check. It hires 0 and leaves the whole purse in the yard. The earned coin total is still reported.
- The banked shore plus one bunk north of the yard keeps that wet haul, dry haul, cart, shipment, earned coins, and bank, and hires 29, leaving 97 in the yard. Painting the bunk when the bunk beat opens hires the same number.
- A dry-pan plan plus a crib, a ship, a stall, a yard, and a bunk keeps a wet haul of 0 and hires 10, leaving 32 in the yard.
- A plan that hires and paints no loft fails the loft check. It lofts 0 and leaves the hires at the bunk.
- The hired shore plus one loft north of the bunk keeps that wet haul, dry haul, cart, shipment, earned coins, hires, and yard remainder, and lofts 29. Painting the loft when the loft beat opens lofts the same number.
- A dry-pan plan plus a crib, a ship, a stall, a yard, a bunk, and a loft keeps a wet haul of 0 and lofts 10, leaving 32 in the yard.
- The winning shore, the dry pans, the cart plans, the ship plans, the market plans, and the bunk plans still report the same wet haul, dry haul, carted salt, shipped salt, earned coins, and hires.
- A plan that lofts and paints no gate fails the gate check. It lets 0 through and leaves the hires in the loft.
- The lofted shore plus one gate north of the loft keeps that wet haul, dry haul, cart, shipment, earned coins, hires, and yard remainder, and lets 10 through, leaving 19 in the loft. Painting the gate when the gate beat opens lets the same number through.
- A dry-pan plan plus a crib, a ship, a stall, a yard, a bunk, a loft, and a gate keeps a wet haul of 0 and lets 10 through, leaving 0 in the loft.
- The winning shore, the dry pans, the cart plans, the ship plans, the market plans, the bunk plans, and the loft plans still report the same wet haul, dry haul, carted salt, shipped salt, earned coins, hires, and loft total.
- A plan that lets hires through and paints no wage pays 0, leaves those 10 unpaid, and leaves 97 in the yard.
- The gated shore plus one wage north of the gate keeps that wet haul, dry haul, cart, shipment, earned coins, and hires, and pays 10, leaving 0 of those who passed unpaid and 57 in the yard. The 19 hires still in the loft stay unpaid. Painting the wage when the wage beat opens pays the same number.
- A dry-pan plan plus a crib, a ship, a stall, a yard, a bunk, a loft, a gate, and a wage keeps a wet haul of 0 and pays 8 at 4 coins each. The yard holds 32, so 2 who passed stay unpaid and the yard is left at 0.
- The winning shore, the dry pans, the cart plans, the ship plans, the market plans, the bunk plans, the loft plans, and the gate plans still report the same earlier totals. A plan that paints the wage changes the yard remainder and nothing else in that list.
- A plan that pays hires and paints no relief posts 0, leaves those 10 paid hires unposted, and leaves the 19 hires still in the loft unpaid.
- The paid shore plus one relief north of the wage keeps that wet haul, dry haul, cart, shipment, earned coins, hires, and yard remainder, and posts 6. It leaves 4 paid hires unposted and 19 unpaid. Painting the relief when the relief beat opens posts the same number.
- A dry-pan plan plus a crib, a ship, a stall, a yard, a bunk, a loft, a gate, a wage, and a relief keeps a wet haul of 0 and posts 6 of the 8 who were paid. It leaves 2 paid hires unposted and 2 unpaid, because those 2 passed the gate and were not paid. The yard stays at 0.
- The winning shore, the dry pans, the cart plans, the ship plans, the market plans, the bunk plans, the loft plans, the gate plans, and the wage plans still report the same earlier totals. A plan that paints the relief changes none of the stored salt, the cart, the shipment, the earned coins, the hire count, or the coins left in the yard.
- A plan that posts hires and paints no watch stands 0, leaves those 6 posted hires on the relief, leaves the 4 paid hires who were not posted on the wage, and leaves the 19 hires still in the loft unpaid.
- The posted shore plus one watch north of the relief keeps that wet haul, dry haul, cart, shipment, earned coins, hires, yard remainder, and posted count, and stands 4. It leaves 2 posted hires unstood, 4 paid hires unposted, and 19 unpaid. Painting the watch when the watch beat opens stands the same number.
- A dry-pan plan plus a crib, a ship, a stall, a yard, a bunk, a loft, a gate, a wage, a relief, and a watch keeps a wet haul of 0 and stands 4 of the 6 who were posted. It leaves 2 posted hires unstood, 2 paid hires unposted, and 2 unpaid, because those 2 passed the gate and were not paid. The posted count stays 6 and the yard stays at 0.
- A plan that paints a watch and no relief stands 0. Nobody was posted, so the paid hires stay on the wage.
- The winning shore, the dry pans, the cart plans, the ship plans, the market plans, the bunk plans, the loft plans, the gate plans, the wage plans, and the relief plans still report the same earlier totals. A plan that paints the watch changes none of the stored salt, the cart, the shipment, the earned coins, the hire count, the coins left in the yard, or the posted count.
- A plan that stands hires and paints no lamp lights 0, leaves those 4 stood hires on the watch, leaves the 2 posted hires who were not stood on the relief, leaves the 4 paid hires who were not posted on the wage, and leaves the 19 hires still in the loft unpaid.
- The stood shore plus one lamp north of the watch keeps that wet haul, dry haul, cart, shipment, earned coins, hires, yard remainder, posted count, and stood count, and lights 3. It leaves 1 stood hire unlit, 2 posted hires unstood, 4 paid hires unposted, and 19 unpaid. Painting the lamp when the lamp beat opens lights the same number.
- A dry-pan plan plus a crib, a ship, a stall, a yard, a bunk, a loft, a gate, a wage, a relief, a watch, and a lamp keeps a wet haul of 0 and lights 3 of the 4 who were stood. It leaves 1 stood hire unlit, 2 posted hires unstood, 2 paid hires unposted, and 2 unpaid, because those 2 passed the gate and were not paid. The stood count stays 4, the posted count stays 6, and the yard stays at 0.
- A plan that paints a lamp and no watch lights 0. Nobody was stood, so the posted hires stay on the relief.
- The winning shore, the dry pans, the cart plans, the ship plans, the market plans, the bunk plans, the loft plans, the gate plans, the wage plans, the relief plans, and the watch plans still report the same earlier totals. A plan that paints the lamp changes none of the stored salt, the cart, the shipment, the earned coins, the hire count, the coins left in the yard, the posted count, or the stood count.
- Two runs of the same paint produce the same stored-salt number, the same cart total, the same shipped total, the same coin total, the same banked total, the same hire count, the same remainder, the same loft total, the same number through the gate, the same number paid, the same number posted, the same number stood, and the same number lit.
- Population stays at or under 40 in those runs.
- The rules API has no select-ant function.

Tick rules live at the top of `scripts/sim.gd`.

## Limits

One scenario, two rains, one cart beat, one ship beat, one market beat, one yard beat, one bunk beat, one loft beat, one gate beat, one wage beat, one relief beat, one watch beat, one lamp beat, no save, no audio. The dry season is 200 ticks (20 seconds) after the 600-tick wet season. The cart beat is 100 ticks (10 seconds) after the second rain. The ship beat is 100 ticks (10 seconds) after the cart. The market beat is 100 ticks (10 seconds) after the ship. The yard beat is 100 ticks (10 seconds) after the market. The bunk beat is 100 ticks (10 seconds) after the yard. The loft beat is 100 ticks (10 seconds) after the bunk. The gate beat is 100 ticks (10 seconds) after the loft. The wage beat is 100 ticks (10 seconds) after the gate. The relief beat is 100 ticks (10 seconds) after the wage. The watch beat is 100 ticks (10 seconds) after the relief. The lamp beat is 100 ticks (10 seconds) after the watch. The gate lets at most 10 hires through. The wage pays 4 coins a hire from the yard, and stops when the yard holds fewer than 4. The relief posts at most 6 hires who were already paid, and does not post anyone who was not paid. The watch stands at most 4 hires who were already posted, and does not stand anyone who was not posted. The lamp lights at most 3 hires who were already stood, and does not light anyone who was not stood. Ants are simulated labor with a fixed job, not units you pick up. A cell holds one mark. Nothing is rolled. The same paint on the same ticks always stores the same salt, carts the same amount, ships the same amount, sells for the same coins, banks the same amount, hires the same number, lofts the same number, lets the same number through the gate, pays the same number, posts the same number, stands the same number, and lights the same number, and the anthill stays at its starting cell.
