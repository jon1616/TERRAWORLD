class_name MotherTreeData
extends RefCounted
## Gli stadi dell'Albero-Madre (voce 63, Roadmap 8 «Il risveglio dell'Albero-Madre»): il **motivo** del gioco.
## L'Albero dorme al centro del Giardino; a ogni stadio chiede delle **offerte** e, quando le ha tutte, cresce e dona
## qualcosa. Solo dati; le regole stanno in `AlberoMadre`, il pannello in `AlberoPanel`.
##
## Offerte:
##   {"item": id, "n": quanti}        oggetti da portare (si offrono anche a più riprese; si contano anche le casse
##                                     vicine); "hint" = dove cercarli, a grandi linee
##   {"stat": nome, "n": quanti}       un traguardo del personaggio (`Character.stats`: mondi visitati, firme, geni
##                                     imparati…); "text" = come lo dice l'Albero, "hint" = come arrivarci
## Doni (`gives`): aiuola (+1 Aiuola nel Giardino), power (un potere del Germogliato, `PowersData`), npc (un abitante
## che arriva al Giardino, `NpcData`), phase (il disegno dell'Albero, 0-4), graft (categorie di geni che il Banco
## dell'Innestatrice sa innestare), lore (la pagina di storia che si apre), items (oggetti che l'Albero mette nella
## Bisaccia: il corredo della rete, Roadmap 19).

const STAGES := [
	{"name": "Il primo respiro", "say": "Il legno mi pesa. Portami terra e legno del Giardino, e va' a vedere il primo mondo.",
		"offers": [
			{"item": "legno", "n": 30, "hint": "dagli alberi del Giardino e dei mondi (ascia)"},
			{"item": "humus", "n": 25, "hint": "scavando la terra, ovunque"},
			{"stat": "viaggi", "n": 1, "text": "Entra nel primo mondo", "hint": "pianta il primo Seme nell'Aiuola e attraversa il portale"},
		],
		"gives": {"aiuola": 1, "npc": "vecchia_radice", "phase": 1, "lore": "albero_primo_respiro"}},
	{"name": "Radici che bevono", "say": "Le mie radici hanno sete di metallo e di geni. Imparane qualcuno per me.",
		"offers": [
			{"item": "lingotto_radicite", "n": 10, "hint": "radicite fusa al Baccello ardente (Sottobosco di radici)"},
			{"item": "gelatina", "n": 10, "hint": "dai grumi"},
			{"stat": "geni_imparati", "n": 3, "text": "Impara tre geni", "hint": "Provetta di Linfa sulle cose dei mondi, Fiale dalle creature (Genario, tasto K)"},
		],
		"gives": {"power": "vista", "phase": 1, "items": {"pinza_vene": 1, "vena_radice": 30, "tamburo_radice": 1, "otre_linfa": 1,
			"lampada_baccello": 2, "leva_radice": 1, "filo_turchese": 20}}},
	{"name": "La prima Linfa antica", "say": "Nel Fondo di ogni mondo batte un Cuore. La sua Linfa più antica mi farebbe svegliare.",
		"offers": [
			{"item": "linfa_antica", "n": 2, "hint": "la dona il Cuore di un mondo quando il suo Guardiano è curato o sconfitto (il Fondo)"},
			{"item": "lingotto_legnoferro", "n": 8, "hint": "legnoferro delle Caverne d'ardesia, fuso al Baccello"},
		],
		"gives": {"aiuola": 1, "npc": "mercante_semi", "phase": 2, "graft": ["grotte", "sottosuolo", "minerali"], "lore": "albero_linfa"}},
	{"name": "Fronde nuove", "say": "Le fronde tornano. Portami una creatura amica e la seta delle radici.",
		"offers": [
			{"stat": "addomesticate", "n": 1, "text": "Addomestica una creatura", "hint": "il suo cibo con il clic destro, o il Laccio quando è stremata"},
			{"item": "seta_radice", "n": 10, "hint": "dalle tessiradici del Sottobosco"},
			{"item": "fungo_luminoso", "n": 10, "hint": "nelle Profondità della Linfa e nelle paludi di spore"},
		],
		"gives": {"power": "canto", "npc": "mandriano", "phase": 2}},
	{"name": "Il Seme che ricorda", "say": "Ogni mondo ha qualcosa che solo lui ha. Trova le loro firme, e impara altri geni.",
		"offers": [
			{"stat": "firme", "n": 2, "text": "Trova le firme di due mondi", "hint": "il luogo unico di ogni mondo: la mappa (M) segna una stella quando lo trovi"},
			{"stat": "geni_imparati", "n": 8, "text": "Impara otto geni", "hint": "Provetta, Fiale, piante-seme: il Genario (K) dice dove cercare"},
			{"item": "linfa_antica", "n": 2, "hint": "dai Cuori dei mondi"},
		],
		"gives": {"npc": "innestatrice", "graft": ["gemme", "rovine", "flora"], "phase": 2}},
	{"name": "Ambra e memoria", "say": "I Seminatori mi piantarono. Riportami ciò che hanno lasciato, e un frammento di me.",
		"offers": [
			{"item": "lingotto_ambra", "n": 8, "hint": "ambra fossile delle Caverne profonde, con il piccone di legnoferro"},
			{"stat": "reliquiari", "n": 1, "text": "Apri un reliquiario dei Seminatori", "hint": "murati nella roccia: la Mappa dei Seminatori li indica"},
			{"item": "frammento_albero", "n": 1, "hint": "le stanze chiuse da un Sigillo velato (Caverne d'ardesia, la Vista della Linfa le mostra) o di radice (Sottobosco)"},
		],
		"gives": {"aiuola": 1, "power": "passo", "phase": 3, "lore": "albero_memoria"}},
	{"name": "Il canto della mandria", "say": "Sento le tue creature. Falle crescere: voglio sentire un uovo schiudersi.",
		"offers": [
			{"stat": "uova_allevate", "n": 1, "text": "Una coppia del recinto fa un uovo", "hint": "due creature della stessa famiglia, di livello 3, in coppia (G) nello stesso recinto"},
			{"item": "lana_muschio", "n": 10, "hint": "dalle pecore di muschio, meglio nel recinto"},
			{"item": "miele_lume", "n": 5, "hint": "dalle api di lume nel recinto"},
		],
		"gives": {"npc": "cartografo", "phase": 3}},
	{"name": "Il fuoco sotto la cenere", "say": "Nelle cenerarie covano le braci. Portami il loro calore.",
		"offers": [
			{"item": "squama_brace", "n": 6, "hint": "dalle salamandre di brace (Cenerarie, mondi con geni caldi)"},
			{"item": "minerale_tizzonite", "n": 12, "hint": "nel profondo, con il piccone d'ambra"},
			{"stat": "custodi", "n": 1, "text": "Sconfiggi un Custode", "hint": "dai bozzoli dei Custodi negli strati (e nei biomi)"},
			{"item": "frammento_albero", "n": 2, "hint": "dietro i Veli del Vuoto, nel Fondo (Passo nel Vuoto)"},
		],
		"gives": {"power": "brace", "phase": 3}},
	{"name": "Le stirpi", "say": "Quanti Cuori hai guarito? Ognuno mi fa più forte.",
		"offers": [
			{"stat": "guardiani", "n": 3, "text": "Risolvi i Guardiani di tre mondi", "hint": "curali con la Rugiada sui quattro nodi, o sconfiggili"},
			{"item": "linfa_antica", "n": 4, "hint": "dai Cuori dei mondi"},
		],
		"gives": {"aiuola": 1, "graft": ["stirpi", "cielo", "tempo"], "phase": 3}},
	{"name": "Oltre il Vuoto", "say": "Il Vuoto mi stringe le radici. Portami ciò che vive laggiù.",
		"offers": [
			{"item": "vuotite", "n": 40, "hint": "il pavimento del Fondo, con il piccone di legnoferro"},
			{"item": "cristallo_linfa", "n": 20, "hint": "cristalli nelle grotte profonde, con il piccone d'ambra"},
			{"stat": "viaggi", "n": 6, "text": "Viaggia in sei mondi", "hint": "pianta nuovi Semi nelle Aiuole"},
			{"item": "frammento_albero", "n": 3, "hint": "dietro i Muri di brace delle Profondità della Linfa (Pelle di brace)"},
		],
		"gives": {"power": "salto", "phase": 4}},
	{"name": "La chioma d'ambra", "say": "Sono quasi sveglio. Mostrami la varietà dei mondi e delle stirpi.",
		"offers": [
			{"stat": "manti_rari", "n": 1, "text": "Fai nascere un manto raro", "hint": "allevando coppie da più generazioni"},
			{"stat": "firme", "n": 5, "text": "Trova cinque firme", "hint": "ogni mondo ne ha una, a grandi linee lontana dalla partenza"},
			{"stat": "geni_imparati", "n": 20, "text": "Impara venti geni", "hint": "il Genario (K) dice le categorie e dove cercarle"},
		],
		"gives": {"power": "ponte", "graft": ["ombra"], "phase": 4}},
	{"name": "Il risveglio", "say": "Portami la Linfa di cinque Cuori, e i Custodi vinti. Poi aprirò gli occhi.",
		"offers": [
			{"item": "linfa_antica", "n": 6, "hint": "dai Cuori dei mondi di vigore alto"},
			{"stat": "custodi", "n": 3, "text": "Sconfiggi tre Custodi", "hint": "richiamali all'Altare dei Seminatori, o trova i loro bozzoli"},
			{"stat": "guardiani", "n": 5, "text": "Risolvi i Guardiani di cinque mondi", "hint": "il Fondo di ogni mondo"},
			{"item": "frammento_albero", "n": 4, "hint": "nei nidi alti nel cielo dei mondi (Salto delle spore e Radici-ponte) e dietro ogni Sigillo"},
		],
		"gives": {"aiuola": 1, "phase": 4, "lore": "albero_sveglio"}},
]

## Le categorie di geni che il Banco sa innestare prima di ogni dono (le altre si aprono con gli stadi).
const GRAFT_START := ["superficie", "forma", "fauna"]


## Tutte le categorie innestabili fino allo stadio `stage` (stadi fatti).
static func graftable(stage: int) -> Array:
	var out: Array = GRAFT_START.duplicate()
	for i in mini(stage, STAGES.size()):
		out.append_array(STAGES[i]["gives"].get("graft", []))
	return out


## Quante Aiuole in più ha dato l'Albero fino allo stadio `stage`.
static func aiuole(stage: int) -> int:
	var n := 0
	for i in mini(stage, STAGES.size()):
		n += int(STAGES[i]["gives"].get("aiuola", 0))
	return n


## Il disegno dell'Albero (0-4) dopo `stage` stadi fatti.
static func phase(stage: int) -> int:
	var p := 0
	for i in mini(stage, STAGES.size()):
		p = maxi(p, int(STAGES[i]["gives"].get("phase", 0)))
	return p


## I poteri e gli abitanti donati fino allo stadio `stage`.
static func gifts(stage: int, key: String) -> Array:
	var out := []
	for i in mini(stage, STAGES.size()):
		if STAGES[i]["gives"].has(key):
			out.append(STAGES[i]["gives"][key])
	return out
