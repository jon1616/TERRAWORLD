class_name EncyCavesData
## Enciclopedia, lo zaino e le grotte piene (Roadmap 30): Bisacce, Dispensa, basto, «Non raccogliere»; i raccolti
## delle piante, i baccelli dormienti, i piccoli incontri, il diario di Tessa, le curiosità degli strati.
## Stesso formato di `EncyGuideData`.

const CHAPTERS := [
	{"id": "zaino", "group": "La guida", "name": "Lo zaino", "text":
"""La **Bisaccia** è la barra rapida più nove **scomparti**, uno per tipo, da 30 caselle ciascuno (più la Raccolta, senza limite). Al Telaio si cuciono **Bisacce** più grandi, con i materiali di strati sempre più profondi, e ognuna ingrandisce **tutti** gli scomparti: di seta (40), cucita di radicite (50), di legnoferro (60), d'ambra (75), della Linfa (90). Ciò che contengono resta; uno scomparto più grande di una pagina si sfoglia cliccando di nuovo la sua scheda.

Gli **scomparti fissi** (la scheda con la freccia) sono otto caselle: quattro per le munizioni (dardi, esplosivi, giavellotti), due per le torce, due per i Lumini. Ciò che è del loro tipo ci va da solo, dopo aver completato la pila che hai già nella barra rapida; quando quella pila finisce, si riempie da lì. **Appassendo restano addosso**, come la Raccolta: nel fagotto finiscono solo gli scomparti per tipo. Il tasto Q e le casse non li toccano.

Per tenere qualcosa sempre con te, **Alt+clic** su una casella della Bisaccia la **blocca** (compare un lucchetto; un altro Alt+clic la sblocca): il tasto Q, «Nelle casse», «Deposita tutto» e «Deposita simili», il Seme della Dispensa non la toccano, e «Riordina» la lascia dov'è.
Il **basto** va a una creatura della [url=cap:mandria]mandria[/url] che ti segue (clic con il basto in mano): finché è con te porta altre caselle, una in più ogni due livelli, e ci finisce ciò che non entra più nella Bisaccia.
La **Dispensa del Giardiniere** (al Ceppo) è una cassa che appartiene a te, non al mondo: quello che ci metti lo ritrovi in ogni Dispensa di ogni mondo. Il Seme della Dispensa (un clic) ci manda da ovunque ciò che contiene già e i materiali; il Cuore della Dispensa la apre dove sei. Ognuno, la prima volta, la fa crescere: 60, 120, 200 caselle. Poi, al Maglio, la **Radice** (lingotti di Linfa: 320 caselle), il **Geode** (vuotite forgiata: 480) e la **Stella della Dispensa** (lingotti stellari: 720); ognuno si fa dal precedente e apre la Dispensa dove sei.
Per non riempirti di ciò che non ti serve, posa un oggetto in Esamina e premi il pulsante sotto: **Raccogli**, **Non raccogliere** (resta a terra) o **Dritto nel Cestino**."""},
	{"id": "raccolti", "group": "Le leggi dei mondi", "name": "I raccolti delle piante", "text":
"""Ogni pianta dei biomi (le erbe, i cespugli, i fiori, le canne, i funghi, i cristalli di brina…) tolta con un clic lascia il **raccolto** del suo bioma: l'erba bassa una volta su tre, le altre sempre. Ognuno serve a qualcosa: le **fibre** fanno Corda di liana al Telaio, i **petali** e i cardi si pestano a mano in una tintura del loro colore, **bacche e funghi** si mangiano (un po' di Vita o di Linfa), le **resine** e le schegge di vetro fanno vetro, la **carbonella** fa torce, lo **zolfo** fa baccelli esplosivi, i **sassi** fanno mattoni o si vendono, e i raccolti **rari** (fiori di pietra, scintille di stella, semi runici…) fanno, a dodici, una Polvere iridata all'Alambicco."""},
	{"id": "ritrovamenti", "group": "Le leggi dei mondi", "name": "Casse dei biomi, mimi, rari e la Pozza", "text":
"""Ogni bioma ha la sua [b]cassa[/b]: la trovi nelle rovine sotto di lui (quelle del cielo negli osservatori), con oggetti che vengono solo da lì. La [b]cassa sigillata[/b] del bioma ha oggetti più forti e si apre solo con la [b]chiave del bioma[/b], che le sue creature lasciano di rado dopo che hai risolto il tuo primo Guardiano.
Attento: a volte una cassa apre la bocca. È un [b]mimo[/b], uno per bioma: sconfitto, lascia le cose della sua cassa.
Ogni specie ha il suo [b]raro[/b]: un'arma o un accessorio che lascia una volta ogni cinquanta-centocinquanta. Un buon motivo per cacciarla ancora anche quando sei più forte.
In ogni mondo ci sono le [b]strutture[/b] del suo grado e dei suoi biomi: villaggi abbandonati, nidi giganti, templi, fucine sepolte, navi di radice nel cielo. Il tesoro sta dietro un enigma, oppure lo difende un guardiano antico.
Nelle Profondità della Linfa c'è la [b]Pozza di Linfa antica[/b]: dopo il primo Guardiano, tieni in mano un oggetto e toccala, e diventa un altro della sua famiglia (le armi firma di una fase, i rari, i pezzi delle spoglie di un boss, gli elmi degli stili…).
Si dice che due Semi con la coppia giusta di geni possano dare un [b]gene segreto[/b], e un mondo che nessuno ha mai visto."""},
	{"id": "baccelli", "group": "Le leggi dei mondi", "name": "I baccelli dormienti", "text":
"""Sparse per le grotte, a centinaia in ogni strato, ci sono **piccole cose da rompere**: baccelli dormienti, nidi di radice, urne dei Seminatori, geodi, bozzoli di Linfa, e in superficie qualche ceppo cavo. Un clic le apre, e dentro c'è sempre qualcosa: Lumini, torce, dardi, pozioni, minerali dello strato; più si scende, più sono ricche. Ogni tanto una cosa rara (Polvere iridata, Scheggia di vigore, Linfa antica) o una [url=cap:curiosita]curiosità[/url]."""},
	{"id": "incontri", "group": "Le leggi dei mondi", "name": "I piccoli incontri", "text":
"""Nelle grotte di ogni mondo ti aspettano **piccoli incontri**. Si annunciano quando ti avvicini (una scritta e un suono), e una volta visti hanno un segno sulla mappa.
• Lo **zaino di un esploratore**: un bottino, torce, a volte una curiosità e sempre una **Pagina strappata**.
• La **tana**: una camera scavata nella roccia con un mucchio d'ossa pieno di bottino. Chi la abita si sveglia quando entri, e la tana non si apre finché non l'hai sconfitto; se scappi, al ritorno ti aspetta ancora.
• La **vena madre**: un cristallo che pulsa, circondato dal minerale ricco dello strato e sorvegliato. Sconfitti i guardiani, un clic destro sul cristallo dà il suo dono (una volta sola).
• La **camera fungina**: una grotta piena di funghi luminosi, con il fungo re al centro. Il suo dono è una manciata di funghi e spore.
Le **Pagine strappate** sono il diario di Tessa la Cercatrice, che ha fatto questa strada prima di te: usale per leggerle, in ordine. All'ultima delle dieci, la sua lanterna è tua."""},
	{"id": "curiosita", "group": "Le leggi dei mondi", "name": "Le curiosità degli strati", "text":
"""Ogni strato nasconde sei **curiosità**: piccoli ritrovamenti che non servono a creare nulla, ma raccontano chi è passato di lì (una chiocciola vuota, un'ammonite d'ardesia, una perla di Linfa, una chiave senza porta…). Si trovano nei [url=cap:baccelli]baccelli[/url] del loro strato, negli zaini e nelle tane, e in superficie qualche volta tra le piante; quelle che ti mancano escono più spesso. Nel Museo del Giardino ogni serie ha la sua sala, e una sala completa dà un piccolo dono per sempre."""},
]
