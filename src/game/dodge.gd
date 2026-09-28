class_name Dodge
extends Node
## Il tasto della schivata (voce 127): con un oggetto che la sblocca (`DashData`) lo scatto parte verso dove si va, con
## un attimo d'invulnerabilità (`Combat.invuln`). Senza, un avviso dice che cosa serve (una volta ogni tanto).

var m: Node2D
var _warned := 0.0
var dashes := 0                          # quante schivate (per le prove)


func setup(main: Node2D) -> void:
	m = main


func _process(dt: float) -> void:
	_warned = maxf(_warned - dt, 0.0)


func _unhandled_input(e: InputEvent) -> void:
	if m == null or not m.built or m.hud.is_open() or not Keys.pressed(e, "schiva"):
		return
	get_viewport().set_input_as_handled()
	dash()


## Prova a schivare verso dove si tiene premuto (o dove si guarda). Restituisce vero se è partita.
func dash() -> bool:
	var p: Player = m.player
	if not p.dash_ok:
		if _warned <= 0.0:
			m.hud.toast("Per schivare serve un oggetto: il Cavigliere di vento (al Telaio)")
			_warned = 20.0
		return false
	var dir := 0.0
	if Keys.held("sinistra"):
		dir = -1.0
	elif Keys.held("destra"):
		dir = 1.0
	if not p.try_dash(dir):
		return false
	m.combat.invuln = maxf(m.combat.invuln, DashData.INVULN)
	Fx.puff(m.fx, p.position, Color(1.2, 1.4, 1.6))
	m.sfx.play("soffio", p.position)
	dashes += 1
	return true
