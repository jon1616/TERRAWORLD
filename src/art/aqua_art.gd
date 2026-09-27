class_name AquaArt
extends RefCounted
## Le creature d'acqua (voce 73): il Pesce lume (un pesce tondo con una lanterna turchese sulla fronte) e l'Anguilla di
## Linfa (lunga, a onde, con i denti chiari). Due fotogrammi: la coda che batte / il corpo che ondeggia.

const OUT := Color(0.02, 0.03, 0.05)


static func pesce(f: int) -> Array:
	var im := Px.img(16, 12)
	var gm := Px.img(16, 12)
	var body := Px.pal(["#1a3a5a", "#2a5a8a", "#4a8ac0", "#8ac8f0"])
	for y in 12:
		for x in 12:
			var d := Vector2((x + 0.5 - 7.0) / 5.5, (y + 0.5 - 6.0) / 4.0)
			if d.length() <= 1.0:
				Px.put(im, x, y, body[clampi(int((0.8 - d.y * 0.4) * 3.5), 0, 3)])
	var tail := 1 if f == 0 else -1
	for k in 4:
		Px.put(im, 12 + k / 2, 6 + tail * (k % 2), body[1])
		Px.put(im, 13 + k / 3, 5 + tail * k / 2, body[2])
	Px.put(im, 3, 5, Color("#0a0a14"))
	var lamp := Color("#6ff0d8")
	Px.line(im, Vector2(4, 2), Vector2(2, 0), 1, body[0])
	Px.put(im, 2, 0, lamp)
	Px.put(gm, 2, 0, lamp)
	Px.outline(im, OUT)
	return [im, gm]


static func anguilla(f: int) -> Array:
	var im := Px.img(28, 12)
	var gm := Px.img(28, 12)
	var body := Px.pal(["#0c3a34", "#16645a", "#2a9a86", "#6ff0d0"])
	for x in 26:
		var yy := 6.0 + sin((x + f * 3) * 0.55) * 2.2
		var th := 2.6 if x < 20 else 2.6 - (x - 20) * 0.35
		for y in range(int(yy - th), int(yy + th) + 1):
			Px.put(im, x + 1, y, body[1] if y > yy else body[2])
		if x % 5 == 2:
			Px.put(im, x + 1, int(yy), body[3])
			Px.put(gm, x + 1, int(yy), body[3])
	Px.put(im, 2, int(6.0 + sin(f * 3 * 0.55) * 2.2) - 1, Color("#ffd24a"))
	Px.put(im, 1, 7, Color("#e8fff8"))
	Px.outline(im, OUT)
	return [im, gm]
