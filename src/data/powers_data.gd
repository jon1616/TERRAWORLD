class_name PowersData
extends RefCounted
## I poteri del Germogliato (voce 64, Roadmap 8): doni permanenti degli stadi dell'Albero-Madre (`MotherTreeData`).
## Ogni potere apre luoghi che prima non si raggiungevano (i Sigilli di `PassSigilli`, i cieli alti, i baratri): la
## esplorazione si apre a strati. Solo dati; le regole stanno in `Powers`.
##   key    tasto che lo usa (vuoto = sempre attivo)
##   seal   il Sigillo che apre (tessera `TileDefs.SIGILLI`), se ne apre uno

const POWERS := {
	"vista": {"name": "Vista della Linfa", "key": "V",
		"desc": "Tasto V: per qualche secondo vedi brillare nella roccia le vene di minerale, i Sigilli nascosti e gli scrigni murati attorno a te.",
		"seal": "velato"},
	"canto": {"name": "Canto delle radici", "key": "",
		"desc": "Le radici ti riconoscono: i Sigilli di radice si aprono al tuo passaggio (clic destro), e le radici giganti si scavano il doppio in fretta.",
		"seal": "radice"},
	"passo": {"name": "Passo nel Vuoto", "key": "",
		"desc": "Attraversi i Veli del Vuoto come se fossero aria: le stanze sigillate del Fondo si aprono per te.",
		"seal": "vuoto"},
	"brace": {"name": "Pelle di brace", "key": "",
		"desc": "Il fuoco non ti tocca: attraversi i Muri di brace e i fiumi di brace del sottosuolo senza ferirti.",
		"seal": "brace"},
	"salto": {"name": "Salto delle spore", "key": "",
		"desc": "Un soffio di spore ti spinge: un salto in aria in più e salti più alti, fino alle isole sospese.",
		"seal": ""},
	"ponte": {"name": "Radici-ponte", "key": "F",
		"desc": "Tasto F: fai crescere una passerella di radici verso il mouse (fino a 12 tessere), che dura un minuto.",
		"seal": ""},
}
