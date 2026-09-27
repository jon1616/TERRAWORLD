class_name EncyGuideData
## Enciclopedia (27 set 2026), prima parte: i primi passi, il mondo, scavare e costruire. Solo testo (BBCode).
## Collegamenti: [url=cap:id]…[/url] a un capitolo, [url=cat:id]…[/url] a un catalogo, [url=item:id], [url=cr:id],
## [url=gene:id]. I numeri tra graffe ({regen_delay}) e i cataloghi in linea ({cat_strati}) li riempie `EncyPages`.
## Ogni capitolo: {"id", "group", "name", "text"}.

const CHAPTERS := [
	{"id": "inizio", "group": "Primi passi", "name": "Il Germogliato e il Giardino", "text":
"""Sei il [b]Germogliato[/b], l'ultimo giardiniere di un cosmo fatto di semi. Ogni mondo nasce da un [url=cap:semi]Seme di mondo[/url] piantato nel [b]Giardino[/b], un'isola sospesa nel Vuoto attorno all'[url=cap:albero_madre]Albero-Madre[/url], che dorme.

[b]Il giro del gioco[/b]
1. L'Albero-Madre e gli [url=cap:abitanti]abitanti[/url] chiedono qualcosa: un materiale, un gene, una creatura.
2. Per trovarlo pianti un Seme in un'[url=cap:portali]Aiuola[/url]: nasce un portale verso un mondo nuovo, fatto dai [url=cap:geni]geni[/url] di quel Seme.
3. Esplori quel mondo: trovi ciò che cercavi e ciò che non ti aspettavi (la sua [url=cap:firme]firma[/url], rovine, creature rare).
4. Torni, offri, e il Giardino cresce: poteri nuovi, abitanti nuovi, Semi migliori.
5. Con l'[url=cap:innesto]innesto[/url] progetti i Semi dei mondi che ti servono.

[b]Dove guardare quando non sai cosa fare[/b]
• Il [url=cap:guida]filo[/url], in alto al centro: la prossima cosa da fare, e una freccia verso dove farla.
• La riga dell'Albero-Madre, in alto a sinistra: che cosa chiede adesso.
• Gli [url=cap:obiettivi]obiettivi[/url], sotto l'orologio.
• La [url=cap:bacheca]Bacheca dei Giardinieri[/url], nel Giardino: richieste sempre nuove.
• Gli abitanti: ognuno ha una richiesta; la Vecchia Radice ti dice cosa manca all'Albero.
• L'[url=cap:erbario]Erbario[/url]: che cosa hai scoperto e, per le famiglie, dove cercare ciò che manca."""},
	{"id": "guida", "group": "Primi passi", "name": "Il filo, la lista e i consigli", "text":
"""Tre aiuti per non perdersi in un gioco grande. Si spengono dalle [url=cap:opzioni]Opzioni[/url], sezione Interfaccia.

[b]Il filo[/b]
In alto al centro c'è sempre [b]una cosa da fare adesso[/b], con sotto dove cercarla. Viene da una di queste fonti, in quest'ordine: la tua lista della spesa, l'[url=cap:albero_madre]Albero-Madre[/url], gli [url=cap:obiettivi]obiettivi[/url], la [url=cap:bacheca]Bacheca[/url]. Il tasto {k_filo} passa alla fonte dopo, e il gioco se la ricorda.
Quando il posto è noto compare un segno: un rombo sopra di lui se lo vedi, una freccia sul bordo dello schermo con la distanza se è lontano. Indica il blocco più vicino già visto di un minerale, l'albero più vicino per il legno, il banco giusto, l'Albero-Madre; se serve scendere, una freccia in basso con il nome dello strato.

[b]La lista della spesa[/b]
In [url=cap:creare]Esamina[/url], accanto a «Crea», il pulsante [b]Segna[/b] mette la ricetta nella lista a destra (al più tre). La lista conta Bisaccia e casse vicine, e sotto un ingrediente che si fabbrica mostra i suoi ingredienti per la parte che manca. Il filo ti porta alla prossima cosa da raccogliere o da creare; fatta la ricetta, esce dalla lista da sola.

[b]I consigli alla prima volta[/b]
La prima volta che succede una cosa nuova (la notte, il buio sotto terra, un blocco troppo duro, la Bisaccia piena, un Seme di mondo…) compare a destra una scheda breve. Mentre si vede, il tasto dell'Enciclopedia apre il capitolo che ne parla."""},
	{"id": "comandi", "group": "Primi passi", "name": "I comandi", "text":
"""I tasti si cambiano nelle [url=cap:opzioni]Opzioni[/url], sezione Comandi.

{tabella_tasti}

[b]Il mouse[/b]
• [b]Clic sinistro[/b]: usa ciò che hai in mano (scava, colpisci, piazza, semina, bevi).
• [b]Clic destro[/b]: tocca (apri casse e scrigni, parla con gli abitanti, portali, Albero-Madre, Sigilli, raccolti); dove non c'è niente da toccare, pianta una torcia dalla Bisaccia.
• [b]1-0 e rotella[/b]: scegli la casella della barra rapida.
• [b]Maiusc[/b] nei suggerimenti: confronta con ciò che indossi o hai in mano; nel pannello Creare, [b]Maiusc+clic[/b] crea cinque volte.
• [b]Esc[/b]: chiude il pannello aperto; se non ce n'è, apre la pausa."""},
	{"id": "vita", "group": "Primi passi", "name": "Vita, Linfa e Scorza", "text":
"""[b]Vita[/b] (la barra verde): parte da {hp} punti. Dopo {regen_delay} secondi senza ferite ricresce da sola, {regen} punti al secondo. Si alza per sempre assorbendo i [b]Cuori di bocciolo[/b] (nelle grotte) e curando i [url=cap:guardiani]Guardiani[/url].
[b]Linfa[/b] (la barra turchese): parte da {linfa} punti e ricresce sempre, {linfa_regen} al secondo. La spendono i [url=cap:combattere]bastoni[/url]. Si alza con le [b]Stille perenni[/b].
[b]Scorza[/b]: la tua difesa, somma dell'armatura, dei [url=cap:set]set[/url] e dei poteri. Ogni ferita perde metà della tua Scorza.
[b]Pozioni[/b]: ne puoi bere una ogni {potion_cd} secondi (vedi [url=cap:pozioni]Pozioni e cibo[/url]).
[b]Cadute[/b]: fino a {fall_safe} tessere non fanno male; oltre, {fall_hurt} punti di Vita per tessera. Alcuni accessori tolgono le ferite da caduta.
[b]Veleno[/b]: certe creature avvelenano; le bende lo tolgono."""},
	{"id": "appassire", "group": "Primi passi", "name": "Appassire e rinascere", "text":
"""Quando la Vita arriva a zero il Germogliato [b]appassisce[/b] e dopo qualche secondo rinasce: nel letto che hai usato per ultimo in quel mondo ([url=cap:costruire]Letto di foglie[/url], clic destro), altrimenti alla partenza.
Appassire costa: la parte grande della Bisaccia (non la barra rapida, non ciò che indossi) resta in un [b]Fagotto[/b] dove sei appassito. Il fagotto è segnato sulla mappa: torna a prenderlo con il clic destro.
Nel Giardino cadere nel Vuoto non uccide: riporta sull'isola con una piccola ferita (nessuna con il potere [url=cap:poteri]Passo nel Vuoto[/url])."""},
	{"id": "luce", "group": "Primi passi", "name": "Luce e buio", "text":
"""In TERRAWORLD dove la luce non arriva è [b]buio pieno[/b]: la luce viene dalle cose vive (torce, funghi, cristalli, alberi-lanterna, la Linfa) e dal cielo di giorno.
• Il Germogliato ha un piccolo alone attorno a sé; accessori e pozioni lo allargano.
• Le [b]torce[/b] si piantano con il clic destro dovunque tu sia (o con il clic sinistro tenendole in mano) e si riprendono. Tenute in mano fanno luce e tremolano.
• La [b]Lanterna di Linfa[/b] in mano illumina di più, di luce turchese.
• Le creature del sottosuolo nascono solo al buio e mai vicino alle torce: illuminare una grotta la rende più sicura.
Se fatichi a vedere, nelle [url=cap:opzioni]Opzioni[/url] c'è il «Chiarore del buio»."""},
	{"id": "bisaccia", "group": "Primi passi", "name": "La Bisaccia", "text":
"""La [b]Bisaccia[/b] ({bag} caselle; le prime 10 sono la [b]barra rapida[/b] in basso). Si apre con {k_bisaccia}.
• [b]Clic[/b] prende o posa una pila; [b]clic destro[/b] ne prende metà; [b]Maiusc+clic[/b] la manda nella cassa aperta.
• A sinistra l'[b]equipaggiamento[/b]: elmo, corazza, gambali e due accessori, con la Scorza totale e il set più avanti.
• Aperta, il mondo si scurisce dietro: in alto a sinistra il pannello [url=cap:creare]Creare[/url], a destra la colonna [b]Esamina[/b] (la ricetta scelta, o l'oggetto che ci posi: a cosa serve, in quali ricette, come si ottiene), in basso a sinistra la scheda del [b]Germogliato[/b].
• «Riordina» mette in ordine (non tocca la barra rapida); «Nelle casse vicine» manda ogni oggetto nella [url=cap:casse]cassa[/url] che lo tiene già.
• Il [b]Cestino[/b] (accanto al titolo della Bisaccia) elimina gli oggetti: clic sul cestino con l'oggetto in mano, o [b]Ctrl+clic[/b] su una casella. L'ultimo oggetto buttato resta nel cestino finché non ne butti un altro: un clic a mani vuote lo riprende.
Gli oggetti a terra vengono attirati quando ti avvicini, se c'è posto."""},
	{"id": "diario", "group": "Primi passi", "name": "Il diario della partita", "text":
"""Il gioco tiene un [b]diario[/b] della tua partita: le prime volte che contano (il primo viaggio, il primo gene imparato, la prima creatura addomesticata…), ogni Guardiano curato o sconfitto (dove, in quanto tempo, dopo quanti appassimenti), ogni grado di vigore nuovo, gli stadi dell'Albero-Madre, i primi lingotti di ogni metallo.
Conta anche gli [b]appassimenti[/b] (e in che strato), il [b]tempo passato in ogni strato[/b] e ciò che [b]fabbrichi[/b].
Si legge nel [b]Semenzaio[/b] ({k_semenzaio}), scheda [b]Storia[/b]: le tappe dalla più recente, e a destra il riassunto. «Esporta» lo scrive in un file di testo."""},
	{"id": "opzioni", "group": "Primi passi", "name": "Opzioni, pausa e suggerimenti", "text":
"""[b]Esc[/b] apre la pausa: da lì Opzioni, questa Enciclopedia, salvataggio, ritorno al menu.
Le [b]Opzioni[/b] coprono audio, video (schermo, fotogrammi, ingrandimento, chiarore del buio), interfaccia, gioco (pausa mentre crei, pausa con i pannelli grandi, salvataggio automatico), suggerimenti (ritardo, grandezza, nel mondo) e comandi.
I [b]suggerimenti[/b]: tieni il mouse su una casella, una creatura, una stazione, un minerale e compare la sua scheda. Tenendo [b]Maiusc[/b], armi e armature si confrontano con ciò che hai. Ricette e provenienza sono nella colonna Esamina.
Nella sezione Gioco c'è anche la [b]grandezza delle pile[/b]: quanti oggetti uguali stanno in una casella, da un quarto del normale a infinite (attrezzi, armi e armature restano uno per casella).
Il gioco [b]si salva da solo[/b] ogni pochi minuti, passando da un portale e uscendo."""},
	# il mondo
	{"id": "strati", "group": "Il mondo", "name": "Gli strati", "text":
"""Ogni mondo scende per strati, ognuno con la sua roccia, le sue creature, i suoi minerali e un pericolo più alto. Il confine tra uno strato e l'altro ondeggia; entrando in uno strato nuovo compare il suo nome.
{cat_strati}
Più in basso: minerali migliori (serve un [url=cap:scavare]piccone[/url] più forte), creature più forti, rovine più ricche. In fondo a ogni mondo c'è la cupola del [url=cap:guardiani]Cuore del mondo[/url]."""},
	{"id": "biomi", "group": "Il mondo", "name": "I biomi", "text":
"""La superficie di un mondo è divisa in biomi, ognuno con erba, alberi, piante, colline, cielo e creature suoi:
{cat_biomi}
Sotto terra ci sono i [b]biomi del sottosuolo[/b], che dipendono dai [url=cap:geni]geni[/url] del mondo:
{cat_sottosuolo}"""},
	{"id": "giorno", "group": "Il mondo", "name": "Giorno e notte", "text":
"""Un giorno dura {day_min} minuti. Di notte il cielo si spegne, escono creature più forti e più numerose, e ci sono [url=cap:eventi]eventi[/url] notturni. L'orologio in alto a sinistra dice giorno, ora e stagione.
Alcuni [url=cap:geni]geni[/url] allungano le notti o schiariscono il buio."""},
	{"id": "stagioni", "group": "Il mondo", "name": "Le stagioni", "text":
"""Ogni mondo ha quattro stagioni di {season_days} giorni l'una; due mondi vicini non sono quasi mai nella stessa.
{cat_stagioni}
Ogni stagione cambia quali creature nascono, quanto crescono le colture, quanti eventi arrivano e il colore del cielo. Ognuna ha una sua [b]creatura di stagione[/b] che lascia un materiale unico, da cui nascono quattro accessori.
I [b]geni di stagione[/b] fermano un mondo per sempre in una stagione: li cattura la Provetta toccando il cielo in quella stagione, o li lascia a volte la sua creatura."""},
	{"id": "eventi", "group": "Il mondo", "name": "Gli eventi", "text":
"""Di giorno e di notte c'è ogni volta una piccola probabilità che succeda qualcosa: più creature di un tipo, più creature rare, piogge di stelle cadenti, fioriture che danno più semi selvatici. Gli eventi con un traguardo (sconfiggere tante creature) danno un premio.
{cat_eventi}"""},
	{"id": "avvizzimento", "group": "Il mondo", "name": "L'Avvizzimento", "text":
"""La malattia dei mondi: terra, muschio e ardesia avvizziti, grigi, dove le creature sono più cattive. Finché il [url=cap:guardiani]Guardiano[/url] del mondo dorme, l'Avvizzimento si allarga piano.
• Sconfitto il Guardiano, si ferma.
• [b]Curato[/b] il Guardiano, si ritira un poco alla volta.
• A mano si purifica con il [b]Seme di muschio[/b] (cerchio piccolo) e la [b]Rugiada di Linfa[/b] (cerchio grande)."""},
	{"id": "rovine", "group": "Il mondo", "name": "Rovine, scrigni e reliquie", "text":
"""I [b]Seminatori[/b], giardinieri di prima, hanno lasciato in ogni mondo stanze di pietra: le [b]rovine[/b], con uno scrigno pieno secondo lo strato. Più in basso, bottino migliore.
• I [b]reliquiari murati[/b] nascondono le [b]reliquie[/b] dei Seminatori: tre collezioni, ognuna completa dà un dono per sempre ({cat_collezioni}). La [b]Mappa dei Seminatori[/b] indica il reliquiario più vicino.
• I [url=cap:poteri]luoghi sigillati[/url] si aprono solo con i poteri dell'Albero-Madre.
• Pericoli: rovi spinosi e rune trappola."""},
	{"id": "mappa", "group": "Il mondo", "name": "Mappa e viaggi", "text":
"""La [b]mappa[/b] ({k_mappa}) mostra tutto ciò che hai già visto: si ingrandisce con la rotella, si sposta trascinando, ci si mettono segni. La [b]minimappa[/b] ({k_minimappa}) è il ritaglio attorno a te.
Sulla mappa: la firma del mondo (stella), i portali, il fagotto se sei appassito.
Le [b]radici viandanti[/b] sono passaggi dentro lo stesso mondo: clic destro su una radice per aprire la mappa e scegliere dove andare."""},
	# scavare e costruire
	{"id": "scavare", "group": "Scavare e costruire", "name": "Scavare e i minerali", "text":
"""Il [b]piccone[/b] rompe la roccia; ogni tessera ha una [b]durezza[/b] (quanto ci vuole) e una [b]forza richiesta[/b]: un piccone troppo debole non la scalfisce. La scheda di una roccia (mouse sopra) ti dice se il tuo piccone basta.
I minerali, dal più facile:
{cat_minerali}
I minerali si fondono in lingotti al [b]Baccello ardente[/b]; con i lingotti si fanno attrezzi, armi e armature migliori (vedi [url=cap:materiali]Materiali[/url]). Il potere [url=cap:poteri]Canto delle radici[/url] fa scavare un quarto più in fretta."""},
	{"id": "alberi", "group": "Scavare e costruire", "name": "Alberi e legno", "text":
"""Ogni bioma ha la sua specie d'albero, in quattro grandezze (piccolo, medio, grande e il raro antico): i grandi reggono più colpi di [b]ascia[/b] e danno più legno.
{cat_alberi}
Abbattuto, un albero lascia legno e a volte semi: il seme piantato cresce nell'albero del bioma dove lo metti."""},
	{"id": "costruire", "group": "Scavare e costruire", "name": "Costruire", "text":
"""• [b]Blocchi[/b]: assi di legno, mattoni d'ardesia, vetro di resina (lascia passare la luce). Si piazzano con il clic tenendoli in mano.
• [b]Pareti di fondo[/b]: si piazzano allo stesso modo; il [b]Martello[/b] le toglie tenendo premuto.
• [b]Passerelle[/b]: reggono chi scende; ci si passa attraverso tenendo {k_giu}.
• [b]Porte[/b]: alte quanto il Germogliato; clic destro le apre e le chiude. Chiuse fermano anche le creature.
• [b]Stazioni e mobili[/b]: si piazzano dalla Bisaccia; si riprendono con il piccone (tranne portali e Cuore).
• [b]Letto di foglie[/b]: clic destro, e rinasci lì in quel mondo.
Un [b]Focolare[/b] con un Letto di foglie libero vicino chiama un [url=cap:abitanti]abitante[/url] (ognuno ha anche una sua condizione)."""},
	{"id": "casse", "group": "Scavare e costruire", "name": "Casse e scrigni", "text":
"""Le casse tengono gli oggetti. Clic destro per aprirle; con una cassa aperta ci sono i pulsanti:
• [b]Prendi tutto[/b], [b]Deposita tutto[/b] (non la barra rapida), [b]Deposita simili[/b] (solo ciò che la cassa tiene già), [b]Rifornisci[/b] (completa le pile della Bisaccia), [b]Riordina[/b].
• Ogni cassa ha un [b]nome[/b] (scritto sopra), «usa per creare» e che cosa [b]raccoglie[/b] (minerali, materiali, costruzione…).
• Il pannello [url=cap:creare]Creare[/url] usa gli ingredienti delle casse entro {chest_reach} tessere che hanno «usa per creare».
• Nella Bisaccia, «Nelle casse vicine» manda ogni oggetto nella cassa giusta.
Le casse hanno dei [b]gradi[/b]: più il materiale è raro, più caselle. Le prime si fanno al Ceppo, le altre al Maglio; gli scrigni dei Seminatori si trovano soltanto, pieni, nelle rovine (più grandi più si scende) e, vuoti, si portano via e si riusano.
{cat_casse}
Quanti oggetti uguali stanno in una casella lo decidi nelle [url=cap:opzioni]Opzioni[/url] (Gioco → Grandezza delle pile): da un quarto del normale fino a pile infinite."""},
	{"id": "segreti", "group": "Il mondo", "name": "I segreti", "text":
"""Ogni mondo nasce con i suoi [b]segreti[/b]: posti nascosti che nessun sentiero porta a vedere. Entrando in un mondo un avviso dice quanti sono; il contatore («trovati 4 su 13») è sulla mappa (M), nella scheda del portale e nel Semenzaio. Un mondo non è finito finché il contatore non è pieno.
Un segreto si trova [b]entrandoci[/b]: il premio dipende dal grado.
{cat_segreti}
Ci sono anche le [b]camere-enigma[/b] (piccole camere dei Seminatori con tre meccanismi), le [b]visioni[/b] (cerchi di pietre accese) e, in alcuni mondi, un'[b]anomalia[/b] che non si trova altrove.
{cat_nascoste}
Guarda bene le pareti delle grotte: alcune sono [b]finte[/b] e crollano appena ci spingi contro. La [b]Mappa del tesoro[/b], trovata in una stanza murata, segna dove scavare.
Per fiutarli: la [b]Bacchetta rabdomante[/b] (indossata o in mano: un anello attorno a te pulsa più in fretta più un segreto è vicino) e l'[b]Eco dei Seminatori[/b] (segna sulla mappa, a grandi linee, i tre più vicini). Anche le stele nella [url=cap:lingua]lingua dei Seminatori[/url] a volte indicano un luogo."""},
	{"id": "rigori", "group": "Il mondo", "name": "Le terre estreme", "text":
"""Alcuni biomi non si attraversano a mani nude: allo scoperto una [b]barra del rigore[/b] sale (accanto a Vita e Linfa) e, piena, ferisce e toglie qualcosa. Scende altrove, sotto un tetto, accanto a un [b]Rifugio del viandante[/b] (un totem) o con il rimedio giusto.
{cat_rigori}
Ci si [b]prepara[/b]: l'equipaggiamento che protegge si fa con i materiali di [i]altri[/i] biomi, e i rimedi sono pozioni che proteggono del tutto per qualche minuto. Il vetro e la brace feriscono i piedi: servono gli Stivali di scaglie. Ogni terra estrema ha anche la sua [b]tempesta[/b], che fa salire la barra il doppio."""},
	{"id": "volo", "group": "Creare ed equipaggiarsi", "name": "Il volo", "text":
"""Le [b]ali[/b] si indossano nel posto del mantello: o un mantello di metallo, o le ali. Si vola [b]tenendo Salto dopo il salto[/b]: passata la spinta, le ali sollevano finché dura la loro [b]autonomia[/b] (la barretta sopra la testa), che torna quando posi i piedi.
Ogni paio ha quattro valori: [b]salita[/b], [b]autonomia[/b], [b]velocità[/b] in volo e [b]ricarica[/b].
{cat_ali}
Le prime, le Ali di foglia, sono poco più di un lungo salto: il volo vero arriva con i biomi e il profondo. Finita la barra si cade, e allora servono ancora la planata (una Foglia planante tra gli accessori), il rampino e i salti in aria. Le leggi del mondo contano: il [b]vento[/b] porta chi vola, in un mondo [b]leggero[/b] la barra dura di più, e nelle [b]correnti ascensionali[/b] si ricarica il doppio."""},
	{"id": "farm", "group": "Scavare e costruire", "name": "Le farm", "text":
"""Una [b]farm[/b] è un posto costruito da te dove le creature nascono, cadono nelle [url=cap:trappole]trappole[/url] e il loro bottino finisce in una cassa, mentre tu fai altro. Nessuna farm è già pronta: i pezzi sono questi, il progetto è tuo.
[b]Come nascono le creature[/b] (le regole di sempre, che valgono anche per le esche):
{cat_regole_nascita}
[b]I pezzi[/b]
{cat_farm}
[b]Principi[/b]: un'esca chiama solo chi [i]vive[/i] lì (lo strato, il bioma, la notte); una creatura cade meglio in un corridoio stretto che in una grande grotta; la spinta di un getto d'acqua porta le creature sulle trappole; i nastri portano il bottino alla tramoggia; una Leva delle trappole ti lascia entrare a raccogliere. Posandoci il mouse, un'esca ti dice chi chiama e perché no.
[b]Il tetto di rendita[/b]: in ogni zona di {farm_zona} tessere, al più {farm_tetto} creature chiamate lasciano bottino ogni {farm_minuti} minuti; oltre, la zona è [i]stanca[/i] e lasciano solo un Lumino. Più farm in zone diverse rendono di più di una farm enorme."""},
	{"id": "trappole", "group": "Scavare e costruire", "name": "Le trappole", "text":
"""Le [b]trappole[/b] sono piccole stazioni che colpiscono da sole chi entra nella loro area: tu non devi esserci. Le creature che abbattono lasciano il loro bottino come se le avessi sconfitte tu, ed è così che nascono le farm.
Ogni trappola aspetta un po' prima di colpire di nuovo la [b]stessa[/b] creatura, quindi più trappole in fila fanno più danno di una sola. I [b]gradi[/b] (Ceppo con la radicite, poi Maglio con legnoferro e ambra) moltiplicano danno ed effetti.
{cat_trappole}
Le rune e il getto di brace colpiscono con un [url=cap:elementi]elemento[/url]: debolezze e reazioni valgono anche qui, e uno Stendardo di guardia vicino fa più male. Il getto d'acqua quasi non ferisce ma [b]spinge[/b]: serve a portare le creature dove vuoi. Spuntoni, lama e pressa feriscono anche te se ci passi sopra: con il clic destro una trappola si [b]disarma[/b] e si riarma. Con una trappola in mano si vedono le aree di quelle vicine (in rosso le disarmate).
Una trappola si appoggia a terra, a una parete o al soffitto. La [b]Leva delle trappole[/b] ferma o arma insieme tutte quelle entro 10 tessere: comoda per entrare nella propria farm a raccogliere."""},
	{"id": "totem", "group": "Scavare e costruire", "name": "Totem, stendardi e altari", "text":
"""Alcune stazioni non servono a fabbricare: cambiano la [b]zona[/b] attorno a sé. Ogni tipo dà il suo effetto in un raggio; i [b]gradi[/b] (Ceppo con la radicite, poi Maglio con legnoferro e ambra) allargano il raggio e rafforzano l'effetto. Con un totem in mano si vedono i raggi di quelli già piazzati e di quello nuovo.
Due totem dello stesso tipo [b]non si sommano[/b]: dove si sovrappongono vale il più forte. Tipi diversi, invece, lavorano insieme.
{cat_totem}
Gli [b]scambi[/b] danno un bonus e un costo insieme: sceglili apposta, non per caso. I [b]totem antichi[/b], più forti di quelli che si fabbricano, si trovano solo nelle rovine del profondo."""},
	{"id": "giardino", "group": "Scavare e costruire", "name": "Il giardino e le colture", "text":
"""I [b]semi da giardino[/b] si piantano sulla terra o sull'erba giusta; la coltura cresce anche lontano da te, e matura si raccoglie con il clic destro (o scavandola). L'[b]annaffiatoio[/b] la fa crescere il doppio più in fretta. Le stagioni e certi geni cambiano la crescita.
{cat_colture}
Raccogliendo piante selvatiche si trovano a volte semi nuovi."""},
]
