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
## Roadmap 20, voce 217, **strade alternative**: {"any": [offerta, offerta, …]} = basta una di queste (le strade di
## pilastri diversi: chi costruisce, chi esplora, chi alleva avanza ognuno a modo suo). `AlberoMadre.alt`.

## Roadmap 21: gli **atti** della storia dell'Albero (il primo stadio di ognuno e il nome). Il dono `seed` di uno stadio
## = il Seme del cosmo di un Giardino perduto (`LostGardensData`).
const ACTS := [
	{"first": 0, "name": "Il risveglio"},
	{"first": 12, "name": "Le radici del cosmo"},
]


## L'atto di uno stadio (indice in `ACTS`).
static func act_of(stage: int) -> int:
	var a := 0
	for i in ACTS.size():
		if stage >= int(ACTS[i]["first"]):
			a = i
	return a


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
			{"any": [{"stat": "geni_imparati", "n": 3, "text": "Impara tre geni", "hint": "Provetta di Linfa sulle cose dei mondi, Fiale dalle creature (Genario, tasto K)"},
				{"stat": "stele", "n": 4, "text": "Leggi quattro stele dei Seminatori", "hint": "le pietre incise nelle grotte e nelle rovine (Quaderno, tasto U)"}]},
		],
		"gives": {"power": "vista", "phase": 1, "items": {"pinza_vene": 1, "vena_radice": 30, "tamburo_radice": 1, "otre_linfa": 1,
			"lampada_baccello": 2, "leva_radice": 1, "filo_turchese": 20}}},
	{"name": "La prima Linfa antica", "say": "Nel Fondo di ogni mondo batte un Cuore. La sua Linfa più antica mi farebbe svegliare.",
		"offers": [
			{"any": [{"item": "linfa_antica", "n": 2, "hint": "la dona il Cuore di un mondo quando il suo Guardiano è curato o sconfitto (il Fondo)"},
				{"stat": "centrali", "n": 1, "text": "Risveglia una Centrale dei Seminatori", "hint": "nelle Caverne e più giù: cristallo, vene riparate, tre leve"}]},
			{"item": "lingotto_legnoferro", "n": 8, "hint": "legnoferro delle Caverne d'ardesia, fuso al Baccello"},
		],
		"gives": {"aiuola": 1, "npc": "mercante_semi", "phase": 2, "graft": ["grotte", "sottosuolo", "minerali"], "lore": "albero_linfa"}},
	{"name": "Fronde nuove", "say": "Le fronde tornano. Portami una creatura amica e la seta delle radici.",
		"offers": [
			{"stat": "addomesticate", "n": 1, "text": "Addomestica una creatura", "hint": "il suo cibo con il clic destro, o il Laccio quando è stremata"},
			{"any": [{"item": "seta_radice", "n": 10, "hint": "dalle tessiradici del Sottobosco"},
				{"stat": "raccolti", "n": 30, "text": "Raccogli trenta colture", "hint": "semina nell'orto, annaffia, raccogli con il clic destro"}]},
			{"item": "fungo_luminoso", "n": 10, "hint": "nelle Profondità della Linfa e nelle paludi di spore"},
		],
		"gives": {"power": "canto", "npc": "mandriano", "phase": 2}},
	{"name": "Il Seme che ricorda", "say": "Ogni mondo ha qualcosa che solo lui ha. Trova le loro firme, e impara altri geni.",
		"offers": [
			{"any": [{"stat": "firme", "n": 2, "text": "Trova le firme di due mondi", "hint": "il luogo unico di ogni mondo: la mappa (M) segna una stella quando lo trovi"},
				{"stat": "segreti", "n": 6, "text": "Trova sei segreti", "hint": "pareti finte, stanze murate, anomalie: il contatore dei segreti del mondo"}]},
			{"any": [{"stat": "geni_imparati", "n": 8, "text": "Impara otto geni", "hint": "Provetta, Fiale, piante-seme: il Genario (K) dice dove cercare"},
				{"stat": "stele", "n": 12, "text": "Leggi dodici stele", "hint": "le stele dei Seminatori in ogni mondo"}]},
			{"any": [{"item": "linfa_antica", "n": 2, "hint": "dai Cuori dei mondi"},
				{"stat": "centrali", "n": 2, "text": "Risveglia due Centrali dei Seminatori", "hint": "nelle Caverne e più giù"}]},
		],
		"gives": {"npc": "innestatrice", "graft": ["gemme", "rovine", "flora"], "phase": 2}},
	{"name": "Ambra e memoria", "say": "I Seminatori mi piantarono. Riportami ciò che hanno lasciato, e un frammento di me.",
		"offers": [
			{"item": "lingotto_ambra", "n": 8, "hint": "ambra fossile delle Caverne profonde, con il piccone di legnoferro"},
			{"any": [{"stat": "reliquiari", "n": 1, "text": "Apri un reliquiario dei Seminatori", "hint": "murati nella roccia: la Mappa dei Seminatori li indica"},
				{"stat": "scrigni_parola", "n": 3, "text": "Apri tre scrigni a parola", "hint": "la parola mancante della frase (Quaderno, tasto U)"}]},
			{"item": "frammento_albero", "n": 1, "hint": "le stanze chiuse da un Sigillo velato (Caverne d'ardesia, la Vista della Linfa le mostra) o di radice (Sottobosco)"},
		],
		"gives": {"aiuola": 1, "power": "passo", "phase": 3, "lore": "albero_memoria"}},
	{"name": "Il canto della mandria", "say": "Sento le tue creature. Falle crescere: voglio sentire un uovo schiudersi.",
		"offers": [
			{"any": [{"stat": "uova_allevate", "n": 1, "text": "Una coppia del recinto fa un uovo", "hint": "due creature della stessa famiglia, di livello 3, in coppia (G) nello stesso recinto"},
				{"stat": "addomesticate", "n": 4, "text": "Addomestica quattro creature", "hint": "il cibo di ogni famiglia, o il Laccio (la Mandria, tasto G)"}]},
			{"any": [{"item": "lana_muschio", "n": 10, "hint": "dalle pecore di muschio, meglio nel recinto"},
				{"stat": "prodotti", "n": 20, "text": "Raccogli venti prodotti della mandria", "hint": "i Recinti-mangiatoia e la Mungitrice"}]},
			{"item": "miele_lume", "n": 5, "hint": "dalle api di lume nel recinto"},
		],
		"gives": {"npc": "cartografo", "phase": 3}},
	{"name": "Il fuoco sotto la cenere", "say": "Nelle cenerarie covano le braci. Portami il loro calore.",
		"offers": [
			{"item": "squama_brace", "n": 6, "hint": "dalle salamandre di brace (Cenerarie, mondi con geni caldi)"},
			{"item": "minerale_tizzonite", "n": 12, "hint": "nel profondo, con il piccone d'ambra"},
			{"any": [{"stat": "custodi", "n": 1, "text": "Sconfiggi un Custode", "hint": "dai bozzoli dei Custodi negli strati (e nei biomi)"},
				{"stat": "signori", "n": 1, "text": "Sconfiggi un Signore dei luoghi", "hint": "con la sua esca rituale, nel suo luogo"}]},
			{"item": "frammento_albero", "n": 2, "hint": "dietro i Veli del Vuoto, nel Fondo (Passo nel Vuoto)"},
		],
		"gives": {"power": "brace", "phase": 3}},
	{"name": "Le stirpi", "say": "Quanti Cuori hai guarito? Ognuno mi fa più forte.",
		"offers": [
			{"any": [{"stat": "guardiani", "n": 3, "text": "Risolvi i Guardiani di tre mondi", "hint": "curali con la Rugiada sui quattro nodi, o sconfiggili"},
				{"stat": "maree_vinte", "n": 3, "text": "Respingi tre maree del mondo", "hint": "fino al loro capo"}]},
			{"any": [{"item": "linfa_antica", "n": 4, "hint": "dai Cuori dei mondi"},
				{"stat": "centrali", "n": 3, "text": "Risveglia tre Centrali dei Seminatori", "hint": "nelle Caverne e più giù"}]},
		],
		"gives": {"aiuola": 1, "graft": ["stirpi", "cielo", "tempo"], "phase": 3}},
	{"name": "Oltre il Vuoto", "say": "Il Vuoto mi stringe le radici. Portami ciò che vive laggiù.",
		"offers": [
			{"item": "vuotite", "n": 40, "hint": "il pavimento del Fondo, con il piccone di legnoferro"},
			{"item": "cristallo_linfa", "n": 20, "hint": "cristalli nelle grotte profonde, con il piccone d'ambra"},
			{"any": [{"stat": "viaggi", "n": 6, "text": "Viaggia in sei mondi", "hint": "pianta nuovi Semi nelle Aiuole"},
				{"stat": "firme", "n": 4, "text": "Trova quattro firme", "hint": "il luogo unico di ogni mondo"}]},
			{"item": "frammento_albero", "n": 3, "hint": "dietro i Muri di brace delle Profondità della Linfa (Pelle di brace)"},
		],
		"gives": {"power": "salto", "phase": 4}},
	{"name": "La chioma d'ambra", "say": "Sono quasi sveglio. Mostrami la varietà dei mondi e delle stirpi.",
		"offers": [
			{"any": [{"stat": "manti_rari", "n": 1, "text": "Fai nascere un manto raro", "hint": "allevando coppie da più generazioni"},
				{"stat": "specie_pescate", "n": 25, "text": "Pesca venticinque specie", "hint": "ogni acqua ha i suoi pesci: la scheda Pesci dell'Erbario"}]},
			{"any": [{"stat": "firme", "n": 5, "text": "Trova cinque firme", "hint": "ogni mondo ne ha una, a grandi linee lontana dalla partenza"},
				{"stat": "segreti", "n": 20, "text": "Trova venti segreti", "hint": "il contatore dei segreti di ogni mondo"}]},
			{"any": [{"stat": "geni_imparati", "n": 20, "text": "Impara venti geni", "hint": "il Genario (K) dice le categorie e dove cercarle"},
				{"stat": "stele", "n": 40, "text": "Leggi quaranta stele", "hint": "le stele dei Seminatori in ogni mondo"}]},
		],
		"gives": {"power": "ponte", "graft": ["ombra"], "phase": 4}},
	{"name": "Il risveglio", "say": "Portami la Linfa di cinque Cuori, e i Custodi vinti. Poi aprirò gli occhi.",
		"offers": [
			{"any": [{"item": "linfa_antica", "n": 6, "hint": "dai Cuori dei mondi di vigore alto"},
				{"stat": "centrali", "n": 5, "text": "Risveglia cinque Centrali dei Seminatori", "hint": "nelle Caverne e più giù"}]},
			{"any": [{"stat": "custodi", "n": 3, "text": "Sconfiggi tre Custodi", "hint": "richiamali all'Altare dei Seminatori, o trova i loro bozzoli"},
				{"stat": "signori", "n": 3, "text": "Sconfiggi tre Signori dei luoghi", "hint": "con le esche rituali"}]},
			{"any": [{"stat": "guardiani", "n": 5, "text": "Risolvi i Guardiani di cinque mondi", "hint": "il Fondo di ogni mondo"},
				{"stat": "maree_vinte", "n": 6, "text": "Respingi sei maree del mondo", "hint": "fino al loro capo"}]},
			{"item": "frammento_albero", "n": 4, "hint": "nei nidi alti nel cielo dei mondi (Salto delle spore e Radici-ponte) e dietro ogni Sigillo"},
		],
		"gives": {"aiuola": 1, "phase": 4, "lore": "albero_sveglio", "seed": "sommerso"}},
	# ---------------------------------------------------------------- Atto II «Le radici del cosmo» (Roadmap 21)
	# tre stadi per Giardino perduto: prepararsi, guarire il suo Albero, portare a casa ciò che vi si trova
	{"name": "La radice che beve il mare", "say": "Una mia radice scende fino a un mare che non conosco. Là sotto, un fratello annega. Impara le acque.",
		"offers": [
			{"any": [{"stat": "pesci", "n": 80, "text": "Pesca ottanta pesci", "hint": "canna di radice e un'esca, in qualunque acqua"},
				{"stat": "specie_pescate", "n": 15, "text": "Pesca quindici specie", "hint": "ogni acqua ha i suoi pesci (Erbario, scheda Pesci)"}]},
			{"item": "esca_squama", "n": 10, "hint": "si fa al Ceppo con le squame dei pesci"},
			{"stat": "viaggi", "n": 12, "text": "Viaggia in dodici mondi", "hint": "il Seme del cosmo nell'Aiuola porta al Giardino sommerso"},
		],
		"gives": {"lore": "atto2_sommerso"}},
	{"name": "Il cuore sott'acqua", "say": "Lo sento respirare piano, sotto il lago. Guariscilo.",
		"offers": [
			{"stat": "perduto_sommerso", "n": 1, "text": "Guarisci l'Albero sommerso", "hint": "nel Giardino sommerso: la sua scheda dice le tre cure"},
			{"item": "perla_maree", "n": 1, "hint": "la lascia la Madre delle maree, il Custode del Giardino sommerso"},
		],
		"gives": {"phase": 4}},
	{"name": "Il mare che ricorda", "say": "Il fratello sommerso mi manda le sue acque. Portami ciò che vive laggiù.",
		"offers": [
			{"any": [{"item": "guscio_lago", "n": 12, "hint": "dai Granchi del lago, nel Giardino sommerso"},
				{"stat": "pesci_leggendari", "n": 1, "text": "Pesca un pesce leggendario", "hint": "di notte, nelle acque più rare"}]},
			{"any": [{"item": "pesce_carpa_radice", "n": 3, "hint": "solo nel lago del Giardino sommerso"},
				{"stat": "specie_pescate", "n": 30, "text": "Pesca trenta specie", "hint": "l'Erbario dei pesci dice dove cercare"}]},
		],
		"gives": {"aiuola": 1, "npc": "palombara", "lore": "atto2_ferro", "seed": "ferro"}},
	{"name": "Il ferro che dorme", "say": "Un altro fratello è stato fuso con le macchine dei Seminatori. Per svegliarlo serve Linfa che scorre.",
		"offers": [
			{"any": [{"stat": "macchine", "n": 15, "text": "Quindici macchine in un mondo", "hint": "la rete di Linfa (Pinza delle vene, categoria «Linfa e macchine»)"},
				{"stat": "centrali", "n": 4, "text": "Risveglia quattro Centrali dei Seminatori", "hint": "nelle Caverne e più giù"}]},
			{"item": "lingotto_legnoferro", "n": 30, "hint": "legnoferro fuso al Baccello (o al Forno a Linfa)"},
		],
		"gives": {}},
	{"name": "Il cuore d'ingranaggio", "say": "Dagli la Linfa che gli manca, e ferma chi lo tiene prigioniero.",
		"offers": [
			{"stat": "perduto_ferro", "n": 1, "text": "Guarisci l'Albero di ferro", "hint": "nel Giardino di ferro, sessanta tessere sotto terra"},
			{"item": "spola_viva", "n": 1, "hint": "la lascia il Telaio vivo, il Custode del Giardino di ferro"},
			{"any": [{"item": "ingranaggio_radice", "n": 12, "hint": "dalle macchine selvatiche del Giardino di ferro"},
				{"item": "vena_ambra", "n": 60, "hint": "al Maglio, con l'ambra fossile"}]},
		],
		"gives": {"phase": 4}},
	{"name": "La Linfa torna", "say": "Sento la sua Linfa mescolarsi alla mia. Insegnami a farla scorrere anche qui.",
		"offers": [
			{"any": [{"stat": "macchine", "n": 30, "text": "Trenta macchine in un mondo", "hint": "una rete grande, con le sue riserve"},
				{"stat": "centrali", "n": 6, "text": "Risveglia sei Centrali dei Seminatori", "hint": "nelle Caverne e più giù"}]},
			{"item": "cristallo_linfa", "n": 15, "hint": "cristalli nelle grotte profonde, con il piccone d'ambra"},
		],
		"gives": {"aiuola": 1, "npc": "fabbro_radici", "lore": "atto2_selvatico", "seed": "selvatico"}},
	{"name": "Le bestie senza nome", "say": "Nel terzo Giardino le bestie hanno dimenticato il Giardiniere. Ricordaglielo, con pazienza.",
		"offers": [
			{"any": [{"stat": "addomesticate", "n": 6, "text": "Addomestica sei creature", "hint": "il cibo di ogni famiglia, o il Laccio (Mandria, tasto G)"},
				{"stat": "prodotti", "n": 40, "text": "Raccogli quaranta prodotti della mandria", "hint": "Recinti-mangiatoia e Mungitrice"}]},
			{"any": [{"item": "bacca_rovo", "n": 20, "hint": "dai Cervi e dai Cinghiali di rovo, nel Giardino selvatico"},
				{"stat": "raccolti", "n": 80, "text": "Raccogli ottanta colture", "hint": "l'orto: semina, annaffia, raccogli"}]},
		],
		"gives": {}},
	{"name": "Il re dei rovi", "say": "Un re di spine tiene la radura. Guarisci il fratello selvatico.",
		"offers": [
			{"stat": "perduto_selvatico", "n": 1, "text": "Guarisci l'Albero selvatico", "hint": "nel Giardino selvatico: la sua scheda dice le tre cure"},
			{"item": "cuore_rovo", "n": 1, "hint": "lo lascia il Re dei rovi, il Custode del Giardino selvatico"},
			{"item": "setola_rovo", "n": 10, "hint": "dai Cinghiali di rovo"},
		],
		"gives": {"phase": 4}},
	{"name": "La radura che canta", "say": "La radura canta di nuovo. Fa' crescere qui le sue stirpi.",
		"offers": [
			{"any": [{"stat": "uova_allevate", "n": 3, "text": "Tre uova dalle coppie del recinto", "hint": "due creature della stessa famiglia, di livello 3"},
				{"stat": "manti_rari", "n": 1, "text": "Fai nascere un manto raro", "hint": "allevando coppie da più generazioni"}]},
			{"any": [{"item": "lana_muschio", "n": 20, "hint": "dalle pecore di muschio del recinto"},
				{"item": "miele_lume", "n": 15, "hint": "dalle api di lume del recinto"}]},
		],
		"gives": {"aiuola": 1, "npc": "guardaboschi", "lore": "atto2_muto", "seed": "muto"}},
	{"name": "Le parole perdute", "say": "L'ultimo fratello ha dimenticato le parole. Io le ricordo a metà. Tu le hai lette sulle stele.",
		"offers": [
			{"any": [{"stat": "stele", "n": 60, "text": "Leggi sessanta stele", "hint": "le stele dei Seminatori di ogni mondo (Quaderno, tasto U)"},
				{"stat": "scrigni_parola", "n": 12, "text": "Apri dodici scrigni a parola", "hint": "la parola mancante della frase"}]},
			{"item": "tavoletta_seminatori", "n": 6, "hint": "nelle rovine, dal Cartografo, dai Guardastele"},
		],
		"gives": {}},
	{"name": "Il Silenzio", "say": "Qualcosa gli ha rubato la voce. Riportagliela.",
		"offers": [
			{"stat": "perduto_muto", "n": 1, "text": "Guarisci l'Albero muto", "hint": "nel Giardino muto, al centro del cerchio di stele"},
			{"item": "parola_prima", "n": 1, "hint": "la lascia il Silenzio, il Custode del Giardino muto"},
			{"item": "eco_parola", "n": 12, "hint": "dalle Ombre di parola del Giardino muto"},
		],
		"gives": {"phase": 4}},
	{"name": "Le radici del cosmo", "say": "Quattro fratelli respirano di nuovo. Le radici del cosmo si scaldano: sento altri Giardini, più lontano.",
		"offers": [
			{"stat": "perduti", "n": 4, "text": "Guarisci i quattro Alberi perduti", "hint": "i quattro Giardini del cosmo"},
			{"any": [{"item": "linfa_antica", "n": 10, "hint": "dai Cuori dei mondi"},
				{"stat": "centrali", "n": 8, "text": "Risveglia otto Centrali dei Seminatori", "hint": "nelle Caverne e più giù"}]},
			{"item": "polvere_iridata", "n": 4, "hint": "dalle creature iridate, dai Custodi, dagli Alberi guariti"},
		],
		"gives": {"aiuola": 1, "lore": "radici_cosmo", "items": {"linfa_antica": 5, "polvere_iridata": 3}}},
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
