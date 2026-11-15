extends RefCounted

## Player-facing plant text. Every number is formatted from PlantCatalog.

const Catalog = preload("res://sim/plant_catalog.gd")


static func stat_lines(kind: int) -> PackedStringArray:
	var stats := Catalog.get_stats(kind)
	var lines := PackedStringArray()
	lines.append(str(stats["name"]))
	lines.append(str(stats["role"]))
	lines.append("Damage: %d" % int(stats["damage"]))
	lines.append("Fire: %.2fs" % float(stats["fire_interval"]))
	lines.append("Light: %dpx" % int(round(float(stats["light_radius"]))))
	if int(stats["slow_ticks"]) > 0:
		lines.append("Slow: %.2f for %.2fs" % [float(stats["slow_factor"]), float(stats["slow_duration"])])
	else:
		lines.append("Slow: none")
	if float(stats["splash_radius"]) > 0.0:
		lines.append("Splash: %dpx" % int(round(float(stats["splash_radius"]))))
	else:
		lines.append("Splash: none")
	if bool(stats["burns_shroud"]):
		lines.append("Shroud: burns")
	else:
		lines.append("Shroud: none")
	return lines
