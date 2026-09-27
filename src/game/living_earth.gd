class_name LivingEarth
extends Node
## La terra viva (voce 77, dati e regole in `LivingData`): tre geni che fanno cambiare il mondo da solo.
##   Radici vive: ogni tessera scavata sotto la superficie (fino al Sottobosco) diventa una «ferita» in
##     `world_meta["ferite"]`; dopo `REGROW` secondi di gioco o d'assenza si richiude di radice, se non la tengono
##     aperta una torcia vicina, una parete costruita, un liquido o il Germogliato stesso.
##   Cristalli vivi: i cristalli di Linfa che toccano l'aria (`world_meta["cristalli"]`, cercati una volta) crescono.
##   Frane: humus ed erba senza appoggio cadono (una coda di zolle, una tessera ogni `FALL_STEP`).
## Il tempo: `world_meta["terra_t"]` (secondi di gioco del mondo) e `world_meta["visto"]` (ora del sistema all'ultimo
## passaggio): entrando dopo un'assenza le radici e i cristalli recuperano il tempo perso, e un avviso lo racconta.

var m: Node2D
var regrow := false
var crystal := 0.0
var falling := false
var closed := 0                        # per le prove e l'avviso: ferite richiuse, cristalli cresciuti, zolle cadute
var grown := 0
var fallen := 0
var last_note := ""                    # l'ultimo «mentre eri via»
var _tick := 0.0
var _crystal_t := 0.0
var _fall_t := 0.0
var _queue: Array[Vector2i] = []       # zolle che forse cadono


func setup(main: Node2D) -> void:
	m = main
	m.actions.dug.connect(_on_dug)
	apply()
	var now := Time.get_unix_time_from_system()
	var seen := float(m.world_meta.get("visto", 0.0))
	if seen > 0.0 and now - seen > 60.0:
		var note := away(now - seen)
		if note != "":
			m.hud.toast(note)
	m.world_meta["visto"] = now


func apply() -> void:
	var e := Genome.effects(m.world_meta.get("geni", []), "run")
	regrow = bool(e.get("regrow", false))
	crystal = float(e.get("crystal", 0.0))
	falling = bool(e.get("falling", false))
	if crystal > 0.0 and not m.world_meta.has("cristalli"):
		m.world_meta["cristalli"] = find_crystals()


## Tempo di gioco di questo mondo, in secondi (avanza anche con le assenze).
func clock() -> float:
	return float(m.world_meta.get("terra_t", 0.0))


func _on_dug(_t: int, c: Vector2i) -> void:
	var w: World = m.world
	if regrow and c.y > w.surface[c.x] + 1 and StrataData.at(w, c.x, c.y) <= LivingData.MAX_STRATUM:
		var list: Array = m.world_meta.get("ferite", [])
		if list.size() < LivingData.MAX_WOUNDS:
			list.append([c.x, c.y, clock() + LivingData.REGROW])
			m.world_meta["ferite"] = list
	if falling:
		_queue.append(c + Vector2i(0, -1))


func _process(dt: float) -> void:
	if not m.built:
		return
	m.world_meta["terra_t"] = clock() + dt
	_tick -= dt
	if _tick <= 0.0:
		_tick = 1.0
		m.world_meta["visto"] = Time.get_unix_time_from_system()
		if regrow:
			heal(clock(), true)
	if crystal > 0.0:
		_crystal_t += dt * crystal
		if _crystal_t >= LivingData.CRYSTAL_EVERY:
			_crystal_t = 0.0
			grow_crystal(true)
	if not _queue.is_empty():
		_fall_t -= dt
		if _fall_t <= 0.0:
			_fall_t = LivingData.FALL_STEP
			_fall_step()


## Richiude le ferite scadute entro `now`. `live`: si gioca (il Germogliato vicino tiene aperto).
func heal(now: float, live: bool) -> int:
	var list: Array = m.world_meta.get("ferite", [])
	var keep := []
	var n := 0
	for f in list:
		if float(f[2]) > now:
			keep.append(f)
			continue
		var c := Vector2i(int(f[0]), int(f[1]))
		var why := _blocked(c, live)
		if why == 1:
			keep.append([c.x, c.y, now + LivingData.REGROW_RETRY])
		elif why == 0:
			_close(c)
			n += 1
	m.world_meta["ferite"] = keep
	closed += n
	return n


## 0 = si può richiudere, 1 = per ora no (si riprova), 2 = mai più (c'è già qualcosa).
func _blocked(c: Vector2i, live: bool) -> int:
	var w: World = m.world
	if not w.inside(c.x, c.y) or w.solid(c.x, c.y):
		return 2
	if w.plat(c.x, c.y) or not w.station_at(c).is_empty() or w.wall(c.x, c.y) in LivingData.BUILT_WALLS:
		return 2
	if w.liq(c.x, c.y) > 0 or w.torch_near(c, LivingData.TORCH_KEEP):
		return 1
	if live and Vector2(c - m.player_cell()).length() < LivingData.REGROW_NEAR:
		return 1
	return 0


func _close(c: Vector2i) -> void:
	var w: World = m.world
	w.set_tile(c.x, c.y, TileDefs.RADICE)
	w.set_decor(c.x, c.y, 0)
	m.view.refresh_around(c)
	m.light.dirty = true


## Tutti i cristalli che toccano l'aria (una volta per mondo): `find` scorre l'array in C++, non in GDScript.
func find_crystals() -> Array:
	var w: World = m.world
	var out := []
	var i := w.tiles.find(TileDefs.CRYSTAL)
	var rng := RandomNumberGenerator.new()
	rng.seed = w.world_seed
	while i >= 0:
		var x := i % w.w
		var y := i / w.w
		if not w.solid(x, y - 1) or not w.solid(x - 1, y) or not w.solid(x + 1, y) or not w.solid(x, y + 1):
			if out.size() < LivingData.CRYSTAL_SEEDS:
				out.append([x, y])
			elif rng.randf() < 0.2:
				out[rng.randi_range(0, out.size() - 1)] = [x, y]
		i = w.tiles.find(TileDefs.CRYSTAL, i + 1)
	return out


## Un cristallo cresce di una tessera verso l'aria. `live`: non addosso al Germogliato.
func grow_crystal(live: bool) -> bool:
	var w: World = m.world
	var seeds: Array = m.world_meta.get("cristalli", [])
	if seeds.is_empty():
		return false
	for tries in 6:
		var k := randi() % seeds.size()
		var s := Vector2i(int(seeds[k][0]), int(seeds[k][1]))
		if w.tile(s.x, s.y) != TileDefs.CRYSTAL:
			seeds.remove_at(k)                    # scavato: quel punto non cresce più
			if seeds.is_empty():
				return false
			continue
		var d: Vector2i = [Vector2i(0, -1), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(0, -1)][randi() % 5]
		var t := s + d
		if not w.inside(t.x, t.y) or w.solid(t.x, t.y) or w.liq(t.x, t.y) > 0 or w.plat(t.x, t.y) \
				or not w.station_at(t).is_empty():
			continue
		if live and Vector2(t - m.player_cell()).length() < 3.0:
			continue
		w.set_tile(t.x, t.y, TileDefs.CRYSTAL)
		w.set_decor(t.x, t.y, 0)
		if seeds.size() < LivingData.CRYSTAL_SEEDS * 2:
			seeds.append([t.x, t.y])
		else:
			seeds[k] = [t.x, t.y]
		m.view.refresh_around(t)
		m.light.dirty = true
		grown += 1
		return true
	return false


## Una zolla per passo: se sotto c'è aria scende di una tessera, e quella sopra la segue.
func _fall_step() -> void:
	var w: World = m.world
	var next: Array[Vector2i] = []
	var seen := {}
	for q in _queue:
		if seen.has(q) or not w.inside(q.x, q.y + 1):
			continue
		seen[q] = true
		var t := w.tile(q.x, q.y)
		if not (t in LivingData.FALLING or TileDefs.is_grass(t)) or w.solid(q.x, q.y + 1) or w.plat(q.x, q.y + 1) or w.liq(q.x, q.y + 1) > 0:
			continue
		if not w.station_at(q + Vector2i(0, -1)).is_empty() or w.tree_at(q + Vector2i(0, -1)).x >= 0:
			continue                              # le radici degli alberi e le stazioni tengono la terra
		var below := q + Vector2i(0, 1)
		w.set_tile(q.x, q.y, TileDefs.AIR)
		var pr: Rect2 = Rect2(m.player.position - Player.HALF, Player.HALF * 2.0)
		if pr.intersects(Rect2(Vector2(below) * 16.0, Vector2(16, 16))):
			# cade in testa al Germogliato: si sbriciola
			m.vitals.hurt(LivingData.FALL_HURT)
			m.drops.spawn(String(TileDefs.DROP.get(t, "")), 1, Vector2(below) * 16.0 + Vector2(8, 8))
		else:
			w.set_tile(below.x, below.y, t)
			next.append(below)
		Fx.dust(m.fx, Vector2(q) * 16.0 + Vector2(8, 14), TileDefs.dust_colors(t))
		m.view.refresh_around(q)
		m.light.dirty = true
		next.append(q + Vector2i(0, -1))
		fallen += 1
	_queue = next


## Il tempo passato altrove (secondi): le radici e i cristalli lo recuperano. Restituisce l'avviso da mostrare.
func away(secs: float) -> String:
	m.world_meta["terra_t"] = clock() + secs
	var c0 := closed
	var g0 := grown
	if regrow:
		heal(clock(), false)
	if crystal > 0.0:
		for k in mini(int(secs / LivingData.CRYSTAL_AWAY * crystal), LivingData.CRYSTAL_AWAY_MAX):
			grow_crystal(false)
	var parts := []
	if closed > c0:
		parts.append("le radici hanno richiuso %d tessere scavate" % (closed - c0))
	if grown > g0:
		parts.append("i cristalli sono cresciuti di %d tessere" % (grown - g0))
	last_note = ""
	if not parts.is_empty():
		last_note = "Mentre eri via (%s): %s." % [_span(secs), ", ".join(parts)]
	return last_note


static func _span(secs: float) -> String:
	if secs >= 86400.0:
		return "%d giorni" % int(secs / 86400.0) if secs >= 172800.0 else "un giorno"
	if secs >= 3600.0:
		return "%d ore" % int(secs / 3600.0) if secs >= 7200.0 else "un'ora"
	return "%d minuti" % maxi(int(secs / 60.0), 1)
