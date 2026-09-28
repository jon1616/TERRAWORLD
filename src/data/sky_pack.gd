extends RefCounted
## Il pacchetto del cielo (Roadmap 16): gli oggetti e le ricette che non stanno nel file di un bioma del cielo (per
## salire, per l'aria sottile, i materiali in comune). Unito alle tabelle comuni come i pacchetti del bestiario
## (`BiomesData.PACK_FILES`). Questo file non nomina altre classi (valori per esteso).

const DATA := {
	# voce 159: le vene del cielo alto (le mette `PassCielo` nei biomi con il campo "ores")
	"tiles": {
		57: {"name": "Nimbite", "hard": 0.7, "power": 45, "drop": "nimbite_grezza",
			"pal": ["#34405a", "#5a7090", "#8ea8c8", "#cfe0f4", "#ffffff"], "layer": "nimbite", "specks": 30},
		58: {"name": "Folgorite", "hard": 0.6, "power": 35, "drop": "folgorite", "emit": [0.25, 0.25, 0.45],
			"pal": ["#2a2450", "#4a4a9a", "#7a8ae0", "#c0d0ff", "#fffac0"], "layer": "folgorite", "specks": 36},
	},
	"items": {
		"seme_vento": {"name": "Seme di vento", "kind": "coltura", "icon": ["seme", "vento"], "stack": 99,
			"desc": "Un seme con le ali: piantalo sull'erba (meglio quella del cielo) e nasce un Fiore di vento."},
		"petali_vento": {"name": "Petali di vento", "kind": "materiale", "icon": ["foglia", "vento"],
			"desc": "Leggeri come l'aria: il cibo delle creature del cielo, e un elisir per respirare lassù."},
		"nimbite_grezza": {"name": "Nimbite grezza", "kind": "materiale", "icon": ["minerale", "nimbite"],
			"desc": "Un metallo leggero come una nuvola, nelle isole del cielo alto. Al Baccello ardente, tre fanno un lingotto."},
		"lingotto_nimbite": {"name": "Lingotto di nimbite", "kind": "materiale", "icon": ["lingotto", "nimbite"], "tier": 3,
			"desc": "Forte come l'ambra e leggero come l'aria: le armi di nimbite colpiscono più svelte."},
		"folgorite": {"name": "Folgorite", "kind": "materiale", "icon": ["gemma", "folgorite"],
			"desc": "Una pietra dove è caduto un fulmine: ronza ancora. Nei Nidi di tempesta."},
		"dardo_folgore": {"name": "Dardo di folgore", "kind": "munizione", "icon": ["freccia", "folgorite"], "damage": 10, "stack": 999,
			"desc": "Punta di folgorite: colpisce forte e la scintilla acceca."},
		"baccello_tuono": {"name": "Baccello del tuono", "kind": "esplosivo", "icon": ["bomba", "folgorite"], "stack": 99,
			"blast": {"radius": 3.2, "power": 45, "damage": 70, "fuse": 1.2}, "desc": "Uno scoppio di tuono: rompe la roccia fino al legnoferro."},
		"lanterna_stelle": {"name": "Lanterna di polvere di stelle", "kind": "accessorio", "icon": ["lanterna", "stelle"], "stack": 1,
			"acc": {"halo": 1.5, "luck": 0.04}, "desc": "Alone di luce più ampio; un poco di fortuna."},
		# voce 157: arrivare in cielo
		"fagiolo_nuvola": {"name": "Fagiolo di nuvola", "kind": "fagiolo", "icon": ["seme", "cielo"], "stack": 20,
			"desc": "Piantalo nella terra all'aperto: in un minuto sale una liana di passerelle, 40 tessere verso il cielo."},
		"piuma_lenta": {"name": "Piuma lenta", "kind": "accessorio", "icon": ["penna", "nuvola"], "stack": 1,
			"acc": {"glide": true, "fall_safe": true}, "desc": "Le cadute non fanno male; tenendo il salto in caduta si plana."},
		# voce 158: l'aria sottile (materiali del cielo basso)
		"maschera_nuvola": {"name": "Maschera di nuvola", "kind": "accessorio", "icon": ["velo", "nuvola"], "stack": 1,
			"acc": {"quota": 0.6}, "desc": "Aria sottile: protegge al 60%. Una nuvola stretta sul viso, che respira per te."},
		"mantello_piume": {"name": "Mantello di piume del cielo", "kind": "accessorio", "icon": ["mantello", "cielo"], "stack": 1,
			"acc": {"quota": 0.5, "glide": true}, "desc": "Aria sottile: protegge a metà; si plana tenendo il salto."},
		"elisir_respiro": {"name": "Elisir del respiro alto", "kind": "consumabile", "icon": ["pozione", "celeste"],
			"boon": ["respiro_alto", 300.0], "stack": 20, "desc": "Per 5 minuti l'aria sottile non ti tocca."},
	},
	# voce 166: i geni di forma del cielo
	"genes": {
		"cieli_alti": {"cat": "forma", "name": "Cieli alti", "rar": 1, "dom": 2, "good": true,
			"desc": "la terra un poco più bassa, un cielo alto e pieno di isole", "gen": {"surface": 0.045, "sky_scale": 1.5, "sky_isles": 2.3}},
		"senza_cielo": {"cat": "cielo", "name": "Cielo vuoto", "rar": 1, "dom": 1, "good": false,
			"desc": "nessuna isola nel cielo: solo vento", "gen": {"no_sky": true}},
	},
	"gene_adj": {"cieli_alti": ["altissimi", "altissime"]},      # gli aggettivi dei nomi dei mondi per i geni di qui
	# voce 163: gli scrigni degli osservatori
	"loot": {
		"marea_cielo": [
			{"item": "vento_imprigionato", "min": 2, "max": 4, "chance": 1.0},
			{"item": "lingotto_nimbite", "min": 3, "max": 6, "chance": 0.8},
			{"item": "penna_tempesta", "min": 3, "max": 6, "chance": 0.6},
			{"item": "elisir_respiro", "min": 2, "max": 3, "chance": 0.5},
			{"item": "linfa_antica", "min": 1, "max": 1, "chance": 0.25},
		],
		"rovina_cielo": [
			{"item": "progetto_osservatorio", "min": 1, "max": 1, "chance": 0.25},
			{"item": "tavoletta_seminatori", "min": 1, "max": 1, "chance": 0.5},
			{"item": "lingotto_nimbite", "min": 2, "max": 5, "chance": 0.7},
			{"item": "cristallo_celeste", "min": 4, "max": 10, "chance": 0.6},
			{"item": "polvere_stelle", "min": 6, "max": 14, "chance": 0.5},
			{"item": "elisir_respiro", "min": 1, "max": 3, "chance": 0.5},
			{"item": "fagiolo_nuvola", "min": 2, "max": 4, "chance": 0.4},
			{"item": "dardo_stella", "min": 20, "max": 40, "chance": 0.3},
			{"item": "lanterna_stelle", "min": 1, "max": 1, "chance": 0.06},
			{"item": "linfa_antica", "min": 1, "max": 1, "chance": 0.15},
		],
	},
	# voce 165: i pesci delle pozze del cielo (campo "sky"; i campi in cima a `FishData`)
	"fish": {
		"pesce_nuvola": {"name": "Pesce nuvola", "rar": "comune", "size": [8, 16], "color": "nuvola",
			"sky": ["mare_nubi", "radici_sospese", "giardini_vento"], "desc": "Bianco e morbido: nuota come una nuvola che passa."},
		"guizzo_pioggia": {"name": "Guizzo di pioggia", "rar": "non_comune", "size": [6, 12], "color": "lagunite",
			"sky": ["mare_nubi", "nidi_tempesta"], "desc": "Nasce da una goccia che non è mai arrivata a terra."},
		"anguilla_turchese": {"name": "Anguilla turchese", "rar": "non_comune", "size": [30, 60], "color": "cielo",
			"sky": ["radici_sospese"], "desc": "Si attorciglia alle radici che pendono nelle pozze."},
		"carpa_vento": {"name": "Carpa dorata del vento", "rar": "non_comune", "size": [20, 40], "color": "vento",
			"sky": ["giardini_vento"], "desc": "Le pinne come girandole: nuota controcorrente anche nell'acqua ferma."},
		"pesce_fulmine": {"name": "Pesce fulmine", "rar": "raro", "size": [15, 30], "color": "folgorite",
			"sky": ["nidi_tempesta", "mare_nubi"], "time": "notte", "desc": "Di notte illumina la pozza a ogni guizzo."},
		"pesce_stella_cielo": {"name": "Pesce stella del cielo", "rar": "leggendario", "size": [20, 45], "color": "stelle",
			"sky": ["mare_nubi", "radici_sospese", "giardini_vento", "nidi_tempesta"], "time": "notte",
			"desc": "Dicono che sia una stella caduta in una pozza, che ha imparato a nuotare."},
	},
	# voce 165: chi si addomestica tra le famiglie del cielo (campi di `HerdData.TAME`); la Balena delle stelle vola
	"tame": {
		"greggi_nuvola": {"diet": ["petali_vento", "miele_cielo"], "diff": 2, "produce": ["lana_nuvola", 200, 1, 3],
			"aid": {"fall_safe": true}, "aid_text": "con lei vicino le cadute non fanno male"},
		"lepri_vento": {"diet": ["petali_vento", "tubero_linfa"], "diff": 2, "produce": ["pelo_vento", 200, 1, 2],
			"aid": {"jump": 1.08}, "aid_text": "salti l'8% più in alto"},
		"api_cielo": {"diet": ["petali_vento", "petali_lume"], "diff": 2, "produce": ["miele_cielo", 240, 1, 1],
			"aid": {"quota": 0.2}, "aid_text": "l'aria sottile ti pesa un po' meno (20%)"},
		"balene_stelle": {"diet": ["polvere_stelle", "miele_cielo"], "diff": 4, "produce": ["ambra_stelle", 900, 1, 1],
			"mount": {"run": 1.15}, "mount_wings": "balena", "mount_text": "vola: tenendo il salto sale piano e a lungo (4 s)"},
	},
	# voce 165: l'orto del cielo (campi di `CropsData`): il Fiore di vento cresce sulle erbe del cielo
	"crops": {
		"fiore_vento": {"name": "Fiore di vento", "seed": "seme_vento", "decor": 85, "grow": 300.0, "soil": "erba",
			"harvest": {"petali_vento": [2, 3]}, "seeds": [1, 2]},
	},
	"wild": [
		[[85], "seme_vento", 0.2],              # i fiori-girandola dei Giardini del vento
		[[84], "seme_vento", 0.05],             # l'erba dorata
	],
	"recipes": [
		{"out": "elisir_respiro", "qty": 1, "in": {"petali_vento": 3, "gelatina": 1}, "station": "alambicco"},
		{"out": "lingotto_nimbite", "qty": 1, "in": {"nimbite_grezza": 3}, "station": "baccello_ardente"},
		{"out": "dardo_folgore", "qty": 25, "in": {"folgorite": 1, "legno": 2}, "station": "ceppo"},
		{"out": "baccello_tuono", "qty": 3, "in": {"folgorite": 2, "gelatina": 2, "nuvola_tempesta": 4}, "station": "maglio"},
		{"out": "lanterna_stelle", "qty": 1, "in": {"polvere_stelle": 20, "lingotto_nimbite": 3, "cristallo_celeste": 2}, "station": "maglio"},
		{"out": "maschera_nuvola", "qty": 1, "in": {"nuvola": 25, "terra_cielo": 10, "gelatina": 4}, "station": "ceppo"},
		{"out": "mantello_piume", "qty": 1, "in": {"piuma_lenta": 1, "nuvola": 20, "cristallo_celeste": 4}, "station": "maglio"},
		{"out": "elisir_respiro", "qty": 2, "in": {"nuvola": 6, "cristallo_celeste": 1, "gelatina": 2}, "station": "alambicco"},
		{"out": "fagiolo_nuvola", "qty": 2, "in": {"legno": 6, "gelatina": 2, "humus": 4}, "station": "ceppo"},
		{"out": "piuma_lenta", "qty": 1, "in": {"penna_corteccia": 4, "gelatina": 3, "legno": 4}, "station": "ceppo"},
	],
}
