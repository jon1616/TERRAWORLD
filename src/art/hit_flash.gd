class_name HitFlash
extends Node2D
## Lo scoppio dipinto di un colpo (8 ott 2026, richiesta dell'utente: «facciamo i colpi per elemento»): otto fotogrammi
## di Nano Banana (`arte/effetti/colpo_<elemento>_<n>.png`, bianchi con l'alfa = luce, fatti da
## `tools/importa_effetto.py --centro`), colorati con l'elemento e sommati come luce, sopra le scintille di `ImpactFx`.
## Uno scoppio nasce, esplode e svanisce in `LIFE` secondi; grande quanto la creatura colpita (fra `MIN_PX` e `MAX_PX`),
## girato e specchiato a caso perché due colpi di fila non siano uguali.

const LIFE := 0.42
const MIN_PX := 22.0
const MAX_PX := 72.0
const PHYSICAL := Color(1.25, 1.0, 0.7)       # il colpo senza elemento: bianco caldo

var _spr: Sprite2D
var _frames: Array = []
var _t := 0.0


## Dove e quanto grande colpire una creatura: il centro e l'altezza della parte DISEGNATA (il corpo degli urti è più
## piccolo del disegno: sul cervo lo scoppio partiva dalle zampe). [centro nel mondo, altezza].
static func aim(c: Creature) -> Array:
	var spr: Sprite2D = c._spr
	if spr == null or spr.texture == null:
		return [c.position, c.half.y * 2.0]
	var r := Halo._box(spr.texture)
	var sc := spr.scale.abs()
	var ts := Vector2(spr.texture.get_size())
	var top := spr.position.y + (spr.offset.y + r.position.y - ts.y / 2.0) * sc.y
	var h := r.size.y * sc.y
	return [c.position + Vector2(0, top + h / 2.0), h]


## `elem` = l'elemento del colpo («» = senza), `size` = l'altezza della creatura colpita. Niente se non c'è il disegno.
static func play(parent: Node, pos: Vector2, elem: String, size: float) -> void:
	var nome := "colpo_" + (elem if elem != "" else "fisico")
	var s := Halo.frames_of(nome)
	if s.is_empty():
		return
	var f := HitFlash.new()
	f._frames = s["frames"]
	f._spr = Sprite2D.new()
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	f._spr.material = mat
	f._spr.texture = f._frames[0]
	f._spr.flip_h = randf() < 0.5
	f.add_child(f._spr)
	var col := PHYSICAL
	if ElementsData.ELEMENTS.has(elem):
		col = Color(String(ElementsData.ELEMENTS[elem]["color"])) * 1.35
	f.modulate = col
	var px := clampf(size * 0.95, MIN_PX, MAX_PX)
	f.scale = Vector2.ONE * px / float((f._frames[0] as Texture2D).get_width())
	f.rotation = randf_range(-0.35, 0.35)
	f.position = pos
	f.z_as_relative = false
	f.z_index = 25                         # sopra l'immagine della luce, come gli aloni: si vede anche al buio
	parent.add_child(f)


func _process(dt: float) -> void:
	_t += dt
	var k := int(_t / LIFE * _frames.size())
	if k >= _frames.size():
		queue_free()
		return
	_spr.texture = _frames[k]
