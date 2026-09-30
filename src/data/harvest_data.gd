class_name HarvestData
extends RefCounted
## I raccolti delle piante (Roadmap 30, voce 300; l'utente: «poco da trovare, pochi oggetti raccoglibili»): ogni pianta
## dei biomi e della base, tolta con un clic, lascia qualcosa del suo bioma. Regole in `Harvest` (`src/game/`).
##   DECOR   decorazione -> [oggetto, probabilità, quanti al meno, quanti al più] (l'erba bassa lascia meno spesso)
##   ITEMS   i raccolti; `role` dice a che cosa servono (`ROLES`): una ricetta per ognuno, generata qui
## Le decorazioni già scritte in `TileDefs.DECOR_DROP` (funghi, gemme, doni) restano come sono.

const DECOR := {
	1: ["fronda_muschio", 0.25, 1, 1], 2: ["fronda_muschio", 0.25, 1, 1], 3: ["fronda_muschio", 0.25, 1, 1],
	4: ["petali_campanula", 1.0, 1, 2], 5: ["petali_campanula_ambra", 1.0, 1, 2], 6: ["petali_campanula_viola", 1.0, 1, 2],
	7: ["ciottolo", 1.0, 1, 2], 8: ["ciottolo", 1.0, 1, 2], 11: ["fibra_radice", 0.8, 1, 2], 12: ["fibra_radice", 0.8, 1, 2],
	13: ["sacca_spore", 1.0, 1, 1], 14: ["fronda_felce", 0.7, 1, 2], 17: ["goccia_linfa_viva", 0.5, 1, 1],
	33: ["bacche_lanterna", 1.0, 1, 3],
	34: ["fili_spora", 0.3, 1, 1], 35: ["canna_palude", 1.0, 1, 2], 36: ["funghetti_palude", 1.0, 1, 2],
	37: ["paglia_dorata", 0.3, 1, 1], 38: ["cardo_ambra", 1.0, 1, 1], 39: ["resina_fiore", 1.0, 1, 2],
	40: ["muschio_gelato", 0.3, 1, 1], 41: ["scheggia_brina", 1.0, 1, 2], 42: ["bacche_brina", 1.0, 1, 3],
	43: ["carbonella", 0.3, 1, 1], 44: ["tizzone_vivo", 1.0, 1, 1], 45: ["carbonella", 1.0, 1, 2],
	46: ["fili_argento", 0.3, 1, 1], 47: ["pappi_vento", 1.0, 1, 3], 48: ["cardo_vento", 1.0, 1, 1],
	49: ["fronda_rame", 1.0, 1, 2], 50: ["foglie_secche", 0.3, 1, 2], 51: ["fungo_mensola", 1.0, 1, 1],
	52: ["muschio_bruno", 0.3, 1, 1], 53: ["funghetti_cappello", 1.0, 1, 2], 54: ["cappello_lucente", 1.0, 1, 1],
	55: ["giunco", 1.0, 1, 2], 56: ["ninfea_linfa", 1.0, 1, 1], 57: ["torba_viva", 1.0, 1, 2],
	58: ["paglia_secca", 0.3, 1, 1], 59: ["scheggia_vetro", 1.0, 1, 2], 60: ["osso_bianco", 1.0, 1, 2],
	61: ["brina_ciuffo", 0.3, 1, 1], 62: ["ghiaccio_linfa", 1.0, 1, 1], 63: ["neve_soffice", 0.6, 1, 2],
	64: ["muschio_grigio", 0.3, 1, 1], 65: ["scheggia_pietrificata", 1.0, 1, 2], 66: ["fiore_pietra", 1.0, 1, 1],
	67: ["carbonella", 0.3, 1, 1], 68: ["tizzone_vivo", 1.0, 1, 1], 69: ["zolfo", 1.0, 1, 2],
	70: ["fronda_gigante", 1.0, 1, 2], 71: ["bulbo_radice", 1.0, 1, 1], 72: ["germoglio_cristallo", 1.0, 1, 1],
	73: ["fungo_acqua", 1.0, 1, 2], 74: ["fili_iridati", 0.3, 1, 1], 75: ["petali_iride", 1.0, 1, 2],
	76: ["fili_stellati", 0.3, 1, 1], 77: ["scintilla_stella", 1.0, 1, 1], 78: ["muschio_argento", 0.3, 1, 1],
	79: ["seme_runico", 1.0, 1, 1],
	80: ["fili_sospesi", 0.3, 1, 1], 81: ["baccello_sospeso", 1.0, 1, 2], 82: ["bioccolo_nube", 0.4, 1, 1],
	83: ["fiore_nube", 1.0, 1, 2], 84: ["fili_vento", 0.3, 1, 1], 85: ["corolla_vento", 1.0, 1, 2],
	86: ["germoglio_celeste", 1.0, 1, 1], 87: ["fiore_cristallo", 1.0, 1, 1], 88: ["fili_tempesta", 0.3, 1, 1],
	89: ["pappo_tempesta", 1.0, 1, 2], 90: ["fili_firmamento", 0.3, 1, 1], 91: ["fiore_firmamento", 1.0, 1, 1],
}

## A che cosa servono i raccolti: una ricetta per ognuno (`recipes`), o si mangiano (bacche e funghi).
##   fibra    → Corda di liana al Telaio (3 → 1)
##   petalo   → la tintura del suo colore, a mano (1 → 6); `dye` = quale
##   cibo     → si mangia: un po' di Vita (`heal`) o di Linfa (`linfa`)
##   resina   → Vetro di resina al Baccello ardente (2 → 1)
##   carbone  → Torce al Ceppo (1 + 1 legno → 4)
##   zolfo    → Baccelli esplosivi al Baccello ardente (2 + 1 gelatina → 2)
##   pietra   → si vende bene agli abitanti; le schegge di vetro danno vetro (2 → 1)
##   raro     → Polvere iridata all'Alambicco (12 → 1)
const ITEMS := {
	"fronda_muschio": {"name": "Fronda di muschio", "role": "fibra", "icon": ["foglia", "muschio"]},
	"petali_campanula": {"name": "Petali di campanula", "role": "petalo", "dye": "tintura_turchese", "icon": ["pappo", "linfa"]},
	"petali_campanula_ambra": {"name": "Petali di campanula d'ambra", "role": "petalo", "dye": "tintura_gialla", "icon": ["pappo", "ambra"]},
	"petali_campanula_viola": {"name": "Petali di campanula viola", "role": "petalo", "dye": "tintura_viola", "icon": ["pappo", "nottilite"]},
	"ciottolo": {"name": "Ciottolo levigato", "role": "pietra", "value": 3, "icon": ["minerale", "ardesia"]},
	"fibra_radice": {"name": "Fibra di radice", "role": "fibra", "icon": ["seta", "radice"]},
	"fronda_felce": {"name": "Fronda di felce", "role": "fibra", "icon": ["foglia", "legno"]},
	"goccia_linfa_viva": {"name": "Goccia di Linfa viva", "role": "cibo", "linfa": 6, "icon": ["goccia", "linfa"]},
	"bacche_lanterna": {"name": "Bacche-lanterna", "role": "cibo", "heal": 8, "icon": ["seme", "ambra"]},
	"fili_spora": {"name": "Fili di spora", "role": "fibra", "icon": ["seta", "muschio"]},
	"canna_palude": {"name": "Canna di palude", "role": "fibra", "icon": ["bastone", "muschio"]},
	"funghetti_palude": {"name": "Funghetti di palude", "role": "cibo", "heal": 6, "icon": ["fungo", "muschio"]},
	"paglia_dorata": {"name": "Paglia dorata", "role": "fibra", "icon": ["penna", "ambra"]},
	"cardo_ambra": {"name": "Cardo d'ambra", "role": "petalo", "dye": "tintura_arancio", "icon": ["artiglio", "ambra"]},
	"resina_fiore": {"name": "Resina di fiore", "role": "resina", "icon": ["goccia", "ambra"]},
	"muschio_gelato": {"name": "Muschio gelato", "role": "fibra", "icon": ["foglia", "cristallo"]},
	"scheggia_brina": {"name": "Scheggia di brina", "role": "pietra", "value": 5, "dye": "tintura_blu", "icon": ["scaglia", "cristallo"]},
	"bacche_brina": {"name": "Bacche di brina", "role": "cibo", "heal": 10, "icon": ["seme", "cristallo"]},
	"carbonella": {"name": "Carbonella", "role": "carbone", "icon": ["polvere", "brace"]},
	"tizzone_vivo": {"name": "Tizzone vivo", "role": "carbone", "icon": ["goccia", "brace"]},
	"fili_argento": {"name": "Fili d'erba argentata", "role": "fibra", "icon": ["seta", "brillaluce"]},
	"pappi_vento": {"name": "Pappi del vento", "role": "fibra", "icon": ["pappo", "seta"]},
	"cardo_vento": {"name": "Cardo del vento", "role": "petalo", "dye": "tintura_blu", "icon": ["artiglio", "lagunite"]},
	"fronda_rame": {"name": "Fronda di felce di rame", "role": "fibra", "icon": ["foglia", "brace"]},
	"foglie_secche": {"name": "Foglie secche", "role": "fibra", "icon": ["foglia", "humus"]},
	"fungo_mensola": {"name": "Fungo a mensola", "role": "cibo", "heal": 9, "icon": ["fungo", "legno"]},
	"muschio_bruno": {"name": "Muschio bruno", "role": "fibra", "icon": ["foglia", "humus"]},
	"funghetti_cappello": {"name": "Funghetti delle colline", "role": "cibo", "heal": 7, "icon": ["fungo", "sanguinella"]},
	"cappello_lucente": {"name": "Cappello lucente", "role": "cibo", "linfa": 5, "icon": ["fungo", "brillaluce"]},
	"giunco": {"name": "Giunco", "role": "fibra", "icon": ["bastone", "legno"]},
	"ninfea_linfa": {"name": "Ninfea di Linfa", "role": "petalo", "dye": "tintura_turchese", "icon": ["pappo", "linfa"]},
	"torba_viva": {"name": "Torba viva", "role": "carbone", "icon": ["zolla", "humus"]},
	"paglia_secca": {"name": "Paglia secca", "role": "fibra", "icon": ["penna", "legno"]},
	"scheggia_vetro": {"name": "Scheggia di vetro", "role": "pietra", "value": 4, "glass": true, "icon": ["scaglia", "brillaluce"]},
	"osso_bianco": {"name": "Osso bianco", "role": "pietra", "value": 6, "dye": "tintura_bianca", "icon": ["artiglio", "seta"]},
	"brina_ciuffo": {"name": "Ciuffo di brina", "role": "fibra", "icon": ["seta", "cristallo"]},
	"ghiaccio_linfa": {"name": "Ghiaccio di Linfa", "role": "raro", "icon": ["cristallo", "linfa"]},
	"neve_soffice": {"name": "Neve soffice", "role": "cibo", "linfa": 2, "icon": ["polvere", "seta"]},
	"muschio_grigio": {"name": "Muschio grigio", "role": "fibra", "icon": ["foglia", "ardesia"]},
	"scheggia_pietrificata": {"name": "Scheggia pietrificata", "role": "pietra", "value": 5, "icon": ["scaglia", "ardesia"]},
	"fiore_pietra": {"name": "Fiore di pietra", "role": "raro", "icon": ["pappo", "ardesia"]},
	"zolfo": {"name": "Zolfo", "role": "zolfo", "icon": ["polvere", "ambra"]},
	"fronda_gigante": {"name": "Fronda gigante", "role": "fibra", "icon": ["foglia", "muschio"]},
	"bulbo_radice": {"name": "Bulbo di radice", "role": "cibo", "heal": 14, "icon": ["tubero", "radice"]},
	"germoglio_cristallo": {"name": "Germoglio di cristallo", "role": "raro", "icon": ["cristallo", "brillaluce"]},
	"fungo_acqua": {"name": "Fungo d'acqua", "role": "cibo", "linfa": 5, "icon": ["fungo", "lagunite"]},
	"fili_iridati": {"name": "Fili iridati", "role": "fibra", "icon": ["seta", "iride"]},
	"petali_iride": {"name": "Petali dell'iride", "role": "raro", "icon": ["pappo", "iride"]},
	"fili_stellati": {"name": "Fili stellati", "role": "fibra", "icon": ["seta", "stelle"]},
	"scintilla_stella": {"name": "Scintilla di stella", "role": "raro", "icon": ["stella", "stelle"]},
	"muschio_argento": {"name": "Muschio d'argento", "role": "fibra", "icon": ["foglia", "brillaluce"]},
	"seme_runico": {"name": "Seme runico", "role": "raro", "icon": ["seme", "nottilite"]},
	"fili_sospesi": {"name": "Fili delle radici sospese", "role": "fibra", "icon": ["seta", "radice"]},
	"baccello_sospeso": {"name": "Baccello sospeso", "role": "cibo", "heal": 10, "icon": ["seme", "nuvola"]},
	"bioccolo_nube": {"name": "Bioccolo di nube", "role": "fibra", "icon": ["pappo", "nuvola"]},
	"fiore_nube": {"name": "Fiore di nube", "role": "petalo", "dye": "tintura_bianca", "icon": ["pappo", "nuvola"]},
	"fili_vento": {"name": "Fili del vento", "role": "fibra", "icon": ["seta", "nuvola"]},
	"corolla_vento": {"name": "Corolla del vento", "role": "petalo", "dye": "tintura_verde", "icon": ["pappo", "muschio"]},
	"germoglio_celeste": {"name": "Germoglio celeste", "role": "raro", "icon": ["cristallo", "lagunite"]},
	"fiore_cristallo": {"name": "Fiore di cristallo", "role": "petalo", "dye": "tintura_blu", "icon": ["pappo", "cristallo"]},
	"fili_tempesta": {"name": "Fili della tempesta", "role": "fibra", "icon": ["seta", "lagunite"]},
	"pappo_tempesta": {"name": "Pappo della tempesta", "role": "zolfo", "icon": ["pappo", "lagunite"]},
	"fili_firmamento": {"name": "Fili del Firmamento", "role": "fibra", "icon": ["seta", "stelle"]},
	"fiore_firmamento": {"name": "Fiore del Firmamento", "role": "raro", "icon": ["pappo", "stelle"]},
}

const ROLE_DESC := {
	"fibra": "Una fibra: tre fanno una Corda di liana, al Telaio.",
	"petalo": "Pestato a mano dà la sua tintura (sei gocce).",
	"cibo": "Si mangia.",
	"resina": "Due, al Baccello ardente, fanno un Vetro di resina.",
	"carbone": "Con un pezzo di legno, al Ceppo, fa quattro torce.",
	"zolfo": "Due, con una gelatina, al Baccello ardente, fanno due Baccelli esplosivi.",
	"pietra": "Gli abitanti la comprano volentieri; al Baccello ardente fa mattoni (o vetro, o tintura).",
	"raro": "Raro: dodici, all'Alambicco, fanno una Polvere iridata.",
}


static func items() -> Dictionary:
	var out := {}
	for id in ITEMS:
		var e: Dictionary = ITEMS[id]
		var it := {"name": e["name"], "kind": "materiale", "icon": e["icon"], "stack": 999, "erba": e["role"] != "pietra",
			"sasso": e["role"] == "pietra", "desc": String(ROLE_DESC[e["role"]])}
		if e["role"] == "cibo":
			it["kind"] = "consumabile"
			if e.has("heal"):
				it["heal"] = e["heal"]
				it["desc"] = "Si mangia: +%d Vita." % int(e["heal"])
			if e.has("linfa"):
				it["linfa"] = e["linfa"]
				it["desc"] = "Si mangia: +%d Linfa." % int(e["linfa"])
			it["stack"] = 99
		if e.has("value"):
			it["value"] = e["value"]
		out[id] = it
	return out


static func recipes() -> Array:
	var out := []
	for id in ITEMS:
		var e: Dictionary = ITEMS[id]
		match String(e["role"]):
			"fibra":
				out.append({"out": "corda_liana", "qty": 1, "in": {id: 3}, "station": "telaio"})
			"petalo":
				out.append({"out": e["dye"], "qty": 6, "in": {id: 1}, "station": ""})
			"resina":
				out.append({"out": "vetro_resina", "qty": 1, "in": {id: 2}, "station": "baccello_ardente"})
			"carbone":
				out.append({"out": "torcia", "qty": 4, "in": {id: 1, "legno": 1}, "station": "ceppo"})
			"zolfo":
				out.append({"out": "baccello_esplosivo", "qty": 2, "in": {id: 2, "gelatina": 1}, "station": "baccello_ardente"})
			"raro":
				out.append({"out": "polvere_iridata", "qty": 1, "in": {id: 12}, "station": "alambicco"})
			"pietra":
				if e.get("glass", false):
					out.append({"out": "vetro_resina", "qty": 1, "in": {id: 2}, "station": "baccello_ardente"})
				elif e.has("dye"):
					out.append({"out": e["dye"], "qty": 4, "in": {id: 1}, "station": ""})
				else:
					out.append({"out": "mattoni_ardesia", "qty": 2, "in": {id: 2, "humus": 1}, "station": "baccello_ardente"})
	return out
