class_name TestsMotion
extends RefCounted
## Il passo delle creature (Roadmap 54, voce 423). Gruppo «moto». Misura come si muovono le creature in recinti scavati
## apposta sotto terra, lontano dalle altre prove: ognuno rifà uno dei difetti visti giocando.
##   muro       una creatura che ti insegue davanti a un muro che non può saltare: quanti salti a vuoto
##   sporgenza  sei su una sporgenza sopra di lei: quante volte si gira avanti e indietro (tremolio)
##   fuga       ferita e paurosa: smette di fuggire quando ti ha perso, si riposa, e messa all'angolo si difende
##   sbuca      le creature che vivono nella terra: non spariscono nel pavimento senza un segnale, nel cielo non cadono
##   incastro   teletrasporto e agguato non mettono il corpo nella roccia; chi ci finisce ne esce
##   folla      ventiquattro specie insieme in una grotta con gradini e sporgenze: i numeri di tutti
## Un «salto a vuoto» = un salto che ricade a meno di mezza tessera da dove era partito; un «tremolio» = due cambi di
## verso a meno di mezzo secondo; «incastrata» = il corpo (meno un pixel per lato) tocca la roccia.

var kit: TestKit
var m: Node2D
var res := {}
var nums := {}
var _base := Vector2i(-1, -1)
var _next_x := 0


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	var w: World = m.world
	var bx := clampi(w.spawn.x - 900, 60, w.w - 700)
	var top := 0
	for x in range(bx, bx + 560):
		top = maxi(top, w.surface[x])
	_base = Vector2i(bx, mini(top + 45, w.h - 80))
	_next_x = _base.x
	var ctl: bool = m.player.control
	m.player.control = false
	m.fauna.clear()
	m.senses.paused = true
	m.day.paused = true
	Mind.lit = 1.0
	await wall()
	await ledge()
	await flee()
	await cornered()
	await intent()
	await burrow()
	await sky_burrow()
	await stuck()
	await crowd()
	m.fauna.clear()
	m.senses.paused = false
	m.day.paused = false
	m.player.control = ctl
	m.player.auto_dir = 0.0
	m.vitals.refill()
	print("passo delle creature, i numeri: %s" % str(nums))
	print("passo delle creature: %s" % str(res))
	if not res.values().all(func(x: Variant) -> bool: return x == true):
		print("ATTENZIONE: le creature si muovono ancora male")


# ------------------------------------------------------------------ i recinti

## Un recinto vuoto di wd × ht celle d'aria con un bordo di roccia spesso `edge` (il pavimento `floor_t`). Restituisce
## l'angolo in alto a sinistra dell'aria. Ogni recinto nuovo sta a destra del precedente.
func _box(wd: int, ht: int, edge := 2, floor_t := 2) -> Vector2i:
	var w: World = m.world
	var o := Vector2i(_next_x + edge, _base.y)
	_next_x += wd + edge * 2 + 2
	for x in range(o.x - edge, o.x + wd + edge):
		for y in range(o.y - edge, o.y + ht + floor_t):
			var air := x >= o.x and x < o.x + wd and y >= o.y and y < o.y + ht
			w.set_tile(x, y, TileDefs.AIR if air else TileDefs.STONE)
			w.set_decor(x, y, 0)
			w.set_plat(x, y, false)
			w.liquid[y * w.w + x] = 0
	m.view.refresh_rect(Rect2i(o - Vector2i(edge, edge), Vector2i(wd + edge * 2, ht + edge + floor_t)))
	return o


func _fill(a: Vector2i, b: Vector2i, t := TileDefs.STONE) -> void:
	for x in range(a.x, b.x + 1):
		for y in range(a.y, b.y + 1):
			m.world.set_tile(x, y, t)
	m.view.refresh_rect(Rect2i(a - Vector2i(1, 1), b - a + Vector2i(3, 3)))


## Il Germogliato in piedi sulla cella c (fermo, con la Vita piena).
func _stand(c: Vector2i) -> void:
	m.snap_to(c)
	m.player.auto_dir = 0.0
	m.vitals.refill()
	await kit.frames(3)


## Una creatura con i piedi sulla cella c (sul pavimento sotto c), che non ferisce: si misura come si muove.
func _spawn(id: String, c: Vector2i) -> Creature:
	var d := CreaturesData.get_data(id)
	var pos := Vector2(c.x * 16 + 8, (c.y + 1) * 16 - float(d["half"][1]) - 0.1)
	var cr: Creature = m.fauna.add(id, pos)
	cr.damage = 0
	return cr


## Le specie che camminano (solo «cammina» tra i modi di muoversi), non boss, non d'acqua, alte al più `hy`.
func _walkers(hy := 12.0) -> Array:
	var out := []
	for id in CreaturesData.CREATURES:
		var d: Dictionary = CreaturesData.CREATURES[id]
		var bh: Array = d.get("behaviors", [])
		if d.get("boss", false) or d.get("fly", false) or d.has("water") or d.get("docile", false):
			continue
		if not "cammina" in bh or float(d["half"][1]) > hy or float(d["half"][0]) > 12.0:
			continue
		var movers := bh.filter(func(b: Variant) -> bool: return String(b) in BondsData.MOVERS)
		if movers.size() == 1 and int(d.get("speed", 0)) >= 50:
			out.append(String(id))
	out.sort()
	return out


# ------------------------------------------------------------------ l'osservatore

## Guarda le creature per `secs` secondi e conta: salti a vuoto, tremolii, fotogrammi incastrate, fotogrammi in tutto.
func _watch(list: Array, secs: float, each := Callable()) -> Dictionary:
	var st := {}
	for c in list:
		st[c] = {"floor": true, "jx": INF, "face": c.facing, "ft": -9.0, "hops": 0, "jumps": 0, "flips": 0, "stuck": 0,
			"n": 0}
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < int(secs * 1000.0):
		await kit.frames(1)
		m.vitals.refill()
		var now := (Time.get_ticks_msec() - t0) / 1000.0
		for c in list:
			if not is_instance_valid(c) or not m.fauna.list.has(c):
				continue
			var s: Dictionary = st[c]
			s["n"] = int(s["n"]) + 1
			if s["floor"] and not c.on_floor and c.vel.y < -150.0:
				s["jx"] = c.position.x
				s["jumps"] = int(s["jumps"]) + 1
			elif not s["floor"] and c.on_floor and float(s["jx"]) != INF:
				if absf(c.position.x - float(s["jx"])) < 8.0:
					s["hops"] = int(s["hops"]) + 1
				s["jx"] = INF
			s["floor"] = c.on_floor
			if c.facing != int(s["face"]):
				if now - float(s["ft"]) < 0.5:
					s["flips"] = int(s["flips"]) + 1
				s["ft"] = now
				s["face"] = c.facing
			if _inside(c):
				s["stuck"] = int(s["stuck"]) + 1
		if each.is_valid():
			each.call(now)
	return st


## Il corpo tocca la roccia? (Chi nuota nella terra o è appeso non conta.)
func _inside(c: Creature) -> bool:
	if c.ghost or c.buried or c.anchored or c.tame != null:
		return false
	return TileBody.collides(m.world, c.position, c.half - Vector2(1, 1))


func _sum(st: Dictionary, k: String) -> int:
	var n := 0
	for c in st:
		n += int(st[c][k])
	return n


# ------------------------------------------------------------------ le prove

## Un muro alto sette tessere tra lei e il Germogliato: salti a vuoto in 6 s (prima: uno a ogni atterraggio).
func wall() -> void:
	var ids := _walkers()
	if ids.is_empty():
		print("ATTENZIONE: nessuna creatura che cammina per la prova del muro")
		return
	var o := _box(40, 12)
	var fy := o.y + 11
	_fill(Vector2i(o.x + 20, fy - 6), Vector2i(o.x + 21, fy))
	await _stand(Vector2i(o.x + 26, fy))
	var list := []
	for k in 3:
		var cr := _spawn(String(ids[(k * 7) % ids.size()]), Vector2i(o.x + 8 + k * 4, fy))
		cr.mind.brave = true
		list.append(cr)
	var st := await _watch(list, 6.0)
	var hops := _sum(st, "hops")
	m.fauna.clear()
	nums["muro_salti_a_vuoto"] = hops
	res["muro"] = hops <= 3
	print("muro: tre creature davanti a un muro di 7 tessere, salti a vuoto in 6 s: %d (salti in tutto %d)" % [hops,
		_sum(st, "jumps")])


## Il Germogliato su una sporgenza quattro tessere sopra: tremolii in 6 s.
func ledge() -> void:
	var ids := _walkers()
	if ids.is_empty():
		return
	var o := _box(30, 12)
	var fy := o.y + 11
	_fill(Vector2i(o.x + 13, fy - 4), Vector2i(o.x + 17, fy - 4))
	await _stand(Vector2i(o.x + 15, fy - 5))
	var list := []
	for k in 3:
		var cr := _spawn(String(ids[(k * 5 + 2) % ids.size()]), Vector2i(o.x + 6 + k * 8, fy))
		cr.mind.brave = true
		list.append(cr)
	var st := await _watch(list, 6.0)
	var flips := _sum(st, "flips")
	m.fauna.clear()
	nums["sporgenza_tremolii"] = flips
	res["sporgenza"] = flips <= 6
	print("sporgenza: tre creature sotto il Germogliato, tremolii in 6 s: %d" % flips)


## Ferita e paurosa, con tanto spazio: fugge, ti perde di vista, smette di fuggire e si cura un poco.
func flee() -> void:
	var ids := _walkers()
	if ids.is_empty():
		return
	var o := _box(84, 8)
	var fy := o.y + 7
	await _stand(Vector2i(o.x + 4, fy))
	var cr := _spawn(String(ids[3 % ids.size()]), Vector2i(o.x + 12, fy))
	cr.mind.brave = false
	cr.hp = maxi(1, cr.hp_max / 10)
	var hp0 := cr.hp
	var states := {}
	var st := await _watch([cr], 16.0, func(_t: float) -> void:
		if is_instance_valid(cr):
			states[cr.mind.state] = true)
	var alive: bool = is_instance_valid(cr) and m.fauna.list.has(cr)
	var calm: bool = alive and cr.mind.state != Mind.FLEE
	var healed: bool = alive and cr.hp > hp0
	var hops := _sum(st, "hops")
	var dist: float = (cr.position.x - m.player.position.x) / 16.0 if alive else -1.0
	m.fauna.clear()
	nums["fuga"] = {"stati": states.keys(), "lontana": roundi(dist), "salti_a_vuoto": hops}
	res["fuga"] = calm and healed and hops <= 3 and dist > 20.0
	print("fuga: lontana %d tessere, alla fine %s, si cura %s, salti a vuoto %d, stati %s" % [roundi(dist),
		cr.mind.label() if alive else "sparita", healed, hops, str(states.keys())])


## Messa all'angolo (un muro alle spalle, il Germogliato a tre tessere): non salta contro il muro, si difende.
func cornered() -> void:
	var ids := _walkers()
	if ids.is_empty():
		return
	var o := _box(22, 8)
	var fy := o.y + 7
	await _stand(Vector2i(o.x + 14, fy))
	var cr := _spawn(String(ids[3 % ids.size()]), Vector2i(o.x + 18, fy))
	cr.mind.brave = false
	cr.hp = maxi(1, cr.hp_max / 10)
	var fought := [false]
	var st := await _watch([cr], 7.0, func(_t: float) -> void:
		if is_instance_valid(cr) and cr.mind.state != Mind.FLEE and absf(cr.position.x - m.player.position.x) < 40.0:
			fought[0] = true)
	var hops := _sum(st, "hops")
	m.fauna.clear()
	nums["angolo"] = {"salti_a_vuoto": hops, "si_difende": fought[0]}
	res["angolo"] = hops <= 3 and fought[0]
	print("all'angolo: salti a vuoto %d, si difende %s" % [hops, fought[0]])


## Voce 427: una creatura che carica, ferita e paurosa, a quattro tessere: fugge e non si gira a caricarti.
func intent() -> void:
	var cid := ""
	for id in CreaturesData.CREATURES:
		var d: Dictionary = CreaturesData.CREATURES[id]
		var bh: Array = d.get("behaviors", [])
		if "cammina" in bh and "carica" in bh and not d.get("fly", false) and not d.get("boss", false) 				and float(d["half"][1]) <= 12.0 and not d.has("water"):
			cid = String(id)
			break
	if cid == "":
		print("ATTENZIONE: nessuna creatura che carica per la prova delle intenzioni")
		return
	var o := _box(60, 8)
	var fy := o.y + 7
	await _stand(Vector2i(o.x + 20, fy))
	var cr := _spawn(cid, Vector2i(o.x + 24, fy))
	cr.mind.brave = false
	cr.hp = maxi(1, cr.hp_max / 10)
	var starts := [0]
	var was := [0.0]
	await _watch([cr], 5.0, func(_t: float) -> void:
		if not is_instance_valid(cr):
			return
		if cr.tele > 0.0 and was[0] <= 0.0 and cr.mind.state in [Mind.FLEE, Mind.REST]:
			starts[0] += 1
		was[0] = cr.tele)
	m.fauna.clear()
	nums["cariche_in_fuga"] = starts[0]
	res["intenzione"] = starts[0] == 0
	print("intenzione (%s): cariche cominciate mentre fugge %d" % [cid, starts[0]])


## Le creature della terra («sbuca»): ogni volta che una sparisce nel pavimento, prima trema e solleva polvere.
func burrow() -> void:
	var ids := []
	for id in CreaturesData.CREATURES:
		var d: Dictionary = CreaturesData.CREATURES[id]
		if "sbuca" in (d.get("behaviors", []) as Array) and not d.get("boss", false) and not d.has("sky"):
			ids.append(String(id))
	ids.sort()
	if ids.is_empty():
		print("ATTENZIONE: nessuna creatura che sbuca")
		return
	var o := _box(34, 8, 2, 6)
	var fy := o.y + 7
	await _stand(Vector2i(o.x + 17, fy))
	var list := []
	for k in mini(3, ids.size()):
		var cr := _spawn(String(ids[k]), Vector2i(o.x + 4 + k * 12, fy))
		list.append(cr)
	var warn := {}
	var shown := {}
	var silent := [0]
	var sinks := [0]
	var born_in := 0
	for c in list:
		warn[c] = -9.0
		shown[c] = not c.buried                  # (voce 424) nasce già nella terra: non la si vede affondare
		born_in += 1 if c.buried else 0
	var t_all := [0.0]
	await _watch(list, 14.0, func(t: float) -> void:
		t_all[0] = t
		for c in list:
			if not is_instance_valid(c):
				continue
			if c.tele > 0.0 or c.shake > 0.0:
				warn[c] = t
			var vis: bool = not c.buried
			if bool(shown[c]) and not vis:
				sinks[0] += 1
				if t - float(warn[c]) > 0.6:
					silent[0] += 1
			shown[c] = vis)
	m.fauna.clear()
	nums["sbuca"] = {"sparite_nella_terra": sinks[0], "senza_segnale": silent[0], "nate_nella_terra": born_in}
	res["sbuca"] = silent[0] == 0 and sinks[0] >= 1
	print("sbuca: nate nella terra %d su %d, %d volte nella terra, %d senza segnale" % [born_in, list.size(), sinks[0], silent[0]])


## Il Mangiastelle del cielo su un'isola sottile sopra il vuoto: non attraversa l'isola e non cade.
func sky_burrow() -> void:
	var id := ""
	for k in CreaturesData.CREATURES:
		var d: Dictionary = CreaturesData.CREATURES[k]
		if "sbuca" in (d.get("behaviors", []) as Array) and d.has("sky") and not d.get("boss", false):
			id = String(k)
	if id == "":
		print("ATTENZIONE: nessuna creatura del cielo che sbuca")
		return
	var o := _box(40, 30)
	var iy := o.y + 12
	_fill(Vector2i(o.x + 10, iy), Vector2i(o.x + 29, iy + 1))
	await _stand(Vector2i(o.x + 14, iy - 1))
	var cr := _spawn(id, Vector2i(o.x + 25, iy - 1))
	var lost := [false]
	await _watch([cr], 12.0, func(_t: float) -> void:
		if is_instance_valid(cr) and cr.position.y > (iy + 3) * 16.0:
			lost[0] = true)
	m.fauna.clear()
	nums["sbuca_cielo_caduta"] = lost[0]
	res["sbuca_cielo"] = not lost[0]
	print("sbuca nel cielo: %s cade sotto l'isola %s" % [id, lost[0]])


## Teletrasporto e agguato con le specie più grandi; una creatura messa dentro la roccia ne esce.
func stuck() -> void:
	var tp := _largest("teletrasporto")
	var ag := _largest("agguato")
	var bad_tp := 0
	var tries := 0
	if tp != "":
		var o := _box(36, 3)
		var fy := o.y + 2
		for x in range(o.x + 4, o.x + 34, 5):
			_fill(Vector2i(x, fy), Vector2i(x, fy))       # gradini sparsi nel cunicolo
		await _stand(Vector2i(o.x + 18, fy - 1))
		var cr := _spawn(tp, Vector2i(o.x + 2, fy))
		var bh: BhTeletrasporto = null
		for b in cr.behaviors:
			if b is BhTeletrasporto:
				bh = b
		for k in 30:
			cr.target = m.player
			bh._jump(cr)
			tries += 1
			if TileBody.collides(m.world, cr.position, cr.half - Vector2(1, 1)):
				bad_tp += 1
		m.fauna.clear()
	var bad_ag := 0
	var ag_n := 0
	if ag != "":
		var o2 := _box(30, 10)
		var fy2 := o2.y + 9
		for x in range(o2.x, o2.x + 30, 2):
			_fill(Vector2i(x, o2.y), Vector2i(x, o2.y + (x / 2) % 3))   # un soffitto frastagliato
		await _stand(Vector2i(o2.x + 28, fy2))
		var list := []
		for x in range(o2.x + 2, o2.x + 26, 3):
			list.append(_spawn(ag, Vector2i(x, fy2)))
		await kit.frames(3)
		for c in list:
			if is_instance_valid(c):
				ag_n += 1
				if TileBody.collides(m.world, c.position, c.half - Vector2(1, 1)):
					bad_ag += 1
		m.fauna.clear()
	# una creatura dentro un masso: ne esce da sola
	var ids := _walkers()
	var freed := false
	if not ids.is_empty():
		var o3 := _box(20, 8)
		var fy3 := o3.y + 7
		_fill(Vector2i(o3.x + 6, fy3 - 4), Vector2i(o3.x + 12, fy3))      # un masso 7 × 5: la fisica da sola non la spinge fuori
		await _stand(Vector2i(o3.x + 16, fy3))
		var cr3 := _spawn(String(ids[0]), Vector2i(o3.x + 9, fy3 - 2))
		cr3.mind.brave = true
		await kit.seconds(1.5)
		freed = is_instance_valid(cr3) and not _inside(cr3)
		m.fauna.clear()
	nums["incastro"] = {"teletrasporto": "%d/%d" % [bad_tp, tries], "agguato": "%d/%d" % [bad_ag, ag_n], "esce": freed}
	res["incastro"] = bad_tp == 0 and bad_ag == 0 and freed
	print("incastro: teletrasporto (%s) nella roccia %d volte su %d, agguato (%s) %d su %d, dal masso esce %s" % [tp,
		bad_tp, tries, ag, bad_ag, ag_n, freed])


## La specie più grande (larghezza × altezza) con un comportamento, non boss.
func _largest(bh: String) -> String:
	var best := ""
	var area := 0.0
	for id in CreaturesData.CREATURES:
		var d: Dictionary = CreaturesData.CREATURES[id]
		if not bh in (d.get("behaviors", []) as Array) or d.get("boss", false) or d.has("water"):
			continue
		var a := float(d["half"][0]) * float(d["half"][1])
		if a > area:
			area = a
			best = String(id)
	return best


## Ventiquattro specie in una grotta con gradini, sporgenze e colonne, attorno al Germogliato.
func crowd() -> void:
	var ids := []
	for id in CreaturesData.CREATURES:
		var d: Dictionary = CreaturesData.CREATURES[id]
		if d.get("boss", false) or d.has("water") or d.has("sky") or d.has("perduto") or int(d.get("damage", 0)) <= 0:
			continue
		if float(d["half"][0]) > 16.0 or float(d["half"][1]) > 16.0:
			continue
		ids.append(String(id))
	ids.sort()
	var o := _box(70, 16)
	var fy := o.y + 15
	_fill(Vector2i(o.x + 10, fy - 1), Vector2i(o.x + 14, fy))             # un gradino
	_fill(Vector2i(o.x + 20, fy - 5), Vector2i(o.x + 27, fy - 5))         # una sporgenza
	_fill(Vector2i(o.x + 40, fy - 3), Vector2i(o.x + 41, fy))             # una colonna bassa
	_fill(Vector2i(o.x + 50, fy - 8), Vector2i(o.x + 51, fy))             # una colonna alta
	_fill(Vector2i(o.x + 56, fy - 2), Vector2i(o.x + 69, fy))             # un rialzo
	await _stand(Vector2i(o.x + 33, fy))
	var list := []
	var n := 24
	for k in n:
		var id := String(ids[(k * ids.size()) / n])
		var x := o.x + 2 + (k * 67) / n
		var cy := fy
		while m.world.solid(x, cy) or m.world.solid(x, cy - 1):
			cy -= 1
		var cr := _spawn(id, Vector2i(x, cy))
		if cr.fly:
			cr.position.y -= 32.0
		list.append(cr)
	var st := await _watch(list, 10.0)
	await kit.save("330_moto_folla")
	var frames := maxi(_sum(st, "n"), 1)
	var stuck_f := _sum(st, "stuck")
	var flips := _sum(st, "flips")
	var hops := _sum(st, "hops")
	var secs := float(frames) / 60.0
	m.fauna.clear()
	nums["folla"] = {"incastrate_%": snappedf(100.0 * stuck_f / frames, 0.01), "tremolii_al_minuto": snappedf(flips * 60.0 / maxf(secs, 0.1), 0.1),
		"salti_a_vuoto_al_minuto": snappedf(hops * 60.0 / maxf(secs, 0.1), 0.1)}
	res["folla"] = stuck_f * 100 < frames and flips * 60.0 / maxf(secs, 0.1) < 6.0 and hops * 60.0 / maxf(secs, 0.1) < 3.0
	print("folla: %d specie, incastrate %.2f%% dei fotogrammi, tremolii %.1f al minuto per creatura, salti a vuoto %.1f al minuto" % [
		n, 100.0 * stuck_f / frames, flips * 60.0 / maxf(secs, 0.1), hops * 60.0 / maxf(secs, 0.1)])
