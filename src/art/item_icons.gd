class_name ItemIcons
extends RefCounted
## Icone degli oggetti costruite da forme e tavolozze: la stessa funzione fa la spada di rame, di ferro, d'oro…

const M_COPPER := ["#6e3818", "#a0542a", "#cf7a3e", "#f0a868"]
const M_IRON := ["#4a4b55", "#7d7e8a", "#b0b1bc", "#e4e5ee"]
const M_GOLD := ["#7a5a0c", "#b68a18", "#e6bd34", "#fff08a"]
const M_CRYSTAL := ["#4a2a90", "#7a52e0", "#a888ff", "#e8dcff"]
const WOOD := ["#3e2614", "#5e3a1e", "#7e5230", "#a0703f"]


static func icon_sword(metal: Array) -> Image:
	var p := Px.pal(metal)
	var w := Px.pal(WOOD)
	var im := Px.img(16, 16)
	Px.line(im, Vector2(5.0, 10.0), Vector2(13.0, 2.0), 2, p[1])
	Px.line(im, Vector2(5.0, 9.5), Vector2(12.5, 2.0), 1, p[3])
	Px.put(im, 14, 1, p[3])
	Px.line(im, Vector2(2.5, 8.5), Vector2(6.5, 12.5), 2, p[0])
	Px.put(im, 4, 10, p[2])
	Px.line(im, Vector2(4.0, 11.5), Vector2(2.0, 13.5), 2, w[1])
	Px.stamp(im, 1.5, 14.0, 2, p[2])
	Px.outline(im, Px.OUTLINE)
	return im


static func icon_pickaxe(metal: Array) -> Image:
	var p := Px.pal(metal)
	var w := Px.pal(WOOD)
	var im := Px.img(16, 16)
	Px.line(im, Vector2(2.0, 14.0), Vector2(10.5, 5.5), 2, w[2])
	Px.line(im, Vector2(2.5, 14.5), Vector2(10.5, 6.5), 1, w[1])
	Px.curve(im, Vector2(5.0, 2.5), Vector2(13.0, 2.0), Vector2(13.5, 10.5), 2, p[1])
	Px.curve(im, Vector2(5.0, 2.0), Vector2(12.5, 1.5), Vector2(13.0, 10.0), 1, p[2])
	Px.put(im, 4, 2, p[3])
	Px.put(im, 13, 11, p[3])
	Px.outline(im, Px.OUTLINE)
	return im


static func icon_bow() -> Image:
	var w := Px.pal(WOOD)
	var im := Px.img(16, 16)
	Px.line(im, Vector2(3.5, 2.5), Vector2(13.5, 12.5), 1, Color("#d8d0c0"))
	Px.curve(im, Vector2(3.0, 2.0), Vector2(15.0, 0.5), Vector2(14.0, 13.0), 2, w[2])
	Px.curve(im, Vector2(3.0, 1.5), Vector2(14.5, 0.0), Vector2(14.5, 12.5), 1, w[3])
	Px.stamp(im, 11.0, 5.0, 2, Color("#b83a2a"))
	Px.outline(im, Px.OUTLINE)
	return im


static func icon_torch() -> Image:
	var w := Px.pal(WOOD)
	var im := Px.img(16, 16)
	Px.line(im, Vector2(7.0, 14.0), Vector2(8.0, 7.0), 2, w[2])
	Px.disc(im, 7.8, 5.2, 2.6, Color("#ff8a2a"))
	Px.disc(im, 7.8, 5.6, 1.5, Color("#ffd24a"))
	Px.put(im, 7, 2, Color("#ff8a2a"))
	Px.put(im, 8, 5, Color("#fff6d0"))
	Px.outline(im, Px.OUTLINE)
	return im


static func icon_bar(metal: Array) -> Image:
	var p := Px.pal(metal)
	var im := Px.img(16, 16)
	for y in range(6, 12):
		for x in range(2, 14):
			var c := p[2]
			if y <= 7:
				if x < 4 + (7 - y) or x > 11 - (7 - y) + 1:
					continue
				c = p[3]
			elif y == 11:
				c = p[0]
			elif x == 2:
				c = p[1]
			Px.put(im, x, y, c)
	Px.put(im, 5, 9, p[3])
	Px.put(im, 6, 9, p[3])
	Px.outline(im, Px.OUTLINE)
	return im


static func icon_potion() -> Image:
	var im := Px.img(16, 16)
	var glass := Color(0.8, 0.9, 0.95, 0.9)
	Px.disc(im, 8.0, 10.0, 4.6, glass)
	for y in range(9, 15):
		for x in 16:
			if Px.alpha(im, x, y) > 0.5:
				Px.put(im, x, y, Color("#d8304a") if x > 5 else Color("#ff5a6e"))
	Px.line(im, Vector2(7.5, 3.0), Vector2(7.5, 5.5), 2, glass)
	Px.stamp(im, 7.5, 2.0, 2, Color("#8a5a30"))
	Px.put(im, 6, 8, Color.WHITE)
	Px.put(im, 5, 9, Color.WHITE)
	Px.outline(im, Px.OUTLINE)
	return im
