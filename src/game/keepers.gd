class_name Keepers
extends Node
## I Custodi degli strati (voce 27, dati in `KeepersData`): dormono nei bozzoli delle loro tane e si schiudono quando
## il Germogliato si avvicina. Si combattono come i Guardiani (barra in alto, luce attorno), ma non si curano: si
## sconfiggono. Sconfitto, il bozzolo resta vuoto (`bozzolo_rotto`) e il Custode si può richiamare all'Altare dei
## Seminatori con il suo richiamo. Se il Germogliato appassisce o si allontana molto, il Custode torna a dormire.
## Stato nel mondo salvato: `world_meta["custodi"]` = {custode: volte in cui è stato sconfitto}.

const S := 16

var m: Node2D
var bar: BossBar
var active: Creature                   # il Custode sveglio (uno alla volta)
var active_id := ""
var active_den := Vector2i(-1, -1)     # il bozzolo da cui è uscito (-1 se richiamato all'Altare)
var dens := {}                         # angolo del bozzolo -> custode (solo quelli ancora pieni)

signal defeated(keeper: String)


func setup(main: Node2D) -> void:
	m = main
	for o in m.world.stations:
		var id := String(m.world.stations[o])
		if id.begins_with("bozzolo_") and id != "bozzolo_rotto":
			dens[o] = id.trim_prefix("bozzolo_")
	bar = BossBar.new()
	m.hud.add_child(bar)
	m.fauna.killed.connect(_on_killed)


func den_center(o: Vector2i) -> Vector2:
	return (Vector2(o) + Vector2(1.5, 1.5)) * S


func _process(_dt: float) -> void:
	if not m.built:
		return
	if active != null and not is_instance_valid(active):
		active = null
	if active == null:
		for o in dens:
			if m.player.position.distance_to(den_center(o)) < KeepersData.WAKE * S and not m.life.dead:
				hatch(o)
				break
	else:
		var home := den_center(active_den) if active_den.x >= 0 else active.position
		var far: bool = m.player.position.distance_to(home) > KeepersData.LEASH * S
		if m.life.dead or far:
			# torna a dormire (e guarisce): la prossima volta si ricomincia
			m.fauna.kill_quietly(active)
			active = null
			bar.follow(null)
	if active != null:
		var bc := Vector2i(floori(active.position.x / S), floori(active.position.y / S))
		m.light.set_extra("custode", [[bc, Color(1.2, 1.1, 1.0)]])
	else:
		m.light.set_extra("custode", [])


## Il Custode si schiude dal suo bozzolo.
func hatch(o: Vector2i) -> void:
	var k := String(dens[o])
	active_den = o
	_spawn(k, den_center(o) + Vector2(0, -S))
	Fx.puff(m.fx, den_center(o), Color(1.6, 1.4, 1.2))


## Richiamo all'Altare: il Custode compare poco sopra l'Altare più vicino. True se l'ha fatto.
func summon(item: String) -> bool:
	var k := KeepersData.of_summon(item)
	if k == "" or active != null:
		if active != null:
			m.hud.toast("Un Custode è già sveglio")
		return false
	var altar := Vector2i(-1, -1)
	for o in m.world.stations:
		if m.world.stations[o] == "altare" and Rect2i(o, Vector2i(3, 2)).grow(StationsData.REACH).has_point(m.player_cell()):
			altar = o
	if altar.x < 0:
		m.hud.toast("Serve un Altare dei Seminatori qui vicino")
		return false
	var beaten: Dictionary = m.world_meta.get("custodi", {})
	if not beaten.has(k):
		m.hud.toast("Prima trova e sconfiggi il Custode nella sua tana")
		return false
	if not m.character.bisaccia.remove(item, 1):
		return false
	active_den = Vector2i(-1, -1)
	_spawn(k, (Vector2(altar) + Vector2(1.5, -4.0)) * S)
	return true


func _spawn(k: String, at: Vector2) -> void:
	var kd: Dictionary = KeepersData.KEEPERS[k]
	var cid := String(kd["creature"])
	active_id = k
	active = m.fauna.add(cid, at)
	active.strengthen(m.fauna.vigor_mult)
	bar.follow(active)
	m.sfx.play("guardiano")
	m.depth_watch.banner.show_stratum(String(CreaturesData.CREATURES[cid]["name"]), String(kd["wake"]), Color(kd["color"]))


func _on_killed(c: Creature) -> void:
	if c != active:
		return
	active = null
	bar.follow(null)
	var beaten: Dictionary = m.world_meta.get("custodi", {})
	var first := not beaten.has(active_id)
	beaten[active_id] = int(beaten.get(active_id, 0)) + 1
	m.world_meta["custodi"] = beaten
	if active_den.x >= 0 and dens.has(active_den):
		# il bozzolo resta vuoto
		dens.erase(active_den)
		m.world.stations[active_den] = "bozzolo_rotto"
		m.view.remove_station(active_den)
		m.view.add_station(active_den)
		m.light.dirty = true
	if first:
		m.guardian.lore.show_page(String(KeepersData.KEEPERS[active_id]["page"]))
	m.objectives.bump("custodi")
	defeated.emit(active_id)
