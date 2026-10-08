class_name PassStrade
extends GenPass
## La strada del sottosuolo (voce 453, Roadmap 57 «Le profondità vere»): una via garantita dalla superficie al Fondo senza
## scavare. Da un ingresso a 250-450 colonne dalla partenza scende una galleria larga 3 che serpeggia (si sposta di lato
## almeno quanto scende: una pendenza che si cammina e si salta), incrociando le grotte che trova, fino al Fondo. Le
## pareti di fondo restano (è buia: la si percorre con le torce). Appunti "strada" [[x, y], ...] ogni 8 passi.
## Le scorciatoie (voragini, radici viandanti) le fanno altre passate.

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
		for dy in range(-int(RADIUS) - 1, int(RADIUS) + 1):
			for dx in range(-int(RADIUS), int(RADIUS) + 1):
				if Vector2(dx, dy).length() <= RADIUS + 0.4:
					var cx := int(x) + dx
					var cy := int(y) + dy
					if w.inside(cx, cy) and cy > w.surface[clampi(cx, 0, w.w - 1)] - 2 and w.tile(cx, cy) != TileDefs.NODO:
						w.set_tile(cx, cy, TileDefs.AIR)
		if k % 8 == 0:
			pts.append([int(x), int(y)])
	c.notes["strada"] = pts
