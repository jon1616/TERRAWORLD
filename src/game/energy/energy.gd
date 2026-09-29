class_name Energy
extends Node
## Roadmap 19 «La Linfa che scorre»: la rete del Flusso, mentre si gioca. Le vene (`World.vein`) che si toccano fanno
## una **rete**; le macchine di `MachinesData` con una cella su una vena ne fanno parte. Ogni `TICK` secondi ogni rete fa
## il conto: quanto danno le sorgenti, quanto chiedono le macchine (per priorità: prima le alte), quanto entra ed esce
## dalle riserve. Una macchina prende al più la portata della vena più stretta sulla strada dalle sorgenti (o dalle
## riserve) fino a lei. Si calcola per reti, non per celle: le reti si rifanno solo quando si posa o si toglie una vena
## (`Veins.changed`) o cambia una stazione (`World.stations_rev`).
## Lo stato delle macchine sta in `world_meta["rete"]["m"]` (chiave «x,y»): si salva con il mondo.

signal rebuilt
signal ticked

const TICK := 0.25

var m: Node2D
var machines := {}                     # angolo -> Machine
var nets: Array[Dictionary] = []       # {cells, sources, reserves, users, prod, used, want, stored, cap, flowing, bottleneck}
var net_of := {}                       # cella di vena -> indice della rete
var cells := {}                        # tutte le celle con una vena del Flusso
var solved := 0                        # quanti conti (per le prove)
var _dirty := true
var _rev := -1
var _t := 0.0
var _lights: Array = []


func setup(main: Node2D) -> void:
	m = main
	m.veins.changed.connect(_on_vein)
	m.view.flow_check = func(c: Vector2i) -> bool: return flows(c)
	m.view.props.machine_look = func(o: Vector2i) -> Array: return look(o)
	_scan_cells()


## L'Occhio delle vene in mano (mostra i fili e i numeri delle reti, voce 194).
func eye_on() -> bool:
	return String(m.hud.current().get("id", "")) == "occhio_vene"


func meta() -> Dictionary:
	if not m.world_meta.has("rete"):
		m.world_meta["rete"] = {"m": {}}
	var r: Dictionary = m.world_meta["rete"]
	if not r.has("m"):
		r["m"] = {}
	return r


## Tutte le celle con una vena (una volta all'ingresso: le righe senza vene si saltano con il conto nativo degli zeri).
func _scan_cells() -> void:
	cells.clear()
	var w: World = m.world
	if w.vein.size() != w.tiles.size() or w.vein.count(0) == w.vein.size():
		return
	for y in w.h:
		var row := w.vein.slice(y * w.w, (y + 1) * w.w)
		if row.count(0) == w.w:
			continue
		for x in w.w:
			if row[x] & VeinsData.TIER_MASK != 0:
				cells[Vector2i(x, y)] = true


func _on_vein(c: Vector2i) -> void:
	if VeinsData.tier(m.world.vein_at(c.x, c.y)) > 0:
		cells[c] = true
	else:
		cells.erase(c)
	_dirty = true


func mark_dirty() -> void:
	_dirty = true


func _process(dt: float) -> void:
	if m == null or not m.built:
		return
	var rev: int = m.world.stations_rev()
	if rev != _rev or _dirty:
		_rev = rev
		rebuild()
	_t += dt
	if _t >= TICK:
		solve(_t)
		_t = 0.0


# ---------------------------------------------------------------- le reti

## Rifà le reti e attacca le macchine.
func rebuild() -> void:
	_dirty = false
	var w: World = m.world
	# le macchine che ci sono (lo stato resta nel mondo, anche per quelle appena tolte e rimesse altrove no)
	var st_all: Dictionary = meta()["m"]
	var alive := {}
	var old := machines
	machines = {}
	for o: Vector2i in w.stations:
		var sid := String(w.stations[o])
		if not MachinesData.is_machine(sid):
			continue
		var key := "%d,%d" % [o.x, o.y]
		if not st_all.has(key) or String((st_all[key] as Dictionary).get("id", sid)) != sid:
			st_all[key] = {"id": sid}
		var mc: Machine = old.get(o)
		if mc == null or mc.id != sid:
			mc = Machine.new()
			mc.setup(o, sid, st_all[key])
		else:
			mc.st = st_all[key]
		mc.net = -1
		machines[o] = mc
		alive[key] = true
	for k in st_all.keys():
		if not alive.has(k):
			st_all.erase(k)
	# le reti: visita delle celle di vena collegate
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
	for ni in nets.size():
		_widest(ni)
	# il bagliore delle vene si ridisegna secondo chi scorre (al primo conto)
	for nt in nets:
		nt["flowing"] = false
	_repaint_all()
	rebuilt.emit()


## La portata di una cella di vena.
func _cap_at(c: Vector2i) -> float:
	return float(VeinsData.TIERS[VeinsData.tier(m.world.vein_at(c.x, c.y))].get("cap", 0))


## Per ogni macchina della rete: la vena più stretta sulla strada migliore dalle sorgenti e dalle riserve (la strada
## più larga: si allarga prima dalle celle più capienti).
func _widest(ni: int) -> void:
	var nt: Dictionary = nets[ni]
	var best := {}
	var buckets := {}                    # portata -> celle da allargare
	for mc in nt["sources"] + nt["reserves"]:
		var v0 := _cap_at(mc.entry)
		if v0 > float(best.get(mc.entry, 0.0)):
			best[mc.entry] = v0
			if not buckets.has(v0):
				buckets[v0] = []
			buckets[v0].append(mc.entry)
	var w: World = m.world
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
			if net_of.get(q, -1) != ni or not VeinsData.joins(b, w.vein_at(q.x, q.y)):
				continue
			var v := minf(top, _cap_at(q))
			if v > float(best.get(q, 0.0)):
				best[q] = v
				if not buckets.has(v):
					buckets[v] = []
				buckets[v].append(q)
	for mc in nt["users"]:
		mc.cap = float(best.get(mc.entry, 0.0))
	for mc in nt["sources"] + nt["reserves"]:
		mc.cap = _cap_at(mc.entry)


# ---------------------------------------------------------------- il conto del Flusso

func solve(dt: float) -> void:
	solved += 1
	var changed := false
	for mc: Machine in machines.values():
		if mc.net < 0:
			mc.power = 0.0
			mc.given = 0.0
			mc.made = mc.bh.produce(mc, self) if mc.role() == "sorgente" else 0.0
	for ni in nets.size():
		var nt: Dictionary = nets[ni]
		var prod := 0.0
		for mc: Machine in nt["sources"]:
			mc.made = minf(mc.bh.produce(mc, self), mc.cap)
			prod += mc.made
		# quanto possono dare le riserve adesso
		var res_out := 0.0
		var stored := 0.0
		var capacity := 0.0
		for mc: Machine in nt["reserves"]:
			var g := float(mc.st.get("g", 0.0))
			stored += g
			capacity += float(mc.d["cap"])
			res_out += minf(minf(float(mc.d["io"]), mc.cap), g / dt)
		var avail := prod + res_out
		# le macchine per priorità: prima le alte
		var want := 0.0
		var used := 0.0
		for pr in [2, 1, 0]:
			var level := 0.0
			var lst: Array = []
			for mc: Machine in nt["users"]:
				if mc.prio() != pr:
					continue
				var wv := minf(mc.bh.demand(mc, self), mc.cap)
				mc.set_meta("want", wv)
				mc.set_meta("want_full", mc.bh.demand(mc, self))
				level += wv
				lst.append(mc)
			want += level
			var give := minf(level, avail)
			var ratio := give / level if level > 0.0 else 0.0
			for mc: Machine in lst:
				var wv2 := float(mc.get_meta("want"))
				var full := float(mc.get_meta("want_full"))
				mc.given = wv2 * ratio
				mc.power = (mc.given / full) if full > 0.0 else 0.0
			avail -= give
			used += give
		# da dove viene ciò che si è usato: prima le sorgenti, poi le riserve
		var from_prod := minf(used, prod)
		var from_res := used - from_prod
		var surplus := prod - from_prod
		for mc: Machine in nt["reserves"]:
			var g2 := float(mc.st.get("g", 0.0))
			if from_res > 0.0 and stored > 0.0:
				g2 -= from_res * dt * (g2 / stored)
			elif surplus > 0.0:
				var room := float(mc.d["cap"]) - g2
				var inflow := minf(minf(float(mc.d["io"]), mc.cap), surplus)
				var add := minf(inflow * dt, room)
				g2 += add
				surplus -= add / dt
			mc.st["g"] = clampf(g2, 0.0, float(mc.d["cap"]))
		var fl := prod > 0.01 or from_res > 0.01
		if fl != bool(nt["flowing"]):
			nt["flowing"] = fl
			changed = true
			_repaint(ni)
		nt["prod"] = prod
		nt["used"] = used
		nt["want"] = want
		nt["stored"] = 0.0
		for mc: Machine in nt["reserves"]:
			nt["stored"] = float(nt["stored"]) + float(mc.st.get("g", 0.0))
		nt["cap"] = capacity
	for mc: Machine in machines.values():
		mc.bh.tick(mc, self, dt)
	_update_looks()
	if changed:
		m.light.dirty = true
	ticked.emit()


## Perché una macchina non ha tutto (per le schede).
func why(mc: Machine) -> String:
	if mc.net < 0:
		return "nessuna vena"
	var nt: Dictionary = nets[mc.net]
	if mc.cap <= 0.0:
		return "nessuna sorgente o riserva sulla sua rete"
	var full := mc.bh.demand(mc, self)
	if mc.cap < full:
		return "la vena più stretta porta %d pulsi, ne chiede %d" % [roundi(mc.cap), roundi(full)]
	return "le sorgenti danno %d pulsi, le macchine ne chiedono %d" % [roundi(float(nt["prod"])), roundi(float(nt["want"]))]


## La Linfa scorre nella cella c? (per il bagliore delle vene)
func flows(c: Vector2i) -> bool:
	var ni: int = net_of.get(c, -1)
	return ni >= 0 and bool(nets[ni]["flowing"])


## La rete di una cella ({} se non c'è).
func net_at(c: Vector2i) -> Dictionary:
	var ni: int = net_of.get(c, -1)
	return nets[ni] if ni >= 0 else {}


func machine_at(c: Vector2i) -> Machine:
	var s: Dictionary = m.world.station_at(c)
	if s.is_empty():
		return null
	return machines.get(s["origin"])


func _repaint(ni: int) -> void:
	for c: Vector2i in nets[ni]["cells"]:
		if m.view.chunks.has(World.chunk_of(c)):
			m.view.refresh_vein(c)


func _repaint_all() -> void:
	for ni in nets.size():
		_repaint(ni)


# ---------------------------------------------------------------- l'aspetto e la luce

## [fa luce, ha energia] di una macchina (per `ViewProps`).
func look(o: Vector2i) -> Array:
	var mc: Machine = machines.get(o)
	if mc == null:
		return [true, true]
	var powered := mc.role() != "macchina" or mc.power >= 0.99 or not mc.on()
	var glow := mc.lit if mc.d.has("light") else (mc.role() != "macchina" or mc.power >= 0.99)
	if mc.role() == "sorgente":
		glow = mc.made > 0.01
	elif mc.role() == "riserva":
		glow = float(mc.st.get("g", 0.0)) > 1.0
	return [glow, powered]


func _update_looks() -> void:
	var lights := []
	for mc: Machine in machines.values():
		var lk := look(mc.o)
		if mc.get_meta("look", []) != lk:
			mc.set_meta("look", lk)
			m.view.props.set_machine_look(mc.o, bool(lk[0]), bool(lk[1]))
		if mc.lit and mc.d.has("light"):
			lights.append([mc.o, mc.d["light"]])
	if lights != _lights:
		_lights = lights
		m.light.set_extra("rete", lights)
