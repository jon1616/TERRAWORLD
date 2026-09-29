class_name EnergyLinks
extends RefCounted
## Roadmap 19: ciò che la rete dice agli altri moduli e al giocatore (spostato da `Energy`, che superava le 400 righe):
## le casse dei Nodi delle casse (`Storage`), le porte con lo Scudo di corteccia (`Wiles`), i numeri di una rete e il
## perché di una macchina ferma (il pannello e le schede).


## Voce 200: le casse delle reti dei Nodi delle casse accesi vicini al Germogliato (a `CRAFT_REACH`): per `Storage`.
static func linked_chests(e: Energy) -> Array[Vector2i]:
	var nets_on := {}
	var p: Vector2 = e.m.player.position
	for mc: Machine in e.machines.values():
		if String(mc.id) == "nodo_casse" and mc.net >= 0 and mc.power >= 0.99 and mc.on() \
				and mc.center().distance_to(p) <= StorageData.CRAFT_REACH * 16.0:
			nets_on[mc.net] = true
	var out: Array[Vector2i] = []
	if nets_on.is_empty():
		return out
	for o: Vector2i in e.station_net:
		if nets_on.has(e.station_net[o]) and e.m.world.chests.has(o):
			out.append(o)
	return out


## Voce 202: questa stazione (una porta) è su una rete con uno Scudo di corteccia acceso? Lo chiede `Wiles`.
static func shielded(e: Energy, o: Vector2i) -> bool:
	var ni: int = e.station_net.get(o, -1)
	if ni < 0:
		return false
	for mc: Machine in e.nets[ni]["users"]:
		if mc.id == "scudo_corteccia" and mc.on() and mc.power >= 0.99:
			return true
	return false


## I numeri di una rete, in parole (per il pannello).
static func net_text(e: Energy, ni: int) -> String:
	if ni < 0 or ni >= e.nets.size():
		return "[color=#ffb070]Non è su una rete: posa una vena sotto di lei con la Pinza delle vene.[/color]"
	var nt: Dictionary = e.nets[ni]
	var t := "[color=#8ef0e8]La rete[/color]: %d vene · %d sorgenti · %d macchine · %d riserve\n" % [(nt["cells"] as Array).size(),
		(nt["sources"] as Array).size(), (nt["users"] as Array).size(), (nt["reserves"] as Array).size()]
	t += "Le sorgenti danno [b]%d[/b] pulsi, le macchine ne chiedono [b]%d[/b]" % [roundi(float(nt["prod"])), roundi(float(nt["want"]))]
	if float(nt["cap"]) > 0.0:
		t += ", nelle riserve [b]%d[/b] gocce su %d" % [roundi(float(nt["stored"])), roundi(float(nt["cap"]))]
	return t + "."


## Perché una macchina non ha tutto (per le schede).
static func why(e: Energy, mc: Machine) -> String:
	if mc.net < 0:
		return "nessuna vena"
	var nt: Dictionary = e.nets[mc.net]
	if mc.cap <= 0.0:
		return "nessuna sorgente o riserva sulla sua rete"
	var full := mc.bh.demand(mc, e)
	if mc.cap < full:
		return "la vena più stretta porta %d pulsi, ne chiede %d" % [roundi(mc.cap), roundi(full)]
	return "le sorgenti danno %d pulsi, le macchine ne chiedono %d" % [roundi(float(nt["prod"])), roundi(float(nt["want"]))]
