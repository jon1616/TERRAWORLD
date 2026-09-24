# TERRAWORLD

Gioco d'esplorazione e costruzione a tessere ispirato a Terraria, in Godot 4.6.1. Stesso metodo di lavoro di Inkblood Arena
(`Desktop\CLAUDE\AUTOBATTLE GODOT`): contenuti come dati, strumenti di verifica, screenshot automatici, Roadmap a voci piccole.
Solo PC, solo italiano. Obiettivo: profondità e longevità altissime (esplorazione, equipaggiamento profondo, obiettivi sempre nuovi).

## Decisioni di base (24 set 2026, scelte dall'utente)

- **Mondi a portale**: un mondo casa più una serie infinita di mondi generati, finiti, con tema e difficoltà crescenti.
- **Mondi medi**: circa 3000×1000 tessere da 16 px.
- **Rete a 2 giocatori** (single player giocabile con un amico in collegamento diretto), host autoritativo come in Inkblood.
- **Universo tutto nostro**: «Il Giardino dei Semi», in `UNIVERSO.md` (ogni elemento del racconto è anche una meccanica).
- **Grafica**: la base è generata dal codice (tessere, luce, effetti, icone in serie, creature semplici); personaggio con tutte
  le animazioni, alcuni mostri e boss arriveranno da immagini generate dall'utente con un'IA grafica (Nano Banana),
  importate con script come in Inkblood (sfondo magenta, griglia fissa, riduzione a una tavolozza comune).
- La scena di prova (24 set 2026) ha superato le aspettative dell'utente: è un **prototipo**, non la base definitiva.

## Comandi

Godot: `C:\Users\Principale\Desktop\GODOT\Godot_v4.6.1-stable_win64_console.exe` (`_console` per vedere stdout).

```bash
# avvio (anche con doppio clic su «Avvia prova.bat»)
Godot_console.exe --path .
# reimporta il progetto (dopo aver aggiunto file con class_name nuovi)
Godot_console.exe --headless --path . --import
# controllo sintattico di uno script
Godot_console.exe --headless --path . --check-only --script res://src/world.gd
# prove automatiche con finestra: screenshot in prove/ (01_superficie, 02_grotta_torcia, 03_cristalli, 04_scavo) e mappa.png
Godot_console.exe --path . -- --prove            # aggiungere --senza-luce per vedere i colori senza il buio
# valori della luce attorno a una torcia e prove/luce.png (senza finestra)
Godot_console.exe --headless --path . --script res://tools/luce_debug.gd
```

## Struttura attuale (prototipo)

- `src/main.gd` — scena: livelli di tessere (pareti, tessere, decorazioni, bagliore), sfondo a strati, giocatore, slime,
  torce, barra degli oggetti, scavo, prove automatiche (`--prove`).
- `src/world.gd` (`World`) — dati del mondo (260×150) e generazione da un seme: strati, grotte a verme e caverne, galleria
  d'ingresso, minerali, cristalli, erba, alberi, decorazioni, torce.
- `src/tiles.gd` (`Tiles`) — tessere disegnate dal codice in un atlante: 7 tipi × 16 combinazioni di bordi × 3 varianti,
  pareti, 10 decorazioni; seconda immagine con le sole parti luminose.
- `src/light.gd` (`LightMap`) — luce a tessere alla Terraria (propagazione con perdita nell'aria e nei blocchi), immagine
  di un pixel per tessera stesa sul mondo in moltiplicazione, luce del giocatore in una finestra a parte.
- `src/art.gd` (`Art`) — personaggio a pose calcolate (fotogrammi generati e messi in cache), icone degli oggetti per
  materiale, slime, alberi, torcia, montagne ripetibili, nuvole, sole. `src/px.gd` (`Px`) — primitive di pixel art.
- `src/body.gd` (`TileBody`) — movimento contro la griglia con gradino automatico. `src/player.gd`, `src/slime.gd`, `src/cursor.gd`.

## Lezioni già imparate

- `rendering/viewport/hdr_2d` è attivo (serve al bagliore): la grafica 2D lavora in spazio lineare, quindi l'immagine
  della luce va codificata con `linear_to_srgb()` o il buio si raddoppia.
- Colori di base troppo scuri + luce = tutto nero: le tavolozze di roccia e terra devono essere di tono medio; le pareti
  di fondo circa al 50% delle tessere.
- Un blocco che tocca l'aria prende quasi la luce dell'aria davanti (`LightMap.redraw`), altrimenti le facce delle
  grotte risultano più scure delle pareti dietro.
- In un .bat, `"%~dp0"` finisce con `\` e rompe le virgolette: usare `cd /d "%~dp0"` e poi `--path .`.
- La luce calcolata su tutto il mondo costa ~0,7 s per 39.000 celle in GDScript: con mondi da 3 milioni di celle andrà
  calcolata solo attorno alla visuale (vedi Roadmap 1).

## Convenzioni

- Tutto il testo visibile in italiano con accenti veri (à è ì ò ù).
- GDScript: tipi espliciti quando il valore viene da Array/Dictionary non tipizzati; `floorf/roundf` invece di `floor/round`
  quando serve un float tipizzato; non chiamare variabili `seed` (nasconde la funzione globale).
- Il Bash tool fallisce con heredoc contenenti apostrofi/accenti: per patch in Python scrivere lo script su file.
- ROADMAP.md va aggiornato sempre: stato della voce ([ ] / [~] / [x]) e riga «fatto il …» con cosa è stato fatto.
- Dopo ogni modifica alla logica: prove automatiche (`-- --prove`) e controllo degli screenshot.
