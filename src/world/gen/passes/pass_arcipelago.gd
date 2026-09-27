class_name PassArcipelago
extends GenPass
## L'Arcipelago (voce 76, gene di forma): la superficie si spezza in pilastri di terra separati da voragini profonde,
## con l'acqua sul fondo (la mette `PassAcqua`), isole sospese a mezz'aria (`PassIsole`) e una corrente ascensionale in
## ogni voragine che riporta su chi ci cade. La partenza resta su un pilastro. Negli appunti: "abissi" [x0, x1, profondità]
## e "correnti" [{x, w, y0, y1}] (le legge `Gravity`).

const EDGE := 7.0                      # tessere di pendio ai bordi di una voragine


func title() -> String:
	return "Arcipelago"


func run(w: World, c: GenContext) -> void:
	if not c.genes().get("archi", false):
		return
	var chasms := []
	var currents := []
	var x := c.rng.randi_range(30, 70)
	var pillar := true
	while x < w.w - 60:
		var wd := c.rng.randi_range(45, 100) if pillar else c.rng.randi_range(70, 130)
		var x1 := mini(x + wd, w.w - 40)
		if not pillar and (x1 < w.spawn.x - 45 or x > w.spawn.x + 45):
			var depth := c.rng.randi_range(34, 48)
			for xx in range(x, x1):
				var t := clampf(minf(xx - x, x1 - 1 - xx) / EDGE, 0.0, 1.0)
				w.surface[xx] += int(depth * t * t * (3.0 - 2.0 * t))
			chasms.append([x, x1, depth])
			var cx := (x + x1) / 2
			currents.append({"x": cx, "w": 1, "y0": w.surface[cx] - depth - 24, "y1": w.surface[cx] - 1})
		x = x1
		pillar = not pillar
	c.notes["abissi"] = chasms
	c.notes["correnti"] = currents
