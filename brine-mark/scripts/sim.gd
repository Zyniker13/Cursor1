extends RefCounted
class_name BrineSim

# Brine Mark slice — Salt Coast tick rules
#
# The player never selects an ant. They paint cells. Workers are simulated
# labor that follow the paint under their feet. This slice has one scenario:
# a wet season, a short dry season, a cart beat, a ship beat, a market beat, a yard beat, a bunk beat, a loft beat, a gate beat, a wage beat, a relief beat, a lamp beat, then a bell beat. The full game's population cap is
# 200; this slice hard-caps at POP_CAP (40) and will not grow past it.
#
# Map
# - Grid is GRID_W by GRID_H. Column COAST_X (0) is brine. It is not paintable
#   and not walkable. In the dry season the brine has pulled back: the column
#   stays unwalkable, and shore rakes no longer touch water.
# - The anthill is the fixed cell ANTHILL (14, 5). It is walkable, not
#   paintable, and the only place workers spawn.
# - Rows run from GRID_NORTH through GRID_H - 1. GRID_NORTH is seven rows north
#   of the old shore edge, so a loft can sit one cell north of a bunk on row 0,
#   a gate can sit one cell north of that loft, a wage can sit one cell
#   north of that gate, a relief can sit one cell north of that wage, a
#   watch can sit one cell north of that relief, a lamp can sit one cell
#   north of that watch, and a bell can sit one cell north of that lamp.
# - Every other cell accepts one mark: empty, rake, stack, cover, trail, pan,
#   crib, ship, stall, yard, bunk, loft, gate, wage, relief, watch, lamp, or bell. A crib is not walkable until the cart beat,
#   a ship is not walkable until the ship beat, a stall is not walkable until
#   the market beat, a yard is not walkable until the yard beat, a bunk is
#   not walkable until the bunk beat, a loft is not walkable until the loft
#   beat, a gate is not walkable until the gate beat, a wage is not
#   walkable until the wage beat, a relief is not walkable until the
#   relief beat, a watch is not walkable until the watch beat, a lamp is
#   not walkable until the lamp beat, and a bell is not walkable until the
#   bell beat, so painting one cannot change an earlier haul.
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
#   cells, ship cells, stall cells, yard cells, bunk cells, loft cells, gate cells, wage cells, relief cells, watch cells, lamp cells, and bell cells are marks only.
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
#   the bell beat ends and the scenario ends. Stored salt is the ledger still
#   unmoved, plus covered salt still on the map, plus salt still in cribs,
#   plus salt still on ships, plus coins still at stalls, plus coins still
#   in yards, plus coins spent on hires, plus coins spent on wages. Hires
#   moved into a loft, hires let through a gate, hires paid a wage, hires
#   posted to a relief, hires stood on a watch, hires lit by a lamp, and
#   hires rung on a bell, still count.
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
#    bell beat every job rings those hires. The job id does not change.
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
#    the bell beat ends.
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
#   stands them, the lamp beat then lights them, and the bell beat then rings them; the rain does none of those.
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
#   hires stayed on the lamp. A plan
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
#   it had before the bell beat existed.
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
#   ends. The bell countdown refills when the lamp beat ends. The sim itself counts ticks,
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

const WET := 0
const DRY := 1
# Cart is a beat after the dry season. The ship beat follows the cart, then
# the market, then the yard, then the bunk, then the loft, then the gate,
# then the wage, then the relief, then the watch, then the lamp, then the bell. get_season() stays DRY through all of them.
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

const GRID_W := 17
const GRID_H := 12
# Six rows north of the old edge. The bunk plans sit on row 0, so the loft is
# row -1, the gate is row -2, the wage is row -3, the relief is row -4, the
# watch is row -5, the lamp is row -6, and the bell is row -7.
const GRID_NORTH := -7
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
	if mode < EMPTY or mode > BELL:
		return false
	var cell := Vector2i(x, y)
	if mode == EMPTY:
		_paint.erase(cell)
	else:
		_paint[cell] = mode
	return true


func get_paint(x: int, y: int) -> int:
	return _paint_at(Vector2i(x, y))


func tick() -> void:
	if _rain_done:
		return
	var end_tick := RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK
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
	elif _tick_index >= end_tick:
		_finish()


func run_until_rain() -> void:
	var guard := 0
	var limit := RAIN_TICK + DRY_TICK + CART_TICK + SHIP_TICK + MARKET_TICK + YARD_TICK + BUNK_TICK + LOFT_TICK + GATE_TICK + WAGE_TICK + RELIEF_TICK + WATCH_TICK + LAMP_TICK + BELL_TICK + 2
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


# WET, DRY, CART, SHIPPING, MARKET, YARDING, BUNKING, LOFTING, GATING, WAGING, RELIEVING, WATCHING, LAMPING, or BELLING. Weather stays dry after the first rain.
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
	return _sum(_bunk) + _sum(_loft) + _sum(_gate) + _sum(_wage) + _sum(_relief) + _sum(_watch) + _sum(_lamp) + _sum(_bell)


# Hires still sitting at a bunk. Lofting moves these one at a time.
func get_bunk_left() -> int:
	return _sum(_bunk)


# Hires moved into a loft, including hires later let through a gate,
# hires later paid a wage, hires later posted, hires later stood, and hires
# later lit. The hire total still counts these.
func get_lofted() -> int:
	return _sum(_loft) + _sum(_gate) + _sum(_wage) + _sum(_relief) + _sum(_watch) + _sum(_lamp) + _sum(_bell)


# Hires still sitting in a loft. The gate moves these one at a time.
func get_loft_left() -> int:
	return _sum(_loft)


# Hires let through a gate, at most GATE_CAP, including hires later paid,
# hires later posted, hires later stood, and hires later lit. Nothing is
# rolled. The loft total and the hire total still count these.
func get_gated() -> int:
	return _sum(_gate) + _sum(_wage) + _sum(_relief) + _sum(_watch) + _sum(_lamp) + _sum(_bell)


# Hires who passed a gate and have not been paid. The wage pays these one at a time.
func get_gate_left() -> int:
	return _sum(_gate)


# Hires paid a wage, including hires later posted, hires later stood, and
# hires later lit. Pay is WAGE_COST coins from the yard. Nothing is rolled.
# The gate total and the hire total still count these.
func get_paid() -> int:
	return _sum(_wage) + _sum(_relief) + _sum(_watch) + _sum(_lamp) + _sum(_bell)


# Hires who were paid and have not been posted. The relief posts these one at a time.
func get_wage_left() -> int:
	return _sum(_wage)


# Hires posted to a relief, at most RELIEF_CAP, including hires later stood
# on a watch and hires later lit by a lamp. Nothing is rolled. The paid
# total and the hire total still count these. Posting spends no coins.
func get_posted() -> int:
	return _sum(_relief) + _sum(_watch) + _sum(_lamp) + _sum(_bell)


# Hires who were posted and have not been stood. The watch stands these one at a time.
func get_relief_left() -> int:
	return _sum(_relief)


# Hires stood on a watch, at most WATCH_CAP, including hires later lit by a
# lamp. Nothing is rolled. The posted total and the hire total still count
# these. Standing spends no coins and does not change the posted count.
func get_stood() -> int:
	return _sum(_watch) + _sum(_lamp) + _sum(_bell)


# Hires who were stood and have not been lit. The lamp lights these one at a time.
func get_watch_left() -> int:
	return _sum(_watch)


# Hires lit by a lamp, at most LAMP_CAP, including hires later rung on a
# bell. Nothing is rolled. The stood total and the hire total still count
# these. Lighting spends no coins and does not change the stood count or
# the posted count.
func get_lit() -> int:
	return _sum(_lamp) + _sum(_bell)


# Hires who were lit and have not been rung. The bell rings these one at a time.
func get_lamp_left() -> int:
	return _sum(_lamp)


# Hires rung on a bell, at most BELL_CAP. Nothing is rolled.
# The lit total and the hire total still count these. Ringing spends no
# coins and does not change the lit count, the stood count, or the posted count.
func get_rung() -> int:
	return _sum(_bell)


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
	# until the lamp beat, and a bell stays shut until the bell beat, so none
	# of them can shortcut an earlier haul. Each stays open afterward so
	# workers can walk the coins, the hires, the crew, the pay, the posting,
	# the standing, the lighting, and then the ringing forward.
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
	return message
