class_name Encounters
extends Node
## I piccoli incontri delle grotte (Roadmap 30, voce 303; dati in `EncountersData`, luoghi di `PassIncontri`).
## Ogni mezzo secondo guarda gli incontri vicini (un indice delle loro stazioni, rifatto quando le stazioni cambiano):
## - entro `ANNOUNCE_R` tessere l'incontro si annuncia una volta (la sua scritta e un suono);
## - entro `WAKE_R` le tane e le vene madri svegliano i loro guardiani (creature dello strato, più forti; una a volte
##   antica). Se te ne vai prima di sconfiggerli, al ritorno si risvegliano quelli che mancano;
## - la vena madre e il fungo re si toccano (clic destro) una volta per il premio; lo zaino e la tana si aprono come casse
##   (la tana solo quando i guardiani sono sconfitti).
## Le Pagine strappate del diario di Tessa si leggono in ordine (`read_page`); all'ultima, la Lanterna di Tessa.
## Stato in `world_meta["incontri"]` ("x,y" -> {a: annunciato, g: guardiani nati, k: sconfitti, p: premio preso}).

const TICK := 0.5

var m: Node2D
var sites: Array[Vector2i] = []
var _rev := -1
var _t := 0.0
var _rng := RandomNumberGenerator.new()


func setup(main: Node2D) -> void:
	m = main
	_rng.randomize()
	m.fauna.killed.connect(_on_killed)


func _state(o: Vector2i) -> Dictionary:
	if not m.world_meta.has("incontri"):
		m.world_meta["incontri"] = {}
	var all: Dictionary = m.world_meta["incontri"]
	var key := "%d,%d" % [o.x, o.y]
	if not all.has(key):
		all[key] = {}
	return all[key]


func _index() -> void:
	if m.world.stations_rev() == _rev:
		return
	_rev = m.world.stations_rev()
	sites.clear()
	for o in m.world.stations:
		if EncountersData.KINDS.has(String(m.world.stations[o])):
			sites.append(o)


func _process(dt: float) -> void:
	if m == null or not m.built:
		return
	_t -= dt
	if _t > 0.0:
		return
	_t = TICK
	_index()
	var pc: Vector2i = m.player_cell()
	for o in sites:
		var d := Vector2(o).distance_to(Vector2(pc))
		if d > EncountersData.ANNOUNCE_R:
			continue
		var k := String(m.world.stations.get(o, ""))
		var e: Dictionary = EncountersData.KINDS.get(k, {})
		if e.is_empty():
			continue
		var st := _state(o)
		if not st.has("a"):
			st["a"] = 1
			m.hud.toast(String(e["hint"]))
			m.sfx.play("presenza", Vector2(o) * 16.0)
		if e.has("guards") and d <= EncountersData.WAKE_R:
			wake(o)


## Sveglia i guardiani di una tana o di una vena madre (quelli che mancano). Restituisce quanti ne sono nati.
func wake(o: Vector2i) -> int:
	var k := String(m.world.stations.get(o, ""))
	var e: Dictionary = EncountersData.KINDS.get(k, {})
	var st := _state(o)
	if not e.has("guards") or guards_alive(o) > 0:
		return 0
	if not st.has("g"):
		st["g"] = _rng.randi_range(int(e["guards"][0]), int(e["guards"][1]))
		st["k"] = 0
	var missing := int(st["g"]) - int(st["k"])
	if missing <= 0:
		return 0
	var s := StrataData.at(m.world, o.x, o.y)
	var biome := String(BiomesData.BIOMES[BiomesData.at(m.world, o.x)]["id"])
	var pool := CreaturesData.of_stratum(s, m.fauna.night, biome)
	if pool.is_empty():
		return 0
	var mult: float = float(StrataData.STRATA[s]["danger"]) * m.fauna.vigor_mult * float(e.get("mult", 1.0))
	var born := 0
	for i in missing:
		var id := _pick(pool)
		var at := _spot_near(o, i)
		var cr: Creature = m.fauna.add(id, at)
		cr.strengthen(mult, mult * DangerData.DAMAGE)
		cr.set_meta("incontro", "%d,%d" % [o.x, o.y])
		if i == 0 and _rng.randf() < 0.35:
			m.fauna.make_ancient(cr, "antica")
		born += 1
	m.hud.toast("Qualcosa si sveglia: chi custodisce questo posto ti ha sentito")
	return born


func guards_alive(o: Vector2i) -> int:
	var key := "%d,%d" % [o.x, o.y]
	var n := 0
	for c in m.fauna.list:
		if is_instance_valid(c) and String(c.get_meta("incontro", "")) == key:
			n += 1
	return n


func _on_killed(c: Creature) -> void:
	if not c.has_meta("incontro"):
		return
	var parts := String(c.get_meta("incontro")).split(",")
	var o := Vector2i(int(parts[0]), int(parts[1]))
	var st := _state(o)
	st["k"] = int(st.get("k", 0)) + 1
	if int(st["k"]) >= int(st.get("g", 0)):
		m.hud.toast("Chi custodiva questo posto è stato sconfitto: ora è tuo")
		m.objectives.bump("incontri_vinti")


## Clic destro su un incontro. Vero se l'ha gestito (la tana chiusa, il premio della vena o del fungo); falso per lasciar
## aprire lo zaino e la tana come casse.
func touch(o: Vector2i, k: String) -> bool:
	var st := _state(o)
	var e: Dictionary = EncountersData.KINDS[k]
	if e.has("guards") and (guards_alive(o) > 0 or int(st.get("k", 0)) < int(st.get("g", 1))):
		wake(o)
		m.hud.toast("Prima devi sconfiggere chi custodisce %s" % String(e["name"]).to_lower())
		return true
	if e.has("slots"):
		if not st.has("p"):
			st["p"] = 1
			m.objectives.bump("incontri")
		return false
	if st.has("p"):
		m.hud.toast("%s ha già dato quello che aveva" % e["name"])
		return true
	st["p"] = 1
	var at := Vector2(o) * 16.0 + Vector2(8, 8)
	var gifts: Array = EncountersData.MUSHROOM_GIFT if k == "fungo_re" else \
		EncountersData.VEIN_GIFT.get(clampi(StrataData.at(m.world, o.x, o.y), 2, 4), [])
	for g in gifts:
		m.drops.spawn(String(g[0]), _rng.randi_range(int(g[1]), int(g[2])), at)
	m.objectives.bump("incontri")
	m.sfx.play("dono", at)
	m.hud.toast("%s: il suo dono è tuo" % e["name"])
	return true


## Una Pagina strappata: la prossima pagina del diario di Tessa; all'ultima, la sua lanterna.
func read_page(id: String) -> bool:
	var n := int(m.character.stats.get("pagine_tessa", 0))
	if n >= EncountersData.DIARY.size():
		m.hud.toast("Hai già letto tutto il diario di Tessa")
		return false
	if not m.character.bisaccia.remove(id, 1):
		return false
	var pg: Array = EncountersData.DIARY[n]
	m.character.stats["pagine_tessa"] = n + 1
	m.guardian.lore.show_text("Diario di Tessa · %d di %d · %s" % [n + 1, EncountersData.DIARY.size(), pg[0]], String(pg[1]))
	m.objectives.bump("pagine_diario")
	if n + 1 >= EncountersData.DIARY.size():
		if m.character.bisaccia.add(EncountersData.PAGE_REWARD, 1) > 0:
			m.drops.spawn(EncountersData.PAGE_REWARD, 1, m.player.position)
		m.hud.toast("Hai letto tutto il diario: la Lanterna di Tessa è tua")
		if m.get("diary") != null:
			m.diary.note("Ho letto tutto il diario di Tessa la Cercatrice", "incontri")
	return true


func _pick(pool: Array) -> String:
	var tot := 0
	for e in pool:
		tot += int(e[1])
	var r := _rng.randi_range(1, maxi(tot, 1))
	for e in pool:
		r -= int(e[1])
		if r <= 0:
			return String(e[0])
	return String(pool[0][0])


## Un posto libero sul pavimento vicino all'incontro (a destra e a sinistra, a turno).
func _spot_near(o: Vector2i, i: int) -> Vector2:
	var w: World = m.world
	for d in range(2, 9):
		var x := o.x + (d if (i + d) % 2 == 0 else -d)
		for dy in range(-3, 4):
			var y := o.y + dy
			if not w.solid(x, y) and not w.solid(x, y - 1) and w.solid(x, y + 1):
				return Vector2(x * 16 + 8, (y + 1) * 16 - 8)
	return Vector2(o) * 16.0 + Vector2(8, -8)
