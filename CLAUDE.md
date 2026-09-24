# TERRAWORLD

Gioco d'esplorazione e costruzione a tessere ispirato a Terraria, in Godot 4.6.1. Stesso metodo di lavoro di Inkblood Arena
(`Desktop\CLAUDE\AUTOBATTLE GODOT`): contenuti come dati, strumenti di verifica, screenshot automatici, Roadmap a voci piccole.
Solo PC, solo italiano. Obiettivo: profondità e longevità altissime (esplorazione, equipaggiamento profondo, obiettivi sempre nuovi).
Documenti: `UNIVERSO.md` (ambientazione «Il Giardino dei Semi»), `ROADMAP.md` (lavori in corso e fatti).

## Decisioni di base (24 set 2026, scelte dall'utente)

- **Mondi a portale**: un mondo casa più una serie infinita di mondi generati, finiti, con tema e difficoltà crescenti.
  Nell'universo: ogni mondo nasce da un Seme piantato nel Giardino (specie, vigore, tratti = parametri del generatore).
- **Mondi medi**: 3000×1000 tessere da 16 px.
- **Rete a 2 giocatori** (single player giocabile con un amico in collegamento diretto), host autoritativo come in Inkblood.
- **Grafica**: la base è generata dal codice (tessere, luce, effetti, icone in serie, creature semplici); personaggio con tutte
  le animazioni, alcuni mostri e boss arriveranno da immagini generate dall'utente con un'IA grafica (Nano Banana),
  importate con script come in Inkblood (sfondo magenta, griglia fissa, riduzione a una tavolozza comune).
- **Stile grafico tutto nostro: «Radici e Linfa» con terreno dai contorni morbidi** (scelto e approvato dall'utente il
  24 set 2026, dopo il suo appunto: «questo non è Terraria, lo stile era identico»). Mondo scuro e profondo dove la luce
  viene dalle cose vive; terra prugna intrecciata di radici, ardesia blu, muschio turchese, ambra e Linfa turchese come
  accenti; alberi-lanterna a salice con baccelli luminosi; cielo turchese-corallo attraversato dalle radici del cosmo;
  il Germogliato con capelli di foglie, tunica ocra e occhi d'ambra che brillano al buio. **Mai tornare a tessere quadrate
  con contorno, terra marrone + erba verde, chiome tonde: sono la firma di Terraria.**
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
# prove automatiche con finestra (~25 s): screenshot in prove/ (01_superficie, 02_grotta_torcia, 03_cristalli, 04_scavo,
# 05_dopo_la_corsa, 06_muro_3_blocchi), misura del movimento (velocità, salto pieno in tessere, muro di 3 blocchi da
# scavalcare) e dei fotogrammi durante una corsa in superficie (obiettivo: 60 fps, fotogramma peggiore < 25 ms)
# Le prove usano user://prove_salvataggi (personaggio «prova», mondo «mondo_prova» rigenerato ogni volta) e alla fine
# salvano dal gioco e ricaricano: il mondo su disco deve risultare «identico».
Godot_console.exe --path . -- --prove            # --carica riapre il mondo di prova salvato invece di rigenerarlo;
                                                 # --senza-luce per vedere i colori senza il buio
# foto delle schermate del menu in prove/ (menu_titolo, menu_personaggi, menu_nuovo_mondo)
Godot_console.exe --path . -- --foto-menu
# prova dei salvataggi senza finestra: salva, ricarica, confronta, rovina il file e recupera dalla copia di sicurezza
Godot_console.exe --headless --path . --script res://tools/prova_salvataggi.gd
# verifica dei contenuti (tabelle di src/data/): riferimenti, ricette, bottino, progressione dei picconi, oggetti che
# non si possono ottenere; salva il foglio di tutte le icone in prove/oggetti.png. Obiettivo: «0 errori».
Godot_console.exe --headless --path . --script res://tools/verifica_dati.gd
# mappe dei mondi: mappe/mondo_<seme>.png a metà grandezza (--intera per 1:1), tempi per passata, conteggi per seme
Godot_console.exe --headless --path . --script res://tools/mappe.gd -- --semi 20 --da 1
```

## Struttura

- `src/core/` — attrezzi generici: `Px` (primitive di pixel art, contorno automatico), `Fx` (sfumature, polvere di scavo).
- `src/data/` — **solo dati** (voce 3):
  - `TileDefs` — tipi di tessera, durezza (`HARD`, secondi col rame), forza di piccone richiesta (`POWER`: il ferro vuole
    rame 35, l'oro ferro 45, i cristalli oro 55), cosa lasciano (`DROP`, `DECOR_DROP`), vene di minerale (`ORES`,
    lette da `PassMinerali`), strati del terreno, tavolozze, luce, decorazioni.
  - `ItemsData` — tutti gli oggetti (campi descritti in cima al file). Le famiglie di metallo (piccone, ascia, spada,
    elmo, corazza, gambali × rame, ferro, oro) nascono da `METALS` × `GEAR` in `all()`: un metallo nuovo = una riga.
    `DEMO_HOTBAR` = barra di prova finché non c'è l'inventario; `use_of(id)` = cosa fa il clic.
  - `RecipesData` (ricette, più quelle generate delle famiglie di metallo), `StationsData` (banco da lavoro, fornace,
    incudine), `CreaturesData` (statistiche, comportamenti, bottino, strati), `LootData` (tabelle e `roll`).
- `src/art/` — grafica generata dal codice:
  - `TerrainPainter` — terreno dai contorni morbidi con la **doppia griglia**: si disegna una griglia spostata di mezza
    tessera; ogni cella tocca i centri di 4 tessere e, secondo quali sono piene (16 combinazioni), traccia una forma
    curva (interpolazione morbida degli angoli + soglia con rumore = bordo irregolare). Uno strato per ogni voce di
    `TileDefs.TERRAIN_LAYERS` (ardesia = sagoma di tutto il terreno, humus, muschio, rame, ferro, oro, cristallo),
    disegnati uno sopra l'altro. Trame da 64×64 senza cuciture divise in 16 varianti (`variant_of`), così la trama
    continua da una cella all'altra. Minerali: solo noduli (trama bucata, alfa 0.9 = niente bordo di strato), si vede
    la roccia che li contiene. Atlante 4096×112.
  - `DecorPainter` — pareti (stesse trame da 64, più scure e fredde) e 14 decorazioni con la loro parte luminosa.
  - `ItemIcons` — icone 16×16 nello stile (manici di radice fasciati di foglia, lame a foglia, lingotti a seme, perle
    d'ambra): `make(forma, materiale)` o `of(id)`; il materiale sceglie la tavolozza.
  - `CharacterArt` (personaggio a pose, restituisce anche mano e occhio), `CreatureArt`, `NatureArt`
    (`tree_linfa` con parte luminosa, `root_arches`, `lantern_forest`, colline, torcia, sole).
- `src/world/` — il mondo:
  - `World` — solo lo stato (tessere, pareti, decorazioni, superficie, torce con indice a celle da 16, alberi per blocco).
  - `gen/` — il generatore: `WorldGen.passes()` elenca le passate in ordine, `GenContext` (seme, rumori per nome,
    parametri, appunti tra passate), `GenPass` (base). Passate in `gen/passes/`: Terreno, Strati, Grotte (profondità,
    regioni, grandi caverne), Ingressi, Minerali, Cristalli, Erba, Alberi, Decorazioni, Torce (prova, provvisoria), Partenza.
    Un mondo 3000×1000 si genera in ~5,5 s (in un thread, con schermata d'attesa).
  - `WorldView` — disegno a blocchi da 32×32: solo i blocchi vicini alla visuale esistono come nodi (1 costruito per
    fotogramma, liberati oltre 2 blocchi di margine); ogni blocco ha pareti (z -10) e decorazioni (z 1) sulla griglia
    normale, i 7 strati del terreno sulla doppia griglia (z 0, spostati di -8,-8), bagliore di cristalli e decorazioni
    (z 25), alberi (z -5, baccelli luminosi in z 26), torce e scintille. `refresh_around(c)` dopo uno scavo.
  - `LightMap` — luce in una finestra di 128×96 tessere attorno alla visuale, calcolata in un thread
    (`WorkerThreadPool`) su copie dei dati; ricentrata quando la visuale si sposta di 6 tessere, ricalcolata quando il
    giocatore cambia cella o `dirty` è vero. Immagine stesa sul mondo in moltiplicazione (`overlay` in main, z 20).
    `AMBIENT` = chiarore minimo freddo (le grotte si leggono anche lontano dalle torce); luce delle decorazioni in
    `TileDefs.DECOR_LIGHT`.
- `src/save/` — salvataggi: `SavePaths` (cartelle, scrittura sicura: file temporaneo → il vecchio diventa `.bak` →
  il nuovo prende il suo posto; lettura con ripiego sulla copia di sicurezza), `WorldSave` (mondo intero compresso ZSTD
  in `mondo.bin` ~0,5 MB, salvataggio ~15 ms, caricamento ~17 ms; `mondo.json` con nome, seme, date, tempo di gioco,
  partenza, posizione di ogni personaggio), `Character` (personaggio separato dai mondi, `personaggi/<id>.json`).
  Cartella: `%APPDATA%\Godot\app_userdata\TERRAWORLD\salvataggi\`. Le creature non si salvano: si rimettono con
  `PassPartenza.place_creatures`.
- `src/entities/` — `TileBody` (movimento contro la griglia, gradino automatico), `Player` (movimento a ogni fotogramma
  disegnato, a passi di al massimo 1/30 s; valori di base in cima al file: corsa 95 px/s, salto pieno ~3,3 tessere;
  `auto_dir`/`auto_jump` per le prove e i futuri bot), `Slime`.
- `src/ui/` — `menu.tscn`/`menu.gd` (scena iniziale: titolo, personaggi, mondi, creazione), `Hud` (barra rapida,
  segnale `selected`, `toast` per i messaggi brevi; barra in basso al centro), `MiningCursor`.
- `src/game/` — `session.gd` (autoload `Session`: personaggio e mondo scelti nel menu; non esiste negli script headless
  né in `--check-only`, dove «Identifier not found: Session» è normale), `main.gd` (solo montaggio: caricamento o
  generazione in un thread, nodi, camera, salvataggio automatico ogni 5 minuti, Esc = salva e torna al menu,
  salvataggio alla chiusura della finestra), `Background`
  (cielo, sole, nuvole, montagne che seguono la superficie sotto la visuale), `PlayerActions` (scavo, torce),
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
  (successo anche in Inkblood). Bastano due `process_frame` prima di leggere l'immagine della finestra.
- Il generatore usa un solo `rng` per tutte le passate: cambiare una passata sposta anche ciò che viene dopo (torce,
  decorazioni). Le prove non devono dipendere da un punto preciso del mondo: cercano il primo candidato valido.
- Gli alberi hanno 8 forme disegnate una volta sola e riusate (disegnarne uno per albero costava secondi).

## Convenzioni

- Tutto il testo visibile in italiano con accenti veri (à è ì ò ù).
- GDScript: tipi espliciti quando il valore viene da Array/Dictionary non tipizzati; `floorf/roundf/floori` invece di
  `floor/round` quando serve un tipo preciso; non chiamare variabili `seed` (nasconde la funzione globale).
- Il Bash tool fallisce con heredoc contenenti apostrofi/accenti: per patch in Python scrivere lo script su file.
- ROADMAP.md va aggiornato sempre: stato della voce ([ ] / [~] / [x]) e riga «fatto il …» con cosa è stato fatto.
- Dopo ogni modifica alla logica: prove automatiche (`-- --prove`) e controllo degli screenshot.
