class_name TrophyItemsData
extends RefCounted
## I trofei (voce 23): ogni specie di creatura ne ha uno, e lo lasciano **solo le sue rare** (antiche, ancestrali,
## capibranco, iridate: vedi `AncientData`). Non è bottino «di più»: è bottino proprio, che non si trova altrove.
## Ogni trofeo serve a un oggetto unico legato a quella creatura; la **Polvere iridata** delle creature iridate serve
## ai quattro oggetti iridati, i più rari del gioco. Solo dati; uniti in `ItemsData.all()`.
##
## Campi in più rispetto a `ItemsData`: gli accessori usano anche damage (danno ×), atk_speed (colpi più rapidi ×),
## linfa_regen (la Linfa ricresce ×); le armi `poison` (i colpi avvelenano) e gli archi `multishot` (dardi per tiro).

## Il trofeo di ogni specie.
const TROPHY_OF := {
	"grumo_muschio": "nucleo_muschio", "grumo_resina": "nucleo_resina", "grumo_spore": "nucleo_spore",
	"falena_brace": "ala_falena", "strisciaradice": "nodo_strisciaradice", "scarabeo_ardesia": "corno_scarabeo",
	"sputaspore": "bocca_sputaspore", "avvizzito_errante": "cuore_errante", "vagavuoto": "occhio_vagavuoto",
	"corvo_corteccia": "becco_corvo", "spinoriccio": "aculeo_maestro", "lucciola_vorace": "lanterna_lucciola",
	"tessiradice": "filiera_radice", "talpone": "muso_talpone", "saltafungo": "cappello_saltafungo",
	"ala_ardesia": "ala_maestra", "chiocciola_cristallo": "spirale_cristallo", "geomimo": "occhio_geode",
	"serpe_linfa": "dente_serpe", "campanula_errante": "pistillo_oro", "guizzalinfa": "scintilla_guizzo",
	"mietivuoto": "falce_maestra", "tessivuoto": "filiera_vuoto", "sciame_schegge": "nucleo_sciame",
	# voce 40 (oggetti e ricette in `BiomeItemsData`)
	"cervo_brina": "cuore_brina", "gufo_gelo": "occhio_gelo", "salamandra_brace": "coda_brace",
	"fatuo_cenere": "fiamma_fatua",
}

const _T := "Lo lasciano solo le creature rare di questa specie."

const ITEMS := {
	# i trofei
	"nucleo_muschio": {"name": "Nucleo di grumo di muschio", "kind": "trofeo", "icon": ["essenza", "muschio"], "desc": _T},
	"nucleo_resina": {"name": "Nucleo di grumo di resina", "kind": "trofeo", "icon": ["essenza", "ambra"], "desc": _T},
	"nucleo_spore": {"name": "Nucleo di grumo di spore", "kind": "trofeo", "icon": ["essenza", "sem"], "desc": _T},
	"ala_falena": {"name": "Ala intatta di falena", "kind": "trofeo", "icon": ["foglia", "brace"], "desc": _T},
	"nodo_strisciaradice": {"name": "Nodo di strisciaradice", "kind": "trofeo", "icon": ["tronco", "radice"], "desc": _T},
	"corno_scarabeo": {"name": "Corno di scarabeo", "kind": "trofeo", "icon": ["aculeo", "ardesia"], "desc": _T},
	"bocca_sputaspore": {"name": "Bocca di sputaspore", "kind": "trofeo", "icon": ["sacca", "sem"], "desc": _T},
	"cuore_errante": {"name": "Cuore dell'errante", "kind": "trofeo", "icon": ["cuore", "nodo"], "desc": _T},
	"occhio_vagavuoto": {"name": "Occhio del Vagavuoto", "kind": "trofeo", "icon": ["occhio", "vuotite"], "desc": _T},
	"becco_corvo": {"name": "Becco di corvo", "kind": "trofeo", "icon": ["aculeo", "ambra"], "desc": _T},
	"aculeo_maestro": {"name": "Aculeo maestro", "kind": "trofeo", "icon": ["aculeo", "brace"], "desc": _T},
	"lanterna_lucciola": {"name": "Lanterna di lucciola", "kind": "trofeo", "icon": ["lanterna", "lucciola"], "desc": _T},
	"filiera_radice": {"name": "Filiera di tessiradice", "kind": "trofeo", "icon": ["seta", "radice"], "desc": _T},
	"muso_talpone": {"name": "Muso di talpone", "kind": "trofeo", "icon": ["artiglio", "humus"], "desc": _T},
	"cappello_saltafungo": {"name": "Cappello di saltafungo", "kind": "trofeo", "icon": ["fungo", "fungo"], "desc": _T},
	"ala_maestra": {"name": "Ala maestra d'ardesia", "kind": "trofeo", "icon": ["membrana", "scisto"], "desc": _T},
	"spirale_cristallo": {"name": "Spirale di cristallo", "kind": "trofeo", "icon": ["guscio", "ambra"], "desc": _T},
	"occhio_geode": {"name": "Occhio di geode", "kind": "trofeo", "icon": ["occhio", "vuotite"], "desc": _T},
	"dente_serpe": {"name": "Dente di serpe", "kind": "trofeo", "icon": ["aculeo", "cristallo"], "desc": _T},
	"pistillo_oro": {"name": "Pistillo d'oro", "kind": "trofeo", "icon": ["pappo", "ambra"], "desc": _T},
	"scintilla_guizzo": {"name": "Scintilla di guizzo", "kind": "trofeo", "icon": ["essenza", "cristallo"], "desc": _T},
	"falce_maestra": {"name": "Falce maestra", "kind": "trofeo", "icon": ["lama", "vuotite"], "desc": _T},
	"filiera_vuoto": {"name": "Filiera del Vuoto", "kind": "trofeo", "icon": ["seta", "vuotite"], "desc": _T},
	"nucleo_sciame": {"name": "Nucleo di sciame", "kind": "trofeo", "icon": ["geode", "vuotite"], "desc": _T},
	"polvere_iridata": {"name": "Polvere iridata", "kind": "materiale", "icon": ["polvere", "iride"], "desc": "Cade dalle creature iridate, le più rare del Giardino. Cambia colore a ogni sguardo."},
	# gli oggetti dei trofei: uno per specie
	"cuore_grumo": {"name": "Cuore di grumo", "kind": "accessorio", "icon": ["cuore", "muschio"], "acc": {"regen": 1.6}, "desc": "La Vita ricresce il 60% più in fretta."},
	"pelle_resina": {"name": "Pelle di resina", "kind": "accessorio", "icon": ["gel", "ambra"], "defense": 3, "acc": {"thorns": 4}, "desc": "+3 Scorza; chi ti tocca resta invischiato e si ferisce (4)."},
	"sacca_aria": {"name": "Sacca d'aria", "kind": "accessorio", "icon": ["sacca", "cristallo"], "acc": {"jump": 1.25}, "desc": "Salto molto più alto."},
	"lume_falena": {"name": "Lume di falena", "kind": "accessorio", "icon": ["lanterna", "brace"], "acc": {"halo": 1.5, "linfa_regen": 1.5}, "desc": "Alone più ampio e Linfa che ricresce più in fretta."},
	"cintura_radice": {"name": "Cintura di radice", "kind": "accessorio", "icon": ["collana", "radice"], "defense": 2, "acc": {"regen": 1.3}, "desc": "+2 Scorza; la Vita ricresce più in fretta."},
	"corno_carica": {"name": "Corno di carica", "kind": "accessorio", "icon": ["aculeo", "ardesia"], "defense": 2, "acc": {"damage": 1.1}, "desc": "+10% danno e +2 Scorza."},
	"bastone_sputaspore": {"name": "Bastone sputaspore", "kind": "bastone", "icon": ["bastone", "sem"], "tier": 2, "damage": 14, "speed": 2.4, "knockback": 1.2, "spell": "spore", "linfa": 4, "desc": "Il ventaglio di spore di uno sputaspore, a comando."},
	"amuleto_errante": {"name": "Amuleto dell'errante", "kind": "accessorio", "icon": ["amuleto", "nodo"], "acc": {"stealth": 0.8, "damage": 1.08}, "desc": "Le creature ti notano più tardi; +8% danno."},
	"occhio_vuoto": {"name": "Occhio del Vuoto", "kind": "accessorio", "icon": ["occhio", "vuotite"], "acc": {"halo": 1.3, "luck": 0.2}, "desc": "Vedi un poco più lontano nel buio, e trovi di più."},
	"pugnale_becco": {"name": "Pugnale di becco", "kind": "spada", "icon": ["spada", "ambra"], "tier": 2, "damage": 13, "speed": 3.6, "knockback": 1.5, "desc": "Leggerissimo: colpisce molto in fretta."},
	"guscio_riccio": {"name": "Guscio di riccio", "kind": "accessorio", "icon": ["scudo", "ambra"], "defense": 2, "acc": {"thorns": 14}, "desc": "Chi ti tocca si punge: 14 danni; +2 Scorza."},
	"lume_lucciola": {"name": "Lume di lucciola", "kind": "accessorio", "icon": ["lanterna", "lucciola"], "acc": {"halo": 1.8}, "desc": "L'alone del Germogliato si allarga molto."},
	"guanti_seta": {"name": "Guanti di seta", "kind": "accessorio", "icon": ["guanti", "seta"], "acc": {"atk_speed": 1.12}, "desc": "Si colpisce il 12% più in fretta, con ogni arma."},
	"elmetto_talpone": {"name": "Muso del talpone", "kind": "accessorio", "icon": ["artiglio", "humus"], "acc": {"dig": 1.6}, "desc": "Scavo e taglio il 60% più rapidi."},
	"spore_saltellanti": {"name": "Spore saltellanti", "kind": "accessorio", "icon": ["fungo", "fungo"], "acc": {"jump": 1.2, "fall_safe": true}, "desc": "Salto più alto e nessuna ferita da caduta."},
	"ali_ardesia": {"name": "Ali d'ardesia", "kind": "accessorio", "icon": ["ali", "scisto"], "acc": {"glide": true, "run": 1.15}, "desc": "Planata tenendo Spazio, corsa più veloce."},
	"guscio_spirale": {"name": "Guscio a spirale", "kind": "accessorio", "icon": ["guscio", "cristallo"], "defense": 8, "desc": "+8 Scorza."},
	"pietra_mimo": {"name": "Pietra del mimo", "kind": "accessorio", "icon": ["geode", "cristallo"], "acc": {"luck": 0.6}, "desc": "Molta fortuna: un giro di bottino in più più spesso."},
	"zanna_serpe": {"name": "Zanna di serpe", "kind": "spada", "icon": ["lama", "cristallo"], "tier": 4, "damage": 24, "speed": 3.0, "knockback": 2.0, "poison": true, "desc": "Ogni colpo avvelena."},
	"bastone_polline": {"name": "Bastone di polline", "kind": "bastone", "icon": ["bastone", "ambra"], "tier": 4, "damage": 16, "speed": 1.6, "knockback": 1.0, "spell": "polline", "linfa": 6, "desc": "Una pioggia di cinque grani di polline accesi."},
	"passo_guizzo": {"name": "Passo di guizzo", "kind": "accessorio", "icon": ["stivali", "cristallo"], "acc": {"run": 1.25, "jump": 1.1}, "desc": "Corsa e salto più svelti."},
	"mietitrice": {"name": "Mietitrice", "kind": "spada", "icon": ["falce", "vuotite"], "tier": 6, "damage": 40, "speed": 2.4, "knockback": 5.0, "desc": "La falce di un Mietivuoto antico."},
	"rete_vuoto": {"name": "Rete del Vuoto", "kind": "accessorio", "icon": ["velo", "vuotite"], "acc": {"stealth": 0.5, "thorns": 6}, "desc": "Quasi invisibile alle creature; chi ti tocca si ferisce (6)."},
	"schegge_orbitanti": {"name": "Schegge orbitanti", "kind": "accessorio", "icon": ["essenza", "vuotite"], "acc": {"damage": 1.12}, "desc": "+12% danno."},
	# gli oggetti iridati: Polvere iridata e trofei di più specie
	"corona_giardino": {"name": "Corona del Giardino", "kind": "accessorio", "icon": ["corona", "iride"], "defense": 3, "acc": {"damage": 1.1, "run": 1.1, "regen": 1.3, "luck": 0.2}, "desc": "Un po' di tutto: danno, corsa, Vita, fortuna, Scorza."},
	"arco_iridato": {"name": "Arco iridato", "kind": "arco", "icon": ["arco", "iride"], "tier": 5, "damage": 18, "speed": 2.4, "knockback": 1.4, "multishot": 3, "desc": "Tira tre dardi a ventaglio."},
	"bastone_iridato": {"name": "Bastone iridato", "kind": "bastone", "icon": ["bastone", "iride"], "tier": 5, "damage": 30, "speed": 2.2, "knockback": 1.5, "spell": "iride", "linfa": 7, "desc": "Una luce che cambia colore: attraversa e insegue."},
	"mantello_iridato": {"name": "Mantello iridato", "kind": "accessorio", "icon": ["mantello", "iride"], "acc": {"glide": true, "fall_safe": true, "stealth": 0.7, "run": 1.2}, "desc": "Planata, niente cadute, corsa più veloce, visto più tardi."},
}

## Le ricette dei trofei (al Maglio dei Seminatori).
const RECIPES := [
	{"out": "cuore_grumo", "qty": 1, "in": {"nucleo_muschio": 2, "gelatina": 20}, "station": "maglio"},
	{"out": "pelle_resina", "qty": 1, "in": {"nucleo_resina": 2, "gelatina": 15, "legno": 10}, "station": "maglio"},
	{"out": "sacca_aria", "qty": 1, "in": {"nucleo_spore": 2, "sacca_spore": 8}, "station": "maglio"},
	{"out": "lume_falena", "qty": 1, "in": {"ala_falena": 2, "polvere_brace": 15}, "station": "maglio"},
	{"out": "cintura_radice", "qty": 1, "in": {"nodo_strisciaradice": 2, "legno": 20}, "station": "maglio"},
	{"out": "corno_carica", "qty": 1, "in": {"corno_scarabeo": 2, "scaglia_ardesia": 12}, "station": "maglio"},
	{"out": "bastone_sputaspore", "qty": 1, "in": {"bocca_sputaspore": 2, "sacca_spore": 6, "legno": 6}, "station": "maglio"},
	{"out": "amuleto_errante", "qty": 1, "in": {"cuore_errante": 2, "cenere_avvizzita": 10}, "station": "maglio"},
	{"out": "occhio_vuoto", "qty": 1, "in": {"occhio_vagavuoto": 2, "scheggia_vuoto": 10}, "station": "maglio"},
	{"out": "pugnale_becco", "qty": 1, "in": {"becco_corvo": 2, "penna_corteccia": 8, "lingotto_radicite": 4}, "station": "maglio"},
	{"out": "guscio_riccio", "qty": 1, "in": {"aculeo_maestro": 2, "aculeo": 20}, "station": "maglio"},
	{"out": "lume_lucciola", "qty": 1, "in": {"lanterna_lucciola": 2, "polvere_lucciola": 15}, "station": "maglio"},
	{"out": "guanti_seta", "qty": 1, "in": {"filiera_radice": 2, "seta_radice": 15}, "station": "maglio"},
	{"out": "elmetto_talpone", "qty": 1, "in": {"muso_talpone": 2, "artiglio_talpone": 4}, "station": "maglio"},
	{"out": "spore_saltellanti", "qty": 1, "in": {"cappello_saltafungo": 2, "lamella_fungo": 12}, "station": "maglio"},
	{"out": "ali_ardesia", "qty": 1, "in": {"ala_maestra": 2, "membrana_ardesia": 12}, "station": "maglio"},
	{"out": "guscio_spirale", "qty": 1, "in": {"spirale_cristallo": 2, "guscio_cristallo": 10}, "station": "maglio"},
	{"out": "pietra_mimo", "qty": 1, "in": {"occhio_geode": 2, "cuore_geode": 3}, "station": "maglio"},
	{"out": "zanna_serpe", "qty": 1, "in": {"dente_serpe": 2, "scaglia_linfa": 10, "lingotto_linfa": 4}, "station": "maglio"},
	{"out": "bastone_polline", "qty": 1, "in": {"pistillo_oro": 2, "polline_luminoso": 12, "legno": 6}, "station": "maglio"},
	{"out": "passo_guizzo", "qty": 1, "in": {"scintilla_guizzo": 2, "occhio_guizzo": 2}, "station": "maglio"},
	{"out": "mietitrice", "qty": 1, "in": {"falce_maestra": 2, "lama_vuoto": 6, "lingotto_vuoto": 6}, "station": "maglio"},
	{"out": "rete_vuoto", "qty": 1, "in": {"filiera_vuoto": 2, "seta_vuoto": 12}, "station": "maglio"},
	{"out": "schegge_orbitanti", "qty": 1, "in": {"nucleo_sciame": 2, "scheggia_vuoto": 15}, "station": "maglio"},
	{"out": "corona_giardino", "qty": 1, "in": {"polvere_iridata": 8, "nucleo_muschio": 1, "ala_falena": 1, "corno_scarabeo": 1, "occhio_vagavuoto": 1}, "station": "maglio"},
	{"out": "arco_iridato", "qty": 1, "in": {"polvere_iridata": 6, "becco_corvo": 2, "lingotto_ambra": 8}, "station": "maglio"},
	{"out": "bastone_iridato", "qty": 1, "in": {"polvere_iridata": 6, "scintilla_guizzo": 2, "cristallo_linfa": 10}, "station": "maglio"},
	{"out": "mantello_iridato", "qty": 1, "in": {"polvere_iridata": 8, "ala_maestra": 1, "filiera_vuoto": 1, "seta_radice": 10}, "station": "maglio"},
]
