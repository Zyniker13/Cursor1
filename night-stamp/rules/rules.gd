# Night Stamp — Act 1 rules
#
# You are a border clerk. One traveler stands at the desk, and their written
# rule is visible before you stamp. Spend ink to press one card onto one cell
# of a 3x3 form. The cell matters as much as the card. The form is a queue:
# when the turn ends it resolves from the top row downward, left to right
# inside a row. A retrigger fires immediately, before the next cell in that
# reading order.
#
# TURN
# - A turn sets ink to 3, or 4 with the Deep Well relic. Unspent ink is lost.
# - Every card costs at least 1. Playing it spends that cost, fills an empty
#   cell, and moves the card from the hand to the discard.
# - Ink of 0 rejects every stamp. The play that spends the last ink ends the
#   turn. The turn also ends when no legal stamp remains, or when the clerk
#   ends it early. Turns always end.
# - The next turn draws the hand back to 5. An empty draw pile is the discard
#   shuffled back in.
#
# RESOLUTION
# - Row 0 is the top row. Row 2 is the bottom row. The player sees columns 1,
#   2, and 3 (indexes 0, 1, and 2).
# - CHAIN_CAP is 8. At most 8 retriggers resolve per turn. The next retrigger
#   stops the chain. Echo, Reply, and Ripple cannot loop forever.
# - PROGRESS_CAP is 40. Progress granted in one turn is clamped to 40.
# - HARD_STEP_LIMIT aborts resolution if a chain ever ignores the cap.
# - After the stamps, a traveler's end-of-queue rule may add progress.
# - Reaching the traveler's goal wins the encounter and patience does not fall.
#   Otherwise patience falls. Patience 0 loses the encounter. The form clears.
#
# POSITION STAMPS
# - Duty: 2 progress, or 4 on the bottom row. Iron Pad adds 1.
# - Exemption: 1 progress. On the traveler's exemption row, it cancels that
#   traveler's rule for the whole resolution, including stamps that resolve
#   before it in the queue.
# - Hold: 1 progress. Each traveler waits in a lane column. A Hold in that
#   column delays them, so patience does not fall this turn. Delay is applied
#   before Cira Venn's double drop.
# - Surcharge: 2 progress, plus 3 if the cell directly above is already filled.
#   The top row has no cell above, so it never gains the bonus.
#
# OTHER STAMPS
# - Entry Mark: 2. Visa Dot: 3. Wax Seal (2 ink): 6.
# - Corner Notch: 1 plus 1 for each orthogonal neighbor.
# - Pair Stamp: 4 if it has an orthogonal neighbor, otherwise 1.
# - Ledger Line: filled cells in this row. Column Tally: filled cells in this column.
# - Cross Check: 2, plus 2 if another stamp shares the row.
# - Queue Push: 4 on the top row, otherwise 2.
# - Waiver: 2, or 5 if the traveler's rule is cancelled.
# - Night Fee: 1 plus 1 for each ink spent earlier this turn (not including itself).
# - Heavy Chop (2 ink): 3, or 6 on the bottom row.
# - Final Notice (2 ink): 3, plus 3 on the bottom row when the cell above is filled.
# - Echo: 1, then retriggers the stamp below. Reply: 1, then retriggers the stamp above.
# - Ripple (2 ink): 2, then retriggers each orthogonal neighbor.
# A refusal or an isolation ignore zeros that stamp's own progress. It does not
# cancel the retrigger, and it does not remove Hold or Exemption.
#
# TRAVELERS, in act order
# - Ada Quill, lane column 1, exemption row top:
#   "Refuses stamps on the top row."
# - Bram Holt, lane column 2, exemption row middle:
#   "Yields if column 2 is stamped." Any stamp in column 2 adds 4 progress
#   after the queue. Exemption on the middle row cancels the yield.
# - Cira Venn, lane column 3, exemption row top:
#   "Patience drops twice when the bottom row is empty."
#   The drop is 2 instead of 1. Exemption on the top row keeps the drop at 1.
# - Doss Kite, lane column 1, exemption row bottom:
#   "Ignores stamps with no orthogonal neighbor."
#   Exemption on the bottom row lets isolated stamps count.
#
# LATE SHIFT, in desk order
# A second night. The stamps, the ink, and the 3x3 form are unchanged. The
# late shift deals the starting deck again. Drafts and the relic from the
# first bell do not carry. Open it from the victory desk, or directly.
# Restart act replays whichever night is on the desk.
# - Nell Parr, lane column 2, exemption row middle, Struck Margin:
#   "Refuses stamps in column 1."
#   Exemption on the middle row lets column 1 count.
# - Sol Wicks, lane column 1, exemption row top, Band Ledger:
#   "Yields if the middle row is full." A full middle row adds 4 progress
#   after the queue. One stamp in column 2 is not enough.
#   Exemption on the top row cancels the yield.
# - Pim Larke, lane column 3, exemption row bottom, Third-Bell Chit:
#   "Patience drops twice when column 3 is empty."
#   The drop is 2 instead of 1. Any stamp in column 3 keeps the drop at 1.
#   Exemption on the bottom row keeps the drop at 1.
#   Hold is applied before the double drop.
# - Rue Calder, lane column 2, exemption row bottom, Corner Ornament:
#   "Ignores stamps in the corner boxes."
#   The corners are both ends of the top row and both ends of the bottom row.
#   A lone center stamp still counts.
#   Exemption on the bottom row lets corner stamps count.
# A refused column and an ignored corner zero that stamp's own progress.
# They do not cancel the retrigger, and they do not remove Hold or Exemption.
#
# CLOSING BELL, in desk order
# A third night. The stamps, the ink, and the 3x3 form are unchanged. The
# closing bell deals the starting deck again. Drafts and the relic from an
# earlier night do not carry. Open it from a victory desk, or directly.
# Restart act replays whichever night is on the desk.
# - Moss Quen, lane column 3, exemption row middle, Folded Band:
#   "Refuses stamps on the middle row."
#   Exemption on the middle row lets the middle row count.
# - Kel Breck, lane column 2, exemption row top, Twin Margin:
#   "Yields if column 1 and column 3 are both stamped." Any stamp in column 1
#   together with any stamp in column 3 adds 4 progress after the queue.
#   One margin is not enough. Stamps in column 2 do not satisfy either margin.
#   Exemption on the top row cancels the yield.
# - Tansy Pell, lane column 1, exemption row bottom, Center Void:
#   "Patience drops twice when the center cell is empty."
#   The center cell is the middle row, column 2. The drop is 2 instead of 1.
#   A stamp in the center keeps the drop at 1.
#   Exemption on the bottom row keeps the drop at 1.
#   Hold is applied before the double drop.
# - Lumen Peck, lane column 3, exemption row bottom, Overprint Slip:
#   "Ignores a stamp with a stamp directly above it."
#   Directly above means the cell in the same column, one row higher.
#   The top row has no cell above, so a top-row stamp is never ignored.
#   A stamp still counts when the cell directly above is empty, even if the
#   top of that column is filled.
#   Exemption on the bottom row lets a covered stamp count.
# A refused middle row and an ignored covered stamp zero that stamp's own
# progress. They do not cancel the retrigger, and they do not remove Hold
# or Exemption.
#
# ASH WATCH, in desk order
# A fourth night. The stamps, the ink, and the 3x3 form are unchanged. The
# ash watch deals the starting deck again. Drafts and the relic from an
# earlier night do not carry. Open it from the desk, or from a victory desk.
# Restart act replays whichever night is on the desk.
# - Orla Fen, lane column 2, exemption row bottom, Sealed Foot:
#   "Refuses stamps on the bottom row."
#   Exemption on the bottom row lets the bottom row count.
# - Joss Mire, lane column 1, exemption row top, Pair Chit:
#   "Yields if the form holds exactly two stamps." Exactly two filled cells
#   add 4 progress after the queue. One stamp is not enough. Three stamps
#   are not enough. Filling one column, or one row, is not the condition.
#   Exemption on the top row cancels the yield.
# - Vetch Rowan, lane column 3, exemption row middle, Row Seal:
#   "Patience does not fall when every row is stamped."
#   Each of the three rows must hold a stamp. Two rows leave the drop at 1.
#   Exemption on the middle row keeps the drop at 1.
#   Hold is applied before the row seal.
# - Nim Harth, lane column 1, exemption row bottom, Tail Slip:
#   "The last stamp in the queue scores twice."
#   The queue is read from the top row downward, left to right inside a row.
#   The last filled cell in that order scores twice. An earlier stamp scores
#   its own number, even on the bottom row. A lone stamp is last, so it
#   scores twice. A retrigger of that last cell scores twice again. A
#   retrigger of an earlier cell does not.
#   Exemption on the bottom row cancels the doubling.
# A refused bottom row zeros that stamp's own progress. It does not cancel
# the retrigger, and it does not remove Hold or Exemption.
#
# GUTTER LAMP, in desk order
# A fifth night. The stamps, the ink, and the 3x3 form are unchanged. The
# gutter lamp deals the starting deck again. Drafts and the relic from an
# earlier night do not carry. Open it from the desk, or from a victory desk.
# Restart act replays whichever night is on the desk.
# - Ivo Dane, lane column 2, exemption row top, Blank Spine:
#   "Refuses stamps in column 2."
#   Column 2 is the spine. A stamp on the top row or the bottom row still
#   counts when it is not in column 2.
#   Exemption on the top row lets column 2 count.
# - Sera Dodd, lane column 1, exemption row middle, Triad Chit:
#   "Yields if every column is stamped."
#   Each of the three columns must hold a stamp. That adds 4 progress after
#   the queue. Two columns are not enough. Three stamps in one column do not
#   cover the other columns. One stamp in each column is enough. A full row
#   yields only because that row touches every column.
#   Exemption on the middle row cancels the yield.
# - Wren Hale, lane column 3, exemption row bottom, Open Margin:
#   "Patience drops twice when column 1 is empty."
#   The drop is 2 instead of 1. Any stamp in column 1 keeps the drop at 1.
#   A bottom-row stamp outside column 1 does not spare the drop.
#   Exemption on the bottom row keeps the drop at 1.
#   Hold is applied before the double drop.
# - Kit Yarrow, lane column 1, exemption row middle, Neighbor Slip:
#   "Ignores a stamp with an orthogonal neighbor."
#   Orthogonal means the cell above, below, left, or right. A diagonal touch
#   is not a neighbor. A lone stamp counts. Two stamps that only meet at a
#   corner both count. Two stamps that share a side both score 0.
#   Exemption on the middle row lets neighboring stamps count.
# A refused spine and an ignored neighbor zero that stamp's own progress.
# They do not cancel the retrigger, and they do not remove Hold or Exemption.
#
# VELLUM BELL, in desk order
# A sixth night. The stamps, the ink, and the 3x3 form are unchanged. The
# vellum bell deals the starting deck again. Drafts and the relic from an
# earlier night do not carry. Open it from the desk, or from a victory desk.
# Restart act replays whichever night is on the desk.
# - Edda Voss, lane column 2, exemption row middle, Quiet Center:
#   "Refuses the center cell."
#   The center cell is the middle row, column 2. The rest of the middle row
#   counts. The rest of column 2 counts. A top-row stamp counts. A bottom-row
#   stamp counts.
#   Exemption on the middle row lets the center count.
# - Rho Tallow, lane column 1, exemption row top, Corner Meet:
#   "Yields if two stamps meet at a corner."
#   A corner means the two cells touch diagonally: one row apart and one
#   column apart. That adds 4 progress after the queue, once. A longer
#   diagonal does not meet. Two stamps that share a side do not meet at a
#   corner. One stamp is not enough. Three stamps in one row, or in one
#   column, are not enough. If any pair meets at a corner, the yield happens
#   even when another pair shares a side.
#   Exemption on the top row cancels the yield.
# - Nessa Brin, lane column 3, exemption row bottom, Row Toll:
#   "Patience drops once for each empty row."
#   An empty row is a row with no stamp. Three empty rows drop patience by 3.
#   Two empty rows drop it by 2. One empty row drops it by 1. A stamp in
#   every row drops it by 0. Three stamps in one row still leave two rows
#   empty.
#   Exemption on the bottom row keeps the drop at 1, even when every row is
#   stamped and even when two rows are empty.
#   Hold is applied before the row toll.
# - Lark Pym, lane column 1, exemption row middle, Solo Line:
#   "Ignores a stamp that shares its row."
#   A stamp scores 0 when another stamp sits in the same row. A lone stamp
#   in a row counts. Stamps in different rows both count. Filling a row
#   ignores every stamp in that row. A stamp directly below another is a
#   different row, so both can count.
#   Exemption on the middle row lets a shared row count.
# A refused center and an ignored shared row zero that stamp's own progress.
# They do not cancel the retrigger, and they do not remove Hold or Exemption.
#
# QUIRE WATCH, in desk order
# A seventh night. The stamps, the ink, and the 3x3 form are unchanged. The
# quire watch deals the starting deck again. Drafts and the relic from an
# earlier night do not carry. Open it from the desk, or from a victory desk.
# Restart act replays whichever night is on the desk.
# - Tess Quern, lane column 3, exemption row top, Far Margin:
#   "Refuses stamps in column 3."
#   Column 3 is the far margin. A stamp on the top row or the bottom row
#   still counts when it is not in column 3. The middle of column 1 and
#   column 2 counts.
#   Exemption on the top row lets column 3 count.
# - Oren Sallow, lane column 1, exemption row middle, Side Meet:
#   "Yields if two stamps share a side."
#   A shared side means the two cells touch orthogonally: the same row and
#   neighboring columns, or the same column and neighboring rows. That adds
#   4 progress after the queue, once. Two stamps that only meet at a corner
#   do not share a side. Two stamps with a gap between them do not share a
#   side. One stamp is not enough. A full row yields because its neighbors
#   share sides. A full column yields for the same reason. If any pair
#   shares a side, the yield happens even when another pair only meets at
#   a corner.
#   Exemption on the middle row cancels the yield.
# - Bryn Solt, lane column 2, exemption row bottom, Column Toll:
#   "Patience drops once for each empty column."
#   An empty column is a column with no stamp. Three empty columns drop
#   patience by 3. Two empty columns drop it by 2. One empty column drops
#   it by 1. A stamp in every column drops it by 0. Three stamps in one
#   column still leave two columns empty. One stamp in each column is
#   enough, even when those stamps share a row.
#   Exemption on the bottom row keeps the drop at 1, even when every column
#   is stamped and even when two columns are empty.
#   Hold is applied before the column toll.
# - Ida Cress, lane column 1, exemption row top, Head Slip:
#   "The first stamp in the queue scores twice."
#   The queue is read from the top row downward, left to right inside a row.
#   The first filled cell in that order scores twice. A later stamp scores
#   its own number. A lone stamp is first, so it scores twice. A retrigger
#   of that first cell scores twice again. A retrigger of a later cell does
#   not.
#   Exemption on the top row cancels the doubling.
# A refused column zeros that stamp's own progress. It does not cancel the
# retrigger, and it does not remove Hold or Exemption.
#
# SALT WATCH, in desk order
# An eighth night. The stamps, the ink, and the 3x3 form are unchanged. The
# salt watch deals the starting deck again. Drafts and the relic from an
# earlier night do not carry. Open it from the desk, or from a victory desk.
# Restart act replays whichever night is on the desk.
# - Pell Voss, lane column 2, exemption row middle, Tide Bar:
#   "A stamp on the middle row scores 0 unless an Exemption is also on the
#   middle row."
#   That is the middle-row refusal. A top-row stamp counts. A bottom-row
#   stamp counts. Exemption on the middle row lets the middle row count,
#   including a stamp that resolved earlier in the queue. An Exemption off
#   the middle row does not.
# - June Hart, lane column 3, exemption row bottom, Pair Toll:
#   "Patience drops by 2 if two stamps share a number."
#   A number is the progress that stamp already grants. Entry Mark is 2.
#   Visa Dot is 3. Duty is 2, or 4 on the bottom row. Exemption and Hold
#   are 1. Two stamps share a number when those values are equal. The same
#   card can fail to share: a top-row Duty is 2 and a bottom-row Duty is 4.
#   Different cards can share: a top-row Duty and an Entry Mark are both 2.
#   One stamp cannot share, so the drop stays 1. Three stamps drop patience
#   by 2 when any pair matches, and by 1 when every number differs. The toll
#   does not change what a stamp scores. A Surcharge is 2, or 5 when the
#   cell above is filled, so the cell can change its number.
#   Exemption on the bottom row keeps the drop at 1.
#   Hold is applied before the pair toll.
# - Cal Mire, lane column 1, exemption row top, Edge Yield:
#   "A stamp on the outer frame yields +3. The center cell does not."
#   The outer frame is every cell except the center. The center is the
#   middle row, column 2. Each frame stamp adds 3 to its own progress.
#   Two frame stamps add 3 each. The center stamp scores its own number.
#   A retrigger of a frame stamp yields +3 again. A retrigger of the center
#   does not.
#   Exemption on the top row cancels the yield, so a frame stamp scores
#   its own number.
# - Ned Quill, lane column 2, exemption row bottom, Last Slip:
#   "The last stamp in the queue scores twice."
#   The queue is read from the top row downward, left to right inside a row.
#   The last filled cell in that order scores twice. An earlier stamp scores
#   its own number, even on the bottom row. A lone stamp is last, so it
#   scores twice. A retrigger of that last cell scores twice again. A
#   retrigger of an earlier cell does not.
#   Exemption on the bottom row cancels the doubling.
# A refused middle row zeros that stamp's own progress. It does not cancel
# the retrigger, and it does not remove Hold or Exemption.
#
# QUAY BELL, in desk order
# A ninth night. The stamps, the ink, and the 3x3 form are unchanged. The
# quay bell deals the starting deck again. Drafts and the relic from an
# earlier night do not carry. Open it from the desk, or from a victory desk.
# Restart act replays whichever night is on the desk.
# - Mara Quill, lane column 2, exemption row top, First Bar:
#   "The first stamp in the queue scores 0 unless an Exemption is on the
#   top row."
#   The queue is read from the top row downward, left to right inside a row.
#   The first filled cell in that order scores 0. A later stamp scores its
#   own number. A lone stamp is first, so it scores 0. A stamp on the top
#   row still counts when an earlier cell in that row is filled. A stamp on
#   the bottom row scores 0 when it is the first filled cell. The order the
#   stamps were pressed does not matter. A cell higher in the queue is first
#   even when it was pressed last.
#   A retrigger of that first cell scores 0 again. A retrigger of a later
#   cell does not.
#   Exemption on the top row lets the first stamp count, including a stamp
#   that resolved earlier in the queue. An Exemption off the top row does not.
# - Holt Venn, lane column 3, exemption row middle, Center Toll:
#   "Patience drops by 2 if the center cell is filled."
#   The center cell is the middle row, column 2. The drop is 2 instead of 1.
#   A stamp outside the center keeps the drop at 1. The center stamp still
#   scores its own number. An empty form keeps the drop at 1.
#   Exemption on the middle row keeps the drop at 1, even when the center
#   is filled. An Exemption in the center is on the middle row, so it keeps
#   the drop at 1. An Exemption off the middle row does not.
#   Hold is applied before the center toll.
# - Sera Dunn, lane column 1, exemption row top, Corner Yield:
#   "A stamp in a corner yields +3. A non-corner edge does not."
#   The corners are both ends of the top row and both ends of the bottom
#   row. Each corner stamp adds 3 to its own progress. Two corner stamps
#   add 3 each. A non-corner edge is the middle of a side: top row column 2,
#   middle row column 1, middle row column 3, and bottom row column 2.
#   Those score their own number. The center cell scores its own number.
#   A retrigger of a corner stamp yields +3 again. A retrigger of any other
#   cell does not.
#   Exemption on the top row cancels the yield, so a corner stamp scores
#   its own number.
# - Ivo Pell, lane column 2, exemption row bottom, Pair Slip:
#   "If two stamps share a number, the later one scores twice."
#   A number is the progress that stamp already grants, before this doubling.
#   Entry Mark is 2. Visa Dot is 3. Duty is 2, or 4 on the bottom row.
#   Exemption and Hold are 1. Two stamps share a number when those values
#   are equal. The same card can fail to share: a top-row Duty is 2 and a
#   bottom-row Duty is 4. Different cards can share: a top-row Duty and an
#   Entry Mark are both 2.
#   Later means later in the queue, not later in the order the stamps were
#   pressed. The earlier stamp of a shared number scores its own number.
#   Each later stamp that shares its number with any earlier stamp scores
#   twice. One stamp cannot share, so it scores once. A later stamp with a
#   different number scores once, even when it is the last cell. Three
#   stamps that all share a number double the second and the third. A gap
#   does not block a pair. A retrigger of a later shared stamp scores twice
#   again. A retrigger of the earlier stamp does not.
#   Exemption on the bottom row cancels the doubling.
#   The slip does not change patience. Two stamps that share a number still
#   drop patience by 1 unless a Hold delays the traveler.
# A refused first stamp zeros that stamp's own progress. It does not cancel
# the retrigger, and it does not remove Hold or Exemption.
#
# FOLIO BELL, in desk order
# A tenth night. The stamps, the ink, and the 3x3 form are unchanged. The
# folio bell deals the starting deck again. Drafts and the relic from an
# earlier night do not carry. Open it from the desk, or from a victory desk.
# Restart act replays whichever night is on the desk.
# - Ness Hart, lane column 1, exemption row bottom, Last Bar:
#   "The last stamp in the queue scores 0 unless an Exemption is on the
#   bottom row."
#   The queue is read from the top row downward, left to right inside a row.
#   The last filled cell in that order scores 0. An earlier stamp scores
#   its own number, even on the bottom row. A lone stamp is last, so it
#   scores 0. A stamp on the bottom row still counts when a later cell in
#   that row is filled. The order the stamps were pressed does not matter.
#   A cell later in the queue is last even when it was pressed first.
#   A retrigger of that last cell scores 0 again. A retrigger of an earlier
#   cell does not.
#   Exemption on the bottom row lets the last stamp count, including a stamp
#   that resolved earlier in the queue. An Exemption off the bottom row does not.
# - Wynn Cress, lane column 3, exemption row middle, Center Slip:
#   "The center stamp scores twice. Other cells score their own number."
#   The center cell is the middle row, column 2. That stamp scores twice
#   its own number. A top-row stamp scores its own number. A bottom-row
#   stamp scores its own number. The rest of the middle row scores its own
#   number. A lone center stamp scores twice. A lone stamp outside the
#   center scores once. A retrigger of the center scores twice again. A
#   retrigger of any other cell does not.
#   Exemption on the middle row cancels the doubling, so the center scores
#   its own number. An Exemption in the center is on the middle row, so it
#   scores 1, not 2.
# - Tam Quern, lane column 1, exemption row top, Column Bar:
#   "A stamp in column 1 scores 0 when that column holds another stamp."
#   Nell Parr already refuses every stamp in column 1, so Tam does not copy
#   that rule. A lone stamp in column 1 scores its own number. A second
#   stamp in column 1 makes every stamp in that column score 0. Columns 2
#   and 3 score their own number, even when they touch column 1 and even
#   when column 1 is stacked. A retrigger of a stacked column-1 stamp scores
#   0 again. A retrigger of a lone column-1 stamp scores its own number again.
#   Exemption on the top row lets a stacked column 1 count. An Exemption
#   off the top row does not. An Exemption in column 1 on the top row is
#   on the exemption row, so the column counts.
# - Pell Sallow, lane column 3, exemption row bottom, Gap Toll:
#   "Patience drops by 2 if two stamps have an empty cell between them."
#   Queue order runs from the top row downward, left to right inside a row.
#   Two filled stamps have a gap when an empty cell sits between them in
#   that order. The drop is 2 instead of 1. Stamps that follow one another
#   in the queue, including the last cell of a row and the first cell of
#   the next row, keep the drop at 1. One stamp cannot leave a gap, so the
#   drop stays 1. An empty form keeps the drop at 1. A diagonal pair still
#   gaps when the queue cells between them are empty. The toll does not
#   change what a stamp scores.
#   Exemption on the bottom row keeps the drop at 1, even when a gap is
#   open and even when the stamps are contiguous.
#   Hold is applied before the gap toll.
# A refused last stamp and a refused stacked column zero that stamp's own
# progress. They do not cancel the retrigger, and they do not remove Hold
# or Exemption.
#
# WICK BELL, in desk order
# An eleventh night. The stamps, the ink, and the 3x3 form are unchanged. The
# wick bell deals the starting deck again. Drafts and the relic from an
# earlier night do not carry. Open it from the desk, or from a victory desk.
# Restart act replays whichever night is on the desk.
# - Odell Voss, lane column 2, exemption row bottom, Row Bar:
#   "A stamp on the bottom row scores 0 when that row holds another stamp."
#   Orla Fen refuses every bottom-row stamp, including a lone one. Lark Pym
#   ignores a shared stamp on every row. Odell does neither. A stamp on the
#   bottom row scores 0 only when another stamp sits on that same row. A
#   lone bottom-row stamp scores its own number. The top row and the middle
#   row score their own number, even when those rows are shared and even
#   when they touch the bottom row. A second bottom-row stamp makes every
#   bottom-row stamp score 0. Columns do not matter. A retrigger of a
#   stacked bottom-row stamp scores 0 again. A retrigger of a lone
#   bottom-row stamp scores its own number again.
#   Exemption on the bottom row lets a stacked bottom row count. An
#   Exemption off the bottom row does not. An Exemption on the bottom row
#   is itself a stamp, so a second bottom-row stamp beside it still sits
#   on the exemption row and the row counts.
# - Cress Hart, lane column 1, exemption row top, First Slip:
#   "The first stamp in the queue scores twice when a later stamp follows it."
#   Ida Cress already doubles every first stamp, including a lone stamp, so
#   Cress does not copy that rule. The first filled cell scores twice only
#   when another stamp follows it in the queue. A lone stamp is both first
#   and last, so it scores its own number. A later stamp scores its own
#   number. The queue is read from the top row downward, left to right
#   inside a row. The order the stamps were pressed does not matter.
#   A retrigger of that followed first cell scores twice again. A retrigger
#   of a later cell does not. A retrigger of a lone stamp does not.
#   Exemption on the top row cancels the doubling.
# - Jun Solt, lane column 3, exemption row bottom, Pair Bar:
#   "If two stamps share a number, the later one scores 0."
#   Ivo Pell doubles that later stamp. June Hart spends patience. Jun does
#   neither. A number is the progress that stamp already grants, before this
#   bar. Entry Mark is 2. Visa Dot is 3. Duty is 2, or 4 on the bottom row.
#   Exemption and Hold are 1. Two stamps share a number when those values
#   are equal. The same card can fail to share: a top-row Duty is 2 and a
#   bottom-row Duty is 4. Different cards can share: a top-row Duty and an
#   Entry Mark are both 2. A Surcharge is 2, or 5 when the cell above is
#   filled.
#   Later means later in the queue, not later in the order the stamps were
#   pressed. The earlier stamp of a shared number scores its own number.
#   Each later stamp that shares its number with any earlier stamp scores 0.
#   One stamp cannot share, so it scores its own number. A later stamp with
#   a different number scores its own number, even when it is the last cell.
#   Three stamps that all share a number zero the second and the third. A
#   gap does not block a pair. A retrigger of a later shared stamp scores 0
#   again. A retrigger of the earlier stamp does not.
#   Exemption on the bottom row lets the later stamp count.
#   The bar does not change patience. Two stamps that share a number still
#   drop patience by 1 unless a Hold delays the traveler.
# - Ives Mire, lane column 2, exemption row top, Empty Yield:
#   "Each empty cell adds 1 to every filled stamp's own progress."
#   An empty cell is a cell with no stamp. The bonus is added to each filled
#   stamp, not once for the form. One filled stamp and eight empty cells
#   add 8. Two filled stamps and seven empty cells add 7 to each stamp.
#   The center cell receives the bonus. A corner receives the same bonus.
#   Cal Mire adds 3 to the frame only, so Ives does not copy that rule.
#   A retrigger of a filled stamp adds the empty-cell bonus again.
#   Exemption on the top row cancels the bonus, so every stamp scores its
#   own number. An Exemption off the top row does not.
# A refused stacked bottom row and a barred later number zero that stamp's
# own progress. They do not cancel the retrigger, and they do not remove
# Hold or Exemption.
#
# MARGIN BELL, in desk order
# A twelfth night. The stamps, the ink, and the 3x3 form are unchanged. The
# margin bell deals the starting deck again. Drafts and the relic from an
# earlier night do not carry. Open it from the desk, or from a victory desk.
# Restart act replays whichever night is on the desk.
# - Nim Voss, lane column 2, exemption row top, Side Bar:
#   "A stamp scores 0 when it shares a side with an earlier stamp."
#   Kit Yarrow already ignores every stamp that shares a side. A corner-only
#   touch does not count for Kit, and a lone stamp scores its own number.
#   Both stamps of a side-sharing pair score 0. Nim does not copy that rule.
#   A stamp scores 0 only when it shares a side with an earlier stamp. The
#   earlier stamp scores its own number. A side is an orthogonal touch: the
#   cell above, below, left, or right. A corner-only touch does not count.
#   Two stamps that only meet at a corner both score their own number. A
#   lone stamp scores its own number. Later means later in the queue, not
#   later in the order the stamps were pressed. A stamp that shares a side
#   only with a later stamp still scores its own number. Three stamps in a
#   row zero the second and the third. A longer diagonal does not bar either
#   stamp. A retrigger of a later side-sharing stamp scores 0 again. A
#   retrigger of the earlier stamp scores its own number again.
#   Exemption on the top row lets the later stamp count. An Exemption off
#   the top row does not.
#   The bar does not change patience.
# - Orla Quill, lane column 1, exemption row bottom, Last Toll:
#   "Patience drops by 2 if the last filled cell is in column 3."
#   The queue is read from the top row downward, left to right inside a row.
#   The last filled cell in that order sets the drop. The drop is 2 instead
#   of 1 when that cell is in column 3. A last cell in column 1 or column 2
#   keeps the drop at 1. An earlier stamp in column 3 does not raise the
#   drop when a later cell is filled outside column 3. A lone stamp in
#   column 3 is last, so the drop is 2. A lone stamp outside column 3 keeps
#   the drop at 1. An empty form has no last cell, so the drop stays 1.
#   The toll does not change what a stamp scores. The order the stamps were
#   pressed does not matter.
#   Exemption on the bottom row keeps the drop at 1, even when the last
#   cell is in column 3. An Exemption off the bottom row does not.
#   Hold is applied before the last toll.
# - Bram Hart, lane column 3, exemption row top, Frame Slip:
#   "A stamp on the outer frame scores twice when the center is filled."
#   The outer frame is every cell except the center. The center is the
#   middle row, column 2. A frame stamp scores twice only when the center
#   is also filled. If the center is empty, frame stamps score their own
#   number. The center scores its own number, even when it is filled. A
#   lone frame stamp scores its own number. A lone center stamp scores its
#   own number. Corners and the middle of each side are both frame. Cal
#   Mire adds 3 to every frame stamp whether or not the center is filled,
#   so Bram does not copy that yield. A retrigger of a frame stamp scores
#   twice again when the center is filled. A retrigger of the center does
#   not. A retrigger of a frame stamp with an empty center does not.
#   Exemption on the top row cancels the doubling, so a frame stamp scores
#   its own number even when the center is filled. An Exemption in the
#   center is on the middle row, so the frame still doubles and the center
#   scores 1.
# - Sable Solt, lane column 2, exemption row bottom, Gap Yield:
#   "If two filled stamps have an empty cell between them, each of those
#   stamps scores +2."
#   Pell Sallow's Gap Toll drops patience by 2 for the same gap. Sable
#   changes the score and does not change patience. Queue order runs from
#   the top row downward, left to right inside a row. Two filled stamps
#   have a gap when an empty cell sits between them in that order. When any
#   such pair exists, every filled stamp is part of one: the first and the
#   last have an empty cell between them, and every stamp between those two
#   does too. Each of those stamps adds 2 to its own progress, once, not
#   once per pair. Stamps that are not part of a gap score their own number.
#   A contiguous block has no gap. A lone stamp has no gap. One stamp cannot
#   leave a gap. Stamps that follow one another, including the last cell of
#   a row and the first cell of the next row, are not a gap. A diagonal pair
#   still gaps when the queue cells between them are empty. A retrigger of
#   a stamp in a gap adds 2 again. A retrigger when the queue has no gap
#   does not.
#   Exemption on the bottom row cancels the bonus, so every stamp scores
#   its own number. An Exemption off the bottom row does not.
#   The yield does not change patience. A gap still drops patience by 1
#   unless a Hold delays the traveler.
# A barred later side zeros that stamp's own progress. It does not cancel
# the retrigger, and it does not remove Hold or Exemption.
#
# INDEX BELL, in desk order
# A thirteenth night. The stamps, the ink, and the 3x3 form are unchanged.
# The index bell deals the starting deck again. Drafts and the relic from an
# earlier night do not carry. Open it from the desk, or from a victory desk.
# Restart act replays whichever night is on the desk.
# - Len Quill, lane column 1, exemption row top, Corner Bar:
#   "A stamp scores 0 only when it touches an earlier stamp at a corner and
#   does not share a side with that same earlier stamp."
#   Nim Voss already zeros a later stamp that shares a side. A corner-only
#   touch does not count for Nim, and Kit Yarrow zeros both stamps of a
#   side-sharing pair. Len does not copy either rule. A stamp scores 0 only
#   when it touches an earlier stamp at a corner and does not share a side
#   with that same earlier stamp. A corner is one row apart and one column
#   apart. A side is an orthogonal touch: the cell above, below, left, or
#   right. A side touch is Nim's rule and does not zero the stamp here. A
#   stamp that only shares a side still scores its own number. The earlier
#   stamp of a corner touch scores its own number. A lone stamp scores its
#   own number. Later means later in the queue, not later in the order the
#   stamps were pressed. A stamp that touches a later stamp at a corner
#   still scores its own number. A longer diagonal, or a gap of two cells,
#   does not bar either stamp. Sharing a side with one earlier stamp does
#   not save a corner touch with a different earlier stamp. A retrigger of
#   a later corner-touching stamp scores 0 again. A retrigger of the earlier
#   stamp scores its own number again. A retrigger of a stamp that only
#   shares a side scores its own number again.
#   Exemption on the top row lets the later stamp count, including a stamp
#   that resolved earlier in the queue. An Exemption off the top row does not.
#   The bar does not change patience.
# - Ada Pell, lane column 3, exemption row bottom, First Toll:
#   "Patience drops by 2 when the first filled cell is in column 1."
#   Orla Quill's Last Toll watches the last filled cell and column 3. Ada
#   watches the first filled cell and column 1. The queue is read from the
#   top row downward, left to right inside a row. The first filled cell in
#   that order sets the drop. The drop is 2 instead of 1 when that cell is
#   in column 1. A first cell in column 2 or column 3 keeps the drop at 1.
#   A later stamp in column 1 does not raise the drop when the first cell
#   is outside column 1. A lone stamp in column 1 is first, so the drop is
#   2. A lone stamp outside column 1 keeps the drop at 1. An empty form has
#   no first cell, so the drop stays 1. The toll does not change what a
#   stamp scores. The order the stamps were pressed does not matter.
#   Exemption on the bottom row keeps the drop at 1, even when the first
#   cell is in column 1. An Exemption off the bottom row does not.
#   Hold is applied before the first toll.
# - Wynn Hart, lane column 2, exemption row top, Full Row:
#   "A stamp scores twice only when its own row is full."
#   A full row is all three cells filled. A stamp in that row scores twice.
#   A stamp in a row that is not full scores its own number. Other rows do
#   not matter. One full row does not double a stamp in an open row. An
#   open row does not stop a full row from doubling. Sol Wicks yields when
#   the middle row is full, and Bram Hart doubles the frame when the center
#   is filled. Wynn does neither. The center scores twice only when its own
#   row is full, and then the other two stamps in that row score twice as
#   well. A lone stamp scores its own number. A pair in a row scores its
#   own number. A retrigger of a stamp in a full row scores twice again. A
#   retrigger of a stamp in a row that is not full does not.
#   Exemption on the top row cancels the doubling, so every stamp scores
#   its own number. An Exemption off the top row does not.
#   The slip does not change patience.
# - Sera Voss, lane column 1, exemption row bottom, End Match:
#   "If the first and last filled stamps show the same number, every filled
#   stamp scores +2."
#   Sable Solt adds 2 when a gap is open. Ivo Pell doubles a later stamp
#   that shares a number. Jun Solt zeros that later stamp. Sera does none
#   of those. A number is the progress that stamp already grants, before
#   this bonus. Entry Mark is 2. Visa Dot is 3. Duty is 2, or 4 on the
#   bottom row. Exemption and Hold are 1. The first and last filled stamps
#   show the same number when those values are equal. The same card can
#   fail to match: a top-row Duty is 2 and a bottom-row Duty is 4.
#   Different cards can match: a top-row Duty and an Entry Mark are both 2.
#   The queue is read from the top row downward, left to right inside a
#   row. The order the stamps were pressed does not matter. When the ends
#   match, every filled stamp adds 2 to its own progress, once, not once
#   per pair. A middle stamp with a different number still adds 2. A lone
#   stamp is both ends, so it scores its own number. Ends that differ
#   score their own number. A gap is not required, and a contiguous block
#   still adds 2 when the ends match. A retrigger of a filled stamp adds 2
#   again when the ends match. A retrigger when the ends differ does not.
#   A retrigger of a lone stamp does not.
#   Exemption on the bottom row cancels the bonus, so every stamp scores
#   its own number. An Exemption off the bottom row does not.
#   The match does not change patience. Matching ends still drop patience
#   by 1 unless a Hold delays the traveler.
# A barred later corner zeros that stamp's own progress. It does not cancel
# the retrigger, and it does not remove Hold or Exemption.
#
# LEDGER BELL, in desk order
# A fourteenth night. The stamps, the ink, and the 3x3 form are unchanged.
# The ledger bell deals the starting deck again. Drafts and the relic from
# an earlier night do not carry. Open it from the desk, or from a victory
# desk. Restart act replays whichever night is on the desk.
# - Nell Voss, lane column 2, exemption row bottom, Wing Pair:
#   "When column 1 and column 3 of the same row are both filled, those two
#   stamps each score +3 once. Column 2 of that row scores its own number."
#   Kel Breck yields +4 after the queue when column 1 and column 3 are both
#   stamped anywhere on the form, even on different rows. Cal Mire adds 3
#   to every frame stamp. Nell does neither. The bonus is added to each
#   wing of one row, once, not once for the form. Column 1 and column 3 of
#   that same row are the wings. Both must be filled. Each of those two
#   stamps adds 3 to its own progress. Column 2 of that row scores its own
#   number. A row missing either wing gives no bonus. Two wings on different
#   rows score their own number, even when both side columns are stamped
#   somewhere on the form. A full row bonuses only its two wings. The middle
#   stamp of that row does not gain the bonus. Another row does not gain it
#   unless that row also holds both wings. A lone stamp scores its own
#   number. A retrigger of a wing stamp adds 3 again when that row still
#   holds both wings. A retrigger of column 2 does not. A retrigger of a
#   wing in a row that is missing the other wing does not.
#   Exemption on the bottom row cancels the bonus, so every stamp scores
#   its own number. An Exemption off the bottom row does not. An Exemption
#   that is itself a wing on the bottom row is on the exemption row, so the
#   bonus is cancelled. An Exemption that is a wing off the bottom row
#   still adds 3.
#   The pair does not change patience.
# - Pell Dane, lane column 1, exemption row bottom, Three Toll:
#   "Patience drops by 2 when exactly three cells are filled."
#   Joss Mire yields +4 after the queue when the form holds exactly two
#   stamps. Pell does not copy that yield, and the toll does not pass when
#   the count is two. The drop is 2 instead of 1 when the form holds
#   exactly three stamps. An empty form keeps the drop at 1. One stamp
#   keeps the drop at 1. Two stamps keep the drop at 1. Four stamps keep
#   the drop at 1. Any other count keeps the drop at 1. The toll does not
#   change what a stamp scores. A full row is three stamps, so patience
#   drops by 2, and each stamp still scores its own number. Three stamps
#   in one column do the same.
#   Exemption on the bottom row keeps the drop at 1, even when exactly
#   three cells are filled and even when the count is anything else. An
#   Exemption off the bottom row does not.
#   Hold is applied before the three toll.
# - Ida Mire, lane column 3, exemption row top, Low Slip:
#   "When two or more stamps are filled, the earliest stamp among those
#   showing the lowest number scores twice. A lone stamp scores its own
#   number."
#   Ida Cress doubles the first stamp in the queue, including a lone stamp.
#   Cress Hart doubles the first stamp only when a later stamp follows it.
#   Ivo Pell doubles a later stamp that shares a number. Ida does none of
#   those. A number is the progress that stamp already grants, before this
#   doubling. Entry Mark is 2. Visa Dot is 3. Duty is 2, or 4 on the bottom
#   row. Exemption and Hold are 1. A Surcharge is 2, or 5 when the cell
#   above is filled. The lowest number is the smallest of those values.
#   The earliest stamp among the stamps that show that number scores twice.
#   If two stamps share that lowest number, only the earlier one doubles.
#   Every other filled stamp scores its own number, even when it is first
#   in the queue and even when it shares a higher number with an earlier
#   stamp. A lone stamp is the only number on the form, so it scores its
#   own number. Later means later in the queue, not later in the order the
#   stamps were pressed. The same card can fail to be the lowest: a top-row
#   Duty is 2 and a bottom-row Duty is 4, so only the top-row Duty is
#   lowest. A retrigger of that earliest lowest stamp scores twice again.
#   A retrigger of any other stamp does not. A retrigger of a lone stamp
#   does not.
#   Exemption on the top row cancels the doubling, so every stamp scores
#   its own number. An Exemption off the top row does not.
#   The slip does not change patience.
# - Sable Quern, lane column 1, exemption row top, After Gap:
#   "A stamp scores twice only when the queue cell immediately before it is
#   empty and some earlier cell is filled."
#   Sable Solt adds 2 to every filled stamp when any gap exists. Pell
#   Sallow drops patience by 2 for that gap. Sable Quern does neither. The
#   queue is read from the top row downward, left to right inside a row.
#   A stamp scores twice only when the cell immediately before it in that
#   order is empty and some cell before that empty cell is filled. The
#   stamp before the empty cell scores its own number. A stamp at the start
#   of the queue has no cell before it, so it does not double. Leading
#   empty cells do not double the first filled stamp. A contiguous block
#   has no doubled stamp. A lone stamp scores its own number. Across a row
#   break, the first cell of the next row doubles only when the last cell
#   of the previous row is empty and some earlier cell is filled. If that
#   last cell is filled, the first cell of the next row scores its own
#   number, even when an earlier gap is open. A stamp that follows a filled
#   cell does not double. A later gap does not double the stamp before it.
#   A retrigger of a stamp that follows a gap scores twice again. A
#   retrigger of a stamp that does not follow a gap does not. A retrigger
#   of a stamp at the start of the queue does not.
#   Exemption on the top row cancels the doubling, so every stamp scores
#   its own number. An Exemption off the top row does not.
#   The slip does not change patience. A gap still drops patience by 1
#   unless a Hold delays the traveler.
# The wing bonus, the low slip, and the after-gap doubling do not remove
# Hold or Exemption, and they do not cancel a retrigger.
#
# SPINE BELL, in desk order
# A fifteenth night. The stamps, the ink, and the 3x3 form are unchanged.
# The spine bell deals the starting deck again. Drafts and the relic from
# an earlier night do not carry. Open it from the desk, or from a victory
# desk. Restart act replays whichever night is on the desk.
# - Wynn Quill, lane column 2, exemption row top, High Slip:
#   "When two or more stamps are filled, the earliest stamp among those
#   showing the highest number scores twice. A lone stamp scores its own
#   number."
#   Ida Mire doubles the earliest stamp among those showing the lowest
#   number. Ida Cress doubles the first stamp in the queue, including a
#   lone stamp. Cress Hart doubles the first stamp only when a later stamp
#   follows it. Wynn does none of those. A number is the progress that
#   stamp already grants, before this doubling. Entry Mark is 2. Visa Dot
#   is 3. Duty is 2, or 4 on the bottom row. Exemption and Hold are 1. A
#   Surcharge is 2, or 5 when the cell above is filled. The highest number
#   is the largest of those values. The earliest stamp among the stamps
#   that show that number scores twice. If two stamps share that highest
#   number, only the earlier one doubles. Every other filled stamp scores
#   its own number, even when it is first in the queue and even when it
#   shares a lower number with an earlier stamp. A lone stamp is the only
#   number on the form, so it scores its own number. Later means later in
#   the queue, not later in the order the stamps were pressed. The same
#   card can fail to be the highest: a top-row Duty is 2 and a bottom-row
#   Duty is 4, so only the bottom-row Duty is highest. A retrigger of that
#   earliest highest stamp scores twice again. A retrigger of any other
#   stamp does not. A retrigger of a lone stamp does not.
#   Exemption on the top row cancels the doubling, so every stamp scores
#   its own number. An Exemption off the top row does not.
#   The slip does not change patience.
# - Ada Hart, lane column 3, exemption row bottom, Four Toll:
#   "Patience drops by 2 when exactly four cells are filled."
#   Pell Dane drops patience by 2 when the form holds exactly three stamps.
#   Joss Mire yields +4 after the queue when the form holds exactly two.
#   Ada does neither. The drop is 2 instead of 1 when the form holds
#   exactly four stamps. An empty form keeps the drop at 1. One stamp
#   keeps the drop at 1. Two stamps keep the drop at 1. Three stamps keep
#   the drop at 1. Five stamps keep the drop at 1. Any other count keeps
#   the drop at 1. The toll does not change what a stamp scores. A full
#   row is three stamps, so the drop stays at 1, and each stamp still
#   scores its own number.
#   Exemption on the bottom row keeps the drop at 1, even when exactly
#   four cells are filled and even when the count is anything else. An
#   Exemption off the bottom row does not.
#   Hold is applied before the four toll.
# - Bram Solt, lane column 1, exemption row top, Before Gap:
#   "A stamp scores twice only when the queue cell immediately after it is
#   empty and some later cell is filled."
#   Sable Quern doubles the stamp that follows an empty cell when some
#   earlier cell is filled. Sable Solt adds 2 to every filled stamp when
#   any gap exists. Pell Sallow drops patience by 2 for that gap. Bram
#   does none of those. The queue is read from the top row downward, left
#   to right inside a row. A stamp scores twice only when the cell
#   immediately after it in that order is empty and some cell after that
#   empty cell is filled. The stamp after the empty cell scores its own
#   number. It does not double because of that gap. A stamp at the end of
#   the queue has no cell after it, so it does not double. Trailing empty
#   cells do not double the last filled stamp. A contiguous block has no
#   doubled stamp. A lone stamp scores its own number. Across a row
#   break, the last cell of a row doubles only when the first cell of the
#   next row is empty and some later cell is filled. If that first cell
#   is filled, the last cell of the previous row scores its own number,
#   even when a later gap is open. A stamp that is followed by a filled
#   cell does not double. An earlier gap does not double the stamp after
#   it. A retrigger of a stamp that precedes a gap scores twice again. A
#   retrigger of a stamp that does not precede a gap does not. A
#   retrigger of a stamp at the end of the queue does not.
#   Exemption on the top row cancels the doubling, so every stamp scores
#   its own number. An Exemption off the top row does not.
#   The slip does not change patience. A gap still drops patience by 1
#   unless a Hold delays the traveler.
# - Sera Pell, lane column 2, exemption row bottom, Column Pair:
#   "When two filled stamps in the same column have exactly one empty cell
#   between them, those two stamps each score +3 once. A third stamp in
#   that column does not get the bonus unless it is one of such a pair."
#   Nell Voss adds 3 to column 1 and column 3 of the same row. Cal Mire
#   adds 3 to every frame stamp. Sera does neither. The bonus is added to
#   each stamp of one column pair, once, not once for the form. The only
#   cells in a column with exactly one cell between them are the top and
#   the bottom. They pair when the middle cell of that column is empty.
#   Each of those two stamps adds 3 to its own progress. The middle stamp
#   is never one of that pair. A third stamp in that column does not get
#   the bonus unless it is one of such a pair. A full column has no empty
#   cell, so no stamp in it gains the bonus, including the middle stamp
#   and the two ends. Stamps in different columns do not pair. Contiguous
#   stamps in a column, with no empty cell between them, get no bonus.
#   Two columns can each hold a pair. Each pair bonuses its own two
#   stamps. A stamp is in one column, so it gains the bonus once. A lone
#   stamp scores its own number. A retrigger of a paired stamp adds 3
#   again when that column still holds the pair. A retrigger of a stamp
#   that is not in a pair does not. A retrigger of a contiguous stamp
#   does not.
#   Exemption on the bottom row cancels the bonus, so every stamp scores
#   its own number. An Exemption off the bottom row does not. An Exemption
#   that is itself one of the pair on the bottom row is on the exemption
#   row, so the bonus is cancelled. An Exemption that is one of the pair
#   off the bottom row still adds 3.
#   The pair does not change patience.
# The high slip, the before-gap doubling, and the column-pair bonus do not
# remove Hold or Exemption, and they do not cancel a retrigger.
#
# HEADBAND BELL, in desk order
# A sixteenth night. The stamps, the ink, and the 3x3 form are unchanged.
# The headband bell deals the starting deck again. Drafts and the relic from
# an earlier night do not carry. Open it from the desk, or from a victory
# desk. Restart act replays whichever night is on the desk.
# - Len Hart, lane column 1, exemption row top, Open Wing:
#   "When column 1 and column 3 of the same row are both filled and column
#   2 of that row is empty, those two stamps each score +3 once."
#   Nell Voss adds 3 to column 1 and column 3 of the same row even when
#   column 2 of that row is filled. Len does not. The bonus is added to
#   each wing of one open row, once, not once for the form. Column 1 and
#   column 3 of the same row pair only when column 2 of that row is empty.
#   Each of those two stamps adds 3 to its own progress. If column 2 of
#   that row is filled, that row gets no bonus, including the two wings
#   and the stamp in column 2. A row with only one wing filled gets no
#   bonus. Column 2 never receives this bonus, even when the wings of
#   another row are open. Two rows can each hold an open pair. Each pair
#   bonuses its own two stamps. A stamp is in one row, so it gains the
#   bonus once. A lone stamp scores its own number. A stamp in another
#   column of another row scores its own number. A retrigger of an open
#   wing adds 3 again when that row still holds the pair. A retrigger of
#   a stamp that is not an open wing does not.
#   Exemption on the top row cancels the bonus, so every stamp scores its
#   own number. An Exemption off the top row does not. An Exemption that
#   is itself one wing on the top row is on the exemption row, so the
#   bonus is cancelled. An Exemption that is one wing off the top row
#   still adds 3.
#   The wing does not change patience.
# - Joss Pell, lane column 3, exemption row bottom, Five Toll:
#   "Patience drops by 2 when exactly five cells are filled."
#   Ada Hart drops patience by 2 when the form holds exactly four stamps.
#   Pell Dane drops patience by 2 when the form holds exactly three.
#   Joss does neither. The drop is 2 instead of 1 when the form holds
#   exactly five stamps. An empty form keeps the drop at 1. One stamp
#   keeps the drop at 1. Two stamps keep the drop at 1. Three stamps keep
#   the drop at 1. Four stamps keep the drop at 1. Six stamps keep the
#   drop at 1. Any other count keeps the drop at 1. The toll does not
#   change what a stamp scores.
#   Exemption on the bottom row keeps the drop at 1, even when exactly
#   five cells are filled and even when the count is anything else. An
#   Exemption off the bottom row does not.
#   Hold is applied before the five toll.
# - Ida Quill, lane column 2, exemption row top, Late High:
#   "When two or more stamps are filled, the latest stamp among those
#   showing the highest number scores twice. A lone stamp scores its own
#   number."
#   Wynn Quill doubles the earliest stamp among those showing the highest
#   number. Ida Mire doubles the earliest of the lowest number. Ida does
#   neither. A number is the progress that stamp already grants, before
#   this doubling. Entry Mark is 2. Visa Dot is 3. Duty is 2, or 4 on the
#   bottom row. Exemption and Hold are 1. A Surcharge is 2, or 5 when the
#   cell above is filled. The highest number is the largest of those
#   values. The latest stamp among the stamps that show that number
#   scores twice. If two stamps share that highest number, only the later
#   one doubles. Every other filled stamp scores its own number, even
#   when it is first in the queue and even when it shows the highest
#   number earlier. A lone stamp is the only number on the form, so it
#   scores its own number. Later means later in the queue, not later in
#   the order the stamps were pressed. The same card can fail to be the
#   highest: a top-row Duty is 2 and a bottom-row Duty is 4, so only the
#   bottom-row Duty is highest. A retrigger of that latest highest stamp
#   scores twice again. A retrigger of any other stamp does not. A
#   retrigger of a lone stamp does not.
#   Exemption on the top row cancels the doubling, so every stamp scores
#   its own number. An Exemption off the top row does not.
#   The slip does not change patience.
# - Cal Quern, lane column 2, exemption row middle, Diagonal Pair:
#   "When two filled stamps on one three-cell diagonal have exactly one
#   empty cell between them, those two each score +3 once."
#   Sera Pell adds 3 to the top and bottom of one column when the middle
#   of that column is empty. Nell Voss adds 3 to the wings of one row.
#   Cal does neither. The two three-cell diagonals are top-left, center,
#   bottom-right, and top-right, center, bottom-left. The only cells on
#   a diagonal with exactly one cell between them are the two ends. They
#   pair when the center cell is empty. Each of those two stamps adds 3
#   to its own progress. A filled center means neither pair qualifies,
#   including the two ends of both diagonals and the center stamp itself.
#   A corner with no partner on its diagonal scores its own number. A
#   stamp that is not one of such a pair scores its own number. The
#   middles of the four sides are not on either diagonal. Two diagonals
#   can each hold a pair when the center is empty. Each pair bonuses its
#   own two stamps. A corner is on one diagonal, so it gains the bonus
#   once. A lone stamp scores its own number. A retrigger of a paired
#   stamp adds 3 again when that diagonal still holds the pair. A
#   retrigger of a stamp that is not in a pair does not.
#   Exemption on the middle row cancels the bonus, so every stamp scores
#   its own number. An Exemption off the middle row does not. An
#   Exemption in the center is on the middle row, and the center is
#   filled, so the pair does not pay. An Exemption that is one end of a
#   pair off the middle row still adds 3.
#   The pair does not change patience.
# The open wing, the late-high doubling, and the diagonal-pair bonus do
# not remove Hold or Exemption, and they do not cancel a retrigger.
#
# CLASP BELL, in desk order
# A seventeenth night. The stamps, the ink, and the 3x3 form are unchanged.
# The clasp bell deals the starting deck again. Drafts and the relic from an
# earlier night do not carry. Open it from the desk, or from a victory desk.
# Restart act replays whichever night is on the desk.
# - Noll Hart, lane column 1, exemption row bottom, Late Low:
#   "When two or more stamps are filled, the latest stamp among those
#   showing the lowest number scores twice. A lone stamp scores its own
#   number."
#   Ida Mire doubles the earliest stamp among those showing the lowest
#   number. Ida Quill doubles the latest stamp among those showing the
#   highest number. Noll does neither. A number is the progress that stamp
#   already grants, before this doubling. Entry Mark is 2. Visa Dot is 3.
#   Duty is 2, or 4 on the bottom row. Exemption and Hold are 1. A
#   Surcharge is 2, or 5 when the cell above is filled. The lowest number
#   is the smallest of those values. The latest stamp among the stamps
#   that show that number scores twice. If two stamps share that lowest
#   number, only the later one doubles. Every other filled stamp scores
#   its own number, even when it is last in the queue and even when it
#   shows the lowest number earlier. A lone stamp is the only number on
#   the form, so it scores its own number. Later means later in the queue,
#   not later in the order the stamps were pressed. The same card can fail
#   to be the lowest: a top-row Duty is 2 and a bottom-row Duty is 4, so
#   only the top-row Duty is lowest. A retrigger of that latest lowest
#   stamp scores twice again. A retrigger of any other stamp does not. A
#   retrigger of a lone stamp does not.
#   Exemption on the bottom row cancels the doubling, so every stamp
#   scores its own number. An Exemption off the bottom row does not.
#   The slip does not change patience.
# - Hugh Pell, lane column 2, exemption row top, Six Toll:
#   "Patience drops by 2 when exactly six cells are filled."
#   Joss Pell drops patience by 2 when the form holds exactly five stamps.
#   Ada Hart drops patience by 2 when the form holds exactly four. Pell
#   Dane drops patience by 2 when the form holds exactly three. Hugh does
#   none of those. The drop is 2 instead of 1 when the form holds exactly
#   six stamps. An empty form keeps the drop at 1. One stamp keeps the
#   drop at 1. Two stamps keep the drop at 1. Three stamps keep the drop
#   at 1. Four stamps keep the drop at 1. Five stamps keep the drop at 1.
#   Seven stamps keep the drop at 1. Any other count keeps the drop at 1.
#   The toll does not change what a stamp scores.
#   Exemption on the top row keeps the drop at 1, even when exactly six
#   cells are filled and even when the count is anything else. An
#   Exemption off the top row does not.
#   Hold is applied before the six toll.
# - Fenn Hart, lane column 3, exemption row middle, Full Column:
#   "A stamp scores twice only when its own column is full."
#   A full column is all three cells filled. A stamp in that column scores
#   twice. A stamp in a column that is not full scores its own number.
#   Other columns do not matter. One full column does not double a stamp
#   in an open column. An open column does not stop a full column from
#   doubling. Wynn Hart doubles a stamp only when its own row is full.
#   Fenn does not. A full row does not double a stamp unless that stamp's
#   own column is also full. A lone stamp scores its own number. A pair in
#   a column scores its own number. A retrigger of a stamp in a full
#   column scores twice again. A retrigger of a stamp in a column that is
#   not full does not.
#   Exemption on the middle row cancels the doubling, so every stamp
#   scores its own number. An Exemption off the middle row does not. An
#   Exemption in the middle of a full column is on the exemption row, so
#   that column scores its own number.
#   The slip does not change patience.
# - Rue Hart, lane column 1, exemption row bottom, Side Slip:
#   "When a stamp shares a side with an earlier stamp, the later stamp
#   scores twice. The earlier stamp scores its own number."
#   Nim Voss already zeros that later stamp. Kit Yarrow zeros both stamps
#   of a side-sharing pair. Rue does neither. A side is an orthogonal
#   touch: the cell above, below, left, or right. A corner-only touch does
#   not count. Two stamps that only meet at a corner both score their own
#   number. A lone stamp scores its own number. Later means later in the
#   queue, not later in the order the stamps were pressed. A stamp that
#   shares a side only with a later stamp still scores its own number.
#   Three stamps in a row double the second and the third. A longer
#   diagonal does not double either stamp. A gap between two stamps in a
#   row does not double the later stamp. A retrigger of a later
#   side-sharing stamp scores twice again. A retrigger of the earlier
#   stamp scores its own number again.
#   Exemption on the bottom row cancels the doubling, so the later stamp
#   scores its own number. An Exemption off the bottom row does not.
#   The slip does not change patience.
# The late-low doubling, the full-column doubling, and the side slip do
# not remove Hold or Exemption, and they do not cancel a retrigger.
#
# SIGNATURE BELL, in desk order
# An eighteenth night. The stamps, the ink, and the 3x3 form are unchanged.
# The signature bell deals the starting deck again. Drafts and the relic
# from an earlier night do not carry. Open it from the desk, or from a
# victory desk. Restart act replays whichever night is on the desk.
# - Dory Hart, lane column 3, exemption row bottom, Seven Toll:
#   "Patience drops by 2 when exactly seven cells are filled."
#   Hugh Pell drops patience by 2 when the form holds exactly six stamps.
#   Joss Pell drops patience by 2 when the form holds exactly five. Ada
#   Hart drops patience by 2 when the form holds exactly four. Pell Dane
#   drops patience by 2 when the form holds exactly three. Dory does none
#   of those. The drop is 2 instead of 1 when the form holds exactly seven
#   stamps. An empty form keeps the drop at 1. One stamp keeps the drop at
#   1. Two stamps keep the drop at 1. Three stamps keep the drop at 1. Four
#   stamps keep the drop at 1. Five stamps keep the drop at 1. Six stamps
#   keep the drop at 1. Eight stamps keep the drop at 1. Nine stamps keep
#   the drop at 1. Any other count keeps the drop at 1. The toll does not
#   change what a stamp scores.
#   Exemption on the bottom row keeps the drop at 1, even when exactly
#   seven cells are filled and even when the count is anything else. An
#   Exemption off the bottom row does not.
#   Hold is applied before the seven toll.
# - Lin Pell, lane column 1, exemption row top, Lone Column:
#   "A stamp scores twice only when it is the only filled stamp in its
#   column."
#   A column with one stamp doubles that stamp. If that column holds
#   another stamp, every stamp in the column scores its own number. A pair
#   does not double. A full column does not double. Other columns do not
#   matter. A lone stamp in one column still doubles when another column is
#   stacked. Tam Quern scores 0 for every stamp in column 1 when that
#   column holds another stamp, and leaves a lone column-1 stamp at its own
#   number. Fenn Hart doubles a stamp only when its own column is full. Lin
#   does neither. A second stamp in column 1 does not score 0. Columns 2
#   and 3 follow the same rule as column 1. A lone stamp on the form is the
#   only stamp in its column, so it scores twice. A retrigger of a stamp
#   that is alone in its column scores twice again. A retrigger of a stamp
#   in a column that holds another stamp does not.
#   Exemption on the top row cancels the doubling, so every stamp scores
#   its own number. An Exemption off the top row does not. An Exemption
#   that is the only stamp in its column and sits off the top row scores
#   twice. An Exemption on the top row is on the exemption row, so that
#   column and every other column score their own number.
#   The slip does not change patience.
# - Opal Quill, lane column 2, exemption row middle, Side Pay:
#   "Each stamp that shares a side with another filled stamp scores +3
#   once."
#   A side is an orthogonal touch: the cell above, below, left, or right.
#   A corner-only touch does not count. Two stamps that only meet at a
#   corner both score their own number. A stamp that shares two sides still
#   scores +3 once, not +3 for each side. A stamp that shares three sides
#   still scores +3 once. A lone stamp scores its own number. Both stamps
#   of a side-sharing pair score +3. Rue Hart doubles only the later stamp
#   of a side pair. Nim Voss zeros that later stamp. Opal does neither.
#   Queue order does not choose who is paid. A gap between two stamps in a
#   row does not pay either stamp. A longer diagonal does not pay either
#   stamp. Three stamps in a row pay each stamp +3 once, including the
#   middle stamp that shares two sides. A retrigger of a stamp that shares
#   a side adds 3 again. A stamp that does not share a side scores its own
#   number, including on a retrigger.
#   Exemption on the middle row cancels the bonus, so every stamp scores
#   its own number. An Exemption off the middle row does not. An Exemption
#   that shares a side and sits off the middle row still adds 3.
#   The pay does not change patience.
# - Holt Quern, lane column 2, exemption row bottom, Next Fill:
#   "A stamp scores twice only when the queue cell immediately after it is
#   filled."
#   The queue is read from the top row downward, left to right inside a
#   row. The cell immediately after a stamp is the next cell in that order.
#   The cell after the right end of a row is the left end of the next row.
#   The bottom-right cell has no cell after it, so it scores its own
#   number. A stamp whose next cell is empty scores its own number, even
#   when a later cell is filled. Bram Solt doubles a stamp when the next
#   cell is empty and some later cell is filled. Holt does not. A
#   contiguous pair doubles the earlier stamp and leaves the later stamp at
#   its own number when the cell after that later stamp is empty. A
#   retrigger of a stamp whose next cell is filled scores twice again. A
#   retrigger of a stamp whose next cell is empty does not. A retrigger of
#   the bottom-right cell does not.
#   Exemption on the bottom row cancels the doubling, so every stamp scores
#   its own number. An Exemption off the bottom row does not.
#   The slip does not change patience.
# The lone-column doubling, the side pay, and the next-fill doubling do not
# remove Hold or Exemption, and they do not cancel a retrigger.
#
# CATCHWORD BELL, in desk order
# A nineteenth night. The stamps, the ink, and the 3x3 form are unchanged.
# The catchword bell deals the starting deck again. Drafts and the relic
# from an earlier night do not carry. Open it from the desk, or from a
# victory desk. Restart act replays whichever night is on the desk.
# - Gwyn Brant, lane column 3, exemption row top, Eight Toll:
#   "Patience drops by 2 when exactly eight cells are filled."
#   Dory Hart drops patience by 2 when the form holds exactly seven stamps.
#   Hugh Pell drops patience by 2 when the form holds exactly six. Joss Pell
#   drops patience by 2 when the form holds exactly five. Ada Hart drops
#   patience by 2 when the form holds exactly four. Pell Dane drops patience
#   by 2 when the form holds exactly three. Gwyn does none of those. The
#   drop is 2 instead of 1 when the form holds exactly eight stamps. An
#   empty form keeps the drop at 1. One stamp keeps the drop at 1. Two
#   stamps keep the drop at 1. Three stamps keep the drop at 1. Four stamps
#   keep the drop at 1. Five stamps keep the drop at 1. Six stamps keep the
#   drop at 1. Seven stamps keep the drop at 1. Nine stamps keep the drop
#   at 1. Any other count keeps the drop at 1. The toll does not change
#   what a stamp scores.
#   Exemption on the top row keeps the drop at 1, even when exactly eight
#   cells are filled and even when the count is anything else. An Exemption
#   off the top row does not.
#   Hold is applied before the eight toll.
# - Hester Keel, lane column 1, exemption row bottom, Prior Fill:
#   "A stamp scores twice only when the queue cell immediately before it
#   is filled."
#   The queue is read from the top row downward, left to right inside a
#   row, the same order Holt Quern uses. The cell immediately before a
#   stamp is the previous cell in that order. The cell before the left end
#   of a row is the right end of the previous row. The top-left cell has
#   no cell before it, so it scores its own number. A stamp whose previous
#   cell is empty scores its own number, even when an earlier cell is
#   filled. A gap means the stamp after the gap does not double. Holt Quern
#   doubles a stamp when the next cell is filled. Bram Solt doubles a stamp
#   when the next cell is empty and some later cell is filled. Sable Quern
#   doubles a stamp when the previous cell is empty and some earlier cell
#   is filled. Hester does none of those. A contiguous pair doubles the
#   later stamp and leaves the earlier stamp at its own number when that
#   earlier stamp has no filled cell before it. A retrigger of a stamp
#   whose previous cell is filled scores twice again. A retrigger of a
#   stamp whose previous cell is empty does not. A retrigger of the
#   top-left cell does not.
#   Exemption on the bottom row cancels the doubling, so every stamp scores
#   its own number. An Exemption off the bottom row does not.
#   The slip does not change patience.
# - Idris Reed, lane column 2, exemption row middle, Corner Pay:
#   "Each stamp that has at least one filled diagonal neighbor scores +3
#   once."
#   A diagonal neighbor is one of the four corner-touching cells: one row
#   apart and one column apart. An orthogonal neighbor does not count. The
#   cell above, below, left, or right is not a diagonal neighbor. A stamp
#   with two or more diagonal neighbors still scores +3 once, not +3 for
#   each. A stamp that only has orthogonal neighbors scores its own number.
#   A lone stamp scores its own number. Two stamps that only share a side
#   both score their own number. Two stamps that meet at a corner each
#   score +3. Opal Quill adds 3 for a side share. Rho Tallow yields once
#   after the queue when two stamps meet at a corner. Idris does neither.
#   A longer diagonal, two cells apart, does not pay either stamp. A gap in
#   a row does not pay either stamp. Queue order does not choose who is
#   paid. A retrigger of a stamp that has a filled diagonal neighbor adds 3
#   again. A retrigger of a stamp that does not have a filled diagonal
#   neighbor does not.
#   Exemption on the middle row cancels the bonus, so every stamp scores
#   its own number. An Exemption off the middle row does not. An Exemption
#   that has a filled diagonal neighbor and sits off the middle row still
#   adds 3.
#   The pay does not change patience.
# - Colm Brigg, lane column 1, exemption row top, Short Row:
#   "A stamp scores twice only when its own row holds exactly two filled
#   stamps."
#   Both stamps in that row score twice. A row with one stamp scores that
#   stamp's own number. A full row of three scores each stamp's own number.
#   Other rows are independent. A pair in one row still doubles when
#   another row is full, and a full row still scores its own numbers when
#   another row holds a pair. Wynn Hart doubles a stamp only when its own
#   row is full. Colm does not. A lone stamp on the form is the only stamp
#   in its row, so it scores its own number. A retrigger of a stamp in a
#   two-stamp row scores twice again. A retrigger of a stamp in a row of
#   one or three does not.
#   Exemption on the top row cancels the doubling, so every stamp scores
#   its own number. An Exemption off the top row does not. An Exemption in
#   a two-stamp row that sits off the top row scores twice.
#   The slip does not change patience.
# The prior-fill doubling, the corner pay, and the short-row doubling do
# not remove Hold or Exemption, and they do not cancel a retrigger.
#
# RUN
# - A run is seeded. The shuffle and the draft offer are a pure function of the
#   seed, the night, the traveler, and the cards owned, so restarting an
#   encounter deals the same hand.
# - The starting deck is four Entry Marks, two Duty, two Surcharge, one
#   Exemption, and one Hold. The pool has 20 cards.
# - After every win except the last, draft 1 of 3 pool cards.
# - After encounter 2, choose one relic before that draft. Iron Pad or Deep
#   Well lasts for the rest of the night.
# - Restart encounter replays the current traveler with the current deck and relic.
# - Restart act starts the open night over from the seed.
extends RefCounted

const CHAIN_CAP := 8
const PROGRESS_CAP := 40
const HARD_STEP_LIMIT := 48
const BASE_INK := 3
const HAND_SIZE := 5
const LOG_LIMIT := 24

const RELIC_IRON_PAD := "iron_pad"
const RELIC_DEEP_WELL := "deep_well"

const SHIFT_FIRST := 0
const SHIFT_LATE := 1
const SHIFT_CLOSING := 2
const SHIFT_ASH := 3
const SHIFT_GUTTER := 4
const SHIFT_VELLUM := 5
const SHIFT_QUIRE := 6
const SHIFT_SALT := 7
const SHIFT_QUAY := 8
const SHIFT_FOLIO := 9
const SHIFT_WICK := 10
const SHIFT_MARGIN := 11
const SHIFT_INDEX := 12
const SHIFT_LEDGER := 13
const SHIFT_SPINE := 14
const SHIFT_HEADBAND := 15
const SHIFT_CLASP := 16
const SHIFT_SIGNATURE := 17
const SHIFT_CATCHWORD := 18

const ROW_NAMES := ["top row", "middle row", "bottom row"]
const COL_NAMES := ["column 1", "column 2", "column 3"]

const POOL := [
	"duty",
	"exemption",
	"hold",
	"surcharge",
	"entry_mark",
	"visa_dot",
	"wax_seal",
	"corner_notch",
	"pair_stamp",
	"ledger_line",
	"column_tally",
	"echo",
	"reply",
	"ripple",
	"waiver",
	"queue_push",
	"night_fee",
	"heavy_chop",
	"cross_check",
	"final_notice",
]

const STARTING_DECK := [
	"entry_mark",
	"entry_mark",
	"entry_mark",
	"entry_mark",
	"duty",
	"duty",
	"surcharge",
	"surcharge",
	"exemption",
	"hold",
]

const CARDS := {
	"duty": {"name": "Duty", "cost": 1, "text": "2 progress, or 4 on the bottom row."},
	"exemption": {"name": "Exemption", "cost": 1, "text": "1 progress. On the traveler's exemption row, cancels their rule."},
	"hold": {"name": "Hold", "cost": 1, "text": "1 progress. In the traveler's column, patience does not fall."},
	"surcharge": {"name": "Surcharge", "cost": 1, "text": "2 progress, plus 3 if the cell above is filled."},
	"entry_mark": {"name": "Entry Mark", "cost": 1, "text": "2 progress."},
	"visa_dot": {"name": "Visa Dot", "cost": 1, "text": "3 progress."},
	"wax_seal": {"name": "Wax Seal", "cost": 2, "text": "6 progress."},
	"corner_notch": {"name": "Corner Notch", "cost": 1, "text": "1 progress, plus 1 for each orthogonal neighbor."},
	"pair_stamp": {"name": "Pair Stamp", "cost": 1, "text": "4 progress with an orthogonal neighbor, otherwise 1."},
	"ledger_line": {"name": "Ledger Line", "cost": 1, "text": "Progress equal to the filled cells in this row."},
	"column_tally": {"name": "Column Tally", "cost": 1, "text": "Progress equal to the filled cells in this column."},
	"echo": {"name": "Echo", "cost": 1, "text": "1 progress, then retriggers the stamp below."},
	"reply": {"name": "Reply", "cost": 1, "text": "1 progress, then retriggers the stamp above."},
	"ripple": {"name": "Ripple", "cost": 2, "text": "2 progress, then retriggers each orthogonal neighbor."},
	"waiver": {"name": "Waiver", "cost": 1, "text": "2 progress, or 5 if the traveler's rule is cancelled."},
	"queue_push": {"name": "Queue Push", "cost": 1, "text": "4 progress on the top row, otherwise 2."},
	"night_fee": {"name": "Night Fee", "cost": 1, "text": "1 progress, plus 1 for each ink spent earlier this turn."},
	"heavy_chop": {"name": "Heavy Chop", "cost": 2, "text": "3 progress, or 6 on the bottom row."},
	"cross_check": {"name": "Cross Check", "cost": 1, "text": "2 progress, plus 2 if another stamp shares the row."},
	"final_notice": {"name": "Final Notice", "cost": 2, "text": "3 progress, plus 3 on the bottom row when the cell above is filled."},
}

const RELICS := {
	"iron_pad": {"name": "Iron Pad", "text": "Duty grants +1 progress for the rest of this night."},
	"deep_well": {"name": "Deep Well", "text": "Start each turn with 4 ink for the rest of this night."},
}

const TRAVELERS := [
	{
		"id": "ada",
		"name": "Ada Quill",
		"rule_text": "Refuses stamps on the top row.",
		"rule": "refuse_top",
		"lane": 0,
		"exemption_row": 0,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "bram",
		"name": "Bram Holt",
		"rule_text": "Yields if column 2 is stamped.",
		"rule": "yield_col2",
		"lane": 1,
		"exemption_row": 1,
		"goal": 24,
		"patience": 5,
	},
	{
		"id": "cira",
		"name": "Cira Venn",
		"rule_text": "Patience drops twice when the bottom row is empty.",
		"rule": "double_patience_if_bottom_empty",
		"lane": 2,
		"exemption_row": 0,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "doss",
		"name": "Doss Kite",
		"rule_text": "Ignores stamps with no orthogonal neighbor.",
		"rule": "ignore_isolated",
		"lane": 0,
		"exemption_row": 2,
		"goal": 20,
		"patience": 5,
	},
]

const LATE_SHIFT := [
	{
		"id": "nell",
		"name": "Nell Parr",
		"form_name": "Struck Margin",
		"rule_text": "Refuses stamps in column 1.",
		"rule": "refuse_col1",
		"lane": 1,
		"exemption_row": 1,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "sol",
		"name": "Sol Wicks",
		"form_name": "Band Ledger",
		"rule_text": "Yields if the middle row is full.",
		"rule": "yield_full_middle",
		"lane": 0,
		"exemption_row": 0,
		"goal": 22,
		"patience": 5,
	},
	{
		"id": "pim",
		"name": "Pim Larke",
		"form_name": "Third-Bell Chit",
		"rule_text": "Patience drops twice when column 3 is empty.",
		"rule": "double_patience_if_col3_empty",
		"lane": 2,
		"exemption_row": 2,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "rue",
		"name": "Rue Calder",
		"form_name": "Corner Ornament",
		"rule_text": "Ignores stamps in the corner boxes.",
		"rule": "ignore_corners",
		"lane": 1,
		"exemption_row": 2,
		"goal": 20,
		"patience": 5,
	},
]


const CLOSING_BELL := [
	{
		"id": "moss",
		"name": "Moss Quen",
		"form_name": "Folded Band",
		"rule_text": "Refuses stamps on the middle row.",
		"rule": "refuse_middle",
		"lane": 2,
		"exemption_row": 1,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "kel",
		"name": "Kel Breck",
		"form_name": "Twin Margin",
		"rule_text": "Yields if column 1 and column 3 are both stamped.",
		"rule": "yield_both_margins",
		"lane": 1,
		"exemption_row": 0,
		"goal": 22,
		"patience": 5,
	},
	{
		"id": "tansy",
		"name": "Tansy Pell",
		"form_name": "Center Void",
		"rule_text": "Patience drops twice when the center cell is empty.",
		"rule": "double_patience_if_center_empty",
		"lane": 0,
		"exemption_row": 2,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "lumen",
		"name": "Lumen Peck",
		"form_name": "Overprint Slip",
		"rule_text": "Ignores a stamp with a stamp directly above it.",
		"rule": "ignore_covered",
		"lane": 2,
		"exemption_row": 2,
		"goal": 20,
		"patience": 5,
	},
]


const ASH_WATCH := [
	{
		"id": "orla",
		"name": "Orla Fen",
		"form_name": "Sealed Foot",
		"rule_text": "Refuses stamps on the bottom row.",
		"rule": "refuse_bottom",
		"lane": 1,
		"exemption_row": 2,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "joss",
		"name": "Joss Mire",
		"form_name": "Pair Chit",
		"rule_text": "Yields if the form holds exactly two stamps.",
		"rule": "yield_exact_two",
		"lane": 0,
		"exemption_row": 0,
		"goal": 22,
		"patience": 5,
	},
	{
		"id": "vetch",
		"name": "Vetch Rowan",
		"form_name": "Row Seal",
		"rule_text": "Patience does not fall when every row is stamped.",
		"rule": "no_drop_if_every_row",
		"lane": 2,
		"exemption_row": 1,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "nim",
		"name": "Nim Harth",
		"form_name": "Tail Slip",
		"rule_text": "The last stamp in the queue scores twice.",
		"rule": "double_last",
		"lane": 0,
		"exemption_row": 2,
		"goal": 22,
		"patience": 5,
	},
]


const GUTTER_LAMP := [
	{
		"id": "ivo",
		"name": "Ivo Dane",
		"form_name": "Blank Spine",
		"rule_text": "Refuses stamps in column 2.",
		"rule": "refuse_col2",
		"lane": 1,
		"exemption_row": 0,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "sera",
		"name": "Sera Dodd",
		"form_name": "Triad Chit",
		"rule_text": "Yields if every column is stamped.",
		"rule": "yield_every_column",
		"lane": 0,
		"exemption_row": 1,
		"goal": 22,
		"patience": 5,
	},
	{
		"id": "wren",
		"name": "Wren Hale",
		"form_name": "Open Margin",
		"rule_text": "Patience drops twice when column 1 is empty.",
		"rule": "double_patience_if_col1_empty",
		"lane": 2,
		"exemption_row": 2,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "kit",
		"name": "Kit Yarrow",
		"form_name": "Neighbor Slip",
		"rule_text": "Ignores a stamp with an orthogonal neighbor.",
		"rule": "ignore_adjacent",
		"lane": 0,
		"exemption_row": 1,
		"goal": 20,
		"patience": 5,
	},
]


const VELLUM_BELL := [
	{
		"id": "edda",
		"name": "Edda Voss",
		"form_name": "Quiet Center",
		"rule_text": "Refuses the center cell.",
		"rule": "refuse_center",
		"lane": 1,
		"exemption_row": 1,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "rho",
		"name": "Rho Tallow",
		"form_name": "Corner Meet",
		"rule_text": "Yields if two stamps meet at a corner.",
		"rule": "yield_diagonal",
		"lane": 0,
		"exemption_row": 0,
		"goal": 22,
		"patience": 5,
	},
	{
		"id": "nessa",
		"name": "Nessa Brin",
		"form_name": "Row Toll",
		"rule_text": "Patience drops once for each empty row.",
		"rule": "drop_per_empty_row",
		"lane": 2,
		"exemption_row": 2,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "lark",
		"name": "Lark Pym",
		"form_name": "Solo Line",
		"rule_text": "Ignores a stamp that shares its row.",
		"rule": "ignore_shared_row",
		"lane": 0,
		"exemption_row": 1,
		"goal": 20,
		"patience": 5,
	},
]


const QUIRE_WATCH := [
	{
		"id": "tess",
		"name": "Tess Quern",
		"form_name": "Far Margin",
		"rule_text": "Refuses stamps in column 3.",
		"rule": "refuse_col3",
		"lane": 2,
		"exemption_row": 0,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "oren",
		"name": "Oren Sallow",
		"form_name": "Side Meet",
		"rule_text": "Yields if two stamps share a side.",
		"rule": "yield_side",
		"lane": 0,
		"exemption_row": 1,
		"goal": 22,
		"patience": 5,
	},
	{
		"id": "bryn",
		"name": "Bryn Solt",
		"form_name": "Column Toll",
		"rule_text": "Patience drops once for each empty column.",
		"rule": "drop_per_empty_column",
		"lane": 1,
		"exemption_row": 2,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "ida",
		"name": "Ida Cress",
		"form_name": "Head Slip",
		"rule_text": "The first stamp in the queue scores twice.",
		"rule": "double_first",
		"lane": 0,
		"exemption_row": 0,
		"goal": 20,
		"patience": 5,
	},
]


const SALT_WATCH := [
	{
		"id": "pell",
		"name": "Pell Voss",
		"form_name": "Tide Bar",
		"rule_text": "A stamp on the middle row scores 0 unless an Exemption is also on the middle row.",
		"rule": "refuse_middle",
		"lane": 1,
		"exemption_row": 1,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "june",
		"name": "June Hart",
		"form_name": "Pair Toll",
		"rule_text": "Patience drops by 2 if two stamps share a number.",
		"rule": "drop_if_shared_number",
		"lane": 2,
		"exemption_row": 2,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "cal",
		"name": "Cal Mire",
		"form_name": "Edge Yield",
		"rule_text": "A stamp on the outer frame yields +3. The center cell does not.",
		"rule": "yield_frame",
		"lane": 0,
		"exemption_row": 0,
		"goal": 22,
		"patience": 5,
	},
	{
		"id": "ned",
		"name": "Ned Quill",
		"form_name": "Last Slip",
		"rule_text": "The last stamp in the queue scores twice.",
		"rule": "double_last",
		"lane": 1,
		"exemption_row": 2,
		"goal": 22,
		"patience": 5,
	},
]


const QUAY_BELL := [
	{
		"id": "mara",
		"name": "Mara Quill",
		"form_name": "First Bar",
		"rule_text": "The first stamp in the queue scores 0 unless an Exemption is on the top row.",
		"rule": "zero_first",
		"lane": 1,
		"exemption_row": 0,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "holt",
		"name": "Holt Venn",
		"form_name": "Center Toll",
		"rule_text": "Patience drops by 2 if the center cell is filled.",
		"rule": "double_patience_if_center_filled",
		"lane": 2,
		"exemption_row": 1,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "dunn",
		"name": "Sera Dunn",
		"form_name": "Corner Yield",
		"rule_text": "A stamp in a corner yields +3. A non-corner edge does not.",
		"rule": "yield_corner",
		"lane": 0,
		"exemption_row": 0,
		"goal": 22,
		"patience": 5,
	},
	{
		"id": "ivo_pell",
		"name": "Ivo Pell",
		"form_name": "Pair Slip",
		"rule_text": "If two stamps share a number, the later one scores twice.",
		"rule": "double_shared_later",
		"lane": 1,
		"exemption_row": 2,
		"goal": 22,
		"patience": 5,
	},
]


const FOLIO_BELL := [
	{
		"id": "ness",
		"name": "Ness Hart",
		"form_name": "Last Bar",
		"rule_text": "The last stamp in the queue scores 0 unless an Exemption is on the bottom row.",
		"rule": "zero_last",
		"lane": 0,
		"exemption_row": 2,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "wynn",
		"name": "Wynn Cress",
		"form_name": "Center Slip",
		"rule_text": "The center stamp scores twice. Other cells score their own number.",
		"rule": "double_center",
		"lane": 2,
		"exemption_row": 1,
		"goal": 22,
		"patience": 5,
	},
	{
		"id": "tam",
		"name": "Tam Quern",
		"form_name": "Column Bar",
		"rule_text": "A stamp in column 1 scores 0 when that column holds another stamp. A lone stamp in column 1 counts.",
		"rule": "refuse_stacked_col1",
		"lane": 0,
		"exemption_row": 0,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "sallow",
		"name": "Pell Sallow",
		"form_name": "Gap Toll",
		"rule_text": "Patience drops by 2 if two stamps have an empty cell between them.",
		"rule": "drop_if_queue_gap",
		"lane": 2,
		"exemption_row": 2,
		"goal": 18,
		"patience": 5,
	},
]


const WICK_BELL := [
	{
		"id": "odell",
		"name": "Odell Voss",
		"form_name": "Row Bar",
		"rule_text": "A stamp on the bottom row scores 0 when that row holds another stamp. A lone bottom-row stamp counts.",
		"rule": "refuse_stacked_bottom",
		"lane": 1,
		"exemption_row": 2,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "cress",
		"name": "Cress Hart",
		"form_name": "First Slip",
		"rule_text": "The first stamp in the queue scores twice when a later stamp follows it. A lone stamp scores its own number.",
		"rule": "double_first_if_followed",
		"lane": 0,
		"exemption_row": 0,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "jun",
		"name": "Jun Solt",
		"form_name": "Pair Bar",
		"rule_text": "If two stamps share a number, the later one scores 0. The earlier stamp scores its own number.",
		"rule": "zero_shared_later",
		"lane": 2,
		"exemption_row": 2,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "ives",
		"name": "Ives Mire",
		"form_name": "Empty Yield",
		"rule_text": "Each empty cell adds 1 to every filled stamp's own progress.",
		"rule": "yield_empty",
		"lane": 1,
		"exemption_row": 0,
		"goal": 22,
		"patience": 5,
	},
]


const MARGIN_BELL := [
	{
		"id": "nim_voss",
		"name": "Nim Voss",
		"form_name": "Side Bar",
		"rule_text": "A stamp scores 0 when it shares a side with an earlier stamp. The earlier stamp scores its own number.",
		"rule": "zero_side_later",
		"lane": 1,
		"exemption_row": 0,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "orla_quill",
		"name": "Orla Quill",
		"form_name": "Last Toll",
		"rule_text": "Patience drops by 2 if the last filled cell is in column 3.",
		"rule": "double_patience_if_last_col3",
		"lane": 0,
		"exemption_row": 2,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "bram_hart",
		"name": "Bram Hart",
		"form_name": "Frame Slip",
		"rule_text": "A stamp on the outer frame scores twice when the center is filled. The center scores its own number.",
		"rule": "double_frame_if_center",
		"lane": 2,
		"exemption_row": 0,
		"goal": 22,
		"patience": 5,
	},
	{
		"id": "sable",
		"name": "Sable Solt",
		"form_name": "Gap Yield",
		"rule_text": "If two filled stamps have an empty cell between them, each of those stamps scores +2. Stamps that are not part of a gap score their own number.",
		"rule": "yield_queue_gap",
		"lane": 1,
		"exemption_row": 2,
		"goal": 22,
		"patience": 5,
	},
]


const INDEX_BELL := [
	{
		"id": "len_quill",
		"name": "Len Quill",
		"form_name": "Corner Bar",
		"rule_text": "A stamp scores 0 only when it touches an earlier stamp at a corner and does not share a side with that same earlier stamp.",
		"rule": "zero_corner_later",
		"lane": 0,
		"exemption_row": 0,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "ada_pell",
		"name": "Ada Pell",
		"form_name": "First Toll",
		"rule_text": "Patience drops by 2 when the first filled cell is in column 1.",
		"rule": "double_patience_if_first_col1",
		"lane": 2,
		"exemption_row": 2,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "wynn_hart",
		"name": "Wynn Hart",
		"form_name": "Full Row",
		"rule_text": "A stamp scores twice only when its own row is full. A stamp in a row that is not full scores its own number.",
		"rule": "double_full_row",
		"lane": 1,
		"exemption_row": 0,
		"goal": 24,
		"patience": 5,
	},
	{
		"id": "sera_voss",
		"name": "Sera Voss",
		"form_name": "End Match",
		"rule_text": "If the first and last filled stamps show the same number, every filled stamp scores +2. A lone stamp scores its own number.",
		"rule": "yield_end_match",
		"lane": 0,
		"exemption_row": 2,
		"goal": 20,
		"patience": 5,
	},
]


const LEDGER_BELL := [
	{
		"id": "nell_voss",
		"name": "Nell Voss",
		"form_name": "Wing Pair",
		"rule_text": "When column 1 and column 3 of the same row are both filled, those two stamps each score +3 once. Column 2 of that row scores its own number.",
		"rule": "yield_row_wings",
		"lane": 1,
		"exemption_row": 2,
		"goal": 22,
		"patience": 5,
	},
	{
		"id": "pell_dane",
		"name": "Pell Dane",
		"form_name": "Three Toll",
		"rule_text": "Patience drops by 2 when exactly three cells are filled.",
		"rule": "drop_if_exact_three",
		"lane": 0,
		"exemption_row": 2,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "ida_mire",
		"name": "Ida Mire",
		"form_name": "Low Slip",
		"rule_text": "When two or more stamps are filled, the earliest stamp among those showing the lowest number scores twice. A lone stamp scores its own number.",
		"rule": "double_lowest_earliest",
		"lane": 2,
		"exemption_row": 0,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "sable_quern",
		"name": "Sable Quern",
		"form_name": "After Gap",
		"rule_text": "A stamp scores twice only when the queue cell immediately before it is empty and some earlier cell is filled.",
		"rule": "double_after_gap",
		"lane": 0,
		"exemption_row": 0,
		"goal": 21,
		"patience": 5,
	},
]


const SPINE_BELL := [
	{
		"id": "wynn_quill",
		"name": "Wynn Quill",
		"form_name": "High Slip",
		"rule_text": "When two or more stamps are filled, the earliest stamp among those showing the highest number scores twice. A lone stamp scores its own number.",
		"rule": "double_highest_earliest",
		"lane": 1,
		"exemption_row": 0,
		"goal": 22,
		"patience": 5,
	},
	{
		"id": "ada_hart",
		"name": "Ada Hart",
		"form_name": "Four Toll",
		"rule_text": "Patience drops by 2 when exactly four cells are filled.",
		"rule": "drop_if_exact_four",
		"lane": 2,
		"exemption_row": 2,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "bram_solt",
		"name": "Bram Solt",
		"form_name": "Before Gap",
		"rule_text": "A stamp scores twice only when the queue cell immediately after it is empty and some later cell is filled.",
		"rule": "double_before_gap",
		"lane": 0,
		"exemption_row": 0,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "sera_pell",
		"name": "Sera Pell",
		"form_name": "Column Pair",
		"rule_text": "When two filled stamps in the same column have exactly one empty cell between them, those two stamps each score +3 once. A third stamp in that column does not get the bonus unless it is one of such a pair.",
		"rule": "yield_column_pair",
		"lane": 1,
		"exemption_row": 2,
		"goal": 24,
		"patience": 5,
	},
]


const HEADBAND_BELL := [
	{
		"id": "len_hart",
		"name": "Len Hart",
		"form_name": "Open Wing",
		"rule_text": "When column 1 and column 3 of the same row are both filled and column 2 of that row is empty, those two stamps each score +3 once. If column 2 of that row is filled, that row gets no bonus.",
		"rule": "yield_open_wing",
		"lane": 0,
		"exemption_row": 0,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "joss_pell",
		"name": "Joss Pell",
		"form_name": "Five Toll",
		"rule_text": "Patience drops by 2 when exactly five cells are filled.",
		"rule": "drop_if_exact_five",
		"lane": 2,
		"exemption_row": 2,
		"goal": 14,
		"patience": 5,
	},
	{
		"id": "ida_quill",
		"name": "Ida Quill",
		"form_name": "Late High",
		"rule_text": "When two or more stamps are filled, the latest stamp among those showing the highest number scores twice. A lone stamp scores its own number.",
		"rule": "double_highest_latest",
		"lane": 1,
		"exemption_row": 0,
		"goal": 22,
		"patience": 5,
	},
	{
		"id": "cal_quern",
		"name": "Cal Quern",
		"form_name": "Diagonal Pair",
		"rule_text": "When two filled stamps on one three-cell diagonal have exactly one empty cell between them, those two each score +3 once. A filled center means neither pair qualifies.",
		"rule": "yield_diagonal_pair",
		"lane": 1,
		"exemption_row": 1,
		"goal": 20,
		"patience": 5,
	},
]


const CLASP_BELL := [
	{
		"id": "noll_hart",
		"name": "Noll Hart",
		"form_name": "Late Low",
		"rule_text": "When two or more stamps are filled, the latest stamp among those showing the lowest number scores twice. A lone stamp scores its own number.",
		"rule": "double_lowest_latest",
		"lane": 0,
		"exemption_row": 2,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "hugh_pell",
		"name": "Hugh Pell",
		"form_name": "Six Toll",
		"rule_text": "Patience drops by 2 when exactly six cells are filled.",
		"rule": "drop_if_exact_six",
		"lane": 1,
		"exemption_row": 0,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "fenn_hart",
		"name": "Fenn Hart",
		"form_name": "Full Column",
		"rule_text": "A stamp scores twice only when its own column is full. A stamp in a column that is not full scores its own number.",
		"rule": "double_full_column",
		"lane": 2,
		"exemption_row": 1,
		"goal": 22,
		"patience": 5,
	},
	{
		"id": "rue_hart",
		"name": "Rue Hart",
		"form_name": "Side Slip",
		"rule_text": "When a stamp shares a side with an earlier stamp, the later stamp scores twice. The earlier stamp scores its own number.",
		"rule": "double_side_later",
		"lane": 0,
		"exemption_row": 2,
		"goal": 18,
		"patience": 5,
	},
]


const SIGNATURE_BELL := [
	{
		"id": "dory_hart",
		"name": "Dory Hart",
		"form_name": "Seven Toll",
		"rule_text": "Patience drops by 2 when exactly seven cells are filled.",
		"rule": "drop_if_exact_seven",
		"lane": 2,
		"exemption_row": 2,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "lin_pell",
		"name": "Lin Pell",
		"form_name": "Lone Column",
		"rule_text": "A stamp scores twice only when it is the only filled stamp in its column. If that column holds another stamp, every stamp in the column scores its own number.",
		"rule": "double_lone_column",
		"lane": 0,
		"exemption_row": 0,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "opal_quill",
		"name": "Opal Quill",
		"form_name": "Side Pay",
		"rule_text": "Each stamp that shares a side with another filled stamp scores +3 once. A stamp that shares two sides still scores +3 once. A corner-only touch does not count. A lone stamp scores its own number.",
		"rule": "yield_side_pay",
		"lane": 1,
		"exemption_row": 1,
		"goal": 22,
		"patience": 5,
	},
	{
		"id": "holt_quern",
		"name": "Holt Quern",
		"form_name": "Next Fill",
		"rule_text": "A stamp scores twice only when the queue cell immediately after it is filled. A stamp whose next cell is empty scores its own number. The bottom-right cell has no cell after it, so it does not double.",
		"rule": "double_next_filled",
		"lane": 1,
		"exemption_row": 2,
		"goal": 16,
		"patience": 5,
	},
]


const CATCHWORD_BELL := [
	{
		"id": "gwyn_brant",
		"name": "Gwyn Brant",
		"form_name": "Eight Toll",
		"rule_text": "Patience drops by 2 when exactly eight cells are filled.",
		"rule": "drop_if_exact_eight",
		"lane": 2,
		"exemption_row": 0,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "hester_keel",
		"name": "Hester Keel",
		"form_name": "Prior Fill",
		"rule_text": "A stamp scores twice only when the queue cell immediately before it is filled. A stamp whose previous cell is empty scores its own number. The top-left cell has no cell before it, so it does not double.",
		"rule": "double_prior_filled",
		"lane": 0,
		"exemption_row": 2,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "idris_reed",
		"name": "Idris Reed",
		"form_name": "Corner Pay",
		"rule_text": "Each stamp that has at least one filled diagonal neighbor scores +3 once. A stamp with two or more diagonal neighbors still scores +3 once. An orthogonal neighbor does not count. A lone stamp scores its own number.",
		"rule": "yield_corner_pay",
		"lane": 1,
		"exemption_row": 1,
		"goal": 22,
		"patience": 5,
	},
	{
		"id": "colm_brigg",
		"name": "Colm Brigg",
		"form_name": "Short Row",
		"rule_text": "A stamp scores twice only when its own row holds exactly two filled stamps. Both stamps in that row double. A row with one stamp scores that stamp's own number. A full row of three scores each stamp's own number.",
		"rule": "double_short_row",
		"lane": 0,
		"exemption_row": 0,
		"goal": 18,
		"patience": 5,
	},
]


class NightState:
	extends RefCounted
	var seed: int = 1
	var rng_state: int = 1
	var next_iid: int = 0
	var library: Array = []
	var draw_pile: Array = []
	var discard: Array = []
	var hand: Array = []
	var form: Array = []
	var relic_id: String = ""
	var shift: int = 0
	var traveler_index: int = 0
	var phase: String = "play"
	var progress: int = 0
	var patience: int = 0
	var ink: int = 0
	var ink_spent: int = 0
	var turn_number: int = 0
	var turn_progress: int = 0
	var uncapped_turn_progress: int = 0
	var rule_cancelled: bool = false
	var resolving: bool = false
	var chain_count: int = 0
	var chain_stopped: bool = false
	var resolver_steps: int = 0
	var chain_note_logged: bool = false
	var encounters_cleared: int = 0
	var draft_options: Array = []
	var relic_options: Array = []
	var log: Array = []
	var silent: bool = false
	var last_chain_count: int = 0
	var last_chain_stopped: bool = false
	var last_progress_gained: int = 0
	var last_uncapped_progress: int = 0
	var last_resolver_steps: int = 0
	var last_patience_loss: int = 0
	var last_won: bool = false
	var last_lost: bool = false


static func _canonical_shift(shift_index: int) -> int:
	if shift_index == SHIFT_LATE:
		return SHIFT_LATE
	if shift_index == SHIFT_CLOSING:
		return SHIFT_CLOSING
	if shift_index == SHIFT_ASH:
		return SHIFT_ASH
	if shift_index == SHIFT_GUTTER:
		return SHIFT_GUTTER
	if shift_index == SHIFT_VELLUM:
		return SHIFT_VELLUM
	if shift_index == SHIFT_QUIRE:
		return SHIFT_QUIRE
	if shift_index == SHIFT_SALT:
		return SHIFT_SALT
	if shift_index == SHIFT_QUAY:
		return SHIFT_QUAY
	if shift_index == SHIFT_FOLIO:
		return SHIFT_FOLIO
	if shift_index == SHIFT_WICK:
		return SHIFT_WICK
	if shift_index == SHIFT_MARGIN:
		return SHIFT_MARGIN
	if shift_index == SHIFT_INDEX:
		return SHIFT_INDEX
	if shift_index == SHIFT_LEDGER:
		return SHIFT_LEDGER
	if shift_index == SHIFT_SPINE:
		return SHIFT_SPINE
	if shift_index == SHIFT_HEADBAND:
		return SHIFT_HEADBAND
	if shift_index == SHIFT_CLASP:
		return SHIFT_CLASP
	if shift_index == SHIFT_SIGNATURE:
		return SHIFT_SIGNATURE
	if shift_index == SHIFT_CATCHWORD:
		return SHIFT_CATCHWORD
	return SHIFT_FIRST


static func new_run(seed_value: int, shift_index: int = SHIFT_FIRST) -> NightState:
	var state = NightState.new()
	state.seed = seed_value
	state.library = []
	state.log = []
	state.relic_id = ""
	state.shift = _canonical_shift(shift_index)
	state.traveler_index = 0
	state.encounters_cleared = 0
	state.next_iid = 0
	for card_id in STARTING_DECK:
		_add_library_card(state, String(card_id))
	if state.shift == SHIFT_CATCHWORD:
		_log(state, "The catchword bell begins. Seed %d." % state.seed)
	elif state.shift == SHIFT_SIGNATURE:
		_log(state, "The signature bell begins. Seed %d." % state.seed)
	elif state.shift == SHIFT_CLASP:
		_log(state, "The clasp bell begins. Seed %d." % state.seed)
	elif state.shift == SHIFT_HEADBAND:
		_log(state, "The headband bell begins. Seed %d." % state.seed)
	elif state.shift == SHIFT_SPINE:
		_log(state, "The spine bell begins. Seed %d." % state.seed)
	elif state.shift == SHIFT_LEDGER:
		_log(state, "The ledger bell begins. Seed %d." % state.seed)
	elif state.shift == SHIFT_INDEX:
		_log(state, "The index bell begins. Seed %d." % state.seed)
	elif state.shift == SHIFT_MARGIN:
		_log(state, "The margin bell begins. Seed %d." % state.seed)
	elif state.shift == SHIFT_WICK:
		_log(state, "The wick bell begins. Seed %d." % state.seed)
	elif state.shift == SHIFT_FOLIO:
		_log(state, "The folio bell begins. Seed %d." % state.seed)
	elif state.shift == SHIFT_QUAY:
		_log(state, "The quay bell begins. Seed %d." % state.seed)
	elif state.shift == SHIFT_SALT:
		_log(state, "The salt watch begins. Seed %d." % state.seed)
	elif state.shift == SHIFT_QUIRE:
		_log(state, "The quire watch begins. Seed %d." % state.seed)
	elif state.shift == SHIFT_VELLUM:
		_log(state, "The vellum bell begins. Seed %d." % state.seed)
	elif state.shift == SHIFT_GUTTER:
		_log(state, "The gutter lamp begins. Seed %d." % state.seed)
	elif state.shift == SHIFT_ASH:
		_log(state, "The ash watch begins. Seed %d." % state.seed)
	elif state.shift == SHIFT_CLOSING:
		_log(state, "The closing bell begins. Seed %d." % state.seed)
	elif state.shift == SHIFT_LATE:
		_log(state, "The late shift begins. Seed %d." % state.seed)
	else:
		_log(state, "Night shift begins. Seed %d." % state.seed)
	_begin_encounter(state)
	return state


static func scripted_encounter(seed_value: int, traveler_index: int, hand_cards: Array, ink_value: int, shift_index: int = SHIFT_FIRST) -> NightState:
	var state = NightState.new()
	state.seed = seed_value
	state.rng_state = 1
	state.shift = _canonical_shift(shift_index)
	state.traveler_index = clampi(traveler_index, 0, _roster(state).size() - 1)
	state.phase = "play"
	state.progress = 0
	state.patience = int(traveler(state)["patience"])
	state.ink = ink_value
	state.ink_spent = 0
	state.form = blank_form()
	state.turn_number = 1
	state.relic_id = ""
	state.resolving = false
	state.rule_cancelled = false
	state.library = []
	state.hand = []
	state.draw_pile = []
	state.discard = []
	for card_id in hand_cards:
		var iid = _add_library_card(state, String(card_id))
		state.hand.append(iid)
	return state


static func restart_encounter(state: NightState) -> void:
	var roster = _roster(state)
	if state.traveler_index >= roster.size():
		state.traveler_index = roster.size() - 1
	state.log = []
	_log(state, "The encounter is restarted.")
	_begin_encounter(state)


static func shift_label(state: NightState) -> String:
	if state.shift == SHIFT_CATCHWORD:
		return "Catchword bell"
	if state.shift == SHIFT_SIGNATURE:
		return "Signature bell"
	if state.shift == SHIFT_CLASP:
		return "Clasp bell"
	if state.shift == SHIFT_HEADBAND:
		return "Headband bell"
	if state.shift == SHIFT_SPINE:
		return "Spine bell"
	if state.shift == SHIFT_LEDGER:
		return "Ledger bell"
	if state.shift == SHIFT_INDEX:
		return "Index bell"
	if state.shift == SHIFT_MARGIN:
		return "Margin bell"
	if state.shift == SHIFT_WICK:
		return "Wick bell"
	if state.shift == SHIFT_FOLIO:
		return "Folio bell"
	if state.shift == SHIFT_QUAY:
		return "Quay bell"
	if state.shift == SHIFT_SALT:
		return "Salt watch"
	if state.shift == SHIFT_QUIRE:
		return "Quire watch"
	if state.shift == SHIFT_VELLUM:
		return "Vellum bell"
	if state.shift == SHIFT_GUTTER:
		return "Gutter lamp"
	if state.shift == SHIFT_ASH:
		return "Ash watch"
	if state.shift == SHIFT_CLOSING:
		return "Closing bell"
	if state.shift == SHIFT_LATE:
		return "Late shift"
	return "Act 1"


static func roster_size(state: NightState) -> int:
	return _roster(state).size()


static func traveler(state: NightState) -> Dictionary:
	var roster = _roster(state)
	var index = state.traveler_index
	if index < 0:
		index = 0
	if index >= roster.size():
		index = roster.size() - 1
	return roster[index]


static func _roster(state: NightState) -> Array:
	if state.shift == SHIFT_CATCHWORD:
		return CATCHWORD_BELL
	if state.shift == SHIFT_SIGNATURE:
		return SIGNATURE_BELL
	if state.shift == SHIFT_CLASP:
		return CLASP_BELL
	if state.shift == SHIFT_HEADBAND:
		return HEADBAND_BELL
	if state.shift == SHIFT_SPINE:
		return SPINE_BELL
	if state.shift == SHIFT_LEDGER:
		return LEDGER_BELL
	if state.shift == SHIFT_INDEX:
		return INDEX_BELL
	if state.shift == SHIFT_MARGIN:
		return MARGIN_BELL
	if state.shift == SHIFT_WICK:
		return WICK_BELL
	if state.shift == SHIFT_FOLIO:
		return FOLIO_BELL
	if state.shift == SHIFT_QUAY:
		return QUAY_BELL
	if state.shift == SHIFT_SALT:
		return SALT_WATCH
	if state.shift == SHIFT_QUIRE:
		return QUIRE_WATCH
	if state.shift == SHIFT_VELLUM:
		return VELLUM_BELL
	if state.shift == SHIFT_GUTTER:
		return GUTTER_LAMP
	if state.shift == SHIFT_ASH:
		return ASH_WATCH
	if state.shift == SHIFT_CLOSING:
		return CLOSING_BELL
	if state.shift == SHIFT_LATE:
		return LATE_SHIFT
	return TRAVELERS


static func ink_per_turn(state: NightState) -> int:
	if state.relic_id == RELIC_DEEP_WELL:
		return 4
	return BASE_INK


static func blank_form() -> Array:
	var form: Array = []
	for _row in 3:
		var line: Array = []
		line.resize(3)
		for col in 3:
			line[col] = null
		form.append(line)
	return form


static func card_id_of(state: NightState, iid: int) -> String:
	for card in state.library:
		if int(card["iid"]) == iid:
			return String(card["card_id"])
	return ""


static func can_play(state: NightState, hand_index: int, row: int, col: int) -> bool:
	if state == null or state.resolving or state.phase != "play":
		return false
	if state.ink <= 0:
		return false
	if hand_index < 0 or hand_index >= state.hand.size():
		return false
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] != null:
		return false
	var card_id = card_id_of(state, int(state.hand[hand_index]))
	if card_id == "" or not CARDS.has(card_id):
		return false
	if int(CARDS[card_id]["cost"]) > state.ink:
		return false
	return true


static func place_stamp(state: NightState, hand_index: int, row: int, col: int) -> bool:
	if not can_play(state, hand_index, row, col):
		return false
	var iid = int(state.hand[hand_index])
	var card_id = card_id_of(state, iid)
	var cost = int(CARDS[card_id]["cost"])
	state.hand.remove_at(hand_index)
	state.discard.append(iid)
	state.form[row][col] = {"card_id": card_id, "spent_before": state.ink_spent}
	state.ink -= cost
	state.ink_spent += cost
	return true


static func play_stamp(state: NightState, hand_index: int, row: int, col: int) -> bool:
	if not place_stamp(state, hand_index, row, col):
		return false
	if state.ink <= 0 or not has_legal_play(state):
		end_turn(state)
	return true


static func has_legal_play(state: NightState) -> bool:
	if state.phase != "play" or state.resolving or state.ink <= 0:
		return false
	var open_cell = false
	for row in 3:
		for col in 3:
			if state.form[row][col] == null:
				open_cell = true
				break
		if open_cell:
			break
	if not open_cell:
		return false
	for iid in state.hand:
		var card_id = card_id_of(state, int(iid))
		if card_id != "" and int(CARDS[card_id]["cost"]) <= state.ink:
			return true
	return false


static func end_turn(state: NightState) -> void:
	if state.phase != "play" or state.resolving:
		return
	state.resolving = true
	var result = resolve_turn(state, false)
	state.resolving = false
	_apply_result(state, result)


static func resolve_turn(state: NightState, quiet: bool = false) -> Dictionary:
	var hush = quiet or state.silent
	state.chain_count = 0
	state.chain_stopped = false
	state.resolver_steps = 0
	state.chain_note_logged = false
	state.turn_progress = 0
	state.uncapped_turn_progress = 0
	state.rule_cancelled = exemption_active(state)
	if state.rule_cancelled and not hush:
		_log(state, "Exemption cancels %s's rule." % traveler(state)["name"])
	for row in 3:
		for col in 3:
			if state.form[row][col] == null:
				continue
			_resolve_stamp(state, row, col, hush)
			if state.resolver_steps >= HARD_STEP_LIMIT:
				state.chain_stopped = true
				break
		if state.resolver_steps >= HARD_STEP_LIMIT:
			break
	_apply_post_rule(state, hush)
	state.uncapped_turn_progress = state.turn_progress
	if state.turn_progress > PROGRESS_CAP:
		if not hush:
			_log(state, "Progress stops at the cap (%d)." % PROGRESS_CAP)
		state.turn_progress = PROGRESS_CAP
	state.progress += state.turn_progress
	var goal = int(traveler(state)["goal"])
	var won = state.progress >= goal
	var loss = 0
	if not won:
		loss = patience_loss(state)
		state.patience -= loss
		if not hush:
			if loss == 0 and hold_active(state):
				_log(state, "Hold delays %s. Patience stays %d." % [traveler(state)["name"], state.patience])
			elif loss == 0:
				_log(state, "Every row is stamped. %s waits. Patience stays %d." % [traveler(state)["name"], state.patience])
			else:
				_log(state, "Patience falls by %d to %d." % [loss, state.patience])
	elif not hush:
		_log(state, "%s is cleared." % traveler(state)["name"])
	if not hush:
		_log(state, "Progress %d / %d." % [state.progress, goal])
	state.form = blank_form()
	state.last_chain_count = state.chain_count
	state.last_chain_stopped = state.chain_stopped
	state.last_progress_gained = state.turn_progress
	state.last_uncapped_progress = state.uncapped_turn_progress
	state.last_resolver_steps = state.resolver_steps
	state.last_patience_loss = loss
	state.last_won = won
	state.last_lost = (not won) and state.patience <= 0
	return {
		"progress_gained": state.turn_progress,
		"uncapped_progress": state.uncapped_turn_progress,
		"won": won,
		"lost": state.last_lost,
		"patience_loss": loss,
		"chain_count": state.chain_count,
		"chain_stopped": state.chain_stopped,
		"resolver_steps": state.resolver_steps,
	}


static func stamp_progress(state: NightState, card_id: String, row: int, col: int) -> int:
	var amount = raw_stamp_progress(state, card_id, row, col)
	if state.rule_cancelled:
		return amount
	var rule = String(traveler(state)["rule"])
	if rule == "refuse_top" and row == 0:
		return 0
	if rule == "refuse_col1" and col == 0:
		return 0
	if rule == "refuse_col2" and col == 1:
		return 0
	if rule == "refuse_middle" and row == 1:
		return 0
	if rule == "refuse_bottom" and row == 2:
		return 0
	if rule == "ignore_isolated" and orthogonal_count(state, row, col) == 0:
		return 0
	if rule == "ignore_corners" and _is_corner(row, col):
		return 0
	if rule == "ignore_covered" and _is_covered(state, row, col):
		return 0
	if rule == "ignore_adjacent" and orthogonal_count(state, row, col) > 0:
		return 0
	if rule == "refuse_center" and row == 1 and col == 1:
		return 0
	if rule == "refuse_col3" and col == 2:
		return 0
	if rule == "ignore_shared_row" and row_fill_count(state, row) > 1:
		return 0
	if rule == "zero_first" and _is_queue_head(state, row, col):
		return 0
	if rule == "double_last" and _is_queue_tail(state, row, col):
		return amount * 2
	if rule == "double_first" and _is_queue_head(state, row, col):
		return amount * 2
	if rule == "double_shared_later" and _shares_number_with_earlier(state, row, col):
		return amount * 2
	if rule == "yield_frame" and not (row == 1 and col == 1):
		return amount + 3
	if rule == "yield_corner" and _is_corner(row, col):
		return amount + 3
	if rule == "zero_last" and _is_queue_tail(state, row, col):
		return 0
	if rule == "double_center" and row == 1 and col == 1:
		return amount * 2
	if rule == "refuse_stacked_col1" and col == 0 and col_fill_count(state, 0) > 1:
		return 0
	if rule == "refuse_stacked_bottom" and row == 2 and row_fill_count(state, 2) > 1:
		return 0
	if rule == "double_first_if_followed" and _is_queue_head(state, row, col) and not _is_queue_tail(state, row, col):
		return amount * 2
	if rule == "zero_shared_later" and _shares_number_with_earlier(state, row, col):
		return 0
	if rule == "yield_empty":
		return amount + _empty_cell_count(state)
	if rule == "zero_side_later" and _shares_side_with_earlier(state, row, col):
		return 0
	if rule == "double_frame_if_center" and _center_filled(state) and not (row == 1 and col == 1):
		return amount * 2
	if rule == "yield_queue_gap" and _queue_has_gap(state):
		return amount + 2
	if rule == "zero_corner_later" and _corners_earlier_without_side(state, row, col):
		return 0
	if rule == "double_full_row" and row_fill_count(state, row) == 3:
		return amount * 2
	if rule == "yield_end_match" and _ends_share_number(state):
		return amount + 2
	if rule == "yield_row_wings" and (col == 0 or col == 2) and _row_wings_filled(state, row):
		return amount + 3
	if rule == "double_lowest_earliest" and _is_earliest_lowest(state, row, col):
		return amount * 2
	if rule == "double_after_gap" and _follows_filled_gap(state, row, col):
		return amount * 2
	if rule == "double_highest_earliest" and _is_earliest_highest(state, row, col):
		return amount * 2
	if rule == "double_before_gap" and _precedes_filled_gap(state, row, col):
		return amount * 2
	if rule == "yield_column_pair" and _is_column_pair_stamp(state, row, col):
		return amount + 3
	if rule == "yield_open_wing" and (col == 0 or col == 2) and _row_open_wings(state, row):
		return amount + 3
	if rule == "double_highest_latest" and _is_latest_highest(state, row, col):
		return amount * 2
	if rule == "yield_diagonal_pair" and _is_diagonal_pair_stamp(state, row, col):
		return amount + 3
	if rule == "double_lowest_latest" and _is_latest_lowest(state, row, col):
		return amount * 2
	if rule == "double_full_column" and col_fill_count(state, col) == 3:
		return amount * 2
	if rule == "double_side_later" and _shares_side_with_earlier(state, row, col):
		return amount * 2
	if rule == "double_lone_column" and col_fill_count(state, col) == 1:
		return amount * 2
	if rule == "yield_side_pay" and orthogonal_count(state, row, col) > 0:
		return amount + 3
	if rule == "double_next_filled" and _next_cell_filled(state, row, col):
		return amount * 2
	if rule == "double_prior_filled" and _prev_cell_filled(state, row, col):
		return amount * 2
	if rule == "yield_corner_pay" and _diagonal_count(state, row, col) > 0:
		return amount + 3
	if rule == "double_short_row" and row_fill_count(state, row) == 2:
		return amount * 2
	return amount


static func raw_stamp_progress(state: NightState, card_id: String, row: int, col: int) -> int:
	var spent_before = 0
	var stamp = state.form[row][col]
	if stamp != null:
		spent_before = int(stamp["spent_before"])
	match card_id:
		"duty":
			var duty_amount = 4 if row == 2 else 2
			if state.relic_id == RELIC_IRON_PAD:
				duty_amount += 1
			return duty_amount
		"exemption", "hold", "echo", "reply":
			return 1
		"surcharge":
			var surcharge_amount = 2
			if row > 0 and state.form[row - 1][col] != null:
				surcharge_amount += 3
			return surcharge_amount
		"entry_mark":
			return 2
		"visa_dot":
			return 3
		"wax_seal":
			return 6
		"corner_notch":
			return 1 + orthogonal_count(state, row, col)
		"pair_stamp":
			return 4 if orthogonal_count(state, row, col) > 0 else 1
		"ledger_line":
			return row_fill_count(state, row)
		"column_tally":
			return col_fill_count(state, col)
		"ripple":
			return 2
		"waiver":
			return 5 if state.rule_cancelled else 2
		"queue_push":
			return 4 if row == 0 else 2
		"night_fee":
			return 1 + spent_before
		"heavy_chop":
			return 6 if row == 2 else 3
		"cross_check":
			var others = row_fill_count(state, row) - 1
			return 2 + (2 if others > 0 else 0)
		"final_notice":
			var notice = 3
			if row == 2 and state.form[row - 1][col] != null:
				notice += 3
			return notice
		_:
			return 0


static func preview_progress(state: NightState, card_id: String, row: int, col: int) -> int:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return -1
	if state.form[row][col] != null:
		return -1
	var sim = clone(state)
	sim.form[row][col] = {"card_id": card_id, "spent_before": state.ink_spent}
	sim.rule_cancelled = exemption_active(sim)
	return stamp_progress(sim, card_id, row, col)


static func patience_loss(state: NightState) -> int:
	if hold_active(state):
		return 0
	var loss = 1
	if not state.rule_cancelled:
		var rule = String(traveler(state)["rule"])
		if rule == "double_patience_if_bottom_empty" and not row_has_stamp(state, 2):
			loss = 2
		elif rule == "double_patience_if_col3_empty" and not column_has_stamp(state, 2):
			loss = 2
		elif rule == "double_patience_if_center_empty" and not _center_filled(state):
			loss = 2
		elif rule == "double_patience_if_col1_empty" and not column_has_stamp(state, 0):
			loss = 2
		elif rule == "no_drop_if_every_row" and _every_row_stamped(state):
			loss = 0
		elif rule == "drop_per_empty_row":
			loss = _empty_row_count(state)
		elif rule == "drop_per_empty_column":
			loss = _empty_column_count(state)
		elif rule == "drop_if_shared_number" and _shares_a_number(state):
			loss = 2
		elif rule == "double_patience_if_center_filled" and _center_filled(state):
			loss = 2
		elif rule == "drop_if_queue_gap" and _queue_has_gap(state):
			loss = 2
		elif rule == "double_patience_if_last_col3" and _last_filled_column(state) == 2:
			loss = 2
		elif rule == "double_patience_if_first_col1" and _first_filled_column(state) == 0:
			loss = 2
		elif rule == "drop_if_exact_three" and _stamp_count(state) == 3:
			loss = 2
		elif rule == "drop_if_exact_four" and _stamp_count(state) == 4:
			loss = 2
		elif rule == "drop_if_exact_five" and _stamp_count(state) == 5:
			loss = 2
		elif rule == "drop_if_exact_six" and _stamp_count(state) == 6:
			loss = 2
		elif rule == "drop_if_exact_seven" and _stamp_count(state) == 7:
			loss = 2
		elif rule == "drop_if_exact_eight" and _stamp_count(state) == 8:
			loss = 2
	return loss


static func exemption_active(state: NightState) -> bool:
	var row = int(traveler(state)["exemption_row"])
	for col in 3:
		var stamp = state.form[row][col]
		if stamp != null and String(stamp["card_id"]) == "exemption":
			return true
	return false


static func hold_active(state: NightState) -> bool:
	var lane = int(traveler(state)["lane"])
	for row in 3:
		var stamp = state.form[row][lane]
		if stamp != null and String(stamp["card_id"]) == "hold":
			return true
	return false


static func choose_relic(state: NightState, relic_id: String) -> bool:
	if state.phase != "relic":
		return false
	var allowed = false
	for option in state.relic_options:
		if String(option) == relic_id:
			allowed = true
	if not allowed or not RELICS.has(relic_id):
		return false
	state.relic_id = relic_id
	_log(state, "Relic taken: %s." % RELICS[relic_id]["name"])
	_open_draft(state)
	return true


static func choose_draft(state: NightState, index: int) -> bool:
	if state.phase != "draft":
		return false
	if index < 0 or index >= state.draft_options.size():
		return false
	var card_id = String(state.draft_options[index])
	_add_library_card(state, card_id)
	_log(state, "Drafted %s." % CARDS[card_id]["name"])
	state.traveler_index += 1
	_begin_encounter(state)
	return true


static func apply_action(state: NightState, action: Dictionary) -> bool:
	var kind = String(action.get("type", ""))
	if kind == "play":
		return play_stamp(state, int(action["hand_index"]), int(action["row"]), int(action["col"]))
	if kind == "end":
		if state.phase != "play":
			return false
		end_turn(state)
		return true
	if kind == "draft":
		return choose_draft(state, int(action["index"]))
	if kind == "relic":
		return choose_relic(state, String(action["id"]))
	return false


static func note(state: NightState, message: String) -> void:
	_log(state, message)


static func clone(state: NightState) -> NightState:
	var copy = NightState.new()
	copy.seed = state.seed
	copy.rng_state = state.rng_state
	copy.next_iid = state.next_iid
	copy.library = []
	for card in state.library:
		copy.library.append({"iid": int(card["iid"]), "card_id": String(card["card_id"])})
	copy.draw_pile = state.draw_pile.duplicate()
	copy.discard = state.discard.duplicate()
	copy.hand = state.hand.duplicate()
	copy.form = blank_form()
	for row in 3:
		for col in 3:
			var stamp = state.form[row][col]
			if stamp != null:
				copy.form[row][col] = {
					"card_id": String(stamp["card_id"]),
					"spent_before": int(stamp["spent_before"]),
				}
	copy.relic_id = state.relic_id
	copy.shift = state.shift
	copy.traveler_index = state.traveler_index
	copy.phase = state.phase
	copy.progress = state.progress
	copy.patience = state.patience
	copy.ink = state.ink
	copy.ink_spent = state.ink_spent
	copy.turn_number = state.turn_number
	copy.rule_cancelled = state.rule_cancelled
	copy.resolving = false
	copy.encounters_cleared = state.encounters_cleared
	copy.draft_options = state.draft_options.duplicate()
	copy.relic_options = state.relic_options.duplicate()
	copy.log = []
	copy.silent = true
	return copy


static func debug_summary(state: NightState) -> String:
	var hand_names: Array = []
	for iid in state.hand:
		hand_names.append(card_id_of(state, int(iid)))
	return "phase=%s shift=%s traveler=%s progress=%d/%d patience=%d ink=%d turn=%d hand=%s cleared=%d log=%s" % [
		state.phase,
		shift_label(state),
		traveler(state)["name"],
		state.progress,
		int(traveler(state)["goal"]),
		state.patience,
		state.ink,
		state.turn_number,
		str(hand_names),
		state.encounters_cleared,
		str(state.log),
	]


static func _resolve_stamp(state: NightState, row: int, col: int, hush: bool) -> void:
	if state.resolver_steps >= HARD_STEP_LIMIT:
		state.chain_stopped = true
		return
	state.resolver_steps += 1
	var stamp = state.form[row][col]
	if stamp == null:
		return
	var card_id = String(stamp["card_id"])
	var raw = raw_stamp_progress(state, card_id, row, col)
	var amount = stamp_progress(state, card_id, row, col)
	if not hush:
		if amount == 0 and raw > 0 and not state.rule_cancelled:
			var rule = String(traveler(state)["rule"])
			if rule == "refuse_top" and row == 0:
				_log(state, "%s refuses %s on the top row." % [traveler(state)["name"], CARDS[card_id]["name"]])
			elif rule == "refuse_col1" and col == 0:
				_log(state, "%s refuses %s in column 1." % [traveler(state)["name"], CARDS[card_id]["name"]])
			elif rule == "refuse_col2" and col == 1:
				_log(state, "%s refuses %s in column 2." % [traveler(state)["name"], CARDS[card_id]["name"]])
			elif rule == "refuse_middle" and row == 1:
				_log(state, "%s refuses %s on the middle row." % [traveler(state)["name"], CARDS[card_id]["name"]])
			elif rule == "refuse_bottom" and row == 2:
				_log(state, "%s refuses %s on the bottom row." % [traveler(state)["name"], CARDS[card_id]["name"]])
			elif rule == "ignore_corners" and _is_corner(row, col):
				_log(state, "%s ignores %s in a corner box." % [traveler(state)["name"], CARDS[card_id]["name"]])
			elif rule == "ignore_covered" and _is_covered(state, row, col):
				_log(state, "%s ignores the covered %s." % [traveler(state)["name"], CARDS[card_id]["name"]])
			elif rule == "ignore_adjacent" and orthogonal_count(state, row, col) > 0:
				_log(state, "%s ignores the neighboring %s." % [traveler(state)["name"], CARDS[card_id]["name"]])
			elif rule == "refuse_center" and row == 1 and col == 1:
				_log(state, "%s refuses %s in the center cell." % [traveler(state)["name"], CARDS[card_id]["name"]])
			elif rule == "refuse_col3" and col == 2:
				_log(state, "%s refuses %s in column 3." % [traveler(state)["name"], CARDS[card_id]["name"]])
			elif rule == "ignore_shared_row" and row_fill_count(state, row) > 1:
				_log(state, "%s ignores %s because the row is shared." % [traveler(state)["name"], CARDS[card_id]["name"]])
			elif rule == "zero_first" and _is_queue_head(state, row, col):
				_log(state, "%s refuses the first stamp, %s." % [traveler(state)["name"], CARDS[card_id]["name"]])
			elif rule == "zero_last" and _is_queue_tail(state, row, col):
				_log(state, "%s refuses the last stamp, %s." % [traveler(state)["name"], CARDS[card_id]["name"]])
			elif rule == "refuse_stacked_col1" and col == 0 and col_fill_count(state, 0) > 1:
				_log(state, "%s refuses %s in a stacked column 1." % [traveler(state)["name"], CARDS[card_id]["name"]])
			elif rule == "refuse_stacked_bottom" and row == 2 and row_fill_count(state, 2) > 1:
				_log(state, "%s refuses %s on a stacked bottom row." % [traveler(state)["name"], CARDS[card_id]["name"]])
			elif rule == "zero_shared_later" and _shares_number_with_earlier(state, row, col):
				_log(state, "%s bars the later shared %s." % [traveler(state)["name"], CARDS[card_id]["name"]])
			elif rule == "zero_side_later" and _shares_side_with_earlier(state, row, col):
				_log(state, "%s bars the later side-sharing %s." % [traveler(state)["name"], CARDS[card_id]["name"]])
			elif rule == "zero_corner_later" and _corners_earlier_without_side(state, row, col):
				_log(state, "%s bars the later corner-touching %s." % [traveler(state)["name"], CARDS[card_id]["name"]])
			elif rule == "ignore_isolated":
				_log(state, "%s ignores the lone %s." % [traveler(state)["name"], CARDS[card_id]["name"]])
			else:
				_log(state, "%s grants 0." % CARDS[card_id]["name"])
		else:
			var tail_rule = String(traveler(state)["rule"])
			if tail_rule == "double_last" and _is_queue_tail(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The queue tail doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_first" and _is_queue_head(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The queue head doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_shared_later" and _shares_number_with_earlier(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The later shared number doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_frame" and not (row == 1 and col == 1) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The outer frame yields +3." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_corner" and _is_corner(row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The corner yields +3." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_center" and row == 1 and col == 1 and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The center doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_first_if_followed" and _is_queue_head(state, row, col) and not _is_queue_tail(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. A later stamp doubles the first." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_empty" and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Each empty cell yields +1." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_frame_if_center" and _center_filled(state) and not (row == 1 and col == 1) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled center doubles the frame." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_queue_gap" and _queue_has_gap(state) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The queue gap yields +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_full_row" and row_fill_count(state, row) == 3 and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The full row doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_end_match" and _ends_share_number(state) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Matching ends yield +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_row_wings" and (col == 0 or col == 2) and _row_wings_filled(state, row) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The wing pair yields +3." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_lowest_earliest" and _is_earliest_lowest(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The earliest lowest number doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_after_gap" and _follows_filled_gap(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell before it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_highest_earliest" and _is_earliest_highest(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The earliest highest number doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_before_gap" and _precedes_filled_gap(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell after it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_column_pair" and _is_column_pair_stamp(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The column pair yields +3." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_open_wing" and (col == 0 or col == 2) and _row_open_wings(state, row) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The open wing yields +3." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_highest_latest" and _is_latest_highest(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The latest highest number doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_diagonal_pair" and _is_diagonal_pair_stamp(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The diagonal pair yields +3." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_lowest_latest" and _is_latest_lowest(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The latest lowest number doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_full_column" and col_fill_count(state, col) == 3 and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The full column doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_side_later" and _shares_side_with_earlier(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The later shared side doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_lone_column" and col_fill_count(state, col) == 1 and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The lone column doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_side_pay" and orthogonal_count(state, row, col) > 0 and amount > raw:
				_log(state, "%s on the %s, %s grants %d. A shared side yields +3." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_next_filled" and _next_cell_filled(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell after it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_prior_filled" and _prev_cell_filled(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell before it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_corner_pay" and _diagonal_count(state, row, col) > 0 and amount > raw:
				_log(state, "%s on the %s, %s grants %d. A diagonal neighbor yields +3." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_short_row" and row_fill_count(state, row) == 2 and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The short row doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			else:
				_log(state, "%s on the %s, %s grants %d." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
	state.turn_progress += amount
	for cell in _retrigger_cells(card_id, row, col):
		_try_retrigger(state, cell.x, cell.y, hush)


static func _try_retrigger(state: NightState, row: int, col: int, hush: bool) -> void:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return
	if state.form[row][col] == null:
		return
	if state.chain_count >= CHAIN_CAP or state.resolver_steps >= HARD_STEP_LIMIT:
		state.chain_stopped = true
		if not hush and not state.chain_note_logged:
			state.chain_note_logged = true
			_log(state, "The queue stops at the chain cap (%d)." % CHAIN_CAP)
		return
	state.chain_count += 1
	_resolve_stamp(state, row, col, hush)


static func _retrigger_cells(card_id: String, row: int, col: int) -> Array:
	var cells: Array = []
	if card_id == "echo" and row + 1 <= 2:
		cells.append(Vector2i(row + 1, col))
	elif card_id == "reply" and row - 1 >= 0:
		cells.append(Vector2i(row - 1, col))
	elif card_id == "ripple":
		for delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var next_row = row + delta.x
			var next_col = col + delta.y
			if next_row >= 0 and next_col >= 0 and next_row <= 2 and next_col <= 2:
				cells.append(Vector2i(next_row, next_col))
	return cells


static func _apply_post_rule(state: NightState, hush: bool) -> void:
	if state.rule_cancelled:
		return
	var rule = String(traveler(state)["rule"])
	if rule == "yield_col2" and column_has_stamp(state, 1):
		state.turn_progress += 4
		if not hush:
			_log(state, "%s yields (+4)." % traveler(state)["name"])
	elif rule == "yield_full_middle" and row_fill_count(state, 1) == 3:
		state.turn_progress += 4
		if not hush:
			_log(state, "%s yields (+4)." % traveler(state)["name"])
	elif rule == "yield_both_margins" and column_has_stamp(state, 0) and column_has_stamp(state, 2):
		state.turn_progress += 4
		if not hush:
			_log(state, "%s yields (+4)." % traveler(state)["name"])
	elif rule == "yield_exact_two" and _stamp_count(state) == 2:
		state.turn_progress += 4
		if not hush:
			_log(state, "%s yields (+4)." % traveler(state)["name"])
	elif rule == "yield_every_column" and _every_column_stamped(state):
		state.turn_progress += 4
		if not hush:
			_log(state, "%s yields (+4)." % traveler(state)["name"])
	elif rule == "yield_diagonal" and _meets_at_corner(state):
		state.turn_progress += 4
		if not hush:
			_log(state, "%s yields (+4)." % traveler(state)["name"])
	elif rule == "yield_side" and _shares_a_side(state):
		state.turn_progress += 4
		if not hush:
			_log(state, "%s yields (+4)." % traveler(state)["name"])


static func _is_corner(row: int, col: int) -> bool:
	return (row == 0 or row == 2) and (col == 0 or col == 2)


static func _is_covered(state: NightState, row: int, col: int) -> bool:
	return row > 0 and state.form[row - 1][col] != null


static func _center_filled(state: NightState) -> bool:
	return state.form[1][1] != null


static func _shares_number_with_earlier(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	var stamp = state.form[row][col]
	if stamp == null:
		return false
	var number = raw_stamp_progress(state, String(stamp["card_id"]), row, col)
	for earlier_row in range(0, row + 1):
		var end_col = 2
		if earlier_row == row:
			end_col = col - 1
		for earlier_col in range(0, end_col + 1):
			var earlier = state.form[earlier_row][earlier_col]
			if earlier == null:
				continue
			var earlier_number = raw_stamp_progress(state, String(earlier["card_id"]), earlier_row, earlier_col)
			if earlier_number == number:
				return true
	return false


static func _is_queue_head(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	for earlier_row in range(0, row + 1):
		var end_col = 2
		if earlier_row == row:
			end_col = col - 1
		for earlier_col in range(0, end_col + 1):
			if state.form[earlier_row][earlier_col] != null:
				return false
	return true


static func _is_queue_tail(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	for later_row in range(row, 3):
		var start_col = 0
		if later_row == row:
			start_col = col + 1
		for later_col in range(start_col, 3):
			if state.form[later_row][later_col] != null:
				return false
	return true


static func _empty_cell_count(state: NightState) -> int:
	return 9 - _stamp_count(state)


static func _stamp_count(state: NightState) -> int:
	var count = 0
	for row in 3:
		count += row_fill_count(state, row)
	return count


static func _every_row_stamped(state: NightState) -> bool:
	return row_has_stamp(state, 0) and row_has_stamp(state, 1) and row_has_stamp(state, 2)


static func _every_column_stamped(state: NightState) -> bool:
	return column_has_stamp(state, 0) and column_has_stamp(state, 1) and column_has_stamp(state, 2)


static func _empty_row_count(state: NightState) -> int:
	var empty_rows = 0
	for row in 3:
		if not row_has_stamp(state, row):
			empty_rows += 1
	return empty_rows


static func _shares_side_with_earlier(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	for delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
		var next_row = row + delta.x
		var next_col = col + delta.y
		if next_row < 0 or next_col < 0 or next_row > 2 or next_col > 2:
			continue
		if state.form[next_row][next_col] == null:
			continue
		if next_row < row or (next_row == row and next_col < col):
			return true
	return false


static func _last_filled_column(state: NightState) -> int:
	for row in range(2, -1, -1):
		for col in range(2, -1, -1):
			if state.form[row][col] != null:
				return col
	return -1


static func _first_filled_column(state: NightState) -> int:
	for row in 3:
		for col in 3:
			if state.form[row][col] != null:
				return col
	return -1


static func _cells_touch_at_corner(row: int, col: int, other_row: int, other_col: int) -> bool:
	var row_gap = row - other_row
	if row_gap < 0:
		row_gap = -row_gap
	var col_gap = col - other_col
	if col_gap < 0:
		col_gap = -col_gap
	return row_gap == 1 and col_gap == 1


static func _cells_share_side(row: int, col: int, other_row: int, other_col: int) -> bool:
	var row_gap = row - other_row
	if row_gap < 0:
		row_gap = -row_gap
	var col_gap = col - other_col
	if col_gap < 0:
		col_gap = -col_gap
	return (row_gap == 1 and col_gap == 0) or (row_gap == 0 and col_gap == 1)


static func _corners_earlier_without_side(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	for other_row in 3:
		for other_col in 3:
			if state.form[other_row][other_col] == null:
				continue
			var earlier = other_row < row or (other_row == row and other_col < col)
			if not earlier:
				continue
			if not _cells_touch_at_corner(row, col, other_row, other_col):
				continue
			if _cells_share_side(row, col, other_row, other_col):
				continue
			return true
	return false


static func _row_wings_filled(state: NightState, row: int) -> bool:
	if row < 0 or row > 2:
		return false
	return state.form[row][0] != null and state.form[row][2] != null


static func _is_earliest_lowest(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var lowest := -1
	var best_row := -1
	var best_col := -1
	var count := 0
	for scan_row in 3:
		for scan_col in 3:
			var stamp = state.form[scan_row][scan_col]
			if stamp == null:
				continue
			count += 1
			var number = raw_stamp_progress(state, String(stamp["card_id"]), scan_row, scan_col)
			if best_row < 0 or number < lowest:
				lowest = number
				best_row = scan_row
				best_col = scan_col
	if count < 2:
		return false
	return best_row == row and best_col == col


static func _is_earliest_highest(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var highest := -1
	var best_row := -1
	var best_col := -1
	var count := 0
	for scan_row in 3:
		for scan_col in 3:
			var stamp = state.form[scan_row][scan_col]
			if stamp == null:
				continue
			count += 1
			var number = raw_stamp_progress(state, String(stamp["card_id"]), scan_row, scan_col)
			if best_row < 0 or number > highest:
				highest = number
				best_row = scan_row
				best_col = scan_col
	if count < 2:
		return false
	return best_row == row and best_col == col


static func _next_cell_filled(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var next_row := row
	var next_col := col + 1
	if next_col > 2:
		next_row = row + 1
		next_col = 0
	if next_row > 2:
		return false
	return state.form[next_row][next_col] != null


static func _prev_cell_filled(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var prev_row := row
	var prev_col := col - 1
	if prev_col < 0:
		prev_row = row - 1
		prev_col = 2
	if prev_row < 0:
		return false
	return state.form[prev_row][prev_col] != null


static func _diagonal_count(state: NightState, row: int, col: int) -> int:
	var count := 0
	for delta in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
		var next_row = row + delta.x
		var next_col = col + delta.y
		if next_row < 0 or next_col < 0 or next_row > 2 or next_col > 2:
			continue
		if state.form[next_row][next_col] != null:
			count += 1
	return count


static func _precedes_filled_gap(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var next_row := row
	var next_col := col + 1
	if next_col > 2:
		next_row = row + 1
		next_col = 0
	if next_row > 2:
		return false
	if state.form[next_row][next_col] != null:
		return false
	for later_row in range(next_row, 3):
		var start_col := 0
		if later_row == next_row:
			start_col = next_col + 1
		for later_col in range(start_col, 3):
			if state.form[later_row][later_col] != null:
				return true
	return false


static func _is_column_pair_stamp(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	if row != 0 and row != 2:
		return false
	return state.form[0][col] != null and state.form[2][col] != null and state.form[1][col] == null


static func _row_open_wings(state: NightState, row: int) -> bool:
	if row < 0 or row > 2:
		return false
	return state.form[row][0] != null and state.form[row][2] != null and state.form[row][1] == null


static func _is_latest_lowest(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var lowest := -1
	var best_row := -1
	var best_col := -1
	var count := 0
	for scan_row in 3:
		for scan_col in 3:
			var stamp = state.form[scan_row][scan_col]
			if stamp == null:
				continue
			count += 1
			var number = raw_stamp_progress(state, String(stamp["card_id"]), scan_row, scan_col)
			if best_row < 0 or number <= lowest:
				lowest = number
				best_row = scan_row
				best_col = scan_col
	if count < 2:
		return false
	return best_row == row and best_col == col


static func _is_latest_highest(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var highest := -1
	var best_row := -1
	var best_col := -1
	var count := 0
	for scan_row in 3:
		for scan_col in 3:
			var stamp = state.form[scan_row][scan_col]
			if stamp == null:
				continue
			count += 1
			var number = raw_stamp_progress(state, String(stamp["card_id"]), scan_row, scan_col)
			if best_row < 0 or number >= highest:
				highest = number
				best_row = scan_row
				best_col = scan_col
	if count < 2:
		return false
	return best_row == row and best_col == col


static func _is_diagonal_pair_stamp(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	if state.form[1][1] != null:
		return false
	if row == 0 and col == 0:
		return state.form[2][2] != null
	if row == 2 and col == 2:
		return state.form[0][0] != null
	if row == 0 and col == 2:
		return state.form[2][0] != null
	if row == 2 and col == 0:
		return state.form[0][2] != null
	return false


static func _follows_filled_gap(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var prev_row := row
	var prev_col := col - 1
	if prev_col < 0:
		prev_row = row - 1
		prev_col = 2
	if prev_row < 0:
		return false
	if state.form[prev_row][prev_col] != null:
		return false
	for earlier_row in range(0, prev_row + 1):
		var end_col := 2
		if earlier_row == prev_row:
			end_col = prev_col - 1
		for earlier_col in range(0, end_col + 1):
			if state.form[earlier_row][earlier_col] != null:
				return true
	return false


static func _ends_share_number(state: NightState) -> bool:
	var first_row := -1
	var first_col := -1
	var last_row := -1
	var last_col := -1
	var count := 0
	for row in 3:
		for col in 3:
			if state.form[row][col] == null:
				continue
			if count == 0:
				first_row = row
				first_col = col
			last_row = row
			last_col = col
			count += 1
	if count < 2:
		return false
	var first_stamp = state.form[first_row][first_col]
	var last_stamp = state.form[last_row][last_col]
	var first_number = raw_stamp_progress(state, String(first_stamp["card_id"]), first_row, first_col)
	var last_number = raw_stamp_progress(state, String(last_stamp["card_id"]), last_row, last_col)
	return first_number == last_number


static func _queue_has_gap(state: NightState) -> bool:
	var first := -1
	var last := -1
	var count := 0
	var index := 0
	for row in 3:
		for col in 3:
			if state.form[row][col] != null:
				if first < 0:
					first = index
				last = index
				count += 1
			index += 1
	if count < 2:
		return false
	return last - first + 1 > count


static func _shares_a_number(state: NightState) -> bool:
	var seen: Dictionary = {}
	for row in 3:
		for col in 3:
			var stamp = state.form[row][col]
			if stamp == null:
				continue
			var number = raw_stamp_progress(state, String(stamp["card_id"]), row, col)
			if seen.has(number):
				return true
			seen[number] = true
	return false


static func _empty_column_count(state: NightState) -> int:
	var empty_columns = 0
	for col in 3:
		if not column_has_stamp(state, col):
			empty_columns += 1
	return empty_columns


static func _shares_a_side(state: NightState) -> bool:
	for row in 3:
		for col in 3:
			if state.form[row][col] == null:
				continue
			for delta in [Vector2i(1, 0), Vector2i(0, 1)]:
				var next_row = row + delta.x
				var next_col = col + delta.y
				if next_row > 2 or next_col > 2:
					continue
				if state.form[next_row][next_col] != null:
					return true
	return false


static func _meets_at_corner(state: NightState) -> bool:
	for row in 3:
		for col in 3:
			if state.form[row][col] == null:
				continue
			for delta in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
				var next_row = row + delta.x
				var next_col = col + delta.y
				if next_row < 0 or next_col < 0 or next_row > 2 or next_col > 2:
					continue
				if state.form[next_row][next_col] != null:
					return true
	return false


static func orthogonal_count(state: NightState, row: int, col: int) -> int:
	var count = 0
	for delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
		var next_row = row + delta.x
		var next_col = col + delta.y
		if next_row < 0 or next_col < 0 or next_row > 2 or next_col > 2:
			continue
		if state.form[next_row][next_col] != null:
			count += 1
	return count


static func row_fill_count(state: NightState, row: int) -> int:
	var count = 0
	for col in 3:
		if state.form[row][col] != null:
			count += 1
	return count


static func col_fill_count(state: NightState, col: int) -> int:
	var count = 0
	for row in 3:
		if state.form[row][col] != null:
			count += 1
	return count


static func row_has_stamp(state: NightState, row: int) -> bool:
	return row_fill_count(state, row) > 0


static func column_has_stamp(state: NightState, col: int) -> bool:
	return col_fill_count(state, col) > 0


static func _apply_result(state: NightState, result: Dictionary) -> void:
	if result["won"]:
		state.encounters_cleared += 1
		if state.traveler_index >= _roster(state).size() - 1:
			state.phase = "victory"
			if state.shift == SHIFT_CATCHWORD:
				_log(state, "The queue is empty. The catchword bell is clear.")
			elif state.shift == SHIFT_SIGNATURE:
				_log(state, "The queue is empty. The signature bell is clear.")
			elif state.shift == SHIFT_CLASP:
				_log(state, "The queue is empty. The clasp bell is clear.")
			elif state.shift == SHIFT_HEADBAND:
				_log(state, "The queue is empty. The headband bell is clear.")
			elif state.shift == SHIFT_SPINE:
				_log(state, "The queue is empty. The spine bell is clear.")
			elif state.shift == SHIFT_LEDGER:
				_log(state, "The queue is empty. The ledger bell is clear.")
			elif state.shift == SHIFT_INDEX:
				_log(state, "The queue is empty. The index bell is clear.")
			elif state.shift == SHIFT_MARGIN:
				_log(state, "The queue is empty. The margin bell is clear.")
			elif state.shift == SHIFT_WICK:
				_log(state, "The queue is empty. The wick bell is clear.")
			elif state.shift == SHIFT_FOLIO:
				_log(state, "The queue is empty. The folio bell is clear.")
			elif state.shift == SHIFT_QUAY:
				_log(state, "The queue is empty. The quay bell is clear.")
			elif state.shift == SHIFT_SALT:
				_log(state, "The queue is empty. The salt watch is clear.")
			elif state.shift == SHIFT_QUIRE:
				_log(state, "The queue is empty. The quire watch is clear.")
			elif state.shift == SHIFT_VELLUM:
				_log(state, "The queue is empty. The vellum bell is clear.")
			elif state.shift == SHIFT_GUTTER:
				_log(state, "The queue is empty. The gutter lamp is clear.")
			elif state.shift == SHIFT_ASH:
				_log(state, "The queue is empty. The ash watch is clear.")
			elif state.shift == SHIFT_CLOSING:
				_log(state, "The queue is empty. The closing bell is clear.")
			elif state.shift == SHIFT_LATE:
				_log(state, "The queue is empty. The late shift is clear.")
			else:
				_log(state, "The queue is empty. Act 1 is clear.")
			return
		if state.traveler_index == 1:
			state.phase = "relic"
			state.relic_options = [RELIC_IRON_PAD, RELIC_DEEP_WELL]
			_log(state, "The drawer offers a relic.")
			return
		_open_draft(state)
		return
	if result["lost"]:
		state.phase = "defeat"
		_log(state, "Patience breaks. The traveler turns away.")
		return
	_start_turn(state)


static func _begin_encounter(state: NightState) -> void:
	state.phase = "play"
	state.progress = 0
	state.patience = int(traveler(state)["patience"])
	state.turn_number = 0
	state.hand = []
	state.discard = []
	state.draw_pile = []
	state.form = blank_form()
	state.resolving = false
	state.ink = 0
	state.ink_spent = 0
	state.draft_options = []
	state.relic_options = []
	state.rule_cancelled = false
	for card in state.library:
		state.draw_pile.append(int(card["iid"]))
	_reseed(state, 1000003)
	_shuffle(state, state.draw_pile)
	if not state.silent:
		_log(state, "%s approaches. %s" % [traveler(state)["name"], traveler(state)["rule_text"]])
	_start_turn(state)


static func _start_turn(state: NightState) -> void:
	state.form = blank_form()
	state.ink_spent = 0
	state.turn_number += 1
	state.ink = ink_per_turn(state)
	_draw_to_hand(state)
	if not state.silent:
		_log(state, "Turn %d. Ink is %d." % [state.turn_number, state.ink])


static func _draw_to_hand(state: NightState) -> void:
	while state.hand.size() < HAND_SIZE:
		if state.draw_pile.is_empty():
			if state.discard.is_empty():
				return
			state.draw_pile = state.discard.duplicate()
			state.discard = []
			_shuffle(state, state.draw_pile)
			if not state.silent:
				_log(state, "The discard is shuffled into the deck.")
		state.hand.append(int(state.draw_pile.pop_front()))


static func _open_draft(state: NightState) -> void:
	_reseed(state, 2000003)
	var bag: Array = []
	for card_id in POOL:
		bag.append(card_id)
	_shuffle(state, bag)
	state.draft_options = [bag[0], bag[1], bag[2]]
	state.phase = "draft"
	_log(state, "Choose one stamp to add to the deck.")


static func _add_library_card(state: NightState, card_id: String) -> int:
	state.next_iid += 1
	state.library.append({"iid": state.next_iid, "card_id": card_id})
	return state.next_iid


static func _reseed(state: NightState, salt: int) -> void:
	var mixed = int(state.seed) * salt + state.traveler_index * 9176 + state.shift * 6151 + _deck_signature(state) + salt
	state.rng_state = mixed & 0x7FFFFFFF
	if state.rng_state == 0:
		state.rng_state = 1


static func _deck_signature(state: NightState) -> int:
	var signature = 0
	for card in state.library:
		signature = (signature * 131 + _card_hash(String(card["card_id"]))) & 0x7FFFFFFF
	return signature


static func _card_hash(card_id: String) -> int:
	var hashed = 0
	for i in card_id.length():
		hashed = (hashed * 33 + card_id.unicode_at(i)) & 0x7FFFFFFF
	return hashed


static func _rand(state: NightState) -> int:
	state.rng_state = (int(state.rng_state) * 1664525 + 1013904223) & 0x7FFFFFFF
	if state.rng_state == 0:
		state.rng_state = 1
	return state.rng_state


static func _shuffle(state: NightState, values: Array) -> void:
	for i in range(values.size() - 1, 0, -1):
		var j = _rand(state) % (i + 1)
		var tmp = values[i]
		values[i] = values[j]
		values[j] = tmp


static func _log(state: NightState, message: String) -> void:
	if state.silent:
		return
	state.log.append(message)
	while state.log.size() > LOG_LIMIT:
		state.log.pop_front()
