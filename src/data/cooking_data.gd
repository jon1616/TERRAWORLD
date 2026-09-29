class_name CookingData
extends RefCounted
## La cucina (Roadmap 24, voce 245): trenta piatti del Paiolo che uniscono colture (anche le varietà degli incroci),
## prodotti della mandria e pesci. Ogni piatto cura e dà **uno o più effetti** (`boons`: gli effetti a tempo di `Boons`,
## compresi i ripari dei rigori di `HarshData`): chi esplora le terre estreme, scava, pesca o combatte ha il suo piatto.
## Le ricette sono nel **Ricettario**: compaiono in Creare solo quando hai già avuto tutti gli ingredienti
## (`Crafting._discovered`, campo "ricettario"). Cucinare conta «piatti» (maestria dell'orto).
##   [nome, ingredienti, Vita, [[effetto, secondi], …], materiale dell'icona]

const DISHES := {
	"zuppa_rugiada": ["Zuppa di rugiada", {"foglia_rugiada": 3, "latte_linfa": 1}, 15, [["sazio", 900], ["rigoglio", 300]], "linfa"],
	"pane_dolce": ["Pane di tubero dolce", {"tubero_dolce": 2, "miele_lume": 1}, 20, [["sazio", 1200], ["passo", 300]], "ambra"],
	"stufato_fiammafredda": ["Stufato di fiammafredda", {"cappello_fiammafredda": 2, "filetto": 1}, 25, [["riparo_calore", 900], ["vigore", 300]], "brina"],
	"tubero_arrosto": ["Tubero fumante arrosto", {"tubero_fumante": 2}, 20, [["riparo_freddo", 900]], "brace"],
	"minestra_bulbo": ["Minestra di bulbo lume", {"bulbo_lume": 2, "foglia_rugiada": 1}, 15, [["bagliore", 900], ["vista", 600]], "brillaluce"],
	"insalata_ombra": ["Insalata d'ombra", {"petali_ombra": 3, "nettare_rugiada": 1}, 10, [["vista", 900], ["esca", 300]], "nottilite"],
	"infuso_vapore": ["Infuso di vapore", {"foglia_vapore": 3, "latte_linfa": 1}, 10, [["riparo_freddo", 1200], ["rigoglio", 300]], "nuvola"],
	"tubero_ripieno": ["Tubero notturno ripieno", {"tubero_notturno": 2, "fungo_luminoso": 2}, 25, [["vista", 1200], ["scavo", 300]], "nottilite"],
	"focaccia_brace": ["Focaccia di brace", {"petali_brace": 2, "tubero_linfa": 2}, 20, [["riparo_freddo", 600], ["vigore", 300]], "brace"],
	"crema_stellata": ["Crema stellata", {"muschio_stellato": 2, "latte_linfa": 2, "miele_cielo": 1}, 20, [["fortuna", 900], ["bagliore", 300]], "stelle"],
	"frittelle_brezza": ["Frittelle di brezza", {"petali_brezza": 3, "miele_cielo": 1}, 15, [["passo", 900], ["respiro_alto", 600]], "vento"],
	"nuvola_dolce": ["Nuvola dolce", {"ciuffo_nuvola": 2, "miele_cielo": 1, "latte_linfa": 1}, 20, [["respiro_alto", 1200], ["sazio", 600]], "nuvola"],
	"tortino_rovo": ["Tortino di rovo", {"bacca_rovo": 3, "tubero_dolce": 1}, 20, [["spine", 600], ["sazio", 600]], "sanguinella"],
	"zuppa_minatore": ["Zuppa del minatore", {"fungo_brace": 2, "tubero_linfa": 1, "filetto": 1}, 25, [["scavo", 900], ["scorza", 300]], "ardesia"],
	"spiedo_linfa": ["Spiedo di Linfa", {"filetto_linfa": 2, "foglia_rugiada": 1}, 30, [["rigoglio", 600], ["sazio", 600]], "linfa"],
	"brodo_brace": ["Brodo di brace", {"filetto_brace": 2, "fungo_brace": 1}, 30, [["riparo_freddo", 900], ["vigore", 600]], "brace"],
	"piatto_pregiato": ["Piatto pregiato", {"filetto_pregiato": 1, "nettare_rugiada": 1, "bulbo_lume": 1}, 40, [["fortuna", 900], ["vigore", 600]], "ambra"],
	"sorbetto_nettare": ["Sorbetto di nettare", {"nettare_rugiada": 2, "foglia_rugiada": 2}, 10, [["riparo_sete", 1200]], "lagunite"],
	"pane_cava": ["Pane di cava", {"tubero_linfa": 3, "fungo_luminoso": 1}, 20, [["riparo_polvere", 1200], ["scavo", 300]], "pallidite"],
	"latte_miele": ["Latte e miele", {"latte_linfa": 1, "miele_lume": 1}, 10, [["rigoglio", 600]], "ambra"],
	"stufato_pastore": ["Stufato del pastore", {"tubero_linfa": 2, "petali_lume": 2, "latte_linfa": 1}, 35, [["scorza", 900], ["sazio", 900]], "muschio"],
	"zuppa_notte": ["Zuppa della notte lunga", {"tubero_notturno": 1, "petali_ombra": 2, "fungo_luminoso": 1}, 20, [["vista", 1800]], "nottilite"],
	"arrosto_chiome": ["Arrosto delle Chiome", {"ciuffo_nuvola": 1, "filetto": 2, "petali_vento": 1}, 30, [["respiro_alto", 900], ["passo", 600]], "cielo"],
	"torta_giardino": ["Torta del Giardino", {"tubero_dolce": 1, "nettare_rugiada": 1, "bulbo_lume": 1, "miele_lume": 1}, 40, [["sazio", 1800], ["fortuna", 600]], "iride"],
	"biscotti_lucciola": ["Biscotti di lucciola", {"polvere_lucciola": 2, "tubero_dolce": 1}, 10, [["bagliore", 1200]], "lucciola"],
	"caramelle_resina": ["Caramelle di resina", {"resina_dolce": 2, "petali_brace": 1}, 10, [["vigore", 300], ["passo", 300]], "ambra"],
	"zuppa_cacciatore": ["Zuppa del cacciatore", {"filetto": 1, "fungo_brace": 1, "cappello_fiammafredda": 1}, 30, [["vigore", 900], ["esca", 300]], "sanguinella"],
	"insalata_stelle": ["Insalata di stelle", {"muschio_stellato": 2, "petali_brezza": 1, "petali_lume": 1}, 15, [["fortuna", 1200]], "stelle"],
	"sorbetto_fresco": ["Sorbetto fresco", {"nettare_rugiada": 1, "ciuffo_nuvola": 1, "latte_linfa": 1}, 10, [["riparo_calore", 1200]], "brina"],
	"banchetto_seminatori": ["Banchetto dei Seminatori", {"tubero_dolce": 2, "cappello_fiammafredda": 1, "filetto_pregiato": 1,
		"muschio_stellato": 1, "miele_cielo": 1}, 60, [["vigore", 1200], ["scorza", 1200], ["sazio", 1200]], "sem"],
}


## I nomi degli effetti (come `Boons.NAMES`: questo file di dati non nomina il modulo di gioco).
const BOON_NAMES := {"bagliore": "Bagliore", "scorza": "Scorza di corteccia", "vigore": "Vigore", "rigoglio": "Rigoglio",
	"passo": "Passo lungo", "scavo": "Minatore", "spine": "Spine", "esca": "Esca", "fortuna": "Fortuna", "sazio": "Sazio",
	"vista": "Occhi della notte"}


## Gli oggetti dei piatti (uniti in `ItemsData.all()`), con la descrizione fatta dagli effetti.
static func items() -> Dictionary:
	var out := {}
	for id in DISHES:
		var d: Array = DISHES[id]
		var fx := []
		for b in d[3]:
			fx.append("%s per %d minuti" % [String(BOON_NAMES.get(String(b[0]), HarshData.boon_names().get(String(b[0]), b[0]))).to_lower(),
				roundi(float(b[1]) / 60.0)])
		out[id] = {"name": String(d[0]), "kind": "consumabile", "icon": ["ciotola", String(d[4])], "heal": int(d[2]),
			"boon": [String(d[3][0][0]), float(d[3][0][1])], "boons": d[3], "stack": 30,
			"desc": "Cura %d Vita; %s." % [int(d[2]), ", ".join(fx)]}
	return out


static func recipes() -> Array:
	var out := []
	for id in DISHES:
		out.append({"out": id, "qty": 1, "in": (DISHES[id][1] as Dictionary).duplicate(), "station": "paiolo", "ricettario": true})
	return out
