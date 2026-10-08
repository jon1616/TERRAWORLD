class_name PassStrade
extends GenPass
## La strada del sottosuolo (voce 453, Roadmap 57 «Le profondità vere»): una via garantita dalla superficie al Fondo senza
## scavare. Da un ingresso a 250-450 colonne dalla partenza scende una galleria larga 3 che serpeggia (si sposta di lato
## almeno quanto scende: una pendenza che si cammina e si salta), incrociando le grotte che trova, fino al Fondo. Le
## pareti di fondo restano (è buia: la si percorre con le torce). Appunti "strada" [[x, y], ...] ogni 8 passi.
## Le scorciatoie (voragini, radici viandanti) le fanno altre passate. Le strutture costruite dopo (stanze, geodi,
## nascondigli) la chiudevano qua e là: `reopen`, chiamata da `PassStradeRiapri` quasi alla fine, la riscava, senza
## toccare le stazioni né le tessere speciali (sigilli, nodi, porte). Appunti "strada_linea": ogni passo.

const RADIUS := 1.6
const SPAWN_GAP := [250, 450]


func title() -> String:
	return "Strada del sottosuolo"


func run(w: World, c: GenContext) -> void:
	c.notes["strada"] = []
	if bool(c.params.get("giardino", false)):
		return
	var side := -1 if c.rng.randf() < 0.5 else 1
	var x := float(clampi(w.spawn.x + side * c.rng.randi_range(SPAWN_GAP[0], SPAWN_GAP[1]), 60, w.w - 60))
	var y := float(w.surface[int(x)] - 1)
	var goal := int(w.surface[int(x)]) + StrataData.top(4) + 20
	var dir := float(side)
	var n := c.noise("strada", 0.05, 2)
	var pts := []
	var line := []
	var k := 0
	var turn := c.rng.randi_range(60, 160)
	while y < goal and y < w.h - 12 and k < 6000:
		k += 1
		# ogni passo: avanti di lato di 1, giù di al più 1 (spesso meno): la pendenza resta percorribile
		x += dir
		y += clampf(0.6 + n.get_noise_1d(k * 1.3) * 0.9, 0.1, 1.0)
		if x < 30 or x > w.w - 30:
			dir = -dir                         # al bordo del mondo si torna indietro
			x += dir * 2.0
		elif k >= turn:
			dir = -dir                         # un tornante ogni 60-160 passi: la strada scende a zig-zag
			turn = k + c.rng.randi_range(60, 160)
		_carve(w, Vector2i(int(x), int(y)))
		line.append(Vector2i(int(x), int(y)))
		# attraverso una caverna la strada è un ponte di passerelle: sotto c'è il vuoto, e chi la segue ci cadrebbe
		var fy := int(y) + 2
		if w.inside(int(x), fy + 1) and not w.solid(int(x), fy) and not w.solid(int(x), fy + 1):
			w.set_plat(int(x), fy, true)
		if k % 8 == 0:
			pts.append([int(x), int(y)])
	c.notes["strada"] = pts
	c.notes["strada_linea"] = line


static func _carve(w: World, p: Vector2i) -> void:
	for dy in range(-int(RADIUS) - 1, int(RADIUS) + 1):
		for dx in range(-int(RADIUS), int(RADIUS) + 1):
			if Vector2(dx, dy).length() <= RADIUS + 0.4:
				var cx := p.x + dx
				var cy := p.y + dy
				if not w.inside(cx, cy) or cy <= w.surface[clampi(cx, 0, w.w - 1)] - 2:
					continue
				var t := w.tile(cx, cy)
				if t == TileDefs.AIR or t == TileDefs.NODO or t == TileDefs.PORTA or t == TileDefs.PORTA_SEM \
						or t in TileDefs.SEALS.values() or not w.station_at(Vector2i(cx, cy)).is_empty():
					continue
				w.set_tile(cx, cy, TileDefs.AIR)


## Riscava la strada dove le strutture costruite dopo l'hanno chiusa (vedi sopra).
static func reopen(w: World, c: GenContext) -> void:
	for p in c.notes.get("strada_linea", []):
		_carve(w, p)
