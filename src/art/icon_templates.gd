class_name IconTemplates
extends RefCounted
## Voce 105: le forme delle icone disegnate con Nano Banana (`arte/forme/<forma>.png`, 16×16, fatte da
## `arte_ia/icone/rifai.sh`). La parte del materiale è disegnata in grigi neutri e prende la tavolozza di ogni
## materiale (`ItemIcons.pal`, anche le leghe): una forma disegnata una volta dà tutta la famiglia. Senza il file,
## `ItemIcons` disegna la forma del codice come prima.


## L'icona della forma colorata con la tavolozza `p`, o null se la forma non è disegnata.
static func make(shape: String, p: Array[Color]) -> Image:
	return tinted("forme", shape, p)


## Un disegno qualunque di `arte/<cartella>/` con i grigi colorati dalla tavolozza `p` (voce 106: le stazioni a gradi).
static func tinted(cartella: String, nome: String, p: Array[Color]) -> Image:
	var tpl: Variant = _template(cartella, nome)
	return _tinted(tpl, p) if tpl != null else null


## Il disegno come immagine RGBA8 che si può leggere pixel per pixel.
static func rgba(t: Texture2D) -> Image:
	var img := t.get_image()
	if img.is_compressed():
		img.decompress()
	img.convert(Image.FORMAT_RGBA8)
	return img


static var _templates := {}


## Il disegno (RGBA) e la gamma dei suoi grigi, o null se il file non c'è.
static func _template(cartella: String, shape: String) -> Variant:
	var key := cartella + "/" + shape
	if _templates.has(key):
		return _templates[key]
	var out := {}
	var t := ArtLib.tex(cartella, shape)
	if t != null:
		var img := rgba(t)
		var lo := 1.0
		var hi := 0.0
		for y in img.get_height():
			for x in img.get_width():
				var c := img.get_pixel(x, y)
				if _is_grey(c):
					lo = minf(lo, c.get_luminance())
					hi = maxf(hi, c.get_luminance())
		out = {"img": img, "lo": lo, "hi": maxf(hi, lo + 0.01)}
	_templates[key] = out if not out.is_empty() else null
	return _templates[key]


## La parte del materiale è disegnata in grigi neutri; il contorno (quasi nero) e il resto (manici, foglie, perline)
## hanno i loro colori e restano come sono.
static func _is_grey(c: Color) -> bool:
	return c.a > 0.5 and maxf(c.r, maxf(c.g, c.b)) - minf(c.r, minf(c.g, c.b)) <= 0.07 and c.get_luminance() > 0.16


## Ogni grigio prende il colore della tavolozza del materiale alla stessa altezza (dal più scuro al più chiaro).
static func _tinted(tpl: Dictionary, p: Array[Color]) -> Image:
	var src: Image = tpl["img"]
	var out := src.duplicate() as Image
	var lo: float = tpl["lo"]
	var hi: float = tpl["hi"]
	for y in src.get_height():
		for x in src.get_width():
			var c := src.get_pixel(x, y)
			if _is_grey(c):
				var t := (c.get_luminance() - lo) / (hi - lo)
				var k := p[clampi(int(t * p.size()), 0, p.size() - 1)]
				out.set_pixel(x, y, Color(k.r, k.g, k.b, c.a))
	return out
