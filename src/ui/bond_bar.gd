class_name BondBar
extends Control
## La barra del compagno (Roadmap 32, voce 311), in basso a destra accanto alla barra rapida: il ritratto di chi è
## in campo con nome, livello, Vita ed esperienza, e sotto i cinque posti della Sacca dei legami (in campo, pronto,
## ferito, KO, vuoto) con i tasti per evocare e cambiare. Si nasconde quando la sacca è vuota.

const W := 380.0
const H := 112.0
const BIG := 64.0                       # il ritratto grande
const SMALL := 30.0                     # i posti della sacca

var m: Node2D
var _t := 0.0
static var _portraits := {}             # specie + manto -> Texture2D


func setup(main: Node2D) -> void:
	m = main
	size = Vector2(W, H)
	position = Vector2(1600.0 - 16.0 - W, Hud.HOTBAR_Y + SlotView.SIZE - H + 4.0)   # a destra (a sinistra ci sono i pulsanti dei pannelli)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	m.bonds.changed.connect(queue_redraw)
	m.herd.changed.connect(queue_redraw)


func _process(dt: float) -> void:
	_t -= dt
	if _t > 0.0:
		return
	_t = 0.2
	var show: bool = m.built and not m.bonds.bag().is_empty() and not m.hud.is_open()   # (Bisaccia aperta: la copre Esamina)
	if visible != show:
		visible = show
	if visible:
		queue_redraw()


## Il ritratto di una scheda (il primo fotogramma della sua specie con il suo manto), fatto una volta.
static func portrait(rec: Dictionary) -> Texture2D:
	var sp := String(rec["specie"])
	var mods: Dictionary = Breeding.mods(rec.get("doti", {}))
	var key := sp + str(mods)
	if not _portraits.has(key):
		var d := CreaturesData.get_data(sp)
		var art: Array = d["art"]
		var fr := CreatureArt.frames(String(art[0]), int(art[1]))
		var all: Dictionary = d.get("art_mods", {}).duplicate()
		all.merge(mods, true)
		if not all.is_empty():
			fr = VariantArt.apply(fr, all)
		_portraits[key] = ImageTexture.create_from_image(CreatureFx.shade(fr["frames"][0]))
	return _portraits[key]


func _draw() -> void:
	if not visible:
		return
	draw_style_box(UiFrames.box("riquadro"), Rect2(Vector2.ZERO, size))
	var f: Font = PixelFont.font()
	var fs := PixelFont.size(2)
	var fs1 := PixelFont.size(1)
	var cur: Dictionary = m.bonds.field()
	var big := Rect2(Vector2(10, 10), Vector2(BIG, BIG))
	draw_style_box(UiFrames.box("casella"), big)
	var x0 := big.end.x + 10.0
	if cur.is_empty():
		draw_string(f, Vector2(x0, 30), "Nessun compagno in campo", HORIZONTAL_ALIGNMENT_LEFT, -1, fs, UiPalette.TESTO_SPENTO)
		draw_string(f, Vector2(x0, 52), "%s: evoca" % Keys.label("compagno"), HORIZONTAL_ALIGNMENT_LEFT, -1, fs1, UiPalette.TESTO_MUTO)
	else:
		_creature(portrait(cur), big.grow(-4.0), 1.0)
		var lvl := int(cur["lvl"])
		draw_string(f, Vector2(x0, 26), String(cur["nome"]), HORIZONTAL_ALIGNMENT_LEFT, -1, fs, UiPalette.TESTO)
		var lt := "liv. %d" % lvl
		var lw := f.get_string_size(lt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		draw_string(f, Vector2(W - 12.0 - lw, 26), lt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, UiPalette.AMBRA_CHIARA)
		var hp := _hp_frac(cur)
		var bw := W - x0 - 12.0
		_bar(Rect2(x0, 34, bw, 12), hp, VitalsView.hp_color(hp))
		var need := HerdData.xp_for(lvl)
		var xf := 1.0 if lvl >= HerdData.LVL_MAX else clampf(float(cur["xp"]) / float(maxi(need, 1)), 0.0, 1.0)
		_bar(Rect2(x0, 50, bw, 6), xf, UiPalette.LINFA)
		var c: Creature = m.herd.beasts.get(int(cur["uid"]))
		if c != null and is_instance_valid(c):
			var t := "%d/%d" % [c.hp, c.hp_max]
			var tw := f.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, fs1).x
			draw_string(f, Vector2(x0 + bw - tw - 4.0, 44), t, HORIZONTAL_ALIGNMENT_LEFT, -1, fs1, UiPalette.FONDO)
	# i cinque posti della sacca
	var list: Array = m.bonds.bag()
	var y := H - SMALL - 8.0
	for i in HerdData.FOLLOW_MAX:
		var r := Rect2(Vector2(10.0 + i * (SMALL + 6.0), y), Vector2(SMALL, SMALL))
		if i >= list.size():
			draw_style_box(UiFrames.box("casella"), r)
			continue
		var rec: Dictionary = list[i]
		var ko := bool(rec.get("ko", false))
		var on := bool(rec.get("campo", false))
		var accent := UiPalette.AMBRA if on else (UiPalette.PERICOLO if ko else Color(0, 0, 0, 0))
		draw_style_box(UiFrames.box("casella", "scelto" if on else "normale", accent), r)
		_creature(portrait(rec), r.grow(-3.0), 0.35 if ko else 1.0)
		if ko:
			draw_line(r.position + Vector2(6, 6), r.end - Vector2(6, 6), UiPalette.PERICOLO, 2.0)
			draw_line(Vector2(r.end.x - 6, r.position.y + 6), Vector2(r.position.x + 6, r.end.y - 6), UiPalette.PERICOLO, 2.0)
		else:
			var hp := 1.0 if on else float(rec.get("vita", 1.0))
			if on:
				hp = _hp_frac(rec)
			if hp < 0.999:
				draw_rect(Rect2(r.position.x + 3, r.end.y - 5, (SMALL - 6.0) * hp, 2), VitalsView.hp_color(hp))
	var hint := "%s evoca · %s cambia" % [Keys.label("compagno"), Keys.label("cambia_compagno")]
	var hw := f.get_string_size(hint, HORIZONTAL_ALIGNMENT_LEFT, -1, fs1).x
	draw_string(f, Vector2(W - 12.0 - hw, H - 14.0), hint, HORIZONTAL_ALIGNMENT_LEFT, -1, fs1, UiPalette.TESTO_MUTO)


func _hp_frac(rec: Dictionary) -> float:
	var c: Creature = m.herd.beasts.get(int(rec["uid"]))
	if c != null and is_instance_valid(c):
		return clampf(float(c.hp) / float(maxi(c.hp_max, 1)), 0.0, 1.0)
	return clampf(float(rec.get("vita", 1.0)), 0.0, 1.0)


## Una creatura dentro un riquadro: ingrandita a pixel interi, centrata.
func _creature(tex: Texture2D, r: Rect2, alpha: float) -> void:
	if tex == null:
		return
	var ts := tex.get_size()
	var k := floorf(minf(r.size.x / ts.x, r.size.y / ts.y))
	if k < 1.0:
		k = minf(r.size.x / ts.x, r.size.y / ts.y)
	var sz := ts * k
	draw_texture_rect(tex, Rect2(r.position + (r.size - sz) * 0.5, sz), false, Color(1, 1, 1, alpha))


func _bar(r: Rect2, f: float, col: Color) -> void:
	draw_rect(r, UiPalette.FONDO)
	draw_rect(Rect2(r.position, Vector2(r.size.x * clampf(f, 0.0, 1.0), r.size.y)), col)
	draw_rect(r, UiPalette.BORDO, false, 1.0)
