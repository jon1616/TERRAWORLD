class_name MbPompa
extends MachineBehavior
## La Pompa di radice: con i suoi pulsi beve il liquido sotto di sé (fino a `DEPTH` tessere) e lo versa dallo Sbocco di
## radice della stessa rete del Flusso (il primo trovato), nella tessera sotto lo sbocco. `RATE` livelli a ogni conto
## (8 livelli = una tessera piena). Si legge e si scrive il mondo: anche lontano dal Germogliato il liquido si sposta
## (i liquidi lontani restano fermi dove sono finché non ci si torna vicino).

const DEPTH := 3
const RATE := 4


func _source(mc: Machine, e: Energy) -> Vector2i:
	var w: World = e.m.world
	for dy in range(1, DEPTH + 1):
		for dx in mc.size().x:
			var c := Vector2i(mc.o.x + dx, mc.o.y + mc.size().y - 1 + dy)
			if w.liq(c.x, c.y) > 0:
				return c
			if w.solid(c.x, c.y):
				break
	return Vector2i(-1, -1)


func _outlet(mc: Machine, e: Energy) -> Machine:
	if mc.net < 0:
		return null
	for o: Machine in e.machines.values():
		if o.net == mc.net and String(o.d.get("bh", "")) == "sbocco":
			return o
	return null


func tick(mc: Machine, e: Energy, _dt: float) -> void:
	if not mc.on() or mc.power < 0.99:
		return
	var out := _outlet(mc, e)
	var src := _source(mc, e)
	if out == null or src.x < 0:
		return
	var w: World = e.m.world
	var dst := out.o + Vector2i(0, out.size().y)
	if w.solid(dst.x, dst.y) or w.liq(dst.x, dst.y) >= 8:
		return
	var typ := w.liq_type(src.x, src.y)
	if w.liq(dst.x, dst.y) > 0 and w.liq_type(dst.x, dst.y) != typ:
		return                                     # liquidi diversi non si mescolano nello sbocco
	var n := mini(mini(RATE, w.liq(src.x, src.y)), 8 - w.liq(dst.x, dst.y))
	w.set_liq(src.x, src.y, w.liq(src.x, src.y) - n, typ)
	w.set_liq(dst.x, dst.y, w.liq(dst.x, dst.y) + n, typ)
	mc.st["mosso"] = int(mc.st.get("mosso", 0)) + n
	if e.m.get("liquids") != null:
		e.m.liquids.wake(src.x, src.y)
		e.m.liquids.wake(dst.x, dst.y)
		e.m.liquids.view.touch(src)
		e.m.liquids.view.touch(dst)


func state_text(mc: Machine, e: Energy) -> String:
	if _outlet(mc, e) == null:
		return "ferma: nessuno Sbocco di radice sulla sua rete"
	if _source(mc, e).x < 0:
		return "ferma: niente liquido sotto di lei"
	return super.state_text(mc, e) + " · %d tessere di liquido spostate" % (int(mc.st.get("mosso", 0)) / 8)
