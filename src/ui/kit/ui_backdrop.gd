class_name UiBackdrop
extends Control
## Lo sfondo dei pannelli a schermo intero (Roadmap 55): inchiostro pieno (copre il mondo), una luce morbida del colore
## del pannello dall'alto a sinistra, i bordi appena più scuri. Disegnato una volta in un'immagine piccola e stirata
## (le sfumature non hanno scalini).

var tint := UiPalette.AMBRA
static var _cache := {}


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR


func _draw() -> void:
	var key := tint.to_html()
	if not _cache.has(key):
		_cache[key] = _paint(tint)
	draw_texture_rect(_cache[key], Rect2(Vector2.ZERO, size), false)


static func _paint(c: Color) -> Texture2D:
	var w := 200
	var h := 113
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	var base := UiPalette.FONDO
	for y in h:
		for x in w:
			var p := Vector2(float(x) / w, float(y) / h)
			var glow := exp(-((p - Vector2(0.12, 0.0)) * Vector2(1.0, 1.6)).length_squared() * 3.2) * 0.10
			var low := exp(-((p - Vector2(0.85, 1.05)) * Vector2(1.0, 1.4)).length_squared() * 4.0) * 0.05
			var edge := Vector2(absf(p.x - 0.5), absf(p.y - 0.5)).length()
			var col := base.lerp(c, glow).lerp(UiPalette.LINFA, low)
			col = col.darkened(clampf((edge - 0.45) * 0.6, 0.0, 0.25))
			img.set_pixel(x, y, Color(col, 1.0))
	return ImageTexture.create_from_image(img)
