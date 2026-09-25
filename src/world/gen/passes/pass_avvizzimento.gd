class_name PassAvvizzimento
extends GenPass
## Le prime macchie dell'Avvizzimento (voce 18): due zone malate in superficie, lontane dalla partenza, che scendono per
## qualche decina di tessere con i bordi sfrangiati. Da qui l'Avvizzimento si allargherà durante il gioco (`Blight`),
## finché il Guardiano del mondo dorme.

const ZONES := 2
const MIN_FROM_SPAWN := 350
const RX := 40
const RY := 38


func title() -> String:
	return "Avvizzimento"


func run(w: World, c: GenContext) -> void:
	var rng := c.rng
	var n_edge := c.noise("avvizzimento", 0.09, 2)
	var placed: Array[int] = []
	var tries := 0
	while placed.size() < ZONES and tries < 50:
		tries += 1
		var side := 1 if rng.randf() < 0.5 else -1
		var cx := w.spawn.x + side * rng.randi_range(MIN_FROM_SPAWN, MIN_FROM_SPAWN + 700)
		if cx < RX + 5 or cx > w.w - RX - 5:
			continue
		var far := true
		for p in placed:
			if absi(p - cx) < RX * 5:
				far = false
		if not far:
			continue
		placed.append(cx)
		var cy := w.surface[cx] + 8
		for y in range(maxi(cy - RY, 0), mini(cy + RY, w.h)):
			for x in range(cx - RX, cx + RX + 1):
				var e := Vector2((x - cx) / float(RX), (y - cy) / float(RY)).length()
				if e + n_edge.get_noise_2d(x, y) * 0.35 > 1.0:
					continue
				var b := TileDefs.blighted_of(w.tile(x, y))
				if b >= 0:
					w.set_tile(x, y, b)
					var d := w.decor_at(x, y - 1)
					if d != 0 and not d in TileDefs.DECOR_CEILING:
						w.set_decor(x, y - 1, 0)
	c.notes["avvizzimento"] = placed
