class_name CreaturePosesData
extends RefCounted
## Le pose delle creature disegnate con Nano Banana (7 ott 2026, richiesta dell'utente: «tutti gli sprite di movimento»).
## Una forma di `CreatureArt` con una riga qui e i suoi file in `arte/creature/<forma>_<n>.png` (fatti da
## `tools/importa_creatura.py`) usa le sue pose al posto dei due fotogrammi del codice; se i file mancano resta il
## disegno di prima. Solo la variante 0 (le altre hanno i colori della variante).
##   n        quanti fotogrammi (1..n nei file)
##   anchor   il punto d'appoggio nel fotogramma: i piedi (chi cammina) o il centro del corpo (chi vola, "center");
##            chi rotola ha il centro della palla e "lift" = di quanto sta sopra i piedi (la palla gira attorno al centro)
##   poses    nome della posa → fotogrammi (indici da 0); più d'uno = un ciclo. I nomi che `Creature._pose_name`
##            sceglie: fermo, cammina, corsa, bruca, carica, stacco, aria, discesa, atterra, colpita (a terra);
##            vola, planata, sospeso, carica, scatto, colpita (in volo). Una posa che manca prende «fermo» o «vola».
##   fps      fotogrammi al secondo dei cicli (cammina e corsa vanno più svelti se la creatura corre)
##   Le chiavi sono le forme di `CreatureArt`, oppure l'id di una creatura che ha un disegno tutto suo (i capi): allora
##   vale solo per lei e i colori della variante («art_mods») non si applicano.
##   «furia_<posa>»: la posa di un boss infuriato (a metà Vita), al posto di quella normale.
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
	"falena": {"n": 8, "anchor": [13, 13], "center": true, "glow": true,
		"poses": {"vola": [0, 1, 2, 3], "sospeso": [4, 5], "planata": [6], "colpita": [7]},
		"fps": {"vola": 12.0, "sospeso": 9.0}},
	"bruco_lanterna": {"n": 8, "anchor": [13, 21], "glow": true,
		"poses": {"cammina": [0, 1, 2, 3], "corsa": [0, 1, 2, 3], "fermo": [4, 4, 4, 5, 5, 4], "bruca": [6],
			"colpita": [7]},
		"fps": {"cammina": 5.0, "corsa": 8.0, "fermo": 1.2}},
	# il Vecchio Zannarossa, il primo capo errante (8 ott 2026: prima era il cinghiale di rovo ingrandito)
	"capo_cinghiale": {"n": 12, "anchor": [32, 48], "glow": true,
		"poses": {"cammina": [0, 1, 2, 3], "fermo": [4], "carica": [5], "scatto": [6], "colpita": [7],
			"furia_fermo": [8], "sputa": [9], "furia_sputa": [9], "furia_carica": [10], "furia_scatto": [11]},
		"fps": {"cammina": 6.0}},
	"lepre_linfa": {"n": 8, "anchor": [12, 21], "glow": true,
		"poses": {"fermo": [0, 0, 0, 0, 1, 0], "allerta": [2], "cammina": [3, 4, 5, 6], "corsa": [3, 4, 5, 6],
			"aria": [5], "stacco": [4], "discesa": [6], "colpita": [7]},
		"fps": {"fermo": 2.0, "cammina": 9.0, "corsa": 12.0}},
	# Spinoriccio (tavola di Nano Banana, tools/installa_creatura.py)
	"spinoriccio": {"n": 8, "anchor": [10, 12], "lift": 8,
		"poses": {"cammina": [0, 1, 2, 3], "fermo": [4], "carica": [5], "scatto": [6], "colpita": [7]},
		"fps": {"cammina": 6.0}},
	# Cervo di brina (tavola di Nano Banana, tools/installa_creatura.py)
	"cervo_brina": {"n": 12, "anchor": [23, 40],
		"poses": {"cammina": [0, 1, 2, 3], "fermo": [4, 4, 4, 4, 11], "carica": [5], "scatto": [6], "bruca": [7], "colpita": [8], "allerta": [9]},
		"fps": {"cammina": 6.0, "fermo": 2.0}},
	# Grumo di spore (tavola di Nano Banana, tools/installa_creatura.py)
	"grumo_spore": {"n": 8, "anchor": [12, 23],
		"poses": {"fermo": [0, 1], "carica": [2], "stacco": [3], "aria": [4], "discesa": [5], "atterra": [6], "colpita": [7]},
		"fps": {"fermo": 1.6}},
	# Ermellino di brina (tavola di Nano Banana, tools/installa_creatura.py)
	"ermellino": {"n": 8, "anchor": [12, 22],
		"poses": {"cammina": [0, 1, 2, 3], "fermo": [4], "corsa": [5], "colpita": [6], "allerta": [7]},
		"fps": {"cammina": 6.0}},
}


static func of(shape: String, variant: int) -> Dictionary:
	if variant != 0:
		return {}
	return POSES.get(shape, {})
