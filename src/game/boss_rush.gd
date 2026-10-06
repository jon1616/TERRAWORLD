class_name BossRush
extends Node
## La corsa dei Guardiani (voce 377, Roadmap 41). Al Cerchio dei Seminatori il Corno della corsa (fatto con i dodici
## Richiami) chiama i dodici Guardiani della spina uno dopo l'altro, con la forza del mondo in cui si è (almeno quella
## del loro vigore) per `K`: meno che da soli, perché sono tanti. Tra uno e l'altro `PAUSE` secondi. Chi appassisce perde
## la corsa; chi li batte tutti vince il premio (la tabella «premio_corsa»: la Corona della corsa la prima volta, armi
## firma dell'ultima fase, Linfa antica, Lumini). Nel personaggio `stats["corse_vinte"]` e il tempo migliore.

const K := 0.55
const PAUSE := 3.0

var m: Node2D
var queue: Array = []
var current: Creature
var arena := Vector2i(-1, -1)
var running := false
var _wait := 0.0
var _time := 0.0
var _rng := RandomNumberGenerator.new()


func setup(main: Node2D) -> void:
	m = main
	_rng.randomize()
	m.fauna.killed.connect(func(c: Creature) -> void:
		if running and c == current:
			current = null
			_wait = PAUSE
			m.hud.toast("Ne restano %d" % queue.size()))


## Il Corno in mano, vicino al Cerchio. True se la corsa è cominciata.
func start() -> bool:
	if running:
		m.hud.toast("La corsa è già cominciata")
		return false
	var o: Vector2i = m.summons.near_arena()
	if o.x < 0:
		m.hud.toast("Serve un Cerchio dei Seminatori qui vicino")
		return false
	if not m.character.bisaccia.remove("corno_corsa", 1):
		return false
	arena = o
	queue.clear()
	for g in GuardiansData.LIST:
		queue.append(g)
	running = true
	_wait = 1.0
	_time = 0.0
	m.fauna.quiet_c = o
	m.depth_watch.banner.show_stratum("La corsa dei Guardiani", "Dodici Guardiani, uno dopo l'altro", Color("#ffd08a"))
	return true


func _process(dt: float) -> void:
	if not running:
		return
	_time += dt
	if m.life.dead:
		_finish(false)
		return
	if current != null and is_instance_valid(current):
		return
	_wait -= dt
	if _wait > 0.0:
		return
	if queue.is_empty():
		_finish(true)
		return
	var g: Dictionary = queue.pop_front()
	var cid := String(g["creature"])
	var fly: bool = CreaturesData.get_data(cid).get("fly", false)
	var at := (Vector2(arena) + Vector2(1.5, -8.0 if fly else -3.0)) * 16.0
	current = m.fauna.add(cid, at)
	var v := maxi(int(m.world_meta.get("vigore", 1)), int(g.get("vigor", 1)))
	current.strengthen(Portal.boss_mult(v) * K, Portal.vigor_dmg(v))
	current.provoke()
	m.guardian.bar.follow(current)
	m.sfx.play("guardiano")


func _finish(won: bool) -> void:
	running = false
	m.fauna.quiet_c = Vector2i(-1, -1)
	if current != null and is_instance_valid(current):
		m.fauna.kill_quietly(current)
	current = null
	m.guardian.bar.follow(null)
	if not won:
		m.hud.toast("La corsa è persa: i Guardiani tornano a dormire")
		return
	var ch: Character = m.character
	var first := int(ch.stats.get("corse_vinte", 0)) == 0
	ch.stats["corse_vinte"] = int(ch.stats.get("corse_vinte", 0)) + 1
	var best := int(ch.stats.get("corsa_migliore", 0))
	if best == 0 or int(_time) < best:
		ch.stats["corsa_migliore"] = int(_time)
	var got := LootData.roll("premio_corsa", _rng, first)
	for id in got:
		m.drops.spawn(String(id), int(got[id]), m.player.position + Vector2(0, -20))
	m.depth_watch.banner.show_stratum("La corsa è vinta", "%d minuti e %d secondi" % [int(_time) / 60, int(_time) % 60],
		Color("#ffd08a"))
