class_name PassBiomi
extends GenPass
## Divide la superficie in tratti di bioma (`BiomesData`) e rimodella il terreno di ciascuno: le paludi più basse e
## piatte, le distese d'ambra più alte e mosse. Il passaggio tra due biomi è morbido (media su BLEND colonne).
## Viene subito dopo il Terreno: le passate che seguono (strati, erba, alberi, decorazioni) leggono `World.biomes`.


func title() -> String:
	return "Biomi"


func run(w: World, c: GenContext) -> void:
	var rng := c.rng
	var B: Array = BiomesData.BIOMES
	# i tratti: da sinistra a destra, mai due uguali di fila; la partenza sempre nella foresta
	var x := 0
	var prev := -1
	while x < w.w:
		var len := rng.randi_range(BiomesData.SEG_MIN, BiomesData.SEG_MAX)
		var b := _pick(rng, prev)
		for k in range(x, mini(x + len, w.w)):
			w.biomes[k] = b
		prev = b
		x += len
	for k in range(maxi(w.spawn.x - BiomesData.SPAWN_SAFE, 0), mini(w.spawn.x + BiomesData.SPAWN_SAFE, w.w)):
		w.biomes[k] = 0
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


func _pick(rng: RandomNumberGenerator, prev: int) -> int:
	var tot := 0
	for k in BiomesData.BIOMES.size():
		if k != prev:
			tot += int(BiomesData.BIOMES[k]["weight"])
	var v := rng.randi_range(1, tot)
	for k in BiomesData.BIOMES.size():
		if k == prev:
			continue
		v -= int(BiomesData.BIOMES[k]["weight"])
		if v <= 0:
			return k
	return 0
