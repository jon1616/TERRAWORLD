class_name LoreData
extends RefCounted
## Frammenti di storia che compaiono nei momenti importanti (voce 8). Solo testo: chi li mostra è `LorePanel`.
## Ogni frammento andrà anche nell'Erbario (vedi UNIVERSO.md, «Da collezionare»).

const PAGES := {
	# Roadmap 21 «Le radici del cosmo»
	"atto2_sommerso": {"title": "La radice che beve il mare",
		"text": "Sveglio, l'Albero-Madre ascolta le sue radici più lunghe, quelle che attraversano il cielo del Giardino. Una scende in un mare che non ha nome.\nLaggiù respira piano un altro Albero, piantato dalle stesse mani: il mare l'ha coperto. L'Albero-Madre ti dona un Seme del cosmo. Piantalo in un'Aiuola: porta a quel Giardino."},
	"atto2_ferro": {"title": "Il ferro che dorme",
		"text": "Il fratello sommerso ti ringrazia con le sue acque. Ma le radici del cosmo toccano un secondo Giardino, e là non scorre più niente.\nI Seminatori fusero il suo Albero con le loro macchine, per farlo lavorare. Poi le macchine si fermarono, e lui con loro."},
	"atto2_selvatico": {"title": "Le bestie senza nome",
		"text": "La Linfa torna nel fratello di ferro, e le radici del cosmo tremano di nuovo: un terzo Giardino, dove tutto è cresciuto senza nessuno.\nLe bestie non ricordano più il Giardiniere. Un re di spine si è preso la radura."},
	"atto2_muto": {"title": "Le parole perdute",
		"text": "Il terzo fratello canta con la radura. Ne resta uno, il più lontano: un Albero che ha dimenticato le sue parole.\nAttorno a lui, un cerchio di stele che nessuno legge più. Qualcosa, là, si nutre del silenzio."},
	"perduto_sommerso": {"title": "L'Albero sommerso",
		"text": "Le acque del lago si fanno limpide fino al fondo. L'Albero apre le fronde come chi riemerge, e per la prima volta dopo secoli le sue radici sentono quelle dell'Albero-Madre.\n«Eravamo quattro», dicono le sue foglie, «e poi tre, e poi nessuno.»"},
	"perduto_ferro": {"title": "L'Albero di ferro",
		"text": "Gli ingranaggi girano una volta sola, poi si fermano per sempre: non servono più. La Linfa scorre da sola nelle vene di ferro.\n«Ci chiesero di lavorare», dice l'Albero, «e noi lavorammo. Nessuno ci chiese mai se volevamo.»"},
	"perduto_selvatico": {"title": "L'Albero selvatico",
		"text": "I rovi si ritirano. I Cervi tornano a brucare vicino al tronco, e uno ti annusa la mano.\n«Il Giardiniere se ne andò una mattina», dice l'Albero, «e noi aspettammo. Poi dimenticammo che cosa aspettavamo.»"},
	"perduto_muto": {"title": "L'Albero muto",
		"text": "La prima parola che l'Albero ritrova è il tuo nome, anche se non gliel'hai mai detto.\n«Il Seme che cadde», dice, «non cadde da solo. Qualcuno lo lasciò andare.» Poi tace, ma è un silenzio diverso: quello di chi pensa."},
	# Roadmap 28, l'Atto III «Il Seme Primo»
	"primo_seminatore": {"title": "L'ultimo Seminatore",
		"text": "Non era un nemico. Era rimasto indietro per custodire l'Albero Antico, e per tanto tempo aveva difeso il seme da tutto ciò che veniva dal Vuoto.\nPrima di spegnersi ti ha guardato a lungo. Ha visto le venature delle tue mani. Ha sorriso.\nPorta il suo seme all'Albero Antico."},
	"atto3_eco": {"title": "L'eco oltre il Vuoto",
		"text": "L'Albero-Madre ascolta. Oltre i quattro Giardini c'è una voce lenta e profonda, come quella di un albero che parla nel sonno.
Non chiede aiuto. Chiama per nome qualcuno che non c'è più."},
	"atto3_parole": {"title": "Le parole antiche",
		"text": "La voce parla la lingua dei Seminatori, ma con parole che nessuna stele ricorda. L'Albero-Madre le ripete piano, una per una.
«Radice. Ritorno. Promessa.» Poi tace, come chi ha capito qualcosa che fa male."},
	"atto3_forza": {"title": "La forza del Giardino",
		"text": "Lungo la radice più lunga qualcosa ha combattuto, tanto tempo fa: la corteccia è segnata da ferite chiuse male.
Chi c'è oltre il Vuoto ha difeso la radice da solo. Ora tocca a te difendere la strada."},
	"atto3_stirpi": {"title": "Le stirpi",
		"text": "Le creature del Giardino si voltano tutte insieme verso il cielo, la stessa notte, senza un suono.
Le stirpi più antiche ricordano la radice: i loro avi la attraversarono con i Seminatori."},
	"atto3_raccolto": {"title": "Il raccolto",
		"text": "L'Albero-Madre assaggia ciò che hai coltivato e trema di piacere. «Così facevano loro», dice. «Seminavano per chi sarebbe venuto dopo.»
Oltre il Vuoto, dice, la terra non ha più nessuno che semini."},
	"atto3_acque": {"title": "Le acque",
		"text": "Nelle radici del cosmo scorre di nuovo un filo d'acqua. Porta con sé il sapore di un lago che non conosci: freddo, fermo, antichissimo.
L'acqua oltre il Vuoto aspetta da troppo tempo qualcuno che la faccia muovere."},
	"atto3_linfa": {"title": "La Linfa dei mondi",
		"text": "Tutta la Linfa delle tue reti scorre verso l'Albero-Madre e da lì lungo la radice più lunga, come in una Centrale grande quanto il cosmo.
La radice si scalda. In fondo, qualcosa si apre."},
	"atto3_casa": {"title": "La casa",
		"text": "«Se tornano», dice l'Albero-Madre, «devono trovare una casa.» Guarda il Giardino che hai costruito e per la prima volta sorride davvero.
Non dice chi dovrebbe tornare. Lo sai già."},
	"atto3_amici": {"title": "Gli amici",
		"text": "Gli abitanti del Giardino si radunano attorno all'Albero-Madre. Nessuno ha paura: hanno visto che cosa sai fare.
«Vai», dicono. «Noi teniamo accese le luci finché torni.»"},
	"radici_cosmo": {"title": "Le radici del cosmo",
		"text": "Quattro Alberi respirano insieme all'Albero-Madre. Le radici del cosmo, sopra il Giardino, si accendono di una luce che non avevi mai visto.\nPiù lontano, oltre i quattro, qualcosa risponde. Non è un Albero. È più vecchio."},
	"albero_primo_respiro": {
		"title": "Il primo respiro",
		"text": "La corteccia si scalda sotto la mano. Una fronda turchese si apre, piano, come chi si stira al mattino.\nL'Albero non parla ancora, ma una radice si sposta e lascia spazio per un'altra Aiuola. Qualcuno, laggiù ai margini del Giardino, ha sentito il respiro e si incammina.",
	},
	"albero_linfa": {
		"title": "La Linfa antica",
		"text": "La Linfa dei Cuori scende nel legno e lo illumina da dentro. Ora le vene dell'Albero brillano come quelle dei mondi.\nOgni Cuore guarito è un mondo che torna a respirare, e l'Albero lo sente. Sotto la corteccia, qualcosa si ricorda come si fa a innestare un seme.",
	},
	"albero_memoria": {
		"title": "Ambra e memoria",
		"text": "I Seminatori piantarono l'Albero quando il Vuoto era ancora giovane. Un giorno non vennero più, e l'Albero si addormentò per non chiedersi dove fossero.\nLe reliquie gli ricordano le loro mani. Tra le radici si apre un passaggio che prima non c'era: il Vuoto, per te, non è più un muro.",
	},
	"albero_sveglio": {
		"title": "Il risveglio",
		"text": "L'Albero-Madre apre gli occhi. Sono d'ambra, come i tuoi.\nTi riconosce: sei il suo germoglio, quello che è andato a cercare. Il Giardino si riempie di luce, e ogni Seme che l'Albero lascerà cadere porterà un mondo più vivo. Ma da qualche parte nel Vuoto un altro seme aspetta: nero, e sveglio da molto più tempo.",
	},
	"albero_addormentato": {
		"title": "L'Albero-Madre",
		"text": "Il Giardino galleggia nel Vuoto, e al centro dorme l'Albero-Madre: la corteccia è grigia, le fronde quasi tutte cadute. Eppure, quando lo tocchi, qualcosa si muove nel legno, come un respiro lento.\nUn seme cade ai tuoi piedi. Ogni mondo nasce così: da un seme che l'Albero lascia andare. Piantalo nell'Aiuola, e raccogli ciò che serve a svegliarlo.",
	},
	"cuore_trovato": {
		"title": "Il Cuore del mondo",
		"text": "Batte piano, grigio come cenere bagnata. Le radici che lo avvolgono sono marce di muffa: l'Avvizzimento è arrivato fin quaggiù.\nQuattro nodi, sul soffitto della cupola, pulsano insieme al Cuore. Qualcosa si muove tra le radici.",
	},
	# voce 81: il Seme Primo
	"seme_primo": {
		"title": "Il Seme Primo",
		"text": "L'Albero-Madre apre una fronda e ti lascia cadere in mano un seme caldo, grande come un pugno. Non è un seme come gli altri: dentro ci sono tutti i biomi, tutte le stelle che hai visto, tutti i geni che hai imparato.\nNon è un mondo: è una strada. Dentro batte qualcosa che segue la radice più lunga, oltre il Vuoto. Piantalo, e la strada si aprirà.",
	},
	"primo_compiuto": {
		"title": "Il Primo Mondo",
		"text": "Il Cuore del Primo Mondo batte forte, e da ogni radice del Giardino risponde un battito. Dai Cuori dei mondi non risponde nessuno: loro non possono.\nNon è una fine. I Semi continuano a crescere, i mondi continuano a nascere, e il vigore non ha tetto: da qui in poi ogni mondo è tuo da inventare.",
	},
	# voce 80: i Guardiani generati
	"generato_sconfitto": {
		"title": "Un Guardiano che non ha nome",
		"text": "Il gigante crolla e il Cuore si libera. Non ha un nome. Forse l'ha avuto: era diviso in troppi pezzi per ricordarlo.\nNel suo petto resta un Nucleo, ancora vivo. I mondi più vigorosi si difendono da soli.",
	},
	"generato_curato": {
		"title": "Il Guardiano si calma",
		"text": "La Rugiada scende sui nodi e il gigante si ferma, confuso. Guarda il Cuore come se lo vedesse per la prima volta, poi guarda te. Cerca una parola e non la trova.\nLascia una Linfa densa, che ricorda il suo elemento, e si accuccia accanto al Cuore.",
	},
	# voce 72: il Seme Nero
	"nero_spezzato": {
		"title": "Il Seme Nero si spezza",
		"text": "Il guscio cede con un suono che non è un suono: è il Vuoto che se ne va. Dalle crepe non esce più niente. In tutti i mondi l'Avvizzimento si ferma dov'è, come una mano che ha perso la presa.
Non guarirà da solo: quello che è malato resta malato. Ma non si allargherà più. Le schegge del seme sono fredde e dure: i Seminatori non avevano avuto il coraggio. Tu sì. Dentro, qualcuno ha detto un nome prima di spegnersi.",
	},
	"nero_curato": {
		"title": "Il Seme Nero guarisce",
		"text": "La Rugiada scende nelle crepe e il viola si spegne, piano. Il seme trema, poi si apre: dentro c'è linfa chiara, come quella del primo giorno.
Dentro c'è qualcuno. Ti guarda con i tuoi stessi occhi e non dice niente. In tutti i mondi l'Avvizzimento comincia a ritirarsi, un poco alla volta. Ma nel Vuoto qualcosa continua a chiamarla.",
	},
	"guardiano_sconfitto": {
		"title": "Il Nodo si spezza",
		"text": "Il Guardiano si sfalda in schegge di legno duro come pietra. Era malato, e ora non c'è più: il Cuore è libero, ma il mondo ha perso chi lo custodiva.\nDai frammenti del Nodo si può forgiare il metallo della Linfa. Il Cuore, sollevato, ti dona un seme.",
	},
	"risveglio_cuore": {
		"title": "Il Risveglio del Cuore",
		"text": "Il quarto Cuore torna a battere e gli altri gli rispondono. Lo senti sotto i piedi in ogni mondo, anche in quelli che hai lasciato: un colpo sordo, poi un altro.\nNelle rocce dei mondi più vigorosi la Linfa si rapprende in metalli che prima non c'erano. Le creature antiche se li portano dentro. Nel Giardino, accanto all'Albero-Madre, spunta una radice nuova.\nI Seminatori lo sapevano: un Cuore sveglio sveglia tutti gli altri. Per questo li avevano lasciati dormire.",
	},
	# voce 373: i Guardiani della spina (pezzi senza nome dei Seminatori, `UNIVERSO.md`)
	"g_falena_sconfitto": {
		"title": "La Falena si spegne",
		"text": "La Falena si sfalda in polvere luminosa che non illumina niente. Per un attimo il Cuore resta al buio, poi riprende a battere da solo.",
	},
	"g_falena_curato": {
		"title": "La Falena chiude le ali",
		"text": "Le ali si chiudono piano. Dentro c'era un pezzo di qualcuno che aveva paura del buio, e per questo lo portava addosso. Ti lascia passare.",
	},
	"g_tessitore_sconfitto": {
		"title": "Il Tessitore si ferma",
		"text": "Le radici smettono di muoversi e tornano legno. Chi le tesseva non c'è più: restano i nodi, ben fatti, che nessuno scioglierà.",
	},
	"g_tessitore_curato": {
		"title": "Il Tessitore lascia i fili",
		"text": "Il Tessitore lascia andare i fili. Ne tiene uno solo e te lo mette in mano, come si fa con un apprendista.",
	},
	"g_marea_sconfitto": {
		"title": "La Marea si ritira",
		"text": "L'acqua se ne va e lascia il Cuore bagnato e vuoto. Sul fondo c'è una conchiglia che non suona.",
	},
	"g_marea_curato": {
		"title": "La Marea si calma",
		"text": "Per la prima volta da secoli si sente il rumore dell'acqua. Qualcuno, là dentro, aveva dimenticato come si parla.",
	},
	"g_mietistelle_sconfitto": {
		"title": "Il Mietitore cade",
		"text": "Il Mietitore cade sulle stelle che aveva raccolto. Si spengono una a una, come se aspettassero solo lui.",
	},
	"g_mietistelle_curato": {
		"title": "Il Mietitore posa le stelle",
		"text": "Lascia cadere le stelle. Non le raccoglieva per sé: le teneva da parte per qualcuno che non è mai tornato.",
	},
	"g_ospite_sconfitto": {
		"title": "L'Ospite se ne va",
		"text": "L'Ospite si dissolve senza un grido. Il Vuoto non lo reclama: era davvero soltanto un ospite.",
	},
	"g_ospite_curato": {
		"title": "L'Ospite si ricorda",
		"text": "La Linfa entra in lui e qualcosa si ricorda di essere stato invitato, un tempo. Lascia il Cuore in silenzio, con un inchino.",
	},
	"g_salamandra_sconfitto": {
		"title": "La Madre si raffredda",
		"text": "La Madre si raffredda e diventa pietra. Sotto di lei le uova sono cenere da tanto tempo.",
	},
	"g_salamandra_curato": {
		"title": "La Madre si accuccia",
		"text": "Il calore diventa tiepido. La Madre ti guarda come guarda i suoi piccoli, poi si accuccia attorno al Cuore.",
	},
	"g_bufera_sconfitto": {
		"title": "Il tuono si spezza",
		"text": "Il tuono si spezza a metà. Nel Cuore smette di nevicare, ma il freddo resta.",
	},
	"g_bufera_curato": {
		"title": "La bufera diventa brezza",
		"text": "La Voce canta una cosa sola, sempre la stessa: il nome di un mondo che non esiste più.",
	},
	"g_giardiniere_sconfitto": {
		"title": "Il Giardiniere crolla",
		"text": "Il Giardiniere crolla tra le aiuole morte. Nessuno le curerà più: era l'ultimo a ricordare che cosa ci cresceva.",
	},
	"g_giardiniere_curato": {
		"title": "Il Giardiniere mostra le aiuole",
		"text": "Ti mostra le aiuole una per una, come si mostra un giardino a un ospite. Poi si siede in mezzo, contento, e non si muove più.",
	},
	"g_eco_sconfitto": {
		"title": "L'Eco si spegne",
		"text": "L'Eco si spegne con la tua voce. Per un momento hai paura che fosse davvero la tua.",
	},
	"g_eco_curato": {
		"title": "L'Eco dice un nome",
		"text": "L'Eco smette di copiarti. Dice una parola sola, che non è tua: un nome corto, che finisce con una vocale.",
	},
	"guardiano_curato": {
		"title": "Il Nodo guarisce",
		"text": "L'ultimo nodo beve la Linfa e la muffa scivola via. Il Guardiano si ferma, apre l'occhio: non è più ambra malata, è Linfa limpida.\nHa l'aria di chi è rimasto sveglio troppo a lungo. Ti riconosce: sei un germoglio dell'Albero-Madre. Ti lascia la sua Linfa più antica e una foglia in più ti cresce sul petto. Poi torna ad avvolgere il Cuore, e questa volta lo protegge davvero.",
	},
	"regina_sconfitta": {
		"title": "La Regina cade",
		"text": "Lo sciame si disperde nell'aria come polvere. Della Regina resta un velo sottile, che non si strappa.\nOgni mondo più lontano dal Giardino ha un Guardiano più antico. Questo era malato quanto il primo.",
	},
	"regina_curata": {
		"title": "La Regina guarisce",
		"text": "Le spore tornano a brillare di viola pulito. La Regina scende fino a te e scuote il suo polline: spore buone, che fanno crescere invece di marcire.\nAnche lei ricorda l'Albero-Madre. Ti chiama con un nome che non conosci ancora.",
	},
	"colosso_sconfitto": {
		"title": "Il Colosso si ferma",
		"text": "La montagna si sbriciola in scaglie. Nel mezzo, un nucleo di pietra ancora caldo.\nI Seminatori non costruivano solo mondi: costruivano chi li custodisse. Chi ha fatto ammalare anche loro?",
	},
	"colosso_curato": {
		"title": "Il Colosso guarisce",
		"text": "La muffa si stacca dalle giunture d'ambra e il Colosso si siede, lento come una frana al contrario.\nDal petto si stacca una pietra che batte piano. Te la porge. Poi torna a dormire attorno al suo Cuore, questa volta in pace.",
	},
	"portale": {
		"title": "Il Seme di mondo",
		"text": "Il seme germoglia in un arco di radici. Dentro, la Linfa gira come un vortice: dall'altra parte c'è un mondo che non esisteva un attimo fa.\nI Seminatori piantavano i mondi così. Ora tocca a te.",
	},
	"custode_cervo": {
		"title": "Il Grande Cervo di brina",
		"text": "Si piega sulle zampe e la brina gli scivola via dal vello. Era il pastore dei boschi gelati: i cervi lo seguivano da una valle all'altra.\nNel bozzolo resta un palco che non si scioglie. Sull'Altare, un palco e un poco di vello lo richiamano.",
	},
	"custode_salamandre": {
		"title": "La Madre delle salamandre",
		"text": "Le braci della sua schiena si spengono una per una. Covava le uova delle salamandre nella cenere calda, e le difendeva da tutto.\nSull'Altare, squame e cenere viva la risvegliano.",
	},
	"custode_madre": {
		"title": "La Madre dei grumi",
		"text": "Si scioglie in una pozza di muschio che trema ancora. I grumi del Sottobosco non erano creature: erano le sue gocce, sparse a cercare cibo per lei.\nNel bozzolo vuoto resta il suo cuore di gelatina. I Seminatori sapevano chiamarla: sull'Altare, una goccia della sua gelatina la risveglia.",
	},
	"custode_tessitrice": {
		"title": "La Tessitrice delle radici",
		"text": "Cade, e i suoi fili si allentano in tutte le Caverne. Per secoli ha cucito le radici dell'Albero-Madre alla roccia, perché non franassero.\nChi indossa la sua seta d'oro non si perde nel buio. Sull'Altare, un filo teso la richiama.",
	},
	"custode_serpe": {
		"title": "La Serpe madre",
		"text": "La Linfa che la teneva insieme torna a scorrere nella roccia. Ogni Serpe di Linfa delle Profondità è nata da lei.\nLe sue scaglie sono ancora calde. Una scaglia di serpe, posata sull'Altare, la fa risalire dal profondo.",
	},
	"custode_mietitore": {
		"title": "Il Mietitore cavo",
		"text": "Il mantello si affloscia: dentro non c'era nessuno. Il Vuoto lo aveva mandato a mietere ciò che il mondo lascia cadere nel Fondo.\nResta un nucleo cavo, freddo. L'eco del Vuoto, sull'Altare, lo chiama indietro: il Vuoto non manda mai un Mietitore una volta sola.",
	},
}
