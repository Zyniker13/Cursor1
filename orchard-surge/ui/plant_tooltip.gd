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
	if bool(stats["cracks_rind"]):
		lines.append("Rind: cracks")
	else:
		lines.append("Rind: none")
	if bool(stats["melts_pitch"]):
		lines.append("Pitch: melts")
	else:
		lines.append("Pitch: none")
	if bool(stats["thaws_frost"]):
		lines.append("Frost: thaws")
	else:
		lines.append("Frost: none")
	if bool(stats["cuts_web"]):
		lines.append("Web: cuts")
	else:
		lines.append("Web: none")
	if bool(stats["cracks_glass"]):
		lines.append("Glass: cracks")
	else:
		lines.append("Glass: none")
	return lines
