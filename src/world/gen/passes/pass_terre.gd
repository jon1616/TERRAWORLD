class_name PassTerre
extends GenPass
## Roadmap 52, voce 412: la terra di ogni bioma. Sotto l'erba l'humus diventa la terra del bioma (sabbia, neve, fango,
## torba, terra grassa…) e nei primi strati l'ardesia diventa la sua roccia (arenaria, basalto, ghiaccio, marmo…), dal
## pacchetto `src/data/vastita/terre.gd` (campo «soils», per id di bioma; la foresta tiene humus e ardesia). Il confine
## tra due biomi si sfrangia con il rumore. Poi le terre che franano (`TileDefs.FALLS`) sopra un vuoto diventano la roccia
## che le regge (`TileDefs.SUPPORT`, o l'ardesia): il mondo nasce fermo, frana solo quando lo si scava.
## Viene dopo gli stagni (le loro rive restano della terra del bioma) e prima degli alberi.

const ROCK_DEPTH := 44                 # fin dove arriva la roccia del bioma (± `ROCK_VAR`)
const ROCK_VAR := 12.0
const JITTER := 7.0                    # di quante colonne si sfrangia il confine tra due biomi
const ROCK_SHARE := -0.35              # sotto questa soglia del rumore resta l'ardesia (vene di ardesia nella roccia)
const FALL_DEPTH := 260                # fin dove si cercano terre sospese (la ghiaia sta nei primi due strati)


func title() -> String:
	return "Terre"


func run(w: World, c: GenContext) -> void:
	var soils: Dictionary = BiomesData.pack("soils")
	var soil := PackedInt32Array()
	var rock := PackedInt32Array()
	for b in BiomesData.BIOMES:
		var s: Dictionary = soils.get(String(b["id"]), {})
		soil.append(int(s.get("suolo", 0)))
		rock.append(int(s.get("roccia", 0)))
	var n_j := c.noise("terre_confini", 0.06, 2)
	var n_r := c.noise("terre_rocce", 0.05, 3)
	var n_d := c.noise("terre_fondo", 0.03, 2)
	var ww := w.w
	var tiles := w.tiles
	for x in ww:
		var s0 := maxi(w.surface[x], 0)
		var deep := ROCK_DEPTH + int(n_d.get_noise_1d(x) * ROCK_VAR)
		for y in range(s0, mini(s0 + deep, w.h)):
			var i := y * ww + x
			var t := tiles[i]
			if t != TileDefs.DIRT and t != TileDefs.STONE:
				continue
			var bx := clampi(x + int(n_j.get_noise_2d(x, y) * JITTER), 0, ww - 1)
			var b := w.biomes[bx]
			if t == TileDefs.DIRT:
				if soil[b] > 0:
					tiles[i] = soil[b]
			elif rock[b] > 0 and n_r.get_noise_2d(x, y) > ROCK_SHARE:
				tiles[i] = rock[b]
	# le terre che franano non restano sospese sopra un vuoto: diventano la roccia che le regge
	for x in ww:
		for y in range(maxi(w.surface[x], 0), mini(maxi(w.surface[x], 0) + FALL_DEPTH, w.h - 1)):
			var i := y * ww + x
			var t := tiles[i]
			if TileDefs.FALLS[t] == 1 and tiles[i + ww] == TileDefs.AIR:
				tiles[i] = int(TileDefs.SUPPORT.get(t, TileDefs.STONE))
	w.tiles = tiles
