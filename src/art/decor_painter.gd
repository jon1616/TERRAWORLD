class_name DecorPainter
extends RefCounted
## Pareti di fondo e decorazioni, stile «Radici e Linfa». Le pareti usano trame da 64×64 senza cuciture divise in 16
## pezzi (come il terreno), così la griglia non si vede. Le decorazioni hanno anche una versione luminosa (punte delle
## radici, campanule, funghi, spore) disegnata sopra il buio.
##
## Atlante: una riga di pareti per ogni `TileDefs.WALL_*` (16 varianti ciascuna), poi la riga delle decorazioni
## (id - 1, fino a 32) e quella delle passerelle di radice (4 varianti).

const S := 16
const DECOR_ROW := TileDefs.WALLS
const PLAT_ROW := TileDefs.WALLS + 1
const COLS := 32
const ROWS := TileDefs.WALLS + 2
## Parete di fondo: materiale e tavolozza da cui nasce (scurita e raffreddata).
const WALL_SRC := {
	TileDefs.WALL_DIRT: ["humus", TileDefs.P_DIRT], TileDefs.WALL_STONE: ["ardesia", TileDefs.P_STONE],
	TileDefs.WALL_ROOT: ["radice", TileDefs.P_RADICE], TileDefs.WALL_SCISTO: ["scisto", TileDefs.P_SCISTO],
	TileDefs.WALL_VOID: ["vuotite", TileDefs.P_VUOTITE],
	TileDefs.WALL_SEM: ["pietra_sem", TileDefs.P_SEM],
}


static func wall_coords(kind: int, x: int, y: int) -> Vector2i:
	return Vector2i(TerrainPainter.variant_of(x, y), kind - 1)


static func decor_coords(id: int) -> Vector2i:
	return Vector2i(id - 1, DECOR_ROW)


static func plat_coords(x: int) -> Vector2i:
	return Vector2i(posmod(x, 4), PLAT_ROW)


static func build() -> Dictionary:
	var img := Px.img(COLS * S, ROWS * S)
	var glow := Px.img(COLS * S, ROWS * S)
	for kind in WALL_SRC:
		var src: Array = WALL_SRC[kind]
		var dark: Array[Color] = []
		for c in Px.pal(src[1]):
			var d := Px.sh(c, 0.46)
			dark.append(d.lerp(Color(d.v * 0.8, d.v * 0.9, d.v * 1.1), 0.35))
		var tex := TerrainPainter.material(String(src[0]), dark, 300 + kind)
		for v in TerrainPainter.VARIANTS:
			var vx := v % TerrainPainter.REP
			var vy := v / TerrainPainter.REP
			for py in S:
				for px in S:
					img.set_pixel(v * S + px, (kind - 1) * S + py, tex[(vy * S + py) * TerrainPainter.TEX + vx * S + px])
	for d in range(1, TileDefs.DECOR_COUNT + 1):
		var r := decor(d)
		img.blit_rect(r["img"], Rect2i(0, 0, S, S), Vector2i((d - 1) * S, DECOR_ROW * S))
		glow.blit_rect(r["glow"], Rect2i(0, 0, S, S), Vector2i((d - 1) * S, DECOR_ROW * S))
	for v in 4:
		img.blit_rect(plank(v), Rect2i(0, 0, S, S), Vector2i(v * S, PLAT_ROW * S))
	return {"img": img, "glow": glow}


## Passerella di radice: un'asse di legno di lanterna legata con radici, spessa 5 pixel in cima alla cella.
static func plank(v: int) -> Image:
	var im := Px.img(S, S)
	var wood := Px.pal(["#2e1c26", "#46303a", "#644652", "#86606e"])
	for y in range(1, 5):
		for x in S:
			var c := wood[3] if y == 1 else (wood[2] if y < 4 else wood[1])
			if (x + v * 5) % 7 == 0 and y > 1:
				c = wood[0]
			im.set_pixel(x, y, c)
	var lash := (v * 5 + 6) % 12 + 2
	for y in range(0, 6):
		im.set_pixel(lash, y, Color("#3aa08a") if y % 2 == 0 else Color("#16574f"))
	return im


## Una decorazione 16×16 e la sua parte luminosa.
static func decor(id: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = id * 1013 + 5
	var im := Px.img(S, S)
	var gm := Px.img(S, S)
	var moss := Px.pal(TileDefs.P_GRASS)
	var root := Px.pal(TileDefs.P_ROOT)
	var outline := true
	match id:
		1, 2, 3:
			# fronde di muschio: steli che si piegano con foglioline alterne
			outline = false
			for k in 3 + id:
				var bx := rng.randf_range(2.0, 13.0)
				var hgt := rng.randf_range(4.0, 6.0 + id * 2.0)
				var bend := rng.randf_range(-3.0, 3.0)
				for s in int(hgt):
					var t := s / hgt
					var x := bx + bend * t * t
					var c := moss[clampi(1 + int(t * 4.0), 1, 4)]
					Px.put(im, int(x), 15 - s, c)
					if s % 2 == 1 and s > 1:
						Px.put(im, int(x) + (1 if s % 4 == 1 else -1), 15 - s, moss[2])
		4, 5, 6:
			# campanule luminose: stelo ad arco e corolla che pende
			var heads := [TileDefs.P_CRYSTAL, TileDefs.P_BRACE, ["#3a1a5a", "#6a3aa8", "#a878f0", "#e0c8ff"]]
			var hp := Px.pal(heads[id - 4])
			Px.curve(im, Vector2(8, 15), Vector2(7, 6), Vector2(11, 6), 1, moss[2])
			Px.put(im, 6, 12, moss[3])
			Px.put(im, 9, 11, moss[3])
			for y in range(7, 11):
				var hw := 1 if y < 9 else 2
				for x in range(11 - hw, 11 + hw + 1):
					var c := hp[2] if x >= 11 else hp[1]
					Px.put(im, x, y, c)
					Px.put(gm, x, y, c)
			Px.put(im, 11, 11, hp[3])
			Px.put(gm, 11, 11, hp[3])
		7, 8:
			var sp := Px.pal(TileDefs.P_STONE)
			var rx := 4.0 if id == 7 else 2.6
			var cx := 8.0 if id == 7 else 6.0
			for y in range(10, 16):
				for x in S:
					var dx := (x + 0.5 - cx) / rx
					var dy := (y + 0.5 - 15.0) / 3.0
					if dx * dx + dy * dy <= 1.0:
						Px.put(im, x, y, sp[clampi(int((0.5 - dx * 0.35 - dy * 0.5) * 5.0), 1, 4)])
		9, 10:
			var stem := Color("#d8c8b0") if id == 9 else Color("#9ad8e8")
			var cap := Px.pal(TileDefs.P_BRACE) if id == 9 else Px.pal(["#0a6a9a", "#28c0ff", "#b0f4ff", "#e8ffff"])
			Px.line(im, Vector2(8, 15), Vector2(8, 11), 2, stem)
			for y in range(6, 11):
				for x in S:
					var dx := (x + 0.5 - 8.5) / 4.6
					var dy := (y + 0.5 - 10.5) / 4.0
					if dx * dx + dy * dy <= 1.0:
						var c: Color = cap[clampi(int((0.55 - dx * 0.3 - dy * 0.5) * 3.0), 0, 2)]
						Px.put(im, x, y, c)
						if id == 10:
							Px.put(gm, x, y, c)
			if id == 9:
				for sp in [Vector2i(6, 8), Vector2i(9, 7), Vector2i(11, 9)]:
					Px.put(im, sp.x, sp.y, Color("#ffe8c0"))
		11, 12:
			# radici pendenti dal soffitto, con la punta accesa di Linfa
			outline = false
			var amber := Px.pal(TileDefs.P_BRACE)
			for k in (3 if id == 11 else 2):
				var x := rng.randf_range(3.0, 12.0)
				var length := rng.randi_range(10, 15) if id == 11 else rng.randi_range(6, 9)
				var sway := rng.randf_range(-1.5, 1.5)
				for y in length:
					var xx := int(round(x + sin(y * 0.6 + k) * 0.8 + sway * y / length))
					Px.put(im, xx, y, root[1] if y % 3 != 0 else root[2])
					if y < 3:
						Px.put(im, xx + 1, y, root[0])
				var tip := int(round(x + sway))
				for t in 2:
					Px.put(im, tip, length + t, amber[3 - t])
					Px.put(gm, tip, length + t, amber[3 - t])
		13:
			# sacca di spore: bolla viola traslucida su un gambo corto
			Px.line(im, Vector2(8, 15), Vector2(8, 12), 1, moss[1])
			for y in range(5, 13):
				for x in S:
					var dx := (x + 0.5 - 8.0) / 4.0
					var dy := (y + 0.5 - 9.0) / 3.8
					var d := dx * dx + dy * dy
					if d <= 1.0:
						var c := Color("#b890ff") if d < 0.35 else Color(0.45, 0.28, 0.72, 0.85)
						Px.put(im, x, y, c)
						if d < 0.35:
							Px.put(gm, x, y, c)
			Px.put(im, 6, 7, Color(1, 1, 1, 0.9))
		15:
			# germoglio d'albero-lanterna: fusticino contorto, due foglie, una gemma d'ambra
			outline = false
			var bark := Px.pal(["#241624", "#362234", "#4c3246"])
			Px.line(im, Vector2(8, 15), Vector2(8, 8), 1, bark[2])
			Px.put(im, 7, 11, bark[1])
			for q in [Vector2i(6, 8), Vector2i(5, 7), Vector2i(10, 7), Vector2i(11, 6)]:
				Px.put(im, q.x, q.y, moss[3])
			Px.put(im, 7, 8, moss[2])
			Px.put(im, 9, 7, moss[2])
			Px.put(im, 8, 6, Color(TileDefs.P_BRACE[3]))
			Px.put(gm, 8, 6, Color(TileDefs.P_BRACE[3]))
		14:
			# felce arricciata (pastorale)
			outline = false
			Px.line(im, Vector2(8, 15), Vector2(8, 8), 1, moss[2])
			var a := 0.0
			var r := 3.2
			for s in 26:
				var p := Vector2(8.0 + 2.8, 7.0) + Vector2(cos(a + PI), sin(a + PI)) * r
				Px.put(im, int(p.x), int(p.y), moss[3])
				a += 0.35
				r *= 0.93
			Px.put(im, 7, 11, moss[3])
			Px.put(im, 9, 10, moss[3])
		16:
			# scheggia del Vuoto: tre punte di vuotite che si aprono a ventaglio, il cuore viola acceso
			var vp := Px.pal(TileDefs.P_VUOTITE)
			for sh in [[8.0, 4.0, 2.2], [5.0, 8.0, 1.6], [11.5, 7.0, 1.7]]:
				var top := Vector2(sh[0], sh[1])
				for y in range(int(sh[1]), 16):
					var t: float = (y - sh[1]) / (16.0 - sh[1])
					var hw: float = sh[2] * t + 0.3
					for x in range(int(top.x - hw), int(top.x + hw) + 1):
						var c := vp[4] if x < top.x else vp[2]
						if absf(x - top.x) < 0.8 and t < 0.7:
							c = Color("#d8b0ff")
							Px.put(gm, x, y, c)
						Px.put(im, x, y, c)
		19:
			# rovo spinoso: steli neri intrecciati con le spine rosse
			outline = false
			var thorn := Color("#c83a3a")
			for k in 4:
				var bx := 2.0 + k * 3.5
				var top := Vector2(bx + rng.randf_range(-2.0, 2.0), rng.randf_range(4.0, 8.0))
				Px.curve(im, Vector2(bx, 15.0), Vector2(bx + rng.randf_range(-3.0, 3.0), 10.0), top, 1, Color("#2a1a22"))
				for s in 3:
					var q := Vector2(bx, 15.0).lerp(top, (s + 1) / 4.0)
					Px.put(im, int(q.x) + (1 if s % 2 == 0 else -1), int(q.y), thorn)
					# le punte brillano appena: un pericolo si deve vedere anche al buio
					Px.put(gm, int(q.x) + (1 if s % 2 == 0 else -1), int(q.y), thorn * Color(1, 1, 1, 0.7))
		20:
			# runa trappola: un segno inciso sul pavimento, appena acceso di verde malato
			outline = false
			var tc := Color("#6a8a4a")
			for q in [Vector2i(4, 14), Vector2i(5, 13), Vector2i(6, 14), Vector2i(7, 13), Vector2i(8, 14), Vector2i(9, 13),
					Vector2i(10, 14), Vector2i(11, 13), Vector2i(7, 12), Vector2i(8, 12)]:
				Px.put(im, q.x, q.y, tc)
				Px.put(gm, q.x, q.y, tc * Color(1, 1, 1, 0.5))
		21:
			# Bocciolo del cuore: un bulbo corallo a forma di cuore chiuso tra due foglie, che pulsa di luce rosa
			Px.line(im, Vector2(8, 15), Vector2(8, 10), 1, moss[2])
			Px.curve(im, Vector2(8, 14), Vector2(5, 13), Vector2(3, 10), 1, moss[3])
			Px.curve(im, Vector2(8, 13), Vector2(11, 12), Vector2(13, 9), 1, moss[3])
			var co := Px.pal(["#5a1024", "#a02040", "#e04a60", "#ff9aa8", "#ffe0e6"])
			for y in range(2, 11):
				for x in S:
					var u := (x + 0.5 - 8.0) / 4.2
					var v := (y + 0.5 - 6.2) / 4.0
					if u * u + pow(-v - sqrt(absf(u)) * 0.6, 2.0) <= 1.0:
						var c := co[3] if u < -0.2 else co[2]
						if u * u + v * v < 0.18:
							c = co[4]
						Px.put(im, x, y, c)
						Px.put(gm, x, y, c * Color(1, 1, 1, 0.8))
		22:
			# Stilla perenne: una goccia d'oro e di Linfa appesa a un filo di radice, che non cade mai
			outline = false
			for y in 6:
				Px.put(im, 8, y, root[1] if y % 2 == 0 else root[2])
			var sp := Px.pal(["#12566a", "#5cc8cc", "#b8f4f0", "#fff2a8"])
			for y in range(6, 15):
				var t := (y - 6.0) / 8.0
				var hw := 3.2 * sqrt(t) * (1.0 - maxf(t - 0.7, 0.0) * 3.0)
				for x in S:
					var dx := x + 0.5 - 8.0
					if absf(dx) <= hw:
						var c := sp[3] if dx < -0.8 else (sp[2] if dx < 0.8 else sp[1])
						Px.put(im, x, y, c)
						Px.put(gm, x, y, c)
		18:
			# runa dei Seminatori: un segno inciso che brilla di Linfa, sospeso davanti alla parete
			outline = false
			var rc := Color("#6ff0d8")
			for q in [Vector2i(8, 4), Vector2i(8, 5), Vector2i(8, 6), Vector2i(8, 7), Vector2i(8, 8), Vector2i(8, 9),
					Vector2i(8, 10), Vector2i(7, 5), Vector2i(6, 6), Vector2i(9, 7), Vector2i(10, 8), Vector2i(7, 10),
					Vector2i(9, 10), Vector2i(6, 11), Vector2i(10, 11)]:
				Px.put(im, q.x, q.y, rc)
				Px.put(gm, q.x, q.y, rc)
		17:
			# goccia di Linfa che pende da un filo di radice
			outline = false
			var lx := int(rng.randf_range(5.0, 11.0))
			for y in 7:
				Px.put(im, lx, y, root[1] if y % 2 == 0 else root[2])
			var lp := Px.pal(TileDefs.P_CRYSTAL)
			for y in range(7, 12):
				var hw := 0 if y == 7 else (1 if y < 11 else 0)
				for x in range(lx - hw, lx + hw + 1):
					var c := lp[4] if x < lx or y == 8 else lp[3]
					Px.put(im, x, y, c)
					Px.put(gm, x, y, c)
	if outline:
		Px.outline(im, Color(0.04, 0.05, 0.08, 0.9))
	return {"img": im, "glow": gm}
