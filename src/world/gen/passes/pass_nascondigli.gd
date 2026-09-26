class_name PassNascondigli
extends GenPass
## I nascondigli dei Seminatori (voce 28): per ogni reliquia di `RelicsData` una piccola stanza murata di Pietra dei
## Seminatori **senza porta**, chiusa nella roccia dello strato della sua collezione, con un **reliquiario** che
## contiene la reliquia e un po' del bottino dello strato. Si trovano scavando, guardando i segni sulla mappa, o con la
## Mappa dei Seminatori. Posizioni negli appunti (`notes["nascondigli"]`).

const RW := 7                          # stanza interna 7×4
const RH := 4


func title() -> String:
	return "Nascondigli"


func run(w: World, c: GenContext) -> void:
	var rng := c.rng
	var out := []
	for col in RelicsData.COLLECTIONS:
		var cd: Dictionary = RelicsData.COLLECTIONS[col]
		for relic in cd["pieces"]:
			var st := int((cd["strata"] as Array)[rng.randi_range(0, (cd["strata"] as Array).size() - 1)])
			for tries in 400:
				var x := rng.randi_range(40, w.w - 50)
				var top := w.surface[x] + StrataData.top(st) + 6
				var bottom := w.surface[x] + StrataData.top(st + 1) if st + 1 < StrataData.STRATA.size() else w.h - 20
				if bottom - top < 10:
					continue
				var y := rng.randi_range(top, bottom - RH - 3)
				if not _solid_block(w, x - 1, y - 1, RW + 2, RH + 2) or not _far(w, Vector2i(x, y)):
					continue
				var o := _build(w, Vector2i(x, y), st, String(relic), rng)
				out.append({"origin": o, "relic": relic})
				break
	c.notes["nascondigli"] = out


## Tutta roccia (niente aria, niente stazioni): il nascondiglio resta chiuso.
func _solid_block(w: World, x0: int, y0: int, bw: int, bh: int) -> bool:
	for y in range(y0 - 1, y0 + bh + 1):
		for x in range(x0 - 1, x0 + bw + 1):
			if not w.solid(x, y):
				return false
	return true


func _far(w: World, q: Vector2i) -> bool:
	for o in w.stations:
		if Vector2(o - q).length() < 40.0:
			return false
	return true


func _build(w: World, p: Vector2i, st: int, relic: String, rng: RandomNumberGenerator) -> Vector2i:
	for y in range(p.y - 1, p.y + RH + 1):
		for x in range(p.x - 1, p.x + RW + 1):
			var i := y * w.w + x
			var shell := y == p.y - 1 or y == p.y + RH or x == p.x - 1 or x == p.x + RW
			w.tiles[i] = TileDefs.PIETRA_SEM if shell else TileDefs.AIR
			w.walls[i] = TileDefs.WALL_SEM
			w.decor[i] = 0
	for x in range(p.x + 1, p.x + RW - 1, 3):
		w.set_decor(x, p.y, TileDefs.DECOR_RUNE)
	var o := Vector2i(p.x + RW / 2 - 1, p.y + RH - int(StationsData.STATIONS["reliquiario"]["size"][1]))
	w.set_decor(o.x, o.y, 0)
	w.set_decor(o.x + 1, o.y, 0)
	w.stations[o] = "reliquiario"
	var chest := w.chest_at(o)
	chest.add(relic, 1)
	var loot := LootData.roll_chest("rovina_%d" % clampi(st, 1, 4), rng, 1)
	for id in loot:
		chest.add(id, int(loot[id]))
	return o
