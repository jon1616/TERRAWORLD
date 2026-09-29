class_name Wiles
extends Node2D
## Le astuzie delle creature nel mondo (voce 130, dati in `WilesData`): i comportamenti scrivono le loro richieste in
## `Creature.acts` e qui diventano vere — il furto dalla Bisaccia, la Linfa bevuta, le ragnatele (disegnate qui), la
## terra rosicchiata, lo scoppio; e alla morte: le figlie di chi si divide, il maltolto del ladro, il gregge sbandato.

const S := 16

var m: Node2D
var webs := {}                           # cella -> secondi che restano
var stolen := 0                          # conteggi (prove)
var splits := 0
var doors_broken := 0
var door_hits := {}                      # origine della porta -> morsi presi
static var siege := false                # un assedio in corso (voce 137): solo allora si rodono le porte
var _burn_t := 0.0


func setup(main: Node2D) -> void:
	m = main
	z_index = 4
	m.fauna.killed.connect(_on_killed)


func _process(dt: float) -> void:
	if m == null or not m.built:
		return
	BhMimetico.reveal = m.powers._vista_t > 0.0
	for c in m.fauna.list.duplicate():
		if c.acts.is_empty():
			continue
		for a in c.acts:
			_act(c, a)
		c.acts.clear()
	_webs(dt)


func _act(c: Creature, a: Dictionary) -> void:
	match String(a["kind"]):
		"ruba":
			_steal(c, int(a["n"]))
		"beve":
			m.vitals.linfa = maxi(m.vitals.linfa - int(a["linfa"]), 0)
			m.vitals.hurt(int(a["vita"]), "un parassita")
			m.vitals.changed.emit()
			Fx.float_text(m.fx, m.player.position + Vector2(0, -20), "-%d Linfa" % int(a["linfa"]), Color("#6ae0d8"))
		"tela":
			var at: Vector2 = a["at"]
			var base := Vector2i(floori(at.x / S) - WilesData.WEB_W / 2, floori(at.y / S) - WilesData.WEB_H + 1)
			for dy in WilesData.WEB_H:
				for dx in WilesData.WEB_W:
					var q := base + Vector2i(dx, dy)
					if m.world.inside(q.x, q.y) and not m.world.solid(q.x, q.y):
						webs[q] = WilesData.WEB_TIME
			queue_redraw()
		"rosicchia":
			_gnaw(c, a["cell"])
		"scoppia":
			var bl := {"radius": float(a["r"]), "power": -1, "damage": int(a["damage"]), "natural": true}   # non rompe blocchi
			m.throwing.explode(c.position, bl)
			m.fauna.kill_quietly(c)                 # scoppiata: niente bottino (abbattuta prima, sì)
		"folgore":
			m.strikes.bolt(float(a["x"]), float(a["delay"]), int(a["damage"]))    # Roadmap 16: il fulmine annunciato
		_:
			if m.great:
				m.great.act(c, a)                   # voce 136: marea, pilastri, correnti


## Ruba fino a n oggetti da una casella della Bisaccia (mai quella in mano, mai oggetti unici), e scappa.
func _steal(c: Creature, n: int) -> void:
	var b: Bisaccia = m.character.bisaccia
	var pick := []
	for i in b.slots.size():
		if i == m.hud.sel or b.slots[i].is_empty() or b.slots[i].has("dati") or ItemsData.stack_of(b.id_at(i)) <= 1:
			continue
		pick.append(i)
	if pick.is_empty():
		return
	var i: int = pick[c.rng.randi_range(0, pick.size() - 1)]
	var id := b.id_at(i)
	var k := mini(n, b.count_at(i))
	b.slots[i]["n"] = b.count_at(i) - k
	if b.count_at(i) <= 0:
		b.slots[i] = {}
	b.changed.emit()
	c.set_meta("rubato", [id, k])
	c.mind.force_flee(10.0)
	stolen += 1
	m.hud.toast("%s ti ha rubato %d %s! Prendilo per riaverli" % [String(c.data.get("name", "")), k, String(ItemsData.get_item(id).get("name", id))])
	Fx.puff(m.fx, m.player.position, Color(1.6, 1.4, 0.6))


## Rode: solo durante un assedio (scelta dell'utente: fuori dagli assedi le creature non distruggono nulla), e solo le
## porte; una porta regge `WilesData.DOOR_HITS` morsi, poi cade e lascia la porta a terra.
func _gnaw(c: Creature, q: Vector2i) -> void:
	if not siege:
		return
	var w: World = m.world
	var st: Dictionary = w.station_at(q)
	if st.is_empty() or String(st["id"]) != "porta":
		return
	var o: Vector2i = st["origin"]
	door_hits[o] = int(door_hits.get(o, 0)) + 1
	Fx.dust(m.fx, Vector2(q) * S + Vector2(8, 8), TileDefs.dust_colors(TileDefs.PORTA))
	m.sfx.play("legno", Vector2(q) * S)
	if int(door_hits[o]) < door_strength(o):
		return
	door_hits.erase(o)
	w.stations.erase(o)
	for dy in m.masonry.door_h():
		w.set_tile(o.x, o.y + dy, TileDefs.AIR)
		m.view.refresh_around(o + Vector2i(0, dy))
	m.view.remove_station(o)
	m.light.dirty = true
	m.drops.spawn("porta_lanterna", 1, Vector2(o) * S + Vector2(8, 8))
	doors_broken += 1
	m.hud.toast("Una porta è caduta!")


func _webs(dt: float) -> void:
	if webs.is_empty():
		return
	var pc: Vector2i = m.player_cell()
	var torch := String(m.hud.current().get("id", "")) != "" and ItemsData.use_of(String(m.hud.current().get("id", ""))) == "torcia"
	var gone := []
	_burn_t -= dt
	var check_torches := _burn_t <= 0.0
	if check_torches:
		_burn_t = 0.5
	for q in webs:
		webs[q] = float(webs[q]) - dt
		if float(webs[q]) <= 0.0:
			gone.append(q)
			continue
		if check_torches:
			for dy in range(-2, 3):
				for dx in range(-2, 3):
					if m.world.torches.has(q + Vector2i(dx, dy)):
						gone.append(q)
		if q == pc or q == pc + Vector2i(0, -1):
			if torch:
				gone.append(q)
				Fx.puff(m.fx, Vector2(q) * S + Vector2(8, 8), Color(2.2, 1.3, 0.5))
			else:
				m.player.slow_t = maxf(m.player.slow_t, WilesData.WEB_SLOW)
	for q in gone:
		webs.erase(q)
	if not gone.is_empty():
		queue_redraw()


func _draw() -> void:
	var col := Color(0.92, 0.94, 1.0, 0.55)
	for q in webs:
		var o := Vector2(q) * S
		draw_line(o, o + Vector2(S, S), col, 1.0)
		draw_line(o + Vector2(S, 0), o + Vector2(0, S), col, 1.0)
		draw_line(o + Vector2(S / 2.0, 0), o + Vector2(S / 2.0, S), col, 1.0)
		draw_arc(o + Vector2(S, S) / 2.0, 5.0, 0.0, TAU, 10, col, 1.0)


func _on_killed(c: Creature) -> void:
	var beh: Array = c.data.get("behaviors", [])
	if c.has_meta("rubato"):
		var r: Array = c.get_meta("rubato")
		m.drops.spawn(String(r[0]), int(r[1]), c.position)
	if "divide" in beh and int(c.get_meta("gen", 0)) < 1 and c.burn_t <= 0.0 \
			and c.last_dmg < c.hp_max * float(c.p.get("big_hit", 0.5)):
		splits += 1
		for i in 2:
			var k: Creature = m.fauna.add(c.id, c.position + Vector2(-8.0 + 16.0 * i, -4.0))
			k.set_meta("gen", 1)
			k.hp_max = maxi(1, roundi(c.hp_max * float(c.p.get("split_hp", 0.45))))
			k.hp = k.hp_max
			k.damage = maxi(1, roundi(c.damage * 0.6))
			k.scale = Vector2(0.75, 0.75)
			k.vel = Vector2(-90.0 + 180.0 * i, -160.0)
			k.provoke()
	# chi seguiva il morto (il gregge del pastore, voce 130; il branco del capobranco, voce 131) si sbanda e fugge
	for o in m.fauna.list:
		if o.mind.lead == c:
			o.mind.lead = null
			o.mind.force_flee(6.0)


## Voce 144: quanti morsi regge una porta: il doppio se è incorniciata da mura dure (costrutti con forza ≥ 35 ai lati).
func door_strength(o: Vector2i) -> int:
	var w: World = m.world
	var strong := 0
	for dy in m.masonry.door_h():
		for dx in [-1, 1]:
			var k := w.build_at(o.x + dx, o.y + dy)
			if k > 0 and BuildData.power(k) >= 35:
				strong += 1
	var k := 2 if strong >= m.masonry.door_h() else 1
	if m.get("energy") != null and m.energy.shielded(o):
		k *= 2                                    # Roadmap 19: lo Scudo di corteccia sulla rete della porta
	return WilesData.DOOR_HITS * k

