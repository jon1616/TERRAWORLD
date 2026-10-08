# Il piano «Il generatore eccellente» (Roadmap 56-61)

Scritto l'8 ottobre 2026 su richiesta dell'utente: «analizza il generatore dei mondi e dimmi cosa faresti per renderlo
eccellente in tutti i sensi. Il cielo è da migliorare nettamente, deve essere grande come la mappa… prepara la roadmap
in maniera completa».

Le voci si numerano dopo quelle della Roadmap 55 «Il volto chiaro» (428-438): **439-474**. Se la 55 ne aggiunge altre,
si rinumera prima di cominciare. Il collegamento in `ROADMAP.md` («Dove siamo») si aggiunge quando parte la prima voce.

---

## 1. Dove siamo (misure dell'8 ott 2026, `tools/mappe.gd -- --semi 2 --da 7`)

| Che cosa | Oggi | Note |
|---|---|---|
| Misura del mondo | 3000 × 1000 tessere | `WorldGen.HEIGHT`, `World.h` |
| Tempo di generazione | ~4,4 s | Grotte 1,06 s, Minerali 0,83 s, Nidi 0,32 s, Erba 0,27 s, Strati 0,26 s |
| Passate | 55 | collaudo: 0 problemi, 0 riparazioni |
| Superficie | ~righe 250-300 | `surface_base` × altezza, colline con tre rumori; tratto piano alla partenza |
| **Cielo** | le righe sopra la superficie (~27% dell'altezza) | fascia bassa di 62 righe a 28 dalla superficie, fascia alta fino a 10 righe dal bordo; zone di 300-520 colonne; **isole di 10-20 tessere**, poche per zona; 60 colonne senza isole attorno alla partenza |
| Strati | Superficie 0, Sottobosco 22, Caverne 140, Profondità 340, Fondo 560 (profondità sotto la superficie) | confini ondulati e regolari: il mondo è «a torta» |
| Grotte | stesse macchie tonde dalla superficie al Fondo | aria sotto terra 32-33%; mancano caverne enormi, voragini, regioni |
| Minerali | ~79.000 tessere di radicite, ~90.000 di legnoferro, ~73.000 d'ambra, ~32.000 di cristalli per mondo | puntinato ovunque: trovarne non è mai una scoperta |
| Biomi del sottosuolo | ci sono (`UnderBiomesData`), ma sulla mappa si vedono poco | Sottosuolo 0 ms: dipende quasi tutto dai geni |
| **Varietà** | distanza media fra due Semi 0,67, **rumore dello stesso genoma 0,66** | due Semi diversi sono a malapena distinguibili; la regola del progetto chiede almeno il doppio del rumore |
| Bordi | il mondo finisce senza un perché | nessun mare, nessuna scogliera |

**Ciò che è già buono e va tenuto**: l'architettura a passate (un caso per passata, le fasce sui processori, la mappa dei
posti `claim`, il collaudatore, la ripetibilità per seme), la velocità, la ricchezza di luoghi scritti (rovine, cripte,
meraviglie, strutture, segreti), il cielo come insieme di biomi con le sue creature e i suoi materiali.

---

## 2. I principi (valgono per ogni voce del piano)

1. **Prima la grande scala, poi il dettaglio.** Ogni mondo si decide in tre passi: la *sagoma* (dove sono terra, cielo,
   mari, abissi), le *regioni* (biomi, caverne, continenti sospesi), il *dettaglio* (grotte piccole, vene, decorazioni).
   Oggi il generatore fa bene il terzo passo e quasi niente il primo.
2. **Ogni luogo ha un perché.** Una caverna enorme ha qualcosa dentro, un continente sospeso ha un tesoro e una
   creatura, un giacimento si annuncia con un segno. È la regola «cosa cerco, perché, l'imprevisto».
3. **Si misura, non si indovina.** Ogni voce si chiude con le mappe prima e dopo (`tools/mappe.gd`), con le misure nuove
   della Roadmap 61 e con il gruppo di prove della parte toccata. La varietà va portata ad **almeno il doppio del rumore**.
4. **Le regole del generatore restano**: un caso per passata (`GenContext.begin`), lavoro a fasce dove si guarda ogni
   tessera (`GenBands`), `is_free`/`claim` per ogni struttura, il collaudatore aggiornato a ogni forma nuova, lo stesso
   seme dà lo stesso mondo (`TestsGenRepeat`).
5. **Tutto come dati.** Stili di grotta, sagome dei mondi, forme dei continenti, giacimenti: righe in `src/data/`, non
   codice nuovo per ogni caso.
6. **Le prestazioni sono un vincolo.** Un mondo nasce in **al più 6 s** anche più alto; il salvataggio resta sotto i
   20 ms e il file sotto 1 MB.
7. **Nessun sistema resta indietro.** Ecologia (nidi, popolazioni), cielo (Chiome, creature, Fagiolo), strutture,
   pesca, rete di Linfa, Atlante e meraviglie devono funzionare anche nelle forme nuove: ogni voce dice chi tocca.

---

## 3. I numeri da raggiungere

| Misura | Oggi | Obiettivo |
|---|---:|---:|
| Altezza del mondo | 1000 | **1200** (scelta da confermare) |
| Righe di cielo sopra la superficie | ~270 | **~450** in tre fasce |
| Terra calpestabile nel cielo, per mondo | poche centinaia di celle | **≥ 15% della larghezza** coperta da continenti e isole in ogni fascia |
| Continenti sospesi | 0 | **1-2 per zona** (100-300 colonne, 20-60 righe, con l'interno da esplorare) |
| Caverne enormi (≥ 60 × 30) | quasi nessuna | **4-8 per mondo**, almeno una per strato dal Sottobosco in giù |
| Voragini che attraversano ≥ 2 strati | 0-1 | **2-4 per mondo** |
| Tessere di metallo per mondo | ~80.000 | **~35-45.000**, in giacimenti (stesso rendimento per minuto di scavo: misurato) |
| Varietà fra due Semi | 0,67 ≈ rumore | **≥ 2× il rumore** (coppia più simile su 30 Semi) |
| Sagome di mondo | 1 | **≥ 6** scelte dal genoma |
| Tempo di generazione | 4,4 s | **≤ 6 s** a 3000 × 1200 |

---

## 4. Le Roadmap

### Roadmap 56 «Il cielo grande» (voci 439-446) — per prima, perché la chiede l'utente

- [ ] **439. La misura di partenza.** Le mappe e le foto di riferimento di cinque Semi fissi (prove/generatore_prima/:
  mappa intera, cielo, sottosuolo, superficie) e i numeri di §1 scritti da `tools/mappe.gd` in un file; il gruppo di prove
  «cielo» e le foto «sfondi» come stato di partenza. Ogni voce dopo si confronta con questi.
- [ ] **440. Il mondo più alto.** `WorldGen.HEIGHT` da 1000 a 1200, con `surface_base` spostato perché le 200 righe in più
  vadano tutte al cielo (gli strati sono misurati dalla superficie: il sottosuolo resta uguale). Da controllare: luce
  (finestra della `LightMap`), mappa e minimappa, `MapReveal`, sfondi (`Background`, `GardenBackdrop`), salvataggio
  (misura, tempo, la riga `h` nei mondi salvati), il Giardino (resta 480×240), memoria e tempo di generazione.
- [ ] **441. Tre fasce di cielo.** Basso (a 25-60 righe dalla superficie, raggiungibile dal primo giorno), medio (il
  cuore del cielo: i continenti) e alto (l'aria sottile, le creature forti, il Firmamento). `SkyData` passa da due a tre
  fasce (`band`: basso/medio/alto) e le altezze diventano dati per fascia; i sei biomi del cielo si ridistribuiscono
  e se ne aggiungono due per la fascia media (con creature, materiali e gene). Le zone coprono **tutta la larghezza**:
  attorno alla partenza al posto del vuoto ci sono isole piccole e facili.
- [ ] **442. I continenti sospesi.** In ogni zona, nella fascia media, 1-2 masse grandi (100-300 colonne, 20-60 righe)
  fatte con la stessa tecnica della superficie (rumore di altezza sopra, rumore di «chiglia» sotto): un terreno del
  bioma del cielo, un cuore di roccia, **grotte dentro** (con lo stile della voce 447), vene di nimbite e folgorite,
  radici pendenti e stalattiti sotto, laghetti e cascate che cadono nel vuoto. Tra i continenti, arcipelaghi di isole
  medie e piccole (le forme di oggi: zolla, nuvola, giardino, scoglio, tempesta, stelle). `claim` per ogni massa.
- [ ] **443. Nuvole, correnti e strade verticali.** Mari di nuvole calpestabili (le tessere 52-53) lunghi decine di
  colonne nella fascia bassa e media; colonne di corrente ascensionale che collegano le fasce (`world_meta["correnti"]`,
  già lette da `Player.lift`); ponti di liane fra le isole vicine; il Fagiolo di nuvola che dalla superficie arriva
  davvero a un'isola. Obiettivo misurato: ogni continente raggiungibile dalla superficie senza ali (voce 446).
- [ ] **444. I luoghi del cielo.** Un luogo grande per zona: templi dei Seminatori sui continenti (dai progetti di
  `ProjectsData`), osservatori più grandi con lo scrigno del cielo, nidi giganti dei Signori del cielo, un relitto o
  un giardino pensile per la firma del mondo. Usano `PlacesData` e `PassStrutture` (strutture come dati) e il cielo entra
  nell'Atlante (meraviglie del cielo).
- [ ] **445. La vita e la luce del cielo.** Creature per fascia (le forti in alto), nascite sui continenti come in
  superficie (`Fauna`, `SkyData.pool_of`), nidi delle famiglie del cielo sui continenti (`PassNidi`), pericolo per fascia
  (`DangerData`); lo sfondo che cambia con la quota (nuvole sotto di te salendo, `SkyClouds`, `Background`) e la luce del
  cielo aperto sui continenti (`LightMap`).
- [ ] **446. La misura del cielo.** `tools/cielo.gd` esteso: celle calpestabili per fascia, grandezza delle isole,
  continenti raggiungibili (una ricerca di percorso con il salto, le correnti e le liane), tempo per arrivare in alto
  con il corredo del primo giorno; mappe prima e dopo; gruppo di prove «cielo» aggiornato (`TestsSky`); resoconto.

### Roadmap 57 «Le profondità vere» (voci 447-453)

- [ ] **447. Uno stile di grotta per strato.** `CaveStylesData`: ogni strato ha il suo modo di scavare, come dati
  (rumore, soglia, direzione, larghezza): gallerie lunghe e intrecciate di radici nel Sottobosco, sale e cunicoli nelle
  Caverne d'ardesia, pozzi verticali e cenge nelle Profondità della Linfa, vuoti enormi e pilastri nel Fondo. `PassGrotte`
  legge lo stile della cella (resta a fasce). I geni «grotte» scelgono o mescolano gli stili.
- [ ] **448. Le grandi caverne e le voragini.** Nuova passata `PassCaverne`: 4-8 caverne enormi per mondo (almeno una
  per strato), con un fondo, un lago o una struttura dentro, e 2-4 voragini che tagliano due o tre strati (con cenge per
  scendere e risalire). Collaudo: niente caverne che bucano la superficie dove c'è la partenza.
- [ ] **449. Le regioni sotterranee.** I biomi del sottosuolo (`UnderBiomesData`) diventano regioni grandi come una zona
  del cielo (200-500 colonne), riconoscibili sulla mappa: fungaie giganti, ghiacciai di Linfa, giungle di radici, laghi
  sotterranei, deserti di vetro. Ogni mondo ne ha almeno tre, scelte dal genoma e dai biomi di superficie sopra.
- [ ] **450. Confini vivi.** Gli strati smettono di essere fasce ondulate: lingue e sacche di uno strato dentro l'altro,
  una fascia di passaggio dove le due rocce si mescolano, colonne di roccia profonda che salgono. `StrataData.offset`
  diventa un campo a due dimensioni.
- [ ] **451. Le acque profonde.** Laghi sotterranei grandi, falde che riempiono le grotte basse, cascate sotterranee,
  sacche di Linfa e di brace al loro strato; tutti fermi alla nascita (i liquidi si muovono solo vicino al Germogliato,
  `Liquids`) e pescabili (`WaterBody`, voce di pesca nei laghi profondi).
- [ ] **452. Le strade del sottosuolo.** Una rete di gallerie che garantisce sempre una via dalla superficie al Fondo
  (anche lunga), e scorciatoie da trovare (pozzi, radici viandanti). Misura: la connettività (voce 469).
- [ ] **453. La misura del sottosuolo.** Mappe prima e dopo, aria per strato, caverne e voragini contate, regioni
  visibili, gruppi di prove «grotte», «terre», «liquidi», «acqua»; resoconto.

### Roadmap 58 «I tesori della roccia» (voci 454-457)

- [ ] **454. Giacimenti invece di puntini.** Vene meno numerose e più grandi, a filoni che si seguono, legate a strato,
  roccia e regione (`TileDefs.ORES`, `PassMinerali`: campi nuovi «clusters», «filone»). Circa metà delle tessere di
  oggi, ma lo stesso rendimento per minuto di scavo per chi sa dove cercare (misurato con un minatore simulato).
- [ ] **455. I segni dei giacimenti.** Affioramenti in superficie sopra i giacimenti grandi, cristalli e piante che
  crescono solo lì, una sfumatura nelle pareti di fondo vicino a una vena madre: si impara a leggere il mondo. Una riga
  in `ConsigliData` e nell'Enciclopedia.
- [ ] **456. Gemme e rarità al posto giusto.** Gemme nei geodi e nelle caverne di cristallo, i metalli rari (della spina
  e del dopo) solo nelle loro regioni e strati, mai sparsi.
- [ ] **457. Il bilancio dei tesori.** `tools/densita.gd` e `tools/percorso.gd`: il tempo per arrivare a ogni grado di
  metallo non deve allungarsi (o di poco, per scelta); gli scrigni e le casse dei biomi restano raggiungibili.

### Roadmap 59 «Mondi che non si somigliano» (voci 458-462)

- [ ] **458. Le sagome dei mondi.** `WorldShapesData`: almeno sei sagome scelte dal genoma (dai geni di forma), ognuna
  una ricetta per la grande scala: *continente* (oggi), *arcipelago* (isole di terra su un mare), *canyon* (una gola
  enorme che taglia il mondo), *guscio* (superficie sottile su un vuoto immenso), *terrazze* (gradoni), *sprofondato* (la
  superficie bassa e un cielo altissimo), *pilastri* (colonne dalla terra al cielo). Applicate da `PassTerreno` e da una
  passata nuova subito dopo.
- [ ] **459. I geni di forma che cambiano la forma.** I geni di forma, grotte e sottosuolo (`GenesData`) rivisti perché
  cambino la grande scala (sagoma, stile di grotta, regioni), non solo il dettaglio; combinazioni con un nome (`combo`).
- [ ] **460. I bordi del mondo.** Mari ai due lati (con creature, pesci e un relitto), oppure scogliere, muri di radice
  o il vuoto, secondo la sagoma. Il mondo finisce con un perché.
- [ ] **461. Il carattere dei biomi di superficie.** Larghezze variabili (un bioma enorme, uno minuscolo), ordine non
  fisso, passaggi sfumati fra due biomi (la terra e la vegetazione si mescolano per 20-40 colonne), micro-biomi (radure,
  boschetti, pozze) dentro i grandi.
- [ ] **462. La misura della varietà.** `tools/mappe.gd -- --caso` su 30 Semi: la coppia più simile ad almeno il doppio
  del rumore; il foglio delle sagome affiancate; resoconto.

### Roadmap 60 «La superficie da cartolina» (voci 463-467)

- [ ] **463. Il rilievo.** Montagne vere con pareti e cenge, valli, sporgenze e archi di roccia, una semplice erosione che
  addolcisce i pendii; la partenza resta su un tratto sicuro (il collaudatore lo controlla già).
- [ ] **464. I punti di riferimento.** Cose che si vedono da lontano e dicono «lì c'è qualcosa»: alberi giganti, guglie,
  crateri, rovine in cima a un colle. Una per bioma almeno; entrano nella mappa come segni.
- [ ] **465. Gli ingressi.** Gli ingressi delle grotte leggibili (caverne aperte sul fianco, doline, pozzi con le corde),
  uno ogni ~200 colonne, così si scende senza scavare per forza.
- [ ] **466. Le acque di superficie.** Laghi nelle valli, fiumi brevi, cascate dalle montagne (`PassAcqua`, `PassStagni`).
- [ ] **467. La misura della superficie.** Le foto «sfondi» e «volto» prima e dopo (`tools/confronto_volto.py`), le mappe,
  il gruppo «biomi»; resoconto.

### Roadmap 61 «Il collaudo del generatore» (voci 468-474; le misure servono già dalla 56)

- [ ] **468. Le misure nuove.** In `tools/mappe.gd`: aria e terra per strato e per fascia di cielo, caverne grandi,
  voragini, regioni, giacimenti, luoghi per 1000 colonne, varietà per parte (già c'è).
- [ ] **469. La connettività.** Una ricerca di percorso sul mondo generato (con salto, corde, correnti, senza scavare):
  quanta parte del sottosuolo e del cielo è raggiungibile, e quanta strada serve per arrivare a ogni risorsa e luogo.
- [ ] **470. Le prestazioni.** A 3000 × 1200 il mondo nasce in ≤ 6 s; le passate più lente (oggi Grotte e Minerali) a fasce
  e misurate; `WorldPregen` ancora pronto prima del viaggio.
- [ ] **471. Le prove riallineate.** Le prove cercano i loro posti (TestKit), non contano su coordinate o su forme fisse;
  `TestsGenRepeat` e l'impronta (`tools/impronta.gd`) aggiornate.
- [ ] **472. L'Atlante e le schede.** Le forme nuove (continenti, caverne, regioni, sagome) nella scheda del portale
  (`PortalInfo`), nell'Atlante e nell'Enciclopedia: il giocatore sa che mondo sta per visitare.
- [ ] **473. Il giro completo.** `tools/prove.sh tutto`, giocatori simulati (`tools/percorso.gd`), densità e durata.
- [ ] **474. Il resoconto del piano** in `ROADMAP.md`, con le mappe prima e dopo.

---

## 5. Scelte da confermare con l'utente prima di partire

1. **Altezza del mondo 1200** (cielo più grande, ~20% di tessere in più) **oppure 1000** con il cielo che prende spazio
   alla superficie (meno sottosuolo). Consiglio: 1200.
2. **Minerali dimezzati ma in giacimenti**, con lo stesso rendimento per chi sa cercare: va bene?
3. **Mari ai bordi**: sì in quasi tutte le sagome, o solo in alcune?
4. **I mondi salvati prima** restano com'erano (i salvataggi in sviluppo non si migrano, scelta del 26 set): un mondo
   vecchio non avrà il cielo nuovo. Il Giardino non cambia.
5. **L'ordine**: cielo (56) → profondità (57) → tesori (58) → varietà (59) → superficie (60), con la 61 fatta un pezzo
   alla volta insieme alle altre.

## 6. Rischi e come si evitano

- **Le prove cambiano luogo**: un mondo più alto e di forma diversa sposta i posti delle prove. Si sistemano voce per
  voce, con le prove che cercano il loro posto (lezione del 25 set: «le prove non dipendono da un punto preciso»).
- **Le prestazioni**: più tessere e passate nuove; si misura ogni voce e si lavora a fasce.
- **Gli equilibri**: meno minerali o più strada per raggiungerli cambiano i tempi della partita; si misura con i
  giocatori simulati prima di chiudere ogni Roadmap.
- **Lavorare insieme a un altro agente**: il generatore tocca le prove e il mondo di prova condiviso
  (`user://prove_salvataggi`); le prove si lanciano solo quando l'altro agente non sta provando.
