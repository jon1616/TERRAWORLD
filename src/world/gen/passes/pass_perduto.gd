class_name PassPerduto
extends GenPass
## Il luogo di un Giardino perduto (Roadmap 21, voce 222; `params["perduto"]`, dati in `LostGardensData`): il suo Albero
## malato (stazione «albero_<giardino>», 9×13) nel posto che lo racconta.
##   sommerso   in fondo a un lago largo sessanta tessere, sott'acqua
##   ferro      in una sala di pietra dei Seminatori sessanta tessere sotto terra, con un pozzo di passerelle per scendere,
##              macchine spente e il cuore di una Centrale addormentato
##   selvatico  in una radura spianata, circondata da alberi e cespugli
##   muto       al centro di un cerchio di otto stele che parlano la lingua nera
## Sempre lontano dalla partenza. Appunti: `notes["perduto"]` = {"id", "tree": angolo, "x", "y"}.

const TREE := Vector2i(9, 13)


func title() -> String:
	return "Giardino perduto"


func run(w: World, c: GenContext) -> void:
	var id := String(c.params.get("perduto", ""))
	if not LostGardensData.GARDENS.has(id):
		return
	var cx := _column(w, c, id)
	var o := Vector2i(-1, -1)
	match id:
		"sommerso":
			o = _lake(w, c, cx)
		"ferro":
			o = _hall(w, c, cx)
		"selvatico":
			o = _clearing(w, c, cx)
		"muto":
			o = _circle(w, c, cx)
	if o.x < 0:
		return
	w.stations[o] = "albero_" + id
	c.notes["perduto"] = {"id": id, "tree": o, "x": o.x + TREE.x / 2, "y": o.y + TREE.y - 1}


## Una colonna lontana dalla partenza (verso un quarto o tre quarti del mondo) dove il luogo non pesta altre strutture.
func _column(w: World, c: GenContext, id: String) -> int:
	var a := w.w / 4
	var b := w.w * 3 / 4
	var base := a if absi(a - w.spawn.x) > absi(b - w.spawn.x) else b
	for k in 40:
		var x: int = base + (k / 2) * 23 * (1 if k % 2 == 0 else -1)
		if x < 60 or x > w.w - 60:
			continue
		var sy := int(w.surface[x])
		var r := Rect2i(x - 40, sy - 20, 80, 30) if id != "ferro" else Rect2i(x - 26, sy - 4, 52, 84)
		if c.is_free(r):
			return x
	return base


## Spiana una striscia di terreno all'altezza y (aria sopra, terra sotto), 16 righe d'aria.
func _flatten(w: World, x0: int, x1: int, y: int) -> void:
	for x in range(x0, x1):
		if not w.inside(x, y):
			continue
		for yy in range(y - 16, y + 1):
			w.set_tile(x, yy, TileDefs.AIR)
			w.set_decor(x, yy, 0)
		for yy in range(y + 1, y + 5):
			if not w.solid(x, yy):
				w.set_tile(x, yy, TileDefs.DIRT)
		w.surface[x] = y + 1


func _lake(w: World, c: GenContext, cx: int) -> Vector2i:
	var sy := int(w.surface[cx]) - 1
	_flatten(w, cx - 36, cx + 36, sy)
	var half := 30
	var deep := 17
	for x in range(cx - half, cx + half + 1):
		var t := float(x - cx) / half
		var d := deep if absi(x - cx) <= 6 else int(deep * (1.0 - t * t))     # il fondo piano sotto l'Albero
		for y in range(sy + 1, sy + 1 + d):
			w.set_tile(x, y, TileDefs.AIR)
			w.set_liq(x, y, 8, LiquidsData.ACQUA)
		for y in range(sy + 1 + d, sy + 5 + d):
			w.set_tile(x, y, TileDefs.STONE)
		w.surface[x] = sy + 1 + d
	var bottom := sy + deep
	var o := Vector2i(cx - TREE.x / 2, bottom - TREE.y + 1)
	c.claim(Rect2i(cx - 36, sy - 16, 72, deep + 22), "giardino perduto")
	return o


func _hall(w: World, c: GenContext, cx: int) -> Vector2i:
	var sy := int(w.surface[cx])
	var top := sy + 60
	var hw := 22
	var hh := 16
	for y in range(top - 1, top + hh + 1):
		for x in range(cx - hw - 1, cx + hw + 2):
			var shell := y == top - 1 or y == top + hh or x == cx - hw - 1 or x == cx + hw + 1
			w.set_tile(x, y, TileDefs.PIETRA_SEM if shell else TileDefs.AIR)
			w.walls[y * w.w + x] = TileDefs.WALL_SEM
			w.set_decor(x, y, 0)
			w.set_liq(x, y, 0, 0)
	# il pozzo per scendere: tre tessere d'aria con una passerella ogni cinque
	for y in range(sy - 2, top):
		for x in range(cx - 1, cx + 2):
			w.set_tile(x, y, TileDefs.AIR)
			w.set_liq(x, y, 0, 0)
		if (y - sy) % 5 == 0 and y > sy:
			w.set_plat(cx - 1, y, true)
			w.set_plat(cx + 1, y, true)
	w.set_tile(cx - 1, top - 1, TileDefs.AIR)
	w.set_tile(cx, top - 1, TileDefs.AIR)
	w.set_tile(cx + 1, top - 1, TileDefs.AIR)
	var floor_y := top + hh - 1
	var o := Vector2i(cx - TREE.x / 2 + 8, floor_y - TREE.y + 1)
	# macchine spente dei Seminatori e il cuore di una Centrale addormentato
	w.stations[Vector2i(cx - hw + 1, floor_y - 1)] = "cuore_centrale"
	w.stations[Vector2i(cx - hw + 5, floor_y)] = "lampada_baccello"
	w.stations[Vector2i(cx - hw + 9, floor_y)] = "lampada_baccello"
	for ix in [0, 6, 12, 18, 24, 30, 36, 42]:
		w.set_decor(cx - hw + ix, top, TileDefs.DECOR_RUNE)
	c.claim(Rect2i(cx - hw - 2, sy - 3, hw * 2 + 5, top - sy + hh + 5), "giardino perduto")
	return o


func _clearing(w: World, c: GenContext, cx: int) -> Vector2i:
	var sy := int(w.surface[cx]) - 1
	_flatten(w, cx - 28, cx + 28, sy)
	for x in range(cx - 28, cx + 28):
		w.set_tile(x, sy + 1, TileDefs.GRASS)
	var o := Vector2i(cx - TREE.x / 2, sy - TREE.y + 1)
	c.claim(Rect2i(cx - 28, sy - 16, 56, 22), "giardino perduto")
	return o


func _circle(w: World, c: GenContext, cx: int) -> Vector2i:
	var sy := int(w.surface[cx]) - 1
	_flatten(w, cx - 30, cx + 30, sy)
	var o := Vector2i(cx - TREE.x / 2, sy - TREE.y + 1)
	var st: Dictionary = c.notes.get("stele", {})
	var rng := c.rng
	for k in 8:
		var side := -1 if k % 2 == 0 else 1
		var x := cx + side * (8 + (k / 2) * 5)
		var so := Vector2i(x, sy - 2)
		w.stations[so] = "stele"
		st["%d,%d" % [so.x, so.y]] = {"words": (LanguageData.LORE_BLACK[rng.randi_range(0, LanguageData.LORE_BLACK.size() - 1)] as Array).duplicate(),
			"hint": []}
	c.notes["stele"] = st
	c.claim(Rect2i(cx - 30, sy - 16, 60, 22), "giardino perduto")
	return o
