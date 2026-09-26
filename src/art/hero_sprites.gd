class_name HeroSprites
extends RefCounted
## Gli sprite del Germogliato fatti con Nano Banana e ridotti a 36 pixel dagli script di `tools/` (26 set 2026):
## `arte/germogliato/<animazione>_<n>.png`. Per ora corsa (8 pose) e fermo (4, il respiro); le pose che mancano
## (salto, colpo, mira, torcia in mano) le disegna ancora `CharacterArt` finché non arrivano le loro tavole.
## Da ogni fotogramma si ricavano da soli:
##   eye     il pixel dell'occhio d'oro (per il bagliore al buio; niente quando l'occhio è chiuso)
##   anchor  il centro del corpo in x (la media della sagoma di tutta l'animazione), che va sul centro del
##           Germogliato: così un'animazione più larga o più stretta non sposta il personaggio

const DIR := "res://arte/germogliato/"
const ANIMS := {"corsa": 8, "fermo": 4}
const GOLD := Color("#f0d048")          # l'occhio (vedi `ACCENTI` in tools/pixela.py)

## Durata di ogni posa del respiro (in quarti di secondo): il fotogramma neutro dura di più, il battito di ciglia poco.
const BREATH := [3, 2, 2, 1]

static var _data := {}
static var _loaded := false


## {animazione: {"tex": [Texture2D], "eye": [Vector2 o Vector2.INF], "anchor": float, "size": Vector2i}}; vuoto se
## mancano i file (allora il Germogliato resta quello disegnato dal codice).
static func data() -> Dictionary:
	if _loaded:
		return _data
	_loaded = true
	for anim in ANIMS:
		var texs: Array[Texture2D] = []
		var eyes: Array[Vector2] = []
		var sum := 0.0
		var cnt := 0
		for i in int(ANIMS[anim]):
			var path := "%s%s_%d.png" % [DIR, anim, i]
			if not ResourceLoader.exists(path):
				break
			var tex: Texture2D = load(path)
			var img := tex.get_image()
			if img.is_compressed():
				img.decompress()
			var eye := Vector2.INF
			for y in img.get_height():
				for x in img.get_width():
					var c := img.get_pixel(x, y)
					if c.a < 0.5:
						continue
					sum += x
					cnt += 1
					if eye == Vector2.INF and absf(c.r - GOLD.r) + absf(c.g - GOLD.g) + absf(c.b - GOLD.b) < 0.12:
						eye = Vector2(x, y)
			texs.append(tex)
			eyes.append(eye)
		if texs.size() == int(ANIMS[anim]):
			_data[anim] = {"tex": texs, "eye": eyes, "anchor": sum / maxf(cnt, 1.0) + 0.5,
				"size": Vector2i(texs[0].get_width(), texs[0].get_height())}
	return _data


## Quale posa del respiro a un certo tempo (secondi).
static func breath_frame(t: float) -> int:
	var total := 0
	for d in BREATH:
		total += d
	var q := int(t * 4.0) % total
	for i in BREATH.size():
		q -= BREATH[i]
		if q < 0:
			return i
	return 0
