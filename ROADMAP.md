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

**Roadmap 2 «Il mondo vivo»** (prevista): biomi di superficie e sotterranei (foresta-lanterna, paludi di spore, distese
d'ambra, giardini di cristallo…), strutture e rovine dei Seminatori, l'Avvizzimento che si espande, e i **Semi che
decidono il mondo** (specie = quali biomi, vigore = difficoltà, tratti = particolarità). Poi: mondi a portale veri,
NPC, eventi, bottino con modificatori, altri boss — a Roadmap successive.
