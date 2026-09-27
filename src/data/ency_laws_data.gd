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
Con il secchio si portano: un ponte di pietra di brace su un fiume di brace, una pozza di Linfa accanto all'orto, un fossato di brace attorno alla casa."""},
	{"id": "meteo", "group": "Le leggi dei mondi", "name": "Vento e tempo atmosferico", "text":
"""In superficie il tempo cambia ogni poche ore di gioco, secondo la stagione, i biomi del mondo e i geni [url=gene:piovoso]Piovoso[/url], [url=gene:ventoso]Ventoso[/url] e [url=gene:nebbioso]Nebbioso[/url]. L'orologio dice che tempo fa. Sotto terra non arriva.
{cat_meteo}
Il [b]vento[/b] (in tutti i tempi, più forte nei temporali e nelle bufere) spinge chi è in aria, e ancora di più chi plana; devia i dardi e gli incantesimi: tieni conto del vento quando tiri. Il [b]Mantello del vento[/b] (Telaio, con la Fulgorite) fa planare e ti lascia spingere poco; l'[b]Amuleto della tempesta[/b] (Maglio) dà un salto in aria in più.
Nei [b]temporali[/b] i fulmini cadono vicino a te: feriscono chi è vicino e a volte lasciano la [b]Fulgorite[/b]. Nella [b]tempesta di cenere[/b] riparati dove c'è una parete dietro di te."""},
	{"id": "forme", "group": "Le leggi dei mondi", "name": "Gravità e mondi strani", "text":
"""Alcuni geni di forma cambiano le leggi stesse del mondo. Si trovano nei Semi di vigore alto, e si leggono sulla scheda del portale prima di partire.
[b][url=gene:lieve]Lieve[/url][/b] (vigore 2+): la gravità è quasi la metà. Il salto arriva quasi al doppio, le cadute sono lente e fanno meno male; ma anche le creature saltano e ricadono piano, e i dardi volano dritti più a lungo. Le montagne sono più alte: tanto le scavalchi.
[b][url=gene:guscio]Guscio[/url][/b] (vigore 3+): la superficie è [i]dentro[/i] il mondo. Sopra gli alberi, a una quarantina di tessere, c'è un tetto di roccia; dietro l'aria c'è la parete, quindi è buio come in una grotta. La luce viene dalle gocce di Linfa e dai baccelli appesi al tetto, e dai [b]pozzi di sole[/b], buchi nel tetto da cui scende il giorno: uno è sempre vicino alla partenza. Sotto il tetto non piove e non c'è vento. Porta torce: qui servono dal primo passo.
[b][url=gene:arcipelago]Arcipelago[/url][/b] (vigore 2+): la terra si spezza in pilastri separati da voragini profonde, con un lago sul fondo (cadere in acqua non ferisce). Sopra le voragini galleggiano isole, alcune con uno scrigno. In ogni voragine sale una [b]corrente d'aria[/b] (foglie e scintille che volano in su): entraci e ti solleva fino sopra i pilastri; poi sposta il salto verso l'isola che vuoi. Il peso è un po' minore che altrove.
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
"""I primi tre mondi hanno i Guardiani che i Seminatori conoscevano: il Nodo Avvizzito, la Regina delle Spore, il Colosso d'Ardesia. Dal vigore 4 in poi ogni mondo ha un [b]Guardiano suo[/b], nato dal mondo stesso: sempre diverso, sempre lo stesso per quel mondo.
Il suo [b]corpo[/b] viene da una delle famiglie di creature, reso gigante, spinoso e del colore del suo [b]elemento[/b]. Il nome dice il suo titolo, la specie e l'elemento. Ha due o tre [b]attacchi[/b] scelti tra ventagli di colpi, scatti, cariche, tiri, bombe dall'alto, salti, lampi (sparisce e ricompare) ed evocazioni della sua specie; solo quelli che il suo corpo sa fare. A metà Vita entra nella [b]seconda fase[/b]: cambia elemento (e con lui le debolezze: guarda la scheda sopra di lui) e diventa più svelto.
Come tutti i Guardiani si sconfigge o si cura con la Rugiada sui quattro nodi. Sconfitto lascia il [b]Nucleo[/b] del suo elemento, curato la [b]Linfa dei Guardiani[/b]; con sei Nuclei e quattro Linfe il Maglio fa il [b]talismano[/b] di quell'elemento. Sei elementi, sei talismani: per averli tutti servono Guardiani di tutti gli elementi, sia sconfitti che curati."""},
	{"id": "leggende", "group": "Senza fine", "name": "Semi leggendari e Seme Primo", "text":
"""Un Seme è [b]leggendario[/b] quando porta insieme i tre geni di una leggenda. Sono geni di categorie diverse e almeno uno è stellare: si mettono insieme innestando (Banco dell'Innestatrice), con le Fiale e con i geni delle firme dei mondi. Il nome del Seme cambia appena li ha tutti.
{cat_leggende}
Il mondo di un Seme leggendario ha il doppio di creature rare e di Lumini; quando il suo Guardiano è curato o sconfitto, il Cuore dona un [b]oggetto unico[/b] della leggenda e tre Linfe antiche.
Il [b]Seme Primo[/b] è il traguardo più lontano. Lo dona l'Albero-Madre, da solo, quando sono vere tutte e tre le cose:
{cat_primo}
Nasce il [b]Primo Mondo[/b]: tutti i biomi, quattro geni stellari, il vigore più alto che conosci più cinque. Il suo Cuore dona il [b]Germoglio del Primo[/b]. E dopo il gioco continua: il vigore non ha tetto, le leggende restano da compiere, e i Semi con le loro sfide."""},
]
