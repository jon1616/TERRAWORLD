class_name ServicesData
## I servizi degli abitanti (voce 353, Roadmap 37, 4 ott 2026). L'utente, dopo sei ore: «ho 2 abitanti ma li trovo poco
## utili: vendo oggetti in cambio di Lumini (che accumulo) e compro qualche oggetto che potrei craftarmi da solo». Ogni
## abitante sa fare **una o due cose che nessun altro fa**, pagate in Lumini: scorciatoie preziose (segni sulla mappa,
## qualità e tempra dell'equipaggiamento, Semi su ordinazione, addestramento, traduzioni, effetti lunghi). Così i Lumini
## hanno uno scopo e ogni abitante nuovo porta qualcosa di nuovo al Giardino.
## Campi: npc, name, desc (che cosa fa, per il pulsante), kind (la funzione `_<kind>` di `Services`), p (parametri),
##   cost (Lumini), step (Lumini in più per ogni livello, per i servizi che crescono con l'oggetto o la creatura),
##   lvl (affetto che serve con l'abitante: 0 subito, 1, 2…), day (al più tante volte per giorno del mondo; 0 = senza
##   limite). Un servizio nuovo = una riga qui (+ la sua funzione in `Services` se il `kind` è nuovo).

const SERVICES := {
	# ---------------------------------------------------------------- i primi del Giardino
	"strade_nascoste": {"npc": "viandante", "name": "Strade nascoste", "kind": "segreti", "cost": 120, "day": 2,
		"desc": "Racconta dei sentieri che ha visto: segna sulla mappa i tre segreti più vicini di questo mondo."},
	"voce_firma": {"npc": "vecchia_radice", "name": "La voce della firma", "kind": "firma", "cost": 150, "day": 1,
		"desc": "Ascolta il mondo in cui sei e ti dice dov'è la sua firma, il luogo che non esiste altrove."},
	"tisana": {"npc": "erborista", "name": "Tisana su misura", "kind": "boon", "cost": 80, "day": 3,
		"p": {"boons": [["rigoglio", 600], ["scorza", 600]]},
		"desc": "Dieci minuti di Rigoglio (la Vita ricresce tre volte più in fretta) e di Scorza di corteccia."},
	# ---------------------------------------------------------------- l'equipaggiamento
	"rifinitura": {"npc": "forgiatore", "name": "Rifinitura", "kind": "qualita", "cost": 250, "step": 250, "day": 0,
		"desc": "Alza di un gradino la qualità dell'oggetto che tieni in mano (grezzo → buono → fine → capolavoro)."},
	"tempra_mano": {"npc": "fabbro_radici", "name": "Tempra a mano", "kind": "tempra", "cost": 300, "step": 300, "day": 0,
		"desc": "Tempra di un livello l'oggetto in mano senza Schegge di vigore (fin dove il vigore del mondo lo permette)."},
	# ---------------------------------------------------------------- i Semi e i geni
	"seme_ordine": {"npc": "mercante_semi", "name": "Seme su ordinazione", "kind": "seme_fiala", "cost": 300, "day": 2,
		"desc": "Tieni in mano la Fiala di un gene: ti fa un Seme di mondo che lo porta (la Fiala resta tua)."},
	"lettura_seme": {"npc": "mercante_semi", "name": "Lettura del Seme", "kind": "analisi", "cost": 60, "day": 0,
		"desc": "Tieni in mano un Seme di mondo: ti svela tutti i suoi geni, anche quelli che non hai mai visto."},
	"fiala_seme": {"npc": "innestatrice", "name": "Fiala dal Seme", "kind": "fiala", "cost": 250, "day": 2,
		"desc": "Tieni in mano un Seme di mondo: ne estrae la Fiala di uno dei suoi geni (il Seme resta intero)."},
	# ---------------------------------------------------------------- la mandria e i compagni
	"addestramento": {"npc": "mandriano", "name": "Addestramento", "kind": "addestra", "cost": 40, "step": 20, "day": 3,
		"desc": "Il compagno in campo (o il primo della sacca) sale subito di un livello."},
	"pasto_stalla": {"npc": "mandriano", "name": "Pasto della stalla", "kind": "sfama", "cost": 50, "day": 1,
		"desc": "Sfama tutta la mandria, ovunque sia, e la rende più felice."},
	"pista_bestie": {"npc": "guardaboschi", "name": "Pista delle bestie rare", "kind": "boon", "cost": 150, "day": 2,
		"p": {"boons": [["esca", 900]]},
		"desc": "Per quindici minuti le creature rare (antiche, iridate, capibranco) escono il doppio."},
	# ---------------------------------------------------------------- la pesca
	"segreto_stagno": {"npc": "pescatore", "name": "Il segreto dello stagno", "kind": "pesca", "cost": 100, "day": 2,
		"p": {"luck": 0.6, "secs": 900},
		"desc": "Per quindici minuti di gioco la tua canna ha molta più fortuna: pesci più rari e più grandi."},
	"occhi_fondo": {"npc": "palombara", "name": "Occhi del fondo", "kind": "boon", "cost": 100, "day": 2,
		"p": {"boons": [["vista", 1200]]},
		"desc": "Venti minuti di Occhi della notte: un chiarore minimo anche dove la luce non arriva."},
	# ---------------------------------------------------------------- l'esplorazione
	"mappa_mondo": {"npc": "mercante_mondi", "name": "Una mappa di questo mondo", "kind": "mappa", "cost": 400, "day": 1,
		"p": {"r": 110},
		"desc": "Ti vende la mappa dei dintorni: si scopre sulla mappa (M) tutto ciò che sta entro 110 tessere da te."},
	"sigilli_reliquiari": {"npc": "cartografo", "name": "I segni dei Seminatori", "kind": "sigilli", "cost": 200, "day": 1,
		"desc": "Segna sulla mappa il Sigillo e il reliquiario murato ancora chiusi più vicini."},
	"nuova_taglia": {"npc": "cacciatore", "name": "Taglie nuove", "kind": "taglia", "cost": 80, "day": 3,
		"desc": "Butta le taglie aperte e ne scrive di nuove, del vigore di adesso."},
	# ---------------------------------------------------------------- i misteri
	"traduzione": {"npc": "pellegrino", "name": "Traduzione", "kind": "parola", "cost": 150, "day": 2, "p": {"layer": "comune"},
		"desc": "Rende certa una parola della lingua comune dei Seminatori che hai già visto (prima le tue ipotesi)."},
	"racconto_antico": {"npc": "cantastorie", "name": "Racconto antico", "kind": "parola", "cost": 250, "day": 2, "p": {"layer": "antica"},
		"desc": "Rende certa una parola della lingua antica che hai già visto."},
	"stima_museo": {"npc": "collezionista", "name": "Stima del Museo", "kind": "museo", "cost": 40, "day": 0,
		"desc": "Ti dice quanti pezzi mancano a ogni sala del Museo, e da dove viene uno di quelli che ti mancano."},
	# ---------------------------------------------------------------- il Giardino
	"serata_musica": {"npc": "musicista", "name": "Una serata di musica", "kind": "boon", "cost": 120, "day": 1,
		"p": {"boons": [["sazio", 1800], ["fortuna", 900]], "herd": 0.15},
		"desc": "Mezz'ora di Sazio, un quarto d'ora di Fortuna, e la mandria più felice."},
	"ricarica_rete": {"npc": "tessitrice", "name": "Ricarica della rete", "kind": "rete", "cost": 150, "day": 1,
		"desc": "Riempie tutte le riserve di Linfa della rete di questo mondo."},
}


## I servizi di un abitante, in ordine.
static func of_npc(npc: String) -> Array:
	var out := []
	for k in SERVICES:
		if String(SERVICES[k]["npc"]) == npc:
			out.append(String(k))
	return out
