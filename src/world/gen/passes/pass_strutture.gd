class_name PassStrutture
extends GenPass
## Le strutture dei biomi (Roadmap 45, voce 394; disegni nel pacchetto `src/data/vastita/strutture.gd`, uniti a
## `PlacesData`): al più `PER_WORLD` per mondo, del grado del mondo (vigori 1-3, 4-6, 7-9, 10 e oltre) e dei biomi
## che ci sono: in superficie nel loro bioma (villaggi, templi), sotto terra sotto il loro bioma (nidi, fucine), nel
## sottosuolo dove c'è il loro bioma, nel cielo nella loro zona (navi). Si costruiscono come i luoghi
## (`PassLuoghi.build`); lo scrigno riceve in più gli oggetti della cassa del bioma e un'arma firma della fase.
## Appunti: `notes["strutture"]` (come i luoghi: li legge `Places`, gli enigmi `Mechanisms`).

const PER_WORLD := 4


func title() -> String:
	return "Strutture"


func run(w: World, c: GenContext) -> void:
	c.notes["strutture"] = []
	if bool(c.params.get("giardino", false)):
		return
	var vigor := int(c.params.get("vigore", 1))
	var tier := clampi((vigor - 1) / 3, 0, 3)
	var cand := []
	for id in PlacesData.PLACES:
		var pd: Dictionary = PlacesData.PLACES[id]
		if pd.get("struttura", false) and int(pd["tier"]) == tier:
			cand.append(String(id))
	cand.sort()
	for i in range(cand.size() - 1, 0, -1):          # mescolati con il caso del mondo
		var j := c.rng.randi_range(0, i)
		var t: String = cand[i]
		cand[i] = cand[j]
		cand[j] = t
	var out := []
	for id in cand:
		if out.size() >= PER_WORLD:
			break
		var o := _find(w, c, String(id))
		if o.x < 0:
			continue
		var e := PassLuoghi.build(w, String(id), o, c.rng)
		_treasure(w, c, e, vigor)
		out.append(e)
	c.notes["strutture"] = out


## Dove mettere una struttura: nel suo bioma, nel suo posto (superficie, sotto terra, sottosuolo, cielo).
func _find(w: World, c: GenContext, id: String) -> Vector2i:
	var pd: Dictionary = PlacesData.PLACES[id]
	var grid := PlacesData.grid(id)
	var gw: int = (grid[0] as String).length()
	var gh := grid.size()
	var b := String(pd["biome"])
	var where := String(pd["where"])
	var cuore: Vector2i = c.notes.get("cuore", Vector2i(-9999, -9999))
	for k in 160:
		var x := c.rng.randi_range(40, w.w - 40 - gw)
		if absi(x + gw / 2 - w.w / 2) < 110:
			continue
		var y := 0
		if where == "cielo":
			var z := SkyData.zone_of(w, x + gw / 2)
			# voce 445: anche la fascia di mezzo (prima solo basso e alto: le strutture dei biomi medi non nascevano mai)
			if z.is_empty() or not b in [String(z["low"]), String(z.get("mid", "")), String(z["high"])]:
				continue
			y = c.rng.randi_range(SkyData.TOP + 4, maxi(int(z["base"]) - gh - 6, SkyData.TOP + 5))
			if SkyData.zone_at(w, x + gw / 2, y + gh / 2) != b:
				continue
		elif where == "sotto":
			var st := c.rng.randi_range(1, 4)
			var top := w.surface[x] + StrataData.top(st) + 4
			var bot := w.surface[x] + (StrataData.top(st + 1) if st + 1 < StrataData.STRATA.size() else w.h) - gh - 4
			if bot <= top or bot >= w.h - gh - 4:
				continue
			y = c.rng.randi_range(top, bot)
			if ChestsData.biome_at(w, Vector2i(x + gw / 2, y + gh / 2), st) != b:
				continue
		else:
			if String(BiomesData.BIOMES[BiomesData.at(w, x)]["id"]) != b or String(BiomesData.BIOMES[BiomesData.at(w, x + gw - 1)]["id"]) != b:
				continue
			if pd.get("surface", false):
				y = w.surface[x + gw / 2] - (gh - 1)
			else:
				var st: Array = pd["strata"]
				var t0 := StrataData.top(int(st[0]))
				var t1 := StrataData.top(int(st[1]) + 1) if int(st[1]) + 1 < StrataData.STRATA.size() else w.h - w.surface[x] - gh - 10
				y = w.surface[x] + c.rng.randi_range(t0 + 4, maxi(t1 - gh - 4, t0 + 5))
		if y < 4 or y + gh + 2 >= w.h:
			continue
		var area := Rect2i(x - 2, y - 2, gw + 4, gh + 4)
		if Vector2(Vector2i(x + gw / 2, y) - cuore).length() < 80.0 or _busy(w, area) or not c.is_free(area):
			continue
		c.claim(area, "struttura")
		return Vector2i(x, y)
	return Vector2i(-1, -1)


func _busy(w: World, r: Rect2i) -> bool:
	for o in w.stations:
		if r.has_point(o):
			return true
	return false


## Il tesoro: gli oggetti della cassa del bioma e un'arma firma della fase del posto.
func _treasure(w: World, c: GenContext, e: Dictionary, vigor: int) -> void:
	var b := String(PlacesData.PLACES[String(e["id"])]["biome"])
	var rect := Rect2i(int(e["x"]), int(e["y"]), int(e["w"]), int(e["h"]))
	for o in w.stations.keys():
		if String(w.stations[o]) != "scrigno" or not rect.has_point(o):
			continue
		var chest := w.chest_at(o)
		var bl := LootData.roll("cassa_" + b, c.rng)
		for id in bl:
			chest.add(String(id), int(bl[id]))
		var st := clampi(StrataData.at(w, o.x, o.y), 0, 4)
		for id in LootData.roll("firma_f%d" % SpineData.zone_phase(vigor, st), c.rng):
			chest.add(String(id), 1)
