class_name FarmInfo
extends RefCounted
## Le schede dei pezzi delle farm (voce 89): l'esca dice chi chiama e, se nessuno, perché; la tramoggia quanto aspira;
## la Radice-ancora e i nastri cosa fanno. Chiamate da `StationTip.card`.


static func card(m: Node2D, c: TipCard, o: Vector2i, id: String) -> void:
	var at := (Vector2(o) + Vector2(0.5, 0.5)) * 16.0
	if FarmData.is_bait(id):
		var bd: Dictionary = FarmData.BAITS[id]
		c.sub("esca · entro %d tessere · al più %d insieme" % [int(bd["r"]), int(bd["cap"])])
		var ca: Dictionary = m.farms.callable_at(o)
		if String(ca["item"]) != "":
			c.pair("Esca", String(ItemsData.get_item(String(ca["item"])).get("name", ca["item"])), TipCard.GOLD)
		var ok: Array = ca["ok"]
		if ok.is_empty():
			c.line(String(ca["why"]), Color("#ff8a6a"))
		else:
			var names: Array[String] = []
			for sp in ok:
				names.append(String(CreaturesData.CREATURES[sp].get("name", sp)))
			c.line("Chiama: " + ", ".join(names), TipCard.GOOD)
		var y: Array = m.farms.zone_yield(at)
		c.bar("Rendita della zona %d / %d" % [y[0], y[1]], float(y[0]) / float(y[1]), Color("#ffb070"))
		if not m.farms.anchored(at):
			c.line("Lavora solo quando sei vicino (o accanto a una Radice-ancora)", TipCard.SOFT)
		c.hint("Clic destro: posa l'esca")
	elif FarmData.is_hopper(id):
		var bag: Bisaccia = m.world.chest_at(o)
		var used := 0
		for s in bag.slots:
			if not s.is_empty():
				used += 1
		c.sub("tramoggia · aspira entro %d tessere" % int(FarmData.HOPPERS[id]["r"]))
		c.bar("Caselle %d / %d" % [used, bag.slots.size()], float(used) / float(bag.slots.size()), TipCard.GOLD)
		c.hint("Clic destro: apri")
	elif id == "radice_ancora":
		c.sub("tiene viva la farm")
		c.line("Entro %d tessere creature, trappole, esche e tramogge lavorano anche quando sei lontano" % FarmData.ANCHOR_R, TipCard.GOLD)
	else:
		c.sub("nastro · verso " + ("destra" if id == "nastro_dx" else "sinistra"))
		c.line("Spinge gli oggetti caduti che ci passano sopra", TipCard.TEXT)
		c.hint("Clic destro: cambia verso")
