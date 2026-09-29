class_name StationsData
extends RefCounted
## Stazioni di fabbricazione: si piazzano nel mondo e permettono le ricette che le nominano quando il giocatore è vicino.
## size = tessere occupate (larghezza, altezza); item = l'oggetto che la piazza.
##   ceppo             il Ceppo del Giardiniere: si lavora il legno (la prima stazione)
##   baccello_ardente  un baccello di pietra che cova la brace: fonde i minerali in lingotti
##   maglio            il Maglio dei Seminatori: forgia attrezzi e armature di metallo
##   cuore_mondo       il Cuore del mondo, malato: nasce nel Fondo con il mondo, non si fabbrica né si sposta
##   cuore_vivo        il Cuore dopo il Guardiano (sconfitto o curato): brilla e dona un Seme di mondo
##   portale           il portale di radici che cresce da un Seme di mondo
##   cesta             Cesta di radici: tiene oggetti (`slots`)
##   scrigno           Scrigno dei Seminatori: nelle rovine, pieno di bottino; vuoto si porta via
##   alambicco         Alambicco di Linfa (voce 25): le pozioni
##   telaio            Telaio di foglie: vesti di seta, mantelli, bende
##   mola              Mola del gemmaio: anelli, bastoni e lame di gemma
## fixed = non si riprende col piccone; light_color = colore della luce (altrimenti brace); slots = contenitore

## Il 26 set 2026 i banchi da lavoro, il tavolo e la sedia sono stati rimpiccioliti (erano alti quasi quanto il
## Germogliato): `OLD_SIZE` sono le misure di prima, per spostare quelli già piazzati nei mondi salvati (`WorldSave`).
const OLD_SIZE := {"ceppo": [3, 2], "baccello_ardente": [3, 2], "maglio": [2, 2], "telaio": [3, 2], "mola": [2, 2],
	"paiolo": [2, 2], "tavolo": [3, 2], "sedia": [1, 2], "banco_innesti": [3, 2], "incubatrice": [2, 2],
	"alambicco": [2, 2], "cesta": [2, 2], "scrigno": [2, 2], "reliquiario": [2, 2]}

## Il 28 set 2026 (l'utente, giocando: «il banco da lavoro e le casse sono troppo piccoli, circa 2×2») banchi e casse
## sono tornati alti due tessere: `V2_SIZE` sono le misure del 26 set, per alzare quelli dei mondi salvati (`WorldSave`).
const V2_SIZE := {"ceppo": [2, 1], "maglio": [2, 1], "alambicco": [2, 1], "mola": [2, 1], "paiolo": [2, 1],
	"cesta": [2, 1], "cassa_legnoferro": [2, 1], "forziere_ambra": [2, 1], "scrigno_linfa": [2, 1],
	"arca_vuoto": [2, 1], "arca_stellare": [2, 1], "scrigno_antico": [2, 1], "arca_seminatori": [2, 1],
	"scrigno": [2, 1], "reliquiario": [2, 1], "banco_innesti": [3, 1]}

## Voce 141: le stazioni scritte qui più gli arredi in serie (`FurnitureData`).
static var STATIONS: Dictionary = _merged()


static func _merged() -> Dictionary:
	var out := _STATIONS.duplicate()
	out.merge(FurnitureData.stations())
	out.merge(MachinesData.stations())                  # Roadmap 19: le macchine della rete
	out.merge(LostGardensData.stations())               # Roadmap 21: gli Alberi dei Giardini perduti
	return out


## Voce 141: il ruolo di una stazione: per un arredo della serie la sua forma («letto», «tavolo»…), altrimenti l'id.
static func role(id: String) -> String:
	return String(STATIONS.get(id, {}).get("arredo", id))


const _STATIONS := {
	"ceppo": {"name": "Ceppo del Giardiniere", "size": [2, 2], "item": "ceppo"},
	"baccello_ardente": {"name": "Baccello ardente", "size": [2, 2], "item": "baccello_ardente", "light": true},
	"maglio": {"name": "Maglio dei Seminatori", "size": [2, 2], "item": "maglio"},
	"alambicco": {"name": "Alambicco di Linfa", "size": [2, 2], "item": "alambicco", "light": true,
		"light_color": Color(0.3, 0.9, 0.9)},
	"telaio": {"name": "Telaio di foglie", "size": [2, 2], "item": "telaio"},
	"scalpellino": {"name": "Banco dello scalpellino", "size": [2, 2], "item": "scalpellino"},   # voce 139
	"mola": {"name": "Mola del gemmaio", "size": [2, 2], "item": "mola"},
	"paiolo": {"name": "Paiolo di radice", "size": [2, 2], "item": "paiolo", "light": true},
	# voce 35: porte e arredi (la porta chiusa riempie le sue celle di tessere `PORTA`, vedi `Masonry`)
	"porta": {"name": "Porta", "size": [1, 2], "item": "porta_lanterna"},
	"porta_aperta": {"name": "Porta aperta", "size": [1, 2], "item": "porta_lanterna"},
	"lampada": {"name": "Lampada di lanterna", "size": [1, 2], "item": "lampada_lanterna", "light": true,
		"light_color": Color(1.5, 1.1, 0.6)},
	"tavolo": {"name": "Tavolo di radice", "size": [3, 1], "item": "tavolo_radice"},
	"sedia": {"name": "Sedia di radice", "size": [1, 1], "item": "sedia_radice"},
	"letto": {"name": "Letto di foglie", "size": [3, 1], "item": "letto_foglie"},
	"radice_viandante": {"name": "Radice viandante", "size": [2, 3], "item": "radice_viandante", "light": true,
		"light_color": Color(0.6, 1.4, 1.3)},
	"focolare": {"name": "Focolare del Giardino", "size": [2, 1], "item": "focolare", "light": true,
		"light_color": Color(1.8, 1.0, 0.5)},
	# voce 27: l'Altare dei Seminatori (richiama i Custodi) e i bozzoli delle tane dei Custodi
	# voce 87: totem, stendardi e altari (tipo × grado; gli effetti in `ZonesData`, le regole in `Zones`)
	"fonte_acqua": {"name": "Fonte di muschio", "size": [1, 2], "item": "fonte_acqua", "fonte": 0},     # voce 119
	"fonte_linfa": {"name": "Fonte di Linfa", "size": [1, 2], "item": "fonte_linfa", "fonte": 1, "light": true,
		"light_color": Color(0.35, 1.3, 1.1)},
	"fonte_brace": {"name": "Bocca di brace", "size": [1, 2], "item": "fonte_brace", "fonte": 2, "light": true,
		"light_color": Color(1.6, 0.7, 0.25)},
	"totem_germoglio_1": {"name": "Totem del germoglio", "size": [1, 2], "item": "totem_germoglio_1"},
	"totem_germoglio_2": {"name": "Totem del germoglio di legnoferro", "size": [1, 2], "item": "totem_germoglio_2"},
	"totem_germoglio_3": {"name": "Totem del germoglio d'ambra", "size": [1, 2], "item": "totem_germoglio_3"},
	"totem_riposo_1": {"name": "Stendardo del riposo", "size": [1, 2], "item": "totem_riposo_1"},
	"totem_riposo_2": {"name": "Stendardo del riposo di legnoferro", "size": [1, 2], "item": "totem_riposo_2"},
	"totem_riposo_3": {"name": "Stendardo del riposo d'ambra", "size": [1, 2], "item": "totem_riposo_3"},
	"totem_fortuna_1": {"name": "Altarino della fortuna", "size": [1, 2], "item": "totem_fortuna_1"},
	"totem_fortuna_2": {"name": "Altarino della fortuna di legnoferro", "size": [1, 2], "item": "totem_fortuna_2"},
	"totem_fortuna_3": {"name": "Altarino della fortuna d'ambra", "size": [1, 2], "item": "totem_fortuna_3"},
	"totem_luce_1": {"name": "Lanterna-totem", "size": [1, 2], "item": "totem_luce_1", "light": true, "light_color": Color(1.10, 0.99, 0.72)},
	"totem_luce_2": {"name": "Lanterna-totem di legnoferro", "size": [1, 2], "item": "totem_luce_2", "light": true, "light_color": Color(1.35, 1.22, 0.88)},
	"totem_luce_3": {"name": "Lanterna-totem d'ambra", "size": [1, 2], "item": "totem_luce_3", "light": true, "light_color": Color(1.60, 1.44, 1.04)},
	"totem_quiete_1": {"name": "Totem della quiete", "size": [1, 2], "item": "totem_quiete_1"},
	"totem_quiete_2": {"name": "Totem della quiete di legnoferro", "size": [1, 2], "item": "totem_quiete_2"},
	"totem_quiete_3": {"name": "Totem della quiete d'ambra", "size": [1, 2], "item": "totem_quiete_3"},
	"totem_guardia_1": {"name": "Stendardo di guardia", "size": [1, 2], "item": "totem_guardia_1"},
	"totem_guardia_2": {"name": "Stendardo di guardia di legnoferro", "size": [1, 2], "item": "totem_guardia_2"},
	"totem_guardia_3": {"name": "Stendardo di guardia d'ambra", "size": [1, 2], "item": "totem_guardia_3"},
	"totem_stirpi_1": {"name": "Altare delle stirpi", "size": [1, 2], "item": "totem_stirpi_1"},
	"totem_stirpi_2": {"name": "Altare delle stirpi di legnoferro", "size": [1, 2], "item": "totem_stirpi_2"},
	"totem_stirpi_3": {"name": "Altare delle stirpi d'ambra", "size": [1, 2], "item": "totem_stirpi_3"},
	"totem_saccheggio_1": {"name": "Stendardo del saccheggio", "size": [1, 2], "item": "totem_saccheggio_1"},
	"totem_saccheggio_2": {"name": "Stendardo del saccheggio di legnoferro", "size": [1, 2], "item": "totem_saccheggio_2"},
	"totem_saccheggio_3": {"name": "Stendardo del saccheggio d'ambra", "size": [1, 2], "item": "totem_saccheggio_3"},
	"totem_purezza_1": {"name": "Totem della radice pura", "size": [1, 2], "item": "totem_purezza_1"},
	"totem_purezza_2": {"name": "Totem della radice pura di legnoferro", "size": [1, 2], "item": "totem_purezza_2"},
	"totem_purezza_3": {"name": "Totem della radice pura d'ambra", "size": [1, 2], "item": "totem_purezza_3"},
	"totem_antico_germoglio": {"name": "Totem antico del germoglio", "size": [1, 2], "item": "totem_antico_germoglio", "light": true, "light_color": Color(0.5, 0.45, 0.2)},
	"totem_antico_quiete": {"name": "Totem antico della quiete", "size": [1, 2], "item": "totem_antico_quiete", "light": true, "light_color": Color(0.5, 0.45, 0.2)},
	"totem_antico_stirpi": {"name": "Altare antico delle stirpi", "size": [1, 2], "item": "totem_antico_stirpi", "light": true, "light_color": Color(0.5, 0.45, 0.2)},
	"leva_trappole": {"name": "Leva delle trappole (giù: ferme)", "size": [1, 1], "item": "leva_trappole"},
	"leva_trappole_su": {"name": "Leva delle trappole (su: armate)", "size": [1, 1], "item": "leva_trappole"},
	# voce 89: le farm (esche, tramogge, Radice-ancora, nastri; dati in `FarmData`, regole in `Farms`)
	"esca": {"name": "Esca di radice", "size": [1, 1], "item": "esca", "slots": 1, "light": true, "light_color": Color(0.5, 0.35, 0.2)},
	"esca_legnoferro": {"name": "Esca di legnoferro", "size": [1, 1], "item": "esca_legnoferro", "slots": 1, "light": true, "light_color": Color(0.5, 0.35, 0.2)},
	"esca_ambra": {"name": "Esca d'ambra", "size": [1, 1], "item": "esca_ambra", "slots": 1, "light": true, "light_color": Color(0.5, 0.35, 0.2)},
	"tramoggia": {"name": "Tramoggia di radice", "size": [1, 1], "item": "tramoggia", "slots": 20},
	"tramoggia_ambra": {"name": "Tramoggia d'ambra", "size": [1, 1], "item": "tramoggia_ambra", "slots": 40},
	"radice_ancora": {"name": "Radice-ancora", "size": [1, 2], "item": "radice_ancora", "light": true, "light_color": Color(0.25, 0.5, 0.45)},
	"nastro_dx": {"name": "Nastro di radici (verso destra)", "size": [1, 1], "item": "nastro"},
	"nastro_sx": {"name": "Nastro di radici (verso sinistra)", "size": [1, 1], "item": "nastro"},
	# voce 88: le trappole (tipo × grado; i dati in `TrapsData`, le regole in `Traps`)
	"trappola_spuntoni_1": {"name": "Spuntoni", "size": [1, 1], "item": "trappola_spuntoni_1"},
	"trappola_spuntoni_2": {"name": "Spuntoni di legnoferro", "size": [1, 1], "item": "trappola_spuntoni_2"},
	"trappola_spuntoni_3": {"name": "Spuntoni d'ambra", "size": [1, 1], "item": "trappola_spuntoni_3"},
	"trappola_lama_1": {"name": "Lama rotante", "size": [1, 1], "item": "trappola_lama_1"},
	"trappola_lama_2": {"name": "Lama rotante di legnoferro", "size": [1, 1], "item": "trappola_lama_2"},
	"trappola_lama_3": {"name": "Lama rotante d'ambra", "size": [1, 1], "item": "trappola_lama_3"},
	"trappola_runa_brace_1": {"name": "Runa di brace", "size": [1, 1], "item": "trappola_runa_brace_1", "light": true, "light_color": Color(0.35, 0.3, 0.25)},
	"trappola_runa_brace_2": {"name": "Runa di brace di legnoferro", "size": [1, 1], "item": "trappola_runa_brace_2", "light": true, "light_color": Color(0.35, 0.3, 0.25)},
	"trappola_runa_brace_3": {"name": "Runa di brace d'ambra", "size": [1, 1], "item": "trappola_runa_brace_3", "light": true, "light_color": Color(0.35, 0.3, 0.25)},
	"trappola_runa_gelo_1": {"name": "Runa di gelo", "size": [1, 1], "item": "trappola_runa_gelo_1", "light": true, "light_color": Color(0.35, 0.3, 0.25)},
	"trappola_runa_gelo_2": {"name": "Runa di gelo di legnoferro", "size": [1, 1], "item": "trappola_runa_gelo_2", "light": true, "light_color": Color(0.35, 0.3, 0.25)},
	"trappola_runa_gelo_3": {"name": "Runa di gelo d'ambra", "size": [1, 1], "item": "trappola_runa_gelo_3", "light": true, "light_color": Color(0.35, 0.3, 0.25)},
	"trappola_runa_spora_1": {"name": "Runa di spora", "size": [1, 1], "item": "trappola_runa_spora_1", "light": true, "light_color": Color(0.35, 0.3, 0.25)},
	"trappola_runa_spora_2": {"name": "Runa di spora di legnoferro", "size": [1, 1], "item": "trappola_runa_spora_2", "light": true, "light_color": Color(0.35, 0.3, 0.25)},
	"trappola_runa_spora_3": {"name": "Runa di spora d'ambra", "size": [1, 1], "item": "trappola_runa_spora_3", "light": true, "light_color": Color(0.35, 0.3, 0.25)},
	"trappola_runa_vuoto_1": {"name": "Runa del Vuoto", "size": [1, 1], "item": "trappola_runa_vuoto_1", "light": true, "light_color": Color(0.35, 0.3, 0.25)},
	"trappola_runa_vuoto_2": {"name": "Runa del Vuoto di legnoferro", "size": [1, 1], "item": "trappola_runa_vuoto_2", "light": true, "light_color": Color(0.35, 0.3, 0.25)},
	"trappola_runa_vuoto_3": {"name": "Runa del Vuoto d'ambra", "size": [1, 1], "item": "trappola_runa_vuoto_3", "light": true, "light_color": Color(0.35, 0.3, 0.25)},
	"trappola_pressa_1": {"name": "Pressa di pietra", "size": [1, 1], "item": "trappola_pressa_1"},
	"trappola_pressa_2": {"name": "Pressa di pietra di legnoferro", "size": [1, 1], "item": "trappola_pressa_2"},
	"trappola_pressa_3": {"name": "Pressa di pietra d'ambra", "size": [1, 1], "item": "trappola_pressa_3"},
	"trappola_getto_brace_1": {"name": "Getto di brace", "size": [1, 1], "item": "trappola_getto_brace_1", "light": true, "light_color": Color(0.35, 0.3, 0.25)},
	"trappola_getto_brace_2": {"name": "Getto di brace di legnoferro", "size": [1, 1], "item": "trappola_getto_brace_2", "light": true, "light_color": Color(0.35, 0.3, 0.25)},
	"trappola_getto_brace_3": {"name": "Getto di brace d'ambra", "size": [1, 1], "item": "trappola_getto_brace_3", "light": true, "light_color": Color(0.35, 0.3, 0.25)},
	"trappola_getto_acqua_1": {"name": "Getto d'acqua", "size": [1, 1], "item": "trappola_getto_acqua_1"},
	"trappola_getto_acqua_2": {"name": "Getto d'acqua di legnoferro", "size": [1, 1], "item": "trappola_getto_acqua_2"},
	"trappola_getto_acqua_3": {"name": "Getto d'acqua d'ambra", "size": [1, 1], "item": "trappola_getto_acqua_3"},
	"trappola_rete_1": {"name": "Rete di radici", "size": [1, 1], "item": "trappola_rete_1"},
	"trappola_rete_2": {"name": "Rete di radici di legnoferro", "size": [1, 1], "item": "trappola_rete_2"},
	"trappola_rete_3": {"name": "Rete di radici d'ambra", "size": [1, 1], "item": "trappola_rete_3"},
	"totem_rifugio_1": {"name": "Rifugio del viandante", "size": [1, 2], "item": "totem_rifugio_1", "light": true, "light_color": Color(1.00, 0.80, 0.55)},
	"totem_rifugio_2": {"name": "Rifugio del viandante di legnoferro", "size": [1, 2], "item": "totem_rifugio_2", "light": true, "light_color": Color(1.20, 0.96, 0.66)},
	"totem_rifugio_3": {"name": "Rifugio del viandante d'ambra", "size": [1, 2], "item": "totem_rifugio_3", "light": true, "light_color": Color(1.40, 1.12, 0.77)},
	"stella_eterna": {"name": "Stella che non si spegne", "size": [1, 1], "fixed": true, "light": true, "light_color": Color(1.6, 1.5, 0.8)},
	"arena": {"name": "Cerchio dei Seminatori", "size": [3, 1], "item": "cerchio_arena", "light": true,
		"light_color": Color(0.6, 0.5, 0.2)},                # voce 84: si evocano i Guardiani già affrontati
	"altare": {"name": "Altare dei Seminatori", "size": [3, 2], "item": "altare", "light": true,
		"light_color": Color(0.2, 0.6, 0.55)},
	"bozzolo_madre_grumi": {"name": "Bozzolo della Madre dei grumi", "size": [3, 3], "item": "", "fixed": true,
		"light": true, "light_color": Color(0.3, 0.9, 0.8)},
	"bozzolo_tessitrice": {"name": "Bozzolo della Tessitrice", "size": [3, 3], "item": "", "fixed": true, "light": true,
		"light_color": Color(0.9, 0.7, 0.3)},
	"bozzolo_serpe_madre": {"name": "Bozzolo della Serpe madre", "size": [3, 3], "item": "", "fixed": true, "light": true,
		"light_color": Color(0.3, 0.8, 0.9)},
	"bozzolo_mietitore": {"name": "Bozzolo del Mietitore", "size": [3, 3], "item": "", "fixed": true, "light": true,
		"light_color": Color(0.7, 0.4, 1.0)},
	"bozzolo_grande_cervo": {"name": "Bozzolo del Grande Cervo", "size": [3, 3], "item": "", "fixed": true, "light": true,
		"light_color": Color(0.6, 0.9, 1.1)},
	"bozzolo_madre_salamandre": {"name": "Bozzolo della Madre delle salamandre", "size": [3, 3], "item": "", "fixed": true,
		"light": true, "light_color": Color(1.2, 0.6, 0.3)},
	"bozzolo_rotto": {"name": "Bozzolo vuoto", "size": [3, 3], "item": "", "fixed": true},
	# voce 28: il reliquiario dei nascondigli murati, con una reliquia dentro
	"reliquiario": {"name": "Reliquiario dei Seminatori", "size": [2, 2], "item": "", "fixed": true, "slots": 10,
		"light": true, "light_color": Color(0.9, 0.75, 0.35)},
	"cesta": {"name": "Cesta di radici", "size": [2, 2], "item": "cesta", "slots": 20},
	# 28 set 2026: i gradi delle casse (capienze e materiali in `ChestsData`)
	"cassa_legnoferro": {"name": "Cassa di legnoferro", "size": [2, 2], "item": "cassa_legnoferro", "slots": 30},
	"forziere_ambra": {"name": "Forziere d'ambra", "size": [2, 2], "item": "forziere_ambra", "slots": 40, "light": true,
		"light_color": Color(0.5, 0.35, 0.1)},
	"scrigno_linfa": {"name": "Scrigno di Linfa", "size": [2, 2], "item": "scrigno_linfa", "slots": 50, "light": true,
		"light_color": Color(0.15, 0.5, 0.45)},
	"arca_vuoto": {"name": "Arca del Vuoto", "size": [2, 2], "item": "arca_vuoto", "slots": 70, "light": true,
		"light_color": Color(0.35, 0.15, 0.6)},
	"arca_stellare": {"name": "Arca stellare", "size": [2, 2], "item": "arca_stellare", "slots": 100, "light": true,
		"light_color": Color(0.7, 0.65, 0.3)},
	"scrigno_antico": {"name": "Scrigno antico dei Seminatori", "size": [2, 2], "item": "scrigno_antico", "slots": 40,
		"light": true, "light_color": Color(0.6, 0.45, 0.15)},
	"arca_seminatori": {"name": "Arca dei Seminatori", "size": [2, 2], "item": "arca_seminatori", "slots": 60,
		"light": true, "light_color": Color(0.7, 0.65, 0.35)},
	"scrigno": {"name": "Scrigno dei Seminatori", "size": [2, 2], "item": "scrigno", "slots": 20, "light": true,
		"light_color": Color(0.2, 0.6, 0.55)},
	# Roadmap 17, voce 174: lo scrigno sigillato da una parola (si apre con la ruota dei glifi, `WordChests`)
	"scrigno_parola": {"name": "Scrigno a parola", "size": [2, 2], "item": "", "fixed": true, "slots": 20, "light": true,
		"light_color": Color(0.9, 0.65, 0.25)},
	# il fagotto di foglie dove il Germogliato è appassito, con la sua Bisaccia (voce 20): sparisce svuotato
	"fagotto": {"name": "Fagotto del Germogliato", "size": [1, 1], "item": "", "fixed": true, "slots": 30, "light": true,
		"light_color": Color(0.9, 0.7, 0.35)},
	"cuore_mondo": {"name": "Cuore del mondo", "size": [3, 3], "item": "", "fixed": true, "light": true,
		"light_color": Color(1.3, 0.85, 0.4)},
	"cuore_vivo": {"name": "Cuore del mondo", "size": [3, 3], "item": "", "fixed": true, "light": true,
		"light_color": Color(0.6, 1.6, 1.5)},
	"portale": {"name": "Portale di radici", "size": [3, 4], "item": "seme_mondo", "fixed": true, "light": true,
		"light_color": Color(0.5, 1.3, 1.4)},
	# voce 58: i nidi e le tane (nascono dal mondo; clic destro: un uovo, o nutrirli; con piccone o ascia si distruggono)
	"nido_erba": {"name": "Nido d'erba", "size": [2, 1], "item": "", "fixed": true},
	"nido_tetto": {"name": "Nido sul tetto", "size": [2, 1], "item": "", "fixed": true},       # voce 146
	"cuccia": {"name": "Cuccia", "size": [2, 1], "item": "cuccia"},                           # voce 148
	"alveare_costruito": {"name": "Alveare costruito", "size": [1, 2], "item": "alveare_costruito"},
	"nido_tana": {"name": "Tana", "size": [2, 1], "item": "", "fixed": true, "light": true, "light_color": Color(0.5, 0.4, 0.1)},
	"nido_alveare": {"name": "Alveare di lume", "size": [2, 2], "item": "", "fixed": true, "light": true,
		"light_color": Color(1.0, 0.7, 0.2)},
	"nido_formicaio": {"name": "Formicaio di resina", "size": [3, 2], "item": "", "fixed": true},
	# voce 59: il Recinto (anche mangiatoia: le caselle) e l'Incubatrice
	"recinto": {"name": "Recinto di radici", "size": [3, 2], "item": "recinto", "slots": 12},
	"incubatrice": {"name": "Incubatrice di muschio", "size": [2, 1], "item": "incubatrice", "slots": 4, "light": true,
		"light_color": Color(0.4, 0.9, 0.7)},
	# voce 62: l'Albero-Madre del Giardino, in cinque fasi di crescita (il disegno in `MotherTreeArt`)
	"albero_madre_0": {"name": "Albero-Madre", "size": [9, 13], "item": "", "fixed": true},
	"albero_madre_1": {"name": "Albero-Madre", "size": [9, 13], "item": "", "fixed": true, "light": true,
		"light_color": Color(0.3, 0.8, 0.7)},
	"albero_madre_2": {"name": "Albero-Madre", "size": [9, 13], "item": "", "fixed": true, "light": true,
		"light_color": Color(0.4, 0.9, 0.8)},
	"albero_madre_3": {"name": "Albero-Madre", "size": [9, 13], "item": "", "fixed": true, "light": true,
		"light_color": Color(0.6, 1.0, 0.8)},
	"albero_madre_4": {"name": "Albero-Madre", "size": [9, 13], "item": "", "fixed": true, "light": true,
		"light_color": Color(1.0, 1.0, 0.8)},
	# voce 68: la stele dei Seminatori (una frase nella loro lingua)
	"stele": {"name": "Stele dei Seminatori", "size": [2, 3], "fixed": true},
	# voce 71: i meccanismi dei luoghi (lo stato è la stazione: accesa, alzata, premuta, desta)
	"braciere": {"name": "Braciere dei Seminatori", "size": [1, 1], "fixed": true},
	"braciere_acceso": {"name": "Braciere acceso", "size": [1, 1], "fixed": true, "light": true},
	"leva": {"name": "Leva di radice (giù)", "size": [1, 1], "fixed": true},
	"leva_su": {"name": "Leva di radice (su)", "size": [1, 1], "fixed": true},
	"piastra": {"name": "Piastra dei Seminatori", "size": [1, 1], "fixed": true},
	"piastra_premuta": {"name": "Piastra premuta", "size": [1, 1], "fixed": true, "light": true},
	"cristallo_eco": {"name": "Cristallo d'eco", "size": [1, 1], "fixed": true},
	"cristallo_eco_desto": {"name": "Cristallo d'eco risvegliato", "size": [1, 1], "fixed": true, "light": true},
	# voce 69: il leggio delle cripte delle catene
	"leggio": {"name": "Leggio dei Seminatori", "size": [2, 2], "fixed": true, "light": true},
	# voce 67: la Bacheca dei Giardinieri (richieste senza fine)
	"bacheca": {"name": "Bacheca dei Giardinieri", "size": [3, 2], "item": "bacheca"},
	# voce 47: il Banco dell'Innestatrice (clic destro: `InnestoPanel`)
	"banco_innesti": {"name": "Banco dell'Innestatrice", "size": [3, 2], "item": "banco_innesti", "light": true,
		"light_color": Color(0.5, 1.1, 0.9)},
	# voce 46: la pianta-seme selvatica (clic destro: una Fiala di gene o un Seme selvatico, vedi `Sampling`)
	"pianta_seme": {"name": "Pianta-seme", "size": [1, 2], "item": "", "fixed": true, "light": true,
		"light_color": Color(0.9, 0.8, 0.35)},
	# voce 45: l'Aiuola del Giardino, dove si piantano i Semi di mondo (diventa un portale della stessa misura)
	"aiuola": {"name": "Aiuola del Giardino", "size": [3, 4], "item": "aiuola", "light": true,
		"light_color": Color(0.35, 0.8, 0.7)},
}

## Distanza massima (in tessere) per usare una stazione.
const REACH := 5
