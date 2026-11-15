# Brine Mark

Indirect colony sim, Salt Coast slice. One coast, a wet season, a short dry season, a cart beat, a ship beat, a market beat, a yard beat, a bunk beat, a loft beat, one quota of covered salt. You paint the flats. Ants follow the mark under their feet. You do not select them.

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
| Space or Enter | Paint the cursor cell |
| R | Restart scenario |

Rake the shore beside the brine during the wet season. Ants pile loose salt there. Stack moves loose salt into stacks. Cover keeps stacked salt when the rain arrives; loose salt is destroyed. The first rain banks whatever was covered and pulls the brine back. Shore rakes go idle. Pan marks crystallize loose salt on the drying flats until the second rain, and the same stack and cover marks move that salt under cover. Trail is how ants cross from the anthill to those marks. The countdown above the flats names the season and refills when the dry season starts. After the second rain, a cart beat opens and the countdown refills. Paint a crib. Workers carry the banked salt — the first-rain haul and whatever the dry season still holds under cover — into that crib. A crib is shut until the cart beat, so it does not change the earlier haul. A coast with no crib leaves the bank where it is. After the cart beat, a ship beat opens and the countdown refills. Paint a ship. Workers load the salt sitting in the crib onto that ship. A ship is shut until the ship beat, so it does not change the wet haul, the dry haul, or the cart. A crib with no ship keeps the salt. After the ship beat, a market beat opens and the countdown refills. Paint a stall. Workers sell the salt already on the ship, one unit at a time, at one coin per unit. A stall is shut until the market beat, so it does not change the wet haul, the dry haul, the cart, or the shipment. A ship with no stall keeps the salt, and the coin total stays 0. After the market beat, a yard beat opens and the countdown refills. Paint a yard. Workers bank the coins already earned, one coin at a time. A yard is shut until the yard beat, so it does not change the wet haul, the dry haul, the cart, the shipment, or the earned coins. A purse with no yard stays at the stall, and the yard total stays 0. After the yard beat, a bunk beat opens and the countdown refills. Paint a bunk one cell north of the yard. Workers hire from the coins already banked, in a fixed order, at 100 coins for one hire. A bunk is shut until the bunk beat, so it does not change the wet haul, the dry haul, the cart, the shipment, or the earned coins. One bunk hires every full hundred and leaves the remainder in the yard. A purse with no bunk hires nobody, and the earned coin total is still reported. After the bunk beat, a loft beat opens and the countdown refills. Paint a loft one cell north of the bunk. Workers move the hires already recorded, one hire at a time, in a fixed order. A loft is shut until the loft beat, so it does not change the wet haul, the dry haul, the cart, the shipment, the earned coins, the hires, or the yard remainder. One loft takes the whole crew. A bunk with no loft keeps the hires, and the loft total stays 0. When the beats end, the summary names the first haul, the dry-season haul, the cart if any salt moved, the shipment if any salt left the crib, the coins if any salt sold, the yard if any coins were banked, the hires if any coins were spent, the loft if any hires moved, and why the quota failed if it did. Restart scenario clears the marks and runs Salt Coast again.

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
- Two runs of the same paint produce the same stored-salt number, the same cart total, the same shipped total, the same coin total, the same banked total, the same hire count, the same remainder, and the same loft total.
- Population stays at or under 40 in those runs.
- The rules API has no select-ant function.

Tick rules live at the top of `scripts/sim.gd`.

## Limits

One scenario, two rains, one cart beat, one ship beat, one market beat, one yard beat, one bunk beat, one loft beat, no save, no audio. The dry season is 200 ticks (20 seconds) after the 600-tick wet season. The cart beat is 100 ticks (10 seconds) after the second rain. The ship beat is 100 ticks (10 seconds) after the cart. The market beat is 100 ticks (10 seconds) after the ship. The yard beat is 100 ticks (10 seconds) after the market. The bunk beat is 100 ticks (10 seconds) after the yard. The loft beat is 100 ticks (10 seconds) after the bunk. Ants are simulated labor with a fixed job, not units you pick up. A cell holds one mark. Nothing is rolled. The same paint on the same ticks always stores the same salt, carts the same amount, ships the same amount, sells for the same coins, banks the same amount, hires the same number, and lofts the same number, and the anthill stays at its starting cell.
