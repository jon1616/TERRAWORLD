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
		"corona":
			# corona di rami intrecciati con tre gemme dei colori del materiale
			var w := ItemIcons.pal("legno")
			for x in range(2, 14):
				Px.put(im, x, 12, w[3])
				Px.put(im, x, 13, w[2])
			for k in 3:
				var bx := 3.0 + k * 5.0
				Px.line(im, Vector2(bx, 12.0), Vector2(bx + 1.0, 5.0 - (k % 2) * 2.0), 1, w[3])
				Px.disc(im, bx + 1.0, 4.5 - (k % 2) * 2.0, 1.6, p[k + 1])
			Px.put(im, 8, 10, p[p.size() - 1])
		"gemma":
			# gemma tagliata: corona a faccette, padiglione a punta, un lampo di luce
			for y in range(3, 14):
				var hw := 6.0 if y < 7 else 6.0 * (13.0 - y) / 6.0
				if y == 3:
					hw = 4.0
				for x in S:
					var dx := x + 0.5 - 8.0
					if absf(dx) <= hw:
						var c := p[3] if y < 7 else (p[2] if dx < 0.0 else p[1])
						if y == 6 or (y < 7 and int(absf(dx)) % 3 == 2):
							c = p[2]
						Px.put(im, x, y, c)
			Px.put(im, 6, 4, p[p.size() - 1])
			Px.put(im, 5, 5, p[p.size() - 1])
		"alambicco":
			var w := ItemIcons.pal("legno")
			Px.line(im, Vector2(3.0, 15.0), Vector2(8.0, 10.0), 1, w[3])
			Px.line(im, Vector2(13.0, 15.0), Vector2(8.0, 10.0), 1, w[3])
			Px.disc(im, 7.0, 8.5, 4.0, Color(0.72, 0.95, 0.98, 0.7))
			Px.disc(im, 7.0, 9.5, 2.8, p[2])
			Px.line(im, Vector2(7.0, 4.0), Vector2(7.0, 1.0), 1, Color(0.72, 0.95, 0.98, 0.8))
			Px.curve(im, Vector2(7.0, 1.0), Vector2(12.0, 0.0), Vector2(13.0, 6.0), 1, Color(0.72, 0.95, 0.98, 0.8))
			Px.put(im, 6, 8, Color.WHITE)
		"telaio":
			var w2 := ItemIcons.pal("legno")
			Px.line(im, Vector2(2.0, 15.0), Vector2(2.0, 2.0), 1, w2[3])
			Px.line(im, Vector2(13.0, 15.0), Vector2(13.0, 2.0), 1, w2[3])
			Px.line(im, Vector2(2.0, 3.0), Vector2(13.0, 3.0), 1, w2[4])
			for x in range(4, 12, 2):
				Px.line(im, Vector2(x, 4.0), Vector2(x, 8.0), 1, p[2])
			for y in range(9, 13):
				for x in range(3, 13):
					Px.put(im, x, y, Color(ItemIcons.LEAF[1]) if y % 2 == 0 else p[3])
		"mola":
			var w3 := ItemIcons.pal("legno")
			Px.line(im, Vector2(2.0, 15.0), Vector2(6.0, 9.0), 1, w3[3])
			Px.line(im, Vector2(14.0, 15.0), Vector2(10.0, 9.0), 1, w3[3])
			Px.disc(im, 8.0, 7.0, 5.5, p[2])
			Px.disc(im, 8.0, 7.0, 4.0, p[1])
			Px.disc(im, 8.0, 7.0, 1.2, w3[3])
			Px.put(im, 13, 14, Color("#c8283c"))
		"altare":
			# una lastra di pietra lavorata su due colonne, la runa accesa sopra
			for x in [3, 12]:
				for y in range(8, 15):
					Px.put(im, x, y, p[2])
					Px.put(im, x + 1, y, p[1])
			for y in range(5, 8):
				for x in range(1, 15):
					Px.put(im, x, y, p[3] if y == 5 else p[2])
			Px.line(im, Vector2(5.0, 3.0), Vector2(10.0, 3.0), 1, Color("#6ff0d8"))
			Px.put(im, 8, 2, Color.WHITE)
		"tavoletta":
			# tavoletta di pietra dei Seminatori con un canto inciso, i segni del colore del materiale
			var sem := ItemIcons.pal("sem")
			for y in range(2, 15):
				for x in range(3, 13):
					Px.put(im, x, y, sem[3] if x < 5 or y < 4 else sem[2])
			for k in 4:
				Px.line(im, Vector2(5.0, 5.0 + k * 2.5), Vector2(10.0 + (k % 2), 5.0 + k * 2.5), 1, p[2])
			Px.put(im, 8, 13, p[p.size() - 1])
		"mappa":
			# una lastra sottile arrotolata ai lati, con un sentiero e una croce accesa
			var sem2 := ItemIcons.pal("sem")
			for y in range(3, 13):
				for x in range(2, 14):
					Px.put(im, x, y, sem2[3] if (x + y) % 5 else sem2[2])
			Px.line(im, Vector2(2.0, 3.0), Vector2(2.0, 12.0), 1, sem2[1])
			Px.line(im, Vector2(13.0, 3.0), Vector2(13.0, 12.0), 1, sem2[1])
			Px.curve(im, Vector2(4.0, 11.0), Vector2(7.0, 4.0), Vector2(10.0, 8.0), 1, Color(ItemIcons.MATERIALS["legno"][2]))
			Px.put(im, 10, 7, Color("#ffd24a"))
			Px.put(im, 11, 8, Color("#ffd24a"))
			Px.put(im, 9, 8, Color("#ffd24a"))
			Px.put(im, 10, 9, Color("#ffd24a"))
		"uncino":
			# una radice arrotolata a spirale con l'uncino in punta del materiale
			var w := ItemIcons.pal("legno")
			var ang := 0.0
			var r := 5.5
			for k in 30:
				var q := Vector2(6.0, 10.0) + Vector2(cos(ang), sin(ang)) * r
				Px.put(im, int(q.x), int(q.y), w[3] if k % 3 else w[2])
				ang += 0.42
				r *= 0.95
			Px.line(im, Vector2(9.0, 7.0), Vector2(12.5, 2.5), 1, w[3])
			Px.curve(im, Vector2(12.5, 2.5), Vector2(15.0, 4.0), Vector2(13.0, 7.0), 1, p[2])
			Px.put(im, 13, 7, p[p.size() - 1])
		"bomba":
			# un baccello gonfio con la miccia accesa
			for y in range(4, 16):
				for x in S:
					var d := Vector2((x + 0.5 - 8.0) / 5.5, (y + 0.5 - 10.0) / 5.5)
					if d.length() <= 1.0:
						Px.put(im, x, y, p[2] if d.x < -0.1 else p[1])
			for k in 3:
				Px.line(im, Vector2(5.0 + k * 3.0, 6.0), Vector2(5.5 + k * 3.0, 14.0), 1, p[0])
			Px.line(im, Vector2(8.0, 4.0), Vector2(10.0, 1.0), 1, Color(ItemIcons.MATERIALS["legno"][3]))
			Px.put(im, 10, 0, Color("#ffe8b0"))
			Px.put(im, 11, 1, Color("#ffb040"))
		"ricurvo":
			# un seme a mezzaluna con le venature
			for y in S:
				for x in S:
					var d := Vector2(x + 0.5 - 7.0, y + 0.5 - 8.0)
					var e := Vector2(x + 0.5 - 10.0, y + 0.5 - 8.0)
					if d.length() <= 6.5 and e.length() > 5.0:
						Px.put(im, x, y, p[2] if y < 8 else p[1])
			Px.put(im, 3, 6, p[p.size() - 1])
			Px.put(im, 3, 10, p[p.size() - 1])
		"giavellotto":
			Px.line(im, Vector2(2.0, 14.0), Vector2(11.0, 5.0), 1, Color(ItemIcons.MATERIALS["legno"][3]))
			Px.line(im, Vector2(11.0, 5.0), Vector2(14.0, 2.0), 2, p[2])
			Px.put(im, 14, 1, p[p.size() - 1])
			Px.put(im, 2, 13, Color(ItemIcons.LEAF[1]))
			Px.put(im, 3, 14, Color(ItemIcons.LEAF[2]))
		"tubero":
			for y in range(6, 15):
				for x in range(2, 14):
					var d := Vector2((x + 0.5 - 8.0) / 5.5, (y + 0.5 - 10.5) / 4.0)
					if d.length() <= 1.0:
						Px.put(im, x, y, p[2] if d.x < -0.1 else p[1])
			Px.put(im, 6, 9, p[p.size() - 1])
			Px.put(im, 10, 12, p[0])
			Px.line(im, Vector2(8.0, 6.0), Vector2(6.0, 1.0), 1, Color(ItemIcons.LEAF[1]))
			Px.line(im, Vector2(8.0, 6.0), Vector2(11.0, 2.0), 1, Color(ItemIcons.LEAF[2]))
		"ciotola":
			# una ciotola di legno piena, il vapore sopra
			var w5 := ItemIcons.pal("legno")
			for y in range(8, 15):
				var hw := 7.0 - (y - 8) * 0.6
				for x in S:
					if absf(x + 0.5 - 8.0) <= hw:
						Px.put(im, x, y, w5[3] if y > 9 else p[2])
			for x in range(2, 14):
				Px.put(im, x, 8, p[p.size() - 1] if x % 3 == 0 else p[2])
			Px.put(im, 6, 5, Color(0.9, 0.9, 0.9, 0.6))
			Px.put(im, 9, 4, Color(0.9, 0.9, 0.9, 0.6))
		"annaffiatoio":
			var w6 := ItemIcons.pal("legno")
			for y in range(6, 14):
				for x in range(3, 11):
					Px.put(im, x, y, w6[3] if x > 3 else w6[4])
			Px.line(im, Vector2(10.0, 11.0), Vector2(14.0, 6.0), 1, w6[3])
			Px.put(im, 14, 5, Color("#6ff0d8"))
			Px.curve(im, Vector2(4.0, 6.0), Vector2(7.0, 1.0), Vector2(10.0, 6.0), 1, w6[2])
		"paiolo":
			for y in range(5, 13):
				var hw2 := 6.0 - absf(y - 9.0) * 0.4
				for x in S:
					if absf(x + 0.5 - 8.0) <= hw2:
						Px.put(im, x, y, p[3] if y < 7 else p[2])
			Px.put(im, 6, 14, Color("#ffb040"))
			Px.put(im, 9, 14, Color("#ff7a30"))
			Px.put(im, 7, 3, Color(0.9, 0.9, 0.9, 0.6))
		"stella":
			# una stellina a cinque punte, calda al centro
			for k in 10:
				var ang := -PI / 2.0 + k * PI / 5.0
				var r := 7.0 if k % 2 == 0 else 3.0
				var q := Vector2(8.0, 8.5) + Vector2(cos(ang), sin(ang)) * r
				Px.line(im, Vector2(8.0, 8.5), q, 1, p[2])
			Px.disc(im, 8.0, 8.5, 2.6, p[p.size() - 1])
			Px.put(im, 8, 8, Color.WHITE)
		"mattoni":
			for y in range(3, 14):
				for x in range(2, 14):
					var row := (y - 3) / 3
					var j := (x + (3 if row % 2 else 0)) % 6 == 0
					Px.put(im, x, y, p[0] if (y - 3) % 3 == 0 or j else (p[3] if (y - 3) % 3 == 1 else p[2]))
		"vetro":
			for y in range(3, 14):
				for x in range(2, 14):
					var c := p[2]
					c.a = 0.5
					if x == 2 or x == 13 or y == 3 or y == 13:
						c = p[0]
					elif (x + y) % 7 < 2:
						c = p[p.size() - 1]
					Px.put(im, x, y, c)
		"parete":
			for y in range(2, 15):
				for x in range(2, 14):
					var row2 := (y - 2) / 4
					var j2 := (x + (3 if row2 % 2 else 0)) % 6 == 0
					Px.put(im, x, y, Px.sh(p[1], 0.7) if (y - 2) % 4 == 0 or j2 else Px.sh(p[2], 0.75))
		"martello":
			var w7 := ItemIcons.pal("legno")
			Px.line(im, Vector2(3.0, 14.0), Vector2(10.0, 6.0), 2, w7[3])
			for y in range(1, 7):
				for x in range(8, 15):
					Px.put(im, x, y, Color(ItemIcons.MATERIALS["ardesia"][3]) if y < 3 else Color(ItemIcons.MATERIALS["ardesia"][2]))
		"porta":
			for y in range(1, 16):
				for x in range(4, 12):
					Px.put(im, x, y, p[3] if (x - 4) % 3 else p[1])
			Px.put(im, 10, 8, Color(ItemIcons.LEAF[2]))
		"lampada":
			var w8 := ItemIcons.pal("legno")
			Px.line(im, Vector2(8.0, 15.0), Vector2(8.0, 8.0), 1, w8[3])
			for y in range(2, 8):
				var hw3 := 1.5 + (y - 2) * 0.7
				for x in S:
					if absf(x + 0.5 - 8.0) <= hw3:
						Px.put(im, x, y, Color("#ffc060") if y > 4 else Color("#e89a40"))
		"tavolo":
			for x in range(1, 15):
				Px.put(im, x, 6, p[p.size() - 1])
				Px.put(im, x, 7, p[3])
			Px.line(im, Vector2(3.0, 8.0), Vector2(3.0, 14.0), 1, p[2])
			Px.line(im, Vector2(12.0, 8.0), Vector2(12.0, 14.0), 1, p[2])
		"sedia":
			Px.line(im, Vector2(5.0, 1.0), Vector2(5.0, 14.0), 1, p[3])
			for x in range(5, 12):
				Px.put(im, x, 8, p[p.size() - 1])
			Px.line(im, Vector2(11.0, 9.0), Vector2(11.0, 14.0), 1, p[2])
		"letto":
			var w9 := ItemIcons.pal("legno")
			for x in range(1, 15):
				Px.put(im, x, 11, w9[3])
			Px.line(im, Vector2(1.0, 11.0), Vector2(1.0, 5.0), 1, w9[3])
			for k in 4:
				Px.disc(im, 4.0 + k * 3.0, 9.0, 2.2, p[2 + k % 2])
			Px.line(im, Vector2(2.0, 12.0), Vector2(2.0, 14.0), 1, w9[2])
			Px.line(im, Vector2(13.0, 12.0), Vector2(13.0, 14.0), 1, w9[2])
		"lumino":
			# una goccia di luce solida con il suo alone
			Px.disc(im, 8.0, 9.0, 5.0, Color(p[1].r, p[1].g, p[1].b, 0.4))
			for y in range(3, 14):
				var t2 := (y - 3.0) / 10.0
				var hw4 := 3.8 * sqrt(t2) * (1.0 - maxf(t2 - 0.7, 0.0) * 2.5)
				for x in S:
					if absf(x + 0.5 - 8.0) <= hw4:
						Px.put(im, x, y, p[p.size() - 1] if x < 8 else p[2])
			Px.put(im, 7, 8, Color.WHITE)
		"focolare":
			var st2 := ItemIcons.pal("ardesia")
			for k in 4:
				Px.disc(im, 3.0 + k * 3.3, 13.0, 1.8, st2[2])
			Px.disc(im, 8.0, 9.0, 3.2, p[2])
			Px.disc(im, 8.0, 8.0, 1.8, p[p.size() - 1])
			Px.put(im, 8, 4, p[2])
		"radice_viaggio":
			# un arco di radice piantato nella terra, con un nodo di Linfa acceso al centro
			var w12 := ItemIcons.pal("legno")
			Px.curve(im, Vector2(2.5, 15.0), Vector2(1.0, 1.0), Vector2(8.0, 2.5), 2, w12[3])
			Px.curve(im, Vector2(8.0, 2.5), Vector2(15.0, 1.0), Vector2(13.5, 15.0), 2, w12[3])
			Px.curve(im, Vector2(3.0, 15.0), Vector2(2.0, 2.0), Vector2(8.0, 3.0), 1, w12[2])
			Px.disc(im, 8.0, 9.0, 3.0, Color(p[2].r, p[2].g, p[2].b, 0.45))
			Px.disc(im, 8.0, 9.0, 1.8, p[2])
			Px.put(im, 8, 8, p[p.size() - 1])
			Px.put(im, 5, 5, Color(ItemIcons.LEAF[1]))
			Px.put(im, 11, 5, Color(ItemIcons.LEAF[2]))
		"vasetto":
			# vasetto di vetro con tappo di corteccia: dentro, un piccolo compagno luminoso del materiale
			var w10 := ItemIcons.pal("legno")
			var gl := Color(0.75, 0.95, 1.0, 0.35)
			for y in range(5, 15):
				for x in range(3, 13):
					Px.put(im, x, y, gl)
			Px.line(im, Vector2(3.0, 5.0), Vector2(3.0, 14.5), 1, Color(0.8, 1.0, 1.0, 0.8))
			Px.line(im, Vector2(12.5, 5.0), Vector2(12.5, 14.5), 1, Color(0.5, 0.7, 0.8, 0.8))
			Px.line(im, Vector2(3.0, 14.5), Vector2(12.5, 14.5), 1, Color(0.5, 0.7, 0.8, 0.8))
			Px.line(im, Vector2(4.0, 3.5), Vector2(11.5, 3.5), 2, w10[3])
			Px.put(im, 7, 1, Color(ItemIcons.LEAF[2]))
			Px.put(im, 8, 2, Color(ItemIcons.LEAF[1]))
			Px.disc(im, 8.0, 10.0, 3.4, Color(p[2].r, p[2].g, p[2].b, 0.5))
			Px.disc(im, 8.0, 10.0, 2.2, p[2])
			Px.put(im, 7, 9, p[p.size() - 1])
			Px.put(im, 9, 9, p[p.size() - 1])
		"evocatore":
			# bastone che si arriccia in cima attorno a un cuore di foglia del materiale
			var w11 := ItemIcons.pal("legno")
			Px.line(im, Vector2(3.0, 15.0), Vector2(8.5, 6.0), 2, w11[3])
			Px.line(im, Vector2(3.5, 15.0), Vector2(9.0, 6.0), 1, w11[2])
			Px.curve(im, Vector2(8.5, 6.0), Vector2(8.0, 0.5), Vector2(14.0, 3.5), 1, w11[2])
			Px.curve(im, Vector2(14.0, 3.5), Vector2(14.5, 9.0), Vector2(10.0, 8.5), 1, w11[2])
			Px.disc(im, 11.3, 5.0, 2.4, p[1])
			Px.disc(im, 11.0, 4.6, 1.5, p[2])
			Px.put(im, 11, 4, p[p.size() - 1])
			Px.put(im, 5, 11, Color(ItemIcons.LEAF[1]))
			Px.put(im, 4, 11, Color(ItemIcons.LEAF[2]))
		_:
			return false
	return true


## Manico corto di legno in basso (specchi, lanterne piccole).
static func _handle_short(im: Image) -> void:
	var w := ItemIcons.pal("legno")
	Px.line(im, Vector2(8.0, 10.0), Vector2(8.0, 15.0), 2, w[3])
	Px.put(im, 8, 13, Color(ItemIcons.LEAF[1]))
