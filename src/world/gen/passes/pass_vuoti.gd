class_name PassVuoti
extends GenPass
## Il Fondo: grandi vuoti allungati dove il mondo si sfilaccia verso il Vuoto, con isole di vuotite sospese e spuntoni
## che scendono dal soffitto. In fondo a tutto, le ultime righe sono vuotite compatta: il pavimento del mondo.

const FLOOR := 6                       # righe di vuotite compatta in fondo al mondo


func title() -> String:
	return "Vuoti"


func run(w: World, c: GenContext) -> void:
	var n_void := c.noise("vuoti", 0.012, 3)
	var n_isle := c.noise("isole", 0.05, 2)
	var top := StrataData.top(4)
	var tiles := w.tiles
	# si parte dalla riga più alta in cui può cominciare il Fondo: sopra non c'è nulla da fare
	var first := w.h
	var off := c.strata_off(w)
	for x in w.w:
		first = mini(first, w.surface[x] + off[x] + top)
	for y in range(maxi(first, 0), w.h):
		var row := y * w.w
		for x in w.w:
			if y >= w.h - FLOOR:
				tiles[row + x] = TileDefs.VUOTITE
				continue
			var dep := y - w.surface[x] - off[x]
			if dep < top:
				continue
			var f := minf((dep - top) / 80.0, 1.0)          # i vuoti si allargano scendendo
			var v := n_void.get_noise_2d(x * 0.6, y * 1.3)
			if v > 0.3 - 0.15 * f and n_isle.get_noise_2d(x, y) < 0.35:
				tiles[row + x] = TileDefs.AIR
	w.tiles = tiles
