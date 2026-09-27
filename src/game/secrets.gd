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
