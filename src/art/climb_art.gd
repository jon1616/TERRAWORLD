class_name ClimbArt
extends RefCounted
## Roadmap 52, voce 415: i disegni delle corde (decorazioni 98 corda di fibra, 99 liana, 100 catena), una cella alta 16
## che si ripete in colonna senza cuciture: il filo passa al centro dall'alto in basso.


static func draw(id: int, im: Image, gm: Image) -> bool:
	match id:
		98:
			# corda di fibra: due trefoli intrecciati
			var a := Color("#8a6a48")
			var b := Color("#5a4230")
			for y in 16:
				var off := 1 if (y / 2) % 2 == 0 else 0
				im.set_pixel(7 + off, y, a)
				im.set_pixel(8 - off, y, b)
				if y % 4 == 0:
					im.set_pixel(7, y, Color("#b0906a"))
			return true
		99:
			# liana: un fusto verde che ondeggia appena, con una foglia ogni tanto e una gemma di luce
			var stem := Color("#1f6a50")
			var dark := Color("#134a38")
			for y in 16:
				var x := 7 + int(round(sin(y * TAU / 16.0)))
				im.set_pixel(x, y, stem)
				im.set_pixel(x + 1, y, dark)
			for leaf in [[3, -1], [10, 1]]:
				var ly: int = leaf[0]
				var dir: int = leaf[1]
				var lx := 7 + int(round(sin(ly * TAU / 16.0))) + (2 if dir > 0 else -1)
				for k in 3:
					im.set_pixel(clampi(lx + k * dir, 0, 15), ly + (1 if k == 2 else 0), Color("#3aa08a"))
			im.set_pixel(8, 13, Color("#8ef0d8"))
			gm.set_pixel(8, 13, Color("#8ef0d8"))
			return true
		100:
			# catena di legnoferro: anelli alternati, uno di faccia e uno di taglio
			var hi := Color("#dce6f2")
			var mid := Color("#a2b0c2")
			var lo := Color("#6a7688")
			for y in 16:
				if (y / 4) % 2 == 0:
					var edge := y % 4 == 0 or y % 4 == 3
					if edge:
						for x in range(6, 10):
							im.set_pixel(x, y, mid)
					else:
						im.set_pixel(6, y, hi)
						im.set_pixel(9, y, lo)
				else:
					im.set_pixel(7, y, mid)
					im.set_pixel(8, y, lo)
			return true
	return false
