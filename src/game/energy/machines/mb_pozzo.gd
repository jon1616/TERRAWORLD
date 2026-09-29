class_name MbPozzo
extends MachineBehavior
## Il Pozzo di Linfa: posato sopra un lago di Linfa ne beve la Linfa. Conta le celle di Linfa liquida sotto di sé (fino a
## `DEPTH` tessere di profondità, un poco oltre i suoi lati): con `FULL` celle dà tutti i suoi pulsi, con meno meno.

const DEPTH := 6
const SIDE := 3
const FULL := 30


func produce(mc: Machine, e: Energy) -> float:
	var w: World = e.m.world
	var n := 0
	var y0 := mc.o.y + mc.size().y
	for y in range(y0, y0 + DEPTH):
		for x in range(mc.o.x - SIDE, mc.o.x + mc.size().x + SIDE):
			if w.liq(x, y) > 0 and w.liq_type(x, y) == LiquidsData.LINFA:
				n += 1
	return float(mc.d["pulsi"]) * minf(float(n) / FULL, 1.0)


func state_text(mc: Machine, e: Energy) -> String:
	if mc.made <= 0.0:
		return "a secco: va posato sopra un lago di Linfa"
	return super.state_text(mc, e)
