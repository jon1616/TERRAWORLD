class_name ItemIcons
extends RefCounted
## Icone degli oggetti (16×16) nello stile «Radici e Linfa»: manici di legno di radice fasciati di foglia, lame a forma
## di foglia, lingotti a forma di seme, perle d'ambra. Ogni forma è una funzione; il materiale sceglie la tavolozza,
## così la stessa funzione fa la spada di radicite, di legnoferro, d'ambra… `make(forma, materiale)`, oppure `of(id)` da `ItemsData`.

const S := 16
const OUT := Color("#050c10")
const MATERIALS := {
	"radicite": ["#5a2414", "#963a22", "#cc6034", "#f8a070"],
	"legnoferro": ["#3a4250", "#6a7688", "#a2b0c2", "#dce6f2"],
	"ambra": ["#6a4a0c", "#b0861c", "#eec04a", "#fff2a8"],
	"brace": ["#5a2a14", "#9a4a22", "#d4783a", "#ffb070"],
	"cristallo": ["#0a2a36", "#1f8a9a", "#5cc8cc", "#b8f4f0"],
	"legno": ["#1c1016", "#2e1c26", "#46303a", "#644652", "#86606e"],
	"humus": ["#34202a", "#4a2e3c", "#62404e", "#7c5262", "#9a6a7a"],
	"ardesia": ["#2a3650", "#3a4966", "#4c5e80", "#62779c", "#8298bc"],
	"muschio": ["#0f3a3a", "#16574f", "#23776a", "#3aa08a", "#72d4b0"],
	"linfa": ["#5a1024", "#a02040", "#e04a60", "#ff9aa8"],
	"sem": ["#2c3a3a", "#405656", "#587270", "#74908c", "#9cb6b0"],
	"nodo": ["#3a3832", "#54524a", "#6e6c60", "#8a887a", "#a8a694"],
	"radice": ["#4a2c22", "#6a3e2c", "#8a5638", "#a8704a", "#c89066"],
	"scisto": ["#263a40", "#34505a", "#446872", "#58848c", "#7aa6aa"],
	"vuotite": ["#261c38", "#34264c", "#463464", "#5c4682", "#9c7ad0"],
	"lucciola": ["#3a4a10", "#8aa020", "#d8ff70", "#f8ffd0"],
	"seta": ["#6a6a5e", "#9a9a8a", "#cacabc", "#f4f4ea"],
	"fungo": ["#6a2a3a", "#a0405a", "#d86a7a", "#ffb0b8"],
}
const LEAF := ["#16574f", "#3aa08a", "#72d4b0"]
const AMBER := ["#9a4a22", "#ffb040", "#ffe0a0"]


static func of(id: String) -> Image:
	var it := ItemsData.get_item(id)
	if it.is_empty():
		return make("?", "ardesia")
	var ic: Array = it["icon"]
	return make(String(ic[0]), String(ic[1]))


static func pal(material: String) -> Array[Color]:
	return Px.pal(MATERIALS.get(material, MATERIALS["ardesia"]))


static func make(shape: String, material: String) -> Image:
	var im := Px.img(S, S)
	var p := pal(material)
	match shape:
		"piccone":
			_handle(im, Vector2(2.5, 13.5), Vector2(10.0, 6.0))
			Px.curve(im, Vector2(4.5, 3.0), Vector2(12.5, 1.5), Vector2(13.5, 10.0), 2, p[1])
			Px.curve(im, Vector2(4.5, 2.5), Vector2(12.0, 1.0), Vector2(13.0, 9.5), 1, p[2])
			Px.put(im, 4, 3, p[3])
			Px.put(im, 13, 10, p[3])
			_bead(im, 10, 6)
		"ascia":
			_handle(im, Vector2(3.5, 14.0), Vector2(10.5, 3.5))
			for y in range(1, 10):
				for x in range(9, 16):
					var d := Vector2(x + 0.5 - 9.5, y + 0.5 - 5.0)
					if d.x > 0.0 and d.length() <= 5.2:
						Px.put(im, x, y, p[2] if d.x > 3.5 else p[1])
			Px.line(im, Vector2(14.0, 2.0), Vector2(14.0, 8.0), 1, p[3])
			_bead(im, 10, 5)
		"spada":
			# lama a foglia: larga al centro, affilata in punta, con la nervatura
			var a := Vector2(4.5, 11.5)
			var b := Vector2(14.0, 2.0)
			for k in 31:
				var t := k / 30.0
				var q := a.lerp(b, t)
				var w := 1.0 + 2.2 * sin(t * PI) * (1.0 - t * 0.35)
				Px.stamp(im, q.x, q.y, maxi(int(round(w)), 1), p[1] if t < 0.9 else p[2])
			Px.line(im, a, b, 1, p[2])
			Px.line(im, a + Vector2(-0.5, -1.0), b + Vector2(-1.0, 0.0), 1, p[3])
			Px.put(im, 3, 10, Color(LEAF[1]))
			Px.put(im, 5, 13, Color(LEAF[1]))
			_handle(im, Vector2(1.5, 14.5), Vector2(4.0, 12.0))
			_bead(im, 4, 12)
		"arco":
			Px.curve(im, Vector2(3.0, 2.0), Vector2(15.0, 0.5), Vector2(14.0, 13.0), 2, p[2])
			Px.curve(im, Vector2(3.0, 1.5), Vector2(14.5, 0.0), Vector2(14.5, 12.5), 1, p[3])
			Px.line(im, Vector2(3.5, 2.5), Vector2(13.5, 12.5), 1, Color("#b8f4f0"))
			Px.put(im, 2, 1, Color(LEAF[2]))
			Px.put(im, 15, 13, Color(LEAF[2]))
		"freccia":
			Px.line(im, Vector2(2.0, 14.0), Vector2(12.0, 4.0), 1, Color(MATERIALS["legno"][3]))
			Px.stamp(im, 13.0, 3.0, 2, p[3])
			Px.put(im, 14, 2, p[4] if p.size() > 4 else p[3])
			for q in [Vector2i(2, 12), Vector2i(3, 13), Vector2i(1, 13), Vector2i(2, 14)]:
				Px.put(im, q.x, q.y, Color(LEAF[1]))
		"torcia":
			_handle(im, Vector2(7.0, 14.5), Vector2(8.0, 7.5))
			Px.disc(im, 8.0, 5.2, 2.7, Color(AMBER[0]))
			Px.disc(im, 8.0, 5.4, 1.8, Color(AMBER[1]))
			Px.put(im, 8, 5, Color(AMBER[2]))
			Px.put(im, 8, 2, Color(AMBER[1]))
		"lingotto":
			# lingotto a forma di seme, con la nervatura
			for y in S:
				for x in S:
					var d := Vector2((x + 0.5 - 8.0) / 6.2, (y + 0.5 - 9.0) / 3.6)
					if d.length() <= 1.0:
						var t := 0.55 - d.x * 0.2 - d.y * 0.45
						Px.put(im, x, y, p[clampi(int(t * p.size()), 0, p.size() - 1)])
			Px.line(im, Vector2(3.5, 9.0), Vector2(12.5, 9.0), 1, p[0])
			Px.put(im, 5, 7, p[p.size() - 1])
		"minerale":
			_clod(im, pal("ardesia"))
			for q in [Vector2(6.0, 7.0), Vector2(10.0, 9.0), Vector2(7.5, 11.0)]:
				Px.disc(im, q.x, q.y, 1.6, p[2])
				Px.put(im, int(q.x) - 1, int(q.y) - 1, p[3])
		"zolla":
			_clod(im, p)
			if material == "humus":
				Px.line(im, Vector2(4, 8), Vector2(9, 11), 1, Color(TileDefs.P_ROOT[2]))
				Px.put(im, 7, 5, Color(LEAF[1]))
				Px.put(im, 8, 4, Color(LEAF[2]))
		"tronco":
			# pezzo di tronco sdraiato: corteccia a righe, sezione chiara con gli anelli, un germoglio
			var ring := Px.pal(["#6a4a3a", "#9a7258", "#c49a74", "#e2c09a"])
			for y in range(5, 13):
				for x in range(2, 13):
					var c := p[4] if y == 5 else (p[3] if (x * 3 + y) % 7 != 0 else p[2])
					if y == 12:
						c = p[1]
					Px.put(im, x, y, c)
			for y in range(5, 13):
				for x in range(10, 16):
					var d := Vector2((x + 0.5 - 12.5) / 2.6, (y + 0.5 - 8.5) / 4.0)
					if d.length() <= 1.0:
						Px.put(im, x, y, ring[3 - clampi(int(d.length() * 3.2), 0, 3)] if d.length() > 0.2 else ring[0])
			Px.put(im, 5, 4, Color(LEAF[1]))
			Px.put(im, 6, 3, Color(LEAF[2]))
			Px.put(im, 4, 3, Color(LEAF[2]))
		"gel":
			for y in S:
				for x in S:
					var d := Vector2((x + 0.5 - 8.0) / 5.5, (y + 0.5 - 10.0) / 4.5)
					if d.length() <= 1.0 and y < 15:
						var c := p[3] if d.y < -0.3 else p[2]
						c.a = 0.85
						Px.put(im, x, y, c)
			Px.put(im, 6, 8, Color.WHITE)
		"fungo":
			Px.line(im, Vector2(8, 14), Vector2(8, 9), 2, Color("#d8c8b0"))
			for y in range(3, 9):
				for x in S:
					var d := Vector2((x + 0.5 - 8.0) / 6.0, (y + 0.5 - 8.5) / 5.0)
					if d.length() <= 1.0:
						Px.put(im, x, y, p[clampi(int((0.6 - d.x * 0.3 - d.y * 0.4) * 3.0), 0, 3)])
			Px.put(im, 6, 5, Color("#ffe8c0"))
			Px.put(im, 10, 6, Color("#ffe8c0"))
		"cristallo":
			for sh in [[Vector2(8.0, 14.0), Vector2(8.0, 2.0), 2.4], [Vector2(6.0, 14.0), Vector2(3.0, 6.0), 1.6], [Vector2(10.0, 14.0), Vector2(13.0, 7.0), 1.6]]:
				var a: Vector2 = sh[0]
				var b: Vector2 = sh[1]
				for k in 21:
					var t := k / 20.0
					var q := a.lerp(b, t)
					Px.stamp(im, q.x, q.y, maxi(int(round(float(sh[2]) * (1.0 - t * 0.7))), 1), p[2] if t < 0.7 else p[3])
		"pozione":
			for y in range(6, 15):
				for x in S:
					var d := Vector2((x + 0.5 - 8.0) / 4.6, (y + 0.5 - 10.5) / 4.2)
					if d.length() <= 1.0:
						Px.put(im, x, y, p[2] if y > 8 else Color(0.8, 0.95, 0.95, 0.55))
			Px.line(im, Vector2(7.5, 3.0), Vector2(7.5, 6.0), 2, Color(0.8, 0.95, 0.95, 0.7))
			Px.stamp(im, 7.5, 2.0, 2, Color(MATERIALS["legno"][3]))
			Px.put(im, 6, 9, Color.WHITE)
			Px.put(im, 10, 12, p[3])
		"elmo":
			for y in range(4, 12):
				for x in range(3, 13):
					var d := Vector2((x + 0.5 - 8.0) / 5.0, (y + 0.5 - 10.0) / 6.0)
					if d.length() <= 1.0 and y < 11:
						Px.put(im, x, y, p[2] if d.x < 0.2 else p[1])
			Px.line(im, Vector2(4.0, 10.5), Vector2(12.0, 10.5), 1, p[3])
			Px.line(im, Vector2(8.0, 4.0), Vector2(10.0, 1.0), 1, Color(LEAF[1]))
			Px.put(im, 11, 1, Color(LEAF[2]))
		"corazza":
			for y in range(3, 14):
				for x in range(3, 13):
					var hw := 5 if y < 6 else (4 if y < 11 else 3)
					if absi(x - 8) < hw or (y < 6 and absi(x - 8) < 5):
						Px.put(im, x, y, p[2] if x < 8 else p[1])
			Px.line(im, Vector2(8.0, 5.0), Vector2(8.0, 12.0), 1, p[3])
			_bead(im, 8, 6)
		"gambali":
			for y in range(3, 15):
				for side in [-1, 1]:
					for dx in 3:
						Px.put(im, 8 + side * (1 + dx) - (1 if side < 0 else 0), y, p[2] if dx == 1 else p[1])
			Px.line(im, Vector2(4.0, 3.5), Vector2(11.0, 3.5), 1, p[3])
		"banco":
			Px.line(im, Vector2(1.0, 6.5), Vector2(14.0, 6.5), 2, p[3])
			for lx in [3.0, 12.0]:
				Px.line(im, Vector2(lx, 7.0), Vector2(lx + (1.0 if lx < 8.0 else -1.0), 14.0), 2, p[1])
			Px.put(im, 5, 5, Color(LEAF[1]))
			Px.put(im, 6, 4, Color(LEAF[2]))
		"fornace":
			for y in range(3, 15):
				for x in range(2, 14):
					var d := Vector2((x + 0.5 - 8.0) / 6.0, (y + 0.5 - 14.0) / 11.0)
					if d.length() <= 1.0:
						Px.put(im, x, y, p[2] if (x + y) % 4 != 0 else p[1])
			Px.disc(im, 8.0, 11.0, 2.4, Color(AMBER[1]))
			Px.put(im, 8, 11, Color(AMBER[2]))
		"incudine":
			Px.line(im, Vector2(2.0, 6.5), Vector2(14.0, 6.5), 2, p[2])
			Px.line(im, Vector2(1.0, 6.0), Vector2(2.0, 7.0), 1, p[2])
			Px.line(im, Vector2(6.0, 8.0), Vector2(10.0, 8.0), 2, p[1])
			Px.line(im, Vector2(4.0, 12.5), Vector2(12.0, 12.5), 2, p[1])
			Px.line(im, Vector2(3.0, 5.5), Vector2(13.0, 5.5), 1, p[3])
		"polvere":
			# mucchietto di polvere di brace con qualche scintilla
			for y in range(8, 15):
				for x in range(2, 14):
					var d := Vector2((x + 0.5 - 8.0) / 6.0, (y + 0.5 - 14.5) / 6.0)
					if d.length() <= 1.0:
						Px.put(im, x, y, p[clampi(int((1.0 - d.length()) * 4.0), 0, 3)])
			for q in [Vector2i(5, 5), Vector2i(9, 3), Vector2i(12, 6), Vector2i(7, 7)]:
				Px.put(im, q.x, q.y, p[3])
		"scaglia":
			# scaglia di guscio: una lama curva con le venature
			for y in S:
				for x in S:
					var d := Vector2((x + 0.5 - 8.0) / 6.5, (y + 0.5 - 9.0) / 5.0)
					var inner := Vector2((x + 0.5 - 8.0) / 5.0, (y + 0.5 - 12.0) / 4.0)
					if d.length() <= 1.0 and inner.length() > 1.0:
						Px.put(im, x, y, p[3] if y < 7 else p[2])
			Px.line(im, Vector2(4.0, 7.0), Vector2(12.0, 7.0), 1, p[p.size() - 1])
			Px.put(im, 8, 5, Color(AMBER[1]))
		"sacca":
			for y in range(4, 15):
				for x in S:
					var d := Vector2((x + 0.5 - 8.0) / 5.0, (y + 0.5 - 10.0) / 5.0)
					if d.length() <= 1.0:
						Px.put(im, x, y, Color("#b890ff") if d.length() < 0.45 else Color(0.42, 0.26, 0.7, 0.95))
			Px.line(im, Vector2(8.0, 4.0), Vector2(8.0, 1.0), 1, p[2])
			Px.put(im, 6, 8, Color.WHITE)
		"seme":
			# seme a mandorla con la sua linea e un germoglio che spunta
			for y in S:
				for x in S:
					var d := Vector2((x + 0.5 - 8.0) / 4.2, (y + 0.5 - 10.0) / 5.2)
					if d.length() <= 1.0:
						Px.put(im, x, y, p[clampi(int((0.6 - d.x * 0.3 - d.y * 0.3) * 4.0), 0, 3)])
			Px.line(im, Vector2(8.0, 6.0), Vector2(8.0, 14.0), 1, p[0])
			Px.line(im, Vector2(8.0, 5.0), Vector2(9.0, 2.0), 1, Color(LEAF[1]))
			Px.put(im, 10, 1, Color(LEAF[2]))
			Px.put(im, 7, 2, Color(LEAF[2]))
		"cesta":
			# cesta intrecciata con il coperchio
			var w: Array[Color] = pal("legno")
			for y in range(5, 15):
				for x in range(2, 14):
					Px.put(im, x, y, w[3] if (x + (y / 2)) % 3 == 0 else w[2])
			Px.line(im, Vector2(1.5, 5.0), Vector2(14.5, 5.0), 2, w[4])
			Px.put(im, 8, 3, Color(LEAF[2]))
		"scrigno":
			# scrigno di pietra dei Seminatori con la runa accesa
			for y in range(4, 15):
				for x in range(2, 14):
					Px.put(im, x, y, p[3] if y < 8 else p[2])
			Px.line(im, Vector2(2.0, 8.0), Vector2(13.0, 8.0), 1, p[0])
			Px.line(im, Vector2(8.0, 9.0), Vector2(8.0, 12.0), 1, Color("#6ff0d8"))
			Px.put(im, 7, 10, Color("#6ff0d8"))
			Px.put(im, 9, 10, Color("#6ff0d8"))
		"stivali":
			var w2: Array[Color] = pal("legno")
			for y in range(4, 13):
				for x in range(4, 9):
					Px.put(im, x, y, w2[3] if x == 4 else w2[2])
			for x in range(4, 13):
				Px.put(im, x, 13, w2[3])
				Px.put(im, x, 14, w2[1])
			Px.line(im, Vector2(4.0, 6.0), Vector2(8.0, 6.0), 1, Color(LEAF[1]))
			Px.put(im, 10, 3, Color(LEAF[2]))
			Px.put(im, 9, 4, Color(LEAF[1]))
		"foglia":
			for y in S:
				for x in S:
					var d := Vector2((x + 0.5 - 8.0) / 6.5, (y + 0.5 - 8.0) / 3.2).rotated(-0.6)
					if d.length() <= 1.0:
						Px.put(im, x, y, p[3] if d.y < 0.0 else p[2])
			Px.line(im, Vector2(3.0, 12.0), Vector2(13.0, 4.0), 1, p[1])
		"amuleto":
			Px.line(im, Vector2(3.0, 2.0), Vector2(8.0, 8.0), 1, Color(MATERIALS["legno"][3]))
			Px.line(im, Vector2(13.0, 2.0), Vector2(8.0, 8.0), 1, Color(MATERIALS["legno"][3]))
			Px.disc(im, 8.0, 10.5, 3.6, p[2])
			Px.disc(im, 7.5, 10.0, 1.6, p[3])
		"anello":
			for k in 24:
				var a2 := k / 24.0 * TAU
				Px.put(im, int(8.0 + cos(a2) * 4.5), int(10.0 + sin(a2) * 3.5), Color(MATERIALS["ambra"][2]))
			Px.disc(im, 8.0, 5.0, 2.4, p[2])
			Px.put(im, 7, 4, Color.WHITE)
		"cuore":
			for y in S:
				for x in S:
					var u := (x + 0.5 - 8.0) / 6.0
					var v := (y + 0.5 - 8.5) / 5.5
					if u * u + pow(-v - sqrt(absf(u)) * 0.8, 2.0) <= 1.0:
						Px.put(im, x, y, p[3] if u < 0.0 else p[2])
			Px.put(im, 5, 6, Color(LEAF[2]))
		"pappo":
			Px.line(im, Vector2(8.0, 14.0), Vector2(8.0, 8.0), 1, Color(MATERIALS["legno"][3]))
			Px.disc(im, 8.0, 14.0, 1.2, Color(MATERIALS["ambra"][1]))
			for k in 9:
				var a3 := PI + k / 8.0 * PI
				Px.line(im, Vector2(8.0, 8.0), Vector2(8.0, 8.0) + Vector2(cos(a3), sin(a3)) * 6.0, 1, Color(0.9, 0.97, 0.95, 0.9))
		"essenza":
			# una goccia di luce che gira su sé stessa, con il suo alone
			Px.disc(im, 8.0, 8.5, 5.5, Color(p[1].r, p[1].g, p[1].b, 0.45))
			Px.disc(im, 8.0, 8.5, 3.8, p[2])
			Px.disc(im, 7.2, 7.6, 2.0, p[p.size() - 1])
			Px.put(im, 6, 6, Color.WHITE)
			for k in 4:
				var a := k * PI / 2.0 + 0.4
				Px.put(im, int(8.0 + cos(a) * 6.5), int(8.5 + sin(a) * 6.5), p[p.size() - 1])
		"lanterna":
			# lanterna di radice intrecciata con un cristallo di Linfa dentro
			var wood: Array[Color] = pal("legno")
			Px.line(im, Vector2(8.0, 1.0), Vector2(8.0, 3.0), 1, wood[3])
			for y in range(3, 15):
				for x in range(3, 13):
					var d := Vector2((x + 0.5 - 8.0) / 5.0, (y + 0.5 - 9.0) / 6.0)
					if d.length() <= 1.0:
						Px.put(im, x, y, wood[2] if (x + y) % 4 == 0 or d.length() > 0.8 else p[2])
			Px.disc(im, 8.0, 9.0, 1.8, p[3])
			Px.put(im, 7, 8, Color.WHITE)
		"goccia":
			for y in range(2, 15):
				for x in S:
					var t := (y - 2.0) / 12.0
					var r := 5.2 * sqrt(clampf(t * 1.25, 0.0, 1.0)) if t < 0.8 else 5.2 * sqrt(maxf(1.0 - (t - 0.8) * 5.0, 0.0) * 0.99 + 0.01)
					if absf(x + 0.5 - 8.0) <= r * (1.0 if t < 0.8 else 1.0):
						Px.put(im, x, y, p[clampi(int((0.7 - (x - 8.0) / 10.0 - t * 0.3) * p.size()), 0, p.size() - 1)])
			Px.put(im, 6, 9, Color.WHITE)
		"piattaforma":
			Px.line(im, Vector2(1.0, 7.5), Vector2(15.0, 7.5), 2, p[3])
			Px.put(im, 4, 9, p[1])
			Px.put(im, 11, 9, p[1])
		_:
			if not IconShapes.draw(shape, im, p):
				Px.disc(im, 8.0, 8.0, 5.0, Color("#ff2080"))
	Px.outline(im, OUT)
	return im


## Manico di legno di radice, con una fasciatura di foglia a metà.
static func _handle(im: Image, a: Vector2, b: Vector2) -> void:
	var w := Px.pal(MATERIALS["legno"])
	Px.line(im, a, b, 2, w[3])
	Px.line(im, a + Vector2(0.5, 0.5), b + Vector2(0.5, 0.5), 1, w[2])
	var m := a.lerp(b, 0.45)
	Px.put(im, int(m.x), int(m.y), Color(LEAF[1]))
	Px.put(im, int(m.x) + 1, int(m.y) - 1, Color(LEAF[2]))


static func _bead(im: Image, x: int, y: int) -> void:
	Px.put(im, x, y, Color(AMBER[1]))
	Px.put(im, x - 1, y, Color(AMBER[0]))


## Zolla: un blocco di materiale dalla forma morbida.
static func _clod(im: Image, p: Array[Color]) -> void:
	for y in range(3, 15):
		for x in range(2, 14):
			var d := Vector2((x + 0.5 - 8.0) / 6.0, (y + 0.5 - 9.0) / 5.5)
			var wob := 0.08 * sin(x * 1.7 + y * 0.9)
			if d.length() <= 1.0 + wob:
				var t := 0.6 - d.x * 0.25 - d.y * 0.4
				Px.put(im, x, y, p[clampi(int(t * p.size()), 0, p.size() - 1)])
