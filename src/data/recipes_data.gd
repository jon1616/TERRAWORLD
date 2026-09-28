class_name RecipesData
extends RefCounted
## Ricette di fabbricazione: cosa si ottiene (out, qty), con cosa (in: {oggetto: quantità}) e dove (station: id di
## `StationsData`, "" = a mano, ovunque). Le ricette delle famiglie di metallo sono generate in `all()`.

const RECIPES := [
	{"out": "ceppo", "qty": 1, "in": {"legno": 10}, "station": ""},
	{"out": "torcia", "qty": 3, "in": {"legno": 1, "gelatina": 1}, "station": ""},
	{"out": "torcia", "qty": 4, "in": {"legno": 1, "polvere_brace": 1}, "station": ""},
	{"out": "corazza_scaglie", "qty": 1, "in": {"scaglia_ardesia": 12, "legno": 4}, "station": "ceppo"},
	{"out": "passerella", "qty": 2, "in": {"legno": 1}, "station": "ceppo"},
	{"out": "cesta", "qty": 1, "in": {"legno": 8}, "station": "ceppo"},
	{"out": "spada_radice", "qty": 1, "in": {"legno": 7}, "station": "ceppo"},
	{"out": "arco_radice", "qty": 1, "in": {"legno": 10}, "station": "ceppo"},
	{"out": "dardo", "qty": 25, "in": {"legno": 1, "ardesia": 1}, "station": "ceppo"},
	{"out": "baccello_ardente", "qty": 1, "in": {"ardesia": 20, "legno": 4, "torcia": 3}, "station": "ceppo"},
	{"out": "lingotto_radicite", "qty": 1, "in": {"minerale_radicite": 3}, "station": "baccello_ardente"},
	{"out": "lingotto_legnoferro", "qty": 1, "in": {"minerale_legnoferro": 3}, "station": "baccello_ardente"},
	{"out": "lingotto_ambra", "qty": 1, "in": {"minerale_ambra": 4}, "station": "baccello_ardente"},
	{"out": "lingotto_pallidite", "qty": 1, "in": {"minerale_pallidite": 3}, "station": "baccello_ardente"},
	{"out": "lingotto_tizzonite", "qty": 1, "in": {"minerale_tizzonite": 4}, "station": "baccello_ardente"},
	# voce 24: le gemme
	{"out": "anello_brillaluce", "qty": 1, "in": {"brillaluce": 5, "lingotto_pallidite": 3}, "station": "mola"},
	{"out": "anello_sanguinella", "qty": 1, "in": {"sanguinella": 5, "lingotto_radicite": 3}, "station": "mola"},
	{"out": "anello_lagunite", "qty": 1, "in": {"lagunite": 5, "lingotto_ambra": 3}, "station": "mola"},
	{"out": "anello_nottilite", "qty": 1, "in": {"nottilite": 5, "lingotto_tizzonite": 3}, "station": "mola"},
	{"out": "bastone_sanguinella", "qty": 1, "in": {"sanguinella": 8, "legno": 8}, "station": "mola"},
	{"out": "bastone_lagunite", "qty": 1, "in": {"lagunite": 8, "lingotto_ambra": 4}, "station": "mola"},
	{"out": "lanterna_brillaluce", "qty": 1, "in": {"brillaluce": 6, "lingotto_pallidite": 4}, "station": "mola"},
	{"out": "lama_nottilite", "qty": 1, "in": {"nottilite": 10, "lingotto_tizzonite": 6}, "station": "mola"},
	{"out": "maglio", "qty": 1, "in": {"lingotto_legnoferro": 5}, "station": "ceppo"},
	{"out": "pozione_rugiada", "qty": 1, "in": {"gelatina": 2, "fungo_brace": 1}, "station": "ceppo"},
	# il primo anello (voce 8)
	{"out": "pozione_bagliore", "qty": 1, "in": {"fungo_luminoso": 2, "gelatina": 1, "sacca_spore": 1}, "station": "alambicco"},
	{"out": "seme_muschio", "qty": 5, "in": {"seme_lanterna": 1, "gelatina": 2}, "station": "ceppo"},
	{"out": "pozione_vigore", "qty": 1, "in": {"cenere_avvizzita": 3, "fungo_brace": 1, "gelatina": 1}, "station": "alambicco"},
	{"out": "pozione_scorza", "qty": 1, "in": {"scaglia_ardesia": 3, "fungo_brace": 1}, "station": "alambicco"},
	# voce 21: Linfa e bastoni
	{"out": "pozione_linfa", "qty": 2, "in": {"fungo_luminoso": 1, "gelatina": 2}, "station": "ceppo"},
	{"out": "bastone_brace", "qty": 1, "in": {"legno": 8, "polvere_brace": 10, "fungo_brace": 3}, "station": "ceppo"},
	{"out": "bastone_spore", "qty": 1, "in": {"lingotto_legnoferro": 6, "sacca_spore": 8, "legno": 4}, "station": "maglio"},
	{"out": "bastone_cristallo", "qty": 1, "in": {"lingotto_ambra": 6, "cristallo_linfa": 10}, "station": "maglio"},
	{"out": "bastone_vuoto", "qty": 1, "in": {"lingotto_linfa": 6, "scheggia_vuoto": 12}, "station": "maglio"},
	{"out": "dardo_vuoto", "qty": 20, "in": {"scheggia_vuoto": 1, "legno": 1}, "station": "ceppo"},
	{"out": "lanterna_linfa", "qty": 1, "in": {"cristallo_linfa": 5, "lingotto_ambra": 2}, "station": "maglio"},
	{"out": "rugiada_linfa", "qty": 1, "in": {"cristallo_linfa": 2, "fungo_luminoso": 1, "pozione_rugiada": 1}, "station": "alambicco"},
	# voce 36: abitanti e commercio
	{"out": "focolare", "qty": 1, "in": {"ardesia": 12, "legno": 6, "torcia": 2}, "station": "ceppo"},
	# voce 35: costruire
	{"out": "assi_lanterna", "qty": 2, "in": {"legno": 1}, "station": "ceppo"},
	{"out": "mattoni_ardesia", "qty": 2, "in": {"ardesia": 2}, "station": "baccello_ardente"},
	{"out": "vetro_resina", "qty": 2, "in": {"gelatina": 1, "ardesia": 2}, "station": "baccello_ardente"},
	{"out": "parete_assi", "qty": 4, "in": {"assi_lanterna": 1}, "station": "ceppo"},
	{"out": "parete_mattoni", "qty": 4, "in": {"mattoni_ardesia": 1}, "station": "ceppo"},
	{"out": "parete_sem", "qty": 4, "in": {"pietra_seminatori": 1}, "station": "ceppo"},
	{"out": "martello_radice", "qty": 1, "in": {"legno": 8, "ardesia": 4}, "station": "ceppo"},
	{"out": "porta_lanterna", "qty": 1, "in": {"legno": 6}, "station": "ceppo"},
	{"out": "lampada_lanterna", "qty": 1, "in": {"legno": 3, "torcia": 1}, "station": "ceppo"},
	{"out": "tavolo_radice", "qty": 1, "in": {"legno": 8}, "station": "ceppo"},
	{"out": "sedia_radice", "qty": 1, "in": {"legno": 4}, "station": "ceppo"},
	{"out": "letto_foglie", "qty": 1, "in": {"legno": 12, "seta_radice": 3}, "station": "ceppo"},
	# voce 34: eventi del mondo
	{"out": "pozione_linfa", "qty": 3, "in": {"stellina": 1, "gelatina": 1}, "station": "alambicco"},
	{"out": "pendente_stelle", "qty": 1, "in": {"stellina": 8, "lingotto_pallidite": 3}, "station": "mola"},
	{"out": "bastone_stellare_caduto", "qty": 1, "in": {"stellina": 12, "lingotto_linfa": 6}, "station": "maglio"},
	# voce 33: il giardino
	{"out": "annaffiatoio", "qty": 1, "in": {"legno": 8, "gelatina": 4}, "station": "ceppo"},
	{"out": "paiolo", "qty": 1, "in": {"ardesia": 10, "legno": 6, "lingotto_radicite": 2}, "station": "ceppo"},
	{"out": "pozione_rugiada", "qty": 1, "in": {"foglia_rugiada": 2, "gelatina": 1}, "station": "ceppo"},
	{"out": "zuppa_funghi", "qty": 1, "in": {"fungo_brace": 2, "fungo_luminoso": 1}, "station": "paiolo"},
	{"out": "pane_tubero", "qty": 1, "in": {"tubero_linfa": 2, "foglia_rugiada": 1}, "station": "paiolo"},
	{"out": "insalata_lume", "qty": 1, "in": {"foglia_rugiada": 2, "petali_lume": 2}, "station": "paiolo"},
	{"out": "stufato_regale", "qty": 1, "in": {"tubero_linfa": 2, "fungo_brace": 2, "gelatina_regale": 1}, "station": "paiolo"},
	{"out": "pozione_notte", "qty": 1, "in": {"petali_lume": 2, "fungo_luminoso": 1}, "station": "alambicco"},
	{"out": "pozione_radice", "qty": 1, "in": {"tubero_linfa": 2, "foglia_rugiada": 2, "gelatina": 1}, "station": "alambicco"},
	{"out": "pozione_linfa", "qty": 2, "in": {"tubero_linfa": 1, "petali_lume": 1}, "station": "alambicco"},
	# voce 32: esplosivi e armi da lancio
	{"out": "baccello_esplosivo", "qty": 3, "in": {"polvere_brace": 3, "gelatina": 2, "ardesia": 2}, "station": "baccello_ardente"},
	{"out": "baccello_tonante", "qty": 2, "in": {"baccello_esplosivo": 2, "lingotto_tizzonite": 1, "polvere_brace": 4}, "station": "baccello_ardente"},
	{"out": "seme_ricurvo", "qty": 1, "in": {"legno": 10, "seme_lanterna": 1}, "station": "ceppo"},
	{"out": "seme_ricurvo_ambra", "qty": 1, "in": {"lingotto_ambra": 6, "legno": 5}, "station": "maglio"},
	{"out": "seme_ricurvo_vuoto", "qty": 1, "in": {"scheggia_vuoto": 10, "lingotto_linfa": 5}, "station": "maglio"},
	{"out": "giavellotto_aculeo", "qty": 10, "in": {"aculeo": 2, "legno": 1}, "station": "ceppo"},
	{"out": "giavellotto_cristallo", "qty": 10, "in": {"cristallo_linfa": 1, "legno": 1}, "station": "maglio"},
	# voce 31: muoversi meglio
	# voce 39: dare una specie al Seme di mondo
	{"out": "banco_innesti", "qty": 1, "in": {"lingotto_legnoferro": 6, "linfa_antica": 2, "vetro_resina": 4, "seme_lanterna": 5}, "station": "maglio"},
	{"out": "provetta", "qty": 3, "in": {"vetro_resina": 1, "gelatina": 2}, "station": "alambicco"},
	{"out": "bacheca", "qty": 1, "in": {"legno": 20, "seta_radice": 2}, "station": "ceppo"},
	{"out": "aiuola", "qty": 1, "in": {"humus": 25, "legno": 12, "seme_lanterna": 3}, "station": "ceppo"},
	# voce 38: viaggio rapido
	{"out": "radice_viandante", "qty": 1, "in": {"legno": 20, "gelatina": 6, "lingotto_radicite": 3}, "station": "ceppo"},
	# voce 37: compagni ed evocatori
	{"out": "vasetto_lucciolina", "qty": 1, "in": {"polvere_lucciola": 10, "vetro_resina": 3}, "station": "ceppo"},
	{"out": "gelatina_viva", "qty": 1, "in": {"gelatina_regale": 2, "gelatina": 20}, "station": "alambicco"},
	{"out": "goccia_spiritello", "qty": 1, "in": {"occhio_guizzo": 2, "cristallo_linfa": 8}, "station": "alambicco"},
	{"out": "bastone_grumi_amici", "qty": 1, "in": {"gelatina": 25, "legno": 10, "lingotto_radicite": 4}, "station": "ceppo"},
	{"out": "bastone_falena_amica", "qty": 1, "in": {"polvere_brace": 14, "seta_radice": 6, "lingotto_legnoferro": 6}, "station": "telaio"},
	{"out": "bastone_vagavuoto", "qty": 1, "in": {"scheggia_vuoto": 24, "seta_vuoto": 6, "cristallo_linfa": 6}, "station": "maglio"},
	{"out": "fischietto_branco", "qty": 1, "in": {"gelatina_regale": 3, "seta_regale": 3, "lingotto_legnoferro": 4}, "station": "maglio"},
	{"out": "radice_uncino", "qty": 1, "in": {"legno": 12, "seta_radice": 6, "lingotto_radicite": 4}, "station": "ceppo"},
	{"out": "uncino_cristallo", "qty": 1, "in": {"cristallo_linfa": 8, "lingotto_ambra": 5, "seta_radice": 6}, "station": "maglio"},
	{"out": "baccello_vento", "qty": 1, "in": {"penna_corteccia": 10, "polvere_lucciola": 8, "gelatina": 5}, "station": "telaio"},
	{"out": "seme_tempesta", "qty": 1, "in": {"baccello_vento": 1, "membrana_ardesia": 10, "lagunite": 4}, "station": "mola"},
	{"out": "artigli_corteccia", "qty": 1, "in": {"artiglio_talpone": 3, "legno": 10, "lingotto_legnoferro": 3}, "station": "maglio"},
	# voce 25: i banchi nuovi e ciò che vi si fa
	{"out": "alambicco", "qty": 1, "in": {"ardesia": 12, "gelatina": 8, "legno": 6}, "station": "ceppo"},
	{"out": "telaio", "qty": 1, "in": {"legno": 20, "seta_radice": 10}, "station": "ceppo"},
	{"out": "mola", "qty": 1, "in": {"ardesia": 20, "lingotto_radicite": 6, "legno": 10}, "station": "ceppo"},
	{"out": "pozione_passo", "qty": 1, "in": {"lamella_fungo": 1, "penna_corteccia": 2, "gelatina": 1}, "station": "alambicco"},
	{"out": "pozione_minatore", "qty": 1, "in": {"brillaluce": 1, "fungo_brace": 1, "gelatina": 1}, "station": "alambicco"},
	{"out": "pozione_spine", "qty": 1, "in": {"aculeo": 4, "gelatina": 1}, "station": "alambicco"},
	{"out": "pozione_esca", "qty": 1, "in": {"sanguinella": 1, "polline_luminoso": 1, "lamella_fungo": 2}, "station": "alambicco"},
	{"out": "pozione_fortuna", "qty": 1, "in": {"nottilite": 1, "polvere_lucciola": 3, "gelatina": 1}, "station": "alambicco"},
	{"out": "cappuccio_seta", "qty": 1, "in": {"seta_radice": 8, "legno": 2}, "station": "telaio"},
	{"out": "veste_seta", "qty": 1, "in": {"seta_radice": 14, "legno": 2}, "station": "telaio"},
	{"out": "calzari_seta", "qty": 1, "in": {"seta_radice": 10, "legno": 2}, "station": "telaio"},
	{"out": "cappuccio_vuoto", "qty": 1, "in": {"seta_vuoto": 8, "scheggia_vuoto": 4}, "station": "telaio"},
	{"out": "veste_vuoto", "qty": 1, "in": {"seta_vuoto": 14, "scheggia_vuoto": 6}, "station": "telaio"},
	{"out": "calzari_vuoto", "qty": 1, "in": {"seta_vuoto": 10, "scheggia_vuoto": 4}, "station": "telaio"},
	# voce 22: ciò che si fa con i materiali delle creature nuove
	{"out": "dardo_piumato", "qty": 25, "in": {"penna_corteccia": 1, "legno": 1}, "station": "ceppo"},
	{"out": "dardo_aculeo", "qty": 25, "in": {"aculeo": 2, "legno": 1}, "station": "ceppo"},
	{"out": "mantello_penne", "qty": 1, "in": {"penna_corteccia": 16, "seta_radice": 8}, "station": "telaio"},
	{"out": "collana_aculei", "qty": 1, "in": {"aculeo": 20, "seta_radice": 4}, "station": "telaio"},
	{"out": "torcia", "qty": 5, "in": {"legno": 1, "polvere_lucciola": 1}, "station": ""},
	{"out": "anello_lucciola", "qty": 1, "in": {"polvere_lucciola": 12, "lingotto_radicite": 3}, "station": "maglio"},
	{"out": "benda_seta", "qty": 2, "in": {"seta_radice": 3, "gelatina": 1}, "station": "telaio"},
	{"out": "guanti_talpone", "qty": 1, "in": {"artiglio_talpone": 4, "lingotto_legnoferro": 4}, "station": "maglio"},
	{"out": "pozione_rigoglio", "qty": 1, "in": {"lamella_fungo": 2, "gelatina": 1, "fungo_luminoso": 1}, "station": "alambicco"},
	{"out": "ali_membrana", "qty": 1, "in": {"membrana_ardesia": 14, "lingotto_legnoferro": 3}, "station": "maglio"},
	{"out": "scudo_guscio", "qty": 1, "in": {"guscio_cristallo": 10, "lingotto_ambra": 4}, "station": "maglio"},
	{"out": "anello_geode", "qty": 1, "in": {"cuore_geode": 3, "lingotto_ambra": 2}, "station": "mola"},
	{"out": "stivali_serpe", "qty": 1, "in": {"scaglia_linfa": 12, "lingotto_ambra": 4}, "station": "maglio"},
	{"out": "pozione_linfa", "qty": 3, "in": {"polline_luminoso": 2, "gelatina": 1}, "station": "ceppo"},
	{"out": "pozione_bagliore", "qty": 1, "in": {"polline_luminoso": 2, "gelatina": 1, "fungo_luminoso": 1}, "station": "alambicco"},
	{"out": "specchio_guizzo", "qty": 1, "in": {"occhio_guizzo": 4, "cristallo_linfa": 6, "lingotto_ambra": 2}, "station": "maglio"},
	{"out": "falce_vuoto", "qty": 1, "in": {"lama_vuoto": 6, "lingotto_linfa": 6}, "station": "maglio"},
	{"out": "velo_ombra", "qty": 1, "in": {"seta_vuoto": 12, "scheggia_vuoto": 6}, "station": "telaio"},
	# il grado della Linfa si apre solo dopo il Guardiano: sconfitto o curato, due strade per lo stesso lingotto
	{"out": "lingotto_linfa", "qty": 2, "in": {"cristallo_linfa": 4, "frammento_nodo": 1}, "station": "baccello_ardente"},
	{"out": "lingotto_linfa", "qty": 2, "in": {"cristallo_linfa": 4, "linfa_guardiano": 1}, "station": "baccello_ardente"},
	# i gradi dei mondi oltre i portali (voce 19): la Regina delle Spore e il Colosso d'Ardesia
	{"out": "lingotto_vuoto", "qty": 2, "in": {"vuotite": 6, "velo_spora": 1}, "station": "baccello_ardente"},
	{"out": "lingotto_vuoto", "qty": 2, "in": {"vuotite": 6, "polline_regina": 1}, "station": "baccello_ardente"},
	{"out": "lingotto_stellare", "qty": 2, "in": {"scheggia_vuoto": 4, "cristallo_linfa": 2, "nucleo_colosso": 1}, "station": "baccello_ardente"},
	{"out": "lingotto_stellare", "qty": 2, "in": {"scheggia_vuoto": 4, "cristallo_linfa": 2, "pietra_battente": 1}, "station": "baccello_ardente"},
]

static var _all: Array = []


static func all() -> Array:
	if not _all.is_empty():
		return _all
	var out := RECIPES.duplicate(true)
	out.append_array(TrophyItemsData.RECIPES.duplicate(true))
	out.append_array(BiomesData.pack_list("recipes").duplicate(true))   # voce 92: le ricette dei biomi
	out.append_array(KeeperItemsData.RECIPES.duplicate(true))
	out.append_array(RelicsData.RECIPES.duplicate(true))
	out.append_array(FaunaItemsData.RECIPES.duplicate(true))
	out.append_array(HerdData.RECIPES.duplicate(true))     # voce 59
	out.append_array(SeasonsData.RECIPES.duplicate(true))  # voce 66
	out.append_array(NeroData.RECIPES.duplicate(true))     # voce 72
	out.append_array(LiquidsData.RECIPES.duplicate(true))  # voce 73
	out.append_array(FishingData.RECIPES.duplicate(true))  # voce 121
	out.append_array(FishingData.fillet_recipes())         # voce 123: pulire i pesci
	out.append_array(DashData.RECIPES.duplicate(true))     # voce 127: la schivata
	out.append_array(BuildData.recipes())                  # voce 128: i costrutti
	out.append_array(BuildData.STATION_RECIPES.duplicate(true))   # voce 139: il Banco dello scalpellino
	out.append_array(BuilderData.recipes())                # voce 140: tinture e Tavola del progetto
	out.append_array(WeatherData.RECIPES.duplicate(true))  # voce 75
	out.append_array(WorldTimeData.RECIPES.duplicate(true))  # voce 78
	out.append_array(GuardianGenData.RECIPES.duplicate(true))  # voce 80
	out.append_array(ChallengesData.RECIPES.duplicate(true))  # voce 82
	out.append_array(ChestsData.recipes())                  # 28 set 2026: i gradi delle casse
	out.append_array(SummonData.RECIPES.duplicate(true))    # voce 84
	out.append_array(JewelsData.recipes())                  # voce 86
	out.append_array(ZonesData.recipes())                   # voce 87
	out.append_array(TrapsData.recipes())                   # voce 88
	out.append_array(FarmData.recipes())                    # voce 89
	out.append_array(FlightData.recipes())                  # voce 90
	out.append_array(SecretsData.RECIPES.duplicate(true))   # voce 95
	for m in MaterialsData.all():
		for f in FormsData.FORMS:
			out.append(FormsData.recipe(f, m))
	out.append_array(MaterialsData.recipes())
	_all = out
	return _all


## Ricette che producono un oggetto.
static func making(id: String) -> Array:
	return all().filter(func(r: Dictionary) -> bool: return r["out"] == id)


## Ricette che usano un oggetto.
static func using(id: String) -> Array:
	return all().filter(func(r: Dictionary) -> bool: return (r["in"] as Dictionary).has(id))
