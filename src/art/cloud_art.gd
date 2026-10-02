class_name CloudArt
extends RefCounted
## Roadmap 34, voce 330: le immagini delle nuvole (puro codice). Ogni nuvola è un gruppo di sbuffi tondi sopra una base
## quasi piatta, a tre toni. L'immagine non porta colori ma tre misure che legge lo shader di `SkyClouds`:
##   R  il tono (1 = la cima illuminata, 0,4 = la pancia in ombra)
##   G  il turno della nuvola (0-1): con il cielo coperto per «c» si vedono le nuvole con il turno sotto «c»
##   A  dentro o fuori
## Le immagini si ripetono senza cuciture in orizzontale.


## Un piano di nuvole largo `w`, alto `h`; `size` le ingrandisce (il piano vicino ha nuvole più grandi).
static func layer(w: int, h: int, sd: int, size: float) -> Image:
	var im := Image.create(w, h, false, Image.FORMAT_RGBA8)
	var rng := RandomNumberGenerator.new()
	rng.seed = sd
	# due file: le nuvole alte e quelle basse, con i turni sfasati (col sereno se ne vede qualcuna in tutte e due)
	for row in 2:
		_row(im, rng, size, h * (0.3 if row == 0 else 0.72), h * (0.12 if row == 0 else 0.14), 0.31 * row)
	return im


static func _row(im: Image, rng: RandomNumberGenerator, size: float, y: float, dy: float, phase: float) -> void:
	var w := im.get_width()
	var x0 := rng.randf_range(0.0, 120.0)
	var x := x0
	var n := 0
	while true:
		var cw := rng.randf_range(50.0, 150.0) * size
		if x + cw * 1.4 > w + x0 - 4.0:        # l'ultima non deve ripetersi sopra la prima
			break
		var cy := y + rng.randf_range(-dy, dy)
		# i turni si alternano fra bassi e alti, così anche un cielo sereno ha nuvole sparse e non tutte da una parte
		var rank := fposmod(float(n) * 0.618 + phase + rng.randf_range(0.0, 0.15), 1.0)
		# una nuvola occupa da -0,7 a +0,7 della sua larghezza: nello stesso piano non se ne toccano due, altrimenti una
		# nascosta (turno alto) «morderebbe» quella accanto
		_cloud(im, x + cw * 0.7, cy, cw, rng, rank)
		x += cw * 1.4 + rng.randf_range(4.0, 60.0) * size
		n += 1


static func _cloud(im: Image, cx: float, cy: float, cw: float, rng: RandomNumberGenerator, rank: float) -> void:
	var puffs := []
	var k := maxi(3, int(cw / 18.0))
	for i in k:
		var t := (float(i) + 0.5) / float(k)
		var mid := 1.0 - absf(t - 0.5) * 2.0                     # gli sbuffi del centro sono i più grandi
		var r := cw / float(k) * rng.randf_range(0.7, 1.0) + cw * 0.12 * mid
		puffs.append(Vector3(cx - cw * 0.5 + t * cw, cy - r * rng.randf_range(0.3, 0.6), r))
	var base := cy + rng.randf_range(2.0, 5.0)
	var w := im.get_width()
	var h := im.get_height()
	for xi in range(int(cx - cw * 0.7), int(cx + cw * 0.7) + 1):
		var top := 1e9
		var bot := -1e9
		for p: Vector3 in puffs:
			var dx := float(xi) - p.x
			if absf(dx) >= p.z:
				continue
			var s := sqrt(p.z * p.z - dx * dx)
			top = minf(top, p.y - s)
			bot = maxf(bot, minf(p.y + s, base))
		if top > bot:
			continue
		var px := posmod(xi, w)
		for yi in range(maxi(int(top), 0), mini(int(bot) + 1, h)):
			var f := (float(yi) - top) / maxf(bot - top, 1.0)
			# la luce dall'alto: un orlo chiaro di 2-3 pixel, poi il corpo, poi la pancia in ombra
			var tone := 0.72
			if float(yi) - top < 2.5 + rng.randf() * 0.8:
				tone = 1.0
			elif f > 0.7:
				tone = 0.42
			if im.get_pixel(px, yi).a == 0.0:             # una nuvola dell'altra fila già lì resta intera
				im.set_pixel(px, yi, Color(tone, rank, 0.0, 1.0))
