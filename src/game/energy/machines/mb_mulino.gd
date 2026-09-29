class_name MbMulino
extends MachineBehavior
## Il Mulino di semi: le pale girano con il vento del meteo (`Weather.wind`). Sempre un filo d'aria (`BREEZE`) all'aperto;
## più in alto sopra la superficie gira di più; nel cielo il 50% in più; sotto terra o sotto un tetto niente.

const WIND_FULL := 160.0               # px/s²: con questo vento le pale danno tutto
const BREEZE := 0.2
const HIGH := 40.0                     # tessere sopra la superficie per il massimo della quota (×1,6)


func produce(mc: Machine, e: Energy) -> float:
	var w: World = e.m.world
	var top := mc.o.y
	var cx := mc.o.x + mc.size().x / 2
	if StrataData.at(w, cx, top) > 0:
		return 0.0                            # sotto terra
	for x in range(mc.o.x, mc.o.x + mc.size().x):
		for y in range(top - 6, top):
			if w.solid(x, y):
				return 0.0                    # sotto un tetto
	var wind := 0.0
	if e.m.get("weather") != null:
		wind = absf(float(e.m.weather.wind))
	var k := clampf(wind / WIND_FULL, maxf(BREEZE, float(e.gene.get("linfa_vento", 0.0))), 1.0)   # voce 207: «Vento perenne»
	var above := float(int(w.surface[clampi(cx, 0, w.w - 1)]) - top)
	k *= 1.0 + clampf(above / HIGH, 0.0, 1.0) * 0.6
	if SkyData.zone_at(w, mc.o.x, mc.o.y) != "":
		k *= 1.5
	return minf(float(mc.d["pulsi"]) * k, float(mc.d["pulsi"]) * 1.5)
