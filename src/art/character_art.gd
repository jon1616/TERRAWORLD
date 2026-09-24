class_name CharacterArt
extends RefCounted
## Il personaggio disegnato dal codice: i fotogrammi non sono fatti a mano, nascono da una posa (angoli di braccia e
## gambe). In futuro verrà sostituito o affiancato dalle immagini generate con l'IA grafica.

# Il Germogliato: pelle calda con una venatura, capelli di foglie, occhi d'ambra, tunica ocra che risalta sul mondo turchese.
const SKIN := Color("#dcb48a")
const SKIN_D := Color("#b08862")
const VEIN := Color("#5aa878")
const HAIR := Color("#1f7a5a")
const HAIR_L := Color("#5cc890")
const HAIR_D := Color("#125040")
const EYE := Color("#ffb040")
const SHIRT := Color("#b8742e")
const SHIRT_L := Color("#d8944a")
const SHIRT_D := Color("#8a5220")
const PANTS := Color("#3a3048")
const PANTS_D := Color("#282034")
const BOOT := Color("#4a2e24")
const BOOT_D := Color("#321e18")
const BELT := Color("#24160e")
const BUCKLE := Color("#3ac0c8")


static func pose_idle() -> Dictionary:
	return {"bob": 0, "fl_t": 0.06, "fl_s": 0.0, "bl_t": -0.08, "bl_s": -0.02,
		"fa_u": 0.12, "fa_l": 0.3, "ba_u": -0.12, "ba_l": 0.05}


static func pose_run(k: int) -> Dictionary:
	var p := k / 8.0 * TAU
	var q := p + PI
	var fl_t := 0.62 * sin(p)
	var bl_t := 0.62 * sin(q)
	return {"bob": 0 if absf(sin(p)) < 0.5 else 1,
		"fl_t": fl_t, "fl_s": fl_t - 1.0 * maxf(0.0, cos(p)) - 0.1,
		"bl_t": bl_t, "bl_s": bl_t - 1.0 * maxf(0.0, cos(q)) - 0.1,
		"fa_u": -0.6 * sin(p), "fa_l": -0.6 * sin(p) + 0.7,
		"ba_u": 0.6 * sin(p), "ba_l": 0.6 * sin(p) + 0.7}


static func pose_jump() -> Dictionary:
	return {"bob": 0, "fl_t": 0.75, "fl_s": -0.15, "bl_t": -0.35, "bl_s": -1.1,
		"fa_u": 2.5, "fa_l": 2.7, "ba_u": -0.9, "ba_l": -0.5}


static func pose_fall() -> Dictionary:
	return {"bob": 0, "fl_t": 0.35, "fl_s": 0.1, "bl_t": -0.25, "bl_s": -0.6,
		"fa_u": 2.0, "fa_l": 2.4, "ba_u": -1.5, "ba_l": -1.2}


static func _limb(im: Image, root: Vector2, a1: float, a2: float, l1: float, l2: float, w: int, c1: Color, c2: Color) -> Vector2:
	var mid := root + Vector2(sin(a1), cos(a1)) * l1
	var end := mid + Vector2(sin(a2), cos(a2)) * l2
	Px.line(im, root, mid, w, c1)
	Px.line(im, mid, end, w, c2)
	return end


static func _leg(im: Image, hip: Vector2, t: float, s: float, col: Color, boot: Color) -> void:
	var knee := hip + Vector2(sin(t), cos(t)) * 5.0
	var foot := knee + Vector2(sin(s), cos(s)) * 5.5
	Px.line(im, hip, knee, 3, col)
	Px.line(im, knee, knee.lerp(foot, 0.35), 3, col)
	Px.line(im, knee.lerp(foot, 0.45), foot, 3, boot)
	Px.stamp(im, foot.x + 1.5, foot.y + 0.5, 2, boot)


## Un fotogramma del personaggio (24×32, rivolto a destra) a partire da una posa. Restituisce l'immagine
## e la posizione della mano davanti, dove si aggancia l'attrezzo.
static func character(pose: Dictionary) -> Dictionary:
	var im := Px.img(24, 32)
	var bob: int = pose["bob"]
	var hip := Vector2(12.0, 19.5 + bob)
	var sh_f := Vector2(12.5, 12.5 + bob)
	var sh_b := Vector2(11.0, 12.5 + bob)
	_limb(im, sh_b, pose["ba_u"], pose["ba_l"], 4.0, 4.0, 2, SHIRT_D, SKIN_D)
	_leg(im, hip + Vector2(-1.0, 0.0), pose["bl_t"], pose["bl_s"], PANTS_D, BOOT_D)
	# busto
	for y in range(11 + bob, 20 + bob):
		for x in range(9, 15):
			var c := SHIRT
			if x == 14:
				c = SHIRT_D
			elif x == 9 and y > 11 + bob:
				c = SHIRT_L
			if y == 18 + bob:
				c = BUCKLE if x == 13 else BELT
			if y == 19 + bob:
				c = PANTS
			Px.put(im, x, y, c)
	_leg(im, hip + Vector2(1.0, 0.0), pose["fl_t"], pose["fl_s"], PANTS, BOOT)
	# testa
	for y in range(3 + bob, 11 + bob):
		for x in range(8, 16):
			Px.put(im, x, y, SKIN_D if x == 15 or y == 10 + bob else SKIN)
	# capelli di foglie: una calotta, foglie che si alzano all'indietro e ciocche che pendono sulla nuca
	for x in range(7, 16):
		Px.put(im, x, 2 + bob, HAIR)
		Px.put(im, x, 3 + bob, HAIR_L if x % 3 == 0 else HAIR)
	for x in range(7, 13):
		Px.put(im, x, 4 + bob, HAIR_D if x < 9 else HAIR)
	for leaf in [[Vector2(9, 2), Vector2(5, 0), HAIR], [Vector2(11, 2), Vector2(9, 0), HAIR_L], [Vector2(7, 3), Vector2(3, 2), HAIR]]:
		Px.line(im, Vector2(leaf[0].x, leaf[0].y + bob), Vector2(leaf[1].x, leaf[1].y + bob), 1, leaf[2])
	Px.put(im, 13, 1 + bob, HAIR_L)
	Px.put(im, 14, 0 + bob, HAIR_L)
	for y in range(4 + bob, 11 + bob):
		Px.put(im, 7, y, HAIR if y < 9 + bob else HAIR_D)
		Px.put(im, 8, y, HAIR_D)
	Px.put(im, 6, 6 + bob, HAIR)
	Px.put(im, 6, 8 + bob, HAIR_D)
	Px.put(im, 9, 5 + bob, HAIR)
	Px.put(im, 15, 4 + bob, HAIR_L)
	Px.put(im, 10, 7 + bob, SKIN_D)
	Px.put(im, 13, 6 + bob, EYE)
	Px.put(im, 13, 7 + bob, EYE)
	Px.put(im, 12, 8 + bob, VEIN)
	Px.put(im, 11, 9 + bob, VEIN)
	Px.put(im, 14, 9 + bob, SKIN_D)
	var hand := _limb(im, sh_f, pose["fa_u"], pose["fa_l"], 4.0, 4.0, 2, SHIRT_L, SKIN)
	Px.outline(im, Px.OUTLINE)
	return {"img": im, "hand": hand, "eye": Vector2(13.5, 7.0 + bob)}
