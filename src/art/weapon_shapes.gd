class_name WeaponShapes
extends RefCounted
## Le icone delle forme d'arma e d'attrezzo della voce 50 (pugnale, spadone, lancia, mazza del martello, falce, frusta, balestra,
## trivella, verga), nello stile di `ItemIcons`: manici di radice fasciati di foglia, lame a foglia, perle d'ambra; la
## tavolozza `p` è quella del materiale. `draw` restituisce false se la forma non è sua.

const S := 16


static func draw(shape: String, im: Image, p: Array[Color]) -> bool:
	var hi := p[p.size() - 1]
	match shape:
		"pugnale":
			_leaf(im, p, Vector2(7.0, 9.0), Vector2(14.0, 2.0), 1.6)
			ItemIcons._handle(im, Vector2(3.0, 13.5), Vector2(6.5, 9.5))
			Px.line(im, Vector2(5.0, 8.0), Vector2(8.5, 11.5), 1, p[3])      # la guardia
			ItemIcons._bead(im, 4, 12)
		"spadone":
			_leaf(im, p, Vector2(4.5, 11.5), Vector2(15.0, 1.0), 3.0)
			Px.line(im, Vector2(2.0, 9.5), Vector2(6.5, 14.0), 1, p[3])      # la guardia larga
			ItemIcons._handle(im, Vector2(0.5, 15.5), Vector2(3.5, 12.5))
			ItemIcons._bead(im, 3, 13)
		"lancia":
			ItemIcons._handle(im, Vector2(1.0, 15.0), Vector2(11.0, 5.0))
			_leaf(im, p, Vector2(10.0, 6.0), Vector2(15.0, 1.0), 1.8)
			Px.put(im, 9, 5, Color(ItemIcons.LEAF[2]))
			Px.put(im, 11, 7, Color(ItemIcons.LEAF[1]))
		"mazza":
			ItemIcons._handle(im, Vector2(2.5, 14.5), Vector2(9.5, 7.5))
			for y in range(1, 9):
				for x in range(8, 16):
					# la testa: un blocco storto di metallo, più chiaro in alto
					var u := Vector2(x + 0.5 - 11.5, y + 0.5 - 4.5).rotated(-0.78)
					if absf(u.x) <= 4.2 and absf(u.y) <= 2.4:
						Px.put(im, x, y, p[2] if u.y < -0.8 else p[1])
			Px.put(im, 12, 2, hi)
			ItemIcons._bead(im, 9, 7)
		"falcione":
			ItemIcons._handle(im, Vector2(4.0, 15.0), Vector2(6.5, 3.0))
			Px.curve(im, Vector2(6.0, 3.0), Vector2(13.0, 0.5), Vector2(14.5, 8.0), 2, p[1])
			Px.curve(im, Vector2(6.5, 2.5), Vector2(12.5, 0.0), Vector2(14.0, 7.5), 1, p[3])
			Px.put(im, 14, 8, hi)
		"frusta":
			ItemIcons._handle(im, Vector2(2.0, 14.5), Vector2(5.5, 10.5))
			Px.curve(im, Vector2(5.5, 10.0), Vector2(15.0, 12.0), Vector2(11.0, 4.0), 1, p[2])
			Px.curve(im, Vector2(11.0, 4.0), Vector2(8.0, 0.5), Vector2(4.0, 3.0), 1, p[1])
			Px.put(im, 4, 3, hi)
		"balestra":
			var w := ItemIcons.pal("legno")
			Px.line(im, Vector2(2.0, 12.0), Vector2(12.0, 5.0), 2, w[3])          # il fusto
			Px.curve(im, Vector2(6.0, 1.5), Vector2(14.0, 4.0), Vector2(15.0, 12.0), 2, p[1])   # l'arco di metallo
			Px.curve(im, Vector2(6.5, 1.0), Vector2(13.5, 3.5), Vector2(14.5, 11.5), 1, p[3])
			Px.line(im, Vector2(6.5, 2.0), Vector2(14.0, 11.5), 1, Color("#b8f4f0"))
			ItemIcons._bead(im, 4, 11)
		"trivella":
			ItemIcons._handle(im, Vector2(2.0, 14.5), Vector2(7.0, 9.5))
			for k in 8:
				# la punta a spirale: dischi sempre più stretti verso l'alto a destra
				var q := Vector2(7.5, 8.5).lerp(Vector2(14.5, 1.5), k / 7.0)
				Px.disc(im, q.x, q.y, 2.8 - k * 0.3, p[1] if k % 2 == 0 else p[2])
			Px.put(im, 15, 1, hi)
		"verga":
			Px.line(im, Vector2(2.0, 15.0), Vector2(11.5, 5.5), 1, p[1])
			Px.line(im, Vector2(2.5, 14.5), Vector2(11.0, 6.0), 1, p[2])
			Px.put(im, 6, 11, Color(ItemIcons.LEAF[1]))
			Px.put(im, 7, 10, Color(ItemIcons.LEAF[2]))
			var c := ItemIcons.pal("cristallo")
			Px.disc(im, 12.5, 3.5, 2.6, c[1])
			Px.disc(im, 12.0, 3.0, 1.6, c[2])
			Px.put(im, 12, 2, c[3])
		"uovo":
			# voce 58: un uovo della tavolozza del materiale, con le macchie
			for y in S:
				for x in S:
					var d := Vector2((x + 0.5 - 8.0) / 5.0, (y + 0.5 - 9.0) / 6.2)
					if d.length() <= 1.0:
						Px.put(im, x, y, p[2] if d.x + d.y < 0.2 else p[1])
			Px.put(im, 6, 5, hi)
			Px.put(im, 9, 9, p[0])
			Px.put(im, 7, 12, p[0])
		_:
			return false
	return true


## Una lama a foglia da a (manico) a b (punta), larga al più `wide`, con la nervatura.
static func _leaf(im: Image, p: Array[Color], a: Vector2, b: Vector2, wide: float) -> void:
	for k in 31:
		var t := k / 30.0
		var q := a.lerp(b, t)
		var w := 1.0 + wide * sin(t * PI) * (1.0 - t * 0.35)
		Px.stamp(im, q.x, q.y, maxi(int(round(w)), 1), p[1] if t < 0.9 else p[2])
	Px.line(im, a, b, 1, p[2])
	Px.line(im, a + Vector2(-0.5, -1.0), b + Vector2(-1.0, 0.0), 1, p[3])
