class_name ArtsData
extends RefCounted
## Le arti del combattimento (Roadmap 25): la maestria di ogni forma d'arma (voce 247) e le sue tecniche (voce 248).
## Regole in `WeaponArts`.
## Maestria: ogni creatura sconfitta con un'arma in mano dà alla sua forma `hp / HP_PER_PT` punti (almeno 1); il rango r
## vuole `RANK_PTS · r²` punti (il 10 a 2000); ogni rango dà `DMG_PER_RANK` di danno in più con quella forma, e i ranghi
## di `TECH_RANKS` aprono e rinforzano la tecnica.

const RANKS := 10
const RANK_PTS := 20
const HP_PER_PT := 20.0
const DMG_PER_RANK := 0.02
const TECH_RANKS := [3, 6, 9]
const KILL_RANGE := 40.0               # tessere: oltre, la creatura non l'ha sconfitta il Germogliato

## Le forme d'arma che hanno una maestria (le altre sono attrezzi o armature) e il nome da usare nelle frasi.
const FORMS := {
	"spada": "della spada", "pugnale": "del pugnale", "spadone": "dello spadone", "lancia": "della lancia",
	"martello": "del martello", "falcione": "della falce", "frusta": "della frusta", "arco": "dell'arco",
	"balestra": "della balestra", "verga": "della verga",
}

## Le tecniche (voce 248), una per forma: tasto «tecnica».
##   name, desc     nome e frase
##   kind           "giro" (colpisce attorno), "affondo" (scatto in avanti e colpo), "pesante" (un colpo davanti,
##                  forte), "terremoto" (onda a terra che stordisce), "laccio" (tira a sé la creatura più vicina davanti),
##                  "raffica" (una pioggia di dardi a ventaglio), "trafiggi" (un dardo che attraversa tutto),
##                  "saetta" (un incantesimo grande)
##   mult           il danno × quello dell'arma, per grado (I, II, III)
##   r              il raggio o la lunghezza, in tessere
##   linfa, cd      il costo e l'attesa in secondi
##   dash, stun, n  lo scatto (tessere), lo stordimento (secondi), quanti dardi
const TECHS := {
	"spada": {"name": "Fendente rotante", "desc": "un giro completo della lama: colpisce tutto attorno", "kind": "giro",
		"mult": [1.4, 1.8, 2.3], "r": 3.5, "linfa": 4, "cd": 4.0},
	"pugnale": {"name": "Affondo", "desc": "uno scatto in avanti e un colpo rapidissimo", "kind": "affondo",
		"mult": [1.6, 2.1, 2.7], "r": 2.0, "linfa": 3, "cd": 3.0, "dash": 5.0},
	"spadone": {"name": "Colpo pesante", "desc": "un colpo davanti che schiaccia e spinge lontano", "kind": "pesante",
		"mult": [2.2, 2.9, 3.8], "r": 3.5, "linfa": 5, "cd": 6.0},
	"lancia": {"name": "Carica", "desc": "uno scatto lungo che trafigge chi sta in linea", "kind": "affondo",
		"mult": [1.5, 2.0, 2.6], "r": 2.5, "linfa": 5, "cd": 5.0, "dash": 9.0},
	"martello": {"name": "Terremoto", "desc": "un colpo a terra: un'onda che stordisce tutto attorno", "kind": "terremoto",
		"mult": [1.2, 1.6, 2.1], "r": 6.0, "linfa": 6, "cd": 8.0, "stun": 1.2},
	"falcione": {"name": "Mietitura", "desc": "un giro largo e basso, davanti e dietro", "kind": "giro",
		"mult": [1.6, 2.1, 2.7], "r": 5.0, "linfa": 5, "cd": 5.0},
	"frusta": {"name": "Laccio", "desc": "afferra la creatura più vicina davanti e la tira a sé", "kind": "laccio",
		"mult": [1.2, 1.6, 2.1], "r": 12.0, "linfa": 3, "cd": 4.0, "stun": 0.8},
	"arco": {"name": "Pioggia di frecce", "desc": "cinque dardi a ventaglio verso il mouse", "kind": "raffica",
		"mult": [0.9, 1.2, 1.5], "r": 30.0, "linfa": 4, "cd": 5.0, "n": 5},
	"balestra": {"name": "Colpo perforante", "desc": "un dardo che attraversa tutte le creature in linea", "kind": "trafiggi",
		"mult": [2.0, 2.6, 3.3], "r": 40.0, "linfa": 4, "cd": 5.0},
	"verga": {"name": "Saetta caricata", "desc": "una saetta grande che esplode dove arriva", "kind": "saetta",
		"mult": [2.0, 2.7, 3.5], "r": 3.0, "linfa": 8, "cd": 6.0},
}


static func points_for(rank: int) -> int:
	return RANK_PTS * rank * rank


static func rank_of(pts: int) -> int:
	var r := 0
	while r < RANKS and pts >= points_for(r + 1):
		r += 1
	return r


## Il grado della tecnica (0 = chiusa, 1-3) a un rango.
static func tech_grade(rank: int) -> int:
	var g := 0
	for t in TECH_RANKS:
		if rank >= int(t):
			g += 1
	return g
