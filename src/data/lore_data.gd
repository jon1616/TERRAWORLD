class_name LoreData
extends RefCounted
## Frammenti di storia che compaiono nei momenti importanti (voce 8). Solo testo: chi li mostra è `LorePanel`.
## Ogni frammento andrà anche nell'Erbario (vedi UNIVERSO.md, «Da collezionare»).

const PAGES := {
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
		"text": "I Seminatori piantarono l'Albero quando il Vuoto era ancora giovane. Poi se ne andarono, e l'Albero si addormentò ad aspettare.\nLe reliquie gli ricordano le loro mani. Tra le radici si apre un passaggio che prima non c'era: il Vuoto, per te, non è più un muro.",
	},
	"albero_sveglio": {
		"title": "Il risveglio",
		"text": "L'Albero-Madre apre gli occhi. Sono d'ambra, come i tuoi.\nTi riconosce: sei il suo germoglio, quello che è andato a cercare. Il Giardino si riempie di luce, e ogni Seme che l'Albero lascerà cadere porterà un mondo più vivo. Ma lontano, oltre il Vuoto, un altro seme aspetta: nero, e sveglio da molto più tempo.",
	},
	"albero_addormentato": {
		"title": "L'Albero-Madre",
		"text": "Il Giardino galleggia nel Vuoto, e al centro dorme l'Albero-Madre: la corteccia è grigia, le fronde quasi tutte cadute. Eppure, quando lo tocchi, qualcosa si muove nel legno, come un respiro lento.\nUn seme cade ai tuoi piedi. Ogni mondo nasce così: da un seme che l'Albero lascia andare. Piantalo nell'Aiuola, e raccogli ciò che serve a svegliarlo.",
	},
	"cuore_trovato": {
		"title": "Il Cuore del mondo",
		"text": "Batte piano, grigio come cenere bagnata. Le radici che lo avvolgono sono marce di muffa: l'Avvizzimento è arrivato fin quaggiù.\nQuattro nodi, sul soffitto della cupola, pulsano insieme al Cuore. Qualcosa si muove tra le radici.",
	},
	"guardiano_sconfitto": {
		"title": "Il Nodo si spezza",
		"text": "Il Guardiano si sfalda in schegge di legno duro come pietra. Era malato, e ora non c'è più: il Cuore è libero, ma il mondo ha perso chi lo custodiva.\nDai frammenti del Nodo si può forgiare il metallo della Linfa. Il Cuore, sollevato, ti dona un seme.",
	},
	"guardiano_curato": {
		"title": "Il Nodo guarisce",
		"text": "L'ultimo nodo beve la Linfa e la muffa scivola via. Il Guardiano si ferma, apre l'occhio: non è più ambra malata, è Linfa limpida.\nTi riconosce: sei un germoglio dell'Albero-Madre. Ti lascia la sua Linfa più antica e una foglia in più ti cresce sul petto. Poi torna ad avvolgere il Cuore, e questa volta lo protegge davvero.",
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
