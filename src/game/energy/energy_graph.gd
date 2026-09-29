class_name EnergyGraph
extends RefCounted
## Roadmap 19: la costruzione delle reti del Flusso (per `Energy.rebuild`): la visita delle celle di vena collegate
## (`VeinsData.joins`), le macchine attaccate (la prima loro cella che sta su una vena) e, per ogni macchina, la vena più
## stretta sulla strada più larga dalle sorgenti e dalle riserve (`Machine.cap`).


static var cap_mult := 1.0             # voce 207: il gene «Terra che conduce» (`EnergyStorm.genes`)
const DIRS: Array[Vector2i] = [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]


static func build(e: Energy) -> void:
	var w: World = e.m.world
	var net_of: Dictionary = e.net_of
	var nets: Array[Dictionary] = e.nets
	var cells: Dictionary = e.cells
	var machines: Dictionary = e.machines
	net_of.clear()
	nets.clear()
	var vein: PackedByteArray = w.vein
	var ww := w.w
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
			for d: Vector2i in DIRS:
				var q: Vector2i = c + d
				if net_of.has(q) or not cells.has(q):
					continue
				var bq := vein[q.y * ww + q.x]          # (le celle di `cells` stanno dentro il mondo)
				# (`VeinsData.joins` scritto in linea: le chiamate nei cicli interni costano)
				var ta := b & 7
				var tb := bq & 7
				if ta == tb or (b & 8 == 0 and bq & 8 == 0):
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
	# le stazioni (casse, porte…) attaccate a una rete: per il Nodo delle casse, lo Smistatore, lo Scudo di corteccia
	e.station_net.clear()
	for q: Vector2i in net_of:                # (dalle celle di vena: le stazioni del mondo sono migliaia, le vene no)
		var st: Dictionary = w.station_at(q)
		if not st.is_empty() and not e.station_net.has(st["origin"]):
			e.station_net[st["origin"]] = int(net_of[q])
	for ni in nets.size():
		_widest(e, ni)


## La portata di una cella di vena.
static func cap_at(w: World, c: Vector2i) -> float:
	return float(VeinsData.TIERS[VeinsData.tier(w.vein_at(c.x, c.y))].get("cap", 0)) * cap_mult


## Per ogni macchina della rete: la vena più stretta sulla strada migliore dalle sorgenti e dalle riserve (la strada
## più larga: si allarga prima dalle celle più capienti).
static func _widest(e: Energy, ni: int) -> void:
	var nt: Dictionary = e.nets[ni]
	var w: World = e.m.world
	var ends: Array = nt["sources"] + nt["reserves"]
	# voce 212: una rete di un grado solo (il caso più comune) non ha strozzature: ogni macchina ha la portata del grado
	var cl: Array = nt["cells"]
	var t0 := w.vein_at(cl[0].x, cl[0].y) & 7 if not cl.is_empty() else 0
	var uniform := true
	var vein: PackedByteArray = w.vein
	var ww := w.w
	for c: Vector2i in cl:
		if vein[c.y * ww + c.x] & 7 != t0:
			uniform = false
			break
	if uniform:
		var cap := cap_at(w, cl[0]) if not ends.is_empty() else 0.0
		for mc in nt["users"]:
			mc.cap = cap
		for mc in ends:
			mc.cap = cap
		return
	# altrimenti la strada più larga: si allarga prima dal grado più alto (una pila per grado, 1-4)
	var net_of: Dictionary = e.net_of
	var best := {}                        # cella -> grado della vena più stretta sulla strada migliore
	var stacks: Array = [[], [], [], [], []]
	for mc in ends:
		var t := vein[mc.entry.y * ww + mc.entry.x] & 7
		if t > int(best.get(mc.entry, 0)):
			best[mc.entry] = t
			stacks[t].append(mc.entry)
	var top := 4
	while top > 0:
		var lst: Array = stacks[top]
		if lst.is_empty():
			top -= 1
			continue
		var c: Vector2i = lst.pop_back()
		if int(best.get(c, 0)) > top:
			continue
		var b := vein[c.y * ww + c.x]
		for d: Vector2i in DIRS:
			var q: Vector2i = c + d
			if net_of.get(q, -1) != ni:
				continue
			var bq := vein[q.y * ww + q.x]
			if not ((b & 7) == (bq & 7) or (b & 8 == 0 and bq & 8 == 0)):
				continue                         # (`VeinsData.joins` in linea: le chiamate nei cicli interni costano)
			var v := mini(top, bq & 7)
			if v > int(best.get(q, 0)):
				best[q] = v
				stacks[v].append(q)
	var caps: Array[float] = []
	for td in VeinsData.TIERS:
		caps.append(float((td as Dictionary).get("cap", 0)) * cap_mult)
	for mc in nt["users"]:
		mc.cap = caps[int(best.get(mc.entry, 0))]
	for mc in nt["sources"] + nt["reserves"]:
		mc.cap = cap_at(w, mc.entry)
