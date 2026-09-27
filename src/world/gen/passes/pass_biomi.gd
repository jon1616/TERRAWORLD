class_name PassBiomi
extends GenPass
## Divide la superficie in tratti di bioma (`BiomesData`) e rimodella il terreno di ciascuno: le paludi più basse e
## piatte, le distese d'ambra più alte e mosse. Il passaggio tra due biomi è morbido (media su BLEND colonne).
## Viene subito dopo il Terreno: le passate che seguono (strati, erba, alberi, decorazioni) leggono `World.biomes`.


const SPLIT_MIN := 90                  # colonne minime di ognuna delle due metà quando si divide un tratto


func title() -> String:
	return "Biomi"


func run(w: World, c: GenContext) -> void:
	var rng := c.rng
	var B: Array = BiomesData.BIOMES
	# i tratti: da sinistra a destra, mai due uguali di fila; la partenza sempre nella foresta
	# il gene di superficie del Seme (voce 42, erano le specie della voce 39) sceglie i pesi dei biomi e quello della
	# partenza
	var sg := c.surface_gene()
	var weights := _weights(sg)
	var home := 0
	var home_set := sg != ""
	if home_set:
		home = BiomesData.index_of(String((GenesData.GENES[sg]["gen"]["biomes"] as Dictionary).keys()[0]))
	var x := 0
	var prev := -1
	var segs := []                          # [inizio, fine, bioma] di ogni tratto
	while x < w.w:
		var len := rng.randi_range(BiomesData.SEG_MIN, BiomesData.SEG_MAX)
		if bool(c.genes()["mosaic"]):
			len /= 4                         # gene «Mosaico» (voce 48): tratti brevi, tutti i biomi
		# con una specie lo stesso bioma può tornare di fila (così domina davvero); senza, mai due uguali
		var b := _pick(rng, -1 if home_set else prev, weights)
		for k in range(x, mini(x + len, w.w)):
			w.biomes[k] = b
		segs.append([x, mini(x + len, w.w), b])
		prev = b
		x += len
	for k in range(maxi(w.spawn.x - BiomesData.SPAWN_SAFE, 0), mini(w.spawn.x + BiomesData.SPAWN_SAFE, w.w)):
		w.biomes[k] = home
	if not home_set:
		_ensure_all(w, segs, weights, rng)
	# il terreno: colline più o meno mosse e superficie più alta o più bassa, sfumate tra un bioma e l'altro
	var base := w.h * float(c.params["surface_base"])
	var hills := PackedFloat32Array()
	var lift := PackedFloat32Array()
	hills.resize(w.w)
	lift.resize(w.w)
	for k in w.w:
		hills[k] = float(B[w.biomes[k]]["hills"])
		lift[k] = float(B[w.biomes[k]]["lift"])
	var r := BiomesData.BLEND
	var sh := 0.0
	var sl := 0.0
	for k in range(-r, r + 1):
		sh += hills[clampi(k, 0, w.w - 1)]
		sl += lift[clampi(k, 0, w.w - 1)]
	var flat := Vector2i(w.spawn.x - 8, w.spawn.x + 8)
	for k in w.w:
		var n := 2 * r + 1
		if k < flat.x or k > flat.y:
			var s := float(w.surface[k])
			w.surface[k] = int(base + (s - base) * sh / n + sl / n)
		sh += hills[clampi(k + r + 1, 0, w.w - 1)] - hills[clampi(k - r, 0, w.w - 1)]
		sl += lift[clampi(k + r + 1, 0, w.w - 1)] - lift[clampi(k - r, 0, w.w - 1)]


## Un mondo senza specie (il mondo casa) ha tutti i biomi: a quelli rimasti fuori per caso si dà un tratto preso a un
## bioma che ne ha più di uno, lontano dalla partenza (con cinque biomi il mondo di prova aveva perso le paludi).
func _ensure_all(w: World, segs: Array, weights: Array, rng: RandomNumberGenerator) -> void:
	var safe := Vector2i(w.spawn.x - BiomesData.SPAWN_SAFE, w.spawn.x + BiomesData.SPAWN_SAFE)
	for k in weights.size():
		if int(weights[k]) <= 0 or segs.any(func(sg: Array) -> bool: return int(sg[2]) == k):
			continue
		var free := []
		for sg in segs:
			var many := segs.filter(func(o: Array) -> bool: return int(o[2]) == int(sg[2])).size() > 1
			if many and (int(sg[1]) < safe.x or int(sg[0]) > safe.y):
				free.append(sg)
		if free.is_empty():
			# nessun bioma ripetuto da cui prendere un tratto: si divide in due il tratto più largo lontano dalla
			# partenza (28 set 2026: con 16 biomi e tratti di 220-440 colonne, prima qualche bioma mancava in silenzio)
			var big: Array = []
			for sg in segs:
				if (int(sg[1]) < safe.x or int(sg[0]) > safe.y) and int(sg[1]) - int(sg[0]) >= 2 * SPLIT_MIN \
						and (big.is_empty() or int(sg[1]) - int(sg[0]) > int(big[1]) - int(big[0])):
					big = sg
			if big.is_empty():
				continue
			var mid := (int(big[0]) + int(big[1])) / 2
			var half := [mid, int(big[1]), k]
			big[1] = mid
			segs.append(half)
			for xx in range(mid, int(half[1])):
				w.biomes[xx] = k
			continue
		var pick: Array = free[rng.randi_range(0, free.size() - 1)]
		pick[2] = k
		for xx in range(int(pick[0]), int(pick[1])):
			w.biomes[xx] = k


## Il peso di ogni bioma: quelli del gene di superficie, o quelli di `BiomesData` se il mondo non ne ha uno.
func _weights(sg: String) -> Array:
	var out := []
	for k in BiomesData.BIOMES.size():
		var bid := String(BiomesData.BIOMES[k]["id"])
		if sg != "":
			out.append(int((GenesData.GENES[sg]["gen"]["biomes"] as Dictionary).get(bid, 0)))
		else:
			out.append(int(BiomesData.BIOMES[k]["weight"]))
	return out


func _pick(rng: RandomNumberGenerator, prev: int, weights: Array) -> int:
	var tot := 0
	for k in weights.size():
		if k != prev:
			tot += int(weights[k])
	if tot <= 0:
		return maxi(prev, 0)                  # una specie con un solo bioma: sempre quello
	var v := rng.randi_range(1, tot)
	for k in weights.size():
		if k == prev:
			continue
		v -= int(weights[k])
		if v <= 0:
			return k
	return 0
