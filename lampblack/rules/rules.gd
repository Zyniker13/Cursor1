class_name LampRules
extends RefCounted

## Lampblack rules.
##
## Turn order
## 1. The player takes one action: step to an adjacent tile, wait, or toggle an adjacent lamp.
## 2. A call may come from that action. It does not change the step taken in step 3.
##    Snuffing a lamp (lit became dark) calls the nearest guard. Stepping onto a plate
##    calls the nearest guard. Stepping onto a bell calls every guard who has a floor
##    path to that bell. Distance is Manhattan from the guard's tile to the target.
##    A tie goes to the lowest guard index. A guard with no floor path to a bell is not
##    called and keeps the rail. Waiting on a plate or a bell does not call again.
##    Lighting a lamp calls nobody.
## 3. Every guard then moves one tile according to the alert that was already active
##    at the start of the turn, or along their rail if they are not alert and not holding.
## 4. The call from step 2 becomes the active alert after that movement. Each called
##    guard's arrow shows the tile he will step to on the next turn.
## 5. Stepping onto the exit wins immediately, before the guards move.
##    Sharing a tile with a guard, or standing on a watched tile, is a loss. That is
##    checked after the player's action and again after the guards move.
##
## Light
## A lit lamp illuminates a Manhattan diamond of its radius, clipped by walls.
## A tile is inside the diamond when its distance from the lamp is at most the radius
## and it is not strictly behind the lamp. "Behind" means the step from the lamp to the
## tile has a negative dot product with the lamp's facing (north, east, south, or west).
## Sideways tiles count. The tile directly behind the lamp stays dark, so the player
## can stand there and snuff it. Walls block the flood; they are never lit. A grate does
## not stop the flood and is never marked lit, so tiles past it still light. A sill stops
## the flood. The sill itself is lit, and tiles past it stay dark. A pane does not stop
## the flood and is never marked lit, so tiles past it still light. The pane itself is
## never lit and is never dark floor, because nobody can stand on it. A curtain does not
## stop the flood. The curtain itself is lit, and tiles past it still light. A shade
## stops the flood. The shade itself is never lit, and tiles past it stay dark. A screen
## does not stop the flood. The screen itself is lit, and tiles past it still light. A
## glaze does not stop the flood. The glaze itself is lit, and tiles past it still light.
## A mica does not stop the flood. The mica itself is never lit, and tiles past it
## still light. A baize stops the flood. The baize itself is never lit, and tiles
## past it stay dark. A scrim stops the flood. The scrim itself is lit, and tiles
## past it stay dark. A gauze does not stop a flood that reaches it from another
## tile. The gauze itself is lit, and tiles past it still light. A lamp standing
## on a gauze does not shine past that tile. A voile does not stop a flood that
## reaches it from another tile. The voile itself is lit, and tiles past it still
## light. A lamp standing on a voile does not shine past that tile. A shade, a
## mica, a baize, and a grate already stay dark under a lamp, so a voile does not.
## A lawn stops the flood. The lawn itself is lit, and tiles past it stay dark.
##
## Movement
## Dark floor and a dark exit may be entered. A gap may be entered only while it is lit.
## Lit floor that no guard is watching is refused. Stepping onto a watched tile is a loss,
## not a refusal — watched means the tile is lit and lies in a guard's vision.
## A plate is floor. It may be entered while it is dark. A lit plate is refused, the same
## as other lit floor, until the lamp covering it is snuffed.
## A bell is floor. It may be entered while it is dark. A lit bell is refused, the same
## as other lit floor, until the lamp covering it is snuffed.
## A grate is floor you may enter. It stays dark even when a lamp's diamond covers its
## tile, so standing on it is not a loss. A lit floor tile beside a grate is still refused.
## A sill is floor. It may be entered while it is dark. A lamp lights it. A lit sill is
## refused, the same as other lit floor, until the lamp covering it is snuffed. Stepping
## onto a lit sill a guard is watching is a loss, the same as any lit floor.
## A pane is not floor. You cannot enter it. A guard cannot enter it.
## A curtain is floor. A lamp lights it. An unwatched lit curtain is refused, the same
## as other lit floor. Stepping onto a lit curtain a guard is watching is a loss.
## A shade is floor you may enter. It stays dark even when a lamp's diamond covers its
## tile, so standing on it is not a loss. A lit floor tile beside a shade is still refused.
## A screen is floor. A lamp lights it. An unwatched lit screen is refused, the same
## as other lit floor. Stepping onto a lit screen a guard is watching is a loss.
## A glaze is floor. A lamp lights it. An unwatched lit glaze is refused, the same
## as other lit floor. Stepping onto a lit glaze a guard is watching is a loss.
## A mica is floor you may enter. It stays dark even when a lamp's diamond covers its
## tile, so standing on it is not a loss.
## A baize is floor you may enter. It stays dark even when a lamp's diamond covers its
## tile, so standing on it is not a loss.
## A scrim is floor. It may be entered only while it is dark. A lamp lights it. An
## unwatched lit scrim is refused, the same as other lit floor. Stepping onto a lit
## scrim a guard is watching is a loss.
## A gauze is floor. It may be entered only while it is dark. A lamp lights it. An
## unwatched lit gauze is refused, the same as other lit floor. Stepping onto a lit
## gauze a guard is watching is a loss.
## A voile is floor. A lamp lights it. The early step onto an unwatched lit voile
## succeeds. A shade, a mica, and a baize already stay dark, so the voile does
## not copy them. Stepping onto a lit voile a guard is watching is still a loss.
## A lawn is floor. A lamp lights it. The early step onto an unwatched lit lawn
## succeeds. A second lamp's light stops at the lawn. No lit cloth already stops
## a second lamp and also allows that early step, so you still leave by stepping
## on the dark lawn. Stepping onto a lit lawn a guard is watching is a loss.
##
## Plates
## The turn the player steps onto a plate calls the nearest guard, by the same rule as a
## snuff: Manhattan distance to that plate, and the lowest guard index wins a tie. The
## call does not change the step taken on that turn. The guard takes the arrow step on
## the next turn, then walks toward the plate and holds there. Waiting while already on
## the plate does not call again. Leaving and stepping back on does. Lighting a lamp
## still calls nobody. Snuffing a lamp still does.
##
## Bells
## The turn the player steps onto a bell calls every guard who has a floor path to that
## bell. Each called guard takes the arrow step on the next turn, then walks to the bell
## and holds there. The call does not change the step taken on that turn. Waiting while
## already on the bell does not call again. Leaving and stepping back on does. A snuff
## still calls only the nearest guard. A plate still calls only the nearest guard.
## Lighting a lamp still calls nobody. A bell pulls a guard off an existing hold. A guard
## with no floor path to the bell is not called and keeps the rail. A grate is not a
## floor path. A sill is not a floor path. A pane is not a floor path. A curtain is a
## floor path. A shade is not a floor path. A screen is not a floor path. A glaze is
## not a floor path. A mica is not a floor path. A baize is not a floor path.
## A scrim is not a floor path. A gauze is not a floor path. A voile is not a floor path. A lawn is not a floor path.
##
## Grates
## A grate is floor you may enter. It is never lit, even when a lamp's diamond covers
## its tile. Light does not stop at it: tiles past the grate still light. Because the
## grate itself stays dark, standing on it is not a loss, and it blocks vision the same
## way any dark floor does. A guard cannot enter a grate. Pathing treats it as closed,
## the same as a wall, so a called guard walks around it. A grate does not call a guard.
## A plate still calls only the nearest guard. A bell still calls every guard who can
## reach it, and a grate is not a path. A lit floor tile beside a grate is still refused.
##
## Sills
## A sill is floor you may enter while it is dark. A lamp lights it. Standing on a lit
## sill is a loss, the same as any lit floor: a lit sill no guard is watching is refused,
## and stepping onto a lit sill a guard is watching loses. Light stops at the sill. The
## sill itself is lit, and tiles past it stay dark even when the lamp's diamond would
## have reached them. That is the difference from a grate, which stays dark and lets
## light through. A guard cannot see through a sill. A lit sill can still be watched.
## A guard cannot enter a sill. Pathing treats it as closed, the same as a wall, so a
## called guard walks around it. A sill calls nobody. It is never a hold. A plate still
## calls only the nearest guard. A bell still calls every guard who can reach it, and a
## sill is not a path.
##
## Panes
## A pane is not floor. You cannot enter it. A guard cannot enter it. Pathing treats it
## as closed, the same as a wall. Light does not stop at a pane. A lamp's diamond
## continues through it, and tiles past it light. The pane itself is never lit and is
## never dark floor, because nobody can stand on it. Vision does not stop at a pane. A
## guard sees lit tiles beyond it. A pane calls nobody. It is never a hold. A plate
## still calls only the nearest guard. A bell still calls every guard who can reach it,
## and a pane is not a path. A pane is not a wall, a sill, a grate, a plate, or a bell.
## A wall blocks the light and the sight. A sill is floor, is lit, and stops both the
## light and the sight. A grate is floor you may enter, stays dark, lets the light
## through, and blocks sight because it is dark. A pane lets both the light and the
## sight through, and neither you nor a guard can step on it.
##
## Curtains
## A curtain is floor you may enter. A lamp lights it. An unwatched lit curtain is
## refused, the same as unwatched lit floor. Stepping onto a curtain a guard is watching
## is a loss. Light does not stop at a curtain: tiles past it still light. Vision does
## stop at a curtain, even when the curtain is lit and the tile past it is lit. A guard
## does not see through it. The lit curtain tile itself can still be watched. A guard
## can enter a curtain. Pathing treats it as open floor, so a plate path and a bell path
## can go through it, and a called guard can walk through it. A curtain calls nobody.
## It is never a hold. A plate still calls only the nearest guard. A bell still calls
## every guard who has a floor path, and a curtain counts as that path. A curtain is not
## a wall, a sill, a grate, a pane, a plate, or a bell. A wall blocks the light and the
## sight, and nobody can enter it. A sill is floor, is lit, stops the light, stops the
## sight, and a guard cannot enter it. A grate stays dark, lets the light through,
## blocks sight because it is dark, and a guard cannot enter it. A pane lets the light
## and the sight through, and neither you nor a guard can step on it. A curtain is lit,
## lets the light through, stops the sight, and a guard can step on it.
##
## Shades
## A shade is floor you may enter. It is never lit, even when a lamp's diamond covers
## its tile. Standing on it is not a loss, because it stays dark. Light stops at a
## shade: tiles past it stay dark even when the lamp's diamond would have reached them.
## Vision stops there the same way any dark floor stops vision. A guard cannot enter a
## shade. Pathing treats it as closed, the same as a wall, so a called guard walks
## around it. A shade calls nobody. It is never a hold. A plate still calls only the
## nearest guard. A bell still calls every guard who has a floor path, and a shade is
## not that path. A shade is not a wall, a sill, a grate, a pane, a plate, a bell, or
## a curtain. A curtain is lit, lets the light through, stops the sight, and a guard
## can step on it. A grate stays dark, lets the light through, and a guard cannot enter
## it. A sill is lit, stops the light, stops the sight, and a guard cannot enter it. A
## pane lets the light and the sight through, and nobody can step on it. A wall blocks
## the light and the sight, and nobody can step on it. A shade stays dark, stops the
## light, stops the sight, and you can step on it. A guard cannot.
##
## Screens
## A screen is floor you may enter. A lamp lights it. An unwatched lit screen is
## refused, the same as unwatched lit floor. Stepping onto a screen a guard is watching
## is a loss. Light does not stop at a screen: tiles past it still light. Vision does
## stop at a screen, even when the screen is lit and the tile past it is lit. A guard
## does not see through it. The lit screen tile itself can still be watched. A guard
## cannot enter a screen. Pathing treats it as closed, the same as a wall, so a
## called guard walks around it. A screen calls nobody. It is never a hold. A plate
## still calls only the nearest guard. A bell still calls every guard who has a floor
## path, and a screen is not that path. A screen is not a wall, a sill, a grate, a
## pane, a plate, a bell, a curtain, or a shade. A curtain is lit, lets the light
## through, stops the sight, and a guard can step on it. A shade stays dark, stops the
## light, stops the sight, and you can step on it. A guard cannot. A grate stays dark,
## lets the light through, and a guard cannot enter it. A sill is lit, stops the light,
## stops the sight, and a guard cannot enter it. A pane lets the light and the sight
## through, and nobody can step on it. A screen is lit, lets the light through, stops
## the sight, and a guard cannot step on it.
##
## Glazes
## A glaze is floor you may enter. A lamp lights it. An unwatched lit glaze is
## refused, the same as unwatched lit floor. Stepping onto a glaze a guard is watching
## is a loss. Light does not stop at a glaze: tiles past it still light. Sight does
## not stop while the glaze is lit: a guard sees through a lit glaze to the lit tiles
## past it. When the glaze is dark, it is ordinary dark floor for vision, so sight
## stops there because the cell is dark. A guard cannot enter a glaze. Pathing treats
## it as closed, the same as a wall, so a called guard walks around it. A glaze calls
## nobody. It is never a hold. A plate still calls only the nearest guard. A bell
## still calls every guard who has a floor path, and a glaze is not that path. A glaze
## is not a wall, a sill, a grate, a pane, a plate, a bell, a curtain, a shade, or a
## screen. A screen is lit, lets the light through, stops the sight, and a guard cannot
## step on it. A curtain is lit, lets the light through, stops the sight, and a guard
## can step on it. A shade stays dark, stops the light, stops the sight, and you can
## step on it. A guard cannot. A grate stays dark, lets the light through, and a guard
## cannot enter it. A sill is lit, stops the light, stops the sight, and a guard cannot
## enter it. A pane lets the light and the sight through, and nobody can step on it.
## A glaze is lit, lets the light through, lets the sight through while it is lit, and
## a guard cannot step on it.
##
## Micas
## A mica is floor you may enter. It stays dark even when a lamp's diamond covers
## its tile, so you may step onto it while a lamp is lit. Standing on it is not a
## loss, because it stays dark. Light does not stop at a mica: tiles past it still
## light. Sight does not stop at a mica: a guard sees lit tiles beyond it, even
## though the mica cell itself is dark. A guard cannot enter a mica. Pathing treats
## it as closed, the same as a wall, so a called guard walks around it. A mica
## calls nobody. It is never a hold. A plate still calls only the nearest guard.
## A bell still calls every guard who has a floor path, and a mica is not that
## path. A mica is not a wall, a sill, a grate, a pane, a plate, a bell, a curtain,
## a shade, a screen, or a glaze. A glaze is lit, so the step onto it before the
## snuff fails. A shade stays dark and stops the light. A grate stays dark and lets
## the light through, but a guard does not see through a grate. A screen is lit,
## lets the light through, and stops the sight. A pane lets the light and the sight
## through, and nobody can step on it. A curtain lets the light through, stops the
## sight, and a guard can enter it. A sill is lit and stops both the light and the
## sight. A mica stays dark, lets the light through, lets the sight through, and
## a guard cannot step on it.
##
## Baizes
## A baize is floor you may enter. It stays dark even when a lamp's diamond
## covers its tile, so you may step onto it while a lamp is lit. Standing on
## it is not a loss, because it stays dark. Light stops at a baize: tiles past
## it stay dark even when the lamp's diamond would have reached them. Sight
## does not stop at a baize: a guard sees lit tiles beyond the dark baize, even
## though the baize cell itself is dark and is not watched. A guard cannot
## enter a baize. Pathing treats it as closed, the same as a wall, so a called
## guard walks around it. A baize calls nobody. It is never a hold. A plate
## still calls only the nearest guard. A bell still calls every guard who has
## a floor path, and a baize is not that path. A baize is not a wall, a sill,
## a grate, a pane, a plate, a bell, a curtain, a shade, a screen, a glaze, or
## a mica. A mica stays dark and lets the light through. A grate stays dark,
## lets the light through, and stops the sight. A shade stays dark, stops the
## light, and stops the sight. A glaze is lit, lets the light through, and lets
## the sight through while it is lit. A screen is lit, lets the light through,
## and stops the sight. A pane lets the light and the sight through, and nobody
## can step on it. A curtain lets the light through, stops the sight, and a
## guard can enter it. A sill is lit and stops both the light and the sight.
## A baize stays dark, stops the light, lets the sight through, and a guard
## cannot step on it.
##
## Scrims
## A scrim is floor you may enter only while it is dark. A lamp lights it, the
## same way a sill, a screen, and a glaze light. An unwatched lit scrim is
## refused. Stepping onto a lit scrim a guard is watching is a loss. Standing
## on it after the lamp is snuffed is not a loss, because it is dark. Light
## stops at a scrim: the scrim itself is lit, and tiles past it stay dark even
## when the lamp's diamond would have reached them. Sight does not stop while
## the scrim is lit: a guard sees lit tiles beyond the lit scrim, and the lit
## scrim itself can be watched. When the scrim is dark, sight stops the same
## way any dark floor does. A guard cannot enter a scrim. Pathing treats it as
## closed, the same as a wall, so a called guard walks around it. A scrim calls
## nobody. It is never a hold. A plate still calls only the nearest guard. A
## bell still calls every guard who has a floor path, and a scrim is not that
## path. A scrim is not a wall, a sill, a grate, a pane, a plate, a bell, a
## curtain, a shade, a screen, a glaze, a mica, or a baize. A baize stays dark,
## stops the light, and lets the sight through. A mica stays dark, lets the
## light through, and lets the sight through. A glaze is lit, lets the light
## through, and lets the sight through while it is lit. A sill is lit, stops
## the light, and stops the sight. A screen is lit, lets the light through, and
## stops the sight. A shade stays dark, stops the light, and stops the sight.
## A grate stays dark, lets the light through, and stops the sight. A scrim is
## lit, stops the light, lets the sight through while it is lit, and a guard
## cannot step on it.
##
## Gauzes
## A gauze is the scrim with one flip: light that reaches it from another lamp
## passes through. A scrim stops that light. A gauze is floor you may enter only
## while it is dark. A lamp lights it, the same way a sill, a screen, a glaze,
## and a scrim light. An unwatched lit gauze is refused. Stepping onto a lit
## gauze a guard is watching is a loss. Standing on it after the lamp is snuffed
## is not a loss, because it is dark. A lamp standing on the gauze does not shine
## past it, the same as a lamp standing on a scrim. A second lamp's light passes
## the gauze: the gauze itself is lit, and tiles past it light even when a scrim
## would have left them dark. Sight does not stop while the gauze is lit: a guard
## sees lit tiles beyond the lit gauze, and the lit gauze itself can be watched.
## When the gauze is dark, sight stops the same way any dark floor does. A guard
## cannot enter a gauze. Pathing treats it as closed, the same as a wall, so a
## called guard walks around it. A gauze calls nobody. It is never a hold. A
## plate still calls only the nearest guard. A bell still calls every guard who
## has a floor path, and a gauze is not that path. A gauze is not a wall, a sill,
## a grate, a pane, a plate, a bell, a curtain, a shade, a screen, a glaze, a
## mica, a baize, or a scrim. A scrim is lit and stops the light. A screen is lit,
## lets the light through, and stops the sight. A shade stays dark, stops the
## light, and stops the sight. A baize stays dark, stops the light, and lets the
## sight through. A glaze is lit, lets the light through, and lets the sight
## through while it is lit. A gauze is lit, a second lamp's light passes it, the
## sight passes while it is lit, and a guard cannot step on it.
##
## Voiles
## A shade stays dark under a lamp. A mica stays dark. A baize stays dark. A grate
## stays dark. A voile does not copy that. It is the gauze with one flip: the
## early step onto the lit voile succeeds. A gauze refuses that step. A voile is
## floor a lamp lights, the same way a gauze lights. An unwatched lit voile may
## be entered. Stepping onto a lit voile a guard is watching is a loss. Standing
## on it after the lamp is snuffed is not a loss, because it is dark. A lamp
## standing on the voile does not shine past it. A second lamp's light passes
## the voile: the voile itself is lit, and tiles past it light even when a scrim
## would have left them dark. Sight does not stop while the voile is lit: a
## guard sees lit tiles beyond the lit voile, and the lit voile itself can be
## watched. When the voile is dark, sight stops the same way any dark floor
## does. A guard cannot enter a voile. Pathing treats it as closed, the same as
## a wall, so a called guard walks around it. A voile calls nobody. It is never
## a hold. A plate still calls only the nearest guard. A bell still calls every
## guard who has a floor path, and a voile is not that path. A voile is not a
## wall, a sill, a grate, a pane, a plate, a bell, a curtain, a shade, a screen,
## a glaze, a mica, a baize, a scrim, or a gauze. A gauze is lit and the early
## step onto it fails. A voile is lit, a second lamp's light passes it, the
## sight passes while it is lit, the early step onto it succeeds, and a guard
## cannot step on it.
##
## Lawns
## A lawn is the voile with one flip: a second lamp's light stops at the lawn.
## A voile lets that light pass. A scrim also stops the light, but the early step
## onto a lit scrim fails. A gauze lets the light pass and refuses the early
## step. No lit cloth already stops a second lamp and also allows the early
## step, so you still leave by stepping on the dark lawn. A lawn is floor a
## lamp lights. An unwatched lit lawn may be entered. Stepping onto a lit lawn
## a guard is watching is a loss. Standing on it after the lamp is snuffed is
## not a loss, because it is dark. Light stops at a lawn: the lawn itself is
## lit, and tiles past it stay dark even when the lamp's diamond would have
## reached them. Sight does not stop while the lawn is lit: a guard sees lit
## tiles beyond the lit lawn, and the lit lawn itself can be watched. When the
## lawn is dark, sight stops the same way any dark floor does. A guard cannot
## enter a lawn. Pathing treats it as closed, the same as a wall, so a called
## guard walks around it. A lawn calls nobody. It is never a hold. A plate
## still calls only the nearest guard. A bell still calls every guard who has a
## floor path, and a lawn is not that path. A lawn is not a wall, a sill, a
## grate, a pane, a plate, a bell, a curtain, a shade, a screen, a glaze, a
## mica, a baize, a scrim, a gauze, or a voile. A voile is lit and a second
## lamp's light passes it. A scrim is lit, stops the light, and the early step
## onto it fails. A lawn is lit, a second lamp's light stops at it, the early
## step onto it succeeds, and a guard cannot step on it.
##
## Vision
## Each guard watches a Manhattan diamond of their vision radius, and only on tiles that
## are currently lit. Walls and dark tiles block vision. A grate stays dark, so it blocks
## vision the same way any dark floor does. A shade stays dark, so it blocks vision the
## same way any dark floor does. A sill blocks vision even when it is lit, so
## a guard cannot see through it; the lit sill itself can still be watched. A curtain
## blocks vision even when it is lit and the tile past it is lit, so a guard cannot see
## through it; the lit curtain itself can still be watched. A screen
## blocks vision even when it is lit and the tile past it is lit, so a guard cannot see
## through it; the lit screen itself can still be watched. A pane does
## not block vision, even though the pane itself is never lit, so a guard sees lit tiles
## beyond it. A lit glaze does not block vision, so a guard sees lit tiles beyond it.
## A dark glaze blocks vision the same way any dark floor does. A mica stays dark, but
## vision does not stop at it, so a guard sees lit tiles beyond it. The mica cell
## itself is not watched, because it is dark. A baize stays dark and stops the
## light, but vision does not stop at it, so a guard sees lit tiles beyond it.
## The baize cell itself is not watched, because it is dark. A lit scrim does not
## block vision, so a guard sees lit tiles beyond it, and the lit scrim itself
## can be watched. A dark scrim blocks vision the same way any dark floor does.
## A lit gauze does not block vision, so a guard sees lit tiles beyond it, and
## the lit gauze itself can be watched. A dark gauze blocks vision the same way
## any dark floor does.
## A lit voile does not block vision, so a guard sees lit tiles beyond it, and
## the lit voile itself can be watched. A dark voile blocks vision the same way
## any dark floor does.
## A lit lawn does not block vision, so a guard sees lit tiles beyond it, and
## the lit lawn itself can be watched. A dark lawn blocks vision the same way
## any dark floor does.
## A guard standing in the dark can still look into an adjacent lit tile. The
## guard's own tile is not marked watched; standing on the guard is a separate loss.
##
## Guards
## Alerted guards take one step along a shortest 4-neighbor path to the tile they were
## called to, a lamp, a plate, or a bell. Neighbors are expanded north, east, south,
## then west, and that order breaks ties. They may walk on floor, plate, bell, exit,
## and curtain tiles, lit or dark, but not through walls, gaps, grates, sills, panes, shades, screens, glazes, micas, baizes, scrims, gauzes, voiles, or lawns. When they step onto that tile
## they hold there. They do not resume the rail unless a later snuff, plate, or bell calls them.
## A guard who is not alert and not holding patrols their rail. The rail is a list of
## waypoints. rail_index is the waypoint they are walking toward, and rail_dir is +1 or -1.
## On reaching that waypoint they advance the index, reversing at either end. A rail with
## fewer than two waypoints means they stand still until called.
##
## Undo
## A snapshot taken before each accepted action restores the player's position and facing,
## every lamp's lit flag, and every guard's position, rail index, rail direction, alert
## target, and hold flag.

enum Tile { WALL, FLOOR, GAP, EXIT, PLATE, BELL, GRATE, SILL, PANE, CURTAIN, SHADE, SCREEN, GLAZE, MICA, BAIZE, SCRIM, GAUZE, VOILE, LAWN }
enum Result { OK, WIN, LOSS, ILLEGAL }

const DIRS := [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]
const FACING := {
	"n": Vector2i(0, -1),
	"e": Vector2i(1, 0),
	"s": Vector2i(0, 1),
	"w": Vector2i(-1, 0),
}


static func build(rows: PackedStringArray, lamps: Array, guards: Array) -> Dictionary:
	var height := rows.size()
	var width := rows[0].length()
	var tiles: Array = []
	tiles.resize(width * height)
	var player := {"x": 1, "y": 1, "fx": 1, "fy": 0}
	for y in height:
		var row: String = rows[y]
		if row.length() != width:
			push_error("ragged row %d" % y)
		for x in width:
			var ch := row.substr(x, 1)
			var kind := Tile.WALL
			match ch:
				"#":
					kind = Tile.WALL
				".":
					kind = Tile.FLOOR
				"G":
					kind = Tile.GAP
				"X":
					kind = Tile.EXIT
				"S":
					kind = Tile.FLOOR
					player = {"x": x, "y": y, "fx": 1, "fy": 0}
				"P":
					kind = Tile.PLATE
				"B":
					kind = Tile.BELL
				"R":
					kind = Tile.GRATE
				"I":
					kind = Tile.SILL
				"A":
					kind = Tile.PANE
				"C":
					kind = Tile.CURTAIN
				"H":
					kind = Tile.SHADE
				"E":
					kind = Tile.SCREEN
				"Z":
					kind = Tile.GLAZE
				"M":
					kind = Tile.MICA
				"J":
					kind = Tile.BAIZE
				"K":
					kind = Tile.SCRIM
				"Q":
					kind = Tile.GAUZE
				"V":
					kind = Tile.VOILE
				"L":
					kind = Tile.LAWN
				_:
					push_error("bad tile '%s'" % ch)
			tiles[y * width + x] = kind
	var lamp_list: Array = []
	for i in lamps.size():
		var src: Dictionary = lamps[i]
		var face: Vector2i = FACING[src["facing"]]
		lamp_list.append({
			"id": i,
			"x": int(src["x"]),
			"y": int(src["y"]),
			"facing": src["facing"],
			"fx": face.x,
			"fy": face.y,
			"radius": int(src["radius"]),
			"lit": bool(src.get("lit", true)),
		})
	var guard_list: Array = []
	for i in guards.size():
		var src: Dictionary = guards[i]
		var rail: Array = []
		for point in src["rail"]:
			rail.append(Vector2i(point))
		guard_list.append({
			"id": i,
			"x": int(src["x"]),
			"y": int(src["y"]),
			"vision": int(src.get("vision", 2)),
			"rail": rail,
			"rail_index": int(src.get("rail_index", 0)),
			"rail_dir": int(src.get("rail_dir", 1)),
			"alert": false,
			"ax": 0,
			"ay": 0,
			"holding": false,
		})
	return {
		"w": width,
		"h": height,
		"tiles": tiles,
		"player": player,
		"lamps": lamp_list,
		"guards": guard_list,
	}


static func clone(state: Dictionary) -> Dictionary:
	return state.duplicate(true)


static func signature(state: Dictionary) -> String:
	var player: Dictionary = state["player"]
	var parts: PackedStringArray = PackedStringArray()
	parts.append("P:%d,%d,%d,%d" % [player["x"], player["y"], player["fx"], player["fy"]])
	for lamp in state["lamps"]:
		var lit_bit := 1 if lamp["lit"] else 0
		parts.append("L%d:%d,%d,%s,%d,%d" % [
			lamp["id"], lamp["x"], lamp["y"], lamp["facing"], lamp["radius"], lit_bit
		])
	for guard in state["guards"]:
		var rail_bits: PackedStringArray = PackedStringArray()
		for point in guard["rail"]:
			var cell: Vector2i = point
			rail_bits.append("%d,%d" % [cell.x, cell.y])
		var alert_bit := 1 if guard["alert"] else 0
		var hold_bit := 1 if guard["holding"] else 0
		parts.append("G%d:%d,%d,v%d,ri%d,rd%d,a%d,t%d,%d,h%d,rail%s" % [
			guard["id"], guard["x"], guard["y"], guard["vision"],
			guard["rail_index"], guard["rail_dir"],
			alert_bit, guard["ax"], guard["ay"],
			hold_bit, "+".join(rail_bits),
		])
	return "|".join(parts)


static func tile_at(state: Dictionary, x: int, y: int) -> int:
	if x < 0 or y < 0 or x >= state["w"] or y >= state["h"]:
		return -1
	return state["tiles"][y * state["w"] + x]


static func is_win(state: Dictionary) -> bool:
	var player: Dictionary = state["player"]
	return tile_at(state, player["x"], player["y"]) == Tile.EXIT


static func in_diamond(lamp: Dictionary, x: int, y: int) -> bool:
	var dx := x - int(lamp["x"])
	var dy := y - int(lamp["y"])
	if absi(dx) + absi(dy) > int(lamp["radius"]):
		return false
	if dx * int(lamp["fx"]) + dy * int(lamp["fy"]) < 0:
		return false
	return true


static func lamp_lights(state: Dictionary, lamp: Dictionary) -> Array:
	var lit: Array = []
	if not lamp["lit"]:
		return lit
	var seen := {}
	var queue: Array = []
	var origin := Vector2i(lamp["x"], lamp["y"])
	var origin_kind := tile_at(state, origin.x, origin.y)
	if origin_kind != Tile.WALL and origin_kind != -1 and in_diamond(lamp, origin.x, origin.y):
		seen[origin] = true
		queue.append(origin)
	# A lamp standing on a sill, a shade, a baize, a scrim, or a gauze does not shine past that tile.
	# Every other lamp still seeds its neighbors. A grate and a pane let the flood through.
	if origin_kind != Tile.SILL and origin_kind != Tile.SHADE and origin_kind != Tile.BAIZE and origin_kind != Tile.SCRIM and origin_kind != Tile.GAUZE and origin_kind != Tile.VOILE and origin_kind != Tile.LAWN:
		for dir in DIRS:
			var nxt: Vector2i = origin + dir
			var seed_kind := tile_at(state, nxt.x, nxt.y)
			if seed_kind == -1 or seed_kind == Tile.WALL:
				continue
			if not in_diamond(lamp, nxt.x, nxt.y):
				continue
			if seen.has(nxt):
				continue
			seen[nxt] = true
			queue.append(nxt)
	var head := 0
	while head < queue.size():
		var cell: Vector2i = queue[head]
		head += 1
		var cell_kind := tile_at(state, cell.x, cell.y)
		# A grate stays dark and lets the flood through. A pane does too, and the pane
		# itself is never lit. A sill is lit, and the flood stops there. A curtain is
		# lit, and the flood does not stop there, so tiles past it still light. A shade
		# stays dark, and the flood stops there, so tiles past it stay dark. A screen is
		# lit, and the flood does not stop there, so tiles past it still light. A glaze
		# is lit, and the flood does not stop there, so tiles past it still light. Sight
		# through a glaze is ordinary floor sight: open while the glaze is lit, and
		# closed while it is dark. A mica stays dark, and the flood does not stop
		# there, so tiles past it still light. A baize stays dark, and the flood
		# stops there, so tiles past it stay dark. A scrim is lit, and the flood
		# stops there, so tiles past it stay dark. A gauze is lit. A flood that
		# reaches the gauze from another tile passes through. A lamp standing on
		# the gauze does not shine past it. A voile is lit the same way. A flood
		# that reaches the voile from another tile passes through. A lamp
		# standing on the voile does not shine past it. A lawn is lit, and the
		# flood stops there, so a second lamp's light does not pass it.
		if cell_kind != Tile.GRATE and cell_kind != Tile.PANE and cell_kind != Tile.SHADE and cell_kind != Tile.MICA and cell_kind != Tile.BAIZE:
			lit.append(cell)
		if (cell_kind == Tile.GAUZE or cell_kind == Tile.VOILE) and cell == origin:
			continue
		if cell_kind == Tile.SILL or cell_kind == Tile.SHADE or cell_kind == Tile.BAIZE or cell_kind == Tile.SCRIM or cell_kind == Tile.LAWN:
			continue
		for dir in DIRS:
			var nxt: Vector2i = cell + dir
			if seen.has(nxt):
				continue
			var flood_kind := tile_at(state, nxt.x, nxt.y)
			if flood_kind == -1 or flood_kind == Tile.WALL:
				continue
			if not in_diamond(lamp, nxt.x, nxt.y):
				continue
			seen[nxt] = true
			queue.append(nxt)
	return lit


static func light_map(state: Dictionary) -> Dictionary:
	var lit := {}
	for lamp in state["lamps"]:
		for cell in lamp_lights(state, lamp):
			lit[cell] = true
	return lit


static func watched_tiles(state: Dictionary, lit: Dictionary = {}) -> Dictionary:
	var lights := lit
	if lights.is_empty():
		lights = light_map(state)
	var watched := {}
	for guard in state["guards"]:
		var origin := Vector2i(guard["x"], guard["y"])
		var queue: Array = [{"cell": origin, "dist": 0}]
		var seen := {origin: true}
		var head := 0
		while head < queue.size():
			var item: Dictionary = queue[head]
			head += 1
			var cell: Vector2i = item["cell"]
			var dist: int = item["dist"]
			if dist > 0 and lights.has(cell):
				watched[cell] = true
			# A sill can be watched, but vision does not pass through it.
			# A curtain can be watched, but vision does not pass through it, even when
			# the curtain is lit and the tile past it is lit. A guard standing on a
			# curtain can still look out from it. A screen can be watched, but vision
			# does not pass through it, even when the screen is lit and the tile past
			# it is lit. A guard standing on a screen can still look out from it. A pane
			# is never lit, and vision passes. A lit glaze is ordinary lit floor for
			# vision, so sight passes to the lit tiles beyond it. A dark glaze is
			# ordinary dark floor, so sight stops there. A mica stays dark, and vision
			# passes, so a guard sees lit tiles beyond it. The mica cell itself is not
			# watched, because it is never lit. A baize stays dark, and vision
			# passes, so a guard sees lit tiles beyond it. The baize cell itself
			# is not watched, because it is never lit. A lit scrim is ordinary
			# lit floor for vision, so sight passes and the scrim itself can be
			# watched. A dark scrim is ordinary dark floor, so sight stops there.
			# A lit gauze is ordinary lit floor for vision, so sight passes and
			# the gauze itself can be watched. A dark gauze is ordinary dark
			# floor, so sight stops there.
			var kind := tile_at(state, cell.x, cell.y)
			if kind == Tile.SILL or ((kind == Tile.CURTAIN or kind == Tile.SCREEN) and dist > 0):
				continue
			if dist >= int(guard["vision"]):
				continue
			var source_open := dist == 0 or lights.has(cell) or kind == Tile.PANE or kind == Tile.MICA or kind == Tile.BAIZE
			if not source_open:
				continue
			for dir in DIRS:
				var nxt: Vector2i = cell + dir
				if seen.has(nxt):
					continue
				var nxt_kind := tile_at(state, nxt.x, nxt.y)
				if nxt_kind == -1 or nxt_kind == Tile.WALL:
					continue
				if absi(nxt.x - origin.x) + absi(nxt.y - origin.y) > int(guard["vision"]):
					continue
				if not lights.has(nxt) and nxt_kind != Tile.PANE and nxt_kind != Tile.MICA and nxt_kind != Tile.BAIZE:
					continue
				seen[nxt] = true
				queue.append({"cell": nxt, "dist": dist + 1})
	return watched


static func is_player_watched(state: Dictionary) -> bool:
	var player: Dictionary = state["player"]
	return watched_tiles(state).has(Vector2i(player["x"], player["y"]))


static func shares_tile_with_guard(state: Dictionary) -> bool:
	var player: Dictionary = state["player"]
	for guard in state["guards"]:
		if guard["x"] == player["x"] and guard["y"] == player["y"]:
			return true
	return false


static func loss_reason(state: Dictionary, lit: Dictionary = {}) -> String:
	if shares_tile_with_guard(state):
		return "guard"
	var lights := lit if not lit.is_empty() else light_map(state)
	var player: Dictionary = state["player"]
	if watched_tiles(state, lights).has(Vector2i(player["x"], player["y"])):
		return "watched"
	return ""


static func guard_walkable(state: Dictionary, x: int, y: int) -> bool:
	var kind := tile_at(state, x, y)
	return kind == Tile.FLOOR or kind == Tile.EXIT or kind == Tile.PLATE or kind == Tile.BELL or kind == Tile.CURTAIN


static func bfs_path(state: Dictionary, sx: int, sy: int, gx: int, gy: int) -> Dictionary:
	var start := Vector2i(sx, sy)
	var goal := Vector2i(gx, gy)
	if start == goal:
		return {"step": start, "path": [start]}
	var queue: Array = [start]
	var parent := {start: Vector2i(-999, -999)}
	var head := 0
	while head < queue.size():
		var cell: Vector2i = queue[head]
		head += 1
		for dir in DIRS:
			var nxt: Vector2i = cell + dir
			if parent.has(nxt):
				continue
			if not guard_walkable(state, nxt.x, nxt.y):
				continue
			parent[nxt] = cell
			if nxt == goal:
				var path: Array = [goal]
				var cursor := cell
				while cursor != Vector2i(-999, -999):
					path.append(cursor)
					cursor = parent[cursor]
				path.reverse()
				return {"step": path[1], "path": path}
			queue.append(nxt)
	return {"step": start, "path": [start]}


static func _advance_rail(guard: Dictionary) -> void:
	var rail: Array = guard["rail"]
	if rail.size() < 2:
		return
	var here := Vector2i(guard["x"], guard["y"])
	var target: Vector2i = rail[guard["rail_index"]]
	if here != target:
		return
	var nxt: int = int(guard["rail_index"]) + int(guard["rail_dir"])
	if nxt < 0 or nxt >= rail.size():
		guard["rail_dir"] = -int(guard["rail_dir"])
		nxt = int(guard["rail_index"]) + int(guard["rail_dir"])
	guard["rail_index"] = nxt


static func plan_guard(state: Dictionary, guard: Dictionary) -> Dictionary:
	var ng: Dictionary = guard.duplicate(true)
	var step := Vector2i(ng["x"], ng["y"])
	var path: Array = [step]
	if ng["alert"]:
		var target := Vector2i(ng["ax"], ng["ay"])
		if step == target:
			ng["alert"] = false
			ng["holding"] = true
			return {"guard": ng, "step": step, "path": path}
		var found := bfs_path(state, step.x, step.y, target.x, target.y)
		step = found["step"]
		path = found["path"]
		ng["x"] = step.x
		ng["y"] = step.y
		if step == target:
			ng["alert"] = false
			ng["holding"] = true
		return {"guard": ng, "step": step, "path": path}
	if ng["holding"] or ng["rail"].size() < 2:
		return {"guard": ng, "step": step, "path": path}
	_advance_rail(ng)
	var waypoint: Vector2i = ng["rail"][ng["rail_index"]]
	var found_rail := bfs_path(state, ng["x"], ng["y"], waypoint.x, waypoint.y)
	step = found_rail["step"]
	path = found_rail["path"]
	ng["x"] = step.x
	ng["y"] = step.y
	return {"guard": ng, "step": step, "path": path}


static func planned_step(state: Dictionary, guard_index: int) -> Vector2i:
	return plan_guard(state, state["guards"][guard_index])["step"]


static func planned_path(state: Dictionary, guard_index: int) -> Array:
	return plan_guard(state, state["guards"][guard_index])["path"]


static func nearest_guard(state: Dictionary, lamp: Dictionary) -> int:
	var ids: Array = []
	for guard in state["guards"]:
		ids.append(int(guard["id"]))
	return nearest_guard_among(state, ids, int(lamp["x"]), int(lamp["y"]))


static func nearest_guard_among(state: Dictionary, ids: Array, x: int, y: int) -> int:
	var best := -1
	var best_dist := 1 << 30
	for id in ids:
		var guard: Dictionary = state["guards"][int(id)]
		var dist := absi(int(guard["x"]) - x) + absi(int(guard["y"]) - y)
		if dist < best_dist or (dist == best_dist and (best == -1 or int(id) < best)):
			best = int(id)
			best_dist = dist
	return best


static func guard_can_reach(state: Dictionary, guard: Dictionary, tx: int, ty: int) -> bool:
	var sx := int(guard["x"])
	var sy := int(guard["y"])
	if sx == tx and sy == ty:
		return true
	var found := bfs_path(state, sx, sy, tx, ty)
	var path: Array = found["path"]
	if path.size() < 2:
		return false
	var last: Vector2i = path[path.size() - 1]
	return last.x == tx and last.y == ty


static func bell_guards(state: Dictionary, x: int, y: int) -> Array:
	var ids: Array = []
	for guard in state["guards"]:
		if guard_can_reach(state, guard, x, y):
			ids.append(int(guard["id"]))
	return ids


static func apply(state: Dictionary, action: Dictionary, allow_toggle: bool = true) -> Dictionary:
	var kind := str(action.get("type", ""))
	if kind == "toggle" and not allow_toggle:
		return _finish(state, Result.ILLEGAL, -1, Vector2i(-1, -1), "toggle")
	var st := state.duplicate(true)
	var player: Dictionary = st["player"]
	var pending_ids: Array = []
	var pending_target := Vector2i.ZERO
	var pending_report := -1
	if kind == "wait":
		pass
	elif kind == "move":
		var dx := int(action["dx"])
		var dy := int(action["dy"])
		var nx := int(player["x"]) + dx
		var ny := int(player["y"]) + dy
		var dest := tile_at(st, nx, ny)
		if dest == -1 or dest == Tile.WALL:
			return _finish(state, Result.ILLEGAL, -1, Vector2i(-1, -1), "wall")
		if dest == Tile.PANE:
			return _finish(state, Result.ILLEGAL, -1, Vector2i(-1, -1), "pane")
		var lit := light_map(st)
		var watch := watched_tiles(st, lit)
		if watch.has(Vector2i(nx, ny)):
			player["x"] = nx
			player["y"] = ny
			player["fx"] = dx
			player["fy"] = dy
			return _finish(st, Result.LOSS, -1, Vector2i(-1, -1), "watched")
		if dest == Tile.GAP:
			if not lit.has(Vector2i(nx, ny)):
				return _finish(state, Result.ILLEGAL, -1, Vector2i(-1, -1), "darkgap")
		elif dest == Tile.GRATE or dest == Tile.SHADE or dest == Tile.MICA or dest == Tile.BAIZE or dest == Tile.VOILE or dest == Tile.LAWN:
			pass
		elif dest == Tile.FLOOR or dest == Tile.EXIT or dest == Tile.PLATE or dest == Tile.BELL or dest == Tile.SILL or dest == Tile.CURTAIN or dest == Tile.SCREEN or dest == Tile.GLAZE or dest == Tile.SCRIM or dest == Tile.GAUZE:
			if lit.has(Vector2i(nx, ny)):
				return _finish(state, Result.ILLEGAL, -1, Vector2i(-1, -1), "lit")
		else:
			return _finish(state, Result.ILLEGAL, -1, Vector2i(-1, -1), "wall")
		for guard in st["guards"]:
			if guard["x"] == nx and guard["y"] == ny:
				player["x"] = nx
				player["y"] = ny
				player["fx"] = dx
				player["fy"] = dy
				return _finish(st, Result.LOSS, -1, Vector2i(-1, -1), "guard")
		player["x"] = nx
		player["y"] = ny
		player["fx"] = dx
		player["fy"] = dy
		if dest == Tile.PLATE:
			var plate_guard := nearest_guard(st, {"x": nx, "y": ny})
			if plate_guard >= 0:
				pending_ids = [plate_guard]
				pending_target = Vector2i(nx, ny)
				pending_report = plate_guard
		elif dest == Tile.BELL:
			pending_target = Vector2i(nx, ny)
			pending_ids = bell_guards(st, nx, ny)
			pending_report = nearest_guard_among(st, pending_ids, nx, ny)
	elif kind == "toggle":
		var index := int(action["lamp"])
		var lamp_list: Array = st["lamps"]
		if index < 0 or index >= lamp_list.size():
			return _finish(state, Result.ILLEGAL, -1, Vector2i(-1, -1), "lamp")
		var lamp: Dictionary = lamp_list[index]
		if absi(int(lamp["x"]) - int(player["x"])) + absi(int(lamp["y"]) - int(player["y"])) != 1:
			return _finish(state, Result.ILLEGAL, -1, Vector2i(-1, -1), "range")
		var here := tile_at(st, player["x"], player["y"])
		if here != Tile.FLOOR and here != Tile.EXIT and here != Tile.PLATE and here != Tile.BELL and here != Tile.GRATE and here != Tile.SILL and here != Tile.CURTAIN and here != Tile.SHADE and here != Tile.SCREEN and here != Tile.GLAZE and here != Tile.MICA and here != Tile.BAIZE and here != Tile.SCRIM and here != Tile.GAUZE and here != Tile.VOILE and here != Tile.LAWN:
			return _finish(state, Result.ILLEGAL, -1, Vector2i(-1, -1), "range")
		var was_lit: bool = lamp["lit"]
		lamp["lit"] = not was_lit
		player["fx"] = int(lamp["x"]) - int(player["x"])
		player["fy"] = int(lamp["y"]) - int(player["y"])
		if was_lit:
			var snuff_guard := nearest_guard(st, lamp)
			if snuff_guard >= 0:
				pending_ids = [snuff_guard]
				pending_target = Vector2i(lamp["x"], lamp["y"])
				pending_report = snuff_guard
	else:
		return _finish(state, Result.ILLEGAL, -1, Vector2i(-1, -1), "action")

	var lit_now := light_map(st)
	var why := loss_reason(st, lit_now)
	if why != "":
		return _finish(st, Result.LOSS, -1, Vector2i(-1, -1), why)
	if tile_at(st, player["x"], player["y"]) == Tile.EXIT:
		return _finish(st, Result.WIN, -1, Vector2i(-1, -1), "exit")

	for i in st["guards"].size():
		var planned := plan_guard(st, st["guards"][i])
		st["guards"][i] = planned["guard"]
	for id in pending_ids:
		var called: Dictionary = st["guards"][int(id)]
		called["alert"] = true
		called["ax"] = pending_target.x
		called["ay"] = pending_target.y
		called["holding"] = false
	var step := Vector2i(-1, -1)
	if pending_report >= 0:
		step = planned_step(st, pending_report)
	lit_now = light_map(st)
	why = loss_reason(st, lit_now)
	if why != "":
		return _finish(st, Result.LOSS, pending_report, step, why)
	return _finish(st, Result.OK, pending_report, step, "")


static func _finish(state: Dictionary, result: int, called: int, step: Vector2i, reason: String) -> Dictionary:
	return {
		"state": state,
		"result": result,
		"called": called,
		"step": step,
		"reason": reason,
	}
