class_name FountainArt
extends RefCounted
## Le fonti della voce 119 (una tessera di larghezza, due d'altezza): una pietra con una bocca da cui cade il liquido,
## del colore del suo liquido (`LiquidsData.TYPES`). Chiamato da `StationArt.make`.


static func draw(id: String, im: Image, gm: Image, w: int, h: int) -> bool:
	if not id.begins_with("fonte_"):
		return false
	var type := int(StationsData.STATIONS[id].get("fonte", 0))
	var liq: Color = LiquidsData.TYPES[type]["color"]
	var top: Color = LiquidsData.TYPES[type]["top"]
	var st := Px.pal(TileDefs.P_STONE)
	var cx := w / 2.0
	# la pietra: più larga in basso, con una cresta di muschio (o di cristallo, o di brace) in cima
	for y in range(4, h):
		var half := 4.0 + (y - 4) * 0.12
		for x in w:
			if absf(x + 0.5 - cx) <= half:
				var k := clampi(int((y - 4) / float(h) * 3.0) + (1 if x < cx else 0), 0, st.size() - 1)
				im.set_pixel(x, y, st[k])
	for x in range(3, w - 3):
		im.set_pixel(x, 4, top.darkened(0.25))
		im.set_pixel(x, 5, top.darkened(0.45))
	# la bocca, sul fianco destro, e il filo di liquido che scende
	for y in range(h - 12, h - 8):
		for x in range(w - 6, w - 2):
			im.set_pixel(x, y, Color(0.04, 0.05, 0.07))
	for y in range(h - 10, h):
		im.set_pixel(w - 2, y, liq.lightened(0.2))
		im.set_pixel(w - 1, y, liq)
		gm.set_pixel(w - 1, y, Color(top, 0.6) if type > 0 else Color(0, 0, 0, 0))
	return true
