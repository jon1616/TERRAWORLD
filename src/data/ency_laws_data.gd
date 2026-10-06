class_name EncyLawsData
## Enciclopedia, quinta parte (Roadmap 10 «Le leggi dei mondi»): acqua e liquidi, vento e tempo, gravità e forme dei
## mondi, terra viva, il tempo dei mondi. Stesso formato di `EncyGuideData`; ogni voce aggiunge qui il suo capitolo.

const CHAPTERS := [
	{"id": "acqua", "group": "Le leggi dei mondi", "name": "L'acqua", "text":
"""In ogni mondo ci sono [b]conche d'acqua[/b] nelle grotte; il gene [url=gene:sorgenti]Sorgenti[/url] ne mette molte di più, e il gene [url=gene:sommerso]Sommerso[/url] copre quasi tutto il mondo con un mare (la partenza è su un'isola).
L'acqua [b]scorre[/b]: cade se sotto c'è posto e si allarga verso il basso. Nasce ferma; si muove quando la tocchi (scavando accanto a un lago lo apri, e l'acqua esce).
[b]Nuotare[/b]: nell'acqua si galleggia piano e si corre più lenti; tenendo il salto si nuota verso l'alto. Nell'acqua non ci si fa male cadendo.
[b]Respiro[/b]: con la testa sott'acqua il respiro cala (i pallini in alto a destra); finito, si perde Vita. Le [b]Branchie di muschio[/b] (Telaio) lo fanno durare tre volte tanto.
[b]Creature d'acqua[/b]: il Pesce lume (docile, lascia le squame per le Branchie) e l'Anguilla di Linfa (morde chi nuota). Fuori dall'acqua boccheggiano.
Il [b]Secchio di radice[/b] (Ceppo) raccoglie una cella piena di liquido e la versa altrove."""},
	{"id": "liquidi", "group": "Le leggi dei mondi", "name": "Linfa e brace liquide", "text":
"""Oltre all'acqua scorrono altri due liquidi, con le stesse regole:
• la [b]Linfa[/b], che brilla di luce turchese, [b]cura[/b] chi ci sta dentro e fa crescere il doppio più in fretta le colture vicine. I laghi di Linfa del gene [url=gene:laghi_linfa]Laghi di Linfa[/url] hanno sul fondo il cristallo rappreso; qualche pozza c'è nelle Profondità di ogni mondo;
• la [b]brace liquida[/b], densa e lenta, che fa luce rossa e [b]brucia[/b] chi ci cade dentro, creature comprese. I fiumi del gene [url=gene:fiumi_brace]Fiumi di brace[/url] sono di brace vera; qualche pozza c'è nel Fondo di ogni mondo.
[b]Quando si toccano[/b]:
{cat_reazioni_liquidi}
Con il secchio si portano: un ponte di pietra di brace su un fiume di brace, una pozza di Linfa accanto all'orto, un fossato di brace attorno alla casa.

[b]Spostare molto liquido[/b]
• L'[b]Otre di legnoferro[/b] (6 celle, al Telaio) e l'[b]Anfora d'ambra[/b] (20 celle, al Maglio): clic su un liquido lo raccoglie dall'alto dello specchio, clic altrove lo versa. La scheda dice che cosa contengono.
• Le [b]fonti[/b] versano senza fine il loro liquido accanto alla bocca, finché il bacino non sale fino a lei: la [b]Fonte di muschio[/b] (acqua, al Ceppo), la [b]Fonte di Linfa[/b] (al Maglio), la [b]Bocca di brace[/b] (al Baccello ardente). Lavorano quando sei vicino.
• Scavando un canale il liquido scorre da solo verso il basso: così si svuota una grotta allagata o si riempie una conca. Un bacino di almeno {min_specchio} celle piene è uno specchio in cui si può pescare."""},
	{"id": "pesca", "group": "Le leggi dei mondi", "name": "La pesca", "text":
"""Un'attività da fare quando vuoi: non serve per andare avanti, ma dà cibo, materiali, trofei e pesci che non si trovano in nessun altro modo.

[b]Come si pesca[/b]
Con una [b]canna[/b] in mano, clic su uno specchio di liquido (o appena sopra): la lenza parte e il galleggiante si posa sul pelo. Aspetta: quando un pesce abbocca il galleggiante va sotto, e il pesce sale da solo nella Bisaccia. Se ti allontani o cambi oggetto, la lenza si ritira.

[b]Dove[/b]
Serve uno specchio di almeno {min_specchio} celle piene: gli stagni di superficie (tanti nelle Torbiere e nelle paludi), i laghetti delle grotte, i laghi di Linfa delle Profondità, quelli di brace del Fondo. Puoi fartene uno: scava una conca e riempila con l'otre, l'anfora o una fonte ([url=cap:liquidi]i liquidi[/url]).
Ogni specchio ha i suoi pesci: conta il liquido, lo strato, il bioma (in superficie), quanto è profondo, e poi la notte, la stagione, il tempo e i geni del mondo. Il mare del gene Sommerso ha pesci tutti suoi.

[b]Le canne[/b]
La [b]Canna di radice[/b] (al Ceppo) pesca solo nell'acqua. Le canne di metallo (al Maglio) hanno la fortuna di pesca (pesci più rari), l'attesa più breve e i liquidi del loro materiale: la Linfa con i materiali di Linfa o di luce, la brace con quelli di brace o di grado alto. La scheda della canna dice tutto.

[b]Esche, accessori e tempo[/b]
• Le [b]esche[/b] (Pallottola d'humus e Esca di petali di lume a mano, Esca di squama al Ceppo, Esca iridata al Maglio) alzano la fortuna e accorciano l'attesa: a ogni pesce si consuma la migliore che hai nella Bisaccia. Senza esche si pesca lo stesso.
• Gli accessori: il [b]Galleggiante di lume[/b] (attesa più breve), l'[b]Amo d'ambra[/b] (fortuna di pesca), la [b]Sacca del pescatore[/b] (pesci più grandi, e a volte due in una volta).
• Il tempo conta: con la pioggia, i temporali e la nebbia i pesci abboccano prima, e ancora di più all'alba e al tramonto; un po' anche di notte. Con la bufera, invece, più piano. Alcuni pesci si fanno vedere solo di notte, in una stagione o con un certo tempo: l'Erbario lo dice.

[b]Che cosa ci fai[/b]
• Ogni pesce si [b]pulisce[/b] a mano (in Creare): dà i filetti del suo liquido (acqua, Linfa, brace); i pesci rari e leggendari danno il [b]filetto pregiato[/b].
• Con i filetti si cucina: [b]Pesce arrosto[/b] e [b]Spiedo ardente[/b] al Baccello ardente, [b]Zuppa di pesce[/b], [b]Guazzetto di Linfa[/b] e [b]Piatto del pescatore[/b] al Paiolo. Curano e danno un effetto (sazio, vista nel buio, vigore, fortuna), senza l'attesa delle pozioni.
• A volte abbocca una [b]cassa[/b] al posto del pesce: la Cassetta d'alga negli stagni, il Forziere sommerso nelle grotte, lo Scrigno del Fondo nel profondo, nella Linfa e nella brace. Clic per aprirla: dentro il bottino delle rovine, a volte una [b]Perla di stagno[/b] e, di rado, uno dei sei tesori della serie [b]Tesori delle acque[/b] (completa: più fortuna di pesca e pesci più grandi per sempre).
• Le perle si trovano anche attaccate alla lenza: tre fanno una Collana di perle.

[b]Il Pescatore[/b]
Quando hai pescato cinque pesci, al tuo Focolare (con un letto libero) si ferma il [b]Pescatore[/b]: vende canne, esche, galleggianti, l'otre e la Fonte di muschio, compra i pesci (i rari valgono molto) e ha tre richieste tutte sue. Anche la [b]Bacheca[/b] a volte chiede pesci che hai già pescato, e in fondo agli obiettivi ce ne sono tre della pesca: niente di tutto questo è obbligatorio.

[b]L'Erbario dei pesci[/b]
Ogni pesce pescato entra nella scheda [b]Pesci[/b] dell'Erbario, con quanti ne hai presi e il più grande: la scheda sta a parte e non conta nella percentuale. Anche un pesce mai pescato dice dove cercarlo."""},
	{"id": "meteo", "group": "Le leggi dei mondi", "name": "Vento e tempo atmosferico", "text":
"""In superficie il tempo cambia ogni poche ore di gioco, secondo la stagione, i biomi del mondo e i geni [url=gene:piovoso]Piovoso[/url], [url=gene:ventoso]Ventoso[/url] e [url=gene:nebbioso]Nebbioso[/url]. L'orologio dice che tempo fa. Sotto terra non arriva.
{cat_meteo}
Il [b]vento[/b] (in tutti i tempi, più forte nei temporali e nelle bufere) spinge chi è in aria, e ancora di più chi plana; devia i dardi e gli incantesimi: tieni conto del vento quando tiri. Il [b]Mantello del vento[/b] (Telaio, con la Fulgorite) fa planare e ti lascia spingere poco; l'[b]Amuleto della tempesta[/b] (Maglio) dà un salto in aria in più.
Nei [b]temporali[/b] i fulmini cadono vicino a te: feriscono chi è vicino e a volte lasciano la [b]Fulgorite[/b]. Nella [b]tempesta di cenere[/b] riparati dove c'è una parete dietro di te."""},
	{"id": "forme", "group": "Le leggi dei mondi", "name": "Gravità e mondi strani", "text":
"""Alcuni geni di forma cambiano le leggi stesse del mondo. Si trovano nei Semi di vigore alto, e si leggono sulla scheda del portale prima di partire.
[b][url=gene:lieve]Lieve[/url][/b] (vigore 2+): la gravità è quasi la metà. Il salto arriva quasi al doppio, le cadute sono lente e fanno meno male; ma anche le creature saltano e ricadono piano, e i dardi volano dritti più a lungo. Le montagne sono più alte: tanto le scavalchi.
[b][url=gene:guscio]Guscio[/url][/b] (vigore 3+): la superficie è [i]dentro[/i] il mondo. Sopra gli alberi, a una quarantina di tessere, c'è un tetto di roccia; dietro l'aria c'è la parete, quindi è buio come in una grotta. La luce viene dalle gocce di Linfa e dai baccelli appesi al tetto, e dai [b]pozzi di sole[/b], buchi nel tetto da cui scende il giorno: uno è sempre vicino alla partenza. Sotto il tetto non piove e non c'è vento. Porta torce: qui servono dal primo passo.
[b][url=gene:arcipelago]Arcipelago[/url][/b] (vigore 2+): la terra si spezza in pilastri separati da voragini profonde, con un lago sul fondo (cadere in acqua non ferisce). Sopra le voragini galleggiano isole, alcune con uno scrigno. In ogni voragine sale una [b]corrente d'aria[/b] (foglie e scintille che volano in su): entraci tenendo premuto il salto e ti solleva fino sopra i pilastri; poi sposta il salto verso l'isola che vuoi. Il peso è un po' minore che altrove.
Tutti e tre hanno il loro Cuore del mondo nel Fondo, come ogni mondo: si giocano dall'inizio alla fine."""},
	{"id": "terra_viva", "group": "Le leggi dei mondi", "name": "La terra viva", "text":
"""In alcuni mondi la terra non sta ferma: cambia mentre la esplori, e anche quando sei altrove. Tornando in un mondo così dopo qualche ora, un avviso racconta cosa è cambiato.
[b][url=gene:radici_vive]Radici vive[/url][/b]: ogni tessera che scavi sotto la superficie (fino al Sottobosco di radici) si richiude di radice dopo qualche minuto di gioco o d'assenza. Le radici non crescono addosso a te, non passano le [b]pareti costruite[/b] con il Martello e stanno lontane dalla [b]luce delle torce[/b]: per tenere aperta una galleria, illuminala o murala. La radice si scava in fretta, ma un cunicolo lasciato al buio non ti aspetta.
[b][url=gene:cristalli_vivi]Cristalli vivi[/url][/b]: i cristalli di Linfa crescono di una tessera ogni tanto, e mentre sei via una ogni dieci minuti. Un banco di cristallo scavato oggi torna a dare cristalli domani: è un motivo per tornare.
[b][url=gene:frane]Frane[/url][/b]: humus ed erba senza niente sotto cadono, e la terra sopra li segue. Scavando sotto una collina puoi farla franare in testa (fa male); le radici degli alberi e le stazioni tengono ferma la terra su cui poggiano. Anche utile: una frana chiude un cunicolo dietro di te."""},
	{"id": "tempo_mondi", "group": "Le leggi dei mondi", "name": "Il tempo dei mondi", "text":
"""Un giorno normale dura venti minuti. Alcuni geni del tempo lo cambiano, e con lui che cosa si può fare e quando.
[b][url=gene:giorni_brevi]Giorni brevi[/url][/b]: un giorno intero in otto minuti; le notti arrivano spesso, con le loro creature. [b][url=gene:giorno_lento]Giorno lento[/url][/b]: quasi un'ora per giorno; lunghe esplorazioni alla luce, e notti lunghissime.
[b][url=gene:eclissi]Eclissi[/url][/b]: ogni giorno a mezzogiorno il sole si spegne per un paio di minuti. Escono le creature della notte, e chi sconfiggi durante l'eclissi può lasciare la [b]Polvere d'eclissi[/b]: serve per l'[b]Amuleto dell'eclissi[/b] (alone più grande, le creature ti vedono meno) e per la [b]Lanterna della notte eterna[/b]. Aspetta il mezzogiorno in superficie, pronto a combattere.
[b][url=gene:notte_eterna]Notte eterna[/url][/b] (vigore 3+): il sole non sorge mai. Sempre le creature della notte, più pericolo e più Lumini. [b][url=gene:senza_sole]Senza sole[/url][/b] (vigore 3+): il cielo non fa luce, nemmeno la luna; si vede solo ciò che brilla da sé (funghi, baccelli, cristalli, torce), ma le creature sono quelle del giorno.
Nei mondi bui le colture crescono a meno di un terzo, tranne vicino a una torcia o a una pozza di Linfa: l'orto va illuminato."""},
	{"id": "vigore", "group": "Senza fine", "name": "Il vigore senza tetto", "text":
"""Il vigore di un mondo non ha un tetto: ogni Seme raccolto porta al mondo dopo, e si può salire per sempre. Ogni cinque punti arriva un [b]grado[/b], e ogni grado porta cose nuove, non solo creature più forti.
{cat_gradi}
Le [b]Schegge di vigore[/b] le lasciano solo le creature dei mondi di vigore 5 e oltre, di più più il grado è alto; un Guardiano ne lascia un mucchio. Al [b]Maglio dei Seminatori[/b], con un attrezzo, un'arma o un'armatura in mano, clic destro: la [b]tempra[/b] lo rafforza di un livello (+8% a danno e Scorza, più forza al piccone). Ogni tre livelli di tempra si apre un [b]posto d'innesto[/b] in più, oltre i soliti. Il livello n costa 4 × n Schegge.
Il Maglio tempra fino a due livelli per grado del mondo in cui si trova: in un mondo di vigore 10 fino a +4, in uno di vigore 20 fino a +8. Le tempre alte si fanno solo nei mondi più vigorosi: è sempre un motivo per andare più in là."""},
	{"id": "guardiani_generati", "group": "Senza fine", "name": "I Guardiani generati", "text":
"""I primi tre mondi hanno i Guardiani che i Seminatori conoscevano: il Nodo Avvizzito, la Regina delle Spore, il Colosso d'Ardesia. Dal vigore 4 al 12 ci sono nove Guardiani che gli abitanti chiamano con un soprannome, perché il loro nome non lo ricorda più nessuno: la Falena del primo buio, il Tessitore delle radici, la Marea muta, il Mietitore di stelle, l'Ospite del Vuoto, la Madre di brace, la Voce della bufera, il Giardiniere spento, l'Eco del Seminatore. Ognuno ha due fasi: a metà Vita arrivano attacchi nuovi e cambia elemento. Alcuni cambiano anche il Cuore: pilastri, maree, correnti.
Ogni Guardiano della spina lascia il suo [b]Sacchetto[/b]: una o due armi firma della sua fase, il suo Richiamo per rievocarlo al Cerchio, lingotti, Lumini e, la prima volta di sicuro, poi a volte, il suo [b]gioiello[/b] (un accessorio solo suo); raramente il suo [b]trofeo[/b]. Rievocato al Cerchio, lascia di nuovo il Sacchetto.
Dal vigore 13 in poi ogni mondo ha un [b]Guardiano suo[/b], nato dal mondo stesso: sempre diverso, sempre lo stesso per quel mondo.
Il suo [b]corpo[/b] viene da una delle famiglie di creature, reso gigante, spinoso e del colore del suo [b]elemento[/b]. Il nome dice il suo titolo, la specie e l'elemento. Ha due o tre [b]attacchi[/b] scelti tra ventagli di colpi, scatti, cariche, tiri, bombe dall'alto, salti, lampi (sparisce e ricompare) ed evocazioni della sua specie; solo quelli che il suo corpo sa fare. A metà Vita entra nella [b]seconda fase[/b]: cambia elemento (e con lui le debolezze: guarda la scheda sopra di lui) e diventa più svelto.
Come tutti i Guardiani si sconfigge o si cura con la Rugiada sui quattro nodi. Sconfitto lascia il [b]Nucleo[/b] del suo elemento, curato la [b]Linfa dei Guardiani[/b]; con sei Nuclei e quattro Linfe il Maglio fa il [b]talismano[/b] di quell'elemento. Sei elementi, sei talismani: per averli tutti servono Guardiani di tutti gli elementi, sia sconfitti che curati."""},
	{"id": "leggende", "group": "Senza fine", "name": "Semi leggendari e Seme Primo", "text":
"""Un Seme è [b]leggendario[/b] quando porta insieme i tre geni di una leggenda. Sono geni di categorie diverse e almeno uno è stellare: si mettono insieme innestando (Banco dell'Innestatrice), con le Fiale e con i geni delle firme dei mondi. Il nome del Seme cambia appena li ha tutti.
{cat_leggende}
Il mondo di un Seme leggendario ha il doppio di creature rare e di Lumini; quando il suo Guardiano è curato o sconfitto, il Cuore dona un [b]oggetto unico[/b] della leggenda e tre Linfe antiche.
Il [b]Seme Primo[/b] è il traguardo più lontano. Lo dona l'Albero-Madre, da solo, quando sono vere tutte e tre le cose:
{cat_primo}
Nasce il [b]Primo Mondo[/b]: tutti i biomi, quattro geni stellari, il vigore più alto che conosci più cinque. Il suo Cuore dona il [b]Germoglio del Primo[/b]. E dopo il gioco continua: il vigore non ha tetto, le leggende restano da compiere, e i Semi con le loro sfide."""},
	{"id": "sfide", "group": "Senza fine", "name": "Le sfide dei Semi", "text":
"""Per chi ha già tutto, e per chi vuole mettersi alla prova. Al Maglio si fanno i [b]Sigilli di sfida[/b] (Lumini e cristalli di Linfa); con il Sigillo in mano, clic su un portale verso un mondo [b]mai visitato[/b]: quel mondo porterà la sfida. La scheda del portale la mostra, e sotto l'orologio compare la riga della sfida con il tempo.
{cat_sfide}
Si [b]vince[/b] risolvendo il Guardiano del Cuore (curato o sconfitto) senza rompere la regola; si [b]perde[/b] se la regola si rompe, e il mondo resta, senza la sfida. Ogni vittoria dà Linfa antica, Schegge di vigore e Lumini (di più più il livello è alto), la prima anche una [b]medaglia[/b]. E alza il [b]livello[/b] di quella sfida: la prossima volta è più dura (meno tempo, meno Vita) e rende di più, senza fine.
I tuoi [b]record[/b] (vittorie, livello, tempo migliore) sono qui sotto e nel Semenzaio (tasto K), nella scheda del Taccuino.
{cat_record}"""},
	{"id": "eventi_capi", "group": "Senza fine", "name": "Gli eventi con un capo", "text":
"""Oltre alla Pioggia di stelle, alla Notte dell'Avvizzimento e alla Fioritura, ci sono otto eventi con un [b]capo[/b]: l'assalto dei rovi, la notte delle falene, la migrazione dei cervi, la pioggia di stelle viva, lo sciame di metallo, la marea di Linfa nera, l'invasione dei Seminatori caduti, l'eclissi del Vuoto. Gli ultimi tre vengono solo dopo il Risveglio del Cuore; ognuno dai mondi di un certo vigore.
Mentre dura, le sue creature nascono più spesso. Quando ne hai sconfitte abbastanza (la riga sotto la minimappa conta), arriva il capo dell'evento: il premio è il suo bottino, cioè la sua arma (sicura la prima volta), un ricordo da indossare, Linfa antica e il [b]segnale[/b] dell'evento. Il segnale (anche al Cerchio, con Lumini e cristalli di Linfa) chiama l'evento quando vuoi."""},
	{"id": "capi", "group": "Senza fine", "name": "Capi erranti e boss facoltativi", "text":
"""[b]I capi erranti[/b] sono ventiquattro creature fuori misura, due per ogni vigore dal primo al dodicesimo: una vive più in alto, l'altra più in basso. Te li trovi davanti esplorando, nello strato giusto dei mondi del loro vigore (e fino a due vigori dopo), una volta per mondo; un avviso dice quando ti hanno sentito. A metà Vita si infuriano. Lasciano le loro cose: la loro [b]arma[/b] (sicura la prima volta), un [b]gioiello[/b], la loro [b]reliquia[/b] e, raro, il trofeo.
[b]I boss facoltativi[/b] sono dieci, fuori dalla strada dei Guardiani, per chi vuole la sfida. Si chiamano al Cerchio dei Seminatori con un'[b]esca[/b] fatta lì, con le reliquie di due capi erranti e i lingotti del loro grado. Combattono almeno con la forza di un mondo del loro vigore, anche se li chiami in un mondo più facile, e lasciano il loro [b]Sacchetto[/b]: armi firma della fase dopo e il loro gioiello.
[b]I superboss del dopo[/b] (la Stella nera, la Radice del Vuoto, il Primo Sogno) si chiamano allo stesso modo, con le reliquie dei capi più forti e la Linfa antica. Hanno la forza dei mondi dal vigore 15 al 21, e i loro gioielli sono i più forti del gioco.
[b]La corsa dei Guardiani[/b]: con i dodici Richiami si fa al Cerchio il [b]Corno della corsa[/b]. Chiama i dodici Guardiani della spina uno dopo l'altro. Chi li batte tutti senza appassire vince armi firma dell'ultima fase, Linfa antica e, la prima volta, la [b]Corona della corsa[/b]."""},
	{"id": "evocazioni", "group": "Senza fine", "name": "Evocare i Guardiani", "text":
"""Un Guardiano che hai già affrontato (curato o sconfitto) non è perso: lo puoi [b]evocare[/b] di nuovo, quando vuoi, per il suo bottino.
Serve il [b]Cerchio dei Seminatori[/b] (Maglio: pietre dei Seminatori, cristalli di Linfa, torce). Piazzalo dove vuoi combattere: vicino al Cerchio, con il [b]Richiamo[/b] del Guardiano in mano, un clic lo risveglia. Il Richiamo di un Guardiano della spina è nel suo [b]Sacchetto[/b]. I primi tre si fanno anche al Cerchio, con i materiali del loro Guardiano:
{cat_richiami}
I Guardiani generati dei mondi di vigore 13 e oltre lasciano, la prima volta, il loro [b]Sigillo[/b]: ricorda proprio quel Guardiano (specie, attacchi, elemento). Con il Sigillo in mano e un [b]Seme d'eco[/b] (Cerchio: Lumini e cristalli di Linfa) lo richiami; il Sigillo resta, il Seme d'eco si consuma.
Finché lo scontro dura, attorno al Cerchio non nasce nessun'altra creatura. Un Guardiano evocato lascia i suoi materiali (meno del primo incontro), mai i doni per sempre: niente Semi di mondo, Linfa antica o Vita in più."""},
]
