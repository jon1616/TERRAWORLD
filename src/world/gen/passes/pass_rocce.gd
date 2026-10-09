class_name PassRocce
extends GenPass
## Le forme di roccia della superficie (voce 465, Roadmap 60): sulle tessere, dopo le Decorazioni e le Liane (che
## riscrivono ogni cella d'aria: le liane messe prima sparivano).
## - **liane sulle pareti**: ogni parete più alta del salto (4+ righe tra una colonna e l'altra) ha una liana dalla cima al
##   piede, così la superficie si percorre sempre senza scavare (la regola del piano: niente pareti senza un passaggio);
##   anche le alzate del canyon e il fianco sinistro dei pilastri (voce 459);
## - **archi**: sotto le creste strette e alte (una colonna più alta di 10+ righe di quelle a 16 colonne di distanza)
##   un foro ellittico lascia sopra un ponte di roccia di 4-6 righe (`ARCHES` per mondo);
## - **sporgenze**: in cima alle pareti di 7+ righe la roccia sporge di 3-6 colonne sul vuoto, spessa 2-3.
## Lontano dalla partenza, mai sopra le stazioni. Appunti "archi", "sporgenze".

const LIANA := 99
const ARCHES := 3


func title() -> String:
	return "Rocce"


func run(w: World, c: GenContext) -> void:
	c.notes["archi"] = []
	c.notes["sporgenze"] = 0
	if bool(c.params.get("giardino", false)):
		return
	_arches(w, c)
	_overhangs(w, c)
	_wall_vines(w)
	_pillar_vines(w, c)
	for v in c.notes.get("liane_ingressi", []):          # voce 467: le doline e i pozzi
		for y in range(int(v[1]), int(v[2])):
			if not w.solid(int(v[0]), y) and w.decor_at(int(v[0]), y) == 0 and w.liq(int(v[0]), y) == 0:
				w.set_decor(int(v[0]), y, LIANA)


func _arches(w: World, c: GenContext) -> void:
	var made := []
	for x in range(40, w.w - 40, 3):
		if made.size() >= ARCHES:
			break
		if absi(x - w.spawn.x) < 60:
			continue
		var s := int(w.surface[x])
		var l := int(w.surface[x - 16])
		var r := int(w.surface[x + 16])
		if mini(l, r) - s < 10 or (made.size() > 0 and absi(int(made.back()[0]) - x) < 200):
			continue
		if c.rng.randf() > 0.5:
			continue
		var bridge := c.rng.randi_range(4, 6)
		var hy := s + bridge + 5
		var rx := 7
		var ry := 4
		if not c.is_free(Rect2i(x - rx - 1, s, 2 * rx + 3, bridge + 12)):
			continue
		for dy in range(-ry, ry + 1):
			for dx in range(-rx, rx + 1):
				var q := Vector2i(x + dx, hy + dy)
				if Vector2(float(dx) / rx, float(dy) / ry).length() <= 1.0 and w.station_at(q).is_empty():
					w.set_tile(q.x, q.y, TileDefs.AIR)
					w.walls[q.y * w.w + q.x] = 0
		made.append([x, hy])
	c.notes["archi"] = made


func _overhangs(w: World, c: GenContext) -> void:
	var n := 0
	for x in range(30, w.w - 30):
		if absi(x - w.spawn.x) < 40:
			continue
		for side in [-1, 1]:
			var s := int(w.surface[x])
			var low := int(w.surface[x + side])
			if low - s < 7 or c.rng.randf() > 0.3:
				continue
			var len := c.rng.randi_range(3, 6)
			var thick := c.rng.randi_range(2, 3)
			var ok := true
			for k in range(1, len + 1):
				var xx: int = x + side * k
				if int(w.surface[clampi(xx, 0, w.w - 1)]) - s < thick + 3:
					ok = false
			if not ok:
				continue
			PassTracce._clear_trees(w, mini(x + side, x + side * len), maxi(x + side, x + side * len) + 1)
			var rock: int = w.tile(x, s + 2) if w.solid(x, s + 2) else TileDefs.STONE
			for k in range(1, len + 1):
				var xx: int = x + side * k
				for dy in thick:
					if w.station_at(Vector2i(xx, s + dy)).is_empty():
						w.set_tile(xx, s + dy, w.tile(x, s) if dy == 0 else rock)
				w.surface[xx] = s
			n += 1
	c.notes["sporgenze"] = n


## Una liana su ogni parete più alta del salto, dalla cima al piede, nella colonna d'aria accanto alla parete.
## (voce 471) La terra vera di ogni colonna, non `World.surface`: gli imbocchi delle gallerie e le bocche delle caverne sul
## fianco scavano la cima del terreno senza cambiarla, e una buca di 5 righe restava senza liana (la ricerca di percorso
## lo ha trovato: metà del mondo non si raggiungeva a piedi).
## (Una liana nella colonna di una corrente non ferma più la salita: dentro una corrente, tenendo il salto, vince la
## corrente, `Player._step`.)
static func _wall_vines(w: World) -> void:
	var g := PackedInt32Array()
	g.resize(w.w)
	for x in w.w:
		# dalla superficie: se lì c'è aria si scende fino alla terra (buche, imbocchi); se c'è roccia si sale finché
		# continua (meraviglie, guglie, colonne costruite sopra la terra: le isole del cielo, staccate, restano fuori)
		var y := int(w.surface[x])
		if not w.solid(x, y):
			while y < mini(int(w.surface[x]) + 60, w.h - 1) and not w.solid(x, y):
				y += 1
		else:
			while y > maxi(int(w.surface[x]) - 160, 1) and w.solid(x, y - 1):
				y -= 1
		g[x] = y
	for x in range(1, w.w - 1):
		for dx in [-1, 1]:
			var hi := g[x + dx]
			var lo := g[x]
			if lo - hi < 4:
				continue
			var y := hi
			while y < lo:
				if w.solid(x, y):
					# (voce 474) una sporgenza corta che taglia la liana si apre: chi sale non le gira intorno (nel mondo di
					# prova una mensola di 3 tessere a metà di una parete di 36 righe chiudeva un terzo del mondo)
					var run := 0
					while y + run < lo and w.solid(x, y + run):
						run += 1
					if run > 4 or y + run >= lo or not _can_open(w, x, y, run):
						y += maxi(run, 1)
						continue
					for k in run:
						w.set_tile(x, y + k, TileDefs.AIR)
				if (w.decor_at(x, y) == 0 or TileDefs.is_soft_decor(w.decor_at(x, y))) and w.liq(x, y) == 0:
					w.set_decor(x, y, LIANA)
				y += 1


static func _can_open(w: World, x: int, y: int, run: int) -> bool:
	for k in run:
		var t := w.tile(x, y + k)
		if t == TileDefs.NODO or t == TileDefs.PORTA or t == TileDefs.PORTA_SEM or t == TileDefs.PIETRA_SEM \
				or t in TileDefs.SEALS.values() or not w.station_at(Vector2i(x, y + k)).is_empty():
			return false
	return true


## La tenda di liane sul fianco sinistro di ogni pilastro, dalla cima a terra.
static func _pillar_vines(w: World, c: GenContext) -> void:
	for p in c.notes.get("pilastri", []):
		var vx := int(p[0]) - 1
		for yy in range(int(p[2]) + 1, int(w.surface[vx])):
			if w.inside(vx, yy) and not w.solid(vx, yy) and w.decor_at(vx, yy) == 0:
				w.set_decor(vx, yy, LIANA)
