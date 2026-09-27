class_name FarmArt
extends RefCounted
## I disegni dei pezzi delle farm (voce 89), nello stile basso dei banchi (`CompactArt`): l'esca è un vasetto di radice
## con un bagliore caldo, la tramoggia un imbuto di metallo su una cesta, la Radice-ancora un paletto di radice avvolto
## che affonda nel terreno, il nastro una fascia di radici intrecciate con le frecce del verso.


static func draw(id: String, im: Image, gm: Image, w: int, h: int) -> void:
	var wood := Px.pal(TileDefs.P_ROOT)
	match id:
		"esca", "esca_legnoferro", "esca_ambra":
			var met := ItemIcons.pal(String(FarmData.BAITS[id]["mat"]))
			for y in range(h - 8, h):
				var half := 5 if y > h - 7 else 4
				for x in range(w / 2 - half, w / 2 + half):
					Px.put(im, x, y, met[2] if (x + y) % 4 else met[3])
			for x in range(w / 2 - 3, w / 2 + 3):
				Px.put(im, x, h - 9, wood[1])
			var glow := Color("#ffb070")
			for q in [Vector2i(w / 2 - 1, h - 10), Vector2i(w / 2, h - 10), Vector2i(w / 2, h - 11), Vector2i(w / 2 - 1, h - 11),
					Vector2i(w / 2, h - 12)]:
				Px.put(im, q.x, q.y, glow)
				Px.put(gm, q.x, q.y, glow)
		"tramoggia", "tramoggia_ambra":
			var met2 := ItemIcons.pal("radicite" if id == "tramoggia" else "ambra")
			for y in range(h - 6, h):
				for x in range(2, w - 2):
					Px.put(im, x, y, wood[2] if (x + y) % 3 else wood[3])
			for k in 6:
				var y2 := h - 7 - k
				for x in range(maxi(1, 5 - k), mini(w - 1, w - 5 + k)):
					Px.put(im, x, y2, met2[3] if x == maxi(1, 5 - k) or x == mini(w - 1, w - 5 + k) - 1 else met2[1])
		"radice_ancora":
			for y in range(2, h):
				Px.put(im, w / 2 - 1, y, wood[2])
				Px.put(im, w / 2, y, wood[3])
				if y % 4 == 0:
					Px.put(im, w / 2 + 1, y, wood[1])
					Px.put(im, w / 2 - 2, y + 1, wood[1])
			var lf := Color("#8ef0d8")
			for q in [Vector2i(w / 2 - 1, 1), Vector2i(w / 2, 1), Vector2i(w / 2 - 2, 2), Vector2i(w / 2 + 1, 2), Vector2i(w / 2, 0)]:
				Px.put(im, q.x, q.y, lf)
				Px.put(gm, q.x, q.y, lf)
		_:
			var dir := 1 if id == "nastro_dx" else -1
			for y in range(h - 4, h):
				for x in w:
					Px.put(im, x, y, wood[2] if (x + y) % 4 else wood[1])
			for k in 3:
				var cx := 3 + k * 5
				Px.put(im, cx, h - 3, Color("#ffd24a"))
				Px.put(im, cx - dir, h - 4, Color("#ffd24a"))
				Px.put(im, cx - dir, h - 2, Color("#ffd24a"))
