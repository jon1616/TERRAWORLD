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
var impulse: Impulse                   # voce 193: i fili e i comandi
var _framed: Array[Machine] = []       # chi va guardato a ogni fotogramma (porte, piastre)
var panel: MachinePanel                # voce 194: il pannello delle macchine
var _dirty := true
var _rev := -1
var _t := 0.0
var _lights: Array = []


func setup(main: Node2D) -> void:
	m = main
	impulse = Impulse.new(self)
	panel = MachinePanel.new()
	m.hud.add_child(panel)
	panel.setup(self)
	m.hud.overlays.append(panel)
	m.veins.changed.connect(_on_vein)
	m.view.flow_check = func(c: Vector2i) -> bool: return flows(c)
	m.view.props.machine_look = func(o: Vector2i) -> Array: return look(o)
	_scan_cells()


## «1 pulso», «12 pulsi».
static func pulsi(n: float) -> String:
	return "1 pulso" if roundi(n) == 1 else "%d pulsi" % roundi(n)


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
			if row[x] == 0:
				continue
			if row[x] & VeinsData.TIER_MASK != 0:
				cells[Vector2i(x, y)] = true
			if row[x] >> VeinsData.WIRE_SHIFT != 0:
				impulse.on_cell(Vector2i(x, y), row[x])


func _on_vein(c: Vector2i) -> void:
	var b: int = m.world.vein_at(c.x, c.y)
	if VeinsData.tier(b) > 0:
		cells[c] = true
	else:
		cells.erase(c)
	impulse.on_cell(c, b)
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
	for mc in _framed:
		mc.bh.frame(mc, self, dt)
	impulse.process(dt)
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
	for o: Vector2i in old:
		if not machines.has(o) or (machines[o] as Machine) != old[o]:
			(old[o] as Machine).bh.removed(old[o], self)
	_framed.clear()
	for mc: Machine in machines.values():
		if mc.d.get("frame", false):
			_framed.append(mc)
	EnergyGraph.build(self)
	impulse.rebuild(machines)
	# il bagliore delle vene si ridisegna secondo chi scorre (al primo conto)
	for nt in nets:
		nt["flowing"] = false
	_repaint_all()
	rebuilt.emit()


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


## Spende le gocce di un'azione (una porta che si muove) dalla rete della macchina: prima da ciò che le sorgenti danno
## in più adesso, poi dalle riserve. Falso se non basta (l'azione non si fa).
func spend(mc: Machine, amount: float) -> bool:
	if amount <= 0.0:
		return true
	if mc.net < 0:
		return false
	var nt: Dictionary = nets[mc.net]
	var spare := (float(nt["prod"]) - float(nt["used"])) * 4.0      # il Flusso in più di un secondo
	if spare >= amount:
		return true
	var need := amount - maxf(spare, 0.0)
	if float(nt["stored"]) < need:
		return false
	for r: Machine in nt["reserves"]:
		var g := float(r.st.get("g", 0.0))
		var take := minf(g, need)
		r.st["g"] = g - take
		need -= take
		if need <= 0.0:
			break
	nt["stored"] = maxf(float(nt["stored"]) - amount, 0.0)
	return true


## La rete di questa sorgente ha bisogno di più Flusso? (Le macchine chiedono più di quanto danno le altre sorgenti, o
## le riserve non sono piene.) Lo guardano le sorgenti che bruciano, per non sprecare.
func needs(mc: Machine) -> bool:
	if mc.net < 0:
		return false
	var nt: Dictionary = nets[mc.net]
	var others := float(nt["prod"]) - mc.made
	return float(nt["want"]) > others + 0.01 or float(nt["stored"]) < float(nt["cap"]) - 1.0


## Roadmap 19, voce 196: il parafulmine più vicino alla colonna x (entro 40), o -1. Lo chiede `Weather.strike`.
func bolt_target(px: int) -> int:
	var best := -1
	for mc: Machine in machines.values():
		if String(mc.d.get("bh", "")) == "parafulmine" and absi(mc.o.x - px) <= 40:
			if best < 0 or absi(mc.o.x - px) < absi(best - px):
				best = mc.o.x
	return best


## Un fulmine è caduto sulla cella c: se ha preso un parafulmine, le sue gocce vanno nelle riserve della sua rete.
func on_bolt(c: Vector2i) -> void:
	for mc: Machine in machines.values():
		if String(mc.d.get("bh", "")) == "parafulmine" and mc.o.x == c.x:
			mc.set_meta("flash", 1.0)
			mc.st["colpi"] = int(mc.st.get("colpi", 0)) + 1
			charge(mc.net, float(mc.d.get("bolt", 0.0)))
			refresh_look(mc)
			return


## Versa gocce nelle riserve di una rete (fino a riempirle); restituisce quante ne sono entrate.
func charge(ni: int, amount: float) -> float:
	if ni < 0 or ni >= nets.size():
		return 0.0
	var left := amount
	for r: Machine in nets[ni]["reserves"]:
		var g := float(r.st.get("g", 0.0))
		var add := minf(float(r.d["cap"]) - g, left)
		r.st["g"] = g + add
		left -= add
		if left <= 0.0:
			break
	return amount - left


## Clic destro su una macchina: il suo comportamento (una leva, un pulsante) o il pannello.
func touch(o: Vector2i) -> bool:
	var mc: Machine = machines.get(o)
	if mc == null:
		return false
	if mc.bh.touch(mc, self):
		refresh_look(mc)
		return true
	panel.open(mc)
	return true


## I numeri di una rete, in parole (per il pannello).
func net_text(ni: int) -> String:
	if ni < 0 or ni >= nets.size():
		return "[color=#ffb070]Non è su una rete: posa una vena sotto di lei con la Pinza delle vene.[/color]"
	var nt: Dictionary = nets[ni]
	var t := "[color=#8ef0e8]La rete[/color]: %d vene · %d sorgenti · %d macchine · %d riserve\n" % [(nt["cells"] as Array).size(),
		(nt["sources"] as Array).size(), (nt["users"] as Array).size(), (nt["reserves"] as Array).size()]
	t += "Le sorgenti danno [b]%d[/b] pulsi, le macchine ne chiedono [b]%d[/b]" % [roundi(float(nt["prod"])), roundi(float(nt["want"]))]
	if float(nt["cap"]) > 0.0:
		t += ", nelle riserve [b]%d[/b] gocce su %d" % [roundi(float(nt["stored"])), roundi(float(nt["cap"]))]
	return t + "."


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

## [fa luce, ha energia, trasparenza] di una macchina (per `ViewProps`).
func look(o: Vector2i) -> Array:
	var mc: Machine = machines.get(o)
	if mc == null:
		return [true, true, 1.0]
	var needs := float(mc.d.get("pulsi", 0)) > 0.0
	var powered := mc.role() != "macchina" or not needs or mc.power >= 0.99 or not mc.on()
	var glow := mc.lit if mc.d.has("light") else (mc.role() != "macchina" or mc.power >= 0.99)
	var alpha := 1.0
	match mc.role():
		"sorgente":
			glow = mc.made > 0.01
		"riserva":
			glow = float(mc.st.get("g", 0.0)) > 1.0
		"comando", "nodo":
			glow = bool(mc.st.get("out", false)) or float(mc.get_meta("flash", 0.0)) > 0.0
	if mc.d.get("porta", false):
		glow = bool(mc.st.get("open", false))
		alpha = 0.3 if glow else 1.0
		powered = true
	return [glow, powered, alpha]


func refresh_look(mc: Machine) -> void:
	var lk := look(mc.o)
	mc.set_meta("look", lk)
	m.view.props.set_machine_look(mc.o, bool(lk[0]), bool(lk[1]), float(lk[2]))


func _update_looks() -> void:
	var lights := []
	for mc: Machine in machines.values():
		if mc.has_meta("flash"):
			mc.set_meta("flash", maxf(float(mc.get_meta("flash")) - TICK, 0.0))
		var lk := look(mc.o)
		if mc.get_meta("look", []) != lk:
			mc.set_meta("look", lk)
			m.view.props.set_machine_look(mc.o, bool(lk[0]), bool(lk[1]), float(lk[2]))
		if mc.lit and mc.d.has("light"):
			lights.append([mc.o, mc.d["light"]])
	if lights != _lights:
		_lights = lights
		m.light.set_extra("rete", lights)
