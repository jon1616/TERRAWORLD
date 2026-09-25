class_name NpcArt
extends RefCounted
## Gli abitanti (voce 36), disegnati dal codice: figure alte come il Germogliato (22×32), con un mantello o un grembiule
## dei loro colori e un segno del mestiere. Due fotogrammi: fermi e a metà passo. `frames(id)` -> [Texture2D, …].

const OUT := Color("#050c10")

static var _cache := {}


static func frames(id: String) -> Array:
	if _cache.has(id):
		return _cache[id]
	var out := []
	for f in 2:
		out.append(ImageTexture.create_from_image(_draw(id, f)))
	_cache[id] = out
	return out


static func _draw(id: String, f: int) -> Image:
	var lk: Dictionary = NpcData.NPCS[id]["look"]
	var cloak := Color(lk["cloak"])
	var trim := Color(lk["trim"])
	var skin := Color(lk["skin"])
	var extra := Color(lk["extra"])
	var im := Px.img(22, 32)
	# gambe e stivali
	var st := 1 if f == 1 else 0
	Px.line(im, Vector2(9, 22), Vector2(9 - st, 30), 2, Color("#3a3048"))
	Px.line(im, Vector2(13, 22), Vector2(13 + st, 30), 2, Color("#282034"))
	Px.line(im, Vector2(8 - st, 30), Vector2(10 - st, 30), 1, Color("#4a2e24"))
	Px.line(im, Vector2(12 + st, 30), Vector2(14 + st, 30), 1, Color("#4a2e24"))
	# il corpo: mantello a campana
	for y in range(10, 24):
		var hw := 3.5 + (y - 10) * 0.3
		for x in 22:
			var dx := x + 0.5 - 11.0
			if absf(dx) <= hw:
				Px.put(im, x, y, Px.sh(cloak, 1.15) if dx < 0.0 else cloak)
	for x in range(7, 16):
		Px.put(im, x, 17, trim)
	# testa
	Px.disc(im, 11.5, 6.5, 4.0, skin)
	Px.put(im, 13, 6, Color("#2a1a10"))
	match id:
		"viandante":
			# cappuccio e bastone da viaggio
			for y in range(1, 8):
				for x in 22:
					var d := Vector2((x + 0.5 - 10.5) / 5.5, (y + 0.5 - 6.0) / 5.5)
					if d.length() <= 1.0 and x < 13:
						Px.put(im, x, y, cloak)
			Px.line(im, Vector2(17, 4), Vector2(17, 31), 1, Color("#644652"))
			Px.put(im, 17, 3, trim)
			Px.disc(im, 5.0, 13.0, 3.0, extra)          # la bisaccia sulla schiena
		"erborista":
			# cappello a foglia larga e un'ampolla
			for x in range(4, 20):
				Px.put(im, x, 3, cloak)
				Px.put(im, x, 2, trim if x % 3 == 0 else cloak)
			Px.disc(im, 12.0, 1.5, 3.0, cloak)
			Px.disc(im, 17.0, 18.0, 2.0, extra)
			Px.put(im, 17, 15, Color("#dcffff"))
		"forgiatore":
			# barba di muschio e martello
			for y in range(8, 12):
				for x in range(9, 15):
					Px.put(im, x, y, Color("#3aa08a") if (x + y) % 2 == 0 else Color("#23776a"))
			Px.line(im, Vector2(17, 12), Vector2(19, 26), 1, Color("#644652"))
			for y in range(9, 13):
				for x in range(16, 21):
					Px.put(im, x, y, extra)
	Px.outline(im, OUT)
	return im
