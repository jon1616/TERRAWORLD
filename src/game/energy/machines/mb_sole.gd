class_name MbSole
extends MachineBehavior
## La Foglia-lanterna: dà pulsi con la luce del giorno che le cade sopra. Di notte niente; sotto un tetto (un blocco
## nelle `ROOF` tessere sopra) niente; con la pioggia o la nebbia metà; nel cielo il 50% in più.

const ROOF := 12
const SKY := 1.5


func produce(mc: Machine, e: Energy) -> float:
	var w: World = e.m.world
	for x in range(mc.o.x, mc.o.x + mc.size().x):
		for y in range(mc.o.y - ROOF, mc.o.y):
			if w.solid(x, y):
				return 0.0
	var k: float = e.m.day.daylight()
	if e.m.get("weather") != null and String(e.m.weather.id) in ["pioggia", "temporale", "nebbia", "cenere", "bufera"]:
		k *= 0.5
	if SkyData.zone_at(w, mc.o.x, mc.o.y) != "":
		k *= SKY
	return float(mc.d["pulsi"]) * k * (1.0 + float(e.gene.get("linfa_sole", 0.0)))   # voce 207: «Sole di Linfa»
