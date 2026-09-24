class_name PassErba
extends GenPass
## L'erba: la prima tessera di terra di ogni colonna, più la terra scoperta vicino alla superficie.


func title() -> String:
	return "Erba"


func run(w: World, _c: GenContext) -> void:
	for x in w.w:
		for y in w.h:
			var t := w.tile(x, y)
			if t != TileDefs.AIR:
				if t == TileDefs.DIRT:
					w.set_tile(x, y, TileDefs.GRASS)
				break
		for y in range(maxi(w.surface[x], 0), mini(w.surface[x] + 6, w.h)):
			if w.tile(x, y) == TileDefs.DIRT and w.wall(x, y) == 0 and PassCristalli._near_air(w, x, y):
				w.set_tile(x, y, TileDefs.GRASS)
