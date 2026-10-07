class_name PassSpine
extends GenPass
## Roadmap 52, voce 418: le spine dei biomi e le ragnatele (`TileDefs.THORNS`, dal pacchetto `terre.gd`). Ogni spina
## nasce sui pavimenti del suo bioma, all'aperto e nelle grotte fino a `DEPTH` tessere sotto la superficie, a cespugli di
## una-tre celle; le ragnatele negli angoli sotto il soffitto delle grotte del Sottobosco e delle Caverne d'ardesia.
## Chi le tocca lo decide `Hazards`. Viene dopo i Pericoli: si mette dove c'è posto. (Niente `station_at` nei cicli: nel
## generatore è lineare; le stazioni coprono comunque la decorazione dietro di sé.)

const DEPTH := 60
const CHANCE := 0.035                  # su un pavimento libero del bioma
const WEB_TRIES := 12000
const WEB_WANT := 260
const WEB_STRATA := [1, 2]


func title() -> String:
	return "Spine e ragnatele"


func run(w: World, c: GenContext) -> void:
	var rng := c.rng
	var by_biome := {}
	var web := 0
	for d in TileDefs.THORNS:
		var bl: Array = TileDefs.THORNS[d]["biomes"]
		if bl.is_empty():
			web = int(d)
		for b in bl:
			by_biome[BiomesData.index_of(String(b))] = int(d)
	var placed := 0
	for x in range(1, w.w - 4):
		var bi := int(w.biomes[x])
		if not by_biome.has(bi):
			continue
		var d: int = by_biome[bi]
		for y in range(maxi(w.surface[x] - 2, 1), mini(w.surface[x] + DEPTH, w.h - 1)):
			if w.solid(x, y) or not w.solid(x, y + 1) or w.decor_at(x, y) != 0 or w.liq(x, y) > 0 or w.plat(x, y) \
					or w.tree_at(Vector2i(x, y)).x >= 0:
				continue
			if rng.randf() >= CHANCE:
				continue
			for dx in rng.randi_range(1, 3):
				var q := Vector2i(x + dx, y)
				if not w.solid(q.x, q.y) and w.solid(q.x, q.y + 1) and w.decor_at(q.x, q.y) == 0 and w.liq(q.x, q.y) == 0 \
						and w.tree_at(q).x < 0:
					w.set_decor(q.x, q.y, d)
					placed += 1
	var webs := 0
	if web > 0:
		for _k in WEB_TRIES:
			if webs >= WEB_WANT:
				break
			var x := rng.randi_range(4, w.w - 5)
			var st := int(WEB_STRATA[rng.randi_range(0, WEB_STRATA.size() - 1)])
			var y := w.surface[x] + rng.randi_range(StrataData.top(st), StrataData.top(st + 1))
			if not w.inside(x, y) or w.solid(x, y):
				continue
			while w.inside(x, y - 1) and not w.solid(x, y - 1):
				y -= 1                             # fino al soffitto
			if not w.solid(x, y - 1) or w.wall(x, y) == 0 or w.decor_at(x, y) != 0 or w.liq(x, y) > 0:
				continue
			if not w.solid(x - 1, y):
				continue                           # un angolo: soffitto sopra e parete a sinistra
			w.set_decor(x, y, web)
			webs += 1
	c.notes["spine"] = [placed, webs]
