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
	if state.shift == SHIFT_VELLUM:
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
	if rule == "ignore_shared_row" and row_fill_count(state, row) > 1:
		return 0
	if rule == "double_last" and _is_queue_tail(state, row, col):
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
			elif rule == "ignore_shared_row" and row_fill_count(state, row) > 1:
				_log(state, "%s ignores %s because the row is shared." % [traveler(state)["name"], CARDS[card_id]["name"]])
			elif rule == "ignore_isolated":
				_log(state, "%s ignores the lone %s." % [traveler(state)["name"], CARDS[card_id]["name"]])
			else:
				_log(state, "%s grants 0." % CARDS[card_id]["name"])
		else:
			var tail_rule = String(traveler(state)["rule"])
			if tail_rule == "double_last" and _is_queue_tail(state, row, col) and amount > raw:
				_log(state, "%s on the %s, %s grants %d. The queue tail doubles it." % [CARDS[card_id]["name"], ROW_NAMES[row], COL_NAMES[col], amount])
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


static func _is_corner(row: int, col: int) -> bool:
	return (row == 0 or row == 2) and (col == 0 or col == 2)


static func _is_covered(state: NightState, row: int, col: int) -> bool:
	return row > 0 and state.form[row - 1][col] != null


static func _center_filled(state: NightState) -> bool:
	return state.form[1][1] != null


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
			if state.shift == SHIFT_VELLUM:
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
