class_name Powers
extends Node
## I poteri del Germogliato (voce 64, dati in `PowersData`): li dona l'Albero-Madre con i suoi stadi (`MotherTreeData`)
## e valgono in ogni mondo. Aprono i luoghi chiusi dai **Sigilli** (`PassSigilli`: clic destro su un Sigillo, se si ha
## il potere giusto il Sigillo intero si dissolve) e aiutano a muoversi:
##   vista   tasto V: per qualche secondo brillano attorno le vene di minerale, i Sigilli (anche quelli velati, che
##           sembrano ardesia) e gli scrigni
##   canto   apre i Sigilli di radice; scavo un po' più rapido
##   passo   apre i Veli del Vuoto; il Vuoto del Giardino non ferisce più
##   brace   apre i Muri di brace; +3 Scorza
##   salto   un salto in aria in più, salti più alti
##   ponte   tasto F: una passerella di radici verso il mouse (fino a `BRIDGE` tessere), che dura `BRIDGE_TIME` secondi
## Gli effetti continui passano da `GearEffects` (`bonuses`), come gli accessori.

const S := 16
const VISTA_TIME := 8.0
const VISTA_R := 22
const BRIDGE := 12
const BRIDGE_TIME := 60.0

var m: Node2D
var owned: Array = []
var extra: Array = []                  # poteri dati a mano (le prove)
var _vista_t := 0.0
var _bridges: Array = []               # [celle, secondi che restano]
var _bridge_cd := 0.0


func setup(main: Node2D) -> void:
	m = main
	# i luoghi sigillati del mondo (dagli appunti del generatore), per la Mappa dei Sigilli
	if m.world.gen_notes.has("sigilli") and not m.world_meta.has("sigilli"):
		var out := []
		for e in m.world.gen_notes["sigilli"]:
			out.append([String(e[0]), int(e[1].x), int(e[1].y)])
		m.world_meta["sigilli"] = out
	refresh()


func refresh() -> void:
	owned = MotherTreeData.gifts(m.albero.stage(), "power") if m.albero != null and m.albero.has_garden() else []
	for p in extra:
		if not p in owned:
			owned.append(p)
	m.gear.refresh()


func has(p: String) -> bool:
	return p in owned


func bonuses() -> Array:
	var out := []
	if has("salto"):
		out.append({"air_jumps": 1, "jump": 1.2})
	if has("canto"):
		out.append({"dig": 1.25})
	if has("brace"):
		out.append({"defense": 3})
	return out


func _unhandled_input(e: InputEvent) -> void:
	if not (e is InputEventKey) or not e.pressed or e.echo or m.hud.is_open():
		return
	if Keys.pressed(e, "vista") and has("vista"):
		vista()
		get_viewport().set_input_as_handled()
	elif Keys.pressed(e, "ponte") and has("ponte"):
		bridge(m.fx.get_global_mouse_position())
		get_viewport().set_input_as_handled()


## Vista della Linfa: le vene, i Sigilli e gli scrigni attorno fanno luce per qualche secondo.
func vista() -> Dictionary:
	var pc: Vector2i = m.player_cell()
	var ores := {}
	for o in TileDefs.ORES:
		ores[int(o["type"])] = true
	var seals: Array = TileDefs.SEALS.values()
	var lights := []
	var n_ore := 0
	var n_seal := 0
	for dy in range(-VISTA_R, VISTA_R + 1):
		for dx in range(-VISTA_R, VISTA_R + 1):
			var c := pc + Vector2i(dx, dy)
			if not m.world.inside(c.x, c.y):
				continue
			var t: int = m.world.tile(c.x, c.y)
			if t in seals:
				n_seal += 1
				if n_seal % 2 == 0:
					lights.append([c, Color(0.6, 1.2, 1.1)])
			elif ores.has(t):
				n_ore += 1
				if n_ore % 3 == 0 and lights.size() < 160:
					lights.append([c, Color(0.9, 0.7, 0.3)])
	var chests := 0
	for o in m.world.stations:
		if String(m.world.stations[o]) in ["scrigno", "reliquiario"] and Vector2(o - pc).length() <= VISTA_R:
			lights.append([o, Color(1.2, 1.0, 0.5)])
			chests += 1
	m.light.set_extra("vista", lights)
	_vista_t = VISTA_TIME
	Fx.puff(m.fx, m.player.position, Color(0.8, 1.7, 1.5))
	m.hud.toast("La Linfa ti mostra: %d vene, %d Sigilli, %d scrigni" % [n_ore, n_seal, chests])
	return {"vene": n_ore, "sigilli": n_seal, "scrigni": chests}


## Radici-ponte: una passerella dalla cella dei piedi verso il punto, fino a `BRIDGE` tessere, per un minuto.
func bridge(to: Vector2) -> int:
	if _bridge_cd > 0.0:
		return 0
	var from: Vector2 = m.player.position + Vector2(0, Player.HALF.y + 2)
	var d := to - from
	var steps := mini(BRIDGE, int(d.length() / S) + 1)
	var cells := []
	for i in range(1, steps + 1):
		var p := from + d.normalized() * i * S
		var c := Vector2i(floori(p.x / S), floori(p.y / S))
		if not m.world.inside(c.x, c.y) or m.world.solid(c.x, c.y):
			break
		if not m.world.plat(c.x, c.y):
			m.world.set_plat(c.x, c.y, true)
			m.view.refresh_around(c)
			cells.append(c)
	if not cells.is_empty():
		_bridges.append([cells, BRIDGE_TIME])
		_bridge_cd = 1.0
		m.sfx.play("legno", m.player.position)
	return cells.size()


## Clic destro su un Sigillo (da `Interact.touch`): con il potere giusto si dissolve tutto il Sigillo.
func open_seal(c: Vector2i) -> bool:
	var t: int = m.world.tile(c.x, c.y)
	var kind := String(TileDefs.SEAL_KIND.get(t, ""))
	if kind == "":
		return false
	var need := ""
	for p in PowersData.POWERS:
		if String(PowersData.POWERS[p]["seal"]) == kind:
			need = p
	if not has(need):
		m.hud.toast("%s: serve il potere «%s», un dono dell'Albero-Madre" % [TileDefs.NAMES.get(t, "Sigillo"),
			PowersData.POWERS[need]["name"]])
		return true
	# si dissolve tutto il Sigillo collegato (al più 300 tessere)
	var todo: Array[Vector2i] = [c]
	var seen := {c: true}
	var n := 0
	while not todo.is_empty() and n < 300:
		var q: Vector2i = todo.pop_back()
		m.world.set_tile(q.x, q.y, TileDefs.AIR)
		n += 1
		for o in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var r: Vector2i = q + o
			if not seen.has(r) and m.world.inside(r.x, r.y) and m.world.tile(r.x, r.y) == t:
				seen[r] = true
				todo.append(r)
	for q in seen:
		if (q.x + q.y) % 4 == 0:
			m.view.refresh_around(q)
	m.view.refresh_around(c)
	m.light.dirty = true
	Fx.puff(m.fx, Vector2(c) * S + Vector2(8, 8), Color(0.9, 1.7, 1.5))
	m.sfx.play("portale", Vector2(c) * S)
	m.objectives.bump("sigilli")
	m.hud.toast("Il Sigillo si dissolve")
	return true


func _process(dt: float) -> void:
	if _vista_t > 0.0:
		_vista_t -= dt
		if _vista_t <= 0.0:
			m.light.set_extra("vista", [])
	_bridge_cd = maxf(_bridge_cd - dt, 0.0)
	for i in range(_bridges.size() - 1, -1, -1):
		_bridges[i][1] = float(_bridges[i][1]) - dt
		if float(_bridges[i][1]) <= 0.0:
			for c in _bridges[i][0]:
				m.world.set_plat(c.x, c.y, false)
				m.view.refresh_around(c)
			_bridges.remove_at(i)
