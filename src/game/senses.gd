class_name Senses
extends Node
## Ciò che le creature sentono del Germogliato (voce 129, il cervello in `Mind`): quanta luce ha addosso, se è ferito,
## se tiene un'esca, e i rumori che fa (scavo, colpi, passi di corsa; le esplosioni le annuncia `Throwing`).

const EVERY := 0.2
const DIG_NOISE := 9.0                   # tessere
const SWING_NOISE := 7.0
const RUN_NOISE := 4.0
const BLAST_NOISE := 28.0
const LIT_GAIN := 1.6                    # la luce della cella del Germogliato, portata a 0-1

var m: Node2D
var paused := false                      # le prove fissano `Mind.lit` a mano
var _t := 0.0
var _step := 0.0


func setup(main: Node2D) -> void:
	m = main
	Mind.reset()
	m.actions.dug.connect(func(_t2: int, c: Vector2i) -> void: Mind.noise((Vector2(c) + Vector2(0.5, 0.5)) * 16.0, DIG_NOISE))


func _process(dt: float) -> void:
	if m == null or not m.built:
		return
	for n in Mind.noises:
		n["t"] = float(n["t"]) - dt
	Mind.noises = Mind.noises.filter(func(n: Dictionary) -> bool: return float(n["t"]) > 0.0)
	var p: Player = m.player
	_step -= dt
	if _step <= 0.0 and p.on_floor and absf(p.vel.x) > 70.0:
		_step = 0.6
		Mind.noise(p.position, RUN_NOISE)
	_t -= dt
	if _t > 0.0 or paused:
		return
	_t = EVERY
	var v: float = m.light.value_at(Vector2i(floori(p.position.x / 16.0), floori(p.position.y / 16.0)))
	Mind.lit = 1.0 if v < 0.0 else clampf(v * LIT_GAIN, 0.0, 1.0)
	Mind.blood = m.vitals.hp < m.vitals.hp_max * Mind.BLOOD_BELOW
	Mind.bait = String(ItemsData.get_item(String(m.hud.current().get("id", ""))).get("kind", "")) == "esca"
