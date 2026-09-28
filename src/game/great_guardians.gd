class_name GreatGuardians
extends Node
## I tre Guardiani scritti a mano (voce 136, dati in `src/data/bestiary/guardiani.gd`): il richiamo giusto nel posto
## giusto li chiama (il Leviatano accanto a un lago grande, la Grande Scavatrice sotto terra, la Signora delle correnti
## in superficie all'aperto). Qui le loro mosse che toccano il mondo, chieste con `Creature.acts` (le passa `Wiles`):
## la **marea** (acqua che trabocca verso il Germogliato), i **pilastri** di radice (si alzano solo nell'aria e crollano
## da soli: niente si rompe) e le **correnti** (una raffica, colonne d'aria che fanno salire, passerelle di nuvola che
## spariscono). Tutto ciò che è temporaneo si toglie anche uscendo dal mondo.

const S := 16
const LAKE_MIN := 80                     # celle d'acqua per il Leviatano
const PILLAR_H := 4
const PILLAR_TIME := 8.0
const CURRENT_TIME := 9.0
const CLOUD_TIME := 12.0
const GUST := 260.0                      # px/s: la raffica

var m: Node2D
var bar: BossBar
var active: Creature
var pillars := []                        # [[cella, secondi]]
var clouds := []                         # [[cella, secondi]]
var currents := []                       # [[corrente (in Gravity.currents), secondi]]
var tides := 0                           # (prove)

signal defeated(key: String)


func setup(main: Node2D) -> void:
	m = main
	bar = BossBar.new()
	m.hud.add_child(bar)
	m.fauna.killed.connect(_on_killed)


func _exit_tree() -> void:
	clear_temp()


## Il richiamo in mano: nel posto giusto, il Guardiano arriva.
func summon(item: String) -> bool:
	var key := String(ItemsData.get_item(item).get("great", ""))
	if key == "" or active != null:
		if active != null:
			m.hud.toast("Un Guardiano è già sveglio")
		return false
	var at := _place(key)
	if at.x < 0.0:
		m.hud.toast(String(ItemsData.get_item(item)["desc"]))
		return false
	if not m.character.bisaccia.remove(item, 1):
		return false
	spawn(key, at)
	return true


## Dove nasce (o Vector2(-1, -1) se il posto non va bene).
func _place(key: String) -> Vector2:
	var pc: Vector2i = m.player_cell()
	var w: World = m.world
	match key:
		"leviatano":
			for r in range(1, 14):
				for dx in [-r, r]:
					for dy in range(-2, 8):
						var c := pc + Vector2i(dx, dy)
						if w.liq(c.x, c.y) >= 6 and w.liq_type(c.x, c.y) == LiquidsData.ACQUA:
							var body := WaterBody.at(w, c)
							if int(body.get("cells", 0)) >= LAKE_MIN:
								return (Vector2(c) + Vector2(0.5, 0.8)) * S
			return Vector2(-1, -1)
		"scavatrice":
			if StrataData.at(w, pc.x, pc.y) < 2:
				return Vector2(-1, -1)
			return m.player.position + Vector2(0, 3.0 * S)
		"correnti":
			if StrataData.at(w, pc.x, pc.y) > 0 or m.weather.roofed:
				return Vector2(-1, -1)
			return m.player.position + Vector2(8.0 * S, -9.0 * S)
	return Vector2(-1, -1)


func spawn(key: String, at: Vector2) -> Creature:
	var cid: String = {"leviatano": "leviatano_lago", "scavatrice": "grande_scavatrice", "correnti": "signora_correnti"}[key]
	active = m.fauna.add(cid, at)
	active.strengthen(m.fauna.vigor_mult)
	active.provoke()
	active.mind.brave = true
	bar.follow(active)
	m.sfx.play("guardiano")
	m.depth_watch.banner.show_stratum(String(active.data["name"]), "Un Guardiano si è svegliato", Color("#ff7a6a"))
	return active


func _process(dt: float) -> void:
	if m == null or not m.built:
		return
	if active != null and not is_instance_valid(active):
		active = null
		bar.follow(null)
	_tick(pillars, dt, func(c: Vector2i) -> void:
		if m.world.tile(c.x, c.y) == TileDefs.RADICE and m.world.build_at(c.x, c.y) == 0:
			m.world.set_tile(c.x, c.y, TileDefs.AIR)
			m.view.refresh_around(c)
			m.light.dirty = true)
	_tick(clouds, dt, func(c: Vector2i) -> void:
		if m.world.plat(c.x, c.y):
			m.world.set_plat(c.x, c.y, false)
			m.view.refresh_around(c))
	for i in range(currents.size() - 1, -1, -1):
		currents[i][1] = float(currents[i][1]) - dt
		if float(currents[i][1]) <= 0.0:
			m.gravity.currents.erase(currents[i][0])
			currents.remove_at(i)


func _tick(list: Array, dt: float, gone: Callable) -> void:
	for i in range(list.size() - 1, -1, -1):
		list[i][1] = float(list[i][1]) - dt
		if float(list[i][1]) <= 0.0:
			gone.call(list[i][0])
			list.remove_at(i)


## Le mosse (da `Wiles`, quando il tipo non è suo).
func act(c: Creature, a: Dictionary) -> void:
	match String(a["kind"]):
		"marea":
			_tide(a["at"], a["to"], int(a["n"]))
		"pilastri":
			_pillars(a["at"], int(a["n"]))
		"correnti":
			_winds(a["at"], a["from"])


## L'acqua sale: nelle celle d'aria sopra il pelo del lago, dalla parte del Germogliato.
func _tide(at: Vector2, to: Vector2, n: int) -> void:
	var w: World = m.world
	var c := Vector2i(floori(at.x / S), floori(at.y / S))
	var top := c
	while top.y > 1 and w.liq(top.x, top.y - 1) > 0:
		top.y -= 1
	var dir := 1 if to.x >= at.x else -1
	var poured := 0
	for i in range(0, 30):
		var q := Vector2i(top.x + dir * i, top.y - 1)
		if poured >= n:
			break
		if not w.solid(q.x, q.y):
			m.liquids.pour(q, 8, LiquidsData.ACQUA)
			poured += 1
	tides += 1
	m.sfx.play("soffio", at)


## I pilastri di radice attorno al Germogliato: solo nelle celle d'aria, crollano da soli.
func _pillars(at: Vector2, n: int) -> void:
	var w: World = m.world
	var pc := Vector2i(floori(at.x / S), floori(at.y / S))
	for k in n:
		var x := pc.x + (k - n / 2) * 4 + (1 if k == n / 2 else 0) * 3
		var y := pc.y
		while y < w.h - 2 and not w.solid(x, y + 1):
			y += 1
		for dy in PILLAR_H:
			var q := Vector2i(x, y - dy)
			if w.inside(q.x, q.y) and not w.solid(q.x, q.y) and w.station_at(q).is_empty() and q != m.player_cell():
				w.set_tile(q.x, q.y, TileDefs.RADICE)
				pillars.append([q, PILLAR_TIME])
				m.view.refresh_around(q)
	m.light.dirty = true
	Fx.dust(m.fx, at, TileDefs.dust_colors(TileDefs.RADICE))


## Una raffica che spinge via, due colonne d'aria che fanno salire, passerelle di nuvola.
func _winds(at: Vector2, from: Vector2) -> void:
	var p: Player = m.player
	var dir := signf(at.x - from.x)
	if dir == 0.0:
		dir = 1.0
	p.vel.x += dir * GUST
	p.vel.y = minf(p.vel.y, -120.0)
	var pc := Vector2i(floori(at.x / S), floori(at.y / S))
	for side in [-6, 6]:
		var cu := {"x": pc.x + side, "w": 1, "y0": pc.y - 16, "y1": pc.y + 2}
		m.gravity.currents.append(cu)
		currents.append([cu, CURRENT_TIME])
	for k in 3:
		var y := pc.y - 5 - k * 4
		var x0 := pc.x - 3 + (k % 2) * 4
		for dx in 4:
			var q := Vector2i(x0 + dx, y)
			if m.world.inside(q.x, q.y) and not m.world.solid(q.x, q.y) and not m.world.plat(q.x, q.y):
				m.world.set_plat(q.x, q.y, true)
				clouds.append([q, CLOUD_TIME])
				m.view.refresh_around(q)
	Fx.puff(m.fx, at, Color(1.4, 1.6, 1.8))
	m.sfx.play("soffio", at)


## Toglie pilastri, nuvole e correnti rimasti.
func clear_temp() -> void:
	if m == null:
		return
	for e in pillars:
		var c: Vector2i = e[0]
		if m.world.tile(c.x, c.y) == TileDefs.RADICE and m.world.build_at(c.x, c.y) == 0:
			m.world.set_tile(c.x, c.y, TileDefs.AIR)
	for e in clouds:
		m.world.set_plat((e[0] as Vector2i).x, (e[0] as Vector2i).y, false)
	for e in currents:
		m.gravity.currents.erase(e[0])
	pillars.clear()
	clouds.clear()
	currents.clear()


func _on_killed(c: Creature) -> void:
	if c != active:
		return
	active = null
	bar.follow(null)
	var key := String(c.data.get("great", ""))
	var rec: Dictionary = m.world_meta.get("grandi_guardiani", {})
	rec[key] = int(rec.get(key, 0)) + 1
	m.world_meta["grandi_guardiani"] = rec
	m.objectives.bump("grandi_guardiani")
	m.hud.toast("Hai sconfitto il %s!" % String(c.data["name"]) if key != "correnti" else "Hai sconfitto la Signora delle correnti!")
	defeated.emit(key)
