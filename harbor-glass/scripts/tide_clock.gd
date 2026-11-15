extends Control
class_name TideClock

const Palette := preload("res://scripts/palette.gd")

# A glass tube. Water fills from the bottom by the share of rows under the line.

var phases: Array = [0]
var phase_index := 0
var rows := 1
var marked := false
var _pulse := 0.0

func _process(_delta: float) -> void:
	_pulse = 0.5 + 0.5 * sin(Time.get_ticks_msec() / 1000.0 * 3.4)
	queue_redraw()

func _draw() -> void:
	var font := ThemeDB.fallback_font
	var tube := Rect2(4, 8, 22, maxf(size.y - 16.0, 24.0))
	draw_rect(tube, Color("0c1c28"))
	draw_rect(tube, Color("9fd0dc"), false, 2.0)
	var flood := 0
	if phase_index >= 0 and phase_index < phases.size():
		flood = int(phases[phase_index])
	var span := maxi(rows, 1)
	var fill_h := tube.size.y * float(flood) / float(span)
	if fill_h > 0.0:
		var fill := Rect2(tube.position.x + 3.0, tube.position.y + tube.size.y - fill_h, tube.size.x - 6.0, fill_h)
		draw_rect(fill, Color("1c86a8"))
		draw_line(
			Vector2(fill.position.x, fill.position.y),
			Vector2(fill.position.x + fill.size.x, fill.position.y),
			Palette.FOAM,
			2.0
		)
	# Names live in the readout under the tube. Ticks stay on the glass so
	# three close waterlines do not pile their words on top of each other.
	for i in phases.size():
		var f := int(phases[i])
		var y := tube.position.y + tube.size.y - tube.size.y * float(f) / float(span)
		var col := Palette.SELECT if i == phase_index else Palette.MUTED
		draw_line(Vector2(tube.end.x + 8.0, y), Vector2(tube.end.x + 20.0, y), col, 2.0)
	if font and phases.size() <= 1:
		draw_string(font, Vector2(tube.end.x + 28.0, tube.position.y + tube.size.y * 0.62), "Holding", HORIZONTAL_ALIGNMENT_LEFT, 160.0, 14, Palette.MUTED)
	if marked:
		var glow := Palette.HINT
		glow.a = 0.35 + 0.65 * _pulse
		draw_rect(tube.grow(5.0), glow, false, 3.0)
