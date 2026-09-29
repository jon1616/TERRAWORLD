class_name MbSmistatore
extends MachineBehavior
## Lo Smistatore: con i suoi pulsi raccoglie gli oggetti a terra vicino a lui (`PULL` tessere: anche quelli che arrivano
## dai nastri) nella sua cassetta e li manda nelle casse della sua rete (`Energy.chest_net`): prima in quella che ha già
## quell'oggetto, poi in quella che raccoglie il suo tipo (le impostazioni delle casse, `Storage.settings`).

const PULL := 2.5
const EVERY := 1.0


func tick(mc: Machine, e: Energy, dt: float) -> void:
	if not mc.on() or mc.power < 0.99:
		return
	var t := float(mc.get_meta("t", 0.0)) - dt
	if t > 0.0:
		mc.set_meta("t", t)
		return
	mc.set_meta("t", EVERY)
	var w: World = e.m.world
	var own: Bisaccia = w.chest_at(mc.o)
	e.m.drops.pull_into(mc.center(), PULL * 16.0, own)
	if own.is_empty() or mc.net < 0:
		return
	var targets: Array[Vector2i] = []
	for o: Vector2i in e.chest_net:
		if e.chest_net[o] == mc.net and o != mc.o and w.chests.has(o) and not MachinesData.is_machine(String(w.stations.get(o, ""))):
			targets.append(o)
	for i in own.slots.size():
		var id := own.id_at(i)
		if id == "":
			continue
		var cat := StorageData.category_of(id)
		for pass_n in 2:
			for o in targets:
				var st: Dictionary = e.m.storage.settings(o)
				if st["tipo"] == "nulla":
					continue
				var chest: Bisaccia = w.chests[o]
				if (chest.count(id) > 0) if pass_n == 0 else (st["tipo"] == cat):
					var left := chest.add_stack(own.slots[i])
					var moved := int(own.slots[i].get("n", 1)) - left
					if moved > 0:
						mc.st["smistati"] = int(mc.st.get("smistati", 0)) + moved
						chest.changed.emit()
					if left <= 0:
						own.slots[i] = {}
					else:
						own.slots[i]["n"] = left
				if own.slots[i].is_empty():
					break
			if own.slots[i].is_empty():
				break
	own.changed.emit()


func state_text(mc: Machine, e: Energy) -> String:
	if mc.net < 0:
		return "ferma: nessuna vena, e le casse si trovano per la rete"
	return super.state_text(mc, e) + " · smistati: %d" % int(mc.st.get("smistati", 0))
