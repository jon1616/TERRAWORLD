class_name ConsigliData
## I consigli alla prima volta (28 set 2026, richiesta dell'utente: aiutare il giocatore nuovo in un gioco ormai vasto).
## Solo dati: ogni riga è una cosa che succede per la prima volta; `Consigli` (in `src/game/`) controlla le condizioni
## (una funzione per `id`), mostra la scheda una volta sola e la ricorda nel personaggio (`Character.guida`).
## Campi: id (la condizione), title, text (due o tre righe, BBCode), cap (il capitolo dell'Enciclopedia che si apre
## con il tasto dell'Enciclopedia mentre la scheda è visibile).

const LIST := [
	{"id": "benvenuto", "title": "Benvenuto, Germogliato", "cap": "inizio",
		"text": "In alto al centro c'è il [b]filo[/b]: la prossima cosa da fare e dove cercarla (una freccia indica il posto, quando si sa). Il tasto {filo} passa a un altro filo: Albero-Madre, obiettivi, Bacheca, la tua lista."},
	{"id": "lista", "title": "La lista della spesa", "cap": "guida",
		"text": "In [b]Esamina[/b] il pulsante [b]Segna[/b] mette una ricetta nella lista a destra: vedi che cosa ti manca, anche gli ingredienti degli ingredienti, e il filo ti porta a cercarli."},
	{"id": "notte", "title": "La prima notte", "cap": "giorno",
		"text": "Di notte escono creature più forti e il buio è pieno. Resta vicino alle torce, o costruisci un riparo con una porta e un letto: il letto diventa il punto in cui rinasci."},
	{"id": "sottoterra", "title": "Sotto terra", "cap": "luce",
		"text": "Dove la luce non arriva è buio pieno: pianta [b]torce[/b] mentre scendi (clic destro le riprende). Ogni strato ha le sue rocce, i suoi minerali e creature più forti."},
	{"id": "profondo", "title": "Le Caverne d'ardesia", "cap": "strati",
		"text": "Più in basso le creature fanno male davvero: un'armatura di metallo e qualche pozione fanno la differenza. I minerali nuovi vogliono un piccone più forte."},
	{"id": "piccone", "title": "Troppo duro", "cap": "scavare",
		"text": "Questo blocco vuole un piccone più forte. I picconi si fanno con i lingotti: radicite, poi legnoferro, poi ambra fossile. L'Esamina di un piccone dice che cosa scava."},
	{"id": "vita_bassa", "title": "Vita bassa", "cap": "vita",
		"text": "La Vita ricresce da sola dopo qualche secondo senza ferite. Le [b]pozioni[/b] curano subito (poi va aspettato un poco prima della prossima). Allontanati, o cura e riprova."},
	{"id": "appassito", "title": "Sei appassito", "cap": "appassire",
		"text": "Si rinasce al letto (o alla partenza) con la Bisaccia intatta. Per non ricominciare lontano, metti un letto vicino a dove esplori."},
	{"id": "piena", "title": "La Bisaccia è piena", "cap": "bisaccia",
		"text": "Metti le cose nelle [b]casse[/b] («Nelle casse vicine» le smista da sola), o buttale nel [b]Cestino[/b] accanto al titolo della Bisaccia (Ctrl+clic su una casella)."},
	{"id": "stazione", "title": "Il primo banco", "cap": "creare",
		"text": "Vicino a un banco la Bisaccia mostra le sue ricette in [b]Creare[/b]. Ogni banco apre ricette nuove: guarda la categoria e il conto «possibili su tutte»."},
	{"id": "cassa", "title": "Le casse", "cap": "casse",
		"text": "Gli ingredienti nelle casse vicine valgono per creare. Dai un nome a una cassa e scegli il tipo che raccoglie: «Nelle casse vicine» ci manda da sola le cose giuste."},
	{"id": "acqua", "title": "Sott'acqua", "cap": "acqua",
		"text": "Sott'acqua il respiro cala (la barra sopra di te): risali prima che finisca. Salto per nuotare verso l'alto."},
	{"id": "seme", "title": "Un Seme di mondo", "cap": "semi",
		"text": "Piantalo in un'[b]Aiuola[/b] del Giardino: nasce un portale verso un mondo nuovo, fatto dai geni del Seme. Col mouse sopra il portale vedi che mondo è."},
	{"id": "rara", "title": "Una creatura rara", "cap": "creature",
		"text": "Le creature con il contorno acceso sono rare: più forti, ma lasciano Essenze e a volte trofei che non si trovano altrove."},
	{"id": "guardiano", "title": "Un Guardiano", "cap": "guardiani",
		"text": "Il Guardiano del mondo è sveglio. Si può sconfiggere, oppure [b]curare[/b] con la Rugiada sui nodi avvizziti: curarlo dona di più."},
	{"id": "gene", "title": "Il primo gene", "cap": "geni",
		"text": "I geni dei mondi si imparano con la Provetta di Linfa e con le Fiale delle creature. Nel Semenzaio (tasto {semenzaio}) il Genario dice che cosa conosci."},
]


static func by_id(id: String) -> Dictionary:
	for c in LIST:
		if String(c["id"]) == id:
			return c
	return {}
