class_name MbRuotaMandria
extends MachineBehavior
## La Ruota della mandria: le creature della mandria che ci corrono dentro la fanno girare: 15 pulsi più 5 per ogni
## livello oltre il primo (la scheda della creatura, `rec.lvl`), fino ai pulsi dei dati. Una creatura affamata
## (`rec.fame` oltre `HUNGRY`) non corre. Messa nel recinto, le creature ci passano spesso.

const BASE := 15.0
const PER_LVL := 5.0
const HUNGRY := 0.85
const SPEED := 20.0


func produce(mc: Machine, e: Energy) -> float:
	var r := Rect2(Vector2(mc.o) * 16.0, Vector2(mc.size()) * 16.0).grow(2.0)
	var sum := 0.0
	for c in e.m.fauna.list:
		if c.tame == null or not r.has_point(c.position) or absf(c.vel.x) < SPEED:
			continue
		var rec: Dictionary = c.tame.rec
		if float(rec.get("fame", 0.0)) > HUNGRY:
			continue
		sum += BASE + PER_LVL * (int(rec.get("lvl", 1)) - 1)
	return minf(sum, float(mc.d["pulsi"]))


func state_text(mc: Machine, e: Energy) -> String:
	if mc.made <= 0.0:
		return "ferma: nessuna creatura della mandria ci corre dentro"
	return super.state_text(mc, e)
