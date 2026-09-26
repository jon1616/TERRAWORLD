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
  **Niente push** su un repository remoto finché non lo chiede (per ora «non ancora»).
- **Ogni passo**: si scrive (le modifiche lunghe con script Python scritti con Write, non con heredoc), controllo di
  sintassi di tutti i .gd cambiati, `--import` se ci sono `class_name` nuovi, prove del gruppo (`--solo=...`), poi il
  **giro completo** in sottofondo con un tempo massimo (`timeout 1200 ... -- --prove > log`, dura ~5 minuti) e un
  controllo che avvisi se si ferma; foto controllate a occhio; commit in italiano con la riga Co-Authored-By.
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
# prove automatiche con finestra (il giro completo dura ~5 minuti; nelle prime Roadmap erano ~25 s): screenshot in prove/ (01_superficie, 02_grotta_buia e 02_grotta_torcia con la
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
# solo alcuni gruppi di prove (per provare in fretta una voce nuova): doni, antiche, pericoli, combattimento, tratti,
# obiettivi, guardiani, rovine, mobilita, lanci, giardino, eventi, casa, abitanti, compagni, viaggio, semi,
# biomi, biomi_nuovi, luoghi, corsa, raccolta, musica, germogliato, interfaccia, geni, forme, ecologia, mandria, casse
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
# voce 43: genomi a caso (`--caso --vigore 7`) o fissi (`--geni cavo,fungaie`), con la misura della varietà in fondo
Godot_console.exe --headless --path . --script res://tools/mappe.gd -- --semi 12 --caso --vigore 7
```

## Struttura

- `src/core/` — attrezzi generici: `Px` (primitive di pixel art, contorno automatico), `Fx` (sfumature, polvere di scavo).
- `src/data/` — **solo dati** (voce 3):
  - `GuardiansData` — il Guardiano di ogni vigore (Nodo Avvizzito, Regina delle Spore, Colosso d'Ardesia, poi da capo),
    con la creatura, ciò che lascia curato e le sue pagine di storia.
  - `LoreData` — le pagine di storia (Cuore trovato, Guardiano sconfitto o curato, portale), mostrate da `LorePanel`.
  - `BiomesData` — i biomi di superficie (foresta-lanterna, paludi di spore, distese d'ambra, boschi di brina,
    cenerarie): erba, alberi, colline,
    altezza, tinta del cielo; `World.biomes` = un bioma per colonna (salvato). Creature con `biomes` compaiono in
    superficie solo lì.
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
  - `FloraData` — alberi e germogli: robustezza (100; ogni colpo toglie la forza dell'ascia), legno e semi che
    lasciano, tempo di crescita dei germogli, spazio richiesto.
  - `SpellsData` — gli incantesimi dei bastoni di Linfa (aspetto, velocità, ventaglio, quante creature attraversa,
    quanto insegue, se passa la roccia, luce).
  - `BeastItemsData` — materiali delle creature della voce 22 e ciò che se ne fa; uniti in `ItemsData.all()`.
  - `BiomeItemsData` — voce 40: materiali, set, armi, trofei e Semi dei Boschi di brina e delle Cenerarie (oggetti e
    ricette, uniti in `all()`).
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
  - `DecorPainter` — pareti (stesse trame da 64, più scure e fredde) e 14 decorazioni con la loro parte luminosa.
  - `IconShapes` — le forme d'icona nuove (dalla voce 21), chiamate da `ItemIcons` quando la forma non è sua.
  - `ItemIcons` — icone 16×16 nello stile (manici di radice fasciati di foglia, lame a foglia, lingotti a seme, perle
    d'ambra): `make(forma, materiale)` o `of(id)`; il materiale sceglie la tavolozza.
  - `StationArt` — Ceppo del Giardiniere, Baccello ardente (bocca di brace luminosa), Maglio dei Seminatori (rune);
    i banchi della voce 25 in `WorkshopArt`. Foglio di tutte le stazioni in prove/stazioni.png.
    Banchi, mobili e casse sono **bassi** (26 set 2026, appunto dell'utente: «troppo grandi»): alti una tessera
    (il Baccello ardente e il Telaio due, ma stretti), disegnati apposta in `CompactArt`. Le misure di prima stanno in
    `StationsData.OLD_SIZE`: `WorldSave` fa scendere al pavimento quelli dei mondi salvati prima (`stazioni_v`), e il
    generatore appoggia le casse al pavimento secondo la loro altezza.
  - `BossArt` — i tre Guardiani (Nodo, Regina, Colosso), malati o guariti, chiamati da `CreatureArt.frames`.
  - `BeastArt` (creature della voce 22 di superficie e Sottobosco, `spider` per i ragni) e `DeepBeastArt` (quelle del
    profondo), chiamate da `CreatureArt.frames` (2 fotogrammi, 3 per guscio e travestimento); `BiomeBeastArt` le
    quattro creature dei biomi della voce 40. Una tessera d'erba nuova: `TileDefs` (costante, `GRASSES`, tabelle,
    tavolozza, strato del terreno), `MapReveal`, suono di scavo in `PlayerActions`, `PassDecorazioni`.
  - `CharacterArt` (personaggio a pose, restituisce anche mano e occhio), `CreatureArt`, `NatureArt`
    (`tree_linfa` con parte luminosa, `root_arches`, `lantern_forest`, colline, torcia, sole).
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
    già accese della vecchia passata provvisoria sono state tolte il 25 set 2026: le torce le mette il giocatore). Un mondo 3000×1000 si genera in ~8,5 s (in un thread, con schermata d'attesa).
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
  `PassPartenza.place_creatures`.
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
  `SlotView` (casella riusabile con icona e quantità), `ExaminePanel` (casella «Esamina» in alto a sinistra della
  Bisaccia aperta: ci si posa un oggetto e compare la sua scheda di `ItemInfo` — a cosa serve, in quali ricette, come
  si ottiene; l'utente la vuole in uno spazio apposito, non nel suggerimento), `VitalsView` (foglie e gocce in alto a destra), colonna
  dell'equipaggiamento a sinistra della Bisaccia (elmo, corazza, gambali, Scorza totale), `CraftingPanel` (colonna «Creare», rifatta il 26 set 2026:
  alta tutta la destra dello schermo, bassa con una cassa aperta (`set_tall`); banchi vicini con le icone, dieci
  categorie colorate (`CraftCatsData`: nome, colore, tipi), ricerca per nome o ingrediente, «Solo possibili»; in
  «Tutto» gruppi per tipo con l'intestazione; lavorazioni del Maglio e del Telaio in cima; Maiusc+clic crea 5) con le
  righe in `RecipeRow` (una per ricetta, **un nodo solo che si disegna da sé** in `_draw`: con una decina di nodi per
  riga la prima apertura costava 90 ms; `refresh(possibile, conteggi)` con i conteggi di `Crafting.counts` fatti una
  volta per tutte le righe), `MiningCursor`.
- `src/game/vitals.gd` (`Vitals`) — Vita (100, foglie da 10) e Linfa (20, gocce da 2), Scorza (metà del suo valore
  tolta a ogni ferita), ricrescita della Vita dopo 6 s senza ferite, attesa di 30 s tra due pozioni; segnali `changed` e
  `died`. In main: ferite da caduta oltre 12 tessere (6 punti per tessera in più), appassire e rinascere alla partenza.
- `src/game/fauna.gd` (`Fauna`) — creature vive: comparsa per strato fuori dalla visuale (`try_spawn`, mai vicino alle
  torce), sparizione lontano, spari raccolti da `c.fire`, `kill` con bottino. `enabled` = falso nelle prove.
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
  materiali bastano?, fabbrica; `describe` per il suggerimento. Gli ingredienti vengono dalla Bisaccia e dalle casse
  vicine (`pool`, `have`, `take`): ogni nuovo costo va contato con `have` e tolto con `take`, non con `Bisaccia.count`.
- `src/game/storage.gd` (`Storage`, dati in `StorageData`) — le casse (26 set 2026, richiesta dell'utente): le casse
  entro 10 tessere con «usa per creare» danno gli ingredienti (`Crafting.pool`); impostazioni per cassa in
  `world_meta["casse"]` (nome scritto sopra la cassa, usa per creare, tipo che raccoglie); Deposita tutto/simili,
  Rifornisci, Riordina (in `ChestPanel`) e «Nelle casse vicine» (nella Bisaccia). I pulsanti non toccano mai la barra
  rapida (tranne Rifornisci, che completa le pile). Prove `--solo=casse`, foto 99_casse.
- `src/game/bisaccia.gd` (`Bisaccia`) — l'inventario: 40 caselle (prime 10 = barra rapida), `add`/`remove`/`count`/
  `room_for`/`take_one`/`swap_with`, equipaggiamento `equip` con `wear`/`scorza` (5 posti: elmo, corazza, gambali,
  `accessorio_1`, `accessorio_2`; `kind_of_slot`); la stessa classe con meno caselle fa da contenuto di ceste e scrigni, corredo iniziale (`STARTER`); si salva
  con il personaggio insieme a Vita e Linfa.
- `src/game/` — `session.gd` (autoload `Session`: personaggio e mondo scelti nel menu; non esiste negli script headless
  né in `--check-only`, dove «Identifier not found: Session» è normale), `main.gd` (solo montaggio: caricamento o
  generazione in un thread, nodi, camera, salvataggio automatico ogni 5 minuti, Esc = salva e torna al menu (con la
  Bisaccia aperta Esc la chiude soltanto),
  salvataggio alla chiusura della finestra), `Background`
  (cielo, radici del cosmo, colline e foreste che seguono la superficie sotto la visuale), `PlayerActions` (secondo
  l'oggetto in mano: scavo con controllo della forza, raccolta di decorazioni e torce, abbattimento degli alberi con
  l'ascia a ritmo di colpi, semina, piazzamento di blocchi e torce dalla Bisaccia), `grow_saplings` in main (ogni
  secondo i germogli si avvicinano all'albero; il tempo corre anche fuori dalla visuale); piazzare e riprendere
  stazioni (mouse sul bordo in basso al centro) e passerelle,
  `AutoTests` (prove automatiche).
- `tools/` — strumenti da riga di comando (`mappe.gd`, `prova_salvataggi.gd`, `verifica_dati.gd`).

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
- Gli alberi hanno 8 forme disegnate una volta sola e riusate (disegnarne uno per albero costava secondi).
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
  le patch con codice GDScript si scrivono con Write, sempre (anche le piccole).

## Convenzioni

- Tutto il testo visibile in italiano con accenti veri (à è ì ò ù).
- GDScript: tipi espliciti quando il valore viene da Array/Dictionary non tipizzati; `floorf/roundf/floori` invece di
  `floor/round` quando serve un tipo preciso; non chiamare variabili `seed` (nasconde la funzione globale).
- Il Bash tool fallisce con heredoc contenenti apostrofi/accenti: per patch in Python scrivere lo script su file.
- ROADMAP.md va aggiornato sempre: stato della voce ([ ] / [~] / [x]) e riga «fatto il …» con cosa è stato fatto.
- Dopo ogni modifica alla logica: prove automatiche (`-- --prove`) e controllo degli screenshot.
