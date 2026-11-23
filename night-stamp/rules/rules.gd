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
# COLOPHON BELL, in desk order
# A twentieth night. The stamps, the ink, and the 3x3 form are unchanged.
# The colophon bell deals the starting deck again. Drafts and the relic
# from an earlier night do not carry. Open it from the desk, or from a
# victory desk. Restart act replays whichever night is on the desk.
# - Nia Soren, lane column 2, exemption row bottom, Nine Toll:
#   "Patience drops by 2 when exactly nine cells are filled."
#   Gwyn Brant drops patience by 2 when the form holds exactly eight
#   stamps. Dory Hart drops patience by 2 when the form holds exactly
#   seven stamps. Hugh Pell drops patience by 2 when the form holds
#   exactly six. Joss Pell drops patience by 2 when the form holds
#   exactly five. Ada Hart drops patience by 2 when the form holds
#   exactly four. Pell Dane drops patience by 2 when the form holds
#   exactly three. Nia does none of those. The drop is 2 instead of 1
#   when the form holds exactly nine stamps. An empty form keeps the
#   drop at 1. One stamp keeps the drop at 1. Two stamps keep the drop
#   at 1. Three stamps keep the drop at 1. Four stamps keep the drop at
#   1. Five stamps keep the drop at 1. Six stamps keep the drop at 1.
#   Seven stamps keep the drop at 1. Eight stamps keep the drop at 1.
#   A full form of nine drops patience by 2. Any other count keeps the
#   drop at 1. The toll does not change what a stamp scores.
#   Exemption on the bottom row keeps the drop at 1, even when the form
#   is full and even when the count is anything else. An Exemption off
#   the bottom row does not.
#   Hold is applied before the nine toll.
# - Perris Wythe, lane column 3, exemption row top, Lone Row:
#   "A stamp scores twice only when it is the only filled stamp in its
#   row."
#   A row with one stamp doubles that stamp. If that row holds another
#   stamp, every stamp in the row scores its own number. A row of two
#   does not double. A full row of three does not double. Other rows do
#   not matter. A lone stamp in one row still doubles when another row
#   is stacked. Lin Pell doubles a stamp only when it is the only filled
#   stamp in its column. Colm Brigg doubles both stamps in a row of
#   exactly two. Wynn Hart doubles a stamp only when its own row is
#   full. Lark Pym ignores a stamp that shares its row, so that stamp
#   scores 0. Perris does none of those. A second stamp in a row does
#   not score 0. A row of two scores each stamp's own number. A full
#   row scores each stamp's own number. Every row follows the same
#   rule. A lone stamp on the form is the only stamp in its row, so it
#   scores twice. A retrigger of a stamp that is alone in its row
#   scores twice again. A retrigger of a stamp in a row that holds
#   another stamp does not.
#   Exemption on the top row cancels the doubling, so every stamp scores
#   its own number. An Exemption off the top row does not. An Exemption
#   that is the only stamp in its row and sits off the top row scores
#   twice. An Exemption on the top row is on the exemption row, so that
#   row and every other row score their own number.
#   The slip does not change patience.
# - Jory Marsh, lane column 1, exemption row middle, Short Column:
#   "A stamp scores twice only when its own column holds exactly two
#   filled stamps."
#   Both stamps in that column score twice. A column with one stamp
#   scores that stamp's own number. A full column of three scores each
#   stamp's own number. Other columns are independent. A pair in one
#   column still doubles when another column is full, and a full column
#   still scores its own numbers when another column holds a pair. A
#   column of two doubles both stamps even when an empty cell sits
#   between them. Colm Brigg doubles both stamps in a row of exactly
#   two. Lin Pell doubles a stamp only when it is the only filled stamp
#   in its column. Fenn Hart doubles a stamp only when its own column
#   is full. Jory does none of those. A lone stamp on the form is the
#   only stamp in its column, so it scores its own number. A retrigger
#   of a stamp in a two-stamp column scores twice again. A retrigger of
#   a stamp in a column of one or three does not.
#   Exemption on the middle row cancels the doubling, so every stamp
#   scores its own number. An Exemption off the middle row does not. An
#   Exemption in a two-stamp column that sits off the middle row scores
#   twice.
#   The slip does not change patience.
# - Maeve Okell, lane column 2, exemption row top, Corner Slip:
#   "When a stamp shares a corner with an earlier stamp, the later stamp
#   scores twice. The earlier stamp scores its own number."
#   A corner is a diagonal touch: one row apart and one column apart.
#   A side share does not count, and it does not double the later stamp.
#   The cell above, below, left, or right is a side, not a corner. A
#   stamp that meets an earlier stamp only at a corner doubles. A lone
#   stamp scores its own number. If the later stamp meets two earlier
#   stamps at corners, it still scores twice, not four times. A longer
#   diagonal, two cells apart, does not double either stamp. The queue
#   is read from the top row downward, left to right inside a row.
#   Press order does not choose who is later. The earlier stamp of a
#   corner pair scores its own number, including on a retrigger. A
#   retrigger of a later corner-sharing stamp scores twice again. A
#   retrigger of the earlier stamp scores its own number again. Rue Hart
#   doubles the later stamp of a side pair. Idris Reed adds 3 to each
#   stamp that has a filled diagonal neighbor. Rho Tallow yields once
#   after the queue when two stamps meet at a corner. Maeve does none
#   of those.
#   Exemption on the top row cancels the doubling, so every stamp scores
#   its own number. An Exemption off the top row does not. An Exemption
#   that shares a corner with an earlier stamp and sits off the top row
#   scores twice.
#   The slip does not change patience.
# The lone-row doubling, the short-column doubling, and the corner-slip
# doubling do not remove Hold or Exemption, and they do not cancel a
# retrigger.
#
# ERRATA BELL, in desk order
# A twenty-first night. The stamps, the ink, and the 3x3 form are unchanged.
# The errata bell deals the starting deck again. Drafts and the relic
# from an earlier night do not carry. Open it from the desk, or from a
# victory desk. Restart act replays whichever night is on the desk.
# - Una Pell, lane column 1, exemption row top, Odd Toll:
#   "Patience drops by 2 when the number of filled cells is odd."
#   Pell Dane drops patience by 2 when the form holds exactly three stamps.
#   Joss Pell drops patience by 2 when the form holds exactly five. Dory
#   Hart drops patience by 2 when the form holds exactly seven. Nia Soren
#   drops patience by 2 when the form holds exactly nine. Ada Hart drops
#   patience by 2 when the form holds exactly four. Hugh Pell drops
#   patience by 2 when the form holds exactly six. Gwyn Brant drops
#   patience by 2 when the form holds exactly eight. Una does none of
#   those. The drop is 2 instead of 1 when the number of filled cells is
#   odd: one, three, five, seven, or nine. An empty form keeps the drop
#   at 1. Two stamps keep the drop at 1. Four stamps keep the drop at 1.
#   Six stamps keep the drop at 1. Eight stamps keep the drop at 1. A
#   single filled cell drops patience by 2. Any even count keeps the drop
#   at 1. The toll does not change what a stamp scores.
#   Exemption on the top row keeps the drop at 1, even when the count is
#   odd and even when the count is anything else. An Exemption off the
#   top row does not.
#   Hold is applied before the odd toll.
# - Orin Keel, lane column 3, exemption row bottom, Next Blank:
#   "A stamp scores twice only when the queue cell immediately after it
#   is empty."
#   The queue is read from the top row downward, left to right inside a
#   row, the same order Holt Quern and Hester Keel use. The cell
#   immediately after a stamp is the next cell in that order. The cell
#   after the right end of a row is the left end of the next row. A stamp
#   whose next cell is filled scores its own number. The bottom-right
#   cell has no cell after it, so it scores its own number. A stamp
#   followed only by empty cells through the end of the queue scores
#   twice. Holt Quern doubles a stamp when the next cell is filled. Bram
#   Solt doubles a stamp when the next cell is empty and some later cell
#   is filled, so a stamp followed by nothing but empty cells does not
#   double for Bram. Hester Keel doubles a stamp when the previous cell
#   is filled. Orin does none of those. A contiguous pair doubles the
#   later stamp and leaves the earlier stamp at its own number. A
#   retrigger of a stamp whose next cell is empty scores twice again. A
#   retrigger of a stamp whose next cell is filled does not. A retrigger
#   of the bottom-right cell does not.
#   Exemption on the bottom row cancels the doubling, so every stamp
#   scores its own number. An Exemption off the bottom row does not. An
#   Exemption that is followed by an empty cell and sits off the bottom
#   row scores twice.
#   The slip does not change patience.
# - Vesper Okell, lane column 2, exemption row middle, Corner Mark:
#   "A stamp scores twice only when it sits in a corner cell."
#   The corner cells are the top-left, the top-right, the bottom-left,
#   and the bottom-right. The center scores its own number. The four
#   edge-middle cells score their own number. A corner doubles even when
#   its neighbors are empty. A corner still doubles only once when its
#   neighbors are filled. Filling a corner does not double the center or
#   an edge-middle cell. Bram Hart doubles every frame stamp, including
#   the edge-middle cells, only when the center is filled. Maeve Okell
#   doubles the later stamp of a diagonal pair and does not care whether
#   that cell is a corner. Idris Reed adds 3 to each stamp that has a
#   filled diagonal neighbor. Vesper does none of those. A lone corner
#   stamp scores twice. A lone center stamp scores its own number. A
#   retrigger of a corner stamp scores twice again. A retrigger of a
#   center stamp or an edge-middle stamp scores its own number again.
#   Exemption on the middle row cancels the doubling, so every stamp
#   scores its own number. An Exemption off the middle row does not. An
#   Exemption in a corner and off the middle row scores twice.
#   The mark does not change patience.
# - Weske Brant, lane column 1, exemption row bottom, Middle Pay:
#   "Each stamp in the middle row scores +2 once."
#   A stamp on the top row scores its own number. A stamp on the bottom
#   row scores its own number. The center is in the middle row, so it
#   scores +2. The two edge cells of the middle row score +2 as well.
#   Neighbors do not change the bonus. A stamp with two neighbors still
#   scores +2 once, not +4. A lone middle-row stamp still scores +2.
#   Opal Quill adds 3 for a side share. Idris Reed adds 3 for a filled
#   diagonal neighbor. The center slip doubles the center cell and does
#   not add 2 to the whole middle row. Weske does none of those. A
#   retrigger of a middle-row stamp adds 2 again. A retrigger of a top
#   stamp or a bottom stamp does not.
#   Exemption on the bottom row cancels the bonus, so every stamp scores
#   its own number. An Exemption off the bottom row does not. An
#   Exemption in the middle row still adds 2, because the middle row is
#   not the bottom row.
#   The pay does not change patience.
# The next-blank doubling, the corner mark, and the middle pay do not
# remove Hold or Exemption, and they do not cancel a retrigger.
#
# FRONTISPIECE BELL, in desk order
# A twenty-second night. The stamps, the ink, and the 3x3 form are unchanged.
# The frontispiece bell deals the starting deck again. Drafts and the relic
# from an earlier night do not carry. Open it from the desk, or from a
# victory desk. Restart act replays whichever night is on the desk.
# - Soren Hale, lane column 3, exemption row middle, Even Toll:
#   "Patience drops by 2 when the number of filled cells is even."
#   Una Pell drops patience by 2 when the number of filled cells is odd,
#   and keeps the drop at 1 for every even count. Ada Hart drops patience
#   by 2 when the form holds exactly four stamps. Hugh Pell drops patience
#   by 2 when the form holds exactly six. Gwyn Brant drops patience by 2
#   when the form holds exactly eight. Soren does none of those. The drop
#   is 2 instead of 1 when the number of filled cells is even: zero, two,
#   four, six, or eight. An empty form drops patience by 2. Exactly two
#   stamps drop patience by 2. A single filled cell keeps the drop at 1.
#   Three, five, seven, and a full form of nine keep the drop at 1. The
#   toll does not change what a stamp scores.
#   Exemption on the middle row keeps the drop at 1, even when the count
#   is even and even when the count is anything else. An Exemption off the
#   middle row does not.
#   Hold is applied before the even toll.
# - Brigg Marsh, lane column 2, exemption row top, Prior Blank:
#   "A stamp scores twice only when the queue cell immediately before it
#   is empty."
#   The queue is read from the top row downward, left to right inside a
#   row, the same order Holt Quern, Hester Keel, and Orin Keel use. The
#   cell immediately before a stamp is the previous cell in that order.
#   The cell before the left end of a row is the right end of the previous
#   row. A stamp whose previous cell is filled scores its own number. The
#   top-left cell has no cell before it, so it scores its own number. A
#   stamp whose previous cell is empty scores twice even when no earlier
#   cell is filled. Hester Keel doubles a stamp when the previous cell is
#   filled. Sable Quern doubles a stamp when the previous cell is empty
#   and some earlier cell is filled, so a stamp that follows an empty cell
#   at the start of the queue does not double for Sable. Orin Keel doubles
#   a stamp when the next cell is empty, and does not look at the previous
#   cell. Brigg does none of those. A contiguous pair leaves both stamps
#   at their own numbers. A retrigger of a stamp whose previous cell is
#   empty scores twice again. A retrigger of a stamp whose previous cell
#   is filled does not. A retrigger of the top-left cell does not.
#   Exemption on the top row cancels the doubling, so every stamp scores
#   its own number. An Exemption off the top row does not. An Exemption
#   that follows an empty cell and sits off the top row scores twice.
#   The slip does not change patience.
# - Tallow Keel, lane column 1, exemption row bottom, Edge Mark:
#   "A stamp scores twice only when it sits in an edge-middle cell."
#   The edge-middle cells are the top middle, the left middle, the right
#   middle, and the bottom middle. The four corners score their own
#   number. The center scores its own number. An edge-middle stamp doubles
#   even when its neighbors are empty. An edge-middle stamp still doubles
#   only once when its neighbors are filled. Filling an edge-middle cell
#   does not double a corner or the center. Vesper Okell doubles the four
#   corners and does not double an edge middle. Bram Hart doubles every
#   frame stamp, including the edge-middle cells and the corners, only
#   when the center is filled. Tallow does neither. A lone edge-middle
#   stamp scores twice. A lone corner scores its own number. A lone center
#   scores its own number. A retrigger of an edge-middle stamp scores
#   twice again. A retrigger of a corner or the center scores its own
#   number again.
#   Exemption on the bottom row cancels the doubling, so every stamp
#   scores its own number. An Exemption off the bottom row does not. An
#   Exemption on an edge-middle cell and off the bottom row scores twice.
#   The mark does not change patience.
# - Yarrow Fen, lane column 2, exemption row middle, Top Pay:
#   "Each stamp in the top row scores +2 once."
#   A stamp in the middle row scores its own number. A stamp on the bottom
#   row scores its own number. Neighbors do not change the bonus. A stamp
#   with two neighbors still scores +2 once, not +4. A lone top-row stamp
#   still scores +2. Weske Brant adds 2 to the middle row and does not add
#   2 to the top row. Opal Quill adds 3 for a side share and does not pay
#   a lone stamp. Yarrow does neither. A retrigger of a top-row stamp adds
#   2 again. A retrigger of a middle stamp or a bottom stamp does not.
#   Exemption on the middle row cancels the bonus, so every stamp scores
#   its own number. An Exemption off the middle row does not. An Exemption
#   in the top row still adds 2, because the top row is not the middle row.
#   The pay does not change patience.
# The prior-blank doubling, the edge mark, and the top pay do not remove
# Hold or Exemption, and they do not cancel a retrigger.
#
# FLYLEAF BELL, in desk order
# A twenty-third night. The stamps, the ink, and the 3x3 form are unchanged.
# The flyleaf bell deals the starting deck again. Drafts and the relic
# from an earlier night do not carry. Open it from the desk, or from a
# victory desk. Restart act replays whichever night is on the desk.
# - Hollin Voss, lane column 2, exemption row bottom, Prime Toll:
#   "Patience drops by 2 when the number of filled cells is prime."
#   Una Pell drops patience by 2 on every odd count, including one and
#   nine, and keeps the drop at 1 on two. Soren Hale drops patience by 2
#   on every even count, including zero, four, six, and eight, and keeps
#   the drop at 1 on three, five, and seven. Pell Dane drops only for
#   exactly three. Joss Pell drops only for exactly five. Dory Hart drops
#   only for exactly seven. Hollin does none of those. The drop is 2
#   instead of 1 when the number of filled cells is prime: two, three,
#   five, or seven. One is not prime. Zero, one, four, six, eight, and a
#   full form of nine keep the drop at 1. The toll does not change what a
#   stamp scores.
#   Exemption on the bottom row keeps the drop at 1, even on a prime count.
#   An Exemption off the bottom row does not.
#   Hold is applied before the prime toll.
# - Perrin Keel, lane column 3, exemption row bottom, Both Blank:
#   "A stamp scores twice only when the queue cell immediately before it
#   is empty and the queue cell immediately after it is empty."
#   The queue is read from the top row downward, left to right inside a
#   row, the same order Holt Quern, Hester Keel, Orin Keel, and Brigg Marsh
#   use. The cell immediately before a stamp is the previous cell in that
#   order. The cell immediately after it is the next cell. The cell before
#   the left end of a row is the right end of the previous row. The top-left
#   cell has no cell before it, so it scores its own number. The bottom-right
#   cell has no cell after it, so it scores its own number. A stamp with an
#   empty previous cell and a filled next cell scores its own number. A stamp
#   with a filled previous cell and an empty next cell scores its own number.
#   A stamp with both neighbors empty scores twice even when cells farther
#   away are filled. Brigg Marsh doubles a stamp whenever the previous cell
#   is empty, even if the next cell is filled, and he doubles a stamp at the
#   start of the queue. Orin Keel doubles a stamp whenever the next cell is
#   empty, even if the previous cell is filled, and he doubles a stamp at
#   the end of the queue. Sable Quern doubles a stamp only when the previous
#   cell is empty and some earlier cell is filled, and she does not look at
#   the next cell. Perrin does none of those. A retrigger of a stamp with
#   both neighbors empty scores twice again. A retrigger of any other stamp
#   does not.
#   Exemption on the bottom row cancels the doubling, so every stamp scores
#   its own number. An Exemption off the bottom row does not. An Exemption
#   with both neighbors empty that sits off the bottom row scores twice.
#   The blank does not change patience.
# - Ewan Holt, lane column 2, exemption row middle, Cross Mark:
#   "A stamp scores twice only when it sits in the plus."
#   The plus is the center, the top middle, the left middle, the right
#   middle, and the bottom middle. The four corners score their own number.
#   A plus cell doubles even when its neighbors are empty. A plus cell still
#   doubles only once when its neighbors are filled. Tallow Keel doubles the
#   four edge-middle cells and does not double the center. Vesper Okell
#   doubles the four corners and does not double an edge middle or the
#   center. Wynn Cress doubles only the center. Bram Hart doubles every
#   frame stamp, including the corners, only when the center is filled.
#   Ewan does none of those. A retrigger of a plus cell scores twice again.
#   A retrigger of a corner scores its own number again.
#   Exemption on the middle row cancels the doubling, so every stamp scores
#   its own number, including the top middle and the bottom middle. An
#   Exemption off the middle row does not. An Exemption on a plus cell and
#   off the middle row scores twice.
#   The mark does not change patience.
# - Maren Fen, lane column 1, exemption row top, Bottom Pay:
#   "Each stamp in the bottom row scores +2 once."
#   A stamp in the top row scores its own number. A stamp in the middle row
#   scores its own number. Neighbors do not change the bonus. A stamp with
#   two neighbors still scores +2 once, not +4. A lone bottom-row stamp
#   still scores +2. Yarrow Fen adds 2 to the top row and does not add 2
#   to the bottom row. Weske Brant adds 2 to the middle row and does not
#   add 2 to the bottom row. Opal Quill adds 3 for a side share and does
#   not pay a lone stamp. Maren does none of those. A retrigger of a
#   bottom-row stamp adds 2 again. A retrigger of a top stamp or a middle
#   stamp does not.
#   Exemption on the top row cancels the bonus, so every stamp scores its
#   own number. An Exemption off the top row does not. An Exemption in the
#   bottom row still adds 2, because the bottom row is not the top row.
#   The pay does not change patience.
# The both-blank doubling, the cross mark, and the bottom pay do not remove
# Hold or Exemption, and they do not cancel a retrigger.
#
# ENDPAPER BELL, in desk order
# A twenty-fourth night. The stamps, the ink, and the 3x3 form are unchanged.
# The endpaper bell deals the starting deck again. Drafts and the relic
# from an earlier night do not carry. Open it from the desk, or from a
# victory desk. Restart act replays whichever night is on the desk.
# - Isla Voss, lane column 1, exemption row middle, Square Toll:
#   "Patience drops by 2 when the number of filled cells is a perfect square."
#   Hollin Voss drops patience by 2 on the primes two, three, five, and
#   seven, and keeps the drop at 1 on zero, one, four, and nine. Una Pell
#   drops patience by 2 on every odd count, including one and nine, and
#   also on three, five, and seven, and keeps the drop at 1 on zero and
#   four. Soren Hale drops patience by 2 on every even count, including
#   zero and four, and also on two, six, and eight, and keeps the drop at
#   1 on one and nine. Ada Hart drops only for exactly four. Nia Soren
#   drops only for exactly nine. Isla does none of those. The drop is 2
#   instead of 1 when the number of filled cells is a perfect square:
#   zero, one, four, or nine. Counts of two, three, five, six, seven, and
#   eight keep the drop at 1. The toll does not change what a stamp scores.
#   Exemption on the middle row keeps the drop at 1, even on a square
#   count. An Exemption off the middle row does not.
#   Hold is applied before the square toll.
# - Edric Keel, lane column 2, exemption row top, End Blank:
#   "A stamp scores twice only when every immediate queue neighbor it has
#   is empty. A missing neighbor counts as empty."
#   The queue is read from the top row downward, left to right inside a
#   row, the same order Perrin Keel uses. The cell immediately before a
#   stamp is the previous cell in that order. The cell immediately after
#   it is the next cell. A missing neighbor counts as empty. The top-left
#   cell has no cell before it. It scores twice when the next cell is
#   empty, and it scores its own number when the next cell is filled. The
#   bottom-right cell has no cell after it. It scores twice when the
#   previous cell is empty, and it scores its own number when the previous
#   cell is filled. A stamp with both neighbors present scores twice only
#   when both are empty. A stamp with either neighbor filled scores its
#   own number. Perrin Keel doubles a stamp only when both neighbors exist
#   and both are empty, so the top-left and the bottom-right never double
#   for Perrin. Brigg Marsh doubles a stamp whenever the previous cell is
#   empty, even if the next cell is filled, and the top-left does not
#   double for Brigg. Orin Keel doubles a stamp whenever the next cell is
#   empty, even if the previous cell is filled, and the bottom-right does
#   not double for Orin. Edric does none of those. A retrigger of a stamp
#   that qualifies scores twice again. A retrigger of a stamp that does
#   not qualify does not.
#   Exemption on the top row cancels the doubling, so every stamp scores
#   its own number. An Exemption off the top row does not. An Exemption
#   that qualifies and sits off the top row scores twice.
#   The blank does not change patience.
# - Petra Hale, lane column 3, exemption row bottom, Frame Pay:
#   "Each stamp in a corner cell scores +2 once."
#   The corners are the top-left, the top-right, the bottom-left, and the
#   bottom-right. The four edge-middle cells and the center score their
#   own number. Neighbors do not change the bonus. A corner with two
#   neighbors still scores +2 once, not +4. A lone corner still scores +2.
#   Vesper Okell doubles a corner and does not add 2. Idris Reed adds 3
#   for a filled diagonal neighbor, including to a cell that is not a
#   corner, and a lone corner gets nothing from Idris. Ewan Holt doubles
#   the plus and does not double a corner. Petra does none of those. A
#   retrigger of a corner adds 2 again. A retrigger of an edge-middle cell
#   or the center does not.
#   Exemption on the bottom row cancels the bonus, so every stamp scores
#   its own number. An Exemption off the bottom row does not. An Exemption
#   in a corner and off the bottom row still adds 2.
#   The pay does not change patience.
# - Colin Fen, lane column 1, exemption row top, Lane Pay:
#   "Each stamp in column 2 scores +2 once."
#   Column 2 is the middle column. A stamp in column 1 or column 3 scores
#   its own number. The center, the top middle, and the bottom middle are
#   column 2, so each scores +2. Neighbors do not change the bonus. A lone
#   middle-column stamp still scores +2. Maren Fen adds 2 to the whole
#   bottom row, including the bottom corners, and does not add 2 to the
#   top middle. Yarrow Fen adds 2 to the whole top row, including the top
#   corners, and does not add 2 to the bottom middle. Weske Brant adds 2
#   to the whole middle row, including the left middle and the right
#   middle, and does not add 2 to the top middle or the bottom middle.
#   Fenn Hart doubles a stamp only when its column is full. Colin does
#   none of those. A retrigger of a middle-column stamp adds 2 again. A
#   retrigger of a column-1 or column-3 stamp does not.
#   Exemption on the top row cancels the bonus, so every stamp scores its
#   own number. An Exemption off the top row does not. An Exemption in
#   column 2 and off the top row still adds 2.
#   The pay does not change patience.
# The end-blank doubling, the frame pay, and the lane pay do not remove
# Hold or Exemption, and they do not cancel a retrigger.
#
# HALF-TITLE BELL, in desk order
# A twenty-fifth night. The stamps, the ink, and the 3x3 form are unchanged.
# The half-title bell deals the starting deck again. Drafts and the relic
# from an earlier night do not carry. Open it from the desk, or from a
# victory desk. Restart act replays whichever night is on the desk.
# - Tamsin Keel, lane column 3, exemption row bottom, Triad Toll:
#   "Patience drops by 2 when the number of filled cells is a multiple of 3."
#   Isla Voss drops patience by 2 on the perfect squares zero, one, four,
#   and nine, so she also drops on one and four, and keeps the drop at 1
#   on three and six. Soren Hale drops patience by 2 on every even count,
#   including zero and six, and also on two, four, and eight, and keeps
#   the drop at 1 on three and nine. Una Pell drops patience by 2 on every
#   odd count, including three and nine, and also on one, five, and seven,
#   and keeps the drop at 1 on zero and six. Pell Dane drops only for
#   exactly three. Hugh Pell drops only for exactly six. Nia Soren drops
#   only for exactly nine. Tamsin does none of those. The drop is 2
#   instead of 1 when the number of filled cells is a multiple of three:
#   zero, three, six, or nine. Counts of one, two, four, five, seven, and
#   eight keep the drop at 1. The toll does not change what a stamp scores.
#   Exemption on the bottom row keeps the drop at 1, even on a multiple
#   of three. An Exemption off the bottom row does not.
#   Hold is applied before the triad toll.
# - Tobin Hart, lane column 2, exemption row middle, Skip Blank:
#   "A stamp scores twice only when the queue cell two places before it
#   is empty."
#   The queue is read from the top row downward, left to right inside a
#   row, the same order Edric Keel uses. The cell two places before a
#   stamp can sit on the previous row. The top-left cell has no cell two
#   places before it, so it scores its own number. The top-middle cell has
#   no cell two places before it, so it scores its own number. The
#   top-right cell scores twice only when the top-left cell is empty. A
#   later cell looks two steps back. The immediate previous cell and the
#   immediate next cell do not matter. A filled cell two back means the
#   stamp scores its own number, even when both immediate neighbors are
#   empty. An empty cell two back means the stamp scores twice, even when
#   an immediate neighbor is filled. Brigg Marsh doubles a stamp whenever
#   the immediate previous cell is empty, including when the cell two back
#   is filled, and the top-middle cell can double for Brigg. Edric Keel
#   doubles a stamp only when every immediate neighbor it has is empty,
#   and a missing neighbor counts as empty, so the top-left can double
#   for Edric. Orin Keel looks at the next cell. Perrin Keel needs both
#   immediate neighbors to exist and be empty. Tobin does none of those.
#   A retrigger of a stamp whose cell two back is empty scores twice
#   again. A retrigger of any other stamp does not.
#   Exemption on the middle row cancels the doubling, so every stamp
#   scores its own number. An Exemption off the middle row does not. An
#   Exemption that qualifies and sits off the middle row scores twice.
#   The blank does not change patience.
# - Willa Brant, lane column 1, exemption row top, Wing Pay:
#   "Each stamp in the left-middle cell or the right-middle cell scores
#   +2 once."
#   The four corners, the center, the top middle, and the bottom middle
#   score their own number. Neighbors do not change the bonus. A wing with
#   two neighbors still scores +2 once, not +4. A lone wing still scores
#   +2. Tallow Keel doubles all four edge-middle cells, including the top
#   middle and the bottom middle, and that is twice the number rather
#   than +2. Weske Brant adds 2 to the whole middle row, including the
#   center. Colin Fen adds 2 to column 2, which is the top middle, the
#   center, and the bottom middle, and not the left middle or the right
#   middle. Ewan Holt doubles the plus, including the center and the top
#   and bottom middles. Willa does none of those. A retrigger of a wing
#   adds 2 again. A retrigger of any other cell does not.
#   Exemption on the top row cancels the bonus, so every stamp scores its
#   own number. An Exemption off the top row does not. An Exemption on a
#   wing and off the top row still adds 2.
#   The pay does not change patience.
# - Hess Fen, lane column 3, exemption row middle, Gutter Pay:
#   "Each stamp in column 1 scores +2 once."
#   A stamp in column 2 or column 3 scores its own number. The top-left,
#   the left middle, and the bottom-left are column 1, so each scores +2.
#   Neighbors do not change the bonus. A column-1 stamp with two neighbors
#   still scores +2 once, not +4. A lone column-1 stamp still scores +2.
#   Colin Fen adds 2 to column 2 and does not add 2 to column 1. Maren Fen
#   adds 2 to the whole bottom row, including the bottom of column 2 and
#   column 3. Yarrow Fen adds 2 to the whole top row. Petra Hale adds 2 to
#   the four corners, including the top and bottom of column 3, and does
#   not add 2 to the left middle. Hess does none of those. A retrigger of
#   a column-1 stamp adds 2 again. A retrigger of a column-2 or column-3
#   stamp does not.
#   Exemption on the middle row cancels the bonus, so every stamp scores
#   its own number. An Exemption off the middle row does not. An Exemption
#   in column 1 and off the middle row still adds 2.
#   The pay does not change patience.
# The skip-blank doubling, the wing pay, and the gutter pay do not remove
# Hold or Exemption, and they do not cancel a retrigger.
#
# TITLE-PAGE BELL, in desk order
# A twenty-sixth night. The stamps, the ink, and the 3x3 form are unchanged.
# The title-page bell deals the starting deck again. Drafts and the relic
# from an earlier night do not carry. Open it from the desk, or from a
# victory desk. Restart act replays whichever night is on the desk.
# - Nessa Voss, lane column 2, exemption row top, High Toll:
#   "Patience drops by 2 when the number of filled cells is 7, 8, or 9."
#   Dory Hart drops patience by 2 only for exactly seven cells, and keeps
#   the drop at 1 for eight and for nine. Gwyn Brant drops only for exactly
#   eight, and keeps the drop at 1 for seven and for nine. Nia Soren drops
#   only for exactly nine, and keeps the drop at 1 for seven and for eight.
#   Una Pell drops for every odd count, including one, three, and five, and
#   keeps the drop at 1 for the even counts zero, two, four, and six. Soren
#   Hale drops for every even count, including zero, two, four, and six, and
#   keeps the drop at 1 for the odd counts one, three, and five. Nessa does
#   none of those. The drop is 2 instead of 1 when the number of filled
#   cells is seven, eight, or nine. Counts of zero through six keep the
#   drop at 1. The toll does not change what a stamp scores.
#   Exemption on the top row keeps the drop at 1, even on seven, eight, or
#   nine. An Exemption off the top row does not.
#   Hold is applied before the high toll.
# - Ned Keel, lane column 1, exemption row bottom, Skip Fill:
#   "A stamp scores twice only when the queue cell two places before it
#   is filled."
#   The queue is read from the top row downward, left to right inside a
#   row, the same order Tobin Hart uses. The cell two places before a
#   stamp can sit on the previous row. The top-left cell has no cell two
#   places before it, so it scores its own number. The top-middle cell has
#   no cell two places before it, so it scores its own number. The
#   top-right cell scores twice only when the top-left cell is filled. A
#   later cell looks two steps back. The immediate previous cell and the
#   immediate next cell do not matter. An empty cell two back means the
#   stamp scores its own number, even when both immediate neighbors are
#   filled. A filled cell two back means the stamp scores twice, even when
#   an immediate neighbor is empty. Tobin Hart doubles a stamp only when
#   the cell two back is empty, so the top-right cell alone doubles for
#   Tobin and a filled cell two back does not. Brigg Marsh looks at the
#   immediate previous cell, so the top-middle cell can double for Brigg
#   and a filled previous cell does not double even when the cell two back
#   is empty. Hester Keel looks at the immediate previous cell being
#   filled, so she doubles the top-right cell when the top-middle cell is
#   filled and does not double it when only the top-left cell is filled.
#   Ned does none of those. A retrigger of a stamp whose cell two back is
#   filled scores twice again. A retrigger of any other stamp does not.
#   Exemption on the bottom row cancels the doubling, so every stamp
#   scores its own number. An Exemption off the bottom row does not. An
#   Exemption that qualifies and sits off the bottom row scores twice.
#   The fill does not change patience.
# - Sela Fen, lane column 3, exemption row middle, Post Pay:
#   "Each stamp in column 3 scores +2 once."
#   A stamp in column 1 or column 2 scores its own number. The top-right,
#   the right middle, and the bottom-right are column 3, so each scores
#   +2. Neighbors do not change the bonus. A column-3 stamp with two
#   neighbors still scores +2 once, not +4. A lone column-3 stamp still
#   scores +2. Hess Fen adds 2 to column 1 and does not add 2 to column 3.
#   Colin Fen adds 2 to column 2 and does not add 2 to column 3. Petra Hale
#   adds 2 to the four corners, including the top and bottom of column 3,
#   and does not add 2 to the right middle. Yarrow Fen adds 2 to the whole
#   top row and does not add 2 to the right middle. Maren Fen adds 2 to
#   the whole bottom row and does not add 2 to the right middle. Sela does
#   none of those. A retrigger of a column-3 stamp adds 2 again. A
#   retrigger of a column-1 or column-2 stamp does not.
#   Exemption on the middle row cancels the bonus, so every stamp scores
#   its own number. An Exemption off the middle row does not. An Exemption
#   in column 3 and off the middle row still adds 2.
#   The pay does not change patience.
# - Tess Okell, lane column 2, exemption row top, Seam Pay:
#   "Each stamp that shares a side with at least one other filled stamp
#   scores +2 once."
#   A corner touch does not count. A lone stamp scores its own number. A
#   stamp with two side neighbors still scores +2 once, not +2 for each
#   neighbor. Opal Quill adds 3 for a side share and does not add 2. Idris
#   Reed adds 3 for a diagonal neighbor and does not add 2 for a side.
#   Rue Hart doubles the later stamp of a side pair and leaves the earlier
#   stamp at its own number. Tess does none of those. A retrigger of a
#   stamp that shares a side adds 2 again. A retrigger of a stamp that
#   does not share a side does not.
#   Exemption on the top row cancels the bonus, so every stamp scores its
#   own number. An Exemption off the top row does not. An Exemption that
#   shares a side and sits off the top row still adds 2.
#   The pay does not change patience.
# The skip-fill doubling, the post pay, and the seam pay do not remove
# Hold or Exemption, and they do not cancel a retrigger.
#
# COPYRIGHT BELL, in desk order
# A twenty-seventh night. The stamps, the ink, and the 3x3 form are unchanged.
# The copyright bell deals the starting deck again. Drafts and the relic
# from an earlier night do not carry. Open it from the desk, or from a
# victory desk. Restart act replays whichever night is on the desk.
# - Merrick Hale, lane column 3, exemption row bottom, Low Toll:
#   "Patience drops by 2 when the number of filled cells is 0, 1, or 2."
#   Nessa Voss drops patience by 2 for seven, eight, or nine, and keeps
#   the drop at 1 for zero, one, and two. Isla Voss drops for the squares
#   zero, one, four, and nine, so she also drops for four and for nine,
#   and keeps the drop at 1 for two. Soren Hale drops for every even count,
#   including zero and two, and also for four, six, and eight, and keeps
#   the drop at 1 for one. Una Pell drops for every odd count, including
#   one, and also for three, five, seven, and nine, and keeps the drop at
#   1 for zero and for two. Merrick does none of those. The drop is 2
#   instead of 1 when the number of filled cells is zero, one, or two.
#   Counts of three through nine keep the drop at 1. The toll does not
#   change what a stamp scores.
#   Exemption on the bottom row keeps the drop at 1, even on zero, one, or
#   two. An Exemption off the bottom row does not.
#   Hold is applied before the low toll.
# - Oren Voss, lane column 2, exemption row top, Skip Gap:
#   "A stamp scores twice only when the queue cell two places after it is
#   empty."
#   The queue is read from the top row downward, left to right inside a
#   row, the same order Ned Keel uses. The cell two places after a stamp
#   can sit on the next row. The bottom-middle cell has no cell two places
#   after it, so it scores its own number. The bottom-right cell has no
#   cell two places after it, so it scores its own number. The bottom-left
#   cell scores twice only when the bottom-right cell is empty. An earlier
#   cell looks two steps ahead. The immediate next cell and the immediate
#   previous cell do not matter. A filled cell two ahead means the stamp
#   scores its own number, even when both immediate neighbors are empty.
#   An empty cell two ahead means the stamp scores twice, even when an
#   immediate neighbor is filled. Ned Keel doubles a stamp only when the
#   cell two back is filled. Tobin Hart doubles a stamp only when the cell
#   two back is empty. Orin Keel doubles a stamp only when the immediate
#   next cell is empty. Oren does none of those. A retrigger of a stamp
#   whose cell two ahead is empty scores twice again. A retrigger of any
#   other stamp does not.
#   Exemption on the top row cancels the doubling, so every stamp scores
#   its own number. An Exemption off the top row does not. An Exemption
#   that qualifies and sits off the top row scores twice.
#   The gap does not change patience.
# - Nim Brant, lane column 1, exemption row middle, Crown Pay:
#   "Each stamp in the top-middle cell scores +2 once."
#   Every other cell scores its own number. Neighbors do not change the
#   bonus. A top-middle stamp with two neighbors still scores +2 once, not
#   +4. A lone top-middle stamp still scores +2. Yarrow Fen adds 2 to the
#   whole top row, including the top corners, and not only the top middle.
#   Colin Fen adds 2 to all of column 2, including the center and the
#   bottom middle, and not only the top middle. Willa Brant adds 2 to the
#   left middle and the right middle, and not to the top middle. Nim does
#   none of those. A retrigger of the top-middle stamp adds 2 again. A
#   retrigger of any other cell does not.
#   Exemption on the middle row cancels the bonus, so every stamp scores
#   its own number. An Exemption off the middle row does not. An Exemption
#   in the top-middle cell and off the middle row still adds 2.
#   The pay does not change patience.
# - Syl Okell, lane column 3, exemption row bottom, Void Pay:
#   "Each stamp that shares no side with another filled stamp scores +2
#   once."
#   A corner touch does not count as a side. A lone stamp scores +2. A
#   stamp with one or more side neighbors scores its own number. Two
#   corner neighbors and no side neighbor still scores +2. Tess Okell adds
#   2 to a stamp that shares a side, and a lone stamp gets nothing from
#   Tess. Opal Quill adds 3 for a side share. Idris Reed adds 3 for a
#   diagonal neighbor. Syl does none of those. A retrigger of a stamp with
#   no side neighbor adds 2 again. A retrigger of a stamp that shares a
#   side does not.
#   Exemption on the bottom row cancels the bonus, so every stamp scores
#   its own number. An Exemption off the bottom row does not. An Exemption
#   with no side neighbor and off the bottom row still adds 2.
#   The pay does not change patience.
# The skip-gap doubling, the crown pay, and the void pay do not remove
# Hold or Exemption, and they do not cancel a retrigger.
#
# DEDICATION BELL, in desk order
# A twenty-eighth night. The stamps, the ink, and the 3x3 form are unchanged.
# The dedication bell deals the starting deck again. Drafts and the relic
# from an earlier night do not carry. Open it from the desk, or from a
# victory desk. Restart act replays whichever night is on the desk.
# Petra Hale already stands on the endpaper bell with Frame Pay, so this
# night's cube toll is Maud Hale. Cube Toll itself was free.
# - Maud Hale, lane column 3, exemption row bottom, Cube Toll:
#   "Patience drops by 2 when the number of filled cells is 1 or 8."
#   Counts of zero, two, three, four, five, six, seven, and nine keep the
#   drop at 1. Gwyn Brant drops only for eight, and keeps the drop at 1
#   for one. Merrick Hale drops for zero, one, and two, so he also drops
#   for zero and for two, and keeps the drop at 1 for eight. Isla Voss
#   drops for the squares zero, one, four, and nine, so she also drops for
#   zero, four, and nine, and keeps the drop at 1 for eight. Una Pell drops
#   for every odd count, one, three, five, seven, and nine, and keeps the
#   drop at 1 for eight. Maud does none of those. The drop is 2 instead of
#   1 only when the number of filled cells is one or eight. The toll does
#   not change what a stamp scores.
#   Exemption on the bottom row keeps the drop at 1, even on one or eight.
#   An Exemption off the bottom row does not.
#   Hold is applied before the cube toll.
# - Colm Voss, lane column 2, exemption row top, Far Blank:
#   "A stamp scores twice only when the queue cell three places after it is
#   empty."
#   The queue is read from the top row downward, left to right inside a
#   row, the same order Oren Voss uses. Three places after a stamp is the
#   cell in the same column on the next row. The bottom-left cell has no
#   cell three places after it, so it scores its own number. The
#   bottom-middle cell has no cell three places after it, so it scores its
#   own number. The bottom-right cell has no cell three places after it, so
#   it scores its own number. The cell one place after a stamp and the cell
#   two places after it do not matter. A filled cell three ahead means the
#   stamp scores its own number, even when the cells one ahead and two
#   ahead are empty. An empty cell three ahead means the stamp scores
#   twice, even when the cell one ahead or the cell two ahead is filled.
#   Oren Voss doubles a stamp only when the cell two ahead is empty, and
#   does not look three ahead. Orin Keel doubles a stamp only when the
#   immediate next cell is empty. Ned Keel doubles a stamp only when the
#   cell two back is filled. Colm does none of those. A retrigger of a
#   stamp whose cell three ahead is empty scores twice again. A retrigger
#   of any other stamp does not.
#   Exemption on the top row cancels the doubling, so every stamp scores
#   its own number. An Exemption off the top row does not. An Exemption
#   that qualifies and sits off the top row scores twice.
#   The blank does not change patience.
# - Sibley Brant, lane column 1, exemption row middle, Heart Pay:
#   "Each stamp in the center cell scores +2 once."
#   Every other cell scores its own number. Neighbors do not change the
#   bonus. A center stamp with two neighbors still scores +2 once, not +4.
#   A lone center stamp still scores +2. Nim Brant adds 2 only to the top
#   middle, and the center scores its own number for Nim. Colin Fen adds 2
#   to all of column 2, including the top middle and the bottom middle, and
#   not only the center. Weske Brant adds 2 to the whole middle row,
#   including the left middle and the right middle. Wynn Cress doubles the
#   center and does not add 2. Sibley does none of those. A retrigger of
#   the center adds 2 again. A retrigger of any other cell does not.
#   Exemption on the middle row cancels the bonus, so every stamp scores
#   its own number. The center is on the middle row, so an Exemption in the
#   center cancels the bonus. An Exemption off the middle row does not. An
#   Exemption off the middle row leaves the center's +2.
#   The pay does not change patience.
# - Orrin Okell, lane column 3, exemption row top, Short Toll:
#   "Patience drops by 2 when the number of filled cells is 1 or 2."
#   A count of zero keeps the drop at 1, and so do counts of three through
#   nine. Merrick Hale drops for zero, one, and two, so he also drops for
#   zero. Hollin Voss drops for the primes two, three, five, and seven, so
#   he also drops for three, five, and seven, and keeps the drop at 1 for
#   one. Una Pell drops for every odd count, including one, and also for
#   three, five, seven, and nine, and keeps the drop at 1 for two. Orrin
#   does none of those. The drop is 2 instead of 1 only when the number of
#   filled cells is one or two. The toll does not change what a stamp
#   scores.
#   Exemption on the top row keeps the drop at 1, even on one or two. An
#   Exemption off the top row does not.
#   Hold is applied before the short toll.
# The far-blank doubling and the heart pay do not remove Hold or Exemption,
# and they do not cancel a retrigger.
#
# EPIGRAPH BELL, in desk order
# A twenty-ninth night. The stamps, the ink, and the 3x3 form are unchanged.
# The epigraph bell deals the starting deck again. Drafts and the relic
# from an earlier night do not carry. Open it from the desk, or from a
# victory desk. Restart act replays whichever night is on the desk.
# The epigraph name was free. The dedication button stays to its left.
# - Enid Hale, lane column 1, exemption row bottom, Composite Toll:
#   "Patience drops by 2 when the number of filled cells is 4, 6, 8, or 9."
#   Counts of zero, one, two, three, five, and seven keep the drop at 1.
#   Ada Hart drops only for four. Hugh Pell drops only for six. Gwyn Brant
#   drops only for eight. Nia Soren drops only for nine. Soren Hale drops
#   for every even count, including zero and two, and keeps the drop at 1
#   for nine. Isla Voss drops for the squares zero, one, four, and nine, so
#   she also drops for zero and for one, and keeps the drop at 1 for six
#   and for eight. Maud Hale drops for one and for eight, so she also drops
#   for one, and keeps the drop at 1 for four, six, and nine. Enid does
#   none of those. The drop is 2 instead of 1 only when the number of
#   filled cells is four, six, eight, or nine. The toll does not change
#   what a stamp scores.
#   Exemption on the bottom row keeps the drop at 1, even on four, six,
#   eight, or nine. An Exemption off the bottom row does not.
#   Hold is applied before the composite toll.
# - Phel Voss, lane column 3, exemption row top, Far Fill:
#   "A stamp scores twice only when the queue cell three places after it is
#   filled."
#   The queue is read from the top row downward, left to right inside a
#   row, the same order Colm Voss uses. Three places after a stamp is the
#   cell in the same column on the next row. The bottom-left cell has no
#   cell three places after it, so it scores its own number. The
#   bottom-middle cell has no cell three places after it, so it scores its
#   own number. The bottom-right cell has no cell three places after it, so
#   it scores its own number. The cell one place after a stamp and the cell
#   two places after it do not matter. An empty cell three ahead means the
#   stamp scores its own number, even when the cells one ahead and two
#   ahead are filled. A filled cell three ahead means the stamp scores
#   twice, even when the cell one ahead or the cell two ahead is empty.
#   Colm Voss doubles a stamp only when the cell three ahead is empty.
#   Ned Keel doubles a stamp only when the cell two places before it is
#   filled, and does not look three ahead. Oren Voss doubles a stamp only
#   when the cell two ahead is empty. Phel does none of those. A retrigger
#   of a stamp whose cell three ahead is filled scores twice again. A
#   retrigger of any other stamp does not.
#   Exemption on the top row cancels the doubling, so every stamp scores
#   its own number. An Exemption off the top row does not. An Exemption
#   that qualifies and sits off the top row scores twice.
#   The fill does not change patience.
# - Lark Brant, lane column 2, exemption row middle, Open Pay:
#   "Each stamp that shares no side and no corner with another filled stamp
#   scores +2 once."
#   A corner touch counts. A side touch counts. A lone stamp scores +2. A
#   stamp with only a corner neighbor scores its own number. A stamp with a
#   side neighbor scores its own number. Syl Okell adds 2 to a stamp with
#   no side neighbor even when a corner neighbor is filled. Opal Quill adds
#   3 for a side share. Idris Reed adds 3 for a diagonal neighbor. Lark does
#   none of those. A retrigger adds 2 again only while the stamp still
#   shares no side and no corner. Echo, Reply, and Ripple sit on a side of
#   the stamp they retrigger, so that retrigger does not add 2.
#   Exemption on the middle row cancels the bonus, so every stamp scores
#   its own number. An Exemption off the middle row does not. An Exemption
#   with no neighbor and off the middle row still adds 2.
#   The pay does not change patience.
# - Doss Okell, lane column 1, exemption row bottom, Long Blank:
#   "A stamp scores twice only when the queue cell four places after it is
#   empty."
#   The queue is the same order Colm Voss uses. Four places after a stamp
#   can land on the next row or the row after that. The middle-right cell
#   has no cell four places after it, so it scores its own number. The
#   bottom-left, bottom-middle, and bottom-right cells have no cell four
#   places after them, so they score their own numbers. The cells one, two,
#   and three places after a stamp do not matter. A filled cell four ahead
#   means the stamp scores its own number, even when the cells one, two,
#   and three ahead are empty. An empty cell four ahead means the stamp
#   scores twice, even when a nearer cell is filled. Colm Voss looks three
#   ahead. Oren Voss looks two ahead. Orin Keel looks one ahead. Doss does
#   none of those. A retrigger of a stamp whose cell four ahead is empty
#   scores twice again. A retrigger of any other stamp does not.
#   Exemption on the bottom row cancels the doubling, so every stamp scores
#   its own number. An Exemption off the bottom row does not. An Exemption
#   that qualifies and sits off the bottom row scores twice.
#   The blank does not change patience.
# The far-fill doubling, the open pay, and the long-blank doubling do not
# remove Hold or Exemption, and they do not cancel a retrigger.
#
# PREFACE BELL, in desk order
# A thirtieth night. The stamps, the ink, and the 3x3 form are unchanged.
# The preface bell deals the starting deck again. Drafts and the relic
# from an earlier night do not carry. Open it from the desk, or from a
# victory desk. Restart act replays whichever night is on the desk.
# The preface name was free. The epigraph button stays to its left.
# Dedication stays to the left of the epigraph button.
# - Neve Hale, lane column 2, exemption row top, Power Toll:
#   "Patience drops by 2 when the number of filled cells is 1, 2, 4, or 8."
#   Counts of zero, three, five, six, seven, and nine keep the drop at 1.
#   Isla Voss drops for the squares zero, one, four, and nine, so she also
#   drops for zero and for nine, and keeps the drop at 1 for two and for
#   eight. Maud Hale drops for one and for eight, and keeps the drop at 1
#   for two and for four. Soren Hale drops for every even count, including
#   zero and six, and keeps the drop at 1 for one. Enid Hale drops for four,
#   six, eight, and nine, so she also drops for six and for nine, and keeps
#   the drop at 1 for one and for two. Hollin Voss drops for the primes two,
#   three, five, and seven, so he also drops for three, five, and seven, and
#   keeps the drop at 1 for one, four, and eight. Neve does none of those.
#   The drop is 2 instead of 1 only on one, two, four, or eight. The toll
#   does not change what a stamp scores.
#   Exemption on the top row keeps the drop at 1, even on one, two, four,
#   or eight. An Exemption off the top row does not.
#   Hold is applied before the power toll.
# - Tarn Voss, lane column 1, exemption row middle, Farther Blank:
#   "A stamp scores twice only when the queue cell five places after it is
#   empty."
#   The queue is read from the top row downward, left to right inside a
#   row, the same order Doss Okell uses. Five places after a stamp can land
#   two rows down. The center cell has no cell five places after it, so it
#   scores its own number. The middle-right cell has no cell five places
#   after it, so it scores its own number. The bottom-left, bottom-middle,
#   and bottom-right cells have no cell five places after them, so they
#   score their own numbers. The cells one, two, three, and four places
#   after a stamp do not matter. A filled cell five ahead means the stamp
#   scores its own number, even when the nearer cells are empty. An empty
#   cell five ahead means the stamp scores twice, even when a nearer cell
#   is filled. Doss Okell looks four ahead and doubles when that cell is
#   empty. Colm Voss looks three ahead. Oren Voss looks two ahead. Orin
#   Keel looks one ahead. Tarn does none of those. A retrigger of a stamp
#   whose cell five ahead is empty scores twice again. A retrigger of a
#   stamp whose cell five ahead is filled does not.
#   Exemption on the middle row cancels the doubling, so every stamp scores
#   its own number. An Exemption off the middle row does not. An Exemption
#   that qualifies and sits off the middle row scores twice.
#   The blank does not change patience.
# - Cade Brant, lane column 3, exemption row bottom, Rim Pay:
#   "Each stamp in an edge-middle cell scores +2 once."
#   The edge-middle cells are the top middle, the left middle, the right
#   middle, and the bottom middle. The four corners and the center score
#   their own number. Neighbors do not change the bonus. Two neighbors do
#   not add 4. A lone edge-middle stamp still scores +2. Tallow Keel doubles
#   an edge-middle cell and does not add 2. Nim Brant adds 2 only to the top
#   middle. Hess Fen adds 2 to all of column 1, including the two left
#   corners. Sela Fen adds 2 to all of column 3, including the two right
#   corners. Sibley Brant adds 2 only to the center. Cade does none of those.
#   A retrigger of an edge-middle stamp adds 2 again. A retrigger of a corner
#   or the center does not.
#   Exemption on the bottom row cancels the bonus, so every stamp scores its
#   own number. An Exemption off the bottom row does not. An Exemption on an
#   edge-middle cell and off the bottom row still adds 2.
#   The pay does not change patience.
# - Sile Okell, lane column 2, exemption row top, Long Fill:
#   "A stamp scores twice only when the queue cell four places after it is
#   filled."
#   The queue is the same order Doss Okell uses. Four places after a stamp
#   can land on the next row or the row after that. The middle-right cell
#   has no cell four places after it, so it scores its own number. The
#   bottom-left, bottom-middle, and bottom-right cells have no cell four
#   places after them, so they score their own numbers. The cells one, two,
#   and three places after a stamp do not matter. An empty cell four ahead
#   means the stamp scores its own number, even when the nearer cells are
#   filled. A filled cell four ahead means the stamp scores twice, even when
#   a nearer cell is empty. Doss Okell doubles when the cell four ahead is
#   empty. Phel Voss doubles when the cell three ahead is filled. Holt Quern
#   doubles when the next cell is filled. Sile does none of those. A retrigger
#   of a stamp whose cell four ahead is filled scores twice again. A retrigger
#   of a stamp whose cell four ahead is empty does not.
#   Exemption on the top row cancels the doubling, so every stamp scores its
#   own number. An Exemption off the top row does not. An Exemption that
#   qualifies and sits off the top row scores twice.
#   The fill does not change patience.
# The farther-blank doubling, the rim pay, and the long-fill doubling do not
# remove Hold or Exemption, and they do not cancel a retrigger.
#
# FOREWORD BELL, in desk order
# A thirty-first night. The stamps, the ink, and the 3x3 form are unchanged.
# The foreword bell deals the starting deck again. Drafts and the relic
# from an earlier night do not carry. Open it from the desk, or from a
# victory desk. Restart act replays whichever night is on the desk.
# The foreword name was free. The preface button stays to its left.
# Epigraph stays to the left of the preface button. Dedication stays to
# the left of the epigraph button.
# - Shay Hale, lane column 3, exemption row bottom, Mid Toll:
#   "Patience drops by 2 when the number of filled cells is 3, 4, 5, or 6."
#   Counts of zero, one, two, seven, eight, and nine keep the drop at 1.
#   Pell Dane drops only for three. Ada Hart drops only for four. Joss Pell
#   drops only for five. Hugh Pell drops only for six. Hollin Voss drops for
#   two, three, five, and seven, so he also drops for two and for seven, and
#   keeps the drop at 1 for four and for six. Enid Hale drops for four, six,
#   eight, and nine, so she also drops for eight and for nine, and keeps the
#   drop at 1 for three and for five. Nessa Voss drops for seven, eight, and
#   nine, and keeps the drop at 1 for three, four, five, and six. Merrick
#   Hale drops for zero, one, and two, and keeps the drop at 1 for three,
#   four, five, and six. Shay does none of those. The drop is 2 instead of 1
#   only on three, four, five, or six. The toll does not change what a stamp
#   scores.
#   Exemption on the bottom row keeps the drop at 1, even on three, four,
#   five, or six. An Exemption off the bottom row does not.
#   Hold is applied before the mid toll.
# - Glen Voss, lane column 2, exemption row top, Farther Fill:
#   "A stamp scores twice only when the queue cell five places after it is
#   filled."
#   The queue is read from the top row downward, left to right inside a
#   row, the same order Tarn Voss uses. Five places after a stamp can land
#   two rows down. The center cell has no cell five places after it, so it
#   scores its own number. The middle-right cell has no cell five places
#   after it, so it scores its own number. The bottom-left, bottom-middle,
#   and bottom-right cells have no cell five places after them, so they
#   score their own numbers. The cells one, two, three, and four places
#   after a stamp do not matter. An empty cell five ahead means the stamp
#   scores its own number, even when the nearer cells are filled. A filled
#   cell five ahead means the stamp scores twice, even when a nearer cell
#   is empty. Tarn Voss doubles when the cell five ahead is empty. Sile
#   Okell doubles when the cell four ahead is filled. Phel Voss doubles
#   when the cell three ahead is filled. Glen does none of those. A
#   retrigger of a stamp whose cell five ahead is filled scores twice
#   again. A retrigger of a stamp whose cell five ahead is empty does not.
#   Exemption on the top row cancels the doubling, so every stamp scores
#   its own number. An Exemption off the top row does not. An Exemption
#   that qualifies and sits off the top row scores twice.
#   The fill does not change patience.
# - Dell Brant, lane column 1, exemption row top, Mitre Pay:
#   "Each stamp that has at least one corner neighbor and no side neighbor
#   scores +2 once."
#   A corner touch counts. A side touch does not qualify, even when a corner
#   is also filled. A lone stamp scores its own number. Two corner neighbors
#   still add 2 once, not 2 for each. Lark Brant adds 2 only when a stamp has
#   no neighbor at all, so a corner neighbor gets nothing from Lark. Syl
#   Okell adds 2 to a stamp with no side neighbor, including a lone stamp.
#   Idris Reed adds 3 for a diagonal neighbor, and a side neighbor does not
#   cancel it. Dell does none of those. A retrigger adds 2 again only while
#   the stamp still has a corner neighbor and no side neighbor. Echo, Reply,
#   and Ripple sit on a side of the stamp they retrigger, so that retrigger
#   does not add 2.
#   Exemption on the top row cancels the bonus, so every stamp scores its
#   own number. An Exemption off the top row does not. An Exemption that
#   qualifies and sits off the top row still adds 2.
#   The pay does not change patience.
# - Faye Okell, lane column 3, exemption row middle, Long Back:
#   "A stamp scores twice only when the queue cell four places before it is
#   filled."
#   The queue is the same order Tarn Voss uses. Four places before a stamp
#   can land on the previous row or the row before that. The top-left cell
#   has no cell four places before it, so it scores its own number. The
#   top-middle cell has no cell four places before it, so it scores its own
#   number. The top-right cell has no cell four places before it, so it
#   scores its own number. The middle-left cell has no cell four places
#   before it, so it scores its own number. The cells one, two, and three
#   places before a stamp do not matter. An empty cell four back means the
#   stamp scores its own number, even when the nearer cells are filled. A
#   filled cell four back means the stamp scores twice, even when a nearer
#   cell is empty. No earlier traveler doubles on a filled cell four places
#   back. Ned Keel doubles when the cell two back is filled. Hester Keel
#   doubles when the cell one back is filled. Sile Okell doubles when the
#   cell four ahead is filled. Faye does none of those. A retrigger of a
#   stamp whose cell four back is filled scores twice again. A retrigger of
#   a stamp whose cell four back is empty does not.
#   Exemption on the middle row cancels the doubling, so every stamp scores
#   its own number. An Exemption off the middle row does not. An Exemption
#   that qualifies and sits off the middle row scores twice.
#   The fill does not change patience.
# The farther-fill doubling, the mitre pay, and the long-back doubling do not
# remove Hold or Exemption, and they do not cancel a retrigger.
#
# CONTENTS BELL, in desk order
# A thirty-second night. The stamps, the ink, and the 3x3 form are unchanged.
# The contents bell deals the starting deck again. Drafts and the relic
# from an earlier night do not carry. Open it from the desk, or from a
# victory desk. Restart act replays whichever night is on the desk.
# The contents name was free. The foreword button stays to its left.
# Preface stays to the left of the foreword button. Epigraph stays to the
# left of the preface button. Dedication stays to the left of the epigraph
# button.
# - Ross Hale, lane column 1, exemption row top, Outer Toll:
#   "Patience drops by 2 when the number of filled cells is 0 or 9."
#   Counts of one through eight keep the drop at 1. Nia Soren drops only for
#   nine, and keeps the drop at 1 for zero. Isla Voss drops for the squares
#   zero, one, four, and nine, so she also drops for one and for four.
#   Soren Hale drops for every even count, including zero, two, four, six,
#   and eight, and keeps the drop at 1 for nine. Merrick Hale drops for
#   zero, one, and two, so he also drops for one and for two, and keeps the
#   drop at 1 for nine. Ross does none of those. The drop is 2 instead of 1
#   only on zero or nine. The toll does not change what a stamp scores.
#   Exemption on the top row keeps the drop at 1, even on zero or nine. An
#   Exemption off the top row does not.
#   Hold is applied before the outer toll.
# - Jude Voss, lane column 3, exemption row bottom, Near Blank:
#   "A stamp scores twice only when the queue cell three places before it is
#   empty."
#   The queue is read from the top row downward, left to right inside a
#   row, the same order Tarn Voss uses. Three places before a stamp is the
#   cell directly above it. The top-left cell has no cell three places
#   before it, so it scores its own number. The top-middle cell has no cell
#   three places before it, so it scores its own number. The top-right cell
#   has no cell three places before it, so it scores its own number. The
#   cells one and two places before a stamp do not matter. A filled cell
#   three back means the stamp scores its own number, even when the nearer
#   cells are empty. An empty cell three back means the stamp scores twice,
#   even when a nearer cell is filled. No earlier traveler doubles on an
#   empty cell three places back, so this form keeps the name Near Blank.
#   Tobin Hart doubles when the cell two back is empty. Brigg Marsh doubles
#   when the cell one back is empty. Faye Okell doubles when the cell four
#   back is filled. Jude does none of those. A retrigger of a stamp whose
#   cell three back is empty scores twice again. A retrigger of a stamp
#   whose cell three back is filled does not.
#   Exemption on the bottom row cancels the doubling, so every stamp scores
#   its own number. An Exemption off the bottom row does not. An Exemption
#   that qualifies and sits off the bottom row scores twice.
#   The blank does not change patience.
# - Clem Brant, lane column 2, exemption row middle, Brace Pay:
#   "Each stamp that has at least one side neighbor and at least one corner
#   neighbor scores +2 once."
#   A side neighbor with no corner neighbor scores its own number. A corner
#   neighbor with no side neighbor scores its own number. A lone stamp
#   scores its own number. Two side neighbors, or two corner neighbors,
#   still add 2 once, not 2 for each. Tess Okell adds 2 for a side neighbor,
#   and a corner neighbor is not required. Dell Brant adds 2 for a corner
#   neighbor only when there is no side neighbor. Opal Quill adds 3 for a
#   side share. Idris Reed adds 3 for a diagonal neighbor, and a side
#   neighbor does not cancel it. Clem does none of those. A retrigger of a
#   qualifying stamp adds 2 again. Echo, Reply, and Ripple sit on a side of
#   the stamp they retrigger. That retrigger adds 2 only when the stamp also
#   has a corner neighbor.
#   Exemption on the middle row cancels the bonus, so every stamp scores its
#   own number. An Exemption off the middle row does not. An Exemption that
#   qualifies and sits off the middle row still adds 2.
#   The pay does not change patience.
# - Ansel Okell, lane column 1, exemption row bottom, Farther Back:
#   "A stamp scores twice only when the queue cell five places before it is
#   filled."
#   The queue is the same order Tarn Voss uses. Five places before a stamp
#   can land on the previous row or the row before that. The top-left cell
#   has no cell five places before it, so it scores its own number. The
#   top-middle cell has no cell five places before it, so it scores its own
#   number. The top-right cell has no cell five places before it, so it
#   scores its own number. The middle-left cell has no cell five places
#   before it, so it scores its own number. The center cell has no cell five
#   places before it, so it scores its own number. The cells one through
#   four places before a stamp do not matter. An empty cell five back means
#   the stamp scores its own number, even when the nearer cells are filled.
#   A filled cell five back means the stamp scores twice, even when a nearer
#   cell is empty. No earlier traveler doubles on a filled cell five places
#   back, so this form keeps the name Farther Back. Faye Okell doubles when
#   the cell four back is filled. Ned Keel doubles when the cell two back is
#   filled. Glen Voss doubles when the cell five ahead is filled. Tarn Voss
#   doubles when the cell five ahead is empty. Ansel does none of those. A
#   retrigger of a stamp whose cell five back is filled scores twice again.
#   A retrigger of a stamp whose cell five back is empty does not.
#   Exemption on the bottom row cancels the doubling, so every stamp scores
#   its own number. An Exemption off the bottom row does not. An Exemption
#   that qualifies and sits off the bottom row scores twice.
#   The fill does not change patience.
# The near-blank doubling, the brace pay, and the farther-back doubling do not
# remove Hold or Exemption, and they do not cancel a retrigger.
#
# INTRODUCTION BELL, in desk order
# A thirty-third night. The stamps, the ink, and the 3x3 form are unchanged.
# The introduction bell deals the starting deck again. Drafts and the relic
# from an earlier night do not carry. Open it from the desk, or from a
# victory desk. Restart act replays whichever night is on the desk.
# The introduction name was free. The contents button stays to its left.
# Foreword stays to the left of the contents button. Preface stays to the
# left of the foreword button. Epigraph stays to the left of the preface
# button.
# No earlier traveler doubles on a filled cell three places back, so Brea
# Voss keeps the name Near Fill. No earlier traveler doubles on an empty
# cell five places back, so Calder Okell keeps the name Farther Gap. The
# empty-cell-four-places-back fallback was not needed, so Long Gap stays
# unused.
# - Quin Hale, lane column 2, exemption row middle, Span Toll:
#   "Patience drops by 2 when the number of filled cells is 5 or 6."
#   Counts of zero, one, two, three, four, seven, eight, and nine keep the
#   drop at 1. Joss Pell drops only for five. Hugh Pell drops only for six.
#   Shay Hale drops for three, four, five, and six, so she also drops for
#   three and for four. Hollin Voss drops for two, three, five, and seven,
#   and keeps the drop at 1 for six. Enid Hale drops for four, six, eight,
#   and nine, and keeps the drop at 1 for five. Quin does none of those. The
#   drop is 2 instead of 1 only on five or six. The toll does not change
#   what a stamp scores.
#   Exemption on the middle row keeps the drop at 1, even on five or six.
#   An Exemption off the middle row does not.
#   Hold is applied before the span toll.
# - Brea Voss, lane column 1, exemption row top, Near Fill:
#   "A stamp scores twice only when the queue cell three places before it is
#   filled."
#   The queue is read from the top row downward, left to right inside a
#   row, the same order Jude Voss uses. Three places before a stamp is the
#   cell directly above it. The top-left cell has no cell three places
#   before it, so it scores its own number. The top-middle cell has no cell
#   three places before it, so it scores its own number. The top-right cell
#   has no cell three places before it, so it scores its own number. The
#   cells one and two places before a stamp do not matter. An empty cell
#   three back means the stamp scores its own number, even when the nearer
#   cells are filled. A filled cell three back means the stamp scores twice,
#   even when a nearer cell is empty. Jude Voss doubles when the cell three
#   back is empty. Faye Okell doubles when the cell four back is filled.
#   Ned Keel doubles when the cell two back is filled. Brea does none of
#   those. A retrigger of a stamp whose cell three back is filled scores
#   twice again. A retrigger of a stamp whose cell three back is empty does
#   not.
#   Exemption on the top row cancels the doubling, so every stamp scores its
#   own number. An Exemption off the top row does not. An Exemption that
#   qualifies and sits off the top row scores twice.
#   The fill does not change patience.
# - Pia Brant, lane column 3, exemption row bottom, Twin Pay:
#   "Each stamp with at least two side neighbors scores +2 once."
#   Exactly one side neighbor scores its own number. A corner neighbor is
#   not a side. A lone stamp scores its own number. Two side neighbors still
#   add 2 once, not 2 for each. A third side neighbor still adds 2 once.
#   Tess Okell adds 2 for one side neighbor. Clem Brant adds 2 for a side
#   neighbor only when a corner neighbor is also filled. Opal Quill adds 3
#   for a side share. Pia does none of those. A retrigger adds 2 again only
#   when the stamp has two side neighbors apart from the stamp that
#   retriggers it. Echo, Reply, and Ripple sit on a side. If the echo is
#   the second side neighbor, that retrigger does not add 2.
#   Exemption on the bottom row cancels the bonus, so every stamp scores its
#   own number. An Exemption off the bottom row does not. An Exemption that
#   qualifies and sits off the bottom row still adds 2.
#   The pay does not change patience.
# - Calder Okell, lane column 2, exemption row top, Farther Gap:
#   "A stamp scores twice only when the queue cell five places before it is
#   empty."
#   The queue is the same order Ansel Okell uses. Five places before a stamp
#   can land on the previous row or the row before that. The top-left cell
#   has no cell five places before it, so it scores its own number. The
#   top-middle cell has no cell five places before it, so it scores its own
#   number. The top-right cell has no cell five places before it, so it
#   scores its own number. The middle-left cell has no cell five places
#   before it, so it scores its own number. The center cell has no cell five
#   places before it, so it scores its own number. The cells one through
#   four places before a stamp do not matter. A filled cell five back means
#   the stamp scores its own number, even when the nearer cells are empty.
#   An empty cell five back means the stamp scores twice, even when a nearer
#   cell is filled. Ansel Okell doubles when the cell five back is filled.
#   Tarn Voss doubles when the cell five ahead is empty. Jude Voss doubles
#   when the cell three back is empty. Calder does none of those. A
#   retrigger of a stamp whose cell five back is empty scores twice again.
#   A retrigger of a stamp whose cell five back is filled does not.
#   Exemption on the top row cancels the doubling, so every stamp scores its
#   own number. An Exemption off the top row does not. An Exemption that
#   qualifies and sits off the top row scores twice.
#   The gap does not change patience.
# The near-fill doubling, the twin pay, and the farther-gap doubling do not
# remove Hold or Exemption, and they do not cancel a retrigger.
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
const SHIFT_COLOPHON := 19
const SHIFT_ERRATA := 20
const SHIFT_FRONTISPIECE := 21
const SHIFT_FLYLEAF := 22
const SHIFT_ENDPAPER := 23
const SHIFT_HALFTITLE := 24
const SHIFT_TITLEPAGE := 25
const SHIFT_COPYRIGHT := 26
const SHIFT_DEDICATION := 27
const SHIFT_EPIGRAPH := 28
const SHIFT_PREFACE := 29
const SHIFT_FOREWORD := 30
const SHIFT_CONTENTS := 31
const SHIFT_INTRODUCTION := 32
const SHIFT_PROLOGUE := 33
const SHIFT_ACKNOWLEDGMENTS := 34
const SHIFT_GLOSSARY := 35
const SHIFT_APPENDIX := 36
const SHIFT_AFTERWORD := 37
const SHIFT_POSTSCRIPT := 38
const SHIFT_ADDENDA := 39
const SHIFT_ENVOI := 40
const SHIFT_CORRIGENDA := 41
const SHIFT_EPILOGUE := 42
const SHIFT_CODA := 43
const SHIFT_EXPLICIT := 44
const SHIFT_FINIS := 45
const SHIFT_ENVOY := 46
const SHIFT_FINALE := 47
const SHIFT_EPODE := 48
const SHIFT_RECESSIONAL := 50
const SHIFT_SEQUENCE := 69
const SHIFT_TRACT := 68
const SHIFT_GRADUAL := 67
const SHIFT_INTROIT := 66
const SHIFT_ANTIPHON := 65
const SHIFT_REQUIEM := 64
const SHIFT_DIRGE := 63
const SHIFT_OCTAVE := 62
const SHIFT_VIGIL := 61
const SHIFT_NONE := 60
const SHIFT_SEXT := 59
const SHIFT_TERCE := 58
const SHIFT_PRIME := 57
const SHIFT_LAUDS := 56
const SHIFT_MATINS := 55
const SHIFT_AUBADE := 54
const SHIFT_VESPERS := 53
const SHIFT_COMPLINE := 52
const SHIFT_NOCTURNE := 51
const SHIFT_VALEDICTION := 49

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


const COLOPHON_BELL := [
	{
		"id": "nia_soren",
		"name": "Nia Soren",
		"form_name": "Nine Toll",
		"rule_text": "Patience drops by 2 when exactly nine cells are filled.",
		"rule": "drop_if_exact_nine",
		"lane": 1,
		"exemption_row": 2,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "perris_wythe",
		"name": "Perris Wythe",
		"form_name": "Lone Row",
		"rule_text": "A stamp scores twice only when it is the only filled stamp in its row. If that row holds another stamp, every stamp in the row scores its own number.",
		"rule": "double_lone_row",
		"lane": 2,
		"exemption_row": 0,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "jory_marsh",
		"name": "Jory Marsh",
		"form_name": "Short Column",
		"rule_text": "A stamp scores twice only when its own column holds exactly two filled stamps. Both stamps in that column double. A column with one stamp scores that stamp's own number. A full column of three scores each stamp's own number.",
		"rule": "double_short_column",
		"lane": 0,
		"exemption_row": 1,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "maeve_okell",
		"name": "Maeve Okell",
		"form_name": "Corner Slip",
		"rule_text": "When a stamp shares a corner with an earlier stamp, the later stamp scores twice. The earlier stamp scores its own number. A side share does not double the later stamp. Two corners still score twice.",
		"rule": "double_corner_later",
		"lane": 1,
		"exemption_row": 0,
		"goal": 22,
		"patience": 5,
	},
]


const ERRATA_BELL := [
	{
		"id": "una_pell",
		"name": "Una Pell",
		"form_name": "Odd Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is odd.",
		"rule": "drop_if_odd_count",
		"lane": 0,
		"exemption_row": 0,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "orin_keel",
		"name": "Orin Keel",
		"form_name": "Next Blank",
		"rule_text": "A stamp scores twice only when the queue cell immediately after it is empty. A stamp whose next cell is filled scores its own number. The bottom-right cell has no cell after it, so it does not double.",
		"rule": "double_next_empty",
		"lane": 2,
		"exemption_row": 2,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "vesper_okell",
		"name": "Vesper Okell",
		"form_name": "Corner Mark",
		"rule_text": "A stamp scores twice only when it sits in a corner cell. The center and the edge-middle cells score their own number.",
		"rule": "double_corner_cell",
		"lane": 1,
		"exemption_row": 1,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "weske_brant",
		"name": "Weske Brant",
		"form_name": "Middle Pay",
		"rule_text": "Each stamp in the middle row scores +2 once. A stamp on the top row or the bottom row scores its own number.",
		"rule": "yield_middle_pay",
		"lane": 0,
		"exemption_row": 2,
		"goal": 22,
		"patience": 5,
	},
]


const FRONTISPIECE_BELL := [
	{
		"id": "soren_hale",
		"name": "Soren Hale",
		"form_name": "Even Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is even.",
		"rule": "drop_if_even_count",
		"lane": 2,
		"exemption_row": 1,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "brigg_marsh",
		"name": "Brigg Marsh",
		"form_name": "Prior Blank",
		"rule_text": "A stamp scores twice only when the queue cell immediately before it is empty. A stamp whose previous cell is filled scores its own number. The top-left cell has no cell before it, so it does not double.",
		"rule": "double_prior_empty",
		"lane": 1,
		"exemption_row": 0,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "tallow_keel",
		"name": "Tallow Keel",
		"form_name": "Edge Mark",
		"rule_text": "A stamp scores twice only when it sits in an edge-middle cell. The four corners and the center score their own number.",
		"rule": "double_edge_middle",
		"lane": 0,
		"exemption_row": 2,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "yarrow_fen",
		"name": "Yarrow Fen",
		"form_name": "Top Pay",
		"rule_text": "Each stamp in the top row scores +2 once. A stamp in the middle row or the bottom row scores its own number.",
		"rule": "yield_top_pay",
		"lane": 1,
		"exemption_row": 1,
		"goal": 22,
		"patience": 5,
	},
]


const FLYLEAF_BELL := [
	{
		"id": "hollin_voss",
		"name": "Hollin Voss",
		"form_name": "Prime Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is prime.",
		"rule": "drop_if_prime_count",
		"lane": 1,
		"exemption_row": 2,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "perrin_keel",
		"name": "Perrin Keel",
		"form_name": "Both Blank",
		"rule_text": "A stamp scores twice only when the queue cell immediately before it is empty and the queue cell immediately after it is empty. The top-left cell has no cell before it, so it does not double. The bottom-right cell has no cell after it, so it does not double.",
		"rule": "double_both_blank",
		"lane": 2,
		"exemption_row": 2,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "ewan_holt",
		"name": "Ewan Holt",
		"form_name": "Cross Mark",
		"rule_text": "A stamp scores twice only when it sits in the plus: the center, the top middle, the left middle, the right middle, or the bottom middle. The four corners score their own number.",
		"rule": "double_plus_cell",
		"lane": 1,
		"exemption_row": 1,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "maren_fen",
		"name": "Maren Fen",
		"form_name": "Bottom Pay",
		"rule_text": "Each stamp in the bottom row scores +2 once. A stamp in the top row or the middle row scores its own number.",
		"rule": "yield_bottom_pay",
		"lane": 0,
		"exemption_row": 0,
		"goal": 18,
		"patience": 5,
	},
]


const ENDPAPER_BELL := [
	{
		"id": "isla_voss",
		"name": "Isla Voss",
		"form_name": "Square Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is a perfect square.",
		"rule": "drop_if_square_count",
		"lane": 0,
		"exemption_row": 1,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "edric_keel",
		"name": "Edric Keel",
		"form_name": "End Blank",
		"rule_text": "A stamp scores twice only when every immediate queue neighbor it has is empty. A missing neighbor counts as empty. The top-left cell doubles when the next cell is empty. The bottom-right cell doubles when the previous cell is empty.",
		"rule": "double_end_blank",
		"lane": 1,
		"exemption_row": 0,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "petra_hale",
		"name": "Petra Hale",
		"form_name": "Frame Pay",
		"rule_text": "Each stamp in a corner cell scores +2 once. The four edge-middle cells and the center score their own number.",
		"rule": "yield_frame_pay",
		"lane": 2,
		"exemption_row": 2,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "colin_fen",
		"name": "Colin Fen",
		"form_name": "Lane Pay",
		"rule_text": "Each stamp in column 2 scores +2 once. A stamp in column 1 or column 3 scores its own number.",
		"rule": "yield_lane_pay",
		"lane": 0,
		"exemption_row": 0,
		"goal": 22,
		"patience": 5,
	},
]

const HALFTITLE_BELL := [
	{
		"id": "tamsin_keel",
		"name": "Tamsin Keel",
		"form_name": "Triad Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is a multiple of 3.",
		"rule": "drop_if_triad_count",
		"lane": 2,
		"exemption_row": 2,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "tobin_hart",
		"name": "Tobin Hart",
		"form_name": "Skip Blank",
		"rule_text": "A stamp scores twice only when the queue cell two places before it is empty. The top-left cell has no cell two places before it, so it does not double. The top-middle cell has no cell two places before it, so it does not double.",
		"rule": "double_skip_blank",
		"lane": 1,
		"exemption_row": 1,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "willa_brant",
		"name": "Willa Brant",
		"form_name": "Wing Pay",
		"rule_text": "Each stamp in the left-middle cell or the right-middle cell scores +2 once. The four corners, the center, the top middle, and the bottom middle score their own number.",
		"rule": "yield_wing_pay",
		"lane": 0,
		"exemption_row": 0,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "hess_fen",
		"name": "Hess Fen",
		"form_name": "Gutter Pay",
		"rule_text": "Each stamp in column 1 scores +2 once. A stamp in column 2 or column 3 scores its own number.",
		"rule": "yield_gutter_pay",
		"lane": 2,
		"exemption_row": 1,
		"goal": 22,
		"patience": 5,
	},
]

const TITLEPAGE_BELL := [
	{
		"id": "nessa_voss",
		"name": "Nessa Voss",
		"form_name": "High Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 7, 8, or 9.",
		"rule": "drop_if_high_count",
		"lane": 1,
		"exemption_row": 0,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "ned_keel",
		"name": "Ned Keel",
		"form_name": "Skip Fill",
		"rule_text": "A stamp scores twice only when the queue cell two places before it is filled. The top-left cell has no cell two places before it, so it does not double. The top-middle cell has no cell two places before it, so it does not double.",
		"rule": "double_skip_fill",
		"lane": 0,
		"exemption_row": 2,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "sela_fen",
		"name": "Sela Fen",
		"form_name": "Post Pay",
		"rule_text": "Each stamp in column 3 scores +2 once. A stamp in column 1 or column 2 scores its own number.",
		"rule": "yield_post_pay",
		"lane": 2,
		"exemption_row": 1,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "tess_okell",
		"name": "Tess Okell",
		"form_name": "Seam Pay",
		"rule_text": "Each stamp that shares a side with at least one other filled stamp scores +2 once. A corner touch does not count. A lone stamp scores its own number.",
		"rule": "yield_seam_pay",
		"lane": 1,
		"exemption_row": 0,
		"goal": 22,
		"patience": 5,
	},
]

const COPYRIGHT_BELL := [
	{
		"id": "merrick_hale",
		"name": "Merrick Hale",
		"form_name": "Low Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 0, 1, or 2.",
		"rule": "drop_if_low_count",
		"lane": 2,
		"exemption_row": 2,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "oren_voss",
		"name": "Oren Voss",
		"form_name": "Skip Gap",
		"rule_text": "A stamp scores twice only when the queue cell two places after it is empty. The bottom-middle cell has no cell two places after it, so it does not double. The bottom-right cell has no cell two places after it, so it does not double.",
		"rule": "double_skip_gap",
		"lane": 1,
		"exemption_row": 0,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "nim_brant",
		"name": "Nim Brant",
		"form_name": "Crown Pay",
		"rule_text": "Each stamp in the top-middle cell scores +2 once. Every other cell scores its own number.",
		"rule": "yield_crown_pay",
		"lane": 0,
		"exemption_row": 1,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "syl_okell",
		"name": "Syl Okell",
		"form_name": "Void Pay",
		"rule_text": "Each stamp that shares no side with another filled stamp scores +2 once. A corner touch does not count as a side. A lone stamp scores +2.",
		"rule": "yield_void_pay",
		"lane": 2,
		"exemption_row": 2,
		"goal": 22,
		"patience": 5,
	},
]


const DEDICATION_BELL := [
	{
		"id": "maud_hale",
		"name": "Maud Hale",
		"form_name": "Cube Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 1 or 8.",
		"rule": "drop_if_cube_count",
		"lane": 2,
		"exemption_row": 2,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "colm_voss",
		"name": "Colm Voss",
		"form_name": "Far Blank",
		"rule_text": "A stamp scores twice only when the queue cell three places after it is empty. The bottom-left cell has no cell three places after it, so it does not double. The bottom-middle cell has no cell three places after it, so it does not double. The bottom-right cell has no cell three places after it, so it does not double.",
		"rule": "double_far_blank",
		"lane": 1,
		"exemption_row": 0,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "sibley_brant",
		"name": "Sibley Brant",
		"form_name": "Heart Pay",
		"rule_text": "Each stamp in the center cell scores +2 once. Every other cell scores its own number.",
		"rule": "yield_heart_pay",
		"lane": 0,
		"exemption_row": 1,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "orrin_okell",
		"name": "Orrin Okell",
		"form_name": "Short Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 1 or 2.",
		"rule": "drop_if_short_count",
		"lane": 2,
		"exemption_row": 0,
		"goal": 22,
		"patience": 5,
	},
]


const EPIGRAPH_BELL := [
	{
		"id": "enid_hale",
		"name": "Enid Hale",
		"form_name": "Composite Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 4, 6, 8, or 9.",
		"rule": "drop_if_composite_count",
		"lane": 0,
		"exemption_row": 2,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "phel_voss",
		"name": "Phel Voss",
		"form_name": "Far Fill",
		"rule_text": "A stamp scores twice only when the queue cell three places after it is filled. The bottom-left cell has no cell three places after it, so it does not double. The bottom-middle cell has no cell three places after it, so it does not double. The bottom-right cell has no cell three places after it, so it does not double.",
		"rule": "double_far_fill",
		"lane": 2,
		"exemption_row": 0,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "lark_brant",
		"name": "Lark Brant",
		"form_name": "Open Pay",
		"rule_text": "Each stamp that shares no side and no corner with another filled stamp scores +2 once. A corner touch counts. A side touch counts. A lone stamp scores +2.",
		"rule": "yield_open_pay",
		"lane": 1,
		"exemption_row": 1,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "doss_okell",
		"name": "Doss Okell",
		"form_name": "Long Blank",
		"rule_text": "A stamp scores twice only when the queue cell four places after it is empty. The middle-right cell has no cell four places after it, so it does not double. The bottom-left cell has no cell four places after it, so it does not double. The bottom-middle cell has no cell four places after it, so it does not double. The bottom-right cell has no cell four places after it, so it does not double.",
		"rule": "double_long_blank",
		"lane": 0,
		"exemption_row": 2,
		"goal": 22,
		"patience": 5,
	},
]




const PREFACE_BELL := [
	{
		"id": "neve_hale",
		"name": "Neve Hale",
		"form_name": "Power Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 1, 2, 4, or 8.",
		"rule": "drop_if_power_count",
		"lane": 1,
		"exemption_row": 0,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "tarn_voss",
		"name": "Tarn Voss",
		"form_name": "Farther Blank",
		"rule_text": "A stamp scores twice only when the queue cell five places after it is empty. The center cell has no cell five places after it, so it does not double. The middle-right cell has no cell five places after it, so it does not double. The bottom-left cell has no cell five places after it, so it does not double. The bottom-middle cell has no cell five places after it, so it does not double. The bottom-right cell has no cell five places after it, so it does not double.",
		"rule": "double_farther_blank",
		"lane": 0,
		"exemption_row": 1,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "cade_brant",
		"name": "Cade Brant",
		"form_name": "Rim Pay",
		"rule_text": "Each stamp in an edge-middle cell scores +2 once. The four corners and the center score their own number.",
		"rule": "yield_rim_pay",
		"lane": 2,
		"exemption_row": 2,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "sile_okell",
		"name": "Sile Okell",
		"form_name": "Long Fill",
		"rule_text": "A stamp scores twice only when the queue cell four places after it is filled. The middle-right cell has no cell four places after it, so it does not double. The bottom-left cell has no cell four places after it, so it does not double. The bottom-middle cell has no cell four places after it, so it does not double. The bottom-right cell has no cell four places after it, so it does not double.",
		"rule": "double_long_fill",
		"lane": 1,
		"exemption_row": 0,
		"goal": 22,
		"patience": 5,
	},
]


const FOREWORD_BELL := [
	{
		"id": "shay_hale",
		"name": "Shay Hale",
		"form_name": "Mid Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 3, 4, 5, or 6.",
		"rule": "drop_if_mid_count",
		"lane": 2,
		"exemption_row": 2,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "glen_voss",
		"name": "Glen Voss",
		"form_name": "Farther Fill",
		"rule_text": "A stamp scores twice only when the queue cell five places after it is filled. The center cell has no cell five places after it, so it does not double. The middle-right cell has no cell five places after it, so it does not double. The bottom-left cell has no cell five places after it, so it does not double. The bottom-middle cell has no cell five places after it, so it does not double. The bottom-right cell has no cell five places after it, so it does not double.",
		"rule": "double_farther_fill",
		"lane": 1,
		"exemption_row": 0,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "dell_brant",
		"name": "Dell Brant",
		"form_name": "Mitre Pay",
		"rule_text": "Each stamp that has at least one corner neighbor and no side neighbor scores +2 once. A corner touch counts. A side touch does not qualify. A lone stamp scores its own number.",
		"rule": "yield_mitre_pay",
		"lane": 0,
		"exemption_row": 0,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "faye_okell",
		"name": "Faye Okell",
		"form_name": "Long Back",
		"rule_text": "A stamp scores twice only when the queue cell four places before it is filled. The top-left cell has no cell four places before it, so it does not double. The top-middle cell has no cell four places before it, so it does not double. The top-right cell has no cell four places before it, so it does not double. The middle-left cell has no cell four places before it, so it does not double.",
		"rule": "double_long_back",
		"lane": 2,
		"exemption_row": 1,
		"goal": 22,
		"patience": 5,
	},
]


const CONTENTS_BELL := [
	{
		"id": "ross_hale",
		"name": "Ross Hale",
		"form_name": "Outer Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 0 or 9.",
		"rule": "drop_if_outer_count",
		"lane": 0,
		"exemption_row": 0,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "jude_voss",
		"name": "Jude Voss",
		"form_name": "Near Blank",
		"rule_text": "A stamp scores twice only when the queue cell three places before it is empty. The top-left cell has no cell three places before it, so it does not double. The top-middle cell has no cell three places before it, so it does not double. The top-right cell has no cell three places before it, so it does not double.",
		"rule": "double_near_blank",
		"lane": 2,
		"exemption_row": 2,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "clem_brant",
		"name": "Clem Brant",
		"form_name": "Brace Pay",
		"rule_text": "Each stamp that has at least one side neighbor and at least one corner neighbor scores +2 once. A side neighbor with no corner neighbor scores its own number. A corner neighbor with no side neighbor scores its own number. A lone stamp scores its own number.",
		"rule": "yield_brace_pay",
		"lane": 1,
		"exemption_row": 1,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "ansel_okell",
		"name": "Ansel Okell",
		"form_name": "Farther Back",
		"rule_text": "A stamp scores twice only when the queue cell five places before it is filled. The top-left cell has no cell five places before it, so it does not double. The top-middle cell has no cell five places before it, so it does not double. The top-right cell has no cell five places before it, so it does not double. The middle-left cell has no cell five places before it, so it does not double. The center cell has no cell five places before it, so it does not double.",
		"rule": "double_farther_back",
		"lane": 0,
		"exemption_row": 2,
		"goal": 22,
		"patience": 5,
	},
]


const INTRODUCTION_BELL := [
	{
		"id": "quin_hale",
		"name": "Quin Hale",
		"form_name": "Span Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 5 or 6.",
		"rule": "drop_if_span_count",
		"lane": 1,
		"exemption_row": 1,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "brea_voss",
		"name": "Brea Voss",
		"form_name": "Near Fill",
		"rule_text": "A stamp scores twice only when the queue cell three places before it is filled. The top-left cell has no cell three places before it, so it does not double. The top-middle cell has no cell three places before it, so it does not double. The top-right cell has no cell three places before it, so it does not double.",
		"rule": "double_near_fill",
		"lane": 0,
		"exemption_row": 0,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "pia_brant",
		"name": "Pia Brant",
		"form_name": "Twin Pay",
		"rule_text": "Each stamp with at least two side neighbors scores +2 once. Exactly one side neighbor scores its own number. A corner neighbor is not a side. A lone stamp scores its own number.",
		"rule": "yield_twin_pay",
		"lane": 2,
		"exemption_row": 2,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "calder_okell",
		"name": "Calder Okell",
		"form_name": "Farther Gap",
		"rule_text": "A stamp scores twice only when the queue cell five places before it is empty. The top-left cell has no cell five places before it, so it does not double. The top-middle cell has no cell five places before it, so it does not double. The top-right cell has no cell five places before it, so it does not double. The middle-left cell has no cell five places before it, so it does not double. The center cell has no cell five places before it, so it does not double.",
		"rule": "double_farther_gap",
		"lane": 1,
		"exemption_row": 0,
		"goal": 22,
		"patience": 5,
	},
]

const PROLOGUE_BELL := [
	{
		"id": "nola_hale",
		"name": "Nola Hale",
		"form_name": "Band Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 4 or 5.",
		"rule": "drop_if_band_count",
		"lane": 2,
		"exemption_row": 0,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "keir_voss",
		"name": "Keir Voss",
		"form_name": "Step Fill",
		"rule_text": "A stamp scores twice only when the queue cell two places after it is filled. The bottom-middle cell has no cell two places after it, so it does not double. The bottom-right cell has no cell two places after it, so it does not double.",
		"rule": "double_step_fill",
		"lane": 0,
		"exemption_row": 2,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "posy_brant",
		"name": "Posy Brant",
		"form_name": "Trio Pay",
		"rule_text": "Each stamp with exactly three side neighbors scores +2 once. Two side neighbors score their own number. Exactly one side neighbor scores its own number. Four side neighbors score their own number. A corner neighbor is not a side. A lone stamp scores its own number.",
		"rule": "yield_trio_pay",
		"lane": 1,
		"exemption_row": 1,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "osric_okell",
		"name": "Osric Okell",
		"form_name": "Long Gap",
		"rule_text": "A stamp scores twice only when the queue cell four places before it is empty. The top-left cell has no cell four places before it, so it does not double. The top-middle cell has no cell four places before it, so it does not double. The top-right cell has no cell four places before it, so it does not double. The middle-left cell has no cell four places before it, so it does not double.",
		"rule": "double_long_gap",
		"lane": 2,
		"exemption_row": 2,
		"goal": 22,
		"patience": 5,
	},
]


const ACKNOWLEDGMENTS_BELL := [
	{
		"id": "maris_hale",
		"name": "Maris Hale",
		"form_name": "Crest Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 6 or 7.",
		"rule": "drop_if_crest_count",
		"lane": 0,
		"exemption_row": 1,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "tavin_voss",
		"name": "Tavin Voss",
		"form_name": "Leap Fill",
		"rule_text": "A stamp scores twice only when the queue cell six places after it is filled. The middle-left cell has no cell six places after it, so it does not double. The center cell has no cell six places after it, so it does not double. The middle-right cell has no cell six places after it, so it does not double. The bottom-left cell has no cell six places after it, so it does not double. The bottom-middle cell has no cell six places after it, so it does not double. The bottom-right cell has no cell six places after it, so it does not double.",
		"rule": "double_leap_fill",
		"lane": 1,
		"exemption_row": 0,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "edith_brant",
		"name": "Edith Brant",
		"form_name": "Quad Pay",
		"rule_text": "Each stamp with exactly four side neighbors scores +2 once. Exactly three side neighbors score their own number. Two side neighbors score their own number. Exactly one side neighbor scores its own number. A corner neighbor is not a side. A lone stamp scores its own number.",
		"rule": "yield_quad_pay",
		"lane": 2,
		"exemption_row": 2,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "lorin_okell",
		"name": "Lorin Okell",
		"form_name": "Deep Gap",
		"rule_text": "A stamp scores twice only when the queue cell six places before it is empty. The top-left cell has no cell six places before it, so it does not double. The top-middle cell has no cell six places before it, so it does not double. The top-right cell has no cell six places before it, so it does not double. The middle-left cell has no cell six places before it, so it does not double. The center cell has no cell six places before it, so it does not double. The middle-right cell has no cell six places before it, so it does not double.",
		"rule": "double_deep_gap",
		"lane": 0,
		"exemption_row": 2,
		"goal": 22,
		"patience": 5,
	},
]


const GLOSSARY_BELL := [
	{
		"id": "sybil_hale",
		"name": "Sybil Hale",
		"form_name": "Peak Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 8 or 9.",
		"rule": "drop_if_peak_count",
		"lane": 1,
		"exemption_row": 2,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "leif_voss",
		"name": "Leif Voss",
		"form_name": "Pitch Fill",
		"rule_text": "A stamp scores twice only when the queue cell seven places after it is filled. The top-right cell has no cell seven places after it, so it does not double. The middle-left cell has no cell seven places after it, so it does not double. The center cell has no cell seven places after it, so it does not double. The middle-right cell has no cell seven places after it, so it does not double. The bottom-left cell has no cell seven places after it, so it does not double. The bottom-middle cell has no cell seven places after it, so it does not double. The bottom-right cell has no cell seven places after it, so it does not double.",
		"rule": "double_pitch_fill",
		"lane": 2,
		"exemption_row": 1,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "auden_brant",
		"name": "Auden Brant",
		"form_name": "Single Pay",
		"rule_text": "Each stamp with exactly one side neighbor scores +2 once. Two side neighbors score their own number. Exactly three side neighbors score their own number. Four side neighbors score their own number. A corner neighbor is not a side. A lone stamp scores its own number.",
		"rule": "yield_single_pay",
		"lane": 0,
		"exemption_row": 0,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "torin_okell",
		"name": "Torin Okell",
		"form_name": "Pitch Gap",
		"rule_text": "A stamp scores twice only when the queue cell seven places before it is empty. The top-left cell has no cell seven places before it, so it does not double. The top-middle cell has no cell seven places before it, so it does not double. The top-right cell has no cell seven places before it, so it does not double. The middle-left cell has no cell seven places before it, so it does not double. The center cell has no cell seven places before it, so it does not double. The middle-right cell has no cell seven places before it, so it does not double. The bottom-left cell has no cell seven places before it, so it does not double.",
		"rule": "double_pitch_gap",
		"lane": 2,
		"exemption_row": 0,
		"goal": 22,
		"patience": 5,
	},
]


const APPENDIX_BELL := [
	{
		"id": "briony_hale",
		"name": "Briony Hale",
		"form_name": "Sill Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 0 or 1.",
		"rule": "drop_if_sill_count",
		"lane": 2,
		"exemption_row": 0,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "nils_voss",
		"name": "Nils Voss",
		"form_name": "Reach Fill",
		"rule_text": "A stamp scores twice only when the queue cell eight places after it is filled. The top-middle cell has no cell eight places after it, so it does not double. The top-right cell has no cell eight places after it, so it does not double. The middle-left cell has no cell eight places after it, so it does not double. The center cell has no cell eight places after it, so it does not double. The middle-right cell has no cell eight places after it, so it does not double. The bottom-left cell has no cell eight places after it, so it does not double. The bottom-middle cell has no cell eight places after it, so it does not double. The bottom-right cell has no cell eight places after it, so it does not double.",
		"rule": "double_reach_fill",
		"lane": 0,
		"exemption_row": 2,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "thea_brant",
		"name": "Thea Brant",
		"form_name": "Pair Pay",
		"rule_text": "Each stamp with exactly two side neighbors scores +2 once. Exactly one side neighbor scores its own number. Exactly three side neighbors score their own number. Four side neighbors score their own number. A corner neighbor is not a side. A lone stamp scores its own number.",
		"rule": "yield_pair_pay",
		"lane": 1,
		"exemption_row": 1,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "hadrian_okell",
		"name": "Hadrian Okell",
		"form_name": "Reach Gap",
		"rule_text": "A stamp scores twice only when the queue cell eight places before it is empty. The top-left cell has no cell eight places before it, so it does not double. The top-middle cell has no cell eight places before it, so it does not double. The top-right cell has no cell eight places before it, so it does not double. The middle-left cell has no cell eight places before it, so it does not double. The center cell has no cell eight places before it, so it does not double. The middle-right cell has no cell eight places before it, so it does not double. The bottom-left cell has no cell eight places before it, so it does not double. The bottom-middle cell has no cell eight places before it, so it does not double.",
		"rule": "double_reach_gap",
		"lane": 0,
		"exemption_row": 1,
		"goal": 22,
		"patience": 5,
	},
]


const AFTERWORD_BELL := [
	{
		"id": "catrin_hale",
		"name": "Catrin Hale",
		"form_name": "Ridge Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 2 or 3.",
		"rule": "drop_if_ridge_count",
		"lane": 0,
		"exemption_row": 1,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "jonas_voss",
		"name": "Jonas Voss",
		"form_name": "Leap Blank",
		"rule_text": "A stamp scores twice only when the queue cell six places after it is empty. The middle-left cell has no cell six places after it, so it does not double. The center cell has no cell six places after it, so it does not double. The middle-right cell has no cell six places after it, so it does not double. The bottom-left cell has no cell six places after it, so it does not double. The bottom-middle cell has no cell six places after it, so it does not double. The bottom-right cell has no cell six places after it, so it does not double.",
		"rule": "double_leap_blank",
		"lane": 1,
		"exemption_row": 0,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "greta_brant",
		"name": "Greta Brant",
		"form_name": "Slant Pay",
		"rule_text": "Each stamp with exactly one corner neighbor scores +2 once. Two corner neighbors score their own number. Exactly three corner neighbors score their own number. Four corner neighbors score their own number. A side neighbor is not a corner. A lone stamp scores its own number.",
		"rule": "yield_slant_pay",
		"lane": 2,
		"exemption_row": 2,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "lyle_okell",
		"name": "Lyle Okell",
		"form_name": "Deep Back",
		"rule_text": "A stamp scores twice only when the queue cell six places before it is filled. The top-left cell has no cell six places before it, so it does not double. The top-middle cell has no cell six places before it, so it does not double. The top-right cell has no cell six places before it, so it does not double. The middle-left cell has no cell six places before it, so it does not double. The center cell has no cell six places before it, so it does not double. The middle-right cell has no cell six places before it, so it does not double.",
		"rule": "double_deep_back",
		"lane": 1,
		"exemption_row": 2,
		"goal": 22,
		"patience": 5,
	},
]


const POSTSCRIPT_BELL := [
	{
		"id": "isolde_hale",
		"name": "Isolde Hale",
		"form_name": "Ledge Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 3 or 4.",
		"rule": "drop_if_ledge_count",
		"lane": 1,
		"exemption_row": 2,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "miles_voss",
		"name": "Miles Voss",
		"form_name": "Pitch Blank",
		"rule_text": "A stamp scores twice only when the queue cell seven places after it is empty. The top-right cell has no cell seven places after it, so it does not double. The middle-left cell has no cell seven places after it, so it does not double. The center cell has no cell seven places after it, so it does not double. The middle-right cell has no cell seven places after it, so it does not double. The bottom-left cell has no cell seven places after it, so it does not double. The bottom-middle cell has no cell seven places after it, so it does not double. The bottom-right cell has no cell seven places after it, so it does not double.",
		"rule": "double_pitch_blank",
		"lane": 2,
		"exemption_row": 1,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "tilda_brant",
		"name": "Tilda Brant",
		"form_name": "Wedge Pay",
		"rule_text": "Each stamp with exactly two corner neighbors scores +2 once. Exactly one corner neighbor scores its own number. Exactly three corner neighbors score their own number. Four corner neighbors score their own number. A side neighbor is not a corner. A lone stamp scores its own number.",
		"rule": "yield_wedge_pay",
		"lane": 0,
		"exemption_row": 0,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "ulric_okell",
		"name": "Ulric Okell",
		"form_name": "Pitch Back",
		"rule_text": "A stamp scores twice only when the queue cell seven places before it is filled. The top-left cell has no cell seven places before it, so it does not double. The top-middle cell has no cell seven places before it, so it does not double. The top-right cell has no cell seven places before it, so it does not double. The middle-left cell has no cell seven places before it, so it does not double. The center cell has no cell seven places before it, so it does not double. The middle-right cell has no cell seven places before it, so it does not double. The bottom-left cell has no cell seven places before it, so it does not double.",
		"rule": "double_pitch_back",
		"lane": 2,
		"exemption_row": 0,
		"goal": 22,
		"patience": 5,
	},
]


const ADDENDA_BELL := [
	{
		"id": "freya_hale",
		"name": "Freya Hale",
		"form_name": "Brow Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 7 or 8.",
		"rule": "drop_if_brow_count",
		"lane": 2,
		"exemption_row": 0,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "hugo_voss",
		"name": "Hugo Voss",
		"form_name": "Reach Blank",
		"rule_text": "A stamp scores twice only when the queue cell eight places after it is empty. The top-middle cell has no cell eight places after it, so it does not double. The top-right cell has no cell eight places after it, so it does not double. The middle-left cell has no cell eight places after it, so it does not double. The center cell has no cell eight places after it, so it does not double. The middle-right cell has no cell eight places after it, so it does not double. The bottom-left cell has no cell eight places after it, so it does not double. The bottom-middle cell has no cell eight places after it, so it does not double. The bottom-right cell has no cell eight places after it, so it does not double.",
		"rule": "double_reach_blank",
		"lane": 0,
		"exemption_row": 2,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "marta_brant",
		"name": "Marta Brant",
		"form_name": "Apex Pay",
		"rule_text": "Each stamp with exactly three corner neighbors scores +2 once. Exactly one corner neighbor scores its own number. Exactly two corner neighbors score their own number. Four corner neighbors score their own number. A side neighbor is not a corner. A lone stamp scores its own number.",
		"rule": "yield_apex_pay",
		"lane": 1,
		"exemption_row": 1,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "klaus_okell",
		"name": "Klaus Okell",
		"form_name": "Reach Back",
		"rule_text": "A stamp scores twice only when the queue cell eight places before it is filled. The top-left cell has no cell eight places before it, so it does not double. The top-middle cell has no cell eight places before it, so it does not double. The top-right cell has no cell eight places before it, so it does not double. The middle-left cell has no cell eight places before it, so it does not double. The center cell has no cell eight places before it, so it does not double. The middle-right cell has no cell eight places before it, so it does not double. The bottom-left cell has no cell eight places before it, so it does not double. The bottom-middle cell has no cell eight places before it, so it does not double.",
		"rule": "double_reach_back",
		"lane": 0,
		"exemption_row": 1,
		"goal": 22,
		"patience": 5,
	},
]


const ENVOI_BELL := [
	{
		"id": "elspeth_hale",
		"name": "Elspeth Hale",
		"form_name": "Cleft Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 0 or 2.",
		"rule": "drop_if_cleft_count",
		"lane": 0,
		"exemption_row": 1,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "owen_voss",
		"name": "Owen Voss",
		"form_name": "Pace Blank",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is empty. The bottom-right cell has no cell one place after it, so it does not double.",
		"rule": "double_pace_blank",
		"lane": 1,
		"exemption_row": 0,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "ingrid_brant",
		"name": "Ingrid Brant",
		"form_name": "Vault Pay",
		"rule_text": "Each stamp with exactly four corner neighbors scores +2 once. Exactly one corner neighbor scores its own number. Exactly two corner neighbors score their own number. Exactly three corner neighbors score their own number. A side neighbor is not a corner. A lone stamp scores its own number.",
		"rule": "yield_vault_pay",
		"lane": 2,
		"exemption_row": 2,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "lars_okell",
		"name": "Lars Okell",
		"form_name": "Pace Back",
		"rule_text": "A stamp scores twice only when the queue cell one place before it is filled. The top-left cell has no cell one place before it, so it does not double.",
		"rule": "double_pace_back",
		"lane": 1,
		"exemption_row": 2,
		"goal": 22,
		"patience": 5,
	},
]


const CORRIGENDA_BELL := [
	{
		"id": "vera_hale",
		"name": "Vera Hale",
		"form_name": "Notch Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 1 or 3.",
		"rule": "drop_if_notch_count",
		"lane": 1,
		"exemption_row": 2,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "felix_voss",
		"name": "Felix Voss",
		"form_name": "Pace Fill",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is filled. The bottom-right cell has no cell one place after it, so it does not double.",
		"rule": "double_pace_fill",
		"lane": 2,
		"exemption_row": 1,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "rhea_brant",
		"name": "Rhea Brant",
		"form_name": "Bare Pay",
		"rule_text": "Each stamp with exactly zero corner neighbors scores +2 once. Exactly one corner neighbor scores its own number. Exactly two corner neighbors score their own number. Exactly three corner neighbors score their own number. Exactly four corner neighbors score their own number. A side neighbor is not a corner. A stamp with only side neighbors scores +2. A lone stamp scores +2 once.",
		"rule": "yield_bare_pay",
		"lane": 0,
		"exemption_row": 0,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "jasper_okell",
		"name": "Jasper Okell",
		"form_name": "Pace Gap",
		"rule_text": "A stamp scores twice only when the queue cell one place before it is empty. The top-left cell has no cell one place before it, so it does not double.",
		"rule": "double_pace_gap",
		"lane": 2,
		"exemption_row": 0,
		"goal": 22,
		"patience": 5,
	},
]


const EPILOGUE_BELL := [
	{
		"id": "sigrid_hale",
		"name": "Sigrid Hale",
		"form_name": "Rift Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 2 or 4.",
		"rule": "drop_if_rift_count",
		"lane": 2,
		"exemption_row": 0,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "oscar_voss",
		"name": "Oscar Voss",
		"form_name": "Twin Blank",
		"rule_text": "A stamp scores twice only when the queue cell one place after it and the queue cell one place before it are empty. The top-left cell has no cell one place before it, so it does not double. The bottom-right cell has no cell one place after it, so it does not double.",
		"rule": "double_twin_blank",
		"lane": 0,
		"exemption_row": 2,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "yara_brant",
		"name": "Yara Brant",
		"form_name": "Flank Pay",
		"rule_text": "Each stamp with exactly one side neighbor scores +2 once. Exactly zero side neighbors score their own number. Exactly two side neighbors score their own number. Exactly three side neighbors score their own number. Exactly four side neighbors score their own number. A corner neighbor is not a side. A lone stamp scores its own number.",
		"rule": "yield_flank_pay",
		"lane": 1,
		"exemption_row": 1,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "ines_okell",
		"name": "Ines Okell",
		"form_name": "Twin Fill",
		"rule_text": "A stamp scores twice only when the queue cell one place after it and the queue cell one place before it are filled. The top-left cell has no cell one place before it, so it does not double. The bottom-right cell has no cell one place after it, so it does not double.",
		"rule": "double_twin_fill",
		"lane": 0,
		"exemption_row": 1,
		"goal": 22,
		"patience": 5,
	},
]


const CODA_BELL := [
	{
		"id": "kira_hale",
		"name": "Kira Hale",
		"form_name": "Split Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 3 or 5.",
		"rule": "drop_if_split_count",
		"lane": 0,
		"exemption_row": 1,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "simon_voss",
		"name": "Simon Voss",
		"form_name": "Skew Blank",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is empty and the queue cell one place before it is filled. The top-left cell has no cell one place before it, so it does not double. The bottom-right cell has no cell one place after it, so it does not double.",
		"rule": "double_skew_blank",
		"lane": 1,
		"exemption_row": 0,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "linnea_brant",
		"name": "Linnea Brant",
		"form_name": "Hinge Pay",
		"rule_text": "Each stamp with exactly one side neighbor and exactly one corner neighbor scores +2 once. Any other count scores its own number. Exactly zero side neighbors score their own number. A lone stamp scores its own number.",
		"rule": "yield_hinge_pay",
		"lane": 2,
		"exemption_row": 2,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "anwen_okell",
		"name": "Anwen Okell",
		"form_name": "Skew Fill",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is filled and the queue cell one place before it is empty. The top-left cell has no cell one place before it, so it does not double. The bottom-right cell has no cell one place after it, so it does not double.",
		"rule": "double_skew_fill",
		"lane": 1,
		"exemption_row": 2,
		"goal": 22,
		"patience": 5,
	},
]


const EXPLICIT_BELL := [
	{
		"id": "edgar_hale",
		"name": "Edgar Hale",
		"form_name": "Stride Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 4 or 6.",
		"rule": "drop_if_stride_count",
		"lane": 1,
		"exemption_row": 2,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "helen_voss",
		"name": "Helen Voss",
		"form_name": "Stride Blank",
		"rule_text": "A stamp scores twice only when the queue cell two places after it is empty and the queue cell two places before it is filled. The top-left cell has no cell two places before it, so it does not double. The top-middle cell has no cell two places before it, so it does not double. The bottom-middle cell has no cell two places after it, so it does not double. The bottom-right cell has no cell two places after it, so it does not double.",
		"rule": "double_stride_blank",
		"lane": 2,
		"exemption_row": 1,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "mira_brant",
		"name": "Mira Brant",
		"form_name": "Bevel Pay",
		"rule_text": "Each stamp with exactly two corner neighbors and exactly one side neighbor scores +2 once. Any other count scores its own number. Exactly one side neighbor with a different corner count scores its own number. Exactly one corner neighbor with a different side count scores its own number. A lone stamp scores its own number.",
		"rule": "yield_bevel_pay",
		"lane": 0,
		"exemption_row": 0,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "celia_okell",
		"name": "Celia Okell",
		"form_name": "Stride Fill",
		"rule_text": "A stamp scores twice only when the queue cell two places after it is filled and the queue cell two places before it is empty. The top-left cell has no cell two places before it, so it does not double. The top-middle cell has no cell two places before it, so it does not double. The bottom-middle cell has no cell two places after it, so it does not double. The bottom-right cell has no cell two places after it, so it does not double.",
		"rule": "double_stride_fill",
		"lane": 2,
		"exemption_row": 0,
		"goal": 22,
		"patience": 5,
	},
]


const FINIS_BELL := [
	{
		"id": "ruth_hale",
		"name": "Ruth Hale",
		"form_name": "Helm Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 5 or 7.",
		"rule": "drop_if_helm_count",
		"lane": 2,
		"exemption_row": 0,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "tomas_voss",
		"name": "Tomas Voss",
		"form_name": "Helm Blank",
		"rule_text": "A stamp scores twice only when the queue cell three places after it is empty and the queue cell three places before it is filled. The top-left cell has no cell three places before it, so it does not double. The top-middle cell has no cell three places before it, so it does not double. The top-right cell has no cell three places before it, so it does not double. The bottom-left cell has no cell three places after it, so it does not double. The bottom-middle cell has no cell three places after it, so it does not double. The bottom-right cell has no cell three places after it, so it does not double.",
		"rule": "double_helm_blank",
		"lane": 0,
		"exemption_row": 2,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "piers_brant",
		"name": "Piers Brant",
		"form_name": "Chevron Pay",
		"rule_text": "Each stamp with exactly two corner neighbors and exactly zero side neighbors scores +2 once. Any other count scores its own number. Exactly two corner neighbors with one or more side neighbors score their own number. A lone stamp scores its own number.",
		"rule": "yield_chevron_pay",
		"lane": 1,
		"exemption_row": 1,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "nesta_okell",
		"name": "Nesta Okell",
		"form_name": "Helm Fill",
		"rule_text": "A stamp scores twice only when the queue cell three places after it is filled and the queue cell three places before it is empty. The top-left cell has no cell three places before it, so it does not double. The top-middle cell has no cell three places before it, so it does not double. The top-right cell has no cell three places before it, so it does not double. The bottom-left cell has no cell three places after it, so it does not double. The bottom-middle cell has no cell three places after it, so it does not double. The bottom-right cell has no cell three places after it, so it does not double.",
		"rule": "double_helm_fill",
		"lane": 0,
		"exemption_row": 1,
		"goal": 22,
		"patience": 5,
	},
]


const ENVOY_BELL := [
	{
		"id": "agnes_hale",
		"name": "Agnes Hale",
		"form_name": "Gauge Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 6 or 8.",
		"rule": "drop_if_gauge_count",
		"lane": 0,
		"exemption_row": 1,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "ellis_voss",
		"name": "Ellis Voss",
		"form_name": "Bias Blank",
		"rule_text": "A stamp scores twice only when the queue cell four places after it is empty and the queue cell four places before it is filled. The top-left cell has no cell four places before it, so it does not double. The top-middle cell has no cell four places before it, so it does not double. The top-right cell has no cell four places before it, so it does not double. The middle-left cell has no cell four places before it, so it does not double. The middle-right cell has no cell four places after it, so it does not double. The bottom-left cell has no cell four places after it, so it does not double. The bottom-middle cell has no cell four places after it, so it does not double. The bottom-right cell has no cell four places after it, so it does not double.",
		"rule": "double_bias_blank",
		"lane": 1,
		"exemption_row": 0,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "nora_brant",
		"name": "Nora Brant",
		"form_name": "Trine Pay",
		"rule_text": "Each stamp with exactly three corner neighbors and exactly zero side neighbors scores +2 once. Any other count scores its own number. Exactly two corner neighbors with zero side neighbors score their own number. A lone stamp scores its own number.",
		"rule": "yield_trine_pay",
		"lane": 2,
		"exemption_row": 2,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "lydia_okell",
		"name": "Lydia Okell",
		"form_name": "Bias Fill",
		"rule_text": "A stamp scores twice only when the queue cell four places after it is filled and the queue cell four places before it is empty. The top-left cell has no cell four places before it, so it does not double. The top-middle cell has no cell four places before it, so it does not double. The top-right cell has no cell four places before it, so it does not double. The middle-left cell has no cell four places before it, so it does not double. The middle-right cell has no cell four places after it, so it does not double. The bottom-left cell has no cell four places after it, so it does not double. The bottom-middle cell has no cell four places after it, so it does not double. The bottom-right cell has no cell four places after it, so it does not double.",
		"rule": "double_bias_fill",
		"lane": 1,
		"exemption_row": 2,
		"goal": 22,
		"patience": 5,
	},
]


const FINALE_BELL := [
	{
		"id": "cedric_hale",
		"name": "Cedric Hale",
		"form_name": "Latch Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 7 or 9.",
		"rule": "drop_if_latch_count",
		"lane": 1,
		"exemption_row": 2,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "rhys_voss",
		"name": "Rhys Voss",
		"form_name": "Full Fill",
		"rule_text": "A stamp scores twice only when the queue cell four places after it is filled and the queue cell four places before it is filled. The top-left cell has no cell four places before it, so it does not double. The top-middle cell has no cell four places before it, so it does not double. The top-right cell has no cell four places before it, so it does not double. The middle-left cell has no cell four places before it, so it does not double. The middle-right cell has no cell four places after it, so it does not double. The bottom-left cell has no cell four places after it, so it does not double. The bottom-middle cell has no cell four places after it, so it does not double. The bottom-right cell has no cell four places after it, so it does not double.",
		"rule": "double_full_fill",
		"lane": 2,
		"exemption_row": 1,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "lorna_brant",
		"name": "Lorna Brant",
		"form_name": "Clasp Pay",
		"rule_text": "Each stamp with exactly three corner neighbors and exactly one side neighbor scores +2 once. Any other count scores its own number. Exactly three corner neighbors with exactly zero side neighbors score their own number. A lone stamp scores its own number.",
		"rule": "yield_clasp_pay",
		"lane": 0,
		"exemption_row": 1,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "basil_okell",
		"name": "Basil Okell",
		"form_name": "Full Blank",
		"rule_text": "A stamp scores twice only when the queue cell four places after it is empty and the queue cell four places before it is empty. The top-left cell has no cell four places before it, so it does not double. The top-middle cell has no cell four places before it, so it does not double. The top-right cell has no cell four places before it, so it does not double. The middle-left cell has no cell four places before it, so it does not double. The middle-right cell has no cell four places after it, so it does not double. The bottom-left cell has no cell four places after it, so it does not double. The bottom-middle cell has no cell four places after it, so it does not double. The bottom-right cell has no cell four places after it, so it does not double.",
		"rule": "double_full_blank",
		"lane": 2,
		"exemption_row": 0,
		"goal": 22,
		"patience": 5,
	},
]










const SEQUENCE_BELL := [
	{
		"id": "odin_brevik",
		"name": "Odin Brevik",
		"form_name": "Burin Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 27 or 30.",
		"rule": "drop_if_burin_count",
		"lane": 2,
		"exemption_row": 0,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "mia_fosse",
		"name": "Mia Fosse",
		"form_name": "Arris Fill",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is filled and the queue cell twenty-one places before it is filled. Every cell on the form has no cell twenty-one places before it, so none of them double.",
		"rule": "double_arris_fill",
		"lane": 0,
		"exemption_row": 2,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "kasper_berge",
		"name": "Kasper Berge",
		"form_name": "Rove Pay",
		"rule_text": "Each stamp with exactly four corner neighbors and exactly nineteen side neighbors scores +2 once. Any other count scores its own number. Exactly four corner neighbors with four, five, six, seven, eight, nine, ten, eleven, twelve, thirteen, fourteen, fifteen, sixteen, seventeen, or eighteen side neighbors score their own number. A lone stamp scores its own number.",
		"rule": "yield_rove_pay",
		"lane": 1,
		"exemption_row": 0,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "inger_halvorsen",
		"name": "Inger Halvorsen",
		"form_name": "Arris Blank",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is empty and the queue cell twenty-one places before it is empty. Every cell on the form has no cell twenty-one places before it, so none of them double.",
		"rule": "double_arris_blank",
		"lane": 0,
		"exemption_row": 1,
		"goal": 22,
		"patience": 5,
	},
]

const TRACT_BELL := [
	{
		"id": "trygve_viken",
		"name": "Trygve Viken",
		"form_name": "Graver Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 26 or 29.",
		"rule": "drop_if_graver_count",
		"lane": 1,
		"exemption_row": 2,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "sofie_haug",
		"name": "Sofie Haug",
		"form_name": "Feather Fill",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is filled and the queue cell twenty places before it is filled. Every cell on the form has no cell twenty places before it, so none of them double.",
		"rule": "double_feather_fill",
		"lane": 2,
		"exemption_row": 1,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "emma_skei",
		"name": "Emma Skei",
		"form_name": "Staple Pay",
		"rule_text": "Each stamp with exactly four corner neighbors and exactly eighteen side neighbors scores +2 once. Any other count scores its own number. Exactly four corner neighbors with four, five, six, seven, eight, nine, ten, eleven, twelve, thirteen, fourteen, fifteen, sixteen, or seventeen side neighbors score their own number. A lone stamp scores its own number.",
		"rule": "yield_staple_pay",
		"lane": 0,
		"exemption_row": 2,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "joakim_strom",
		"name": "Joakim Strom",
		"form_name": "Feather Blank",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is empty and the queue cell twenty places before it is empty. Every cell on the form has no cell twenty places before it, so none of them double.",
		"rule": "double_feather_blank",
		"lane": 2,
		"exemption_row": 0,
		"goal": 22,
		"patience": 5,
	},
]

const GRADUAL_BELL := [
	{
		"id": "kjetil_fjeld",
		"name": "Kjetil Fjeld",
		"form_name": "Scribe Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 25 or 28.",
		"rule": "drop_if_scribe_count",
		"lane": 0,
		"exemption_row": 1,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "ingeborg_dal",
		"name": "Ingeborg Dal",
		"form_name": "Plow Fill",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is filled and the queue cell nineteen places before it is filled. Every cell on the form has no cell nineteen places before it, so none of them double.",
		"rule": "double_plow_fill",
		"lane": 1,
		"exemption_row": 0,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "simen_roe",
		"name": "Simen Roe",
		"form_name": "Lag Pay",
		"rule_text": "Each stamp with exactly four corner neighbors and exactly seventeen side neighbors scores +2 once. Any other count scores its own number. Exactly four corner neighbors with four, five, six, seven, eight, nine, ten, eleven, twelve, thirteen, fourteen, fifteen, or sixteen side neighbors score their own number. A lone stamp scores its own number.",
		"rule": "yield_lag_pay",
		"lane": 2,
		"exemption_row": 1,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "hedvig_qvale",
		"name": "Hedvig Qvale",
		"form_name": "Plow Blank",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is empty and the queue cell nineteen places before it is empty. Every cell on the form has no cell nineteen places before it, so none of them double.",
		"rule": "double_plow_blank",
		"lane": 1,
		"exemption_row": 2,
		"goal": 22,
		"patience": 5,
	},
]

const INTROIT_BELL := [
	{
		"id": "eirik_ostby",
		"name": "Eirik Ostby",
		"form_name": "Prick Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 21 or 24.",
		"rule": "drop_if_prick_count",
		"lane": 2,
		"exemption_row": 0,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "vetle_aune",
		"name": "Vetle Aune",
		"form_name": "Dado Fill",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is filled and the queue cell eighteen places before it is filled. Every cell on the form has no cell eighteen places before it, so none of them double.",
		"rule": "double_dado_fill",
		"lane": 0,
		"exemption_row": 2,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "marte_bergstrom",
		"name": "Marte Bergstrom",
		"form_name": "Screw Pay",
		"rule_text": "Each stamp with exactly four corner neighbors and exactly sixteen side neighbors scores +2 once. Any other count scores its own number. Exactly four corner neighbors with four, five, six, seven, eight, nine, ten, eleven, twelve, thirteen, fourteen, or fifteen side neighbors score their own number. A lone stamp scores its own number.",
		"rule": "yield_screw_pay",
		"lane": 1,
		"exemption_row": 0,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "henrik_lievik",
		"name": "Henrik Lievik",
		"form_name": "Dado Blank",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is empty and the queue cell eighteen places before it is empty. Every cell on the form has no cell eighteen places before it, so none of them double.",
		"rule": "double_dado_blank",
		"lane": 0,
		"exemption_row": 1,
		"goal": 22,
		"patience": 5,
	},
]

const ANTIPHON_BELL := [
	{
		"id": "ivar_bye",
		"name": "Ivar Bye",
		"form_name": "Punch Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 20 or 23.",
		"rule": "drop_if_punch_count",
		"lane": 1,
		"exemption_row": 2,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "sindre_aas",
		"name": "Sindre Aas",
		"form_name": "Rebate Fill",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is filled and the queue cell seventeen places before it is filled. Every cell on the form has no cell seventeen places before it, so none of them double.",
		"rule": "double_rebate_fill",
		"lane": 2,
		"exemption_row": 1,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "tuva_dalen",
		"name": "Tuva Dalen",
		"form_name": "Nut Pay",
		"rule_text": "Each stamp with exactly four corner neighbors and exactly fifteen side neighbors scores +2 once. Any other count scores its own number. Exactly four corner neighbors with four, five, six, seven, eight, nine, ten, eleven, twelve, thirteen, or fourteen side neighbors score their own number. A lone stamp scores its own number.",
		"rule": "yield_nut_pay",
		"lane": 0,
		"exemption_row": 2,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "aksel_bergum",
		"name": "Aksel Bergum",
		"form_name": "Rebate Blank",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is empty and the queue cell seventeen places before it is empty. Every cell on the form has no cell seventeen places before it, so none of them double.",
		"rule": "double_rebate_blank",
		"lane": 2,
		"exemption_row": 0,
		"goal": 22,
		"patience": 5,
	},
]

const REQUIEM_BELL := [
	{
		"id": "tor_eik",
		"name": "Tor Eik",
		"form_name": "Die Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 19 or 22.",
		"rule": "drop_if_die_count",
		"lane": 0,
		"exemption_row": 1,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "njal_vold",
		"name": "Njal Vold",
		"form_name": "Chase Fill",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is filled and the queue cell sixteen places before it is filled. Every cell on the form has no cell sixteen places before it, so none of them double.",
		"rule": "double_chase_fill",
		"lane": 1,
		"exemption_row": 0,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "vilde_lie",
		"name": "Vilde Lie",
		"form_name": "Washer Pay",
		"rule_text": "Each stamp with exactly four corner neighbors and exactly fourteen side neighbors scores +2 once. Any other count scores its own number. Exactly four corner neighbors with four, five, six, seven, eight, nine, ten, eleven, twelve, or thirteen side neighbors score their own number. A lone stamp scores its own number.",
		"rule": "yield_washer_pay",
		"lane": 2,
		"exemption_row": 1,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "rasmus_rye",
		"name": "Rasmus Rye",
		"form_name": "Chase Blank",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is empty and the queue cell sixteen places before it is empty. Every cell on the form has no cell sixteen places before it, so none of them double.",
		"rule": "double_chase_blank",
		"lane": 1,
		"exemption_row": 2,
		"goal": 22,
		"patience": 5,
	},
]

const DIRGE_BELL := [
	{
		"id": "siri_nes",
		"name": "Siri Nes",
		"form_name": "Tap Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 15 or 18.",
		"rule": "drop_if_tap_count",
		"lane": 2,
		"exemption_row": 0,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "olav_sande",
		"name": "Olav Sande",
		"form_name": "Rut Fill",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is filled and the queue cell fifteen places before it is filled. Every cell on the form has no cell fifteen places before it, so none of them double.",
		"rule": "double_rut_fill",
		"lane": 0,
		"exemption_row": 2,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "magnus_holte",
		"name": "Magnus Holte",
		"form_name": "Stud Pay",
		"rule_text": "Each stamp with exactly four corner neighbors and exactly thirteen side neighbors scores +2 once. Any other count scores its own number. Exactly four corner neighbors with four, five, six, seven, eight, nine, ten, eleven, or twelve side neighbors score their own number. A lone stamp scores its own number.",
		"rule": "yield_stud_pay",
		"lane": 1,
		"exemption_row": 0,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "silje_hauge",
		"name": "Silje Hauge",
		"form_name": "Rut Blank",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is empty and the queue cell fifteen places before it is empty. Every cell on the form has no cell fifteen places before it, so none of them double.",
		"rule": "double_rut_blank",
		"lane": 0,
		"exemption_row": 1,
		"goal": 22,
		"patience": 5,
	},
]

const OCTAVE_BELL := [
	{
		"id": "anne_bakke",
		"name": "Anne Bakke",
		"form_name": "Bit Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 14 or 17.",
		"rule": "drop_if_bit_count",
		"lane": 1,
		"exemption_row": 2,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "kari_lind",
		"name": "Kari Lind",
		"form_name": "Furrow Fill",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is filled and the queue cell fourteen places before it is filled. Every cell on the form has no cell fourteen places before it, so none of them double.",
		"rule": "double_furrow_fill",
		"lane": 2,
		"exemption_row": 1,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "jon_aasen",
		"name": "Jon Aasen",
		"form_name": "Spike Pay",
		"rule_text": "Each stamp with exactly four corner neighbors and exactly twelve side neighbors scores +2 once. Any other count scores its own number. Exactly four corner neighbors with four, five, six, seven, eight, nine, ten, or eleven side neighbors score their own number. A lone stamp scores its own number.",
		"rule": "yield_spike_pay",
		"lane": 0,
		"exemption_row": 2,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "oddvar_vik",
		"name": "Oddvar Vik",
		"form_name": "Furrow Blank",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is empty and the queue cell fourteen places before it is empty. Every cell on the form has no cell fourteen places before it, so none of them double.",
		"rule": "double_furrow_blank",
		"lane": 2,
		"exemption_row": 0,
		"goal": 22,
		"patience": 5,
	},
]


const VIGIL_BELL := [
	{
		"id": "tone_nilsen",
		"name": "Tone Nilsen",
		"form_name": "Awl Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 13 or 16.",
		"rule": "drop_if_awl_count",
		"lane": 0,
		"exemption_row": 1,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "emil_eriksen",
		"name": "Emil Eriksen",
		"form_name": "Groove Fill",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is filled and the queue cell thirteen places before it is filled. Every cell on the form has no cell thirteen places before it, so none of them double.",
		"rule": "double_groove_fill",
		"lane": 1,
		"exemption_row": 0,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "grete_hansen",
		"name": "Grete Hansen",
		"form_name": "Sprig Pay",
		"rule_text": "Each stamp with exactly four corner neighbors and exactly eleven side neighbors scores +2 once. Any other count scores its own number. Exactly four corner neighbors with four, five, six, seven, eight, nine, or ten side neighbors score their own number. A lone stamp scores its own number.",
		"rule": "yield_sprig_pay",
		"lane": 2,
		"exemption_row": 1,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "hilde_olsen",
		"name": "Hilde Olsen",
		"form_name": "Groove Blank",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is empty and the queue cell thirteen places before it is empty. Every cell on the form has no cell thirteen places before it, so none of them double.",
		"rule": "double_groove_blank",
		"lane": 1,
		"exemption_row": 2,
		"goal": 22,
		"patience": 5,
	},
]


const NONE_BELL := [
	{
		"id": "kare_holmen",
		"name": "Kåre Holmen",
		"form_name": "Gimlet Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 12 or 15.",
		"rule": "drop_if_gimlet_count",
		"lane": 2,
		"exemption_row": 0,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "sissel_lunde",
		"name": "Sissel Lunde",
		"form_name": "Flute Fill",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is filled and the queue cell twelve places before it is filled. Every cell on the form has no cell twelve places before it, so none of them double.",
		"rule": "double_flute_fill",
		"lane": 0,
		"exemption_row": 2,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "sigurd_bakken",
		"name": "Sigurd Bakken",
		"form_name": "Tack Pay",
		"rule_text": "Each stamp with exactly four corner neighbors and exactly ten side neighbors scores +2 once. Any other count scores its own number. Exactly four corner neighbors with four, five, six, seven, eight, or nine side neighbors score their own number. A lone stamp scores its own number.",
		"rule": "yield_tack_pay",
		"lane": 1,
		"exemption_row": 0,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "brita_solheim",
		"name": "Brita Solheim",
		"form_name": "Flute Blank",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is empty and the queue cell twelve places before it is empty. Every cell on the form has no cell twelve places before it, so none of them double.",
		"rule": "double_flute_blank",
		"lane": 0,
		"exemption_row": 1,
		"goal": 22,
		"patience": 5,
	},
]


const SEXT_BELL := [
	{
		"id": "sondre_eide",
		"name": "Sondre Eide",
		"form_name": "Auger Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 11 or 14.",
		"rule": "drop_if_auger_count",
		"lane": 1,
		"exemption_row": 2,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "iben_ruud",
		"name": "Iben Ruud",
		"form_name": "Wave Fill",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is filled and the queue cell eleven places before it is filled. Every cell on the form has no cell eleven places before it, so none of them double.",
		"rule": "double_wave_fill",
		"lane": 2,
		"exemption_row": 1,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "unn_strand",
		"name": "Unn Strand",
		"form_name": "Nail Pay",
		"rule_text": "Each stamp with exactly four corner neighbors and exactly nine side neighbors scores +2 once. Any other count scores its own number. Exactly four corner neighbors with four, five, six, seven, or eight side neighbors score their own number. A lone stamp scores its own number.",
		"rule": "yield_nail_pay",
		"lane": 0,
		"exemption_row": 2,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "guro_hagen",
		"name": "Guro Hagen",
		"form_name": "Wave Blank",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is empty and the queue cell eleven places before it is empty. Every cell on the form has no cell eleven places before it, so none of them double.",
		"rule": "double_wave_blank",
		"lane": 2,
		"exemption_row": 0,
		"goal": 22,
		"patience": 5,
	},
]


const TERCE_BELL := [
	{
		"id": "torsten_bjerke",
		"name": "Torsten Bjerke",
		"form_name": "Countersink Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 10 or 13.",
		"rule": "drop_if_countersink_count",
		"lane": 0,
		"exemption_row": 1,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "jens_solberg",
		"name": "Jens Solberg",
		"form_name": "Crimp Fill",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is filled and the queue cell ten places before it is filled. Every cell on the form has no cell ten places before it, so none of them double.",
		"rule": "double_crimp_fill",
		"lane": 1,
		"exemption_row": 0,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "frida_haugen",
		"name": "Frida Haugen",
		"form_name": "Cotter Pay",
		"rule_text": "Each stamp with exactly four corner neighbors and exactly eight side neighbors scores +2 once. Any other count scores its own number. Exactly four corner neighbors with four, five, six, or seven side neighbors score their own number. A lone stamp scores its own number.",
		"rule": "yield_cotter_pay",
		"lane": 2,
		"exemption_row": 1,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "magda_nygaard",
		"name": "Magda Nygaard",
		"form_name": "Crimp Blank",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is empty and the queue cell ten places before it is empty. Every cell on the form has no cell ten places before it, so none of them double.",
		"rule": "double_crimp_blank",
		"lane": 1,
		"exemption_row": 2,
		"goal": 22,
		"patience": 5,
	},
]


const PRIME_BELL := [
	{
		"id": "siv_moen",
		"name": "Siv Moen",
		"form_name": "Drift Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 9 or 12.",
		"rule": "drop_if_drift_count",
		"lane": 2,
		"exemption_row": 0,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "halvard_falk",
		"name": "Halvard Falk",
		"form_name": "Hook Fill",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is filled and the queue cell nine places before it is filled. Every cell on the form has no cell nine places before it, so none of them double.",
		"rule": "double_hook_fill",
		"lane": 0,
		"exemption_row": 2,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "eira_skog",
		"name": "Eira Skog",
		"form_name": "Set Pay",
		"rule_text": "Each stamp with exactly four corner neighbors and exactly seven side neighbors scores +2 once. Any other count scores its own number. Exactly four corner neighbors with four, five, or six side neighbors score their own number. A lone stamp scores its own number.",
		"rule": "yield_set_pay",
		"lane": 1,
		"exemption_row": 0,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "runar_nore",
		"name": "Runar Nore",
		"form_name": "Hook Blank",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is empty and the queue cell nine places before it is empty. Every cell on the form has no cell nine places before it, so none of them double.",
		"rule": "double_hook_blank",
		"lane": 0,
		"exemption_row": 1,
		"goal": 22,
		"patience": 5,
	},
]


const LAUDS_BELL := [
	{
		"id": "ragna_moe",
		"name": "Ragna Moe",
		"form_name": "Broach Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 8 or 11.",
		"rule": "drop_if_broach_count",
		"lane": 1,
		"exemption_row": 2,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "thora_dahl",
		"name": "Thora Dahl",
		"form_name": "Jog Fill",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is filled and the queue cell eight places before it is filled. The top-left, top-middle, top-right, middle-left, center, middle-right, bottom-left, and bottom-middle cells have no cell eight places before them, so they do not double. The bottom-right cell has no cell one place after it, so it does not double.",
		"rule": "double_jog_fill",
		"lane": 2,
		"exemption_row": 1,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "birgit_berg",
		"name": "Birgit Berg",
		"form_name": "Peen Pay",
		"rule_text": "Each stamp with exactly four corner neighbors and exactly six side neighbors scores +2 once. Any other count scores its own number. Exactly four corner neighbors with exactly four side neighbors score their own number. Exactly four corner neighbors with exactly five side neighbors score their own number. A lone stamp scores its own number.",
		"rule": "yield_peen_pay",
		"lane": 0,
		"exemption_row": 2,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "olaf_lund",
		"name": "Olaf Lund",
		"form_name": "Jog Blank",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is empty and the queue cell eight places before it is empty. The top-left, top-middle, top-right, middle-left, center, middle-right, bottom-left, and bottom-middle cells have no cell eight places before them, so they do not double. The bottom-right cell has no cell one place after it, so it does not double.",
		"rule": "double_jog_blank",
		"lane": 2,
		"exemption_row": 0,
		"goal": 22,
		"patience": 5,
	},
]


const MATINS_BELL := [
	{
		"id": "astrid_holm",
		"name": "Astrid Holm",
		"form_name": "Chamfer Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 7 or 10.",
		"rule": "drop_if_chamfer_count",
		"lane": 0,
		"exemption_row": 1,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "signe_damm",
		"name": "Signe Damm",
		"form_name": "Nick Fill",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is filled and the queue cell seven places before it is filled. The top-left cell has no cell seven places before it, so it does not double. The top-middle cell has no cell seven places before it, so it does not double. The top-right cell has no cell seven places before it, so it does not double. The middle-left cell has no cell seven places before it, so it does not double. The center cell has no cell seven places before it, so it does not double. The middle-right cell has no cell seven places before it, so it does not double. The bottom-left cell has no cell seven places before it, so it does not double. The bottom-right cell has no cell one place after it, so it does not double.",
		"rule": "double_nick_fill",
		"lane": 1,
		"exemption_row": 0,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "knut_kett",
		"name": "Knut Kett",
		"form_name": "Stake Pay",
		"rule_text": "Each stamp with exactly four corner neighbors and exactly five side neighbors scores +2 once. Any other count scores its own number. Exactly four corner neighbors with exactly four side neighbors score their own number. Exactly four corner neighbors with exactly three side neighbors score their own number. A lone stamp scores its own number.",
		"rule": "yield_stake_pay",
		"lane": 2,
		"exemption_row": 1,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "yrsa_vang",
		"name": "Yrsa Vang",
		"form_name": "Nick Blank",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is empty and the queue cell seven places before it is empty. The top-left cell has no cell seven places before it, so it does not double. The top-middle cell has no cell seven places before it, so it does not double. The top-right cell has no cell seven places before it, so it does not double. The middle-left cell has no cell seven places before it, so it does not double. The center cell has no cell seven places before it, so it does not double. The middle-right cell has no cell seven places before it, so it does not double. The bottom-left cell has no cell seven places before it, so it does not double. The bottom-right cell has no cell one place after it, so it does not double.",
		"rule": "double_nick_blank",
		"lane": 1,
		"exemption_row": 2,
		"goal": 22,
		"patience": 5,
	},
]


const AUBADE_BELL := [
	{
		"id": "vidar_hale",
		"name": "Vidar Hale",
		"form_name": "Burr Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 6 or 9.",
		"rule": "drop_if_burr_count",
		"lane": 2,
		"exemption_row": 0,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "ylva_voss",
		"name": "Ylva Voss",
		"form_name": "Kink Fill",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is filled and the queue cell six places before it is filled. The top-left cell has no cell six places before it, so it does not double. The top-middle cell has no cell six places before it, so it does not double. The top-right cell has no cell six places before it, so it does not double. The middle-left cell has no cell six places before it, so it does not double. The center cell has no cell six places before it, so it does not double. The middle-right cell has no cell six places before it, so it does not double. The bottom-right cell has no cell one place after it, so it does not double.",
		"rule": "double_kink_fill",
		"lane": 0,
		"exemption_row": 2,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "hanne_brant",
		"name": "Hanne Brant",
		"form_name": "Clench Pay",
		"rule_text": "Each stamp with exactly four corner neighbors and exactly four side neighbors scores +2 once. Any other count scores its own number. Exactly four corner neighbors with exactly three side neighbors score their own number. Exactly four corner neighbors with exactly two side neighbors score their own number. A lone stamp scores its own number.",
		"rule": "yield_clench_pay",
		"lane": 1,
		"exemption_row": 0,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "esben_okell",
		"name": "Esben Okell",
		"form_name": "Kink Blank",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is empty and the queue cell six places before it is empty. The top-left cell has no cell six places before it, so it does not double. The top-middle cell has no cell six places before it, so it does not double. The top-right cell has no cell six places before it, so it does not double. The middle-left cell has no cell six places before it, so it does not double. The center cell has no cell six places before it, so it does not double. The middle-right cell has no cell six places before it, so it does not double. The bottom-right cell has no cell one place after it, so it does not double.",
		"rule": "double_kink_blank",
		"lane": 0,
		"exemption_row": 1,
		"goal": 22,
		"patience": 5,
	},
]


const VESPERS_BELL := [
	{
		"id": "gunnar_hale",
		"name": "Gunnar Hale",
		"form_name": "Ream Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 5 or 8.",
		"rule": "drop_if_ream_count",
		"lane": 1,
		"exemption_row": 2,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "torun_voss",
		"name": "Torun Voss",
		"form_name": "Bend Fill",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is filled and the queue cell five places before it is filled. The top-left cell has no cell five places before it, so it does not double. The top-middle cell has no cell five places before it, so it does not double. The top-right cell has no cell five places before it, so it does not double. The middle-left cell has no cell five places before it, so it does not double. The center cell has no cell five places before it, so it does not double. The bottom-right cell has no cell one place after it, so it does not double.",
		"rule": "double_bend_fill",
		"lane": 2,
		"exemption_row": 1,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "solveig_brant",
		"name": "Solveig Brant",
		"form_name": "Clinch Pay",
		"rule_text": "Each stamp with exactly four corner neighbors and exactly three side neighbors scores +2 once. Any other count scores its own number. Exactly four corner neighbors with exactly two side neighbors score their own number. Exactly four corner neighbors with exactly one side neighbor score their own number. A lone stamp scores its own number.",
		"rule": "yield_clinch_pay",
		"lane": 0,
		"exemption_row": 2,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "einar_okell",
		"name": "Einar Okell",
		"form_name": "Bend Blank",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is empty and the queue cell five places before it is empty. The top-left cell has no cell five places before it, so it does not double. The top-middle cell has no cell five places before it, so it does not double. The top-right cell has no cell five places before it, so it does not double. The middle-left cell has no cell five places before it, so it does not double. The center cell has no cell five places before it, so it does not double. The bottom-right cell has no cell one place after it, so it does not double.",
		"rule": "double_bend_blank",
		"lane": 2,
		"exemption_row": 0,
		"goal": 22,
		"patience": 5,
	},
]


const COMPLINE_BELL := [
	{
		"id": "arvid_hale",
		"name": "Arvid Hale",
		"form_name": "Kerf Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 4 or 7.",
		"rule": "drop_if_kerf_count",
		"lane": 0,
		"exemption_row": 1,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "hedda_voss",
		"name": "Hedda Voss",
		"form_name": "Crook Fill",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is filled and the queue cell four places before it is filled. The top-left cell has no cell four places before it, so it does not double. The top-middle cell has no cell four places before it, so it does not double. The top-right cell has no cell four places before it, so it does not double. The middle-left cell has no cell four places before it, so it does not double. The bottom-right cell has no cell one place after it, so it does not double.",
		"rule": "double_crook_fill",
		"lane": 1,
		"exemption_row": 0,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "kajsa_brant",
		"name": "Kajsa Brant",
		"form_name": "Rivet Pay",
		"rule_text": "Each stamp with exactly four corner neighbors and exactly two side neighbors scores +2 once. Any other count scores its own number. Exactly four corner neighbors with exactly one side neighbor score their own number. Exactly three corner neighbors with exactly four side neighbors score their own number. A lone stamp scores its own number.",
		"rule": "yield_rivet_pay",
		"lane": 2,
		"exemption_row": 1,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "bodil_okell",
		"name": "Bodil Okell",
		"form_name": "Crook Blank",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is empty and the queue cell four places before it is empty. The top-left cell has no cell four places before it, so it does not double. The top-middle cell has no cell four places before it, so it does not double. The top-right cell has no cell four places before it, so it does not double. The middle-left cell has no cell four places before it, so it does not double. The bottom-right cell has no cell one place after it, so it does not double.",
		"rule": "double_crook_blank",
		"lane": 1,
		"exemption_row": 2,
		"goal": 22,
		"patience": 5,
	},
]


const NOCTURNE_BELL := [
	{
		"id": "halvar_hale",
		"name": "Halvar Hale",
		"form_name": "Gouge Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 3 or 6.",
		"rule": "drop_if_gouge_count",
		"lane": 2,
		"exemption_row": 0,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "maja_voss",
		"name": "Maja Voss",
		"form_name": "Bight Fill",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is filled and the queue cell three places before it is filled. The top-left cell has no cell three places before it, so it does not double. The top-middle cell has no cell three places before it, so it does not double. The top-right cell has no cell three places before it, so it does not double. The bottom-right cell has no cell one place after it, so it does not double.",
		"rule": "double_bight_fill",
		"lane": 0,
		"exemption_row": 2,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "ebba_brant",
		"name": "Ebba Brant",
		"form_name": "Brad Pay",
		"rule_text": "Each stamp with exactly four corner neighbors and exactly one side neighbor scores +2 once. Any other count scores its own number. Exactly three corner neighbors with exactly four side neighbors score their own number. A lone stamp scores its own number.",
		"rule": "yield_brad_pay",
		"lane": 1,
		"exemption_row": 0,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "sten_okell",
		"name": "Sten Okell",
		"form_name": "Bight Blank",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is empty and the queue cell three places before it is empty. The top-left cell has no cell three places before it, so it does not double. The top-middle cell has no cell three places before it, so it does not double. The top-right cell has no cell three places before it, so it does not double. The bottom-right cell has no cell one place after it, so it does not double.",
		"rule": "double_bight_blank",
		"lane": 0,
		"exemption_row": 1,
		"goal": 22,
		"patience": 5,
	},
]


const RECESSIONAL_BELL := [
	{
		"id": "peder_hale",
		"name": "Peder Hale",
		"form_name": "Gash Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 2 or 5.",
		"rule": "drop_if_gash_count",
		"lane": 1,
		"exemption_row": 2,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "svea_voss",
		"name": "Svea Voss",
		"form_name": "Hitch Fill",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is filled and the queue cell two places before it is filled. The top-left cell has no cell two places before it, so it does not double. The top-middle cell has no cell two places before it, so it does not double. The bottom-right cell has no cell one place after it, so it does not double.",
		"rule": "double_hitch_fill",
		"lane": 2,
		"exemption_row": 1,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "asta_brant",
		"name": "Asta Brant",
		"form_name": "Pin Pay",
		"rule_text": "Each stamp with exactly three corner neighbors and exactly four side neighbors scores +2 once. Any other count scores its own number. Exactly three corner neighbors with exactly three side neighbors score their own number. A lone stamp scores its own number.",
		"rule": "yield_pin_pay",
		"lane": 0,
		"exemption_row": 2,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "liv_okell",
		"name": "Liv Okell",
		"form_name": "Hitch Blank",
		"rule_text": "A stamp scores twice only when the queue cell one place after it is empty and the queue cell two places before it is empty. The top-left cell has no cell two places before it, so it does not double. The top-middle cell has no cell two places before it, so it does not double. The bottom-right cell has no cell one place after it, so it does not double.",
		"rule": "double_hitch_blank",
		"lane": 2,
		"exemption_row": 0,
		"goal": 22,
		"patience": 5,
	},
]


const VALEDICTION_BELL := [
	{
		"id": "theo_hale",
		"name": "Theo Hale",
		"form_name": "Dent Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 1 or 4.",
		"rule": "drop_if_dent_count",
		"lane": 0,
		"exemption_row": 1,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "rolf_voss",
		"name": "Rolf Voss",
		"form_name": "Peg Fill",
		"rule_text": "A stamp scores twice only when the queue cell two places after it is filled and the queue cell two places before it is filled. The top-left cell has no cell two places before it, so it does not double. The top-middle cell has no cell two places before it, so it does not double. The bottom-middle cell has no cell two places after it, so it does not double. The bottom-right cell has no cell two places after it, so it does not double.",
		"rule": "double_peg_fill",
		"lane": 1,
		"exemption_row": 0,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "inga_brant",
		"name": "Inga Brant",
		"form_name": "Bolt Pay",
		"rule_text": "Each stamp with exactly three corner neighbors and exactly three side neighbors scores +2 once. Any other count scores its own number. Exactly three corner neighbors with exactly two side neighbors score their own number. A lone stamp scores its own number.",
		"rule": "yield_bolt_pay",
		"lane": 2,
		"exemption_row": 1,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "elin_okell",
		"name": "Elin Okell",
		"form_name": "Peg Blank",
		"rule_text": "A stamp scores twice only when the queue cell two places after it is empty and the queue cell two places before it is empty. The top-left cell has no cell two places before it, so it does not double. The top-middle cell has no cell two places before it, so it does not double. The bottom-middle cell has no cell two places after it, so it does not double. The bottom-right cell has no cell two places after it, so it does not double.",
		"rule": "double_peg_blank",
		"lane": 1,
		"exemption_row": 2,
		"goal": 22,
		"patience": 5,
	},
]


const EPODE_BELL := [
	{
		"id": "alma_hale",
		"name": "Alma Hale",
		"form_name": "Fork Toll",
		"rule_text": "Patience drops by 2 when the number of filled cells is 0 or 3.",
		"rule": "drop_if_fork_count",
		"lane": 2,
		"exemption_row": 0,
		"goal": 18,
		"patience": 5,
	},
	{
		"id": "stig_voss",
		"name": "Stig Voss",
		"form_name": "Yoke Fill",
		"rule_text": "A stamp scores twice only when the queue cell three places after it is filled and the queue cell three places before it is filled. The top-left cell has no cell three places before it, so it does not double. The top-middle cell has no cell three places before it, so it does not double. The top-right cell has no cell three places before it, so it does not double. The bottom-left cell has no cell three places after it, so it does not double. The bottom-middle cell has no cell three places after it, so it does not double. The bottom-right cell has no cell three places after it, so it does not double.",
		"rule": "double_yoke_fill",
		"lane": 0,
		"exemption_row": 2,
		"goal": 20,
		"patience": 5,
	},
	{
		"id": "rune_brant",
		"name": "Rune Brant",
		"form_name": "Hasp Pay",
		"rule_text": "Each stamp with exactly three corner neighbors and exactly two side neighbors scores +2 once. Any other count scores its own number. Exactly three corner neighbors with exactly one side neighbor score their own number. A lone stamp scores its own number.",
		"rule": "yield_hasp_pay",
		"lane": 1,
		"exemption_row": 2,
		"goal": 16,
		"patience": 5,
	},
	{
		"id": "cora_okell",
		"name": "Cora Okell",
		"form_name": "Yoke Blank",
		"rule_text": "A stamp scores twice only when the queue cell three places after it is empty and the queue cell three places before it is empty. The top-left cell has no cell three places before it, so it does not double. The top-middle cell has no cell three places before it, so it does not double. The top-right cell has no cell three places before it, so it does not double. The bottom-left cell has no cell three places after it, so it does not double. The bottom-middle cell has no cell three places after it, so it does not double. The bottom-right cell has no cell three places after it, so it does not double.",
		"rule": "double_yoke_blank",
		"lane": 0,
		"exemption_row": 1,
		"goal": 22,
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
	var score_ignore_row: int = -1
	var score_ignore_col: int = -1


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
	if shift_index == SHIFT_COLOPHON:
		return SHIFT_COLOPHON
	if shift_index == SHIFT_ERRATA:
		return SHIFT_ERRATA
	if shift_index == SHIFT_FRONTISPIECE:
		return SHIFT_FRONTISPIECE
	if shift_index == SHIFT_FLYLEAF:
		return SHIFT_FLYLEAF
	if shift_index == SHIFT_ENDPAPER:
		return SHIFT_ENDPAPER
	if shift_index == SHIFT_HALFTITLE:
		return SHIFT_HALFTITLE
	if shift_index == SHIFT_TITLEPAGE:
		return SHIFT_TITLEPAGE
	if shift_index == SHIFT_COPYRIGHT:
		return SHIFT_COPYRIGHT
	if shift_index == SHIFT_SEQUENCE:
		return SHIFT_SEQUENCE
	if shift_index == SHIFT_TRACT:
		return SHIFT_TRACT
	if shift_index == SHIFT_GRADUAL:
		return SHIFT_GRADUAL
	if shift_index == SHIFT_INTROIT:
		return SHIFT_INTROIT
	if shift_index == SHIFT_ANTIPHON:
		return SHIFT_ANTIPHON
	if shift_index == SHIFT_REQUIEM:
		return SHIFT_REQUIEM
	if shift_index == SHIFT_DIRGE:
		return SHIFT_DIRGE
	if shift_index == SHIFT_OCTAVE:
		return SHIFT_OCTAVE
	if shift_index == SHIFT_VIGIL:
		return SHIFT_VIGIL
	if shift_index == SHIFT_NONE:
		return SHIFT_NONE
	if shift_index == SHIFT_SEXT:
		return SHIFT_SEXT
	if shift_index == SHIFT_TERCE:
		return SHIFT_TERCE
	if shift_index == SHIFT_PRIME:
		return SHIFT_PRIME
	if shift_index == SHIFT_LAUDS:
		return SHIFT_LAUDS
	if shift_index == SHIFT_MATINS:
		return SHIFT_MATINS
	if shift_index == SHIFT_AUBADE:
		return SHIFT_AUBADE
	if shift_index == SHIFT_VESPERS:
		return SHIFT_VESPERS
	if shift_index == SHIFT_COMPLINE:
		return SHIFT_COMPLINE
	if shift_index == SHIFT_NOCTURNE:
		return SHIFT_NOCTURNE
	if shift_index == SHIFT_RECESSIONAL:
		return SHIFT_RECESSIONAL
	if shift_index == SHIFT_VALEDICTION:
		return SHIFT_VALEDICTION
	if shift_index == SHIFT_EPODE:
		return SHIFT_EPODE
	if shift_index == SHIFT_FINALE:
		return SHIFT_FINALE
	if shift_index == SHIFT_ENVOY:
		return SHIFT_ENVOY
	if shift_index == SHIFT_FINIS:
		return SHIFT_FINIS
	if shift_index == SHIFT_EXPLICIT:
		return SHIFT_EXPLICIT
	if shift_index == SHIFT_CODA:
		return SHIFT_CODA
	if shift_index == SHIFT_EPILOGUE:
		return SHIFT_EPILOGUE
	if shift_index == SHIFT_CORRIGENDA:
		return SHIFT_CORRIGENDA
	if shift_index == SHIFT_ENVOI:
		return SHIFT_ENVOI
	if shift_index == SHIFT_ADDENDA:
		return SHIFT_ADDENDA
	if shift_index == SHIFT_POSTSCRIPT:
		return SHIFT_POSTSCRIPT
	if shift_index == SHIFT_AFTERWORD:
		return SHIFT_AFTERWORD
	if shift_index == SHIFT_APPENDIX:
		return SHIFT_APPENDIX
	if shift_index == SHIFT_GLOSSARY:
		return SHIFT_GLOSSARY
	if shift_index == SHIFT_ACKNOWLEDGMENTS:
		return SHIFT_ACKNOWLEDGMENTS
	if shift_index == SHIFT_PROLOGUE:
		return SHIFT_PROLOGUE
	if shift_index == SHIFT_INTRODUCTION:
		return SHIFT_INTRODUCTION
	if shift_index == SHIFT_CONTENTS:
		return SHIFT_CONTENTS
	if shift_index == SHIFT_FOREWORD:
		return SHIFT_FOREWORD
	if shift_index == SHIFT_PREFACE:
		return SHIFT_PREFACE
	if shift_index == SHIFT_EPIGRAPH:
		return SHIFT_EPIGRAPH
	if shift_index == SHIFT_DEDICATION:
		return SHIFT_DEDICATION
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
	if state.shift == SHIFT_SEQUENCE:
		_log(state, "The sequence bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_TRACT:
		_log(state, "The tract bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_GRADUAL:
		_log(state, "The gradual bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_INTROIT:
		_log(state, "The introit bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_ANTIPHON:
		_log(state, "The antiphon bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_REQUIEM:
		_log(state, "The requiem bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_DIRGE:
		_log(state, "The dirge bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_OCTAVE:
		_log(state, "The octave bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_VIGIL:
		_log(state, "The vigil bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_NONE:
		_log(state, "The none bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_SEXT:
		_log(state, "The sext bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_TERCE:
		_log(state, "The terce bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_PRIME:
		_log(state, "The prime bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_LAUDS:
		_log(state, "The lauds bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_MATINS:
		_log(state, "The matins bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_AUBADE:
		_log(state, "The aubade bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_VESPERS:
		_log(state, "The vespers bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_COMPLINE:
		_log(state, "The compline bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_NOCTURNE:
		_log(state, "The nocturne bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_RECESSIONAL:
		_log(state, "The recessional bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_VALEDICTION:
		_log(state, "The valediction bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_EPODE:
		_log(state, "The epode bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_FINALE:
		_log(state, "The finale bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_ENVOY:
		_log(state, "The envoy bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_FINIS:
		_log(state, "The finis bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_EXPLICIT:
		_log(state, "The explicit bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_CODA:
		_log(state, "The coda bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_EPILOGUE:
		_log(state, "The epilogue bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_CORRIGENDA:
		_log(state, "The corrigenda bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_ENVOI:
		_log(state, "The envoi bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_ADDENDA:
		_log(state, "The addenda bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_POSTSCRIPT:
		_log(state, "The postscript bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_AFTERWORD:
		_log(state, "The afterword bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_APPENDIX:
		_log(state, "The appendix bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_GLOSSARY:
		_log(state, "The glossary bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_ACKNOWLEDGMENTS:
		_log(state, "The acknowledgments bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_PROLOGUE:
		_log(state, "The prologue bell begins. Seed %d." % state.seed)
	if state.shift == SHIFT_INTRODUCTION:
		_log(state, "The introduction bell begins. Seed %d." % state.seed)
	elif state.shift == SHIFT_CONTENTS:
		_log(state, "The contents bell begins. Seed %d." % state.seed)
	elif state.shift == SHIFT_FOREWORD:
		_log(state, "The foreword bell begins. Seed %d." % state.seed)
	elif state.shift == SHIFT_PREFACE:
		_log(state, "The preface bell begins. Seed %d." % state.seed)
	elif state.shift == SHIFT_EPIGRAPH:
		_log(state, "The epigraph bell begins. Seed %d." % state.seed)
	elif state.shift == SHIFT_DEDICATION:
		_log(state, "The dedication bell begins. Seed %d." % state.seed)
	elif state.shift == SHIFT_COPYRIGHT:
		_log(state, "The copyright bell begins. Seed %d." % state.seed)
	elif state.shift == SHIFT_TITLEPAGE:
		_log(state, "The title-page bell begins. Seed %d." % state.seed)
	elif state.shift == SHIFT_HALFTITLE:
		_log(state, "The half-title bell begins. Seed %d." % state.seed)
	elif state.shift == SHIFT_ENDPAPER:
		_log(state, "The endpaper bell begins. Seed %d." % state.seed)
	elif state.shift == SHIFT_FLYLEAF:
		_log(state, "The flyleaf bell begins. Seed %d." % state.seed)
	elif state.shift == SHIFT_FRONTISPIECE:
		_log(state, "The frontispiece bell begins. Seed %d." % state.seed)
	elif state.shift == SHIFT_ERRATA:
		_log(state, "The errata bell begins. Seed %d." % state.seed)
	elif state.shift == SHIFT_COLOPHON:
		_log(state, "The colophon bell begins. Seed %d." % state.seed)
	elif state.shift == SHIFT_CATCHWORD:
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
	if state.shift == SHIFT_SEQUENCE:
		return "Sequence bell"
	if state.shift == SHIFT_TRACT:
		return "Tract bell"
	if state.shift == SHIFT_GRADUAL:
		return "Gradual bell"
	if state.shift == SHIFT_INTROIT:
		return "Introit bell"
	if state.shift == SHIFT_ANTIPHON:
		return "Antiphon bell"
	if state.shift == SHIFT_REQUIEM:
		return "Requiem bell"
	if state.shift == SHIFT_DIRGE:
		return "Dirge bell"
	if state.shift == SHIFT_OCTAVE:
		return "Octave bell"
	if state.shift == SHIFT_VIGIL:
		return "Vigil bell"
	if state.shift == SHIFT_NONE:
		return "None bell"
	if state.shift == SHIFT_SEXT:
		return "Sext bell"
	if state.shift == SHIFT_TERCE:
		return "Terce bell"
	if state.shift == SHIFT_PRIME:
		return "Prime bell"
	if state.shift == SHIFT_LAUDS:
		return "Lauds bell"
	if state.shift == SHIFT_MATINS:
		return "Matins bell"
	if state.shift == SHIFT_AUBADE:
		return "Aubade bell"
	if state.shift == SHIFT_VESPERS:
		return "Vespers bell"
	if state.shift == SHIFT_COMPLINE:
		return "Compline bell"
	if state.shift == SHIFT_NOCTURNE:
		return "Nocturne bell"
	if state.shift == SHIFT_RECESSIONAL:
		return "Recessional bell"
	if state.shift == SHIFT_VALEDICTION:
		return "Valediction bell"
	if state.shift == SHIFT_EPODE:
		return "Epode bell"
	if state.shift == SHIFT_FINALE:
		return "Finale bell"
	if state.shift == SHIFT_ENVOY:
		return "Envoy bell"
	if state.shift == SHIFT_FINIS:
		return "Finis bell"
	if state.shift == SHIFT_EXPLICIT:
		return "Explicit bell"
	if state.shift == SHIFT_CODA:
		return "Coda bell"
	if state.shift == SHIFT_EPILOGUE:
		return "Epilogue bell"
	if state.shift == SHIFT_CORRIGENDA:
		return "Corrigenda bell"
	if state.shift == SHIFT_ENVOI:
		return "Envoi bell"
	if state.shift == SHIFT_ADDENDA:
		return "Addenda bell"
	if state.shift == SHIFT_POSTSCRIPT:
		return "Postscript bell"
	if state.shift == SHIFT_AFTERWORD:
		return "Afterword bell"
	if state.shift == SHIFT_APPENDIX:
		return "Appendix bell"
	if state.shift == SHIFT_GLOSSARY:
		return "Glossary bell"
	if state.shift == SHIFT_ACKNOWLEDGMENTS:
		return "Acknowledgments bell"
	if state.shift == SHIFT_PROLOGUE:
		return "Prologue bell"
	if state.shift == SHIFT_INTRODUCTION:
		return "Introduction bell"
	if state.shift == SHIFT_CONTENTS:
		return "Contents bell"
	if state.shift == SHIFT_FOREWORD:
		return "Foreword bell"
	if state.shift == SHIFT_PREFACE:
		return "Preface bell"
	if state.shift == SHIFT_EPIGRAPH:
		return "Epigraph bell"
	if state.shift == SHIFT_DEDICATION:
		return "Dedication bell"
	if state.shift == SHIFT_COPYRIGHT:
		return "Copyright bell"
	if state.shift == SHIFT_TITLEPAGE:
		return "Title-page bell"
	if state.shift == SHIFT_HALFTITLE:
		return "Half-title bell"
	if state.shift == SHIFT_ENDPAPER:
		return "Endpaper bell"
	if state.shift == SHIFT_FLYLEAF:
		return "Flyleaf bell"
	if state.shift == SHIFT_FRONTISPIECE:
		return "Frontispiece bell"
	if state.shift == SHIFT_ERRATA:
		return "Errata bell"
	if state.shift == SHIFT_COLOPHON:
		return "Colophon bell"
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
	if state.shift == SHIFT_SEQUENCE:
		return SEQUENCE_BELL
	if state.shift == SHIFT_TRACT:
		return TRACT_BELL
	if state.shift == SHIFT_GRADUAL:
		return GRADUAL_BELL
	if state.shift == SHIFT_INTROIT:
		return INTROIT_BELL
	if state.shift == SHIFT_ANTIPHON:
		return ANTIPHON_BELL
	if state.shift == SHIFT_REQUIEM:
		return REQUIEM_BELL
	if state.shift == SHIFT_DIRGE:
		return DIRGE_BELL
	if state.shift == SHIFT_OCTAVE:
		return OCTAVE_BELL
	if state.shift == SHIFT_VIGIL:
		return VIGIL_BELL
	if state.shift == SHIFT_NONE:
		return NONE_BELL
	if state.shift == SHIFT_SEXT:
		return SEXT_BELL
	if state.shift == SHIFT_TERCE:
		return TERCE_BELL
	if state.shift == SHIFT_PRIME:
		return PRIME_BELL
	if state.shift == SHIFT_LAUDS:
		return LAUDS_BELL
	if state.shift == SHIFT_MATINS:
		return MATINS_BELL
	if state.shift == SHIFT_AUBADE:
		return AUBADE_BELL
	if state.shift == SHIFT_VESPERS:
		return VESPERS_BELL
	if state.shift == SHIFT_COMPLINE:
		return COMPLINE_BELL
	if state.shift == SHIFT_NOCTURNE:
		return NOCTURNE_BELL
	if state.shift == SHIFT_RECESSIONAL:
		return RECESSIONAL_BELL
	if state.shift == SHIFT_VALEDICTION:
		return VALEDICTION_BELL
	if state.shift == SHIFT_EPODE:
		return EPODE_BELL
	if state.shift == SHIFT_FINALE:
		return FINALE_BELL
	if state.shift == SHIFT_ENVOY:
		return ENVOY_BELL
	if state.shift == SHIFT_FINIS:
		return FINIS_BELL
	if state.shift == SHIFT_EXPLICIT:
		return EXPLICIT_BELL
	if state.shift == SHIFT_CODA:
		return CODA_BELL
	if state.shift == SHIFT_EPILOGUE:
		return EPILOGUE_BELL
	if state.shift == SHIFT_CORRIGENDA:
		return CORRIGENDA_BELL
	if state.shift == SHIFT_ENVOI:
		return ENVOI_BELL
	if state.shift == SHIFT_ADDENDA:
		return ADDENDA_BELL
	if state.shift == SHIFT_POSTSCRIPT:
		return POSTSCRIPT_BELL
	if state.shift == SHIFT_AFTERWORD:
		return AFTERWORD_BELL
	if state.shift == SHIFT_APPENDIX:
		return APPENDIX_BELL
	if state.shift == SHIFT_GLOSSARY:
		return GLOSSARY_BELL
	if state.shift == SHIFT_ACKNOWLEDGMENTS:
		return ACKNOWLEDGMENTS_BELL
	if state.shift == SHIFT_PROLOGUE:
		return PROLOGUE_BELL
	if state.shift == SHIFT_INTRODUCTION:
		return INTRODUCTION_BELL
	if state.shift == SHIFT_CONTENTS:
		return CONTENTS_BELL
	if state.shift == SHIFT_FOREWORD:
		return FOREWORD_BELL
	if state.shift == SHIFT_PREFACE:
		return PREFACE_BELL
	if state.shift == SHIFT_EPIGRAPH:
		return EPIGRAPH_BELL
	if state.shift == SHIFT_DEDICATION:
		return DEDICATION_BELL
	if state.shift == SHIFT_COPYRIGHT:
		return COPYRIGHT_BELL
	if state.shift == SHIFT_TITLEPAGE:
		return TITLEPAGE_BELL
	if state.shift == SHIFT_HALFTITLE:
		return HALFTITLE_BELL
	if state.shift == SHIFT_ENDPAPER:
		return ENDPAPER_BELL
	if state.shift == SHIFT_FLYLEAF:
		return FLYLEAF_BELL
	if state.shift == SHIFT_FRONTISPIECE:
		return FRONTISPIECE_BELL
	if state.shift == SHIFT_ERRATA:
		return ERRATA_BELL
	if state.shift == SHIFT_COLOPHON:
		return COLOPHON_BELL
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
	state.score_ignore_row = -1
	state.score_ignore_col = -1
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
	if rule == "double_lone_row" and row_fill_count(state, row) == 1:
		return amount * 2
	if rule == "double_short_column" and col_fill_count(state, col) == 2:
		return amount * 2
	if rule == "double_corner_later" and _corners_earlier_without_side(state, row, col):
		return amount * 2
	if rule == "double_next_empty" and _next_cell_empty(state, row, col):
		return amount * 2
	if rule == "double_corner_cell" and _is_corner(row, col):
		return amount * 2
	if rule == "yield_middle_pay" and row == 1:
		return amount + 2
	if rule == "double_prior_empty" and _prev_cell_empty(state, row, col):
		return amount * 2
	if rule == "double_edge_middle" and _is_edge_middle(row, col):
		return amount * 2
	if rule == "yield_top_pay" and row == 0:
		return amount + 2
	if rule == "double_both_blank" and _prev_cell_empty(state, row, col) and _next_cell_empty(state, row, col):
		return amount * 2
	if rule == "double_plus_cell" and _is_plus_cell(row, col):
		return amount * 2
	if rule == "yield_bottom_pay" and row == 2:
		return amount + 2
	if rule == "double_end_blank" and _end_blank(state, row, col):
		return amount * 2
	if rule == "yield_frame_pay" and _is_corner(row, col):
		return amount + 2
	if rule == "yield_lane_pay" and col == 1:
		return amount + 2
	if rule == "double_skip_blank" and _skip_blank(state, row, col):
		return amount * 2
	if rule == "yield_wing_pay" and _is_wing_cell(row, col):
		return amount + 2
	if rule == "yield_gutter_pay" and col == 0:
		return amount + 2
	if rule == "double_skip_fill" and _skip_fill(state, row, col):
		return amount * 2
	if rule == "yield_post_pay" and col == 2:
		return amount + 2
	if rule == "yield_seam_pay" and orthogonal_count(state, row, col) > 0:
		return amount + 2
	if rule == "double_skip_gap" and _skip_gap(state, row, col):
		return amount * 2
	if rule == "yield_crown_pay" and row == 0 and col == 1:
		return amount + 2
	if rule == "yield_void_pay" and orthogonal_count(state, row, col) == 0:
		return amount + 2
	if rule == "double_far_blank" and _far_blank(state, row, col):
		return amount * 2
	if rule == "yield_heart_pay" and row == 1 and col == 1:
		return amount + 2
	if rule == "double_far_fill" and _far_fill(state, row, col):
		return amount * 2
	if rule == "yield_open_pay" and _untouched(state, row, col):
		return amount + 2
	if rule == "double_long_blank" and _long_blank(state, row, col):
		return amount * 2
	if rule == "double_farther_blank" and _farther_blank(state, row, col):
		return amount * 2
	if rule == "yield_rim_pay" and _is_edge_middle(row, col):
		return amount + 2
	if rule == "double_long_fill" and _long_fill(state, row, col):
		return amount * 2
	if rule == "double_farther_fill" and _farther_fill(state, row, col):
		return amount * 2
	if rule == "yield_mitre_pay" and _mitre_pay(state, row, col):
		return amount + 2
	if rule == "double_long_back" and _long_back(state, row, col):
		return amount * 2
	if rule == "double_near_blank" and _near_blank(state, row, col):
		return amount * 2
	if rule == "yield_brace_pay" and _brace_pay(state, row, col):
		return amount + 2
	if rule == "double_farther_back" and _farther_back(state, row, col):
		return amount * 2
	if rule == "double_near_fill" and _near_fill(state, row, col):
		return amount * 2
	if rule == "yield_twin_pay" and _twin_pay(state, row, col):
		return amount + 2
	if rule == "double_farther_gap" and _farther_gap(state, row, col):
		return amount * 2
	if rule == "double_step_fill" and _step_fill(state, row, col):
		return amount * 2
	if rule == "yield_trio_pay" and _trio_pay(state, row, col):
		return amount + 2
	if rule == "double_long_gap" and _long_gap(state, row, col):
		return amount * 2
	if rule == "double_leap_fill" and _leap_fill(state, row, col):
		return amount * 2
	if rule == "yield_quad_pay" and _quad_pay(state, row, col):
		return amount + 2
	if rule == "double_deep_gap" and _deep_gap(state, row, col):
		return amount * 2
	if rule == "double_pitch_fill" and _pitch_fill(state, row, col):
		return amount * 2
	if rule == "yield_single_pay" and _single_pay(state, row, col):
		return amount + 2
	if rule == "double_pitch_gap" and _pitch_gap(state, row, col):
		return amount * 2
	if rule == "double_reach_fill" and _reach_fill(state, row, col):
		return amount * 2
	if rule == "yield_pair_pay" and _pair_pay(state, row, col):
		return amount + 2
	if rule == "double_reach_gap" and _reach_gap(state, row, col):
		return amount * 2
	if rule == "double_leap_blank" and _leap_blank(state, row, col):
		return amount * 2
	if rule == "yield_slant_pay" and _slant_pay(state, row, col):
		return amount + 2
	if rule == "double_deep_back" and _deep_back(state, row, col):
		return amount * 2
	if rule == "double_pitch_blank" and _pitch_blank(state, row, col):
		return amount * 2
	if rule == "yield_wedge_pay" and _wedge_pay(state, row, col):
		return amount + 2
	if rule == "double_pitch_back" and _pitch_back(state, row, col):
		return amount * 2
	if rule == "double_reach_blank" and _reach_blank(state, row, col):
		return amount * 2
	if rule == "yield_apex_pay" and _apex_pay(state, row, col):
		return amount + 2
	if rule == "double_reach_back" and _reach_back(state, row, col):
		return amount * 2
	if rule == "double_pace_blank" and _pace_blank(state, row, col):
		return amount * 2
	if rule == "yield_vault_pay" and _vault_pay(state, row, col):
		return amount + 2
	if rule == "double_pace_back" and _pace_back(state, row, col):
		return amount * 2
	if rule == "double_pace_fill" and _pace_fill(state, row, col):
		return amount * 2
	if rule == "yield_bare_pay" and _bare_pay(state, row, col):
		return amount + 2
	if rule == "double_pace_gap" and _pace_gap(state, row, col):
		return amount * 2
	if rule == "double_twin_blank" and _twin_blank(state, row, col):
		return amount * 2
	if rule == "yield_flank_pay" and _flank_pay(state, row, col):
		return amount + 2
	if rule == "double_twin_fill" and _twin_fill(state, row, col):
		return amount * 2
	if rule == "double_skew_blank" and _skew_blank(state, row, col):
		return amount * 2
	if rule == "yield_hinge_pay" and _hinge_pay(state, row, col):
		return amount + 2
	if rule == "double_skew_fill" and _skew_fill(state, row, col):
		return amount * 2
	if rule == "double_stride_blank" and _stride_blank(state, row, col):
		return amount * 2
	if rule == "yield_bevel_pay" and _bevel_pay(state, row, col):
		return amount + 2
	if rule == "double_stride_fill" and _stride_fill(state, row, col):
		return amount * 2
	if rule == "double_helm_blank" and _helm_blank(state, row, col):
		return amount * 2
	if rule == "yield_chevron_pay" and _chevron_pay(state, row, col):
		return amount + 2
	if rule == "double_helm_fill" and _helm_fill(state, row, col):
		return amount * 2
	if rule == "double_bias_blank" and _bias_blank(state, row, col):
		return amount * 2
	if rule == "yield_trine_pay" and _trine_pay(state, row, col):
		return amount + 2
	if rule == "double_bias_fill" and _bias_fill(state, row, col):
		return amount * 2
	if rule == "double_full_fill" and _full_fill(state, row, col):
		return amount * 2
	if rule == "yield_clasp_pay" and _clasp_pay(state, row, col):
		return amount + 2
	if rule == "double_full_blank" and _full_blank(state, row, col):
		return amount * 2
	if rule == "double_yoke_fill" and _yoke_fill(state, row, col):
		return amount * 2
	if rule == "yield_hasp_pay" and _hasp_pay(state, row, col):
		return amount + 2
	if rule == "double_peg_fill" and _peg_fill(state, row, col):
		return amount * 2
	if rule == "yield_bolt_pay" and _bolt_pay(state, row, col):
		return amount + 2
	if rule == "double_peg_blank" and _peg_blank(state, row, col):
		return amount * 2
	if rule == "double_hitch_fill" and _hitch_fill(state, row, col):
		return amount * 2
	if rule == "yield_pin_pay" and _pin_pay(state, row, col):
		return amount + 2
	if rule == "double_hitch_blank" and _hitch_blank(state, row, col):
		return amount * 2
	if rule == "double_bight_fill" and _bight_fill(state, row, col):
		return amount * 2
	if rule == "yield_brad_pay" and _brad_pay(state, row, col):
		return amount + 2
	if rule == "double_bight_blank" and _bight_blank(state, row, col):
		return amount * 2
	if rule == "double_crook_fill" and _crook_fill(state, row, col):
		return amount * 2
	if rule == "yield_rivet_pay" and _rivet_pay(state, row, col):
		return amount + 2
	if rule == "double_crook_blank" and _crook_blank(state, row, col):
		return amount * 2
	if rule == "double_bend_fill" and _bend_fill(state, row, col):
		return amount * 2
	if rule == "yield_clinch_pay" and _clinch_pay(state, row, col):
		return amount + 2
	if rule == "double_bend_blank" and _bend_blank(state, row, col):
		return amount * 2
	if rule == "double_kink_fill" and _kink_fill(state, row, col):
		return amount * 2
	if rule == "yield_clench_pay" and _clench_pay(state, row, col):
		return amount + 2
	if rule == "double_nick_fill" and _nick_fill(state, row, col):
		return amount * 2
	if rule == "yield_stake_pay" and _stake_pay(state, row, col):
		return amount + 2
	if rule == "double_arris_fill" and _arris_fill(state, row, col):
		return amount * 2
	if rule == "yield_rove_pay" and _rove_pay(state, row, col):
		return amount + 2
	if rule == "double_arris_blank" and _arris_blank(state, row, col):
		return amount * 2
	if rule == "double_feather_fill" and _feather_fill(state, row, col):
		return amount * 2
	if rule == "yield_staple_pay" and _staple_pay(state, row, col):
		return amount + 2
	if rule == "double_feather_blank" and _feather_blank(state, row, col):
		return amount * 2
	if rule == "double_plow_fill" and _plow_fill(state, row, col):
		return amount * 2
	if rule == "yield_lag_pay" and _lag_pay(state, row, col):
		return amount + 2
	if rule == "double_plow_blank" and _plow_blank(state, row, col):
		return amount * 2
	if rule == "double_dado_fill" and _dado_fill(state, row, col):
		return amount * 2
	if rule == "yield_screw_pay" and _screw_pay(state, row, col):
		return amount + 2
	if rule == "double_dado_blank" and _dado_blank(state, row, col):
		return amount * 2
	if rule == "double_rebate_fill" and _rebate_fill(state, row, col):
		return amount * 2
	if rule == "yield_nut_pay" and _nut_pay(state, row, col):
		return amount + 2
	if rule == "double_rebate_blank" and _rebate_blank(state, row, col):
		return amount * 2
	if rule == "double_chase_fill" and _chase_fill(state, row, col):
		return amount * 2
	if rule == "yield_washer_pay" and _washer_pay(state, row, col):
		return amount + 2
	if rule == "double_chase_blank" and _chase_blank(state, row, col):
		return amount * 2
	if rule == "double_rut_fill" and _rut_fill(state, row, col):
		return amount * 2
	if rule == "yield_stud_pay" and _stud_pay(state, row, col):
		return amount + 2
	if rule == "double_rut_blank" and _rut_blank(state, row, col):
		return amount * 2
	if rule == "double_furrow_fill" and _furrow_fill(state, row, col):
		return amount * 2
	if rule == "yield_spike_pay" and _spike_pay(state, row, col):
		return amount + 2
	if rule == "double_furrow_blank" and _furrow_blank(state, row, col):
		return amount * 2
	if rule == "double_groove_fill" and _groove_fill(state, row, col):
		return amount * 2
	if rule == "yield_sprig_pay" and _sprig_pay(state, row, col):
		return amount + 2
	if rule == "double_groove_blank" and _groove_blank(state, row, col):
		return amount * 2
	if rule == "double_flute_fill" and _flute_fill(state, row, col):
		return amount * 2
	if rule == "yield_tack_pay" and _tack_pay(state, row, col):
		return amount + 2
	if rule == "double_flute_blank" and _flute_blank(state, row, col):
		return amount * 2
	if rule == "double_wave_fill" and _wave_fill(state, row, col):
		return amount * 2
	if rule == "yield_nail_pay" and _nail_pay(state, row, col):
		return amount + 2
	if rule == "double_wave_blank" and _wave_blank(state, row, col):
		return amount * 2
	if rule == "double_crimp_fill" and _crimp_fill(state, row, col):
		return amount * 2
	if rule == "yield_cotter_pay" and _cotter_pay(state, row, col):
		return amount + 2
	if rule == "double_crimp_blank" and _crimp_blank(state, row, col):
		return amount * 2
	if rule == "double_hook_fill" and _hook_fill(state, row, col):
		return amount * 2
	if rule == "yield_set_pay" and _set_pay(state, row, col):
		return amount + 2
	if rule == "double_hook_blank" and _hook_blank(state, row, col):
		return amount * 2
	if rule == "double_jog_fill" and _jog_fill(state, row, col):
		return amount * 2
	if rule == "yield_peen_pay" and _peen_pay(state, row, col):
		return amount + 2
	if rule == "double_jog_blank" and _jog_blank(state, row, col):
		return amount * 2
	if rule == "double_nick_blank" and _nick_blank(state, row, col):
		return amount * 2
	if rule == "double_kink_blank" and _kink_blank(state, row, col):
		return amount * 2
	if rule == "double_yoke_blank" and _yoke_blank(state, row, col):
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
		elif rule == "drop_if_exact_nine" and _stamp_count(state) == 9:
			loss = 2
		elif rule == "drop_if_odd_count" and _stamp_count(state) % 2 == 1:
			loss = 2
		elif rule == "drop_if_even_count" and _stamp_count(state) % 2 == 0:
			loss = 2
		elif rule == "drop_if_prime_count" and _is_prime_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_square_count" and _is_square_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_triad_count" and _stamp_count(state) % 3 == 0:
			loss = 2
		elif rule == "drop_if_high_count" and _is_high_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_low_count" and _is_low_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_cube_count" and _is_cube_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_short_count" and _is_short_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_composite_count" and _is_composite_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_power_count" and _is_power_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_mid_count" and _is_mid_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_outer_count" and _is_outer_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_span_count" and _is_span_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_band_count" and _is_band_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_crest_count" and _is_crest_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_peak_count" and _is_peak_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_sill_count" and _is_sill_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_ridge_count" and _is_ridge_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_ledge_count" and _is_ledge_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_brow_count" and _is_brow_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_cleft_count" and _is_cleft_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_notch_count" and _is_notch_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_rift_count" and _is_rift_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_split_count" and _is_split_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_stride_count" and _is_stride_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_helm_count" and _is_helm_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_gauge_count" and _is_gauge_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_latch_count" and _is_latch_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_burin_count" and _is_burin_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_graver_count" and _is_graver_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_scribe_count" and _is_scribe_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_prick_count" and _is_prick_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_punch_count" and _is_punch_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_die_count" and _is_die_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_tap_count" and _is_tap_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_bit_count" and _is_bit_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_awl_count" and _is_awl_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_gimlet_count" and _is_gimlet_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_auger_count" and _is_auger_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_countersink_count" and _is_countersink_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_drift_count" and _is_drift_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_broach_count" and _is_broach_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_chamfer_count" and _is_chamfer_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_burr_count" and _is_burr_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_ream_count" and _is_ream_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_kerf_count" and _is_kerf_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_gouge_count" and _is_gouge_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_gash_count" and _is_gash_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_dent_count" and _is_dent_count(_stamp_count(state)):
			loss = 2
		elif rule == "drop_if_fork_count" and _is_fork_count(_stamp_count(state)):
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
	copy.score_ignore_row = state.score_ignore_row
	copy.score_ignore_col = state.score_ignore_col
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
			elif tail_rule == "double_lone_row" and row_fill_count(state, row) == 1 and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The lone row doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_short_column" and col_fill_count(state, col) == 2 and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The short column doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_corner_later" and _corners_earlier_without_side(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The later shared corner doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_next_empty" and _next_cell_empty(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell after it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_corner_cell" and _is_corner(row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The corner cell doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_middle_pay" and row == 1 and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The middle row pays +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_prior_empty" and _prev_cell_empty(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The blank cell before it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_edge_middle" and _is_edge_middle(row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The edge-middle cell doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_top_pay" and row == 0 and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The top row pays +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_both_blank" and _prev_cell_empty(state, row, col) and _next_cell_empty(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Both neighboring cells are empty, so it doubles." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_plus_cell" and _is_plus_cell(row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The plus cell doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_bottom_pay" and row == 2 and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The bottom row pays +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_end_blank" and _end_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Every immediate neighbor it has is empty, so it doubles." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_frame_pay" and _is_corner(row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The corner pays +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_lane_pay" and col == 1 and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The middle column pays +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_skip_blank" and _skip_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell two places before it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_wing_pay" and _is_wing_cell(row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The wing pays +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_gutter_pay" and col == 0 and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Column 1 pays +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_skip_fill" and _skip_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell two places before it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_post_pay" and col == 2 and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Column 3 pays +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_seam_pay" and orthogonal_count(state, row, col) > 0 and amount > raw:
				_log(state, "%s on the %s, %s grants %d. A shared side pays +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_skip_gap" and _skip_gap(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell two places after it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_crown_pay" and row == 0 and col == 1 and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The top middle pays +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_void_pay" and orthogonal_count(state, row, col) == 0 and amount > raw:
				_log(state, "%s on the %s, %s grants %d. No shared side pays +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_far_blank" and _far_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell three places after it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_heart_pay" and row == 1 and col == 1 and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The center pays +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_far_fill" and _far_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell three places after it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_open_pay" and _untouched(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. No shared side or corner pays +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_long_blank" and _long_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell four places after it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_farther_blank" and _farther_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell five places after it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_rim_pay" and _is_edge_middle(row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The edge-middle cell pays +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_long_fill" and _long_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell four places after it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_farther_fill" and _farther_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell five places after it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_mitre_pay" and _mitre_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. A corner neighbor and no side neighbor pays +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_long_back" and _long_back(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell four places before it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_near_blank" and _near_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell three places before it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_brace_pay" and _brace_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. A side neighbor and a corner neighbor pay +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_farther_back" and _farther_back(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell five places before it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_near_fill" and _near_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell three places before it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_twin_pay" and _twin_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Two side neighbors pay +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_farther_gap" and _farther_gap(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell five places before it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_step_fill" and _step_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell two places after it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_trio_pay" and _trio_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Three side neighbors pay +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_long_gap" and _long_gap(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell four places before it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_leap_fill" and _leap_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell six places after it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_quad_pay" and _quad_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Four side neighbors pay +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_deep_gap" and _deep_gap(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell six places before it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_pitch_fill" and _pitch_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell seven places after it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_single_pay" and _single_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. One side neighbor pays +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_pitch_gap" and _pitch_gap(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell seven places before it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_reach_fill" and _reach_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell eight places after it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_pair_pay" and _pair_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Two side neighbors pay +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_reach_gap" and _reach_gap(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell eight places before it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_leap_blank" and _leap_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell six places after it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_slant_pay" and _slant_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. One corner neighbor pays +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_deep_back" and _deep_back(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell six places before it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_pitch_blank" and _pitch_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell seven places after it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_wedge_pay" and _wedge_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Two corner neighbors pay +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_pitch_back" and _pitch_back(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell seven places before it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_reach_blank" and _reach_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell eight places after it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_apex_pay" and _apex_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Three corner neighbors pay +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_reach_back" and _reach_back(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell eight places before it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_pace_blank" and _pace_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell one place after it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_vault_pay" and _vault_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Four corner neighbors pay +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_pace_back" and _pace_back(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell one place before it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_pace_fill" and _pace_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell one place after it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_bare_pay" and _bare_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. No corner neighbors pay +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_pace_gap" and _pace_gap(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell one place before it doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_twin_blank" and _twin_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cells one place before and after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_flank_pay" and _flank_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. One side neighbor pays +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_twin_fill" and _twin_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cells one place before and after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_skew_blank" and _skew_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell one place before it and the empty cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_hinge_pay" and _hinge_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. One side neighbor and one corner neighbor pay +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_skew_fill" and _skew_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell one place before it and the filled cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_stride_blank" and _stride_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell two places before it and the empty cell two places after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_bevel_pay" and _bevel_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Two corner neighbors and one side neighbor pay +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_stride_fill" and _stride_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell two places before it and the filled cell two places after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_helm_blank" and _helm_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell three places before it and the empty cell three places after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_chevron_pay" and _chevron_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Two corner neighbors and no side neighbor pay +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_helm_fill" and _helm_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell three places before it and the filled cell three places after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_bias_blank" and _bias_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell four places before it and the empty cell four places after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_trine_pay" and _trine_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Three corner neighbors and no side neighbor pay +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_bias_fill" and _bias_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell four places before it and the filled cell four places after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_full_fill" and _full_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell four places before it and the filled cell four places after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_clasp_pay" and _clasp_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Three corner neighbors and one side neighbor pay +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_full_blank" and _full_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell four places before it and the empty cell four places after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_yoke_fill" and _yoke_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell three places before it and the filled cell three places after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_hasp_pay" and _hasp_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Three corner neighbors and two side neighbors pay +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_peg_fill" and _peg_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell two places before it and the filled cell two places after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_bolt_pay" and _bolt_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Three corner neighbors and three side neighbors pay +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_peg_blank" and _peg_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell two places before it and the empty cell two places after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_yoke_blank" and _yoke_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell three places before it and the empty cell three places after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_hitch_fill" and _hitch_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell two places before it and the filled cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_pin_pay" and _pin_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Three corner neighbors and four side neighbors pay +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_hitch_blank" and _hitch_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell two places before it and the empty cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_bight_fill" and _bight_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell three places before it and the filled cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_brad_pay" and _brad_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Four corner neighbors and one side neighbor pay +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_bight_blank" and _bight_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell three places before it and the empty cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_crook_fill" and _crook_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell four places before it and the filled cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_rivet_pay" and _rivet_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Four corner neighbors and two side neighbors pay +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_crook_blank" and _crook_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell four places before it and the empty cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_bend_fill" and _bend_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell five places before it and the filled cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_clinch_pay" and _clinch_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Four corner neighbors and three side neighbors pay +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_bend_blank" and _bend_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell five places before it and the empty cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_kink_fill" and _kink_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell six places before it and the filled cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_clench_pay" and _clench_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Four corner neighbors and four side neighbors pay +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_kink_blank" and _kink_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell six places before it and the empty cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_nick_fill" and _nick_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell seven places before it and the filled cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_stake_pay" and _stake_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Four corner neighbors and five side neighbors pay +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_nick_blank" and _nick_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell seven places before it and the empty cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_arris_fill" and _arris_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell twenty-one places before it and the filled cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_rove_pay" and _rove_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Four corner neighbors and nineteen side neighbors pay +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_arris_blank" and _arris_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell twenty-one places before it and the empty cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_feather_fill" and _feather_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell twenty places before it and the filled cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_staple_pay" and _staple_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Four corner neighbors and eighteen side neighbors pay +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_feather_blank" and _feather_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell twenty places before it and the empty cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_plow_fill" and _plow_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell nineteen places before it and the filled cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_lag_pay" and _lag_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Four corner neighbors and seventeen side neighbors pay +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_plow_blank" and _plow_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell nineteen places before it and the empty cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_dado_fill" and _dado_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell eighteen places before it and the filled cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_screw_pay" and _screw_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Four corner neighbors and sixteen side neighbors pay +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_dado_blank" and _dado_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell eighteen places before it and the empty cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_rebate_fill" and _rebate_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell seventeen places before it and the filled cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_nut_pay" and _nut_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Four corner neighbors and fifteen side neighbors pay +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_rebate_blank" and _rebate_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell seventeen places before it and the empty cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_chase_fill" and _chase_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell sixteen places before it and the filled cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_washer_pay" and _washer_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Four corner neighbors and fourteen side neighbors pay +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_chase_blank" and _chase_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell sixteen places before it and the empty cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_rut_fill" and _rut_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell fifteen places before it and the filled cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_stud_pay" and _stud_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Four corner neighbors and thirteen side neighbors pay +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_rut_blank" and _rut_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell fifteen places before it and the empty cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_furrow_fill" and _furrow_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell fourteen places before it and the filled cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_spike_pay" and _spike_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Four corner neighbors and twelve side neighbors pay +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_furrow_blank" and _furrow_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell fourteen places before it and the empty cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_groove_fill" and _groove_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell thirteen places before it and the filled cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_sprig_pay" and _sprig_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Four corner neighbors and eleven side neighbors pay +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_groove_blank" and _groove_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell thirteen places before it and the empty cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_flute_fill" and _flute_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell twelve places before it and the filled cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_tack_pay" and _tack_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Four corner neighbors and ten side neighbors pay +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_flute_blank" and _flute_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell twelve places before it and the empty cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_wave_fill" and _wave_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell eleven places before it and the filled cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_nail_pay" and _nail_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Four corner neighbors and nine side neighbors pay +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_wave_blank" and _wave_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell eleven places before it and the empty cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_crimp_fill" and _crimp_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell ten places before it and the filled cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_cotter_pay" and _cotter_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Four corner neighbors and eight side neighbors pay +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_crimp_blank" and _crimp_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell ten places before it and the empty cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_hook_fill" and _hook_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell nine places before it and the filled cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_set_pay" and _set_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Four corner neighbors and seven side neighbors pay +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_hook_blank" and _hook_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell nine places before it and the empty cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_jog_fill" and _jog_fill(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The filled cell eight places before it and the filled cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "yield_peen_pay" and _peen_pay(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. Four corner neighbors and six side neighbors pay +2." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			elif tail_rule == "double_jog_blank" and _jog_blank(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The empty cell eight places before it and the empty cell one place after it double it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
			else:
				_log(state, "%s on the %s, %s grants %d." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
	state.turn_progress += amount
	for cell in _retrigger_cells(card_id, row, col):
		_try_retrigger(state, cell.x, cell.y, hush, row, col)


static func _try_retrigger(state: NightState, row: int, col: int, hush: bool, source_row: int = -1, source_col: int = -1) -> void:
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
	var saved_row := state.score_ignore_row
	var saved_col := state.score_ignore_col
	state.score_ignore_row = source_row
	state.score_ignore_col = source_col
	_resolve_stamp(state, row, col, hush)
	state.score_ignore_row = saved_row
	state.score_ignore_col = saved_col


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


static func _is_plus_cell(row: int, col: int) -> bool:
	return (row == 1 and col == 1) or _is_edge_middle(row, col)


static func _is_prime_count(count: int) -> bool:
	return count == 2 or count == 3 or count == 5 or count == 7


static func _is_square_count(count: int) -> bool:
	return count == 0 or count == 1 or count == 4 or count == 9


static func _skip_blank(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 2
	if back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] == null


static func _is_high_count(count: int) -> bool:
	return count == 7 or count == 8 or count == 9


static func _is_low_count(count: int) -> bool:
	return count <= 2


static func _is_cube_count(count: int) -> bool:
	return count == 1 or count == 8


static func _is_short_count(count: int) -> bool:
	return count == 1 or count == 2


static func _is_composite_count(count: int) -> bool:
	return count == 4 or count == 6 or count == 8 or count == 9


static func _is_power_count(count: int) -> bool:
	return count == 1 or count == 2 or count == 4 or count == 8


static func _is_mid_count(count: int) -> bool:
	return count == 3 or count == 4 or count == 5 or count == 6


static func _is_outer_count(count: int) -> bool:
	return count == 0 or count == 9


static func _is_span_count(count: int) -> bool:
	return count == 5 or count == 6


static func _near_fill(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 3
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] != null


static func _twin_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var sides := 0
	for delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
		var side_row = row + delta.x
		var side_col = col + delta.y
		if side_row < 0 or side_col < 0 or side_row > 2 or side_col > 2:
			continue
		if side_row == state.score_ignore_row and side_col == state.score_ignore_col:
			continue
		if state.form[side_row][side_col] != null:
			sides += 1
	return sides >= 2


static func _is_band_count(count: int) -> bool:
	return count == 4 or count == 5


static func _is_crest_count(count: int) -> bool:
	return count == 6 or count == 7


static func _leap_fill(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var ahead_row := row
	var ahead_col := col + 6
	while ahead_col > 2:
		ahead_row += 1
		ahead_col -= 3
	if ahead_row > 2:
		return false
	return state.form[ahead_row][ahead_col] != null


static func _quad_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var sides := 0
	for delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
		var side_row = row + delta.x
		var side_col = col + delta.y
		if side_row < 0 or side_col < 0 or side_row > 2 or side_col > 2:
			continue
		if state.form[side_row][side_col] != null:
			sides += 1
	return sides == 4


static func _deep_gap(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 6
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] == null


static func _is_peak_count(count: int) -> bool:
	return count == 8 or count == 9


static func _pitch_fill(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var ahead_row := row
	var ahead_col := col + 7
	while ahead_col > 2:
		ahead_row += 1
		ahead_col -= 3
	if ahead_row > 2:
		return false
	return state.form[ahead_row][ahead_col] != null


static func _single_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var sides := 0
	for delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
		var side_row = row + delta.x
		var side_col = col + delta.y
		if side_row < 0 or side_col < 0 or side_row > 2 or side_col > 2:
			continue
		if state.form[side_row][side_col] != null:
			sides += 1
	return sides == 1


static func _pitch_gap(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 7
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] == null


static func _is_sill_count(count: int) -> bool:
	return count == 0 or count == 1


static func _reach_fill(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var ahead_row := row
	var ahead_col := col + 8
	while ahead_col > 2:
		ahead_row += 1
		ahead_col -= 3
	if ahead_row > 2:
		return false
	return state.form[ahead_row][ahead_col] != null


static func _pair_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var sides := 0
	for delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
		var side_row = row + delta.x
		var side_col = col + delta.y
		if side_row < 0 or side_col < 0 or side_row > 2 or side_col > 2:
			continue
		if state.form[side_row][side_col] != null:
			sides += 1
	return sides == 2


static func _is_ridge_count(count: int) -> bool:
	return count == 2 or count == 3


static func _leap_blank(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var ahead_row := row
	var ahead_col := col + 6
	while ahead_col > 2:
		ahead_row += 1
		ahead_col -= 3
	if ahead_row > 2:
		return false
	return state.form[ahead_row][ahead_col] == null


static func _slant_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	return _diagonal_count(state, row, col) == 1


static func _is_ledge_count(count: int) -> bool:
	return count == 3 or count == 4


static func _pitch_blank(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var ahead_row := row
	var ahead_col := col + 7
	while ahead_col > 2:
		ahead_row += 1
		ahead_col -= 3
	if ahead_row > 2:
		return false
	return state.form[ahead_row][ahead_col] == null


static func _wedge_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	return _diagonal_count(state, row, col) == 2


static func _is_burin_count(count: int) -> bool:
	return count == 27 or count == 30


static func _arris_fill(state: NightState, row: int, col: int) -> bool:
	return _twenty_one_back(state, row, col) and _pace_fill(state, row, col)


static func _rove_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	return orthogonal_count(state, row, col) == 19 and _diagonal_count(state, row, col) == 4


static func _arris_blank(state: NightState, row: int, col: int) -> bool:
	return _twenty_one_gap(state, row, col) and _pace_blank(state, row, col)


static func _twenty_one_back(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 21
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] != null


static func _twenty_one_gap(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 21
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] == null


static func _is_graver_count(count: int) -> bool:
	return count == 26 or count == 29


static func _feather_fill(state: NightState, row: int, col: int) -> bool:
	return _twenty_back(state, row, col) and _pace_fill(state, row, col)


static func _staple_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	return orthogonal_count(state, row, col) == 18 and _diagonal_count(state, row, col) == 4


static func _feather_blank(state: NightState, row: int, col: int) -> bool:
	return _twenty_gap(state, row, col) and _pace_blank(state, row, col)


static func _twenty_back(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 20
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] != null


static func _twenty_gap(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 20
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] == null


static func _is_scribe_count(count: int) -> bool:
	return count == 25 or count == 28


static func _plow_fill(state: NightState, row: int, col: int) -> bool:
	return _nineteen_back(state, row, col) and _pace_fill(state, row, col)


static func _lag_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	return orthogonal_count(state, row, col) == 17 and _diagonal_count(state, row, col) == 4


static func _plow_blank(state: NightState, row: int, col: int) -> bool:
	return _nineteen_gap(state, row, col) and _pace_blank(state, row, col)


static func _nineteen_back(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 19
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] != null


static func _nineteen_gap(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 19
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] == null


static func _is_prick_count(count: int) -> bool:
	return count == 21 or count == 24


static func _dado_fill(state: NightState, row: int, col: int) -> bool:
	return _eighteen_back(state, row, col) and _pace_fill(state, row, col)


static func _screw_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	return orthogonal_count(state, row, col) == 16 and _diagonal_count(state, row, col) == 4


static func _dado_blank(state: NightState, row: int, col: int) -> bool:
	return _eighteen_gap(state, row, col) and _pace_blank(state, row, col)


static func _eighteen_back(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 18
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] != null


static func _eighteen_gap(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 18
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] == null


static func _is_punch_count(count: int) -> bool:
	return count == 20 or count == 23


static func _rebate_fill(state: NightState, row: int, col: int) -> bool:
	return _seventeen_back(state, row, col) and _pace_fill(state, row, col)


static func _nut_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	return orthogonal_count(state, row, col) == 15 and _diagonal_count(state, row, col) == 4


static func _rebate_blank(state: NightState, row: int, col: int) -> bool:
	return _seventeen_gap(state, row, col) and _pace_blank(state, row, col)


static func _seventeen_back(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 17
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] != null


static func _seventeen_gap(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 17
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] == null


static func _is_die_count(count: int) -> bool:
	return count == 19 or count == 22


static func _chase_fill(state: NightState, row: int, col: int) -> bool:
	return _sixteen_back(state, row, col) and _pace_fill(state, row, col)


static func _washer_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	return orthogonal_count(state, row, col) == 14 and _diagonal_count(state, row, col) == 4


static func _chase_blank(state: NightState, row: int, col: int) -> bool:
	return _sixteen_gap(state, row, col) and _pace_blank(state, row, col)


static func _sixteen_back(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 16
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] != null


static func _sixteen_gap(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 16
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] == null


static func _is_tap_count(count: int) -> bool:
	return count == 15 or count == 18


static func _rut_fill(state: NightState, row: int, col: int) -> bool:
	return _fifteen_back(state, row, col) and _pace_fill(state, row, col)


static func _stud_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	return orthogonal_count(state, row, col) == 13 and _diagonal_count(state, row, col) == 4


static func _rut_blank(state: NightState, row: int, col: int) -> bool:
	return _fifteen_gap(state, row, col) and _pace_blank(state, row, col)


static func _fifteen_back(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 15
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] != null


static func _fifteen_gap(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 15
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] == null


static func _is_bit_count(count: int) -> bool:
	return count == 14 or count == 17


static func _furrow_fill(state: NightState, row: int, col: int) -> bool:
	return _fourteen_back(state, row, col) and _pace_fill(state, row, col)


static func _spike_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	return orthogonal_count(state, row, col) == 12 and _diagonal_count(state, row, col) == 4


static func _furrow_blank(state: NightState, row: int, col: int) -> bool:
	return _fourteen_gap(state, row, col) and _pace_blank(state, row, col)


static func _fourteen_back(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 14
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] != null


static func _fourteen_gap(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 14
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] == null


static func _is_awl_count(count: int) -> bool:
	return count == 13 or count == 16


static func _groove_fill(state: NightState, row: int, col: int) -> bool:
	return _thirteen_back(state, row, col) and _pace_fill(state, row, col)


static func _sprig_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	return orthogonal_count(state, row, col) == 11 and _diagonal_count(state, row, col) == 4


static func _groove_blank(state: NightState, row: int, col: int) -> bool:
	return _thirteen_gap(state, row, col) and _pace_blank(state, row, col)


static func _thirteen_back(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 13
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] != null


static func _thirteen_gap(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 13
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] == null


static func _is_gimlet_count(count: int) -> bool:
	return count == 12 or count == 15


static func _flute_fill(state: NightState, row: int, col: int) -> bool:
	return _twelve_back(state, row, col) and _pace_fill(state, row, col)


static func _tack_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	return orthogonal_count(state, row, col) == 10 and _diagonal_count(state, row, col) == 4


static func _flute_blank(state: NightState, row: int, col: int) -> bool:
	return _twelve_gap(state, row, col) and _pace_blank(state, row, col)


static func _twelve_back(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 12
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] != null


static func _twelve_gap(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 12
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] == null


static func _is_auger_count(count: int) -> bool:
	return count == 11 or count == 14


static func _wave_fill(state: NightState, row: int, col: int) -> bool:
	return _eleven_back(state, row, col) and _pace_fill(state, row, col)


static func _nail_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	return orthogonal_count(state, row, col) == 9 and _diagonal_count(state, row, col) == 4


static func _wave_blank(state: NightState, row: int, col: int) -> bool:
	return _eleven_gap(state, row, col) and _pace_blank(state, row, col)


static func _eleven_back(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 11
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] != null


static func _eleven_gap(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 11
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] == null


static func _is_countersink_count(count: int) -> bool:
	return count == 10 or count == 13


static func _crimp_fill(state: NightState, row: int, col: int) -> bool:
	return _decade_back(state, row, col) and _pace_fill(state, row, col)


static func _cotter_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	return orthogonal_count(state, row, col) == 8 and _diagonal_count(state, row, col) == 4


static func _crimp_blank(state: NightState, row: int, col: int) -> bool:
	return _decade_gap(state, row, col) and _pace_blank(state, row, col)


static func _decade_back(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 10
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] != null


static func _decade_gap(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 10
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] == null


static func _is_drift_count(count: int) -> bool:
	return count == 9 or count == 12


static func _hook_fill(state: NightState, row: int, col: int) -> bool:
	return _span_back(state, row, col) and _pace_fill(state, row, col)


static func _set_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	return orthogonal_count(state, row, col) == 7 and _diagonal_count(state, row, col) == 4


static func _hook_blank(state: NightState, row: int, col: int) -> bool:
	return _span_gap(state, row, col) and _pace_blank(state, row, col)


static func _span_back(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 9
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] != null


static func _span_gap(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 9
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] == null


static func _is_broach_count(count: int) -> bool:
	return count == 8 or count == 11


static func _jog_fill(state: NightState, row: int, col: int) -> bool:
	return _reach_back(state, row, col) and _pace_fill(state, row, col)


static func _peen_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	return orthogonal_count(state, row, col) == 6 and _diagonal_count(state, row, col) == 4


static func _jog_blank(state: NightState, row: int, col: int) -> bool:
	return _reach_gap(state, row, col) and _pace_blank(state, row, col)


static func _is_chamfer_count(count: int) -> bool:
	return count == 7 or count == 10


static func _nick_fill(state: NightState, row: int, col: int) -> bool:
	return _pitch_back(state, row, col) and _pace_fill(state, row, col)


static func _stake_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	return orthogonal_count(state, row, col) == 5 and _diagonal_count(state, row, col) == 4


static func _nick_blank(state: NightState, row: int, col: int) -> bool:
	return _pitch_gap(state, row, col) and _pace_blank(state, row, col)


static func _is_burr_count(count: int) -> bool:
	return count == 6 or count == 9


static func _kink_fill(state: NightState, row: int, col: int) -> bool:
	return _deep_back(state, row, col) and _pace_fill(state, row, col)


static func _clench_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	return orthogonal_count(state, row, col) == 4 and _diagonal_count(state, row, col) == 4


static func _kink_blank(state: NightState, row: int, col: int) -> bool:
	return _deep_gap(state, row, col) and _pace_blank(state, row, col)


static func _is_ream_count(count: int) -> bool:
	return count == 5 or count == 8


static func _bend_fill(state: NightState, row: int, col: int) -> bool:
	return _farther_back(state, row, col) and _pace_fill(state, row, col)


static func _clinch_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	return orthogonal_count(state, row, col) == 3 and _diagonal_count(state, row, col) == 4


static func _bend_blank(state: NightState, row: int, col: int) -> bool:
	return _farther_gap(state, row, col) and _pace_blank(state, row, col)


static func _is_kerf_count(count: int) -> bool:
	return count == 4 or count == 7


static func _crook_fill(state: NightState, row: int, col: int) -> bool:
	return _long_back(state, row, col) and _pace_fill(state, row, col)


static func _rivet_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	return orthogonal_count(state, row, col) == 2 and _diagonal_count(state, row, col) == 4


static func _crook_blank(state: NightState, row: int, col: int) -> bool:
	return _long_gap(state, row, col) and _pace_blank(state, row, col)


static func _is_gouge_count(count: int) -> bool:
	return count == 3 or count == 6


static func _bight_fill(state: NightState, row: int, col: int) -> bool:
	return _near_fill(state, row, col) and _pace_fill(state, row, col)


static func _brad_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	return orthogonal_count(state, row, col) == 1 and _diagonal_count(state, row, col) == 4


static func _bight_blank(state: NightState, row: int, col: int) -> bool:
	return _near_blank(state, row, col) and _pace_blank(state, row, col)


static func _is_gash_count(count: int) -> bool:
	return count == 2 or count == 5


static func _hitch_fill(state: NightState, row: int, col: int) -> bool:
	return _skip_fill(state, row, col) and _pace_fill(state, row, col)


static func _pin_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	return orthogonal_count(state, row, col) == 4 and _diagonal_count(state, row, col) == 3


static func _hitch_blank(state: NightState, row: int, col: int) -> bool:
	return _skip_blank(state, row, col) and _pace_blank(state, row, col)


static func _is_dent_count(count: int) -> bool:
	return count == 1 or count == 4


static func _peg_fill(state: NightState, row: int, col: int) -> bool:
	return _skip_fill(state, row, col) and _step_fill(state, row, col)


static func _bolt_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	return orthogonal_count(state, row, col) == 3 and _diagonal_count(state, row, col) == 3


static func _peg_blank(state: NightState, row: int, col: int) -> bool:
	return _skip_blank(state, row, col) and _skip_gap(state, row, col)


static func _is_fork_count(count: int) -> bool:
	return count == 0 or count == 3


static func _yoke_fill(state: NightState, row: int, col: int) -> bool:
	return _near_fill(state, row, col) and _far_fill(state, row, col)


static func _hasp_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	return orthogonal_count(state, row, col) == 2 and _diagonal_count(state, row, col) == 3


static func _yoke_blank(state: NightState, row: int, col: int) -> bool:
	return _near_blank(state, row, col) and _far_blank(state, row, col)


static func _is_latch_count(count: int) -> bool:
	return count == 7 or count == 9


static func _full_fill(state: NightState, row: int, col: int) -> bool:
	return _long_back(state, row, col) and _long_fill(state, row, col)


static func _clasp_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	return orthogonal_count(state, row, col) == 1 and _diagonal_count(state, row, col) == 3


static func _full_blank(state: NightState, row: int, col: int) -> bool:
	return _long_gap(state, row, col) and _long_blank(state, row, col)


static func _is_gauge_count(count: int) -> bool:
	return count == 6 or count == 8


static func _bias_blank(state: NightState, row: int, col: int) -> bool:
	return _long_back(state, row, col) and _long_blank(state, row, col)


static func _trine_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	return orthogonal_count(state, row, col) == 0 and _diagonal_count(state, row, col) == 3


static func _bias_fill(state: NightState, row: int, col: int) -> bool:
	return _long_gap(state, row, col) and _long_fill(state, row, col)


static func _is_helm_count(count: int) -> bool:
	return count == 5 or count == 7


static func _helm_blank(state: NightState, row: int, col: int) -> bool:
	return _near_fill(state, row, col) and _far_blank(state, row, col)


static func _chevron_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	return orthogonal_count(state, row, col) == 0 and _diagonal_count(state, row, col) == 2


static func _helm_fill(state: NightState, row: int, col: int) -> bool:
	return _near_blank(state, row, col) and _far_fill(state, row, col)


static func _is_stride_count(count: int) -> bool:
	return count == 4 or count == 6


static func _stride_blank(state: NightState, row: int, col: int) -> bool:
	return _skip_fill(state, row, col) and _skip_gap(state, row, col)


static func _bevel_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	return orthogonal_count(state, row, col) == 1 and _diagonal_count(state, row, col) == 2


static func _stride_fill(state: NightState, row: int, col: int) -> bool:
	return _skip_blank(state, row, col) and _step_fill(state, row, col)


static func _is_split_count(count: int) -> bool:
	return count == 3 or count == 5


static func _skew_blank(state: NightState, row: int, col: int) -> bool:
	return _prev_cell_filled(state, row, col) and _next_cell_empty(state, row, col)


static func _hinge_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	return orthogonal_count(state, row, col) == 1 and _diagonal_count(state, row, col) == 1


static func _skew_fill(state: NightState, row: int, col: int) -> bool:
	return _prev_cell_empty(state, row, col) and _next_cell_filled(state, row, col)


static func _is_rift_count(count: int) -> bool:
	return count == 2 or count == 4


static func _twin_blank(state: NightState, row: int, col: int) -> bool:
	return _prev_cell_empty(state, row, col) and _next_cell_empty(state, row, col)


static func _flank_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	return orthogonal_count(state, row, col) == 1


static func _twin_fill(state: NightState, row: int, col: int) -> bool:
	return _prev_cell_filled(state, row, col) and _next_cell_filled(state, row, col)


static func _is_notch_count(count: int) -> bool:
	return count == 1 or count == 3


static func _pace_fill(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var ahead_row := row
	var ahead_col := col + 1
	while ahead_col > 2:
		ahead_row += 1
		ahead_col -= 3
	if ahead_row > 2:
		return false
	return state.form[ahead_row][ahead_col] != null


static func _bare_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	return _diagonal_count(state, row, col) == 0


static func _pace_gap(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 1
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] == null


static func _is_cleft_count(count: int) -> bool:
	return count == 0 or count == 2


static func _pace_blank(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var ahead_row := row
	var ahead_col := col + 1
	while ahead_col > 2:
		ahead_row += 1
		ahead_col -= 3
	if ahead_row > 2:
		return false
	return state.form[ahead_row][ahead_col] == null


static func _vault_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	return _diagonal_count(state, row, col) == 4


static func _pace_back(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 1
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] != null


static func _is_brow_count(count: int) -> bool:
	return count == 7 or count == 8


static func _reach_blank(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var ahead_row := row
	var ahead_col := col + 8
	while ahead_col > 2:
		ahead_row += 1
		ahead_col -= 3
	if ahead_row > 2:
		return false
	return state.form[ahead_row][ahead_col] == null


static func _apex_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	return _diagonal_count(state, row, col) == 3


static func _reach_back(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 8
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] != null


static func _pitch_back(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 7
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] != null


static func _deep_back(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 6
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] != null


static func _reach_gap(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 8
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] == null


static func _step_fill(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var ahead_row := row
	var ahead_col := col + 2
	if ahead_col > 2:
		ahead_row += 1
		ahead_col -= 3
	if ahead_row > 2:
		return false
	return state.form[ahead_row][ahead_col] != null


static func _trio_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var sides := 0
	for delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
		var side_row = row + delta.x
		var side_col = col + delta.y
		if side_row < 0 or side_col < 0 or side_row > 2 or side_col > 2:
			continue
		if state.form[side_row][side_col] != null:
			sides += 1
	return sides == 3


static func _long_gap(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 4
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] == null


static func _farther_gap(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 5
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] == null


static func _far_blank(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var ahead_row := row
	var ahead_col := col + 3
	if ahead_col > 2:
		ahead_row += 1
		ahead_col -= 3
	if ahead_row > 2:
		return false
	return state.form[ahead_row][ahead_col] == null


static func _far_fill(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var ahead_row := row
	var ahead_col := col + 3
	if ahead_col > 2:
		ahead_row += 1
		ahead_col -= 3
	if ahead_row > 2:
		return false
	return state.form[ahead_row][ahead_col] != null


static func _long_blank(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var ahead_row := row
	var ahead_col := col + 4
	while ahead_col > 2:
		ahead_row += 1
		ahead_col -= 3
	if ahead_row > 2:
		return false
	return state.form[ahead_row][ahead_col] == null


static func _farther_blank(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var ahead_row := row
	var ahead_col := col + 5
	while ahead_col > 2:
		ahead_row += 1
		ahead_col -= 3
	if ahead_row > 2:
		return false
	return state.form[ahead_row][ahead_col] == null


static func _farther_fill(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var ahead_row := row
	var ahead_col := col + 5
	while ahead_col > 2:
		ahead_row += 1
		ahead_col -= 3
	if ahead_row > 2:
		return false
	return state.form[ahead_row][ahead_col] != null


static func _long_back(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 4
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] != null


static func _mitre_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	return _diagonal_count(state, row, col) > 0 and orthogonal_count(state, row, col) == 0


static func _near_blank(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 3
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] == null


static func _brace_pay(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	return orthogonal_count(state, row, col) > 0 and _diagonal_count(state, row, col) > 0


static func _farther_back(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 5
	while back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] != null


static func _long_fill(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var ahead_row := row
	var ahead_col := col + 4
	while ahead_col > 2:
		ahead_row += 1
		ahead_col -= 3
	if ahead_row > 2:
		return false
	return state.form[ahead_row][ahead_col] != null


static func _untouched(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	return orthogonal_count(state, row, col) == 0 and _diagonal_count(state, row, col) == 0


static func _skip_gap(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var ahead_row := row
	var ahead_col := col + 2
	if ahead_col > 2:
		ahead_row += 1
		ahead_col -= 3
	if ahead_row > 2:
		return false
	return state.form[ahead_row][ahead_col] == null


static func _skip_fill(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	var back_row := row
	var back_col := col - 2
	if back_col < 0:
		back_row -= 1
		back_col += 3
	if back_row < 0:
		return false
	return state.form[back_row][back_col] != null


static func _is_wing_cell(row: int, col: int) -> bool:
	return row == 1 and col != 1


static func _end_blank(state: NightState, row: int, col: int) -> bool:
	if row < 0 or col < 0 or row > 2 or col > 2:
		return false
	if state.form[row][col] == null:
		return false
	if _prev_cell_filled(state, row, col):
		return false
	if _next_cell_filled(state, row, col):
		return false
	return true


static func _is_edge_middle(row: int, col: int) -> bool:
	if row == 1 and col != 1:
		return true
	if col == 1 and row != 1:
		return true
	return false


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


static func _next_cell_empty(state: NightState, row: int, col: int) -> bool:
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
	return state.form[next_row][next_col] == null


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


static func _prev_cell_empty(state: NightState, row: int, col: int) -> bool:
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
	return state.form[prev_row][prev_col] == null


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
			if state.shift == SHIFT_SEQUENCE:
				_log(state, "The queue is empty. The sequence bell is clear.")
			if state.shift == SHIFT_TRACT:
				_log(state, "The queue is empty. The tract bell is clear.")
			if state.shift == SHIFT_GRADUAL:
				_log(state, "The queue is empty. The gradual bell is clear.")
			if state.shift == SHIFT_INTROIT:
				_log(state, "The queue is empty. The introit bell is clear.")
			if state.shift == SHIFT_ANTIPHON:
				_log(state, "The queue is empty. The antiphon bell is clear.")
			if state.shift == SHIFT_REQUIEM:
				_log(state, "The queue is empty. The requiem bell is clear.")
			if state.shift == SHIFT_DIRGE:
				_log(state, "The queue is empty. The dirge bell is clear.")
			if state.shift == SHIFT_OCTAVE:
				_log(state, "The queue is empty. The octave bell is clear.")
			if state.shift == SHIFT_VIGIL:
				_log(state, "The queue is empty. The vigil bell is clear.")
			if state.shift == SHIFT_NONE:
				_log(state, "The queue is empty. The none bell is clear.")
			if state.shift == SHIFT_SEXT:
				_log(state, "The queue is empty. The sext bell is clear.")
			if state.shift == SHIFT_TERCE:
				_log(state, "The queue is empty. The terce bell is clear.")
			if state.shift == SHIFT_PRIME:
				_log(state, "The queue is empty. The prime bell is clear.")
			if state.shift == SHIFT_LAUDS:
				_log(state, "The queue is empty. The lauds bell is clear.")
			if state.shift == SHIFT_MATINS:
				_log(state, "The queue is empty. The matins bell is clear.")
			if state.shift == SHIFT_AUBADE:
				_log(state, "The queue is empty. The aubade bell is clear.")
			if state.shift == SHIFT_VESPERS:
				_log(state, "The queue is empty. The vespers bell is clear.")
			if state.shift == SHIFT_COMPLINE:
				_log(state, "The queue is empty. The compline bell is clear.")
			if state.shift == SHIFT_NOCTURNE:
				_log(state, "The queue is empty. The nocturne bell is clear.")
			if state.shift == SHIFT_RECESSIONAL:
				_log(state, "The queue is empty. The recessional bell is clear.")
			if state.shift == SHIFT_VALEDICTION:
				_log(state, "The queue is empty. The valediction bell is clear.")
			if state.shift == SHIFT_EPODE:
				_log(state, "The queue is empty. The epode bell is clear.")
			if state.shift == SHIFT_FINALE:
				_log(state, "The queue is empty. The finale bell is clear.")
			if state.shift == SHIFT_ENVOY:
				_log(state, "The queue is empty. The envoy bell is clear.")
			if state.shift == SHIFT_FINIS:
				_log(state, "The queue is empty. The finis bell is clear.")
			if state.shift == SHIFT_EXPLICIT:
				_log(state, "The queue is empty. The explicit bell is clear.")
			if state.shift == SHIFT_CODA:
				_log(state, "The queue is empty. The coda bell is clear.")
			if state.shift == SHIFT_EPILOGUE:
				_log(state, "The queue is empty. The epilogue bell is clear.")
			if state.shift == SHIFT_CORRIGENDA:
				_log(state, "The queue is empty. The corrigenda bell is clear.")
			if state.shift == SHIFT_ENVOI:
				_log(state, "The queue is empty. The envoi bell is clear.")
			if state.shift == SHIFT_ADDENDA:
				_log(state, "The queue is empty. The addenda bell is clear.")
			if state.shift == SHIFT_POSTSCRIPT:
				_log(state, "The queue is empty. The postscript bell is clear.")
			if state.shift == SHIFT_AFTERWORD:
				_log(state, "The queue is empty. The afterword bell is clear.")
			if state.shift == SHIFT_APPENDIX:
				_log(state, "The queue is empty. The appendix bell is clear.")
			if state.shift == SHIFT_GLOSSARY:
				_log(state, "The queue is empty. The glossary bell is clear.")
			if state.shift == SHIFT_ACKNOWLEDGMENTS:
				_log(state, "The queue is empty. The acknowledgments bell is clear.")
			if state.shift == SHIFT_PROLOGUE:
				_log(state, "The queue is empty. The prologue bell is clear.")
			if state.shift == SHIFT_INTRODUCTION:
				_log(state, "The queue is empty. The introduction bell is clear.")
			elif state.shift == SHIFT_CONTENTS:
				_log(state, "The queue is empty. The contents bell is clear.")
			elif state.shift == SHIFT_FOREWORD:
				_log(state, "The queue is empty. The foreword bell is clear.")
			elif state.shift == SHIFT_PREFACE:
				_log(state, "The queue is empty. The preface bell is clear.")
			elif state.shift == SHIFT_EPIGRAPH:
				_log(state, "The queue is empty. The epigraph bell is clear.")
			elif state.shift == SHIFT_DEDICATION:
				_log(state, "The queue is empty. The dedication bell is clear.")
			elif state.shift == SHIFT_COPYRIGHT:
				_log(state, "The queue is empty. The copyright bell is clear.")
			elif state.shift == SHIFT_TITLEPAGE:
				_log(state, "The queue is empty. The title-page bell is clear.")
			elif state.shift == SHIFT_HALFTITLE:
				_log(state, "The queue is empty. The half-title bell is clear.")
			elif state.shift == SHIFT_ENDPAPER:
				_log(state, "The queue is empty. The endpaper bell is clear.")
			elif state.shift == SHIFT_FLYLEAF:
				_log(state, "The queue is empty. The flyleaf bell is clear.")
			elif state.shift == SHIFT_FRONTISPIECE:
				_log(state, "The queue is empty. The frontispiece bell is clear.")
			elif state.shift == SHIFT_ERRATA:
				_log(state, "The queue is empty. The errata bell is clear.")
			elif state.shift == SHIFT_COLOPHON:
				_log(state, "The queue is empty. The colophon bell is clear.")
			elif state.shift == SHIFT_CATCHWORD:
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
