class_name IconShapes
extends RefCounted
## Le forme d'icona nate dalla Roadmap 3 (voce 21 in poi), separate da `ItemIcons` perché quel file non cresca oltre
## le 400 righe. Stesso stile: legno di radice, foglie, perle d'ambra; il materiale sceglie la tavolozza `p`.
## `draw` restituisce false se la forma non è sua (allora `ItemIcons` disegna il segno d'errore).

const S := 16


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
		"penna":
			# penna di corteccia: rachide scuro e barbe a foglia
			Px.line(im, Vector2(3.0, 14.0), Vector2(12.0, 2.0), 1, p[1])
			for k in 9:
				var q := Vector2(3.0, 14.0).lerp(Vector2(12.0, 2.0), 0.2 + k * 0.09)
				Px.line(im, q, q + Vector2(-3.0, -1.0), 1, p[3] if k % 2 == 0 else p[2])
				Px.line(im, q, q + Vector2(2.0, 2.5), 1, p[2])
			Px.put(im, 12, 2, Color(ItemIcons.LEAF[2]))
		"aculeo":
			for k in 3:
				var bx := 4.0 + k * 4.0
				Px.line(im, Vector2(bx, 14.0), Vector2(bx + 2.0, 2.0 + k * 2.0), 2 if k == 1 else 1, p[2])
				Px.put(im, int(bx + 2.0), 2 + k * 2, p[p.size() - 1])
		"seta":
			# un gomitolo di filo avvolto su un rametto
			Px.line(im, Vector2(2.0, 13.0), Vector2(14.0, 3.0), 1, Color(ItemIcons.MATERIALS["legno"][3]))
			Px.disc(im, 8.0, 8.0, 4.6, p[2])
			for k in 4:
				Px.line(im, Vector2(4.5, 6.0 + k * 1.6), Vector2(11.5, 7.0 + k * 1.6), 1, p[p.size() - 1] if k % 2 == 0 else p[1])
		"artiglio":
			for k in 3:
				Px.curve(im, Vector2(3.0 + k * 3.5, 3.0), Vector2(6.0 + k * 3.5, 9.0), Vector2(3.5 + k * 3.5, 14.0), 2 if k == 1 else 1, p[2])
				Px.put(im, int(3.5 + k * 3.5), 14, p[p.size() - 1])
			Px.line(im, Vector2(2.0, 3.0), Vector2(12.0, 3.0), 2, Color(ItemIcons.MATERIALS["humus"][3]))
		"membrana":
			# un lembo d'ala teso tra tre dita di pietra
			for k in 12:
				Px.line(im, Vector2(2.0, 3.0), Vector2(14.0, 3.0).lerp(Vector2(8.0, 14.0), k / 11.0), 1, p[2] if k % 3 else p[3])
			Px.line(im, Vector2(2.0, 3.0), Vector2(14.0, 3.0), 1, p[1])
			Px.line(im, Vector2(2.0, 3.0), Vector2(8.0, 14.0), 1, p[1])
		"guscio":
			for y in S:
				for x in S:
					var d := Vector2(x + 0.5 - 8.0, y + 0.5 - 8.5)
					if d.length() <= 6.2:
						var ring := fmod(d.length() + atan2(d.y, d.x) * 0.9 + TAU, 2.6)
						Px.put(im, x, y, p[p.size() - 1] if ring < 0.7 else (p[2] if ring < 1.6 else p[1]))
		"geode":
			Px.disc(im, 8.0, 8.5, 6.0, Color(ItemIcons.MATERIALS["ardesia"][2]))
			Px.disc(im, 8.0, 8.5, 4.2, p[1])
			for q in [Vector2(6.0, 7.0), Vector2(9.5, 6.5), Vector2(8.0, 10.5), Vector2(10.5, 9.5), Vector2(5.5, 10.0)]:
				Px.put(im, int(q.x), int(q.y), p[p.size() - 1])
				Px.put(im, int(q.x), int(q.y) + 1, p[3])
		"occhio":
			for y in S:
				for x in S:
					var e := Vector2((x + 0.5 - 8.0) / 6.5, (y + 0.5 - 8.0) / 4.2)
					if e.length() <= 1.0:
						Px.put(im, x, y, Color("#e8f8f8") if e.length() > 0.55 else p[2])
			Px.disc(im, 8.0, 8.0, 1.2, Color("#101820"))
			Px.put(im, 9, 7, Color.WHITE)
		"lama":
			Px.curve(im, Vector2(3.0, 14.0), Vector2(14.0, 11.0), Vector2(11.0, 1.0), 2, p[2])
			Px.curve(im, Vector2(4.0, 13.0), Vector2(13.0, 10.0), Vector2(11.0, 2.0), 1, p[p.size() - 1])
		"mantello":
			for y in range(3, 15):
				var hw := 2.0 + (y - 3) * 0.45
				for x in S:
					var dx := x + 0.5 - 8.0
					if absf(dx) <= hw:
						Px.put(im, x, y, p[3] if (x + y) % 3 == 0 else (p[2] if dx < 0.0 else p[1]))
			Px.line(im, Vector2(5.0, 3.0), Vector2(11.0, 3.0), 1, Color(ItemIcons.LEAF[2]))
		"collana":
			for k in 24:
				var a := k / 24.0 * PI
				Px.put(im, int(8.0 + cos(a) * 6.0), int(4.0 + sin(a) * 6.0), Color(ItemIcons.MATERIALS["seta"][2]))
			for k in 5:
				var a2 := 0.3 + k / 4.0 * (PI - 0.6)
				var q := Vector2(8.0 + cos(a2) * 6.0, 4.0 + sin(a2) * 6.0)
				Px.line(im, q, q + Vector2(cos(a2), sin(a2)) * 3.5, 1, p[2])
		"benda":
			for y in range(4, 13):
				for x in range(2, 14):
					if absf((x - 8.0) * 0.6 - (y - 8.0)) < 3.2:
						Px.put(im, x, y, p[2] if (x + y) % 4 else p[1])
			Px.line(im, Vector2(6.0, 9.0), Vector2(10.0, 7.0), 1, Color("#e04a60"))
		"guanti":
			for y in range(5, 15):
				for x in range(3, 11):
					Px.put(im, x, y, p[2] if x > 3 else p[3])
			for k in 3:
				Px.line(im, Vector2(4.0 + k * 3.0, 5.0), Vector2(5.0 + k * 3.0, 1.0), 1, Color(ItemIcons.MATERIALS["legnoferro"][3]))
			Px.line(im, Vector2(10.0, 9.0), Vector2(14.0, 6.0), 2, p[2])
		"ali":
			for side in [-1, 1]:
				for k in 8:
					Px.line(im, Vector2(8.0, 9.0), Vector2(8.0 + side * 7.0, 2.0).lerp(Vector2(8.0 + side * 5.0, 14.0), k / 7.0), 1, p[2] if k % 2 else p[3])
			Px.disc(im, 8.0, 9.0, 1.5, p[1])
		"scudo":
			for y in range(1, 15):
				var hw := 6.0 if y < 8 else 6.0 - (y - 8) * 0.85
				for x in S:
					var dx := x + 0.5 - 8.0
					if absf(dx) <= hw:
						Px.put(im, x, y, p[3] if dx < 0.0 else p[2])
			Px.disc(im, 8.0, 7.0, 2.0, p[p.size() - 1])
		"specchio":
			_handle_short(im)
			Px.disc(im, 8.0, 6.0, 5.2, Color(ItemIcons.MATERIALS["ambra"][2]))
			Px.disc(im, 8.0, 6.0, 4.0, p[2])
			Px.put(im, 6, 4, Color.WHITE)
			Px.put(im, 7, 3, p[p.size() - 1])
		"falce":
			Px.line(im, Vector2(3.0, 15.0), Vector2(9.0, 3.0), 1, Color(ItemIcons.MATERIALS["legno"][3]))
			Px.curve(im, Vector2(9.0, 3.0), Vector2(15.0, 5.0), Vector2(13.0, 12.0), 2, p[2])
			Px.curve(im, Vector2(9.0, 2.0), Vector2(14.0, 4.0), Vector2(14.0, 11.0), 1, p[p.size() - 1])
		"velo":
			for y in range(2, 15):
				for x in range(3, 13):
					var wave := sin(y * 0.9 + x * 0.3) * 1.2
					if absf(x + 0.5 - 8.0 + wave * 0.5) <= 4.2:
						var c := p[2] if (x + y) % 3 else p[3]
						c.a = 0.85
						Px.put(im, x, y, c)
		_:
			return false
	return true


## Manico corto di legno in basso (specchi, lanterne piccole).
static func _handle_short(im: Image) -> void:
	var w := ItemIcons.pal("legno")
	Px.line(im, Vector2(8.0, 10.0), Vector2(8.0, 15.0), 2, w[3])
	Px.put(im, 8, 13, Color(ItemIcons.LEAF[1]))
