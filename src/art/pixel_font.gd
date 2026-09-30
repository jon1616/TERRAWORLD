class_name PixelFont
extends RefCounted
## Il carattere di pixel del gioco (voce 272, guida `ARTE.md` §5), disegnato dal codice da `PixelGlyphs`: per i titoli
## dei pannelli e i numeri (barra rapida, danno), mai per il testo lungo. È un carattere a bitmap alto `H` pixel: si usa
## solo a misure multiple di `H` (`size(k)` = k volte), così ogni pixel della lettera è un quadrato netto di k × k.
## Ha le lettere dell'italiano e i segni del gioco; quelle che mancano non si vedono: si aggiungono a `PixelGlyphs`.

const H := 11                  # righe della cella: 2 per gli accenti delle maiuscole, 7 di maiuscola, 2 di coda
const ASCENT := 9              # dalla cima della cella alla linea di base
const SPACE := 3               # la larghezza dello spazio

static var _font: FontFile


## La misura del carattere per `k` pixel dello schermo per pixel della lettera (2 = numeri e sottotitoli, 3 = titoli).
static func size(k: int) -> int:
	return H * k


static func font() -> FontFile:
	if _font == null:
		_font = _build()
	return _font


## Mette il carattere su un'etichetta: `k` volte, colore e, per il testo sopra il mondo, un'ombra di un pixel.
static func apply(l: Control, k: int, col := Color(0, 0, 0, 0), shadow := false) -> void:
	l.add_theme_font_override("font", font())
	l.add_theme_font_size_override("font_size", size(k))
	l.add_theme_constant_override("line_spacing", 0)
	if col.a > 0.0:
		l.add_theme_color_override("font_color", col)
	if shadow:
		l.add_theme_color_override("font_shadow_color", Color(0.01, 0.03, 0.04, 0.9))
		l.add_theme_constant_override("shadow_offset_x", k)
		l.add_theme_constant_override("shadow_offset_y", k)
		l.add_theme_constant_override("shadow_outline_size", 0)


static func _build() -> FontFile:
	var cells := {}                      # carattere -> Image della cella (larghezza della lettera × H)
	for ch in PixelGlyphs.CAPS:
		cells[ch] = _cell(PixelGlyphs.CAPS[ch], 2)
	for ch in PixelGlyphs.SMALL:
		cells[ch] = _cell(PixelGlyphs.SMALL[ch], 2)
	for ch in PixelGlyphs.ACCENTED:
		var pair: Array = PixelGlyphs.ACCENTED[ch]
		var base := String(pair[0])
		var small := PixelGlyphs.SMALL.has(base)
		var rows: Array = PixelGlyphs.SMALL[base] if small else PixelGlyphs.CAPS[base]
		var mark: Array = PixelGlyphs.MARKS[String(pair[1])]
		var img := _cell(rows, 2, 2)
		var mx := (img.get_width() - 2) / 2
		var my := 2 if small else 0
		for y in 2:
			for x in 2:
				if String(mark[y])[x] == "#":
					img.set_pixel(mx + x, my + y, Color.WHITE)
		cells[ch] = img
	# l'atlante: le celle una accanto all'altra, con un pixel vuoto tra l'una e l'altra
	var total := 0
	for ch in cells:
		total += (cells[ch] as Image).get_width() + 1
	var atlas := Image.create(maxi(total, 1), H, false, Image.FORMAT_RGBA8)
	var f := FontFile.new()
	f.fixed_size = H
	f.fixed_size_scale_mode = TextServer.FIXED_SIZE_SCALE_INTEGER_ONLY
	f.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	f.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	f.generate_mipmaps = false
	# niente carattere di riserva: le sue misure (più alte) allargherebbero ogni riga; le lettere che mancano si
	# aggiungono a `PixelGlyphs`
	var sz := Vector2i(H, 0)
	f.set_cache_ascent(0, H, ASCENT)
	f.set_cache_descent(0, H, H - ASCENT)
	var x := 0
	for ch in cells:
		var img: Image = cells[ch]
		atlas.blit_rect(img, Rect2i(0, 0, img.get_width(), H), Vector2i(x, 0))
		var g := String(ch).unicode_at(0)
		f.set_glyph_advance(0, H, g, Vector2(img.get_width() + 1, 0))
		f.set_glyph_offset(0, sz, g, Vector2(0, -ASCENT))
		f.set_glyph_size(0, sz, g, Vector2(img.get_width(), H))
		f.set_glyph_uv_rect(0, sz, g, Rect2(x, 0, img.get_width(), H))
		f.set_glyph_texture_idx(0, sz, g, 0)
		x += img.get_width() + 1
	var sp := " ".unicode_at(0)
	f.set_glyph_advance(0, H, sp, Vector2(SPACE, 0))
	f.set_glyph_size(0, sz, sp, Vector2.ZERO)
	f.set_glyph_texture_idx(0, sz, sp, -1)
	f.set_texture_image(0, sz, 0, atlas)
	return f


## Una cella alta H con le righe della lettera a partire dalla riga `top`; larga almeno `min_w`.
static func _cell(rows: Array, top: int, min_w := 1) -> Image:
	var w := min_w
	for r in rows:
		w = maxi(w, String(r).length())
	var img := Image.create(w, H, false, Image.FORMAT_RGBA8)
	var dx := 0
	# le lettere strette in una cella più larga (la ı accentata) stanno al centro
	var own := 0
	for r in rows:
		own = maxi(own, String(r).length())
	dx = (w - own) / 2
	for y in rows.size():
		var r := String(rows[y])
		for x in r.length():
			if r[x] == "#":
				img.set_pixel(x + dx, top + y, Color.WHITE)
	return img
