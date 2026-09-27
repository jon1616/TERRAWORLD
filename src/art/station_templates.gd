class_name StationTemplates
extends RefCounted
## Voce 106: le stazioni disegnate con Nano Banana (`arte/stazioni/<id>.png`, grandi quanto la stazione, fatte da
## `arte_ia/stazioni/rifai.sh`). Le stazioni a gradi (totem, trappole… `_1`, `_2`, `_3`) hanno un disegno solo, senza
## il numero, con la parte del materiale in grigio: prende la tavolozza di radice, legnoferro o ambra. La parte
## luminosa si ricava dal disegno (i pixel accesi e saturi: fuoco, Linfa, ambra) per le stazioni che fanno luce.
## Senza il file, `StationArt` disegna la stazione del codice come prima.

const TIERS := {"1": "radice", "2": "legnoferro", "3": "ambra"}


## {img, glow} della stazione disegnata, o {} se non c'è (o se la sua misura non è quella della stazione).
static func make(id: String, w: int, h: int) -> Dictionary:
	var img: Image = null
	var t := ArtLib.tex("stazioni", id)
	if t != null:
		img = IconTemplates.rgba(t)
	else:
		var tail := id.get_slice("_", id.get_slice_count("_") - 1)
		if TIERS.has(tail):
			img = IconTemplates.tinted("stazioni", id.trim_suffix("_" + tail), ItemIcons.pal(String(TIERS[tail])))
	if img == null or img.get_width() != w or img.get_height() != h:
		return {}
	var glow := Px.img(w, h)
	if StationsData.STATIONS[id].get("light", false):
		for y in h:
			for x in w:
				var c := img.get_pixel(x, y)
				var hi := maxf(c.r, maxf(c.g, c.b))
				if c.a > 0.5 and hi > 0.72 and hi - minf(c.r, minf(c.g, c.b)) > 0.35:
					glow.set_pixel(x, y, c)
	return {"img": img, "glow": glow}
