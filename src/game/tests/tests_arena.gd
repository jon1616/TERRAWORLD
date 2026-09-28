class_name TestsArena
extends RefCounted
## Voce 180 (Roadmap 18 «Il bilancio»): il bot in arena. Un recinto piano in superficie, il Germogliato guidato da un
## bot che gioca come una persona media (si avvicina, colpisce quando è a portata, salta verso chi vola, arretra un
## attimo dopo una ferita, salta i proiettili che vede arrivare con un ritardo di reazione, prende l'arco se la
## creatura resta fuori portata), creature vere con i loro comportamenti veri, rinforzate come le farebbe nascere
## `Fauna` nello strato. Tre scenari per strato:
##   duello    una creatura alla volta, vista arrivare da lontano
##   sorpresa  una creatura che arriva alle spalle mentre il bot è occupato (un secondo senza reagire)
##   gruppo    tre creature insieme, da due parti
## Per ogni scontro: secondi, Vita persa e ferite, accanto a `FightModel` con l'abilità «bot». In fondo i numeri che
## tarano il modello (contatti al secondo, ferite d'apertura, quanto pesa un gruppo). Scrive prove/arena.txt.
## Solo con `--solo=arena` (è una misura lunga, non una prova del giro).

const S := 16
const HALF := 30                       # mezza larghezza del recinto, in tessere
const PER_STRATUM := 5                 # specie per strato (le più frequenti che feriscono)
const LIMIT := 30.0                    # secondi al più per uno scontro
const REACT := 0.25                    # ritardo di reazione ai proiettili
const BUSY := 1.0                      # secondi senza reagire nella sorpresa
const MATS := ["radicite", "radicite", "legnoferro", "ambra", "linfa"]

var kit: TestKit
var m: Node
var out := ""
var _hurt_sum := 0
var _hurt_n := 0
## Somme per scenario: t (secondi), l (Vita persa), n (ferite), c (creature), tm, lm (modello), f (scontri)
var sums := {}


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	var w: World = m.world
	var spot := kit.flat_spot(w.spawn, 12)
	if spot.x < 0:
		spot = w.spawn
		print("ATTENZIONE: arena: nessun posto piano, uso la partenza")
	_build(spot)
	m.fauna.clear()
	m.day.paused = true
	var ctl: bool = m.player.control
	m.player.control = false
	var hp0: int = m.vitals.hp_max
	m.vitals.wounded.connect(_on_wounded)
	var b: Bisaccia = kit.bisaccia()
	var eq0: Dictionary = b.equip.duplicate()
	_p("ARENA (voce 180): bot contro creature vere; modello = FightModel con l'abilità «bot»")
	_p("%-9s %-40s %-9s | %6s %6s | %6s %6s | ferite" % ["scontro", "creature", "metallo", "s vero", "s mod", "Vita v", "Vita m"])
	for sc in ["duello", "sorpresa", "gruppo"]:
		sums[sc] = {"t": 0.0, "l": 0.0, "n": 0, "c": 0, "tm": 0.0, "lm": 0.0, "f": 0, "slow": 0}
	for s in StrataData.STRATA.size():
		var mat: String = MATS[s]
		_wear(b, mat)
		var sp := _species(s)
		for id in sp:
			await _fight(spot, [id], s, mat, "duello")
		for k in mini(2, sp.size()):
			await _fight(spot, [sp[k]], s, mat, "sorpresa")
		if sp.size() >= 3:
			await _fight(spot, sp.slice(0, 3), s, mat, "gruppo")
	_p("")
	for sc in sums:
		var e: Dictionary = sums[sc]
		_p("%-9s: %d scontri, %d creature, tempo vero/modello %.2f, Vita vera/modello %.2f, ferite per creatura %.2f, ferite al secondo %.2f, Vita per creatura %.1f%s" % [
			sc, int(e["f"]), int(e["c"]), float(e["t"]) / maxf(float(e["tm"]), 0.01), float(e["l"]) / maxf(float(e["lm"]), 0.01),
			float(e["n"]) / maxi(int(e["c"]), 1), float(e["n"]) / maxf(float(e["t"]), 0.01), float(e["l"]) / maxi(int(e["c"]), 1),
			(", %d non finiti" % int(e["slow"])) if int(e["slow"]) > 0 else ""])
	# com'era
	m.vitals.wounded.disconnect(_on_wounded)
	b.equip = eq0
	b.changed.emit()
	m.vitals.hp_max = hp0
	m.vitals.refill()
	m.player.control = ctl
	_release()
	m.day.paused = false
	var f := FileAccess.open("res://prove/arena.txt", FileAccess.WRITE)
	if f:
		f.store_string(out)


func _p(s: String) -> void:
	print(s)
	out += s + "\n"


func _on_wounded(n: int) -> void:
	_hurt_sum += n
	_hurt_n += 1


func _release() -> void:
	m.player.auto_dir = 0.0
	m.player.auto_jump = false
	m.player.force_swing = false
	m.combat.auto_fire = false
	m.combat.auto_aim = Vector2.INF


## Un recinto: pavimento di pietra, aria alta 10 tessere, due muri alle estremità.
func _build(c: Vector2i) -> void:
	var w: World = m.world
	for x in range(c.x - HALF - 1, c.x + HALF + 2):
		for y in range(c.y - 12, c.y + 1):
			var t := w.tree_at(Vector2i(x, y))
			if t.x >= 0:
				m.actions.fell_tree(t)
	for x in range(c.x - HALF - 1, c.x + HALF + 2):
		w.set_tile(x, c.y + 1, TileDefs.STONE)
		for y in range(c.y - 10, c.y + 1):
			var wall := absi(x - c.x) > HALF
			if w.station_at(Vector2i(x, y)).is_empty():
				w.set_tile(x, y, TileDefs.STONE if wall else TileDefs.AIR)
				w.set_decor(x, y, 0)
	for x in range(c.x - HALF - 1, c.x + HALF + 2, 8):
		m.view.refresh_around(Vector2i(x, c.y))
	m.view.refresh_around(Vector2i(c.x + HALF + 1, c.y))


## L'armatura intera di un metallo.
func _wear(b: Bisaccia, mat: String) -> void:
	b.equip = {}
	b.equip_traits = {}
	b.equip_data = {}
	for piece in ["elmo", "corazza", "gambali", "guanti", "stivali"]:
		if not ItemsData.get_item("%s_%s" % [piece, mat]).is_empty():
			b.equip[piece] = "%s_%s" % [piece, mat]
	b.changed.emit()


## Le specie più frequenti di uno strato che feriscono (niente acqua, niente boss).
func _species(s: int) -> Array:
	var pl := ZoneModel.pool(s)
	var ids := pl.keys()
	ids.sort_custom(func(a: Variant, bb: Variant) -> bool: return float(pl[a]) > float(pl[bb]))
	var out_ids := []
	for id in ids:
		var d := CreaturesData.get_data(String(id))
		if d.get("boss", false) or d.has("water") or int(d.get("damage", 0)) <= 0:
			continue
		out_ids.append(id)
		if out_ids.size() >= PER_STRATUM:
			break
	return out_ids


func _spawn(id: String, s: int, cell_x: int, y: int) -> Creature:
	var d := CreaturesData.get_data(id)
	var pos := Vector2(cell_x * S + 8, (y + 1) * S - float(d["half"][1]) - 0.1)
	if d.get("fly", false):
		pos.y -= 3 * S
	var cr: Creature = m.fauna.add(id, pos)
	var mult := float(StrataData.STRATA[s]["danger"])
	cr.strengthen(mult, mult * DangerData.DAMAGE)
	return cr


## Uno scontro con una o più creature.
func _fight(spot: Vector2i, ids: Array, s: int, mat: String, scene: String) -> void:
	var v: Vitals = m.vitals
	v.hp_max = 5000
	v.refill()
	var sword := "spada_" + mat
	var bow := "arco_" + mat
	if kit.bisaccia().count("dardo") < 200:
		kit.bisaccia().add("dardo", 300)
	kit.hold(sword)
	m.snap_to(spot)
	await kit.frames(3)
	var crs: Array[Creature] = []
	var hps := []
	for k in ids.size():
		var side := 1 if (k % 2 == 0) == (randf() < 0.5) else -1
		var dist := 9 + k
		if scene == "sorpresa":
			dist = 3
			side = -m.player.facing
		crs.append(_spawn(String(ids[k]), s, spot.x + side * dist, spot.y))
		hps.append(crs[k].hp_max)
	_hurt_sum = 0
	_hurt_n = 0
	var t := 0.0
	var back_t := 0.0
	var jump_t := 0.0
	var seen := {}
	var last_hurt := 0
	var ranged := false
	var out_of_reach := 0.0
	var busy := BUSY if scene == "sorpresa" else 0.0
	while t < LIMIT:
		await m.get_tree().process_frame
		var dt: float = m.get_process_delta_time()
		var alive: Array[Creature] = []
		for c in crs:
			if is_instance_valid(c) and m.fauna.list.has(c):
				alive.append(c)
		if alive.is_empty():
			break
		t += dt
		var p: Player = m.player
		if busy > 0.0:
			busy -= dt                             # occupato (scava, legge): non si accorge di niente
			continue
		var cr: Creature = alive[0]
		for c in alive:
			if c.position.distance_to(p.position) < cr.position.distance_to(p.position):
				cr = c
		var dx := cr.position.x - p.position.x
		var dy := cr.position.y - p.position.y
		if _hurt_n > last_hurt:
			last_hurt = _hurt_n
			back_t = 0.35                          # un attimo indietro dopo una ferita
		back_t -= dt
		jump_t -= dt
		p.facing = 1 if dx >= 0.0 else -1
		# chi resta alto fuori portata: dopo qualche secondo si prende l'arco
		if not ranged and cr.fly and dy < -2.5 * S:
			out_of_reach += dt
			if out_of_reach > 3.0:
				ranged = true
				kit.hold(bow)
				p.force_swing = false
		if ranged:
			var want := 6.0 * S
			p.auto_dir = -signf(dx) if absf(dx) < want - S else (signf(dx) if absf(dx) > want + 3 * S else 0.0)
			m.combat.auto_aim = cr.position
			m.combat.auto_fire = true
		else:
			if back_t > 0.0:
				p.auto_dir = -signf(dx)
			else:
				p.auto_dir = signf(dx) if absf(dx) > 22.0 else 0.0
			p.force_swing = absf(dx) < 40.0 and absf(dy) < 40.0
			if dy < -20.0 and absf(dx) < 3.0 * S and p.on_floor:
				jump_t = 0.2                       # chi vola: si salta per colpirla
		# i proiettili: visti arrivare, dopo il tempo di reazione si salta
		for sh in m.shots._shots:
			if bool(sh["player"]) or not is_instance_valid(sh["node"]):
				continue
			var n: Node2D = sh["node"]
			var key := n.get_instance_id()
			var rel: Vector2 = p.position - n.position
			if rel.length() < 7.0 * S and rel.dot(sh["vel"]) > 0.0:
				if not seen.has(key):
					seen[key] = t
				elif t - float(seen[key]) >= REACT and p.on_floor:
					jump_t = 0.2
		p.auto_jump = jump_t > 0.0
	_release()
	var left := 0
	for c in crs:
		if is_instance_valid(c) and m.fauna.list.has(c):
			left += 1
	if left > 0:
		m.fauna.clear()
	await kit.seconds(0.3)
	# il modello: la somma dei duelli con le stesse creature e lo stesso equipaggiamento
	var fx := FightModel.effects(_equip_cells())
	var wm := FightModel.weapon({"id": sword}, fx)
	var tm := 0.0
	var lm := 0.0
	var names := []
	for k in ids.size():
		var f := FightModel.foe(String(ids[k]), s, 1)
		f["hp"] = float(hps[k])
		var du := FightModel.duel(wm, int(fx["scorza"]), 5000.0, f, FightModel.SKILL["bot"])
		tm += float(du["ttk"])
		lm += float(du["lost"])
		names.append(String(CreaturesData.get_data(String(ids[k])).get("name", ids[k])).left(14))
	var e: Dictionary = sums[scene]
	e["t"] = float(e["t"]) + t
	e["l"] = float(e["l"]) + _hurt_sum
	e["n"] = int(e["n"]) + _hurt_n
	e["c"] = int(e["c"]) + ids.size()
	e["tm"] = float(e["tm"]) + tm
	e["lm"] = float(e["lm"]) + lm
	e["f"] = int(e["f"]) + 1
	if left > 0:
		e["slow"] = int(e["slow"]) + 1
	_p("%-9s %-40s %-9s | %5.1fs %5.1fs | %6d %6.0f | %d%s%s" % [scene, ", ".join(names).left(40), mat.left(9), t, tm, _hurt_sum,
		lm, _hurt_n, " (arco)" if ranged else "", ("  (%d non abbattute)" % left) if left > 0 else ""])


func _equip_cells() -> Dictionary:
	var out_e := {}
	var b: Bisaccia = kit.bisaccia()
	for k in b.equip:
		out_e[k] = {"id": String(b.equip[k])}
	return out_e
