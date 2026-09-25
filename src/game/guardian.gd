class_name Guardian
extends Node
## Il Guardiano del Cuore del mondo (voci 8 e 19; quale Guardiano lo dice `GuardiansData` secondo il vigore del mondo).
## Dorme finché il Germogliato non entra nella cupola del Cuore; poi combatte. Due strade, scelte dal giocatore:
##   sconfitto  il Guardiano muore: lascia il suo materiale (il grado d'equipaggiamento successivo), il Cuore si libera;
##   curato     il giocatore versa la Rugiada di Linfa sui quattro nodi avvizziti del soffitto: il Guardiano guarisce,
##              lascia l'altro materiale (lo stesso grado, per un'altra strada) e dona +20 Vita massima, per sempre.
## In entrambi i casi il Cuore torna vivo e dona un Seme di mondo (il portale, vedi `Portal`).
## Stato nel mondo salvato: `world_meta["guardiano"]` = "dorme" · "sconfitto" · "curato".

const S := 16
const WAKE := 24.0                     # tessere dal Cuore entro cui il Guardiano si sveglia
const BEAT_EVERY := 25.0               # ogni quanto, nel Fondo, si sente il battito del Cuore
const HP_GIFT := 20

var m: Node2D
var cuore := Vector2i(-1, -1)          # angolo della stazione del Cuore
var state := "dorme"
var boss: Creature
var bar: BossBar
var lore: LorePanel
var _beat := 5.0
var _seen := false

signal resolved(how: String)


func setup(main: Node2D) -> void:
	m = main
	for o in m.world.stations:
		if String(m.world.stations[o]) in ["cuore_mondo", "cuore_vivo"]:
			cuore = o
	state = String(m.world_meta.get("guardiano", "dorme"))
	bar = BossBar.new()
	m.hud.add_child(bar)
	lore = LorePanel.new()
	m.hud.add_child(lore)
	m.fauna.killed.connect(_on_killed)


## Centro del Cuore in pixel.
func heart_pos() -> Vector2:
	return (Vector2(cuore) + Vector2(1.5, 1.5)) * S


func _process(dt: float) -> void:
	if not m.built or cuore.x < 0:
		return
	var d: float = m.player.position.distance_to(heart_pos()) / S
	if not _seen and d < WAKE:
		_seen = true
		m.objectives.bump("cuore")
		if state == "dorme":
			lore.show_page("cuore_trovato")
	if state == "dorme" and boss == null and d < WAKE and not m.life.dead:
		wake()
	# il battito: nel Fondo si sente da che parte è il Cuore
	if state == "dorme" and m.depth_watch.stratum >= 3 and d > WAKE:
		_beat -= dt
		if _beat <= 0.0:
			_beat = BEAT_EVERY
			var dx: float = heart_pos().x - m.player.position.x
			var dy: float = heart_pos().y - m.player.position.y
			var where := "verso destra" if dx > 0.0 else "verso sinistra"
			if absf(dx) < 20 * S:
				where = "proprio qui"
			m.hud.toast("Un battito lontano… %s%s" % [where, ", più in basso" if dy > 6 * S else ""])
	# un Guardiano sveglio fa luce attorno a sé: nel buio vero la lotta deve leggersi
	if boss != null and is_instance_valid(boss):
		var bc := Vector2i(floori(boss.position.x / S), floori(boss.position.y / S))
		m.light.set_extra("guardiano", [[bc, Color(1.3, 1.1, 0.9)]])
	else:
		m.light.set_extra("guardiano", [])
	# se il Germogliato appassisce, il Guardiano torna a dormire (e guarisce)
	if boss != null and m.life.dead and state == "dorme":
		m.fauna.kill_quietly(boss)
		boss = null
		bar.follow(null)


## Il Guardiano di questo mondo, secondo il vigore (`GuardiansData`).
func info() -> Dictionary:
	return GuardiansData.for_vigor(int(m.world_meta.get("vigore", 1)))


func wake() -> void:
	var g := info()
	var cid := String(g["creature"])
	var fly: bool = CreaturesData.CREATURES[cid].get("fly", false)
	# chi vola nasce sopra il Cuore, chi cammina sul pavimento accanto
	var at := heart_pos() + (Vector2(0, -8 * S) if fly else Vector2(-6 * S, 0))
	boss = m.fauna.add(cid, at)
	# oltre il terzo mondo i Guardiani tornano, ma più forti (il vigore lo sa già `Fauna.vigor_mult`)
	boss.strengthen(m.fauna.vigor_mult)
	m.sfx.play("guardiano")
	bar.follow(boss)
	m.depth_watch.banner.show_stratum(String(CreaturesData.CREATURES[cid]["name"]), String(g["wake"]), Color(g["color"]))


func _on_killed(c: Creature) -> void:
	if c == boss and state == "dorme":
		boss = null
		_resolve("sconfitto")


## La Rugiada di Linfa versata su un nodo avvizzito (clic con la Rugiada in mano). True se ha curato qualcosa.
func cure_at(c: Vector2i) -> bool:
	if m.world.tile(c.x, c.y) != TileDefs.NODO:
		m.hud.toast("La Rugiada serve a guarire i nodi avvizziti")
		return false
	if not m.actions.in_reach(c):
		return false
	var b: Bisaccia = m.character.bisaccia
	if not b.remove("rugiada_linfa", 1):
		return false
	# il nodo intero (le tessere avvizzite attaccate) torna radice viva
	var todo: Array[Vector2i] = [c]
	while not todo.is_empty():
		var q: Vector2i = todo.pop_back()
		if m.world.tile(q.x, q.y) != TileDefs.NODO:
			continue
		m.world.set_tile(q.x, q.y, TileDefs.RADICE)
		m.view.refresh_around(q)
		Fx.puff(m.fx, Vector2(q) * S + Vector2(8, 8), Color(0.6, 1.8, 1.6))
		for o in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			todo.append(q + o)
	m.light.dirty = true
	var left := nodes_left()
	if left > 0:
		m.hud.toast("Il nodo guarisce. Ne restano %d" % left)
	elif state == "dorme":
		_resolve("curato")
	return true


## Quanti nodi avvizziti restano attorno al Cuore (tessere separate contano come nodi diversi).
func nodes_left() -> int:
	var seen := {}
	var n := 0
	for y in range(cuore.y - 30, cuore.y + 15):
		for x in range(cuore.x - 40, cuore.x + 43):
			var q := Vector2i(x, y)
			if m.world.tile(x, y) == TileDefs.NODO and not seen.has(q):
				n += 1
				var todo: Array[Vector2i] = [q]
				while not todo.is_empty():
					var r: Vector2i = todo.pop_back()
					if seen.has(r) or m.world.tile(r.x, r.y) != TileDefs.NODO:
						continue
					seen[r] = true
					for o in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
						todo.append(r + o)
	return n


func _resolve(how: String) -> void:
	state = how
	m.world_meta["guardiano"] = how
	var ch: Character = m.character
	if how == "curato":
		if boss != null:
			boss.make_calm()
			var calm_boss: WeakRef = weakref(boss)   # debole: se nel frattempo sparisce, niente da fare
			get_tree().create_timer(6.0).timeout.connect(func() -> void:
				var cb: Creature = calm_boss.get_ref()
				if cb != null:
					m.fauna.kill_quietly(cb))
		boss = null
		var cure: Dictionary = info()["cure"]
		for id in cure:
			m.drops.spawn(id, int(cure[id]), heart_pos() + Vector2(0, -2 * S))
		if not m.world_id in ch.guardiani_curati:
			ch.guardiani_curati.append(m.world_id)
			ch.vita_extra += HP_GIFT
			m.vitals.hp_max += HP_GIFT
			m.vitals.refill()
		lore.show_page(String(info()["pages"]["curato"]))
	else:
		lore.show_page(String(info()["pages"]["sconfitto"]))
	bar.follow(null)
	# il Cuore torna vivo e dona il Seme di mondo
	m.world.stations[cuore] = "cuore_vivo"
	m.view.remove_station(cuore)
	m.view.add_station(cuore)
	m.light.dirty = true
	m.drops.spawn("seme_mondo", 1, heart_pos())
	m.save_game()
	resolved.emit(how)
