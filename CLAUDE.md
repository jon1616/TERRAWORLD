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
- **Ordine del codice fin dall'inizio** (richiesta dell'utente: in Inkblood `main.gd` era arrivato a 17.000 righe) e **Git**
  dal primo giorno. Vedi «Ordine del codice» qui sotto.

## Comandi

Godot: `C:\Users\Principale\Desktop\GODOT\Godot_v4.6.1-stable_win64_console.exe` (`_console` per vedere stdout).

```bash
# avvio (anche con doppio clic su «Avvia prova.bat»)
Godot_console.exe --path .
# reimporta il progetto (dopo aver aggiunto file con class_name nuovi)
Godot_console.exe --headless --path . --import
# controllo sintattico di uno script
Godot_console.exe --headless --path . --check-only --script res://src/world/world.gd
# prove automatiche con finestra (~25 s): screenshot in prove/ (01_superficie, 02_grotta_torcia, 03_cristalli, 04_scavo,
# 05_dopo_la_corsa) e misura dei fotogrammi durante una corsa in superficie (obiettivo: 60 fps, fotogramma peggiore < 25 ms)
Godot_console.exe --path . -- --prove            # aggiungere --senza-luce per vedere i colori senza il buio
# mappe dei mondi: mappe/mondo_<seme>.png a metà grandezza (--intera per 1:1), tempi per passata, conteggi per seme
Godot_console.exe --headless --path . --script res://tools/mappe.gd -- --semi 20 --da 1
```

## Struttura

- `src/core/` — attrezzi generici: `Px` (primitive di pixel art, contorno automatico), `Fx` (sfumature, polvere di scavo).
- `src/data/` — **solo dati**: `TileDefs` (tipi di tessera, durezza, tavolozze, luce, colori della mappa), `ItemDefs`
  (oggetti della barra rapida; inventario e ricette con la voce 3).
- `src/art/` — grafica generata dal codice: `TilePainter` (atlante delle tessere: 7 tipi × 16 bordi × 3 varianti, pareti,
  10 decorazioni, immagine delle parti luminose), `CharacterArt` (personaggio a pose), `ItemIcons`, `CreatureArt`,
  `NatureArt` (alberi, torcia, montagne ripetibili, nuvole, sole).
- `src/world/` — il mondo:
  - `World` — solo lo stato (tessere, pareti, decorazioni, superficie, torce con indice a celle da 16, alberi per blocco).
  - `gen/` — il generatore: `WorldGen.passes()` elenca le passate in ordine, `GenContext` (seme, rumori per nome,
    parametri, appunti tra passate), `GenPass` (base). Passate in `gen/passes/`: Terreno, Strati, Grotte (profondità,
    regioni, grandi caverne), Ingressi, Minerali, Cristalli, Erba, Alberi, Decorazioni, Torce (prova, provvisoria), Partenza.
    Un mondo 3000×1000 si genera in ~5,5 s (in un thread, con schermata d'attesa).
  - `WorldView` — disegno a blocchi da 32×32: solo i blocchi vicini alla visuale esistono come nodi (2 costruiti per
    fotogramma, liberati oltre 2 blocchi di margine); ogni blocco ha i suoi livelli (pareti z -10, alberi -5, tessere 0,
    decorazioni 1, bagliore 25, effetti 26), torce e scintille. `refresh_around(c)` dopo uno scavo.
  - `LightMap` — luce in una finestra di 128×96 tessere attorno alla visuale, calcolata in un thread
    (`WorkerThreadPool`) su copie dei dati; ricentrata quando la visuale si sposta di 6 tessere, ricalcolata quando il
    giocatore cambia cella o `dirty` è vero. Immagine stesa sul mondo in moltiplicazione (`overlay` in main, z 20).
- `src/entities/` — `TileBody` (movimento contro la griglia, gradino automatico), `Player`, `Slime`.
- `src/ui/` — `Hud` (barra rapida, segnale `selected`), `MiningCursor`.
- `src/game/` — `main.gd` (solo montaggio: generazione, nodi, camera, aggiornamenti per fotogramma), `Background`
  (cielo, sole, nuvole, montagne che seguono la superficie sotto la visuale), `PlayerActions` (scavo, torce),
  `AutoTests` (prove automatiche).
- `tools/` — strumenti da riga di comando (`mappe.gd`).

## Ordine del codice

- **Un file, una responsabilità.** Sopra le ~400 righe un file va diviso; `main.gd` fa solo montaggio.
- **Dati separati dal codice**: contenuti (tessere, oggetti, creature, ricette, biomi…) in `src/data/`, mai sparsi nella logica.
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
- Gli alberi hanno 8 forme disegnate una volta sola e riusate (disegnarne uno per albero costava secondi).

## Convenzioni

- Tutto il testo visibile in italiano con accenti veri (à è ì ò ù).
- GDScript: tipi espliciti quando il valore viene da Array/Dictionary non tipizzati; `floorf/roundf/floori` invece di
  `floor/round` quando serve un tipo preciso; non chiamare variabili `seed` (nasconde la funzione globale).
- Il Bash tool fallisce con heredoc contenenti apostrofi/accenti: per patch in Python scrivere lo script su file.
- ROADMAP.md va aggiornato sempre: stato della voce ([ ] / [~] / [x]) e riga «fatto il …» con cosa è stato fatto.
- Dopo ogni modifica alla logica: prove automatiche (`-- --prove`) e controllo degli screenshot.
