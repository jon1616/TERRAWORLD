class_name CreaturePosesData
extends RefCounted
## Le pose delle creature disegnate con Nano Banana (7 ott 2026, richiesta dell'utente: «tutti gli sprite di movimento»).
## Una forma di `CreatureArt` con una riga qui e i suoi file in `arte/creature/<forma>_<n>.png` (fatti da
## `tools/importa_creatura.py`) usa le sue pose al posto dei due fotogrammi del codice; se i file mancano resta il
## disegno di prima. Solo la variante 0 (le altre hanno i colori della variante).
##   n        quanti fotogrammi (1..n nei file)
##   anchor   il punto d'appoggio nel fotogramma: i piedi (chi cammina) o il centro del corpo (chi vola, "center")
##   poses    nome della posa → fotogrammi (indici da 0); più d'uno = un ciclo. I nomi che `Creature._pose_name`
##            sceglie: fermo, cammina, corsa, bruca, carica, stacco, aria, discesa, atterra, colpita (a terra);
##            vola, planata, sospeso, carica, scatto, colpita (in volo). Una posa che manca prende «fermo» o «vola».
##   fps      fotogrammi al secondo dei cicli (cammina e corsa vanno più svelti se la creatura corre)
##   glow     colori che brillano al buio: la maschera è nei file <forma>_<n>_luce.png

const POSES := {
	"grumo": {"n": 8, "anchor": [10, 21],
		"poses": {"fermo": [0, 1], "carica": [2], "stacco": [3], "aria": [4], "discesa": [5], "atterra": [6],
			"colpita": [7]},
		"fps": {"fermo": 1.6}},
	"corvo": {"n": 8, "anchor": [18, 16], "center": true,
		"poses": {"vola": [0, 1, 2, 3], "planata": [4], "sospeso": [5], "carica": [6], "scatto": [7]},
		"fps": {"vola": 10.0}},
	"pecora_muschio": {"n": 8, "anchor": [12, 18],
		"poses": {"cammina": [0, 1, 2, 3], "fermo": [4], "bruca": [5], "aria": [6], "corsa": [0, 1, 2, 3],
			"colpita": [7]},
		"fps": {"cammina": 6.0, "corsa": 10.0}},
	"lepre_linfa": {"n": 8, "anchor": [12, 21], "glow": true,
		"poses": {"fermo": [0, 0, 0, 0, 1, 0], "allerta": [2], "cammina": [3, 4, 5, 6], "corsa": [3, 4, 5, 6],
			"aria": [5], "stacco": [4], "discesa": [6], "colpita": [7]},
		"fps": {"fermo": 2.0, "cammina": 9.0, "corsa": 12.0}},
}


static func of(shape: String, variant: int) -> Dictionary:
	if variant != 0:
		return {}
	return POSES.get(shape, {})
