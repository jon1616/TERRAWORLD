class_name EnergyGraph
extends RefCounted
## Roadmap 19: la costruzione delle reti del Flusso (per `Energy.rebuild`): la visita delle celle di vena collegate
## (`VeinsData.joins`), le macchine attaccate (la prima loro cella che sta su una vena) e, per ogni macchina, la vena più
## stretta sulla strada più larga dalle sorgenti e dalle riserve (`Machine.cap`).


static func build(e: Energy) -> void:
	var w: World = e.m.world
	var net_of: Dictionary = e.net_of
	var nets: Array[Dictionary] = e.nets
	var cells: Dictionary = e.cells
	var machines: Dictionary = e.machines
	net_of.clear()
	nets.clear()
	for c0: Vector2i in cells:
		if net_of.has(c0):
			continue
		var idx := nets.size()
		var list: Array[Vector2i] = [c0]
		net_of[c0] = idx
		var i := 0
		while i < list.size():
			var c: Vector2i = list[i]
			i += 1
			var b := w.vein_at(c.x, c.y)
			for d in [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]:
				var q: Vector2i = c + d
				if net_of.has(q) or not cells.has(q):
					continue
				if VeinsData.joins(b, w.vein_at(q.x, q.y)):
					net_of[q] = idx
					list.append(q)
		nets.append({"cells": list, "sources": [], "reserves": [], "users": [], "prod": 0.0, "used": 0.0, "want": 0.0,
			"stored": 0.0, "cap": 0.0, "flowing": false})
	# le macchine: la prima cella della stazione che sta su una vena
	for o: Vector2i in machines:
		var mc: Machine = machines[o]
		for dy in mc.size().y:
			for dx in mc.size().x:
				var q := o + Vector2i(dx, dy)
				if mc.net < 0 and net_of.has(q):
					mc.net = int(net_of[q])
					mc.entry = q
		if mc.net >= 0:
			var nt: Dictionary = nets[mc.net]
			match mc.role():
				"sorgente":
					nt["sources"].append(mc)
				"riserva":
					nt["reserves"].append(mc)
				"macchina":
					nt["users"].append(mc)
	# le casse (e le cassette delle macchine) attaccate a una rete: per il Nodo delle casse e lo Smistatore
	e.chest_net.clear()
	for o: Vector2i in w.chests:
		var sid := String(w.stations.get(o, ""))
		if sid == "" or not StationsData.STATIONS.has(sid):
			continue
		var sz: Array = StationsData.STATIONS[sid]["size"]
		for dy in int(sz[1]):
			for dx in int(sz[0]):
				var q := o + Vector2i(dx, dy)
				if not e.chest_net.has(o) and net_of.has(q):
					e.chest_net[o] = int(net_of[q])
	for ni in nets.size():
		_widest(e, ni)


## La portata di una cella di vena.
static func cap_at(w: World, c: Vector2i) -> float:
	return float(VeinsData.TIERS[VeinsData.tier(w.vein_at(c.x, c.y))].get("cap", 0))


## Per ogni macchina della rete: la vena più stretta sulla strada migliore dalle sorgenti e dalle riserve (la strada
## più larga: si allarga prima dalle celle più capienti).
static func _widest(e: Energy, ni: int) -> void:
	var nt: Dictionary = e.nets[ni]
	var w: World = e.m.world
	var best := {}
	var buckets := {}                    # portata -> celle da allargare
	for mc in nt["sources"] + nt["reserves"]:
		var v0 := cap_at(w, mc.entry)
		if v0 > float(best.get(mc.entry, 0.0)):
			best[mc.entry] = v0
			if not buckets.has(v0):
				buckets[v0] = []
			buckets[v0].append(mc.entry)
	while not buckets.is_empty():
		var top: float = buckets.keys().max()
		var lst: Array = buckets[top]
		var c: Vector2i = lst.pop_back()
		if lst.is_empty():
			buckets.erase(top)
		if float(best.get(c, 0.0)) > top:
			continue
		var b := w.vein_at(c.x, c.y)
		for d in [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]:
			var q: Vector2i = c + d
			if e.net_of.get(q, -1) != ni or not VeinsData.joins(b, w.vein_at(q.x, q.y)):
				continue
			var v := minf(top, cap_at(w, q))
			if v > float(best.get(q, 0.0)):
				best[q] = v
				if not buckets.has(v):
					buckets[v] = []
				buckets[v].append(q)
	for mc in nt["users"]:
		mc.cap = float(best.get(mc.entry, 0.0))
	for mc in nt["sources"] + nt["reserves"]:
		mc.cap = cap_at(w, mc.entry)
