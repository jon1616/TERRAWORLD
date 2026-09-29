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
	{"id": "armatura", "title": "La Scorza conta", "cap": "pericolo",
		"text": "La [b]Scorza[/b] toglie una parte di ogni ferita: con 10 le ferite si dimezzano, con 20 ne resta un terzo. Qui le creature ne vogliono di più: un'armatura intera (elmo, corazza, gambali, guanti, stivali) del metallo migliore che hai. La Bisaccia dice quanto toglie la tua."},
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
	{"id": "canna", "title": "Una canna da pesca", "cap": "pesca",
		"text": "Clic su uno specchio d'acqua (almeno qualche decina di celle): la lenza parte e il pesce, quando abbocca, sale da solo. Le esche nella Bisaccia aiutano; la pesca non è obbligatoria, ma dà cibo, perle e tesori."},
	{"id": "cassa_pescata", "title": "Una cassa dall'acqua", "cap": "pesca",
		"text": "A volte alla lenza abbocca una cassa: tienila in mano e fai clic per aprirla. Dentro c'è il bottino delle rovine, e di rado un tesoro delle acque."},
	{"id": "gene", "title": "Il primo gene", "cap": "geni",
		"text": "I geni dei mondi si imparano con la Provetta di Linfa e con le Fiale delle creature. Nel Semenzaio (tasto {semenzaio}) il Genario dice che cosa conosci."},
	# Roadmap 15: il mondo abitato
	{"id": "allerta", "title": "Ti hanno sentito", "cap": "creature_vive",
		"text": "Il [b]?[/b] sopra una creatura: ha sentito un rumore (scavo, colpi, passi di corsa) e viene a guardare. Al buio ti vedono meno lontano; ferito, i predatori ti fiutano da lontano."},
	{"id": "stanza", "title": "La tua prima stanza", "cap": "stanze",
		"text": "Blocchi attorno, pareti dietro e una porta: è una [b]stanza[/b]. Gli arredi le danno un tipo (un letto: una casa; due banchi: un laboratorio) e un aiuto; bellezza e luci il comfort."},
	{"id": "marea", "title": "Una marea", "cap": "maree",
		"text": "Si avvicina una [b]marea[/b]: arriveranno ondate di creature e alla fine il loro capo. Preparati vicino a un riparo; sconfitto il capo, c'è un premio."},
	{"id": "signore", "title": "Un'esca rituale", "cap": "signori",
		"text": "Con l'esca rituale in mano, nel luogo del suo Signore, un clic lo chiama. È un mini-boss: a metà Vita entra in furia. Lascia un materiale che c'è solo da lui."},
	{"id": "studiata", "title": "Una specie studiata", "cap": "combattere",
		"text": "Hai studiato una specie: la sua scheda mostra come si batte, e fai più danno contro di lei per sempre. La [b]Provetta[/b] su una creatura aiuta a studiarla."},
	{"id": "progetto", "title": "Un progetto dei Seminatori", "cap": "progetti",
		"text": "Un progetto in mano mostra la sagoma di una struttura; se nella Bisaccia hai i materiali (la scheda li elenca), un clic la costruisce in un colpo."},
	# Roadmap 16: il cielo
	{"id": "cielo", "title": "Le Chiome del cielo", "cap": "cielo",
		"text": "Sei tra le isole del [b]cielo[/b]. Qui sotto è il cielo basso; più su, il cielo alto (dove l'aria è sottile). Attento a dove metti i piedi: la [b]Piuma lenta[/b] toglie il danno delle cadute."},
	{"id": "aria_sottile", "title": "L'aria sottile", "cap": "aria_sottile",
		"text": "Nel cielo alto sale la barra dell'[b]aria sottile[/b]: piena, il fiato ferisce. La Maschera di nuvola, il Mantello di piume o l'Elisir del respiro alto ti proteggono."},
	{"id": "fulmine", "title": "Una colonna di luce", "cap": "creature_cielo",
		"text": "Una riga di luce sulla tua colonna: tra un attimo cade un [b]fulmine[/b]. Spostati di lato; sotto un tetto non ti tocca."},
	{"id": "fagiolo", "title": "Il Fagiolo di nuvola", "cap": "cielo",
		"text": "Piantalo nella terra all'aperto: in un minuto sale una liana di [b]passerelle[/b] verso il cielo. Ci si sale saltando."},
	# Roadmap 17: la lingua dei Seminatori
	{"id": "prima_stele", "title": "Una stele dei Seminatori", "cap": "lingua",
		"text": "Le parole che hai letto ora sono [b]viste[/b]: ritrovale in altre stele e te ne farai un'ipotesi. Tutto ciò che sai della lingua è nel [b]Quaderno delle parole[/b] (tasto U)."},
	{"id": "prima_ipotesi", "title": "Un'ipotesi", "cap": "lingua",
		"text": "Hai visto una parola in abbastanza frasi: ora ha tre [b]significati possibili[/b]. Apri il Quaderno (U), guarda le frasi in cui compare e scegli quello giusto."},
	{"id": "prima_certa", "title": "Una parola certa", "cap": "lingua",
		"text": "Una parola dei Seminatori è [b]certa[/b]: ora la leggi in italiano ovunque. Le parole certe si incidono al Maglio e svelano ricette scritte."},
	{"id": "scrigno_parola", "title": "Uno scrigno a parola", "cap": "scrigni_parola",
		"text": "Questo scrigno ha un sigillo: una frase con una parola mancante. Scegli la parola giusta tra quelle che hai visto; se sbagli si richiude per un po'."},
	# Roadmap 19 «La Linfa che scorre»
	{"id": "pinza", "title": "La Pinza delle vene", "cap": "rete_vene",
		"text": "Clic e trascina: una linea di vena (o di filo). [b]Maiusc+rotella[/b] sceglie che cosa posare, il clic destro riprende. Le macchine prendono la Linfa dalle vene che toccano con una loro cella."},
	{"id": "rete_ferma", "title": "Una macchina senza vena", "cap": "rete_flusso",
		"text": "Questa macchina non tocca nessuna vena: posane una sotto di lei con la Pinza, fino a una sorgente (Tamburo, Foglia-lanterna, Mulino…). L'[b]Occhio delle vene[/b] dice tutto di una rete."},
	{"id": "tempesta_linfa", "title": "La Tempesta di Linfa", "cap": "rete_tempesta",
		"text": "Le sorgenti danno di più, ma le vene di radice e di legnoferro tese si spezzano. Una [b]Valvola di sfogo[/b] sulla rete la protegge; le vene isolate con la gelatina non si spezzano."},
	{"id": "centrale", "title": "Una Centrale dei Seminatori", "cap": "rete_centrali",
		"text": "Il cuore dorme: un [b]cristallo di Linfa[/b] lo sveglia. Poi ripara la vena d'ambra del pavimento (lo scrigno all'ingresso ha ciò che serve) e alza le tre leve: la porta della sala interna si apre."},
	{"id": "succhiavena", "title": "Qualcosa beve le vene", "cap": "rete_creature",
		"text": "Un [b]Succhiavena[/b] ha bevuto una vena di radice. Le vene di legnoferro (e più dure) non le toccano, e nemmeno quelle isolate con la gelatina."},
	# Roadmap 20 «Il motore comune»
	{"id": "maestria", "title": "Il primo grado", "cap": "pilastri",
		"text": "Un pilastro è salito di grado: ciò che fai nel suo campo lo fa salire, e ogni grado dà un premio. Il [b]Libro dei pilastri[/b] ({pilastri}) mostra tutti e dieci i pilastri, a che punto sei e che cosa dà il grado dopo."},
]


static func by_id(id: String) -> Dictionary:
	for c in LIST:
		if String(c["id"]) == id:
			return c
	return {}
