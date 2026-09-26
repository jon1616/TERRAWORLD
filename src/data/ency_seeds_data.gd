class_name EncySeedsData
## Enciclopedia (27 set 2026), terza parte: i Semi, i geni, i mondi, il Giardino e l'Albero-Madre.
## Stesso formato di `EncyGuideData`. Le voci della Roadmap 9-11 aggiungono qui i loro capitoli.

const CHAPTERS := [
	{"id": "semi", "group": "Semi e mondi", "name": "I Semi di mondo", "text":
"""Un [b]Seme di mondo[/b] è un mondo che aspetta di nascere. Ha un [b]genoma[/b]: un gene di superficie (che bioma sarà il mondo, e dà il nome al Seme), al più un gene per ogni altra [url=cap:geni]categoria[/url], e il [b]vigore[/b].
[b]Il vigore[/b] è quanto è forte il mondo: ogni punto dà alle creature il {vigor_pct}% di Vita e danno in più, ma anche vene più grandi, materiali migliori e Guardiani nuovi. Un Seme raccolto in un mondo di vigore N nasce di vigore N+1.
Dove si trovano: il primo te lo dà l'Albero-Madre; poi dal Cuore guarito di ogni mondo, dalle [b]piante-seme[/b] selvatiche, dalla [url=cap:bacheca]Bacheca[/url], dal Mercante di Semi, dall'[url=cap:innesto]innesto[/url].
La scheda di un Seme (mouse sopra o Esamina) mostra i suoi geni; quelli che non hai mai visto sono «?»."""},
	{"id": "portali", "group": "Semi e mondi", "name": "Aiuole e portali", "text":
"""I Semi si piantano solo nelle [b]Aiuole[/b] del Giardino (clic con il Seme in mano). L'Aiuola diventa un [b]portale[/b]: clic destro una volta per sapere dove porta, un'altra per partire. Con il mouse sopra, la scheda del mondo: nome, vigore, Guardiano, stagione, geni, e se l'hai già visitato quanto l'hai esplorato.
Nel mondo nuovo c'è un portale di ritorno accanto alla partenza.
All'inizio hai [b]una[/b] Aiuola; l'Albero-Madre te ne dona altre crescendo.
Dal [url=cap:semenzaio]Semenzaio[/url] si può [b]chiudere[/b] un mondo: il portale torna Aiuola e ti resta in mano il suo [b]Seme dormiente[/b], che ripiantato riapre lo stesso mondo, com'era."""},
	{"id": "geni", "group": "Semi e mondi", "name": "I geni", "text":
"""I geni decidono come sarà un mondo: forma del terreno, grotte, sottosuolo, minerali, gemme, rovine, creature, stirpi rare, flora, cielo, tempo, ombra (l'Avvizzimento). Ogni gene ha una [b]rarità[/b] ({cat_rarita}) e una [b]dominanza[/b] (quanto facilmente passa ai figli negli innesti). Alcuni nascono solo per [b]mutazione[/b], solo nei mondi di vigore alto, solo dalle firme o solo in una stagione.
Un gene è [b]visto[/b] quando entri in un mondo che lo porta, [b]imparato[/b] quando hai la sua Fiala: solo i geni imparati si possono fissare negli innesti.
Le categorie:
{cat_categorie_geni}
Tutti i geni: [url=cat:geni]il catalogo dei geni[/url] (quelli non ancora visti restano nascosti)."""},
	{"id": "provetta", "group": "Semi e mondi", "name": "Trovare i geni", "text":
"""Tre strade in ogni mondo:
• la [b]Provetta di Linfa[/b]: clic su ciò che porta un gene (erba e terra per la superficie, aria delle grotte, rocce profonde, vene di minerale, gemme, pietra dei Seminatori, alberi, cielo aperto, terra avvizzita; vicino alla firma, un gene della firma) e ottieni la [b]Fiala[/b] di quel gene del mondo. Se il mondo non ha geni di quella categoria la Provetta non si consuma;
• le [b]piante-seme[/b] selvatiche (clic destro): una Fiala, o un Seme selvatico figlio del mondo (a volte mutato);
• le [b]creature[/b]: a volte lasciano la Fiala del gene di fauna del mondo; le rare quella delle stirpi; le creature di stagione quella della loro stagione.
Ogni Fiala che entra nella Bisaccia ti fa imparare il suo gene."""},
	{"id": "innesto", "group": "Semi e mondi", "name": "L'innesto dei Semi", "text":
"""Al [b]Banco dell'Innestatrice[/b] due Semi danno un [b]Seme figlio[/b]: per ogni categoria il figlio prende il gene di uno dei due genitori (più spesso quello più dominante). Prima di innestare il banco mostra le probabilità.
• Una [b]Fiala[/b] di un gene imparato lo [b]fissa[/b] nel figlio (solo nelle categorie che l'Albero-Madre ti ha aperto).
• Ogni innesto costa una [b]Linfa antica[/b] (dalle firme dei mondi).
• A volte nasce una [b]mutazione[/b]: un gene che nessuno dei due aveva; alcune coppie di geni fanno nascere più spesso geni segreti.
Così si [b]progettano[/b] i mondi: il gene giusto per la richiesta giusta."""},
	{"id": "firme", "group": "Semi e mondi", "name": "Le firme dei mondi", "text":
"""Ogni mondo ha una [b]firma[/b]: un luogo unico che si trova solo lì (un albero colossale, il cratere di una stella…), scelto dai suoi geni. Avvicinandoti la [b]trovi[/b]: una scritta la presenta e la mappa la segna con una stella. Lì c'è il suo [b]ricordo[/b] (oggetto da collezione, uno per mondo) e [b]Linfa antica[/b], e vicino si trovano i suoi geni.
{cat_firme}"""},
	{"id": "semenzaio", "group": "Semi e mondi", "name": "Il Semenzaio", "text":
"""Il [b]Semenzaio[/b] ({k_semenzaio}) ha due parti:
• [b]Mondi[/b]: tutti i mondi del tuo Giardino con vigore, geni, quanto li hai esplorati, se hai trovato la firma; da qui si chiude un mondo (Seme dormiente).
• [b]Genario[/b]: tutti i geni per categoria, visti, imparati o ancora sconosciuti, con dove si prelevano."""},
	{"id": "albero_madre", "group": "Il Giardino", "name": "L'Albero-Madre", "text":
"""L'Albero-Madre dorme al centro del Giardino. Si sveglia per [b]stadi[/b] ({stages}): ogni stadio chiede delle [b]offerte[/b] (materiali, geni imparati, creature sconfitte, mondi visitati, Frammenti dell'Albero) e, quando le hai date tutte, [b]si risveglia[/b] un poco e ti dona qualcosa: Aiuole, poteri, abitanti, categorie di geni da innestare, pagine di storia. Cresce anche a vedersi.
Clic destro sull'Albero: le offerte (si danno dalla Bisaccia) e gli stadi. La riga in alto a sinistra dice cosa chiede adesso.
{cat_stadi}"""},
	{"id": "poteri", "group": "Il Giardino", "name": "Poteri e Sigilli", "text":
"""Alcuni stadi dell'Albero-Madre donano un [b]potere[/b] al Germogliato:
{cat_poteri}
In ogni mondo ci sono [b]luoghi sigillati[/b]: stanze chiuse da un [b]Sigillo[/b] che il piccone non scalfisce, ognuno nel suo strato. Clic destro con il potere giusto e il Sigillo si dissolve. Il Sigillo velato sembra ardesia: lo mostra solo la Vista della Linfa. Nel cielo ci sono anche nidi alti, raggiungibili con il salto e le radici-ponte.
Dentro: uno scrigno e un [b]Frammento dell'Albero[/b], che gli stadi più alti chiedono."""},
	{"id": "bacheca", "group": "Il Giardino", "name": "La Bacheca dei Giardinieri", "text":
"""Nel Giardino, accanto alla partenza. Clic destro: ci sono sempre [b]quattro richieste[/b], costruite da ciò che conosci già (materiali trovati, famiglie incontrate, geni visti, poteri), così sono sempre fattibili: forniture, materiali dei geni, caccia, mandria, prodotti, firme, viaggi, Sigilli. Più scopri, più sono varie.
Premi: Lumini, Fiale, Provette, Linfa antica, Polvere iridata e il più ambito, un [b]Seme di mondo con un gene raro[/b]. «Cambia» sostituisce una richiesta che non ti piace."""},
	{"id": "obiettivi", "group": "Il Giardino", "name": "Obiettivi, Erbario e storia", "text":
"""Gli [b]obiettivi[/b] ({n_obiettivi}) accompagnano tutta la partita; i prossimi tre sono sotto l'orologio, e danno premi.
L'[b]Erbario[/b] ({k_erbario}) raccoglie ciò che hai scoperto: creature (quante ne hai sconfitte), famiglie (con indizi su dove cercare quelle che mancano), oggetti, pagine di storia.
Le [b]pagine di storia[/b] si trovano curando o sconfiggendo i Guardiani, aprendo i portali, svegliando l'Albero-Madre: raccontano chi erano i Seminatori e che cosa è successo al cosmo."""},
]
