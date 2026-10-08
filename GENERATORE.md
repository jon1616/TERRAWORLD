# Il piano «Il generatore eccellente» (Roadmap 56-61)

Scritto l'8 ottobre 2026 su richiesta dell'utente: «analizza il generatore dei mondi e dimmi cosa faresti per renderlo
eccellente in tutti i sensi. Il cielo è da migliorare nettamente, deve essere grande come la mappa… prepara la roadmap
in maniera completa», poi «metti a punto la roadmap in attesa dell'altro agente».

Le voci si numerano dopo quelle della Roadmap 55 «Il volto chiaro» (428-438): **439-478**. Se la 55 ne aggiunge altre,
si rinumera prima di cominciare. Il collegamento in `ROADMAP.md` («Dove siamo») si aggiunge quando parte la prima voce.
**Si parte quando l'agente della Roadmap 55 ha finito**: il generatore cambia il mondo di prova che tutte le prove usano
(`user://prove_salvataggi`).

---

## 1. Dove siamo (misure dell'8 ott 2026)

Misure con `tools/mappe.gd -- --semi 2 --da 7` (attenzione: lo strumento usa **vigore 5** di base, voce 439) e lettura
del codice di tutte le passate.

| Che cosa | Oggi | Dove |
|---|---|---|
| Misura del mondo | 3000 × 1000 | `WorldGen.HEIGHT` (`world_gen.gd:7`), `World.setup` |
| Tempo di generazione | ~4,4 s | Grotte 1,06 s, Minerali 0,83 s, Nidi 0,32 s, Erba 0,27 s, Strati 0,26 s |
| Passate | 55 | collaudo: 0 problemi, 0 riparazioni |
| Superficie | 270 ± 55 ± 12 ± 2 | `surface_base` 0,27 (frazione dell'altezza, `gen_context.gd:10`), `hills` 55; geni additivi (altopiano −0,05, conca +0,035, cieli_alti +0,045) |
| Biomi di superficie | tratti di 220-440 colonne, ordine solo a caso pesato, confini netti | `PassBiomi`: 320 colonne della partenza sovrascritte, `_ensure_all` che divide i tratti (biomi da ~110) |
| **Cielo** | zone di 300-520 colonne; fascia bassa di 62 righe a 28 dalla superficie più alta, alta da riga 10 allo split (~100 righe) | `SkyData.make_zones`, `PassCielo._band`: **isole con `half` 7-16** in un posto di 22 righe, quota uniforme; 60 colonne vuote alla partenza |
| Strade del cielo | radici-passerelle dal 60% delle isole basse, ponti fra isole vicine, 1-3 correnti per zona | `PassCielo._roots/_bridges/_currents`; Fagiolo di nuvola alto **40 tessere** (`BEAN_H`) |
| Strati | top 0/22/140/340/560 sotto la superficie | `StrataData`: `offset` solo 1D, ±13 |
| Grotte | un solo gradiente `f = dep/300` dalla superficie al Fondo: le stesse macchie ovunque | `PassGrotte`: gallerie, caverne, grandi caverne oltre 180; nessuno stile per strato |
| Minerali (a vigore 5) | ~79.000 radicite, ~90.000 legnoferro, ~73.000 ambra, ~32.000 cristalli | `PassMinerali`: vene a rumore su strati interi, la prima vena valida vince; `richer` abbassa le soglie col vigore |
| Biomi del sottosuolo | **esistono solo con un gene**, macchie di 20-80 colonne senza `claim` | `PassSottosuolo`, `UnderBiomesData`, `UnderBuilders` |
| Acqua | conche piccole (≤ 600 celle) nelle grotte, mare solo col gene Sommerso, stagni di superficie | `PassAcqua`, `PassStagni` |
| **Varietà** | distanza fra due Semi 0,67 contro un rumore di 0,66 | `tools/mappe.gd`: il rumore è **un solo** confronto; senza `--caso` il genoma è vuoto |
| Bordi | il mondo finisce senza un perché | — |

**Guasti trovati leggendo il codice** (si riparano nella voce 440):
1. Il gene **«Mondo cavo»** fa il contrario di ciò che promette: `room` +2 e `big` +3 sono soglie che si sommano, quindi
   caverne e grandi caverne diventano impossibili (`pass_grotte.gd:46,49`).
2. **L'Arcipelago corre prima dei Biomi**: il rimodellamento dei biomi schiaccia le voragini (in palude da 34-48 a
   ~10-15 righe) e le correnti restano sulla superficie di prima.
3. **`PassSottosuolo` non fa `claim`**: le passate dopo possono sovrascriverne i luoghi.
4. **`tools/mappe.gd` misura a vigore 5**: i minerali risultano gonfiati; e il rumore viene da un solo confronto.
5. Il **Guscio** riempie di pietra tutto il cielo sopra il tetto: con 200 righe in più sarebbe il 20% di pietra in più.

**Cosa è già buono e si tiene**: l'architettura a passate (un caso per passata, le fasce sui processori, `claim`, il
collaudatore, la ripetibilità per seme), la velocità, i luoghi scritti (rovine, cripte, meraviglie, strutture, segreti),
il cielo come insieme di biomi con creature (30 specie), materiali e geni.

---

## 2. I principi (valgono per ogni voce)

1. **Prima la grande scala, poi il dettaglio.** Ogni mondo si decide in tre passi: la *sagoma* (terra, cielo, mari,
   abissi), le *regioni* (biomi, caverne, continenti sospesi), il *dettaglio* (grotte piccole, vene, decorazioni).
2. **Ogni luogo ha un perché**: una caverna enorme ha qualcosa dentro, un continente ha un tesoro e una creatura, un
   giacimento si annuncia con un segno («cosa cerco, perché, l'imprevisto»).
3. **Si misura, non si indovina**: ogni voce si chiude con le mappe prima e dopo dei cinque Semi fissi (voce 439), le
   misure della Roadmap 61 e il gruppo di prove della parte toccata. Varietà ad **almeno il doppio del rumore**.
4. **Le regole del generatore restano**: `GenContext.begin` per passata, `GenBands` dove si guarda ogni tessera,
   `is_free`/`claim` per ogni struttura (anche i continenti, le caverne, le regioni), collaudatore aggiornato a ogni forma
   nuova, `TestsGenRepeat` e `tools/impronta.gd` (rifatta la base a ogni voce che cambia il mondo, di proposito).
5. **Tutto come dati**: stili di grotta, sagome, continenti, giacimenti sono righe in `src/data/`.
6. **Prestazioni**: ≤ 6 s a 3000 × 1200; salvataggio ≤ 20 ms; file ≤ 1 MB; memoria del mondo ~32 MB (oggi 27).
7. **Nessun sistema resta indietro**: ogni voce elenca chi tocca (ecologia, Chiome, fauna, Signori, Atlante, pesca,
   rete, filo, obiettivi, Enciclopedia).
8. **La luce del cielo**: oggi ogni cella d'aria **senza parete** prende la luce del cielo (`light_map.gd:266-271`). Le
   grotte dei continenti sospesi e lo spazio sotto di loro vanno fatti con le pareti di fondo, o al buio sarebbe giorno.

---

## 3. I numeri da raggiungere

| Misura | Oggi | Obiettivo |
|---|---:|---:|
| Altezza del mondo | 1000 | **1200** (scelta dell'utente) |
| Righe di cielo sopra la superficie | ~270 | **~470** in tre fasce: basso ~90, medio ~200, alto ~150 |
| Terra calpestabile nel cielo | isole di 15-30 colonne | **≥ 15% della larghezza** coperta in ogni fascia |
| Continenti sospesi | 0 | **1-2 per zona** (100-300 colonne, 20-60 righe, con l'interno da esplorare) |
| Caverne enormi (≥ 60 × 30) | quasi nessuna | **4-8 per mondo**, almeno una per strato dal Sottobosco in giù |
| Voragini che attraversano ≥ 2 strati | 0 (solo col gene) | **2-4 per mondo** |
| Regioni sotterranee visibili | 0 senza gene | **≥ 3 per mondo**, 200-500 colonne |
| Metallo per mondo (a vigore 1) | da rimisurare (voce 439) | **circa la metà**, in giacimenti, stesso rendimento per minuto di scavo per chi sa cercare |
| Varietà fra due Semi | 0,67 ≈ rumore | **≥ 2× il rumore** (coppia più simile su 30 Semi, rumore su 10 coppie) |
| Sagome di mondo | 1 (+ arcipelago e guscio dai geni) | **≥ 6** scelte dal genoma |
| Mondi con i mari ai bordi | 0 (solo col gene Sommerso) | **quasi tutti** (scelta dell'utente) |
| Tempo di generazione | 4,4 s | **≤ 6 s** a 3000 × 1200 |

---

## 4. Le Roadmap

Ogni voce: **cosa**, **dove** (file), **chi tocca**, **fatta quando**.

### Roadmap 56 «Il cielo grande» (voci 439-447) — per prima, la chiede l'utente

- [ ] **439. La misura di partenza.** `tools/mappe.gd`: misura a **vigore 1** di base (`--vigore` resta), rumore medio su
  10 coppie dello stesso genoma invece di una, opzione `--prima <cartella>` che salva mappe e numeri. Cinque Semi fissi
  (1, 7, 13, 42, 20260924 = il mondo di prova) → `prove/generatore_prima/`: mappa intera, ritagli di cielo, sottosuolo e
  superficie, i numeri di §1. Foto «sfondi» e «volto» di partenza. **Fatta quando** le mappe e il file dei numeri ci sono
  e si rifanno identici due volte di fila.
- [ ] **440. I guasti trovati.** Riparati i cinque di §1: «Mondo cavo» con `room`/`big` negativi (caverne più facili);
  Arcipelago dopo i Biomi (o voragini ed `correnti` ricalcolate dopo il rimodellamento); `claim` in `PassSottosuolo`;
  il Guscio che lascia vuoto sopra il tetto (o roccia solo per ~60 righe). **Fatta quando** `tools/mappe.gd --geni
  mondo_cavo` mostra caverne grandi, le voragini dell'Arcipelago restano profonde 34-48 in ogni bioma, gruppi «geni»,
  «gravita», «base» verdi.
- [ ] **441. Il mondo più alto.** `WorldGen.HEIGHT` 1200. La superficie diventa **una distanza dal fondo**
  (`surface_base` → `ground_depth` 730 righe dal fondo, i geni «surface» in righe: altopiano −50, conca +35, cieli_alti
  +45), così le 200 righe vanno tutte al cielo, il sottosuolo resta identico e i mondi di prova 1600×900 tengono la
  profondità di oggi. Da adattare: `pass_terreno.gd:17-19`, `pass_biomi.gd:46`, `pass_giardino` (resta 480×240),
  `AtlasData.MAP_FRAC` 0,06 → 0,05 (la mappa ha il 20% di celle in più), `WorldPregen` (chiave con l'altezza),
  `CLAUDE.md` e `ROADMAP.md` dove dicono 1000. Già pronti (leggono `w.h`): `MapReveal`, `Minimap`, `MapPanel`,
  `LightMap`, `Background`, camera, `WorldSave` (salva `w`,`h`: i mondi vecchi si caricano a 1000). **Fatta quando** il
  mondo di prova nasce a 1200 in ≤ 6 s, si salva e ricarica identico (`tools/prova_salvataggi.gd`), il gruppo «base» e
  la galleria sono verdi.
- [ ] **442. Tre fasce di cielo.** `SkyData`: le altezze delle fasce come dati (`BANDS`: basso 25-110 sopra la superficie
  più alta della zona, medio fino a ~310, alto fino a `TOP`), zone `{x0, x1, low, mid, high, base, split_lm, split_mh}`,
  `zone_at`/`band_at` a tre rami, **compatibilità** con le zone salvate `{low, high, split}` (letto come basso e alto,
  senza medio). Le zone coprono **tutta la larghezza** (`SPAWN_FREE` diventa «isole piccole e basse sopra la partenza»).
  Due biomi nuovi per la fascia media (file `cielo_*.gd`: tessere, vegetazione, 5 creature ciascuno in
  `tools/bestiario_cielo.py`, gene, pesci, materiale), e i sei di oggi ridistribuiti. Chi legge le fasce: `Chiome`
  (`cielo_max` 1/2/3), `ObjectivesData` (un obiettivo «cielo_medio»), `Board`, `Filo`, `PassOsservatori` (sul medio o
  sull'alto), `GreatGuardians` (l'Occhio resta in alto), `Lords`, `Fauna` (`SKY_SHARE`, pericolo per fascia),
  `EncySkyData`. **Fatta quando** ogni colonna ha un cielo basso, medio e alto e il gruppo «cielo» (riscritto per tre fasce:
  zones, high, biomes, thin, mats, island_spot, life) è verde.
- [ ] **443. I continenti sospesi.** Passata nuova `PassContinenti` (prima di `PassCielo`, con `claim` grande): 1-2 masse
  per zona nella fascia media, 100-300 colonne × 20-60 righe, fatte come la superficie (rumore della cima sopra, rumore
  della «chiglia» sotto). Dentro: terra e vegetazione del bioma, cuore di roccia, **grotte con le pareti di fondo** (stile
  della voce 448), vene di nimbite e folgorite, uno scrigno del cielo; sotto: radici pendenti e stalattiti; ai bordi
  laghetti e cascate che cadono nel vuoto (liquidi fermi alla nascita). `PassCielo._band` resta per arcipelaghi di isole
  medie (`half` fino a 30) e piccole fra i continenti, nelle tre fasce; la quota delle isole non più uniforme (più fitte
  vicino ai continenti). Forme come dati (`SkyContinentsData`). **Fatta quando** ogni zona ha il suo continente,
  `tools/cielo.gd` conta la terra calpestabile ≥ 15% per fascia e lo spazio sotto i continenti è buio di notte.
- [ ] **444. Le strade verso l'alto.** Mari di nuvole lunghi decine di colonne (tessera 52, che attutisce le cadute; dove
  serve attraversarli da sotto, passerelle), correnti ascensionali per ogni fascia (`notes["correnti"]` con `cielo:true`,
  lette da `Gravity`), ponti di liane fra le isole vicine nelle tre fasce, radici-passerelle anche dai continenti. Il
  **Fagiolo** cresce finché trova un'isola o un continente sopra (al più 120 tessere, `BEAN_H` e la prova del gruppo
  «cielo» aggiornati). **Fatta quando** (voce 447) ogni continente si raggiunge dalla superficie senza ali.
- [ ] **445. I luoghi del cielo.** Un luogo grande per zona sui continenti: templi dei Seminatori (griglie in
  `PlacesData`/`ProjectsData`, messe da `PassStrutture` con `zone_of`), osservatori più grandi, nidi giganti dei Signori
  del cielo (`signori.gd`, «where» sulla fascia), un giardino pensile o un relitto per la firma del mondo (`PassFirma`).
  Meraviglie del cielo nell'Atlante (`WondersData`). **Fatta quando** ogni zona ha un luogo e la prova dei luoghi lo
  trova.
- [ ] **446. La vita e la luce del cielo.** Creature per fascia (le forti in alto), nascite sui continenti come in
  superficie (`Fauna._room_below`, `SkyData.pool_of` per fascia), nidi delle famiglie del cielo sui continenti
  (`PassOsservatori._nests` o `PassNidi`), pericolo per fascia (`DangerData`), aria sottile da una certa quota
  (`HarshData` «quota»). Lo sfondo che cambia salendo (`Background`: i piani della superficie scendono, nuvole sotto di
  te con `SkyClouds`), la luce aperta sui continenti. **Fatta quando** le foto del cielo (gruppo «cielo») mostrano
  creature in tutte e tre le fasce e `tools/percorso.gd` non cambia gli appassimenti all'ora oltre la soglia.
- [ ] **447. La misura del cielo.** `tools/cielo.gd` esteso: terra calpestabile per fascia, grandezza delle isole,
  continenti, **raggiungibilità** (ricerca di percorso con salto, correnti, liane, passerelle, senza ali né scavo), tempo
  per arrivare in alto con il corredo del primo giorno; mappe prima e dopo dei cinque Semi; resoconto in `ROADMAP.md`.

### Roadmap 57 «Le profondità vere» (voci 448-454)

- [ ] **448. Uno stile di grotta per strato.** `CaveStylesData` (dati): per ogni strato i parametri di `PassGrotte`
  (frequenze, soglie, stiramento in x/y, larghezza delle gallerie, peso di caverne e gallerie): **gallerie lunghe e
  intrecciate** nel Sottobosco (con le radici giganti), **sale e cunicoli** nelle Caverne d'ardesia, **pozzi verticali e
  cenge** nelle Profondità della Linfa, **vuoti e pilastri** nel Fondo. Passaggio sfumato di ~20 righe fra due stili.
  `PassGrotte` resta a fasce; i geni «grotte» moltiplicano lo stile. **Fatta quando** sulla mappa si riconosce lo strato
  dalla forma delle grotte e l'aria per strato resta fra il 25% e il 40%.
- [ ] **449. Le grandi caverne e le voragini.** Passata `PassCaverne` (dopo le grotte, `claim`): 4-8 caverne enormi per
  mondo (≥ 60 × 30, almeno una per strato dal Sottobosco), ognuna con un contenuto (un lago, un bosco di funghi, una
  rovina, un nido); 2-4 voragini che tagliano due o tre strati, con cenge per scendere e risalire. Mai sotto la partenza.
  **Fatta quando** le conta `tools/mappe.gd` e il collaudatore controlla che nessuna buchi la superficie della partenza.
- [ ] **450. Le regioni sotterranee.** I biomi del sottosuolo diventano **regioni** di 200-500 colonne in ogni mondo
  (almeno tre, scelte dal genoma e dai biomi di superficie sopra; i geni del sottosuolo ne aggiungono o ne ingrandiscono),
  con pareti, roccia, vegetazione e creature proprie, `claim` e un confine sfumato. `UnderBiomesData` ha i campi della
  regione (larghezza, strati, roccia); `PassSottosuolo` e `UnderBuilders` costruiscono dentro la regione. La misura di
  `tools/mappe.gd` conta anche i pavimenti 40-43. **Fatta quando** ogni mondo mostra tre regioni sulla mappa e il gruppo
  «biomi» (sottosuolo) è verde.
- [ ] **451. Confini vivi.** `StrataData.offset` diventa un campo 2D (lingue e sacche di uno strato nell'altro, colonne di
  roccia profonda che salgono), una fascia di passaggio dove le due rocce si mescolano. `index`/`at` e `GenContext
  .strata_off` restano le uniche porte d'accesso. **Fatta quando** nessun confine è più una linea ondulata sulla mappa e
  `DepthWatch` (la scritta dello strato) non sfarfalla.
- [ ] **452. Le acque profonde.** Laghi sotterranei grandi nelle caverne e nelle regioni (oltre il limite di 600 celle di
  `_fill_basin`), falde che riempiono le grotte basse, cascate sotterranee, sacche di Linfa e di brace al loro strato;
  pescabili (`WaterBody`). **Fatta quando** `tools/specchi.gd` conta laghi grandi in ogni strato e i gruppi «liquidi»,
  «acqua», «pesca» sono verdi.
- [ ] **453. Le strade del sottosuolo.** Una via garantita dalla superficie al Fondo (gallerie e cenge, anche lunga), e
  scorciatoie da trovare (voragini, radici viandanti). **Fatta quando** la connettività (voce 474) trova la via in ogni
  Seme.
- [ ] **454. La misura del sottosuolo.** Mappe prima e dopo, aria per strato, caverne, voragini, regioni, laghi; gruppi
  «grotte», «terre», «liquidi», «acqua», «ecologia» (i nidi trovano posto); resoconto.

### Roadmap 58 «I tesori della roccia» (voci 455-458)

- [ ] **455. Giacimenti invece di puntini.** `PassMinerali`: le vene diventano **giacimenti** (campi nuovi dei dati:
  «deposit» = quanti per 1000 colonne di strato, grandezza, «filone» = lunghezza e direzione), filoni che si seguono,
  legati a strato, roccia e regione; circa metà delle tessere di oggi. Le vene dei pacchetti (`terre.gd`, generato da
  `tools/vastita_gen/terre.py`: si cambia il generatore, non il file) e i metalli della spina seguono la stessa regola.
  Rendimento misurato con un minatore simulato (tessere di metallo per minuto di scavo per chi segue i filoni).
  **Fatta quando** il rendimento è uguale a oggi (±15%) e la mappa non è più puntinata.
- [ ] **456. I segni dei giacimenti.** Affioramenti in superficie sopra i giacimenti grandi, cristalli e piante che
  crescono solo lì (`PassDecorazioni`), una sfumatura nelle pareti di fondo vicino a una vena madre (`WallFx`); una riga
  in `ConsigliData` e il capitolo nell'Enciclopedia. **Fatta quando** una prova trova un giacimento partendo da un segno.
- [ ] **457. Gemme e rarità al posto giusto.** Gemme nei geodi e nelle caverne di cristallo, i metalli rari (spina e
  dopo) solo nelle loro regioni e strati; i cristalli di `PassCristalli` raccolti in grotte di cristallo invece che su ogni
  parete. **Fatta quando** `tools/densita.gd` mostra le gemme concentrate.
- [ ] **458. Il bilancio dei tesori.** `tools/densita.gd`, `tools/percorso.gd`, `tools/durata.gd`: il tempo per ogni
  grado di metallo non si allunga (o di poco, per scelta); scrigni e casse dei biomi raggiungibili; gruppi «grotte»,
  «terre», «spina»; resoconto.

### Roadmap 59 «Mondi che non si somigliano» (voci 459-464)

- [ ] **459. Le sagome dei mondi.** `WorldShapesData` (dati): almeno sei sagome scelte dal genoma, ognuna una ricetta per
  la grande scala, applicata da `PassTerreno` e da una passata nuova subito dopo: *continente* (oggi), *arcipelago* (isole
  di terra su un mare: l'Arcipelago di oggi migliorato), *canyon* (una gola enorme che taglia il mondo), *guscio*
  (superficie sottile su un vuoto immenso: il Guscio di oggi), *terrazze* (gradoni), *sprofondato* (superficie bassa e
  cielo altissimo), *pilastri* (colonne dalla terra al cielo, che toccano i continenti). **Fatta quando** il foglio delle
  sagome affiancate mostra mondi riconoscibili a colpo d'occhio.
- [ ] **460. I geni che cambiano la forma.** I geni di forma, grotte e sottosuolo (`GenesData`) rivisti perché cambino la
  grande scala (sagoma, stile di grotta, regioni), non solo il dettaglio; combinazioni con un nome (`combo`); `Genome.roll`
  sceglie sempre un gene di grande scala.
- [ ] **461. I mari ai bordi.** In quasi tutte le sagome (scelta dell'utente; non nel guscio e nei pilastri) un mare a ogni
  bordo, 150-250 colonne: spiaggia che scende, fondale, isolotti, un relitto con uno scrigno, creature e pesci di mare
  (`FishData`, il bestiario), la pesca in mare. Il mare del gene Sommerso diventa il caso estremo. **Fatta quando** il
  gruppo «pesca» pesca in mare e la prova della partenza resta sicura.
- [ ] **462. Il carattere dei biomi di superficie.** `PassBiomi`: larghezze variabili (un bioma enorme, uno minuscolo),
  vicinanze sensate (il freddo vicino al freddo), **passaggi sfumati** di 20-40 colonne in cui terra, erba e vegetazione
  si mescolano, micro-biomi (radure, boschetti, pozze) dentro i grandi; la partenza nel suo bioma senza schiacciare i
  vicini.
- [ ] **463. Le tracce del passato.** Grandi strutture che legano superficie, sottosuolo e cielo nello stesso punto: una
  radice cosmica che scende dal cielo nel Fondo, una città sepolta dei Seminatori con l'ingresso in superficie, un
  cratere con la sua stella caduta. Una per mondo, scelta dal genoma.
- [ ] **464. La misura della varietà.** `tools/mappe.gd -- --caso` su 30 Semi, rumore su 10 coppie: la coppia più simile ad
  almeno il doppio del rumore; il foglio delle sagome; resoconto.

### Roadmap 60 «La superficie da cartolina» (voci 465-469)

- [ ] **465. Il rilievo.** Montagne con pareti e cenge, valli, sporgenze e archi di roccia, una semplice erosione che
  addolcisce i pendii (sempre percorribili: niente pareti più alte del salto senza un passaggio); la partenza su un tratto
  sicuro (collaudatore).
- [ ] **466. I punti di riferimento.** Cose che si vedono da lontano: alberi giganti, guglie, crateri, rovine in cima a un
  colle; almeno uno per bioma; segni sulla mappa (`MapReveal`).
- [ ] **467. Gli ingressi.** Ingressi leggibili (caverne aperte sul fianco, doline, pozzi con le corde di `Grounds`) ogni
  ~200 colonne: si scende senza scavare per forza (`PassIngressi` riscritta come dati).
- [ ] **468. Le acque di superficie.** Laghi nelle valli, fiumi brevi, cascate dalle montagne (`PassAcqua`, `PassStagni`).
- [ ] **469. La misura della superficie.** Foto «sfondi» e «volto» prima e dopo (`tools/confronto_volto.py`), mappe,
  gruppo «biomi»; resoconto.

### Roadmap 61 «Il collaudo del generatore» (voci 470-478; le misure servono già dalla 56)

- [ ] **470. Le misure nuove.** In `tools/mappe.gd`: aria e terra per strato e per fascia di cielo, caverne grandi,
  voragini, regioni, giacimenti, laghi, luoghi per 1000 colonne.
- [ ] **471. La connettività.** Una ricerca di percorso sul mondo generato (salto, corde, correnti, passerelle, nuoto,
  senza scavare): quanta parte del sottosuolo e del cielo si raggiunge, e quanta strada serve per ogni risorsa e luogo.
- [ ] **472. Le prestazioni.** ≤ 6 s a 3000 × 1200; le passate lente (Grotte, Minerali) misurate e a fasce; `WorldPregen`
  sempre pronto prima del viaggio.
- [ ] **473. Le prove riallineate.** Le prove cercano i loro posti (`TestKit`), nessuna conta su coordinate o forme fisse;
  i dieci mondi di misura fissa (1600×900: `tests_gen_repeat`, `tests_nero`, `tests_chains`, `tests_finds`,
  `tests_liquids`, `tests_places`, `tests_primo`, `tests_water`, e `tests_genes` 900×1000, `tests_anomalies` 1600×1000)
  controllati uno per uno; `TestsGenRepeat` e `tools/impronta.gd` con la base nuova.
- [ ] **474. La connettività come prova.** La ricerca di percorso della voce 471 entra nel collaudatore (`PassCollaudo`
  scrive quanto è raggiungibile) e in una prova del gruppo «base».
- [ ] **475. L'Atlante e le schede.** Sagoma, continenti, regioni e mari nella scheda del portale (`PortalInfo`),
  nell'Atlante e nell'Enciclopedia (capitolo «I mondi»): il giocatore sa che mondo sta per visitare.
- [ ] **476. I mondi vecchi.** I mondi salvati prima restano giocabili a 1000 righe con il cielo vecchio (le zone
  `{low, high, split}` lette dalla compatibilità della voce 442); una prova li carica.
- [ ] **477. Il giro completo.** `tools/prove.sh tutto`, giocatori simulati (`tools/percorso.gd`), densità, durata.
- [ ] **478. Il resoconto del piano** in `ROADMAP.md`, con le mappe prima e dopo.

---

## 5. Le scelte dell'utente (8 ott 2026)

1. **Altezza del mondo 1200** («1200»): le 200 righe in più vanno tutte al cielo, il sottosuolo resta com'è.
2. **Minerali in giacimenti** («minerali in giacimenti sì»): circa metà delle tessere, a filoni, con lo stesso rendimento
   per chi sa dove cercare.
3. **Mari ai bordi in quasi tutte le sagome** («mari ai bordi in quasi tutte»): fanno eccezione il guscio e i pilastri.
4. **I mondi salvati prima** restano com'erano (i salvataggi in sviluppo non si migrano, scelta del 26 set): un mondo
   vecchio non avrà il cielo nuovo, ma si carica e si gioca (voce 476). Il Giardino non cambia.
5. **L'ordine**: cielo (56) → profondità (57) → tesori (58) → varietà (59) → superficie (60), con la 61 fatta un pezzo
   alla volta insieme alle altre. Si parte quando l'agente della Roadmap 55 ha finito.

## 6. Rischi e come si evitano

- **Le prove cambiano luogo**: un mondo più alto e di forma diversa sposta i posti delle prove; si sistemano voce per
  voce, con le prove che cercano il loro posto (voce 473).
- **La luce**: i continenti e le caverne nuove senza pareti sarebbero illuminati come il cielo (principio 8).
- **Le prestazioni**: +20% di celle e passate nuove; si misura ogni voce (principio 6).
- **Gli equilibri**: meno minerali e più strada cambiano i tempi della partita; giocatori simulati prima di chiudere
  ogni Roadmap (voci 458, 477).
- **Lavorare insieme a un altro agente**: il generatore tocca le prove e il mondo di prova condiviso; le prove si lanciano
  solo quando nessun altro sta provando, e i commit aggiungono i file per nome.
