class_name Impulse
extends RefCounted
## Roadmap 19, voce 193: l'Impulso. I fili dello stesso colore che si toccano fanno una **rete del filo**; le macchine
## che toccano un filo con una loro cella ne fanno parte. Una rete del filo è accesa quando almeno un comando «a stato»
## che la tocca è acceso (una leva alzata, una piastra premuta, un sensore vero). Gli eventi:
##   "su" / "giu"  la rete si è accesa / spenta
##   "colpo"       un colpo istantaneo (un pulsante, un orologio)
## Ogni macchina che riceve reagisce secondo la sua `reazione` (`MachineBehavior.on_impulse`): «segue» (accesa finché
## il filo è acceso; un colpo la alterna) o «alterna» (ogni accensione o colpo la alterna).
## **Niente giri infiniti**: chi risponde a un impulso con un altro impulso (i nodi della logica) lo manda un passo dopo
## (`STEP`), e in un fotogramma si consegnano al più `MAX_EVENTS` eventi: un circuito chiuso su se stesso oscilla, non
## blocca il gioco.

const STEP := 0.05
const MAX_EVENTS := 400

var e: Energy
var wcells: Array[Dictionary] = [{}, {}, {}, {}]      # colore -> {cella: true}
var wnet_of: Array[Dictionary] = [{}, {}, {}, {}]     # colore -> {cella: indice}
var wnets: Array = [[], [], [], []]                    # colore -> [{cells, members, state}]
var queue: Array = []                                  # [tempo, colore, rete, tipo, chi l'ha mandato]
var traps := {}                                        # voce 202: trappola (angolo) -> [colore, rete del filo] che la arma
var now := 0.0
var delivered := 0                                     # eventi consegnati (per le prove)


func _init(energy: Energy) -> void:
	e = energy


func on_cell(c: Vector2i, b: int) -> void:
	for k in 4:
		if VeinsData.has_wire(b, k):
			wcells[k][c] = true
		else:
			wcells[k].erase(c)


## Le reti dei fili e chi ne fa parte (dopo che `Energy` ha rifatto le macchine).
func rebuild(machines: Dictionary) -> void:
	for k in 4:
		var of := {}
		var nets := []
		for c0: Vector2i in wcells[k]:
			if of.has(c0):
				continue
			var idx := nets.size()
			var list: Array[Vector2i] = [c0]
			of[c0] = idx
			var i := 0
			while i < list.size():
				var c: Vector2i = list[i]
				i += 1
				for d in [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]:
					var q: Vector2i = c + d
					if not of.has(q) and wcells[k].has(q):
						of[q] = idx
						list.append(q)
			nets.append({"cells": list, "members": [], "state": false})
		wnet_of[k] = of
		wnets[k] = nets
	for mc: Machine in machines.values():
		mc.wired.clear()
		for dy in mc.size().y:
			for dx in mc.size().x:
				var q := mc.o + Vector2i(dx, dy)
				for k in 4:
					if not mc.wired.has(k) and wnet_of[k].has(q):
						mc.wired[k] = int(wnet_of[k][q])
						wnets[k][mc.wired[k]]["members"].append(mc)
	# voce 202: le trappole che toccano un filo: armate finché il filo è acceso
	traps.clear()
	var w: World = e.m.world
	for o: Vector2i in w.stations:
		if not TrapsData.is_trap(String(w.stations[o])):
			continue
		for k in 4:
			if wnet_of[k].has(o) and not traps.has(o):
				traps[o] = [k, int(wnet_of[k][o])]
	# lo stato delle reti dai comandi, e chi «segue» si mette in pari senza eventi
	for k in 4:
		for nt: Dictionary in wnets[k]:
			nt["state"] = _or(nt)
	for mc: Machine in machines.values():
		if mc.role() in ["comando", "nodo"]:
			continue
		if mc.wired.is_empty():
			if not mc.st.has("off_by_hand"):
				mc.st["on"] = true
		elif String(mc.st.get("reazione", "segue")) == "segue":
			var any := false
			for k in mc.wired:
				if bool(wnets[k][mc.wired[k]]["state"]):
					any = true
			mc.st["on"] = any
	queue.clear()


## Il filo della rete è acceso se almeno un comando che lo tocca è acceso.
func _or(nt: Dictionary) -> bool:
	for mc: Machine in nt["members"]:
		if mc.role() in ["comando", "nodo"] and bool(mc.st.get("out", false)):
			return true
	return false


## Un comando cambia il suo stato (leva, piastra, sensore, nodo): le reti che tocca si riaccendono o si spengono.
func set_out(mc: Machine, value: bool, delay := 0.0) -> void:
	if bool(mc.st.get("out", false)) == value:
		return
	mc.st["out"] = value
	for k in mc.wired:
		var nt: Dictionary = wnets[k][mc.wired[k]]
		var s := _or(nt)
		if s != bool(nt["state"]):
			nt["state"] = s
			queue.append([now + delay, k, int(mc.wired[k]), "su" if s else "giu", mc])


## Un colpo istantaneo su tutti i fili che il comando tocca.
func pulse(mc: Machine, delay := 0.0) -> void:
	for k in mc.wired:
		queue.append([now + delay, k, int(mc.wired[k]), "colpo", mc])


## Consegna gli eventi arrivati (al più `MAX_EVENTS` per fotogramma).
func process(dt: float) -> void:
	now += dt
	if queue.is_empty():
		return
	queue.sort_custom(func(a: Array, b: Array) -> bool: return float(a[0]) < float(b[0]))
	var n := 0
	while not queue.is_empty() and float(queue[0][0]) <= now and n < MAX_EVENTS:
		var ev: Array = queue.pop_front()
		n += 1
		var k: int = ev[1]
		var ni: int = ev[2]
		if ni >= (wnets[k] as Array).size():
			continue
		for mc: Machine in wnets[k][ni]["members"]:
			if mc == ev[4] and mc.role() == "comando":
				continue                                 # chi manda non riceve il suo stesso colpo
			mc.bh.on_impulse(mc, e, k, String(ev[3]))
			delivered += 1


## Lo stato del filo di un colore in una cella (per le schede): -1 nessun filo, 0 spento, 1 acceso.
func state_at(c: Vector2i, k: int) -> int:
	if not wnet_of[k].has(c):
		return -1
	return 1 if bool(wnets[k][wnet_of[k][c]]["state"]) else 0


## Voce 202: le trappole con un filo sono armate finché il filo è acceso (`Traps.set_armed`).
func sync_traps() -> void:
	if traps.is_empty() or e.m.get("traps") == null:
		return
	for o: Vector2i in traps:
		var k: int = traps[o][0]
		var ni: int = traps[o][1]
		if ni >= (wnets[k] as Array).size():
			continue
		var on: bool = wnets[k][ni]["state"]
		if e.m.traps.armed(o) != on:
			e.m.traps.set_armed(o, on)
