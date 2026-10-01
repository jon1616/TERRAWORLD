class_name EncyBondsData
## Enciclopedia, i compagni di battaglia (Roadmap 32): legare ogni creatura, la Sacca dei legami, lo stile, la
## crescita, gli oggetti, l'atteggiamento e l'affiatamento, il Libro dei legami. Stesso formato di `EncyGuideData`.

const CHAPTERS := [
	{"id": "compagni_battaglia", "group": "La vita del mondo", "name": "I compagni di battaglia", "text":
"""Ogni creatura del gioco si può **legare** (tranne Guardiani, Custodi e Signori) e portare con te in battaglia.
La **Sacca dei legami** tiene cinque compagni: **uno solo è in campo**, ti segue e combatte da solo **con lo stile della sua specie**: il lupo carica, lo sputaspore sputa da lontano, il talpone scava e sbuca sotto il nemico, chi nuota ti segue nuotando nell'aria dentro una bolla. Se resta indietro o si blocca, ricompare accanto a te.
Il tasto {k_compagno} lo evoca o lo richiama, {k_cambia_compagno} manda in campo il prossimo della sacca, {k_compagni} apre il pannello dei compagni (anche un clic sulla sua barra, in basso a destra).
Quando la sua Vita finisce va **KO**: torna nella sacca e guarisce **solo nel Giardino**. Intanto lo sostituisce uno degli altri quattro. Le ferite piccole si richiudono piano quando non combatte.
Le creature selvatiche lo vedono: chi lui colpisce, o chi gli sta molto più vicino che a te, lo prende di mira."""},
	{"id": "legare", "group": "La vita del mondo", "name": "Legare le creature", "text":
"""Il **Laccio** prende una creatura stremata (meno del 40% della Vita): più è debole, più è facile. Il **Laccio intrecciato** (al Telaio) prende fino a metà della Vita e tiene di più; il **Laccio dei Seminatori** (al Maglio) fino a tre quinti, tiene il doppio e lega anche le creature **ancestrali**.
Con il **cibo** che le piace (clic destro) ogni creatura si fida un poco di più; le **uova** dei nidi si schiudono nell'Incubatrice già tue.
Alcune creature vogliono il loro momento:
• le **avvizzite** vanno prima curate con una Rugiada di Linfa (un clic sopra);
• le creature del **Vuoto** (e le varianti «cave») si legano solo al buio;
• gli **spiriti** solo di notte, o nel buio sotto terra;
• chi **si traveste** solo quando è scoperta;
• quelle di **pietra e d'ingranaggio** (golem, sentinelle, gargolle) non le tiene nessun laccio: serve il **Sigillo del legame** (al Maglio).
Le **rare** (antiche, ancestrali, capobranco, iridate) sono più difficili, ma legate restano rare: aura, tratti e più forza.
Una creatura legata quando la sacca è piena va a riposare nel Giardino: la riserva, con i recinti e la guardia (vedi [url=cap:mandria]La mandria[/url])."""},
	{"id": "crescere_compagni", "group": "La vita del mondo", "name": "Far crescere un compagno", "text":
"""Un compagno sale di livello (fino al {lvl_max}) con l'esperienza: ogni creatura che sconfigge gliene dà secondo quanto era forte (di più se era più forte di lui), e metà quando la sconfiggi tu mentre è in campo. La **forza viene dal livello**, la specie dà la forma: allo stesso livello un grumo e un lupo si equivalgono, ma il grumo ha più Vita e il lupo colpi più duri. Al livello 20 e al 40 si vede più grande.
Gli **oggetti** si danno con un clic sul compagno in campo:
• i **Frutti del legame** (Bacca del cuore, della zanna, del guscio, del vento): +3% di Vita, di danno, di velocità o +1 di difesa per sempre, al più dieci di ognuno;
• il **Seme del ricordo**: metà di un livello di esperienza;
• gli **Istinti**: una mossa nuova (carica, scatto, sputo, ventaglio, picchiata, guscio, scudo, passo d'ombra, talpa, scoppio, folgore, cura…). I posti per le mosse si aprono ai livelli 10, 25 e 40; dal pannello una mossa si dimentica e l'istinto torna nella Bisaccia;
• le **Pietre d'elemento**: cambiano l'elemento (colori, debolezze, il segno dei suoi colpi);
• i **Ciondoli**: un posto, un dono (più danno, più Vita, più esperienza, ferite che si richiudono in fretta…);
• le **Essenze** delle creature rare: un tratto antico (al più due).
Si trovano nei baccelli dormienti (le Urne dei Seminatori danno istinti e ciondoli, i Geodi le pietre), e dalle creature: gli istinti da chi ha quella mossa, e le rare ne lasciano molti."""},
	{"id": "affiatamento", "group": "La vita del mondo", "name": "Atteggiamento e affiatamento", "text":
"""Nel pannello dei compagni scegli l'**atteggiamento**: **protettivo** (attacca chi ti minaccia), **feroce** (attacca ogni creatura ostile che vede), **prudente** (come protettivo, ma prima di cadere torna da solo nella sacca: niente KO), **fermo** (non combatte, ti segue e ti dà il suo dono).
Ogni compagno in campo ti dà un **dono**, come un accessorio (le lepri ti fanno correre, le api ricrescere la Vita, i predatori colpire più forte…).
L'**affiatamento** cresce combattendo insieme e stando in campo. Cinque gradi:
1. attacca la creatura che colpisci tu;
2. colpi più forti del 10%;
3. sulle creature segnate dal tuo elemento colpisce il 25% più forte;
4. il suo dono vale il doppio;
5. una volta per visita al Giardino resiste a un colpo che lo manderebbe KO."""},
	{"id": "libro_legami", "group": "La vita del mondo", "name": "Il Libro dei legami", "text":
"""Il **Libro dei legami** (nel pannello dei compagni) segna ogni specie che hai legato almeno una volta: sono {book_all}. A 10, 25, 50, 80, 120 e a tutte, un dono (lacci, frutti, semi, istinti, ciondoli…). La scheda di una creatura selvatica ti dice se è una specie nuova per il Libro, e come si lega.
La **Bacheca** chiede ogni tanto di legare una specie nuova o di far crescere un compagno; legare, allevare e far crescere i compagni fa salire il pilastro della mandria."""},
]
