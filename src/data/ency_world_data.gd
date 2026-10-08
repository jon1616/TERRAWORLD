class_name EncyWorldData
## Enciclopedia, sesta parte (Roadmap 15 «Il mondo abitato», voce 149): le creature nuove e come pensano, i Signori dei
## luoghi, i tre Guardiani scritti a mano, le maree, costruire (costrutti, arredi, stanze, case, ospiti, progetti).
## Stesso formato di `EncyGuideData`.

const CHAPTERS := [
	{"id": "creature_vive", "group": "Il mondo abitato", "name": "Come pensano le creature", "text":
"""Le creature hanno [b]sensi[/b]: ti vedono meno lontano al buio, [b]sentono[/b] lo scavo, i colpi, le esplosioni e i passi di corsa (e vengono a guardare: un [b]?[/b] sopra la testa), [b]fiutano[/b] il sangue quando sei ferito e un'esca che tieni in mano. Persa di vista, una creatura ti cerca dove ti ha visto l'ultima volta; ferita gravemente, una paurosa fugge finché ti perde di vista, poi si nasconde e si cura piano (se la ritrovi presto è ancora debole; messa all'angolo si difende); quelle che vivono nella terra, prima di immergersi, si fermano e scavano sollevando polvere; troppo lontana da casa, torna indietro.
[b]I gruppi[/b]: i branchi ti accerchiano (uno davanti, gli altri ai lati), gli sciami girano in cerchio e scendono a ondate, le colonie difendono i nidi, le prede ferite avvisano le compagne e fuggono insieme. Se cade il capobranco o il pastore, il gruppo si sbanda.
[b]Le astuzie[/b] (vedi [url=cap:combattere]Combattere[/url]): ognuna si annuncia e ha una contromossa, che la scheda della creatura mostra quando l'hai studiata."""},
	{"id": "bestiario_nuovo", "group": "Il mondo abitato", "name": "Le creature di ogni luogo", "text":
"""Ogni bioma di superficie ha almeno cinque facce sue (un erbivoro, un predatore, un volante, qualcuno che si vede solo di notte, uno raro), e così ogni strato e ogni bioma del sottosuolo. Nei [b]liquidi[/b] vivono le loro creature: il luccio e la carpa nell'acqua, la salamandra nella Linfa, l'anguilla nella brace; la [b]lontra[/b] e il [b]luccio[/b] rubano il pesce dalla lenza (presi, lo restituiscono).
Alcune creature esistono solo a una condizione: di notte (i lupi lunari, la falena vampira), in una stagione (il bruco del Germoglio, la damigella del Rigoglio, il cinghiale del Raccolto, la volpe del Gelo), con un tempo (la rana del tuono, il lumacone della pioggia, il velo di nebbia, lo spirito della bufera) o durante un'eclissi (l'Eclissimo). Uscire col brutto tempo diventa una scelta.
Ogni specie lascia il suo materiale e, le rare, un trofeo: con i materiali si fanno accessori e pozioni, con i trofei di un luogo il suo [b]talismano[/b]."""},
	{"id": "signori", "group": "Il mondo abitato", "name": "I Signori dei luoghi", "text":
"""Ogni bioma di superficie, ogni bioma del sottosuolo e ogni strato ha il suo [b]Signore[/b]: un mini-boss con due o tre attacchi e una [b]furia[/b] a metà della Vita. Non si incontra per caso: si chiama con la sua [b]esca rituale[/b] (all'[b]Altare dei Seminatori[/b], con i materiali delle creature di quel luogo), usata proprio lì.
Lascia un materiale che c'è solo da lui e il suo trofeo: insieme, al Maglio, diventano il suo oggetto. I materiali dei Signori servono anche per chiamare i tre grandi Guardiani."""},
	{"id": "grandi_guardiani", "group": "Il mondo abitato", "name": "Tre Guardiani scritti a mano", "text":
"""• [b]Il Leviatano del lago[/b]: si chiama accanto a un lago grande (almeno 80 celle d'acqua). Sale e scende dall'acqua e alza la [b]marea[/b]: quando il lago ribolle, sali in alto.
• [b]La Grande Scavatrice[/b]: si chiama sotto terra, dalle Caverne d'ardesia in giù. Sbuca dal terreno e alza [b]pilastri di radice[/b] che crollano da soli: spostati quando la terra trema, e usali per salire.
• [b]La Signora delle correnti[/b]: si chiama in superficie, all'aperto. Chiama le [b]raffiche[/b], le colonne d'aria che fanno salire e le passerelle di nuvola: combatti in alto, dove vola lei.
I richiami si fanno all'Altare con i materiali dei Signori; ognuno lascia un trofeo e il materiale per un oggetto grande.
Nel cielo alto c'è un quarto Guardiano: [url=cap:occhio_tempesta]l'Occhio della Tempesta[/url]."""},
	{"id": "maree", "group": "Il mondo abitato", "name": "Le maree del mondo", "text":
"""A volte, al calar della notte, al sorgere del giorno o quando comincia un'eclissi, arriva una [b]marea[/b]: prima si annuncia (una scritta e un segno sulla mappa), poi arrivano le [b]ondate[/b], e alla fine il [b]capo[/b] (un Signore). Sconfitto il capo, il premio e il suo [b]Sigillo[/b]: con tutti e sei, all'Altare, la Corona delle sei maree.
Le maree: la Notte delle spore, la Migrazione (i branchi attraversano il mondo e i predatori li seguono), l'[b]Assedio dei rosicchiatori[/b], la Marea di brace, lo Stormo, l'Eclissi dei mimi, e in cielo la [url=cap:creature_cielo]Burrasca delle Chiome[/url]. La stagione ne rende alcune più frequenti.
[b]L'assedio[/b] arriva al massimo una volta a stagione, solo se hai una base (un Focolare e una porta): i rosicchiatori rodono le [b]porte[/b] (nient'altro). Una porta regge qualche morso, il doppio se è incorniciata da mura dure; le creature di guardia della mandria difendono la casa. Gli assedi si spengono dalle Opzioni."""},
	{"id": "stanze", "group": "Il mondo abitato", "name": "Le stanze e le case", "text":
"""Una [b]stanza[/b] è un posto chiuso da blocchi, con una parete dietro ogni cella e una porta. Entrando il gioco ti dice che cos'è e il suo [b]comfort[/b] (la bellezza degli arredi e dei blocchi, le luci, le serie complete):
• [b]Casa[/b] (un letto): la Vita ricresce più in fretta. • [b]Laboratorio[/b] (due banchi): creazioni di qualità più alta.
• [b]Serra[/b] (tre colture o tre vasi): le colture crescono molto più in fretta. • [b]Stalla[/b] (un recinto): la mandria produce di più.
• [b]Acquario[/b] (acqua e due specie di pesci nei contenitori): fortuna di pesca. • [b]Sala dei trofei[/b] (tre trofei nei contenitori): più danno contro quelle famiglie.
• [b]Biblioteca[/b] (due scaffali, un tavolo e una luce): una parola in più dalle tavolette. • [b]Osservatorio[/b] (due finestre e un tavolo, sopra la terra): eventi più frequenti.
• [b]Cantina[/b] (due contenitori con cibo o pozioni): cibi e pozioni bevuti lì durano di più.
Una stanza [b]ripara[/b] dai rigori (i materiali che isolano ancora di più, un camino ferma il freddo) e dai fulmini. Lasciata sola e al buio si riempie di ragnatele; sui tetti delle case gli uccelli fanno il nido.
[b]Gli abitanti[/b] vogliono una stanza ciascuno e hanno i loro gusti (materiali, arredi, vicini): felici fanno prezzi migliori e lasciano un regalo al giorno; una casa bella libera li fa arrivare anche lontano dal Focolare."""},
	{"id": "progetti", "group": "Il mondo abitato", "name": "I progetti dei Seminatori", "text":
"""Negli scrigni delle rovine a volte c'è un [b]progetto[/b]: il ponte, la torre di vedetta, la serra a cupola, il faro, il pozzo delle fonti, la sala dei trofei. In mano mostra la sagoma; se nella Bisaccia hai i materiali (la scheda li elenca), un clic lo costruisce in un colpo.
Per le tue costruzioni c'è anche la [b]Tavola del progetto[/b] (allo scalpellino): copia qualcosa che hai costruito e lo rifà altrove."""},
]
