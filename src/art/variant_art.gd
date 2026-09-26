class_name VariantArt
extends RefCounted
## Il disegno delle varianti (voce 55, `FamiliesData`): dai fotogrammi della specie, lo stesso disegno con
##   elem    i colori verso quelli dell'elemento (tenendo luci e ombre) e, per brace, luce e Linfa, un bagliore
##   scale   più piccola o più grande (pixel interi, niente sfumature)
##   temper  feroce: tre punte scure sul dorso; docile: colori un poco più chiari; timida: un poco più pallida
##   manto   (voce 60) il colore del manto allevato, e i segni rari (albino, iridato, cristallino, d'ombra, dorato…)
## `apply` prende e restituisce {frames, glow} come `CreatureArt.frames`.

const ELEM_COLOR := {"brace": Color("#ff7a3a"), "gelo": Color("#8ad8ff"), "spora": Color("#b070f0"),
	"linfa": Color("#40f0d0"), "vuoto": Color("#8a50e0"), "luce": Color("#fff08a")}


static func apply(fr: Dictionary, mods: Dictionary) -> Dictionary:
	var frames := []
	var glows := []
	for k in (fr["frames"] as Array).size():
		var im: Image = (fr["frames"][k] as Image).duplicate()
		var gm: Image = (fr["glow"][mini(k, (fr["glow"] as Array).size() - 1)] as Image).duplicate()
		var tint: Color = mods.get("tint", Color(0, 0, 0, 0))
		var amount := float(mods.get("tint_amount", 0.5))
		if ELEM_COLOR.has(String(mods.get("elem", ""))):
			tint = ELEM_COLOR[mods["elem"]]
			amount = 0.55
		if tint.a > 0.0:
			_tint(im, tint, amount)
		var coat := BreedData.coat(String(mods.get("manto", "")))      # voce 60
		if coat.has("tint"):
			_tint(im, coat["tint"], float(coat["amount"]))
		if coat.get("rainbow", false):
			_rainbow(im)
		if coat.get("stars", false):
			_stars(im)
		match String(mods.get("temper", "")):
			"docile":
				_lighten(im, 0.14)
			"timida":
				_lighten(im, 0.22)
			"feroce":
				_spikes(im)
		if mods.get("glow_body", false) or coat.get("glow", false) or String(mods.get("elem", "")) in ["brace", "luce", "linfa"]:
			gm = _glow_of(im)
		var sc := float(mods.get("scale", 1.0)) * (BreedData.GIANT_SCALE if mods.get("gigante", false) else 1.0)
		if absf(sc - 1.0) > 0.01:
			var w := maxi(roundi(im.get_width() * sc), 4)
			var h := maxi(roundi(im.get_height() * sc), 4)
			im.resize(w, h, Image.INTERPOLATE_NEAREST)
			gm.resize(w, h, Image.INTERPOLATE_NEAREST)
		frames.append(im)
		glows.append(gm)
	return {"frames": frames, "glow": glows}


## Ogni pixel verso il colore dato, con la sua luminosità (le ombre restano ombre).
static func _tint(im: Image, c: Color, amount: float) -> void:
	for y in im.get_height():
		for x in im.get_width():
			var p := im.get_pixel(x, y)
			if p.a < 0.05 or p.v < 0.08:
				continue                              # trasparente o contorno
			var t := Color(c.r * p.v * 1.25, c.g * p.v * 1.25, c.b * p.v * 1.25, p.a)
			im.set_pixel(x, y, p.lerp(t, amount))


static func _lighten(im: Image, amount: float) -> void:
	for y in im.get_height():
		for x in im.get_width():
			var p := im.get_pixel(x, y)
			if p.a > 0.05 and p.v >= 0.08:
				im.set_pixel(x, y, p.lerp(Color(1, 1, 1, p.a), amount))


## Tre punte scure sul dorso (sopra il pixel più alto delle colonne a un terzo, metà e due terzi).
static func _spikes(im: Image) -> void:
	var w := im.get_width()
	for k in 3:
		var x := int(w * (0.3 + 0.2 * k))
		for y in im.get_height():
			if im.get_pixel(x, y).a > 0.3:
				if y >= 2:
					im.set_pixel(x, y - 1, Color("#2a0c10"))
					im.set_pixel(x, y - 2, Color("#5a1a1a"))
				break


## Un bagliore dal corpo stesso (le varianti di brace, luce e Linfa brillano al buio).
static func _glow_of(im: Image) -> Image:
	var gm := Image.create_empty(im.get_width(), im.get_height(), false, Image.FORMAT_RGBA8)
	for y in im.get_height():
		for x in im.get_width():
			var p := im.get_pixel(x, y)
			if p.a > 0.3 and p.v > 0.45:
				gm.set_pixel(x, y, Color(p.r, p.g, p.b, 0.55))
	return gm


## Voce 60, manto iridato: la tinta gira lungo il corpo come un arcobaleno (tenendo luci e ombre).
static func _rainbow(im: Image) -> void:
	var w := float(im.get_width())
	var h := float(im.get_height())
	for y in im.get_height():
		for x in im.get_width():
			var p := im.get_pixel(x, y)
			if p.a < 0.05 or p.v < 0.08:
				continue
			var c := Color.from_hsv(fmod(x / w + y / h * 0.5, 1.0), 0.55, p.v * 1.1, p.a)
			im.set_pixel(x, y, p.lerp(c, 0.5))


## Voce 60, manto stellato: puntini di luce sparsi sul corpo scuro.
static func _stars(im: Image) -> void:
	for y in range(1, im.get_height() - 1):
		for x in range(1, im.get_width() - 1):
			var p := im.get_pixel(x, y)
			if p.a > 0.5 and p.v > 0.08 and (x * 7 + y * 13) % 17 == 0:
				im.set_pixel(x, y, Color(1.0, 0.98, 0.8, p.a))
