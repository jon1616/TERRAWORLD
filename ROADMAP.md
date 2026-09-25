# TERRAWORLD — Roadmap 1: «Le fondamenta» (dal 24 set 2026)

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

## 7. [ ] Prova con Nano Banana (M) — insieme all'utente
Un personaggio con camminata, salto, colpo e un'armatura. Prompt pronti, griglia fissa su magenta, script di
importazione con riduzione a tavolozza comune. Esito: si decide come fare tutte le animazioni.

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
come una fiamma (`Boons._flicker`: cambia un poco d'intensità ogni 0,09 s; 60 fps confermati dalla prova).
