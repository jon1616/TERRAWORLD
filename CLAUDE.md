# TERRAWORLD

Gioco d'esplorazione e costruzione a tessere ispirato a Terraria, in Godot 4.6.1. Stesso metodo di lavoro di Inkblood Arena
(`Desktop\CLAUDE\AUTOBATTLE GODOT`): contenuti come dati, strumenti di verifica, screenshot automatici, Roadmap a voci piccole.
Solo PC, solo italiano. Obiettivo: profondità e longevità altissime (esplorazione, equipaggiamento profondo, obiettivi sempre nuovi).
Documenti: `UNIVERSO.md` (ambientazione «Il Giardino dei Semi»), `ROADMAP.md` (lavori in corso e fatti; in cima «Dove
siamo»).

## Come si lavora (per riprendere dopo una pausa o una compattazione)
- **Lo stato** è in cima a `ROADMAP.md` («Dove siamo»); la direzione in «La filosofia del gioco» qui sotto; le
  scelte dell'utente dopo; le lezioni in fondo.
- **L'utente**: dà la direzione e lascia a Claude ordine e tecnica; vuole sostanza, spiegazioni in italiano semplice e
  un resoconto alla fine; per la grafica collabora generando le immagini con Gemini/Nano Banana su prompt di Claude.
  **Repository**: https://github.com/jon1616/TERRAWORLD (privato, creato il 28 set 2026 su richiesta dell'utente);
  il push si fa quando l'utente lo chiede.
- **Ogni passo**: si scrive (le modifiche lunghe con script Python scritti con Write, non con heredoc), poi
  `tools/prove.sh base,<gruppi della parte toccata>`: fa il controllo di sintassi dei .gd cambiati (se uno non
  compila le prove non partono), `--import`, le prove con un tempo massimo e il riassunto. Il gruppo **«base»**
  (~1 minuto: mondo, alberi, creazione, Vita, movimento a 60 e 144 fps, combattimento, corsa, salvataggio) va
  sempre; foto controllate a occhio; commit in italiano con la riga Co-Authored-By.
  **Il giro intero** (`tools/prove.sh tutto`, ~8 minuti) solo quando è indispensabile (scelta dell'utente, 28 set
  2026: «stava diventando troppo lungo»): alla fine di un lavoro grande (più voci) o dopo cambi profondi ai sistemi
  condivisi (generatore, salvataggi, movimento, luce). Alla fine stampa «tempi del giro» con i gruppi più lenti.
  Le prove che generano mondi li fanno insieme, in parallelo (`TestKit.gen_many`).
- **Controllo di sintassi** dei file cambiati: `for f in $(git diff --name-only | grep .gd$); do Godot_console.exe
  --headless --path . --check-only --script res://$f; done` («Identifier not found: Session/Musica» è normale).

## La filosofia del gioco: «Il Giardiniere dei mondi» (26 set 2026, approvata dall'utente)

L'obiettivo dell'utente: un gioco **molto più vasto, vario e profondo di Terraria**, pressoché infinito, con sempre
qualcosa da fare, cercare o esplorare **e un motivo per farlo**. Grafica, rete e rifinitura vengono dopo. Il piano è
in `ROADMAP.md` (Roadmap 5-11). Queste regole valgono per **ogni** voce, anche fuori dal piano:

- **La vastità a caso annoia.** Il giocatore esplora solo se sa *cosa* cerca, *perché* gli serve, e ogni tanto trova
  ciò che *non si aspettava*. Ogni contenuto nuovo deve rispondere ad almeno una di queste tre domande.
- **Il giro che si ripete**: l'Albero-Madre e gli abitanti chiedono → serve un gene, un materiale o una creatura →
  si innestano i Semi per ottenere il mondo giusto → lo si esplora → si trova ciò che si cercava e l'imprevisto → si
  torna e il Giardino cresce. Il giocatore **progetta** i suoi mondi: è ciò che Terraria non ha.
- **Moltiplicare, non sommare.** Un sistema nuovo deve moltiplicare quelli che ci sono: un gene nuovo porta creature,
  materiali, attrezzi, strutture e ricerche insieme. Prima di scrivere una voce ci si chiede «quanti altri sistemi
  rende più ricchi?». Contenuti scritti uno per uno solo dove devono essere speciali (trofei, reliquie, boss, luoghi).
- **Un solo motore genetico**, riusato: geni con dominanza e rarità, eredità, mutazioni per i Semi, le creature
  allevate e i Guardiani generati. Stesso codice, non tre copie.
- **Tutto è componibile e scritto come dati**: geni, materiali con proprietà, forme degli attrezzi, famiglie di
  creature, firme, luoghi. Aggiungere una cosa = aggiungere una riga (o un file) di dati, non codice nuovo.
- **Ogni mondo ha una firma**: almeno una cosa che si trova solo lì. Due mondi non devono mai sembrare lo stesso mondo
  con numeri diversi; `tools/mappe.gd` misura la varietà.
- **Generato + scritto a mano**: il generatore dà la quantità, i pezzi a mano (luoghi, catene della storia, boss,
  oggetti unici) danno il sapore e vengono piazzati dal generatore nei mondi giusti.
- **Salire di vigore porta cose diverse, non solo numeri più alti**: meccaniche, indoli, materiali, leggi fisiche.
- **Il racconto è una meccanica** (regola dell'universo): la lingua dei Seminatori, le catene tra i mondi e il Seme
  Nero sono progressioni di gioco, non testo da leggere.
- **Sempre un filo da seguire**: in ogni momento della partita devono esserci richieste chiare e raggiungibili (Albero,
  abitanti, bacheca, Genario, Erbario che dice cosa manca e dove cercarlo a grandi linee).
- **I salvataggi di oggi restano giocabili**: il piano cambia la forma di molte cose, quindi ogni cambio di formato
  passa da una migrazione (voce 41).
  **Sospesa per ora** (26 set 2026, l'utente): in pieno sviluppo le partite sono solo prove, non serve preservarle.

## Decisioni di base (24 set 2026, scelte dall'utente)

- **Mondi a portale**: un mondo casa più una serie infinita di mondi generati, finiti, con tema e difficoltà crescenti.
  Nell'universo: ogni mondo nasce da un Seme piantato nel Giardino (specie, vigore, tratti = parametri del generatore).
- **Mondi medi**: 3000×1000 tessere da 16 px.
- **Solo uso personale** (26 set 2026): il gioco non sarà mai venduto né pubblicato, lo useranno l'utente e 2-3 amici.
  Le licenze degli asset di terzi non contano: le grafiche si scelgono solo per stile e prospettiva (vista di lato).
- **Rete a 2 giocatori** (single player giocabile con un amico in collegamento diretto), host autoritativo come in Inkblood.
  **Rimandata** il 26 set 2026 (scelta dell'utente: «per ora non è una priorità»).
- **Grafica**: la base è generata dal codice (tessere, luce, effetti, icone in serie, creature semplici); personaggio con tutte
  le animazioni, alcuni mostri e boss arriveranno da immagini generate dall'utente con un'IA grafica (Nano Banana),
  importate con script come in Inkblood (sfondo magenta, griglia fissa, riduzione a una tavolozza comune).
- **Stile grafico tutto nostro: «Radici e Linfa» con terreno dai contorni morbidi** (scelto e approvato dall'utente il
  24 set 2026, dopo il suo appunto: «questo non è Terraria, lo stile era identico»). Mondo scuro e profondo dove la luce
  viene dalle cose vive; terra prugna intrecciata di radici, ardesia blu, muschio turchese, ambra e Linfa turchese come
  accenti; alberi-lanterna a salice con baccelli luminosi; cielo turchese-corallo attraversato dalle radici del cosmo;
  il Germogliato con capelli di foglie, tunica ocra e occhi d'ambra che brillano al buio. **Mai tornare a tessere quadrate
  con contorno, terra marrone + erba verde, chiome tonde: sono la firma di Terraria.**
- **Nomi tutti nostri**: le funzioni possono somigliare a Terraria, i nomi no (appunto dell'utente, 24 set 2026). Metalli
  radicite → legnoferro → ambra fossile → cristallo di Linfa; stazioni Ceppo del Giardiniere, Baccello ardente, Maglio
  dei Seminatori; creature «grumi». Elenco in `UNIVERSO.md`, sezione «Nomi delle cose». Ogni contenuto nuovo nasce con
  un nome dell'universo.
- **Ordine del codice fin dall'inizio** (richiesta dell'utente: in Inkblood `main.gd` era arrivato a 17.000 righe) e **Git**
  dal primo giorno. Vedi «Ordine del codice» qui sotto.

## Comandi

Godot: `C:\Users\Principale\Desktop\GODOT\Godot_v4.6.1-stable_win64_console.exe` (`_console` per vedere stdout).

```bash
# avvio (anche con doppio clic su «Avvia prova.bat»): menu → personaggio → mondo → gioco
Godot_console.exe --path .
# reimporta il progetto (dopo aver aggiunto file con class_name nuovi)
Godot_console.exe --headless --path . --import
# controllo sintattico di uno script
Godot_console.exe --headless --path . --check-only --script res://src/world/world.gd
# prove automatiche con finestra (il giro intero dura ~8 minuti, il gruppo «base» ~1; nelle prime Roadmap ~25 s): screenshot in prove/ (01_superficie, 02_grotta_buia e 02_grotta_torcia con la
# misura del buio, 03_cristalli, 04_scavo,
# 05_dopo_la_corsa, 06_muro_3_blocchi), misura del movimento (velocità, salto pieno in tessere, muro di 3 blocchi da
# scavalcare) e dei fotogrammi durante una corsa in superficie (obiettivo: 60 fps, fotogramma peggiore < 25 ms)
# Le prove usano user://prove_salvataggi (personaggio «prova» con il corredo iniziale, mondo «mondo_prova» rigenerato
# ogni volta); controllano raccolta e piazzamento di un blocco, salvano dal gioco e ricaricano (mondo e Bisaccia
# «identici»), abbattono un albero (08_albero_cade), raccolgono il legno, piantano un seme e lo fanno crescere
# (09_albero_ricresciuto), fabbricano ceppo, passerelle, torce e baccello ardente, li piazzano (10_creare,
# 11_baccello_ardente), indossano un'armatura (12_equipaggiamento), cadono da 20 tessere, bevono una pozione
# (13_vita_e_linfa), appassiscono e rinascono (14_appassito), misurano salto e muro a 60 e a 144 fotogrammi al secondo,
# e fotografano la Bisaccia aperta (07_bisaccia).
Godot_console.exe --path . -- --prove            # --carica riapre il mondo di prova salvato invece di rigenerarlo;
                                                 # --senza-luce per vedere i colori senza il buio
# viaggio vero attraverso il portale (voce 12): pianta un Seme, va nel mondo nuovo (vigore 2, portale di ritorno), torna
Godot_console.exe --path . -- --prove --prova-portale
# Roadmap 8: un Giardino nuovo («giardino_prova»): Albero-Madre, stadi, poteri, abitanti, Bacheca (foto 101-108)
Godot_console.exe --path . -- --prove --prova-giardino
# solo alcuni gruppi di prove (per provare in fretta una voce nuova): doni, antiche, pericoli, combattimento, tratti,
# obiettivi, guardiani, rovine, mobilita, lanci, giardino, eventi, casa, abitanti, compagni, viaggio, semi,
# biomi, biomi_nuovi, luoghi, corsa, raccolta, musica, germogliato, interfaccia, geni, forme, ecologia, mandria, casse, alberi,
# base (il cuore del gioco, da lanciare sempre), sigilli, stagioni, suggerimenti, opzioni, enciclopedia, lingua, catene, luoghi_scritti, enigmi, seme_nero, acqua,
# liquidi, meteo, gravita, terra_viva, tempo_mondi, vigore, guardiani_generati, leggende, sfide, grafica, vivo, cielo,
# comodita
# (elenco in `AutoTests._group`)
Godot_console.exe --path . -- --prove --solo=doni,antiche
# suoni generati: prove/suoni/*.wav da ascoltare, con durata, picco e volume medio (segnala muti e distorti)
Godot_console.exe --headless --path . --script res://tools/suoni.gd
# foto delle schermate del menu in prove/ (menu_titolo, menu_personaggi, menu_nuovo_mondo)
Godot_console.exe --path . -- --foto-menu
# prova dei salvataggi senza finestra: salva, ricarica, confronta, rovina il file e recupera dalla copia di sicurezza
Godot_console.exe --headless --path . --script res://tools/prova_salvataggi.gd
# verifica dei contenuti (tabelle di src/data/): riferimenti, ricette, bottino, progressione dei picconi, oggetti che
# non si possono ottenere; salva il foglio di tutte le icone in prove/oggetti.png. Obiettivo: «0 errori».
Godot_console.exe --headless --path . --script res://tools/verifica_dati.gd
# elenco di tutto ciò che c'è nel gioco, per categorie (oggetti, creature, stazioni, tessere, tratti…)
Godot_console.exe --headless --path . --script res://tools/elenco.gd
# grafica del Germogliato da Nano Banana (Python): riferimento, tavole delle animazioni, respiro (vedi «Struttura»)
python tools/pixela.py arte_ia/germogliato/00_profilo_fermo_v4.png --alto 36 --anteprima
python tools/importa_tavola.py arte_ia/germogliato/01_corsa_v2.png --griglia 4x2 --nome corsa --alto 35
python tools/respiro.py
# mappe dei mondi: mappe/mondo_<seme>.png a metà grandezza (--intera per 1:1), tempi per passata, conteggi per seme
Godot_console.exe --headless --path . --script res://tools/mappe.gd -- --semi 20 --da 1
# Roadmap 16: la misura del cielo (zone, tessere, isole, osservatori) con e senza i geni del cielo → prove/cielo.txt
Godot_console.exe --headless --path . --script res://tools/cielo.gd -- --semi 3
# voce 43: genomi a caso (`--caso --vigore 7`) o fissi (`--geni cavo,fungaie`), con la misura della varietà in fondo
Godot_console.exe --headless --path . --script res://tools/mappe.gd -- --semi 12 --caso --vigore 7
```

## Struttura

- `src/core/` — attrezzi generici: `Px` (primitive di pixel art, contorno automatico), `Fx` (sfumature, polvere di scavo),
  `Par` (`each(n, lavoro)`: lavori indipendenti su più processori; uno alla volta dentro il gruppo di thread).
- `src/data/` — **solo dati** (voce 3):
  - `GuardiansData` — il Guardiano di ogni vigore (Nodo Avvizzito, Regina delle Spore, Colosso d'Ardesia, poi da capo),
    con la creatura, ciò che lascia curato e le sue pagine di storia.
  - `LoreData` — le pagine di storia (Cuore trovato, Guardiano sconfitto o curato, portale), mostrate da `LorePanel`.
  - `BiomesData` — i biomi (voce 91: **un file per bioma** in `src/data/biomes/`, 16 di superficie + 9 del sottosuolo
    `sotto_*.gd`, più i pacchetti di contenuto `PACK_FILES`); `World.biomes` = l'indice del bioma per colonna (salvato:
    i biomi nuovi vanno in fondo a `FILES`). Ogni file porta tutto: erba, albero, vegetazione, cielo, tempo, elemento,
    gene, e il **pacchetto** (creature con la ricetta del disegno, famiglie, bottino, oggetti, ricette, set, geni,
    paesaggi dei nomi) che le tabelle comuni uniscono (`static var` in `TileDefs`, `TreesData`, `CreaturesData`,
    `LootData`, `ElementsData`, `FamiliesData`, `TrophyItemsData`, `GenesData`, `NamesData`, `SetsData`, `ItemsData`,
    `RecipesData`). **Questi file e `BiomesData` non nominano altre classi** (valori per esteso). Foglio: `tools/biomi.gd`.
  - `DangerData` — il pericolo di una zona (strato, notte, Avvizzimento, vigore) → tetto di creature, ritmo delle
    nascite, soglia di buio per nascere sotto terra, moltiplicatore del danno. Qui si regola la difficoltà.
  - `AncientData` — creature antiche e ancestrali: rarità (probabilità secondo il pericolo, moltiplicatori, aura),
    11 tratti di creatura con l'Essenza che lasciano. `Ancient` (in `src/entities/`) li applica a una `Creature`
    (contorno acceso con `Ancient.ring`, scritta, effetti); `Fauna.make_ancient`; innesto con `Crafting.graft`.
  - `StrataData` — i 5 strati di profondità (Superficie, Sottobosco di radici, Caverne d'ardesia, Profondità della
    Linfa, il Fondo): dove cominciano, roccia, sacche, parete, chiarore, pericolo delle creature, scritta d'ingresso.
    Il confine ondeggia (`offset(x, seme)`); `at(world, x, y)` / `index(x, profondità, seme)` = strato di una cella.
  - `TileDefs` — tipi di tessera, durezza (`HARD`, secondi col rame), forza di piccone richiesta (`POWER`: il ferro vuole
    radicite 35, l'ambra legnoferro 45, i cristalli ambra 55), cosa lasciano (`DROP`, `DECOR_DROP`), vene (`ORES`,
    lette da `PassMinerali`, ognuna con i suoi strati e le sue rocce), strati del terreno, tavolozze, luce, decorazioni.
    Rocce degli strati: radice antica (`RADICE`), scisto di Linfa (`SCISTO`), vuotite (`VUOTITE`, vuole il legnoferro);
    pareti `WALL_*` (5, righe dell'atlante di `DecorPainter`).
  - `ItemsData` — tutti gli oggetti (campi descritti in cima al file). Le famiglie di metallo (piccone, ascia, spada,
    elmo, corazza, gambali × radicite, legnoferro, ambra) nascono da `METALS` × `GEAR` in `all()`: un metallo = una riga.
    `use_of(id)` = cosa fa il clic (scava, abbatti, colpo, torcia, semina, bevi). Ogni uso che tiene un attrezzo in mano
    va aggiunto anche in `PlayerActions._on_selected`, o l'attrezzo non si disegna (successo con l'ascia).
  - `TraitsData` — i tratti dell'equipaggiamento (`roll`, `effect`, `full_name`, costo del rinnovo al Maglio). Le
    caselle della Bisaccia hanno "tratto"; `add_stack` sposta una casella senza perderlo, `equip_traits` per ciò che
    si indossa.
  - `FloraData` — germogli e semi: tempo di crescita, spazio richiesto, altezza massima di un albero (`HEIGHT`).
  - `TreesData` — gli alberi (26 set 2026): una **specie per bioma** (albero-lanterna, fungo-albero, acacia d'ambra,
    abete di brina, tizzone) e quattro **grandezze** (piccolo, medio, grande, antico: altezza, robustezza, legno);
    la variante salvata per ogni albero è specie × grandezza × forma in un intero (`encode`/`decode`), `roll` ne
    sceglie una per un bioma e lo spazio libero. Disegni in `TreeArt` (`src/art/`); foglio con
    `tools/alberi.gd` → prove/alberi.png; prove `--solo=alberi` (foto 100_alberi_<bioma>).
  - `SpellsData` — gli incantesimi dei bastoni di Linfa (aspetto, velocità, ventaglio, quante creature attraversa,
    quanto insegue, se passa la roccia, luce).
  - `BeastItemsData` — materiali delle creature della voce 22 e ciò che se ne fa; uniti in `ItemsData.all()`.
  - (Materiali, set, armi, trofei e Semi di ogni bioma stanno nel pacchetto del suo file in `src/data/biomes/`:
    `BiomeItemsData` non c'è più, pulizia del 28 set 2026.)
  - `GenesData` (Roadmap 5, piano «Il Giardiniere dei mondi») — i **geni** dei Semi di mondo in 13 categorie (superficie,
    forma, grotte, sottosuolo, minerali, gemme, rovine, fauna, stirpi, flora, cielo, tempo, ombra): rarità, dominanza,
    effetti `gen` (generatore) e `run` (in gioco, chiavi in `DEFAULTS`), `vmin`, `only` ("mutazione", "firma"), `combo`;
    le Fiale (`items()`, una per gene) e la Provetta. Le regole stanno in `Genome` (`src/game/`).
  - `SignaturesData` (firme dei mondi, ricordi, Linfa antica) e `NamesData` (nomi dei mondi nati dai Semi).
  - Roadmap 6 «La materia viva»: `MaterialsData` (materiali con proprietà: 8 metalli, 28 leghe generate, 12 materiali
    dei geni), `FormsData` (16 forme: formule dei valori, aree dei colpi `AREA`, fasce del Telaio `FASCE`, ricette),
    `ElementsData` (6 elementi, debolezze e resistenze di ogni creatura, reazioni). Gli oggetti forma × materiale sono
    generati in `ItemsData.all()` (id «forma_materiale», campo `gen` per quelli che l'Erbario non conta). In
    `TraitsData` la qualità di fabbricazione (`QUALITY`) e i posti d'innesto.
  - `CompanionsData` (voce 37: compagni e alleati), `NpcData` e `ValueData` (voce 36: abitanti, merci, prezzi).
  - `TrophyItemsData` — i trofei di ogni specie (`TROPHY_OF`: li lasciano solo le rare), gli oggetti unici che ne
    nascono, la Polvere iridata e gli oggetti iridati, con le loro ricette (unite in `RecipesData.all()`).
  - `SetsData` — i set di equipaggiamento: `METAL_BONUS` (un set per metallo, pezzi generati), vesti e coppie di
    accessori; `complete(equip)`, `worn`, `of_item`.
  - `KeepersData` — i Custodi degli strati (creatura, strato della tana, richiamo, pagina); `KeeperItemsData` i loro
    oggetti, i richiami e l'Altare dei Seminatori.
  - `RelicsData` — le reliquie dei Seminatori, le tre collezioni e il loro bonus per sempre, la Mappa dei Seminatori.
  - `RecipesData` (ricette, più quelle generate delle famiglie di metallo), `StationsData` (ceppo, baccello ardente,
    maglio), `CreaturesData` (creature: statistiche, comportamenti con i parametri `p`, bottino, strati, peso di comparsa), `LootData` (tabelle e `roll`).
- `src/art/` — grafica generata dal codice:
  - `TerrainPainter` — terreno dai contorni morbidi con la **doppia griglia**: si disegna una griglia spostata di mezza
    tessera; ogni cella tocca i centri di 4 tessere e, secondo quali sono piene (16 combinazioni), traccia una forma
    curva (interpolazione morbida degli angoli + soglia con rumore = bordo irregolare). Uno strato per ogni voce di
    `TileDefs.TERRAIN_LAYERS` (ardesia = sagoma di tutto il terreno, humus, muschio, rame, ferro, oro, cristallo),
    disegnati uno sopra l'altro. Trame da 64×64 senza cuciture divise in 16 varianti (`variant_of`), così la trama
    continua da una cella all'altra. Minerali: solo noduli (trama bucata, alfa 0.9 = niente bordo di strato), si vede
    la roccia che li contiene. Atlante 4096×112.
  - `DecorPainter` — pareti (stesse trame da 64, più scure e fredde) e le decorazioni con la loro parte luminosa
    (atlante largo 48 celle); la vegetazione dei biomi (26 set 2026: erba bassissima, cespugli, canne, cardi,
    cristalli di brina, braci…) in `BiomeDecorArt`, id 33-45 in `TileDefs` (`DECOR_BIOME_GRASS/PLANTS`,
    `is_soft_decor`), piazzata per bioma da `PassDecorazioni`.
  - `IconShapes` — le forme d'icona nuove (dalla voce 21), chiamate da `ItemIcons` quando la forma non è sua.
  - `ItemIcons` — icone 16×16 nello stile (manici di radice fasciati di foglia, lame a foglia, lingotti a seme, perle
    d'ambra): `make(forma, materiale)` o `of(id)`; il materiale sceglie la tavolozza.
  - `StationArt` — Ceppo del Giardiniere, Baccello ardente (bocca di brace luminosa), Maglio dei Seminatori (rune);
    i banchi della voce 25 in `WorkshopArt`. Foglio di tutte le stazioni in prove/stazioni.png.
    Mobili **bassi** (26 set 2026, appunto dell'utente: «troppo grandi»), ma banchi da lavoro e casse **2×2** (28 set
    2026, l'utente giocando: «troppo piccoli, circa 2×2»; `V2_SIZE` alza quelli dei mondi salvati prima): mobili alti una tessera
    (il Baccello ardente e il Telaio due, ma stretti), disegnati apposta in `CompactArt`. Le misure di prima stanno in
    `StationsData.OLD_SIZE`: `WorldSave` fa scendere al pavimento quelli dei mondi salvati prima (`stazioni_v`), e il
    generatore appoggia le casse al pavimento secondo la loro altezza.
  - `BossArt` — i tre Guardiani (Nodo, Regina, Colosso), malati o guariti, chiamati da `CreatureArt.frames`.
  - `BeastArt` (creature della voce 22 di superficie e Sottobosco, `spider` per i ragni) e `DeepBeastArt` (quelle del
    profondo), chiamate da `CreatureArt.frames` (2 fotogrammi, 3 per guscio e travestimento); `BiomeBeastArt` le
    quattro creature dei biomi della voce 40. Una tessera d'erba nuova: `TileDefs` (costante, `GRASSES`, tabelle,
    tavolozza, strato del terreno), `MapReveal`, suono di scavo in `PlayerActions`, `PassDecorazioni`.
  - `CharacterArt` (personaggio a pose, restituisce anche mano e occhio), `CreatureArt`, `NatureArt`
    (`root_arches`, `lantern_forest`, colline, torcia, sole), `TreeArt` (gli alberi dei biomi).
- **La grafica di Nano Banana (Roadmap 13)**: disegni originali in `arte_ia/<categoria>/` (con `rifai.sh`), png del gioco
  in `arte/<categoria>/`, fatti da `tools/tavola.py` e `tools/illustrazione.py`; nel gioco li carica `ArtLib`
  (`src/art/art_lib.gd`, null se manca: resta il disegno del codice). Forme d'icona colorate per materiale in
  `IconTemplates`; stati sopra le creature `StatusMarks`; pulsanti dei pannelli `PanelButtons`. Il metodo e le
  lezioni sui prompt sono in ROADMAP.md, Roadmap 13. Claude crea sempre la cartella prima di dare il prompt.
- `musica/` — le musiche fatte dall'utente con Gemini («crea musica»): `esplorazione` (sottofondo) e `guardiano`
  (scontri con i boss), .mp3/.ogg/.wav; per cambiarne una si sostituisce il file con lo stesso nome (poi `--import`).
  Le suona l'autoload `Musica` (`src/audio/music.gd`): già nel menu e senza interruzioni nel mondo; brano del boss
  quando c'è una creatura `boss` non curata entro 45 tessere (sottofondo in pausa, riprende da dov'era), ritorno dopo
  3 s di calma, dissolvenza di 4 s quando un brano ricomincia, più piano sotto terra. Volume `Settings.music`.
  `main.gd` si presenta con `Musica.attach(self)`. Prove `--solo=musica`.
- `arte_ia/germogliato/` — i disegni del personaggio fatti dall'utente con Nano Banana (grandi, su magenta), con i nomi
  dati da Claude (`00_profilo_fermo_v4.png` = riferimento, `01_corsa_v2.png`…). La cartella ha `.gdignore`: Godot non
  la importa (come `prove/` e `mappe/`). Gli sprite del gioco nascono da qui con gli script Python di `tools/`:
  `pixela.py` (da disegno grande a pixel art di 36 px come un pixel artist: tavolozza, moda per pixel, accenti fissi
  per occhio d'oro, perlina e foglia, pulizia, contorno), `importa_tavola.py` (taglia una tavola nelle pose, toglie
  scritte, linee e ombre che Nano Banana aggiunge sempre, allinea piedi e testa, stessa finestra, fattore e tavolozza
  per tutte le pose) e `respiro.py` (il fermo che respira, fatto dal riferimento spostando pochi pixel). Risultato in
  `arte/germogliato/<animazione>_<n>.png` + `tavolozza.png`, anteprime in `prove/germogliato_*.png/.gif`.
  In gioco li carica `HeroSprites` (`src/art/`: occhio e centro del corpo ricavati da ogni posa, pugno e angolo del
  braccio dai .json di `--mano`) e li disegna `HeroAnimator` (`src/entities/`, chiamato da `Player._animate`): fermo
  (respiro), corsa, salto (posa dalla velocità verticale), colpo (attrezzo nel pugno, segue `swing_period`), mira (la
  posa più vicina alla direzione, l'arma con l'angolo vero), torcia (ferma e di corsa, con la fiamma), speciali
  (parete di spalle al muro, planata, rampino tirato/appeso con la corda dal pugno `Player.hand_world`), colpito
  (`Player.hurt_t` a ogni ferita, `Player.wilting` quando appassisce: vince su tutto). `CharacterArt`
  resta di riserva se mancano i file. Corpo 10×30 (sprite 36: passa nei cunicoli da 2). Tavole in
  `arte_ia/germogliato/`: 01_corsa_v2, 02_fermo (non usata: respiro dallo script), 03_salto, 04_colpo, 05_mira,
  06_torcia, 07_speciali, 08_colpito; il comando di importazione di ognuna è nel messaggio del suo commit.
- `src/audio/` — `SfxSynth` (ricette di `SoundsData` → campioni PCM, limitatore, anelli senza cuciture per i
  sottofondi) e `Sfx` (modulo della scena: `play(id, punto)`, sottofondo dello strato generato in un thread e sfumato;
  `played` conta i suoni per le prove). I moduli lo chiamano con `m.sfx.play(...)`, `PlayerActions` con `sfx`.
- `src/world/` — il mondo:
  - `World` — solo lo stato (contenitori: `chests` angolo → `Bisaccia` del contenuto, `chest_at(o)`; tessere, pareti, decorazioni, superficie, torce con indice a celle da 16, alberi per blocco,
    germogli con il tempo che manca, stazioni per angolo in alto a sinistra, passerelle in un array a parte `plats`).
    `tree_at(c)`/`tree_fits(c)` per gli alberi, `station_at(c)`/`station_fits(id, o)` per le stazioni, `plat(x, y)`.
  - `gen/` — il generatore: `WorldGen.passes()` elenca le passate in ordine, `GenContext` (seme, rumori per nome,
    parametri, appunti tra passate), `GenPass` (base). Passate in `gen/passes/`: Terreno, Biomi (tratti di bioma e
    forma del terreno di ciascuno), Strati (roccia, sacche e
    pareti di ogni strato di `StrataData`, confini sfrangiati), Grotte (profondità, regioni, grandi caverne), Vuoti (i
    grandi vuoti del Fondo e il suo pavimento di vuotite), Radici (radici giganti del Sottobosco, anche attraverso le
    grotte), Ingressi, Minerali (per strato e roccia), Cristalli, Sottosuolo (fungaie, geodi di brina, fiumi di brace,
    laghi di Linfa, cuore cavo: `PassSottosuolo`, secondo i geni), Erba, Alberi, Decorazioni (per strato), Avvizzimento (due macchie malate in superficie), Cuore (la
    cupola del Cuore del mondo nel Fondo, con i 4 nodi avvizziti e la stazione `cuore_mondo`), Rovine (44 stanze dei
    Seminatori con uno scrigno pieno secondo lo strato), Pericoli (rovi spinosi e rune trappola, vedi `Hazards`), Doni (Boccioli del cuore e Stille perenni), Gemme (grappoli nelle grotte, per strato), Tane (dei Custodi), Nascondigli (reliquiari murati), Geodi, Isole (sospese, gene raro), Firma (il
    luogo unico del mondo, `PassFirma`), Piante-seme, Partenza (le torce
    già accese della vecchia passata provvisoria sono state tolte il 25 set 2026: le torce le mette il giocatore),
    Collaudo (l'ultima). Un mondo 3000×1000 si genera in **~3 s** (28 set 2026, prima 10), in un thread suo con la
    schermata d'attesa. Le regole del generatore (28 set 2026):
    - **un caso per passata**: `GenContext.begin(nome)` riparte da seme del mondo + nome della passata, così cambiare
      una passata non sposta le altre; le casse si riempiono con il caso del generatore (`World.gen_rng`,
      `Bisaccia.rng`), mai con quello globale;
    - **a fasce**: le passate che guardano ogni tessera (Strati, Grotte, Minerali, Cristalli, Decorazioni, Pericoli)
      lavorano per fasce fisse di 25 righe con `GenBands.run(c, h, lavoro)`, su tutti i processori; chi usa il caso lo
      prende da `c.band_rng(fascia)`. Il lavoro legge copie locali e scrive solo la sua fascia (regole in cima a
      `gen_bands.gd`). Lo strato di una cella: `c.strata_off(w)` e `c.strata_tops()`;
    - **la mappa dei posti**: ogni struttura chiede `c.is_free(rettangolo)` e poi `c.claim(rettangolo, nome)`; una
      struttura nuova deve fare lo stesso;
    - **il collaudatore** (`PassCollaudo`): sovrapposizioni, Cuore, firma, partenza sicura, stazioni dentro il mondo e
      non murate; ripara ciò che può e scrive `notes["collaudo"]` (lo stampa `tools/mappe.gd`);
    - **ripetibile**: lo stesso seme dà lo stesso mondo in ogni parte (`WorldGen.fingerprint`, prova `TestsGenRepeat`
      nel gruppo «base», da sola `--solo=ripeti`); `tools/impronta.gd` confronta tutto prima e dopo un riordino;
    - **preparato in anticipo**: piantando un Seme, `Portal.pregen` fa nascere il mondo in sottofondo su un processore
      solo (`WorldPregen`, parametro "seriale"); il viaggio lo usa se è pronto con gli stessi parametri
      (`MainBoot.gen_params`), altrimenti genera come sempre.
  - `ViewArt` — le trame e le tavole (TileSet) di terreno e decorazioni e le texture delle stazioni, uguali in ogni
    mondo: preparate una volta per sessione in un thread, già dal menu (`Session._ready`); `get_all()` le dà a
    `WorldView` e `ViewProps` (ingresso in un mondo da 12 a ~3 s, 28 set 2026).
  - `WorldView` — disegno a blocchi da 32×32: solo i blocchi vicini alla visuale esistono come nodi (1 costruito per
    fotogramma, liberati oltre 2 blocchi di margine); ogni blocco ha pareti (z -10) e decorazioni (z 1) sulla griglia
    normale, i 7 strati del terreno sulla doppia griglia (z 0, spostati di -8,-8), bagliore di cristalli e decorazioni
    (z 25), alberi (z -5, un nodo con il perno alla base: `shake_tree`, `fell_tree`, `grow_tree`; baccelli luminosi in
    z 26), torce e scintille. `refresh_around(c)` dopo uno scavo.
  - `LightMap` — luce in una finestra di 128×96 tessere attorno alla visuale, calcolata in un thread
    (`WorkerThreadPool`) su copie dei dati; ricentrata quando la visuale si sposta di 6 tessere, ricalcolata quando il
    giocatore cambia cella o `dirty` è vero. Immagine stesa sul mondo in moltiplicazione (`overlay` in main, z 20).
    `ambient` = chiarore minimo (le grotte si leggono anche lontano dalle torce), del colore dello strato in cui si trova
    il giocatore (lo sfuma `DepthWatch`); luce delle decorazioni in `TileDefs.DECOR_LIGHT`.
- `src/save/` — salvataggi: `SavePaths` (cartelle, scrittura sicura: file temporaneo → il vecchio diventa `.bak` →
  il nuovo prende il suo posto; lettura con ripiego sulla copia di sicurezza), `WorldSave` (mondo intero compresso ZSTD
  in `mondo.bin` ~0,5 MB, salvataggio ~15 ms, caricamento ~17 ms; `mondo.json` con nome, seme, date, tempo di gioco,
  partenza, posizione di ogni personaggio), `Character` (personaggio separato dai mondi, `personaggi/<id>.json`), `Settings` (impostazioni del giocatore in
  `user://impostazioni.json`: volumi di effetti, sottofondo e musica).
  Cartella: `%APPDATA%\Godot\app_userdata\TERRAWORLD\salvataggi\`. Le creature non si salvano: si rimettono con
  `PassPartenza.place_creatures`. I mondi nati dai Semi si salvano dentro il loro Giardino,
  `mondi/<giardino>/semi/<id>` (28 set 2026, richiesta dell'utente: nel menu solo il mondo principale):
  `WorldSave.dir_of` li trova, `list()` li elenca tutti (la rete delle Aiuole), `list_main()` solo i principali (menu);
  quelli salvati prima in cima si spostano da soli; cancellando il Giardino se ne vanno anche loro.
- `src/entities/` — `TileBody` (movimento contro la griglia, gradino automatico, passerelle che reggono solo chi scende
  e si attraversano tenendo S), `Creature` (una sola classe per tutte le creature: dati da `CreaturesData`, fisica a
  terra o in volo, fotogrammi, `take_hit` con spinta e lampo, `HpBar`), `behaviors/` (`Behavior.make(id)`: un
  comportamento per file, scrivono le intenzioni della creatura `want_x`, `want_fly`, `vel`, `fire`, `busy`; dalla
  voce 22 anche `anchored` (ferma, senza fisica), `upside` (appesa), `ghost`/`buried` (nella terra), `shell`),
  `Projectiles` (dardi e spore in volo; chi colpiscono lo decide `Combat.on_shot`), `Player` (movimento a ogni fotogramma
  disegnato, a passi di al massimo 1/30 s, spostamento con la velocità media del passo = salto identico a ogni
  frequenza; valori di base in cima al file: corsa 95 px/s, salto pieno 3,36 tessere; armatura disegnata (`set_look`);
  segnale `landed` con le tessere di caduta; `auto_dir`/`auto_jump` per le prove e i futuri bot), `Drops` (oggetti caduti a terra: cadono, vengono attirati entro
  5 tessere, entrano nella Bisaccia se c'è posto; non si salvano).
- `src/game/chronicle.gd` (`Chronicle`) — collega gli eventi (creature rare, rare sconfitte, innesti, oggetti dei
  trofei, reliquie) agli avvisi, all'Erbario e ai conteggi degli obiettivi: `main.gd` resta solo montaggio.
- `src/ui/character_sheet.gd` (`CharacterSheet`) — la scheda del Germogliato nella casella Esamina vuota.
- `src/ui/` — `menu.tscn`/`menu.gd` (scena iniziale: titolo, personaggi, mondi, creazione), `Hud` (barra rapida = le
  prime 10 caselle della Bisaccia, in basso al centro; `current()` = oggetto in mano; segnale `selected`; `toast`; tasto
  E/Tab apre la Bisaccia), `BisacciaPanel` (le altre 30 caselle; clic prende/posa/scambia, clic destro metà pila),
  `SlotView` (casella riusabile con icona e quantità). **La Bisaccia aperta** (riprogettata il 28 set 2026, richiesta
  dell'utente: «impaginazione nettamente migliore, sfondo scuro, pratica, intuitiva e chiara»): uno sfondo scuro copre
  il mondo, riquadri opachi (`CraftingPanel.panel_box`); `panel.z_index` 4 sopra le scritte dell'HUD, la barra rapida
  (5) e gli avvisi (6) sopra la Bisaccia.
    `CraftingPanel` — «Creare», in alto a sinistra (`RECT`): banchi vicini con icona e nome, categorie in colonna con
    «possibili/tutte» (più «Lavorazioni» del Maglio e del Telaio, righe in `CraftWork`), ricerca, «Solo possibili»,
    «Anche i banchi lontani»; la griglia delle ricette per categoria (`RecipeTile` in `src/ui/craft/`: un nodo che si
    disegna da sé, barra di quanto hai degli ingredienti; clic sceglie, doppio clic crea, Maiusc+clic crea 5), caselle
    preparate poche per fotogramma a Bisaccia chiusa e riusate. `pick`, `times_possible`, `craft_times`, `station_ok`;
    con una cassa aperta lascia il posto alla cassa (`set_tall(false)`).
    `ExaminePanel` — «Esamina», la colonna a destra: la scheda della ricetta scelta (oggetto, banco vicino o no,
    ingredienti con «ne hai / ne servono», quantità −/+/Max, «Crea») e sotto `ItemInfo`; oppure l'oggetto posato
    nella casella (con «Vai alla ricetta»). L'utente vuole i dettagli qui, in uno spazio apposito, non nei suggerimenti.
    `CharacterCard` — la scheda del Germogliato in basso a sinistra (`CharacterSheet`).
    Come è fatto il pannello (cornice, categorie, ricerca, griglia) sta in `CraftLayout` (`src/ui/craft/`).
    `RecipeRow` resta per lo stile dei bottoni (`RecipeRow.style`). `MiningCursor`.
- `src/game/vitals.gd` (`Vitals`) — Vita (100, foglie da 10) e Linfa (20, gocce da 2), Scorza (metà del suo valore
  tolta a ogni ferita), ricrescita della Vita dopo 6 s senza ferite, attesa di 30 s tra due pozioni; segnali `changed` e
  `died`. In main: ferite da caduta oltre 12 tessere (6 punti per tessera in più), appassire e rinascere alla partenza.
- `src/game/fauna.gd` (`Fauna`) — creature vive: comparsa per strato fuori dalla visuale (`try_spawn`, mai vicino alle
  torce), sparizione lontano, spari raccolti da `c.fire`, `kill` con bottino. `enabled` = falso nelle prove.
  Il bottino, sciami e branchi, `make_ancient` e `family_weights` stanno in `FaunaExtra` (`fauna_extra.gd`).
- `src/game/combat.gd` (`Combat`) — colpi in mischia a ogni giro dell'arma (`Player.swing_period` = 1/velocità),
  arco (`Player.aim`, dardi dalla Bisaccia; `auto_aim`/`auto_fire` per le prove), ferite al contatto e dalle spore con
  invulnerabilità, spinta e lampeggio.
- `src/game/guardian.gd` (`Guardian`) — il primo Guardiano (voce 8): si sveglia entrando nella cupola del Cuore;
  sconfitto (frammenti) o curato con la Rugiada sui 4 nodi (`cure_at`: Linfa del Guardiano e +20 Vita massima, una
  volta per mondo); poi il Cuore diventa `cuore_vivo` e dona il Seme di mondo. Stato in `world_meta["guardiano"]`.
  Nel Fondo un «battito» dice da che parte è il Cuore. `BossBar` e `LorePanel` in `src/ui/`.
- `src/game/portal.gd` (`Portal`) — Seme di mondo piantato in un'Aiuola (voce 45) = stazione `portale`; clic destro = salva e passa al
  mondo nato da quel seme con il vigore del Seme (`destination(o)`, `world_meta["portali"]` per ogni portale,
  `place_return` nel mondo nuovo, `vigor_mult`: +35% alle creature per punto di vigore). Il vigore arriva al generatore
  in `GenContext.params` (`WorldGen.generate(…, params)`), vene più grandi in `PassMinerali`.
  Con il mouse sopra un portale compare la scheda del mondo (`StationTip.portal`, testo di `PortalInfo`: vigore,
  Guardiano, stagione, visitato o no, firma, genoma); prova nel gruppo `semi` (foto 109_scheda_portale).
- `src/game/spells.gd` (`Spells`) — i bastoni di Linfa: tenendo premuto tirano l'incantesimo verso il mouse spendendo
  Linfa (`auto_aim`/`auto_fire` per le prove); `nearest` per i colpi che inseguono (`Projectiles.seek`). I colpi con
  `pierce` attraversano più creature (`Combat.on_shot` tiene l'elenco di chi hanno già preso).
- `src/game/gifts.gd` (`Gifts`) — i doni da assorbire (Cuore di bocciolo, Stilla perenne): Vita o Linfa massima per
  sempre fino a `gift_max`; conteggi in `Character.stats["doni_<id>"]`, `Character.linfa_extra`.
- `src/game/keepers.gd` (`Keepers`) — i Custodi: `dens` (bozzoli ancora pieni), `hatch` avvicinandosi, `summon`
  all'Altare (solo se già sconfitto), `world_meta["custodi"]`; il bozzolo sconfitto diventa `bozzolo_rotto`.
  Disegni in `KeeperArt` (Custodi e bozzoli).
- `src/game/grapple.gd` (`Grapple`) — il rampino: `fire(oggetto, punto)` cerca la roccia lungo la linea entro la
  portata e aggancia `Player.hook`; il Player è tirato in `_hook_step`; sgancio con salto, S, distanza o tessera scavata.
  Doppio salto (`Player.air_jumps`) e pareti (`Player.wall_climb`) sono effetti degli accessori.
- `src/game/throwing.gd` (`Throwing`) — esplosivi (`explode(punto, blast)`: roccia fino alla forza, creature,
  Germogliato vicino), semi ricurvi (uno alla volta, tornano in mano) e giavellotti (con `Projectiles`).
- `src/game/garden.gd` (`Garden`) — il giardino: `plant`, `grow` (ogni secondo, `paused` nelle prove), `water`,
  `harvest` (clic destro, da `Interact.touch`), raccolto e semi selvatici dal segnale `PlayerActions.decor_picked`.
- `src/game/events.gd` (`Events`) — eventi del mondo: `start`/`stop`, effetti su `Fauna` (`event_danger`,
  `event_rare`, `event_pool`) e `Garden.wild_mult`, stelle cadenti (`fall_star`), conteggio verso il premio.
- `src/game/masonry.gd` (`Masonry`) — costruire: `place_wall`/`remove_wall` (Martello), porte (`toggle_door`,
  tessere `PORTA` quando è chiusa; `Building` le mette e le toglie piazzando e riprendendo), letto (`use_bed`,
  `respawn_point` usato da `Life`). Arredi e porte disegnati in `FurnitureArt`.
- `src/game/villagers.gd` (`Villagers`) — gli abitanti: `check` (arrivi: Focolare, letti liberi, condizioni di
  `NpcData`), `npc_at`, `open_trade`; `Npc` in `src/entities/` (passeggia, si gira verso il giocatore), `NpcArt`,
  `TradePanel` in `src/ui/`. Prezzi e valori in `ValueData` (`value`, `sell_price`, `buy_price`).
- `src/game/companions.gd` (`Companions`) — compagni (`toggle_pet`, doni su `Drops.magnet_mult` e
  `Vitals.pet_linfa`, luce) e alleati dei bastoni evocatori (`summon`, `MAX_ALLIES` + `GearEffects.allies`); dati in
  `CompanionsData`, entità `Ally` in `src/entities/` (segue, sceglie un bersaglio, colpisce con `Combat._strike`).
- `src/game/travel.gd` (`Travel`) — radici viandanti: `roots`, `open_from` (mappa in modo viaggio), `go`, `describe`.
  `Minimap` in `src/ui/` (ritaglio della mappa esplorata, tasto N).
- `src/game/world_traits.gd` (`WorldTraits`) — i geni del mondo mentre si gioca (`world_meta["geni"]`, parte `run` di
  `GenesData`): `apply` imposta le leve `Fauna.world_danger/world_lumini/world_rare`, `Garden.grow_mult`,
  `DayCycle.night_extra/night_floor`, `Events.chance_mult`, `Blight.spread_mult`; entrando, i geni del mondo diventano
  «visti». Nel generatore i geni arrivano in `params["geni"]` (`GenContext.genes()`, `surface_gene()`).
  `Portal.touch`: primo tocco = descrizione, secondo = viaggio.
- **Il piano «Il Giardiniere dei mondi» (Roadmap 5)**:
  - `Genome` (`src/game/genome.gd`) — il motore genetico, uno solo per tutto il piano: genoma {"geni", "vigore"} nei
    "dati" della casella del Seme (`Bisaccia.data_at`), `roll` (sempre un gene di forma, grotte o sottosuolo),
    `effects`, `describe`/`sheet` (geni mai visti = «?»), `odds`/`cross` (innesto), `mutate`, `mutation_chance`
    (combinazioni segrete); `local_vigor` = vigore dei Semi raccolti in questo mondo, `known` = `Character.genario`.
  - `SaveMigrations` (`src/save/`) — versioni di personaggi e mondi e i passi di migrazione; `Bisaccia` con caselle che
    portano "dati" (non si impilano).
  - `Signature` — la firma del mondo (ritrovamento, stella sulla mappa; i mondi vecchi la ricevono al primo ingresso).
  - `Aiuole` — il Giardino (mondo di partenza) e le sue Aiuole (al più 3 + `bonus`), la rete dei mondi (`network`,
    `home_id`, `world_meta["casa"]`), `close` (Seme dormiente). `SemenzaioPanel` (tasto K: Mondi e Genario).
  - `Sampling` — trovare i geni: Provetta di Linfa (`category_at`: cosa si tocca → categoria), piante-seme
    (`harvest`, `wild_seed`), Fiale dalle creature; le Fiale nella Bisaccia fanno imparare il gene. `Genario` (vista).
  - `InnestoPanel` (`src/ui/`) — il Banco dell'Innestatrice: due Semi + Fiale + Linfa antica → Seme figlio.
- **Roadmap 6 «La materia viva»**:
  - `Gear` (`src/game/gear.gd`) — i valori veri di **un** oggetto (casella con "tratto" e "dati"): base forma ×
    materiale, qualità ("q"), fascia, tratto di nascita e innesti ("innesti"), elemento; `full_name`, `line`,
    `effect` (somma dei tratti), `slots`/`free_slots`. Lo usano `Combat`, `Spells`, `PlayerActions`, `GearEffects`,
    `Bisaccia.scorza` ed Esamina. Ogni nuovo modo di cambiare un oggetto passa di qui.
  - `Combat.melee_area(forma)` (aree dei colpi), `_strike(…, elem)` → `Elements.hit` (debolezze, stati, reazioni;
    `Creature` ha `burn_t`, `weak_t`, `elem`/`elem_t`); le leghe con due elementi li alternano.
  - `Crafting`: `craft` dà la qualità (`roll_quality`, la fortuna aiuta), `wrap` (fascia al Telaio), `graft`/`ungraft`
    (innesti al Maglio), `known` (le ricette delle leghe si scoprono). `GeneMaterials` — i materiali dei geni che
    cadono scavando (`PlayerActions.dig_hook`) o dalle creature. Icone delle forme nuove in `WeaponShapes`.
- **Roadmap 7 «L'ecologia»**:
  - `FamiliesData` (36 famiglie: ruolo, prede, nidi, migrazioni) e le varianti «specie~taglia~elemento~indole»
    (`CreaturesData.get_data`, disegno in `VariantArt`); `Fauna.set_world` (famiglie favorite e assenti del mondo).
  - `Ecology` — popolazioni per zona (`world_meta["popolazioni"]`), caccia (`BhCaccia`) e pascolo (`BhPascola`),
    nidi (`world_meta["nidi"]`, `PassNidi`, `NestArt`, `touch_nest`: uovo, nutrire, distruggere) e migrazioni.
  - La mandria: `HerdData` (chi si addomestica, cibo, prodotti, doni, cavalcature, oggetti), `Herd` (schede in
    `Character.mandria`, stati segue/recinto/riposo, livelli, `bonuses()` per `GearEffects`, tasto R in sella),
    `Taming` (cibo, Laccio, Vasetto), `Pens` (Recinto-mangiatoia, Incubatrice, tempo passato altrove con l'orologio,
    coppie che fanno uova), `HerdInfo` (testi), `HerdPanel` (tasto G), `BhMandria` (la creatura della mandria in
    scena: `Creature.tame`). Allevamento: `BreedData` (doti, manti) e `Breeding` (`child`, `odds`, `preview`).
  - `BestiaryInfo` — l'Erbario vivo: la scheda Famiglie, con indizi per ciò che manca e dove cercare.
- **Roadmap 8 «Il risveglio dell'Albero-Madre»** (il motivo della partita; una partita nuova comincia nel Giardino):
  - Il **Giardino** — un'isola di 480×240 sospesa nel Vuoto (`WorldGen.garden_passes()`: `PassGiardino`,
    `PassGiardinoRifinitura`), con l'Albero-Madre (stazione `albero_madre_<fase>`, disegno `MotherTreeArt`), una
    prima Aiuola e la Bacheca. `Giardino` (`src/game/`): caduta nel Vuoto, primo tocco dell'Albero = primo Seme,
    `world_meta["giardino"]`. Il vecchio mondo di partenza è ora il primo mondo nato da un Seme.
  - `MotherTreeData` (12 stadi con le offerte e i doni: Aiuole, poteri, abitanti, fasi, categorie d'innesto, pagine) e
    `AlberoMadre` (`Character.albero`, `offer`, `awaken`, riga nell'HUD), `AlberoPanel`. Le categorie di Fiala
    innestabili si aprono con gli stadi (`graftable`).
  - `PowersData` e `Powers` — sei poteri (Vista V, Canto, Passo, Brace, Salto, Radici-ponte F) e i **Sigilli**:
    `PassSigilli` (14 stanze sigillate + 2 nidi alti per mondo, tessere `SIG_*` che il piccone non scalfisce,
    `TileDefs.SEALS`), `open_seal`, `world_meta["sigilli"]`; dentro, i Frammenti dell'Albero che gli stadi chiedono.
  - `NpcBonds` — affetto (doni, richieste, livelli con sconti e regali) e le tre richieste di ogni abitante, nel
    `TradePanel`; 9 abitanti in `NpcData` (i nuovi arrivano con gli stadi; la Vecchia Radice vive accanto all'Albero).
  - `SeasonsData` e `Seasons` — quattro stagioni di 3 giorni per mondo (chi nasce, crescita, eventi, cielo,
    creatura e materiale di stagione, geni `only: "stagione"` che le fermano).
  - `Board` e `BoardPanel` — la Bacheca dei Giardinieri: sempre 4 richieste costruite da ciò che il personaggio
    conosce (`Character.bacheca`), premi fino a Semi con un gene raro.
- **I suggerimenti** (`src/ui/tips/`, 27 set 2026, richiesta dell'utente): un motore solo per tutto il gioco.
  `Tips` (autoload `TipsLayer`: sceglie la scheda per il Control sotto il mouse o per la cosa del mondo, ritardo,
  posizione, aggiornamento; `Tips.attach(control, funzione)`, `Tips.set_world`, `Tips.shift`, `show_at`/`unpin` per
  le prove), `TipCard` (il contenuto: title, sub, stats, text, line, pair, bar, sep, hint; `plain()` per le prove),
  `TipView` (il disegno). Le schede: `ItemTip` (oggetti, con il confronto di Maiusc), `WorldTip` (creature, abitanti,
  oggetti a terra, alberi, colture, tessere, Sigilli, piante, nidi), `StationTip` (stazioni, casse, portali,
  Albero-Madre, Bacheca), `HudTips` (Vita e Linfa, orologio, obiettivi, riga dell'Albero, effetti, minimappa); parole e
  colori in `TipWordsData`. `TipsHook` (`src/game/`) collega la partita: `SlotView.context` (Bisaccia, oggetto in
  mano, prezzi del mercante) e la cosa sotto il mouse, solo dove la mappa è esplorata. I suggerimenti di Godot sono
  spenti (`gui/timers/tooltip_delay_sec` enorme): un `tooltip_text` qualunque diventa una scheda di sole parole.
  **Ricette e provenienza non vanno nei suggerimenti** (scelta dell'utente): stanno in Esamina.
  Ogni contenuto nuovo: se ha un campo che il giocatore deve capire, va letto anche nella sua scheda.
- **Opzioni e pausa** (27 set 2026): `OptionsData` (le opzioni come dati) e `KeysData` (i comandi); `Settings`
  (`v(id)`, `set_v`, `keys_of`; `for_tests` = valori di partenza senza scrivere il file); `Keys` (`pressed`, `held`,
  `label`, `help_text`: **mai `KEY_…` nel codice del gioco**, tranne Esc e i numeri); `OptionsPanel` e `PauseMenu` in
  `src/ui/`; `GameOptions` (`src/game/`) mette in pausa (`get_tree().paused`; interfaccia, suggerimenti, suoni con
  `PROCESS_MODE_ALWAYS`), l'ingrandimento, la minimappa, il contatore. Un'opzione nuova = una riga in `OptionsData` +
  chi la legge con `Settings.v`.
- **Enciclopedia** (27 set 2026): capitoli in `EncyGuideData`, `EncyCraftData`, `EncySeedsData` (BBCode con
  collegamenti `[url=cap:id]`, `cat:`, `item:`, `cr:`, `gene:`; `{numero}` e `{cat_…}` riempiti dai dati); `EncyPages`
  (pagine, ricerca, ciò che si conosce), `EncyCatalogs` (liste e cataloghi dai dati), `EncyPanel` (in `src/ui/ency/`),
  `Encyclopedia` (`src/game/`, tasto H e bottone). **Ogni voce nuova scrive o aggiorna il suo capitolo**; la prova
  `--solo=enciclopedia` controlla segnaposti e collegamenti. Capitoli delle Roadmap 9-11 in `EncyStoryData` (lingua,
  catene, luoghi, enigmi, Seme Nero) ed `EncyLawsData` (gruppi «Le leggi dei mondi» e «Senza fine»).
- **Roadmap 9 «Il mistero dei Seminatori»** (voci 68-72):
  - `LanguageData` (50 parole, indizi, pagine) e `Language` — le stele (`PassStele`, `SeminatoriArt`), le tavolette,
    le parole imparate in `Character.lingua`, i segni sulla mappa (`world_meta["segni"]`); `ReadPanel` in `src/ui/`.
  - `ChainsData` e `Chains` — la catena lunga (5 tappe fino al Seme Nero) e le brevi; le cripte dei Seminatori
    (`PassCatene`, da `Chains.pending`) e il leggio; il Taccuino nel Semenzaio (`view`, `records_text`).
  - `PlacesData` (luoghi scritti a mano come griglie di caratteri, fatte da `places_gen.py`), `PassLuoghi.build`,
    `Places`; `WorldView.refresh_rect` per ridisegnare una zona.
  - `Mechanisms` — gli enigmi (bracieri, leve, piastre, cristalli d'eco, porte `PORTA_SEM`), stazioni dei meccanismi.
  - `NeroData`, `NeroArt`, `PassNero` — il mondo dove cadde il Seme Nero e il suo Guardiano; la scelta (curato o
    spezzato) vale per tutti i mondi (`Character.seme_nero`, `Blight.tick`).
- **Roadmap 10 «Le leggi dei mondi»** (voci 73-78):
  - I liquidi: `World.liquid` (livello 0-8 nei 4 bit bassi, tipo nei bit 4-5), `LiquidsData` (acqua, Linfa, brace,
    reazioni), `Liquids` (automa a celle **solo attive e solo vicino al Germogliato**, livellamento del tratto
    appoggiato; nuoto, respiro, secchio; le pellicole sottili evaporano), `LiquidView` (z 12), `PassAcqua` (conche,
    mare del gene Sommerso, laghi nelle voragini dell'Arcipelago), `BhNuota`, `AquaArt`.
  - `WeatherData` e `Weather` — sei tempi scelti per stagione, biomi e geni: vento (`Player.wind`,
    `Projectiles.wind`), pioggia (acqua vera nelle conche), nebbia (`Behavior.fog`), fulmini, cenere, bufera.
  - `Gravity` — il peso del mondo (`Player.grav_mult`, `Creature.grav` per tutto ciò che cade) e le correnti
    ascensionali (`world_meta["correnti"]`, `Player.lift`); `PassGuscio` (tetto di roccia, pozzi di sole) e
    `PassArcipelago` (pilastri, voragini, isole). Sotto il tetto non piove (`Weather.roofed`).
  - `LivingData` e `LivingEarth` — Radici vive (ferite che si richiudono), Cristalli vivi, Frane; il tempo d'assenza
    (`world_meta["terra_t"]`, `["visto"]`) e l'avviso «Mentre eri via». Segnale `PlayerActions.dug`.
  - `WorldTimeData` e i geni del tempo in `DayCycle` (`day_len`, `eternal`, `sunless`, `eclipses`, `dark_grow`);
    `Background.eclipse` / `no_lights`.
- **Roadmap 11 «Senza fine»** (voci 79-82):
  - `VigorData` e `Vigor` — i gradi (vigore / 5), le indoli di grado (in `FamiliesData.make`, disegno in
    `VariantArt`), le Schegge, la tempra al Maglio (`Gear`: `dati.tempra`, danno, posti d'innesto, nome «+n»).
  - `GuardianGenData` e `GuardianGen` — i Guardiani generati «gg~<seme>» (riconosciuti da `CreaturesData.get_data`),
    usati da `Guardian.info` oltre il vigore 3; `Guardian._phase` (seconda fase: cambia elemento); Nuclei, talismani.
  - `LegendsData` e `Legends` — le leggende si riconoscono dai geni (`of_genes`), il Seme Primo (`give_primo`,
    `progress`), `Character.leggende`; `world_meta["primo"]` arriva dal portale come "nero".
  - `ChallengesData` e `Challenges` — i Sigilli di sfida sui portali, le regole (`PlayerActions.no_torches`,
    `Fauna.force_ancient`…), vittoria e record in `Character.sfide`, la riga sotto l'orologio.
- **Roadmap 12 «Il mondo si riempie»** (voci 83-99, 28 set 2026):
  - `Diary`/`DiaryData` (il diario, scheda «Storia» del Semenzaio), `tools/bilancio.gd` (numeri del gioco in
    prove/bilancio.txt). `SummonData`/`Summons` (Guardiani evocati al Cerchio).
  - `EffectsData`/`Effects` (effetti speciali: righe «quando × cosa»), `UniquesData` e `UniqueSeriesData` (151 unici in
    15 serie con premio per sempre, `UniquesData.roll` dai pool; generati da `tools/gen_unici.py`), `JewelsData`, dieci
    posti in `Bisaccia.EQUIP_SLOTS`.
  - `ZonesData`/`Zones` (totem: `mult_at`/`add_at`), `TrapsData`/`Traps` (trappole, leva), `FarmData`/`Farms` (esche,
    tramogge, nastri, Radice-ancora, tetto di rendita in `Fauna.loot_gate`), `FlightData`/`Flight` (ali nel posto del
    mantello; il volo in `Player._step`).
  - I biomi: `BodyArt` (creature da una ricetta: 7 piani del corpo), `TreeArtTemperate`/`TreeArtExtreme`,
    `TemperateDecorArt`/`ExtremeDecorArt`/`RareDecorArt` (vegetazione 46-79), `UnderBuilders` (forme del sottosuolo),
    `UnderBiomesData.pool_at` (creature che nascono sopra il loro pavimento). I rigori: `HarshData`/`Harshness`/
    `HarshBar` (freddo, sete, calore, polvere; protezioni `caldo`/`acqua`/`fresco`/`filtro`/`passo`, rimedi in `Boons`).
  - I segreti: `SecretsData`, `PassSegreti` (l'elenco, dagli appunti), `PassSegretiStanze` (pareti finte `FINTA`,
    stanze murate, passaggi, tesori, nidi), `PassSegretiAnomalie` (camere-enigma in `notes["camere"]`, visioni,
    anomalie), `Secrets` (contatore, premi, bacchetta, Eco, mappa del tesoro), `HiddenCreatures` (creature a
    condizione, pacchetto `src/data/hidden_creatures.gd`).
- **La guida del giocatore** (28 set 2026, richiesta dell'utente: il gioco è vasto, il giocatore nuovo si perde):
  `Filo` (`src/game/filo.gd`: in alto al centro una cosa da fare adesso, dalle fonti lista → Albero-Madre → obiettivi →
  Bacheca; tasto «filo» (J) per cambiarla; `FiloMarker` in `src/ui/` disegna il rombo sopra il posto o la freccia sul
  bordo, «giù» con lo strato), `Spesa` (la lista della spesa: «Segna» in Esamina, al più 3 ricette, ingredienti degli
  ingredienti fino a 3 livelli, `next_step` per il filo; esce dalla lista quando la si crea), `Consigli` + `ConsigliData`
  (una scheda la prima volta che succede una cosa nuova, una condizione `_c_<id>` per riga; mentre si vede il tasto
  dell'Enciclopedia apre il suo capitolo, `Encyclopedia.next_addr`; fermi nelle prove, `paused`). Tutto in
  `Character.guida`; opzioni «filo», «lista_spesa», «consigli»; capitolo «guida»; prove `--solo=guida` (foto 170, 171).
  Un contenuto nuovo che il giocatore deve scoprire da sé può aggiungere una riga a `ConsigliData`.
- **Roadmap 14 «Le acque vive»** (la pesca, dal 28 set 2026; scelte dell'utente: gesto quasi automatico, attività
  laterale ricca ma non indispensabile, in tutti i liquidi, liquidi spostabili dal giocatore): `WaterBody`
  (`src/world/`: lo specchio riconosciuto al momento, `ok` da `MIN_VOLUME` celle), `PassStagni` (stagni di superficie dal
  campo «stagni» dei biomi), `tools/specchi.gd` (la misura), prove `--solo=pesca` (`TestsFishing`). `LiquidTools` (otre,
  anfora, fonti: spostare i liquidi). `FishData` (i pesci: di tutti i mondi qui, quelli dei biomi nel campo «fish» dei
  file dei biomi; `pool`/`roll`; ogni pesce è anche un oggetto di tipo «pesce»); l'Erbario ha la scheda Pesci
  (`Erbario.add_fish`), fuori dalla percentuale. `Fishing` (il gesto: `cast`, attesa, `catch`; la lenza disegnata),
  `FishingData` (la Canna di radice e `rod_stats`, i valori della forma «canna» di `FormsData`; esche, accessori con gli
  effetti `fish_*` di `GearEffects`, il tempo, filetti generati, piatti, casse pescate, la fatica degli specchi); il
  Pescatore in `NpcData` (condizione «stat»); la serie «Tesori delle acque» in `UniqueSeriesData` (scritta a mano).
- **Roadmap 15 «Il mondo abitato»** (voci 126-151, 29 set 2026; scelte dell'utente: le creature rompono **solo le porte
  e solo negli assedi**, la schivata solo con gli oggetti, assedi una volta a stagione, niente pendenze né mezzi blocchi):
  - Le creature pensano: `Mind` (`src/entities/mind.gd`, uno per creatura: vista secondo la luce, udito `Mind.noise`,
    olfatto, memoria; stati calma/allerta/caccia/fuga/ritorno; `lead`, `flank`, `slot` per i gruppi) e `Senses`
    (`src/game/`: luce sul Germogliato, sangue, esca, passi); `Behavior.sees` passa dal cervello. Il segnale degli
    attacchi `TeleMark` («!» con `Creature.telegraph`, «?» in allerta); la schivata `Dodge` + `DashData` + `Player.try_dash`.
  - Le astuzie: 14 comportamenti in `src/entities/behaviors/` (sbuca, divide, ladro, mimetico, scudo, guaritore,
    richiamo, parassita, tuffatore, tessitore, rosicchia, fotofobo, pastore, scoppia) più marea, rimodella e correnti dei
    Guardiani; nome, segnale e contromossa in `WilesData`; ciò che tocca il mondo lo fa `Wiles` dalle richieste
    `Creature.acts` (furti, Linfa bevuta, ragnatele disegnate lì, porte rosicchiate solo con `Wiles.siege`, scoppi che non
    rompono blocchi; alla morte figlie, maltolto, gregge sbandato). Tattiche di gruppo in `Tactics`.
  - Il bestiario nuovo è **dati generati**: `tools/gen_bestiario.py` (righe in `tools/bestiario_sottosuolo.py`,
    `bestiario_tempo.py`) scrive `src/data/bestiary/{superficie,sottosuolo,tempo}.gd`; `tools/gen_signori.py` scrive
    `signori.gd`; `guardiani.gd` e `maree.gd` sono scritti a mano. Tutti in `BiomesData.PACK_FILES`. Campi nuovi delle
    creature: `under`/`uw` (biomi del sottosuolo, anche dai pacchetti), `water` + `liquid`, `season`/`weather`/`eclipse`
    (`CreaturesData.now_*`), `fury` (la furia dei boss a metà Vita), `lord`, `great`, `p.steal_fish`. Foglio dei disegni:
    `tools/bestiario.gd -- <file>`; misura degli ecosistemi `tools/ecosistemi.gd` (0 zone con buchi).
  - Signori (`Lords`, esca rituale nel suo luogo: `here()`), tre Guardiani scritti a mano (`GreatGuardians`: marea,
    pilastri che crollano da soli, raffiche/correnti/nuvole temporanee), le maree a ondate (`Tides` + `TidesData`:
    annuncio, ondate, capo, premio; l'assedio accende `Wiles.siege`, `world_meta["assedio"]`), lo studio (`Study`: gradi
    dell'Erbario, schede che si svelano, +6% di danno).
  - Costruire: i **costrutti** (`BuildData` forme × materiali, 27 × 9 = 243; una tessera `COSTRUTTO`/`COSTRUTTO_T` più il
    byte `World.build`, i colori in `World.tint`; atlante squadrato `BuildPainter`, strati a parte in `WorldView`;
    pareti da `BuildData.WALL_BASE`), `BuilderTools` + `BuilderData` (linea, area col tasto «area», scalpello del
    Martello, tinture, Tavola del progetto, i progetti dei Seminatori di `ProjectsData`), gli arredi in serie
    (`FurnitureData` × `FurnitureSeriesArt`; `StationsData.STATIONS` ora è `static var` = `_STATIONS` + arredi; il ruolo di
    una stazione con `StationsData.role`), le stanze (`Rooms` + `RoomsData`: riconoscimento, tipo, comfort, bonus,
    riparo `shelter`), le case degli abitanti (`Homes` + `HomesData`: felicità, prezzi `NpcBonds.mood_mult`, regali),
    gli ospiti (`Dwellers`: ragnatele, nidi sui tetti, alveari), la mandria di guardia (`Herd` stato «guardia», cucce).
  - Prove: gruppo «vivo» (`TestsAlive` per le creature, `TestsAliveBuild` per le costruzioni, `TestsAliveBeasts` per
    bestiario, Signori, maree, studio e tempi). Enciclopedia: `EncyWorldData` («Il mondo abitato»).
- **Roadmap 16 «Le Chiome del cielo»** (voci 152-169, 29 set 2026; scelte dell'utente: il cielo è sia uno strato in ogni
  mondo sia un gene, ci si arriva presto):
  - Le comodità: il tasto «riponi» (Q, `Storage._unhandled_input` → `quick_stack`) e lo **scavo intelligente**
    (`SmartDig`, `src/game/smart_dig.gd`, da `PlayerActions._process`: mai costruito, mai sotto i piedi, mai accanto ai
    liquidi, solo blocchi che toccano l'aria; tasto «vena» = stesso blocco). Opzioni «riponi_tasto», «scavo_intelligente».
  - Il cielo nei dati: `SkyData` (fasce basso/alto, zone lungo il mondo, `zone_at`, `band_at`, `pool_of`, `soft_under`) e
    i sei biomi come file `src/data/biomes/cielo_*.gd` (`BiomesData.SKY_FILES`, uniti ai pacchetti; campi in cima a
    `SkyData`: floor, isle, isles, pools, danger, thin, dark, ores, bolts, gusts, genes). Le tessere dei pacchetti hanno
    `pass` ed `emit` per la luce (`TileDefs.LIGHT_PASS/LIGHT_EMIT`, lette da `LightMap`: le nuvole lasciano passare la
    luce). Il pacchetto `src/data/sky_pack.gd` (oggetti, ricette, tessere della nimbite e della folgorite, pesci `fish`
    con `sky`, `tame`, `crops`, `wild`, `genes`, `gene_adj`, `loot`); le creature in `src/data/bestiary/cielo.gd`
    (righe in `tools/bestiario_cielo.py`, campi `sky` e `sw`, peso 0 fuori dal cielo).
  - Il generatore: `PassCielo` (zone → `World.sky`, salvato in `world_meta["cielo"]` da `Chiome`; isole per forma,
    radici pendenti, ponti di liane, pozze da pesca, vene, correnti del cielo negli appunti "correnti" con `cielo: true`)
    e `PassOsservatori` (la cupola del progetto «osservatorio» su un'isola alta per zona, scrigno «rovina_cielo», stele;
    i nidi delle famiglie del cielo, che `PassNidi` salta). Misura: `tools/cielo.gd`.
  - In partita: `Chiome` (`src/game/chiome.gd`: la scritta del bioma, `stats.cielo_max`, il Fagiolo di nuvola
    `plant_bean`/`grow_beans`, il Firmamento che fa notte con `DayCycle.high_dark`, `extra_dark` dell'Occhio, il tempo del
    cielo: fulmini dei Nidi, raffiche dei Giardini, l'arcobaleno dopo la pioggia) e `SkyStrikes` (`src/game/sky_strikes.gd`:
    il fulmine annunciato da una colonna di luce; lo chiedono «folgore» con `Creature.acts`, l'Occhio e i Nidi).
    L'aria sottile è il rigore «quota» di `HarshData` (protezione `quota`), presa dalla zona in `Harshness`. Le nuvole
    attutiscono le cadute (`Life._on_landed`). Tre comportamenti: `BhPicchiata`, `BhFolgore`, `BhDeriva`.
  - Il resto passa dai sistemi di prima: Signori del cielo (`where: {sky}` in `tools/gen_signori.py`, `Lords.here()`),
    l'Occhio della Tempesta (`guardiani.gd`, `GreatGuardians._place("tempesta")`), la marea «burrasca» (`TidesData`,
    campo `sky`), l'evento «arcobaleno» (`EventsData`, «speciale»), la nimbite (`MaterialsData`: 8 leghe, set), il
    cristallo celeste (28° e ultimo materiale di `BuildData`), le Ali di nuvola e della tempesta e la cavalcatura che vola
    (`FlightData.MOUNT_WINGS`, `mount_wings` in `HerdData.TAME`, letto da `Flight`), i pesci (`FishData.fits` con `sky`).
  - Prove: gruppo «cielo» (`TestsSky`, foto 212-220) e «comodita» (`TestsComfort`). Enciclopedia: `EncySkyData`.
- `src/game/boons.gd` (`Boons`) — effetti a tempo delle pozioni (bagliore, scorza) e luce del giocatore
  (`LightMap.player_light`, più forte con la Lanterna di Linfa in mano). Non si salvano.
- `src/game/building.gd` (`Building`) — piazzare e riprendere stazioni e passerelle (`actions.build`); le stazioni
  `fixed` (Cuore, portale) non si riprendono.
- `src/game/day_cycle.gd` (`DayCycle`) — giorno e notte: `time` 0-1 (giorno di 20 min), `daylight()`, `is_night()`;
  imposta `LightMap.sky`, i colori dello sfondo (`Background.set_time`: sole, luna, stelle) e `Fauna.night`. `paused`
  nelle prove (mezzogiorno fisso).
- `src/game/interact.gd` (`Interact`) — smista i clic che `PlayerActions` non conosce (`use_hook`/`touch_hook`):
  Rugiada → `Guardian.cure_at`, Seme di mondo → `Portal.plant`; clic destro su portale, Cuore, ceste e scrigni
  (apre `ChestPanel` in `src/ui/`, che condivide la pila in mano con `BisacciaPanel`; Maiusc+clic con `quick_target`).
- `src/game/gear_effects.gd` (`GearEffects`) — effetti di ciò che si indossa (`acc` in `ItemsData`, anche sulle
  armature), dei tratti e dei set completi (`sets`), sommati da `_add`: corsa, salto, planata, cadute, alone, Vita,
  Linfa, spine, fortuna, scavo, ombra, danno, colpi, incantesimi, Scorza dei set; ricalcolati a ogni cambio della Bisaccia.
- `src/game/map_reveal.gd` (`MapReveal`) — mappa esplorata: segna viste le celle illuminate (`World.explored`) e le
  dipinge in un'immagine 1 pixel = 1 tessera; `MapPanel` in `src/ui/` (tasto M, rotella, trascinare, segni).
- `src/game/erbario.gd` (`Erbario`) — le scoperte del personaggio (`Character.erbario`: creature sconfitte con il
  conteggio, oggetti, pagine lette), `percent()`; `ErbarioPanel` in `src/ui/` (tasto L). Pannelli a schermo intero
  come questo vanno in `Hud.overlays` (così il mouse non scava mentre sono aperti).
- `src/game/objectives.gd` (`Objectives`) — obiettivi di `ObjectivesData` controllati ogni secondo, ricompense,
  i prossimi tre in alto a sinistra; `bump(stat)` per i conteggi del personaggio (`Character.stats`); `paused` nelle
  prove. In `main.gd` i moduli si montano con `_mount(nodo)` (una riga per modulo).
- `src/game/blight.gd` (`Blight`) — l'Avvizzimento: elenco delle tessere malate (cercato in un thread), contagio se il
  Guardiano dorme, ritiro se è curato, `purify(centro, raggio)`, `use_seed`; `surface_blighted(world, x)` per scritta,
  cielo e creature. `paused` nelle prove.
- `src/game/depth_watch.gd` (`DepthWatch`) — in che strato è il giocatore (con un margine sul confine): sfuma il
  chiarore della luce e mostra la scritta dello strato (`StratumBanner` in `src/ui/`).
- `src/game/crafting.gd` (`Crafting`) — regole della fabbricazione: stazioni a portata (5 tessere), ricette usabili,
  materiali bastano?, fabbrica. Gli ingredienti vengono dalla Bisaccia e dalle casse
  vicine (`pool`, `have`, `take`): ogni nuovo costo va contato con `have` e tolto con `take`, non con `Bisaccia.count`.
- `src/game/storage.gd` (`Storage`, dati in `StorageData`) — le casse (26 set 2026, richiesta dell'utente): le casse
  entro 10 tessere con «usa per creare» danno gli ingredienti (`Crafting.pool`); impostazioni per cassa in
  `world_meta["casse"]` (nome scritto sopra la cassa, usa per creare, tipo che raccoglie); Deposita tutto/simili,
  Rifornisci, Riordina (in `ChestPanel`) e «Nelle casse vicine» (nella Bisaccia). I pulsanti non toccano mai la barra
  rapida (tranne Rifornisci, che completa le pile). Prove `--solo=casse`, foto 99_casse.
  I **gradi delle casse** (28 set 2026) in `ChestsData`: sei da fabbricare (20-100 caselle, dal legno alla stellare) e
  tre da trovare nelle rovine (più grandi più si scende: `PassRovine`); `ChestPanel._layout` allarga la griglia (fino a
  15 × 7) senza coprire Esamina; disegno in `CompactArt._cassa`/`_trim`. Chi riconosceva «scrigno»/«cesta» usa
  `ChestsData.is_chest`/`is_found`. Foto 99_casse_arca.
  **Grandezza delle pile** (opzione `pile`): `ItemsData.stack_mult` (lo imposta `Settings`), negativo = infinite
  (`INFINITE_STACK`); ciò che non si impila resta 1; `SlotView.short_count` scrive «12,5k», «5M».
- `src/game/bisaccia.gd` (`Bisaccia`) — l'inventario: 40 caselle (prime 10 = barra rapida), `add`/`remove`/`count`/
  `room_for`/`take_one`/`swap_with`, equipaggiamento `equip` con `wear`/`scorza` (5 posti: elmo, corazza, gambali,
  `accessorio_1`, `accessorio_2`; `kind_of_slot`); la stessa classe con meno caselle fa da contenuto di ceste e scrigni, corredo iniziale (`STARTER`); si salva
  con il personaggio insieme a Vita e Linfa.
- `src/game/` — `session.gd` (autoload `Session`: personaggio e mondo scelti nel menu; non esiste negli script headless
  né in `--check-only`, dove «Identifier not found: Session» è normale), `main.gd` (solo montaggio; il mondo nuovo, la schermata
  d'attesa, la costruzione della scena e il salvataggio stanno in `MainBoot`, `main_boot.gd`: caricamento o
  generazione in un thread, nodi, camera, salvataggio automatico ogni 5 minuti, Esc = salva e torna al menu (con la
  Bisaccia aperta Esc la chiude soltanto),
  salvataggio alla chiusura della finestra), `Background`
  (cielo, radici del cosmo, colline e foreste che seguono la superficie sotto la visuale), `PlayerActions` (secondo
  l'oggetto in mano: scavo con controllo della forza, raccolta di decorazioni e torce, abbattimento degli alberi con
  l'ascia a ritmo di colpi, semina, piazzamento di blocchi e torce dalla Bisaccia), `grow_saplings` in main (ogni
  secondo i germogli si avvicinano all'albero; il tempo corre anche fuori dalla visuale); piazzare e riprendere
  stazioni (mouse sul bordo in basso al centro) e passerelle,
  `AutoTests` (prove automatiche).
- `tools/` — strumenti da riga di comando (`mappe.gd`, `prova_salvataggi.gd`, `verifica_dati.gd`, `impronta.gd`:
  l'impronta di tutto il contenuto e di due mappe in prove/impronta.txt, da confrontare prima e dopo un riordino).
- Il giro intero prepara all'inizio, in parallelo, tutti i mondi delle prove pesanti (`TestKit.prefetch`, con i
  `jobs()` di ogni file di prove); `gen_many` li prende dalla cache. Una prova nuova che genera mondi aggiunge i suoi
  lavori a `jobs()` e alla riga di `prefetch` in `AutoTests`.

## Ordine del codice

- **Un file, una responsabilità.** Sopra le ~400 righe un file va diviso; `main.gd` fa solo montaggio.
- **Dati separati dal codice**: contenuti (tessere, oggetti, creature, ricette, biomi…) in `src/data/`, mai sparsi nella logica.
  Dopo ogni contenuto nuovo: `tools/verifica_dati.gd` deve dire «0 errori» (gli avvisi vanno letti e capiti).
- **Il generatore cresce a passate**: una cosa nuova nel mondo = un file nuovo in `gen/passes/` + una riga in `WorldGen.passes()`.
- `class_name` per ogni script riusato; cartelle per argomento, non per tipo di nodo.
- Commenti in italiano che spiegano il perché; nomi del codice brevi e chiari.
- **Git**: un commit per ogni passo compiuto (voce o parte di voce della Roadmap), messaggio in italiano che dice cosa e
  perché. Ignorati: `.godot/`, `prove/`, `mappe/`, `build/`.

## Lezioni già imparate

- `rendering/viewport/hdr_2d` è attivo (serve al bagliore): la grafica 2D lavora in spazio lineare, quindi l'immagine
  della luce va codificata con `linear_to_srgb()` o il buio si raddoppia.
- Colori di base troppo scuri + luce = tutto nero: le tavolozze di roccia e terra devono essere di tono medio; le pareti
  di fondo circa al 50% delle tessere.
- Un blocco che tocca l'aria prende quasi la luce dell'aria davanti, altrimenti le facce delle grotte risultano più scure
  delle pareti dietro.
- In un .bat, `"%~dp0"` finisce con `\` e rompe le virgolette: usare `cd /d "%~dp0"` e poi `--path .`.
- GDScript regge bene i cicli grandi (3 milioni di letture di rumore in ~0,45 s), ma le chiamate di funzione nei cicli
  interni costano: nel calcolo della luce i passaggi sono scritti in linea su array locali.
- Salvare il mondo intero compresso (0,5 MB) è meglio di seme + modifiche: non dipende dalla versione del generatore,
  che cambierà spesso, e caricare (17 ms) è molto più rapido che rigenerare (5,5 s).
- Contorni morbidi senza cambiare la logica: la «doppia griglia» (16 forme per strato) tiene scavo e collisioni sulle
  tessere quadrate. Le collisioni restano squadrate: i bordi disegnati coincidono con i lati delle tessere a metà strada.
- Nelle prove con finestra non aspettare `RenderingServer.frame_post_draw`: a volte non arriva e la prova resta ferma
  (successo anche in Inkblood). Si aspettano 4 `process_frame` prima di leggere l'immagine della finestra: con 2 a
  volte l'immagine era di qualche fotogramma prima (la Bisaccia appena aperta non compariva).
- Il generatore usa un solo `rng` per tutte le passate: cambiare una passata sposta anche ciò che viene dopo (torce,
  decorazioni). Le prove non devono dipendere da un punto preciso del mondo: cercano il primo candidato valido.
- Il movimento calcolato a ogni fotogramma deve dare lo stesso risultato a ogni frequenza: con il semplice «velocità
  per tempo» il salto era 3,31 tessere a 60 fps e 3,22 a 144 (il muro di 3 blocchi non si superava più). Si usa la
  velocità media del passo; le prove misurano a 60 e a 144 fps, e contano il tempo in secondi, non in fotogrammi.
  Vale per **ogni** attesa di qualcosa che dura un tempo (una rara che svanisce, un seme ricurvo che torna, un salto,
  un oggetto che vola nella Bisaccia): a volte il gioco gira senza sincronia verticale (130-540 fotogrammi al secondo)
  e le attese a fotogrammi finivano troppo presto (26 set 2026). Si prova con `--disable-vsync`. Le attese a
  fotogrammi vanno bene solo per lasciar disegnare lo schermo.
- Gli alberi si disegnano una volta per combinazione (specie × grandezza × forma, solo le specie dei biomi del mondo,
  all'avvio: ~15 ms l'uno) e si riusano (disegnarne uno per albero costava secondi).
- Dopo molti `snap_to` di fila (e con vsync spento) la foto della finestra arrivava in ritardo anche di secondi (mostrava
  la scena di prima): `TestKit.save` ora chiama `RenderingServer.force_draw(false)` prima di leggere l'immagine.
- L'immagine della luce (moltiplicazione) scurisce anche lo sfondo: il colore del cielo va diviso per la luce che
  gli cade sopra (`DayCycle.apply`), altrimenti al tramonto il cielo diventa nero.
- Ogni modulo che lancia un lavoro in `WorkerThreadPool` e poi ne legge o scrive i risultati nel proprio nodo deve
  aspettarlo in `_exit_tree()`: uscendo subito dopo un caricamento (menu, portale, chiusura) il nodo spariva con il
  thread ancora al lavoro e il gioco si chiudeva con un errore di memoria (trovato dalla prova del viaggio).
- Una funzione anonima collegata a un timer non deve trattenere un nodo che può sparire prima: si usa `weakref`
  (altrimenti «Lambda capture was freed»). E nei file del gioco i tipi dedotti da un Variant sono errori: `var x: T =`.
- Il buio (deciso dall'utente il 25 set 2026: «il buio non c'è, le torce non servono», poi con un'immagine di
  riferimento: «dove la luce non arriva deve essere completamente buio»): chiarore di fondo nero pieno e soglia di
  taglio `LightMap.CUT` (0,1): la luce cala a ogni tessera ma non arriva mai a zero, e senza soglia la sua coda lunga
  lasciava vedere tutto per 20-30 tessere. Luce che perde il 12% per tessera d'aria, alone del giocatore piccolo, nessuna
  torcia già accesa nel mondo. Il 24 set le grotte erano state schiarite perché i colori di base erano troppo scuri:
  quello resta vero (tavolozze di tono medio), ma la leggibilità viene dalle luci, non dal chiarore di fondo.
  La curva finale della luce è `pow(v, 0.85)`: con 0,7 il buio veniva sollevato al 25-35%.
- Le trame delle pareti nascono dalla tavolozza scurita: i colori fissi (vene, scintille) vanno ricavati dalla
  tavolozza, altrimenti sulle pareti si vede la ripetizione ogni 64 pixel.
- I Control figli di un CanvasLayer (HUD) non prendono la misura dalle ancore se vengono creati prima di entrare
  nell'albero: la misura va presa da `get_viewport_rect()` quando si mostrano (scritta degli strati, mappa).
- I suggerimenti (tooltip) compaiono in una finestrella a sé che non eredita il tema della finestra principale:
  il loro stile si scrive nel tema predefinito del motore (`GameTheme.apply`, chiamato da `Session._ready`).
  Nelle prove un suggerimento compare solo con un evento di movimento del mouse (`Input.parse_input_event`).
- Il JSON rilegge i numeri come decimali e riordina le chiavi: dopo il caricamento si riconvertono gli interi, e
  i dizionari si confrontano con `==` (non con `str()`).
- Una prova che cerca un posto adatto deve dire ad alta voce quando non lo trova («ATTENZIONE: …»): cambiando la
  grotta di prova per il buio, la prova di scavo è stata saltata in silenzio per diversi cicli.
- Le prove che mettono qualcosa «a N tessere» devono usare `world.surface[x]` di quella colonna: il terreno piano
  vicino alla partenza è corto e il bersaglio finiva dentro la terra.
- Il tratto piano vicino alla partenza le prove precedenti lo occupano con le stazioni: `TestKit.flat_spot` accetta un
  dislivello di una o due tessere, e chi deve piazzare stazioni spiana prima il terreno (`TestKit.flatten`). Con la
  barra rapida piena un oggetto va portato in mano con `TestKit.hold`, non cercato solo nella barra.
- Chi viene spostato di colpo (specchio, rinascita, prove) mentre è in aria atterrava contando tutto il viaggio come
  una caduta e appassiva: ogni spostamento passa da `main.snap_to`, che chiama `Player.reset_fall`.
- Non chiamare una proprietà di un nodo `hidden` (è un segnale di CanvasItem: «Cannot assign a new value to a
  constant»): per le creature nella terra si usa `buried`.
- Dopo ogni file nuovo con `class_name` va rifatto `--import`, anche prima di `--prove`: altrimenti «Identifier not
  declared» e le prove partono a metà.
- Nelle patch Python scritte dentro un heredoc del Bash tool i `\\n` diventano a capo veri dentro le stringhe
  GDScript: le patch si scrivono su file con Write. Per scovare stringhe spezzate: righe con un numero dispari di
  virgolette.

- Un bioma in più cambia la forma di tutto il mondo di prova: nel giro lungo tre prove sono cadute (casa, seme ricurvo,
  scavo) perché il loro posto era occupato o diverso. Le prove sgomberano e spianano il loro posto prima di usarlo;
  un mondo senza specie ha sempre tutti i biomi (`PassBiomi._ensure_all`), altrimenti il mondo di prova perde un bioma.
- Il fotogramma lento del giro lungo (75-120 ms, 26 set 2026): ogni oggetto raccolto cambia la Bisaccia, e il pannello
  Creare, **anche chiuso**, rifaceva a ogni cambio l'elenco delle ricette dei banchi a portata. Alla partenza le prove
  avevano piazzato tutti i banchi: una raccolta costava 103 ms (0,4 ms ora). I pannelli ascoltano `Bisaccia.changed`
  segnando soltanto «da ridisegnare» e si ridisegnano in `_process`, una volta per fotogramma e solo se si vedono.
  L'elenco Creare **riusa le sue righe** (`RecipeRow` in `src/ui/recipe_row.gd`, una per ricetta, preparate poche per fotogramma a Bisaccia
  chiusa; stili condivisi; suggerimento scritto solo al passaggio del mouse): rifarlo costa 9 ms invece di 106, e la
  prima apertura 43 ms invece di 206.
  Trovato con `FrameProbe` (in `src/game/tests/`): una sonda dopo ogni figlio della scena di gioco dice quanto ha
  preso ogni modulo nel fotogramma peggiore della corsa; `--solo=raccolta` rifà il caso (mucchio di 20 oggetti con
  tutti i banchi attorno). Nello stesso giro: gli oggetti fermi a terra non rifanno la fisica e non chiedono posto
  alla Bisaccia se sono lontani (300 oggetti: da 6,6 a 0,85 ms per fotogramma).

- Grafica con Nano Banana (26 set 2026): non sa disegnare a pixel grossi e, se gli si chiede di rimpicciolire
  un'immagine data, restituisce la stessa. Si fa disegnare in grande (forme grandi, viso scoperto, occhio grande:
  progettato per essere piccolo) e pixela lo script, uguale per tutte le pose. Le modifiche mirate riescono se piccole
  (germoglio più piccolo, colore dell'occhio), non le girate del corpo. Le animazioni sottili (respiro) non si chiedono
  a Nano Banana: le sue pose differiscono più di un pixel e tremolano. Un colore d'accento deve essere unico nella
  figura (l'occhio oro #F0D848), altrimenti lo script lo confonde con la tunica.
- Una cartella con immagini che il gioco non usa va segnata con `.gdignore`, altrimenti Godot le importa e finiscono
  nel gioco esportato (succedeva con `prove/` e con i disegni grandi di `arte_ia/`).

- Una prova che cambia uno stato condiviso (il controllo del Germogliato, un accessorio, la velocità del gioco) deve
  rimetterlo com'era, non a un valore fisso: la prova dei movimenti rimetteva il controllo alla tastiera e tutte le
  prove dopo, che muovono il personaggio con i comandi simulati, lo trovavano fermo (26 set 2026).
- Prima di lanciare il giro lungo, sempre il controllo di sintassi: una prova che non compila ferma il giro a metà
  senza chiudere il gioco (26 set 2026: fermo 13 minuti). Il giro si lancia con `timeout`.
- Un test che finisce «sparito» senza una morte vista: chiedersi se il Germogliato è appassito ed è rinato al letto
  (26 set 2026: la caccia falliva nel giro lungo perché arrivava con poca Vita). Le prove che durano partono con la
  Vita piena, e annotano chi toglie le creature (`Fauna.killed`, `Vitals.died`).
- Un nodo aggiunto con `add_child` riprende a lavorare: `set_process(false)` va chiamato **dopo** `add_child`.
- La musica: se il brano da suonare è fermo del tutto riparte (`Musica._process`); un blocco di qualche secondo
  (generazione di un mondo) poteva farlo finire senza che il ricominciare lo vedesse.

- Due voci che toccano gli stessi file non si scrivono insieme prima del commit della prima: la 41 e la 42 sono finite
  in un commit solo (26 set 2026). Il lavoro della voce dopo si prepara in file nuovi o in patch tenute da parte, e si
  applica dopo il commit.
- La varietà dei mondi si misura, non si indovina: un Seme con soli geni «in gioco» (fauna, cielo…) dava la stessa mappa
  di un altro (distanza sotto il rumore). Ogni Seme trovato ha un gene di forma, grotte o sottosuolo, e i biomi del
  sottosuolo sono stati ingranditi finché si vedevano sulla mappa. Soglia: la coppia di mondi più simile ad almeno il
  doppio del rumore (`tools/mappe.gd -- --caso`).
- Le prove che piantano un Seme di mondo mettono prima un'Aiuola (`TestKit.aiuola`): a terra non si pianta più.
- Un nome di forma d'icona già usato da un altro oggetto dà a tutta la famiglia la vecchia icona (il martello nuovo
  usciva uguale in tutti i metalli): le forme nuove guardano il foglio prove/89_forme.png, e `FormsData` ha `icon`.
- Un effetto applicato prima di `take_hit` può essere cancellato da `take_hit` stesso (lo stordimento del Vapore
  tornava a 0,2 s): i valori «almeno tanto» si scrivono con `maxf`.
- Nelle patch Python dentro un heredoc del Bash tool le tabulazioni e le barre rovesciate non arrivano sempre uguali:
  le patch con codice GDScript si scrivono con Write, sempre (anche le piccole). Una riga che finisce con «\\» dentro
  un heredoc sparisce: la continuazione diventa una riga sola (successo il 27 set 2026 in `VariantArt`).

- Un `PackedByteArray` passato a una funzione è una **copia** (copia alla scrittura): le modifiche fatte dentro non
  tornano indietro. Nei liquidi i cambi si raccolgono e si applicano in linea (27 set 2026).
- Il mouse del sistema nelle prove non è affidabile: per i Control si usa `TestKit.hover`, per le schede del mondo
  `Tips.mouse_at` (27 set 2026).
- Lavorando a più voci insieme, **mai `git add -A`**: i file nuovi delle voci dopo finiscono nel commit sbagliato
  (successo due volte il 27 set 2026). Si fa `git add -u` più i file nuovi della voce, per nome; i file delle voci dopo
  si tengono fuori dal progetto (anche perché una prova che non compila ferma il giro).
- Prima di aggiungere un gene si cerca se il nome c'è già (`grep '"nome":'`): «eclissi» esisteva, e il dizionario
  con due chiavi uguali non compila (27 set 2026). Meglio arricchire il gene vecchio.
- Un fotogramma peggiore di 33 ms con gli script a 2 ms è un'attesa del disegno (vsync mancato, due fotogrammi da
  16,7): la sonda lo dice («disegno, fisica e il resto»). Si riprova prima di cercare un colpevole nel codice.

- Una prova che usa il mouse vero sul mondo (suggerimenti) lascia prima andare i tasti: nel giro lungo un tasto
  restava «premuto» da una prova di prima, e con un tasto premuto le schede del mondo non compaiono (27 set 2026).
- Una prova che tocca una cella per il suo tipo (Provetta: cielo, flora…) la cerca con `category_at`, non la
  indovina con uno scarto fisso: sopra un albero la prova delle stagioni falliva una volta ogni tanto.

- Il mouse vero del sistema non è affidabile nelle prove: dopo `warp_mouse` arrivano movimenti veri, e la finestra
  può avere un'altra misura dello schermo di gioco (1600×900). Per i controlli si usa `TestKit.hover` (converte con
  `get_final_transform`); per le schede del mondo `Tips.mouse_at` (un punto fisso) (27 set 2026).

- **Mai chiamare `_input` (o `_unhandled_input`) una funzione collegata a `gui_input`**: sono metodi che il motore
  chiama per OGNI evento del gioco; con `accept_event` le mille caselle ricetta si mangiavano tutti i clic di tutti i
  menu (28 set 2026). E `z_index` cambia solo il disegno: i clic seguono l'ordine dei nodi (`Hud.bring_panel_forward`).
  Le prove che chiamano le funzioni dei pulsanti non vedono questi guasti: `TestsClicks` (nel gruppo «base») clicca
  davvero con `TestKit.click`.

- Le tabelle comuni che si riempiono dai file dei biomi sono `static var` inizializzate al caricamento della classe: i
  file dei biomi e `BiomesData` **non nominano nessun'altra classe** (valori scritti per esteso), altrimenti un giro di
  dipendenze le lascia a metà a seconda di chi si carica prima (28 set 2026: la mappa dei colori perdeva un'erba solo
  in `tools/mappe.gd`). Le prove non devono dipendere da quali famiglie sono assenti nel mondo di prova (cambiano con
  ogni famiglia nuova): la prova delle stagioni misurava un rapporto con una specie «assente».

- **Id doppi nei pacchetti** (Roadmap 15, 29 set 2026): l'unione delle tabelle (`merge`) tiene il primo, e un oggetto o
  una creatura di un pacchetto con l'id di un altro spariva in silenzio (sette oggetti, e la «libellula_rigoglio» delle
  stagioni con un campo `season` di tipo diverso che rompeva `Sampling`). `verifica_dati` ora controlla i nomi di ogni
  pacchetto; prima di dare un id nuovo si cerca (`grep '"id"'`).
- I parametri dei comportamenti hanno i loro nomi (`rate`, `fan_n`, `fan_rate`, `blink_every`…): un dato con un nome
  inventato viene ignorato senza errori. Si guarda `c.p.get(` nel comportamento prima di scrivere i dati.
- Le prove che cercano un posto «piano» (`kit.flat_spot`) possono non trovarlo quando le prove prima hanno costruito:
  si ricade sulla cella del Germogliato, e quando serve si costruisce il posto (stanza, porta) invece di cercarlo.
- Un comando Bash troppo lungo (un heredoc di centinaia di righe) fallisce con «ENAMETOOLONG»: i dati lunghi si
  scrivono con Write in un file e si importano.
- Nelle patch Python, `rindex(']')` per trovare la fine di un elenco trova l'ultima parentesi del file (anche dentro una
  funzione): si cerca la fine dell'elenco a partire dalla sua costante.

- **`Character.stats` tiene solo numeri** (Roadmap 16, 29 set 2026): il caricamento li rilegge con `int()`, e un
  dizionario messo lì («cieli_visti») rompeva il personaggio al primo salvataggio. Più cose = più chiavi numeriche
  (`cielo_<bioma>` = 1).
- Un campo dei pacchetti ha **un solo tipo in tutti i file**: `BiomesData.pack(k)` fonde i dizionari di tutti, e «adj»
  era un elenco nei biomi e un dizionario nel pacchetto del cielo (errore di `merge`). Per un significato nuovo, un nome
  nuovo (`gene_adj`).
- Le prove che muovono il Germogliato con `auto_dir` tolgono prima il controllo alla tastiera (`player.control =
  false`) e lo rimettono com'era: altrimenti il comando simulato è ignorato, e la prova passa o no per caso.
- Le attese delle prove si calcolano dai dati: una corrente di 120 tessere sale per 8 s, e il limite fisso di 8 s
  faceva fallire la prova proprio all'arrivo.
- Una struttura costruita **dentro** il posto di un'altra (l'osservatorio sull'isola) non fa `claim`: il collaudatore la
  vede sovrapposta. Il posto lo tiene già la struttura che la contiene.
- `Sky` è una classe del motore: un `class_name` con lo stesso nome non compila («hides a native class»). Nomi
  dell'universo anche per le classi (`Chiome`).
- Le tabelle scritte con `const` non si allargano dai pacchetti: diventano `static var X = _X.merged(BiomesData.pack(...))`
  (`HerdData.TAME`, `CropsData.CROPS/WILD`), e chi le legge non cambia.

## Convenzioni

- Tutto il testo visibile in italiano con accenti veri (à è ì ò ù).
- GDScript: tipi espliciti quando il valore viene da Array/Dictionary non tipizzati; `floorf/roundf/floori` invece di
  `floor/round` quando serve un tipo preciso; non chiamare variabili `seed` (nasconde la funzione globale).
- Il Bash tool fallisce con heredoc contenenti apostrofi/accenti: per patch in Python scrivere lo script su file.
- ROADMAP.md va aggiornato sempre: stato della voce ([ ] / [~] / [x]) e riga «fatto il …» con cosa è stato fatto.
- Dopo ogni modifica alla logica: prove automatiche (`-- --prove`) e controllo degli screenshot.

- `WorkerThreadPool`: i lavori a bassa priorità hanno solo una parte dei thread (3 su 12), e la luce, la mappa e i
  suoni li usano. Un lavoro lungo delle prove messo a bassa priorità faceva aspettare la luce: il gioco sembrava
  fermo (28 set 2026). I lavori lunghi di preparazione vanno ad alta priorità. E non si aspetta mai un Group ID che
  potrebbe non esistere: `is_group_task_completed` su un ID non valido non diventa mai vero (ciclo infinito).
- Una scritta con suggerimento (mouse_filter PASS) o uno sfondo a tutto schermo prendono i clic destinati ai
  pannelli: gli sfondi hanno `MOUSE_FILTER_IGNORE`, e con la Bisaccia aperta `Hud.bring_panel_forward` spegne il
  mouse delle scritte dell'HUD. Una prova che chiude un pannello lo chiude con la sua `close()`, mai con
  `visible = false`: la prova delle reliquie lasciava «Creare» nascosto per tutte le prove dopo (28 set 2026).
- **Mai `git add -u` né `-A`** quando un'altra sessione può lavorare sullo stesso progetto: il 28 set 2026 due immagini
  della Roadmap 13 (fatta da un'altra sessione nello stesso momento) sono finite in un commit del generatore. Si
  aggiungono i file per nome, e prima del commit si guarda `git show --stat`.
- Una tavola (`TileSetAtlasSource`) costruita in un thread va costruita con `use_texture_padding = false` e il bordo
  riacceso nel thread principale a tavola finita: a ogni tessera aggiunta il motore rifà il bordo nel thread principale
  e leggeva le tessere mentre il thread le stava ancora aggiungendo («no tile at (101, 16)», una volta su cinque). E
  aggiungere tessere a una tavola costa sempre di più (il motore le riordina a ogni aggiunta): le tavole grandi si
  fanno una volta per sessione.
- Fare in parallelo non rende sempre più veloci: i 120 alberi di un mondo su 12 processori ci mettevano 3,4 s invece
  di 1,8 uno alla volta (qualcosa di condiviso li fa litigare). Si misura sempre prima e dopo.
- Un thread in sottofondo che il thread principale poi **aspetta** (`ViewArt`, generazione) fa solo lavoro di puro codice:
  niente `load()` di file. Il 28 set 2026 le stazioni cominciarono a caricare i disegni di Nano Banana e il mondo non si
  apriva più (il thread aspettava il principale, il principale aspettava il thread). Chi aggiunge file a un pittore
  controlla se quel pittore gira in un thread.
- `String(x)` con un numero è un errore: per un campo che può essere numero o testo («place» è un numero per i blocchi)
  si usa `str(x)`. Trappole e totem lo sbagliavano a ogni fotogramma con un blocco in mano.
