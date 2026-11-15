# Night Stamp

Act 1 of a border-desk deckbuilder. Travelers arrive with a written rule. You spend ink to press stamps onto a 3×3 form. The cell matters as much as the card. When the turn ends, the form resolves from the top row downward.

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
- Late shift opens the second night with a fresh deck. First bell returns to Act 1. The victory desk offers the same choice.
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

## Tests

From this directory:

```
godot --headless --path . -s res://tests/run_tests.gd
```

The process exits 0 when every check passes and non-zero when one fails. The checks cover the 20-card pool, a fixed-seed clear of both nights, a turn with 0 ink, the chain cap, the same card producing different numbers on two cells, and a correct stamp beside a wrong stamp for each late-shift form.
