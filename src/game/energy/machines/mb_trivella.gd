class_name MbTrivella
extends MachineBehavior
## La Trivella di radice: con i suoi pulsi e un piccone nella cassetta scava da sola un pozzo largo quanto lei, verso il
## basso, una tessera alla volta (da sinistra a destra, poi la riga sotto). Il tempo di ogni tessera è quello del
## piccone (`TileDefs.HARD` × 35 / forza) diviso `SPEED`; ciò che la tessera lascia (`TileDefs.DROP`) va nella cassetta.
## Si ferma: davanti a un blocco troppo duro per il piccone, a un liquido, a un Sigillo o a una porta dei Seminatori, a
## ciò che è stato costruito, a cassetta piena, oltre `MAX_DEPTH`, e dopo `DAY_CAP` blocchi in un giorno del mondo (il
## tetto di resa: una macchina risparmia fatica, non crea ricchezza senza fine).

const SPEED := 1.0
const MAX_DEPTH := 400
const DAY_CAP := 600


func _pick(box: Bisaccia) -> Dictionary:
	var best := {}
	var best_p := 0
	for i in box.slots.size():
		var id := box.id_at(i)
		if id == "" or String(ItemsData.get_item(id).get("kind", "")) != "piccone":
			continue
		var pw := int(Gear.stats(box.slots[i])["power"])
		if pw > best_p:
			best_p = pw
			best = box.slots[i]
	return best


## La prossima cella da scavare (o Vector2i(-1, -1) in fondo).
func _next(mc: Machine, w: World) -> Vector2i:
	var depth := int(mc.st.get("y", 0))
	var col := int(mc.st.get("x", 0))
	while depth < MAX_DEPTH:
		var c := Vector2i(mc.o.x + col, mc.o.y + mc.size().y + depth)
		if not w.inside(c.x, c.y):
			return Vector2i(-1, -1)
		if w.solid(c.x, c.y) or w.liq(c.x, c.y) > 0:
			mc.st["y"] = depth
			mc.st["x"] = col
			return c
		col += 1
		if col >= mc.size().x:
			col = 0
			depth += 1
	return Vector2i(-1, -1)


func demand(mc: Machine, e: Energy) -> float:
	if String(mc.get_meta("stop", "")) != "":
		return 0.0                                  # ferma: non consuma
	return super.demand(mc, e)


func tick(mc: Machine, e: Energy, dt: float) -> void:
	var w: World = e.m.world
	var day := int(e.m.world_meta.get("giorno", 1))
	if int(mc.st.get("giorno", -1)) != day:
		mc.st["giorno"] = day
		mc.st["oggi"] = 0
	var box: Bisaccia = w.chest_at(mc.o)
	var pick := _pick(box)
	var stop := ""
	var c := _next(mc, w)
	if pick.is_empty():
		stop = "metti un piccone nella sua cassetta"
	elif c.x < 0:
		stop = "è arrivata in fondo"
	elif int(mc.st.get("oggi", 0)) >= DAY_CAP:
		stop = "per oggi basta (%d blocchi): riparte domani" % DAY_CAP
	elif w.liq(c.x, c.y) > 0:
		stop = "c'è un liquido sotto"
	else:
		var t := w.tile(c.x, c.y)
		var pw := int(Gear.stats(pick)["power"])
		if TileDefs.SEAL_KIND.has(t) or t == TileDefs.PORTA_SEM or w.build_at(c.x, c.y) > 0 or not w.station_at(c).is_empty():
			stop = "sotto c'è qualcosa che non si scava (un Sigillo, una porta, ciò che hai costruito)"
		elif int(TileDefs.POWER.get(t, 0)) > pw:
			stop = "troppo duro per il piccone (vuole forza %d, ha %d)" % [int(TileDefs.POWER.get(t, 0)), pw]
		elif box.room_for(String(TileDefs.DROP.get(t, ""))) <= 0 and String(TileDefs.DROP.get(t, "")) != "":
			stop = "la cassetta è piena"
	mc.set_meta("stop", stop)
	if stop != "" or not mc.on() or mc.power < 0.99:
		mc.lit = false
		return
	mc.lit = true
	var tile := w.tile(c.x, c.y)
	var need := float(TileDefs.HARD.get(tile, 0.4)) * 35.0 / maxf(float(Gear.stats(pick)["power"]), 1.0) / SPEED
	var prog := float(mc.st.get("p", 0.0)) + dt
	if prog < need:
		mc.st["p"] = prog
		return
	mc.st["p"] = 0.0
	var drop := TileDefs.drop_of(tile)                 # voce 413: le vene che dormono danno roccia
	w.set_tile(c.x, c.y, TileDefs.AIR)
	if w.decor_at(c.x, c.y) != 0:
		w.set_decor(c.x, c.y, 0)
	if drop != "":
		box.add(drop, 1)
	mc.st["oggi"] = int(mc.st.get("oggi", 0)) + 1
	mc.st["scavati"] = int(mc.st.get("scavati", 0)) + 1
	if e.m.view.chunks.has(World.chunk_of(c)):
		e.m.view.refresh_around(c)
		Fx.dust(e.m.fx, Vector2(c) * 16.0 + Vector2(8, 8), TileDefs.dust_colors(tile))
	e.m.light.dirty = true


func state_text(mc: Machine, e: Energy) -> String:
	var stop := String(mc.get_meta("stop", ""))
	var t := "profondità %d, scavati %d (oggi %d)" % [int(mc.st.get("y", 0)), int(mc.st.get("scavati", 0)), int(mc.st.get("oggi", 0))]
	if stop != "":
		return "ferma: %s · %s" % [stop, t]
	if not mc.on() or mc.power < 0.99:
		return super.state_text(mc, e)
	return "scava · " + t
