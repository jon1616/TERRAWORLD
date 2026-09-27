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
]
