class_name Juice
extends Node
## Le sensazioni dei colpi (voce 293; l'utente: «vivo ma sobrio»): una scossa piccola della visuale quando il
## Germogliato è ferito (più forte se la ferita è grande, mai oltre 5 px), una pausa d'impatto brevissima quando una
## creatura cade. Opzione «scosse»; spente nelle prove (le misure del movimento vogliono il tempo vero).

const SHAKE_MAX := 5.0
const STOP := 0.035                    # secondi veri della pausa d'impatto

static var enabled := true

var m: Node2D
var _shake := 0.0
var _shake_t := 0.0
var _stopping := false


func setup(main: Node2D) -> void:
	m = main
	if "--prove" in OS.get_cmdline_user_args():
		enabled = false
	m.vitals.wounded.connect(func(amount: int) -> void: shake(clampf(amount / 8.0, 1.5, SHAKE_MAX), 0.2))
	m.fauna.killed.connect(func(_c: Creature) -> void: hit_stop())


func _on() -> bool:
	return enabled and bool(Settings.v("scosse"))


func shake(px: float, dur: float) -> void:
	if not _on():
		return
	_shake = maxf(_shake, px)
	_shake_t = maxf(_shake_t, dur)


func hit_stop() -> void:
	if not _on() or _stopping or Engine.time_scale != 1.0:
		return
	_stopping = true
	Engine.time_scale = 0.05
	await get_tree().create_timer(STOP, true, false, true).timeout
	if Engine.time_scale == 0.05:
		Engine.time_scale = 1.0
	_stopping = false


func _process(dt: float) -> void:
	if _shake_t <= 0.0:
		if m.cam.offset != Vector2.ZERO:
			m.cam.offset = Vector2.ZERO
		return
	_shake_t -= dt
	var k := clampf(_shake_t / 0.2, 0.0, 1.0)
	# pixel interi: la visuale salta di 1-5 px e torna, senza sfocare la pixel art
	m.cam.offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).round() * roundf(_shake * k * 0.5)
	if _shake_t <= 0.0:
		_shake = 0.0
		m.cam.offset = Vector2.ZERO


func _exit_tree() -> void:
	if _stopping:
		Engine.time_scale = 1.0
