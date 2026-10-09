class_name Cascades
extends Node
## Le cascate (voce 482): l'acqua esce dalle sorgenti che il generatore ha trovato (`PassCascate`, appunti "cascate",
## copiati una volta in `world_meta["cascate"]`), cade dritta nello specchio sotto, e lo «scarico» toglie l'acqua che
## arriva sopra il pelo dello specchio: il livello resta quello del mondo appena nato e la valle non si allaga mai.
## Come i liquidi lavorano solo vicino al Germogliato (`LiquidsData.WINDOW`); la caduta, gli spruzzi e la schiuma li
## disegnano `LiquidView` e `WaterFx`, come per ogni acqua che cade.
## [x, y della sorgente, lato, y del pelo, x0, x1 dello specchio]

const EMIT := 3                         # livelli (1/8 di cella) nella bocca, rimessi appena l'acqua è caduta giù
const DRAIN_ROWS := 2                   # righe sopra il pelo che lo scarico svuota

var m: Node2D
var list: Array = []
var paused := false                     # (le prove che misurano i liquidi la fermano)
var drained := 0                        # livelli tolti dallo scarico (per le prove)


var _fx: CascadeFx


func setup(main: Node2D) -> void:
	m = main
	_fx = CascadeFx.new()
	_fx.z_index = 12                          # con i liquidi (`LiquidView`), sotto la luce
	m.view.add_child(_fx)


func _process(dt: float) -> void:
	if not m.built or paused:
		return
	if list.is_empty() and not m.world_meta.has("cascate"):
		var notes: Variant = m.world.gen_notes.get("cascate", [])
		m.world_meta["cascate"] = (notes as Array).duplicate(true)
	list = m.world_meta.get("cascate", [])
	if list.is_empty():
		return
	var pc: Vector2i = m.player_cell()
	var win := LiquidsData.WINDOW
	var w: World = m.world
	var shown := []
	for e in list:
		var sx := int(e[0])
		var sy := int(e[1])
		if absi(sx - pc.x) > win.x - 4 or absi(sy - pc.y) > win.y - 4:
			continue
		var ex := sx + int(e[2])
		# la bocca si riempie appena si è svuotata (il getto che si vede lo disegna `CascadeFx`)
		if w.inside(ex, sy) and not w.solid(ex, sy) and w.liq(ex, sy) == 0:
			m.liquids.pour(Vector2i(ex, sy), EMIT, 0)
		_drain(w, ex, int(e[3]), int(e[4]), int(e[5]))
		shown.append([ex, sy, int(e[3])])
	_fx.cols = shown
	_fx.queue_redraw()


## Toglie l'acqua sopra il pelo dello specchio (le righe appena sopra, su tutta la sua larghezza), ma non dalla colonna
## dove cade (lx e le due accanto): lì l'acqua deve arrivare fino al pelo, se no la cascata finirebbe a mezz'aria.
func _drain(w: World, lx: int, ys: int, x0: int, x1: int) -> void:
	for y in range(maxi(ys - DRAIN_ROWS, 1), ys):
		for x in range(maxi(x0 - 1, 1), mini(x1 + 2, w.w - 1)):
			if absi(x - lx) <= 1:
				continue
			var v := w.liquid[y * w.w + x]
			if (v & 15) > 0 and (v >> 4) == 0:
				drained += v & 15
				w.set_liq(x, y, 0, 0)
				m.liquids.wake(x, y + 1)
				m.liquids.view.touch(Vector2i(x, y))


## Il getto disegnato (voce 482): il motore dei liquidi fa scendere l'acqua anche di più celle in un passo, e la caduta
## vera si vedeva a grumi; qui una colonna d'acqua continua dalla bocca al pelo, con le strisce chiare che scendono.
## Solo vista: l'acqua che conta è quella dei liquidi.
class CascadeFx extends Node2D:
	var cols: Array = []                    # [x della colonna, y della bocca, y del pelo]
	var _t := 0.0

	func _process(dt: float) -> void:
		_t += dt

	func _draw() -> void:
		var td: Dictionary = LiquidsData.TYPES[0]
		var body := Color(td["color"] as Color, 0.62)
		var lite := Color(td["top"] as Color, 0.55)
		for c in cols:
			var x := float(int(c[0]) * 16)
			var y0 := float(int(c[1]) * 16)
			var y1 := float(int(c[2]) * 16)
			draw_rect(Rect2(x + 3.0, y0, 10.0, y1 - y0), body)
			# le strisce che scendono, a velocità diverse
			for k in 3:
				var sp := 140.0 + k * 55.0
				var off := fmod(_t * sp + k * 37.0, 48.0)
				var yy := y0 + off - 48.0
				while yy < y1:
					var a := maxf(yy, y0)
					var b := minf(yy + 14.0, y1)
					if b > a:
						draw_line(Vector2(x + 5.0 + k * 3.0, a), Vector2(x + 5.0 + k * 3.0, b), lite, 1.5)
					yy += 48.0
			# la schiuma dove cade
			draw_circle(Vector2(x + 8.0, y1), 6.0 + sin(_t * 9.0) * 1.5, Color(1, 1, 1, 0.35))
