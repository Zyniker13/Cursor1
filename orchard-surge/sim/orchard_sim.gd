extends RefCounted

## Fixed-timestep orchard combat. No SceneTree, no drawing, no input devices.
## Given the same seed and the same command each tick, the run is deterministic.
## The scene only reads this state and sends commands.
## Shroud moths stay hidden in ordinary light and ignore shots until a wick burns their tile.
## Rind moths stay hidden until a briar cracks their tile.
## Pitch moths stay hidden until a flare melts their tile.
## Frost moths stay hidden until a hearth thaws their tile.
## Web moths stay hidden until a shear cuts their tile.
## Glass moths stay hidden until a chime cracks their tile.
## Scale moths stay hidden until a rasp strips their tile.
## Mail moths stay hidden until a maul cracks their tile.
## Hide moths stay hidden until a bill splits their tile. A moth can carry more than one lock.
## Dusk moths stay sealed until a shade covers their tile. The shade is not a light.
## No other plant opens dusk. Outside the shade the dusk seals again.
## Veil moths stay sealed until a cowl covers their tile. The cowl is not a light.
## No other plant opens veil. Outside the cowl the veil seals again.
## Pall moths stay sealed until a hood covers their tile. The hood is not a light.
## No other plant opens pall. Outside the hood the pall seals again.
## Gloom moths stay sealed until a cloak covers their tile. The cloak is not a light.
## No other plant opens gloom. Outside the cloak the gloom seals again.
## Murk moths stay sealed until a cape covers their tile. The cape is not a light.
## No other plant opens murk. Outside the cape the murk seals again.
## Dread moths stay sealed until a shawl covers their tile. The shawl is not a light.
## No other plant opens dread. Outside the shawl the dread seals again.
## Woe moths stay sealed until a stole covers their tile. The stole is not a light.
## No other plant opens woe. Outside the stole the woe seals again.
## Blight moths stay sealed until a mantle covers their tile. The mantle is not a light.
## No other plant opens blight. Outside the mantle the blight seals again.
## Rot moths stay sealed until a tippet covers their tile. The tippet is not a light.
## No other plant opens rot. Outside the tippet the rot seals again.
## Mildew moths stay sealed until a wimple covers their tile. The wimple is not a light.
## No other plant opens mildew. Outside the wimple the mildew seals again.
## Rust moths stay sealed until an alb covers their tile. The alb is not a light.
## No other plant opens rust. Outside the alb the rust seals again.
## Scab moths stay sealed until an amice covers their tile. The amice is not a light.
## No other plant opens scab. Outside the amice the scab seals again.
## Spot moths stay sealed until an orphrey covers their tile. The orphrey is not a light.
## No other plant opens spot. Outside the orphrey the spot seals again.
## Scald moths stay sealed until a maniple covers their tile. The maniple is not a light.
## No other plant opens scald. Outside the maniple the scald seals again.

const Catalog = preload("res://sim/plant_catalog.gd")

const DT := Catalog.DT
const MAP_W := 15
const MAP_H := 11
const TILE := 48.0

const PHASE_PLANT := 0
const PHASE_WAVE := 1
const OUTCOME_RUNNING := 0
const OUTCOME_WON := 1
const OUTCOME_LOST := 2

const PLAYER_HP := 100
const PLAYER_SPEED := 130.0
const PLAYER_RADIUS := 12.0
const CONTACT_DAMAGE := 20
const HURT_TICKS := 12
const PEST_HP := 12
const PEST_SPEED := 42.0
const PEST_RADIUS := 11.0
const START_SEEDS := 30
const PLANT_TICKS := 240
const WAVE_COUNT := 61
const START_CELL := Vector2i(7, 5)
const PROJECTILE_RADIUS := 4.0
const PROJECTILE_LIFE := 75

# Nights 1–3 are the original waves. Nights 4 and 5 bring shroud moths, not a boss.
# Nights 6 and 7 bring rind moths. Night 7 sends rind and shroud on the same moths.
# Nights 8 and 9 bring pitch moths. Night 9 sends pitch, rind, and shroud together.
# Nights 10 and 11 bring frost moths. Night 11 sends frost, pitch, rind, and shroud together.
# Nights 12 and 13 bring web moths. Night 13 sends web, frost, pitch, rind, and shroud together.
# Nights 14 and 15 bring glass moths. Night 15 sends glass, web, frost, pitch, rind, and shroud together.
# Nights 16 and 17 bring scale moths. Night 17 sends scale, glass, web, frost, pitch, rind, and shroud together.
# Nights 18 and 19 bring mail moths. Night 19 sends mail, scale, glass, web, frost, pitch, rind, and shroud together.
# Nights 20 and 21 bring hide moths. Night 21 sends hide, mail, scale, glass, web, frost, pitch, rind, and shroud together.
# Nights 22 and 23 bring dusk moths. Night 23 sends dusk, hide, mail, scale, glass, web, frost, pitch, rind, and shroud together.
# Nights 24 and 25 bring veil moths. Night 25 sends veil, dusk, hide, mail, scale, glass, web, frost, pitch, rind, and shroud together.
# Nights 26 and 27 bring pall moths. Night 27 sends pall, veil, dusk, hide, mail, scale, glass, web, frost, pitch, rind, and shroud together.
# Nights 28 and 29 bring gloom moths. Night 29 sends gloom, pall, veil, dusk, hide, mail, scale, glass, web, frost, pitch, rind, and shroud together.
# Nights 30 and 31 bring murk moths. Night 31 sends murk, gloom, pall, veil, dusk, hide, mail, scale, glass, web, frost, pitch, rind, and shroud together.
# Nights 32 and 33 bring dread moths. Night 33 sends dread, murk, gloom, pall, veil, dusk, hide, mail, scale, glass, web, frost, pitch, rind, and shroud together.
# Nights 34 and 35 bring woe moths. Night 34 is woe alone. Night 35 sends woe, dread, murk, gloom, pall, veil, dusk, hide, mail, scale, glass, web, frost, pitch, rind, and shroud together.
# Nights 36 and 37 bring blight moths. Night 36 is blight alone. Night 37 sends blight, woe, dread, murk, gloom, pall, veil, dusk, hide, mail, scale, glass, web, frost, pitch, rind, and shroud together.
# Nights 38 and 39 bring rot moths. Night 38 is rot alone. Night 39 sends rot, blight, woe, dread, murk, gloom, pall, veil, dusk, hide, mail, scale, glass, web, frost, pitch, rind, and shroud together.
# Nights 40 and 41 bring mildew moths. Night 40 is mildew alone. Night 41 sends mildew, rot, blight, woe, dread, murk, gloom, pall, veil, dusk, hide, mail, scale, glass, web, frost, pitch, rind, and shroud together.
# Nights 42 and 43 bring rust moths. Night 42 is rust alone. Night 43 sends rust, mildew, rot, blight, woe, dread, murk, gloom, pall, veil, dusk, hide, mail, scale, glass, web, frost, pitch, rind, and shroud together.
# Nights 44 and 45 bring scab moths. Night 44 is scab alone. Night 45 sends scab, rust, mildew, rot, blight, woe, dread, murk, gloom, pall, veil, dusk, hide, mail, scale, glass, web, frost, pitch, rind, and shroud together.
# Nights 46 and 47 bring spot moths. Night 46 is spot alone. Night 47 sends spot together with every Blotch lock. The moth count stays 16; spot is a lock on every one of those moths.
# Nights 48 and 49 bring scald moths. Night 48 is scald alone. Night 49 sends scald together with every Scorch lock. The moth count stays 16; scald is a lock on every one of those moths.
# Nights 50 and 51 bring blister moths. Night 50 is blister alone. Night 51 sends blister together with every Sear lock. The moth count stays 16; blister is a lock on every one of those moths.
# Nights 52 and 53 bring char moths. Night 52 is char alone. Night 53 sends char together with every Weal lock. The moth count stays 16; char is a lock on every one of those moths.
# Nights 54 and 55 bring scorch moths. Night 54 is scorch alone. Night 55 sends scorch together with every Singe lock. The moth count stays 16; scorch is a lock on every one of those moths. Night 47 stays named Scorch and carries no scorch.
# Nights 56 and 57 bring sear moths. Night 56 is sear alone. Night 57 sends sear together with every Cinder lock. The moth count stays 16; sear is a lock on every one of those moths. Night 49 stays named Sear and carries no sear, so night 56 is named Parch.
# Nights 58 and 59 bring singe moths. Night 58 is singe alone. Night 59 sends singe together with every Ember lock. The moth count stays 16; singe is a lock on every one of those moths. Night 53 stays named Singe and carries no singe. Night 5 stays named Ash, so night 58 is named Soot.
# shroud_every / rind_every / pitch_every / frost_every / web_every / glass_every / scale_every / mail_every / hide_every / dusk_every / veil_every / pall_every / gloom_every / murk_every / dread_every / woe_every / blight_every / rot_every / mildew_every / rust_every / scab_every / spot_every / scald_every / blister_every / char_every / scorch_every / sear_every / singe_every / brand_every 0: none. 1: every spawn. N: every Nth spawn, the Nth included.
# Nights 1–21 omit dusk_every; a missing key spawns no dusk.
# Nights 1–23 omit veil_every; a missing key spawns no veil.
# Nights 1–25 omit pall_every; a missing key spawns no pall.
# Nights 1–27 omit gloom_every; a missing key spawns no gloom.
# Nights 1–29 omit murk_every; a missing key spawns no murk. Night 29 is still Cope and carries no murk.
# Nights 1–31 omit dread_every; a missing key spawns no dread. Night 31 is still Fell and carries no dread.
# Nights 1–33 omit woe_every; a missing key spawns no woe. Night 32 is still Dread and carries no woe. Night 33 is still Bane and carries no woe.
# Nights 1–35 omit blight_every; a missing key spawns no blight. Night 33 is still Bane and carries no blight. Night 34 is still Woe and carries no blight. Night 35 is still Hex and carries no blight.
# Nights 1–37 omit rot_every; a missing key spawns no rot. Night 36 is still Gall and carries no rot. Night 37 is still Canker and carries no rot.
# Nights 1–39 omit mildew_every; a missing key spawns no mildew. Night 36 is still Gall and carries no mildew. Night 37 is still Canker and carries no mildew. Night 38 is still Rot and carries no mildew. Night 39 is still Smut and carries no mildew.
# Nights 1–41 omit rust_every; a missing key spawns no rust. Night 40 is still Mildew and carries no rust. Night 41 is still Ergot and carries no rust.
# Nights 1–43 omit scab_every; a missing key spawns no scab. Night 42 is still Rust and carries no scab. Night 43 is still Brand and carries no scab.
# Nights 1–45 omit spot_every; a missing key spawns no spot. Night 44 is still Scab and carries no spot. Night 45 is still Blotch and carries no spot.
# Nights 1–47 omit scald_every; a missing key spawns no scald. Night 46 is still Spot and carries no scald. Night 47 is still Scorch and carries no scald.
# Nights 1–49 omit blister_every; a missing key spawns no blister. Night 48 is still Scald and carries no blister. Night 49 is still Sear and carries no blister.
# Nights 1–51 omit char_every; a missing key spawns no char. Night 50 is still Blister and carries no char. Night 51 is still Weal and carries no char.
# Nights 1–53 omit scorch_every; a missing key spawns no scorch. Night 47 is still Scorch and carries no scorch. Night 52 is still Char and carries no scorch. Night 53 is still Singe and carries no scorch.
# Nights 1–55 omit sear_every; a missing key spawns no sear. Night 49 is still Sear and carries no sear. Night 54 is still Scorch and keeps scorch. Night 55 is still Cinder, keeps scorch, and carries no sear.
# Nights 1–57 omit singe_every; a missing key spawns no singe. Night 5 is still Ash and carries no singe. Night 53 is still Singe and carries no singe. Night 56 is still Parch and keeps sear. Night 57 is still Ember and carries no singe. Night 55 is still Cinder, keeps scorch, and carries no sear and no singe.
# Nights 1–59 omit brand_every; a missing key spawns no brand. Night 43 is still named Brand and carries no brand lock. Night 58 is still Soot and keeps singe. Night 59 is still Coal, keeps singe, and carries no brand. Night 29 is still Cope and carries no singe.
const WAVES := [
	{"count": 8, "interval": 72, "shroud_every": 0, "rind_every": 0, "pitch_every": 0, "frost_every": 0, "web_every": 0, "glass_every": 0, "scale_every": 0, "mail_every": 0, "hide_every": 0, "name": ""},
	{"count": 12, "interval": 66, "shroud_every": 0, "rind_every": 0, "pitch_every": 0, "frost_every": 0, "web_every": 0, "glass_every": 0, "scale_every": 0, "mail_every": 0, "hide_every": 0, "name": ""},
	{"count": 22, "interval": 60, "shroud_every": 0, "rind_every": 0, "pitch_every": 0, "frost_every": 0, "web_every": 0, "glass_every": 0, "scale_every": 0, "mail_every": 0, "hide_every": 0, "name": ""},
	{"count": 8, "interval": 78, "shroud_every": 1, "rind_every": 0, "pitch_every": 0, "frost_every": 0, "web_every": 0, "glass_every": 0, "scale_every": 0, "mail_every": 0, "hide_every": 0, "name": "Shroud"},
	{"count": 16, "interval": 54, "shroud_every": 2, "rind_every": 0, "pitch_every": 0, "frost_every": 0, "web_every": 0, "glass_every": 0, "scale_every": 0, "mail_every": 0, "hide_every": 0, "name": "Ash"},
	{"count": 10, "interval": 72, "shroud_every": 0, "rind_every": 1, "pitch_every": 0, "frost_every": 0, "web_every": 0, "glass_every": 0, "scale_every": 0, "mail_every": 0, "hide_every": 0, "name": "Rind"},
	{"count": 16, "interval": 60, "shroud_every": 2, "rind_every": 1, "pitch_every": 0, "frost_every": 0, "web_every": 0, "glass_every": 0, "scale_every": 0, "mail_every": 0, "hide_every": 0, "name": "Gall"},
	{"count": 10, "interval": 72, "shroud_every": 0, "rind_every": 0, "pitch_every": 1, "frost_every": 0, "web_every": 0, "glass_every": 0, "scale_every": 0, "mail_every": 0, "hide_every": 0, "name": "Pitch"},
	{"count": 16, "interval": 60, "shroud_every": 2, "rind_every": 1, "pitch_every": 1, "frost_every": 0, "web_every": 0, "glass_every": 0, "scale_every": 0, "mail_every": 0, "hide_every": 0, "name": "Tar"},
	{"count": 10, "interval": 72, "shroud_every": 0, "rind_every": 0, "pitch_every": 0, "frost_every": 1, "web_every": 0, "glass_every": 0, "scale_every": 0, "mail_every": 0, "hide_every": 0, "name": "Frost"},
	{"count": 16, "interval": 60, "shroud_every": 2, "rind_every": 1, "pitch_every": 1, "frost_every": 1, "web_every": 0, "glass_every": 0, "scale_every": 0, "mail_every": 0, "hide_every": 0, "name": "Rime"},
	{"count": 10, "interval": 72, "shroud_every": 0, "rind_every": 0, "pitch_every": 0, "frost_every": 0, "web_every": 1, "glass_every": 0, "scale_every": 0, "mail_every": 0, "hide_every": 0, "name": "Web"},
	{"count": 16, "interval": 60, "shroud_every": 2, "rind_every": 1, "pitch_every": 1, "frost_every": 1, "web_every": 1, "glass_every": 0, "scale_every": 0, "mail_every": 0, "hide_every": 0, "name": "Snare"},
	{"count": 10, "interval": 72, "shroud_every": 0, "rind_every": 0, "pitch_every": 0, "frost_every": 0, "web_every": 0, "glass_every": 1, "scale_every": 0, "mail_every": 0, "hide_every": 0, "name": "Glass"},
	{"count": 16, "interval": 60, "shroud_every": 2, "rind_every": 1, "pitch_every": 1, "frost_every": 1, "web_every": 1, "glass_every": 1, "scale_every": 0, "mail_every": 0, "hide_every": 0, "name": "Pane"},
	{"count": 10, "interval": 72, "shroud_every": 0, "rind_every": 0, "pitch_every": 0, "frost_every": 0, "web_every": 0, "glass_every": 0, "scale_every": 1, "mail_every": 0, "hide_every": 0, "name": "Scale"},
	{"count": 16, "interval": 60, "shroud_every": 2, "rind_every": 1, "pitch_every": 1, "frost_every": 1, "web_every": 1, "glass_every": 1, "scale_every": 1, "mail_every": 0, "hide_every": 0, "name": "Plate"},
	{"count": 10, "interval": 72, "shroud_every": 0, "rind_every": 0, "pitch_every": 0, "frost_every": 0, "web_every": 0, "glass_every": 0, "scale_every": 0, "mail_every": 1, "hide_every": 0, "name": "Mail"},
	{"count": 16, "interval": 60, "shroud_every": 2, "rind_every": 1, "pitch_every": 1, "frost_every": 1, "web_every": 1, "glass_every": 1, "scale_every": 1, "mail_every": 1, "hide_every": 0, "name": "Armor"},
	{"count": 10, "interval": 72, "shroud_every": 0, "rind_every": 0, "pitch_every": 0, "frost_every": 0, "web_every": 0, "glass_every": 0, "scale_every": 0, "mail_every": 0, "hide_every": 1, "name": "Hide"},
	{"count": 16, "interval": 60, "shroud_every": 2, "rind_every": 1, "pitch_every": 1, "frost_every": 1, "web_every": 1, "glass_every": 1, "scale_every": 1, "mail_every": 1, "hide_every": 1, "name": "Coat"},
	{"count": 10, "interval": 72, "shroud_every": 0, "rind_every": 0, "pitch_every": 0, "frost_every": 0, "web_every": 0, "glass_every": 0, "scale_every": 0, "mail_every": 0, "hide_every": 0, "dusk_every": 1, "name": "Dusk"},
	{"count": 16, "interval": 60, "shroud_every": 2, "rind_every": 1, "pitch_every": 1, "frost_every": 1, "web_every": 1, "glass_every": 1, "scale_every": 1, "mail_every": 1, "hide_every": 1, "dusk_every": 1, "name": "Dim"},
	{"count": 10, "interval": 72, "shroud_every": 0, "rind_every": 0, "pitch_every": 0, "frost_every": 0, "web_every": 0, "glass_every": 0, "scale_every": 0, "mail_every": 0, "hide_every": 0, "dusk_every": 0, "veil_every": 1, "name": "Veil"},
	{"count": 16, "interval": 60, "shroud_every": 2, "rind_every": 1, "pitch_every": 1, "frost_every": 1, "web_every": 1, "glass_every": 1, "scale_every": 1, "mail_every": 1, "hide_every": 1, "dusk_every": 1, "veil_every": 1, "name": "Mask"},
	{"count": 10, "interval": 72, "shroud_every": 0, "rind_every": 0, "pitch_every": 0, "frost_every": 0, "web_every": 0, "glass_every": 0, "scale_every": 0, "mail_every": 0, "hide_every": 0, "dusk_every": 0, "veil_every": 0, "pall_every": 1, "name": "Pall"},
	{"count": 16, "interval": 60, "shroud_every": 2, "rind_every": 1, "pitch_every": 1, "frost_every": 1, "web_every": 1, "glass_every": 1, "scale_every": 1, "mail_every": 1, "hide_every": 1, "dusk_every": 1, "veil_every": 1, "pall_every": 1, "name": "Mantle"},
	{"count": 10, "interval": 72, "shroud_every": 0, "rind_every": 0, "pitch_every": 0, "frost_every": 0, "web_every": 0, "glass_every": 0, "scale_every": 0, "mail_every": 0, "hide_every": 0, "dusk_every": 0, "veil_every": 0, "pall_every": 0, "gloom_every": 1, "name": "Gloom"},
	{"count": 16, "interval": 60, "shroud_every": 2, "rind_every": 1, "pitch_every": 1, "frost_every": 1, "web_every": 1, "glass_every": 1, "scale_every": 1, "mail_every": 1, "hide_every": 1, "dusk_every": 1, "veil_every": 1, "pall_every": 1, "gloom_every": 1, "name": "Cope"},
	{"count": 10, "interval": 72, "shroud_every": 0, "rind_every": 0, "pitch_every": 0, "frost_every": 0, "web_every": 0, "glass_every": 0, "scale_every": 0, "mail_every": 0, "hide_every": 0, "dusk_every": 0, "veil_every": 0, "pall_every": 0, "gloom_every": 0, "murk_every": 1, "name": "Murk"},
	{"count": 16, "interval": 60, "shroud_every": 2, "rind_every": 1, "pitch_every": 1, "frost_every": 1, "web_every": 1, "glass_every": 1, "scale_every": 1, "mail_every": 1, "hide_every": 1, "dusk_every": 1, "veil_every": 1, "pall_every": 1, "gloom_every": 1, "murk_every": 1, "name": "Fell"},
	{"count": 10, "interval": 72, "shroud_every": 0, "rind_every": 0, "pitch_every": 0, "frost_every": 0, "web_every": 0, "glass_every": 0, "scale_every": 0, "mail_every": 0, "hide_every": 0, "dusk_every": 0, "veil_every": 0, "pall_every": 0, "gloom_every": 0, "murk_every": 0, "dread_every": 1, "name": "Dread"},
	{"count": 16, "interval": 60, "shroud_every": 2, "rind_every": 1, "pitch_every": 1, "frost_every": 1, "web_every": 1, "glass_every": 1, "scale_every": 1, "mail_every": 1, "hide_every": 1, "dusk_every": 1, "veil_every": 1, "pall_every": 1, "gloom_every": 1, "murk_every": 1, "dread_every": 1, "name": "Bane"},
	{"count": 10, "interval": 72, "shroud_every": 0, "rind_every": 0, "pitch_every": 0, "frost_every": 0, "web_every": 0, "glass_every": 0, "scale_every": 0, "mail_every": 0, "hide_every": 0, "dusk_every": 0, "veil_every": 0, "pall_every": 0, "gloom_every": 0, "murk_every": 0, "dread_every": 0, "woe_every": 1, "name": "Woe"},
	{"count": 16, "interval": 60, "shroud_every": 2, "rind_every": 1, "pitch_every": 1, "frost_every": 1, "web_every": 1, "glass_every": 1, "scale_every": 1, "mail_every": 1, "hide_every": 1, "dusk_every": 1, "veil_every": 1, "pall_every": 1, "gloom_every": 1, "murk_every": 1, "dread_every": 1, "woe_every": 1, "name": "Hex"},
	{"count": 10, "interval": 78, "shroud_every": 0, "rind_every": 0, "pitch_every": 0, "frost_every": 0, "web_every": 0, "glass_every": 0, "scale_every": 0, "mail_every": 0, "hide_every": 0, "dusk_every": 0, "veil_every": 0, "pall_every": 0, "gloom_every": 0, "murk_every": 0, "dread_every": 0, "woe_every": 0, "blight_every": 1, "name": "Gall"},
	{"count": 16, "interval": 60, "shroud_every": 2, "rind_every": 1, "pitch_every": 1, "frost_every": 1, "web_every": 1, "glass_every": 1, "scale_every": 1, "mail_every": 1, "hide_every": 1, "dusk_every": 1, "veil_every": 1, "pall_every": 1, "gloom_every": 1, "murk_every": 1, "dread_every": 1, "woe_every": 1, "blight_every": 1, "name": "Canker"},
	{"count": 10, "interval": 84, "shroud_every": 0, "rind_every": 0, "pitch_every": 0, "frost_every": 0, "web_every": 0, "glass_every": 0, "scale_every": 0, "mail_every": 0, "hide_every": 0, "dusk_every": 0, "veil_every": 0, "pall_every": 0, "gloom_every": 0, "murk_every": 0, "dread_every": 0, "woe_every": 0, "blight_every": 0, "rot_every": 1, "mildew_every": 0, "name": "Rot"},
	{"count": 16, "interval": 60, "shroud_every": 2, "rind_every": 1, "pitch_every": 1, "frost_every": 1, "web_every": 1, "glass_every": 1, "scale_every": 1, "mail_every": 1, "hide_every": 1, "dusk_every": 1, "veil_every": 1, "pall_every": 1, "gloom_every": 1, "murk_every": 1, "dread_every": 1, "woe_every": 1, "blight_every": 1, "rot_every": 1, "mildew_every": 0, "name": "Smut"},
	{"count": 10, "interval": 90, "shroud_every": 0, "rind_every": 0, "pitch_every": 0, "frost_every": 0, "web_every": 0, "glass_every": 0, "scale_every": 0, "mail_every": 0, "hide_every": 0, "dusk_every": 0, "veil_every": 0, "pall_every": 0, "gloom_every": 0, "murk_every": 0, "dread_every": 0, "woe_every": 0, "blight_every": 0, "rot_every": 0, "mildew_every": 1, "rust_every": 0, "name": "Mildew"},
	{"count": 16, "interval": 60, "shroud_every": 2, "rind_every": 1, "pitch_every": 1, "frost_every": 1, "web_every": 1, "glass_every": 1, "scale_every": 1, "mail_every": 1, "hide_every": 1, "dusk_every": 1, "veil_every": 1, "pall_every": 1, "gloom_every": 1, "murk_every": 1, "dread_every": 1, "woe_every": 1, "blight_every": 1, "rot_every": 1, "mildew_every": 1, "rust_every": 0, "name": "Ergot"},
	{"count": 10, "interval": 96, "shroud_every": 0, "rind_every": 0, "pitch_every": 0, "frost_every": 0, "web_every": 0, "glass_every": 0, "scale_every": 0, "mail_every": 0, "hide_every": 0, "dusk_every": 0, "veil_every": 0, "pall_every": 0, "gloom_every": 0, "murk_every": 0, "dread_every": 0, "woe_every": 0, "blight_every": 0, "rot_every": 0, "mildew_every": 0, "rust_every": 1, "name": "Rust"},
	{"count": 16, "interval": 60, "shroud_every": 2, "rind_every": 1, "pitch_every": 1, "frost_every": 1, "web_every": 1, "glass_every": 1, "scale_every": 1, "mail_every": 1, "hide_every": 1, "dusk_every": 1, "veil_every": 1, "pall_every": 1, "gloom_every": 1, "murk_every": 1, "dread_every": 1, "woe_every": 1, "blight_every": 1, "rot_every": 1, "mildew_every": 1, "rust_every": 1, "name": "Brand"},
	{"count": 10, "interval": 102, "shroud_every": 0, "rind_every": 0, "pitch_every": 0, "frost_every": 0, "web_every": 0, "glass_every": 0, "scale_every": 0, "mail_every": 0, "hide_every": 0, "dusk_every": 0, "veil_every": 0, "pall_every": 0, "gloom_every": 0, "murk_every": 0, "dread_every": 0, "woe_every": 0, "blight_every": 0, "rot_every": 0, "mildew_every": 0, "rust_every": 0, "scab_every": 1, "name": "Scab"},
	{"count": 16, "interval": 60, "shroud_every": 2, "rind_every": 1, "pitch_every": 1, "frost_every": 1, "web_every": 1, "glass_every": 1, "scale_every": 1, "mail_every": 1, "hide_every": 1, "dusk_every": 1, "veil_every": 1, "pall_every": 1, "gloom_every": 1, "murk_every": 1, "dread_every": 1, "woe_every": 1, "blight_every": 1, "rot_every": 1, "mildew_every": 1, "rust_every": 1, "scab_every": 1, "name": "Blotch"},
	{"count": 10, "interval": 108, "shroud_every": 0, "rind_every": 0, "pitch_every": 0, "frost_every": 0, "web_every": 0, "glass_every": 0, "scale_every": 0, "mail_every": 0, "hide_every": 0, "dusk_every": 0, "veil_every": 0, "pall_every": 0, "gloom_every": 0, "murk_every": 0, "dread_every": 0, "woe_every": 0, "blight_every": 0, "rot_every": 0, "mildew_every": 0, "rust_every": 0, "scab_every": 0, "spot_every": 1, "name": "Spot"},
	{"count": 16, "interval": 60, "shroud_every": 2, "rind_every": 1, "pitch_every": 1, "frost_every": 1, "web_every": 1, "glass_every": 1, "scale_every": 1, "mail_every": 1, "hide_every": 1, "dusk_every": 1, "veil_every": 1, "pall_every": 1, "gloom_every": 1, "murk_every": 1, "dread_every": 1, "woe_every": 1, "blight_every": 1, "rot_every": 1, "mildew_every": 1, "rust_every": 1, "scab_every": 1, "spot_every": 1, "name": "Scorch"},
	{"count": 10, "interval": 114, "shroud_every": 0, "rind_every": 0, "pitch_every": 0, "frost_every": 0, "web_every": 0, "glass_every": 0, "scale_every": 0, "mail_every": 0, "hide_every": 0, "dusk_every": 0, "veil_every": 0, "pall_every": 0, "gloom_every": 0, "murk_every": 0, "dread_every": 0, "woe_every": 0, "blight_every": 0, "rot_every": 0, "mildew_every": 0, "rust_every": 0, "scab_every": 0, "spot_every": 0, "scald_every": 1, "name": "Scald"},
	{"count": 16, "interval": 60, "shroud_every": 2, "rind_every": 1, "pitch_every": 1, "frost_every": 1, "web_every": 1, "glass_every": 1, "scale_every": 1, "mail_every": 1, "hide_every": 1, "dusk_every": 1, "veil_every": 1, "pall_every": 1, "gloom_every": 1, "murk_every": 1, "dread_every": 1, "woe_every": 1, "blight_every": 1, "rot_every": 1, "mildew_every": 1, "rust_every": 1, "scab_every": 1, "spot_every": 1, "scald_every": 1, "name": "Sear"},
	{"count": 10, "interval": 120, "shroud_every": 0, "rind_every": 0, "pitch_every": 0, "frost_every": 0, "web_every": 0, "glass_every": 0, "scale_every": 0, "mail_every": 0, "hide_every": 0, "dusk_every": 0, "veil_every": 0, "pall_every": 0, "gloom_every": 0, "murk_every": 0, "dread_every": 0, "woe_every": 0, "blight_every": 0, "rot_every": 0, "mildew_every": 0, "rust_every": 0, "scab_every": 0, "spot_every": 0, "scald_every": 0, "blister_every": 1, "name": "Blister"},
	{"count": 16, "interval": 60, "shroud_every": 2, "rind_every": 1, "pitch_every": 1, "frost_every": 1, "web_every": 1, "glass_every": 1, "scale_every": 1, "mail_every": 1, "hide_every": 1, "dusk_every": 1, "veil_every": 1, "pall_every": 1, "gloom_every": 1, "murk_every": 1, "dread_every": 1, "woe_every": 1, "blight_every": 1, "rot_every": 1, "mildew_every": 1, "rust_every": 1, "scab_every": 1, "spot_every": 1, "scald_every": 1, "blister_every": 1, "name": "Weal"},
	{"count": 10, "interval": 126, "shroud_every": 0, "rind_every": 0, "pitch_every": 0, "frost_every": 0, "web_every": 0, "glass_every": 0, "scale_every": 0, "mail_every": 0, "hide_every": 0, "dusk_every": 0, "veil_every": 0, "pall_every": 0, "gloom_every": 0, "murk_every": 0, "dread_every": 0, "woe_every": 0, "blight_every": 0, "rot_every": 0, "mildew_every": 0, "rust_every": 0, "scab_every": 0, "spot_every": 0, "scald_every": 0, "blister_every": 0, "char_every": 1, "name": "Char"},
	{"count": 16, "interval": 60, "shroud_every": 2, "rind_every": 1, "pitch_every": 1, "frost_every": 1, "web_every": 1, "glass_every": 1, "scale_every": 1, "mail_every": 1, "hide_every": 1, "dusk_every": 1, "veil_every": 1, "pall_every": 1, "gloom_every": 1, "murk_every": 1, "dread_every": 1, "woe_every": 1, "blight_every": 1, "rot_every": 1, "mildew_every": 1, "rust_every": 1, "scab_every": 1, "spot_every": 1, "scald_every": 1, "blister_every": 1, "char_every": 1, "name": "Singe"},
	{"count": 10, "interval": 132, "shroud_every": 0, "rind_every": 0, "pitch_every": 0, "frost_every": 0, "web_every": 0, "glass_every": 0, "scale_every": 0, "mail_every": 0, "hide_every": 0, "dusk_every": 0, "veil_every": 0, "pall_every": 0, "gloom_every": 0, "murk_every": 0, "dread_every": 0, "woe_every": 0, "blight_every": 0, "rot_every": 0, "mildew_every": 0, "rust_every": 0, "scab_every": 0, "spot_every": 0, "scald_every": 0, "blister_every": 0, "char_every": 0, "scorch_every": 1, "name": "Scorch"},
	{"count": 16, "interval": 60, "shroud_every": 2, "rind_every": 1, "pitch_every": 1, "frost_every": 1, "web_every": 1, "glass_every": 1, "scale_every": 1, "mail_every": 1, "hide_every": 1, "dusk_every": 1, "veil_every": 1, "pall_every": 1, "gloom_every": 1, "murk_every": 1, "dread_every": 1, "woe_every": 1, "blight_every": 1, "rot_every": 1, "mildew_every": 1, "rust_every": 1, "scab_every": 1, "spot_every": 1, "scald_every": 1, "blister_every": 1, "char_every": 1, "scorch_every": 1, "name": "Cinder"},
	{"count": 10, "interval": 138, "shroud_every": 0, "rind_every": 0, "pitch_every": 0, "frost_every": 0, "web_every": 0, "glass_every": 0, "scale_every": 0, "mail_every": 0, "hide_every": 0, "dusk_every": 0, "veil_every": 0, "pall_every": 0, "gloom_every": 0, "murk_every": 0, "dread_every": 0, "woe_every": 0, "blight_every": 0, "rot_every": 0, "mildew_every": 0, "rust_every": 0, "scab_every": 0, "spot_every": 0, "scald_every": 0, "blister_every": 0, "char_every": 0, "scorch_every": 0, "sear_every": 1, "name": "Parch"},
	{"count": 16, "interval": 60, "shroud_every": 2, "rind_every": 1, "pitch_every": 1, "frost_every": 1, "web_every": 1, "glass_every": 1, "scale_every": 1, "mail_every": 1, "hide_every": 1, "dusk_every": 1, "veil_every": 1, "pall_every": 1, "gloom_every": 1, "murk_every": 1, "dread_every": 1, "woe_every": 1, "blight_every": 1, "rot_every": 1, "mildew_every": 1, "rust_every": 1, "scab_every": 1, "spot_every": 1, "scald_every": 1, "blister_every": 1, "char_every": 1, "scorch_every": 1, "sear_every": 1, "name": "Ember"},
	{"count": 10, "interval": 144, "shroud_every": 0, "rind_every": 0, "pitch_every": 0, "frost_every": 0, "web_every": 0, "glass_every": 0, "scale_every": 0, "mail_every": 0, "hide_every": 0, "dusk_every": 0, "veil_every": 0, "pall_every": 0, "gloom_every": 0, "murk_every": 0, "dread_every": 0, "woe_every": 0, "blight_every": 0, "rot_every": 0, "mildew_every": 0, "rust_every": 0, "scab_every": 0, "spot_every": 0, "scald_every": 0, "blister_every": 0, "char_every": 0, "scorch_every": 0, "sear_every": 0, "singe_every": 1, "brand_every": 0, "name": "Soot"},
	{"count": 16, "interval": 60, "shroud_every": 2, "rind_every": 1, "pitch_every": 1, "frost_every": 1, "web_every": 1, "glass_every": 1, "scale_every": 1, "mail_every": 1, "hide_every": 1, "dusk_every": 1, "veil_every": 1, "pall_every": 1, "gloom_every": 1, "murk_every": 1, "dread_every": 1, "woe_every": 1, "blight_every": 1, "rot_every": 1, "mildew_every": 1, "rust_every": 1, "scab_every": 1, "spot_every": 1, "scald_every": 1, "blister_every": 1, "char_every": 1, "scorch_every": 1, "sear_every": 1, "singe_every": 1, "brand_every": 0, "name": "Coal"},
	{"count": 10, "interval": 150, "shroud_every": 0, "rind_every": 0, "pitch_every": 0, "frost_every": 0, "web_every": 0, "glass_every": 0, "scale_every": 0, "mail_every": 0, "hide_every": 0, "dusk_every": 0, "veil_every": 0, "pall_every": 0, "gloom_every": 0, "murk_every": 0, "dread_every": 0, "woe_every": 0, "blight_every": 0, "rot_every": 0, "mildew_every": 0, "rust_every": 0, "scab_every": 0, "spot_every": 0, "scald_every": 0, "blister_every": 0, "char_every": 0, "scorch_every": 0, "sear_every": 0, "singe_every": 0, "brand_every": 1, "name": "Flake"},
	{"count": 16, "interval": 60, "shroud_every": 2, "rind_every": 1, "pitch_every": 1, "frost_every": 1, "web_every": 1, "glass_every": 1, "scale_every": 1, "mail_every": 1, "hide_every": 1, "dusk_every": 1, "veil_every": 1, "pall_every": 1, "gloom_every": 1, "murk_every": 1, "dread_every": 1, "woe_every": 1, "blight_every": 1, "rot_every": 1, "mildew_every": 1, "rust_every": 1, "scab_every": 1, "spot_every": 1, "scald_every": 1, "blister_every": 1, "char_every": 1, "scorch_every": 1, "sear_every": 1, "singe_every": 1, "brand_every": 1, "name": "Slag"},
]


class Command:
	var move_x: int = 0
	var move_y: int = 0
	var plant_kind: int = -1
	var tile: Vector2i = Vector2i(-1, -1)


class Plant:
	var alive: bool = true
	var kind: int = 0
	var cell: Vector2i = Vector2i.ZERO
	var pos: Vector2 = Vector2.ZERO
	var damage: int = 0
	var fire_ticks: int = 1
	var cooldown: int = 0
	var light_radius: float = 0.0
	var weapon_range: float = 0.0
	var projectile_speed: float = 0.0
	var slow_factor: float = 1.0
	var slow_ticks: int = 0
	var splash_radius: float = 0.0
	var burns_shroud: bool = false
	var cracks_rind: bool = false
	var melts_pitch: bool = false
	var thaws_frost: bool = false
	var cuts_web: bool = false
	var cracks_glass: bool = false
	var strips_scale: bool = false
	var cracks_mail: bool = false
	var splits_hide: bool = false
	var shades_dusk: bool = false
	var cowls_veil: bool = false
	var hoods_pall: bool = false
	var cloaks_gloom: bool = false
	var capes_murk: bool = false
	var shawls_dread: bool = false
	var stoles_woe: bool = false
	var mantles_blight: bool = false
	var tippets_rot: bool = false
	var wimples_mildew: bool = false
	var albs_rust: bool = false
	var amices_scab: bool = false
	var orphreys_spot: bool = false
	var maniples_scald: bool = false
	var chasubles_blister: bool = false
	var dalmatics_char: bool = false
	var tunicles_scorch: bool = false
	var rochets_sear: bool = false
	var copes_singe: bool = false
	var surplices_brand: bool = false
	var casts_light: bool = true


class Pest:
	var id: int = 0
	var pos: Vector2 = Vector2.ZERO
	var hp: int = 0
	var alive: bool = true
	var hidden: bool = true
	var shrouded: bool = false
	var rinded: bool = false
	var pitched: bool = false
	var frosted: bool = false
	var webbed: bool = false
	var glassed: bool = false
	var scaled: bool = false
	var mailed: bool = false
	var hided: bool = false
	var dusked: bool = false
	var veiled: bool = false
	var palled: bool = false
	var gloomed: bool = false
	var murked: bool = false
	var dreaded: bool = false
	var woed: bool = false
	var blighted: bool = false
	var rotted: bool = false
	var mildewed: bool = false
	var rusted: bool = false
	var scabbed: bool = false
	var spotted: bool = false
	var scalded: bool = false
	var blistered: bool = false
	var charred: bool = false
	var scorched: bool = false
	var seared: bool = false
	var singed: bool = false
	var branded: bool = false
	var speed: float = 0.0
	var slow_factor: float = 1.0
	var slow_ticks: int = 0


class Projectile:
	var alive: bool = true
	var kind: int = 0
	var pos: Vector2 = Vector2.ZERO
	var dir: Vector2 = Vector2.RIGHT
	var speed: float = 0.0
	var damage: int = 0
	var target_id: int = -1
	var life: int = 0
	var splash_radius: float = 0.0
	var slow_factor: float = 1.0
	var slow_ticks: int = 0


var run_seed: int = 1
var tick: int = 0
var phase: int = PHASE_PLANT
var phase_ticks: int = 0
var wave: int = 0
var outcome: int = OUTCOME_RUNNING
var seeds: int = START_SEEDS
var player_hp: int = PLAYER_HP
var player_pos: Vector2 = Vector2.ZERO
var hurt_ticks: int = 0
var spawns_left: int = 0
var spawn_wait: int = 0
var spawn_interval: int = 0
var shots_fired: int = 0
var shrouds_spawned: int = 0
var shrouds_killed: int = 0
var rinds_spawned: int = 0
var rinds_killed: int = 0
var pitches_spawned: int = 0
var pitches_killed: int = 0
var frosts_spawned: int = 0
var frosts_killed: int = 0
var webs_spawned: int = 0
var webs_killed: int = 0
var glasses_spawned: int = 0
var glasses_killed: int = 0
var scales_spawned: int = 0
var scales_killed: int = 0
var mails_spawned: int = 0
var mails_killed: int = 0
var hides_spawned: int = 0
var hides_killed: int = 0
var dusks_spawned: int = 0
var dusks_killed: int = 0
var veils_spawned: int = 0
var veils_killed: int = 0
var palls_spawned: int = 0
var palls_killed: int = 0
var glooms_spawned: int = 0
var glooms_killed: int = 0
var murks_spawned: int = 0
var murks_killed: int = 0
var dreads_spawned: int = 0
var dreads_killed: int = 0
var woes_spawned: int = 0
var woes_killed: int = 0
var blights_spawned: int = 0
var blights_killed: int = 0
var rots_spawned: int = 0
var rots_killed: int = 0
var mildews_spawned: int = 0
var mildews_killed: int = 0
var rusts_spawned: int = 0
var rusts_killed: int = 0
var scabs_spawned: int = 0
var scabs_killed: int = 0
var spots_spawned: int = 0
var spots_killed: int = 0
var scalds_spawned: int = 0
var scalds_killed: int = 0
var blisters_spawned: int = 0
var blisters_killed: int = 0
var chars_spawned: int = 0
var chars_killed: int = 0
var scorches_spawned: int = 0
var scorches_killed: int = 0
var sears_spawned: int = 0
var sears_killed: int = 0
var singes_spawned: int = 0
var singes_killed: int = 0
var brands_spawned: int = 0
var brands_killed: int = 0
var plants: Array = []
var pests: Array = []
var projectiles: Array = []
var events: Array = []

var _rng := RandomNumberGenerator.new()
var _next_pest_id: int = 1


func _init(start_seed: int = 1) -> void:
	run_seed = start_seed
	_rng.seed = start_seed
	player_pos = tile_center(START_CELL.x, START_CELL.y)
	player_hp = PLAYER_HP
	seeds = START_SEEDS
	phase = PHASE_PLANT
	outcome = OUTCOME_RUNNING


func step(cmd: Command) -> void:
	if outcome != OUTCOME_RUNNING:
		return
	events.clear()
	tick += 1
	var started_wave := false
	if phase == PHASE_PLANT:
		_try_plant(cmd)
		phase_ticks += 1
		if phase_ticks >= PLANT_TICKS:
			_begin_wave()
			started_wave = true
	if phase == PHASE_WAVE and not started_wave:
		_move_player(cmd)
		_wave_spawns()
	_move_pests()
	_refresh_visibility()
	_plants_fire()
	_move_projectiles()
	_contact()
	if outcome == OUTCOME_RUNNING and phase == PHASE_WAVE and not started_wave:
		_maybe_end_wave()
	_cull()


func tile_center(tx: int, ty: int) -> Vector2:
	return Vector2((float(tx) + 0.5) * TILE, (float(ty) + 0.5) * TILE)


func cell_of(pos: Vector2) -> Vector2i:
	var tx := clampi(floori(pos.x / TILE), 0, MAP_W - 1)
	var ty := clampi(floori(pos.y / TILE), 0, MAP_H - 1)
	return Vector2i(tx, ty)


func tile_lit(tx: int, ty: int) -> bool:
	return _tile_in_light(tx, ty, false, false, false, false, false, false, false, false, false, false)


func tile_burns_shroud(tx: int, ty: int) -> bool:
	return _tile_in_light(tx, ty, true, false, false, false, false, false, false, false, false, false)


func tile_cracks_rind(tx: int, ty: int) -> bool:
	return _tile_in_light(tx, ty, false, true, false, false, false, false, false, false, false, false)


func tile_melts_pitch(tx: int, ty: int) -> bool:
	return _tile_in_light(tx, ty, false, false, true, false, false, false, false, false, false, false)


func tile_thaws_frost(tx: int, ty: int) -> bool:
	return _tile_in_light(tx, ty, false, false, false, true, false, false, false, false, false, false)


func tile_cuts_web(tx: int, ty: int) -> bool:
	return _tile_in_light(tx, ty, false, false, false, false, true, false, false, false, false, false)


func tile_cracks_glass(tx: int, ty: int) -> bool:
	return _tile_in_light(tx, ty, false, false, false, false, false, true, false, false, false, false)


func tile_strips_scale(tx: int, ty: int) -> bool:
	return _tile_in_light(tx, ty, false, false, false, false, false, false, true, false, false, false)


func tile_cracks_mail(tx: int, ty: int) -> bool:
	return _tile_in_light(tx, ty, false, false, false, false, false, false, false, true, false, false)


func tile_splits_hide(tx: int, ty: int) -> bool:
	return _tile_in_light(tx, ty, false, false, false, false, false, false, false, false, true, false)


func tile_shades_dusk(tx: int, ty: int) -> bool:
	return _tile_in_light(tx, ty, false, false, false, false, false, false, false, false, false, true)


func tile_cowls_veil(tx: int, ty: int) -> bool:
	return _tile_in_light(tx, ty, false, false, false, false, false, false, false, false, false, false, true)


func tile_hoods_pall(tx: int, ty: int) -> bool:
	return _tile_in_light(tx, ty, false, false, false, false, false, false, false, false, false, false, false, true)


func tile_cloaks_gloom(tx: int, ty: int) -> bool:
	return _tile_in_light(tx, ty, false, false, false, false, false, false, false, false, false, false, false, false, true)


func tile_capes_murk(tx: int, ty: int) -> bool:
	return _tile_in_light(tx, ty, false, false, false, false, false, false, false, false, false, false, false, false, false, true)


func tile_shawls_dread(tx: int, ty: int) -> bool:
	return _tile_in_light(tx, ty, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)


func tile_stoles_woe(tx: int, ty: int) -> bool:
	return _tile_in_light(tx, ty, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)


func tile_mantles_blight(tx: int, ty: int) -> bool:
	return _tile_in_light(tx, ty, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)


func tile_tippets_rot(tx: int, ty: int) -> bool:
	return _tile_in_light(tx, ty, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)


func tile_wimples_mildew(tx: int, ty: int) -> bool:
	return _tile_in_light(tx, ty, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)


func tile_albs_rust(tx: int, ty: int) -> bool:
	return _tile_in_light(tx, ty, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)


func tile_amices_scab(tx: int, ty: int) -> bool:
	return _tile_in_light(tx, ty, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)


func tile_orphreys_spot(tx: int, ty: int) -> bool:
	return _tile_in_light(tx, ty, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)


func tile_maniples_scald(tx: int, ty: int) -> bool:
	return _tile_in_light(tx, ty, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)


func tile_chasubles_blister(tx: int, ty: int) -> bool:
	return _tile_in_light(tx, ty, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)


func tile_dalmatics_char(tx: int, ty: int) -> bool:
	return _tile_in_light(tx, ty, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)

func tile_tunicles_scorch(tx: int, ty: int) -> bool:
	return _tile_in_light(tx, ty, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)

func tile_rochets_sear(tx: int, ty: int) -> bool:
	return _tile_in_light(tx, ty, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)

func tile_copes_singe(tx: int, ty: int) -> bool:
	return _tile_in_light(tx, ty, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)

func tile_surplices_brand(tx: int, ty: int) -> bool:
	return _tile_in_light(tx, ty, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)


func _tile_in_light(tx: int, ty: int, shroud_only: bool, rind_only: bool, pitch_only: bool, frost_only: bool, web_only: bool, glass_only: bool, scale_only: bool, mail_only: bool, hide_only: bool, dusk_only: bool, veil_only: bool = false, pall_only: bool = false, gloom_only: bool = false, murk_only: bool = false, dread_only: bool = false, woe_only: bool = false, blight_only: bool = false, rot_only: bool = false, mildew_only: bool = false, rust_only: bool = false, scab_only: bool = false, spot_only: bool = false, scald_only: bool = false, blister_only: bool = false, char_only: bool = false, scorch_only: bool = false, sear_only: bool = false, singe_only: bool = false, brand_only: bool = false) -> bool:
	if tx < 0 or ty < 0 or tx >= MAP_W or ty >= MAP_H:
		return false
	var rect_min := Vector2(float(tx) * TILE, float(ty) * TILE)
	var rect_max := rect_min + Vector2(TILE, TILE)
	for plant in plants:
		var grown := plant as Plant
		if not grown.alive:
			continue
		if shroud_only and not grown.burns_shroud:
			continue
		if rind_only and not grown.cracks_rind:
			continue
		if pitch_only and not grown.melts_pitch:
			continue
		if frost_only and not grown.thaws_frost:
			continue
		if web_only and not grown.cuts_web:
			continue
		if glass_only and not grown.cracks_glass:
			continue
		if scale_only and not grown.strips_scale:
			continue
		if mail_only and not grown.cracks_mail:
			continue
		if hide_only and not grown.splits_hide:
			continue
		if dusk_only and not grown.shades_dusk:
			continue
		if veil_only and not grown.cowls_veil:
			continue
		if pall_only and not grown.hoods_pall:
			continue
		if gloom_only and not grown.cloaks_gloom:
			continue
		if murk_only and not grown.capes_murk:
			continue
		if dread_only and not grown.shawls_dread:
			continue
		if woe_only and not grown.stoles_woe:
			continue
		if blight_only and not grown.mantles_blight:
			continue
		if rot_only and not grown.tippets_rot:
			continue
		if mildew_only and not grown.wimples_mildew:
			continue
		if rust_only and not grown.albs_rust:
			continue
		if scab_only and not grown.amices_scab:
			continue
		if spot_only and not grown.orphreys_spot:
			continue
		if scald_only and not grown.maniples_scald:
			continue
		if blister_only and not grown.chasubles_blister:
			continue
		if char_only and not grown.dalmatics_char:
			continue
		if scorch_only and not grown.tunicles_scorch:
			continue
		if sear_only and not grown.rochets_sear:
			continue
		if singe_only and not grown.copes_singe:
			continue
		if brand_only and not grown.surplices_brand:
			continue
		var special := shroud_only or rind_only or pitch_only or frost_only or web_only or glass_only or scale_only or mail_only or hide_only or dusk_only or veil_only or pall_only or gloom_only or murk_only or dread_only or woe_only or blight_only or rot_only or mildew_only or rust_only or scab_only or spot_only or scald_only or blister_only or char_only or scorch_only or sear_only or singe_only or brand_only
		if not special and not grown.casts_light:
			continue
		var source: Vector2 = grown.pos
		var closest := Vector2(
			clampf(source.x, rect_min.x, rect_max.x),
			clampf(source.y, rect_min.y, rect_max.y)
		)
		if source.distance_to(closest) <= grown.light_radius:
			return true
	return false


func is_plantable(cell: Vector2i) -> bool:
	if outcome != OUTCOME_RUNNING or phase != PHASE_PLANT or seeds <= 0:
		return false
	if not _in_orchard(cell):
		return false
	return _plant_on(cell) == null


func has_plant(kind: int) -> bool:
	return plant_of_kind(kind) != null


func plant_of_kind(kind: int):
	for plant in plants:
		if (plant as Plant).alive and (plant as Plant).kind == kind:
			return plant
	return null


func pest_by_id(pest_id: int):
	for pest in pests:
		if (pest as Pest).id == pest_id:
			return pest
	return null


func living_pest_count() -> int:
	var count := 0
	for pest in pests:
		if (pest as Pest).alive:
			count += 1
	return count


func pests_remaining() -> int:
	return living_pest_count() + spawns_left


func plant_seconds_left() -> float:
	if phase != PHASE_PLANT:
		return 0.0
	return maxf(float(PLANT_TICKS - phase_ticks), 0.0) * DT


func phase_text() -> String:
	if outcome == OUTCOME_WON:
		return "The orchard holds"
	if outcome == OUTCOME_LOST:
		return "The lights went out"
	if phase == PHASE_PLANT:
		var next_wave := mini(wave + 1, WAVE_COUNT)
		return "Planting — night %d%s in %.1fs" % [next_wave, _night_suffix(next_wave), plant_seconds_left()]
	return "Night %d of %d%s — %d pests left" % [wave, WAVE_COUNT, _night_suffix(wave), pests_remaining()]


func _night_suffix(index: int) -> String:
	if index < 1 or index > WAVES.size():
		return ""
	var name := str(WAVES[index - 1].get("name", ""))
	if name == "":
		return ""
	return " (%s)" % name


## Shared entry for wave spawns and the visibility test. Does not alter damage or health.
func spawn_pest(pos: Vector2, shrouded: bool = false, rinded: bool = false, pitched: bool = false, frosted: bool = false, webbed: bool = false, glassed: bool = false, scaled: bool = false, mailed: bool = false, hided: bool = false, dusked: bool = false, veiled: bool = false, palled: bool = false, gloomed: bool = false, murked: bool = false, dreaded: bool = false, woed: bool = false, blighted: bool = false, rotted: bool = false, mildewed: bool = false, rusted: bool = false, scabbed: bool = false, spotted: bool = false, scalded: bool = false, blistered: bool = false, charred: bool = false, scorched: bool = false, seared: bool = false, singed: bool = false, branded: bool = false):
	var pest := Pest.new()
	pest.id = _next_pest_id
	_next_pest_id += 1
	pest.pos = pos
	pest.hp = PEST_HP
	pest.alive = true
	pest.speed = PEST_SPEED
	pest.slow_factor = 1.0
	pest.slow_ticks = 0
	pest.shrouded = shrouded
	pest.rinded = rinded
	pest.pitched = pitched
	pest.frosted = frosted
	pest.webbed = webbed
	pest.glassed = glassed
	pest.scaled = scaled
	pest.mailed = mailed
	pest.hided = hided
	pest.dusked = dusked
	pest.veiled = veiled
	pest.palled = palled
	pest.gloomed = gloomed
	pest.murked = murked
	pest.dreaded = dreaded
	pest.woed = woed
	pest.blighted = blighted
	pest.rotted = rotted
	pest.mildewed = mildewed
	pest.rusted = rusted
	pest.scabbed = scabbed
	pest.spotted = spotted
	pest.scalded = scalded
	pest.blistered = blistered
	pest.charred = charred
	pest.scorched = scorched
	pest.seared = seared
	pest.singed = singed
	pest.branded = branded
	if shrouded:
		shrouds_spawned += 1
	if rinded:
		rinds_spawned += 1
	if pitched:
		pitches_spawned += 1
	if frosted:
		frosts_spawned += 1
	if webbed:
		webs_spawned += 1
	if glassed:
		glasses_spawned += 1
	if scaled:
		scales_spawned += 1
	if mailed:
		mails_spawned += 1
	if hided:
		hides_spawned += 1
	if dusked:
		dusks_spawned += 1
	if veiled:
		veils_spawned += 1
	if palled:
		palls_spawned += 1
	if gloomed:
		glooms_spawned += 1
	if murked:
		murks_spawned += 1
	if dreaded:
		dreads_spawned += 1
	if woed:
		woes_spawned += 1
	if blighted:
		blights_spawned += 1
	if rotted:
		rots_spawned += 1
	if mildewed:
		mildews_spawned += 1
	if rusted:
		rusts_spawned += 1
	if scabbed:
		scabs_spawned += 1
	if spotted:
		spots_spawned += 1
	if scalded:
		scalds_spawned += 1
	if blistered:
		blisters_spawned += 1
	if charred:
		chars_spawned += 1
	if scorched:
		scorches_spawned += 1
	if seared:
		sears_spawned += 1
	if singed:
		singes_spawned += 1
	if branded:
		brands_spawned += 1
	_apply_visibility(pest)
	pests.append(pest)
	return pest


func _begin_wave() -> void:
	wave += 1
	phase = PHASE_WAVE
	var spec: Dictionary = WAVES[wave - 1]
	spawns_left = int(spec["count"])
	spawn_interval = int(spec["interval"])
	spawn_wait = 0
	events.append({"type": "wave", "wave": wave})


func _maybe_end_wave() -> void:
	if spawns_left > 0 or living_pest_count() > 0:
		return
	if wave >= WAVE_COUNT:
		outcome = OUTCOME_WON
		events.append({"type": "won"})
	else:
		phase = PHASE_PLANT
		phase_ticks = 0
		events.append({"type": "plant_phase", "wave": wave + 1})


func _try_plant(cmd: Command) -> void:
	if cmd.plant_kind < 0:
		return
	var kind := cmd.plant_kind
	if phase != PHASE_PLANT or seeds <= 0 or kind < 0 or kind >= Catalog.COUNT:
		events.append({"type": "plant_rejected"})
		return
	if not _in_orchard(cmd.tile) or _plant_on(cmd.tile) != null:
		events.append({"type": "plant_rejected"})
		return
	var stats := Catalog.get_stats(kind)
	var plant := Plant.new()
	plant.kind = kind
	plant.cell = cmd.tile
	plant.pos = tile_center(cmd.tile.x, cmd.tile.y)
	plant.damage = int(stats["damage"])
	plant.fire_ticks = int(stats["fire_ticks"])
	plant.cooldown = 0
	plant.light_radius = float(stats["light_radius"])
	plant.weapon_range = float(stats["weapon_range"])
	plant.projectile_speed = float(stats["projectile_speed"])
	plant.slow_factor = float(stats["slow_factor"])
	plant.slow_ticks = int(stats["slow_ticks"])
	plant.splash_radius = float(stats["splash_radius"])
	plant.burns_shroud = bool(stats["burns_shroud"])
	plant.cracks_rind = bool(stats["cracks_rind"])
	plant.melts_pitch = bool(stats["melts_pitch"])
	plant.thaws_frost = bool(stats["thaws_frost"])
	plant.cuts_web = bool(stats["cuts_web"])
	plant.cracks_glass = bool(stats["cracks_glass"])
	plant.strips_scale = bool(stats["strips_scale"])
	plant.cracks_mail = bool(stats["cracks_mail"])
	plant.splits_hide = bool(stats["splits_hide"])
	plant.shades_dusk = bool(stats["shades_dusk"])
	plant.cowls_veil = bool(stats["cowls_veil"])
	plant.hoods_pall = bool(stats["hoods_pall"])
	plant.cloaks_gloom = bool(stats["cloaks_gloom"])
	plant.capes_murk = bool(stats["capes_murk"])
	plant.shawls_dread = bool(stats["shawls_dread"])
	plant.stoles_woe = bool(stats["stoles_woe"])
	plant.mantles_blight = bool(stats["mantles_blight"])
	plant.tippets_rot = bool(stats["tippets_rot"])
	plant.wimples_mildew = bool(stats["wimples_mildew"])
	plant.albs_rust = bool(stats["albs_rust"])
	plant.amices_scab = bool(stats["amices_scab"])
	plant.orphreys_spot = bool(stats["orphreys_spot"])
	plant.maniples_scald = bool(stats["maniples_scald"])
	plant.chasubles_blister = bool(stats["chasubles_blister"])
	plant.dalmatics_char = bool(stats["dalmatics_char"])
	plant.tunicles_scorch = bool(stats["tunicles_scorch"])
	plant.rochets_sear = bool(stats["rochets_sear"])
	plant.copes_singe = bool(stats["copes_singe"])
	plant.surplices_brand = bool(stats["surplices_brand"])
	plant.casts_light = bool(stats["casts_light"])
	plants.append(plant)
	seeds -= 1
	events.append({"type": "planted", "kind": kind, "x": cmd.tile.x, "y": cmd.tile.y})


func _move_player(cmd: Command) -> void:
	var direction := Vector2(float(cmd.move_x), float(cmd.move_y))
	if direction.length_squared() > 1.0:
		direction = direction.normalized()
	if direction == Vector2.ZERO:
		return
	player_pos += direction * PLAYER_SPEED * DT
	var margin := 14.0
	player_pos.x = clampf(player_pos.x, margin, MAP_W * TILE - margin)
	player_pos.y = clampf(player_pos.y, margin, MAP_H * TILE - margin)


func _wave_spawns() -> void:
	if spawns_left <= 0:
		return
	if spawn_wait > 0:
		spawn_wait -= 1
		return
	var edge := _rng.randi() % 4
	var cell := Vector2i.ZERO
	if edge == 0:
		cell = Vector2i(_rng.randi() % MAP_W, 0)
	elif edge == 1:
		cell = Vector2i(_rng.randi() % MAP_W, MAP_H - 1)
	elif edge == 2:
		cell = Vector2i(0, 1 + _rng.randi() % (MAP_H - 2))
	else:
		cell = Vector2i(MAP_W - 1, 1 + _rng.randi() % (MAP_H - 2))
	var spec: Dictionary = WAVES[wave - 1]
	var shroud_every := int(spec.get("shroud_every", 0))
	var rind_every := int(spec.get("rind_every", 0))
	var pitch_every := int(spec.get("pitch_every", 0))
	var frost_every := int(spec.get("frost_every", 0))
	var web_every := int(spec.get("web_every", 0))
	var glass_every := int(spec.get("glass_every", 0))
	var scale_every := int(spec.get("scale_every", 0))
	var mail_every := int(spec.get("mail_every", 0))
	var hide_every := int(spec.get("hide_every", 0))
	var dusk_every := int(spec.get("dusk_every", 0))
	var veil_every := int(spec.get("veil_every", 0))
	var pall_every := int(spec.get("pall_every", 0))
	var gloom_every := int(spec.get("gloom_every", 0))
	var murk_every := int(spec.get("murk_every", 0))
	var dread_every := int(spec.get("dread_every", 0))
	var woe_every := int(spec.get("woe_every", 0))
	var blight_every := int(spec.get("blight_every", 0))
	var rot_every := int(spec.get("rot_every", 0))
	var mildew_every := int(spec.get("mildew_every", 0))
	var rust_every := int(spec.get("rust_every", 0))
	var scab_every := int(spec.get("scab_every", 0))
	var spot_every := int(spec.get("spot_every", 0))
	var scald_every := int(spec.get("scald_every", 0))
	var blister_every := int(spec.get("blister_every", 0))
	var char_every := int(spec.get("char_every", 0))
	var scorch_every := int(spec.get("scorch_every", 0))
	var sear_every := int(spec.get("sear_every", 0))
	var singe_every := int(spec.get("singe_every", 0))
	var brand_every := int(spec.get("brand_every", 0))
	var index := int(spec["count"]) - spawns_left
	var shrouded := shroud_every > 0 and index % shroud_every == shroud_every - 1
	var rinded := rind_every > 0 and index % rind_every == rind_every - 1
	var pitched := pitch_every > 0 and index % pitch_every == pitch_every - 1
	var frosted := frost_every > 0 and index % frost_every == frost_every - 1
	var webbed := web_every > 0 and index % web_every == web_every - 1
	var glassed := glass_every > 0 and index % glass_every == glass_every - 1
	var scaled := scale_every > 0 and index % scale_every == scale_every - 1
	var mailed := mail_every > 0 and index % mail_every == mail_every - 1
	var hided := hide_every > 0 and index % hide_every == hide_every - 1
	var dusked := dusk_every > 0 and index % dusk_every == dusk_every - 1
	var veiled := veil_every > 0 and index % veil_every == veil_every - 1
	var palled := pall_every > 0 and index % pall_every == pall_every - 1
	var gloomed := gloom_every > 0 and index % gloom_every == gloom_every - 1
	var murked := murk_every > 0 and index % murk_every == murk_every - 1
	var dreaded := dread_every > 0 and index % dread_every == dread_every - 1
	var woed := woe_every > 0 and index % woe_every == woe_every - 1
	var blighted := blight_every > 0 and index % blight_every == blight_every - 1
	var rotted := rot_every > 0 and index % rot_every == rot_every - 1
	var mildewed := mildew_every > 0 and index % mildew_every == mildew_every - 1
	var rusted := rust_every > 0 and index % rust_every == rust_every - 1
	var scabbed := scab_every > 0 and index % scab_every == scab_every - 1
	var spotted := spot_every > 0 and index % spot_every == spot_every - 1
	var scalded := scald_every > 0 and index % scald_every == scald_every - 1
	var blistered := blister_every > 0 and index % blister_every == blister_every - 1
	var charred := char_every > 0 and index % char_every == char_every - 1
	var scorched := scorch_every > 0 and index % scorch_every == scorch_every - 1
	var seared := sear_every > 0 and index % sear_every == sear_every - 1
	var singed := singe_every > 0 and index % singe_every == singe_every - 1
	var branded := brand_every > 0 and index % brand_every == brand_every - 1
	spawn_pest(tile_center(cell.x, cell.y), shrouded, rinded, pitched, frosted, webbed, glassed, scaled, mailed, hided, dusked, veiled, palled, gloomed, murked, dreaded, woed, blighted, rotted, mildewed, rusted, scabbed, spotted, scalded, blistered, charred, scorched, seared, singed, branded)
	spawns_left -= 1
	spawn_wait = spawn_interval


func _move_pests() -> void:
	for entry in pests:
		var pest := entry as Pest
		if not pest.alive:
			continue
		if pest.slow_ticks > 0:
			pest.slow_ticks -= 1
			if pest.slow_ticks <= 0:
				pest.slow_factor = 1.0
		var offset := player_pos - pest.pos
		var distance := offset.length()
		if distance <= 0.001:
			continue
		var step_len := pest.speed * pest.slow_factor * DT
		if step_len >= distance:
			pest.pos = player_pos
		else:
			pest.pos += offset * (step_len / distance)


func _refresh_visibility() -> void:
	for entry in pests:
		_apply_visibility(entry as Pest)


func _apply_visibility(pest: Pest) -> void:
	if not pest.alive:
		pest.hidden = true
		return
	var cell := cell_of(pest.pos)
	if pest.shrouded or pest.rinded or pest.pitched or pest.frosted or pest.webbed or pest.glassed or pest.scaled or pest.mailed or pest.hided or pest.dusked or pest.veiled or pest.palled or pest.gloomed or pest.murked or pest.dreaded or pest.woed or pest.blighted or pest.rotted or pest.mildewed or pest.rusted or pest.scabbed or pest.spotted or pest.scalded or pest.blistered or pest.charred or pest.scorched or pest.seared or pest.singed or pest.branded:
		var open := true
		if pest.shrouded:
			open = open and tile_burns_shroud(cell.x, cell.y)
		if pest.rinded:
			open = open and tile_cracks_rind(cell.x, cell.y)
		if pest.pitched:
			open = open and tile_melts_pitch(cell.x, cell.y)
		if pest.frosted:
			open = open and tile_thaws_frost(cell.x, cell.y)
		if pest.webbed:
			open = open and tile_cuts_web(cell.x, cell.y)
		if pest.glassed:
			open = open and tile_cracks_glass(cell.x, cell.y)
		if pest.scaled:
			open = open and tile_strips_scale(cell.x, cell.y)
		if pest.mailed:
			open = open and tile_cracks_mail(cell.x, cell.y)
		if pest.hided:
			open = open and tile_splits_hide(cell.x, cell.y)
		if pest.dusked:
			open = open and tile_shades_dusk(cell.x, cell.y)
		if pest.veiled:
			open = open and tile_cowls_veil(cell.x, cell.y)
		if pest.palled:
			open = open and tile_hoods_pall(cell.x, cell.y)
		if pest.gloomed:
			open = open and tile_cloaks_gloom(cell.x, cell.y)
		if pest.murked:
			open = open and tile_capes_murk(cell.x, cell.y)
		if pest.dreaded:
			open = open and tile_shawls_dread(cell.x, cell.y)
		if pest.woed:
			open = open and tile_stoles_woe(cell.x, cell.y)
		if pest.blighted:
			open = open and tile_mantles_blight(cell.x, cell.y)
		if pest.rotted:
			open = open and tile_tippets_rot(cell.x, cell.y)
		if pest.mildewed:
			open = open and tile_wimples_mildew(cell.x, cell.y)
		if pest.rusted:
			open = open and tile_albs_rust(cell.x, cell.y)
		if pest.scabbed:
			open = open and tile_amices_scab(cell.x, cell.y)
		if pest.spotted:
			open = open and tile_orphreys_spot(cell.x, cell.y)
		if pest.scalded:
			open = open and tile_maniples_scald(cell.x, cell.y)
		if pest.blistered:
			open = open and tile_chasubles_blister(cell.x, cell.y)
		if pest.charred:
			open = open and tile_dalmatics_char(cell.x, cell.y)
		if pest.scorched:
			open = open and tile_tunicles_scorch(cell.x, cell.y)
		if pest.seared:
			open = open and tile_rochets_sear(cell.x, cell.y)
		if pest.singed:
			open = open and tile_copes_singe(cell.x, cell.y)
		if pest.branded:
			open = open and tile_surplices_brand(cell.x, cell.y)
		pest.hidden = not open
	else:
		pest.hidden = not tile_lit(cell.x, cell.y)


func _shroud_up(pest: Pest) -> bool:
	if not pest.shrouded:
		return false
	var cell := cell_of(pest.pos)
	return not tile_burns_shroud(cell.x, cell.y)


func _rind_up(pest: Pest) -> bool:
	if not pest.rinded:
		return false
	var cell := cell_of(pest.pos)
	return not tile_cracks_rind(cell.x, cell.y)


func _pitch_up(pest: Pest) -> bool:
	if not pest.pitched:
		return false
	var cell := cell_of(pest.pos)
	return not tile_melts_pitch(cell.x, cell.y)


func _frost_up(pest: Pest) -> bool:
	if not pest.frosted:
		return false
	var cell := cell_of(pest.pos)
	return not tile_thaws_frost(cell.x, cell.y)


func _web_up(pest: Pest) -> bool:
	if not pest.webbed:
		return false
	var cell := cell_of(pest.pos)
	return not tile_cuts_web(cell.x, cell.y)


func _glass_up(pest: Pest) -> bool:
	if not pest.glassed:
		return false
	var cell := cell_of(pest.pos)
	return not tile_cracks_glass(cell.x, cell.y)


func _scale_up(pest: Pest) -> bool:
	if not pest.scaled:
		return false
	var cell := cell_of(pest.pos)
	return not tile_strips_scale(cell.x, cell.y)


func _mail_up(pest: Pest) -> bool:
	if not pest.mailed:
		return false
	var cell := cell_of(pest.pos)
	return not tile_cracks_mail(cell.x, cell.y)


func _hide_up(pest: Pest) -> bool:
	if not pest.hided:
		return false
	var cell := cell_of(pest.pos)
	return not tile_splits_hide(cell.x, cell.y)


func _dusk_up(pest: Pest) -> bool:
	if not pest.dusked:
		return false
	var cell := cell_of(pest.pos)
	return not tile_shades_dusk(cell.x, cell.y)


func _veil_up(pest: Pest) -> bool:
	if not pest.veiled:
		return false
	var cell := cell_of(pest.pos)
	return not tile_cowls_veil(cell.x, cell.y)


func _pall_up(pest: Pest) -> bool:
	if not pest.palled:
		return false
	var cell := cell_of(pest.pos)
	return not tile_hoods_pall(cell.x, cell.y)


func _gloom_up(pest: Pest) -> bool:
	if not pest.gloomed:
		return false
	var cell := cell_of(pest.pos)
	return not tile_cloaks_gloom(cell.x, cell.y)


func _murk_up(pest: Pest) -> bool:
	if not pest.murked:
		return false
	var cell := cell_of(pest.pos)
	return not tile_capes_murk(cell.x, cell.y)


func _dread_up(pest: Pest) -> bool:
	if not pest.dreaded:
		return false
	var cell := cell_of(pest.pos)
	return not tile_shawls_dread(cell.x, cell.y)


func _woe_up(pest: Pest) -> bool:
	if not pest.woed:
		return false
	var cell := cell_of(pest.pos)
	return not tile_stoles_woe(cell.x, cell.y)


func _blight_up(pest: Pest) -> bool:
	if not pest.blighted:
		return false
	var cell := cell_of(pest.pos)
	return not tile_mantles_blight(cell.x, cell.y)


func _rot_up(pest: Pest) -> bool:
	if not pest.rotted:
		return false
	var cell := cell_of(pest.pos)
	return not tile_tippets_rot(cell.x, cell.y)


func _mildew_up(pest: Pest) -> bool:
	if not pest.mildewed:
		return false
	var cell := cell_of(pest.pos)
	return not tile_wimples_mildew(cell.x, cell.y)


func _rust_up(pest: Pest) -> bool:
	if not pest.rusted:
		return false
	var cell := cell_of(pest.pos)
	return not tile_albs_rust(cell.x, cell.y)


func _scab_up(pest: Pest) -> bool:
	if not pest.scabbed:
		return false
	var cell := cell_of(pest.pos)
	return not tile_amices_scab(cell.x, cell.y)


func _spot_up(pest: Pest) -> bool:
	if not pest.spotted:
		return false
	var cell := cell_of(pest.pos)
	return not tile_orphreys_spot(cell.x, cell.y)


func _scald_up(pest: Pest) -> bool:
	if not pest.scalded:
		return false
	var cell := cell_of(pest.pos)
	return not tile_maniples_scald(cell.x, cell.y)


func _blister_up(pest: Pest) -> bool:
	if not pest.blistered:
		return false
	var cell := cell_of(pest.pos)
	return not tile_chasubles_blister(cell.x, cell.y)


func _char_up(pest: Pest) -> bool:
	if not pest.charred:
		return false
	var cell := cell_of(pest.pos)
	return not tile_dalmatics_char(cell.x, cell.y)


func _scorch_up(pest: Pest) -> bool:
	if not pest.scorched:
		return false
	var cell := cell_of(pest.pos)
	return not tile_tunicles_scorch(cell.x, cell.y)


func _sear_up(pest: Pest) -> bool:
	if not pest.seared:
		return false
	var cell := cell_of(pest.pos)
	return not tile_rochets_sear(cell.x, cell.y)


func _singe_up(pest: Pest) -> bool:
	if not pest.singed:
		return false
	var cell := cell_of(pest.pos)
	return not tile_copes_singe(cell.x, cell.y)


func _brand_up(pest: Pest) -> bool:
	if not pest.branded:
		return false
	var cell := cell_of(pest.pos)
	return not tile_surplices_brand(cell.x, cell.y)


func _plants_fire() -> void:
	for entry in plants:
		var plant := entry as Plant
		if not plant.alive:
			continue
		if plant.cooldown > 0:
			plant.cooldown -= 1
			continue
		var target: Pest = _choose_target(plant)
		if target == null:
			continue
		var shot := Projectile.new()
		shot.kind = plant.kind
		shot.pos = plant.pos
		shot.speed = plant.projectile_speed
		shot.damage = plant.damage
		shot.target_id = target.id
		shot.life = PROJECTILE_LIFE
		shot.splash_radius = plant.splash_radius
		shot.slow_factor = plant.slow_factor
		shot.slow_ticks = plant.slow_ticks
		var aim := target.pos - plant.pos
		shot.dir = aim.normalized() if aim.length_squared() > 0.0001 else Vector2.RIGHT
		projectiles.append(shot)
		plant.cooldown = plant.fire_ticks
		shots_fired += 1


func _choose_target(plant: Plant) -> Pest:
	var best: Pest = null
	var best_player_distance := INF
	var best_id := 0
	for entry in pests:
		var pest := entry as Pest
		if not pest.alive or pest.hidden:
			continue
		if plant.pos.distance_to(pest.pos) > plant.weapon_range:
			continue
		var player_distance := player_pos.distance_to(pest.pos)
		if best == null or player_distance < best_player_distance - 0.001 or (absf(player_distance - best_player_distance) <= 0.001 and pest.id < best_id):
			best = pest
			best_player_distance = player_distance
			best_id = pest.id
	return best


func _move_projectiles() -> void:
	for entry in projectiles:
		var shot := entry as Projectile
		if not shot.alive:
			continue
		var target: Pest = pest_by_id(shot.target_id)
		if target != null and target.alive:
			var aim := target.pos - shot.pos
			if aim.length_squared() > 0.0001:
				shot.dir = aim.normalized()
		var dest := shot.pos + shot.dir * shot.speed * DT
		if target != null and target.alive:
			var reach := PROJECTILE_RADIUS + PEST_RADIUS
			if _segment_hits(shot.pos, dest, target.pos, reach):
				_impact(shot, target)
				continue
		shot.pos = dest
		shot.life -= 1
		if shot.life <= 0:
			shot.alive = false


func _impact(shot: Projectile, target: Pest) -> void:
	shot.alive = false
	var victims: Array = [target]
	if shot.splash_radius > 0.0:
		for entry in pests:
			var other := entry as Pest
			if other == target or not other.alive:
				continue
			if other.pos.distance_to(target.pos) <= shot.splash_radius:
				victims.append(other)
	for entry in victims:
		var pest := entry as Pest
		if pest.alive:
			_damage_pest(pest, shot)


func _damage_pest(pest: Pest, shot: Projectile) -> void:
	if _shroud_up(pest) or _rind_up(pest) or _pitch_up(pest) or _frost_up(pest) or _web_up(pest) or _glass_up(pest) or _scale_up(pest) or _mail_up(pest) or _hide_up(pest) or _dusk_up(pest) or _veil_up(pest) or _pall_up(pest) or _gloom_up(pest) or _murk_up(pest) or _dread_up(pest) or _woe_up(pest) or _blight_up(pest) or _rot_up(pest) or _mildew_up(pest) or _rust_up(pest) or _scab_up(pest) or _spot_up(pest) or _scald_up(pest) or _blister_up(pest) or _char_up(pest) or _scorch_up(pest) or _sear_up(pest) or _singe_up(pest) or _brand_up(pest):
		return
	pest.hp -= shot.damage
	if shot.slow_ticks > 0:
		pest.slow_ticks = shot.slow_ticks
		pest.slow_factor = shot.slow_factor
	var hp_after := maxi(pest.hp, 0)
	events.append({
		"type": "hit",
		"damage": shot.damage,
		"pest_id": pest.id,
		"hp_after": hp_after,
		"kind": shot.kind,
	})
	if pest.hp <= 0:
		pest.hp = 0
		pest.alive = false
		if pest.shrouded:
			shrouds_killed += 1
		if pest.rinded:
			rinds_killed += 1
		if pest.pitched:
			pitches_killed += 1
		if pest.frosted:
			frosts_killed += 1
		if pest.webbed:
			webs_killed += 1
		if pest.glassed:
			glasses_killed += 1
		if pest.scaled:
			scales_killed += 1
		if pest.mailed:
			mails_killed += 1
		if pest.hided:
			hides_killed += 1
		if pest.dusked:
			dusks_killed += 1
		if pest.veiled:
			veils_killed += 1
		if pest.palled:
			palls_killed += 1
		if pest.gloomed:
			glooms_killed += 1
		if pest.murked:
			murks_killed += 1
		if pest.dreaded:
			dreads_killed += 1
		if pest.woed:
			woes_killed += 1
		if pest.blighted:
			blights_killed += 1
		if pest.rotted:
			rots_killed += 1
		if pest.mildewed:
			mildews_killed += 1
		if pest.rusted:
			rusts_killed += 1
		if pest.scabbed:
			scabs_killed += 1
		if pest.spotted:
			spots_killed += 1
		if pest.scalded:
			scalds_killed += 1
		if pest.blistered:
			blisters_killed += 1
		if pest.charred:
			chars_killed += 1
		if pest.scorched:
			scorches_killed += 1
		if pest.seared:
			sears_killed += 1
		if pest.singed:
			singes_killed += 1
		if pest.branded:
			brands_killed += 1
		events.append({
			"type": "died",
			"x": pest.pos.x,
			"y": pest.pos.y,
			"hidden": pest.hidden,
			"id": pest.id,
		})


func _contact() -> void:
	if hurt_ticks > 0:
		hurt_ticks -= 1
	if hurt_ticks > 0:
		return
	var reach := PLAYER_RADIUS + PEST_RADIUS
	for entry in pests:
		var pest := entry as Pest
		if not pest.alive:
			continue
		if player_pos.distance_to(pest.pos) > reach:
			continue
		player_hp -= CONTACT_DAMAGE
		hurt_ticks = HURT_TICKS
		if player_hp <= 0:
			player_hp = 0
			outcome = OUTCOME_LOST
		events.append({"type": "hurt", "hp": player_hp})
		if outcome == OUTCOME_LOST:
			events.append({"type": "lost"})
		return


func _cull() -> void:
	var next_pests: Array = []
	for entry in pests:
		if (entry as Pest).alive:
			next_pests.append(entry)
	pests = next_pests
	var next_shots: Array = []
	for entry in projectiles:
		if (entry as Projectile).alive:
			next_shots.append(entry)
	projectiles = next_shots


func _in_orchard(cell: Vector2i) -> bool:
	return cell.x >= 1 and cell.y >= 1 and cell.x <= MAP_W - 2 and cell.y <= MAP_H - 2


func _plant_on(cell: Vector2i):
	for entry in plants:
		var plant := entry as Plant
		if plant.alive and plant.cell == cell:
			return plant
	return null


func _segment_hits(start: Vector2, dest: Vector2, center: Vector2, radius: float) -> bool:
	var span := dest - start
	var length_sq := span.length_squared()
	var t := 0.0
	if length_sq > 0.000001:
		t = clampf((center - start).dot(span) / length_sq, 0.0, 1.0)
	var closest := start + span * t
	return closest.distance_squared_to(center) <= radius * radius
