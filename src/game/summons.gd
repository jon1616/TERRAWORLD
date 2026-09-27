class_name Summons
extends Node
## Evocare i Guardiani già risolti (voce 84, dati in `SummonData`). I Guardiani affrontati si ricordano nel personaggio
## (`Character.guardiani`: id della creatura → {"volte", "nome"}); vicino al Cerchio dei Seminatori (stazione `arena`)
## un Richiamo (Guardiani scritti a mano) o il Sigillo del Guardiano con un Seme d'eco (Guardiani generati) lo
## risveglia. Durante lo scontro attorno al Cerchio non nasce niente (`Fauna.quiet_c`), e il Guardiano lascia un bottino
## più magro del primo incontro: niente Semi di mondo, Linfa antica né Vita per sempre. Il Sigillo lo dona il Cuore la
## prima volta che un Guardiano generato è risolto.

var m: Node2D
var active: Creature
var arena := Vector2i(-1, -1)
var _phased := false
var fights := 0                        # per le prove


func setup(main: Node2D) -> void:
	m = main
	m.guardian.resolved.connect(_on_resolved)
	m.fauna.killed.connect(_on_killed)


## Il Guardiano del mondo è risolto: il personaggio lo ricorda; un Guardiano generato lascia il suo Sigillo.
func _on_resolved(_how: String) -> void:
	var g: Dictionary = m.guardian.info()
	var cid := String(g["creature"])
	remember(cid)
	if GuardianGen.is_gen(cid):
		m.drops.spawn("sigillo_guardiano", 1, m.guardian.heart_pos() + Vector2(0, -2 * 16), sigil_of(cid))


func remember(cid: String) -> void:
	var ch: Character = m.character
	var e: Dictionary = ch.guardiani.get(cid, {"volte": 0, "nome": String(CreaturesData.get_data(cid).get("name", cid))})
	e["volte"] = int(e["volte"]) + 1
	ch.guardiani[cid] = e


static func sigil_of(cid: String) -> Dictionary:
	var d := CreaturesData.get_data(cid)
	return {"guardiano": cid, "nome": String(d.get("name", "")), "elem": String(d.get("elem", ""))}


## Il Cerchio dei Seminatori a portata (angolo), o (-1, -1).
func near_arena() -> Vector2i:
	var pc: Vector2i = m.player_cell()
	for o in m.world.stations:
		if String(m.world.stations[o]) == "arena" and Rect2i(o, Vector2i(3, 1)).grow(SummonData.REACH).has_point(pc):
			return o
	return Vector2i(-1, -1)


## Clic con un Richiamo o con il Sigillo in mano. True se ha risvegliato un Guardiano.
func summon(item: String, dati := {}) -> bool:
	if active != null and is_instance_valid(active):
		m.hud.toast("Un Guardiano evocato è già sveglio")
		return false
	var o := near_arena()
	if o.x < 0:
		m.hud.toast("Serve un Cerchio dei Seminatori qui vicino")
		return false
	var cid := ""
	var b: Bisaccia = m.character.bisaccia
	if item == "sigillo_guardiano":
		cid = String(dati.get("guardiano", ""))
		if cid == "":
			return false
		if Crafting.have(b, "seme_eco") < 1:
			m.hud.toast("Con il Sigillo serve anche un Seme d'eco")
			return false
	else:
		cid = String(SummonData.CALLS.get(item, {}).get("creature", ""))
	if cid == "" or not m.character.guardiani.has(cid):
		m.hud.toast("Si evocano solo i Guardiani che hai già affrontato")
		return false
	if item == "sigillo_guardiano":
		Crafting.take(b, "seme_eco", 1)
	elif not b.remove(item, 1):
		return false
	start(cid, o)
	return true


## Lo scontro: il Guardiano sopra il Cerchio, niente nascite attorno, la barra in alto.
func start(cid: String, o: Vector2i) -> Creature:
	arena = o
	_phased = false
	var fly: bool = CreaturesData.get_data(cid).get("fly", false)
	var at := (Vector2(o) + Vector2(1.5, -8.0 if fly else -3.0)) * 16.0
	for c in m.fauna.list.duplicate():
		if is_instance_valid(c) and (c as Creature).position.distance_to(at) < SummonData.ARENA_R * 16.0:
			m.fauna.kill_quietly(c)
	active = m.fauna.add(cid, at)
	active.strengthen(m.fauna.vigor_mult)
	active.set_meta("evocato", true)
	m.fauna.quiet_c = o
	m.guardian.bar.follow(active)
	m.sfx.play("guardiano")
	m.depth_watch.banner.show_stratum(String(CreaturesData.get_data(cid)["name"]), "Evocato al Cerchio dei Seminatori",
		Color("#ffd08a"))
	fights += 1
	return active


func _process(_dt: float) -> void:
	if active == null:
		return
	if not is_instance_valid(active):
		_end()
		return
	# la seconda fase dei Guardiani generati, come nel loro mondo
	if active.enraged and not _phased and active.data.has("phase_elem"):
		_phased = true
		m.guardian._phase(active)
		m.guardian._phased = false
	if m.life.dead:
		m.fauna.kill_quietly(active)
		_end()


func _on_killed(c: Creature) -> void:
	if c != active:
		return
	var at := c.position + Vector2(0, -8)
	var cid := c.id
	var call := SummonData.of_creature(cid)
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	if call != "":
		var loot: Dictionary = SummonData.CALLS[call]["loot"]
		for id in loot:
			m.drops.spawn(String(id), rng.randi_range(int(loot[id][0]), int(loot[id][1])), at)
	elif GuardianGen.is_gen(cid):
		m.drops.spawn("nucleo_" + String(CreaturesData.get_data(cid)["elem"]), SummonData.GEN_DROP, at)
	var pool: Dictionary = UniquesData.POOLS["evocati"]           # voce 85: a volte un oggetto unico
	if rng.randf() < float(pool["chance"]):
		var list: Array = pool["items"]
		m.drops.spawn(String(list[rng.randi_range(0, list.size() - 1)]), 1, at + Vector2(0, -10))
	remember(cid)
	m.objectives.bump("evocati")
	_end()


func _end() -> void:
	active = null
	m.fauna.quiet_c = Vector2i(-1, -1)
	m.guardian.bar.follow(null)
