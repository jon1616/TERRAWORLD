# TERRAWORLD — Roadmap

## Dove siamo (aggiornato il 26 set 2026)
- **Fatte**: Roadmap 1 «Le fondamenta» (voci 0-16, tranne la 6), Roadmap 2 (17-20), Roadmap 3 «Esplorare, trovare,
  crescere» (21-30 + extra), Roadmap 4 «Un mondo da abitare» (31-40), il fotogramma lento del giro lungo (pannelli che
  si ridisegnavano a ogni raccolta, vedi CLAUDE.md), la musica (autoload `Musica`, file in `musica/`) e il Germogliato
  di Nano Banana (sezione in fondo: tutte le tavole importate e in gioco).
- **La direzione (decisa con l'utente il 26 set 2026)**: «Il Giardiniere dei mondi», il piano delle Roadmap 5-11 in
  fondo a questo file; la filosofia che lo regge è in CLAUDE.md («La filosofia del gioco»). Priorità dell'utente:
  vastità, profondità, avventura e ricerca; grafica, rifinitura del movimento, armatura sugli sprite e rete **dopo**.
- **Rimandate** (scelta dell'utente): voce 6 «Rete a 2»; dal Germogliato: armatura sugli sprite nuovi, colpo in corsa;
  mostri e boss con Nano Banana.
- **Fatta la Roadmap 5 «Il Seme e i suoi geni»** (voci 41-48, 26 set 2026): resoconto in fondo alla Roadmap 5.
- **Fatta la Roadmap 6 «La materia viva»** (voci 49-54, 26 set 2026): resoconto in fondo alla Roadmap 6.
- **Fatta la Roadmap 7 «L'ecologia»** (voci 55-61, 26 set 2026): resoconto in fondo alla voce 61.
- **Fatti i ritocchi chiesti dall'utente dopo la Roadmap 7** (26 set 2026): sezione «Ritocchi dopo la Roadmap 7»
  prima della Roadmap 8 (barre di Vita e Linfa, misure di banchi, mobili, casse e porte, casse per la creazione e
  pulsanti di comodità, pannello Creare rifatto, alberi e vegetazione di ogni bioma).
- **Fatti i ritocchi dopo la Roadmap 8** (26-27 set 2026): scheda dei portali, il **sistema dei suggerimenti**, le
  **Opzioni** con la pausa e l'**Enciclopedia** (sezione «Ritocchi dopo la Roadmap 8», prima della Roadmap 9).
- **Salvataggi**: in pieno sviluppo le partite sono solo prove (scelta dell'utente): niente migrazioni per ora.
- **Fatta la Roadmap 8 «Il risveglio dell'Albero-Madre»** (voci 62-67, 26 set 2026): resoconto dopo la voce 67.
  Decisione di Claude (l'utente l'ha lasciata a lui): una partita nuova comincia nel **Giardino** sospeso nel Vuoto;
  il mondo di partenza di prima è diventato il primo mondo nato da un Seme (vigore 1).
- **Prossimo passo**: Roadmap 9 «Il mistero dei Seminatori» (voce 68, la lingua dei Seminatori). L'utente dà la
  direzione e lascia a Claude ordine e tecnica; chiede sempre un resoconto alla fine di un lavoro lungo.
- **Contenuti oggi**: 1259 oggetti (768 sono armi, attrezzi e armature generati da 48 materiali × 16 forme; 58 le
  Fiale dei geni), 1027 ricette, 45 stazioni, 47 creature (più 4 di stagione) in 36 famiglie (84 varianti per specie; 25 famiglie si
  addomesticano, 10 manti), 6 elementi e 4 reazioni, 5 biomi di superficie e 5 del sottosuolo, 5 strati,
  10 Guardiani/Custodi, 61 geni in 13 categorie, 12 firme dei mondi, 5 specie d'albero in 4 grandezze, 45
  decorazioni (13 di vegetazione dei biomi), 9 abitanti, 12 stadi dell'Albero-Madre, 6 poteri, 4 Sigilli, 4
  stagioni, 78 obiettivi; `tools/verifica_dati.gd` dà 0 errori e 0 avvisi (`tools/elenco.gd` di nuovo a posto).

# Roadmap 1: «Le fondamenta» (dal 24 set 2026)

Obiettivo: passare dal prototipo a una base che regga anni di aggiunte (meccaniche, creature, oggetti, generatore di mondi)
senza riscritture. Alla fine della Roadmap: un mondo medio generato, salvabile, esplorabile in due in rete, con il primo
anello di gioco completo (esplorare → raccogliere → fabbricare → equipaggiarsi → boss → grado successivo).
Dimensioni: S piccola, M media, L grande.

## 0. [x] L'universo, prima bozza (M) — fatto il 24 set 2026
24 set 2026: scelta la direzione «Il Giardino dei Semi»; bozza 1 in `UNIVERSO.md` (cosmo, Germogliato, semi come generatore
di mondi con specie/vigore/tratti/innesto, Cuori e Guardiani, stagioni, Avvizzimento, Albero-Madre, innesti
sull'equipaggiamento, NPC, Erbario). Decisioni dell'utente: ogni Guardiano si può sconfiggere o curare (bottino, storia e
benefici diversi); il tempo scorre sempre come in Terraria; tratti vegetali del personaggio evidenti; nome TERRAWORLD.
Le voci ❓ rimaste si decideranno quando servono.

## 1. [x] Mondo a blocchi (L) — fatto il 24 set 2026
Mondo di circa 3000×1000 diviso in blocchi (es. 64×64): generato, disegnato e illuminato solo attorno alla visuale.
Generatore a **passate** indipendenti (terreno, strati, grotte, biomi, strutture, minerali, decorazioni), ognuna
sostituibile e misurabile. Luce ricalcolata solo nella zona visibile. Strumento: mappe PNG di 20 semi + tempi per passata.
Traguardo: generazione di un mondo medio in pochi secondi, 60 fotogrammi al secondo mentre si esplora.
**Fatto**: codice riordinato in cartelle (core, data, art, world, world/gen, entities, ui, game) con Git dal primo commit.
Mondo 3000×1000 generato da 11 passate in `src/world/gen/passes/` in ~5,5 s, in un thread con schermata d'attesa.
Blocchi da 32×32 costruiti vicino alla visuale (2 per fotogramma) e liberati lontano; luce in una finestra 128×96 in un
thread. Misura della corsa in superficie: 60 fps, fotogramma peggiore ~20 ms. Grotte variate per profondità, regioni e
grandi caverne nel profondo; ingressi dalla superficie ogni 220-420 tessere. `tools/mappe.gd` per mappe e tempi.
Da migliorare più avanti (con i biomi): il sottosuolo visto dall'alto è ancora troppo uniforme; la generazione si può
accelerare con più thread se servirà.

## 2. [x] Salvataggi (M) — fatto il 24 set 2026
Come Terraria: personaggio e mondo separati. Il mondo si salva come seme + blocchi modificati. Più mondi per profilo
(pronto per i portali). Salvataggio automatico e copia di sicurezza.
**Fatto**, con un cambio rispetto al piano: il mondo si salva **intero e compresso** invece che come seme + modifiche
(il generatore cambierà spesso e i mondi salvati non devono dipenderne; 0,5 MB, salvataggio 15 ms, caricamento 17 ms
contro 5,5 s di generazione). Menu nuovo (titolo → personaggi → mondi, creazione con nome e seme), personaggi separati
dai mondi, posizione di ogni personaggio ricordata nel mondo, tempo di gioco, salvataggio automatico ogni 5 minuti, Esc
salva e torna al menu, salvataggio alla chiusura; scrittura sicura con copia `.bak` e recupero automatico.
Prove: `tools/prova_salvataggi.gd` (confronto, recupero da file rovinato) e fine delle prove automatiche (salva dal
gioco e ricarica: identico). Più avanti: eliminare mondi e personaggi dal menu, elenco a scorrimento quando sono tanti.

## 2b. [x] Stile grafico tutto nostro (M) — fatto il 24 set 2026
L'utente: «questo non è Terraria! Lo stile grafico è identico a Terraria». Tre direzioni proposte; scelta **«Radici e
Linfa» con terreno dai contorni morbidi**. Prova su un ramo Git a parte, poi approvata («schiarisci le grotte e migliora
le celle dei minerali, poi uniscilo»). Doppia griglia per il terreno, tavolozze nuove, decorazioni vive e luminose,
alberi-lanterna, cielo con le radici del cosmo, spore nell'aria, occhi d'ambra, barra rapida e menu nello stesso stile,
chiarore minimo nelle grotte, minerali a noduli. Da rifare nello stile più avanti: la torcia nel mondo (le icone degli
oggetti sono state rifatte nella voce 3).

## 3. [x] Contenuti come dati (M) — fatto il 24 set 2026
Tabelle per tessere, oggetti, ricette, stazioni di fabbricazione, creature, bottino, biomi. Uno script di verifica
controlla i riferimenti (ricette con oggetti inesistenti, creature senza bottino, ecc.), come `verifica_dati` di Inkblood.
**Fatto**: `ItemsData` (40 oggetti, famiglie di metallo generate da metalli × modelli), `RecipesData` (30 ricette),
`StationsData` (banco da lavoro, fornace, incudine), `CreaturesData` (3 slime), `LootData`; in `TileDefs` forza di
piccone richiesta (la progressione rame → ferro → oro → cristalli), cosa lascia ogni tessera, vene di minerale come dati.
Icone di tutti gli oggetti rifatte nello stile «Radici e Linfa». Il gioco usa già i dati: la barra rapida legge
`ItemsData` e lo scavo controlla la forza del piccone (il rame non stacca l'oro) e ne scala la velocità.
`tools/verifica_dati.gd`: 0 errori; 2 avvisi voluti (cristallo di Linfa e fungo luminoso non servono ancora a nessuna
ricetta: li useranno le voci 5b e 8). Biomi e strati: nella voce 5b. Nomi poi sostituiti con quelli dell'universo
(radicite, legnoferro, ambra; Ceppo, Baccello ardente, Maglio; grumi) su appunto dell'utente. Prove automatiche rese robuste (niente attese su
`frame_post_draw`, grotta con torcia cercata tra più candidati).

## 4. [x] Il giocatore (L) — fatto il 24 set 2026
Inventario, barra rapida, equipaggiamento (armatura in 3 pezzi, accessori), vita e mana, fabbricazione vicino alle
stazioni, raccolta degli oggetti a terra. Passata sulla sensazione dei controlli **con le prove dell'utente**.
**Alberi** (aggiunti il 24 set 2026 su richiesta dell'utente): si abbattono con l'ascia, il tronco cade a pezzi, si
raccoglie il legno — la prima risorsa, serve per il banco da lavoro e le prime costruzioni.
24 set 2026, anticipato su richiesta dell'utente: valori di base del movimento (corsa da 150 a 95 px/s, accelerazione e
frenata più morbide, salto pieno 3,3 tessere che basta per un muro di 3 blocchi, movimento calcolato a ogni fotogramma
disegnato per la fluidità); le prove automatiche misurano velocità, salto e il muro di 3 blocchi.
Divisa in 4a Bisaccia e raccolta · 4b alberi · 4c stazioni e fabbricazione · 4d equipaggiamento, vita e Linfa.
**4a fatta il 24 set 2026**: la **Bisaccia** (40 caselle, le prime 10 sono la barra rapida; si apre con E; si salva con
il personaggio; corredo iniziale piccone e ascia di radicite, spada di radice, 10 torce). Ciò che si scava cade a terra
e viene attirato nella Bisaccia; funghi e torce si raccolgono; i blocchi si piazzano dalla mano; le torce si consumano.
Prove: raccolta, piazzamento, Bisaccia salvata e ricaricata identica, foto della Bisaccia aperta.
**4b fatta il 24 set 2026**: gli alberi-lanterna si abbattono con l'ascia (3 colpi con quella di radicite; l'albero
trema a ogni colpo e cade dalla parte opposta al giocatore), lasciano 6-10 legni e spesso un **seme d'albero-lanterna**
(scelta legata all'universo: i semi sono il cuore del Giardino). Il seme si pianta sul muschio: nasce un germoglio che in
2,5-5 minuti di gioco diventa un albero, così il legno è rinnovabile. Germogli salvati nel mondo; il blocco sotto un
albero non si scava finché l'albero c'è.
**4c fatta il 24 set 2026**: stazioni (Ceppo del Giardiniere, Baccello ardente che fa luce, Maglio dei Seminatori)
disegnate nello stile, piazzate e riprese, salvate nel mondo; colonna **«Creare»** a destra della Bisaccia con le
ricette delle stazioni vicine (possibili in cima, le altre attenuate, suggerimento con i materiali che servono e quanti
se ne hanno); **passerelle di radice** (una tessera a parte: si sale saltando da sotto, si scende tenendo S).
Prove: giro completo legno → ceppo → passerelle e torce → baccello ardente, passerella piazzata e ripresa.
**4d fatta il 24 set 2026**: **Vita** come 10 foglie che appassiscono, **Linfa** come gocce turchesi, **Scorza** (la
difesa dell'equipaggiamento, metà del suo valore tolta a ogni ferita); equipaggiamento (elmo, corazza, gambali) in una
colonna accanto alla Bisaccia e **disegnato sul personaggio**; ferite da caduta oltre 12 tessere; **Pozione di rugiada**
(la cura, rinominata per non confonderla con la Linfa); il Germogliato che appassisce rinasce alla partenza; Vita e
Linfa salvate. Trovato e corretto: il salto dipendeva dalla frequenza dello schermo (a 144 Hz non si superava il muro di
3 blocchi); ora è identico a 60 e a 144 fps.
Resta aperta, con le prove dell'utente, la passata sulla sensazione dei controlli.

## 5. [x] Creature e combattimento (L) — fatto il 24 set 2026
Un sistema unico a comportamenti combinabili (cammina, salta, vola, scava, spara, carica, evoca, fasi). Danno,
contraccolpo, invulnerabilità breve, bottino. Prime 4-5 creature. Armi da mischia e a distanza.
**Fatto il 24 set 2026**: una sola classe `Creature` che monta comportamenti combinabili, uno per file
(`salta_verso`, `cammina`, `vola`, `carica`, `spara`, `fermo`; «scava», «evoca» e «fasi» arriveranno con i Guardiani).
**7 creature** nei dati, disegnate dal codice con 2 fotogrammi: grumo di muschio, di resina, di spore; **falena di
brace** (vola ondeggiando, brilla); **strisciaradice** (cammina, nodi di Linfa luminosi); **scarabeo d'ardesia** (guscio
duro, si ferma, trema e carica a testa bassa); **sputaspore** (pianta ferma che sputa spore con parabola mirata).
La **fauna** le fa comparire fuori dalla visuale secondo lo strato (al massimo 7, mai vicino alle torce) e le toglie
quando ci si allontana. Combattimento: ogni giro dell'arma colpisce una volta (danno, velocità e spinta dall'oggetto;
anche piccone e ascia colpiscono, più piano); **arco** con posa di mira che tira **dardi** dalla Bisaccia; ferite al
contatto e dalle spore con 0,7 s di invulnerabilità, spinta indietro e lampeggio; numeri che salgono, barra della vita
sopra la creatura colpita, sbuffo alla morte e **bottino** a terra (materiali nuovi: polvere di brace, scaglia
d'ardesia, sacca di spore; la polvere fa 4 torce, le scaglie la **Corazza di scaglie**).
Prove: contatto, spada (strisciaradice abbattuta, legno raccolto), arco (grumo a 7 tessere), spora che colpisce,
comparsa per strato, foto di tutte le creature (15_creature) e della mira con l'arco (16_arco).

## 5b. [x] Strati di profondità (L) — aggiunta il 24 set 2026, fatta il 24 set 2026
Il mondo cambia scendendo: cinque strati con identità propria — **Superficie** (muschio, alberi-lanterna),
**Sottobosco di radici** (terra intrecciata di radici enormi, ambra), **Caverne d'ardesia** (grandi vuoti, ferro, primi
pericoli seri), **Profondità della Linfa** (cristalli, funghi luminosi, oro, creature luminose), **Il Fondo** (vicino al
Vuoto, rocce strane, il Cuore del mondo e il suo Guardiano). Per ogni strato: materiali, pareti, decorazioni, luce,
minerali, creature e difficoltà crescente, tutto in una tabella di dati. Viene dopo contenuti come dati (3) e creature
(5) perché ne ha bisogno, e prima del primo anello di gioco (8) perché l'anello si svolge dentro gli strati.
**Fatta il 24 set 2026**: tabella `StrataData` con i 5 strati (profondità d'inizio, confine che ondeggia e si
sfrangia, roccia, sacche, parete, chiarore, pericolo, scritta). Tre rocce nuove disegnate dal codice: **radice antica**
(radici giganti che scendono serpeggiando nel Sottobosco e attraversano le grotte come ponti), **scisto di Linfa**
(grigio-turchese con vene di Linfa) e **vuotite** (viola scuro con scintille, vuole il piccone di legnoferro); tre
pareti nuove (radici, scisto, vuotite: nel Fondo sembra un cielo stellato). Il Fondo ha grandi vuoti e un pavimento di
vuotite. Minerali per strato e roccia (radicite in alto, legnoferro nel mezzo, ambra dalle Caverne in giù), cristalli
dalle Profondità della Linfa. Decorazioni per strato, due nuove: **scheggia del Vuoto** (si raccoglie) e **goccia di
Linfa** che pende. Chiarore di fondo del colore dello strato, sfumato, e **scritta con il nome** quando si entra in uno
strato. Creature più forti scendendo (Vita e danno × pericolo: da 1 a 2,3) e una nuova del Fondo, il **Vagavuoto**
(occhio di vuotite che fluttua e scaglia schegge). Prove: foto di ogni strato (17-20) con scritta e chiarore controllati.

## 6. [ ] Rete a 2 (L)
Host autoritativo. All'ingresso l'host manda il mondo compresso (~0,5 MB, lo stesso formato del salvataggio: niente
dipendenza dalla versione del generatore), poi solo le tessere che cambiano. Movimento reattivo per chi non è host. Prova con due istanze vere del gioco (come la prova di rete di Inkblood).

## 7. [x] Prova con Nano Banana (M) — insieme all'utente, fatto il 26 set 2026
Un personaggio con camminata, salto, colpo e un'armatura. Prompt pronti, griglia fissa su magenta, script di
importazione con riduzione a tavolozza comune. Esito: si decide come fare tutte le animazioni.
**Fatto il 26 set 2026** (vedi la sezione «Il Germogliato di Nano Banana» in fondo): tutte le animazioni del
personaggio, tranne l'armatura (aperta).

## 8. [x] Il primo anello di gioco (L) — fatto il 24 set 2026
Radicite → legnoferro → ambra fossile con Ceppo, Baccello ardente e Maglio; 10-15 oggetti per grado; il primo
Guardiano (da sconfiggere o curare) che sblocca il grado successivo; usi per cristalli di Linfa e funghi luminosi.
Primo portale verso un secondo mondo (anche solo come prova).
**Fatto il 24 set 2026**:
- **Gradi**: radicite → legnoferro → ambra → **Linfa** (il quarto grado, aperto dal Guardiano): per ogni metallo
  piccone, ascia, spada, **arco**, elmo, corazza, gambali (28 oggetti di metallo). Il lingotto di Linfa ha due ricette:
  cristalli di Linfa + **Frammento del Nodo** (Guardiano sconfitto) oppure + **Linfa del Guardiano** (Guardiano curato).
- **Oggetti nuovi**: Pozione di bagliore (funghi luminosi, gelatina, sacca di spore: il Germogliato brilla 3 minuti),
  Pozione di scorza (+8 Scorza), Lanterna di Linfa (luce turchese in mano), Dardi di vuotite (l'arco li preferisce),
  **Rugiada di Linfa** (cura i nodi avvizziti), Seme di mondo. Ora ogni materiale serve a qualcosa: 0 avvisi.
- **Il Cuore del mondo**: una cupola nel Fondo, lontana dalla partenza, con il nido di radici, passerelle, due gallerie
  d'ingresso, quattro **nodi avvizziti** sul soffitto e il Cuore malato al centro. Nel Fondo un «battito» dice da che
  parte andare.
- **Il primo Guardiano, il Nodo Avvizzito**: si sveglia entrando nella cupola; vola ondeggiando, scaglia ventagli di
  spore, ogni tanto trema e scatta addosso; sotto metà Vita diventa rosso, più rapido e chiama grumi in aiuto. Barra
  della Vita in alto.
- **Due strade** (decisione dell'utente): **sconfitto** → 30 Frammenti del Nodo, schegge, ambra; **curato** (Rugiada
  su tutti e quattro i nodi, anche durante la lotta) → il Guardiano si calma e torna radice viva, lascia 30 Linfa del
  Guardiano e dona **+20 Vita massima per sempre** (una foglia in più). Ognuna ha la sua pagina di storia. In entrambi
  i casi il Cuore torna vivo e dona un **Seme di mondo**.
- **Il portale**: il Seme si pianta sul terreno e cresce un arco di radici con un vortice di Linfa; clic destro = si
  salva e si passa al mondo nato da quel seme (generato la prima volta, poi sempre lo stesso). Per ora il mondo nuovo
  è uguale per difficoltà e non c'è un portale di ritorno (si torna dal menu).
Prove: risveglio, seconda fase con grumi evocati, sconfitta (Cuore vivo), cura (4 nodi, Vita massima 120), lingotto
di Linfa dalle due strade, bagliore e lanterna, portale piantato (foto 21-25).

**Buio vero** (25 set 2026, dopo la prima partita dell'utente: «il buio non c'è, le torce non servono»): tolte le
~1300 torce già accese della passata provvisoria; chiarore di fondo quasi nero tinto dallo strato; la luce perde il 12%
per tessera d'aria; il Germogliato ha un piccolo alone suo; decorazioni luminose come piccole pozze di luce. Prova:
misura della luce in una grotta buia e dopo una torcia (02_grotta_buia, 02_grotta_torcia).
Poi, con un'immagine di riferimento dell'utente: nero pieno dove la luce non arriva (chiarore di fondo a zero e soglia
di taglio della luce, confine netto tra luce e buio), radici accese più rare e più deboli.

Ordine di lavoro (deciso il 24 set 2026): 3 → 4 → 5 → 5b → 6 → 7 → 8.

## Cicli autonomi (dal 25 set 2026) — l'utente al lavoro, Claude decide ordine e tecnica
L'utente prova il gioco la sera e dà il suo parere. Scelta dell'ordine: prima ciò che rende la prova di stasera più
ricca (obiettivi per esplorare, ritmo del giorno, orientarsi), poi i mondi a portale veri; la **rete a 2 (voce 6)**
viene dopo perché va provata con due giocatori veri, e la **voce 7** si fa insieme all'utente.
Ogni ciclo: dati → codice → prove automatiche e foto → ROADMAP/CLAUDE.md → commit.

## 9. [x] Giorno e notte (M) — fatto il 25 set 2026
Il tempo scorre sempre (UNIVERSO.md): giorno di 20 minuti, alba e tramonto; di notte il cielo si spegne, la luce del sole
cala, in superficie compaiono più creature (e una della notte). Ora del giorno salvata nel mondo, orologio nell'HUD.
**Fatto il 25 set 2026**: `DayCycle` (giorno di 20 minuti, un mondo nuovo comincia alle 7), sole che fa l'arco, luna e
stelle di notte, cielo e colline rosati al tramonto e blu di notte; la luce del cielo cala fino alla luce della luna
(la superficie di notte è scura, le torce contano anche lì). Di notte in superficie fino a 4 creature in più e
l'**Avvizzito errante** (guscio di radici malate con gli occhi d'ambra, solo di notte). Orologio «Giorno N · hh:mm» in
alto a sinistra; ora e giorno salvati nel mondo. Prove: luce del cielo a mezzogiorno, tramonto e mezzanotte, creature
della notte solo di notte, foto 26_tramonto e 27_notte (le altre prove girano a mezzogiorno fisso).

## 10. [x] Rovine e scrigni dei Seminatori (L) — fatto il 25 set 2026
Piccole rovine sparse negli strati, con uno **scrigno** dal bottino secondo lo strato (oggetti che non si fabbricano:
accessori, semi, pozioni, lingotti). Lo scrigno si apre con il clic destro e ha le sue caselle. Obiettivi per esplorare.
**Fatto il 25 set 2026**: 44 rovine per mondo (12 nel Sottobosco, 11-12 nelle Caverne e nelle Profondità della
Linfa, 9 nel Fondo): stanze di **Pietra dei Seminatori** (mattoni con rune, un po' crollate, un'apertura su un lato),
parete lavorata, **rune accese** al soffitto e uno **Scrigno dei Seminatori** con il bottino dello strato (tabelle
«rovina_1-4»: lingotti, pozioni, dardi, cristalli, Rugiada di Linfa nel Fondo, e **accessori**). Pannello dei
contenitori sopra la Bisaccia: clic prende/posa, clic destro metà pila, **Maiusc+clic** sposta subito dall'altra
parte, **Prendi tutto**; si chiude chiudendo la Bisaccia o allontanandosi. Lo scrigno vuoto si porta via; la **Cesta
di radici** (8 legni al Ceppo) è il contenitore da fabbricare. Contenuti salvati con il mondo.
**Accessori** (nuova profondità dell'equipaggiamento, 2 caselle accanto all'armatura, due uguali non si sommano):
Stivali di radice svelta (corsa ×1,25), Foglia planante (plana tenendo Spazio, niente ferite da caduta), Amuleto di
corteccia (+4 Scorza), Anello di lucciola (alone ×1,6), Cuore di muschio (Vita che ricresce ×2), Pappo di seme (salto
×1,18). Prove: scrigni per strato, apertura, Prendi tutto, scrigno portato via, effetti degli accessori, cesta piena
salvata e ricaricata identica (foto 28_rovina_scrigno).

## 11. [x] Mappa del mondo esplorato (M) — fatto il 25 set 2026
Tasto M: la mappa di ciò che il Germogliato ha visto (nebbia sul resto), con la partenza, il Cuore se trovato, i
portali. Esplorato salvato con il mondo.
**Fatto il 25 set 2026**: ciò che la luce tocca attorno al Germogliato diventa «visto» (`World.explored`, salvato con
il mondo compresso: pochi byte in più); `MapReveal` dipinge un pixel per tessera con i colori delle rocce e delle
pareti (in un thread all'avvio, poi a pezzi mentre si gioca). Tasto **M**: mappa a schermo intero, rotella per
ingrandire (5 livelli), trascinare per spostarsi, segni per il Germogliato, la partenza, il Cuore, i portali, le
ceste e gli scrigni già visti. Aperta la mappa, il mouse non scava. Prove: celle viste, foto 29_mappa, mappa uguale
dopo salvataggio e ricaricamento.

## 12. [x] Mondi a portale veri (M) — fatto il 25 set 2026
Il Seme di mondo porta a un mondo più vigoroso (creature più forti, minerali più ricchi) e nel mondo nuovo nasce un
portale di ritorno accanto alla partenza.
**Fatto il 25 set 2026**: ogni mondo ha un **vigore** (il primo 1); il portale porta a un mondo con un vigore in più
(«Nome, vigore 2»): creature e Guardiano +35% di Vita e danno per ogni punto, vene di minerale più grandi. Nel mondo
nuovo nasce un **portale di ritorno** accanto alla partenza, con la scritta del mondo e del vigore all'arrivo. Ogni
portale ricorda la sua destinazione (`world_meta["portali"]`), il menu mostra il vigore dei mondi. Prova del viaggio
vero con i cambi di scena (`-- --prove --prova-portale`): andata, controlli nel mondo nuovo, ritorno (foto
30_mondo_oltre_il_portale).

## 13. [x] Biomi di superficie (L) — fatto il 25 set 2026
Prime zone diverse in superficie (foresta-lanterna, paludi di spore, distese d'ambra), dati in una tabella, una passata
del generatore, creature e decorazioni proprie.
**Fatto il 25 set 2026**: `BiomesData` e la passata Biomi (subito dopo il Terreno): la superficie è divisa in tratti di
220-440 colonne, mai due uguali di fila, foresta attorno alla partenza. **Foresta-lanterna** (com'era), **Paludi di
spore** (terreno basso e piatto, muschio di spore viola, sacche di spore e funghi luminosi, sputaspore e grumi di
spore in superficie) e **Distese d'ambra** (erba d'ambra dorata, colline alte e valli profonde, pochi alberi, sassi e
campanule d'ambra, scarabei d'ardesia in superficie). Passaggio morbido del terreno tra i biomi, cielo tinto dal
bioma, scritta con il nome entrando. Bioma di ogni colonna salvato con il mondo; germogli e alberi crescono su tutte le
erbe. Prove: colonne per bioma, visita e creature di paludi e ambra (foto 31_paludi, 32_ambra).

## 14. [x] Erbario (M) — fatto il 25 set 2026
Il catalogo di ciò che si è scoperto (creature, oggetti, pagine di storia), con la percentuale di completamento.
**Fatto il 25 set 2026**: tasto **L**. Tre schede: **Creature** (contano quelle sconfitte, con quante volte, Vita,
danno, dove vivono), **Oggetti** (ogni oggetto entrato nella Bisaccia o indossato, con la descrizione) e **Pagine di
storia** (quelle lette, rileggibili). Voci non scoperte con il punto di domanda; percentuale in alto, per sezione e
totale; avviso «Erbario: nuova voce». Salvato con il personaggio, quindi vale in tutti i mondi. Prove: percentuali,
foto 33_erbario, Erbario uguale dopo il salvataggio.

## 15. [x] Tratti dell'equipaggiamento (M) — fatto il 25 set 2026
Aggiunta dai cicli autonomi per l'«equipaggiamento profondo» chiesto dall'utente: ogni arma, attrezzo, armatura e
accessorio nasce con un **tratto** a caso o nessuno (`TraitsData`): Spina (+15% danno), Vento (+12% velocità), Radice
profonda (+40% spinta), Linfa viva, Tenacia (+25% scavo e taglio), Seccume e Crepa (peggiori); per le armature
Corteccia, Muschio fitto (+1/+2 Scorza), Piuma (+5% corsa), Tarlo; per gli accessori Fiore, Brezza, Lucciola. Il nome
mostra il tratto («Spada di legnoferro [Spina]»), il suggerimento dice l'effetto, le caselle hanno una stellina. Al
**Maglio** una riga «Rinnova il tratto» cambia il tratto dell'oggetto in mano per 3 Polvere di brace (sempre diverso).
Tratti salvati nella Bisaccia, nell'equipaggiamento indossato e nelle ceste; il corredo iniziale non ne ha. Prove:
distribuzione, effetto sul danno, Scorza e corsa indossando, rinnovo, salvataggio.

## 16. [x] Obiettivi del Germogliato (M) — fatto il 25 set 2026
Aggiunta dai cicli autonomi per «avere sempre obiettivi da raggiungere» (priorità dell'utente): 21 traguardi in ordine
(`ObjectivesData`), dal primo albero al Ceppo, alle torce, ai cinque strati, alla prima notte, agli scrigni, agli
accessori, al Maglio e al legnoferro, ai cristalli, al Cuore, al Guardiano, al portale e a metà Erbario. I prossimi tre
sono sempre in alto a sinistra con il conteggio; ogni traguardo dà una piccola ricompensa (pozioni, torce, lingotti,
Rugiada…) e un avviso. Salvati con il personaggio insieme ai conteggi (notti, scrigni aperti, viaggi, strato più
profondo, Cuore trovato). Avvisi spostati al centro (erano sopra la Vita), aiuto in alto su due righe.

## 17. [x] Suoni generati dal codice (M) — fatto il 25 set 2026
Prima non c'era nessun suono. Come la grafica, anche i suoni nascono dal codice: ricette in `SoundsData` (toni, rumore
filtrato, scivolamenti, vibrato, inviluppi) trasformate in campioni da `SfxSynth`, suonate da `Sfx` con un filo di
variazione di tono e più piano da lontano. 22 effetti: scavo (terra o roccia), rottura, posa, colpi d'ascia, albero
che cade, torcia, colpo, creatura colpita, morte, ferita, arco, spora, salto, atterraggio, raccolta, fabbricazione,
scrigno, pozione, obiettivo, portale, risveglio del Guardiano. Un **sottofondo per strato** (vento in superficie,
calore nel Sottobosco, freddo nelle Caverne, luccichio nella Linfa, rombo nel Fondo) in anelli senza cuciture, sfumati
cambiando strato. Limitatore contro la distorsione. Strumento `tools/suoni.gd`: salva tutto in prove/suoni/*.wav con
durata, picco e volume medio. Nel menu **Impostazioni**: volume degli effetti e del sottofondo (salvati sul computer,
`Settings`). Trovata e corretta una regressione delle prove: dal cambio del buio la prova di scavo,
raccolta e posa veniva saltata senza avviso.

## 18. [x] L'Avvizzimento (L) — fatto il 25 set 2026
Primo pezzo della Roadmap 2 («l'Avvizzimento che si espande»), legato alla scelta del Guardiano: due macchie per mondo
in superficie (passata Avvizzimento), con **terra, muschio e ardesia avvizziti** grigi e marci. `Blight` le allarga
piano (contagio sul bordo ogni 1,5 s) **finché il Guardiano dorme**; sconfitto il Guardiano si fermano, **curato si
ritirano** un poco alla volta. Purificare a mano: **Seme di muschio** (5 da un seme d'albero-lanterna e 2 gelatine,
cerchio di 4 tessere) e Rugiada di Linfa (cerchio di 7). Le zone avvizzite danno **cenere avvizzita** → **Pozione di
vigore** (+20% danno per 3 minuti); scritta «Terre avvizzite», cielo grigio, Avvizziti erranti anche di giorno;
obiettivo «Purifica una zona avvizzita». I suoni ora si generano in un thread. Prove: zone, contagio, ritiro,
purificazione (foto 35_avvizzimento, 36_purificato).

## 19. [x] I Guardiani dei mondi oltre i portali (L) — fatto il 25 set 2026
Per la longevità dei mondi a portale: ogni vigore ha il suo Guardiano (`GuardiansData`). Vigore 1 il Nodo Avvizzito,
vigore 2 la **Regina delle Spore** (medusa di spore volante: ventagli larghi, scatti, evoca grumi di spore; 1300 Vita),
vigore 3 il **Colosso d'Ardesia** (montagna di scaglie che cammina, carica, scaglia rocce ed evoca scarabei; 2200
Vita); poi si ricomincia, più forti. Ognuno con le sue due strade: la Regina lascia **Velo di spora** (sconfitta) o
**Polline della Regina** (curata) → **Lingotto di vuotite forgiata** e il grado 5 «di vuotite forgiata»; il Colosso
lascia **Nucleo del Colosso** o **Pietra che batte** → **Lingotto stellare** e il grado 6 «stellare». Quattro pagine di
storia nuove. Il Guardiano sveglio fa luce attorno a sé (nel buio vero la lotta non si vedeva). Prove: risveglio con il
vigore 2 e 3, sconfitta e bottino, lingotti dalle due strade (foto 37_regina_spore, 38_colosso_ardesia).

## 20. [x] Pericolo e creature antiche (L) — fatta il 25 set 2026
Dopo la prima partita dell'utente («troppo facile, non c'è molto rischio ad esplorare»), con la richiesta: niente
decine di mostri in superficie, pericoli adeguati alla zona; le creature rare e forti come parte fondamentale del gioco.
**20a fatta il 25 set 2026 — pericolo per zona**: `DangerData` calcola il pericolo dove si trova il Germogliato (strato
1 / 2,5 / 3,5 / 4,5 / 5,5; +1,5 di notte in superficie; +1,5 nelle terre avvizzite; +1 per punto di vigore) e da lì il
tetto di creature (superficie di giorno 2, di notte 4, Fondo 8) e il ritmo delle nascite (7 s / pericolo). Sotto terra
le creature nascono **solo al buio** (le torce sono un riparo), appena fuori dalla visuale (28-44 tessere). Danno delle
creature ×1,35, Vita che ricresce dopo 10 s (prima 6) e più piano. **Appassire costa**: la parte grande della Bisaccia
(non la barra rapida né ciò che si indossa) resta in un **Fagotto del Germogliato** dove si è caduti, segnato sulla
mappa; svuotato sparisce. Prove: tabella del pericolo per zona, fagotto lasciato e recuperato.
**20b fatta il 25 set 2026 — creature antiche**: ogni creatura che nasce può essere **antica** (1 tratto, Vita ×3,
danno ×1,4, più grande; dal 3% in superficie al 10% nel Fondo) o **ancestrale** (2-3 tratti, Vita ×7, danno ×1,8; dallo
0,3% all'1,7%, annunciata da un avviso e da un suono). 11 tratti (`AncientData`): Furiosa, Corazzata, Rapida, Gigante,
Velenosa (avvelena il Germogliato), Spinosa (ferisce chi la colpisce da vicino), Rigenerante, Evocatrice, Luminosa (fa
luce), Esplosiva (scoppia morendo), Evanescente (quasi invisibile finché non è vicina). Si riconoscono da un contorno
acceso (arancio le antiche, viola le ancestrali, visibile anche al buio), dalla scritta con i tratti e dalla Vita sempre
in vista. Bottino doppio o quadruplo e un'**Essenza** per ogni tratto: al **Maglio** si **innesta** su un'arma,
un'armatura o un accessorio e dà un tratto che non esce mai a caso (Furia, Guscio, Fulmine, Vastità, Veleno, Spine,
Linfa lenta, Fortuna, Lucciola viva, Scoppio, Ombra). Nell'Erbario le rare sconfitte; tre obiettivi nuovi (antica,
innesto, ancestrale). Prove: probabilità per zona, statistiche, veleno, spine, Essenze, innesto, foto 41_antiche.
**20c fatta il 25 set 2026 — pericoli dell'ambiente** (passata Pericoli, modulo `Hazards`): **rovi spinosi** sui
pavimenti delle grotte dalle Caverne in giù (4-8% dei pavimenti, più fitti scendendo) e nelle terre avvizzite: pungono
(6 + 4 per strato), le punte brillano appena per vederli al buio, si tagliano come ogni decorazione; **rune trappola**
sui pavimenti delle rovine (2 per rovina): una scarica di spore (ferita e veleno), poi si spengono. Prove: rovo che
punge, runa che scatta e si spegne (foto 42_rovi). Corretto anche il ritardo delle foto nelle prove.

**Roadmap 2 «Il mondo vivo»** (prevista): biomi di superficie e sotterranei (foresta-lanterna, paludi di spore, distese
d'ambra, giardini di cristallo…), strutture e rovine dei Seminatori, l'Avvizzimento che si espande, e i **Semi che
decidono il mondo** (specie = quali biomi, vigore = difficoltà, tratti = particolarità). Poi: mondi a portale veri,
NPC, eventi, bottino con modificatori, altri boss — a Roadmap successive.

# Roadmap 3 «Esplorare, trovare, crescere» (25 set 2026)

Richiesta dell'utente prima di uscire: «siamo circa al 5% dei contenuti e delle meccaniche». Esplorazione pericolosa ma
avvincente con ricompense adeguate; molti più oggetti ed equipaggiamento, **set con bonus**, altre **rarità di mostri
con bottino proprio** (non solo di più), molti più **tipi di mostri**, interfaccia chiara e pulita, più meccaniche,
**cose da trovare**, **obiettivi e boss intermedi**, altri **banchi da lavoro** e **minerali**. Carta bianca.

## 21. [x] Doni da trovare e armi di Linfa (M) — fatto il 25 set 2026
Passata **Doni**: 60 **Boccioli del cuore** sui pavimenti delle grotte dal Sottobosco in giù (lasciano il **Cuore di
bocciolo**: +10 Vita massima per sempre, fino a 15) e 36 **Stille perenni** appese ai soffitti dalle Profondità della
Linfa in giù (+4 Linfa massima, fino a 10), lontani tra loro e più fitti scendendo; brillano nel buio. La Linfa ora
serve: quattro **bastoni** (`SpellsData`, modulo `Spells`) che tenendo premuto tirano incantesimi verso il mouse
spendendo Linfa: **brace** (faville che fanno luce), **spore** (ventaglio di tre ad arco), **cristallo** (scheggia che
attraversa quattro creature), **Vuoto** (sfera che attraversa la roccia e insegue la creatura più vicina). **Pozione di
Linfa** (senza attesa). Vita e Linfa: foglie in righe da 10 (oltre le 20 ognuna vale di più), numeri «attuale/massimo».
Prove con `--solo=doni` (nuovo filtro delle prove): doni nel mondo, assorbire e tetto, pozione, scheggia su 3 creature
in fila, sfera che insegue alle spalle (foto 43_bastoni, 44_bocciolo).

## 22. [x] Il bestiario si allarga (L) — fatto il 25 set 2026
**15 creature nuove** (da 12 a 27), almeno due per strato, ognuna con il suo modo di essere pericolosa e un materiale
proprio. Superficie: **Corvo di corteccia** (vola alto e si getta in picchiata), **Spinoriccio** (si appallottola e
carica rotolando), di notte gli sciami di **Lucciole voraci**. Sottobosco: **Tessiradice** (appeso al soffitto, ti
cade addosso e tira ragnatele che invischiano: corsa a metà), **Talpone di humus** (nuota nella terra, si vede solo la
polvere, salta fuori a mordere), **Saltafungo**. Caverne: **Ala d'ardesia** (svolazza sopra la testa e scatta),
**Chiocciola di cristallo** (colpita si chiude nel guscio: un quarto del danno), **Geomimo** (un mucchio di rocce con
i cristalli che si sveglia quando gli sei addosso). Profondità della Linfa: **Serpe di Linfa**, **Campanula errante**
(fluttua alta e fa piovere polline), **Guizzalinfa** (sparisce e ti ricompare accanto). Il Fondo: **Mietivuoto**
(scatta rasoterra con le falci), **Tessivuoto**, **Sciame di schegge**. Sei comportamenti nuovi (agguato, scava,
teletrasporto, guscio, bombarda, mimo), sciami (`group`: le compagne non contano nel tetto), `hover` per chi vola alto.
14 materiali e 18 oggetti nuovi (`BeastItemsData`): Dardi piumati e d'aculeo, Mantello di penne (planata), Collana
d'aculei (spine), Benda di seta (cura il veleno), Guanti del talpone (scavo +35%), Pozione di rigoglio, Ali di
membrana, Scudo di guscio, Anello del geode (fortuna), Stivali della serpe (corsa +40%), **Specchio del guizzo**
(riporta alla partenza), Falce del Vuoto, Velo d'ombra; l'Anello di lucciola ora si fabbrica. `verifica_dati` salva
anche il foglio di tutte le creature (prove/creature.png). Prove `--solo=bestiario`: ogni comportamento, gli
accessori, lo specchio (foto 45_bestiario, 46_agguato).

## 23. [x] Rarità nuove e trofei (M) — fatto il 25 set 2026
Due rarità nuove oltre ad antiche e ancestrali (`AncientData`, tirate in ordine dalla più rara): il **Capobranco**
(dall'1,7% in superficie al 4,3% nel Fondo; contorno verde, 0-1 tratti, guida un branco di 2-4 compagne della sua
specie; mai per chi nasce già in sciame) e la **Creatura iridata** (dallo 0,4% allo 0,9%; colori che cambiano di
continuo, non attacca, **fugge** e se non la prendi in 75 secondi **svanisce**; si annuncia come le ancestrali).
Il bottino delle rare non è solo «di più»: ogni specie ha un **trofeo** proprio (24, `TrophyItemsData`) che lasciano
**solo le sue rare** (antiche 35%, le altre sempre), e ogni trofeo apre un **oggetto unico** legato a quella creatura
(24 al Maglio: Cuore di grumo, Pelle di resina, Sacca d'aria, Lume di falena, Corno di carica, Bastone sputaspore,
Amuleto dell'errante, Pugnale di becco, Guscio di riccio, Guanti di seta, Muso del talpone, Ali d'ardesia, Guscio a
spirale, Pietra del mimo, **Zanna di serpe** che avvelena, **Bastone di polline**, **Mietitrice**, Rete del Vuoto,
Schegge orbitanti…). Le iridate lasciano la **Polvere iridata** per i quattro oggetti più rari: **Corona del
Giardino**, **Arco iridato** (tre dardi a tiro), **Bastone iridato** (luce che attraversa e insegue), **Mantello
iridato**. Effetti nuovi degli accessori: danno, colpi più rapidi, Linfa che ricresce. Oggetti: 146 → 199. Prove
`--solo=rarita`: probabilità, branco, trofeo, fuga e svanire, polvere, accessori, arco (foto 47_rarita).

## 24. [x] Minerali e gemme (M) — fatto il 25 set 2026
Due **metalli laterali** con la famiglia completa (piccone, ascia, spada, arco, elmo, corazza, gambali: 14 oggetti
nati da due righe di `METALS`): la **pallidite** (Sottobosco e Caverne, nella roccia e nelle radici giganti; si
scava con la radicite; armi più veloci del legnoferro) e la **tizzonite** (Profondità della Linfa e Fondo; vuole il
piccone d'ambra; la strada forte prima della Linfa). Quattro **gemme a grappolo** che brillano sui pavimenti delle
grotte (passata **Gemme**, ~110 grappoli ciascuna): **sanguinella** (Sottobosco e Caverne), **brillaluce** (Caverne),
**lagunite** (Profondità), **nottilite** (Fondo). Con le gemme: quattro anelli (danno, Linfa, alone, fortuna e
ombra), il **Bastone di sanguinella**, il **Bastone di lagunite** (un'onda fredda che **rallenta** le creature: meccanica
nuova), la **Lanterna di brillaluce**, la **Lama di nottilite**. Oggetti: 199 → 229. Prove `--solo=gemme`: quantità
per strato, forza di piccone, rallentamento, lanterna (foto 48_gemme).

## 25. [x] Nuovi banchi da lavoro (M) — fatto il 25 set 2026
Tre banchi nuovi, fabbricati al Ceppo, ognuno con il suo mestiere (disegni in `WorkshopArt`): l'**Alambicco di Linfa**
(tutte le pozioni avanzate e la Rugiada di Linfa, più cinque pozioni nuove: **passo lungo** corsa +30%, **minatore**
scavo +50%, **spine**, **esca** creature rare ×2 per cinque minuti, **fortuna**), il **Telaio di foglie** (mantello,
collana, bende, velo e le **vesti di seta**: cappuccio, veste e calzari di seta di radice e del Vuoto, poca Scorza ma
incantesimi più forti e Linfa più svelta: la strada del Germogliato che usa i bastoni) e la **Mola del gemmaio**
(anelli, bastoni, lanterna e lama di gemma). Anche le armature possono avere effetti (`acc`); effetto nuovo `magic`.
L'Altare dei Seminatori per richiamare i boss arriva con la voce 27. Corretto un difetto vero trovato dalle prove:
spostato di colpo mentre era in aria (specchio, rinascita), all'atterraggio il Germogliato contava tutto il viaggio
come una caduta e appassiva (`Player.reset_fall`). `verifica_dati` salva anche il foglio delle stazioni
(prove/stazioni.png). Prove `--solo=banchi` (foto 49_banchi).

## 26. [x] Set di equipaggiamento (M) — fatto il 25 set 2026
**15 set** (`SetsData`): chi indossa tutti i pezzi riceve un bonus in più degli effetti dei singoli pezzi. Otto set di
metallo (elmo, corazza e gambali dello stesso metallo, generati da `METALS`): Radici salde (radicite), Corteccia di
ferro (legnoferro), Passo di luna (pallidite: corsa e colpi), Luce fossile (ambra), Brace viva (tizzonite: danno e
spine), Linfa che scorre, Ombra del Vuoto, Stella del Giardino. Due set di vesti (Tessitore di Linfa e del Vuoto:
incantesimi e Linfa) e cinque coppie di accessori che stanno bene insieme (Guscio di scarabeo, Occhi della notte,
Fuoco e gelo, Riccio e resina, Ali del cielo). `GearEffects` riscritto: somma in un solo modo gli effetti dei pezzi,
dei tratti e dei set (anche la Scorza dei set, `Vitals.set_scorza`). Nella colonna dell'equipaggiamento sotto gli
accessori compare il set più avanti con i pezzi indossati (dorato se completo, il bonus nel suggerimento) e la Scorza
conta anche quella dei set; la casella Esamina dice di che set fa parte un pezzo, con chi e il bonus. Le prove non
trovavano più terreno piano vicino alla partenza (le prove precedenti ci costruiscono sopra): `TestKit.flat_spot` ora
accetta un dislivello di una o due tessere. Prove `--solo=set` (foto 50_set).

## 27. [x] Boss intermedi (L) — fatto il 25 set 2026
I **Custodi degli strati** (`KeepersData`, modulo `Keepers`), quattro boss intermedi tra l'inizio e il Guardiano, uno
per strato: la **Madre dei grumi** (Sottobosco: salti enormi, poi chiama i suoi piccoli), la **Tessitrice delle
radici** (Caverne: carica, ricopre tutto di ragnatele, chiama i Tessiradice), la **Serpe madre** (Profondità: nuota
nell'aria, scatta, ventagli di Linfa) e il **Mietitore cavo** (Fondo: sparisce e ricompare, scatta con la falce,
chiama sciami di schegge). Passata **Tane**: per ognuno una grande caverna ovale nel suo strato, lontana dal resto, con
le decorazioni del suo stile e un **bozzolo** di radici con il cuore acceso del suo colore. Avvicinandosi il Custode si
schiude (barra in alto, scritta, luce attorno); se il Germogliato appassisce o si allontana torna a dormire.
Sconfitto, lascia sempre il suo **materiale regale**, un dono (Cuore di bocciolo o Stilla perenne), metà delle volte
il trofeo della sua specie, e la prima volta una pagina di storia; il bozzolo resta vuoto. All'**Altare dei
Seminatori** (nuovo banco: pietre delle rovine) si fabbricano i **richiami** e si risveglia un Custode già sconfitto,
per tornare a cercare il suo bottino. Oggetti dei Custodi: Corona gelatinosa, Sacca dei grumi, Manto della
Tessitrice, Arco di seta regale (due dardi), Anello e Bastone della Serpe madre (tre serpi che cercano), Falce del
Mietitore, Cuore cavo. Prove `--solo=custodi`: tane per strato, schiusa, sconfitta, richiamo rifiutato e accettato
(foto 51_custode, 52_tessitrice).

## 28. [x] Segreti del mondo (M) — fatto il 25 set 2026
Passata **Nascondigli**: dodici stanze murate di Pietra dei Seminatori **senza porta**, chiuse nella roccia del
profondo, ognuna con un **Reliquiario** che custodisce una **reliquia** (e un po' di bottino). Le reliquie formano tre
**collezioni** (`RelicsData`): **Attrezzi dei Seminatori** (zappa, falcetto, annaffiatoio, sementiera; Sottobosco e
Caverne), **Canti dei Seminatori** (quattro tavolette: alba, giorno, tramonto, notte; Caverne e Profondità) e **Semi
perduti** (quattro semi antichi; Profondità e Fondo). Trovata l'ultima reliquia di una collezione (basta averla
avuta una volta: la ricorda l'Erbario) il Germogliato riceve il bonus **per sempre** (scavo e fortuna; Linfa e
incantesimi; Vita e Scorza). La **Mappa dei Seminatori** (all'Altare, o negli scrigni delle rovine) indica a parole il
reliquiario più vicino non ancora aperto e lo rivela sulla mappa. Passata **Geodi**: trenta sfere cave chiuse nella
roccia delle Caverne e delle Profondità, con un guscio di cristalli di Linfa e gemme dentro. Sulla mappa (M) ora si
vedono anche reliquiari, tane dei Custodi e altari. Prove `--solo=reliquie` (foto 53_nascondiglio, 54_geode); le prove
dei banchi spianano il terreno prima di piazzarli (`TestKit.flatten`).

## 29. [x] Interfaccia chiara (M) — fatto il 25 set 2026
Con più di 170 ricette la colonna **Creare** si è riorganizzata: otto **categorie** (Tutto, Armi, Armature, Accessori,
Pozioni, Materiali, Banchi, Altro), una **ricerca** per nome (mentre si scrive il Germogliato non si muove e i tasti
del gioco tacciono), e in ogni riga, sotto il nome, gli **ingredienti con la loro icona** e quanti ne servono (in rosso
quelli che mancano); nel titolo quante ricette sono possibili e quanti banchi sono vicini (i nomi nel suggerimento).
La casella **Esamina**, vuota, mostra la **scheda del Germogliato** (`CharacterSheet`): Vita, Linfa, Scorza, tutti i
moltiplicatori attivi (danno, colpi, incantesimi, corsa, salto, scavo, ricrescita, alone, ombra, fortuna, spine,
planata), set completi e collezioni di reliquie, doni assorbiti, Erbario. Nella Bisaccia il bottone **Riordina** (per
tipo e per nome, unendo le pile; la barra rapida resta com'è). L'aiuto dei tasti in alto a sinistra si mostra e si
nasconde con **F1** (parte nascosto dopo venti minuti di gioco). Prove `--solo=interfaccia` (foto 55_creare,
56_creare_armi); `TestKit.place_station_near` ora porta in mano la stazione anche con la barra rapida piena.

## 30. [x] Obiettivi intermedi (S) — fatto il 25 set 2026
La catena degli obiettivi passa da 25 a **45**, con traguardi intermedi intrecciati a quelli di prima: il primo
Bocciolo del cuore, il Bastone di brace, l'Alambicco, il primo capobranco e il primo oggetto da un trofeo, l'Altare, il
primo Custode (poi due, poi tutti e quattro), Telaio e Mola, la pallidite, il primo reliquiario, un set completo, la
tizzonite, cinque Cuori di bocciolo, la prima iridata, la prima collezione di reliquie (poi tutte e tre), un oggetto
iridato. Condizioni nuove: `set`, `collezione`, `any`; conteggio nuovo `oggetti_trofeo`. Ricompense legate al
traguardo (pozioni dell'esca e di fortuna, mappe dei Seminatori, Cuori di bocciolo, Stille perenni…).

## Extra. [x] Eliminare personaggi e mondi — fatto il 25 set 2026
Richiesta dell'utente. Nel menu, accanto a ogni personaggio e a ogni mondo, un bottone rosso **Elimina** che porta a
una conferma («Sei sicuro?»): il primo bottone, con il fuoco, è «No, torna indietro», così Invio non cancella nulla.
Si cancellano anche le copie di sicurezza (`SavePaths.delete_file`/`delete_dir`, `Character.delete`,
`WorldSave.delete`); un portale che portava a un mondo cancellato lo farà rinascere dal suo seme. Provato in
`prova_salvataggi.gd` (personaggio e mondo spariscono dagli elenchi) e nelle foto del menu (menu_mondi, menu_conferma).

## Extra. [x] La torcia in mano — fatto il 25 set 2026
Richiesta dell'utente: con la torcia (o una lanterna) nella casella scelta il Germogliato la tiene in mano, a braccio
avanti, e si vede sempre; la torcia ha in cima una fiamma che guizza sopra il buio e fa una luce calda attorno a lui
(`Boons.LIGHT_TORCIA`, come una torcia piantata). `Player.carry` e `carry_glow`, impostati da
`PlayerActions._on_selected`. Prova `--solo=torcia` (foto 57_torcia_in_mano, 58_torcia_vicino). Poi, su richiesta, la luce della torcia in mano **tremola**
come una fiamma (`Boons._flicker`: cambia un poco d'intensità ogni 0,09 s; 60 fps confermati dalla prova). Tremolano anche le **torce piantate**, ognuna con la sua
fase (nasce dalla cella: non pulsano tutte insieme; `LightMap.FLICKER`, `flicker_time` mandato avanti da `Boons` solo
se c'è una torcia nella finestra della luce). Prova: 11 valori diversi in 2 s, nessun fotogramma perso.

# Roadmap 4 «Un mondo da abitare» (26 set 2026)

Richiesta dell'utente: dieci cicli consecutivi di migliorie ed espansioni, «voglio sostanza», un gioco molto più vasto
nelle meccaniche e nei contenuti, senza il suo intervento. Scelte di Claude, dalla meccanica che cambia di più il
modo di giocare a quella che allarga di più i mondi.

## 31. [x] Muoversi meglio (M) — fatto il 26 set 2026
Il **rampino** (modulo `Grapple`): la **Radice uncino** (Ceppo, portata 11 tessere) e l'**Uncino di cristallo**
(Maglio, 18 tessere, più svelto). Con il rampino in mano il clic lancia la radice verso il mouse: se tocca la roccia
si aggancia e tira il Germogliato fino al punto, dove resta appeso senza cadere; il salto lo sgancia con un balzo, e
così S, allontanarsi troppo o scavare via la tessera d'aggancio. **Doppio salto**: il **Baccello di vento** (un salto
in aria, con uno sbuffo e un soffio; negli scrigni delle rovine o al Telaio) e il **Seme di tempesta** (due salti in
aria). **Artigli di corteccia**: in aria, spingendo contro una parete, si scivola piano (senza ferite da caduta) e il
salto stacca verso l'alto e lontano dal muro. Effetti nuovi degli accessori `air_jumps` e `wall`. Prove
`--solo=mobilita`: salto 3,3 → 6,1 tessere con il Baccello, rampino che sale di 7 tessere e si sgancia, scivolata a
70 px/s invece di 520 (foto 59_rampino).

## 32. [x] Esplosivi e armi da lancio (M) — fatto il 26 set 2026
Modulo `Throwing`, tutto con il clic verso il mouse. Il **Baccello esplosivo** (Baccello ardente, tre per volta) vola ad
arco, rimbalza, lampeggia sempre più in fretta e scoppia: rompe terra e roccia attorno (forza 40: non l'ambra, non la
vuotite, non i cristalli; ciò che rompe cade a terra come scavato), ferisce le creature e anche il Germogliato se è
troppo vicino, con un lampo di luce e un boato. Il **Baccello tonante** è più grande e rompe anche l'ambra. I **semi
ricurvi** (di legno al Ceppo, d'ambra e del Vuoto al Maglio) volano avanti, feriscono ogni creatura che attraversano e
tornano in mano. I **giavellotti** (d'aculeo, di cristallo) si consumano come i dardi e attraversano due o tre
creature. I bastoni di Linfa ora ricevono i tratti come le altre armi. Prove `--solo=lanci` (foto 60_scoppio).

## 33. [x] Il giardino del Germogliato (M) — fatto il 26 set 2026
Il Germogliato coltiva (`CropsData`, modulo `Garden`): cinque colture, **erba di rugiada**, **funghi di brace**,
**funghi luminosi** (solo sotto terra, al buio), **campanula lume** (fa luce) e **tubero di Linfa**. Il seme si pianta
con il clic su un terreno adatto (muschio ed erbe; i funghi anche su terra e roccia): nasce un germoglio che dopo 3-7
minuti diventa la pianta matura, e il tempo corre anche lontano. Clic destro sulla pianta matura (o scavarla) = il
raccolto e i semi per ripiantare; l'**Annaffiatoio di zucca** dimezza il tempo che manca, una volta per pianta. I semi
si trovano raccogliendo fronde, campanule e funghi selvatici, negli scrigni delle rovine e da Saltafunghi e
Strisciaradici. Colture salvate con il mondo (`World.crops`). Dal raccolto: la Pozione di rugiada coltivabile, la
**Pozione di radice** (grande cura), la **Pozione di notte** (per cinque minuti un chiarore anche dove non arriva la
luce) e al nuovo **Paiolo di radice** i piatti (zuppa di funghi, pane di tubero, insalata di lume, stufato regale):
**Sazio** per dieci-trenta minuti, con Vita un po' più svelta e colpi e corsa +5%. Prove `--solo=giardino` (foto
61_giardino).

## 34. [x] Eventi del mondo (M) — fatto il 26 set 2026
Modulo `Events`, dati in `EventsData`: al calar della notte e al sorgere del giorno si tira se comincia un evento, con
la sua scritta, un suono e il nome in alto a destra; dura fino al cambio successivo. **Pioggia di stelle** (30% delle
notti): ogni 8-18 secondi una stella cade con una scia dal cielo vicino al Germogliato e resta a terra una **Stellina
caduta** (Pozione di Linfa, **Pendente di stelle**, **Bastone delle stelle cadute**). **Notte dell'Avvizzimento** (12%
delle notti): pericolo +2, sei nascite su dieci sono Avvizziti, e sconfiggendo 40 creature prima dell'alba si vince un
premio (cenere, semi di muschio, pozioni, a volte Cuori di bocciolo, Stille, Essenze, Polvere iridata). **Fioritura**
(15% dei giorni): creature rare ×2 e semi selvatici ×3. Prove `--solo=eventi` (foto 62_pioggia_stelle); nelle prove
gli eventi sono spenti (`Events.paused`).

## 35. [x] Costruire (M) — fatto il 26 set 2026
Tre **blocchi da costruzione** con i bordi **squadrati** (nuovo modo di disegno `_square` in `TerrainPainter`: le
costruzioni hanno spigoli dritti, il terreno naturale resta morbido): **Assi di lanterna**, **Mattoni d'ardesia** e
**Vetro di resina** (solido, ma la luce ci passa attraverso). **Pareti di fondo** da piazzare con il clic (assi,
mattoni, pietra dei Seminatori) e da togliere tenendo premuto con il **Martello di radice** (modulo `Masonry`; le
pareti costruite tornano nella Bisaccia). La **Porta di lanterna** (vano alto 3): clic destro la apre e la chiude, e
chiusa è fatta di tessere solide che fermano anche le creature; non si chiude addosso a qualcuno. Arredi: **Lampada
di lanterna** (luce calda), **Tavolo** e **Sedia di radice**, e il **Letto di foglie**: clic destro e da allora si
rinasce lì invece che alla partenza (`world_meta["letti"]`). Prove `--solo=casa`: una casetta costruita come la farebbe
il giocatore (foto 63_casa); `TestKit.flatten` ora abbatte anche gli alberi.

## 36. [x] Abitanti e commercio (L) — fatto il 26 set 2026
Una moneta, i **Lumini**: cadono da ogni creatura sconfitta (quanti secondo la sua forza; ×3 le antiche e i
capibranco, ×8 le iridate, ×10 le ancestrali, molti dai boss) e dagli scrigni delle rovine. Il valore di ogni oggetto
lo calcola `ValueData` (materiali grezzi scritti, il resto dagli ingredienti della ricetta più un quarto). Il
**Focolare del Giardino** (Ceppo) attira gli **abitanti** (`NpcData`, modulo `Villagers`): uno per ogni Letto di foglie
libero entro 25 tessere, ognuno quando il mondo è pronto per lui: la **Viandante** (torce, pozioni, dardi, semi,
baccelli, mappe, rampino, ceste), l'**Erborista** (dopo l'Alambicco: pozioni e semi rari) e il **Forgiatore** (dopo il
primo Custode: lingotti, polvere di brace, baccelli tonanti, uncino di cristallo, dardi di vuotite). Passeggiano
attorno al Focolare con il loro nome sopra e si girano verso il Germogliato; clic destro = il **commercio** (`TradePanel`,
sopra la Bisaccia come le ceste): clic su una merce per comprarla (il doppio del valore), Maiusc+clic su una casella
della Bisaccia o «Vendi ciò che hai in mano» per vendere (un terzo). Salvati con il mondo (`world_meta["abitanti"]`).
Prove `--solo=abitanti` (foto 64_abitanti, 65_commercio).

## 37. [x] Compagni (M) — fatto il 26 set 2026
**Compagni** che seguono il Germogliato (`CompanionsData.PETS`, modulo `Companions`, entità `Ally`): uno alla volta,
si chiamano e si congedano con il clic sul loro oggetto, restano con il personaggio. La **Lucciolina** (vasetto: polvere
di lucciola e vetro, al Ceppo) fa luce attorno; il **Grumetto** (Gelatina viva: gelatina regale, all'Alambicco) attira
gli oggetti da più del doppio della distanza; lo **Spiritello di Linfa** (occhi di guizzo e cristalli, all'Alambicco)
fa ricrescere la Linfa il 30% più in fretta. **Bastoni evocatori** (10 Linfa a richiamo, due alleati insieme, il più
vecchio lascia il posto): Grumo amico (Ceppo), Falena amica (Telaio), Vagavuoto domato che tira sfere (Maglio). Gli
alleati vedono le creature entro 14 tessere, ci vanno addosso e tornano; il danno cresce con gli incantesimi; il
**Fischietto del branco** (accessorio, Maglio) ne aggiunge uno. Prove `--solo=compagni` (foto 66_compagni).

## 38. [x] Viaggio rapido e minimappa (M) — fatto il 26 set 2026
Le **Radici viandanti** (stazione 2×3 con un nodo di Linfa acceso; legno, gelatina e radicite al Ceppo): tutte le
radici di un mondo sono collegate. Clic destro su una radice = la mappa si apre in **modo viaggio** (inquadra tutte
le radici, sempre segnate anche dove la mappa è nera): clic su un'altra radice e ci si arriva (`Travel`,
`MapPanel.open_travel`/`pick_root`). Da sola una radice «non trova compagne». La **minimappa** in alto a destra
(`Minimap`): un ritaglio di 110×64 tessere della mappa esplorata attorno al Germogliato, con i segni di radici,
portali, Focolare e fagotto; tasto N per nasconderla, sparisce con i pannelli aperti (la scritta degli eventi è scesa
sotto di lei). Sei obiettivi nuovi per i sistemi della Roadmap 4: raccolto, abitante, radici, notte dell'Avvizzimento,
compagno, alleato. Prove `--solo=viaggio` (foto 67_viaggio_mappa, 68_minimappa).

## 39. [x] Semi con specie e tratti (L) — fatto il 26 set 2026
Ogni portale ha la **specie** del suo Seme e i **tratti** del mondo che nascerà (`SpeciesData`), scelti quando il Seme
si pianta (dal seme del portale: stesso portale, stesso mondo). La specie decide i biomi di superficie e quello della
partenza (salice-lanterna → foreste, sporangio → paludi, resina → distese d'ambra; con una specie lo stesso bioma può
tornare di fila, così domina davvero: 59% di paludi contro 26%). All'**Altare** si dà una specie al Seme di mondo con i
materiali del suo bioma; il Seme del Cuore ne ha una a caso. **Tratti** (uno, più uno ogni due punti di vigore, fino a
quattro): Vene ricche, Rovine fitte, Gemme ricche (nel generatore: +28% di minerali, 70 scrigni invece di 44, il doppio
delle gemme), Iridescente, Fertile, Stellato, Quieto (doni) e Brulicante (più pericolo ma il doppio dei Lumini), Notti
lunghe, Avvizzito (prove); gli effetti mentre si gioca li mette `WorldTraits` (pericolo, Lumini, rarità, colture,
durata della notte, eventi, Avvizzimento). Il **primo clic destro sul portale** dice dove porta («Verso "…, vigore 3" ·
Seme di sporangio · Vene ricche, Notti lunghe»), il secondo parte. Entrando la prima volta una scritta presenta il
mondo; la scheda del personaggio lo ricorda. Prove `--solo=semi`.

## 40. [x] Biomi nuovi (L) — fatto il 26 set 2026
Due biomi di superficie nuovi, ognuno con la sua tessera d'erba (con i contorni morbidi, sulla mappa e
nell'Avvizzimento), le sue decorazioni, il suo cielo, due creature, i materiali, un set e i trofei:
- **Boschi di brina** (muschio di brina azzurro): il **Cervo di brina** carica a testa bassa (vello, palchi), il **Gufo
  del gelo** tira schegge fredde che rallentano (piume). Vesti di brina al Telaio (set «Passo di brina»: corsa +12%,
  niente ferite da caduta), Arco del gelo (due dardi), Dardi del gelo, Amuleto del palco.
- **Cenerarie** (cenere viva rosata, quasi senza alberi): la **Salamandra di brace** salta addosso (squame), i **Fatui
  di cenere** arrivano a gruppetti e scattano (cenere viva). Corazza di squame al Maglio (set «Cuore di brace»: +10%
  danno, spine 12), Lama della salamandra, Cuore di brace.
- Trofei delle quattro creature (solo dalle rare) con i loro oggetti unici: Corona di palchi, Sguardo del gelo,
  Frusta di coda (brucia), Lanterna fatua.
- Due specie nuove di Semi di mondo, **brina** e **cenere** (all'Altare): un mondo di cenere è per il 92% Cenerarie.
  Nei mondi nuovi senza specie i due biomi compaiono accanto agli altri (peso 2).
Il sottosuolo resta per la prossima Roadmap. Oggetti e ricette in `BiomeItemsData`, disegni in `BiomeBeastArt`.
Prove `--solo=biomi_nuovi` (foto 69_boschi_brina, 70_cenerarie).

# Il Germogliato di Nano Banana (26 set 2026, lavoro guidato dall'utente)

- [x] Riferimento `00_profilo_fermo_v4` (forme grandi pensate per 36 pixel, germoglio piccolo, occhio d'oro unico nella
  figura); misura 36 pixel e cunicoli da 2 blocchi (scelta dell'utente), corpo 10×30.
- [x] Strumenti: `tools/pixela.py` (pixel art da disegno grande), `tools/importa_tavola.py` (tavole: pulizia,
  allineamento, misura sulla testa, correzione dei colori, pugno per gli attrezzi), `tools/respiro.py`.
- [x] Tavole: corsa, fermo (respiro dallo script), salto, colpo, mira, torcia, speciali (parete, planata, rampino),
  colpito e appassire. In gioco con `HeroSprites` e `HeroAnimator`; `CharacterArt` resta di riserva.
- [ ] L'armatura sugli sprite nuovi (colori scambiati della tunica e dei pantaloni; l'elmo?).
- [ ] Colpo in corsa (oggi colpendo le gambe restano ferme per un terzo di secondo), se in prova non piace.

Come si è lavorato (per le prossime tavole, per esempio mostri e boss): prompt in inglese ultra dettagliati scritti da
Claude, l'utente genera con Gemini e salva in `arte_ia/<soggetto>/` con il nome dato da Claude, poi `importa_tavola.py`
e prova in gioco. Le lezioni (cosa Nano Banana sa e non sa fare) sono in CLAUDE.md, «Lezioni già imparate».

# Il piano «Il Giardiniere dei mondi» (Roadmap 5-11, deciso il 26 set 2026)

Richiesta dell'utente: un gioco «molto più vasto, vario e profondo di Terraria», pressoché infinito, con sempre cose da
fare, cercare ed esplorare **e un motivo per farlo**; grafica e rifinitura dopo. La filosofia è in CLAUDE.md.

**Il giro che si ripete all'infinito**: l'Albero-Madre (e gli abitanti) chiedono qualcosa → serve un gene, un
materiale o una creatura che non si ha → si **innestano due Semi** per ottenere un mondo che probabilmente lo contiene →
lo si esplora → si trova ciò che si cercava **e** l'imprevisto (geni nuovi, mutazioni, tracce dei Seminatori) → si
torna → l'Albero cresce e chiede altro.

**Un solo motore, riusato ovunque**: la genetica (geni con dominanza e rarità, eredità, mutazioni) nasce per i Semi
(Roadmap 5) e si riusa per le creature allevate (Roadmap 7) e i Guardiani generati (Roadmap 11). I materiali con
proprietà (Roadmap 6) fanno sì che ogni gene di minerale porti subito decine di attrezzi.

Ordine: prima il motore (5), poi ciò che il motore moltiplica (6 materia, 7 fauna), poi il motivo (8 Albero-Madre),
poi il racconto sopra il motore (9 Seminatori), poi le meccaniche fisiche nuove come geni rari (10), poi il fine gioco
senza fine (11). Ogni Roadmap lascia il gioco completo e giocabile; ogni voce ha il suo «pronto quando».
Dimensioni: S piccola, M media, L grande.

# Roadmap 5 «Il Seme e i suoi geni» — il motore dell'infinito

## 41. [x] Versione dei salvataggi e migrazioni (S) — fatto il 26 set 2026
Il piano cambia la forma di oggetti, Semi e creature: ogni salvataggio (mondo, `mondo.json`, personaggio) riceve un
numero di versione e una catena di migrazioni (`SaveMigrations`: da 1 a 2, da 2 a 3…), così i mondi e i personaggi di
oggi restano giocabili fino alla fine del piano. Le caselle della Bisaccia diventano capaci di portare dati propri
(oggi il solo «tratto»): un campo `dati` generico, che servirà al genoma dei Semi e ai componenti degli attrezzi.
**Pronto quando**: un salvataggio di oggi si apre, migra e risalva identico; `tools/prova_salvataggi.gd` prova anche
la migrazione.
**Fatto il 26 set 2026**: `SaveMigrations` (`src/save/`): "formato" in ogni personaggio e mondo, catena di passi alla
lettura (`WorldSave.read_meta` e `Character.from_dict` restituiscono sempre la forma di oggi), un file di una versione
più nuova non si apre. Le caselle della Bisaccia (e di ceste, scrigni, oggetti a terra con `Drops.spawn(…, dati)`)
portano "dati" propri: una casella con dati non si unisce mai a un'altra pila, i numeri tornano interi dopo il JSON
(`SaveMigrations.ints`). La prova dei salvataggi controlla dati, riordino, versioni più nuove e la migrazione 1 → 2.

## 42. [x] Il genoma del Seme (L) — fatto il 26 set 2026
`GenesData`: i geni, in **categorie** che corrispondono alle parti del generatore — clima e biomi di superficie,
suolo e strati, grotte, minerali e gemme, flora, fauna, strutture, cielo ed eventi, «leggi» (dalla Roadmap 10).
Ogni gene: nome dell'universo, rarità (comune, robusto, antico, stellare), dominanza, geni con cui non va d'accordo,
cosa fa. Un Seme di mondo porta un **genoma** (pochi geni, uno o due per categoria, più il vigore) nei `dati` della
casella. Le 5 specie e i 10 tratti di oggi diventano geni (migrazione dei portali esistenti). Scheda del Seme in
Esamina: geni noti in chiaro, quelli mai visti come «?».
**Pronto quando**: ogni Seme ha un genoma leggibile, i portali di oggi lo hanno ricevuto, `verifica_dati` controlla i
geni (riferimenti, incompatibilità, ogni gene ottenibile).
**Fatto il 26 set 2026**: `GenesData` (13 categorie: superficie, forma, grotte, sottosuolo, minerali, gemme, rovine,
fauna, stirpi, flora, cielo, tempo, ombra; 4 rarità; dominanza) e `Genome` (`src/game/`: genoma a caso secondo il
vigore, effetti sommati, descrizione e scheda). Le 5 specie e i 10 tratti della voce 39 sono diventati 15 geni
(`SpeciesData` tolto); le categorie rendono incompatibili da sole i geni opposti (brulicante/quieto). Ogni Seme di mondo
nella Bisaccia ha il suo genoma (non si impila più; il vigore è quello del mondo dove lo si raccoglie più uno,
`Genome.local_vigor`), piantato lo passa al portale ("geni", "vigore"), il mondo nato lo porta in `world_meta["geni"]`
e il generatore in `GenContext.params["geni"]` (`c.genes()`, `c.surface_gene()`). Migrazione del mondo 1 → 2 (specie
e tratti → geni, anche nei portali). Entrando in un mondo i suoi geni diventano «visti» (`Character.genario`); in
Esamina il Seme mostra il genoma, i geni mai visti come «?».

## 43. [x] Il generatore guidato dai geni (L) — fatto il 26 set 2026
Ogni categoria di geni entra nella sua passata: biomi (peso e forma), strati (rocce e sacche diverse per gene), grotte
(«Cavo», «Compatto», «Alveare»…), minerali (quali vene e dove), flora, fauna (quali famiglie compaiono), strutture.
Sottosuolo con i biomi propri come geni (fungaie giganti nel Sottobosco, geodi di brina, fiumi di brace nel
profondo), primi 20-25 geni in tutto. `tools/mappe.gd` stampa il genoma sotto ogni mappa e una **misura della
varietà** (quanto due mondi differiscono: biomi, rocce, grotte, fauna).
**Pronto quando**: 20 Semi a caso danno 20 mappe riconoscibili a occhio; la misura della varietà non scende sotto una
soglia scelta insieme.
**Fatto il 26 set 2026**: 27 geni nuovi (42 in tutto). Forma: Pianure, Montagne, Altopiano, Conca, Frastagliato.
Grotte: Cavo, Compatto, Gallerie, Alveare (celle da un rumore cellulare), Voragini (pozzi dalla superficie), Abissale.
Sottosuolo (`PassSottosuolo`, nuova passata dopo i Cristalli): Fungaie (sale con funghi giganti di radice e spore nel
Sottobosco), Geodi di brina, Fiumi di brace (gallerie di cenere viva e tizzonite), Laghi di Linfa (cristallo rappreso),
Radici giganti. Minerali: Vene affioranti, Radicite diffusa, Metalli nobili; Gemme: Geodi fitti, Cristalli giganti;
Rovine sepolte (scrigni più ricchi); Ancestrale; Rigoglioso e Spoglio; Giorni lunghi; Sano (nessuna macchia
d'Avvizzimento; Avvizzito ne fa il doppio). I geni rari hanno un vigore minimo (`vmin`). Un Seme trovato ha **sempre**
un gene di forma, grotte o sottosuolo (`Genome.SHAPE_CATS`): senza, due mondi con soli geni «in gioco» avevano la
stessa mappa. `tools/mappe.gd -- --caso --vigore 7` stampa i geni e la **misura della varietà** (impronta di ogni
mondo: biomi, superficie, grotte per strato, minerali, sottosuolo, alberi e scrigni): su 12 mondi a caso distanza
media 5,0 e minima 2,2 contro un rumore di 0,74 dello stesso genoma con un seme diverso. **Soglia scelta**: la coppia
più simile deve stare ad almeno il doppio del rumore. Gli appunti del generatore restano nel mondo appena nato
(`World.gen_notes`). Prove `--solo=geni` (foto 80_fungaia, 81_fiume_brace).

## 44. [x] La firma di ogni mondo (M) — fatto il 26 set 2026
**Regola d'oro del piano**: ogni mondo ha almeno una cosa che si trova **solo lì**, scelta dal genoma e dal seme:
un luogo speciale (albero colossale, lago di Linfa, cratere di stelle, foresta pietrificata…), una variante di
creatura, una vena unica. Il mondo riceve un **nome** generato dal genoma («Paludi cristalline di Vel-Arim»), una
descrizione e la firma, mostrati sul portale e nel registro. Almeno 12 firme diverse per cominciare, scritte come dati.
**Pronto quando**: ogni mondo generato ha nome e firma, e la firma si trova davvero (prova: la cerca e la raggiunge).
**Fatto il 26 set 2026**: 12 firme (`SignaturesData`, costruite da `PassFirma` con le tessere che ci sono già):
Albero colossale, Cratere delle stelle, Foresta pietrificata, Pozzo senza fondo (fino al Fondo), Arco di radici,
Isola sospesa, Grotta delle lucciole, Nodo delle radici, Serra sepolta, Sala delle colonne d'ambra, Alveare di
cristallo, Bolla del Vuoto. Scelta dal seme e dai geni (i geni «graditi» la rendono 4 volte più probabile), lontano
dalla partenza e dal Cuore; dentro lo **scrigno della firma**: bottino del profondo, 3 Linfa antica (per gli innesti
della voce 47) e il **ricordo** del luogo (12 oggetti da collezione, tipo «ricordo»). Il modulo `Signature` segue il
ritrovamento (entro 26 tessere: scritta, conteggio «firme», stella sulla mappa, riga nella scheda); i mondi salvati
prima ricevono la loro firma al primo ingresso. **Nomi dei mondi** (`NamesData`): paesaggio dal gene di superficie,
aggettivo da un gene di forma, nome proprio dal seme («Foreste gelide di Caleren», «Paludi cave di Velmè»). Obiettivi
«Trova la firma di un mondo» e «Trova le firme di cinque mondi». Foto 82_firma_albero, 83_firma_bolla.

## 45. [x] Le Aiuole e il registro dei mondi (M) — fatto il 26 set 2026
I portali si piantano nelle **Aiuole** (stazione del Giardino, con un numero limitato che crescerà con l'Albero-Madre):
il mondo casa diventa il centro della rete. Il **Semenzaio** (pannello, tasto dedicato) elenca i mondi aperti: nome,
genoma, vigore, firma (trovata o no), quanto è esplorato, Cuore e Guardiano. Si può chiudere un mondo per liberare
un'Aiuola (il mondo resta salvato e si può riaprire con il suo Seme). Scegliere il Seme di partenza dal menu.
**Pronto quando**: si hanno più mondi aperti insieme, si passa dall'uno all'altro dal Giardino, il Semenzaio li
descrive tutti.
**Fatto il 26 set 2026**: il mondo creato dal menu è il **Giardino** (`Aiuole.is_home`: senza "ritorno"); i Semi di
mondo si piantano solo nelle **Aiuole** (stazione 3×4 del Ceppo: humus, legno, semi di lanterna), che si mettono solo
nel Giardino e al più tre (`Aiuole.max_aiuole`, `bonus` per l'Albero-Madre della Roadmap 8; controllo con
`PlayerActions.station_check`): l'Aiuola diventa il portale, i mondi nuovi ricordano il loro Giardino
(`world_meta["casa"]`; quelli di prima lo ritrovano seguendo i portali di ritorno). Il **Semenzaio** (tasto K,
`SemenzaioPanel`): i mondi della rete con genoma, firma, Cuore, esplorato e tempo di gioco; dal Giardino si **chiude**
un mondo (l'Aiuola torna libera, resta il **Seme dormiente** con "mondo" nel genoma, che ripiantato lo riapre). Il seme
di un mondo nuovo nasce dal conto dei Semi piantati nel Giardino (una stessa Aiuola ospita molti Semi). Nel menu si
sceglie il **Seme del Giardino** (tutti i biomi o uno dei cinque). Deciso da Claude: niente più portali piantati a terra
(quelli di prima restano), così il Giardino è davvero il centro. Foto 84_semenzaio.

## 46. [x] Trovare semi e geni (M) — fatto il 26 set 2026
Da dove vengono i geni: Cuori e Guardiani (Semi interi), scrigni delle rovine, **piante-seme** selvatiche rare in ogni
mondo (portano un gene del mondo in cui crescono), e i **campioni**: con la **Provetta di Linfa** si preleva un gene
da un bioma, una roccia, una creatura sconfitta o la firma. Il gene prelevato si **impara** (collezione dei geni:
nuova pagina dell'Erbario, il **Genario**, con la percentuale) e diventa una Fiala di gene da usare negli innesti.
**Pronto quando**: in un mondo si possono trovare tutti i suoi geni per almeno due strade; il Genario li conta.
**Fatto il 26 set 2026** (`Sampling`, `Genario`): la **Provetta di Linfa** (3 all'Alambicco con vetro e gelatina):
clic su ciò che porta un gene — erba della superficie, terra vicino alla superficie (forma), aria delle grotte, rocce
profonde (sottosuolo), vene, cristalli e gemme, pietra dei Seminatori, alberi, cielo aperto (cielo o tempo), terra
avvizzita — dà la **Fiala** del gene del mondo in quella categoria; se il mondo non ne ha, la Provetta non si consuma
e una scritta dice cosa cercavi. Le **Fiale** (una per gene, generate da `GenesData.items()`) nella Bisaccia fanno
**imparare** il gene. **Piante-seme** selvatiche (`PassPianteSeme`: 8 in superficie e 10 nelle grotte; stazione con il
baccello d'ambra): clic destro = una Fiala di un gene del mondo o (30%) un **Seme selvatico** figlio del mondo (ogni
gene del mondo resta col 70%, 8% di mutazione). Le creature sconfitte lasciano a volte la Fiala del gene di fauna, le
rare quella delle stirpi; un quarto degli scrigni delle rovine ha la Fiala di un gene qualunque (anche di altri mondi).
Il **Genario** è la seconda scheda del Semenzaio (mai visto «?», visto, imparato; dove si preleva, come nasce).
Obiettivi: prelevare un gene, impararne 10 e 25. Deciso da Claude: il Genario sta nel Semenzaio (non nell'Erbario),
vicino ai mondi da cui vengono i geni. Foto 85_genario.

## 47. [x] L'innesto dei semi (L) — fatto il 26 set 2026
Al **Banco dell'Innestatrice** (stazione nuova) si uniscono due Semi, più eventuali Fiale di gene: nasce un Seme
figlio. Regole: per ogni categoria si eredita da uno dei due genitori secondo la dominanza; una Fiala fissa quel gene;
il vigore è quello del genitore più forte più uno; costa Linfa antica (dai Cuori). **Mutazioni**: una piccola
probabilità (più alta con certi geni e certe Essenze) di un gene che nessuno dei genitori aveva, anche uno che non si
trova in nessun altro modo. Prima di innestare si vedono le probabilità, ma solo per i geni già imparati.
**Pronto quando**: si può progettare un mondo («voglio grotte ad alveare e fiumi di brace») e ottenerlo con gli
innesti; le mutazioni si vedono e finiscono nel Genario.
**Fatto il 26 set 2026**: il **Banco dell'Innestatrice** (stazione 3×2 al Maglio: legnoferro, 2 Linfa antica, vetro,
semi di lanterna) e il suo pannello (`InnestoPanel`): si scelgono due Semi e fino a due Fiale (una per categoria) e si
vedono le probabilità del figlio categoria per categoria (`Genome.odds`): geni diversi → uno dei due secondo la
dominanza (90% in tutto, 10% nessuno), gene di un solo genitore → 65%, la superficie sempre; una Fiala **fissa** il suo
gene (100%, e la mutazione non tocca quella categoria). Le percentuali si leggono solo per i geni imparati; dei geni
visti si legge il nome. Il vigore del figlio è quello del genitore più forte (deciso da Claude: niente «+1» negli
innesti, sennò si salirebbe di vigore senza esplorare). Costo: una Linfa antica (scrigni delle firme, obiettivi, e ora
anche 2 da ogni Cuore guarito o sconfitto). **Mutazione** 8% (`Genome.mutate`): un gene che nessuno dei genitori aveva,
con i geni «solo per mutazione» tre volte più probabili; scritta nel Seme («Mutato»). Prova: 2000 innesti rispettano le
probabilità promesse (Sporangio 0,60 atteso 0,60; Cavo 0,69 atteso 0,68; mutati 8,8%). Obiettivo «Innesta due Semi».
Foto 86_innesto, 87_innesto_nato.

## 48. [x] Geni rari e mutazioni (M) — fatto il 26 set 2026
Il secondo giro di geni (fino a ~45): geni antichi e stellari, geni che si ottengono **solo** per mutazione o solo
incrociando due geni precisi (combinazioni segrete, scoperte giocando e poi scritte nel Genario), geni «malati»
dell'Avvizzimento (mondi più duri, materiali unici). Semi selvatici che mutano da soli nel giardino se lasciati a
lungo.
**Pronto quando**: completare il Genario richiede incroci pensati; almeno 8 geni si ottengono solo per mutazione o
combinazione.
**Fatto il 26 set 2026**: 12 geni nuovi (54 in tutto). **Solo per mutazione** (6): Mosaico (tutti i biomi a tratti
brevi, con il suo Seme a mosaico), Isole sospese (`PassIsole`: nove isole di terra con alberi e radici pendenti, una su
tre con uno scrigno), Cuore cavo (una caverna immensa nel Fondo), Città sepolta (4×3 stanze dei Seminatori collegate,
12 scrigni), Aurora (di notte la luce non scende sotto il 35%: `DayCycle.night_floor`; per le creature resta notte),
Cuore nero (Avvizzimento ovunque, creature rare e feroci). **Combinazioni segrete** (2): Vene stellari (Vene ricche +
Stellato) e Fioritura eterna (Fertile + Rigoglioso): con i due geni nei genitori la mutazione sale dal 8% al 35% e dà
quel gene (prova: 361 su 1000). **Della firma** (3): Eco dei Seminatori, Cuore stellare, Radice madre (fungaie e laghi
di Linfa insieme): li preleva la Provetta vicino alla firma, e solo lì. Eclissi (vigore 4 o più). I Semi selvatici
delle piante-seme mutano da soli (8%): è così che «mutano nel giardino» (deciso da Claude, al posto di Semi che mutano
col tempo). Nessun Seme trovato porta geni «solo mutazione» o «della firma» (0 su 400). Foto 88_isole_sospese.

# Roadmap 5 — resoconto (26 set 2026)
Il motore c'è: 54 geni in 13 categorie, Semi con il loro genoma, generatore guidato dai geni (con la misura della
varietà), una firma e un nome per ogni mondo, il Giardino con le Aiuole e il Semenzaio, Provetta, Fiale, piante-seme e
Genario, l'innesto con mutazioni e combinazioni segrete. Il giro «il Giardino chiede → innesto → esploro → trovo»
funziona dalla parte del giocatore; manca chi *chiede* (Albero-Madre e abitanti: Roadmap 8). Prossima: Roadmap 6.

# Roadmap 6 «La materia viva» — l'equipaggiamento che si genera

## 49. [x] Proprietà dei materiali (L) — fatto il 26 set 2026
`MaterialsData`: ogni materiale (metalli, legni, gemme, parti di creatura) ha le sue proprietà — durezza, peso,
conduzione della Linfa, elemento, risonanza, grado. I metalli di oggi (famiglie `METALS` × `GEAR`) migrano qui: le loro
statistiche escono dalle proprietà invece che da tabelle scritte a mano, con valori vicini a quelli di oggi.
**Pronto quando**: tutti gli attrezzi di metallo di oggi nascono dalle proprietà, con statistiche entro il 10% di
quelle attuali; `verifica_dati` controlla la progressione.
**Fatto il 26 set 2026**: `MaterialsData` (8 metalli con durezza, filo, peso, tenacia, conduzione, elemento,
risonanza, grado, lingotto) e `FormsData` (le forme con le formule: forza = durezza, danno = filo pesato dalla forma,
colpi al secondo = 3 − 0,04 × peso, Scorza = tenacia × 1 o × 1,6 per la corazza). `ItemsData.all()` e le ricette del
Maglio nascono da forma × materiale (`METALS` e `GEAR` tolti). `verifica_dati` confronta ogni valore con la tabella di
prima: tutto uguale tranne la corazza di pallidite (3 invece di 2, entro un punto). In Esamina il materiale e le sue
proprietà.

## 50. [x] Forme e fabbricazione componibile (L) — fatto il 26 set 2026
`FormsData`: le forme (lama corta, lama lunga, lancia, martello, falce, frusta, arco, balestra, bastone, piccone,
ascia, trivella, elmo, corazza…) con il loro modo di colpire e come pesano le proprietà del materiale. Un attrezzo =
forma × materiale principale × materiale del manico/della fascia: statistiche, nome («Falce di legnoferro con fascia
di seta») e icona (`ItemIcons.make` con forma e tavolozza) nascono da soli. Le istanze portano i componenti nei `dati`.
Le forme nuove richiedono nuovi modi di colpire in `Combat` (affondo della lancia, giro del martello, frusta).
**Pronto quando**: con 8 materiali e 14 forme il gioco offre centinaia di attrezzi diversi e confrontabili, tutti con
nome, icona e scheda in Esamina.
**Fatto il 26 set 2026**: 16 forme (le 7 di prima più Pugnale, Spadone, Lancia, Martello, Falce, Frusta, Balestra,
Trivella, Verga), 128 oggetti di metallo con icone nuove (`WeaponShapes`). Ogni forma pesa il materiale a modo suo
(lo spadone e il martello fanno danno anche col peso, il pugnale è rapidissimo) e colpisce nella sua area
(`FormsData.AREA`, `Combat.melee_area`): la lancia e la frusta lontano in linea, la falce davanti e dietro; la
balestra trafigge due creature; la trivella scava 1,6 volte più in fretta; la verga tira saette con la Linfa (danno
dalla conduzione del metallo). Il secondo materiale è la **fascia** del manico (seta, membrana, scaglie di serpe,
penne, gelatina regale): si avvolge al **Telaio** sull'oggetto in mano (`Crafting.wrap`) e sta nei "dati" della
casella. Tutto passa da `Gear` (`src/game/gear.gd`: i valori veri di un oggetto con tratto e fascia, il nome completo),
usato da `Combat`, `Spells`, `PlayerActions` ed Esamina; l'armatura indossata tiene i suoi dati (`Bisaccia.equip_data`).
Deciso da Claude: la fascia al posto di «materiale del manico» nella ricetta (sarebbero state 5 ricette per oggetto:
righe a centinaia). 128 × 5 fasce = 640 varianti. Prove `--solo=forme`, foglio delle icone prove/89_forme.png.

## 51. [x] Elementi e reazioni (M) — fatto il 26 set 2026
Sei elementi (brace, gelo, spora, Linfa, Vuoto, luce) portati dai materiali e dalle Essenze: stati sulle creature
(brucia, rallenta, avvelena, prosciuga, acceca…), debolezze e resistenze delle famiglie di creature, **reazioni** tra
elementi (gelo + brace = vapore che stordisce, spora + brace = scoppio…).
**Pronto quando**: scegliere l'elemento giusto cambia davvero lo scontro con almeno metà delle creature; l'Erbario
mostra le debolezze scoperte.
**Fatto il 26 set 2026** (`ElementsData`, `Elements`): sei elementi con il loro stato — brace (brucia nel tempo),
gelo (rallenta), spora (avvelena), Linfa (ti cura di un decimo del danno), Vuoto (vulnerabile: +30% a ogni colpo),
luce (acceca e ferma). Li portano i metalli (ambra e stellare luce, Linfa, Vuoto, pallidite gelo, tizzonite brace)
e gli incantesimi; valgono per mischia, dardi e saette. **Tutte** le 35 creature hanno una debolezza (danno ×1,6) e
molte una resistenza (×0,5); l'Erbario le ricorda quando le scopri. Ogni colpo lascia un **segno** per 3 secondi:
un colpo d'altro elemento sulla creatura segnata fa una **reazione** — Vapore (gelo + brace: stordisce, ×1,5),
Fiammata (spora + brace: ferisce chi sta attorno), Cristallo (gelo + Linfa: ferma a lungo), Squarcio (Vuoto + luce:
×2,5). Obiettivo «Fai reagire due elementi». Prova: brace 16 e spora 5 contro 10 sul grumo di muschio; Vapore 23.

## 52. [x] Leghe (M) — fatto il 26 set 2026
Al Baccello ardente due metalli si fondono in una **lega** con proprietà miste (e a volte una proprietà che nessuno dei
due aveva): i metalli di N mondi danno N×N leghe. Nomi delle leghe generati, pochi nomi speciali scritti a mano per le
combinazioni migliori.
**Pronto quando**: esistono leghe migliori dei loro metalli per certi usi, e nessuna è la migliore in tutto.
**Fatto il 26 set 2026**: 28 leghe (ogni coppia degli 8 metalli, con un nome scritto a mano: ferrobruno, ferrambra,
linfastella, stellanera, vaporite…). Al Baccello ardente un lingotto per metallo ne dà due di lega. Proprietà: durezza
quasi quella del più duro (×0,95), filo e tenacia della media +10%, il peso del più leggero, risonanza +1; se i due
metalli hanno elementi diversi la lega li porta tutti e due, **alternati** colpo dopo colpo (la vaporite, pallidite e
tizzonite, fa il Vapore da sola ogni due colpi). Ogni lega ha tutte le 16 forme (448 oggetti) e l'icona con i colori a
metà tra i due metalli. Per non riempire l'elenco Creare, le leghe si **scoprono**: la ricetta del lingotto compare
quando conosci i due metalli, le armi quando hai avuto il lingotto (`Crafting.known`); l'Erbario non conta gli oggetti
generati (`gen`) né le Fiale. `verifica_dati`: nessuna lega batte tutti i metalli in tutto. Foto prove/90_leghe.png.

## 53. [x] Materiali dai geni (M) — fatto il 26 set 2026
Ogni gene di minerale e di fauna porta **materiali propri** con proprietà scritte nei dati (non generate a caso): con la
Roadmap 5 i materiali passano da una decina a 30-40. Grazie alle forme ognuno dà subito tutta la sua serie di attrezzi.
**Pronto quando**: un materiale nuovo si aggiunge con una riga di dati e compare con tutti i suoi attrezzi, le ricette
e le icone.
**Fatto il 26 set 2026**: 12 materiali dei geni (`MaterialsData.GENE_MATERIALS`, una riga ciascuno): ferro di brina
(geodi di brina), ossidiana di brace (fiumi di brace), micelio duro (fungaie), linfite (laghi di Linfa: la migliore
conduzione), radicite pura, ambra dorata (metalli nobili), ferro stellato (vene stellari), vuoto cavo (cuore cavo),
sospesite (isole sospese: leggerissima, risonanza 3), nerume (Avvizzimento), chitina (creature dei mondi brulicanti),
osso antico (creature rare dei mondi ancestrali). Il grezzo cade scavando le tessere giuste solo nei mondi con il gene
(`GeneMaterials`, `PlayerActions.dig_hook`) o dalle creature; tre fanno un lingotto al Baccello; poi tutte le 16 forme.
Materiali in tutto: 48 (8 metalli, 28 leghe, 12 dei geni), oggetti 1190. Anche le loro ricette si scoprono (la colonna
Creare resta sotto le 300 righe).

## 54. [x] Innesti e qualità (M) — fatto il 26 set 2026
Gli innesti dell'universo: posti d'innesto per attrezzo secondo la qualità di fabbricazione (che dipende dalla stazione,
dai materiali e da un po' di fortuna); Essenze e parti di creatura come innesti; togliere un innesto costa. I tratti
di oggi diventano innesti.
**Pronto quando**: due attrezzi uguali possono essere molto diversi, e inseguire l'attrezzo perfetto è un obiettivo
lungo.
**Fatto il 26 set 2026**: ogni pezzo fabbricato nasce con una **qualità** (grezzo, buono, fine, capolavoro: danno e
Scorza ×0,9-1,18, colpi un poco più svelti; il Maglio lavora meglio del Ceppo, la fortuna alza il tiro). I **posti
d'innesto** sono 1 + i gradi oltre «buono» + la risonanza del materiale (al più 4): le Essenze si aggiungono nei posti
liberi ("dati.innesti"), il tratto di nascita occupa il primo; al Maglio un innesto si toglie (5 polvere di brace,
l'Essenza si perde). Tutti i tratti si sommano (`Gear.effect`) in combattimento, nell'armatura e nella Scorza. Il
nome dice tutto: «Spada d'ambra capolavoro [Furia, Fulmine, Vastità]». Prova: tra due spade d'ambra la peggiore fa 12,
la migliore 26. Deciso da Claude: la «qualità della stazione» vale per il Maglio contro gli altri banchi (le stazioni
migliori arriveranno con l'Albero-Madre).

# Roadmap 6 — resoconto (26 set 2026)
Gli oggetti ora si **generano**: 48 materiali con proprietà (8 metalli, 28 leghe, 12 materiali che esistono solo nei
mondi con il loro gene) × 16 forme, ognuna con il suo modo di colpire, 6 elementi con debolezze e reazioni, fasce,
qualità e innesti. Da 426 a 1190 oggetti, e ogni singolo pezzo può essere diverso da un altro uguale. La moltiplicazione
chiesta dalla filosofia: un gene nuovo porta un materiale, e il materiale porta 16 attrezzi. Prossima: Roadmap 7
«L'ecologia».

# Roadmap 7 «L'ecologia» — la fauna che vive

## 55. [x] Creature componibili (L) — fatto il 26 set 2026
`FamiliesData`: una **famiglia** (corpo, disegno di base, modo di muoversi) × **elemento** × **indole**
(comportamento) × **taglia** × varianti di colore = molte creature da una famiglia. Il disegno varia con tavolozza,
misura e piccoli pezzi aggiunti dal codice (corna, spine, bagliore). Le 27 creature di oggi diventano famiglie e
varianti.
**Pronto quando**: una famiglia nuova si scrive una volta e dà almeno 6 creature diverse nei mondi giusti.
**Fatto il 26 set 2026**: `FamiliesData` (26 famiglie dalle specie di prima: i tre grumi sono una famiglia) e le
**varianti** «specie~taglia~elemento~indole» (`CreaturesData.get_data`, `base_of`): taglia piccola o grande (Vita,
danno, velocità, misura), sei elementi (colori dell'elemento, resiste al suo e teme l'opposto, brace/luce/Linfa
brillano), tre indoli — **docile** (gironzola e non ferisce finché non la colpisci: la base dell'addomesticamento),
**feroce** (più forte e svelta, punte sul dorso), **timida** (scappa). Disegno in `VariantArt` (nessun disegno nuovo:
colori, misura e segni sul disegno della specie). Ogni famiglia dà 84 combinazioni (`verifica_dati` ne vuole almeno 6
con nomi diversi). Nascono a caso secondo il pericolo, con l'elemento del luogo più probabile (`Fauna.elem_bias`).
L'Erbario conta le specie e ricorda le varianti sconfitte. Foto 91_varianti. Prove `--solo=ecologia`.

## 56. [x] Famiglie per gene (M) — fatto il 26 set 2026
I geni di fauna decidono quali famiglie e quali varianti vivono in un mondo; 10-12 famiglie nuove (acquatiche pronte
per la Roadmap 10, volanti, scavatrici, colonie). Un **Custode per bioma** (Grande Cervo di brina, Madre delle
salamandre…) con la sua tana.
**Pronto quando**: due mondi con geni di fauna diversi hanno faune diverse per davvero.
**Fatto il 26 set 2026**: 10 famiglie nuove disegnate dal codice (`FaunaArt`): Pecora di muschio, Cornoradice,
Lepre di Linfa, Bruco di lanterna (erbivori, in gran parte docili), Ape di lume e Formica di resina (colonie in
sciame), Pipistrello di corteccia e Libellula di brina (volanti), Volpe d'ambra e Lince d'ardesia (predatori); con
materiali, trofei e 21 ricette nuove (`FaunaItemsData`: veste di lana, pozione di miele, dardi di libellula, spiedino,
accessori dai trofei…). Ogni famiglia ha un **ruolo** (erbivoro, predatore, colonia, volante, scavatore, neutro).
La fauna di un mondo (`Fauna.set_world`): dal seme tre famiglie favorite (×2,5) e due assenti; dai geni tre geni di
fauna nuovi — **Pascoli** (erbivori ×3), **Cacciatori** (predatori ×2,5), **Alveari** (colonie ×3) — e l'elemento più
comune delle varianti (fungaie → spora, geodi di brina → gelo…). Prova: erbivori nella foresta 61% con Pascoli, 32%
con Cacciatori. Due **Custodi dei biomi** con tana appena sotto la superficie del loro bioma: il **Grande Cervo di
brina** e la **Madre delle salamandre** (disegni ingranditi e tinti, pagine di storia, richiami all'Altare, un
accessorio ciascuno). Foto 92_famiglie. Le famiglie acquatiche aspettano l'acqua (Roadmap 10).

## 57. [x] La catena alimentare (L) — fatto il 26 set 2026
Le creature hanno bisogni: predatori che cacciano prede, erbivori che brucano piante e colture, spazzini che mangiano ciò
che resta, creature che si combattono tra loro. Popolazioni per zona (che calano se le si caccia troppo e crescono se
le si lascia), comportamenti visibili (fuga, branco, agguato).
**Pronto quando**: fermandosi a guardare si vede un mondo che vive anche senza il giocatore; le prove misurano che le
popolazioni restano in equilibrio.
**Fatto il 26 set 2026**: i **predatori** (8 famiglie con le loro prede in `FamiliesData.prey`) hanno fame e, quando
ce l'hanno, cacciano la preda più vicina (`BhCaccia`: corsa più svelta, morso che la prende: niente bottino, la
popolazione della preda cala). Gli **erbivori** (`BhPascola`) scappano dai predatori che li cacciano, con il fiato
che finisce (poi si fermano a riprenderlo: la volpe li raggiunge), e quando hanno fame brucano erba, fiori e felci
del pavimento (l'erba sparisce davvero); lepri e bruchi (`pest`) mangiano anche le colture del giardino.
**Popolazioni per zona** (`Ecology`, zone di 200 colonne, salvate nel mondo): ogni famiglia ha un fattore 0,15-1,8
che cambia quante ne nascono lì; cacciare una famiglia la fa calare, lasciarla stare la fa tornare, predatori e
prede si inseguono (più prede → più predatori → meno prede). La prova: 400 passi (mezz'ora di gioco) restano tra
0,19 e 1,05. Nel giro lungo, un Germogliato arrivato alla prova con poca Vita appassiva e rinasceva al letto:
la prova ora parte con la Vita piena e annota chi toglie le creature; e `snap_to` stacca la corda del rampino.

## 58. [x] Nidi, tane e migrazioni (M) — fatto il 26 set 2026
Nidi e tane da trovare (da cui nascono le creature di una zona: distruggerli la svuota, proteggerli la arricchisce),
migrazioni di branchi al cambio del giorno e (con la voce 66) delle stagioni.
**Pronto quando**: le creature non compaiono più «dal nulla» fuori dalla visuale ma dai loro nidi (dove il gene lo
prevede).
**Fatto il 26 set 2026**: 15 famiglie hanno **nidi** (`FamiliesData.nest`): nidi d'erba, tane (con due occhi che
brillano), alveari di lume e formicai di resina, disegnati in `NestArt` e sparsi dal generatore (`PassNidi`: dove
vive la specie, lontani dalla partenza e tra loro; nel mondo di prova 59). I mondi di prima li ricevono al primo
ingresso. Le creature di quelle famiglie nascono per lo più dai nidi della zona (`Ecology.nest_spawn`,
`Fauna.spawn_at_nest`). Clic destro su un nido: prendi un **uovo** (con la famiglia e la variante nei dati: si
schiude nell'Incubatrice della voce 59), oppure lo **nutri** con il cibo della famiglia (uova più in fretta, più
creature nella zona), oppure, con piccone o ascia, lo **distruggi** (la zona si svuota: popolazione 0,97 → 0,47).
Ogni nido rifà un uovo ogni 4 minuti, fino a tre. All'alba e al tramonto i branchi di 5 famiglie **migrano**, tutti
dalla stessa parte, per 50 secondi. Obiettivo «Prendi un uovo». Foto 93_nido.

## 59. [x] Addomesticare (L) — fatto il 26 set 2026
Calmare una creatura (cibo giusto, stordirla senza ucciderla, Essenze) e portarla nel Giardino in un **Vasetto**:
recinti e stalle, creature che producono materiali (seta, gelatina, latte di Linfa, piume), compagni e cavalcature da
qualunque famiglia adatta. I compagni e gli alleati di oggi entrano nel sistema; livelli dei compagni.
**Pronto quando**: si possono tenere almeno 10 famiglie diverse nel Giardino, ognuna utile a qualcosa.
**Fatto il 26 set 2026** (l'utente l'ha chiesta ampia): **25 famiglie** si addomesticano (`HerdData.TAME`: cibo,
difficoltà da 1 a 5, prodotto del recinto, dono a chi seguono, cavalcatura). Tre modi (`Taming`): il **cibo** giusto
con il clic destro, quando la creatura si fida (le docili sempre, le altre se hanno fame, sono stordite o indebolite:
ogni pasto dà affetto, di più alle docili, meno alle feroci); il **Laccio di seta** su una creatura stremata (sotto il
40% della Vita: più è debole più riesce, le feroci si liberano più spesso); le **uova** dei nidi nell'**Incubatrice
di muschio** (si schiudono in due minuti e mezzo, anche lontano). Il cibo sbagliato non va: la dieta si scopre
provando o dopo tre sconfitte. La **mandria** sta nel personaggio (`Character.mandria`, una scheda per creatura con
nome, livello fino a 20, fame, umore, Vita) e viaggia da un mondo all'altro (`Herd`): fino a 3 ti **seguono**, con
la fogliolina turchese, combattono le creature che ti minacciano (con l'elemento della loro variante), si feriscono
e, stremate, tornano a riposare nel Giardino; crescono di livello combattendo, mangiando e producendo; ognuna porta il
suo **dono** (Scorza, corsa, luce, fortuna, scavo, spine, rigenerazione, incantesimi…). Tasto **R**: in **sella**
a cornoradici, cervi, linci, salamandre o talponi (corsa fino a +65%, salto, niente ferite da caduta, scavo doppio).
Il **Recinto di radici** (4 creature, ed è anche la mangiatoia): mangiano da sole, producono lana, seta, miele,
resina, latte di Linfa, humus, piume, aculei… più in fretta se felici, di livello alto e con compagne della stessa
famiglia; il tempo passa anche mentre sei via (al più due ore). Il **Vasetto di radice** porta una creatura come
oggetto (la scheda nei dati). Pannello della **mandria** (tasto G): elenco, scheda, Segui, Riposa, Al recinto, Nel
vasetto, Libera, nome da cambiare. 6 obiettivi nuovi. Foto 95_mandria (in sella) e 96_recinto; prove `--solo=mandria`.
I compagni e gli alleati dei bastoni di prima restano com'erano (una cosa diversa: non mangiano e non crescono).

## 60. [x] Allevamento (M) — fatto il 26 set 2026
Due creature addomesticate danno un piccolo con i geni di entrambe (**lo stesso motore della voce 47**): colori,
taglia, elemento, doni. Varianti rare che si ottengono solo allevando.
**Pronto quando**: allevare è una seconda collezione lunga, con almeno 6 varianti ottenibili solo così.
**Fatto il 26 set 2026**: ogni creatura della mandria ha le sue **doti** (`BreedData`, regole in `Breeding`):
Vita, Forza e Resa (numeri attorno a 1), un **manto**, la generazione. Due creature della stessa famiglia, di
livello 3 o più, messe in **coppia** dal pannello della mandria e tenute nello stesso recinto sazie e contente, fanno
un **uovo** ogni 8 minuti (poi riposano un quarto d'ora): l'uovo compare nella mangiatoia e si schiude
nell'Incubatrice. Il figlio prende specie, taglia, elemento e indole da uno dei due (a volte ne esce una nuova), i
numeri dalla media più un po' di caso (e ogni tanto un salto in su): scegliendo i migliori per dieci generazioni la
Resa arriva a ×1,77. Manti: quattro comuni (chiaro, scuro, fulvo, muschiato) e **sei rari che si ottengono solo
allevando** — albino, d'ombra, dorato, cristallino, stellato (dalla terza generazione), iridato (dalla quarta) — più
il **gigante**: ognuno con il suo disegno (`VariantArt`: tinta, arcobaleno, puntini di stelle, bagliore, misura) e i
suoi bonus. I rari compaiono di più nelle stirpi lunghe (10% dei figli alla prima generazione, 28% alla settima) e un
genitore raro passa il suo manto a metà dei figli. Prima di decidere, il pannello mostra **che cosa può nascere** da
una coppia (400 figli di prova: intervalli dei numeri, manti con la percentuale, specie). Lo stesso modo di pensare
del motore dei Semi (dominanza del raro, rarità, mutazioni), con le sue tabelle. 3 obiettivi. Foto 97_manti.

## 61. [x] L'Erbario vivo (S) — fatto il 26 set 2026
Ogni famiglia con le sue varianti, dove vive, cosa mangia, debolezze, nidi, prodotti, vista/sconfitta/addomesticata/
allevata; percentuali per famiglia e totale.
**Pronto quando**: l'Erbario dice sempre cosa manca e dove cercarlo (a grandi linee: «nei mondi con il gene…»).
**Fatto il 26 set 2026**: l'Erbario ha la scheda **Famiglie** (36): per ognuna quello che il Germogliato ha
scoperto giocando (`BestiaryInfo`) — che vita fa, le specie, le varianti viste (su 84 per specie), dove vive e la
catena alimentare (dopo 3 sconfitte), i nidi (dopo averne trovato uno), se si addomestica e quanto è difficile, cosa
mangia (dandole il cibo o dopo 3 sconfitte), cosa dà nel recinto, il dono e la cavalcatura (dopo averne addomesticata
una), i manti visti nascere. Al posto di ogni riga che manca c'è un **indizio** di come scoprirla, e una famiglia mai
incontrata dice **dove cercarla** a grandi linee (strati, biomi, di notte, «più comune nei mondi con il gene
Pascoli/Cacciatori/Alveari», «se qui non c'è prova un altro Seme»). Le famiglie entrano nella percentuale
dell'Erbario; sotto ogni creatura, la famiglia e le varianti viste. La lista degli obiettivi si nasconde sotto i
pannelli a schermo intero (ci finiva sopra). Foto 98_erbario_famiglie.

**Resoconto della Roadmap 7** (voci 55-61, 26 set 2026): la fauna è diventata un sistema che vive. Famiglie e
varianti (36 famiglie × 84 varianti per specie), una fauna diversa per ogni mondo, predatori che cacciano ed erbivori
che scappano e brucano, popolazioni per zona, nidi e migrazioni; poi la parte più grande, chiesta dall'utente:
**addomesticare** (25 famiglie, tre modi, mandria che segue, combatte, cresce e aiuta, cinque cavalcature, recinti
che producono anche mentre sei via, Vasetti, Incubatrice) e **allevare** (doti, coppie, uova, sei manti rari e il
gigante solo allevando, anteprima dei figli). L'Erbario racconta tutto e dice cosa manca.

# Ritocchi dopo la Roadmap 7 (26 set 2026) — chiesti dall'utente provando il gioco

## R1. [x] Barre di Vita e Linfa (S) — fatto il 26 set 2026
Erano dieci foglie e dieci gocce piccole, quasi invisibili e coperte dalla minimappa. Ora due barre grandi su un
riquadro scuro, con il numero dentro; la Vita cambia colore (muschio, ambra, rosso), la parte appena persa si svuota
piano, sotto un quarto pulsa. La minimappa comincia sotto (`VitalsView.BOTTOM`).

## R2. [x] Banchi, mobili, casse e porte della misura giusta (M) — fatto il 26 set 2026
Erano alti quasi quanto il Germogliato. Alti una tessera: Ceppo, Maglio, Alambicco, Mola, Paiolo, Banco
dell'Innestatrice, Incubatrice, tavolo, sedia, letto, Focolare, Cesta, Scrigno, Reliquiario (Baccello ardente e Telaio
2×2); disegni fatti per la misura nuova (`CompactArt`). Porte alte due tessere, quanto il Germogliato; la prova della
casa controlla che la porta chiusa lo fermi e aperta lo lasci passare, e che il letto resti il punto di rinascita. Il
generatore appoggia le casse al pavimento secondo la loro altezza. Restano grandi di proposito: Altare, Radice
viandante, Recinto, portale, Aiuola, Cuore, bozzoli e nidi.

## R3. [x] Casse: creazione dalle casse vicine, impostazioni, pulsanti (M) — fatto il 26 set 2026
La creazione prende gli ingredienti anche dalle casse entro 10 tessere con «usa per creare» (`Crafting.pool`,
`have`, `take`: vale anche per rinnovo, fasce e innesti). Ogni cassa ha un nome (scritto sopra la cassa), «usa per
creare» e che cosa raccoglie (`StorageData`: minerali, materiali, costruzione, equipaggiamento, pozioni, semi,
mandria, tesori, niente). Pulsanti: Prendi tutto, Deposita tutto, Deposita simili, Rifornisci, Riordina; nella
Bisaccia «Nelle casse vicine». La barra rapida non si svuota mai da sola. Modulo `Storage`, prove `--solo=casse`.

## R4. [x] Il pannello Creare rifatto (M) — fatto il 26 set 2026
Alto tutta la destra dello schermo (basso con una cassa aperta); banchi vicini con le icone; nove categorie colorate
(`CraftCatsData`: armi, attrezzi, armature, accessori, pozioni e cibo, materiali, costruzione, giardino e mandria,
altro) che tingono righe, bottoni e intestazioni; ricerca per nome o ingrediente; «Solo possibili»; in «Tutto» gruppi
per tipo con quante ricette sono possibili; ogni riga con il banco e «ne hai/ne servono»; Maiusc+clic crea cinque
volte. Le righe sono un nodo solo che si disegna da sé: rifare l'elenco costa 7 ms, la prima apertura 42 ms.

## R5. [x] Alberi e vegetazione di ogni bioma (M) — fatto il 26 set 2026
Prima: otto forme dello stesso albero-lanterna, tutte alte uguali, in ogni bioma. Ora una specie per bioma
(`TreesData`, disegni in `TreeArt`): albero-lanterna, fungo-albero, acacia d'ambra, abete di brina, tizzone, in
quattro grandezze (piccolo, medio, grande, antico raro) e tre forme; i grandi reggono più colpi e danno più legno, un
seme cresce nell'albero del bioma dove lo si pianta. Tredici piante nuove (`BiomeDecorArt`): cespugli di
bacche-lanterna; erba di spore, canne, funghetti a grappolo; erba dorata, cardi, fiori di resina; muschio gelato,
cristalli e cespugli di brina; ciuffi bruciati, braci, stecchi carbonizzati. L'erba di ogni bioma resta bassissima
(4-5 pixel, richiesta dell'utente). Le piante si pascolano, ci si semina sopra, alcune lasciano semi selvatici.
Foglio con `tools/alberi.gd`, prove `--solo=alberi` (una foto per bioma).

# Roadmap 8 «Il risveglio dell'Albero-Madre» — il motivo

## 62. [x] Il Giardino vero (L) — fatto il 26 set 2026
Il mondo casa diventa **il Giardino**: un mondo più piccolo sospeso nel Vuoto attorno all'Albero-Madre addormentato,
con le Aiuole, lo spazio per la base, i recinti e la serra. I personaggi e i mondi di oggi migrano: il mondo di partenza
diventa il primo mondo nato da Seme (da decidere con l'utente quando si arriva qui).
**Pronto quando**: una partita nuova comincia nel Giardino, e il primo Seme porta al primo mondo.
**Fatto il 26 set 2026** (il mondo di partenza lo ha deciso Claude, su delega dell'utente): una partita nuova (menu «Nuovo
Giardino») comincia nel **Giardino**, un mondo piccolo (480×240) sospeso nel Vuoto (`PassGiardino`): un'isola di
muschio e terra con il cuore di pietra e un po' di radicite, le radici che pendono sotto, due isolotti vicini, alberi e
piante della foresta; al centro l'**Albero-Madre** addormentato (grande, spoglio, gli occhi chiusi nel legno:
`MotherTreeArt`, cinque fasi di crescita), accanto la prima **Aiuola**. Solo cielo, stelle e radici del cosmo dietro
(`Background.set_void`); niente creature, Avvizzimento, firma né Cuore; chi cade nel Vuoto è respinto all'Albero.
Il **mondo di partenza di prima diventa il primo mondo nato da Seme**: toccando l'Albero la prima volta, lui lascia
cadere il primo Seme (con il gene scelto nel menu, vigore 1); piantato nell'Aiuola apre il portale verso un mondo come
quelli di sempre. Corretto un difetto vecchio: i mondi dei portali non venivano riconosciuti come «non casa» (si
guardava "ritorno", mai scritto): ora `Aiuole.is_home` guarda "casa". Prove `-- --prove --prova-giardino`
(`TestsHome`), foto 101_giardino.

## 63. [x] Gli stadi dell'Albero-Madre (L) — fatto il 26 set 2026
10-15 stadi di crescita; ognuno chiede **offerte** (Linfa antica dei Cuori, geni, creature, reliquie, materiali di
mondi con certi geni) e sblocca: Aiuole, stazioni, categorie di geni innestabili, abitanti, poteri. L'Albero si vede
crescere nel Giardino (disegno a stadi).
**Pronto quando**: dal primo all'ultimo stadio c'è sempre una richiesta chiara e un modo per capire dove cercare.
**Fatto il 26 set 2026**: 12 stadi (`MotherTreeData`): Il primo respiro, Radici che bevono, La prima Linfa antica,
Fronde nuove, Il Seme che ricorda, Ambra e memoria, Il canto della mandria, Il fuoco sotto la cenere, Le stirpi, Oltre
il Vuoto, La chioma d'ambra, Il risveglio. Ognuno chiede **offerte** — oggetti (legno, lingotti, Linfa antica dei
Cuori, seta, squame, vuotite, cristalli, Frammenti dell'Albero…) che si portano anche a più riprese, prendendoli dalla
Bisaccia e dalle casse vicine, e **traguardi** (mondi visitati, geni imparati, firme, creature addomesticate, uova
allevate, Custodi, Guardiani risolti, manti rari) — ognuno con un **indizio di dove cercare**. Quando c'è tutto,
«Risveglia» lo fa crescere (`AlberoMadre`, stato nel personaggio): cinque fasi di disegno, **Aiuole** in più (si parte
da una sola), i **poteri** (voce 64), gli **abitanti** (voce 65), le **categorie di geni** che il Banco
dell'Innestatrice sa innestare (all'inizio superficie, forma e fauna), quattro pagine di storia. Pannello
`AlberoPanel` (clic destro sull'Albero); in ogni mondo una riga sotto gli obiettivi ricorda che cosa chiede adesso
l'Albero (il filo da seguire). Tre obiettivi nuovi. Foto 102_albero e 103_albero_sveglio.

## 64. [x] I poteri del Germogliato (M) — fatto il 26 set 2026
Poteri permanenti dagli stadi dell'Albero (vista della Linfa per vedere vene e geni nascosti, respiro nell'acqua,
radici-ponte, salto delle spore, passo nel Vuoto…). Certi luoghi e certi geni si raggiungono solo con un potere:
l'esplorazione si apre a strati, come in un metroidvania.
**Pronto quando**: almeno 6 poteri, ognuno apre luoghi che prima non si potevano raggiungere.
**Fatto il 26 set 2026**: sei poteri, doni degli stadi 2, 4, 6, 8, 10 e 11 dell'Albero (`PowersData`, regole in
`Powers`): **Vista della Linfa** (tasto V: per 8 secondi brillano le vene, i Sigilli e gli scrigni attorno),
**Canto delle radici**, **Passo nel Vuoto**, **Pelle di brace** (aprono ognuno i suoi Sigilli; in più scavo +25%, il
Vuoto del Giardino non ferisce, +3 Scorza), **Salto delle spore** (un salto in aria in più, salti più alti),
**Radici-ponte** (tasto F: una passerella di radici verso il mouse, 12 tessere, un minuto). Ogni mondo ha 14 **luoghi
sigillati** (`PassSigilli`): stanze chiuse da un **Sigillo** (quattro tessere nuove che il piccone non scalfisce: il
velato sembra ardesia e lo mostra la Vista; radice, Vuoto e brace sono pietra lavorata con le rune accese) nel loro
strato, e due **nidi alti** nel cielo (Salto e Ponte). Clic destro su un Sigillo con il potere giusto: si dissolve
tutto. Dentro, uno scrigno con il bottino e un **Frammento dell'Albero**, che gli stadi 6, 8, 10 e 12 chiedono: i
poteri aprono i frammenti, i frammenti gli stadi, gli stadi i poteri dopo. Prove `--solo=sigilli` (foto
106_sigillo_chiuso) e nel Giardino (foto 104_sigillo).

## 65. [x] Abitanti con i mestieri (L) — fatto il 26 set 2026
Gli abitanti dell'universo: la **Vecchia Radice** (guida, racconta), il **Mercante di Semi**, l'**Innestatrice**,
il **Cartografo dei Seminatori**, il **Mandriano** (creature), più quelli di oggi. Arrivano con gli stadi
dell'Albero; affetto (sconti, doni), una casa per ciascuno, richieste personali.
**Pronto quando**: ogni abitante ha un motivo per esserci e almeno una catena di richieste.
**Fatto il 26 set 2026**: cinque abitanti nuovi con un mestiere, che arrivano man mano che l'Albero-Madre cresce:
la **Vecchia Radice** (vive accanto all'Albero dal primo stadio, senza casa: suggerisce l'offerta che manca), il
**Mercante di Semi** (Semi di mondo già pronti, Fiale), il **Mandriano** (esche, recinti, prodotti), l'**Innestatrice**
(Fiale e Linfa antica) e il **Cartografo** (la Mappa dei Sigilli e la Mappa della firma: dicono da che parte è il
Sigillo o la firma più vicina). **Affetto** (`NpcBonds`): i doni che un abitante ama valgono 5 per oggetto, gli altri
1 (al più 20 per dono), una richiesta compiuta 30; ogni 25 punti un livello (cuori nel titolo), il 5% di sconto per
livello e un regalo ai livelli 2 e 4. Ogni abitante ha **tre richieste** in fila (portare, trovare, sconfiggere), mostrate
nel pannello del commercio con «Consegna la richiesta» e «Dona ciò che hai in mano». Obiettivi «richiesta» e
«richieste_10». Prove nel Giardino (`--prova-giardino`, foto 105_abitanti).

## 66. [x] Le stagioni (M) — fatto il 26 set 2026
Le stagioni in ogni mondo (durata da provare): cambiano creature, colture, eventi, migrazioni; geni, creature e boss
che esistono solo in una stagione.
**Pronto quando**: tornare in un mondo in un'altra stagione dà cose nuove da trovare.
**Fatto il 26 set 2026**: ogni mondo ha quattro **stagioni** (`SeasonsData`, regole in `Seasons`) di tre giorni
l'una, spostate dal seme del mondo (due mondi vicini non sono nella stessa stagione): **Germoglio** (erbivori e colonie
ovunque, le colture crescono in fretta), **Rigoglio** (i volanti riempiono il cielo, notti brevi), **Raccolto** (i
predatori cacciano, i branchi migrano, più eventi), **Gelo** (tutto rallenta, pochi erbivori, scendono cervi e gufi
del gelo). Ogni stagione cambia chi nasce (ruoli e famiglie), la crescita del giardino, gli eventi e la tinta del
cielo; è scritta nell'orologio e al cambio compare la scritta come per gli strati. Ogni stagione ha la sua
**creatura** (Lepre del germoglio, Libellula del rigoglio, Volpe del raccolto, Cervo del gelo: varianti di specie che ci
sono già, generate da `SeasonsData.make`) con il suo **materiale**, da cui nascono quattro **accessori** (Corona del
germoglio, Ali del rigoglio, Mantello del raccolto, Cuore del gelo). Quattro **geni di stagione** (`only: "stagione"`:
Germoglio eterno, Rigoglio lungo, Raccolto d'oro, Gelo perenne) fermano un mondo in una stagione: si prendono con la
Provetta toccando cielo o tempo in quella stagione o dalla sua creatura, e si innestano nei Semi. Obiettivi «stagione» e «stagioni_4».
Prove `--solo=stagioni` (foto 107_stagione).

## 67. [x] La bacheca delle richieste (M) — fatto il 26 set 2026
Richieste generate senza fine, costruite dal registro dei geni e dei mondi: «portami tre Palchi di brina da un mondo
con notti lunghe», «trova la firma di un mondo con grotte ad alveare», «alleva una salamandra bianca». Ricompense:
Semi rari, Fiale di gene, Linfa antica, oggetti unici. Le richieste puntano sempre a qualcosa che il giocatore **può**
fare con ciò che ha già imparato (o quasi).
**Pronto quando**: in qualunque momento della partita ci sono almeno tre richieste sensate aperte.
**Fatto il 26 set 2026**: la **Bacheca dei Giardinieri** (stazione 3×2, già piazzata nel Giardino accanto alla
partenza; se ne fa un'altra al Ceppo con legno e seta di radice). Clic destro: ci sono sempre **quattro richieste**
aperte (`Board`, stato in `Character.bacheca`: seguono il personaggio in ogni mondo), costruite da ciò che il
personaggio **conosce già**, così sono sempre fattibili: fornitura (un materiale già trovato: il filo che non si spezza
mai), materiale dei geni (da un mondo con un gene visto), caccia (una famiglia incontrata), mandria e prodotto (famiglie
addomesticabili), firma, viaggio, Sigillo (se si ha un potere che li apre). Più si scopre, più le richieste sono varie.
Premi: Semi di mondo con un **gene raro** in più (il premio più ambito), Fiale, Linfa antica, Provette, Polvere
iridata, Lumini. «Cambia» sostituisce una richiesta che non piace. Il pannello (`BoardPanel`) mostra per ogni foglio il
tipo con il suo colore, l'icona, la barra di avanzamento e i premi; gli oggetti si consegnano anche dalle casse vicine.
Obiettivi «bacheca» e «bacheca_20». Prova nel Giardino (`--prova-giardino`, foto 108_bacheca).

### Resoconto della Roadmap 8 (26 set 2026)
La partita ha un motivo: si comincia nel **Giardino**, un'isola sospesa nel Vuoto con l'**Albero-Madre**
addormentato. Il primo tocco dà il primo Seme; da lì in poi l'Albero chiede offerte (materiali, geni, creature,
Frammenti) per **12 stadi**, e ogni stadio dona qualcosa che cambia il modo di giocare: Aiuole in più, categorie di
Fiale da innestare, abitanti nuovi, e **sei poteri** che aprono i **Sigilli** dei mondi (dentro ci sono i Frammenti che
servono agli stadi dopo: il giro si chiude su se stesso). Gli **abitanti** hanno un mestiere, un affetto che cresce con
doni e richieste, e tre richieste ciascuno; le **stagioni** cambiano ogni mondo ogni tre giorni e portano creature,
materiali e geni loro; la **Bacheca** dà sempre quattro richieste fattibili, costruite da ciò che si conosce. In ogni
momento c'è un filo da seguire: la riga dell'Albero nell'HUD, la Vecchia Radice che suggerisce, gli abitanti, la
Bacheca. Prove: `--prova-giardino` (foto 101-108), gruppi `sigilli` e `stagioni`; giro completo pulito, fotogramma
peggiore sotto i 25 ms.

# Ritocchi dopo la Roadmap 8 (26-27 set 2026) — chiesti dall'utente provando il gioco

## R6. [x] La scheda del mondo sopra i portali (S) — fatto il 26 set 2026
Con il mouse sopra un portale: nome del mondo, vigore spiegato, Guardiano del Cuore, stagione, visitato o no (quanto
esplorato, tempo, firma), genoma con i geni mai visti come «?» (`PortalInfo`). Ora è una scheda del sistema R7.

## R7. [x] Il sistema dei suggerimenti (L) — fatto il 27 set 2026
Richiesta dell'utente: «un sistema di tooltips generale del gioco vasto, completo e bello». Scelte dell'utente:
suggerimenti ricchi sugli oggetti (ricette e provenienza restano in Esamina) e anche nel mondo, su tutto.
Un motore solo (`Tips`, autoload `TipsLayer`, in `src/ui/tips/`) sostituisce i suggerimenti di Godot (spenti in
project.godot): schede composte con `TipCard` (nome con icona, che cos'è, valori in colonna, righe con i colori, barre,
righe sottili, comandi in fondo) e disegnate da `TipView` (riquadro scuro, bordo e filo del colore della scheda, ombra,
comparsa morbida); accanto al mouse, sopra il mouse vicino al bordo in basso; nel mondo dopo un attimo di mouse fermo,
nell'interfaccia quasi subito, la successiva senza attesa; si aggiornano da sole (Vita di una creatura, crescita).
- **Oggetti** (`ItemTip`, in ogni casella: Bisaccia, barra rapida, equipaggiamento, casse, mercante, Esamina, pila in
  mano, righe di Creare): nome del colore della qualità o del tipo, tipo, grado e qualità, valori veri (danno, colpi al
  secondo, forza e che cosa scava, Scorza, trafigge, cure, Linfa, portata, esplosione), elemento, tratti e innesti
  (rossi quelli che peggiorano), posti d'innesto liberi, fascia, effetti da indossato, set con i pezzi che hai,
  effetto delle pozioni, doni, geni di un Seme uno per riga, creature nel vasetto, uova, descrizione, valore o prezzo
  del mercante; **Maiusc** confronta con l'armatura indossata o con l'arma e l'attrezzo in mano (+/− colorati).
- **Creare**: la scheda dell'oggetto che nasce, gli ingredienti con quanti ne hai (e quanti nelle casse), il banco.
- **Mondo** (`WorldTip`, `StationTip`; solo dove hai già visto): creature (Vita, danno, Scorza, debolezze e
  resistenze agli elementi, tratti delle antiche, stati, se si addomestica e con che cosa, affetto, quante ne hai
  sconfitte e che cosa lasciano), abitanti (affetto, sconto, che cosa gli piace, richiesta), oggetti a terra, banchi
  (ricette, se sei abbastanza vicino), casse e scrigni (nome, caselle, contenuto), portali, Albero-Madre (offerte con le
  barre), Bacheca, nidi, bozzoli, alberi (specie, grandezza, legno), colture (crescita, annaffiata), minerali e rocce
  (forza richiesta contro il tuo piccone, che cosa lasciano), Sigilli (con che potere si aprono; il velato resta
  nascosto finché non usi la Vista), piante da raccogliere.
- **Interfaccia** (`HudTips`): Vita e Linfa (Scorza, ricrescite, doni, attesa delle pozioni), orologio (notte,
  stagione e quando cambia), obiettivi (premi e barre), riga dell'Albero, effetti attivi, minimappa; celle
  dell'Erbario; i vecchi `tooltip_text` di bottoni e pannelli diventano schede da soli.
Costo: 0,6 ms per comporre una scheda, 3 ms per disegnarla (solo quando cambia). Prove `--solo=suggerimenti` (foto
110-120).

## R8. [x] Le Opzioni e la pausa (M) — fatto il 27 set 2026
Richiesta dell'utente: «una ampia e completa schermata delle opzioni che copra tutti gli aspetti del gioco, compresa la
possibilità di mettere in pausa il gioco quando si è in creazione e decidere il ritardo dei tooltips».
**Esc** apre il menu di pausa (Riprendi, Opzioni, Enciclopedia, Salva ora, Salva e torna al menu, Salva ed esci): prima
Esc salvava e tornava subito al menu. Le **Opzioni** (`OptionsPanel`, dati in `OptionsData`: 29 opzioni in sei
sezioni, ognuna con la sua spiegazione) si aprono dalla pausa e dal menu iniziale:
- **Audio**: volume generale, musica, effetti, ambiente, musica degli scontri.
- **Video**: finestra / schermo intero / senza bordi, sincronia verticale, fotogrammi al massimo, ingrandimento della
  visuale (1,5×-3×), chiarore del buio (per chi fatica a vedere; di partenza buio pieno), tremolio della torcia, polvere
  e scintille, contatore dei fotogrammi.
- **Interfaccia**: aiuto dei tasti (prime ore, sempre, mai), obiettivi, riga dell'Albero, minimappa, barre della Vita
  delle creature, durata degli avvisi.
- **Gioco**: **pausa mentre crei** (Bisaccia aperta), pausa con i pannelli grandi, pausa fuori dalla finestra,
  salvataggio automatico (1-10 minuti o mai).
- **Suggerimenti**: accesi, **ritardo** nell'interfaccia e nel mondo, nel mondo sì o no, grandezza, confronto sempre o
  con Maiusc.
- **Comandi**: ogni tasto si cambia (due per comando; un tasto già usato passa al comando nuovo); nessun `KEY_…` è più
  scritto nel codice (`KeysData`, `Keys`), e l'aiuto a schermo scrive i tasti scelti.
In pausa il mondo si ferma (creature, tempo, crescita) ma interfaccia, suggerimenti e suoni restano vivi. Le prove usano
sempre i valori di partenza e non scrivono mai il file del giocatore. Prove `--solo=opzioni` (foto 121-123).

## R9. [x] L'Enciclopedia (L) — fatto il 27 set 2026
Richiesta dell'utente: «una ampia Enciclopedia del gioco, accessibile con un pulsante nel gioco… il punto di
riferimento per il giocatore, dove può togliersi qualsiasi dubbio». Tasto **H**, bottone «?» in basso a sinistra,
menu di pausa, menu iniziale. A sinistra ricerca e indice, a destra la pagina con i collegamenti; Indietro, Inizio.
- **Capitoli** scritti (`EncyGuideData`, `EncyCraftData`, `EncySeedsData`, otto gruppi: Primi passi, Il mondo, Scavare e
  costruire, Creare ed equipaggiarsi, Combattere, La vita del mondo, Semi e mondi, Il Giardino) che spiegano ogni
  meccanica; i numeri (Vita, attese, portate, percentuali) e le liste (strati, biomi, stagioni, eventi, minerali, banchi,
  forme, fasce, set, elementi e reazioni, Guardiani, Custodi, abitanti, categorie dei geni, stadi, poteri, tasti) li
  prende dai dati, così restano giusti.
- **Cataloghi** generati: oggetti per categoria, creature per famiglia, famiglie, geni per categoria, materiali, forme,
  tratti, banchi e stazioni, obiettivi (con quelli fatti); ogni voce apre la sua scheda (oggetto come in Esamina,
  creatura con dove vive, elementi, bottino e addomesticamento, gene come nel Genario).
- Ciò che non hai scoperto resta «???»; «Anticipazioni» lo mostra.
Le prove controllano ogni pagina (niente segnaposti rimasti) e ogni collegamento (751, tutti validi). Prove
`--solo=enciclopedia` (foto 124-126). **Ogni voce nuova aggiunge o aggiorna il suo capitolo.**

# Roadmap 9 «Il mistero dei Seminatori» — il racconto sopra il motore

## 68. [x] La lingua dei Seminatori (M) — fatto il 26 set 2026
Le scritte dei Seminatori sono glifi: ogni tavoletta trovata insegna parole, il Cartografo aiuta a decifrare. Le
scritte sui muri delle rovine si leggono a poco a poco: una progressione di **conoscenza**, non di equipaggiamento.
**Pronto quando**: una stessa scritta, riletta più avanti nella partita, dice di più (e indica qualcosa da cercare).
**Fatto il 27 set 2026**: la lingua dei Seminatori è una lingua vera, con 50 parole sue (`LanguageData`: «vehl» =
radice, «dun» = sigillo, «ost» = verso l'alba…). In ogni mondo le **stele** (`PassStele`: una in ogni rovina dove c'è
posto, due in superficie vicino alla partenza, una nel Giardino) portano una frase: quasi tutte indicano un **luogo vero**
di quel mondo rispetto alla stele (un Sigillo con il suo tipo, un reliquiario, la firma, il Cuore, la tana di un
Custode: «sigillo di brace dorme sotto, verso l'alba, lontano»), le altre raccontano la storia dei Seminatori e del Seme
Nero. Leggendo (clic destro, `ReadPanel`) le parole conosciute sono in italiano, le altre restano nella loro lingua; la
prima lettura insegna una parola dal contesto; le **tavolette dei Seminatori** (scrigni delle rovine, Cartografo)
insegnano tre parole, prima quelle delle stele del mondo dove sei. Quando una frase è tutta compresa il luogo si
**segna sulla mappa** (`world_meta["segni"]`, un rombo con il nome, anche dove la mappa è nera): la stessa stele,
riletta più avanti, dice di più. Le parole valgono in tutti i mondi (`Character.lingua`). La scheda di una stele (mouse
sopra) mostra la frase e quante parole capisci. Obiettivi «stele», «parole» (15), «parole_tutte». Enciclopedia: capitolo
«La lingua dei Seminatori» e il **Glossario**. Prove `--solo=lingua` (foto 127_stele, 128_segno_sulla_mappa).

## 69. [x] Le catene di ricerca tra i mondi (L) — fatto il 26 set 2026
Catene generate e scritte: un indizio in un mondo indica un gene o una combinazione di geni; il mondo che ne nasce ha
una rovina sigillata; dentro c'è la chiave o la mappa per la tappa dopo. Alcune catene lunghe scritte a mano (la
storia), molte brevi generate (i segreti).
**Pronto quando**: esiste la prima catena lunga completa (5+ tappe in mondi diversi) e le brevi non finiscono mai.
**Fatto il 27 set 2026**: le catene di ricerca (`ChainsData`, regole in `Chains`). Ogni tappa dice **di che geni
deve essere fatto un mondo**: quando si pianta un Seme con quei geni, il generatore (`PassCatene`, con le tappe aperte in
`params["catene"]`) mette nel mondo nuovo una **cripta dei Seminatori** con il **leggio**; entrando nel mondo la cripta
si segna sulla mappa. Sul leggio (clic destro) il pezzo di storia, il premio e l'indizio della tappa dopo.
- **La via del Seme Nero**, scritta a mano, cinque tappe in cinque mondi (Radici giganti → Avvizzito di vigore 2 →
  Stellato → Brina con Fungaie → Cuore nero), comincia dopo il primo viaggio e finisce con il **Seme Nero** (voce 72).
  Il gene Cuore nero ha ora una combinazione segreta (Avvizzito + Notti lunghe) che la catena insegna.
- **Catene brevi**, due alla volta e senza fine, dai geni già visti (due categorie diverse), con premi a caso (Semi con
  un gene raro, Linfa antica, tavolette, Polvere iridata, Lumini, Rugiada, Provette).
Il **Taccuino delle catene** è la terza scheda del Semenzaio (K): indizio, geni necessari e se li conosci. La scheda di un
Seme (mouse sopra) dice se porta a una cripta. Obiettivi «catena» e «catene_10»; capitolo nell'Enciclopedia; la verifica
dei dati controlla geni e premi delle catene. Prove `--solo=catene` (foto 129_leggio, 130_taccuino).

## 70. [x] Luoghi scritti a mano (L) — fatto il 26 set 2026
Luoghi progettati come modelli (tempio sommerso, città sepolta, biblioteca di radici, serra dei Seminatori,
osservatorio, alveare colossale…) che il generatore piazza solo nei mondi con i geni giusti, adattandoli al terreno.
Sono la parte «a mano» che dà sapore a quella generata. Almeno 8 per cominciare.
**Pronto quando**: trovare un luogo scritto a mano è un evento; ognuno ha un premio e un pezzo di storia.
**Fatto il 27 set 2026**: otto luoghi scritti a mano (`PlacesData`: disegni a caratteri, uno per fila di tessere, con
pietre, vetro, radici, ambra, cristalli, vuotite, stazioni e i posti della porta e dei meccanismi della voce 71): la
**Biblioteca di radici** (stele), la **Serra dei Seminatori** (piante-seme, vetro), l'**Osservatorio** (cupola di vetro in
superficie), l'**Alveare colossale** (celle d'ambra), la **Forgia antica** (un Maglio), la **Cripta di brina** (pareti di
cristallo), il **Santuario del Vuoto** (vuotite, chiuso a chiave: la chiave è in uno scrigno delle rovine dello stesso
mondo) e il **Tempio della Linfa**. `PassLuoghi` li mette **solo nei mondi con i geni giusti** (ne basta uno di quelli
del luogo), al più tre per mondo, nel loro strato o sulla superficie, lontano da partenza, Cuore e costruzioni, e li
scava nel terreno con le rune sul soffitto. Entrando in un luogo lo si **trova** (`Places`): scritta come per gli strati,
segno sulla mappa, conteggi. Il **leggio** racconta un pezzo della storia dei Seminatori e del seme caduto dal Vuoto;
lo **scrigno** ha bottino ricco, tavolette, Linfa antica e l'**oggetto unico** del luogo (otto accessori nuovi: Occhiali
dei Seminatori, Guanti del giardiniere, Lente stellare, Pettorale di cera, Anello del mantice, Cuore di brina eterna,
Frammento di Vuoto domato, Goccia della Linfa madre). Le stele possono indicare anche un luogo. `WorldView.refresh_rect`
ridisegna una zona cambiata. Obiettivi «luogo» e «luoghi_tutti»; capitolo nell'Enciclopedia (i luoghi non trovati
restano nascosti). Prove `--solo=luoghi_scritti` (foto 131_luogo, 132_luoghi).

## 71. [x] Enigmi e meccanismi (M) — fatto il 26 set 2026
Meccanismi dei Seminatori (leve di radice, specchi che portano la luce, canali di Linfa da aprire, piastre, porte a
glifi) nei luoghi della voce 70 e nelle rovine sigillate.
**Pronto quando**: almeno 6 tipi di meccanismo combinabili; i luoghi grandi hanno un enigma ciascuno.
**Fatto il 27 set 2026**: sei tipi di meccanismo dei Seminatori (`Mechanisms`, dati in `PlacesData`), combinati negli
otto luoghi della voce 70: la stanza del tesoro è chiusa da una **porta dei Seminatori** (tessera nuova `PORTA_SEM`,
pietra con le rune d'oro, il piccone non la scalfisce) che si apre risolvendo l'enigma del luogo:
- **bracieri** da accendere tutti con una torcia (clic destro, la consuma) — Osservatorio, Forgia;
- **leve** da mettere come dice il leggio, scritto nella lingua dei Seminatori («ul» su, «nae» giù: la lingua della voce
  68 serve anche qui) — Serra, Tempio;
- **piastre** su cui salire tutte entro 5 secondi — Alveare;
- **cristalli d'eco** da risvegliare con un'arma dell'elemento giusto in mano (la scheda del cristallo dice quale) —
  Cripta di brina;
- **porta a glifi**: una frase nella lingua dei Seminatori, si apre quando ne conosci tutte le parole — Biblioteca;
- **chiave**: la Chiave dei Seminatori, in uno scrigno delle rovine dello stesso mondo — Santuario del Vuoto.
I parametri (il codice delle leve, gli elementi dei cristalli, la frase della porta) nascono dal seme del mondo; lo
stato dei meccanismi sono le stazioni stesse (braciere / braciere acceso, leva giù / su, piastra / premuta, cristallo /
risvegliato), disegnate in `SeminatoriArt`. Le schede della porta e dei meccanismi dicono che cosa chiedono. Aperta la
porta: rune che si spengono, suono, avviso, conteggio «enigmi». `WorldView.refresh_rect` ora rimette in coda i blocchi
visibili (prima restavano vuoti finché la visuale non si spostava). Obiettivi «enigma» e «enigmi_8»; capitolo
nell'Enciclopedia. Prove `--solo=enigmi`: tutti e otto risolti come li risolverebbe il giocatore (foto 133_enigma,
134_porta_aperta).

## 72. [x] Il Seme Nero (L) — fatto il 26 set 2026
L'origine dell'Avvizzimento e il grande arco del racconto: indizi in tutte le catene, geni malati, un luogo finale e un
Guardiano che si può sconfiggere o curare, come tutti. Non chiude il gioco: apre il fine gioco (Roadmap 11).
**Pronto quando**: la storia principale si può giocare dall'inizio alla fine.
**Fatto il 27 set 2026**: il grande arco del racconto (`NeroData`). L'ultima tappa della via del Seme Nero (voce 69) dà
il **Seme Nero**; piantato in un'Aiuola apre il mondo «**Dove cadde il Seme Nero**» (`world_meta["nero"]`, gene Cuore
nero: Avvizzimento a macchie ovunque; `PassNero` fa malata tutta la roccia attorno alla cupola del Cuore, con punte di
vuotite). Il suo Guardiano non è uno dei tre ma **l'Avvizzitore** (`NeroArt`: il seme stesso cresciuto, guscio nero
con le crepe viola; guarito verde scuro con le crepe turchesi e le foglie), debole alla luce e alla Linfa, con ventagli
fitti, scatti e avvizziti chiamati in aiuto. Come ogni Guardiano si **sconfigge** o si **cura** (Rugiada sui quattro
nodi), e la scelta vale per **tutti i mondi** (`Character.seme_nero`, `Guardian.nero_choice`): **spezzato**,
l'Avvizzimento smette di allargarsi ovunque e lascia le Schegge del Seme Nero; **curato**, si ritira un poco alla volta
in tutti i mondi e lascia la Linfa del Seme guarito (due amuleti nuovi al Maglio). Due pagine di storia per il finale;
indizi in tutte le catene, nelle stele e nei leggii dei luoghi. Non chiude il gioco: apre il fine gioco. Obiettivo
«seme_nero»; capitolo nell'Enciclopedia. Prove `--solo=seme_nero` (foto 135_avvizzitore, 136_avvizzitore_guarito).

### Resoconto della Roadmap 9 (27 set 2026)
Il racconto è diventato una meccanica. La **lingua dei Seminatori** (50 parole) si impara da stele, tavolette e
contesto, e fa capire frasi che indicano luoghi veri di ogni mondo. Le **catene di ricerca** chiedono mondi fatti di
certi geni e costringono a **progettare** i Semi: la via del Seme Nero è la storia principale, le catene brevi non
finiscono mai. Otto **luoghi scritti a mano** compaiono solo nei mondi con i geni giusti, ognuno con storia, tesoro
unico e un **enigma** (sei tipi di meccanismo, anche con la lingua). Il **Seme Nero** chiude l'arco con una scelta che
cambia tutti i mondi. Prove `--solo=lingua,catene,luoghi_scritti,enigmi,seme_nero`; giro completo pulito.

# Roadmap 10 «Le leggi dei mondi» — meccaniche fisiche come geni

Ogni legge è un **gene** (raro, spesso di vigore alto): i mondi non diventano solo più forti ma **diversi da giocare**.

## 73. [x] L'acqua (L) — fatto il 26 set 2026
Liquidi che scorrono a tessere (simulazione a blocchi, solo vicino alla visuale), nuoto, respiro, creature acquatiche
(famiglie della voce 56), laghi e grotte allagate; gene «Sommerso» (mondi quasi tutti d'acqua).
**Pronto quando**: un mondo sommerso si gioca in modo diverso da tutti gli altri, e resta a 60 fotogrammi al secondo.
**Fatto il 27 set 2026**: l'acqua. Un nuovo strato del mondo (`World.liquid`: livello 0-8 e tipo per cella, salvato con
il mondo; i mondi di prima nascono senza liquidi) e un automa a celle (`Liquids`, dati in `LiquidsData`): solo le celle
**attive** e solo vicino al Germogliato (`WINDOW`), a passi di 0,05 s con un tetto di celle per passo; un liquido cade se
sotto c'è posto, altrimenti **il tratto appoggiato sulla stessa riga si livella tutto insieme** (niente gradini, e si
ferma senza oscillare); scavare accanto a un liquido lo risveglia (`World.on_change`). Un passo con 400 celle in moto
costa ~0,5 ms. Disegno per blocchi (`LiquidView`, ridisegnato solo dove cambia), davanti al Germogliato. Il
**nuoto** (`Player.in_liquid`: gravità e caduta lente, si sale tenendo il salto, niente ferite da caduta) e il
**respiro** (12 s sott'acqua, poi si perde Vita; i pallini in alto a destra). Due **creature d'acqua** (`BhNuota`,
`AquaArt`: il Pesce lume, docile, e l'Anguilla di Linfa, che morde chi nuota; fuori dall'acqua boccheggiano), nate solo
nei liquidi. Il **Secchio di radice** raccoglie e versa; le **Branchie di muschio** (respiro ×3) e l'Amuleto d'anguilla.
Il generatore (`PassAcqua`) mette conche d'acqua nelle grotte di ogni mondo; il gene **Sorgenti** ne mette molte di più;
il gene **Sommerso** (forma, vigore 2+) copre il 90% delle colonne con un mare, con un'isola per la partenza. La scheda
di un liquido (mouse sopra) dice che cosa fa. Capitolo nell'Enciclopedia (gruppo «Le leggi dei mondi»). Prove
`--solo=acqua` (foto 137_acqua).

## 74. [x] Linfa e brace liquide (M) — fatto il 26 set 2026
Due liquidi in più con lo stesso sistema: la Linfa liquida (cura, fa crescere, luminosa) e la brace liquida
(brucia, indurisce a contatto con l'acqua in una roccia nuova). Reazioni tra liquidi.
**Pronto quando**: i liquidi si mescolano con regole chiare e utili (costruire, difendersi, coltivare).
**Fatto il 27 set 2026**: altri due liquidi con lo stesso sistema dell'acqua. La **Linfa** (luce turchese, cura chi ci sta
dentro, fa crescere il doppio più in fretta le colture entro tre tessere) e la **brace liquida** (densa e lenta: scorre un
passo su quattro; luce rossa; brucia il Germogliato e le creature, che prendono fuoco). La luce (`LightMap`) legge i
liquidi e si ricalcola quando Linfa e brace si muovono. **Reazioni** (`LiquidsData.REACTIONS`, applicate alla fine di ogni
passo): l'acqua sulla brace fa la **Pietra di brace** (tessera nuova, un blocco da costruzione: si scava col legnoferro),
la Linfa sulla brace **cristallizza** in cristallo di Linfa, l'acqua **annacqua** la Linfa. Il generatore: i fiumi del gene
Fiumi di brace sono di brace vera, i laghi del gene Laghi di Linfa hanno tre righe di Linfa sopra il cristallo rappreso,
e in ogni mondo qualche pozza di brace nel Fondo e di Linfa nelle Profondità. Il disegno dei liquidi ha profondità
(più scuro sotto), una lieve variazione tra le celle, le braci che galleggiano e un riflesso sulla superficie.
Capitolo nell'Enciclopedia con le reazioni. Prove `--solo=liquidi` (foto 138_liquidi).

## 75. [x] Vento e tempo atmosferico (M) — fatto il 26 set 2026
Vento che spinge il Germogliato, le planate, i dardi e le spore; piogge, nebbie, tempeste di cenere, bufere di brina,
secondo i geni del cielo e la stagione.
**Pronto quando**: il tempo atmosferico cambia il modo di muoversi e combattere, non solo il colore del cielo.
**Fatto il 27 set 2026**: il tempo atmosferico (`Weather`, dati in `WeatherData`). Ogni 4 minuti il mondo sceglie un tempo
secondo la stagione, i biomi e tre geni nuovi (**Piovoso**, **Ventoso**, **Nebbioso**): sereno, pioggia, temporale,
nebbia, bufera di brina (solo con i Boschi di brina), tempesta di cenere (solo con le Cenerarie). Vale in superficie,
non sotto terra né nel Giardino; l'orologio dice che tempo fa. Il **vento** spinge chi è in aria (di più chi plana:
`Player.wind`) e devia dardi e incantesimi (`Projectiles.wind`); la **pioggia** versa acqua vera nelle conche vicine
(le pellicole sottili sui tratti piani evaporano) e fa crescere l'orto di più; la **nebbia** vela il mondo e accorcia
la vista delle creature (`Behavior.fog`); nei **temporali** cadono fulmini che feriscono chi è vicino e lasciano la
**Fulgorite**; la **cenere** ferisce chi resta senza una parete dietro; la **bufera** rallenta la corsa. Gocce, fiocchi e
cenere sono particelle attorno alla visuale. Oggetti: Amuleto della tempesta (salto in aria), Mantello del vento
(planata, vento ×0,4). Capitolo nell'Enciclopedia. Prove `--solo=meteo` (foto 139_pioggia, 140_nebbia, 141_bufera).
Nello stesso giro: la mappa esplorata legge la luce come byte (il suo giro costava 6 ms in un fotogramma, ora 1,3).

## 76. [x] Gravità e mondi strani (M) — fatto il 26 set 2026
Geni di forma del mondo: gravità leggera, isole sospese nel Vuoto, mondi cavi (superficie dentro), mondi capovolti
in certe zone.
**Pronto quando**: almeno 3 forme di mondo diverse, tutte giocabili dall'inizio al Cuore.
**Fatto il 27 set 2026**: tre geni di forma che cambiano le leggi del mondo. **Lieve** (vigore 2+): la gravità è
0,55 per il Germogliato (`Player.grav_mult`: salto da 3,4 a 6,1 tessere, cadute lente che contano meno) e per tutto
ciò che cade (`Creature.grav`: creature, oggetti a terra, dardi, bombe), con montagne più alte. **Guscio** (vigore 3+,
`PassGuscio`): la superficie è dentro il mondo, sotto un tetto di roccia a 30-50 tessere dal terreno; dietro l'aria c'è
la parete, quindi è buio come in grotta, rischiarato da gocce di Linfa e baccelli appesi al tetto e dai **pozzi di
sole** (buchi nel tetto, uno sempre vicino alla partenza); sotto il tetto non piove. **Arcipelago** (vigore 2+,
`PassArcipelago`): pilastri di terra tra voragini profonde con un lago sul fondo, isole sospese sopra le voragini e una
**corrente ascensionale** in ognuna (`Gravity`: `Player.lift`, particelle che salgono) che riporta su chi ci cade.
Tutti e tre hanno il Cuore nel Fondo e la partenza libera (le prove generano i mondi e lo controllano). Capitolo
nell'Enciclopedia. Prove `--solo=gravita` (foto 142_corrente).

## 77. [x] Terra viva (M) — fatto il 26 set 2026
Radici che ricrescono e chiudono i cunicoli, terreno che si sposta, cristalli che crescono nel tempo: mondi che
cambiano mentre li si esplora.
**Pronto quando**: tornare in un mondo con questi geni dopo qualche giorno lo trova cambiato.
**Fatto il 27 set 2026**: tre geni che fanno cambiare il mondo da solo (`LivingEarth`, dati in `LivingData`).
**Radici vive**: ogni tessera scavata sotto la superficie, fino al Sottobosco, si richiude di radice dopo 4 minuti di
gioco o d'assenza; la tengono aperta una torcia vicina, una parete costruita, un liquido o il Germogliato stesso.
**Cristalli vivi**: i cristalli di Linfa che toccano l'aria (cercati una volta con `find`, 500 punti di crescita)
crescono di una tessera ogni 20 s, e mentre sei via di una ogni 10 minuti. **Frane**: humus ed erba senza appoggio
cadono, una tessera alla volta, e la terra sopra le segue (le radici degli alberi e le stazioni la tengono; una zolla
in testa fa male). Il tempo del mondo (`world_meta["terra_t"]`) e l'ora dell'ultimo passaggio (`["visto"]`): entrando
dopo un'assenza radici e cristalli recuperano il tempo perso e un avviso lo racconta («Mentre eri via (3 ore): le
radici hanno richiuso 5 tessere scavate, i cristalli sono cresciuti di 18 tessere»). `PlayerActions.dug` (segnale
nuovo) per chi vuole sapere delle tessere rotte. Capitolo nell'Enciclopedia. Prove `--solo=terra_viva` (foto 143_frana).

## 78. [x] Il tempo dei mondi (S) — fatto il 26 set 2026
Geni del tempo: giorni lunghissimi o brevissimi, eclissi, notti eterne, mondi senza sole con luce solo dalle cose vive.
**Pronto quando**: i geni del tempo cambiano davvero cosa si può fare e quando.
**Fatto il 27 set 2026**: i geni del tempo (`DayCycle`, dati in `WorldTimeData`). **Giorni brevi** (un giorno in 8
minuti) e **Giorno lento** (quasi un'ora): `DayCycle.day_len`. **Notte eterna** (vigore 3+): l'ora resta a mezzanotte,
sempre le creature della notte, più pericolo e Lumini; i giorni si contano lo stesso. **Senza sole** (vigore 3+): il
cielo non fa luce, né sole né luna (`Background.no_lights`); si vede solo ciò che brilla, ma le creature sono quelle del
giorno. Il gene **Eclissi** (che c'era già: notti lunghe, creature rare) ora spegne davvero il sole ogni mezzogiorno per
un paio di minuti (disco nero nel cielo, creature della notte, avviso) e chi si sconfigge durante l'eclissi può lasciare
la **Polvere d'eclissi**: Amuleto dell'eclissi (alone e furtività) e Lanterna della notte eterna. Nei mondi bui le
colture crescono a 0,3 tranne vicino a una torcia o alla Linfa (`DayCycle.dark_grow`). Capitolo nell'Enciclopedia.
Prove `--solo=tempo_mondi` (foto 144_eclissi, 145_senza_sole).

# Roadmap 11 «Senza fine» — il fine gioco che non finisce

## 79. [x] Vigore senza tetto (M) — fatto il 26 set 2026
La scala del vigore continua per sempre: a gradini regolari arrivano un grado nuovo di materiali (dai geni), creature
più forti con indoli nuove, nuovi posti d'innesto; il vigore non è solo «numeri più alti».
**Pronto quando**: un mondo di vigore 20 ha cose che un mondo di vigore 10 non ha.
**Fatto il 27 set 2026**: il vigore a **gradi** (`Vigor`, dati in `VigorData`): ogni 5 punti di vigore un grado, e
ogni grado porta cose nuove. **Indoli nuove** delle creature (in `FamiliesData.make`, disegno in `VariantArt`):
corazzate (grado 1: Vita quasi doppia, più lente, grigie e spinose), rigeneranti (grado 2: si rimarginano, luminose),
gemelle (grado 3: sconfitte si dividono in due piccole), voraci (grado 4: danno, corsa e vista); nascono con probabilità
7% per grado (fino al 45%) e dal quinto grado sono tutte più frequenti. Le **Schegge di vigore** cadono solo nei mondi
di grado 1+ (di più più il grado è alto; un Guardiano ne lascia 4 per grado). La **tempra** al Maglio dei Seminatori
(clic destro con l'attrezzo in mano): +8% danno e Scorza e +4 forza di piccone per livello, un **posto d'innesto** in
più ogni 3 livelli (oltre il tetto di prima), nome «+n», costo 4 × n Schegge; il Maglio tempra fino a 2 livelli per grado
del mondo in cui si trova, quindi le tempre alte vogliono i mondi più vigorosi, senza fine. Arrivando in un mondo di
grado nuovo un avviso dice cosa porta. `verifica_dati` accetta `used_for` per i materiali che servono fuori dalle
ricette. Capitolo nell'Enciclopedia (gruppo «Senza fine»). Prove `--solo=vigore` (foto 146_gemelle).

## 80. [x] Guardiani generati (L) — fatto il 26 set 2026
Guardiani composti dai geni (corpo di famiglia, taglia gigante, attacchi scelti da una libreria di schemi, fasi
secondo l'elemento), accanto a quelli scritti a mano. Ognuno si sconfigge o si cura, e lascia materiali propri.
**Pronto quando**: ogni mondo senza un Guardiano scritto a mano ne ha uno generato diverso e credibile.
**Fatto il 27 set 2026**: oltre i tre Guardiani scritti a mano (vigore 1-3) ogni mondo ha un **Guardiano generato**
dal suo seme (`GuardianGen`, dati in `GuardianGenData`; id della creatura «gg~<seme>», che `CreaturesData.get_data`
riconosce: nasce sempre uguale senza salvare niente). Il **corpo** viene da una delle specie delle famiglie, gigante
(×3), spinoso e del colore del suo **elemento**; il nome dice titolo, specie ed elemento («La Signora lince d'ardesia
della luce»); due o tre **attacchi** dalla libreria (ventaglio, scatto, carica, spara, bombarda, salto, lampo, evoca la
sua specie) scelti tra quelli che il corpo sa fare; a metà Vita la **seconda fase** cambia elemento, debolezze e
disegno e lo rende più svelto (`Guardian._phase`). Sconfitto lascia 14 **Nuclei** del suo elemento, curato 14 **Linfe
dei Guardiani**: con 6 + 4 il Maglio fa il **talismano** dell'elemento (sei talismani). Due pagine di storia; la scheda
del portale dice quale Guardiano aspetta; l'Erbario non conta i generati come specie. Su 30 semi: 30 nomi, 20 corpi,
27 combinazioni di attacchi. Capitolo nell'Enciclopedia. Prove `--solo=guardiani_generati` (foto 147_guardiano_generato).

## 81. [x] Semi leggendari e il Seme Primo (L) — fatto il 26 set 2026
Semi leggendari (combinazioni rarissime di geni stellari, catene lunghe) e l'obiettivo finale: il **Seme Primo**,
che si ottiene solo completando gran parte del Genario e dell'Albero-Madre.
**Pronto quando**: esiste un traguardo finale lontano e chiaro, e dopo di esso il gioco continua.
**Fatto il 27 set 2026**: sei **Semi leggendari** (`LegendsData`, `Legends`): un Seme è leggendario quando porta i tre
geni di una leggenda (categorie diverse, almeno uno stellare: Aurora sospesa, Arcipelago dei venti, Cuore di cristallo,
Città viva, Abisso sommerso, Notte stellata). Si riconosce dai geni (`Legends.of_genes`), quindi niente da salvare: il
Seme cambia nome, la scheda del portale lo dice, il mondo ha creature rare e Lumini doppi e il suo Cuore dona un
**oggetto unico** della leggenda e tre Linfe antiche (`Character.leggende`). Il **Seme Primo** è il traguardo lontano:
lo dona l'Albero-Madre da solo quando è sveglio del tutto, il Genario ha il 60% dei geni imparati e due leggende sono
compiute; porta il Mosaico (tutti i biomi), quattro geni stellari di categorie diverse e il vigore più alto conosciuto
più cinque. Nasce il **Primo Mondo** (`world_meta["primo"]`, dal portale come il Seme Nero), il cui Cuore dona il
**Germoglio del Primo**; poi il gioco continua (vigore senza tetto, leggende, sfide). Due pagine di storia. Capitolo
nell'Enciclopedia con le leggende (i geni mai visti restano «?») e l'avanzamento verso il Seme Primo. Prove
`--solo=leggende` (foto 148_leggende).

## 82. [ ] Sfide dei Semi (M)
Semi con prove (senza torce, a tempo, Avvizzimento che avanza, creature solo antiche…) e premi propri; record
personali nel Semenzaio.
**Pronto quando**: ci sono sempre sfide nuove da tentare anche per chi ha tutto.

# Fuori piano (rimandato dall'utente il 26 set 2026)
- Voce 6 «Rete a 2».
- Grafica: armatura sugli sprite nuovi (tunica e pantaloni con i colori del metallo, l'elmo come calotta sui capelli di
  foglie), colpo in corsa, mostri e boss con Nano Banana (stesso metodo del Germogliato).
- Rifinitura del movimento e del combattimento (all'utente sembrano già validi).
