class_name NpcStoriesData
extends RefCounted
## Le storie degli abitanti (Roadmap 22, voce 231): cinque capitoli per abitante, dopo le sue richieste di sempre.
## Un capitolo si apre con l'affetto (`lvl`: livello dell'affetto), ha una richiesta (oggetti `need` o un traguardo
## `stat` + `n`), un premio e una **scena** (il racconto che compare consegnandolo). Finita la storia, l'abitante vende
## una merce in più (`FINAL`). Scritto da `tools/gen_storie.py` (python, 29 set 2026): si cambia là e si rilancia, o
## si ritocca a mano. Le regole in `NpcBonds`.

const STORIES := {
	"viandante": [
		{"title": "La strada di casa", "text": "Portami trenta torce: la strada che faccio ogni notte è buia.", "lvl": 1, "need": {"torcia": 30}, "reward": {"lumino": 120}, "scene": "«Ogni torcia che pianto è una casa per un'ora», dice. «Poi riparto.»"},
		{"title": "I tre mondi", "text": "Visita cinque mondi: voglio sapere se ci sono ancora le strade che ricordo.", "lvl": 1, "stat": "viaggi", "n": 5, "reward": {"mappa_seminatori": 1}, "scene": "Le racconti dei mondi e lei ride: «Le strade cambiano. Chi le cammina, no.»"},
		{"title": "La bisaccia leggera", "text": "Una cesta: la mia bisaccia non basta più.", "lvl": 2, "need": {"cesta": 1}, "reward": {"pozione_rugiada": 5}, "scene": "Riempie la cesta con cura. «Mi fermo un po'», dice, e sembra sorpresa lei stessa."},
		{"title": "Il nome del viandante", "text": "Trova due firme: una volta ne vidi una, e non ricordo dove.", "lvl": 3, "stat": "firme", "n": 2, "reward": {"linfa_antica": 1}, "scene": "«Era questa», sussurra davanti al ricordo. «Ci sono passata da bambina. Allora avevo un nome diverso.»"},
		{"title": "Restare", "text": "Dieci pozioni di rugiada, per chi arriva stanco.", "lvl": 4, "need": {"pozione_rugiada": 10}, "reward": {"lumino": 400}, "scene": "Appende la sua bisaccia accanto al letto. «Il Giardino è l'ultimo mondo della mia strada. E il primo.»"},
	],
	"erborista": [
		{"title": "Foglie e radici", "text": "Dieci funghi luminosi: le mie pozioni ne hanno bisogno.", "lvl": 1, "need": {"fungo_luminoso": 10}, "reward": {"pozione_bagliore": 3}, "scene": "Li schiaccia nel mortaio e l'aria si fa turchese. «Ecco. Ora respira.»"},
		{"title": "L'orto delle cure", "text": "Raccogli trenta colture: voglio sapere che cosa cresce qui.", "lvl": 1, "stat": "raccolti", "n": 30, "reward": {"pozione_rigoglio": 3}, "scene": "«La tua terra è buona», dice annusandola. «Chi la cura, la rende così.»"},
		{"title": "Il fiore che non c'è", "text": "Semina quaranta colture diverse volte.", "lvl": 2, "stat": "semine", "n": 40, "reward": {"seme_campanula": 6}, "scene": "Tra le file dell'orto trova un fiore che non aveva mai visto. Lo disegna, e sorride."},
		{"title": "La pozione perduta", "text": "Cinque sete di radice.", "lvl": 3, "need": {"seta_radice": 5}, "reward": {"pozione_passo": 3}, "scene": "«Mia madre la faceva così», dice mescolando. «L'avevo dimenticata. Grazie di avermela fatta ricordare.»"},
		{"title": "La serra", "text": "Una stanza serra nel Giardino.", "lvl": 4, "stat": "stanza_serra", "n": 1, "reward": {"lumino": 400}, "scene": "Passa la notte nella serra. La mattina dopo ha le mani verdi e gli occhi lucidi."},
	],
	"forgiatore": [
		{"title": "Il canto del Maglio", "text": "Dieci lingotti di legnoferro.", "lvl": 1, "need": {"lingotto_legnoferro": 10}, "reward": {"polvere_brace": 5}, "scene": "Batte il primo colpo e il Maglio risponde. «Senti? Si ricorda di me.»"},
		{"title": "Le armi dei Custodi", "text": "Sconfiggi due Custodi.", "lvl": 1, "stat": "custodi", "n": 2, "reward": {"lingotto_ambra": 3}, "scene": "Esamina le tue armi graffiate. «Hanno combattuto bene. Anche tu.»"},
		{"title": "L'ambra che canta", "text": "Otto lingotti d'ambra.", "lvl": 2, "need": {"lingotto_ambra": 8}, "reward": {"baccello_tonante": 3}, "scene": "L'ambra fonde e per un attimo dentro si vede un insetto antico. «Tutto torna», dice."},
		{"title": "La tempra", "text": "Sconfiggi un Signore dei luoghi.", "lvl": 3, "stat": "signori", "n": 1, "reward": {"polvere_iridata": 1}, "scene": "«Un'arma si tempra nel fuoco», dice, «chi la porta, contro chi la sfida.»"},
		{"title": "L'ultima lama", "text": "Cinque cristalli di Linfa.", "lvl": 4, "need": {"cristallo_linfa": 5}, "reward": {"lumino": 450}, "scene": "Forgia una lama sottile e te la mostra, poi la appende al muro. «Questa è per il Giardino. Non per la guerra.»"},
	],
	"vecchia_radice": [
		{"title": "Le radici ricordano", "text": "Raccontami un mondo: visitane tre.", "lvl": 1, "stat": "viaggi", "n": 3, "reward": {"lumino": 100}, "scene": "«L'Albero sente ogni mondo che attraversi», dice. «Io sento l'Albero.»"},
		{"title": "La prima Linfa", "text": "Tre Linfe antiche.", "lvl": 1, "need": {"linfa_antica": 3}, "reward": {"provetta": 5}, "scene": "Ne beve una goccia e chiude gli occhi. «Sapeva di pioggia, il giorno che ci piantarono.»"},
		{"title": "Le parole dell'Albero", "text": "Leggi quindici stele.", "lvl": 2, "stat": "stele", "n": 15, "reward": {"tavoletta_seminatori": 2}, "scene": "«I Seminatori scrivevano sulle pietre», dice, «l'Albero lo scrive nel legno. È la stessa lingua.»"},
		{"title": "Le mie radici", "text": "Risolvi i Guardiani di quattro mondi.", "lvl": 3, "stat": "guardiani", "n": 4, "reward": {"linfa_antica": 2}, "scene": "Per la prima volta ti mostra le sue radici: sono intrecciate a quelle dell'Albero-Madre."},
		{"title": "Il seme della Vecchia Radice", "text": "Guarisci un Albero perduto.", "lvl": 4, "stat": "perduti", "n": 1, "reward": {"lumino": 500}, "scene": "«Io ero un seme di uno di loro», confessa. «Non l'ho mai detto a nessuno. Ora posso tornare a trovarlo.»"},
	],
	"mercante_semi": [
		{"title": "Il seme raro", "text": "Impara cinque geni.", "lvl": 1, "stat": "geni_imparati", "n": 5, "reward": {"seme_mondo_mosaico": 1}, "scene": "«Chi conosce i geni, conosce i mondi», dice sfogliando il suo quaderno."},
		{"title": "Il catalogo", "text": "Innesta due Semi.", "lvl": 1, "stat": "innesti", "n": 2, "reward": {"linfa_antica": 1}, "scene": "Annota i tuoi innesti in una pagina nuova. «Questo non l'avevo mai visto.»"},
		{"title": "La mutazione", "text": "Fai nascere un Seme mutato.", "lvl": 2, "stat": "mutazioni", "n": 1, "reward": {"fiala_fertile": 1}, "scene": "Tiene il Seme controluce per un'ora intera. «È nato qualcosa che non c'era.»"},
		{"title": "Il mercante di mondi", "text": "Visita dieci mondi.", "lvl": 3, "stat": "viaggi", "n": 10, "reward": {"linfa_antica": 2}, "scene": "«Un tempo li vendevo, i mondi», dice. «Poi ho capito che si possono solo piantare.»"},
		{"title": "L'ultimo seme", "text": "Impara venticinque geni.", "lvl": 4, "stat": "geni_imparati", "n": 25, "reward": {"lumino": 500}, "scene": "Ti regala il suo quaderno. «Ora ne sai più di me. Continua tu.»"},
	],
	"mandriano": [
		{"title": "La prima bestia", "text": "Addomestica tre creature.", "lvl": 1, "stat": "addomesticate", "n": 3, "reward": {"laccio": 1}, "scene": "Accarezza la tua creatura. «Si fida di te. Non tradirla.»"},
		{"title": "Il recinto", "text": "Venti prodotti della mandria.", "lvl": 1, "stat": "prodotti", "n": 20, "reward": {"vasetto": 3}, "scene": "«Una bestia contenta dà di più», dice, «e tu dormi meglio.»"},
		{"title": "Le uova", "text": "Due uova schiuse.", "lvl": 2, "stat": "schiuse", "n": 2, "reward": {"laccio": 2}, "scene": "Il piccolo ti segue ovunque. Il Mandriano ride: «Ti ha scelto.»"},
		{"title": "La cavalcata", "text": "Cavalca dieci volte.", "lvl": 3, "stat": "cavalcate", "n": 10, "reward": {"polvere_iridata": 1}, "scene": "«Correre insieme a una bestia è l'unico modo di capirla», dice."},
		{"title": "Il manto raro", "text": "Fai nascere un manto raro.", "lvl": 4, "stat": "manti_rari", "n": 1, "reward": {"lumino": 500}, "scene": "Guarda il manto nuovo in silenzio. «Mio padre ne aspettò uno per tutta la vita.»"},
	],
	"pescatore": [
		{"title": "L'acqua ascolta", "text": "Pesca quaranta pesci.", "lvl": 1, "stat": "pesci", "n": 40, "reward": {"esca_petali": 10}, "scene": "«L'acqua ti ha sentito», dice. «Ora ti risponde.»"},
		{"title": "Le specie", "text": "Pesca venti specie.", "lvl": 1, "stat": "specie_pescate", "n": 20, "reward": {"esca_squama": 10}, "scene": "Ti mostra il suo quaderno di pesci. Il tuo è già più lungo."},
		{"title": "Il grande", "text": "Pesca un pesce leggendario.", "lvl": 2, "stat": "pesci_leggendari", "n": 1, "reward": {"amo_ambra": 1}, "scene": "Lo guarda a lungo, poi ti chiede di liberarlo. Lo fai. Lui annuisce."},
		{"title": "Il lago di Linfa", "text": "Dieci perle di stagno.", "lvl": 3, "need": {"perla_stagno": 10}, "reward": {"esca_iridata": 10}, "scene": "Le infila in una collana. «Per mia figlia», dice, e non aggiunge altro."},
		{"title": "L'ultimo lancio", "text": "Pesca quaranta specie.", "lvl": 4, "stat": "specie_pescate", "n": 40, "reward": {"lumino": 500}, "scene": "Ti regala la sua canna più vecchia. «Ha pescato per cinquant'anni. Ora pesca con te.»"},
	],
	"palombara": [
		{"title": "Il respiro", "text": "Pesca venti pesci: sotto il sole o sotto la luna, basta che siano venti.", "lvl": 1, "stat": "pesci", "n": 20, "reward": {"esca_squama": 5}, "scene": "«Sott'acqua si impara a stare fermi», dice. «È la cosa più difficile.»"},
		{"title": "Il fondo del lago", "text": "Dieci gusci del lago.", "lvl": 1, "need": {"guscio_lago": 10}, "reward": {"goccia_acqua_viva": 5}, "scene": "Costruisce una piccola vasca e ci mette i gusci. «Così mi sento a casa.»"},
		{"title": "La perla", "text": "Una perla delle maree.", "lvl": 2, "need": {"perla_maree": 1}, "reward": {"linfa_antica": 2}, "scene": "La tiene sul palmo e canta piano. Non avevi mai sentito quella lingua."},
		{"title": "Il mare lontano", "text": "Pesca sessanta specie.", "lvl": 3, "stat": "specie_pescate", "n": 60, "reward": {"esca_iridata": 20}, "scene": "«Ci sono mari che nessuno ha visto», dice, «e tu li stai vedendo tutti.»"},
		{"title": "Tornare a galla", "text": "Quindici gocce d'acqua viva.", "lvl": 4, "need": {"goccia_acqua_viva": 15}, "reward": {"lumino": 500}, "scene": "Si siede sulla riva e respira a lungo. «L'aria non mi pesa più», dice."},
	],
	"fabbro_radici": [
		{"title": "Il ferro vivo", "text": "Quindici ingranaggi di radice.", "lvl": 1, "need": {"ingranaggio_radice": 15}, "reward": {"vena_ambra": 20}, "scene": "Monta gli ingranaggi e li fa girare una volta. «Sentono la Linfa. Come noi.»"},
		{"title": "La rete grande", "text": "Venti macchine in un mondo.", "lvl": 1, "stat": "macchine", "n": 20, "reward": {"vena_cristallo": 10}, "scene": "Cammina lungo le tue vene con l'orecchio a terra. «Canta bene, la tua rete.»"},
		{"title": "Le Centrali", "text": "Risveglia cinque Centrali.", "lvl": 2, "stat": "centrali", "n": 5, "reward": {"linfa_antica": 2}, "scene": "«I Seminatori non volevano far lavorare gli Alberi», dice. «Volevano farli cantare insieme. Qualcuno sbagliò.»"},
		{"title": "La spola", "text": "Una spola viva.", "lvl": 3, "need": {"spola_viva": 1}, "reward": {"polvere_iridata": 2}, "scene": "La fa girare tra le dita. «Questa tesse da sola da cent'anni. Lasciamola riposare.»"},
		{"title": "Il canto", "text": "Cinquanta macchine in un mondo.", "lvl": 4, "stat": "macchine", "n": 50, "reward": {"lumino": 500}, "scene": "Accende tutto insieme e il Giardino si illumina. «Ecco. Così doveva essere.»"},
	],
	"guardaboschi": [
		{"title": "Le tracce", "text": "Addomestica cinque creature.", "lvl": 1, "stat": "addomesticate", "n": 5, "reward": {"laccio": 2}, "scene": "«Una bestia si avvicina a chi non ha fretta», dice."},
		{"title": "I rovi", "text": "Venti bacche di rovo.", "lvl": 1, "need": {"bacca_rovo": 20}, "reward": {"marmellata_rovo": 4}, "scene": "Ne mangia una e fa una smorfia. «Aspre. Come il Re dei rovi.»"},
		{"title": "Il cuore di rovo", "text": "Un cuore di rovo.", "lvl": 2, "need": {"cuore_rovo": 1}, "reward": {"linfa_antica": 2}, "scene": "Lo pianta in un vaso. Il giorno dopo ha già una foglia."},
		{"title": "La radura", "text": "Quattro uova dalle coppie del recinto.", "lvl": 3, "stat": "uova_allevate", "n": 4, "reward": {"polvere_iridata": 1}, "scene": "«Le stirpi continuano», dice guardando i piccoli. «È questo, il Giardino.»"},
		{"title": "Il bosco", "text": "Raccogli cento colture.", "lvl": 4, "stat": "raccolti", "n": 100, "reward": {"lumino": 500}, "scene": "Pianta un albero accanto alla sua casa. «Tra cent'anni sarà un bosco. Tornerò a vederlo.»"},
	],
	"cantastorie": [
		{"title": "La prima storia", "text": "Leggi trenta stele.", "lvl": 1, "stat": "stele", "n": 30, "reward": {"tavoletta_seminatori": 2}, "scene": "Te la racconta di sera, accanto al Focolare. Gli abitanti ascoltano in silenzio."},
		{"title": "Le parole rubate", "text": "Dieci eco di parola.", "lvl": 1, "need": {"eco_parola": 10}, "reward": {"stilo_seminatori": 1}, "scene": "Le libera una a una nell'aria. Alcune tornano a lei, come uccelli."},
		{"title": "La parola prima", "text": "La parola prima.", "lvl": 2, "need": {"parola_prima": 1}, "reward": {"linfa_antica": 2}, "scene": "La pronuncia una volta sola, piano. L'Albero-Madre, lontano, muove una foglia."},
		{"title": "Gli scrigni", "text": "Apri quindici scrigni a parola.", "lvl": 3, "stat": "scrigni_parola", "n": 15, "reward": {"polvere_iridata": 1}, "scene": "«Ogni scrigno è una frase finita», dice. «Ne restano tante da finire.»"},
		{"title": "L'ultima storia", "text": "Leggi cento stele.", "lvl": 4, "stat": "stele", "n": 100, "reward": {"lumino": 500}, "scene": "Racconta la storia del Seme Nero, tutta. Quando finisce, nessuno parla per molto tempo."},
	],
	"tessitrice": [
		{"title": "Il primo filo", "text": "Dieci macchine in un mondo.", "lvl": 1, "stat": "macchine", "n": 10, "reward": {"vena_ambra": 10}, "scene": "Segue le tue vene con un dito. «Le hai posate bene. Si sente.»"},
		{"title": "La Linfa rappresa", "text": "Dieci Linfe rappresa.", "lvl": 1, "need": {"linfa_rappresa": 10}, "reward": {"valvola_sfogo": 1}, "scene": "«I Succhiavena non sono cattivi», dice. «Hanno fame. Come tutti.»"},
		{"title": "La tempesta", "text": "Tre Centrali risvegliate.", "lvl": 2, "stat": "centrali", "n": 3, "reward": {"vena_cristallo": 10}, "scene": "Guarda il cielo. «Quando la Linfa ribolle, la rete deve respirare. Ricordatelo.»"},
		{"title": "Le lucciole", "text": "Dieci luci di vena.", "lvl": 3, "need": {"luce_vena": 10}, "reward": {"ampolla_lucciole": 1}, "scene": "Le lascia volare sopra le vene. «Ecco. Ora sai dove scorre.»"},
		{"title": "La trama del mondo", "text": "Trenta macchine in un mondo.", "lvl": 4, "stat": "macchine", "n": 30, "reward": {"lumino": 500}, "scene": "«Tutto il mondo è una rete», dice. «Tu hai imparato a vederla.»"},
	],
	"innestatrice": [
		{"title": "La mano", "text": "Innesta tre Semi.", "lvl": 1, "stat": "innesti", "n": 3, "reward": {"linfa_antica": 1}, "scene": "«Hai la mano ferma», dice. «Il resto si impara.»"},
		{"title": "I geni rari", "text": "Impara quindici geni.", "lvl": 1, "stat": "geni_imparati", "n": 15, "reward": {"fiala_vene_ricche": 1}, "scene": "Ti mostra un gene che non conoscevi. «L'ho trovato in un mondo che nessuno ricorda.»"},
		{"title": "La mutazione", "text": "Due Semi mutati.", "lvl": 2, "stat": "mutazioni", "n": 2, "reward": {"linfa_antica": 2}, "scene": "«Una mutazione è un mondo che sceglie da solo», dice. «Rispettala.»"},
		{"title": "Le leggende", "text": "Una leggenda compiuta.", "lvl": 3, "stat": "leggende", "n": 1, "reward": {"polvere_iridata": 2}, "scene": "Per la prima volta ride forte. «Allora esistono davvero.»"},
		{"title": "Il Seme perfetto", "text": "Impara trenta geni.", "lvl": 4, "stat": "geni_imparati", "n": 30, "reward": {"lumino": 500}, "scene": "«Non esiste un Seme perfetto», dice, «esiste il Seme giusto per chi lo pianta.»"},
	],
	"cartografo": [
		{"title": "La mappa bianca", "text": "Trova tre firme.", "lvl": 1, "stat": "firme", "n": 3, "reward": {"mappa_firma": 1}, "scene": "Segna i tre luoghi sulla sua mappa, con cura. «Ora sono veri.»"},
		{"title": "I Sigilli", "text": "Apri tre Sigilli.", "lvl": 1, "stat": "sigilli", "n": 3, "reward": {"mappa_sigilli": 1}, "scene": "«I Seminatori chiudevano ciò che temevano», dice. «O ciò che amavano troppo.»"},
		{"title": "I segreti", "text": "Trova quindici segreti.", "lvl": 2, "stat": "segreti", "n": 15, "reward": {"linfa_antica": 1}, "scene": "Ti chiede di raccontarli tutti, uno per uno, e li disegna a margine."},
		{"title": "Il mondo intero", "text": "Un mondo con tutti i segreti trovati.", "lvl": 3, "stat": "mondi_completi", "n": 1, "reward": {"polvere_iridata": 2}, "scene": "«Un mondo intero», ripete. «Non l'ha mai fatto nessuno, che io sappia.»"},
		{"title": "L'atlante", "text": "Trova otto firme.", "lvl": 4, "stat": "firme", "n": 8, "reward": {"lumino": 500}, "scene": "Ti regala il suo atlante. «La mia mappa finisce qui. La tua comincia.»"},
	],
}

## La merce che l'abitante vende in più a storia finita.
const FINAL := {
	"viandante": ["radice_uncino", 1],
	"erborista": ["pozione_vigore", 3],
	"forgiatore": ["lingotto_linfa", 2],
	"vecchia_radice": ["linfa_antica", 1],
	"mercante_semi": ["fiala_vene_ricche", 1],
	"mandriano": ["vasetto", 5],
	"pescatore": ["esca_iridata", 10],
	"palombara": ["amo_ambra", 1],
	"fabbro_radici": ["nodo_memoria", 2],
	"guardaboschi": ["laccio", 3],
	"cantastorie": ["stilo_seminatori", 1],
	"tessitrice": ["vena_cristallo", 10],
	"innestatrice": ["fiala_rovine_fitte", 1],
	"cartografo": ["mappa_firma", 1],
}
