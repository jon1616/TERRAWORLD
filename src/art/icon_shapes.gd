class_name IconShapes
extends RefCounted
## Le forme d'icona nate dalla Roadmap 3 (voce 21 in poi), separate da `ItemIcons` perché quel file non cresca oltre
## le 400 righe. Stesso stile: legno di radice, foglie, perle d'ambra; il materiale sceglie la tavolozza `p`.
## `draw` restituisce false se la forma non è sua (allora `ItemIcons` disegna il segno d'errore).


static func draw(shape: String, im: Image, p: Array[Color]) -> bool:
	match shape:
		"bastone":
			# bastone di radice nodoso, con in cima una gemma del materiale stretta da tre radichette
			var w := ItemIcons.pal("legno")
			Px.line(im, Vector2(2.5, 14.5), Vector2(10.5, 5.5), 2, w[3])
			Px.line(im, Vector2(3.0, 14.5), Vector2(11.0, 5.5), 1, w[2])
			Px.put(im, 6, 10, Color(ItemIcons.LEAF[1]))
			Px.put(im, 7, 10, Color(ItemIcons.LEAF[2]))
			for q in [Vector2(8.5, 5.0), Vector2(13.5, 8.0), Vector2(9.5, 1.0)]:
				Px.line(im, Vector2(11.0, 5.0), q, 1, w[2])
			Px.disc(im, 11.5, 4.5, 3.6, p[1])
			Px.disc(im, 11.0, 4.0, 2.6, p[2])
			Px.put(im, 10, 3, p[p.size() - 1])
			Px.put(im, 11, 3, p[p.size() - 1])
		_:
			return false
	return true
