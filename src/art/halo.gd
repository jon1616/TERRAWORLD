class_name Halo
extends Node2D
## L'alone animato delle creature rare (8 ott 2026, richiesta dell'utente: «una tavola per grado… adatta l'effetto alle
## dimensioni e al profilo delle creature»). I fotogrammi sono di Nano Banana (`arte/effetti/alone_<grado>_<n>.png`,
## bianchi con l'alfa = luce, fatti da `tools/importa_effetto.py`; la «base» = dove poggiano i piedi, nel .json): si
## colorano con il colore della rarità e si **sommano** alla scena come luce. Due fotogrammi sfumati uno nell'altro, così
## otto disegni bastano per un ciclo morbido. La misura segue la parte disegnata della creatura, larghezza e altezza
## separate: una creatura bassa e larga ha un arco basso e largo.

const FPS := 7.0
const WIDE := 1.75          # l'alone largo quanto la figura × questo (l'apertura dell'arco è circa metà della larghezza)
const TALL := 1.5           # alto (sopra i piedi) quanto la figura × questo
const MIN_PX := 18.0        # le creature piccolissime hanno comunque un alone che si vede

static var _sets := {}       # nome → {"frames": Array[Texture2D], "base": float} (o {} se manca)
static var _boxes := {}      # id della texture → la parte disegnata (Rect2i)

var _a: Sprite2D
var _b: Sprite2D
var _frames: Array = []
var _base := 0.8
var _t := 0.0


## I fotogrammi di un alone, o {} se non è ancora disegnato.
static func frames_of(nome: String) -> Dictionary:
	if _sets.has(nome):
		return _sets[nome]
	var out := {}
	var fr: Array = []
	var i := 1
	while true:
		var t := ArtLib.tex("effetti", "%s_%d" % [nome, i])
		if t == null:
			break
		fr.append(t)
		i += 1
	if not fr.is_empty():
		var base := 0.8
		var f := FileAccess.open("res://arte/effetti/%s.json" % nome, FileAccess.READ)
		if f != null:
			var d: Variant = JSON.parse_string(f.get_as_text())
			if d is Dictionary:
				base = float((d as Dictionary).get("base", base))
		out = {"frames": fr, "base": base}
	_sets[nome] = out
	return out


## Un alone pronto, o null se il grado non ha ancora il suo disegno (resta il contorno di `Ancient.ring`).
static func make(nome: String) -> Halo:
	var s := frames_of(nome)
	if s.is_empty():
		return null
	var h := Halo.new()
	h._frames = s["frames"]
	h._base = float(s["base"])
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	h._a = Sprite2D.new()
	h._b = Sprite2D.new()
	for sp in [h._a, h._b]:
		sp.material = mat
		sp.texture = h._frames[0]
		h.add_child(sp)
	h._t = randf() * h._frames.size() / FPS      # due rare vicine non respirano insieme
	return h


static func _box(tex: Texture2D) -> Rect2i:
	var key := tex.get_instance_id()
	if not _boxes.has(key):
		var img := tex.get_image()
		_boxes[key] = img.get_used_rect() if img != null else Rect2i(Vector2i.ZERO, tex.get_size())
	return _boxes[key]


## Ogni fotogramma: il ciclo e la misura sulla figura di adesso (la posa cambia, la creatura cresce o respira).
func step(spr: Sprite2D, dt: float) -> void:
	_t += dt
	var n := _frames.size()
	var p := fmod(_t * FPS, float(n))
	var i := int(p)
	var f := p - i
	_a.texture = _frames[i]
	_b.texture = _frames[(i + 1) % n]
	_a.modulate.a = 1.0 - f
	_b.modulate.a = f
	# la parte disegnata della figura, nelle coordinate della creatura
	var tex := spr.texture
	if tex == null:
		return
	var r := _box(tex)
	var sc := spr.scale.abs()
	var ts := Vector2(tex.get_size())
	var w := maxf(r.size.x * sc.x, MIN_PX * 0.6)
	var hgt := maxf(r.size.y * sc.y, MIN_PX * 0.6)
	var feet := spr.position.y + (spr.offset.y + r.end.y - ts.y / 2.0) * sc.y
	var hs := Vector2(_frames[0].get_size())
	var want_w := maxf(w * WIDE, MIN_PX)
	var want_h := maxf(hgt * TALL, MIN_PX * 0.8)
	scale = Vector2(want_w / hs.x, want_h / (hs.y * _base))
	# l'anello a terra (la «base» del disegno) sui piedi della figura, al centro del corpo
	position = Vector2(0, feet - (_base - 0.5) * hs.y * scale.y)
