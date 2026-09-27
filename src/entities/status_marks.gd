class_name StatusMarks
extends Node2D
## Voce 101: gli stati di una creatura come icone sopra la sua barra della Vita (brucia, avvelenata, rallentata,
## vulnerabile, stordita). Le icone sono di 16 px disegnate a metà (8 unità del mondo): con la visuale ingrandita due
## volte tornano a 16 pixel netti sullo schermo. Si controlla quattro volte al secondo, non a ogni fotogramma.

const SIZE := 8.0
const GAP := 1.0
const EVERY := 0.25

var cr: Creature
var _shown: Array[String] = []
var _t := 0.0


func _init(c: Creature) -> void:
	cr = c
	z_index = 27


func _process(dt: float) -> void:
	_t -= dt
	if _t > 0.0:
		return
	_t = EVERY
	var now := states(cr)
	if now != _shown:
		_shown = now
		queue_redraw()


## Le icone degli stati che la creatura ha adesso (nomi dei file in arte/interfaccia/).
static func states(c: Creature) -> Array[String]:
	var out: Array[String] = []
	if c.burn_t > 0.0:
		out.append("brace")
	if c.poison_t > 0.0:
		out.append("spora")
	if c.chill_t > 0.0:
		out.append("rallentato")
	if c.weak_t > 0.0:
		out.append("vulnerabile")
	if c.stun > 0.0:
		out.append("stordito")
	return out


func _draw() -> void:
	var n := _shown.size()
	var x := -(n * SIZE + (n - 1) * GAP) * 0.5
	for id in _shown:
		var t := ArtLib.tex("interfaccia", id)
		if t != null:
			draw_texture_rect(t, Rect2(x, -SIZE, SIZE, SIZE), false)
		x += SIZE + GAP
