class_name MachineTip
extends RefCounted
## Roadmap 19, voce 194: le schede dei suggerimenti della rete. Una macchina: che cos'è, che cosa fa adesso e perché, i
## numeri della sua rete. Una vena: il grado, la portata, la rete e se la Linfa scorre; i fili che passano nella cella.


static func card(m: Node2D, o: Vector2i, id: String) -> TipCard:
	var d := MachinesData.get_machine(id)
	var c := TipCard.new()
	c.title(String(d["name"]), Color("#8ef0e8"), id)
	var e: Energy = m.energy
	var mc: Machine = e.machines.get(o)
	var role_name: String = {"sorgente": "sorgente di Linfa", "riserva": "riserva di Linfa", "macchina": "macchina della rete",
		"comando": "comando dell'Impulso", "nodo": "nodo della logica"}.get(String(d.get("role", "")), "")
	c.sub(role_name)
	if mc != null:
		var s := mc.bh.state_text(mc, e)
		var col := Color("#8ef0c0")
		if s.begins_with("ferma") or s == "spenta":
			col = Color("#ff9a7a")
		c.pair("Adesso", s, col)
		if mc.role() == "riserva":
			var g := float(mc.st.get("g", 0.0))
			c.bar("%d / %d gocce" % [roundi(g), int(d["cap"])], g / maxf(float(d["cap"]), 1.0), Color("#3aa8a8"))
		if mc.net >= 0:
			var nt: Dictionary = e.nets[mc.net]
			c.pair("La sua rete", "dà %d pulsi, ne chiede %d" % [roundi(float(nt["prod"])), roundi(float(nt["want"]))], TipCard.GOLD)
		elif mc.role() != "comando":
			c.line("Nessuna vena la tocca: posane una sotto (Pinza delle vene).", Color("#ffb070"))
	if d.has("pulsi") and String(d.get("role", "")) == "macchina" and int(d["pulsi"]) > 0:
		c.pair("Chiede", Energy.pulsi(float(d["pulsi"])), Color("#cfe6e0"))
	if d.has("pulsi") and String(d.get("role", "")) == "sorgente":
		c.pair("Dà al più", "%d pulsi" % int(d["pulsi"]), Color("#cfe6e0"))
	if d.has("colpo"):
		c.pair("Ogni azione", "%d gocce" % int(d["colpo"]), Color("#cfe6e0"))
	c.hint("Clic destro: " + ("usa" if String(d.get("bh", "")) in ["leva", "pulsante"] else "il pannello"))
	return c


## La scheda di una vena (e dei fili) in una cella.
static func vein(m: Node2D, cell: Vector2i) -> TipCard:
	var b: int = m.world.vein_at(cell.x, cell.y)
	var t := VeinsData.tier(b)
	var c := TipCard.new()
	var e: Energy = m.energy
	if t > 0:
		var td: Dictionary = VeinsData.TIERS[t]
		c.title(String(td["name"]), Color("#8ef0e8"), String(td["item"]))
		c.pair("Porta al più", "%d pulsi" % int(td["cap"]), Color("#cfe6e0"))
		if b & VeinsData.INSULATED:
			c.line("Isolata: non si collega alle vene di un altro grado.", TipCard.GOLD)
		var nt := e.net_at(cell)
		if not nt.is_empty():
			c.pair("La rete", "%d vene, %d sorgenti, %d macchine, %d riserve" % [(nt["cells"] as Array).size(),
				(nt["sources"] as Array).size(), (nt["users"] as Array).size(), (nt["reserves"] as Array).size()], TipCard.GOLD)
			c.pair("Adesso", "le sorgenti danno %d pulsi, le macchine ne chiedono %d" % [roundi(float(nt["prod"])),
				roundi(float(nt["want"]))], Color("#8ef0c0") if bool(nt["flowing"]) else Color("#a0b4b0"))
			if float(nt["cap"]) > 0.0:
				c.bar("riserve %d / %d gocce" % [roundi(float(nt["stored"])), roundi(float(nt["cap"]))],
					float(nt["stored"]) / float(nt["cap"]), Color("#3aa8a8"))
	else:
		c.title("Fili dell'Impulso", Color("#ffc050"))
	for k in 4:
		var s: int = e.impulse.state_at(cell, k)
		if s >= 0:
			c.pair(String(VeinsData.WIRES[k]["name"]), "acceso" if s == 1 else "spento", VeinsData.WIRES[k]["color"])
	c.hint("Pinza delle vene: clic destro la riprende")
	return c
