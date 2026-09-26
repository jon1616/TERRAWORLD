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
- **Prossimo passo**: voce 41 (versione dei salvataggi), poi la Roadmap 5 in ordine. L'utente dà la direzione e lascia
  a Claude ordine e tecnica; chiede sempre un resoconto alla fine di un lavoro lungo.
- **Contenuti oggi**: 355 oggetti, 239 ricette, 28 stazioni, 35 creature, 5 biomi di superficie, 5 strati, 8
  Guardiani/Custodi, 5 specie di Seme e 10 tratti di mondo; `tools/verifica_dati.gd` dà 0 errori e 0 avvisi.

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

## 47. [ ] L'innesto dei semi (L)
Al **Banco dell'Innestatrice** (stazione nuova) si uniscono due Semi, più eventuali Fiale di gene: nasce un Seme
figlio. Regole: per ogni categoria si eredita da uno dei due genitori secondo la dominanza; una Fiala fissa quel gene;
il vigore è quello del genitore più forte più uno; costa Linfa antica (dai Cuori). **Mutazioni**: una piccola
probabilità (più alta con certi geni e certe Essenze) di un gene che nessuno dei genitori aveva, anche uno che non si
trova in nessun altro modo. Prima di innestare si vedono le probabilità, ma solo per i geni già imparati.
**Pronto quando**: si può progettare un mondo («voglio grotte ad alveare e fiumi di brace») e ottenerlo con gli
innesti; le mutazioni si vedono e finiscono nel Genario.

## 48. [ ] Geni rari e mutazioni (M)
Il secondo giro di geni (fino a ~45): geni antichi e stellari, geni che si ottengono **solo** per mutazione o solo
incrociando due geni precisi (combinazioni segrete, scoperte giocando e poi scritte nel Genario), geni «malati»
dell'Avvizzimento (mondi più duri, materiali unici). Semi selvatici che mutano da soli nel giardino se lasciati a
lungo.
**Pronto quando**: completare il Genario richiede incroci pensati; almeno 8 geni si ottengono solo per mutazione o
combinazione.

# Roadmap 6 «La materia viva» — l'equipaggiamento che si genera

## 49. [ ] Proprietà dei materiali (L)
`MaterialsData`: ogni materiale (metalli, legni, gemme, parti di creatura) ha le sue proprietà — durezza, peso,
conduzione della Linfa, elemento, risonanza, grado. I metalli di oggi (famiglie `METALS` × `GEAR`) migrano qui: le loro
statistiche escono dalle proprietà invece che da tabelle scritte a mano, con valori vicini a quelli di oggi.
**Pronto quando**: tutti gli attrezzi di metallo di oggi nascono dalle proprietà, con statistiche entro il 10% di
quelle attuali; `verifica_dati` controlla la progressione.

## 50. [ ] Forme e fabbricazione componibile (L)
`FormsData`: le forme (lama corta, lama lunga, lancia, martello, falce, frusta, arco, balestra, bastone, piccone,
ascia, trivella, elmo, corazza…) con il loro modo di colpire e come pesano le proprietà del materiale. Un attrezzo =
forma × materiale principale × materiale del manico/della fascia: statistiche, nome («Falce di legnoferro con fascia
di seta») e icona (`ItemIcons.make` con forma e tavolozza) nascono da soli. Le istanze portano i componenti nei `dati`.
Le forme nuove richiedono nuovi modi di colpire in `Combat` (affondo della lancia, giro del martello, frusta).
**Pronto quando**: con 8 materiali e 14 forme il gioco offre centinaia di attrezzi diversi e confrontabili, tutti con
nome, icona e scheda in Esamina.

## 51. [ ] Elementi e reazioni (M)
Sei elementi (brace, gelo, spora, Linfa, Vuoto, luce) portati dai materiali e dalle Essenze: stati sulle creature
(brucia, rallenta, avvelena, prosciuga, acceca…), debolezze e resistenze delle famiglie di creature, **reazioni** tra
elementi (gelo + brace = vapore che stordisce, spora + brace = scoppio…).
**Pronto quando**: scegliere l'elemento giusto cambia davvero lo scontro con almeno metà delle creature; l'Erbario
mostra le debolezze scoperte.

## 52. [ ] Leghe (M)
Al Baccello ardente due metalli si fondono in una **lega** con proprietà miste (e a volte una proprietà che nessuno dei
due aveva): i metalli di N mondi danno N×N leghe. Nomi delle leghe generati, pochi nomi speciali scritti a mano per le
combinazioni migliori.
**Pronto quando**: esistono leghe migliori dei loro metalli per certi usi, e nessuna è la migliore in tutto.

## 53. [ ] Materiali dai geni (M)
Ogni gene di minerale e di fauna porta **materiali propri** con proprietà scritte nei dati (non generate a caso): con la
Roadmap 5 i materiali passano da una decina a 30-40. Grazie alle forme ognuno dà subito tutta la sua serie di attrezzi.
**Pronto quando**: un materiale nuovo si aggiunge con una riga di dati e compare con tutti i suoi attrezzi, le ricette
e le icone.

## 54. [ ] Innesti e qualità (M)
Gli innesti dell'universo: posti d'innesto per attrezzo secondo la qualità di fabbricazione (che dipende dalla stazione,
dai materiali e da un po' di fortuna); Essenze e parti di creatura come innesti; togliere un innesto costa. I tratti
di oggi diventano innesti.
**Pronto quando**: due attrezzi uguali possono essere molto diversi, e inseguire l'attrezzo perfetto è un obiettivo
lungo.

# Roadmap 7 «L'ecologia» — la fauna che vive

## 55. [ ] Creature componibili (L)
`FamiliesData`: una **famiglia** (corpo, disegno di base, modo di muoversi) × **elemento** × **indole**
(comportamento) × **taglia** × varianti di colore = molte creature da una famiglia. Il disegno varia con tavolozza,
misura e piccoli pezzi aggiunti dal codice (corna, spine, bagliore). Le 27 creature di oggi diventano famiglie e
varianti.
**Pronto quando**: una famiglia nuova si scrive una volta e dà almeno 6 creature diverse nei mondi giusti.

## 56. [ ] Famiglie per gene (M)
I geni di fauna decidono quali famiglie e quali varianti vivono in un mondo; 10-12 famiglie nuove (acquatiche pronte
per la Roadmap 10, volanti, scavatrici, colonie). Un **Custode per bioma** (Grande Cervo di brina, Madre delle
salamandre…) con la sua tana.
**Pronto quando**: due mondi con geni di fauna diversi hanno faune diverse per davvero.

## 57. [ ] La catena alimentare (L)
Le creature hanno bisogni: predatori che cacciano prede, erbivori che brucano piante e colture, spazzini che mangiano ciò
che resta, creature che si combattono tra loro. Popolazioni per zona (che calano se le si caccia troppo e crescono se
le si lascia), comportamenti visibili (fuga, branco, agguato).
**Pronto quando**: fermandosi a guardare si vede un mondo che vive anche senza il giocatore; le prove misurano che le
popolazioni restano in equilibrio.

## 58. [ ] Nidi, tane e migrazioni (M)
Nidi e tane da trovare (da cui nascono le creature di una zona: distruggerli la svuota, proteggerli la arricchisce),
migrazioni di branchi al cambio del giorno e (con la voce 66) delle stagioni.
**Pronto quando**: le creature non compaiono più «dal nulla» fuori dalla visuale ma dai loro nidi (dove il gene lo
prevede).

## 59. [ ] Addomesticare (L)
Calmare una creatura (cibo giusto, stordirla senza ucciderla, Essenze) e portarla nel Giardino in un **Vasetto**:
recinti e stalle, creature che producono materiali (seta, gelatina, latte di Linfa, piume), compagni e cavalcature da
qualunque famiglia adatta. I compagni e gli alleati di oggi entrano nel sistema; livelli dei compagni.
**Pronto quando**: si possono tenere almeno 10 famiglie diverse nel Giardino, ognuna utile a qualcosa.

## 60. [ ] Allevamento (M)
Due creature addomesticate danno un piccolo con i geni di entrambe (**lo stesso motore della voce 47**): colori,
taglia, elemento, doni. Varianti rare che si ottengono solo allevando.
**Pronto quando**: allevare è una seconda collezione lunga, con almeno 6 varianti ottenibili solo così.

## 61. [ ] L'Erbario vivo (S)
Ogni famiglia con le sue varianti, dove vive, cosa mangia, debolezze, nidi, prodotti, vista/sconfitta/addomesticata/
allevata; percentuali per famiglia e totale.
**Pronto quando**: l'Erbario dice sempre cosa manca e dove cercarlo (a grandi linee: «nei mondi con il gene…»).

# Roadmap 8 «Il risveglio dell'Albero-Madre» — il motivo

## 62. [ ] Il Giardino vero (L)
Il mondo casa diventa **il Giardino**: un mondo più piccolo sospeso nel Vuoto attorno all'Albero-Madre addormentato,
con le Aiuole, lo spazio per la base, i recinti e la serra. I personaggi e i mondi di oggi migrano: il mondo di partenza
diventa il primo mondo nato da Seme (da decidere con l'utente quando si arriva qui).
**Pronto quando**: una partita nuova comincia nel Giardino, e il primo Seme porta al primo mondo.

## 63. [ ] Gli stadi dell'Albero-Madre (L)
10-15 stadi di crescita; ognuno chiede **offerte** (Linfa antica dei Cuori, geni, creature, reliquie, materiali di
mondi con certi geni) e sblocca: Aiuole, stazioni, categorie di geni innestabili, abitanti, poteri. L'Albero si vede
crescere nel Giardino (disegno a stadi).
**Pronto quando**: dal primo all'ultimo stadio c'è sempre una richiesta chiara e un modo per capire dove cercare.

## 64. [ ] I poteri del Germogliato (M)
Poteri permanenti dagli stadi dell'Albero (vista della Linfa per vedere vene e geni nascosti, respiro nell'acqua,
radici-ponte, salto delle spore, passo nel Vuoto…). Certi luoghi e certi geni si raggiungono solo con un potere:
l'esplorazione si apre a strati, come in un metroidvania.
**Pronto quando**: almeno 6 poteri, ognuno apre luoghi che prima non si potevano raggiungere.

## 65. [ ] Abitanti con i mestieri (L)
Gli abitanti dell'universo: la **Vecchia Radice** (guida, racconta), il **Mercante di Semi**, l'**Innestatrice**,
il **Cartografo dei Seminatori**, il **Mandriano** (creature), più quelli di oggi. Arrivano con gli stadi
dell'Albero; affetto (sconti, doni), una casa per ciascuno, richieste personali.
**Pronto quando**: ogni abitante ha un motivo per esserci e almeno una catena di richieste.

## 66. [ ] Le stagioni (M)
Le stagioni in ogni mondo (durata da provare): cambiano creature, colture, eventi, migrazioni; geni, creature e boss
che esistono solo in una stagione.
**Pronto quando**: tornare in un mondo in un'altra stagione dà cose nuove da trovare.

## 67. [ ] La bacheca delle richieste (M)
Richieste generate senza fine, costruite dal registro dei geni e dei mondi: «portami tre Palchi di brina da un mondo
con notti lunghe», «trova la firma di un mondo con grotte ad alveare», «alleva una salamandra bianca». Ricompense:
Semi rari, Fiale di gene, Linfa antica, oggetti unici. Le richieste puntano sempre a qualcosa che il giocatore **può**
fare con ciò che ha già imparato (o quasi).
**Pronto quando**: in qualunque momento della partita ci sono almeno tre richieste sensate aperte.

# Roadmap 9 «Il mistero dei Seminatori» — il racconto sopra il motore

## 68. [ ] La lingua dei Seminatori (M)
Le scritte dei Seminatori sono glifi: ogni tavoletta trovata insegna parole, il Cartografo aiuta a decifrare. Le
scritte sui muri delle rovine si leggono a poco a poco: una progressione di **conoscenza**, non di equipaggiamento.
**Pronto quando**: una stessa scritta, riletta più avanti nella partita, dice di più (e indica qualcosa da cercare).

## 69. [ ] Le catene di ricerca tra i mondi (L)
Catene generate e scritte: un indizio in un mondo indica un gene o una combinazione di geni; il mondo che ne nasce ha
una rovina sigillata; dentro c'è la chiave o la mappa per la tappa dopo. Alcune catene lunghe scritte a mano (la
storia), molte brevi generate (i segreti).
**Pronto quando**: esiste la prima catena lunga completa (5+ tappe in mondi diversi) e le brevi non finiscono mai.

## 70. [ ] Luoghi scritti a mano (L)
Luoghi progettati come modelli (tempio sommerso, città sepolta, biblioteca di radici, serra dei Seminatori,
osservatorio, alveare colossale…) che il generatore piazza solo nei mondi con i geni giusti, adattandoli al terreno.
Sono la parte «a mano» che dà sapore a quella generata. Almeno 8 per cominciare.
**Pronto quando**: trovare un luogo scritto a mano è un evento; ognuno ha un premio e un pezzo di storia.

## 71. [ ] Enigmi e meccanismi (M)
Meccanismi dei Seminatori (leve di radice, specchi che portano la luce, canali di Linfa da aprire, piastre, porte a
glifi) nei luoghi della voce 70 e nelle rovine sigillate.
**Pronto quando**: almeno 6 tipi di meccanismo combinabili; i luoghi grandi hanno un enigma ciascuno.

## 72. [ ] Il Seme Nero (L)
L'origine dell'Avvizzimento e il grande arco del racconto: indizi in tutte le catene, geni malati, un luogo finale e un
Guardiano che si può sconfiggere o curare, come tutti. Non chiude il gioco: apre il fine gioco (Roadmap 11).
**Pronto quando**: la storia principale si può giocare dall'inizio alla fine.

# Roadmap 10 «Le leggi dei mondi» — meccaniche fisiche come geni

Ogni legge è un **gene** (raro, spesso di vigore alto): i mondi non diventano solo più forti ma **diversi da giocare**.

## 73. [ ] L'acqua (L)
Liquidi che scorrono a tessere (simulazione a blocchi, solo vicino alla visuale), nuoto, respiro, creature acquatiche
(famiglie della voce 56), laghi e grotte allagate; gene «Sommerso» (mondi quasi tutti d'acqua).
**Pronto quando**: un mondo sommerso si gioca in modo diverso da tutti gli altri, e resta a 60 fotogrammi al secondo.

## 74. [ ] Linfa e brace liquide (M)
Due liquidi in più con lo stesso sistema: la Linfa liquida (cura, fa crescere, luminosa) e la brace liquida
(brucia, indurisce a contatto con l'acqua in una roccia nuova). Reazioni tra liquidi.
**Pronto quando**: i liquidi si mescolano con regole chiare e utili (costruire, difendersi, coltivare).

## 75. [ ] Vento e tempo atmosferico (M)
Vento che spinge il Germogliato, le planate, i dardi e le spore; piogge, nebbie, tempeste di cenere, bufere di brina,
secondo i geni del cielo e la stagione.
**Pronto quando**: il tempo atmosferico cambia il modo di muoversi e combattere, non solo il colore del cielo.

## 76. [ ] Gravità e mondi strani (M)
Geni di forma del mondo: gravità leggera, isole sospese nel Vuoto, mondi cavi (superficie dentro), mondi capovolti
in certe zone.
**Pronto quando**: almeno 3 forme di mondo diverse, tutte giocabili dall'inizio al Cuore.

## 77. [ ] Terra viva (M)
Radici che ricrescono e chiudono i cunicoli, terreno che si sposta, cristalli che crescono nel tempo: mondi che
cambiano mentre li si esplora.
**Pronto quando**: tornare in un mondo con questi geni dopo qualche giorno lo trova cambiato.

## 78. [ ] Il tempo dei mondi (S)
Geni del tempo: giorni lunghissimi o brevissimi, eclissi, notti eterne, mondi senza sole con luce solo dalle cose vive.
**Pronto quando**: i geni del tempo cambiano davvero cosa si può fare e quando.

# Roadmap 11 «Senza fine» — il fine gioco che non finisce

## 79. [ ] Vigore senza tetto (M)
La scala del vigore continua per sempre: a gradini regolari arrivano un grado nuovo di materiali (dai geni), creature
più forti con indoli nuove, nuovi posti d'innesto; il vigore non è solo «numeri più alti».
**Pronto quando**: un mondo di vigore 20 ha cose che un mondo di vigore 10 non ha.

## 80. [ ] Guardiani generati (L)
Guardiani composti dai geni (corpo di famiglia, taglia gigante, attacchi scelti da una libreria di schemi, fasi
secondo l'elemento), accanto a quelli scritti a mano. Ognuno si sconfigge o si cura, e lascia materiali propri.
**Pronto quando**: ogni mondo senza un Guardiano scritto a mano ne ha uno generato diverso e credibile.

## 81. [ ] Semi leggendari e il Seme Primo (L)
Semi leggendari (combinazioni rarissime di geni stellari, catene lunghe) e l'obiettivo finale: il **Seme Primo**,
che si ottiene solo completando gran parte del Genario e dell'Albero-Madre.
**Pronto quando**: esiste un traguardo finale lontano e chiaro, e dopo di esso il gioco continua.

## 82. [ ] Sfide dei Semi (M)
Semi con prove (senza torce, a tempo, Avvizzimento che avanza, creature solo antiche…) e premi propri; record
personali nel Semenzaio.
**Pronto quando**: ci sono sempre sfide nuove da tentare anche per chi ha tutto.

# Fuori piano (rimandato dall'utente il 26 set 2026)
- Voce 6 «Rete a 2».
- Grafica: armatura sugli sprite nuovi (tunica e pantaloni con i colori del metallo, l'elmo come calotta sui capelli di
  foglie), colpo in corsa, mostri e boss con Nano Banana (stesso metodo del Germogliato).
- Rifinitura del movimento e del combattimento (all'utente sembrano già validi).
