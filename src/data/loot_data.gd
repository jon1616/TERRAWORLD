class_name LootData
extends RefCounted
## Tabelle di bottino: ogni voce = oggetto, quantità minima e massima, probabilità (0-1).

const TABLES := {
	"grumo": [
		{"item": "gelatina", "min": 1, "max": 2, "chance": 1.0},
	],
	"grumo_resina": [
		{"item": "gelatina", "min": 2, "max": 3, "chance": 1.0},
		{"item": "fungo_brace", "min": 1, "max": 1, "chance": 0.15},
	],
	"grumo_spore": [
		{"item": "gelatina", "min": 2, "max": 4, "chance": 1.0},
		{"item": "fungo_luminoso", "min": 1, "max": 2, "chance": 0.25},
	],
	"falena": [
		{"item": "polvere_brace", "min": 1, "max": 2, "chance": 0.8},
	],
	"strisciaradice": [
		{"item": "occhio_tubero", "min": 1, "max": 1, "chance": 0.08},
		{"item": "legno", "min": 1, "max": 3, "chance": 1.0},
		{"item": "seme_lanterna", "min": 1, "max": 1, "chance": 0.1},
	],
	"scarabeo": [
		{"item": "scaglia_ardesia", "min": 1, "max": 3, "chance": 1.0},
		{"item": "minerale_legnoferro", "min": 1, "max": 2, "chance": 0.3},
	],
	"avvizzito": [
		{"item": "legno", "min": 1, "max": 2, "chance": 1.0},
		{"item": "fungo_brace", "min": 1, "max": 1, "chance": 0.3},
		{"item": "seme_lanterna", "min": 1, "max": 1, "chance": 0.12},
	],
	# scrigni delle rovine dei Seminatori, per strato (1 Sottobosco … 4 il Fondo); `roll_chest` tira più volte
	"rovina_1": [
		{"item": "tavoletta_seminatori", "min": 1, "max": 1, "chance": 0.35},
		{"item": "lumino", "min": 5, "max": 15, "chance": 1.0},
		{"item": "seme_rugiada", "min": 2, "max": 4, "chance": 0.3},
		{"item": "occhio_tubero", "min": 1, "max": 2, "chance": 0.15},
		{"item": "torcia", "min": 6, "max": 12, "chance": 0.7},
		{"item": "pozione_rugiada", "min": 1, "max": 2, "chance": 0.5},
		{"item": "dardo", "min": 20, "max": 40, "chance": 0.4},
		{"item": "lingotto_radicite", "min": 3, "max": 6, "chance": 0.4},
		{"item": "seme_lanterna", "min": 1, "max": 3, "chance": 0.3},
		{"item": "stivali_radice", "min": 1, "max": 1, "chance": 0.18},
		{"item": "anello_lucciola", "min": 1, "max": 1, "chance": 0.18},
		{"item": "pappo_seme", "min": 1, "max": 1, "chance": 0.12},
	],
	"rovina_2": [
		{"item": "tavoletta_seminatori", "min": 1, "max": 1, "chance": 0.4},
		{"item": "lumino", "min": 10, "max": 30, "chance": 1.0},
		{"item": "spore_luminose", "min": 2, "max": 3, "chance": 0.2},
		{"item": "seme_campanula", "min": 1, "max": 2, "chance": 0.15},
		{"item": "baccello_vento", "min": 1, "max": 1, "chance": 0.12},
		{"item": "mappa_seminatori", "min": 1, "max": 1, "chance": 0.25},
		{"item": "torcia", "min": 8, "max": 15, "chance": 0.5},
		{"item": "lingotto_legnoferro", "min": 3, "max": 6, "chance": 0.45},
		{"item": "pozione_scorza", "min": 1, "max": 2, "chance": 0.4},
		{"item": "pozione_rugiada", "min": 1, "max": 3, "chance": 0.4},
		{"item": "dardo", "min": 30, "max": 60, "chance": 0.35},
		{"item": "foglia_planante", "min": 1, "max": 1, "chance": 0.16},
		{"item": "amuleto_corteccia", "min": 1, "max": 1, "chance": 0.16},
		{"item": "stivali_radice", "min": 1, "max": 1, "chance": 0.12},
		{"item": "cuore_muschio", "min": 1, "max": 1, "chance": 0.1},
	],
	"rovina_3": [
		{"item": "tavoletta_seminatori", "min": 1, "max": 2, "chance": 0.45},
		{"item": "lumino", "min": 20, "max": 50, "chance": 1.0},
		{"item": "baccello_vento", "min": 1, "max": 1, "chance": 0.1},
		{"item": "artigli_corteccia", "min": 1, "max": 1, "chance": 0.08},
		{"item": "mappa_seminatori", "min": 1, "max": 1, "chance": 0.25},
		{"item": "lingotto_ambra", "min": 3, "max": 6, "chance": 0.45},
		{"item": "pozione_bagliore", "min": 1, "max": 2, "chance": 0.45},
		{"item": "cristallo_linfa", "min": 2, "max": 5, "chance": 0.4},
		{"item": "pozione_rugiada", "min": 2, "max": 3, "chance": 0.4},
		{"item": "cuore_muschio", "min": 1, "max": 1, "chance": 0.15},
		{"item": "pappo_seme", "min": 1, "max": 1, "chance": 0.15},
		{"item": "anello_lucciola", "min": 1, "max": 1, "chance": 0.12},
		{"item": "foglia_planante", "min": 1, "max": 1, "chance": 0.12},
	],
	"rovina_4": [
		{"item": "tavoletta_seminatori", "min": 1, "max": 2, "chance": 0.5},
		{"item": "lumino", "min": 40, "max": 90, "chance": 1.0},
		{"item": "lingotto_ambra", "min": 4, "max": 8, "chance": 0.5},
		{"item": "rugiada_linfa", "min": 1, "max": 2, "chance": 0.45},
		{"item": "dardo_vuoto", "min": 20, "max": 40, "chance": 0.4},
		{"item": "cristallo_linfa", "min": 3, "max": 6, "chance": 0.4},
		{"item": "amuleto_corteccia", "min": 1, "max": 1, "chance": 0.18},
		{"item": "cuore_muschio", "min": 1, "max": 1, "chance": 0.18},
		{"item": "foglia_planante", "min": 1, "max": 1, "chance": 0.15},
	],
	"guardiano": [
		{"item": "frammento_nodo", "min": 30, "max": 30, "chance": 1.0},
		{"item": "scheggia_vuoto", "min": 8, "max": 12, "chance": 1.0},
		{"item": "minerale_ambra", "min": 10, "max": 16, "chance": 1.0},
	],
	"regina": [
		{"item": "velo_spora", "min": 30, "max": 30, "chance": 1.0},
		{"item": "sacca_spore", "min": 10, "max": 15, "chance": 1.0},
		{"item": "cristallo_linfa", "min": 8, "max": 12, "chance": 1.0},
	],
	"colosso": [
		{"item": "nucleo_colosso", "min": 30, "max": 30, "chance": 1.0},
		{"item": "scaglia_ardesia", "min": 20, "max": 30, "chance": 1.0},
		{"item": "scheggia_vuoto", "min": 10, "max": 16, "chance": 1.0},
	],
	"vagavuoto": [
		{"item": "scheggia_vuoto", "min": 1, "max": 3, "chance": 1.0},
		{"item": "minerale_ambra", "min": 1, "max": 2, "chance": 0.25},
	],
	"sputaspore": [
		{"item": "sacca_spore", "min": 1, "max": 2, "chance": 1.0},
		{"item": "fungo_luminoso", "min": 1, "max": 1, "chance": 0.3},
	],
	# voce 34: la ricompensa della Notte dell'Avvizzimento vinta
	"alba": [
		{"item": "cenere_avvizzita", "min": 5, "max": 10, "chance": 1.0},
		{"item": "seme_muschio", "min": 3, "max": 5, "chance": 0.6},
		{"item": "pozione_rigoglio", "min": 1, "max": 2, "chance": 0.7},
		{"item": "cuore_bocciolo", "min": 1, "max": 1, "chance": 0.25},
		{"item": "stilla_perenne", "min": 1, "max": 1, "chance": 0.15},
		{"item": "essenza_furia", "min": 1, "max": 1, "chance": 0.2},
		{"item": "essenza_guscio", "min": 1, "max": 1, "chance": 0.2},
		{"item": "polvere_iridata", "min": 1, "max": 2, "chance": 0.1},
	],
	# voce 22
	"corvo": [
		{"item": "penna_corteccia", "min": 1, "max": 3, "chance": 1.0},
		{"item": "legno", "min": 1, "max": 1, "chance": 0.3},
	],
	"spinoriccio": [{"item": "aculeo", "min": 2, "max": 4, "chance": 1.0}],
	"lucciola": [{"item": "polvere_lucciola", "min": 1, "max": 1, "chance": 0.7}],
	"tessiradice": [{"item": "seta_radice", "min": 2, "max": 4, "chance": 1.0}],
	"talpone": [
		{"item": "artiglio_talpone", "min": 1, "max": 1, "chance": 0.6},
		{"item": "humus", "min": 2, "max": 4, "chance": 1.0},
		{"item": "minerale_radicite", "min": 1, "max": 2, "chance": 0.3},
	],
	"saltafungo": [
		{"item": "spore_brace", "min": 1, "max": 2, "chance": 0.3},
		{"item": "lamella_fungo", "min": 1, "max": 3, "chance": 1.0},
		{"item": "fungo_brace", "min": 1, "max": 1, "chance": 0.3},
	],
	"ala_ardesia": [{"item": "membrana_ardesia", "min": 1, "max": 2, "chance": 1.0}],
	"chiocciola": [
		{"item": "guscio_cristallo", "min": 1, "max": 2, "chance": 1.0},
		{"item": "cristallo_linfa", "min": 1, "max": 1, "chance": 0.3},
	],
	"geomimo": [
		{"item": "cuore_geode", "min": 1, "max": 1, "chance": 1.0},
		{"item": "minerale_ambra", "min": 2, "max": 4, "chance": 0.6},
		{"item": "cristallo_linfa", "min": 1, "max": 3, "chance": 0.5},
	],
	"serpe": [{"item": "scaglia_linfa", "min": 1, "max": 3, "chance": 1.0}],
	"campanula": [{"item": "polline_luminoso", "min": 1, "max": 3, "chance": 1.0}],
	"guizzalinfa": [
		{"item": "occhio_guizzo", "min": 1, "max": 1, "chance": 0.5},
		{"item": "cristallo_linfa", "min": 1, "max": 2, "chance": 0.5},
	],
	"mietivuoto": [
		{"item": "lama_vuoto", "min": 1, "max": 1, "chance": 0.5},
		{"item": "scheggia_vuoto", "min": 1, "max": 3, "chance": 1.0},
	],
	"tessivuoto": [{"item": "seta_vuoto", "min": 2, "max": 3, "chance": 1.0}],
	# voce 40
	"cervo_brina": [
		{"item": "vello_brina", "min": 1, "max": 3, "chance": 1.0},
		{"item": "palco_brina", "min": 1, "max": 1, "chance": 0.25},
	],
	"gufo_gelo": [{"item": "piuma_gelo", "min": 1, "max": 2, "chance": 1.0}],
	"salamandra": [
		{"item": "squama_brace", "min": 1, "max": 2, "chance": 1.0},
		{"item": "fungo_brace", "min": 1, "max": 1, "chance": 0.2},
	],
	"fatuo_cenere": [{"item": "cenere_viva", "min": 1, "max": 2, "chance": 0.9}],
	"sciame": [{"item": "scheggia_vuoto", "min": 1, "max": 1, "chance": 0.8}],
	# voce 27: i Custodi degli strati (sempre il loro materiale regale e un dono)
	# voce 56
	"pecora_muschio": [{"item": "lana_muschio", "min": 1, "max": 3, "chance": 1.0}, {"item": "boccone", "min": 1, "max": 1, "chance": 0.6}],
	"cornoradice": [{"item": "corno_radice", "min": 1, "max": 2, "chance": 1.0}, {"item": "boccone", "min": 1, "max": 2, "chance": 0.8}],
	"lepre_linfa": [{"item": "pelo_lepre", "min": 1, "max": 2, "chance": 1.0}, {"item": "boccone", "min": 1, "max": 1, "chance": 0.5}],
	"bruco_lanterna": [{"item": "seta_bruco", "min": 1, "max": 2, "chance": 1.0}],
	"ape_lume": [{"item": "miele_lume", "min": 1, "max": 1, "chance": 0.7}],
	"formica_resina": [{"item": "resina_dolce", "min": 1, "max": 1, "chance": 0.6}],
	"pipistrello": [{"item": "ala_pipistrello", "min": 1, "max": 1, "chance": 0.8}],
	"libellula": [{"item": "ala_libellula", "min": 1, "max": 1, "chance": 0.8}],
	"volpe": [{"item": "pelliccia_volpe", "min": 1, "max": 2, "chance": 1.0}],
	"lince": [{"item": "zanna_lince", "min": 1, "max": 2, "chance": 1.0}],
	"grande_cervo": [
		{"item": "manto_grande_cervo", "min": 1, "max": 1, "chance": 1.0},
		{"item": "vello_brina", "min": 12, "max": 20, "chance": 1.0},
		{"item": "palco_brina", "min": 4, "max": 8, "chance": 1.0},
		{"item": "cuore_bocciolo", "min": 1, "max": 1, "chance": 1.0},
	],
	"madre_salamandre": [
		{"item": "cuore_salamandre", "min": 1, "max": 1, "chance": 1.0},
		{"item": "squama_brace", "min": 12, "max": 20, "chance": 1.0},
		{"item": "cenere_viva", "min": 15, "max": 25, "chance": 1.0},
		{"item": "stilla_perenne", "min": 1, "max": 1, "chance": 1.0},
	],
	"madre_grumi": [
		{"item": "gelatina_regale", "min": 5, "max": 7, "chance": 1.0},
		{"item": "gelatina", "min": 15, "max": 25, "chance": 1.0},
		{"item": "cuore_bocciolo", "min": 1, "max": 1, "chance": 1.0},
		{"item": "nucleo_muschio", "min": 1, "max": 1, "chance": 0.5},
	],
	"tessitrice": [
		{"item": "seta_regale", "min": 5, "max": 7, "chance": 1.0},
		{"item": "seta_radice", "min": 15, "max": 25, "chance": 1.0},
		{"item": "cuore_bocciolo", "min": 1, "max": 1, "chance": 1.0},
		{"item": "filiera_radice", "min": 1, "max": 1, "chance": 0.5},
	],
	"serpe_madre": [
		{"item": "scaglia_madre", "min": 5, "max": 7, "chance": 1.0},
		{"item": "scaglia_linfa", "min": 8, "max": 14, "chance": 1.0},
		{"item": "stilla_perenne", "min": 1, "max": 1, "chance": 1.0},
		{"item": "dente_serpe", "min": 1, "max": 1, "chance": 0.5},
	],
	"mietitore": [
		{"item": "nucleo_cavo", "min": 5, "max": 7, "chance": 1.0},
		{"item": "scheggia_vuoto", "min": 10, "max": 20, "chance": 1.0},
		{"item": "stilla_perenne", "min": 1, "max": 1, "chance": 1.0},
		{"item": "falce_maestra", "min": 1, "max": 1, "chance": 0.5},
	],
}


## Il bottino di uno scrigno: la tabella tirata `rolls` volte, mai vuoto (si ritira finché esce qualcosa).
static func roll_chest(table: String, rng: RandomNumberGenerator, rolls := 2) -> Dictionary:
	var out := {}
	for k in 12:
		for r in rolls:
			var got := roll(table, rng)
			for id in got:
				out[id] = int(out.get(id, 0)) + int(got[id])
		if not out.is_empty():
			break
	return out


## Tira il bottino di una tabella: {oggetto: quantità}.
static func roll(table: String, rng: RandomNumberGenerator) -> Dictionary:
	var out := {}
	for e in TABLES.get(table, SeasonsData.LOOT.get(table, [])):       # voce 66: il bottino delle creature delle stagioni
		if rng.randf() <= float(e["chance"]):
			out[e["item"]] = int(out.get(e["item"], 0)) + rng.randi_range(int(e["min"]), int(e["max"]))
	return out
