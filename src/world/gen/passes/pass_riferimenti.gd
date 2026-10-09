class_name PassRiferimenti
extends GenPass
## I punti di riferimento (voce 466, Roadmap 60): cose che si vedono da lontano e dicono «sono di qua». In ogni tratto di
## bioma lungo almeno `MIN_RUN` colonne (fuori dai mari e dalla partenza), sul punto più alto, una di:
## - **guglia**: un dente della roccia del bioma alto 22-40 righe, che si stringe salendo, con una liana per salirci;
## - **rovina sul colle**: due colonne di pietra dei Seminatori con l'architrave spezzato e uno scrigno ai loro piedi;
## - **cerchio di pietre**: quattro o cinque pietre ritte alte 5-9.
## Diventano punti di riferimento anche i massicci, gli archi e la traccia del passato (che aggiunge `PassTracce`). Appunti "riferimenti"
## [[x, y, nome]]: `MapReveal` li copia in `world_meta["riferimenti"]` e la mappa li segna una volta visti.
## Dopo le Rocce (le liane non si cancellano più), prima delle Rovine (che vedono il loro posto preso).

const MIN_RUN := 120
const KINDS := ["guglia", "rovina", "cerchio"]
const LIANA := 99


func title() -> String:
	return "Punti di riferimento"


func run(w: World, c: GenContext) -> void:
	var out := []
	c.notes["riferimenti"] = out
	if bool(c.params.get("giardino", false)):
		return
	var sea := PackedByteArray()
	sea.resize(w.w)
	for s in c.notes.get("mari", []):
		for x in range(maxi(int(s[0]) - 10, 0), mini(int(s[1]) + 10, w.w)):
			sea[x] = 1
	var x := 0
	var k := 0
	while x < w.w:
		var b := int(w.biomes[x])
		var x1 := x
		while x1 < w.w and int(w.biomes[x1]) == b:
			x1 += 1
		if x1 - x >= MIN_RUN:
			# i punti più alti del tratto, dal più alto: il primo con il posto libero
			var cand := []
			for xx in range(x + 15, x1 - 15, 3):
				if sea[xx] == 0 and absi(xx - w.spawn.x) >= 150:
					cand.append(xx)
			cand.sort_custom(func(a: int, bb: int) -> bool: return w.surface[a] < w.surface[bb])
			var kind: String = KINDS[(k + c.rng.randi_range(0, 2)) % KINDS.size()]
			for best in cand.slice(0, 12):
				var name := _build(w, c, kind, best, b)
				if name != "":
					out.append([best, int(w.surface[best]) - 2, name])
					k += 1
					break
		x = x1
	for m in c.notes.get("massicci", []):
		out.append([int(m[0]), int(w.surface[int(m[0])]) - 2, "Il massiccio"])
	for a in c.notes.get("archi", []):
		out.append([int(a[0]), int(a[1]), "L'arco di roccia"])


func _build(w: World, c: GenContext, kind: String, x: int, b: int) -> String:
	var s := int(w.surface[x])
	var rect := Rect2i(x - 12, s - 42, 25, 44)
	if not c.is_free(rect):
		return ""
	PassTracce._clear_trees(w, x - 12, x + 13)
	var rock: int = w.tile(x, s + 6) if w.solid(x, s + 6) else TileDefs.STONE
	var bname := String(BiomesData.BIOMES[b]["name"])
	var name := ""
	match kind:
		"guglia":
			var h := c.rng.randi_range(22, 40)
			for dy in range(1, h + 1):
				var half := int(round(3.0 * (1.0 - float(dy) / h) + 0.4))
				for dx in range(-half, half + 1):
					w.set_tile(x + dx, s - dy, rock)
			for dy in range(1, h - 2):
				var half := int(round(3.0 * (1.0 - float(dy) / h) + 0.4))
				for vx in [x - half - 1, x + half + 1]:              # (voce 474) su tutti e due i fianchi
					_vine(w, vx, s - dy)
			name = "La guglia (%s)" % bname
		"rovina":
			var h := c.rng.randi_range(8, 12)
			for side in [-5, 5]:
				for dy in range(1, h + 1 - (2 if side > 0 else 0)):        # la colonna di destra è spezzata
					w.set_tile(x + side, s - dy, TileDefs.PIETRA_SEM)
					w.set_tile(x + side + 1, s - dy, TileDefs.PIETRA_SEM)
			for dx in range(-5, 3):
				w.set_tile(x + dx, s - h - 1, TileDefs.PIETRA_SEM)                # l'architrave, spezzato a destra
			# (voce 474) le liane fuori e dentro le colonne: senza, la rovina era un muro per chi passava
			for side in [-5, 5]:
				for vx in [x + side - 1, x + side + 2]:
					for dy in range(1, h + 1):
						_vine(w, vx, s - dy)
			var o := Vector2i(x - 1, s - 2)
			if w.station_fits("scrigno", o):
				w.stations[o] = "scrigno"
				var loot := LootData.roll_chest("rovina_1", c.rng, 2)
				for id in loot:
					w.chest_at(o).add(id, int(loot[id]))
			name = "La rovina sul colle (%s)" % bname
		"cerchio":
			var n := c.rng.randi_range(4, 5)
			for i in n:
				var px := x - (n - 1) * 3 + i * 6
				var ph := c.rng.randi_range(5, 9)
				var py := int(w.surface[px])
				for dy in range(1, ph + 1):
					w.set_tile(px, py - dy, rock)
					w.set_tile(px + 1, py - dy, rock)
				for dy in range(1, ph + 1):
					_vine(w, px - 1, py - dy)                             # (voce 474) si sale da tutti e due i lati
					_vine(w, px + 2, py - dy)
			name = "Il cerchio di pietre (%s)" % bname
	c.claim(rect, "riferimento")
	return name


static func _vine(w: World, x: int, y: int) -> void:
	if w.inside(x, y) and not w.solid(x, y) and (w.decor_at(x, y) == 0 or TileDefs.is_soft_decor(w.decor_at(x, y))):
		w.set_decor(x, y, LIANA)
