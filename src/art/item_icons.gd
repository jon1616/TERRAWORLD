class_name ItemIcons
extends RefCounted
## Icone degli oggetti (16×16) nello stile «Radici e Linfa»: manici di legno di radice fasciati di foglia, lame a forma
## di foglia, lingotti a forma di seme, perle d'ambra. Ogni forma è una funzione; il materiale sceglie la tavolozza,
## così la stessa funzione fa la spada di rame, di ferro, d'oro… `make(forma, materiale)`, oppure `of(id)` da `ItemsData`.

const S := 16
const OUT := Color("#050c10")
const MATERIALS := {
	"rame": ["#5a2a14", "#9a4a22", "#d4783a", "#ffb070"],
	"ferro": ["#3a4250", "#6a7688", "#a2b0c2", "#dce6f2"],
	"oro": ["#6a4a0c", "#b0861c", "#eec04a", "#fff2a8"],
	"cristallo": ["#0a2a36", "#1f8a9a", "#5cc8cc", "#b8f4f0"],
	"legno": ["#1c1016", "#2e1c26", "#46303a", "#644652", "#86606e"],
	"humus": ["#34202a", "#4a2e3c", "#62404e", "#7c5262", "#9a6a7a"],
	"ardesia": ["#2a3650", "#3a4966", "#4c5e80", "#62779c", "#8298bc"],
	"muschio": ["#0f3a3a", "#16574f", "#23776a", "#3aa08a", "#72d4b0"],
	"linfa": ["#5a1024", "#a02040", "#e04a60", "#ff9aa8"],
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
		"piattaforma":
			Px.line(im, Vector2(1.0, 7.5), Vector2(15.0, 7.5), 2, p[3])
			Px.put(im, 4, 9, p[1])
			Px.put(im, 11, 9, p[1])
		_:
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
