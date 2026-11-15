# Night Stamp

A border-desk deckbuilder across eleven nights. Travelers arrive with a written rule. You spend ink to press stamps onto a 3×3 form. The cell matters as much as the card. When the turn ends, the form resolves from the top row downward.

This folder is a Godot 4 project. It was built against Godot 4.7.2.

## Run

From this directory:

```
godot --path .
```

From the repository root:

```
godot --path night-stamp
```

A run is seeded. The seed field decides the shuffle and the draft offers. Restart encounter deals the current traveler again with the same deck and relic. Restart act starts the night on the desk over from the seed.

## Controls

- Click a stamp, then click a cell. Arrows or WASD move the form cursor.
- Keys 1–5 select a stamp. Enter or Space stamps the cursor. E ends the turn.
- On a draft or relic choice, click a card or press 1, 2, or 3.
- Late shift opens the second night with a fresh deck. While that night is open, First bell returns to Act 1.
- Closing bell opens the third night with a fresh deck. While that night is open, the same button returns to the first bell.
- Ash watch opens the fourth night with a fresh deck. While that night is open, the same button returns to the first bell.
- Gutter lamp opens the fifth night with a fresh deck. While that night is open, the same button returns to the first bell.
- Vellum bell opens the sixth night with a fresh deck. While that night is open, the same button returns to the first bell.
- Quire watch opens the seventh night with a fresh deck. While that night is open, the same button returns to the first bell.
- Salt watch opens the eighth night with a fresh deck. While that night is open, the same button returns to the first bell.
- Quay bell opens the ninth night with a fresh deck. While that night is open, the same button returns to the first bell.
- Folio bell opens the tenth night with a fresh deck. While that night is open, the same button returns to the first bell. A victory desk can open any later night.
- Wick bell opens the eleventh night with a fresh deck. While that night is open, the same button returns to the first bell. A victory desk can open it too.
- Ink is 3 at the start of a turn (4 with Deep Well). Spending the last ink ends the turn. A turn with 0 ink accepts no further stamp.

The rules comment at the top of `rules/rules.gd` is the full rules text. The first bell has four travelers:

- Ada Quill — Refuses stamps on the top row.
- Bram Holt — Yields if column 2 is stamped.
- Cira Venn — Patience drops twice when the bottom row is empty.
- Doss Kite — Ignores stamps with no orthogonal neighbor.

The late shift is another night on the same desk. Same stamps, same ink, a new deck. Restart act replays the night that is open.

- Nell Parr — Struck Margin. Refuses stamps in column 1.
- Sol Wicks — Band Ledger. Yields if the middle row is full.
- Pim Larke — Third-Bell Chit. Patience drops twice when column 3 is empty.
- Rue Calder — Corner Ornament. Ignores stamps in the corner boxes.

The closing bell is a third night. Same stamps, same ink, a new deck.

- Moss Quen — Folded Band. Refuses stamps on the middle row.
- Kel Breck — Twin Margin. Yields if column 1 and column 3 are both stamped.
- Tansy Pell — Center Void. Patience drops twice when the center cell is empty.
- Lumen Peck — Overprint Slip. Ignores a stamp with a stamp directly above it.

The ash watch is a fourth night. Same stamps, same ink, a new deck.

- Orla Fen — Sealed Foot. Refuses stamps on the bottom row.
- Joss Mire — Pair Chit. Yields if the form holds exactly two stamps.
- Vetch Rowan — Row Seal. Patience does not fall when every row is stamped.
- Nim Harth — Tail Slip. The last stamp in the queue scores twice.

The gutter lamp is a fifth night. Same stamps, same ink, a new deck.

- Ivo Dane — Blank Spine. Refuses stamps in column 2.
- Sera Dodd — Triad Chit. Yields if every column is stamped.
- Wren Hale — Open Margin. Patience drops twice when column 1 is empty.
- Kit Yarrow — Neighbor Slip. Ignores a stamp with an orthogonal neighbor.

The vellum bell is a sixth night. Same stamps, same ink, a new deck.

- Edda Voss — Quiet Center. Refuses the center cell.
- Rho Tallow — Corner Meet. Yields if two stamps meet at a corner.
- Nessa Brin — Row Toll. Patience drops once for each empty row.
- Lark Pym — Solo Line. Ignores a stamp that shares its row.

The quire watch is a seventh night. Same stamps, same ink, a new deck.

- Tess Quern — Far Margin. Refuses stamps in column 3.
- Oren Sallow — Side Meet. Yields if two stamps share a side.
- Bryn Solt — Column Toll. Patience drops once for each empty column.
- Ida Cress — Head Slip. The first stamp in the queue scores twice.

The salt watch is an eighth night. Same stamps, same ink, a new deck.

- Pell Voss — Tide Bar. A stamp on the middle row scores 0 unless an Exemption is also on the middle row.
- June Hart — Pair Toll. Patience drops by 2 if two stamps share a number. A number is the progress that stamp already grants.
- Cal Mire — Edge Yield. A stamp on the outer frame yields +3. The center cell does not.
- Ned Quill — Last Slip. The last stamp in the queue scores twice.

The quay bell is a ninth night. Same stamps, same ink, a new deck.

- Mara Quill — First Bar. The first stamp in the queue scores 0 unless an Exemption is on the top row.
- Holt Venn — Center Toll. Patience drops by 2 if the center cell is filled.
- Sera Dunn — Corner Yield. A stamp in a corner yields +3. A non-corner edge does not.
- Ivo Pell — Pair Slip. If two stamps share a number, the later one scores twice.

The folio bell is a tenth night. Same stamps, same ink, a new deck.

- Ness Hart — Last Bar. The last stamp in the queue scores 0 unless an Exemption is on the bottom row.
- Wynn Cress — Center Slip. The center stamp scores twice. Other cells score their own number.
- Tam Quern — Column Bar. A stamp in column 1 scores 0 when that column holds another stamp. A lone stamp in column 1 counts. Columns 2 and 3 score normally. Nell Parr already refuses every stamp in column 1, so Tam does not.
- Pell Sallow — Gap Toll. Patience drops by 2 if two stamps have an empty cell between them in queue order.

The wick bell is an eleventh night. Same stamps, same ink, a new deck.

- Odell Voss — Row Bar. A stamp on the bottom row scores 0 when that row holds another stamp. A lone bottom-row stamp counts.
- Cress Hart — First Slip. The first stamp in the queue scores twice when a later stamp follows it. A lone stamp scores its own number. Ida Cress already doubles a lone first stamp, so Cress does not.
- Jun Solt — Pair Bar. If two stamps share a number, the later one scores 0. The earlier stamp scores its own number.
- Ives Mire — Empty Yield. Each empty cell adds 1 to every filled stamp's own progress.

## Tests

From this directory:

```
godot --headless --path . -s res://tests/run_tests.gd
```

The process exits 0 when every check passes and non-zero when one fails. The checks cover the 20-card pool, a fixed-seed clear of each night, a turn with 0 ink, the chain cap, the same card producing different numbers on two cells, and a correct stamp beside a wrong stamp for each late-shift, closing-bell, ash-watch, gutter-lamp, vellum-bell, quire-watch, salt-watch, quay-bell, folio-bell, and wick-bell form.
