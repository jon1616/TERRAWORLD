class_name NeroArt
extends RefCounted
## L'Avvizzitore (voce 72): il Seme Nero cresciuto, un seme enorme e spaccato da cui escono radici nere; nelle crepe
## brilla un viola malato. Guarito: un seme verde scuro con le crepe turchesi e piccole foglie. Due fotogrammi (le radici
## ondeggiano). Stesso stile dei Guardiani di `BossArt`.

const OUT := Color(0.03, 0.02, 0.05)


static func avvizzitore(f: int, healed: bool) -> Array:
	var sz := 74
	var im := Px.img(sz, sz)
	var gm := Px.img(sz, sz)
	var shell := Px.pal(["#0c0a12", "#1a1424", "#2a2038", "#3c2e52", "#54426e"]) if not healed \
		else Px.pal(["#0c2a24", "#16453a", "#23644f", "#3a8a6a", "#72c4a0"])
	var crack := Color("#c070ff") if not healed else Color("#6ff0d8")
	var c := Vector2(37.0, 33.0)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7272
	# le radici sotto e ai lati
	for k in 8:
		var a := PI * (0.15 + k * 0.1)
		var sway := 3.0 if (k + f) % 2 == 0 else -3.0
		var from := c + Vector2(cos(a) * 18.0, sin(a) * 21.0)
		var to := c + Vector2(cos(a) * 35.0 + sway, sin(a) * 38.0)
		Px.curve(im, from, (from + to) / 2.0 + Vector2(sway, 0), to, 2, shell[1])
		Px.curve(im, from, (from + to) / 2.0 + Vector2(sway, 0), to, 1, shell[2])
	# il seme: una goccia rovesciata, appuntita in alto
	for y in sz:
		for x in sz:
			var dy := (y + 0.5 - c.y) / 27.0
			var hw := 22.0 * (1.0 - maxf(-dy - 0.35, 0.0) * 1.3)
			var d := Vector2((x + 0.5 - c.x) / maxf(hw, 1.0), dy)
			if d.length() <= 1.0:
				var t := 0.7 - d.x * 0.35 - dy * 0.3
				Px.put(im, x, y, shell[clampi(int(t * 5.0), 0, 4)])
	# le crepe che brillano
	for k in 6:
		var p := c + Vector2(rng.randf_range(-12, 12), rng.randf_range(-18, 15))
		for s in 7:
			var q := p + Vector2(rng.randf_range(-1.6, 1.6), 1.2) * s
			var dd := Vector2((q.x - c.x) / 21.0, (q.y - c.y) / 26.0)
			if dd.length() < 0.95:
				Px.put(im, int(q.x), int(q.y), crack)
				Px.put(gm, int(q.x), int(q.y), crack)
	# il cuore al centro
	for y in range(int(c.y) - 6, int(c.y) + 7):
		for x in range(int(c.x) - 6, int(c.x) + 7):
			if Vector2(x + 0.5 - c.x, y + 0.5 - c.y).length() <= 5.6:
				var col := crack.lightened(0.35) if (x + y + f) % 3 else crack
				Px.put(im, x, y, col)
				Px.put(gm, x, y, col)
	if healed:
		var leaf := Color("#8ef0a0")
		for q in [Vector2(27, 9), Vector2(45, 11), Vector2(36, 6)]:
			Px.disc(im, q.x, q.y, 2.2, leaf)
	Px.outline(im, OUT)
	return [im, gm]
