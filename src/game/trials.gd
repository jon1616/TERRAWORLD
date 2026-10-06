class_name Trials
extends Node
## Le prove del Cerchio (Roadmap 25, voce 250): al Cerchio dei Seminatori (stazione «arena»), clic destro due volte di
## fila = comincia la prova a ondate. `WAVES` ondate di creature dello strato del Cerchio, sempre di più e più forti
## (`STEP` per ondata, oltre al vigore del mondo); alle ondate multiple di `BOSS_EVERY` anche un capo ancestrale.
## L'ondata dopo parte quando la precedente è tutta sconfitta. Finisce vincendo l'ultima, appassendo o allontanandosi
## più di `LEAVE` tessere. Premio secondo le ondate vinte; il record in `Character.stats["prova_record"]`.

const S := 16.0
const WAVES := 10
const BOSS_EVERY := 5
const STEP := 0.12
const LEAVE := 45.0
const SPAWN_R := [9, 15]
const CONFIRM := 6.0

var m: Node2D
var arena := Vector2i(-1, -1)
var wave := 0
var active := false
var _list: Array = []
var _confirm_t := 0.0
var _confirm_o := Vector2i(-1, -1)
var _rng := RandomNumberGenerator.new()


func setup(main: Node2D) -> void:
	m = main
	_rng.randomize()
	m.vitals.died.connect(func() -> void:
		if active:
			finish(false))


## Clic destro sul Cerchio: la prima volta spiega, la seconda (entro qualche secondo) comincia.
func touch(o: Vector2i) -> bool:
	if active:
		m.hud.toast("Prova in corso: ondata %d di %d" % [wave, WAVES])
		return true
	var now := Time.get_ticks_msec() / 1000.0
	if _confirm_o == o and now < _confirm_t:
		start(o)
		return true
	_confirm_o = o
	_confirm_t = now + CONFIRM
	m.hud.toast("La prova del Cerchio: %d ondate, un capo ogni %d. Record: %d. Clic destro di nuovo per cominciare" % [WAVES,
		BOSS_EVERY, int(m.character.stats.get("prova_record", 0))])
	return true


func start(o: Vector2i) -> void:
	arena = o
	wave = 0
	active = true
	_list.clear()
	_next()


func center() -> Vector2:
	return (Vector2(arena) + Vector2(1.5, -1.0)) * S


## Le creature della prova: quelle comuni dello strato del Cerchio.
func pool() -> Array:
	var st := StrataData.at(m.world, arena.x, arena.y)
	var out := []
	for cid in CreaturesData.CREATURES:
		var c: Dictionary = CreaturesData.CREATURES[cid]
		if int(c.get("weight", 0)) > 0 and st in (c.get("strata", []) as Array) and not c.get("boss", false) \
				and not c.get("docile", false) and not c.has("water") and not c.has("sky") and not c.has("perduto"):
			out.append(String(cid))
	return out if not out.is_empty() else ["grumo_muschio"]


func _next() -> void:
	wave += 1
	var p := pool()
	var n := 2 + wave
	var mult: float = m.fauna.vigor_mult * (1.0 + STEP * (wave - 1))
	for k in n:
		var cr := _spawn(String(p[_rng.randi_range(0, p.size() - 1)]))
		if cr != null:
			cr.strengthen(mult, m.fauna.dmg_for(mult))
	if wave % BOSS_EVERY == 0:
		var b := _spawn(String(p[_rng.randi_range(0, p.size() - 1)]))
		if b != null:
			m.fauna.make_ancient(b, "ancestrale")
			b.strengthen(mult, m.fauna.dmg_for(mult))
	m.hud.toast("Prova del Cerchio: ondata %d di %d%s" % [wave, WAVES, " · un capo!" if wave % BOSS_EVERY == 0 else ""])
	m.sfx.play("guardiano" if wave % BOSS_EVERY == 0 else "presenza")


func _spawn(cid: String) -> Creature:
	var fly: bool = CreaturesData.get_data(cid).get("fly", false)
	for tries in 20:
		var dx := _rng.randi_range(SPAWN_R[0], SPAWN_R[1]) * (1 if _rng.randf() < 0.5 else -1)
		var c := arena + Vector2i(dx, -1)
		for dy in range(-6, 7):
			var q := c + Vector2i(0, dy)
			if m.fauna._free(q.x, q.y) and (fly or m.world.solid(q.x, q.y + 1)):
				var cr: Creature = m.fauna.add(cid, Vector2(q.x * S + 8, (q.y + 1) * S - float(CreaturesData.get_data(cid)["half"][1]) - 0.1))
				cr.set_meta("prova", true)
				_list.append(cr)
				return cr
	return null


func _process(_dt: float) -> void:
	if not active or m == null or not m.built:
		return
	if m.player.position.distance_to(center()) > LEAVE * S:
		finish(false)
		return
	_list = _list.filter(func(c: Variant) -> bool: return is_instance_valid(c) and m.fauna.list.has(c))
	if _list.is_empty():
		m.objectives.bump("prove_ondate")
		if wave >= WAVES:
			finish(true)
		else:
			_next()


## Fine della prova: premio per le ondate vinte, record.
func finish(win: bool) -> void:
	active = false
	var won := wave if win else wave - 1
	for c in _list:
		if is_instance_valid(c) and m.fauna.list.has(c):
			m.fauna.kill_quietly(c)
	_list.clear()
	var st: Dictionary = m.character.stats
	var rec := won > int(st.get("prova_record", 0))
	if rec:
		st["prova_record"] = won
	if won <= 0:
		m.hud.toast("La prova del Cerchio è finita: nessuna ondata vinta")
		return
	var gift := {"scheggia_vigore": won, "polvere_iridata": maxi(1, won / 3)}
	if win:
		gift["linfa_antica"] = 3
		m.objectives.bump("prove_vinte")
	m.hud.toast("Prova del Cerchio: %d ondate vinte%s · %s" % [won, " (record!)" if rec else "", Lineage._give(m, gift)])
	m.sfx.play("dono")
