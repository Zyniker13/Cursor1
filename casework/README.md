# Casework

A deduction game with one case, **The spare key**.

The game keeps a single timeline. You read the exhibits and pin who took the spare key, the room they took it to, and the hour of that taking. A theory is accepted only when it fits every exhibit. A theory that does not fit comes back naming the exhibits it contradicts. An empty pin is refused by the name of the missing slot.

There is no voice. The papers and the board are the whole case.

## Play

Requires Godot 4. From this folder:

```
godot --path .
```

From the repository root:

```
godot --path casework
```

You can also open `project.godot` in the Godot 4 editor and press Play.

## Test

Requires Godot 4. From this folder:

```
godot --headless --path . -s res://tests/run.gd
```

The process exits 0 when every check passes and non-zero when any check fails.
