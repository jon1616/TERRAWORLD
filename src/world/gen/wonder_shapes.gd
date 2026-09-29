class_name WonderShapes
extends RefCounted
## Le forme delle meraviglie (Roadmap 23, voce 237), chiamate da `PassMeraviglie`. `build(id, mondo, centro, caso)` scava
## e riempie, e restituisce l'angolo in alto a sinistra del cuore (2×2, appoggiato a un pavimento) o (-1, -1) se la forma
## non riesce. `SIZE` = metà larghezza e metà altezza del posto che occupa (per `GenContext.is_free`/`claim`); per le
## meraviglie di superficie il centro è sulla superficie.

const SIZE := {
	"arco_pietra": Vector2i(18, 28), "cratere_stella": Vector2i(24, 14), "ponte_giganti": Vector2i(22, 46),
	"pozzo_abisso": Vector2i(8, 260), "radice_cosmo": Vector2i(28, 105), "albero_fossile": Vector2i(20, 22),
	"scheletro_gigante": Vector2i(34, 14), "foresta_cristallo": Vector2i(26, 12), "lago_nascosto": Vector2i(30, 13),
	"coppa_linfa": Vector2i(20, 16), "geode_gigante": Vector2i(18, 18), "occhio_brace": Vector2i(18, 14),
}


static func build(k: String, w: World, ctr: Vector2i, rng: RandomNumberGenerator) -> Vector2i:
	_clear_trees(w, Rect2i(ctr - SIZE[k], SIZE[k] * 2 + Vector2i.ONE))
	var shapes := WonderShapes.new()
	return shapes.call("_b_" + k, w, ctr, rng)


# ---------------------------------------------------------------- attrezzi

static func _clear_trees(w: World, r: Rect2i) -> void:
	for cx in range(floori(r.position.x / 32.0) - 1, floori(r.end.x / 32.0) + 2):
		for cy in range(floori(r.position.y / 32.0) - 1, floori(r.end.y / 32.0) + 2):
			var list: Array = w.trees.get(Vector2i(cx, cy), [])
			for t in list.duplicate():
				if r.has_point(Vector2i(t.x, t.y)):
					list.erase(t)


static func _put(w: World, x: int, y: int, t: int) -> void:
	if not w.inside(x, y):
		return
	var i := y * w.w + x
	w.tiles[i] = t
	w.liquid[i] = 0
	if t != TileDefs.AIR:
		w.decor[i] = 0


static func _air(w: World, x: int, y: int, wall: int) -> void:
	if not w.inside(x, y):
		return
	var i := y * w.w + x
	w.tiles[i] = TileDefs.AIR
	w.decor[i] = 0
	w.liquid[i] = 0
	if wall >= 0:
		w.walls[i] = wall


static func _ellipse(w: World, ctr: Vector2i, rx: float, ry: float, wall: int, rng: RandomNumberGenerator, rough := 0.08) -> void:
	for y in range(ctr.y - int(ry) - 1, ctr.y + int(ry) + 2):
		for x in range(ctr.x - int(rx) - 1, ctr.x + int(rx) + 2):
			var d := pow((x - ctr.x) / rx, 2.0) + pow((y - ctr.y) / ry, 2.0)
			if d <= 1.0 - rng.randf() * rough:
				_air(w, x, y, wall)


static func _liquid(w: World, x: int, y: int, type: int) -> void:
	if w.inside(x, y) and w.tile(x, y) == TileDefs.AIR:
		w.set_liq(x, y, 8, type)


## Il cuore su un pavimento vicino a (x, y): scende lungo la colonna x fino alla terra, completa il pavimento sotto la
## seconda colonna e lascia 2×2 d'aria sopra.
static func _heart(w: World, x: int, y: int) -> Vector2i:
	for dy in 60:
		var fy := y + dy
		if w.solid(x, fy) and not w.solid(x, fy - 1):
			if not w.solid(x + 1, fy):
				_put(w, x + 1, fy, w.tile(x, fy))
			for yy in range(fy - 2, fy):
				for xx in range(x, x + 2):
					_air(w, xx, yy, -1)
			return Vector2i(x, fy - 2)
	return Vector2i(-1, -1)


## Sotto terra una meraviglia nasce solo nella roccia piena (non sospesa nei grandi vuoti): almeno `frac` di celle solide.
static func solid_enough(w: World, r: Rect2i, frac := 0.6) -> bool:
	var n := 0
	var tot := 0
	for y in range(r.position.y, r.end.y, 3):
		for x in range(r.position.x, r.end.x, 3):
			tot += 1
			if w.solid(x, y):
				n += 1
	return n >= tot * frac


static func _rock(w: World, ctr: Vector2i) -> int:
	return int(StrataData.STRATA[StrataData.at(w, ctr.x, ctr.y)]["rock"])


static func _wall(w: World, ctr: Vector2i) -> int:
	return int(StrataData.STRATA[StrataData.at(w, ctr.x, ctr.y)]["wall"])


# ---------------------------------------------------------------- di superficie

## Due gambe d'ardesia e un arco sopra, a cavallo della superficie.
static func _b_arco_pietra(w: World, ctr: Vector2i, _rng: RandomNumberGenerator) -> Vector2i:
	var top := ctr.y - 16
	for side in [-1, 1]:
		for dx in range(10, 14):
			var x: int = ctr.x + side * dx
			for y in range(top, w.surface[x] + 3):
				_put(w, x, y, TileDefs.STONE)
	for y in range(top - 14, top + 1):
		for x in range(ctr.x - 14, ctr.x + 15):
			var d := Vector2(x - ctr.x, (y - top) * 1.1).length()
			if d >= 10.0 and d <= 13.8:
				_put(w, x, y, TileDefs.STONE)
	for x in range(ctr.x - 9, ctr.x + 10):
		if not w.solid(x, w.surface[x] - 1):
			w.set_decor(x, w.surface[x] - 1, TileDefs.DECOR_FLOWERS[absi(x) % 3])
	return _heart(w, ctr.x - 1, ctr.y - 8)


## Una conca tonda con il fondo di cristallo.
static func _b_cratere_stella(w: World, ctr: Vector2i, rng: RandomNumberGenerator) -> Vector2i:
	var c := Vector2i(ctr.x, ctr.y - 2)
	for y in range(c.y - 14, c.y + 12):
		for x in range(ctr.x - 23, ctr.x + 24):
			var d := pow((x - c.x) / 21.0, 2.0) + pow((y - c.y) / 10.0, 2.0)
			if d <= 1.0:
				_air(w, x, y, -1)
			elif d <= 1.25 and y > c.y - 2:
				_put(w, x, y, TileDefs.CRYSTAL if rng.randf() < 0.75 else TileDefs.STONE)
	for x in range(ctr.x - 12, ctr.x + 13):
		for y in range(c.y, c.y + 12):
			if w.solid(x, y + 1) and not w.solid(x, y):
				if rng.randf() < 0.3:
					w.set_decor(x, y, TileDefs.DECOR_SHARD)
				break
	return _heart(w, ctr.x - 1, c.y)


## Una voragine stretta e profonda, con una lingua di roccia che la attraversa.
static func _b_ponte_giganti(w: World, ctr: Vector2i, rng: RandomNumberGenerator) -> Vector2i:
	var wall := int(StrataData.STRATA[1]["wall"])
	for x in range(ctr.x - 16, ctr.x + 17):
		var half := 16.0 - absf(x - ctr.x) * 0.25
		for y in range(w.surface[x] - 2, ctr.y + int(half * 2.6) + rng.randi_range(0, 3)):
			_air(w, x, y, wall if y > w.surface[x] + 3 else -1)
	var by := ctr.y
	for x in range(ctr.x - 20, ctr.x + 21):
		for y in range(by, by + 3):
			_put(w, x, y, TileDefs.STONE)
	for x in range(ctr.x - 20, ctr.x + 21):
		for y in range(by + 3, by + 6 - int(absf(x - ctr.x) / 7.0)):
			_put(w, x, y, TileDefs.STONE)
	return _heart(w, ctr.x - 1, by - 4)


## Un pozzo dritto e largo cinque tessere, anelli di radice ogni venti righe, il cuore sul fondo.
static func _b_pozzo_abisso(w: World, ctr: Vector2i, _rng: RandomNumberGenerator) -> Vector2i:
	var bottom := mini(ctr.y + 240, w.h - 30)
	for y in range(ctr.y - 3, bottom):
		for x in range(ctr.x - 2, ctr.x + 3):
			_air(w, x, y, _wall(w, Vector2i(x, y)) if y > ctr.y + 3 else -1)
		if y > ctr.y + 10 and (y - ctr.y) % 20 == 0:
			for x in [ctr.x - 3, ctr.x + 3]:
				_put(w, x, y, TileDefs.RADICE)
				_put(w, x, y + 1, TileDefs.RADICE)
	for x in range(ctr.x - 5, ctr.x + 6):              # una stanza tonda sul fondo
		for y in range(bottom - 5, bottom):
			_air(w, x, y, _wall(w, Vector2i(x, y)))
		_put(w, x, bottom, TileDefs.CRYSTAL)
	return _heart(w, ctr.x - 1, bottom - 4)


## Una radice spessa che scende di sbieco dal cielo nel profondo, con una stanza alla punta.
static func _b_radice_cosmo(w: World, ctr: Vector2i, rng: RandomNumberGenerator) -> Vector2i:
	var dir := 1 if rng.randf() < 0.5 else -1
	var a := Vector2(ctr.x - dir * 22, ctr.y - 38)
	var b := Vector2(ctr.x + dir * 20, ctr.y + 92)
	var steps := int(a.distance_to(b))
	for s in steps:
		var p := a.lerp(b, float(s) / steps) + Vector2(sin(s * 0.07) * 4.0, 0)
		var th := 3.2 - 1.6 * float(s) / steps
		var under := int(p.y) > w.surface[clampi(int(p.x), 0, w.w - 1)] + 2
		for dy in range(-6, 7):
			for dx in range(-6, 7):
				var d := Vector2(dx, dy).length()
				var q := Vector2i(int(p.x) + dx, int(p.y) + dy)
				if d <= th:
					_put(w, q.x, q.y, TileDefs.RADICE)
				elif under and d <= th + 2.5 and w.inside(q.x, q.y) and w.tile(q.x, q.y) != TileDefs.RADICE:
					_air(w, q.x, q.y, _wall(w, q))          # sotto terra la radice corre in una galleria
	var tip := Vector2i(b) + Vector2i(0, 4)
	var wall := _wall(w, tip)
	for y in range(tip.y, tip.y + 6):
		for x in range(tip.x - 6, tip.x + 7):
			_air(w, x, y, wall)
	for x in range(tip.x - 6, tip.x + 7):
		_put(w, x, tip.y + 6, TileDefs.RADICE)
	return _heart(w, tip.x - 1, tip.y + 2)


# ---------------------------------------------------------------- sotto terra

## Una sala con un albero d'ambra in piedi, rami e baccelli.
static func _b_albero_fossile(w: World, ctr: Vector2i, rng: RandomNumberGenerator) -> Vector2i:
	var wall := _wall(w, ctr)
	_ellipse(w, ctr, 19.0, 18.0, wall, rng)
	var floor_y := ctr.y + 14
	for x in range(ctr.x - 19, ctr.x + 20):
		for y in range(floor_y, ctr.y + 19):
			if not w.solid(x, y):
				_put(w, x, y, _rock(w, ctr))
	for y in range(ctr.y - 10, floor_y):
		for x in range(ctr.x - 2, ctr.x + 2):
			_put(w, x, y, TileDefs.AMBRA)
	for br in [[-1, -6], [1, -2], [-1, 2], [1, 6]]:
		var y0: int = ctr.y + br[1]
		for s in 11:
			_put(w, ctr.x + br[0] * (2 + s), y0 - s / 2, TileDefs.AMBRA)
	for x in range(ctr.x - 10, ctr.x + 11):
		if rng.randf() < 0.35 and not w.solid(x, ctr.y - 11):
			w.set_decor(x, ctr.y - 11, TileDefs.DECOR_LINFA)
	return _heart(w, ctr.x + 5, floor_y - 3)


## Una sala lunga con le ossa di una bestia enorme: spina, costole, cranio.
static func _b_scheletro_gigante(w: World, ctr: Vector2i, rng: RandomNumberGenerator) -> Vector2i:
	var wall := _wall(w, ctr)
	_ellipse(w, ctr, 33.0, 12.0, wall, rng)
	var floor_y := ctr.y + 9
	for x in range(ctr.x - 33, ctr.x + 34):
		for y in range(floor_y, ctr.y + 13):
			if not w.solid(x, y):
				_put(w, x, y, _rock(w, ctr))
	var bone := TileDefs.PALLIDITE
	var spine_y := ctr.y - 3
	for x in range(ctr.x - 22, ctr.x + 16):
		_put(w, x, spine_y + int(sin((x - ctr.x) * 0.12) * 1.5), bone)
	for k in 7:
		var rx := ctr.x - 18 + k * 5
		for s in 11:
			var yy := spine_y + 1 + s
			if yy < floor_y:
				_put(w, rx + int(sin(s * 0.3) * 2.0), yy, bone)
	for y in range(spine_y - 4, spine_y + 4):                # il cranio
		for x in range(ctr.x + 16, ctr.x + 26):
			var d := Vector2((x - ctr.x - 21) / 5.0, (y - spine_y) / 4.0).length()
			if d <= 1.0 and d >= 0.55:
				_put(w, x, y, bone)
	return _heart(w, ctr.x + 20, spine_y - 1)


## Una sala larga piena di punte di cristallo dal pavimento e dal soffitto.
static func _b_foresta_cristallo(w: World, ctr: Vector2i, rng: RandomNumberGenerator) -> Vector2i:
	var wall := _wall(w, ctr)
	_ellipse(w, ctr, 25.0, 11.0, wall, rng)
	for x in range(ctr.x - 23, ctr.x + 24, 3):
		if absi(x - ctr.x) < 3:
			continue
		var fy := ctr.y
		while fy < ctr.y + 12 and not w.solid(x, fy + 1):
			fy += 1
		var h := rng.randi_range(3, 8)
		for s in h:                                         # dal pavimento, più larga alla base
			_put(w, x, fy - s, TileDefs.CRYSTAL)
			if s < h / 2:
				_put(w, x - 1, fy - s, TileDefs.CRYSTAL)
		for s in rng.randi_range(2, 6):                     # dal soffitto
			_put(w, x + 1, ctr.y - 10 + s, TileDefs.CRYSTAL)
	for x in range(ctr.x - 24, ctr.x + 25):
		if not w.solid(x, ctr.y + 11):
			_put(w, x, ctr.y + 11, TileDefs.CRYSTAL)
	return _heart(w, ctr.x - 1, ctr.y)


## Una caverna larga con un lago d'acqua ferma e una sponda asciutta.
static func _b_lago_nascosto(w: World, ctr: Vector2i, rng: RandomNumberGenerator) -> Vector2i:
	var wall := _wall(w, ctr)
	_ellipse(w, ctr, 29.0, 12.0, wall, rng, 0.04)
	var rock := _rock(w, ctr)
	for x in range(ctr.x - 30, ctr.x + 31):
		if not w.solid(x, ctr.y + 13):
			_put(w, x, ctr.y + 13, rock)
	for x in range(ctr.x - 22, ctr.x - 13):                 # la sponda
		for y in range(ctr.y + 3, ctr.y + 13):
			_put(w, x, y, rock)
	for x in range(ctr.x - 29, ctr.x + 30):
		for y in range(ctr.y + 3, ctr.y + 13):
			_liquid(w, x, y, LiquidsData.ACQUA)
	return _heart(w, ctr.x - 19, ctr.y - 2)


## Una caverna con una coppa di cristallo piena di Linfa, su un gambo.
static func _b_coppa_linfa(w: World, ctr: Vector2i, rng: RandomNumberGenerator) -> Vector2i:
	var wall := _wall(w, ctr)
	_ellipse(w, ctr, 19.0, 15.0, wall, rng)
	var floor_y := ctr.y + 12
	for x in range(ctr.x - 19, ctr.x + 20):
		for y in range(floor_y, ctr.y + 16):
			if not w.solid(x, y):
				_put(w, x, y, _rock(w, ctr))
	for y in range(ctr.y + 2, floor_y):                     # il gambo
		for x in range(ctr.x - 1, ctr.x + 2):
			_put(w, x, y, TileDefs.CRYSTAL)
	for x in range(ctr.x - 10, ctr.x + 11):                 # la coppa
		var y := ctr.y + 1 - int(pow(absf(x - ctr.x) / 10.0, 2.0) * 6.0)
		_put(w, x, y + 1, TileDefs.CRYSTAL)
		for yy in range(ctr.y - 5, y + 1):
			if absi(x - ctr.x) < 10:
				_liquid(w, x, yy, LiquidsData.LINFA)
	return _heart(w, ctr.x + 8, floor_y - 3)


## Una sfera cava: guscio di roccia, cristallo spesso, dentro vuoto con gemme.
static func _b_geode_gigante(w: World, ctr: Vector2i, rng: RandomNumberGenerator) -> Vector2i:
	var rock := _rock(w, ctr)
	var wall := _wall(w, ctr)
	for y in range(ctr.y - 17, ctr.y + 18):
		for x in range(ctr.x - 17, ctr.x + 18):
			var d := Vector2(x - ctr.x, y - ctr.y).length()
			if d > 16.5:
				continue
			if d > 15.0:
				_put(w, x, y, rock)
			elif d > 12.0 - rng.randf():
				_put(w, x, y, TileDefs.CRYSTAL)
			else:
				_air(w, x, y, wall)
	for x in range(ctr.x - 9, ctr.x + 10):
		for y in range(ctr.y, ctr.y + 13):
			if not w.solid(x, y) and w.solid(x, y + 1):
				if rng.randf() < 0.5:
					w.set_decor(x, y, TileDefs.DECOR_GEMS[rng.randi_range(0, 3)])
				break
	return _heart(w, ctr.x - 1, ctr.y + 4)


## Una sala tonda con un lago di brace al centro e una cengia per il cuore.
static func _b_occhio_brace(w: World, ctr: Vector2i, rng: RandomNumberGenerator) -> Vector2i:
	var wall := _wall(w, ctr)
	_ellipse(w, ctr, 17.0, 13.0, wall, rng)
	for x in range(ctr.x - 17, ctr.x + 18):
		for y in range(ctr.y + 5, ctr.y + 14):
			var d := Vector2((x - ctr.x) / 12.0, (y - ctr.y - 5) / 6.0).length()
			if d > 1.0 and not w.solid(x, y):
				_put(w, x, y, TileDefs.PIETRA_BRACE)
	for x in range(ctr.x - 11, ctr.x + 12):
		for y in range(ctr.y + 6, ctr.y + 11):
			_liquid(w, x, y, LiquidsData.BRACE)
	for x in range(ctr.x - 16, ctr.x - 11):                 # la cengia
		_put(w, x, ctr.y - 2, TileDefs.PIETRA_BRACE)
	return _heart(w, ctr.x - 15, ctr.y - 6)
