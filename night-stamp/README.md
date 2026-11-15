# Night Stamp

A border-desk deckbuilder across twenty-two nights. Travelers arrive with a written rule. You spend ink to press stamps onto a 3×3 form. The cell matters as much as the card. When the turn ends, the form resolves from the top row downward.

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
- Margin bell opens the twelfth night with a fresh deck. While that night is open, the same button returns to the first bell. A victory desk can open it too.
- Index bell opens the thirteenth night with a fresh deck. While that night is open, the same button returns to the first bell. A victory desk can open it too.
- Ledger bell opens the fourteenth night with a fresh deck. While that night is open, the same button returns to the first bell. A victory desk can open it too.
- Spine bell opens the fifteenth night with a fresh deck. While that night is open, the same button returns to the first bell. A victory desk can open it too.
- Headband bell opens the sixteenth night with a fresh deck. While that night is open, the same button returns to the first bell. A victory desk can open it too.
- Clasp bell opens the seventeenth night with a fresh deck. While that night is open, the same button returns to the first bell. A victory desk can open it too.
- Signature bell opens the eighteenth night with a fresh deck. While that night is open, the same button returns to the first bell. A victory desk can open it too.
- Catchword bell opens the nineteenth night with a fresh deck. While that night is open, the same button returns to the first bell. A victory desk can open it too.
- Colophon bell opens the twentieth night with a fresh deck. While that night is open, the same button returns to the first bell. A victory desk can open it too.
- Errata bell opens the twenty-first night with a fresh deck. While that night is open, the same button returns to the first bell. A victory desk can open it too.
- Frontispiece bell opens the twenty-second night with a fresh deck. While that night is open, the same button returns to the first bell. A victory desk can open it too.
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

The margin bell is a twelfth night. Same stamps, same ink, a new deck.

- Nim Voss — Side Bar. A stamp scores 0 when it shares a side with an earlier stamp. The earlier stamp scores its own number. A corner-only touch does not count, and a lone stamp scores its own number. Kit Yarrow already zeros both stamps of a side-sharing pair, so Nim does not.
- Orla Quill — Last Toll. Patience drops by 2 if the last filled cell is in column 3. Hold is applied first.
- Bram Hart — Frame Slip. A stamp on the outer frame scores twice when the center is filled. If the center is empty, frame stamps score their own number. The center scores its own number.
- Sable Solt — Gap Yield. If two filled stamps have an empty cell between them, each of those stamps scores +2. Stamps that are not part of a gap score their own number. This changes the score. It does not change patience.

The index bell is a thirteenth night. Same stamps, same ink, a new deck.

- Len Quill — Corner Bar. A stamp scores 0 only when it touches an earlier stamp at a corner and does not share a side with that same earlier stamp. A side touch scores its own number. A lone stamp scores its own number. Nim Voss already zeros a later side, so Len does not.
- Ada Pell — First Toll. Patience drops by 2 when the first filled cell is in column 1. A first cell in column 2 or column 3 keeps the drop at 1. Hold is applied first.
- Wynn Hart — Full Row. A stamp scores twice only when its own row is full. A stamp in a row that is not full scores its own number. Sol Wicks yields when the middle row is full, and Bram Hart doubles the frame when the center is filled, so Wynn does neither.
- Sera Voss — End Match. If the first and last filled stamps show the same number, every filled stamp scores +2. A lone stamp scores its own number. Ends that differ score their own number. This is not a gap bonus, and it does not change patience.

The ledger bell is a fourteenth night. Same stamps, same ink, a new deck.

- Nell Voss — Wing Pair. When column 1 and column 3 of the same row are both filled, those two stamps each score +3 once. Column 2 of that row scores its own number. A row missing either wing gets no bonus. Kel Breck already yields when both side columns are stamped anywhere, so Nell does not.
- Pell Dane — Three Toll. Patience drops by 2 when exactly three cells are filled. Any other count keeps the drop at 1. Hold is applied first. Joss Mire already yields when the form holds exactly two stamps, so Pell does not.
- Ida Mire — Low Slip. When two or more stamps are filled, the earliest stamp among those showing the lowest number scores twice. If two stamps share that lowest number, only the earlier one doubles. A lone stamp scores its own number. Ida Cress already doubles the first stamp, so Ida does not.
- Sable Quern — After Gap. A stamp scores twice only when the queue cell immediately before it is empty and some earlier cell is filled. A contiguous block has no doubled stamp. Sable Solt already adds 2 to every filled stamp when any gap exists, so Sable Quern does not.

The spine bell is a fifteenth night. Same stamps, same ink, a new deck.

- Wynn Quill — High Slip. When two or more stamps are filled, the earliest stamp among those showing the highest number scores twice. If two stamps share that highest number, only the earlier one doubles. A lone stamp scores its own number. Ida Mire already doubles the lowest number, so Wynn does not.
- Ada Hart — Four Toll. Patience drops by 2 when exactly four cells are filled. Any other count, including an empty form and a form of three, keeps the drop at 1. Hold is applied first. Pell Dane already drops patience by 2 for exactly three cells, so Ada does not.
- Bram Solt — Before Gap. A stamp scores twice only when the queue cell immediately after it is empty and some later cell is filled. A stamp at the end of the queue does not double. A contiguous block has no doubled stamp. Sable Quern already doubles the stamp that follows the empty cell, so Bram does not.
- Sera Pell — Column Pair. When two filled stamps in the same column have exactly one empty cell between them, those two stamps each score +3 once. A third stamp in that column does not get the bonus unless it is one of such a pair. Contiguous stamps in a column get no bonus. Nell Voss already pays the two side columns of one row, so Sera does not.

The headband bell is a sixteenth night. Same stamps, same ink, a new deck.

- Len Hart — Open Wing. Goal 18. Lane column 1. Exemption row top. When column 1 and column 3 of the same row are both filled and column 2 of that row is empty, those two stamps each score +3 once. If column 2 of that row is filled, that row gets no bonus. A row with only one wing filled gets no bonus. Column 2 never receives this bonus. Nell Voss already pays the wings of a row even when the middle of that row is filled, so Len does not.
- Joss Pell — Five Toll. Goal 14. Lane column 3. Exemption row bottom. Patience drops by 2 when exactly five cells are filled. Any other count, including an empty form and a form of four, keeps the drop at 1. Hold is applied first. Ada Hart already drops for exactly four cells, and Pell Dane already drops for exactly three, so Joss does not.
- Ida Quill — Late High. Goal 22. Lane column 2. Exemption row top. When two or more stamps are filled, the latest stamp among those showing the highest number scores twice. If two stamps share that highest number, only the later one doubles. A lone stamp scores its own number. Wynn Quill already doubles the earlier of the highest number, so Ida does not.
- Cal Quern — Diagonal Pair. Goal 20. Lane column 2. Exemption row middle. When two filled stamps on one three-cell diagonal have exactly one empty cell between them, those two each score +3 once. The diagonals are top-left / center / bottom-right, and top-right / center / bottom-left. A filled center means neither pair qualifies. Sera Pell already pays a column pair, and Nell Voss already pays a row's wings, so Cal does not.

The clasp bell is a seventeenth night. Same stamps, same ink, a new deck.

- Noll Hart — Late Low. Goal 20. Lane column 1. Exemption row bottom. When two or more stamps are filled, the latest stamp among those showing the lowest number scores twice. If two stamps share that lowest number, only the later one doubles. A lone stamp scores its own number. Ida Mire already doubles the earlier of the lowest number, and Ida Quill already doubles the later of the highest number, so Noll does not.
- Hugh Pell — Six Toll. Goal 16. Lane column 2. Exemption row top. Patience drops by 2 when exactly six cells are filled. Any other count, including an empty form and a form of five, keeps the drop at 1. Hold is applied first. Joss Pell already drops for exactly five cells, Ada Hart for exactly four, and Pell Dane for exactly three, so Hugh does not.
- Fenn Hart — Full Column. Goal 22. Lane column 3. Exemption row middle. A stamp scores twice only when its own column is full. A stamp in a column that is not full scores its own number. Wynn Hart already doubles a stamp only when its own row is full, so Fenn does not.
- Rue Hart — Side Slip. Goal 18. Lane column 1. Exemption row bottom. When a stamp shares a side with an earlier stamp, the later stamp scores twice. The earlier stamp scores its own number. A corner-only touch does not count. A lone stamp scores its own number. Nim Voss already zeros that later stamp, so Rue does not.

The signature bell is an eighteenth night. Same stamps, same ink, a new deck.

- Dory Hart — Seven Toll. Goal 18. Lane column 3. Exemption row bottom. Patience drops by 2 when exactly seven cells are filled. Any other count, including an empty form and a form of six, keeps the drop at 1. Hold is applied first. Hugh Pell already drops for exactly six cells, Joss Pell for exactly five, Ada Hart for exactly four, and Pell Dane for exactly three, so Dory does not.
- Lin Pell — Lone Column. Goal 20. Lane column 1. Exemption row top. A stamp scores twice only when it is the only filled stamp in its column. If that column holds another stamp, every stamp in the column scores its own number. Tam Quern already zeros a second stamp in column 1, and Fenn Hart already doubles a stamp only when its column is full, so Lin does not.
- Opal Quill — Side Pay. Goal 22. Lane column 2. Exemption row middle. Each stamp that shares a side with another filled stamp scores +3 once. A stamp that shares two sides still scores +3 once. A corner-only touch does not count. A lone stamp scores its own number. Rue Hart already doubles the later stamp of a side pair, and Nim Voss already zeros that later stamp, so Opal does not.
- Holt Quern — Next Fill. Goal 16. Lane column 2. Exemption row bottom. A stamp scores twice only when the queue cell immediately after it is filled. A stamp whose next cell is empty scores its own number. The bottom-right cell has no cell after it, so it does not double. Bram Solt already doubles a stamp when the next cell is empty and a later cell is filled, so Holt does not.

The catchword bell is a nineteenth night. Same stamps, same ink, a new deck.

- Gwyn Brant — Eight Toll. Goal 16. Lane column 3. Exemption row top. Patience drops by 2 when exactly eight cells are filled. Any other count, including an empty form, a form of seven, and a full form of nine, keeps the drop at 1. Hold is applied first. The toll does not change what a stamp scores. Exemption on the top row keeps the drop at 1 even when exactly eight cells are filled. An Exemption off the top row does not. Dory Hart already drops for exactly seven cells, Hugh Pell for six, Joss Pell for five, Ada Hart for four, and Pell Dane for three, so Gwyn does not.
- Hester Keel — Prior Fill. Goal 20. Lane column 1. Exemption row bottom. A stamp scores twice only when the queue cell immediately before it is filled. The queue is read from the top row downward, left to right inside a row, the same order Holt Quern uses. A stamp whose previous cell is empty scores its own number. The top-left cell has no cell before it, so it does not double. A gap means the stamp after the gap does not double. A retrigger of a stamp whose previous cell is filled scores twice again. A retrigger of a stamp whose previous cell is empty does not. Exemption on the bottom row cancels the doubling, so every stamp scores its own number. An Exemption off the bottom row does not. The slip does not change patience. Holt Quern already doubles a stamp when the next cell is filled, Bram Solt already doubles a stamp when the next cell is empty and a later cell is filled, and Sable Quern already doubles a stamp when the previous cell is empty and some earlier cell is filled, so Hester does none of those.
- Idris Reed — Corner Pay. Goal 22. Lane column 2. Exemption row middle. Each stamp that has at least one filled diagonal neighbor scores +3 once. A diagonal neighbor is one of the four corner-touching cells. An orthogonal neighbor does not count. A stamp with two or more diagonal neighbors still scores +3 once, not +3 for each. A stamp that only has orthogonal neighbors scores its own number. A lone stamp scores its own number. A retrigger of a stamp that has a filled diagonal neighbor adds 3 again. Exemption on the middle row cancels the bonus, so every stamp scores its own number. An Exemption off the middle row does not. An Exemption that has a filled diagonal neighbor and sits off the middle row still adds 3. The pay does not change patience. Opal Quill already adds 3 for a side share, and Rho Tallow already yields when two stamps meet at a corner, so Idris does neither.
- Colm Brigg — Short Row. Goal 18. Lane column 1. Exemption row top. A stamp scores twice only when its own row holds exactly two filled stamps. Both stamps in that row double. A row with one stamp scores that stamp's own number. A full row of three scores each stamp's own number. Other rows are independent. A retrigger of a stamp in a two-stamp row scores twice again. A retrigger of a stamp in a row of one or three does not. Exemption on the top row cancels the doubling, so every stamp scores its own number. An Exemption off the top row does not. The slip does not change patience. Wynn Hart already doubles a stamp only when its own row is full, so Colm does not.

The colophon bell is a twentieth night. Same stamps, same ink, a new deck.

- Nia Soren — Nine Toll. Goal 18. Lane column 2. Exemption row bottom. Patience drops by 2 when exactly nine cells are filled. Any other count, including an empty form and a form of eight, keeps the drop at 1. Hold is applied first. The toll does not change what a stamp scores. Exemption on the bottom row keeps the drop at 1 even when the form is full. An Exemption off the bottom row does not. Gwyn Brant already drops for exactly eight cells, Dory Hart for seven, Hugh Pell for six, Joss Pell for five, Ada Hart for four, and Pell Dane for three, so Nia does not.
- Perris Wythe — Lone Row. Goal 20. Lane column 3. Exemption row top. A stamp scores twice only when it is the only filled stamp in its row. If that row holds another stamp, every stamp in the row scores its own number. Other rows do not matter. A lone stamp on the form is the only stamp in its row, so it scores twice. A row of two does not double. A full row does not double. A retrigger of a stamp that is alone in its row scores twice again. A retrigger of a stamp in a row that holds another stamp does not. Exemption on the top row cancels the doubling, so every stamp scores its own number. An Exemption off the top row does not. An Exemption that is the only stamp in its row and sits off the top row scores twice. The slip does not change patience. Lin Pell already doubles a stamp only when it is alone in its column. Colm Brigg already doubles both stamps in a row of exactly two. Wynn Hart already doubles a stamp only when its row is full. Lark Pym already ignores a stamp that shares its row. Perris does none of those.
- Jory Marsh — Short Column. Goal 16. Lane column 1. Exemption row middle. A stamp scores twice only when its own column holds exactly two filled stamps. Both stamps in that column double. A column with one stamp scores that stamp's own number. A full column of three scores each stamp's own number. Other columns are independent. A retrigger of a stamp in a two-stamp column scores twice again. A retrigger of a stamp in a column of one or three does not. Exemption on the middle row cancels the doubling, so every stamp scores its own number. An Exemption off the middle row does not. The slip does not change patience. Colm Brigg already doubles a row of exactly two. Lin Pell already doubles a stamp only when it is alone in its column. Fenn Hart already doubles a stamp only when its column is full. Jory does none of those.
- Maeve Okell — Corner Slip. Goal 22. Lane column 2. Exemption row top. When a stamp shares a corner with an earlier stamp, the later stamp scores twice. The earlier stamp scores its own number. A corner is a diagonal touch. A side share does not count, and it does not double the later stamp. A stamp that meets an earlier stamp only at a corner doubles. A lone stamp scores its own number. If the later stamp meets two earlier stamps at corners, it still scores twice, not four times. A retrigger of a later corner-sharing stamp scores twice again. A retrigger of the earlier stamp scores its own number again. Exemption on the top row cancels the doubling, so every stamp scores its own number. An Exemption off the top row does not. The slip does not change patience. Rue Hart already doubles the later stamp of a side pair. Idris Reed already adds 3 to each stamp that has a filled diagonal neighbor. Rho Tallow already yields when two stamps meet at a corner. Maeve does none of those.

The errata bell is a twenty-first night. Same stamps, same ink, a new deck.

- Una Pell — Odd Toll. Goal 18. Lane column 1. Exemption row top. Patience drops by 2 when the number of filled cells is odd: one, three, five, seven, or nine. An even count keeps the drop at 1. That includes an empty form and a form of two, four, six, or eight. Hold is applied first. The toll does not change what a stamp scores. Exemption on the top row keeps the drop at 1 even when the count is odd. An Exemption off the top row does not. Pell Dane already drops only for exactly three, Joss Pell only for five, Dory Hart only for seven, and Nia Soren only for nine. Ada Hart, Hugh Pell, and Gwyn Brant already drop for the even counts four, six, and eight. Una does none of those. Una also drops for a single filled cell, which none of those exact tolls do.
- Orin Keel — Next Blank. Goal 20. Lane column 3. Exemption row bottom. A stamp scores twice only when the queue cell immediately after it is empty. The queue is the top row downward, left to right inside a row, the same order Holt Quern and Hester Keel use. A stamp whose next cell is filled scores its own number. The bottom-right cell has no cell after it, so it does not double. A stamp followed only by empty cells through the end of the queue does double. A retrigger of a stamp whose next cell is empty scores twice again. A retrigger of a stamp whose next cell is filled does not. Exemption on the bottom row cancels the doubling, so every stamp scores its own number. An Exemption off the bottom row does not. An Exemption that is followed by an empty cell and sits off the bottom row scores twice. The slip does not change patience. Holt Quern already doubles a stamp only when the next cell is filled. Bram Solt already doubles a stamp only when the next cell is empty and some later cell is filled, so a stamp followed by nothing but empty cells does not double for Bram. Hester Keel already doubles a stamp only when the previous cell is filled. Orin does none of those.
- Vesper Okell — Corner Mark. Goal 16. Lane column 2. Exemption row middle. A stamp scores twice only when it sits in one of the four corner cells: top-left, top-right, bottom-left, or bottom-right. The center and the four edge-middle cells score their own number, whether or not a corner is filled. A corner doubles even when its neighbors are empty, and it still only doubles once when its neighbors are filled. A retrigger of a corner stamp scores twice again. A retrigger of a center or edge-middle stamp scores its own number again. Exemption on the middle row cancels the doubling, so every stamp scores its own number. An Exemption off the middle row does not. An Exemption in a corner and off the middle row scores twice. The mark does not change patience. Bram Hart already doubles every frame stamp only when the center is filled, and that includes the edge-middle cells. Maeve Okell already doubles the later stamp of a diagonal pair and does not care whether the cell is a corner. Idris Reed already adds 3 for a filled diagonal neighbor. Vesper does none of those.
- Weske Brant — Middle Pay. Goal 22. Lane column 1. Exemption row bottom. Each stamp in the middle row scores +2 once. A stamp on the top row or the bottom row scores its own number. The center is in the middle row, so it gets +2. The two edge cells of the middle row get +2 as well. Neighbors do not change the bonus. Two neighbors do not add 4. A lone middle-row stamp still gets +2. A retrigger of a middle-row stamp adds 2 again. A retrigger of a top or bottom stamp does not. Exemption on the bottom row cancels the bonus, so every stamp scores its own number. An Exemption off the bottom row does not. An Exemption in the middle row still adds 2, because the middle row is not the bottom row. The pay does not change patience. Opal Quill already adds 3 for a side share. Idris Reed already adds 3 for a diagonal neighbor. The center slip already doubles one cell and does not add 2 to the whole middle row. Weske does none of those.

The frontispiece bell is a twenty-second night. Same stamps, same ink, a new deck.

- Soren Hale — Even Toll. Goal 18. Lane column 3. Exemption row middle. Patience drops by 2 when the number of filled cells is even: zero, two, four, six, or eight. An odd count keeps the drop at 1. That includes a single filled cell and a full form of nine. Hold is applied first. The toll does not change what a stamp scores. Exemption on the middle row keeps the drop at 1 even when the count is even. An Exemption off the middle row does not. Una Pell already drops on every odd count and does not drop on an even count. Ada Hart already drops only for exactly four, Hugh Pell only for exactly six, and Gwyn Brant only for exactly eight. Soren also drops for an empty form and for exactly two, which none of those exact tolls do, and she drops for every even count rather than one exact count.
- Brigg Marsh — Prior Blank. Goal 20. Lane column 2. Exemption row top. A stamp scores twice only when the queue cell immediately before it is empty. The queue is the top row downward, left to right inside a row, the same order Holt Quern, Hester Keel, and Orin Keel use. A stamp whose previous cell is filled scores its own number. The top-left cell has no cell before it, so it does not double. A stamp whose previous cell is empty doubles even when no earlier cell is filled. A retrigger of a stamp whose previous cell is empty scores twice again. A retrigger of a stamp whose previous cell is filled does not. Exemption on the top row cancels the doubling, so every stamp scores its own number. An Exemption off the top row does not. An Exemption that follows an empty cell and sits off the top row scores twice. The slip does not change patience. Hester Keel already doubles a stamp only when the previous cell is filled. Sable Quern already doubles a stamp only when the previous cell is empty and some earlier cell is filled, so a stamp that follows an empty cell at the start of the queue does not double for Sable. Orin Keel already looks at the next cell, not the previous cell. Brigg does none of those.
- Tallow Keel — Edge Mark. Goal 16. Lane column 1. Exemption row bottom. A stamp scores twice only when it sits in one of the four edge-middle cells: top middle, left middle, right middle, or bottom middle. The four corners and the center score their own number. An edge-middle stamp doubles even when its neighbors are empty, and it still only doubles once when its neighbors are filled. A retrigger of an edge-middle stamp scores twice again. A retrigger of a corner or the center scores its own number again. Exemption on the bottom row cancels the doubling, so every stamp scores its own number. An Exemption off the bottom row does not. An Exemption on an edge-middle cell and off the bottom row scores twice. The mark does not change patience. Vesper Okell already doubles the four corners and does not double an edge middle. Bram Hart already doubles every frame stamp only when the center is filled. Tallow does neither.
- Yarrow Fen — Top Pay. Goal 22. Lane column 2. Exemption row middle. Each stamp in the top row scores +2 once. A stamp in the middle row or the bottom row scores its own number. Neighbors do not change the bonus. Two neighbors do not add 4. A lone top-row stamp still gets +2. A retrigger of a top-row stamp adds 2 again. A retrigger of a middle or bottom stamp does not. Exemption on the middle row cancels the bonus, so every stamp scores its own number. An Exemption off the middle row does not. An Exemption in the top row still adds 2, because the top row is not the middle row. The pay does not change patience. Weske Brant already adds 2 to the middle row and not to the top row. Opal Quill already adds 3 for a side share. Yarrow does neither.

## Tests

From this directory:

```
godot --headless --path . -s res://tests/run_tests.gd
```

The process exits 0 when every check passes and non-zero when one fails. The checks cover the 20-card pool, a fixed-seed clear of each night, a turn with 0 ink, the chain cap, the same card producing different numbers on two cells, and a correct stamp beside a wrong stamp for each late-shift, closing-bell, ash-watch, gutter-lamp, vellum-bell, quire-watch, salt-watch, quay-bell, folio-bell, wick-bell, margin-bell, index-bell, ledger-bell, spine-bell, headband-bell, clasp-bell, signature-bell, catchword-bell, colophon-bell, errata-bell, and frontispiece-bell form.
