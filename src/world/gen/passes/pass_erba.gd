class_name PassErba
extends GenPass
## L'erba: la prima tessera di terra di ogni colonna, più la terra scoperta vicino alla superficie. Quale erba lo
## decide il bioma della colonna (muschio, muschio di spore, erba d'ambra); vicino a un confine a chiazze quella del
## vicino (voce 462, `BiomesData.mix_at`), e la vegetazione, che segue l'erba, si mescola con lei.


func title() -> String:
	return "Erba"


func run(w: World, c: GenContext) -> void:
	var n := c.noise("biomi_chiazze", 0.09, 2)
	for x in w.w:
		var grass: int = BiomesData.BIOMES[BiomesData.mix_at(w, x, n)]["grass"]
		for y in w.h:
			var t := w.tile(x, y)
			if t != TileDefs.AIR:
				if t == TileDefs.DIRT:
					w.set_tile(x, y, grass)
				break
		for y in range(maxi(w.surface[x], 0), mini(w.surface[x] + 6, w.h)):
			if w.tile(x, y) == TileDefs.DIRT and w.wall(x, y) == 0 and PassCristalli._near_air(w, x, y):
				w.set_tile(x, y, grass)
