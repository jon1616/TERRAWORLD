class_name PassTerreno
extends GenPass
## Il profilo della superficie: colline grandi, pendii, piccole irregolarità. Spiana la zona di partenza.
## Geni di forma (voce 43): altezza della superficie, colline più o meno alte, rupi.


func title() -> String:
	return "Terreno"


func run(w: World, c: GenContext) -> void:
	var big := c.noise("colline", 0.0025, 3)
	var mid := c.noise("pendii", 0.012, 3)
	var small := c.noise("dettaglio", 0.06, 2)
	var jag := c.noise("rupi", 0.03, 3)
	var g := c.genes()
	c.params["surface_base"] = float(c.params["surface_base"]) + float(g["surface"])
	c.params["hills"] = float(c.params["hills"]) * float(g["hills"])
	var base := w.h * float(c.params["surface_base"])
	var hills: float = c.params["hills"]
	var rough := float(g["rough"]) * 3.0
	for x in w.w:
		w.surface[x] = int(base + big.get_noise_1d(x) * hills + mid.get_noise_1d(x) * 12.0 + small.get_noise_1d(x) * 2.0
			+ jag.get_noise_1d(x) * rough)
	w.spawn.x = w.w / 2
	var s := w.surface[w.spawn.x]
	for x in range(w.spawn.x - 7, w.spawn.x + 8):
		w.surface[x] = s
