extends RefCounted
class_name BrineSim

# Brine Mark slice — Salt Coast tick rules
#
# The player never selects an ant. They paint cells. Workers are simulated
# labor that follow the paint under their feet. This slice has one scenario:
# a wet season, a short dry season, a cart beat, a ship beat, a market beat, a yard beat, a bunk beat, a loft beat, a gate beat, a wage beat, a relief beat, a watch beat, a lamp beat, a bell beat, a horn beat, a flag beat, a banner beat, a pennant beat, a standard beat, a jack beat, an ensign beat, a burgee beat, a cornet beat, a guidon beat, then a fanion beat. The full game's population cap is
# 200; this slice hard-caps at POP_CAP (40) and will not grow past it.
#
# Map
# - Grid is GRID_W by GRID_H. Column COAST_X (0) is brine. It is not paintable
#   and not walkable. In the dry season the brine has pulled back: the column
#   stays unwalkable, and shore rakes no longer touch water.
# - The anthill is the fixed cell ANTHILL (14, 5). It is walkable, not
#   paintable, and the only place workers spawn.
# - Rows run from GRID_NORTH through GRID_H - 1. GRID_NORTH is eighteen rows north
#   of the old shore edge, so a loft can sit one cell north of a bunk on row 0,
#   a gate can sit one cell north of that loft, a wage can sit one cell
#   north of that gate, a relief can sit one cell north of that wage, a
#   watch can sit one cell north of that relief, a lamp can sit one cell
#   north of that watch, a bell can sit one cell north of that lamp, a
#   horn can sit one cell north of that bell, a flag can sit one cell
#   north of that horn, a banner can sit one cell north of that flag, a
#   pennant can sit one cell north of that banner, a standard can sit
#   one cell north of that pennant, a jack can sit one cell north of
#   that standard, an ensign can sit one cell north of that jack, a burgee can sit one cell north of that ensign, a cornet can sit one cell north of that burgee, a guidon can sit one cell north of that cornet, and a fanion can sit one cell north of that guidon.
# - Every other cell accepts one mark: empty, rake, stack, cover, trail, pan,
#   crib, ship, stall, yard, bunk, loft, gate, wage, relief, watch, lamp, bell, horn, flag, banner, pennant, standard, jack, ensign, burgee, cornet, or guidon, or fanion. A pennant is accepted only at (14, -11). That cell rejects a banner, a standard, a jack, an ensign, a burgee, a cornet, and a guidon. The banner cell (14, -10) still accepts a banner and rejects a pennant. A standard is accepted only at (14, -12). That cell rejects a pennant and a jack. A jack is accepted only at (14, -13). That cell rejects a standard, an ensign, a burgee, a cornet, and a guidon. An ensign is accepted only at (14, -14). That cell rejects a jack, a burgee, a cornet, and a guidon. A burgee is accepted only at (14, -15). That cell rejects an ensign, a cornet, and a guidon. A cornet is accepted only at (14, -16). That cell rejects a burgee and a guidon. A guidon is accepted only at (14, -17). That cell rejects a cornet and a fanion. A fanion is accepted only at (14, -18). That cell rejects a guidon. A crib is not walkable until the cart beat,
#   a ship is not walkable until the ship beat, a stall is not walkable until
#   the market beat, a yard is not walkable until the yard beat, a bunk is
#   not walkable until the bunk beat, a loft is not walkable until the loft
#   beat, a gate is not walkable until the gate beat, a wage is not
#   walkable until the wage beat, a relief is not walkable until the
#   relief beat, a watch is not walkable until the watch beat, a lamp is
#   not walkable until the lamp beat, a bell is not walkable until the
#   bell beat, a horn is not walkable until the horn beat, a flag is
#   not walkable until the flag beat, a banner is not walkable until
#   the banner beat, a pennant is not walkable until the pennant beat,
#   a standard is not walkable until the standard beat, a jack is not
#   walkable until the jack beat, an ensign is not walkable until the
#   ensign beat, a burgee is not walkable until the
#   burgee beat, a cornet is not walkable until the
#   cornet beat, a guidon is not walkable until the
#   guidon beat, and a fanion is not walkable until the
#   fanion beat,
#   so painting one cannot change an earlier haul.
#
# Determinism
# - No randomness and no seed. Given the same paint map at each tick and this
#   starting anthill, the stored-salt result is identical.
# - Workers act in ascending id order. Flow fields are breadth-first. When
#   several cells are equally close, the first one reached wins. Expansion
#   order is north, west, east, south. Goals are seeded row-major (y, then x).
# - Salt transfers pick the neighbor with the largest pile. Ties break toward
#   the smaller y, then the smaller x.
#
# Seasons
# - Wet season: tick indexes 0 .. RAIN_TICK-1. Gatherers on brine-adjacent
#   rake cells pile loose salt. Pan cells are only ground to cross. Crib
#   cells, ship cells, stall cells, yard cells, bunk cells, loft cells, gate cells, wage cells, relief cells, watch cells, lamp cells, bell cells, horn cells, flag cells, banner cells, pennant cells, standard cells, jack cells, ensign cells, burgee cells, cornet cells, guidon cells, and fanion cells are marks only.
# - At tick RAIN_TICK the first rain falls. Loose salt is destroyed. Stacked
#   salt on a cover cell is hauled into the wet-season ledger and cleared
#   from the flats. Stacked salt outside cover is destroyed. The scenario
#   continues, and the season becomes dry.
# - Dry season: the next DRY_TICK work rounds. Rake cells are not goals, and
#   a gatherer standing on one does nothing. A pan cell is a gather goal:
#   one unit of work crystallizes 1 loose salt, up to LOOSE_CAP, with no need
#   to touch the brine. Stack and cover work as in the wet season.
# - At tick RAIN_TICK + DRY_TICK the second rain falls. Loose salt is destroyed
#   again. Covered stacked salt stays on the map. The cart beat opens. The
#   scenario does not end, and the weather season stays dry.
# - Cart beat: the next CART_TICK work rounds. The bank is the ledger (what
#   the first rain hauled) plus covered salt still on the flats. Every worker
#   carries that bank. A crib cell is the only goal, and it is walkable only
#   now. One unit of work moves 1 salt from the bank onto the crib, taking the
#   ledger first and then covered salt in row-major order, up to CRIB_CAP.
#   Rakes and pans make no salt. With no crib, the bank stays where it is.
# - At tick RAIN_TICK + DRY_TICK + CART_TICK the cart beat ends and the ship
#   beat opens. The scenario does not end. Salt sitting in a crib stays there.
# - Ship beat: the next SHIP_TICK work rounds. Every worker loads the crib.
#   A ship cell is the only goal, and it is walkable only now. One unit of
#   work moves 1 salt from a crib onto the ship, taking crib salt in row-major
#   order, up to SHIP_CAP. Rakes and pans make no salt. With no ship, the crib
#   stays where it is. Loading the ship does not change the stored total.
# - At tick RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK the ship beat ends
#   and the market beat opens. The scenario does not end. Salt sitting on a
#   ship stays there.
# - Market beat: the next MARKET_TICK work rounds (100 ticks, 10 seconds).
#   Every worker sells. A stall cell is the only goal, and it is walkable
#   only now. One unit of work sells 1 salt already on a ship for 1 coin,
#   taking ship salt in row-major order, up to STALL_CAP. The coin is that
#   sold unit. Nothing is rolled. Rakes and pans make no salt. With no
#   stall, the salt stays on the ship and the coin total stays 0. Selling
#   does not change the stored, carted, or shipped totals.
# - At tick RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK the
#   market beat ends and the yard beat opens. The scenario does not end.
#   Coins earned at a stall stay there.
# - Yard beat: the next YARD_TICK work rounds (100 ticks, 10 seconds).
#   Every worker banks. A yard cell is the only goal, and it is walkable
#   only now. One unit of work banks 1 coin already earned at a stall,
#   taking stall coins in row-major order, up to YARD_CAP. One coin moves.
#   Nothing is rolled. Rakes and pans make no salt. With no yard, the coins
#   stay at the stall and the yard total stays 0. The earned coin total is
#   still reported. Banking does not change the stored, carted, shipped, or
#   earned-coin totals.
# - At tick RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK
#   the yard beat ends and the bunk beat opens. The scenario does not end.
#   Coins banked in a yard stay there.
# - Bunk beat: the next BUNK_TICK work rounds (100 ticks, 10 seconds).
#   Every worker hires. A bunk cell is the only goal, and it is walkable
#   only now. One unit of work hires 1 worker for HIRE_COST coins already
#   banked in a yard, taking yard coins in row-major order, up to BUNK_CAP
#   hires on that bunk. One hundred coins leave the yard. Nothing is rolled.
#   A hire is not made when fewer than HIRE_COST coins remain, so the
#   remainder stays in the yard. Rakes and pans make no salt. With no bunk,
#   the coins stay in the yard and the hire total stays 0. The earned coin
#   total is still reported. Hiring does not change the stored, carted,
#   shipped, or earned-coin totals.
# - At tick RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK
#   the bunk beat ends and the loft beat opens. The scenario does not end.
#   Hires recorded at a bunk stay there.
# - Loft beat: the next LOFT_TICK work rounds (100 ticks, 10 seconds).
#   Every worker lofts. A loft cell is the only goal, and it is walkable
#   only now. One unit of work moves 1 hire already recorded at a bunk onto
#   the loft, taking bunks in row-major order, up to LOFT_CAP. One hire moves.
#   Nothing is rolled. Rakes and pans make no salt. With no loft, the hires
#   stay at the bunk and the loft total stays 0. The hire total is still
#   reported. Lofting does not change the stored, carted, shipped, earned-coin,
#   or hire totals, and it does not spend the yard remainder.
# - At tick RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK
#   the loft beat ends and the gate beat opens. The scenario does not end.
#   Hires recorded in a loft stay there.
# - Gate beat: the next GATE_TICK work rounds (100 ticks, 10 seconds).
#   Every worker walks to a gate. A gate cell is the only goal, and it is
#   walkable only now. One unit of work lets 1 hire already recorded in a
#   loft through the gate, taking lofts in row-major order (the same order
#   they were filled: north to south, then west to east), up to GATE_CAP
#   hires in total. One hire moves. Nothing is rolled. The gate stops at
#   GATE_CAP even if ticks remain. Hires past the cap stay in the loft.
#   Rakes and pans make no salt. With no gate, the hires stay in the loft
#   and the gate total stays 0. The hire total is still reported. Letting
#   hires through does not change the stored, carted, shipped, earned-coin,
#   or hire totals, and it does not spend the yard remainder.
# - At tick RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK
#   the gate beat ends and the wage beat opens. The scenario does not end.
#   Hires who passed a gate stay there until they are paid.
# - Wage beat: the next WAGE_TICK work rounds (100 ticks, 10 seconds).
#   Every worker walks to a wage. A wage cell is the only goal, and it is
#   walkable only now. One unit of work pays 1 hire who already passed a
#   gate, taking gates in row-major order (the same order they passed:
#   north to south, then west to east). Pay is WAGE_COST coins already left
#   in a yard, taking yards in row-major order. One hire is paid. Nothing
#   is rolled. If the yard holds fewer than WAGE_COST coins, that hire stays
#   unpaid, the remaining coins stay, and later work does nothing. Hires
#   still in the loft are not paid. Rakes and pans make no salt. With no
#   wage, the hires who passed stay unpaid and the yard remainder stays.
#   The hire total is still reported. Paying does not change the stored,
#   carted, shipped, or earned-coin totals. It does spend the yard remainder.
# - At tick RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK
#   the wage beat ends and the relief beat opens. The scenario does not end.
#   Hires who were paid stay on the wage until they are posted.
# - Relief beat: the next RELIEF_TICK work rounds (100 ticks, 10 seconds).
#   Every worker walks to a relief. A relief cell is the only goal, and it
#   is walkable only now. One unit of work posts 1 hire who was already
#   paid, taking wages in row-major order (the same order they were paid:
#   north to south, then west to east), up to RELIEF_CAP hires in total.
#   One hire moves. Nothing is rolled. The relief stops at RELIEF_CAP even
#   if ticks remain and paid hires remain. Hires who were not paid are not
#   posted. That includes hires still in a loft and hires who passed a gate
#   but were not paid. Rakes and pans make no salt. With no relief, the
#   paid hires stay on the wage and the posted total stays 0. The hire
#   total is still reported. Posting does not change the stored, carted,
#   shipped, or earned-coin totals, the hire count, or the coins left in
#   the yard.
# - At tick RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK
#   the relief beat ends and the watch beat opens. The scenario does not end.
#   Hires who were posted stay on the relief until they are stood.
# - Watch beat: the next WATCH_TICK work rounds (100 ticks, 10 seconds).
#   Every worker walks to a watch. A watch cell is the only goal, and it
#   is walkable only now. One unit of work stands 1 hire who was already
#   posted, taking reliefs in row-major order (the same order they were
#   posted: north to south, then west to east), up to WATCH_CAP hires in
#   total. One hire moves. Nothing is rolled. The watch stops at WATCH_CAP
#   even if ticks remain and posted hires remain. Hires who were not posted
#   are not stood. That includes hires still in a loft, hires who passed a
#   gate but were not paid, and hires who were paid but were not posted.
#   Rakes and pans make no salt. With no watch, the posted hires stay on
#   the relief and the stood total stays 0. With nobody posted, the stood
#   total stays 0. The hire total and the posted total are still reported.
#   Standing does not change the stored, carted, shipped, or earned-coin
#   totals, the hire count, the coins left in the yard, or the posted count.
# - At tick RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK
#   the watch beat ends and the lamp beat opens. The scenario does not end.
#   Hires who were stood stay on the watch until they are lit.
# - Lamp beat: the next LAMP_TICK work rounds (100 ticks, 10 seconds).
#   Every worker walks to a lamp. A lamp cell is the only goal, and it
#   is walkable only now. One unit of work lights 1 hire who was already
#   stood, taking watches in row-major order (the same order they were
#   stood: north to south, then west to east), up to LAMP_CAP hires in
#   total. One hire moves. Nothing is rolled. The lamp stops at LAMP_CAP
#   even if ticks remain and stood hires remain. Hires who were not stood
#   are not lit. That includes hires still in a loft, hires who passed a
#   gate but were not paid, hires who were paid but were not posted, and
#   hires who were posted but were not stood. Rakes and pans make no salt.
#   With no lamp, the stood hires stay on the watch and the lit total stays
#   0. With nobody stood, the lit total stays 0. The hire total, the posted
#   total, and the stood total are still reported. Lighting does not change
#   the stored, carted, shipped, or earned-coin totals, the hire count, the
#   coins left in the yard, the posted count, or the stood count.
# - At tick RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK
#   the lamp beat ends and the bell beat opens. The scenario does not end.
#   Hires who were lit stay on the lamp until they are rung.
# - Bell beat: the next BELL_TICK work rounds (100 ticks, 10 seconds).
#   Every worker walks to a bell. A bell cell is the only goal, and it
#   is walkable only now. One unit of work rings 1 hire who was already
#   lit, taking lamps in row-major order (the same order they were
#   lit: north to south, then west to east), up to BELL_CAP hires in
#   total. One hire moves. Nothing is rolled. The bell stops at BELL_CAP
#   even if ticks remain and lit hires remain. Hires who were not lit
#   are not rung. That includes hires still in a loft, hires who passed a
#   gate but were not paid, hires who were paid but were not posted, hires
#   who were posted but were not stood, and hires who were stood but were
#   not lit. Rakes and pans make no salt. With no bell, the lit hires stay
#   on the lamp and the rung total stays 0. With nobody lit, the rung total
#   stays 0. The hire total, the posted total, the stood total, and the lit
#   total are still reported. Ringing does not change the stored, carted,
#   shipped, or earned-coin totals, the hire count, the coins left in the
#   yard, the posted count, the stood count, or the lit count.
# - At tick RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK
#   the bell beat ends and the horn beat opens. The scenario does not end.
#   Hires who were rung stay on the bell until they are sounded.
# - Horn beat: the next HORN_TICK work rounds (100 ticks, 10 seconds).
#   Every worker walks to a horn. A horn cell is the only goal, and it
#   is walkable only now. One unit of work sounds 1 hire who was already
#   rung, taking bells in row-major order (the same order they were
#   rung: north to south, then west to east), up to HORN_CAP hires in
#   total. One hire moves. Nothing is rolled. The horn stops at HORN_CAP
#   even if ticks remain and rung hires remain. Hires who were not rung
#   are not sounded. That includes hires still in a loft, hires who passed a
#   gate but were not paid, hires who were paid but were not posted, hires
#   who were posted but were not stood, hires who were stood but were
#   not lit, and hires who were lit but were not rung. Rakes and pans make
#   no salt. With no horn, the rung hires stay on the bell and the sounded
#   total stays 0. With nobody rung, the sounded total stays 0. The hire
#   total, the posted total, the stood total, the lit total, and the rung
#   total are still reported. Sounding does not change the stored, carted,
#   shipped, or earned-coin totals, the hire count, the coins left in the
#   yard, the posted count, the stood count, the lit count, or the rung count.
# - At tick RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK
#   the horn beat ends and the flag beat opens. The scenario does not end.
#   Hires who were sounded stay on the horn until they are raised.
# - Flag beat: the next FLAG_TICK work rounds (100 ticks, 10 seconds).
#   Every worker walks to a flag. A flag cell is the only goal, and it
#   is walkable only now. One unit of work raises 1 hire who was already
#   sounded, taking horns in row-major order (the same order they were
#   sounded: north to south, then west to east), up to FLAG_CAP hires in
#   total. One hire moves. Nothing is rolled. The flag stops at FLAG_CAP
#   even if ticks remain and sounded hires remain. Hires who were not
#   sounded are not raised. That includes hires still in a loft, hires who
#   passed a gate but were not paid, hires who were paid but were not posted,
#   hires who were posted but were not stood, hires who were stood but were
#   not lit, hires who were lit but were not rung, and hires who were rung
#   but were not sounded. Rakes and pans make no salt. With no flag, the
#   sounded hires stay on the horn and the raised total stays 0. With nobody
#   sounded, the raised total stays 0. The hire total, the posted total, the
#   stood total, the lit total, the rung total, and the sounded total are
#   still reported. Raising does not change the stored, carted, shipped, or
#   earned-coin totals, the hire count, the coins left in the yard, the posted
#   count, the stood count, the lit count, the rung count, or the sounded
#   count. The sounded total still counts a hire who was later raised.
# - At tick RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK
#   the flag beat ends and the banner beat opens. The scenario does not end.
#   Hires who were raised stay on the flag until they are hoisted.
# - Banner beat: the next BANNER_TICK work rounds (100 ticks, 10 seconds).
#   Every worker walks to a banner. A banner cell is the only goal, and it
#   is walkable only now. One unit of work hoists 1 hire who was already
#   raised, taking flags in row-major order (the same order they were
#   raised: north to south, then west to east), up to BANNER_CAP hires in
#   total. One hire moves. Nothing is rolled. The banner stops at BANNER_CAP
#   even if ticks remain and raised hires remain. Hires who were not
#   raised are not hoisted. That includes hires still in a loft, hires who
#   passed a gate but were not paid, hires who were paid but were not posted,
#   hires who were posted but were not stood, hires who were stood but were
#   not lit, hires who were lit but were not rung, hires who were rung but
#   were not sounded, and hires who were sounded but were not raised. Rakes
#   and pans make no salt. With no banner, the raised hires stay on the flag
#   and the hoisted total stays 0. With nobody raised, the hoisted total stays
#   0. The hire total, the posted total, the stood total, the lit total, the
#   rung total, the sounded total, and the raised total are still reported.
#   Hoisting spends no coins and does not change the stored, carted, shipped,
#   or earned-coin totals, the hire count, the coins left in the yard, the
#   posted count, the stood count, the lit count, the rung count, the sounded
#   count, or the raised count. The raised total still counts a hire who was
#   later hoisted.
# - At tick RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK
#   the banner beat ends and the pennant beat opens. The scenario does not end.
#   Hires who were hoisted stay on the banner until they are flown.
# - Pennant beat: the next PENNANT_TICK work rounds (100 ticks, 10 seconds).
#   Every worker walks to a pennant. A pennant cell is the only goal, and it
#   is walkable only now. One unit of work flies 1 hire who was already
#   hoisted, taking banners in row-major order (the same order they were
#   hoisted: north to south, then west to east), up to PENNANT_CAP hires in
#   total. One hire moves. Nothing is rolled. The pennant stops at PENNANT_CAP
#   even if ticks remain and hoisted hires remain. Hires who were not
#   hoisted are not flown. That includes hires still in a loft, hires who
#   passed a gate but were not paid, hires who were paid but were not posted,
#   hires who were posted but were not stood, hires who were stood but were
#   not lit, hires who were lit but were not rung, hires who were rung but
#   were not sounded, hires who were sounded but were not raised, and hires
#   who were raised but were not hoisted. Rakes and pans make no salt. With
#   no pennant, the hoisted hires stay on the banner and the flown total stays
#   0. With nobody hoisted, the flown total stays 0. The hire total, the posted
#   total, the stood total, the lit total, the rung total, the sounded total,
#   the raised total, and the hoisted total are still reported. Flying spends
#   no coins and does not change the stored, carted, shipped, or earned-coin
#   totals, the hire count, the coins left in the yard, the posted count, the
#   stood count, the lit count, the rung count, the sounded count, the raised
#   count, or the hoisted count. The hoisted total still counts a hire who was
#   later flown.
# - At tick RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK
#   the pennant beat ends and the standard beat opens. The scenario does not end.
#   Hires who were flown stay on the pennant until they are carried.
# - Standard beat: the next STANDARD_TICK work rounds (100 ticks, 10 seconds).
#   Every worker walks to a standard. A standard cell is the only goal, and it
#   is walkable only now. One unit of work carries 1 hire who was already
#   flown, taking pennants in row-major order (the same order they were
#   flown: north to south, then west to east), up to STANDARD_CAP hires in
#   total. One hire moves. Nothing is rolled. The standard stops at STANDARD_CAP
#   even if ticks remain and flown hires remain. Hires who were not
#   flown are not carried. That includes hires still in a loft, hires who
#   passed a gate but were not paid, hires who were paid but were not posted,
#   hires who were posted but were not stood, hires who were stood but were
#   not lit, hires who were lit but were not rung, hires who were rung but
#   were not sounded, hires who were sounded but were not raised, hires
#   who were raised but were not hoisted, and hires who were hoisted but
#   were not flown. Rakes and pans make no salt. With no standard, the flown
#   hires stay on the pennant and the carried total stays 0. With nobody
#   flown, the carried total stays 0. The hire total, the posted total, the
#   stood total, the lit total, the rung total, the sounded total, the raised
#   total, the hoisted total, and the flown total are still reported. Carrying
#   spends no coins and does not change the stored, carted, shipped, or
#   earned-coin totals, the hire count, the coins left in the yard, the posted
#   count, the stood count, the lit count, the rung count, the sounded count,
#   the raised count, the hoisted count, or the flown count. The flown total
#   still counts a hire who was later carried.
# - At tick RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK
#   the standard beat ends and the jack beat opens. The scenario does not end.
#   Hires who were carried stay on the standard until they are shown.
# - Jack beat: the next JACK_TICK work rounds (100 ticks, 10 seconds).
#   Every worker walks to a jack. A jack cell is the only goal, and it
#   is walkable only now. One unit of work shows 1 hire who was already
#   carried, taking standards in row-major order (the same order they were
#   carried: north to south, then west to east), up to JACK_CAP hires in
#   total. One hire moves. Nothing is rolled. The jack stops at JACK_CAP
#   even if ticks remain and carried hires remain. Hires who were not
#   carried are not shown. That includes hires still in a loft, hires who
#   passed a gate but were not paid, hires who were paid but were not posted,
#   hires who were posted but were not stood, hires who were stood but were
#   not lit, hires who were lit but were not rung, hires who were rung but
#   were not sounded, hires who were sounded but were not raised, hires
#   who were raised but were not hoisted, hires who were hoisted but were
#   not flown, and hires who were flown but were not carried. Rakes and pans
#   make no salt. With no jack, the carried hires stay on the standard and
#   the shown total stays 0. With nobody carried, the shown total stays 0.
#   The hire total, the posted total, the stood total, the lit total, the
#   rung total, the sounded total, the raised total, the hoisted total, the
#   flown total, and the carried total are still reported. Showing spends no
#   coins and does not change the stored, carted, shipped, or earned-coin
#   totals, the hire count, the coins left in the yard, the posted count, the
#   stood count, the lit count, the rung count, the sounded count, the raised
#   count, the hoisted count, the flown count, or the carried count. The
#   carried total still counts a hire who was later shown.
# - At tick RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK
#   the jack beat ends and the ensign beat opens. The scenario does not end.
#   Hires who were shown stay on the jack until they are broken.
# - Ensign beat: the next ENSIGN_TICK work rounds (100 ticks, 10 seconds).
#   Every worker walks to an ensign. An ensign cell is the only goal, and it
#   is walkable only now. One unit of work breaks 1 hire who was already
#   shown, taking jacks in row-major order (the same order they were
#   shown: north to south, then west to east), up to ENSIGN_CAP hires in
#   total. One hire moves. Nothing is rolled. The ensign stops at ENSIGN_CAP
#   even if ticks remain and shown hires remain. Hires who were not
#   shown are not broken. That includes hires still in a loft, hires who
#   passed a gate but were not paid, hires who were paid but were not posted,
#   hires who were posted but were not stood, hires who were stood but were
#   not lit, hires who were lit but were not rung, hires who were rung but
#   were not sounded, hires who were sounded but were not raised, hires
#   who were raised but were not hoisted, hires who were hoisted but were
#   not flown, hires who were flown but were not carried, and hires who
#   were carried but were not shown. Rakes and pans make no salt. With no
#   ensign, the shown hires stay on the jack and the broken total stays 0.
#   With nobody shown, the broken total stays 0. The hire total, the posted
#   total, the stood total, the lit total, the rung total, the sounded total,
#   the raised total, the hoisted total, the flown total, the carried total,
#   and the shown total are still reported. Breaking spends no coins and does
#   not change the stored, carted, shipped, or earned-coin totals, the hire
#   count, the coins left in the yard, the posted count, the stood count, the
#   lit count, the rung count, the sounded count, the raised count, the
#   hoisted count, the flown count, the carried count, or the shown count.
#   The shown total still counts a hire who was later broken.
# - At tick RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK + ENSIGN_TICK
#   the ensign beat ends and the burgee beat opens. The scenario does not end.
#   Hires who were broken stay on the ensign until they are struck.
# - Burgee beat: the next BURGEE_TICK work rounds (100 ticks, 10 seconds).
#   Every worker walks to a burgee. A burgee cell is the only goal, and it
#   is walkable only now. One unit of work strikes 1 hire who was already
#   broken, taking ensigns in row-major order (the same order they were
#   broken: north to south, then west to east), up to BURGEE_CAP hires in
#   total. One hire moves. Nothing is rolled. The burgee stops at BURGEE_CAP
#   even if ticks remain and broken hires remain. Hires who were not
#   broken are not struck. That includes hires still in a loft, hires who
#   passed a gate but were not paid, hires who were paid but were not posted,
#   hires who were posted but were not stood, hires who were stood but were
#   not lit, hires who were lit but were not rung, hires who were rung but
#   were not sounded, hires who were sounded but were not raised, hires
#   who were raised but were not hoisted, hires who were hoisted but were
#   not flown, hires who were flown but were not carried, hires who were
#   carried but were not shown, and hires who were shown but were not broken.
#   Rakes and pans make no salt. With no burgee, the broken hires stay on the
#   ensign and the struck total stays 0. With nobody broken, the struck total
#   stays 0. The hire total, the posted total, the stood total, the lit total,
#   the rung total, the sounded total, the raised total, the hoisted total,
#   the flown total, the carried total, the shown total, and the broken total
#   are still reported. Striking spends no coins and does not change the
#   stored, carted, shipped, or earned-coin totals, the hire count, the coins
#   left in the yard, the posted count, the stood count, the lit count, the
#   rung count, the sounded count, the raised count, the hoisted count, the
#   flown count, the carried count, the shown count, or the broken count.
#   The broken total still counts a hire who was later struck.
# - At tick RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK + ENSIGN_TICK + BURGEE_TICK
#   the burgee beat ends and the cornet beat opens. The scenario does not end.
#   Hires who were struck stay on the burgee until they are dipped.
# - Cornet beat: the next CORNET_TICK work rounds (100 ticks, 10 seconds).
#   Every worker walks to a cornet. A cornet cell is the only goal, and it
#   is walkable only now. One unit of work dips 1 hire who was already
#   struck, taking burgees in row-major order (the same order they were
#   struck: north to south, then west to east), up to CORNET_CAP hires in
#   total. One hire moves. Nothing is rolled. The cornet stops at CORNET_CAP
#   even if ticks remain and struck hires remain. Hires who were not
#   struck are not dipped. That includes hires still in a loft, hires who
#   passed a gate but were not paid, hires who were paid but were not posted,
#   hires who were posted but were not stood, hires who were stood but were
#   not lit, hires who were lit but were not rung, hires who were rung but
#   were not sounded, hires who were sounded but were not raised, hires
#   who were raised but were not hoisted, hires who were hoisted but were
#   not flown, hires who were flown but were not carried, hires who were
#   carried but were not shown, hires who were shown but were not broken,
#   and hires who were broken but were not struck.
#   Rakes and pans make no salt. With no cornet, the struck hires stay on the
#   burgee and the dipped total stays 0. With nobody struck, the dipped total
#   stays 0. The hire total, the posted total, the stood total, the lit total,
#   the rung total, the sounded total, the raised total, the hoisted total,
#   the flown total, the carried total, the shown total, the broken total,
#   and the struck total are still reported. Dipping spends no coins and does
#   not change the stored, carted, shipped, or earned-coin totals, the hire
#   count, the coins left in the yard, or any earlier count. The struck total
#   still counts a hire who was later dipped.
# - At tick RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK + ENSIGN_TICK + BURGEE_TICK + CORNET_TICK
#   the cornet beat ends and the guidon beat opens. The scenario does not end.
#   Hires who were dipped stay on the cornet until they are saluted.
# - Guidon beat: the next GUIDON_TICK work rounds (100 ticks, 10 seconds).
#   Every worker walks to a guidon. A guidon cell is the only goal, and it
#   is walkable only now. One unit of work salutes 1 hire who was already
#   dipped, taking cornets in row-major order (the same order they were
#   dipped: north to south, then west to east), up to GUIDON_CAP hires in
#   total. One hire moves. Nothing is rolled. The guidon stops at GUIDON_CAP
#   even if ticks remain and dipped hires remain. Hires who were not
#   dipped are not saluted. That includes hires still in a loft, hires who
#   passed a gate but were not paid, hires who were paid but were not posted,
#   hires who were posted but were not stood, hires who were stood but were
#   not lit, hires who were lit but were not rung, hires who were rung but
#   were not sounded, hires who were sounded but were not raised, hires
#   who were raised but were not hoisted, hires who were hoisted but were
#   not flown, hires who were flown but were not carried, hires who were
#   carried but were not shown, hires who were shown but were not broken,
#   hires who were broken but were not struck, and hires who were struck
#   but were not dipped.
#   Rakes and pans make no salt. With no guidon, the dipped hires stay on the
#   cornet and the saluted total stays 0. With nobody dipped, the saluted
#   total stays 0 and the struck hire stays on the burgee. The hire total,
#   the posted total, the stood total, the lit total, the rung total, the
#   sounded total, the raised total, the hoisted total, the flown total, the
#   carried total, the shown total, the broken total, the struck total, and
#   the dipped total are still reported. Saluting spends no coins and does
#   not change the stored, carted, shipped, or earned-coin totals, the hire
#   count, the coins left in the yard, or any earlier count. The dipped total
#   still counts a hire who was later saluted.
# - At tick RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK + ENSIGN_TICK + BURGEE_TICK + CORNET_TICK + GUIDON_TICK
#   the guidon beat ends and the fanion beat opens. The scenario does not end.
#   Hires who were saluted stay on the guidon until they are presented.
# - Fanion beat: the next FANION_TICK work rounds (100 ticks, 10 seconds).
#   Every worker walks to a fanion. A fanion cell is the only goal, and it
#   is walkable only now. One unit of work presents 1 hire who was already
#   saluted, taking guidons in row-major order (the same order they were
#   saluted: north to south, then west to east), up to FANION_CAP hires in
#   total. One hire moves. Nothing is rolled. The fanion stops at FANION_CAP
#   even if ticks remain and saluted hires remain. Hires who were not
#   saluted are not presented. That includes hires still in a loft, hires who
#   passed a gate but were not paid, hires who were paid but were not posted,
#   hires who were posted but were not stood, hires who were stood but were
#   not lit, hires who were lit but were not rung, hires who were rung but
#   were not sounded, hires who were sounded but were not raised, hires
#   who were raised but were not hoisted, hires who were hoisted but were
#   not flown, hires who were flown but were not carried, hires who were
#   carried but were not shown, hires who were shown but were not broken,
#   hires who were broken but were not struck, hires who were struck
#   but were not dipped, and hires who were dipped but were not saluted.
#   Rakes and pans make no salt. With no fanion, the saluted hires stay on the
#   guidon and the presented total stays 0. With nobody saluted, the presented
#   total stays 0 and the dipped hire stays on the cornet. The hire total,
#   the posted total, the stood total, the lit total, the rung total, the
#   sounded total, the raised total, the hoisted total, the flown total, the
#   carried total, the shown total, the broken total, the struck total, the
#   dipped total, and the saluted total are still reported. Presenting spends
#   no coins and does not change the stored, carted, shipped, or earned-coin
#   totals, the hire count, the coins left in the yard, or any earlier count,
#   including the saluted count. The saluted total still counts a hire who was
#   later presented.
# - At tick RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK + ENSIGN_TICK + BURGEE_TICK + CORNET_TICK + GUIDON_TICK + FANION_TICK
#   the fanion beat ends and the scenario ends. Stored salt is the ledger still
#   unmoved, plus covered salt still on the map, plus salt still in cribs,
#   plus salt still on ships, plus coins still at stalls, plus coins still
#   in yards, plus coins spent on hires, plus coins spent on wages. Hires
#   moved into a loft, hires let through a gate, hires paid a wage, hires
#   posted to a relief, hires stood on a watch, hires lit by a lamp, hires
#   rung on a bell, hires sounded on a horn, hires raised on a flag, hires
#   hoisted on a banner, hires flown on a pennant, hires carried on a
#   standard, hires shown on a jack, hires broken on an ensign, hires
#   struck on a burgee, hires dipped on a cornet, hires saluted on a
#   guidon, and hires presented on a fanion, still count.
#
# Tick (work rounds, then a rain at each season boundary)
# 1. If the scenario has already ended, the tick does nothing.
# 2. Spawn. On tick indexes 1, 2, ... while the index is a positive multiple
#    of SPAWN_EVERY and the population is below POP_CAP, one worker is added
#    at the anthill. Its job is id % 3 and never changes:
#      0 gather — rake in the wet season, pan in the dry season
#      1 stack  — move loose salt into stacks
#      2 cover  — move stacked salt into cover
#    During the cart beat every job carries the bank. During the ship beat
#    every job loads a ship. During the market beat every job sells. During
#    the yard beat every job banks the purse. During the bunk beat every job
#    hires from the banked coins. During the loft beat every job moves those
#    hires. During the gate beat every job lets those hires through. During
#    the wage beat every job pays those hires. During the relief beat every
#    job posts those hires. During the watch beat every job stands those
#    hires. During the lamp beat every job lights those hires. During the
#    bell beat every job rings those hires. During the horn beat every job
#    sounds those hires. During the flag beat every job raises those hires.
#    During the banner beat every job hoists those hires. During the pennant
#    beat every job flies those hires. During the standard beat every job
#    carries those hires. During the jack beat every job shows those hires.
#    During the ensign beat every job breaks those hires.
#    During the burgee beat every job strikes those hires.
#    During the cornet beat every job dips those hires.
#    During the guidon beat every job salutes those hires.
#    During the fanion beat every job presents those hires.
#    The job id does not change.
#    The new worker acts on the tick it spawns. The starting population is
#    INITIAL_POP, created before tick 0. Spawn refuses to exceed POP_CAP.
# 3. Goals, from the salt map and the beat as the tick begins (later
#    workers see salt changes, but not new paths, until the next tick):
#      Gather, wet: rake cell in the shore column (x == 1) whose loose pile
#              is below LOOSE_CAP. Inland rake never makes salt.
#      Gather, dry: pan cell whose loose pile is below LOOSE_CAP.
#      Stack:  stack cell below STACK_CAP with loose salt on a 4-neighbor.
#      Cover:  cover cell below COVER_CAP with stacked salt on an adjacent
#              stack cell.
#      Cart:   crib cell below CRIB_CAP while any banked salt remains.
#              All three jobs share that flow.
#      Ship:   ship cell below SHIP_CAP while any salt remains in a crib.
#              All three jobs share that flow.
#      Market: stall cell below STALL_CAP while any salt remains on a ship.
#              All three jobs share that flow. One sale is one coin.
#      Yard:   yard cell below YARD_CAP while any earned coin remains at a
#              stall. All three jobs share that flow. One bank is one coin.
#      Bunk:   bunk cell below BUNK_CAP while at least HIRE_COST coins remain
#              in a yard. All three jobs share that flow. One hire spends
#              HIRE_COST coins.
#      Loft:   loft cell below LOFT_CAP while any hire remains at a bunk.
#              All three jobs share that flow. One loft moves one hire.
#      Gate:   gate cell while fewer than GATE_CAP hires have passed and any
#              hire remains in a loft. All three jobs share that flow. One
#              pass lets one hire through. The total stops at GATE_CAP.
#      Wage:   wage cell below WAGE_CAP while any hire who passed a gate is
#              still unpaid and at least WAGE_COST coins remain in a yard.
#              All three jobs share that flow. One payment pays one hire.
#              A short yard stops the beat from paying anyone else.
#      Relief: relief cell while fewer than RELIEF_CAP hires have been posted
#              and any paid hire is still on a wage. All three jobs share
#              that flow. One post moves one paid hire. The total stops at
#              RELIEF_CAP. Unpaid hires are not goals and are not posted.
#      Watch:  watch cell while fewer than WATCH_CAP hires have been stood
#              and any posted hire is still on a relief. All three jobs share
#              that flow. One stand moves one posted hire. The total stops at
#              WATCH_CAP. Hires who were not posted are not goals and are not
#              stood.
#      Lamp:   lamp cell while fewer than LAMP_CAP hires have been lit and
#              any stood hire is still on a watch. All three jobs share that
#              flow. One light moves one stood hire. The total stops at
#              LAMP_CAP. Hires who were not stood are not goals and are not
#              lit.
#      Bell:   bell cell while fewer than BELL_CAP hires have been rung and
#              any lit hire is still on a lamp. All three jobs share that
#              flow. One ring moves one lit hire. The total stops at
#              BELL_CAP. Hires who were not lit are not goals and are not
#              rung.
#      Horn:   horn cell while fewer than HORN_CAP hires have been sounded and
#              any rung hire is still on a bell. All three jobs share that
#              flow. One sound moves one rung hire. The total stops at
#              HORN_CAP. Hires who were not rung are not goals and are not
#              sounded.
#      Flag:   flag cell while fewer than FLAG_CAP hires have been raised and
#              any sounded hire is still on a horn. All three jobs share that
#              flow. One raise moves one sounded hire. The total stops at
#              FLAG_CAP. Hires who were not sounded are not goals and are not
#              raised.
#      Banner: banner cell while fewer than BANNER_CAP hires have been hoisted
#              and any raised hire is still on a flag. All three jobs share
#              that flow. One hoist moves one raised hire. The total stops at
#              BANNER_CAP. Hires who were not raised are not goals and are not
#              hoisted.
#      Pennant: pennant cell while fewer than PENNANT_CAP hires have been flown
#              and any hoisted hire is still on a banner. All three jobs share
#              that flow. One flight moves one hoisted hire. The total stops at
#              PENNANT_CAP. Hires who were not hoisted are not goals and are not
#              flown.
#      Standard: standard cell while fewer than STANDARD_CAP hires have been
#              carried and any flown hire is still on a pennant. All three jobs
#              share that flow. One carry moves one flown hire. The total stops
#              at STANDARD_CAP. Hires who were not flown are not goals and are
#              not carried.
#      Jack:   jack cell while fewer than JACK_CAP hires have been shown and
#              any carried hire is still on a standard. All three jobs share
#              that flow. One show moves one carried hire. The total stops at
#              JACK_CAP. Hires who were not carried are not goals and are not
#              shown.
#      Ensign: ensign cell while fewer than ENSIGN_CAP hires have been broken
#              and any shown hire is still on a jack. All three jobs share that
#              flow. One break moves one shown hire. The total stops at
#              ENSIGN_CAP. Hires who were not shown are not goals and are not
#              broken.
#      Burgee: burgee cell while fewer than BURGEE_CAP hires have been struck
#              and any broken hire is still on an ensign. All three jobs share
#              that flow. One strike moves one broken hire. The total stops at
#              BURGEE_CAP. Hires who were not broken are not goals and are not
#              struck.
#      Cornet: cornet cell while fewer than CORNET_CAP hires have been dipped
#              and any struck hire is still on a burgee. All three jobs share
#              that flow. One dip moves one struck hire. The total stops at
#              CORNET_CAP. Hires who were not struck are not goals and are not
#              dipped.
#      Guidon: guidon cell while fewer than GUIDON_CAP hires have been saluted
#              and any dipped hire is still on a cornet. All three jobs share
#              that flow. One salute moves one dipped hire. The total stops at
#              GUIDON_CAP. Hires who were not dipped are not goals and are not
#              saluted.
#      Fanion: fanion cell while fewer than FANION_CAP hires have been presented
#              and any saluted hire is still on a guidon. All three jobs share
#              that flow. One present moves one saluted hire. The total stops at
#              FANION_CAP. Hires who were not saluted are not goals and are not
#              presented.
#    Trail cells are only ground to cross. They are not goals. Pan cells are
#    not goals during the wet season. Rake cells are not goals during the
#    dry season or any later beat. Crib cells are not goals before the cart
#    beat. During the ship beat, the market beat, the yard beat, the bunk
#    beat, the loft beat, the gate beat, the wage beat, the relief beat, and
#    the watch beat they are only ground. Ship cells are not goals before the
#    ship beat. During the market beat, the yard beat, the bunk beat, the loft
#    beat, the gate beat, the wage beat, the relief beat, and the watch beat
#    they are only ground, so workers can walk from the ship to the stall.
#    Stall cells are not goals before the market beat. During the yard beat,
#    the bunk beat, the loft beat, the gate beat, the wage beat, the relief
#    beat, and the watch beat they are only ground, so workers can walk from
#    the stall to the yard. Yard cells are not goals before the yard beat.
#    During the bunk beat, the loft beat, the gate beat, the wage beat, the
#    relief beat, and the watch beat they are only ground, so workers can walk
#    from the yard to the bunk. Bunk cells are not goals before the bunk beat.
#    During the loft beat, the gate beat, the wage beat, the relief beat, and
#    the watch beat they are only ground, so workers can walk from the bunk to
#    the loft. Loft cells are not goals before the loft beat. During the gate
#    beat, the wage beat, the relief beat, and the watch beat they are only
#    ground, so workers can walk from the loft to the gate. Gate cells are not
#    goals before the gate beat. During the wage beat, the relief beat, and
#    the watch beat they are only ground, so workers can walk from the gate to
#    the wage. Wage cells are not goals before the wage beat. During the relief
#    beat and the watch beat they are only ground, so workers can walk from the
#    wage to the relief. Relief cells are not goals before the relief beat.
#    During the watch beat they are only ground, so workers can walk from the
#    relief to the watch. Watch cells are not goals before the watch beat.
#    During the lamp beat they are only ground, so workers can walk from the
#    watch to the lamp. Lamp cells are not goals before the lamp beat.
#    During the bell beat they are only ground, so workers can walk from the
#    lamp to the bell. Bell cells are not goals before the bell beat.
#    During the horn beat they are only ground, so workers can walk from the
#    bell to the horn. Horn cells are not goals before the horn beat.
#    During the flag beat they are only ground, so workers can walk from the
#    horn to the flag. Flag cells are not goals before the flag beat.
#    During the banner beat they are only ground, so workers can walk from the
#    flag to the banner. Banner cells are not goals before the banner beat.
#    During the pennant beat they are only ground, so workers can walk from the
#    banner to the pennant. Pennant cells are not goals before the pennant beat.
#    During the standard beat they are only ground, so workers can walk from the
#    pennant to the standard. Standard cells are not goals before the standard beat.
#    During the jack beat they are only ground, so workers can walk from the
#    standard to the jack. Jack cells are not goals before the jack beat.
#    During the ensign beat they are only ground, so workers can walk from the
#    jack to the ensign. Ensign cells are not goals before the ensign beat.
#    During the burgee beat they are only ground, so workers can walk from the
#    ensign to the burgee. Burgee cells are not goals before the burgee beat.
#    During the cornet beat they are only ground, so workers can walk from the
#    burgee to the cornet. Cornet cells are not goals before the cornet beat.
#    During the guidon beat they are only ground, so workers can walk from the
#    cornet to the guidon. Guidon cells are not goals before the guidon beat.
#    During the fanion beat they are only ground, so workers can walk from the
#    guidon to the fanion. Fanion cells are not goals before the fanion beat.
# 4. Each job builds a flow field: multi-source BFS from its goals through
#    walkable cells (any painted cell, plus the anthill). A goal's next step
#    is itself. Every other reached cell points one step toward the nearest
#    goal.
# 5. Each worker acts:
#      - Off the walkable network (the mark under them was erased): step to
#        the first walkable 4-neighbor in expansion order, else stay.
#      - On a flow cell whose next step is itself: do one unit of work.
#      - Otherwise: step to that next cell. Workers do not block each other.
#    Work, one unit, and only if the cell still qualifies:
#      Gather, wet: loose salt on this rake cell increases by 1, up to LOOSE_CAP.
#      Gather, dry: loose salt on this pan cell increases by 1, up to LOOSE_CAP.
#      Stack:  1 loose salt moves from the chosen neighbor onto this stack,
#              up to STACK_CAP.
#      Cover:  1 stacked salt moves from the chosen adjacent stack into this
#              cover cell, up to COVER_CAP.
#      Cart:   1 banked salt moves onto this crib. The ledger is taken first.
#              Covered salt is taken next, row-major (y, then x).
#      Ship:   1 crib salt moves onto this ship. Cribs are taken in row-major
#              order (y, then x).
#      Market: 1 ship salt is sold onto this stall for 1 coin. Ships are taken
#              in row-major order (y, then x).
#      Yard:   1 earned coin moves from a stall onto this yard. Stalls are
#              taken in row-major order (y, then x).
#      Bunk:   HIRE_COST earned coins leave a yard and this bunk gains 1 hire.
#              Yards are taken in row-major order (y, then x). The remainder
#              under HIRE_COST stays in the yard.
#      Loft:   1 hire moves from a bunk onto this loft. Bunks are taken in
#              row-major order (y, then x).
#      Gate:   1 hire moves from a loft through this gate. Lofts are taken in
#              row-major order (y, then x), the same order they were filled.
#              The gate lets at most GATE_CAP hires through, then stops.
#      Wage:   WAGE_COST coins leave a yard and 1 hire moves from a gate onto
#              this wage. Gates are taken in row-major order (y, then x), the
#              same order the hires passed. The remainder under WAGE_COST stays
#              in the yard, and that hire stays unpaid. Hires still in a loft
#              are not paid.
#      Relief: 1 hire moves from a wage onto this relief. Wages are taken in
#              row-major order (y, then x), the same order the hires were
#              paid. The relief posts at most RELIEF_CAP hires, then stops.
#              Hires still on a gate and hires still in a loft are not posted.
#      Watch:  1 hire moves from a relief onto this watch. Reliefs are taken
#              in row-major order (y, then x), the same order the hires were
#              posted. The watch stands at most WATCH_CAP hires, then stops.
#              Hires still on a wage, hires still on a gate, and hires still
#              in a loft are not stood.
#      Lamp:   1 hire moves from a watch onto this lamp. Watches are taken
#              in row-major order (y, then x), the same order the hires were
#              stood. The lamp lights at most LAMP_CAP hires, then stops.
#              Hires still on a relief, hires still on a wage, hires still
#              on a gate, and hires still in a loft are not lit.
#      Bell:   1 hire moves from a lamp onto this bell. Lamps are taken
#              in row-major order (y, then x), the same order the hires were
#              lit. The bell rings at most BELL_CAP hires, then stops.
#              Hires still on a watch, hires still on a relief, hires still
#              on a wage, hires still on a gate, and hires still in a loft
#              are not rung.
#      Horn:   1 hire moves from a bell onto this horn. Bells are taken
#              in row-major order (y, then x), the same order the hires were
#              rung. The horn sounds at most HORN_CAP hires, then stops.
#              Hires still on a lamp, hires still on a watch, hires still
#              on a relief, hires still on a wage, hires still on a gate, and
#              hires still in a loft are not sounded.
#      Flag:   1 hire moves from a horn onto this flag. Horns are taken
#              in row-major order (y, then x), the same order the hires were
#              sounded. The flag raises at most FLAG_CAP hires, then stops.
#              Hires still on a bell, hires still on a lamp, hires still on a
#              watch, hires still on a relief, hires still on a wage, hires
#              still on a gate, and hires still in a loft are not raised.
#      Banner: 1 hire moves from a flag onto this banner. Flags are taken
#              in row-major order (y, then x), the same order the hires were
#              raised. The banner hoists at most BANNER_CAP hires, then stops.
#              Hires still on a horn, hires still on a bell, hires still on a
#              lamp, hires still on a watch, hires still on a relief, hires
#              still on a wage, hires still on a gate, and hires still in a
#              loft are not hoisted.
#      Pennant: 1 hire moves from a banner onto this pennant. Banners are taken
#              in row-major order (y, then x), the same order the hires were
#              hoisted. The pennant flies at most PENNANT_CAP hires, then stops.
#              Hires still on a flag, hires still on a horn, hires still on a
#              bell, hires still on a lamp, hires still on a watch, hires still
#              on a relief, hires still on a wage, hires still on a gate, and
#              hires still in a loft are not flown.
#      Standard: 1 hire moves from a pennant onto this standard. Pennants are
#              taken in row-major order (y, then x), the same order the hires
#              were flown. The standard carries at most STANDARD_CAP hires, then
#              stops. Hires still on a banner, hires still on a flag, hires
#              still on a horn, hires still on a bell, hires still on a lamp,
#              hires still on a watch, hires still on a relief, hires still on
#              a wage, hires still on a gate, and hires still in a loft are not
#              carried.
#      Jack:   1 hire moves from a standard onto this jack. Standards are
#              taken in row-major order (y, then x), the same order the hires
#              were carried. The jack shows at most JACK_CAP hires, then
#              stops. Hires still on a pennant, hires still on a banner, hires
#              still on a flag, hires still on a horn, hires still on a bell,
#              hires still on a lamp, hires still on a watch, hires still on a
#              relief, hires still on a wage, hires still on a gate, and hires
#              still in a loft are not shown.
#      Ensign: 1 hire moves from a jack onto this ensign. Jacks are taken in
#              row-major order (y, then x), the same order the hires were
#              shown. The ensign breaks at most ENSIGN_CAP hires, then stops.
#              Hires still on a standard, hires still on a pennant, hires still
#              on a banner, hires still on a flag, hires still on a horn, hires
#              still on a bell, hires still on a lamp, hires still on a watch,
#              hires still on a relief, hires still on a wage, hires still on a
#              gate, and hires still in a loft are not broken.
#      Burgee: 1 hire moves from an ensign onto this burgee. Ensigns are taken
#              in row-major order (y, then x), the same order the hires were
#              broken. The burgee strikes at most BURGEE_CAP hires, then stops.
#              Hires still on a jack, hires still on a standard, hires still on
#              a pennant, hires still on a banner, hires still on a flag, hires
#              still on a horn, hires still on a bell, hires still on a lamp,
#              hires still on a watch, hires still on a relief, hires still on
#              a wage, hires still on a gate, and hires still in a loft are not
#              struck.
#      Cornet: 1 hire moves from a burgee onto this cornet. Burgees are taken
#              in row-major order (y, then x), the same order the hires were
#              struck. The cornet dips at most CORNET_CAP hires, then stops.
#              Hires still on an ensign, hires still on a jack, hires still on
#              a standard, hires still on a pennant, hires still on a banner,
#              hires still on a flag, hires still on a horn, hires still on a
#              bell, hires still on a lamp, hires still on a watch, hires still
#              on a relief, hires still on a wage, hires still on a gate, and
#              hires still in a loft are not dipped.
#      Guidon: 1 hire moves from a cornet onto this guidon. Cornets are taken
#              in row-major order (y, then x), the same order the hires were
#              dipped. The guidon salutes at most GUIDON_CAP hires, then stops.
#              Hires still on a burgee, hires still on an ensign, hires still
#              on a jack, hires still on a standard, hires still on a pennant,
#              hires still on a banner, hires still on a flag, hires still on
#              a horn, hires still on a bell, hires still on a lamp, hires
#              still on a watch, hires still on a relief, hires still on a
#              wage, hires still on a gate, and hires still in a loft are not
#              saluted.
#      Fanion: 1 hire moves from a guidon onto this fanion. Guidons are taken
#              in row-major order (y, then x), the same order the hires were
#              saluted. The fanion presents at most FANION_CAP hires, then stops.
#              Hires still on a cornet, hires still on a burgee, hires still on
#              an ensign, hires still on a jack, hires still on a standard,
#              hires still on a pennant, hires still on a banner, hires still
#              on a flag, hires still on a horn, hires still on a bell, hires
#              still on a lamp, hires still on a watch, hires still on a relief,
#              hires still on a wage, hires still on a gate, and hires still in
#              a loft are not presented.
# 6. If the population is above POP_CAP, the violation is counted. Spawning
#    is the only way workers are added, and it stops at the cap.
# 7. The tick index increases by 1. When it reaches RAIN_TICK, the first rain
#    falls immediately (the dry season's first work round is the next tick).
#    When it reaches RAIN_TICK + DRY_TICK, the second rain falls and the cart
#    beat's first work round is the next tick. When it reaches
#    RAIN_TICK + DRY_TICK + CART_TICK, the ship beat's first work round is the
#    next tick. When it reaches RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK,
#    the market beat's first work round is the next tick. When it reaches
#    RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK, the yard
#    beat's first work round is the next tick. When it reaches
#    RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK,
#    the bunk beat's first work round is the next tick. When it reaches
#    RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK,
#    the loft beat's first work round is the next tick. When it reaches
#    RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK,
#    the gate beat's first work round is the next tick. When it reaches
#    RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK,
#    the wage beat's first work round is the next tick. When it reaches
#    RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK,
#    the relief beat's first work round is the next tick. When it reaches
#    RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK,
#    the watch beat's first work round is the next tick. When it reaches
#    RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK,
#    the lamp beat's first work round is the next tick. When it reaches
#    RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK,
#    the bell beat's first work round is the next tick. When it reaches
#    RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK,
#    the horn beat's first work round is the next tick. When it reaches
#    RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK,
#    the flag beat's first work round is the next tick. When it reaches
#    RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK,
#    the banner beat's first work round is the next tick. When it reaches
#    RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK,
#    the pennant beat's first work round is the next tick. When it reaches
#    RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK,
#    the standard beat's first work round is the next tick. When it reaches
#    RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK,
#    the jack beat's first work round is the next tick. When it reaches
#    RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK,
#    the ensign beat's first work round is the next tick. When it reaches
#    RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK + ENSIGN_TICK,
#    the burgee beat's first work round is the next tick. When it reaches
#    RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK + ENSIGN_TICK + BURGEE_TICK,
#    the cornet beat's first work round is the next tick. When it reaches
#    RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK + ENSIGN_TICK + BURGEE_TICK + CORNET_TICK,
#    the guidon beat's first work round is the next tick. When it reaches
#    RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK + ENSIGN_TICK + BURGEE_TICK + CORNET_TICK + GUIDON_TICK,
#    the fanion beat's first work round is the next tick. When it reaches
#    RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK + ENSIGN_TICK + BURGEE_TICK + CORNET_TICK + GUIDON_TICK + FANION_TICK,
#    the fanion beat ends.
#
# Rain
# - Loose salt is destroyed on every cell. Loose salt never survives a rain.
# - First rain: stacked salt on a cover cell is hauled (added to the ledger)
#   and removed from the cell. That haul counts toward stored salt. The flats
#   start the dry season clear.
# - Second rain: stacked salt on a cover cell stays, folded into the covered
#   pile, and counts toward stored salt along with the ledger. The cart beat
#   then moves that bank; the rain itself does not. The ship beat then loads
#   a crib, the market beat then sells a ship, the yard beat then banks
#   the coins, the bunk beat then hires from that purse, the loft beat then
#   moves those hires, the gate beat then lets them through, the wage beat
#   then pays them, the relief beat then posts them, the watch beat then
#   stands them, the lamp beat then lights them, the bell beat then rings them, the horn beat then sounds them, the flag beat then raises them, the banner beat then hoists them, the pennant beat then flies them, the standard beat then carries them, the jack beat then shows them, the ensign beat then breaks them, the burgee beat then strikes them, the cornet beat then dips them, the guidon beat then salutes them, and the fanion beat then presents them; the rain does none of those.
# - Stacked or covered salt outside a cover cell is destroyed.
# - Destruction is applied row-major. The same paint map yields the same
#   stored-salt number.
#
# Summary
# - Stored salt >= QUOTA: the rains passed. The line names the first-rain
#   haul and what the dry season held. If the cart moved any salt, the line
#   also names how much reached a crib. If the ship beat loaded any of that
#   crib, the line names how much left it. If the market sold any of that
#   ship, the line names the coins. If the yard banked any of those coins,
#   the line names how much reached the yard. If the bunk hired from those
#   coins, the line names the hires and what stayed in the yard. If the loft
#   moved any of those hires, the line names how many reached it. If the gate
#   let any of those hires through, the line names how many passed and how
#   many stayed in the loft. If the wage paid any of those hires, the line
#   names how many were paid and how many who passed are still unpaid. If
#   the relief posted any of those paid hires, the line names how many were
#   posted and how many paid hires stayed on the wage. If the watch stood any
#   of those posted hires, the line names the watch, how many were stood, and
#   how many posted hires stayed on the relief. If the lamp lit any of those
#   stood hires, the line names the lamp, how many were lit, and how many
#   stood hires stayed on the watch. If the bell rang any of those lit
#   hires, the line names the bell, how many were rung, and how many lit
#   hires stayed on the lamp. If the horn sounded any of those rung
#   hires, the line names the horn, how many were sounded, and how many rung
#   hires stayed on the bell. If the flag raised any of those sounded
#   hires, the line names the flag, how many were raised, and how many
#   sounded hires stayed on the horn. If the banner hoisted any of those
#   raised hires, the line names the banner, how many were hoisted, and how
#   many raised hires stayed on the flag. If the pennant flew any of those
#   hoisted hires, the line names the pennant, how many were flown, and how
#   many hoisted hires stayed on the banner. If the standard carried any of
#   those flown hires, the line names the standard, how many were carried, and
#   how many flown hires stayed on the pennant. If the jack showed any of
#   those carried hires, the line names the jack, how many were shown, and
#   how many carried hires stayed on the standard. If the ensign broke any of
#   those shown hires, the line names the ensign, how many were broken, and
#   how many shown hires stayed on the jack. If the burgee struck any of
#   those broken hires, the line names the burgee, how many were struck, and
#   how many broken hires stayed on the ensign. If the cornet dipped any of
#   those struck hires, the line names the cornet, how many were dipped, and
#   how many struck hires stayed on the burgee. If the guidon saluted any of
#   those dipped hires, the line names the guidon, how many were saluted, and
#   how many dipped hires stayed on the cornet. If the fanion presented any of
#   those saluted hires, the line names the fanion, how many were presented, and
#   how many saluted hires stayed on the guidon. A plan
#   that paints no crib keeps the summary it had before the cart beat existed.
#   A plan that paints no ship keeps the summary it had before the ship beat
#   existed. A plan that paints no stall keeps the summary it had before the
#   market beat existed. A plan that paints no yard keeps the summary it had
#   before the yard beat existed. A plan that paints no bunk keeps the summary
#   it had before the bunk beat existed. A plan that paints no loft keeps the
#   summary it had before the loft beat existed. A plan that paints no gate
#   keeps the summary it had before the gate beat existed. A plan that paints
#   no wage keeps the summary it had before the wage beat existed. A plan
#   that paints no relief keeps the summary it had before the relief beat
#   existed. A plan that paints no watch keeps the summary it had before the
#   watch beat existed. A plan that paints no lamp keeps the summary it had
#   before the lamp beat existed. A plan that paints no bell keeps the summary
#   it had before the bell beat existed. A plan that paints no horn keeps the
#   summary it had before the horn beat existed. A plan that paints no flag
#   keeps the summary it had before the flag beat existed. A plan that paints
#   no banner keeps the summary it had before the banner beat existed. A plan
#   that paints no pennant keeps the summary it had before the pennant beat
#   existed. A plan that paints no standard keeps the summary it had before
#   the standard beat existed. A plan that paints no jack keeps the summary
#   it had before the jack beat existed. A plan that paints no ensign keeps
#   the summary it had before the ensign beat existed. A plan that paints no burgee keeps
#   the summary it had before the burgee beat existed. A plan that paints no cornet keeps
#   the summary it had before the cornet beat existed. A plan that paints no guidon keeps
#   the summary it had before the guidon beat existed. A plan that paints no fanion keeps
#   the summary it had before the fanion beat existed.
# - Stored salt == 0 and any salt was destroyed: the quota was missed because
#   uncovered salt was destroyed. An all-rake coast does this: workers pile
#   loose salt, nothing is stacked into cover, the first rain wrecks the
#   piles, and idle rakes add nothing once the brine pulls back.
# - Stored salt == 0 and nothing was destroyed: no salt was stored.
# - Stored salt is short of the quota but not zero: not enough covered salt
#   survived. If uncovered salt was also destroyed, the summary says so.
#
# Clock
# - The scene shows the current beat's remaining ticks at TICK_HZ. The cart
#   countdown refills when the second rain opens the beat. The ship countdown
#   refills when the cart beat ends. The market countdown refills when the
#   ship beat ends. The yard countdown refills when the market beat ends.
#   The bunk countdown refills when the yard beat ends. The loft countdown
#   refills when the bunk beat ends. The gate countdown refills when the loft
#   beat ends. The wage countdown refills when the gate beat ends. The relief
#   countdown refills when the wage beat ends. The watch countdown refills
#   when the relief beat ends. The lamp countdown refills when the watch beat
#   ends. The bell countdown refills when the lamp beat ends. The horn countdown refills when the bell beat ends. The flag countdown refills when the horn beat ends. The banner countdown refills when the flag beat ends. The pennant countdown refills when the banner beat ends. The standard countdown refills when the pennant beat ends. The jack countdown refills when the standard beat ends. The ensign countdown refills when the jack beat ends. The burgee countdown refills when the ensign beat ends. The cornet countdown refills when the burgee beat ends. The guidon countdown refills when the cornet beat ends. The fanion countdown refills when the guidon beat ends. The sim itself counts ticks,
#   not wall-clock time, so a headless run is the same scenario as the window.

const EMPTY := 0
const RAKE := 1
const STACK := 2
const COVER := 3
const TRAIL := 4
const PAN := 5
const CRIB := 6
const SHIP := 7
const STALL := 8
const YARD := 9
const BUNK := 10
const LOFT := 11
const GATE := 12
const WAGE := 13
const RELIEF := 14
const WATCH := 15
const LAMP := 16
const BELL := 17
const HORN := 18
const FLAG := 19
const BANNER := 20
const PENNANT := 21
const STANDARD := 22
const JACK := 23
const ENSIGN := 24
const BURGEE := 25
const CORNET := 26
const GUIDON := 27
const FANION := 28
const PENNON := 29
const GONFALON := 30
const ORIFLAMME := 31
const VEXILLUM := 32
const LABARUM := 33
const SIGNUM := 34
const STREAMER := 35

const WET := 0
const DRY := 1
# Cart is a beat after the dry season. The ship beat follows the cart, then
# the market, then the yard, then the bunk, then the loft, then the gate,
# then the wage, then the relief, then the watch, then the lamp, then the bell, then the horn, then the flag, then the banner, then the pennant, then the standard, then the jack, then the ensign, then the burgee, then the cornet, then the guidon, then the fanion. get_season() stays DRY through all of them.
const CART := 2
const SHIPPING := 3
const MARKET := 4
const YARDING := 5
const BUNKING := 6
const LOFTING := 7
const GATING := 8
const WAGING := 9
const RELIEVING := 10
const WATCHING := 11
const LAMPING := 12
const BELLING := 13
const HORNING := 14
const FLAGGING := 15
const BANNERING := 16
const PENNANTING := 17
const STANDARDING := 18
const JACKING := 19
const ENSIGNING := 20
const BURGEEING := 21
const CORNETING := 22
const GUIDONING := 23
const FANIONING := 24
const PENNONING := 25
const GONFALONING := 26
const ORIFLAMMING := 27
const VEXILLUMING := 28
const LABARUMING := 29
const SIGNUMING := 30
const STREAMERING := 31

const GRID_W := 17
const GRID_H := 12
# Seventeen rows north of the old edge. The bunk plans sit on row 0, so the loft is
# row -1, the gate is row -2, the wage is row -3, the relief is row -4, the
# watch is row -5, the lamp is row -6, the bell is row -7, the horn is row -8,
# the flag is row -9, the banner is row -10, the pennant is row -11, the
# standard is row -12, the jack is row -13, the ensign is row -14, the
# burgee is row -15, the cornet is row -16, the guidon is row -17, the fanion is row -18, the pennon is row -19, the gonfalon is row -20, the oriflamme is row -21, the vexillum is row -22, the labarum is row -23, the signum is row -24, and the streamer is row -25.
const GRID_NORTH := -25
# The only cell that accepts a pennant. One cell north of the banner at (14, -10).
const PENNANT_CELL := Vector2i(14, -11)
# The only cell that accepts a standard. One cell north of the pennant.
const STANDARD_CELL := Vector2i(14, -12)
# The only cell that accepts a jack. One cell north of the standard.
const JACK_CELL := Vector2i(14, -13)
# The only cell that accepts an ensign. One cell north of the jack.
const ENSIGN_CELL := Vector2i(14, -14)
# The only cell that accepts a burgee. One cell north of the ensign.
const BURGEE_CELL := Vector2i(14, -15)
# The only cell that accepts a cornet. One cell north of the burgee.
const CORNET_CELL := Vector2i(14, -16)
# The only cell that accepts a guidon. One cell north of the cornet.
const GUIDON_CELL := Vector2i(14, -17)
# The only cell that accepts a fanion. One cell north of the guidon.
const FANION_CELL := Vector2i(14, -18)
# The only cell that accepts a pennon. One cell north of the fanion.
const PENNON_CELL := Vector2i(14, -19)
# The only cell that accepts a gonfalon. One cell north of the pennon.
const GONFALON_CELL := Vector2i(14, -20)
# The only cell that accepts an oriflamme. One cell north of the gonfalon.
const ORIFLAMME_CELL := Vector2i(14, -21)
# The only cell that accepts a vexillum. One cell north of the oriflamme.
const VEXILLUM_CELL := Vector2i(14, -22)
# The only cell that accepts a labarum. One cell north of the vexillum.
const LABARUM_CELL := Vector2i(14, -23)
# The only cell that accepts a signum. One cell north of the labarum.
const SIGNUM_CELL := Vector2i(14, -24)
# The only cell that accepts a streamer. One cell north of the signum.
const STREAMER_CELL := Vector2i(14, -25)
const COAST_X := 0
const ANTHILL := Vector2i(14, 5)

const POP_CAP := 40
const INITIAL_POP := 10
const SPAWN_EVERY := 10
const QUOTA := 12
const RAIN_TICK := 600
const DRY_TICK := 200
const CART_TICK := 100
const SHIP_TICK := 100
const MARKET_TICK := 100
const YARD_TICK := 100
const BUNK_TICK := 100
const LOFT_TICK := 100
const GATE_TICK := 100
const WAGE_TICK := 100
const RELIEF_TICK := 100
const WATCH_TICK := 100
const LAMP_TICK := 100
const BELL_TICK := 100
const HORN_TICK := 100
const FLAG_TICK := 100
const BANNER_TICK := 100
const PENNANT_TICK := 100
const STANDARD_TICK := 100
const JACK_TICK := 100
const ENSIGN_TICK := 100
const BURGEE_TICK := 100
const CORNET_TICK := 100
const GUIDON_TICK := 100
const FANION_TICK := 100
const PENNON_TICK := 100
const GONFALON_TICK := 100
const ORIFLAMME_TICK := 100
const VEXILLUM_TICK := 100
const LABARUM_TICK := 100
const SIGNUM_TICK := 100
const STREAMER_TICK := 100
const TICK_HZ := 10
const HIRE_COST := 100
# Coins one payment takes from the yard. A shorter purse pays nobody.
const WAGE_COST := 4

const LOOSE_CAP := 12
const STACK_CAP := 12
const COVER_CAP := 999
const CRIB_CAP := 9999
const SHIP_CAP := 9999
const STALL_CAP := 9999
const YARD_CAP := 9999
const BUNK_CAP := 9999
const LOFT_CAP := 9999
# Total hires the gate lets through. Past this the beat stops moving them.
const GATE_CAP := 10
const WAGE_CAP := 9999
# Total paid hires the relief posts. Past this the beat stops moving them.
const RELIEF_CAP := 6
# Total posted hires the watch stands. Past this the beat stops moving them.
const WATCH_CAP := 4
# Total stood hires the lamp lights. Past this the beat stops moving them.
const LAMP_CAP := 3
# Total lit hires the bell rings. Past this the beat stops moving them.
const BELL_CAP := 2
# Total rung hires the horn sounds. Past this the beat stops moving them.
const HORN_CAP := 1
# Total sounded hires the flag raises. Past this the beat stops moving them.
const FLAG_CAP := 1
# Total raised hires the banner hoists. Past this the beat stops moving them.
const BANNER_CAP := 1
# Total hoisted hires the pennant flies. Past this the beat stops moving them.
const PENNANT_CAP := 1
# Total flown hires the standard carries. Past this the beat stops moving them.
const STANDARD_CAP := 1
# Total carried hires the jack shows. Past this the beat stops moving them.
const JACK_CAP := 1
# Total shown hires the ensign breaks. Past this the beat stops moving them.
const ENSIGN_CAP := 1
# Total broken hires the burgee strikes. Past this the beat stops moving them.
const BURGEE_CAP := 1
# Total struck hires the cornet dips. Past this the beat stops moving them.
const CORNET_CAP := 1
# Total dipped hires the guidon salutes. Past this the beat stops moving them.
const GUIDON_CAP := 1
# Total saluted hires the fanion presents. Past this the beat stops moving them.
const FANION_CAP := 1
# Total presented hires the pennon furls. Past this the beat stops moving them.
const PENNON_CAP := 1
# Total furled hires the gonfalon dips. Past this the beat stops moving them.
const GONFALON_CAP := 1
# Total dipped hires the oriflamme lowers. Past this the beat stops moving them.
const ORIFLAMME_CAP := 1
# Total lowered hires the vexillum houses. Past this the beat stops moving them.
const VEXILLUM_CAP := 1
# Total housed hires the labarum cases. Past this the beat stops moving them.
const LABARUM_CAP := 1
# Total cased hires the signum sleeves. Past this the beat stops moving them.
const SIGNUM_CAP := 1
# Total sleeved hires the streamer rolls. Past this the beat stops moving them.
const STREAMER_CAP := 1

const JOB_GATHER := 0
const JOB_STACK := 1
const JOB_COVER := 2

# North, west, east, south. Equal-length paths keep the first of these.
const DIRS: Array = [Vector2i(0, -1), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, 1)]

var _paint: Dictionary = {}
var _loose: Dictionary = {}
var _stacked: Dictionary = {}
var _covered: Dictionary = {}
var _crib: Dictionary = {}
var _ship: Dictionary = {}
var _stall: Dictionary = {}
var _yard: Dictionary = {}
var _bunk: Dictionary = {}
var _loft: Dictionary = {}
var _gate: Dictionary = {}
var _wage: Dictionary = {}
var _relief: Dictionary = {}
var _watch: Dictionary = {}
var _lamp: Dictionary = {}
var _bell: Dictionary = {}
var _horn: Dictionary = {}
var _flag: Dictionary = {}
var _banner: Dictionary = {}
var _pennant: Dictionary = {}
var _standard: Dictionary = {}
var _jack: Dictionary = {}
var _ensign: Dictionary = {}
var _burgee: Dictionary = {}
var _cornet: Dictionary = {}
var _guidon: Dictionary = {}
var _fanion: Dictionary = {}
var _pennon: Dictionary = {}
var _gonfalon: Dictionary = {}
var _oriflamme: Dictionary = {}
var _vexillum: Dictionary = {}
var _labarum: Dictionary = {}
var _signum: Dictionary = {}
var _streamer: Dictionary = {}
var _workers: Array = []

var _next_id: int = 0
var _tick_index: int = 0
var _season: int = WET
var _phase: int = WET
var _wet_haul: int = 0
var _ledger: int = 0
var _rain_done: bool = false
var _max_population: int = 0
var _pop_cap_violations: int = 0
var _uncovered_destroyed: int = 0
var _summary: String = ""


class Worker:
	var id: int
	var x: int
	var y: int
	var job: int


func _init() -> void:
	restart()


func restart() -> void:
	_paint.clear()
	_loose.clear()
	_stacked.clear()
	_covered.clear()
	_crib.clear()
	_ship.clear()
	_stall.clear()
	_yard.clear()
	_bunk.clear()
	_loft.clear()
	_gate.clear()
	_wage.clear()
	_relief.clear()
	_watch.clear()
	_lamp.clear()
	_bell.clear()
	_horn.clear()
	_flag.clear()
	_banner.clear()
	_pennant.clear()
	_standard.clear()
	_jack.clear()
	_ensign.clear()
	_burgee.clear()
	_cornet.clear()
	_guidon.clear()
	_fanion.clear()
	_pennon.clear()
	_gonfalon.clear()
	_oriflamme.clear()
	_vexillum.clear()
	_labarum.clear()
	_signum.clear()
	_streamer.clear()
	_workers.clear()
	_next_id = 0
	_tick_index = 0
	_season = WET
	_phase = WET
	_wet_haul = 0
	_ledger = 0
	_rain_done = false
	_max_population = 0
	_pop_cap_violations = 0
	_uncovered_destroyed = 0
	_summary = ""
	var starter := mini(INITIAL_POP, POP_CAP)
	for _i in starter:
		_add_worker()


func paint_cell(x: int, y: int, mode: int) -> bool:
	if _rain_done:
		return false
	if not _paintable(x, y):
		return false
	if mode < EMPTY or mode > STREAMER:
		return false
	# The pennant row accepts a pennant only at PENNANT_CELL. A banner stays
	# one cell south, and that cell rejects a pennant. The standard row accepts
	# a standard only at STANDARD_CELL, one cell north of the pennant. The jack
	# row accepts a jack only at JACK_CELL, one cell north of the standard. The
	# ensign row accepts an ensign only at ENSIGN_CELL, one cell north of the jack.
	# The burgee row accepts a burgee only at BURGEE_CELL, one cell north of the ensign.
	# The cornet row accepts a cornet only at CORNET_CELL, one cell north of the burgee.
	# The guidon row accepts a guidon only at GUIDON_CELL, one cell north of the cornet.
	# The fanion row accepts a fanion only at FANION_CELL, one cell north of the guidon.
	# The pennon row accepts a pennon only at PENNON_CELL, one cell north of the fanion.
	# The gonfalon row accepts a gonfalon only at GONFALON_CELL, one cell north of the pennon.
	# The oriflamme row accepts an oriflamme only at ORIFLAMME_CELL, one cell north of the gonfalon.
	# The vexillum row accepts a vexillum only at VEXILLUM_CELL, one cell north of the oriflamme.
	# The labarum row accepts a labarum only at LABARUM_CELL, one cell north of the vexillum.
	# The signum row accepts a signum only at SIGNUM_CELL, one cell north of the labarum.
	# The streamer row accepts a streamer only at STREAMER_CELL, one cell north of the signum.
	if mode == PENNANT and Vector2i(x, y) != PENNANT_CELL:
		return false
	if y == PENNANT_CELL.y and mode != PENNANT and mode != EMPTY:
		return false
	if mode == STANDARD and Vector2i(x, y) != STANDARD_CELL:
		return false
	if y == STANDARD_CELL.y and mode != STANDARD and mode != EMPTY:
		return false
	if mode == JACK and Vector2i(x, y) != JACK_CELL:
		return false
	if y == JACK_CELL.y and mode != JACK and mode != EMPTY:
		return false
	if mode == ENSIGN and Vector2i(x, y) != ENSIGN_CELL:
		return false
	if y == ENSIGN_CELL.y and mode != ENSIGN and mode != EMPTY:
		return false
	if mode == BURGEE and Vector2i(x, y) != BURGEE_CELL:
		return false
	if y == BURGEE_CELL.y and mode != BURGEE and mode != EMPTY:
		return false
	if mode == CORNET and Vector2i(x, y) != CORNET_CELL:
		return false
	if y == CORNET_CELL.y and mode != CORNET and mode != EMPTY:
		return false
	if mode == GUIDON and Vector2i(x, y) != GUIDON_CELL:
		return false
	if y == GUIDON_CELL.y and mode != GUIDON and mode != EMPTY:
		return false
	if mode == FANION and Vector2i(x, y) != FANION_CELL:
		return false
	if y == FANION_CELL.y and mode != FANION and mode != EMPTY:
		return false
	if mode == PENNON and Vector2i(x, y) != PENNON_CELL:
		return false
	if y == PENNON_CELL.y and mode != PENNON and mode != EMPTY:
		return false
	if mode == GONFALON and Vector2i(x, y) != GONFALON_CELL:
		return false
	if y == GONFALON_CELL.y and mode != GONFALON and mode != EMPTY:
		return false
	if mode == ORIFLAMME and Vector2i(x, y) != ORIFLAMME_CELL:
		return false
	if y == ORIFLAMME_CELL.y and mode != ORIFLAMME and mode != EMPTY:
		return false
	if mode == VEXILLUM and Vector2i(x, y) != VEXILLUM_CELL:
		return false
	if y == VEXILLUM_CELL.y and mode != VEXILLUM and mode != EMPTY:
		return false
	if mode == LABARUM and Vector2i(x, y) != LABARUM_CELL:
		return false
	if y == LABARUM_CELL.y and mode != LABARUM and mode != EMPTY:
		return false
	if mode == SIGNUM and Vector2i(x, y) != SIGNUM_CELL:
		return false
	if y == SIGNUM_CELL.y and mode != SIGNUM and mode != EMPTY:
		return false
	if mode == STREAMER and Vector2i(x, y) != STREAMER_CELL:
		return false
	if y == STREAMER_CELL.y and mode != STREAMER and mode != EMPTY:
		return false
	var cell := Vector2i(x, y)
	if mode == EMPTY:
		_paint.erase(cell)
	else:
		_paint[cell] = mode
	return true


func get_paint(x: int, y: int) -> int:
	return _paint_at(Vector2i(x, y))


func _pennon_painted() -> bool:
	return _paint_at(PENNON_CELL) == PENNON


func _gonfalon_painted() -> bool:
	return _paint_at(GONFALON_CELL) == GONFALON


func _oriflamme_painted() -> bool:
	return _paint_at(ORIFLAMME_CELL) == ORIFLAMME


func _vexillum_painted() -> bool:
	return _paint_at(VEXILLUM_CELL) == VEXILLUM


func _labarum_painted() -> bool:
	return _paint_at(LABARUM_CELL) == LABARUM


func _signum_painted() -> bool:
	return _paint_at(SIGNUM_CELL) == SIGNUM


func _streamer_painted() -> bool:
	return _paint_at(STREAMER_CELL) == STREAMER


func _scenario_end_tick() -> int:
	var end_tick := RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK + ENSIGN_TICK + BURGEE_TICK + CORNET_TICK + GUIDON_TICK + FANION_TICK
	# A painted pennon opens one more beat. With no pennon, the fanion still ends the scenario.
	if _phase == PENNONING or _pennon_painted() or _phase == GONFALONING or _gonfalon_painted() or _phase == ORIFLAMMING or _oriflamme_painted() or _phase == VEXILLUMING or _vexillum_painted() or _phase == LABARUMING or _labarum_painted() or _phase == SIGNUMING or _signum_painted() or _phase == STREAMERING or _streamer_painted():
		end_tick += PENNON_TICK
	# A painted gonfalon opens one more beat after the pennon. With no gonfalon, the pennon still ends the scenario.
	if _phase == GONFALONING or _gonfalon_painted() or _phase == ORIFLAMMING or _oriflamme_painted() or _phase == VEXILLUMING or _vexillum_painted() or _phase == LABARUMING or _labarum_painted() or _phase == SIGNUMING or _signum_painted() or _phase == STREAMERING or _streamer_painted():
		end_tick += GONFALON_TICK
	# A painted oriflamme opens one more beat after the gonfalon. With no oriflamme, the gonfalon still ends the scenario.
	if _phase == ORIFLAMMING or _oriflamme_painted() or _phase == VEXILLUMING or _vexillum_painted() or _phase == LABARUMING or _labarum_painted() or _phase == SIGNUMING or _signum_painted() or _phase == STREAMERING or _streamer_painted():
		end_tick += ORIFLAMME_TICK
	# A painted vexillum opens one more beat after the oriflamme. With no vexillum, the oriflamme still ends the scenario.
	if _phase == VEXILLUMING or _vexillum_painted() or _phase == LABARUMING or _labarum_painted() or _phase == SIGNUMING or _signum_painted() or _phase == STREAMERING or _streamer_painted():
		end_tick += VEXILLUM_TICK
	# A painted labarum opens one more beat after the vexillum. With no labarum, the vexillum still ends the scenario.
	if _phase == LABARUMING or _labarum_painted() or _phase == SIGNUMING or _signum_painted() or _phase == STREAMERING or _streamer_painted():
		end_tick += LABARUM_TICK
	# A painted signum opens one more beat after the labarum. With no signum, the labarum still ends the scenario.
	if _phase == SIGNUMING or _signum_painted() or _phase == STREAMERING or _streamer_painted():
		end_tick += SIGNUM_TICK
	# A painted streamer opens one more beat after the signum. With no streamer, the signum still ends the scenario.
	if _phase == STREAMERING or _streamer_painted():
		end_tick += STREAMER_TICK
	return end_tick


func tick() -> void:
	if _rain_done:
		return
	var end_tick := _scenario_end_tick()
	if _tick_index >= end_tick:
		_finish()
		return
	_maybe_spawn()
	var flows := _flows()
	for worker in _workers:
		_act(worker, flows[int(worker.job)])
	if _workers.size() > POP_CAP:
		_pop_cap_violations += 1
	_tick_index += 1
	if _tick_index == RAIN_TICK:
		_resolve_first_rain()
	elif _tick_index == RAIN_TICK + DRY_TICK:
		_open_cart()
	elif _tick_index == RAIN_TICK + DRY_TICK + CART_TICK:
		_open_ship()
	elif _tick_index == RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK:
		_open_market()
	elif _tick_index == RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK:
		_open_yard()
	elif _tick_index == RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK:
		_open_bunk()
	elif _tick_index == RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK:
		_open_loft()
	elif _tick_index == RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK:
		_open_gate()
	elif _tick_index == RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK:
		_open_wage()
	elif _tick_index == RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK:
		_open_relief()
	elif _tick_index == RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK:
		_open_watch()
	elif _tick_index == RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK:
		_open_lamp()
	elif _tick_index == RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK:
		_open_bell()
	elif _tick_index == RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK:
		_open_horn()
	elif _tick_index == RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK:
		_open_flag()
	elif _tick_index == RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK:
		_open_banner()
	elif _tick_index == RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK:
		_open_pennant()
	elif _tick_index == RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK:
		_open_standard()
	elif _tick_index == RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK:
		_open_jack()
	elif _tick_index == RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK:
		_open_ensign()
	elif _tick_index == RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK + ENSIGN_TICK:
		_open_burgee()
	elif _tick_index == RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK + ENSIGN_TICK + BURGEE_TICK:
		_open_cornet()
	elif _tick_index == RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK + ENSIGN_TICK + BURGEE_TICK + CORNET_TICK:
		_open_guidon()
	elif _tick_index == RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK + ENSIGN_TICK + BURGEE_TICK + CORNET_TICK + GUIDON_TICK:
		_open_fanion()
	elif _tick_index == RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK + ENSIGN_TICK + BURGEE_TICK + CORNET_TICK + GUIDON_TICK + FANION_TICK:
		if _pennon_painted():
			_open_pennon()
		else:
			_finish()
	elif _tick_index == RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK + ENSIGN_TICK + BURGEE_TICK + CORNET_TICK + GUIDON_TICK + FANION_TICK + PENNON_TICK:
		if _gonfalon_painted():
			_open_gonfalon()
		else:
			_finish()
	elif _tick_index == RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK + ENSIGN_TICK + BURGEE_TICK + CORNET_TICK + GUIDON_TICK + FANION_TICK + PENNON_TICK + GONFALON_TICK:
		if _oriflamme_painted():
			_open_oriflamme()
		else:
			_finish()
	elif _tick_index == RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK + ENSIGN_TICK + BURGEE_TICK + CORNET_TICK + GUIDON_TICK + FANION_TICK + PENNON_TICK + GONFALON_TICK + ORIFLAMME_TICK:
		if _vexillum_painted():
			_open_vexillum()
		else:
			_finish()
	elif _tick_index == RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK + ENSIGN_TICK + BURGEE_TICK + CORNET_TICK + GUIDON_TICK + FANION_TICK + PENNON_TICK + GONFALON_TICK + ORIFLAMME_TICK + VEXILLUM_TICK:
		if _labarum_painted():
			_open_labarum()
		else:
			_finish()
	elif _tick_index == RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK + ENSIGN_TICK + BURGEE_TICK + CORNET_TICK + GUIDON_TICK + FANION_TICK + PENNON_TICK + GONFALON_TICK + ORIFLAMME_TICK + VEXILLUM_TICK + LABARUM_TICK:
		if _signum_painted():
			_open_signum()
		else:
			_finish()
	elif _tick_index == RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK + ENSIGN_TICK + BURGEE_TICK + CORNET_TICK + GUIDON_TICK + FANION_TICK + PENNON_TICK + GONFALON_TICK + ORIFLAMME_TICK + VEXILLUM_TICK + LABARUM_TICK + SIGNUM_TICK:
		if _streamer_painted():
			_open_streamer()
		else:
			_finish()
	elif _tick_index >= end_tick:
		_finish()


func run_until_rain() -> void:
	var guard := 0
	var limit := RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK + ENSIGN_TICK + BURGEE_TICK + CORNET_TICK + GUIDON_TICK + FANION_TICK + PENNON_TICK + GONFALON_TICK + ORIFLAMME_TICK + VEXILLUM_TICK + LABARUM_TICK + SIGNUM_TICK + STREAMER_TICK + 2
	while not _rain_done and guard < limit:
		tick()
		guard += 1


func get_stored_salt() -> int:
	return _ledger + _covered_on_map() + _sum(_crib) + _sum(_ship) + _sum(_stall) + _sum(_yard) + _hired_coins() + _wage_coins()


func get_loose_salt() -> int:
	return _sum(_loose)


func get_stacked_salt() -> int:
	return _sum(_stacked)


func get_wet_haul() -> int:
	return _wet_haul


func get_season() -> int:
	return _season


# WET, DRY, CART, SHIPPING, MARKET, YARDING, BUNKING, LOFTING, GATING, WAGING, RELIEVING, WATCHING, LAMPING, BELLING, HORNING, FLAGGING, BANNERING, PENNANTING, STANDARDING, JACKING, ENSIGNING, BURGEEING, CORNETING, GUIDONING, FANIONING, PENNONING, GONFALONING, ORIFLAMMING, VEXILLUMING, LABARUMING, SIGNUMING, or STREAMERING. Weather stays dry after the first rain.
func get_beat() -> int:
	return _phase


# Salt that reached a crib. Salt loaded onto a ship, salt sold later, coins banked later, coins spent hiring, and coins spent on wages, still count.
func get_carted() -> int:
	return _sum(_crib) + _sum(_ship) + _sum(_stall) + _sum(_yard) + _hired_coins() + _wage_coins()


func get_crib_salt() -> int:
	return _sum(_crib)


# Salt that reached a ship. Salt sold at a stall, coins banked later, coins spent hiring, and coins spent on wages, still count.
func get_shipped() -> int:
	return _sum(_ship) + _sum(_stall) + _sum(_yard) + _hired_coins() + _wage_coins()


func get_ship_salt() -> int:
	return _sum(_ship)


# One coin per sold unit, including coins later banked in a yard, coins spent hiring, and coins spent on wages. Nothing is rolled.
func get_coins() -> int:
	return _sum(_stall) + _sum(_yard) + _hired_coins() + _wage_coins()


# Coins still sitting at a stall. Banking moves these into a yard.
func get_purse() -> int:
	return _sum(_stall)


# Coins moved into a yard, including coins later spent on hires and wages.
func get_banked() -> int:
	return _sum(_yard) + _hired_coins() + _wage_coins()


# Coins still sitting in a yard. Hiring spends these in blocks of HIRE_COST.
# The wage spends what hiring left, in blocks of WAGE_COST.
func get_yard_left() -> int:
	return _sum(_yard)


# Hires bought from banked coins, including hires later moved into a loft,
# hires later let through a gate, hires later paid a wage, and hires later
# posted to a relief, hires later stood on a watch, and hires later lit
# by a lamp. One hire costs HIRE_COST. Nothing is rolled.
func get_hired() -> int:
	return _sum(_bunk) + _sum(_loft) + _sum(_gate) + _sum(_wage) + _sum(_relief) + _sum(_watch) + _sum(_lamp) + _sum(_bell) + _sum(_horn) + _sum(_flag) + _sum(_banner) + _sum(_pennant) + _sum(_standard) + _sum(_jack) + _sum(_ensign) + _sum(_burgee) + _sum(_cornet) + _sum(_guidon) + _sum(_fanion) + _sum(_pennon) + _sum(_gonfalon) + _sum(_oriflamme) + _sum(_vexillum) + _sum(_labarum) + _sum(_signum) + _sum(_streamer)


# Hires still sitting at a bunk. Lofting moves these one at a time.
func get_bunk_left() -> int:
	return _sum(_bunk)


# Hires moved into a loft, including hires later let through a gate,
# hires later paid a wage, hires later posted, hires later stood, and hires
# later lit. The hire total still counts these.
func get_lofted() -> int:
	return _sum(_loft) + _sum(_gate) + _sum(_wage) + _sum(_relief) + _sum(_watch) + _sum(_lamp) + _sum(_bell) + _sum(_horn) + _sum(_flag) + _sum(_banner) + _sum(_pennant) + _sum(_standard) + _sum(_jack) + _sum(_ensign) + _sum(_burgee) + _sum(_cornet) + _sum(_guidon) + _sum(_fanion) + _sum(_pennon) + _sum(_gonfalon) + _sum(_oriflamme) + _sum(_vexillum) + _sum(_labarum) + _sum(_signum) + _sum(_streamer)


# Hires still sitting in a loft. The gate moves these one at a time.
func get_loft_left() -> int:
	return _sum(_loft)


# Hires let through a gate, at most GATE_CAP, including hires later paid,
# hires later posted, hires later stood, and hires later lit. Nothing is
# rolled. The loft total and the hire total still count these.
func get_gated() -> int:
	return _sum(_gate) + _sum(_wage) + _sum(_relief) + _sum(_watch) + _sum(_lamp) + _sum(_bell) + _sum(_horn) + _sum(_flag) + _sum(_banner) + _sum(_pennant) + _sum(_standard) + _sum(_jack) + _sum(_ensign) + _sum(_burgee) + _sum(_cornet) + _sum(_guidon) + _sum(_fanion) + _sum(_pennon) + _sum(_gonfalon) + _sum(_oriflamme) + _sum(_vexillum) + _sum(_labarum) + _sum(_signum) + _sum(_streamer)


# Hires who passed a gate and have not been paid. The wage pays these one at a time.
func get_gate_left() -> int:
	return _sum(_gate)


# Hires paid a wage, including hires later posted, hires later stood, and
# hires later lit. Pay is WAGE_COST coins from the yard. Nothing is rolled.
# The gate total and the hire total still count these.
func get_paid() -> int:
	return _sum(_wage) + _sum(_relief) + _sum(_watch) + _sum(_lamp) + _sum(_bell) + _sum(_horn) + _sum(_flag) + _sum(_banner) + _sum(_pennant) + _sum(_standard) + _sum(_jack) + _sum(_ensign) + _sum(_burgee) + _sum(_cornet) + _sum(_guidon) + _sum(_fanion) + _sum(_pennon) + _sum(_gonfalon) + _sum(_oriflamme) + _sum(_vexillum) + _sum(_labarum) + _sum(_signum) + _sum(_streamer)


# Hires who were paid and have not been posted. The relief posts these one at a time.
func get_wage_left() -> int:
	return _sum(_wage)


# Hires posted to a relief, at most RELIEF_CAP, including hires later stood
# on a watch and hires later lit by a lamp. Nothing is rolled. The paid
# total and the hire total still count these. Posting spends no coins.
func get_posted() -> int:
	return _sum(_relief) + _sum(_watch) + _sum(_lamp) + _sum(_bell) + _sum(_horn) + _sum(_flag) + _sum(_banner) + _sum(_pennant) + _sum(_standard) + _sum(_jack) + _sum(_ensign) + _sum(_burgee) + _sum(_cornet) + _sum(_guidon) + _sum(_fanion) + _sum(_pennon) + _sum(_gonfalon) + _sum(_oriflamme) + _sum(_vexillum) + _sum(_labarum) + _sum(_signum) + _sum(_streamer)


# Hires who were posted and have not been stood. The watch stands these one at a time.
func get_relief_left() -> int:
	return _sum(_relief)


# Hires stood on a watch, at most WATCH_CAP, including hires later lit by a
# lamp. Nothing is rolled. The posted total and the hire total still count
# these. Standing spends no coins and does not change the posted count.
func get_stood() -> int:
	return _sum(_watch) + _sum(_lamp) + _sum(_bell) + _sum(_horn) + _sum(_flag) + _sum(_banner) + _sum(_pennant) + _sum(_standard) + _sum(_jack) + _sum(_ensign) + _sum(_burgee) + _sum(_cornet) + _sum(_guidon) + _sum(_fanion) + _sum(_pennon) + _sum(_gonfalon) + _sum(_oriflamme) + _sum(_vexillum) + _sum(_labarum) + _sum(_signum) + _sum(_streamer)


# Hires who were stood and have not been lit. The lamp lights these one at a time.
func get_watch_left() -> int:
	return _sum(_watch)


# Hires lit by a lamp, at most LAMP_CAP, including hires later rung on a
# bell and hires later sounded on a horn. Nothing is rolled. The stood total
# and the hire total still count these. Lighting spends no coins and does not
# change the stood count or the posted count.
func get_lit() -> int:
	return _sum(_lamp) + _sum(_bell) + _sum(_horn) + _sum(_flag) + _sum(_banner) + _sum(_pennant) + _sum(_standard) + _sum(_jack) + _sum(_ensign) + _sum(_burgee) + _sum(_cornet) + _sum(_guidon) + _sum(_fanion) + _sum(_pennon) + _sum(_gonfalon) + _sum(_oriflamme) + _sum(_vexillum) + _sum(_labarum) + _sum(_signum) + _sum(_streamer)


# Hires who were lit and have not been rung. The bell rings these one at a time.
func get_lamp_left() -> int:
	return _sum(_lamp)


# Hires rung on a bell, at most BELL_CAP, including hires later sounded on a
# horn. Nothing is rolled. The lit total and the hire total still count these.
# Ringing spends no coins and does not change the lit count, the stood count,
# or the posted count.
func get_rung() -> int:
	return _sum(_bell) + _sum(_horn) + _sum(_flag) + _sum(_banner) + _sum(_pennant) + _sum(_standard) + _sum(_jack) + _sum(_ensign) + _sum(_burgee) + _sum(_cornet) + _sum(_guidon) + _sum(_fanion) + _sum(_pennon) + _sum(_gonfalon) + _sum(_oriflamme) + _sum(_vexillum) + _sum(_labarum) + _sum(_signum) + _sum(_streamer)


# Hires who were rung and have not been sounded. The horn sounds these one at a time.
func get_bell_left() -> int:
	return _sum(_bell)


# Hires sounded on a horn, at most HORN_CAP, including hires later raised on
# a flag and hires later hoisted on a banner. Nothing is rolled. The rung
# total and the hire total still count these. Sounding spends no coins and
# does not change the rung count, the lit count, the stood count, or the
# posted count.
func get_sounded() -> int:
	return _sum(_horn) + _sum(_flag) + _sum(_banner) + _sum(_pennant) + _sum(_standard) + _sum(_jack) + _sum(_ensign) + _sum(_burgee) + _sum(_cornet) + _sum(_guidon) + _sum(_fanion) + _sum(_pennon) + _sum(_gonfalon) + _sum(_oriflamme) + _sum(_vexillum) + _sum(_labarum) + _sum(_signum) + _sum(_streamer)


# Hires who were sounded and have not been raised. The flag raises these one at a time.
func get_horn_left() -> int:
	return _sum(_horn)


# Hires raised on a flag, at most FLAG_CAP, including hires later hoisted on
# a banner. Nothing is rolled. The sounded total and the hire total still
# count these. Raising spends no coins and does not change the sounded count,
# the rung count, the lit count, the stood count, or the posted count.
# The raised total still counts a hire who was later hoisted.
func get_raised() -> int:
	return _sum(_flag) + _sum(_banner) + _sum(_pennant) + _sum(_standard) + _sum(_jack) + _sum(_ensign) + _sum(_burgee) + _sum(_cornet) + _sum(_guidon) + _sum(_fanion) + _sum(_pennon) + _sum(_gonfalon) + _sum(_oriflamme) + _sum(_vexillum) + _sum(_labarum) + _sum(_signum) + _sum(_streamer)


# Hires who were raised and have not been hoisted. The banner hoists these one at a time.
func get_flag_left() -> int:
	return _sum(_flag)


# Hires hoisted on a banner, at most BANNER_CAP, including hires later flown
# on a pennant. Nothing is rolled. The raised total and the hire total still
# count these. Hoisting spends no coins and does not change the raised count,
# the sounded count, the rung count, the lit count, the stood count, or the
# posted count. The hoisted total still counts a hire who was later flown.
func get_hoisted() -> int:
	return _sum(_banner) + _sum(_pennant) + _sum(_standard) + _sum(_jack) + _sum(_ensign) + _sum(_burgee) + _sum(_cornet) + _sum(_guidon) + _sum(_fanion) + _sum(_pennon) + _sum(_gonfalon) + _sum(_oriflamme) + _sum(_vexillum) + _sum(_labarum) + _sum(_signum) + _sum(_streamer)


# Hires who were hoisted and have not been flown. The pennant flies these one at a time.
func get_banner_left() -> int:
	return _sum(_banner)


# Hires flown on a pennant, at most PENNANT_CAP, including hires later carried
# on a standard. Nothing is rolled. The hoisted total and the hire total still
# count these. Flying spends no coins and does not change the hoisted count,
# the raised count, the sounded count, the rung count, the lit count, the stood
# count, or the posted count. The flown total still counts a hire who was later
# carried.
func get_flown() -> int:
	return _sum(_pennant) + _sum(_standard) + _sum(_jack) + _sum(_ensign) + _sum(_burgee) + _sum(_cornet) + _sum(_guidon) + _sum(_fanion) + _sum(_pennon) + _sum(_gonfalon) + _sum(_oriflamme) + _sum(_vexillum) + _sum(_labarum) + _sum(_signum) + _sum(_streamer)


# Hires who were flown and have not been carried. The standard carries these one at a time.
func get_pennant_left() -> int:
	return _sum(_pennant)


# Hires carried on a standard, at most STANDARD_CAP, including hires later
# shown on a jack. Nothing is rolled. The flown total and the hire total still
# count these. Carrying spends no coins and does not change the flown count,
# the hoisted count, the raised count, the sounded count, the rung count, the
# lit count, the stood count, or the posted count. The carried total still
# counts a hire who was later shown.
func get_carried() -> int:
	return _sum(_standard) + _sum(_jack) + _sum(_ensign) + _sum(_burgee) + _sum(_cornet) + _sum(_guidon) + _sum(_fanion) + _sum(_pennon) + _sum(_gonfalon) + _sum(_oriflamme) + _sum(_vexillum) + _sum(_labarum) + _sum(_signum) + _sum(_streamer)


# Hires who were carried and have not been shown. The jack shows these one at a time.
func get_standard_left() -> int:
	return _sum(_standard)


# Hires shown on a jack, at most JACK_CAP, including hires later broken on an
# ensign, hires later struck on a burgee, and hires later dipped on a cornet.
# Nothing is rolled. The carried total and the hire total still count these.
# Showing spends no coins and does not change the carried count, the flown
# count, the hoisted count, the raised count, the sounded count, the rung
# count, the lit count, the stood count, or the posted count. The shown total
# still counts a hire who was later broken, struck, or dipped.
func get_shown() -> int:
	return _sum(_jack) + _sum(_ensign) + _sum(_burgee) + _sum(_cornet) + _sum(_guidon) + _sum(_fanion) + _sum(_pennon) + _sum(_gonfalon) + _sum(_oriflamme) + _sum(_vexillum) + _sum(_labarum) + _sum(_signum) + _sum(_streamer)


# Hires who were shown and have not been broken. The ensign breaks these one at a time.
func get_jack_left() -> int:
	return _sum(_jack)


# Hires broken on an ensign, at most ENSIGN_CAP, including hires later struck
# on a burgee and hires later dipped on a cornet. Nothing is rolled. The shown
# total and the hire total still count these. Breaking spends no coins and does
# not change the shown count, the carried count, the flown count, the hoisted
# count, the raised count, the sounded count, the rung count, the lit count,
# the stood count, or the posted count. The broken total still counts a hire
# who was later struck or dipped.
func get_broken() -> int:
	return _sum(_ensign) + _sum(_burgee) + _sum(_cornet) + _sum(_guidon) + _sum(_fanion) + _sum(_pennon) + _sum(_gonfalon) + _sum(_oriflamme) + _sum(_vexillum) + _sum(_labarum) + _sum(_signum) + _sum(_streamer)


# Hires who were broken and have not been struck. The burgee strikes these one at a time.
func get_ensign_left() -> int:
	return _sum(_ensign)


# Hires struck on a burgee, at most BURGEE_CAP, including hires later dipped
# on a cornet and hires later saluted on a guidon. Nothing is rolled. The
# broken total and the hire total still count these. Striking spends no coins
# and does not change the broken count, the shown count, the carried count,
# the flown count, the hoisted count, the raised count, the sounded count,
# the rung count, the lit count, the stood count, or the posted count. The
# struck total still counts a hire who was later dipped or saluted.
func get_struck() -> int:
	return _sum(_burgee) + _sum(_cornet) + _sum(_guidon) + _sum(_fanion) + _sum(_pennon) + _sum(_gonfalon) + _sum(_oriflamme) + _sum(_vexillum) + _sum(_labarum) + _sum(_signum) + _sum(_streamer)


# Hires who were struck and have not been dipped. The cornet dips these one at a time.
func get_burgee_left() -> int:
	return _sum(_burgee)


# Hires dipped on a cornet, at most CORNET_CAP, including hires later saluted
# on a guidon. Nothing is rolled. The struck total and the hire total still
# count these. Dipping spends no coins and does not change the struck count,
# the broken count, the shown count, the carried count, the flown count, the
# hoisted count, the raised count, the sounded count, the rung count, the lit
# count, the stood count, or the posted count. The dipped total still counts
# a hire who was later saluted.
func get_dipped() -> int:
	return _sum(_cornet) + _sum(_guidon) + _sum(_fanion) + _sum(_pennon) + _sum(_gonfalon) + _sum(_oriflamme) + _sum(_vexillum) + _sum(_labarum) + _sum(_signum) + _sum(_streamer)


# Hires who were dipped and have not been saluted. The guidon salutes these one at a time.
func get_cornet_left() -> int:
	return _sum(_cornet)


# Hires saluted on a guidon, at most GUIDON_CAP, including hires later presented
# on a fanion. Nothing is rolled. The dipped total and the hire total still
# count these. Saluting spends no coins and does not change the dipped count,
# the struck count, the broken count, the shown count, the carried count, the
# flown count, the hoisted count, the raised count, the sounded count, the rung
# count, the lit count, the stood count, or the posted count. The saluted total
# still counts a hire who was later presented.
func get_saluted() -> int:
	return _sum(_guidon) + _sum(_fanion) + _sum(_pennon) + _sum(_gonfalon) + _sum(_oriflamme) + _sum(_vexillum) + _sum(_labarum) + _sum(_signum) + _sum(_streamer)


# Hires who were saluted and have not been presented. The fanion presents these one at a time.
func get_guidon_left() -> int:
	return _sum(_guidon)


# Hires presented on a fanion, at most FANION_CAP, including hires later furled
# on a pennon. Nothing is rolled. The saluted total and the hire total still
# count these. Presenting spends no coins and does not change the saluted count,
# the dipped count, the struck count, the broken count, the shown count, the
# carried count, the flown count, the hoisted count, the raised count, the
# sounded count, the rung count, the lit count, the stood count, or the posted
# count. The presented total still counts a hire who was later furled.
func get_presented() -> int:
	return _sum(_fanion) + _sum(_pennon) + _sum(_gonfalon) + _sum(_oriflamme) + _sum(_vexillum) + _sum(_labarum) + _sum(_signum) + _sum(_streamer)


# Hires who were presented and have not been furled. The pennon furls these one at a time.
func get_fanion_left() -> int:
	return _sum(_fanion)


# Hires furled on a pennon, at most PENNON_CAP, including hires later dipped on
# a gonfalon. Nothing is rolled. The presented total and the hire total still
# count these. Furling spends no coins and does not change the presented count
# or any earlier count. The furled total still counts a hire who was later dipped.
func get_furled() -> int:
	return _sum(_pennon) + _sum(_gonfalon) + _sum(_oriflamme) + _sum(_vexillum) + _sum(_labarum) + _sum(_signum) + _sum(_streamer)


# Hires who were furled and have not been dipped on a gonfalon. The gonfalon dips these one at a time.
func get_pennon_left() -> int:
	return _sum(_pennon)


# Hires dipped on a gonfalon, at most GONFALON_CAP, including hires later lowered
# on an oriflamme and later housed on a vexillum. Nothing is rolled. The furled
# total and the hire total still count these. Dipping spends no coins and does
# not change the furled count, the presented count, or any earlier count. The
# dipped total still counts a hire who was later lowered. The cornet's dipped
# total is get_dipped().
func get_gonfalon_dipped() -> int:
	return _sum(_gonfalon) + _sum(_oriflamme) + _sum(_vexillum) + _sum(_labarum) + _sum(_signum) + _sum(_streamer)


# Hires who were dipped on a gonfalon and have not been lowered. The oriflamme lowers these one at a time.
func get_gonfalon_left() -> int:
	return _sum(_gonfalon)


# Hires lowered on an oriflamme, at most ORIFLAMME_CAP, including hires later
# housed on a vexillum. Nothing is rolled. The gonfalon dipped total and the
# hire total still count these. Lowering spends no coins and does not change
# the gonfalon dipped count, the furled count, the presented count, or any
# earlier count. The lowered total still counts a hire who was later housed.
func get_oriflamme_lowered() -> int:
	return _sum(_oriflamme) + _sum(_vexillum) + _sum(_labarum) + _sum(_signum) + _sum(_streamer)


# Hires who were lowered on an oriflamme and have not been housed. The vexillum houses these one at a time.
func get_oriflamme_left() -> int:
	return _sum(_oriflamme)


# Hires housed on a vexillum, at most VEXILLUM_CAP, including hires later
# cased on a labarum. Nothing is rolled. The oriflamme lowered total and the
# hire total still count these. Housing spends no coins and does not change
# the lowered count, the gonfalon dipped count, the furled count, the presented
# count, or any earlier count. The housed total still counts a hire who was later cased.
func get_vexillum_housed() -> int:
	return _sum(_vexillum) + _sum(_labarum) + _sum(_signum) + _sum(_streamer)


# Hires who were housed on a vexillum and have not been cased. The labarum cases these one at a time.
func get_vexillum_left() -> int:
	return _sum(_vexillum)


# Hires cased on a labarum, at most LABARUM_CAP, including hires later sleeved
# on a signum. Nothing is rolled. The vexillum housed total and the hire total
# still count these. Casing spends no coins and does not change the housed
# count, the lowered count, or any earlier count. The cased total still counts
# a hire who was later sleeved.
func get_labarum_cased() -> int:
	return _sum(_labarum) + _sum(_signum) + _sum(_streamer)


# Hires who were cased on a labarum and have not been sleeved. The signum sleeves these one at a time.
func get_labarum_left() -> int:
	return _sum(_labarum)


# Hires sleeved on a signum, at most SIGNUM_CAP, including hires later rolled
# on a streamer. Nothing is rolled. The labarum cased total and the hire total
# still count these. Sleeving spends no coins and does not change the cased
# count, the housed count, or any earlier count. The sleeved total still counts
# a hire who was later rolled.
func get_signum_sleeved() -> int:
	return _sum(_signum) + _sum(_streamer)


# Hires who were sleeved on a signum and have not been rolled. The streamer rolls these one at a time.
func get_signum_left() -> int:
	return _sum(_signum)


# Hires rolled on a streamer, at most STREAMER_CAP. Nothing is rolled. The signum
# sleeved total and the hire total still count these. Rolling spends no coins and
# does not change the sleeved count, the cased count, or any earlier count.
func get_streamer_rolled() -> int:
	return _sum(_streamer)


func _hired_coins() -> int:
	return get_hired() * HIRE_COST


func _wage_coins() -> int:
	return get_paid() * WAGE_COST


func get_bank_left() -> int:
	return _ledger + _sum(_covered)


func get_population() -> int:
	return _workers.size()


func get_max_population() -> int:
	return _max_population


func get_pop_cap_violations() -> int:
	return _pop_cap_violations


func get_uncovered_destroyed() -> int:
	return _uncovered_destroyed


func get_summary() -> String:
	return _summary


func get_ticks_until_rain() -> int:
	if _rain_done:
		return 0
	var horizon := RAIN_TICK
	if _phase == DRY:
		horizon = RAIN_TICK + DRY_TICK
	elif _phase == CART:
		horizon = RAIN_TICK + DRY_TICK + CART_TICK
	elif _phase == SHIPPING:
		horizon = RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK
	elif _phase == MARKET:
		horizon = RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK
	elif _phase == YARDING:
		horizon = RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK
	elif _phase == BUNKING:
		horizon = RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK
	elif _phase == LOFTING:
		horizon = RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK
	elif _phase == GATING:
		horizon = RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK
	elif _phase == WAGING:
		horizon = RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK
	elif _phase == RELIEVING:
		horizon = RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK
	elif _phase == WATCHING:
		horizon = RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK
	elif _phase == LAMPING:
		horizon = RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK
	elif _phase == BELLING:
		horizon = RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK
	elif _phase == HORNING:
		horizon = RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK
	elif _phase == FLAGGING:
		horizon = RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK
	elif _phase == BANNERING:
		horizon = RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK
	elif _phase == PENNANTING:
		horizon = RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK
	elif _phase == STANDARDING:
		horizon = RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK
	elif _phase == JACKING:
		horizon = RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK
	elif _phase == ENSIGNING:
		horizon = RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK + ENSIGN_TICK
	elif _phase == BURGEEING:
		horizon = RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK + ENSIGN_TICK + BURGEE_TICK
	elif _phase == CORNETING:
		horizon = RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK + ENSIGN_TICK + BURGEE_TICK + CORNET_TICK
	elif _phase == GUIDONING:
		horizon = RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK + ENSIGN_TICK + BURGEE_TICK + CORNET_TICK + GUIDON_TICK
	elif _phase == FANIONING:
		horizon = RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK + ENSIGN_TICK + BURGEE_TICK + CORNET_TICK + GUIDON_TICK + FANION_TICK
	elif _phase == PENNONING:
		horizon = RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK + ENSIGN_TICK + BURGEE_TICK + CORNET_TICK + GUIDON_TICK + FANION_TICK + PENNON_TICK
	elif _phase == GONFALONING:
		horizon = RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK + ENSIGN_TICK + BURGEE_TICK + CORNET_TICK + GUIDON_TICK + FANION_TICK + PENNON_TICK + GONFALON_TICK
	elif _phase == STREAMERING:
		horizon = RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK + ENSIGN_TICK + BURGEE_TICK + CORNET_TICK + GUIDON_TICK + FANION_TICK + PENNON_TICK + GONFALON_TICK + ORIFLAMME_TICK + VEXILLUM_TICK + LABARUM_TICK + SIGNUM_TICK + STREAMER_TICK
	elif _phase == SIGNUMING:
		horizon = RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK + ENSIGN_TICK + BURGEE_TICK + CORNET_TICK + GUIDON_TICK + FANION_TICK + PENNON_TICK + GONFALON_TICK + ORIFLAMME_TICK + VEXILLUM_TICK + LABARUM_TICK + SIGNUM_TICK
	elif _phase == LABARUMING:
		horizon = RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK + ENSIGN_TICK + BURGEE_TICK + CORNET_TICK + GUIDON_TICK + FANION_TICK + PENNON_TICK + GONFALON_TICK + ORIFLAMME_TICK + VEXILLUM_TICK + LABARUM_TICK
	elif _phase == VEXILLUMING:
		horizon = RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK + ENSIGN_TICK + BURGEE_TICK + CORNET_TICK + GUIDON_TICK + FANION_TICK + PENNON_TICK + GONFALON_TICK + ORIFLAMME_TICK + VEXILLUM_TICK
	elif _phase == ORIFLAMMING:
		horizon = RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + HORN_TICK + FLAG_TICK + BANNER_TICK + PENNANT_TICK + STANDARD_TICK + JACK_TICK + ENSIGN_TICK + BURGEE_TICK + CORNET_TICK + GUIDON_TICK + FANION_TICK + PENNON_TICK + GONFALON_TICK + ORIFLAMME_TICK
	return maxi(horizon - _tick_index, 0)


func is_over() -> bool:
	return _rain_done


func get_anthill() -> Vector2i:
	return ANTHILL


func get_cell_salt(x: int, y: int) -> Dictionary:
	var cell := Vector2i(x, y)
	return {
		"loose": _amount(_loose, cell),
		"stacked": _amount(_stacked, cell),
		"covered": _amount(_covered, cell),
		"crib": _amount(_crib, cell),
		"ship": _amount(_ship, cell),
		"stall": _amount(_stall, cell),
		"yard": _amount(_yard, cell),
		"bunk": _amount(_bunk, cell),
		"loft": _amount(_loft, cell),
		"gate": _amount(_gate, cell),
		"wage": _amount(_wage, cell),
		"relief": _amount(_relief, cell),
		"watch": _amount(_watch, cell),
		"lamp": _amount(_lamp, cell),
		"bell": _amount(_bell, cell),
		"horn": _amount(_horn, cell),
		"flag": _amount(_flag, cell),
		"banner": _amount(_banner, cell),
		"pennant": _amount(_pennant, cell),
		"standard": _amount(_standard, cell),
		"jack": _amount(_jack, cell),
		"ensign": _amount(_ensign, cell),
		"burgee": _amount(_burgee, cell),
		"cornet": _amount(_cornet, cell),
		"guidon": _amount(_guidon, cell),
		"fanion": _amount(_fanion, cell),
		"pennon": _amount(_pennon, cell),
		"gonfalon": _amount(_gonfalon, cell),
		"oriflamme": _amount(_oriflamme, cell),
		"vexillum": _amount(_vexillum, cell),
		"labarum": _amount(_labarum, cell),
		"signum": _amount(_signum, cell),
		"streamer": _amount(_streamer, cell),
	}


# Positions for drawing. This does not select a worker.
func get_ant_draw_positions() -> Array:
	var out: Array = []
	for worker in _workers:
		out.append({
			"id": int(worker.id),
			"x": int(worker.x),
			"y": int(worker.y),
			"job": int(worker.job),
		})
	return out


func rules_api() -> PackedStringArray:
	return PackedStringArray([
		"restart",
		"paint_cell",
		"get_paint",
		"tick",
		"run_until_rain",
		"get_stored_salt",
		"get_loose_salt",
		"get_stacked_salt",
		"get_wet_haul",
		"get_season",
		"get_beat",
		"get_carted",
		"get_crib_salt",
		"get_shipped",
		"get_ship_salt",
		"get_coins",
		"get_purse",
		"get_banked",
		"get_yard_left",
		"get_hired",
		"get_bunk_left",
		"get_lofted",
		"get_loft_left",
		"get_gated",
		"get_gate_left",
		"get_paid",
		"get_wage_left",
		"get_posted",
		"get_relief_left",
		"get_stood",
		"get_watch_left",
		"get_lit",
		"get_lamp_left",
		"get_rung",
		"get_bell_left",
		"get_sounded",
		"get_horn_left",
		"get_raised",
		"get_flag_left",
		"get_hoisted",
		"get_banner_left",
		"get_flown",
		"get_pennant_left",
		"get_carried",
		"get_standard_left",
		"get_shown",
		"get_jack_left",
		"get_broken",
		"get_ensign_left",
		"get_struck",
		"get_burgee_left",
		"get_dipped",
		"get_cornet_left",
		"get_saluted",
		"get_guidon_left",
		"get_presented",
		"get_fanion_left",
		"get_furled",
		"get_pennon_left",
		"get_gonfalon_dipped",
		"get_gonfalon_left",
		"get_oriflamme_lowered",
		"get_oriflamme_left",
		"get_vexillum_housed",
		"get_vexillum_left",
		"get_labarum_cased",
		"get_labarum_left",
		"get_signum_sleeved",
		"get_signum_left",
		"get_streamer_rolled",
		"get_bank_left",
		"get_population",
		"get_max_population",
		"get_pop_cap_violations",
		"get_uncovered_destroyed",
		"get_summary",
		"get_ticks_until_rain",
		"is_over",
		"get_anthill",
		"get_cell_salt",
		"get_ant_draw_positions",
		"rules_api",
	])


func _add_worker() -> void:
	if _workers.size() >= POP_CAP:
		return
	var worker := Worker.new()
	worker.id = _next_id
	worker.x = ANTHILL.x
	worker.y = ANTHILL.y
	worker.job = _next_id % 3
	_next_id += 1
	_workers.append(worker)
	if _workers.size() > _max_population:
		_max_population = _workers.size()


func _maybe_spawn() -> void:
	if _tick_index <= 0:
		return
	if _tick_index % SPAWN_EVERY != 0:
		return
	_add_worker()


func _paintable(x: int, y: int) -> bool:
	if x <= COAST_X or x >= GRID_W or y < GRID_NORTH or y >= GRID_H:
		return false
	if Vector2i(x, y) == ANTHILL:
		return false
	return true


func _walkable(x: int, y: int) -> bool:
	if x < 0 or y < GRID_NORTH or x >= GRID_W or y >= GRID_H:
		return false
	if x == COAST_X:
		return false
	if Vector2i(x, y) == ANTHILL:
		return true
	var paint := _paint_at(Vector2i(x, y))
	if paint == EMPTY:
		return false
	# A crib stays shut until the cart beat, a ship stays shut until the ship
	# beat, a stall stays shut until the market beat, a yard stays shut until
	# the yard beat, a bunk stays shut until the bunk beat, a loft stays shut
	# until the loft beat, a gate stays shut until the gate beat, a wage
	# stays shut until the wage beat, a relief stays shut until the relief
	# beat, a watch stays shut until the watch beat, and a lamp stays shut
	# until the lamp beat, and a bell stays shut until the bell beat, and a
	# horn stays shut until the horn beat, a flag stays shut until the
	# flag beat, a banner stays shut until the banner beat, a pennant
	# stays shut until the pennant beat, a standard stays shut until the
	# standard beat, a jack stays shut until the jack beat, an ensign
	# stays shut until the ensign beat, a burgee stays shut until the
	# burgee beat, a cornet stays shut until the
	# cornet beat, a guidon stays shut until the
	# guidon beat, and a fanion stays shut until the
	# fanion beat, so none of
	# them can shortcut an earlier haul. Each stays
	# open afterward so workers can walk the coins, the hires, the crew, the
	# pay, the posting, the standing, the lighting, the ringing, the sounding,
	# the raising, the hoisting, the flying, the carrying, the showing, the breaking, the striking, the dipping, the saluting, and then the presenting forward.
	# Phase numbers increase in that order, so a mark is open from its own beat on.
	if paint == CRIB and _phase < CART:
		return false
	if paint == SHIP and _phase < SHIPPING:
		return false
	if paint == STALL and _phase < MARKET:
		return false
	if paint == YARD and _phase < YARDING:
		return false
	if paint == BUNK and _phase < BUNKING:
		return false
	if paint == LOFT and _phase < LOFTING:
		return false
	if paint == GATE and _phase < GATING:
		return false
	if paint == WAGE and _phase < WAGING:
		return false
	if paint == RELIEF and _phase < RELIEVING:
		return false
	if paint == WATCH and _phase < WATCHING:
		return false
	if paint == LAMP and _phase < LAMPING:
		return false
	if paint == BELL and _phase < BELLING:
		return false
	if paint == HORN and _phase < HORNING:
		return false
	if paint == FLAG and _phase < FLAGGING:
		return false
	if paint == BANNER and _phase < BANNERING:
		return false
	if paint == PENNANT and _phase < PENNANTING:
		return false
	if paint == STANDARD and _phase < STANDARDING:
		return false
	if paint == JACK and _phase < JACKING:
		return false
	if paint == ENSIGN and _phase < ENSIGNING:
		return false
	if paint == BURGEE and _phase < BURGEEING:
		return false
	if paint == CORNET and _phase < CORNETING:
		return false
	if paint == GUIDON and _phase < GUIDONING:
		return false
	if paint == FANION and _phase < FANIONING:
		return false
	if paint == PENNON and _phase < PENNONING:
		return false
	if paint == GONFALON and _phase < GONFALONING:
		return false
	if paint == ORIFLAMME and _phase < ORIFLAMMING:
		return false
	if paint == VEXILLUM and _phase < VEXILLUMING:
		return false
	if paint == LABARUM and _phase < LABARUMING:
		return false
	if paint == SIGNUM and _phase < SIGNUMING:
		return false
	if paint == STREAMER and _phase < STREAMERING:
		return false
	return true


func _paint_at(cell: Vector2i) -> int:
	return int(_paint.get(cell, EMPTY))


func _amount(store: Dictionary, cell: Vector2i) -> int:
	return int(store.get(cell, 0))


func _sum(store: Dictionary) -> int:
	var total := 0
	for value in store.values():
		total += int(value)
	return total


func _put(store: Dictionary, cell: Vector2i, amount: int) -> void:
	if amount <= 0:
		store.erase(cell)
	else:
		store[cell] = amount


func _covered_on_map() -> int:
	var total := 0
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _paint_at(cell) == COVER:
				total += _amount(_covered, cell) + _amount(_stacked, cell)
	return total


func _brine_adjacent(cell: Vector2i) -> bool:
	return cell.x == COAST_X + 1 and cell.y >= GRID_NORTH and cell.y < GRID_H


func _flows() -> Dictionary:
	if _phase == CART:
		var carting := _build_flow(_crib_goals())
		return {
			JOB_GATHER: carting,
			JOB_STACK: carting,
			JOB_COVER: carting,
		}
	if _phase == SHIPPING:
		var loading := _build_flow(_ship_goals())
		return {
			JOB_GATHER: loading,
			JOB_STACK: loading,
			JOB_COVER: loading,
		}
	if _phase == MARKET:
		var selling := _build_flow(_stall_goals())
		return {
			JOB_GATHER: selling,
			JOB_STACK: selling,
			JOB_COVER: selling,
		}
	if _phase == YARDING:
		var banking := _build_flow(_yard_goals())
		return {
			JOB_GATHER: banking,
			JOB_STACK: banking,
			JOB_COVER: banking,
		}
	if _phase == BUNKING:
		var hiring := _build_flow(_bunk_goals())
		return {
			JOB_GATHER: hiring,
			JOB_STACK: hiring,
			JOB_COVER: hiring,
		}
	if _phase == LOFTING:
		var lofting := _build_flow(_loft_goals())
		return {
			JOB_GATHER: lofting,
			JOB_STACK: lofting,
			JOB_COVER: lofting,
		}
	if _phase == GATING:
		var passing := _build_flow(_gate_goals())
		return {
			JOB_GATHER: passing,
			JOB_STACK: passing,
			JOB_COVER: passing,
		}
	if _phase == WAGING:
		var paying := _build_flow(_wage_goals())
		return {
			JOB_GATHER: paying,
			JOB_STACK: paying,
			JOB_COVER: paying,
		}
	if _phase == RELIEVING:
		var posting := _build_flow(_relief_goals())
		return {
			JOB_GATHER: posting,
			JOB_STACK: posting,
			JOB_COVER: posting,
		}
	if _phase == WATCHING:
		var standing := _build_flow(_watch_goals())
		return {
			JOB_GATHER: standing,
			JOB_STACK: standing,
			JOB_COVER: standing,
		}
	if _phase == LAMPING:
		var lighting := _build_flow(_lamp_goals())
		return {
			JOB_GATHER: lighting,
			JOB_STACK: lighting,
			JOB_COVER: lighting,
		}
	if _phase == BELLING:
		var ringing := _build_flow(_bell_goals())
		return {
			JOB_GATHER: ringing,
			JOB_STACK: ringing,
			JOB_COVER: ringing,
		}
	if _phase == HORNING:
		var sounding := _build_flow(_horn_goals())
		return {
			JOB_GATHER: sounding,
			JOB_STACK: sounding,
			JOB_COVER: sounding,
		}
	if _phase == FLAGGING:
		var raising := _build_flow(_flag_goals())
		return {
			JOB_GATHER: raising,
			JOB_STACK: raising,
			JOB_COVER: raising,
		}
	if _phase == BANNERING:
		var hoisting := _build_flow(_banner_goals())
		return {
			JOB_GATHER: hoisting,
			JOB_STACK: hoisting,
			JOB_COVER: hoisting,
		}
	if _phase == PENNANTING:
		var flying := _build_flow(_pennant_goals())
		return {
			JOB_GATHER: flying,
			JOB_STACK: flying,
			JOB_COVER: flying,
		}
	if _phase == STANDARDING:
		var carrying := _build_flow(_standard_goals())
		return {
			JOB_GATHER: carrying,
			JOB_STACK: carrying,
			JOB_COVER: carrying,
		}
	if _phase == JACKING:
		var showing := _build_flow(_jack_goals())
		return {
			JOB_GATHER: showing,
			JOB_STACK: showing,
			JOB_COVER: showing,
		}
	if _phase == ENSIGNING:
		var breaking := _build_flow(_ensign_goals())
		return {
			JOB_GATHER: breaking,
			JOB_STACK: breaking,
			JOB_COVER: breaking,
		}
	if _phase == BURGEEING:
		var striking := _build_flow(_burgee_goals())
		return {
			JOB_GATHER: striking,
			JOB_STACK: striking,
			JOB_COVER: striking,
		}
	if _phase == CORNETING:
		var dipping := _build_flow(_cornet_goals())
		return {
			JOB_GATHER: dipping,
			JOB_STACK: dipping,
			JOB_COVER: dipping,
		}
	if _phase == GUIDONING:
		var saluting := _build_flow(_guidon_goals())
		return {
			JOB_GATHER: saluting,
			JOB_STACK: saluting,
			JOB_COVER: saluting,
		}
	if _phase == FANIONING:
		var presenting := _build_flow(_fanion_goals())
		return {
			JOB_GATHER: presenting,
			JOB_STACK: presenting,
			JOB_COVER: presenting,
		}
	if _phase == PENNONING:
		var furling := _build_flow(_pennon_goals())
		return {
			JOB_GATHER: furling,
			JOB_STACK: furling,
			JOB_COVER: furling,
		}
	if _phase == GONFALONING:
		var dipping := _build_flow(_gonfalon_goals())
		return {
			JOB_GATHER: dipping,
			JOB_STACK: dipping,
			JOB_COVER: dipping,
		}
	if _phase == STREAMERING:
		var rolling := _build_flow(_streamer_goals())
		return {
			JOB_GATHER: rolling,
			JOB_STACK: rolling,
			JOB_COVER: rolling,
		}
	if _phase == SIGNUMING:
		var sleeving := _build_flow(_signum_goals())
		return {
			JOB_GATHER: sleeving,
			JOB_STACK: sleeving,
			JOB_COVER: sleeving,
		}
	if _phase == LABARUMING:
		var casing := _build_flow(_labarum_goals())
		return {
			JOB_GATHER: casing,
			JOB_STACK: casing,
			JOB_COVER: casing,
		}
	if _phase == VEXILLUMING:
		var housing := _build_flow(_vexillum_goals())
		return {
			JOB_GATHER: housing,
			JOB_STACK: housing,
			JOB_COVER: housing,
		}
	if _phase == ORIFLAMMING:
		var lowering := _build_flow(_oriflamme_goals())
		return {
			JOB_GATHER: lowering,
			JOB_STACK: lowering,
			JOB_COVER: lowering,
		}
	return {
		JOB_GATHER: _build_flow(_gather_goals()),
		JOB_STACK: _build_flow(_stack_goals()),
		JOB_COVER: _build_flow(_cover_goals()),
	}


func _gather_goals() -> Array:
	var goals: Array = []
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _phase == DRY:
				if _paint_at(cell) != PAN:
					continue
			elif _phase == WET:
				if _paint_at(cell) != RAKE or not _brine_adjacent(cell):
					continue
			else:
				continue
			if _amount(_loose, cell) >= LOOSE_CAP:
				continue
			goals.append(cell)
	return goals


func _crib_goals() -> Array:
	var goals: Array = []
	if get_bank_left() <= 0:
		return goals
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _paint_at(cell) != CRIB:
				continue
			if _amount(_crib, cell) >= CRIB_CAP:
				continue
			goals.append(cell)
	return goals


func _ship_goals() -> Array:
	var goals: Array = []
	if _sum(_crib) <= 0:
		return goals
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _paint_at(cell) != SHIP:
				continue
			if _amount(_ship, cell) >= SHIP_CAP:
				continue
			goals.append(cell)
	return goals


func _stall_goals() -> Array:
	var goals: Array = []
	if _sum(_ship) <= 0:
		return goals
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _paint_at(cell) != STALL:
				continue
			if _amount(_stall, cell) >= STALL_CAP:
				continue
			goals.append(cell)
	return goals


func _yard_goals() -> Array:
	var goals: Array = []
	if get_purse() <= 0:
		return goals
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _paint_at(cell) != YARD:
				continue
			if _amount(_yard, cell) >= YARD_CAP:
				continue
			goals.append(cell)
	return goals


func _bunk_goals() -> Array:
	var goals: Array = []
	if get_yard_left() < HIRE_COST:
		return goals
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _paint_at(cell) != BUNK:
				continue
			if _amount(_bunk, cell) >= BUNK_CAP:
				continue
			goals.append(cell)
	return goals


func _loft_goals() -> Array:
	var goals: Array = []
	if get_bunk_left() <= 0:
		return goals
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _paint_at(cell) != LOFT:
				continue
			if _amount(_loft, cell) >= LOFT_CAP:
				continue
			goals.append(cell)
	return goals


func _gate_goals() -> Array:
	var goals: Array = []
	if get_gated() >= GATE_CAP or get_loft_left() <= 0:
		return goals
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _paint_at(cell) != GATE:
				continue
			if _amount(_gate, cell) >= GATE_CAP:
				continue
			goals.append(cell)
	return goals


func _wage_goals() -> Array:
	var goals: Array = []
	if get_yard_left() < WAGE_COST or get_gate_left() <= 0:
		return goals
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _paint_at(cell) != WAGE:
				continue
			if _amount(_wage, cell) >= WAGE_CAP:
				continue
			goals.append(cell)
	return goals


func _relief_goals() -> Array:
	var goals: Array = []
	if get_posted() >= RELIEF_CAP or get_wage_left() <= 0:
		return goals
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _paint_at(cell) != RELIEF:
				continue
			if _amount(_relief, cell) >= RELIEF_CAP:
				continue
			goals.append(cell)
	return goals


func _watch_goals() -> Array:
	var goals: Array = []
	if get_stood() >= WATCH_CAP or get_relief_left() <= 0:
		return goals
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _paint_at(cell) != WATCH:
				continue
			if _amount(_watch, cell) >= WATCH_CAP:
				continue
			goals.append(cell)
	return goals


func _bell_goals() -> Array:
	var goals: Array = []
	if get_rung() >= BELL_CAP or get_lamp_left() <= 0:
		return goals
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _paint_at(cell) != BELL:
				continue
			if _amount(_bell, cell) >= BELL_CAP:
				continue
			goals.append(cell)
	return goals


func _horn_goals() -> Array:
	var goals: Array = []
	if get_sounded() >= HORN_CAP or get_bell_left() <= 0:
		return goals
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _paint_at(cell) != HORN:
				continue
			if _amount(_horn, cell) >= HORN_CAP:
				continue
			goals.append(cell)
	return goals


func _flag_goals() -> Array:
	var goals: Array = []
	if get_raised() >= FLAG_CAP or get_horn_left() <= 0:
		return goals
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _paint_at(cell) != FLAG:
				continue
			if _amount(_flag, cell) >= FLAG_CAP:
				continue
			goals.append(cell)
	return goals


func _banner_goals() -> Array:
	var goals: Array = []
	if get_hoisted() >= BANNER_CAP or get_flag_left() <= 0:
		return goals
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _paint_at(cell) != BANNER:
				continue
			if _amount(_banner, cell) >= BANNER_CAP:
				continue
			goals.append(cell)
	return goals


func _pennant_goals() -> Array:
	var goals: Array = []
	if get_flown() >= PENNANT_CAP or get_banner_left() <= 0:
		return goals
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _paint_at(cell) != PENNANT:
				continue
			if _amount(_pennant, cell) >= PENNANT_CAP:
				continue
			goals.append(cell)
	return goals


func _standard_goals() -> Array:
	var goals: Array = []
	if get_carried() >= STANDARD_CAP or get_pennant_left() <= 0:
		return goals
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _paint_at(cell) != STANDARD:
				continue
			if _amount(_standard, cell) >= STANDARD_CAP:
				continue
			goals.append(cell)
	return goals


func _jack_goals() -> Array:
	var goals: Array = []
	if get_shown() >= JACK_CAP or get_standard_left() <= 0:
		return goals
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _paint_at(cell) != JACK:
				continue
			if _amount(_jack, cell) >= JACK_CAP:
				continue
			goals.append(cell)
	return goals


func _ensign_goals() -> Array:
	var goals: Array = []
	if get_broken() >= ENSIGN_CAP or get_jack_left() <= 0:
		return goals
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _paint_at(cell) != ENSIGN:
				continue
			if _amount(_ensign, cell) >= ENSIGN_CAP:
				continue
			goals.append(cell)
	return goals


func _burgee_goals() -> Array:
	var goals: Array = []
	if get_struck() >= BURGEE_CAP or get_ensign_left() <= 0:
		return goals
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _paint_at(cell) != BURGEE:
				continue
			if _amount(_burgee, cell) >= BURGEE_CAP:
				continue
			goals.append(cell)
	return goals


func _cornet_goals() -> Array:
	var goals: Array = []
	if get_dipped() >= CORNET_CAP or get_burgee_left() <= 0:
		return goals
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _paint_at(cell) != CORNET:
				continue
			if _amount(_cornet, cell) >= CORNET_CAP:
				continue
			goals.append(cell)
	return goals


func _guidon_goals() -> Array:
	var goals: Array = []
	if get_saluted() >= GUIDON_CAP or get_cornet_left() <= 0:
		return goals
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _paint_at(cell) != GUIDON:
				continue
			if _amount(_guidon, cell) >= GUIDON_CAP:
				continue
			goals.append(cell)
	return goals


func _fanion_goals() -> Array:
	var goals: Array = []
	if get_presented() >= FANION_CAP or get_guidon_left() <= 0:
		return goals
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _paint_at(cell) != FANION:
				continue
			if _amount(_fanion, cell) >= FANION_CAP:
				continue
			goals.append(cell)
	return goals


func _streamer_goals() -> Array:
	var goals: Array = []
	if get_streamer_rolled() >= STREAMER_CAP or get_signum_left() <= 0:
		return goals
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _paint_at(cell) != STREAMER:
				continue
			if _amount(_streamer, cell) >= STREAMER_CAP:
				continue
			goals.append(cell)
	return goals


func _signum_goals() -> Array:
	var goals: Array = []
	if get_signum_sleeved() >= SIGNUM_CAP or get_labarum_left() <= 0:
		return goals
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _paint_at(cell) != SIGNUM:
				continue
			if _amount(_signum, cell) >= SIGNUM_CAP:
				continue
			goals.append(cell)
	return goals


func _labarum_goals() -> Array:
	var goals: Array = []
	if get_labarum_cased() >= LABARUM_CAP or get_vexillum_left() <= 0:
		return goals
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _paint_at(cell) != LABARUM:
				continue
			if _amount(_labarum, cell) >= LABARUM_CAP:
				continue
			goals.append(cell)
	return goals


func _vexillum_goals() -> Array:
	var goals: Array = []
	if get_vexillum_housed() >= VEXILLUM_CAP or get_oriflamme_left() <= 0:
		return goals
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _paint_at(cell) != VEXILLUM:
				continue
			if _amount(_vexillum, cell) >= VEXILLUM_CAP:
				continue
			goals.append(cell)
	return goals


func _oriflamme_goals() -> Array:
	var goals: Array = []
	if get_oriflamme_lowered() >= ORIFLAMME_CAP or get_gonfalon_left() <= 0:
		return goals
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _paint_at(cell) != ORIFLAMME:
				continue
			if _amount(_oriflamme, cell) >= ORIFLAMME_CAP:
				continue
			goals.append(cell)
	return goals


func _gonfalon_goals() -> Array:
	var goals: Array = []
	if get_gonfalon_dipped() >= GONFALON_CAP or get_pennon_left() <= 0:
		return goals
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _paint_at(cell) != GONFALON:
				continue
			if _amount(_gonfalon, cell) >= GONFALON_CAP:
				continue
			goals.append(cell)
	return goals


func _pennon_goals() -> Array:
	var goals: Array = []
	if get_furled() >= PENNON_CAP or get_fanion_left() <= 0:
		return goals
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _paint_at(cell) != PENNON:
				continue
			if _amount(_pennon, cell) >= PENNON_CAP:
				continue
			goals.append(cell)
	return goals


func _lamp_goals() -> Array:
	var goals: Array = []
	if get_lit() >= LAMP_CAP or get_watch_left() <= 0:
		return goals
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _paint_at(cell) != LAMP:
				continue
			if _amount(_lamp, cell) >= LAMP_CAP:
				continue
			goals.append(cell)
	return goals


func _stack_goals() -> Array:
	var goals: Array = []
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _paint_at(cell) != STACK:
				continue
			if _amount(_stacked, cell) >= STACK_CAP:
				continue
			if _best_loose_neighbor(cell).x < 0:
				continue
			goals.append(cell)
	return goals


func _cover_goals() -> Array:
	var goals: Array = []
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var cell := Vector2i(x, y)
			if _paint_at(cell) != COVER:
				continue
			if _amount(_covered, cell) >= COVER_CAP:
				continue
			if _best_stack_neighbor(cell).x < 0:
				continue
			goals.append(cell)
	return goals


func _build_flow(goals: Array) -> Dictionary:
	var flow: Dictionary = {}
	var queue: Array = []
	for goal in goals:
		var cell: Vector2i = goal
		if flow.has(cell):
			continue
		if not _walkable(cell.x, cell.y):
			continue
		flow[cell] = cell
		queue.append(cell)
	var head := 0
	while head < queue.size():
		var current: Vector2i = queue[head]
		head += 1
		for direction in DIRS:
			var nxt: Vector2i = current + direction
			if flow.has(nxt):
				continue
			if not _walkable(nxt.x, nxt.y):
				continue
			flow[nxt] = current
			queue.append(nxt)
	return flow


func _act(worker: Worker, flow: Dictionary) -> void:
	if not _walkable(worker.x, worker.y):
		_step_stranded(worker)
		return
	var pos := Vector2i(worker.x, worker.y)
	if not flow.has(pos):
		return
	var nxt: Vector2i = flow[pos]
	if nxt == pos:
		_work(worker)
	else:
		worker.x = nxt.x
		worker.y = nxt.y


func _step_stranded(worker: Worker) -> void:
	for direction in DIRS:
		var nxt: Vector2i = Vector2i(worker.x, worker.y) + direction
		if _walkable(nxt.x, nxt.y):
			worker.x = nxt.x
			worker.y = nxt.y
			return


func _work(worker: Worker) -> void:
	if _phase == CART:
		_cart(worker)
		return
	if _phase == SHIPPING:
		_load_ship(worker)
		return
	if _phase == MARKET:
		_sell(worker)
		return
	if _phase == YARDING:
		_bank(worker)
		return
	if _phase == BUNKING:
		_hire(worker)
		return
	if _phase == LOFTING:
		_loft_hire(worker)
		return
	if _phase == GATING:
		_pass_gate(worker)
		return
	if _phase == WAGING:
		_pay_wage(worker)
		return
	if _phase == RELIEVING:
		_post_relief(worker)
		return
	if _phase == WATCHING:
		_stand_watch(worker)
		return
	if _phase == LAMPING:
		_light_lamp(worker)
		return
	if _phase == BELLING:
		_ring_bell(worker)
		return
	if _phase == HORNING:
		_sound_horn(worker)
		return
	if _phase == FLAGGING:
		_raise_flag(worker)
		return
	if _phase == BANNERING:
		_hoist_banner(worker)
		return
	if _phase == PENNANTING:
		_fly_pennant(worker)
		return
	if _phase == STANDARDING:
		_carry_standard(worker)
		return
	if _phase == JACKING:
		_show_jack(worker)
		return
	if _phase == ENSIGNING:
		_break_ensign(worker)
		return
	if _phase == BURGEEING:
		_strike_burgee(worker)
		return
	if _phase == CORNETING:
		_dip_cornet(worker)
		return
	if _phase == GUIDONING:
		_salute_guidon(worker)
		return
	if _phase == FANIONING:
		_present_fanion(worker)
		return
	if _phase == PENNONING:
		_furl_pennon(worker)
		return
	if _phase == GONFALONING:
		_dip_gonfalon(worker)
		return
	if _phase == STREAMERING:
		_roll_streamer(worker)
		return
	if _phase == SIGNUMING:
		_sleeve_signum(worker)
		return
	if _phase == LABARUMING:
		_case_labarum(worker)
		return
	if _phase == VEXILLUMING:
		_house_vexillum(worker)
		return
	if _phase == ORIFLAMMING:
		_lower_oriflamme(worker)
		return
	var cell := Vector2i(worker.x, worker.y)
	if worker.job == JOB_GATHER:
		if _phase == DRY:
			if _paint_at(cell) != PAN:
				return
		elif _phase != WET or _paint_at(cell) != RAKE or not _brine_adjacent(cell):
			return
		var loose := _amount(_loose, cell)
		if loose >= LOOSE_CAP:
			return
		_put(_loose, cell, loose + 1)
	elif worker.job == JOB_STACK:
		if _paint_at(cell) != STACK:
			return
		var stacked := _amount(_stacked, cell)
		if stacked >= STACK_CAP:
			return
		var src := _best_loose_neighbor(cell)
		if src.x < 0:
			return
		_put(_loose, src, _amount(_loose, src) - 1)
		_put(_stacked, cell, stacked + 1)
	elif worker.job == JOB_COVER:
		if _paint_at(cell) != COVER:
			return
		var covered := _amount(_covered, cell)
		if covered >= COVER_CAP:
			return
		var src := _best_stack_neighbor(cell)
		if src.x < 0:
			return
		_put(_stacked, src, _amount(_stacked, src) - 1)
		_put(_covered, cell, covered + 1)


func _cart(worker: Worker) -> void:
	var cell := Vector2i(worker.x, worker.y)
	if _paint_at(cell) != CRIB:
		return
	var held := _amount(_crib, cell)
	if held >= CRIB_CAP:
		return
	if _ledger > 0:
		_ledger -= 1
		_put(_crib, cell, held + 1)
		return
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var src := Vector2i(x, y)
			var amount := _amount(_covered, src)
			if amount <= 0:
				continue
			_put(_covered, src, amount - 1)
			_put(_crib, cell, held + 1)
			return


func _load_ship(worker: Worker) -> void:
	var cell := Vector2i(worker.x, worker.y)
	if _paint_at(cell) != SHIP:
		return
	var held := _amount(_ship, cell)
	if held >= SHIP_CAP:
		return
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var src := Vector2i(x, y)
			var amount := _amount(_crib, src)
			if amount <= 0:
				continue
			_put(_crib, src, amount - 1)
			_put(_ship, cell, held + 1)
			return


func _sell(worker: Worker) -> void:
	var cell := Vector2i(worker.x, worker.y)
	if _paint_at(cell) != STALL:
		return
	var held := _amount(_stall, cell)
	if held >= STALL_CAP:
		return
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var src := Vector2i(x, y)
			var amount := _amount(_ship, src)
			if amount <= 0:
				continue
			_put(_ship, src, amount - 1)
			_put(_stall, cell, held + 1)
			return


func _bank(worker: Worker) -> void:
	var cell := Vector2i(worker.x, worker.y)
	if _paint_at(cell) != YARD:
		return
	var held := _amount(_yard, cell)
	if held >= YARD_CAP:
		return
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var src := Vector2i(x, y)
			var amount := _amount(_stall, src)
			if amount <= 0:
				continue
			_put(_stall, src, amount - 1)
			_put(_yard, cell, held + 1)
			return


func _hire(worker: Worker) -> void:
	var cell := Vector2i(worker.x, worker.y)
	if _paint_at(cell) != BUNK:
		return
	var held := _amount(_bunk, cell)
	if held >= BUNK_CAP:
		return
	if get_yard_left() < HIRE_COST:
		return
	var need := HIRE_COST
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var src := Vector2i(x, y)
			var amount := _amount(_yard, src)
			if amount <= 0:
				continue
			var take := mini(amount, need)
			_put(_yard, src, amount - take)
			need -= take
			if need == 0:
				_put(_bunk, cell, held + 1)
				return


func _loft_hire(worker: Worker) -> void:
	var cell := Vector2i(worker.x, worker.y)
	if _paint_at(cell) != LOFT:
		return
	var held := _amount(_loft, cell)
	if held >= LOFT_CAP:
		return
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var src := Vector2i(x, y)
			var amount := _amount(_bunk, src)
			if amount <= 0:
				continue
			_put(_bunk, src, amount - 1)
			_put(_loft, cell, held + 1)
			return


func _pass_gate(worker: Worker) -> void:
	var cell := Vector2i(worker.x, worker.y)
	if _paint_at(cell) != GATE:
		return
	if get_gated() >= GATE_CAP:
		return
	var held := _amount(_gate, cell)
	if held >= GATE_CAP:
		return
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var src := Vector2i(x, y)
			var amount := _amount(_loft, src)
			if amount <= 0:
				continue
			_put(_loft, src, amount - 1)
			_put(_gate, cell, held + 1)
			return


func _pay_wage(worker: Worker) -> void:
	var cell := Vector2i(worker.x, worker.y)
	if _paint_at(cell) != WAGE:
		return
	var held := _amount(_wage, cell)
	if held >= WAGE_CAP:
		return
	if get_yard_left() < WAGE_COST:
		return
	var src := Vector2i(-1, -1)
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var candidate := Vector2i(x, y)
			if _amount(_gate, candidate) <= 0:
				continue
			src = candidate
			break
		if src.x >= 0:
			break
	if src.x < 0:
		return
	var need := WAGE_COST
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var purse := Vector2i(x, y)
			var amount := _amount(_yard, purse)
			if amount <= 0:
				continue
			var take := mini(amount, need)
			_put(_yard, purse, amount - take)
			need -= take
			if need == 0:
				_put(_gate, src, _amount(_gate, src) - 1)
				_put(_wage, cell, held + 1)
				return


func _post_relief(worker: Worker) -> void:
	var cell := Vector2i(worker.x, worker.y)
	if _paint_at(cell) != RELIEF:
		return
	if get_posted() >= RELIEF_CAP:
		return
	var held := _amount(_relief, cell)
	if held >= RELIEF_CAP:
		return
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var src := Vector2i(x, y)
			var amount := _amount(_wage, src)
			if amount <= 0:
				continue
			_put(_wage, src, amount - 1)
			_put(_relief, cell, held + 1)
			return


func _stand_watch(worker: Worker) -> void:
	var cell := Vector2i(worker.x, worker.y)
	if _paint_at(cell) != WATCH:
		return
	if get_stood() >= WATCH_CAP:
		return
	var held := _amount(_watch, cell)
	if held >= WATCH_CAP:
		return
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var src := Vector2i(x, y)
			var amount := _amount(_relief, src)
			if amount <= 0:
				continue
			_put(_relief, src, amount - 1)
			_put(_watch, cell, held + 1)
			return


func _light_lamp(worker: Worker) -> void:
	var cell := Vector2i(worker.x, worker.y)
	if _paint_at(cell) != LAMP:
		return
	if get_lit() >= LAMP_CAP:
		return
	var held := _amount(_lamp, cell)
	if held >= LAMP_CAP:
		return
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var src := Vector2i(x, y)
			var amount := _amount(_watch, src)
			if amount <= 0:
				continue
			_put(_watch, src, amount - 1)
			_put(_lamp, cell, held + 1)
			return


func _ring_bell(worker: Worker) -> void:
	var cell := Vector2i(worker.x, worker.y)
	if _paint_at(cell) != BELL:
		return
	if get_rung() >= BELL_CAP:
		return
	var held := _amount(_bell, cell)
	if held >= BELL_CAP:
		return
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var src := Vector2i(x, y)
			var amount := _amount(_lamp, src)
			if amount <= 0:
				continue
			_put(_lamp, src, amount - 1)
			_put(_bell, cell, held + 1)
			return


func _sound_horn(worker: Worker) -> void:
	var cell := Vector2i(worker.x, worker.y)
	if _paint_at(cell) != HORN:
		return
	if get_sounded() >= HORN_CAP:
		return
	var held := _amount(_horn, cell)
	if held >= HORN_CAP:
		return
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var src := Vector2i(x, y)
			var amount := _amount(_bell, src)
			if amount <= 0:
				continue
			_put(_bell, src, amount - 1)
			_put(_horn, cell, held + 1)
			return


func _raise_flag(worker: Worker) -> void:
	var cell := Vector2i(worker.x, worker.y)
	if _paint_at(cell) != FLAG:
		return
	if get_raised() >= FLAG_CAP:
		return
	var held := _amount(_flag, cell)
	if held >= FLAG_CAP:
		return
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var src := Vector2i(x, y)
			var amount := _amount(_horn, src)
			if amount <= 0:
				continue
			_put(_horn, src, amount - 1)
			_put(_flag, cell, held + 1)
			return


func _hoist_banner(worker: Worker) -> void:
	var cell := Vector2i(worker.x, worker.y)
	if _paint_at(cell) != BANNER:
		return
	if get_hoisted() >= BANNER_CAP:
		return
	var held := _amount(_banner, cell)
	if held >= BANNER_CAP:
		return
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var src := Vector2i(x, y)
			var amount := _amount(_flag, src)
			if amount <= 0:
				continue
			_put(_flag, src, amount - 1)
			_put(_banner, cell, held + 1)
			return


func _roll_streamer(worker: Worker) -> void:
	var cell := Vector2i(worker.x, worker.y)
	if _paint_at(cell) != STREAMER:
		return
	if get_streamer_rolled() >= STREAMER_CAP:
		return
	var held := _amount(_streamer, cell)
	if held >= STREAMER_CAP:
		return
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var src := Vector2i(x, y)
			var amount := _amount(_signum, src)
			if amount <= 0:
				continue
			_put(_signum, src, amount - 1)
			_put(_streamer, cell, held + 1)
			return


func _sleeve_signum(worker: Worker) -> void:
	var cell := Vector2i(worker.x, worker.y)
	if _paint_at(cell) != SIGNUM:
		return
	if get_signum_sleeved() >= SIGNUM_CAP:
		return
	var held := _amount(_signum, cell)
	if held >= SIGNUM_CAP:
		return
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var src := Vector2i(x, y)
			var amount := _amount(_labarum, src)
			if amount <= 0:
				continue
			_put(_labarum, src, amount - 1)
			_put(_signum, cell, held + 1)
			return


func _case_labarum(worker: Worker) -> void:
	var cell := Vector2i(worker.x, worker.y)
	if _paint_at(cell) != LABARUM:
		return
	if get_labarum_cased() >= LABARUM_CAP:
		return
	var held := _amount(_labarum, cell)
	if held >= LABARUM_CAP:
		return
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var src := Vector2i(x, y)
			var amount := _amount(_vexillum, src)
			if amount <= 0:
				continue
			_put(_vexillum, src, amount - 1)
			_put(_labarum, cell, held + 1)
			return


func _house_vexillum(worker: Worker) -> void:
	var cell := Vector2i(worker.x, worker.y)
	if _paint_at(cell) != VEXILLUM:
		return
	if get_vexillum_housed() >= VEXILLUM_CAP:
		return
	var held := _amount(_vexillum, cell)
	if held >= VEXILLUM_CAP:
		return
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var src := Vector2i(x, y)
			var amount := _amount(_oriflamme, src)
			if amount <= 0:
				continue
			_put(_oriflamme, src, amount - 1)
			_put(_vexillum, cell, held + 1)
			return


func _lower_oriflamme(worker: Worker) -> void:
	var cell := Vector2i(worker.x, worker.y)
	if _paint_at(cell) != ORIFLAMME:
		return
	if get_oriflamme_lowered() >= ORIFLAMME_CAP:
		return
	var held := _amount(_oriflamme, cell)
	if held >= ORIFLAMME_CAP:
		return
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var src := Vector2i(x, y)
			var amount := _amount(_gonfalon, src)
			if amount <= 0:
				continue
			_put(_gonfalon, src, amount - 1)
			_put(_oriflamme, cell, held + 1)
			return


func _dip_gonfalon(worker: Worker) -> void:
	var cell := Vector2i(worker.x, worker.y)
	if _paint_at(cell) != GONFALON:
		return
	if get_gonfalon_dipped() >= GONFALON_CAP:
		return
	var held := _amount(_gonfalon, cell)
	if held >= GONFALON_CAP:
		return
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var src := Vector2i(x, y)
			var amount := _amount(_pennon, src)
			if amount <= 0:
				continue
			_put(_pennon, src, amount - 1)
			_put(_gonfalon, cell, held + 1)
			return


func _furl_pennon(worker: Worker) -> void:
	var cell := Vector2i(worker.x, worker.y)
	if _paint_at(cell) != PENNON:
		return
	if get_furled() >= PENNON_CAP:
		return
	var held := _amount(_pennon, cell)
	if held >= PENNON_CAP:
		return
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var src := Vector2i(x, y)
			var amount := _amount(_fanion, src)
			if amount <= 0:
				continue
			_put(_fanion, src, amount - 1)
			_put(_pennon, cell, held + 1)
			return


func _present_fanion(worker: Worker) -> void:
	var cell := Vector2i(worker.x, worker.y)
	if _paint_at(cell) != FANION:
		return
	if get_presented() >= FANION_CAP:
		return
	var held := _amount(_fanion, cell)
	if held >= FANION_CAP:
		return
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var src := Vector2i(x, y)
			var amount := _amount(_guidon, src)
			if amount <= 0:
				continue
			_put(_guidon, src, amount - 1)
			_put(_fanion, cell, held + 1)
			return


func _salute_guidon(worker: Worker) -> void:
	var cell := Vector2i(worker.x, worker.y)
	if _paint_at(cell) != GUIDON:
		return
	if get_saluted() >= GUIDON_CAP:
		return
	var held := _amount(_guidon, cell)
	if held >= GUIDON_CAP:
		return
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var src := Vector2i(x, y)
			var amount := _amount(_cornet, src)
			if amount <= 0:
				continue
			_put(_cornet, src, amount - 1)
			_put(_guidon, cell, held + 1)
			return


func _dip_cornet(worker: Worker) -> void:
	var cell := Vector2i(worker.x, worker.y)
	if _paint_at(cell) != CORNET:
		return
	if get_dipped() >= CORNET_CAP:
		return
	var held := _amount(_cornet, cell)
	if held >= CORNET_CAP:
		return
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var src := Vector2i(x, y)
			var amount := _amount(_burgee, src)
			if amount <= 0:
				continue
			_put(_burgee, src, amount - 1)
			_put(_cornet, cell, held + 1)
			return


func _strike_burgee(worker: Worker) -> void:
	var cell := Vector2i(worker.x, worker.y)
	if _paint_at(cell) != BURGEE:
		return
	if get_struck() >= BURGEE_CAP:
		return
	var held := _amount(_burgee, cell)
	if held >= BURGEE_CAP:
		return
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var src := Vector2i(x, y)
			var amount := _amount(_ensign, src)
			if amount <= 0:
				continue
			_put(_ensign, src, amount - 1)
			_put(_burgee, cell, held + 1)
			return


func _break_ensign(worker: Worker) -> void:
	var cell := Vector2i(worker.x, worker.y)
	if _paint_at(cell) != ENSIGN:
		return
	if get_broken() >= ENSIGN_CAP:
		return
	var held := _amount(_ensign, cell)
	if held >= ENSIGN_CAP:
		return
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var src := Vector2i(x, y)
			var amount := _amount(_jack, src)
			if amount <= 0:
				continue
			_put(_jack, src, amount - 1)
			_put(_ensign, cell, held + 1)
			return


func _show_jack(worker: Worker) -> void:
	var cell := Vector2i(worker.x, worker.y)
	if _paint_at(cell) != JACK:
		return
	if get_shown() >= JACK_CAP:
		return
	var held := _amount(_jack, cell)
	if held >= JACK_CAP:
		return
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var src := Vector2i(x, y)
			var amount := _amount(_standard, src)
			if amount <= 0:
				continue
			_put(_standard, src, amount - 1)
			_put(_jack, cell, held + 1)
			return


func _carry_standard(worker: Worker) -> void:
	var cell := Vector2i(worker.x, worker.y)
	if _paint_at(cell) != STANDARD:
		return
	if get_carried() >= STANDARD_CAP:
		return
	var held := _amount(_standard, cell)
	if held >= STANDARD_CAP:
		return
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var src := Vector2i(x, y)
			var amount := _amount(_pennant, src)
			if amount <= 0:
				continue
			_put(_pennant, src, amount - 1)
			_put(_standard, cell, held + 1)
			return


func _fly_pennant(worker: Worker) -> void:
	var cell := Vector2i(worker.x, worker.y)
	if _paint_at(cell) != PENNANT:
		return
	if get_flown() >= PENNANT_CAP:
		return
	var held := _amount(_pennant, cell)
	if held >= PENNANT_CAP:
		return
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var src := Vector2i(x, y)
			var amount := _amount(_banner, src)
			if amount <= 0:
				continue
			_put(_banner, src, amount - 1)
			_put(_pennant, cell, held + 1)
			return


func _best_loose_neighbor(cell: Vector2i) -> Vector2i:
	var best := Vector2i(-1, -1)
	var best_amount := 0
	for direction in DIRS:
		var nxt: Vector2i = cell + direction
		var amount := _amount(_loose, nxt)
		if amount <= 0:
			continue
		if amount > best_amount or (amount == best_amount and _prefer(nxt, best)):
			best = nxt
			best_amount = amount
	return best


func _best_stack_neighbor(cell: Vector2i) -> Vector2i:
	var best := Vector2i(-1, -1)
	var best_amount := 0
	for direction in DIRS:
		var nxt: Vector2i = cell + direction
		if _paint_at(nxt) != STACK:
			continue
		var amount := _amount(_stacked, nxt)
		if amount <= 0:
			continue
		if amount > best_amount or (amount == best_amount and _prefer(nxt, best)):
			best = nxt
			best_amount = amount
	return best


func _prefer(candidate: Vector2i, incumbent: Vector2i) -> bool:
	if incumbent.x < 0:
		return true
	if candidate.y != incumbent.y:
		return candidate.y < incumbent.y
	return candidate.x < incumbent.x


func _resolve_first_rain() -> void:
	if _season != WET or _rain_done:
		return
	var shipped := _sweep_rain(true)
	_wet_haul += shipped
	_ledger += shipped
	_season = DRY
	_phase = DRY


func _open_cart() -> void:
	if _phase != DRY or _rain_done:
		return
	_sweep_rain(false)
	_phase = CART


func _open_ship() -> void:
	if _phase != CART or _rain_done:
		return
	_phase = SHIPPING


func _open_market() -> void:
	if _phase != SHIPPING or _rain_done:
		return
	_phase = MARKET


func _open_yard() -> void:
	if _phase != MARKET or _rain_done:
		return
	_phase = YARDING


func _open_bunk() -> void:
	if _phase != YARDING or _rain_done:
		return
	_phase = BUNKING


func _open_loft() -> void:
	if _phase != BUNKING or _rain_done:
		return
	_phase = LOFTING


func _open_gate() -> void:
	if _phase != LOFTING or _rain_done:
		return
	_phase = GATING


func _open_wage() -> void:
	if _phase != GATING or _rain_done:
		return
	_phase = WAGING


func _open_relief() -> void:
	if _phase != WAGING or _rain_done:
		return
	_phase = RELIEVING


func _open_watch() -> void:
	if _phase != RELIEVING or _rain_done:
		return
	_phase = WATCHING


func _open_lamp() -> void:
	if _phase != WATCHING or _rain_done:
		return
	_phase = LAMPING


func _open_bell() -> void:
	if _phase != LAMPING or _rain_done:
		return
	_phase = BELLING


func _open_horn() -> void:
	if _phase != BELLING or _rain_done:
		return
	_phase = HORNING


func _open_flag() -> void:
	if _phase != HORNING or _rain_done:
		return
	_phase = FLAGGING


func _open_banner() -> void:
	if _phase != FLAGGING or _rain_done:
		return
	_phase = BANNERING


func _open_pennant() -> void:
	if _phase != BANNERING or _rain_done:
		return
	_phase = PENNANTING


func _open_standard() -> void:
	if _phase != PENNANTING or _rain_done:
		return
	_phase = STANDARDING


func _open_jack() -> void:
	if _phase != STANDARDING or _rain_done:
		return
	_phase = JACKING


func _open_ensign() -> void:
	if _phase != JACKING or _rain_done:
		return
	_phase = ENSIGNING


func _open_burgee() -> void:
	if _phase != ENSIGNING or _rain_done:
		return
	_phase = BURGEEING


func _open_cornet() -> void:
	if _phase != BURGEEING or _rain_done:
		return
	_phase = CORNETING


func _open_guidon() -> void:
	if _phase != CORNETING or _rain_done:
		return
	_phase = GUIDONING


func _open_fanion() -> void:
	if _phase != GUIDONING or _rain_done:
		return
	_phase = FANIONING


func _open_pennon() -> void:
	if _phase != FANIONING or _rain_done or not _pennon_painted():
		return
	_phase = PENNONING


func _open_gonfalon() -> void:
	if _phase != PENNONING or _rain_done or not _gonfalon_painted():
		return
	_phase = GONFALONING


func _open_oriflamme() -> void:
	if _phase != GONFALONING or _rain_done or not _oriflamme_painted():
		return
	_phase = ORIFLAMMING


func _open_vexillum() -> void:
	if _phase != ORIFLAMMING or _rain_done or not _vexillum_painted():
		return
	_phase = VEXILLUMING


func _open_labarum() -> void:
	if _phase != VEXILLUMING or _rain_done or not _labarum_painted():
		return
	_phase = LABARUMING


func _open_signum() -> void:
	if _phase != LABARUMING or _rain_done or not _signum_painted():
		return
	_phase = SIGNUMING


func _open_streamer() -> void:
	if _phase != SIGNUMING or _rain_done or not _streamer_painted():
		return
	_phase = STREAMERING


func _finish() -> void:
	if _rain_done:
		return
	_rain_done = true
	_summary = _make_summary()


func _sweep_rain(ship_covered: bool) -> int:
	var destroyed := 0
	var shipped := 0
	for y in range(GRID_NORTH, GRID_H):
		for x in GRID_W:
			var cell := Vector2i(x, y)
			var loose := _amount(_loose, cell)
			var stacked := _amount(_stacked, cell)
			var covered := _amount(_covered, cell)
			destroyed += loose
			_loose.erase(cell)
			if _paint_at(cell) == COVER:
				var kept := stacked + covered
				if ship_covered:
					shipped += kept
					_stacked.erase(cell)
					_covered.erase(cell)
				elif stacked > 0:
					_put(_covered, cell, covered + stacked)
					_stacked.erase(cell)
			else:
				destroyed += stacked + covered
				_stacked.erase(cell)
				_covered.erase(cell)
	_uncovered_destroyed += destroyed
	return shipped


func _make_summary() -> String:
	var stored := get_stored_salt()
	var dry_held := stored - _wet_haul
	var carted := get_carted()
	var message := ""
	if stored >= QUOTA:
		message = "The rains passed. Covered salt held: %d (quota %d). First rain hauled %d; dry season held %d." % [stored, QUOTA, _wet_haul, dry_held]
	elif stored <= 0 and _uncovered_destroyed > 0:
		message = "Quota missed: uncovered salt was destroyed by the rain (%d). Covered salt held: 0 (quota %d). Dry season held %d." % [_uncovered_destroyed, QUOTA, dry_held]
	elif stored <= 0:
		message = "Quota missed: no salt was stored before the rain. Covered salt held: 0 (quota %d). Dry season held %d." % [QUOTA, dry_held]
	else:
		message = "Quota missed: not enough covered salt survived the rain. Covered salt held: %d (quota %d). First rain hauled %d; dry season held %d." % [stored, QUOTA, _wet_haul, dry_held]
		if _uncovered_destroyed > 0:
			message += " Uncovered salt was destroyed by the rain."
	if carted > 0:
		message += " Carted %d into the crib." % carted
	if get_shipped() > 0:
		message += " Shipped %d." % get_shipped()
	if get_coins() > 0:
		message += " Coins %d." % get_coins()
	if get_banked() > 0:
		message += " Banked %d into the yard." % get_banked()
	if get_hired() > 0:
		message += " Hired %d. Left %d in the yard." % [get_hired(), get_yard_left()]
	if get_lofted() > 0:
		message += " Lofted %d." % get_lofted()
	if get_gated() > 0:
		message += " Gated %d. Left %d in the loft." % [get_gated(), get_loft_left()]
	if get_paid() > 0:
		message += " Paid %d. Left %d unpaid." % [get_paid(), get_gate_left()]
	if get_posted() > 0:
		message += " Posted %d. Left %d at the wage." % [get_posted(), get_wage_left()]
	if get_stood() > 0:
		message += " Stood %d on the watch. Left %d at the relief." % [get_stood(), get_relief_left()]
	if get_lit() > 0:
		message += " Lit %d on the lamp. Left %d at the watch." % [get_lit(), get_watch_left()]
	if get_rung() > 0:
		message += " Rung %d on the bell. Left %d at the lamp." % [get_rung(), get_lamp_left()]
	if get_sounded() > 0:
		message += " Sounded %d on the horn. Left %d at the bell." % [get_sounded(), get_bell_left()]
	if get_raised() > 0:
		message += " Raised %d on the flag. Left %d at the horn." % [get_raised(), get_horn_left()]
	if get_hoisted() > 0:
		message += " Hoisted %d on the banner. Left %d at the flag." % [get_hoisted(), get_flag_left()]
	if get_flown() > 0:
		message += " Flew %d on the pennant. Left %d at the banner." % [get_flown(), get_banner_left()]
	if get_carried() > 0:
		message += " Carried %d on the standard. Left %d at the pennant." % [get_carried(), get_pennant_left()]
	if get_shown() > 0:
		message += " Showed %d on the jack. Left %d at the standard." % [get_shown(), get_standard_left()]
	if get_broken() > 0:
		message += " Broke %d on the ensign. Left %d at the jack." % [get_broken(), get_jack_left()]
	if get_struck() > 0:
		message += " Struck %d on the burgee. Left %d at the ensign." % [get_struck(), get_ensign_left()]
	if get_dipped() > 0:
		message += " Dipped %d on the cornet. Left %d at the burgee." % [get_dipped(), get_burgee_left()]
	if get_saluted() > 0:
		message += " Saluted %d on the guidon. Left %d at the cornet." % [get_saluted(), get_cornet_left()]
	if get_presented() > 0:
		message += " Presented %d on the fanion. Left %d at the guidon." % [get_presented(), get_guidon_left()]
	if get_furled() > 0:
		message += " Furled %d on the pennon. Left %d at the fanion." % [get_furled(), get_fanion_left()]
	if get_gonfalon_dipped() > 0:
		message += " Dipped %d on the gonfalon. Left %d at the pennon." % [get_gonfalon_dipped(), get_pennon_left()]
	if get_oriflamme_lowered() > 0:
		message += " Lowered %d on the oriflamme. Left %d at the gonfalon." % [get_oriflamme_lowered(), get_gonfalon_left()]
	if get_vexillum_housed() > 0:
		message += " Housed %d on the vexillum. Left %d at the oriflamme." % [get_vexillum_housed(), get_oriflamme_left()]
	if get_labarum_cased() > 0:
		message += " Cased %d on the labarum. Left %d at the vexillum." % [get_labarum_cased(), get_vexillum_left()]
	if get_signum_sleeved() > 0:
		message += " Sleeved %d on the signum. Left %d at the labarum." % [get_signum_sleeved(), get_labarum_left()]
	if get_streamer_rolled() > 0:
		message += " Rolled %d on the streamer. Left %d at the signum." % [get_streamer_rolled(), get_signum_left()]
	return message
