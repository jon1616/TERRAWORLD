class_name NpcData
extends RefCounted
## Gli abitanti (voce 36): viandanti che si fermano al **Focolare** del Germogliato se trovano un **Letto di foglie**
## libero lì vicino, uno per letto. Ognuno arriva quando il mondo è pronto per lui (`requires`) e vende le sue merci in
## cambio di Lumini; tutti comprano tutto (un terzo del valore, vedi `ValueData`). Solo dati; li gestisce `Villagers`.
##
## Campi: name, greet (ciò che dice aprendo il commercio), requires (condizione: vuoto, "station" = una stazione
## piazzata nel mondo, "custodi" = Custodi sconfitti in questo mondo, "albero" = stadio dell'Albero-Madre, "giardino" =
## solo nel Giardino, "stat" + "n" = un conteggio del personaggio, voce 124), look (colori per `NpcArt`), goods ([oggetto, quantità] in vendita); dalla voce 65 anche free
## (vive accanto all'Albero, senza letto), likes, gifts, quests (vedi `NpcBonds`).

## Tessere dal Focolare entro cui contano i letti e in cui gli abitanti passeggiano.
const HOME_RANGE := 25
const WANDER := 8

## Il nome di un abitante (anche di quelli che non sono ancora nei dati).
static func name_of(id: String) -> String:
	return String(NPCS.get(id, {}).get("name", id.capitalize()))


const NPCS := {
	"viandante": {"name": "La Viandante", "greet": "Ho camminato per tre mondi. Guarda cosa ho nella bisaccia.",
		"requires": {}, "look": {"cloak": "#2f7a70", "trim": "#8ef0d8", "skin": "#c8a07a", "extra": "#d8944a"},
		"goods": [["torcia", 10], ["pozione_rugiada", 1], ["pozione_linfa", 1], ["dardo", 50], ["seme_rugiada", 3],
			["spore_brace", 3], ["baccello_esplosivo", 3], ["mappa_seminatori", 1], ["radice_uncino", 1], ["cesta", 1]]},
	"erborista": {"name": "L'Erborista", "greet": "Ogni foglia è una cura, se sai come chiederglielo.",
		"requires": {"station": "alambicco"}, "look": {"cloak": "#3a6a2a", "trim": "#c8e070", "skin": "#dcb48a", "extra": "#b870d8"},
		"goods": [["pozione_bagliore", 1], ["pozione_scorza", 1], ["pozione_vigore", 1], ["pozione_rigoglio", 1],
			["pozione_passo", 1], ["pozione_notte", 1], ["spore_luminose", 3], ["seme_campanula", 3], ["occhio_tubero", 3],
			["benda_seta", 2]]},
	"forgiatore": {"name": "Il Forgiatore", "greet": "Il Maglio dei Seminatori canta ancora. Io lo ascolto.",
		"requires": {"custodi": 1}, "look": {"cloak": "#5a3a26", "trim": "#ffb040", "skin": "#b08862", "extra": "#a2b0c2"},
		"goods": [["lingotto_radicite", 5], ["lingotto_legnoferro", 5], ["lingotto_pallidite", 5], ["lingotto_ambra", 3],
			["polvere_brace", 5], ["baccello_tonante", 2], ["uncino_cristallo", 1], ["martello_radice", 1],
			["dardo_vuoto", 50], ["giavellotto_aculeo", 20]]},
	# voce 65: gli abitanti dell'Albero-Madre. Arrivano al Giardino con gli stadi dell'Albero ("albero" = stadio fatto);
	# la Vecchia Radice vive accanto all'Albero ("free": non vuole un letto), gli altri come sempre al Focolare.
	# likes = oggetti che fanno piacere (dono: +15 d'affetto; altri doni +3); gifts = regali agli affetti 2 e 4;
	# quests = la catena di richieste personali (need: oggetti da consegnare o un traguardo; reward; +30 d'affetto).
	"vecchia_radice": {"name": "La Vecchia Radice", "greet": "Sono qui da quando l'Albero dormiva. So che cosa vuole: chiedimelo.",
		"requires": {"albero": 1, "giardino": true}, "free": true,
		"look": {"cloak": "#4c3246", "trim": "#8ef0d8", "skin": "#8a6a52", "extra": "#62c4a4"},
		"goods": [["torcia", 10], ["pozione_rugiada", 1], ["seme_lanterna", 3], ["aiuola", 1], ["provetta", 3],
			["annaffiatoio", 1]],
		"likes": ["petali_lume", "linfa_antica", "miele_lume", "cuore_bocciolo"],
		"gifts": {2: ["pozione_rugiada", 3], 4: ["cuore_bocciolo", 1]},
		"quests": [
			{"text": "Portami dieci petali di lume: le campanule del Giardino hanno fame di luce.", "need": {"petali_lume": 10},
				"reward": {"pozione_rugiada": 2}},
			{"text": "Va' a vedere tre mondi diversi: l'Albero li sente, quando ci cammini.", "stat": "viaggi", "n": 3,
				"reward": {"linfa_antica": 1}},
			{"text": "Fa' crescere l'Albero fino alla sua prima Linfa antica.", "stat": "albero", "n": 3,
				"reward": {"cuore_bocciolo": 1}},
		]},
	"mercante_semi": {"name": "Il Mercante di Semi", "greet": "Semi da ogni mondo! Ognuno una promessa, nessuno uguale all'altro.",
		"requires": {"albero": 3, "giardino": true},
		"look": {"cloak": "#7a5a2a", "trim": "#ffd24a", "skin": "#c8a07a", "extra": "#8a5a28"},
		"goods": [["seme_mondo_lanterna", 1], ["seme_mondo_sporangio", 1], ["seme_mondo_resina", 1], ["seme_mondo_brina", 1],
			["seme_mondo_cenere", 1], ["seme_mondo_mosaico", 1], ["seme_rugiada", 5], ["spore_luminose", 5]],
		"likes": ["fungo_luminoso", "lamella_fungo", "seme_lanterna", "resina_dolce"],
		"gifts": {2: ["seme_mondo_mosaico", 1], 4: ["fiala_fertile", 1]},
		"quests": [
			{"text": "Dieci funghi luminosi: con le loro spore conservo i semi.", "need": {"fungo_luminoso": 10},
				"reward": {"seme_mondo_mosaico": 1}},
			{"text": "Trova le firme di due mondi: voglio sapere che cosa nascondono i miei semi.", "stat": "firme", "n": 2,
				"reward": {"fiala_fertile": 1}},
			{"text": "Tre gocce di Linfa antica, e ti vendo il seme più raro che ho.", "need": {"linfa_antica": 3},
				"reward": {"seme_mondo_cenere": 1, "lumino": 200}},
		]},
	"mandriano": {"name": "Il Mandriano", "greet": "Ogni bestia ha un cibo che la calma. Il trucco è sapere quale.",
		"requires": {"albero": 4, "giardino": true},
		"look": {"cloak": "#5a4a3a", "trim": "#d8b070", "skin": "#b08862", "extra": "#e8e0c8"},
		"goods": [["laccio", 3], ["vasetto", 2], ["boccone", 5], ["tubero_linfa", 5], ["petali_lume", 5], ["recinto", 1],
			["incubatrice", 1]],
		"likes": ["lana_muschio", "pelliccia_volpe", "corno_radice", "miele_lume"],
		"gifts": {2: ["laccio", 5], 4: ["incubatrice", 1]},
		"quests": [
			{"text": "Otto matasse di lana di muschio: la mia coperta è bucata.", "need": {"lana_muschio": 8},
				"reward": {"laccio": 5}},
			{"text": "Addomestica tre creature: voglio vedere come te la cavi.", "stat": "addomesticate", "n": 3,
				"reward": {"incubatrice": 1}},
			{"text": "Fa' nascere un manto raro. Non ne ho mai visto uno.", "stat": "manti_rari", "n": 1,
				"reward": {"polvere_iridata": 2, "lumino": 300}},
		]},
	# voce 124: il Pescatore arriva al Focolare quando si sono pescati cinque pesci ("stat": un conteggio del personaggio)
	"pescatore": {"name": "Il Pescatore", "greet": "Ogni stagno ha la sua voce. Stai zitto un momento, e l'acqua ti dice chi ci abita.",
		"requires": {"stat": "pesci", "n": 5},
		"look": {"cloak": "#2a4a5a", "trim": "#8ec8ff", "skin": "#c89a72", "extra": "#d8c070"},
		"goods": [["canna_radice", 1], ["esca_humus", 10], ["esca_petali", 5], ["galleggiante_lume", 1], ["sacca_pescatore", 1],
			["otre_legnoferro", 1], ["fonte_acqua", 1]],
		"likes": ["perla_stagno", "filetto_pregiato", "zuppa_pesce", "squama_lume"],
		"gifts": {2: ["amo_ambra", 1], 4: ["esca_iridata", 10]},
		"quests": [
			{"text": "Tre Carpe-lanterna: le cucino per chi arriva stanco al Focolare.", "need": {"pesce_carpa_lanterna": 3},
				"reward": {"esca_squama": 10}},
			{"text": "Pesca dieci specie diverse: voglio sapere quante acque hai ascoltato.", "stat": "specie_pescate", "n": 10,
				"reward": {"sacca_pescatore": 1}},
			{"text": "Un Cuore di Linfa, dal fondo di un lago di Linfa. Dicono che batta ancora.", "need": {"pesce_cuore_linfa": 1},
				"reward": {"amo_ambra": 1, "lumino": 150}},
		]},
	"innestatrice": {"name": "L'Innestatrice", "greet": "Due semi, una lama, un po' di Linfa antica. E un mondo che non c'era.",
		"requires": {"albero": 5, "giardino": true},
		"look": {"cloak": "#2a4a3a", "trim": "#8ef0d8", "skin": "#dcb48a", "extra": "#a2b0c2"},
		"goods": [["provetta", 5], ["linfa_antica", 1], ["fiala_fertile", 1], ["fiala_vene_ricche", 1], ["fiala_rovine_fitte", 1],
			["banco_innesti", 1]],
		"likes": ["linfa_antica", "cristallo_linfa", "resina_dolce", "vetro_resina"],
		"gifts": {2: ["linfa_antica", 2], 4: ["fiala_vene_ricche", 1]},
		"quests": [
			{"text": "Innesta un Seme al Banco. Voglio vedere la tua mano.", "stat": "innesti", "n": 1,
				"reward": {"linfa_antica": 2}},
			{"text": "Impara dodici geni: non si innesta ciò che non si conosce.", "stat": "geni_imparati", "n": 12,
				"reward": {"fiala_vene_ricche": 1}},
			{"text": "Quindici cristalli di Linfa, per le mie lame.", "need": {"cristallo_linfa": 15},
				"reward": {"fiala_rovine_fitte": 1, "provetta": 5}},
		]},
	"cartografo": {"name": "Il Cartografo dei Seminatori", "greet": "I Seminatori segnavano tutto. Io ritrovo i loro segni.",
		"requires": {"albero": 7, "giardino": true},
		"look": {"cloak": "#26364a", "trim": "#e8e0c8", "skin": "#c8a07a", "extra": "#d8c8a0"},
		"goods": [["mappa_seminatori", 1], ["mappa_sigilli", 1], ["mappa_firma", 1], ["tavoletta_seminatori", 1], ["passerella", 20], ["torcia", 20]],
		"likes": ["penna_corteccia", "piuma_gelo", "vetro_resina", "scaglia_ardesia"],
		"gifts": {2: ["mappa_sigilli", 2], 4: ["mappa_firma", 2]},
		"quests": [
			{"text": "Apri un reliquiario dei Seminatori: dentro ci sono le loro mappe.", "stat": "reliquiari", "n": 1,
				"reward": {"mappa_seminatori": 2}},
			{"text": "Apri due Sigilli con i poteri dell'Albero.", "stat": "sigilli", "n": 2,
				"reward": {"mappa_sigilli": 2}},
			{"text": "Trova quattro firme: disegnerò la mappa di tutti i tuoi mondi.", "stat": "firme", "n": 4,
				"reward": {"mappa_firma": 3, "lumino": 200}},
		]},
}
