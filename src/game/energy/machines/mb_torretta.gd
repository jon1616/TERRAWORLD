class_name MbTorretta
extends MachineBehavior
## La Torretta di spine: con i suoi pulsi tira i dardi della sua cassetta (i migliori, come l'arco: `Combat.AMMO`) alla
## creatura ostile più vicina che vede entro `RANGE` tessere, uno ogni `EVERY` secondi. Il danno è quello del dardo più
## `BASE`; ogni tiro costa `colpo` gocce. Ostile = selvatica e che ferisce (la mandria e le docili no).

const RANGE := 18.0
const EVERY := 0.8
const BASE := 8
const SPEED := 420.0


func _see(w: World, a: Vector2, b: Vector2) -> bool:
	var n := int(a.distance_to(b) / 8.0)
	for i in range(1, n):
		var p := a.lerp(b, float(i) / n)
		if w.solid(floori(p.x / 16.0), floori(p.y / 16.0)):
			return false
	return true


func frame(mc: Machine, e: Energy, dt: float) -> void:
	if not mc.on() or mc.power < 0.99:
		return
	var t := float(mc.get_meta("t", 0.0)) - dt
	if t > 0.0:
		mc.set_meta("t", t)
		return
	mc.set_meta("t", 0.2)                          # senza bersaglio si riguarda presto
	var eye := Vector2(mc.o) * 16.0 + Vector2(8, 6)
	var best: Creature = null
	for c in e.m.fauna.list:
		if not is_instance_valid(c) or c.tame != null or c.damage <= 0 or c.buried:
			continue
		var d: float = c.position.distance_to(eye)
		if d > RANGE * 16.0 or (best != null and d >= best.position.distance_to(eye)):
			continue
		if _see(e.m.world, eye, c.position):
			best = c
	if best == null:
		return
	var box: Bisaccia = e.m.world.chest_at(mc.o)
	var dart := ""
	for a in Combat.AMMO:
		if box.count(String(a)) > 0:
			dart = String(a)
			break
	if dart == "" or not e.spend(mc, float(mc.d.get("colpo", 0))):
		return
	box.remove(dart, 1)
	var dir := (best.position - eye).normalized()
	var dmg := int(ItemsData.get_item(dart).get("damage", 4)) + BASE
	e.m.shots.fire(eye + dir * 8.0, dir * SPEED, 60.0, dmg, true, 1.0, {"look": "dardo"})
	mc.set_meta("t", EVERY)
	mc.st["tiri"] = int(mc.st.get("tiri", 0)) + 1
	e.m.sfx.play("tira", eye)


func state_text(mc: Machine, e: Energy) -> String:
	var box: Bisaccia = e.m.world.chest_at(mc.o)
	var darts := 0
	for a in Combat.AMMO:
		darts += box.count(String(a))
	if darts == 0:
		return "ferma: niente dardi nella cassetta"
	return super.state_text(mc, e) + " · %d dardi, tiri: %d" % [darts, int(mc.st.get("tiri", 0))]
