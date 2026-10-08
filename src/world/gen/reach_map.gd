class_name ReachMap
extends RefCounted
## Dove si arriva senza scavare (voce 471, Roadmap 61 «Il collaudo del generatore»): una ricerca in ampiezza sui posti
## dove il Germogliato sta in piedi (due celle d'aria con sotto un appoggio: roccia, passerella, liquido o una liana),
## dalla partenza. Le mosse, prudenti rispetto a quelle vere: camminare e il gradino, il salto (3 su, fino a 4 di lato;
## 5 di lato in piano o in discesa), cadere, attraversare le passerelle, nuotare in su (fino a 9), salire e scendere
## lungo le liane e le corde (`TileDefs.CLIMB_SPEED`), le correnti d'aria degli appunti "correnti" (portano in cima).
## `dist` = i passi della ricerca (−1 = non si arriva). Lo usano `tools/connettivita.gd` e il collaudatore.

var w: World
var stand := PackedByteArray()
var dist := PackedInt32Array()
var reached := 0


static func of(world: World, currents: Array) -> ReachMap:
	var r := ReachMap.new()
	r.w = world
	r._stand()
	r._search(currents)
	return r


func at(x: int, y: int) -> int:
	if x < 0 or y < 0 or x >= w.w or y >= w.h:
		return -1
	return dist[y * w.w + x]


## Il passo più vicino a una cella entro `r` (per uno scrigno o un luogo: ci si arriva accanto), −1 se nessuno.
func near(c: Vector2i, r := 3) -> int:
	var best := -1
	for dy in range(-r, r + 1):
		for dx in range(-r, r + 1):
			var d := at(c.x + dx, c.y + dy)
			if d >= 0 and (best < 0 or d < best):
				best = d
	return best


func _stand() -> void:
	var ww := w.w
	var hh := w.h
	var n := ww * hh
	stand.resize(n)
	var tiles := w.tiles
	var liq := w.liquid
	var decor := w.decor
	var plats := w.plats
	var climb := TileDefs.CLIMB_SPEED
	var solid := PackedByteArray()
	solid.resize(256)
	solid.fill(1)
	solid[TileDefs.AIR] = 0                   # come `World.solid`: ogni tessera che non è aria
	for y in range(1, hh - 1):
		var row := y * ww
		for x in ww:
			var i := row + x
			if solid[tiles[i]] == 1 or solid[tiles[i - ww]] == 1:
				continue
			var d := decor[i]
			if solid[tiles[i + ww]] == 1 or (liq[i] & 15) > 0 or (d < climb.size() and climb[d] > 0.0) \
					or (i + ww < plats.size() and plats[i + ww] != 0):
				stand[i] = 1


func _search(currents: Array) -> void:
	var ww := w.w
	var hh := w.h
	dist.resize(ww * hh)
	dist.fill(-1)
	var q := PackedInt32Array()
	var start := _land(w.spawn.x, w.spawn.y)
	if start < 0:
		return
	dist[start] = 0
	q.append(start)
	var lifts := {}                           # colonna -> la riga in cima alla corrente
	for cu in currents:
		var d: Dictionary = cu
		for x in range(int(d["x"]) - int(d.get("w", 1)), int(d["x"]) + int(d.get("w", 1)) + 1):
			lifts[x] = [int(d["y0"]), int(d["y1"])]
	var liq := w.liquid
	var decor := w.decor
	var climb := TileDefs.CLIMB_SPEED
	var head := 0
	var nxt := PackedInt32Array()
	while head < q.size():
		var i := q[head]
		head += 1
		var x := i % ww
		var y := i / ww
		var dd := dist[i] + 1
		nxt.clear()
		# camminare, il gradino, il salto in su (3), i salti di lato e in discesa (5)
		for dy in range(-3, 4):
			var reach_x := 5 if dy < 0 else 6         # si corre a ~6 tessere al secondo
			for dx in range(-reach_x, reach_x + 1):
				if dx == 0 and dy == 0:
					continue
				var xx := x + dx
				var yy := y + dy
				if xx < 0 or xx >= ww or yy < 1 or yy >= hh - 1:
					continue
				if stand[yy * ww + xx] == 1:
					nxt.append(yy * ww + xx)
		# cadere da un lato, anche correndo oltre il bordo (fino a 4 colonne, con il passaggio libero all'altezza del corpo)
		for s in [-1, 1]:
			for k in range(1, 5):
				var xx: int = x + s * k
				if xx < 0 or xx >= ww or w.solid(xx, y) or w.solid(xx, y - 1):
					break
				var f := _fall(xx, y)
				if f >= 0:
					nxt.append(f)
		# le liane e le corde: su e giù di una cella; nuotare in su fino a 9; scendere da una passerella o nell'acqua
		var dc := decor[i]
		var climbing := dc < climb.size() and climb[dc] > 0.0
		var wet := (liq[i] & 15) > 0
		if climbing or wet:
			for k in range(1, 10 if wet else 2):
				var up := i - k * ww
				if up >= ww and stand[up] == 1:
					nxt.append(up)
		var below := _fall(x, y + 1)
		if below >= 0:
			nxt.append(below)
		# le correnti: dalla colonna della corrente alla sua cima
		if lifts.has(x):
			var lf: Array = lifts[x]
			if y >= int(lf[0]) - 2 and y <= int(lf[1]) + 2:
				for dx in range(-6, 7):
					for yy in range(int(lf[0]) - 3, int(lf[0]) + 3):
						var xx := x + dx
						if xx >= 0 and xx < ww and yy > 0 and stand[yy * ww + xx] == 1:
							nxt.append(yy * ww + xx)
		for j in nxt:
			if dist[j] < 0:
				dist[j] = dd
				q.append(j)
	reached = q.size()


## Il primo posto su cui si sta cadendo da (x, y) in giù (−1 se si esce o si è nella roccia).
func _fall(x: int, y: int) -> int:
	if x < 0 or x >= w.w or y < 1:
		return -1
	var yy := y
	while yy < w.h - 1:
		var i := yy * w.w + x
		if w.solid(x, yy):
			return -1
		if stand[i] == 1:
			return i
		yy += 1
	return -1


func _land(x: int, y: int) -> int:
	for yy in range(maxi(y - 4, 1), w.h - 1):
		if stand[yy * w.w + x] == 1:
			return yy * w.w + x
	return -1
