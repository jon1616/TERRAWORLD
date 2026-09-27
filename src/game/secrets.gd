class_name Secrets
extends Node2D
## I segreti del mondo (voce 95, dati in `SecretsData`, elenco fatto da `PassSegreti`): `world_meta["segreti"]` =
## [{k, r: [x, y, larghezza, altezza], g: grado, f: trovato}]. Entrando nel riquadro di un segreto lo si trova: avviso,
## premio secondo il grado, conteggio («4 su 13»: sulla mappa, nella scheda del portale, nel Semenzaio). Attrezzi per
## fiutarli: la Bacchetta rabdomante (indossata o in mano: un anello che pulsa più in fretta più il segreto è vicino) e
## l'Eco dei Seminatori (segna sulla mappa, a grandi linee, i tre più vicini). I mondi salvati prima non ne hanno.

const TICK := 0.3

var m: Node2D
var list: Array = []
var rod := -1.0                        # 0..1 quanto vibra la bacchetta (-1 = non c'è)
var _t := 0.0
var _clock := 0.0
var _rng := RandomNumberGenerator.new()


func setup(main: Node2D) -> void:
	m = main
	_rng.randomize()
	z_as_relative = false
	z_index = 24
	if not m.world_meta.has("segreti"):
		m.world_meta["segreti"] = (m.world.gen_notes.get("segreti", []) as Array).duplicate(true)
	list = m.world_meta["segreti"]
	_announce.call_deferred()


## Entrando: quanti segreti ha il mondo.
func _announce() -> void:
	var c := counts()
	if c[1] > 0 and m.hud != null:
		m.hud.toast("Questo mondo ha %d segreti: ne hai trovati %d" % [c[1], c[0]])


## [trovati, tutti].
func counts() -> Array:
	var f := 0
	for s in list:
		if s.get("f", false):
			f += 1
	return [f, list.size()]


## I segreti di un mondo salvato (per la scheda del portale e il Semenzaio): [trovati, tutti].
static func counts_of(meta: Dictionary) -> Array:
	var f := 0
	var all: Array = meta.get("segreti", [])
	for s in all:
		if s.get("f", false):
			f += 1
	return [f, all.size()]


static func rect_of(s: Dictionary) -> Rect2i:
	var r: Array = s["r"]
	return Rect2i(int(r[0]), int(r[1]), int(r[2]), int(r[3]))


func _process(dt: float) -> void:
	if not m.built:
		return
	_clock += dt
	_t -= dt
	if _t > 0.0:
		if rod >= 0.0:
			queue_redraw()
		return
	_t = TICK
	var pc: Vector2i = m.player_cell()
	_push_fake(pc)
	var best := 1e9
	for s in list:
		if s.get("f", false):
			continue
		var r := rect_of(s)
		if r.has_point(pc):
			_found(s)
			continue
		best = minf(best, Vector2(r.get_center() - pc).length())
	var has_rod: bool = m.character.bisaccia.equip.values().has("bacchetta_rabdomante") \
		or String(m.hud.current().get("id", "")) == "bacchetta_rabdomante"
	rod = clampf(1.0 - best / SecretsData.R_ROD, 0.0, 1.0) if has_rod else -1.0
	queue_redraw()


func _found(s: Dictionary) -> void:
	s["f"] = true
	var kd: Dictionary = SecretsData.KINDS.get(String(s["k"]), {"name": "Segreto"})
	var gd: Dictionary = SecretsData.GRADES[clampi(int(s.get("g", 0)), 0, SecretsData.GRADES.size() - 1)]
	var c := counts()
	m.hud.toast("Segreto trovato: %s (%s) — %d su %d" % [kd["name"], gd["name"], c[0], c[1]])
	# il premio, secondo il grado
	var at: Vector2 = m.player.position + Vector2(0, -12)
	m.drops.spawn("lumino", int(gd["lumini"]), at)
	var loot := LootData.roll_chest(String(gd["loot"]), _rng, 2)
	for id in loot:
		m.drops.spawn(String(id), int(loot[id]), at)
	if _rng.randf() < float(gd["unique"]):
		var ids := UniquesData.ITEMS.keys()
		m.drops.spawn(String(ids[_rng.randi_range(0, ids.size() - 1)]), 1, at)
	Fx.puff(m.fx, at, Color(gd["color"]) * 1.6)
	m.sfx.play("apri", at)
	if String(s["k"]) == "nido_nascosto":
		_wake_nest(s)
	m.objectives.bump("segreti")
	if c[0] == c[1]:
		m.objectives.bump("mondi_completi")
		m.hud.toast("Hai trovato tutti i segreti di questo mondo!")


## L'Eco dei Seminatori: segna sulla mappa, a grandi linee, i segreti non trovati più vicini.
func use_echo(id: String) -> bool:
	var pc: Vector2i = m.player_cell()
	var open := list.filter(func(s: Dictionary) -> bool: return not s.get("f", false))
	if open.is_empty():
		m.hud.toast("L'Eco torna indietro vuoto: qui non resta nessun segreto")
		return false
	open.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return Vector2(rect_of(a).get_center() - pc).length() < Vector2(rect_of(b).get_center() - pc).length())
	if not m.character.bisaccia.remove(id, 1):
		return false
	for k in mini(SecretsData.ECHO_N, open.size()):
		var s: Dictionary = open[k]
		var q := rect_of(s).get_center() + Vector2i(_rng.randi_range(-SecretsData.ECHO_BLUR, SecretsData.ECHO_BLUR),
			_rng.randi_range(-SecretsData.ECHO_BLUR, SecretsData.ECHO_BLUR))
		var gd: Dictionary = SecretsData.GRADES[clampi(int(s.get("g", 0)), 0, 3)]
		m.language.add_mark(q, "segreto?", Color(gd["color"]))
	m.sfx.play("apri", m.player.position)
	m.hud.toast("L'Eco rimbalza nel mondo: sulla mappa (M) %d segni" % mini(SecretsData.ECHO_N, open.size()))
	return true


## La bacchetta rabdomante: un anello attorno al Germogliato che pulsa più in fretta vicino a un segreto.
func _draw() -> void:
	if rod < 0.0:
		return
	var p: Vector2 = m.player.position
	var speed := 2.0 + rod * 14.0
	var k := 0.5 + 0.5 * sin(_clock * speed)
	var col := Color("#8ef0d8").lerp(Color("#ffd24a"), rod)
	draw_arc(p, 18.0 + k * 6.0 * (0.3 + rod), 0.0, TAU, 32, Color(col, 0.25 + 0.6 * rod * k), 1.5 + rod * 1.5)



## Voce 96: la parete finta crolla appena ci si spinge contro (o la si tocca da sopra o da sotto).
func _push_fake(pc: Vector2i) -> void:
	var w: World = m.world
	for q in [pc + Vector2i(-1, 0), pc + Vector2i(1, 0), pc + Vector2i(-1, -1), pc + Vector2i(1, -1), pc + Vector2i(0, 1),
			pc + Vector2i(0, -2)]:
		if w.inside(q.x, q.y) and w.tile(q.x, q.y) == TileDefs.FINTA:
			crumble(q)
			return


## Fa crollare tutta la parete finta collegata a una cella.
func crumble(start: Vector2i) -> int:
	var w: World = m.world
	var todo: Array[Vector2i] = [start]
	var n := 0
	while not todo.is_empty() and n < 60:
		var q: Vector2i = todo.pop_back()
		if not w.inside(q.x, q.y) or w.tile(q.x, q.y) != TileDefs.FINTA:
			continue
		w.set_tile(q.x, q.y, TileDefs.AIR)
		n += 1
		Fx.puff(m.fx, (Vector2(q) + Vector2(0.5, 0.5)) * 16.0, Color(0.6, 0.65, 0.75))
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			todo.append(q + d)
	if n > 0:
		m.view.refresh_rect(Rect2i(start.x - 8, start.y - 8, 17, 17))
		m.light.dirty = true
		m.sfx.play("rompi", Vector2(start) * 16.0)
		m.hud.toast("La parete era finta!")
	return n


## Voce 96: nel nido nascosto si sveglia una creatura rara dello strato.
func _wake_nest(s: Dictionary) -> void:
	var r := rect_of(s)
	var st := StrataData.at(m.world, r.get_center().x, r.get_center().y)
	var pool := CreaturesData.of_stratum(st, false, "")
	var ok := pool.filter(func(e: Array) -> bool: return int(e[1]) > 0 and not CreaturesData.get_data(String(e[0])).get("fly", false))
	if ok.is_empty():
		return
	var id := String(ok[_rng.randi_range(0, ok.size() - 1)][0])
	var cr: Creature = m.fauna.add(id, (Vector2(r.get_center()) + Vector2(0.5, 0.0)) * 16.0)
	var mult := float(StrataData.STRATA[st]["danger"]) * float(m.fauna.vigor_mult)
	cr.strengthen(mult, mult * DangerData.DAMAGE)
	m.fauna.make_ancient(cr, "antica")
	m.hud.toast("Nel nido dormiva qualcosa di raro…")


## Voce 96: la Mappa del tesoro segna dove è sepolto (i "dati" della casella dicono dove).
func use_treasure_map() -> bool:
	var b: Bisaccia = m.character.bisaccia
	var d: Dictionary = b.data_at(m.hud.sel)
	if not d.has("x"):
		m.hud.toast("La mappa è sbiadita: non si legge più")
		return false
	m.language.add_mark(Vector2i(int(d["x"]), int(d["y"])), "tesoro", Color("#ffd24a"))
	b.take_one(m.hud.sel)
	m.hud.toast("Sulla mappa (M) c'è una croce: il tesoro è sepolto lì sotto")
	return true
