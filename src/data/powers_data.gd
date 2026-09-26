class_name PowersData
extends RefCounted
## I poteri del Germogliato (voce 64, Roadmap 8): doni permanenti degli stadi dell'Albero-Madre (`MotherTreeData`).
## Ogni potere apre luoghi che prima non si raggiungevano (i Sigilli di `PassSigilli`, i cieli alti, i baratri): la
## esplorazione si apre a strati. Solo dati; le regole stanno in `Powers`.
##   key    tasto che lo usa (vuoto = sempre attivo)
##   seal   il Sigillo che apre (tessera `TileDefs.SIGILLI`), se ne apre uno

## Il Frammento dell'Albero: sta negli scrigni dei luoghi sigillati; gli stadi più alti dell'Albero-Madre lo chiedono.
const ITEMS := {
	"frammento_albero": {"name": "Frammento dell'Albero", "kind": "materiale", "icon": ["seme", "ambra"], "stack": 20,
		"source": "negli scrigni dei luoghi sigillati (Sigilli) e dei nidi alti",
		"desc": "Un pezzo di corteccia dell'Albero-Madre, portato via dai Seminatori e chiuso dietro un Sigillo. L'Albero lo rivuole."},
}

const POWERS := {
	"vista": {"name": "Vista della Linfa", "key": "V",
		"desc": "Tasto V: per qualche secondo vedi brillare nella roccia le vene di minerale, i Sigilli nascosti e gli scrigni murati attorno a te.",
		"seal": "velato"},
	"canto": {"name": "Canto delle radici", "key": "",
		"desc": "Le radici ti riconoscono: i Sigilli di radice del Sottobosco si aprono al tuo tocco (clic destro), e scavi un quarto più in fretta.",
		"seal": "radice"},
	"passo": {"name": "Passo nel Vuoto", "key": "",
		"desc": "I Veli del Vuoto (i Sigilli del Fondo) si dissolvono al tuo tocco, e il Vuoto del Giardino non ti ferisce più.",
		"seal": "vuoto"},
	"brace": {"name": "Pelle di brace", "key": "",
		"desc": "Il fuoco ti riconosce: i Muri di brace delle Profondità si aprono al tuo tocco, e la pelle si indurisce (+3 Scorza).",
		"seal": "brace"},
	"salto": {"name": "Salto delle spore", "key": "",
		"desc": "Un soffio di spore ti spinge: un salto in aria in più e salti più alti. Con le Radici-ponte si arriva ai nidi alti nel cielo.",
		"seal": ""},
	"ponte": {"name": "Radici-ponte", "key": "F",
		"desc": "Tasto F: fai crescere una passerella di radici verso il mouse (fino a 12 tessere), che dura un minuto.",
		"seal": ""},
}
