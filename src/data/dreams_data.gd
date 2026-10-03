class_name DreamsData
extends RefCounted
## I sogni (Roadmap 36, voce 343): usando un letto, a volte, un ricordo dell'Albero-Madre. Due righe, mai di più; il
## primo sogno pronto (nell'ordine di questo elenco) che non si è ancora visto. Le condizioni sono quelle di `LoreConds`.
## L'ultimo è il segreto dei segreti (canone in `UNIVERSO.md`): si vede solo dopo aver trovato tutto il resto.
##   [id, titolo, testo, condizione]

const COOLDOWN := 300.0                  # secondi di gioco tra un sogno e l'altro

const DREAMS := [
	["frutto", "Il ramo", "Sei appeso a un ramo, al buio. Sotto di te qualcuno conta i frutti caduti.\nArriva a te e si ferma.", {}],
	["mani", "Le mani", "Mani lunghe, dita come radici, ti girano verso la luce.\nUna voce dice: «Questo no. Questo resta.»", {"stat": "viaggi", "n": 2}],
	["cuore", "Il Cuore", "Un Cuore batte nel buio. Dentro, qualcuno trattiene il fiato\nda un'era intera.", {"stat": "guardiani", "n": 1}],
	["guardare", "Chi guarda", "Uno di Linfa fissa il Vuoto e non si volta. «Lo vedi anche tu?»\nNon vedi niente. Poi, qualcosa.", {"sower": "odran", "n": 1}],
	["serra", "La serra", "Una serra piena di canti. Una donna ripete un nome, piano,\ncome per non dimenticarlo. Lo dimentica.", {"sower": "ilvenna", "n": 1}],
	["pietra", "La pietra", "Colpi di martello sulla pietra. A ogni colpo\nun nome diventa più piccolo.", {"sower": "varek", "n": 1}],
	["lite", "La lite", "Voci che litigano sotto l'Albero. Una ride.\nLe altre tacciono; poi tacciono per sempre.", {"any": [{"stat": "cronache", "n": 3}, {"stat": "catene", "n": 2}]}],
	["gola", "La gola", "Il Vuoto non è vuoto. Ha una gola.\nSenti l'aria che va dentro, e non torna.", {"albero": 8}],
	["seme", "Il seme", "Un seme nero tra due mani. Le mani tremano,\nma non di paura.", {"nero": "si"}],
	["voce_c", "La voce", "Qualcuno ti ringrazia con la tua stessa voce.\nTi svegli con la bocca che sa di terra.", {"nero": "curato"}],
	["voce_s", "Il silenzio", "Dove c'era una voce adesso c'è silenzio.\nNon sai perché ti manca.", {"nero": "spezzato"}],
	["alberi", "Quattro alberi", "Quattro alberi cantano insieme, sempre più forte.\nIl canto si spezza come vetro.", {"stat": "perduti", "n": 4}],
	["radice", "La radice lunga", "Una radice lunghissima nel buio. In fondo, qualcuno\nsi è piantato per non tornare indietro.", {"stat": "ultimo_seminatore", "n": 1}],
	["lanterne", "Le lanterne", "Nomi che si spengono uno a uno, come lanterne.\nUno dei buchi ha la tua forma.", {"spent": 5}],
	["linfa", "La raccolta", "L'Albero raccoglie Linfa dai Cuori, goccia a goccia.\nL'ultima goccia è nera. Con quella ti ha fatto camminare.",
		{"all": [{"sower": "odran", "n": 1}, {"sower": "ilvenna", "n": 1}, {"sower": "varek", "n": 1}, {"nero": "si"},
			{"stat": "ultimo_seminatore", "n": 1}, {"truths": 6}]}],
]


static func index_of(id: String) -> int:
	for i in DREAMS.size():
		if String(DREAMS[i][0]) == id:
			return i
	return -1
