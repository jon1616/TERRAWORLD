class_name PassTane
extends GenPass
## Le tane dei Custodi degli strati (voce 27): per ogni Custode di `KeepersData` una grande caverna ovale nel suo
## strato, con la parete dello strato, le decorazioni del suo stile sulle pareti e al centro, sul pavimento, il
## **bozzolo** (stazione fissa `bozzolo_<custode>`) da cui si schiude quando il Germogliato si avvicina. Lontana dal
## Cuore, dalle rovine e dalla partenza. Posizioni negli appunti (`notes["tane"]`).

const W := 38                          # larghezza della caverna (tessere)
const H := 18
const FAR := 90.0                      # distanza minima dalle altre stazioni e dalla partenza


func title() -> String:
	return "Tane"


func run(w: World, c: GenContext) -> void:
	var dens := {}
	for k in KeepersData.KEEPERS:
		var kd: Dictionary = KeepersData.KEEPERS[k]
		var st := int(kd["stratum"])
		var top := StrataData.top(st) + H
		var bottom := (StrataData.top(st + 1) if st + 1 < StrataData.STRATA.size() else w.h) - H
		for tries in 200:
			var x := c.rng.randi_range(W + 60, w.w - W - 60)
			if kd.has("biome") and String(BiomesData.BIOMES[BiomesData.at(w, x)]["id"]) != String(kd["biome"]):
				continue                           # voce 56: i Custodi dei biomi, solo nel loro bioma
			var y := w.surface[x] + c.rng.randi_range(top, maxi(top + 1, bottom))
			var den := Rect2i(x - W / 2 - 3, y - H / 2 - 3, W + 6, H + 6)
			if y + H / 2 + 4 >= w.h or not _far(w, Vector2i(x, y)) or not c.is_free(den):
				continue
			_carve(w, c, Vector2i(x, y), st, int(kd["lair"]))
			c.claim(den, "tana")
			var o := Vector2i(x - 1, y + H / 2 - 4)       # il bozzolo (3×3) poggia sul pavimento della tana
			w.stations[o] = "bozzolo_" + k
			dens[k] = o
			break
	c.notes["tane"] = dens


func _far(w: World, q: Vector2i) -> bool:
	if Vector2(q - Vector2i(w.w / 2, w.surface[w.w / 2])).length() < FAR:
		return false                       # la partenza è a metà del mondo
	for o in w.stations:
		if Vector2(o - q).length() < FAR:
			return false
	return true


## La caverna: un ovale d'aria con il pavimento piatto al fondo, la parete dello strato, le decorazioni sulle pareti.
func _carve(w: World, c: GenContext, ctr: Vector2i, st: int, decor: int) -> void:
	var wall := int(StrataData.STRATA[st]["wall"])
	var rock := int(StrataData.STRATA[st]["rock"])
	var floor_y := ctr.y + H / 2 - 2
	for y in range(ctr.y - H / 2 - 2, ctr.y + H / 2 + 3):
		for x in range(ctr.x - W / 2 - 2, ctr.x + W / 2 + 3):
			if not w.inside(x, y):
				continue
			var d := Vector2((x - ctr.x) / (W * 0.5), (y - ctr.y) / (H * 0.5))
			var i := y * w.w + x
			if d.length() <= 1.0 and y <= floor_y:
				w.tiles[i] = TileDefs.AIR
				w.decor[i] = 0
				w.walls[i] = wall
			elif d.length() <= 1.25 or (y > floor_y and absf(d.x) <= 1.1 and y <= floor_y + 2):
				if w.tiles[i] == TileDefs.AIR:
					w.tiles[i] = rock           # un guscio di roccia attorno, così la tana ha una forma sua
				w.walls[i] = wall
	# le decorazioni dello stile: sulle pareti in alto (pendono) o sul pavimento
	for k in 26:
		var x := ctr.x + c.rng.randi_range(-W / 2 + 2, W / 2 - 2)
		for y in range(ctr.y - H / 2, floor_y + 1):
			var up := decor in TileDefs.DECOR_CEILING
			if up and not w.solid(x, y) and w.solid(x, y - 1):
				w.set_decor(x, y, decor)
				break
			if not up and not w.solid(x, y) and w.solid(x, y + 1) and absi(x - ctr.x) > 3:
				w.set_decor(x, y, decor)
				break
