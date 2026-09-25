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
# prove automatiche con finestra (~25 s): screenshot in prove/ (01_superficie, 02_grotta_buia e 02_grotta_torcia con la
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
# obiettivi, guardiani, rovine (elenco in `AutoTests._group`)
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
# mappe dei mondi: mappe/mondo_<seme>.png a metà grandezza (--intera per 1:1), tempi per passata, conteggi per seme
Godot_console.exe --headless --path . --script res://tools/mappe.gd -- --semi 20 --da 1
```

## Struttura

- `src/core/` — attrezzi generici: `Px` (primitive di pixel art, contorno automatico), `Fx` (sfumature, polvere di scavo).
- `src/data/` — **solo dati** (voce 3):
  - `GuardiansData` — il Guardiano di ogni vigore (Nodo Avvizzito, Regina delle Spore, Colosso d'Ardesia, poi da capo),
    con la creatura, ciò che lascia curato e le sue pagine di storia.
  - `LoreData` — le pagine di storia (Cuore trovato, Guardiano sconfitto o curato, portale), mostrate da `LorePanel`.
  - `BiomesData` — i biomi di superficie (foresta-lanterna, paludi di spore, distese d'ambra): erba, alberi, colline,
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
    i banchi della voce 25 (Alambicco, Telaio, Mola) in `WorkshopArt`. Foglio di tutte le stazioni in prove/stazioni.png.
  - `BossArt` — i tre Guardiani (Nodo, Regina, Colosso), malati o guariti, chiamati da `CreatureArt.frames`.
  - `BeastArt` (creature della voce 22 di superficie e Sottobosco, `spider` per i ragni) e `DeepBeastArt` (quelle del
    profondo), chiamate da `CreatureArt.frames` (2 fotogrammi, 3 per guscio e travestimento).
  - `CharacterArt` (personaggio a pose, restituisce anche mano e occhio), `CreatureArt`, `NatureArt`
    (`tree_linfa` con parte luminosa, `root_arches`, `lantern_forest`, colline, torcia, sole).
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
    grotte), Ingressi, Minerali (per strato e roccia), Cristalli, Erba, Alberi, Decorazioni (per strato), Avvizzimento (due macchie malate in superficie), Cuore (la
    cupola del Cuore del mondo nel Fondo, con i 4 nodi avvizziti e la stazione `cuore_mondo`), Rovine (44 stanze dei
    Seminatori con uno scrigno pieno secondo lo strato), Pericoli (rovi spinosi e rune trappola, vedi `Hazards`), Pericoli (rovi e rune trappola), Doni (Boccioli del cuore e Stille perenni), Gemme (grappoli nelle grotte, per strato), Tane (dei Custodi), Nascondigli (reliquiari murati), Geodi, Partenza (le torce
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
  `user://impostazioni.json`: volumi).
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
  dell'equipaggiamento a sinistra della Bisaccia (elmo, corazza, gambali, Scorza totale), `CraftingPanel` (colonna «Creare» a destra della Bisaccia: ricette
  delle stazioni a portata, prima quelle possibili; passando sopra si vede cosa serve), `MiningCursor`.
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
- `src/game/portal.gd` (`Portal`) — Seme di mondo piantato = stazione `portale`; clic destro = salva e passa al
  mondo nato da quel seme con un vigore in più (`destination(o)`, `world_meta["portali"]` per ogni portale,
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
  materiali bastano?, fabbrica; `describe` per il suggerimento.
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

## Convenzioni

- Tutto il testo visibile in italiano con accenti veri (à è ì ò ù).
- GDScript: tipi espliciti quando il valore viene da Array/Dictionary non tipizzati; `floorf/roundf/floori` invece di
  `floor/round` quando serve un tipo preciso; non chiamare variabili `seed` (nasconde la funzione globale).
- Il Bash tool fallisce con heredoc contenenti apostrofi/accenti: per patch in Python scrivere lo script su file.
- ROADMAP.md va aggiornato sempre: stato della voce ([ ] / [~] / [x]) e riga «fatto il …» con cosa è stato fatto.
- Dopo ogni modifica alla logica: prove automatiche (`-- --prove`) e controllo degli screenshot.
