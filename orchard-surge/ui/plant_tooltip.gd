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
	if bool(stats["cowls_veil"]):
		lines.append("Cowl: %dpx" % int(round(float(stats["light_radius"]))))
	elif bool(stats["hoods_pall"]):
		lines.append("Hood: %dpx" % int(round(float(stats["light_radius"]))))
	elif bool(stats["cloaks_gloom"]):
		lines.append("Cloak: %dpx" % int(round(float(stats["light_radius"]))))
	elif bool(stats["capes_murk"]):
		lines.append("Cape: %dpx" % int(round(float(stats["light_radius"]))))
	elif bool(stats["shawls_dread"]):
		lines.append("Shawl: %dpx" % int(round(float(stats["light_radius"]))))
	elif bool(stats["stoles_woe"]):
		lines.append("Stole: %dpx" % int(round(float(stats["light_radius"]))))
	elif bool(stats["casts_light"]):
		lines.append("Light: %dpx" % int(round(float(stats["light_radius"]))))
	else:
		lines.append("Shade: %dpx" % int(round(float(stats["light_radius"]))))
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
	if bool(stats["strips_scale"]):
		lines.append("Scale: strips")
	else:
		lines.append("Scale: none")
	if bool(stats["cracks_mail"]):
		lines.append("Mail: cracks")
	else:
		lines.append("Mail: none")
	if bool(stats["splits_hide"]):
		lines.append("Hide: splits")
	else:
		lines.append("Hide: none")
	if bool(stats["shades_dusk"]):
		lines.append("Dusk: shades")
	else:
		lines.append("Dusk: none")
	if bool(stats["cowls_veil"]):
		lines.append("Veil: cowls")
	else:
		lines.append("Veil: none")
	if bool(stats["hoods_pall"]):
		lines.append("Pall: hoods")
	else:
		lines.append("Pall: none")
	if bool(stats["cloaks_gloom"]):
		lines.append("Gloom: cloaks")
	else:
		lines.append("Gloom: none")
	if bool(stats["capes_murk"]):
		lines.append("Murk: capes")
	else:
		lines.append("Murk: none")
	if bool(stats["shawls_dread"]):
		lines.append("Dread: shawls")
	else:
		lines.append("Dread: none")
	if bool(stats["stoles_woe"]):
		lines.append("Woe: stoles")
	else:
		lines.append("Woe: none")
	return lines
