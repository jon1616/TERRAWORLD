class_name BuildPainter
extends RefCounted
## L'atlante dei costrutti (voce 128): una riga per costrutto (`BuildData.kinds`), 16 colonne per i bordi (quali dei 4
## vicini sono anch'essi costrutti: 1 su, 2 destra, 4 giù, 8 sinistra). Il disegno della forma (mattoni, lastre,
## colonna…) nasce dalla tavolozza del materiale; dove non c'è un vicino, un bordo scuro e sopra un filo di luce. E
## l'atlante delle pareti costruite: una riga per materiale, 4 varianti. Puro codice: si prepara in `ViewArt`, anche in un
## thread.

const S := 16
const COLS := 16
const WALL_VARIANTS := 4


static func build() -> Dictionary:
	var ks := BuildData.kinds()
	var img := Image.create_empty(COLS * S, ks.size() * S, false, Image.FORMAT_RGBA8)
	var glow := Image.create_empty(COLS * S, ks.size() * S, false, Image.FORMAT_RGBA8)
	for e in ks:
		var k := int(e["kind"])
		var md := BuildData.material_of(k)
		var p := Px.pal(md["pal"])
		var tile := _pattern(String(e["form"]), p)
		for mask in COLS:
			var ox := mask * S
			var oy := (k - 1) * S
			for y in S:
				for x in S:
					var c: Color = tile.get_pixel(x, y)
					# i bordi dove non c'è un vicino costruito
					var edge := (y == 0 and mask & 1 == 0) or (x == S - 1 and mask & 2 == 0) or (y == S - 1 and mask & 4 == 0) \
						or (x == 0 and mask & 8 == 0)
					if edge:
						c = Color(p[0].darkened(0.35), maxf(c.a, 0.9))
					elif y == 1 and mask & 1 == 0:
						c = Color(p[4], maxf(c.a, 0.9))            # un filo di luce in cima
					img.set_pixel(ox + x, oy + y, c)
					if md.get("glow", false) and not edge and c.a > 0.0:
						glow.set_pixel(ox + x, oy + y, Color(p[4], 0.35))
	return {"img": img, "glow": glow}


## Le coordinate nell'atlante di un costrutto con i suoi vicini.
static func coords(k: int, mask: int) -> Vector2i:
	return Vector2i(mask, k - 1)


## L'atlante delle pareti costruite: una riga per materiale, più scura del blocco.
static func walls() -> Image:
	var img := Image.create_empty(WALL_VARIANTS * S, BuildData.MATERIALS.size() * S, false, Image.FORMAT_RGBA8)
	for mi in BuildData.MATERIALS.size():
		var p := Px.pal(BuildData.MATERIALS[mi]["pal"])
		for v in WALL_VARIANTS:
			for y in S:
				for x in S:
					var n := _hash(x + v * 17, y + mi * 5)
					var c: Color = p[1] if n < 0.55 else p[0] if n < 0.8 else p[2]
					if (y % 8 == 7) or ((x + (8 if (y / 8) % 2 == 1 else 0)) % 16 == 0):
						c = p[0].darkened(0.3)                    # i giunti delle lastre di fondo
					img.set_pixel(v * S + x, mi * S + y, c.darkened(0.35))
	return img


static func wall_coords(wall: int, x: int, y: int) -> Vector2i:
	return Vector2i(posmod(x * 7 + y * 3, WALL_VARIANTS), wall - BuildData.WALL_BASE)


static func _hash(x: int, y: int) -> float:
	var h := (x * 374761393 + y * 668265263) & 0x7fffffff
	h = (h ^ (h >> 13)) * 1274126177 & 0x7fffffff
	return float(h % 1000) / 1000.0


## Il disegno di una forma, 16×16, dalla tavolozza (p[0] il più scuro … p[4] il più chiaro).
static func _pattern(form: String, p: Array[Color]) -> Image:
	var im := Image.create_empty(S, S, false, Image.FORMAT_RGBA8)
	for y in S:
		for x in S:
			var n := _hash(x, y)
			var c: Color = p[2]
			match form:
				"grezzo":
					c = p[2] if n < 0.5 else p[1] if n < 0.8 else p[3]
				"mattoni":
					var row := y / 4
					var off := 4 if row % 2 == 1 else 0
					var mortar := y % 4 == 3 or (x + off) % 8 == 7
					c = p[0] if mortar else (p[2] if n < 0.7 else p[3])
				"lastre":
					c = p[0] if y % 8 == 7 else (p[3] if y % 8 == 0 else (p[2] if n < 0.8 else p[1]))
				"levigato":
					c = p[3].lerp(p[2], float(y) / S)
					if (x + y) % 11 == 0:
						c = p[4]
				"colonna":
					var fl := x % 4
					c = p[3] if fl == 1 else p[1] if fl == 3 else p[2]
					if y < 2 or y > 13:
						c = p[3]
				"travi":
					c = p[2] if (y % 5) != 4 else p[0]
					if n > 0.85:
						c = p[1]
					if x == 15 and (y / 5) % 2 == 0:
						c = p[0]
				"tegole":
					var ty := y % 5
					var bump := absf(float((x % 6)) - 2.5)
					c = p[0] if ty == 4 or float(ty) < bump * 0.6 - 0.5 else (p[3] if ty == 0 else p[2])
				"piastrelle":
					var grout := x % 8 == 7 or y % 8 == 7
					var check := ((x / 8) + (y / 8)) % 2 == 0
					c = p[0] if grout else (p[3] if check else p[2])
				"vetrata":
					var frame := x % 8 == 0 or y % 8 == 0
					c = p[1] if frame else Color(p[4], 0.35 + 0.15 * n)
			im.set_pixel(x, y, c)
	return im
