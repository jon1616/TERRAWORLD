# TERRAWORLD

Gioco d'esplorazione e costruzione a tessere ispirato a Terraria, in Godot 4.6.1. Stesso metodo di lavoro di Inkblood Arena
(`Desktop\CLAUDE\AUTOBATTLE GODOT`): contenuti come dati, strumenti di verifica, screenshot automatici, Roadmap a voci piccole.
Solo PC, solo italiano. Obiettivo: profondità e longevità altissime (esplorazione, equipaggiamento profondo, obiettivi sempre nuovi).
Documenti: `ARTE.md` (la guida di stile: colori, misure, cornici, carattere, movimento), `UNIVERSO.md` (ambientazione «Il Giardino dei Semi»), `ROADMAP.md` (lavori in corso e fatti; in cima «Dove
siamo»), `VASTITA.md` (il piano «La vastità», Roadmap 38-51: la profondità di Terraria + Calamity + Thorium misurata sui
dati reali e i numeri da raggiungere).

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

## I pilastri: un gioco enorme che rispetta il giocatore (29 set 2026, approvata dall'utente)

L'obiettivo finale dell'utente: un gioco **enorme** (la parte a obiettivi ~500 ore per un giocatore medio, misurata con
`tools/durata.gd`), pieno di cose da fare anche **senza** avanzare nella storia principale, con meccaniche lunghe e mai
noiose che danno **tutte** qualcosa di utile. In una stessa partita il giocatore sceglie se progredire, esplorare, curare
la base o altro, e nessuna scelta è tempo perso. Regole per ogni voce, insieme a «Il Giardiniere dei mondi»:

- **Più pilastri, ognuno una partita a sé**: storia (Albero-Madre, catene, Seme Nero), esplorazione, Giardino e base,
  mandria, pesca, rete di Linfa, misteri e lingua dei Seminatori, collezioni (e i prossimi). Ogni pilastro ha una
  **strada lunga sua** (gradi di maestria, cose che si sbloccano solo lì, un traguardo in fondo): una serata dedicata a
  un pilastro solo si chiude con qualcosa di nuovo in mano.
- **Ogni pilastro nutre gli altri** (è «moltiplicare, non sommare»): ciò che si ottiene in uno serve negli altri.
- **La storia è la spina dorsale, con strade alternative**: le richieste della storia si soddisfano in più modi (dal
  Guardiano, dall'allevamento, da una Centrale…), così chi ama costruire avanza costruendo e chi ama esplorare esplorando.
- **Rispettare i tempi del giocatore**: qualcosa di utile in 15 minuti come in 3 ore; niente muri che obbligano a
  ripetere la stessa cosa per ore; le cose lunghe (allevare, la rete, il lavoro mentre si è via) vanno avanti mentre si
  fa altro. **Nessun limite** a chi insiste su una cosa sola (scelta dell'utente, 29 set 2026): la varietà si invoglia
  con ciò che dà, non si impone togliendo rendita.
- **La maestria è a gradi numerati e visibili** (scelta dell'utente, 29 set 2026): un solo motore per tutti i pilastri.
- **Mai noioso**: salendo un pilastro cambia forma (meccaniche, luoghi, imprevisti), non solo i numeri.
- **Il giocatore vede le sue strade**: in ogni momento deve sapere quali pilastri ha, a che punto è in ognuno e qual è
  il prossimo passo interessante (il filo, la Bacheca, il diario, e un posto che li mostri tutti).
- **Mai allungare gonfiando i costi**: le ore vengono da cose nuove da fare, non dalla ripetizione. Una voce che allunga
  la partita dice quali ore aggiunge e a quale pilastro (`tools/durata.gd`).

## Decisioni di base (24 set 2026, scelte dall'utente)

- **Mondi a portale**: un mondo casa più una serie infinita di mondi generati, finiti, con tema e difficoltà crescenti.
  Nell'universo: ogni mondo nasce da un Seme piantato nel Giardino (specie, vigore, tratti = parametri del generatore).
- **Mondi medi**: 3000×1200 tessere da 16 px (1000 fino all'8 ott 2026: le 200 righe in più sono cielo, voce 441;
  la superficie sta a `ground_depth` 730 righe dal fondo, `PassTerreno.base_of`).
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
# comodita, legami (i compagni di battaglia, Roadmap 32), energia (la rete della Roadmap 19, ~3 minuti), galleria (Roadmap 29: ogni pannello fotografato in
# prove/galleria/ e il controllo dell'impaginazione LayoutCheck: tagli, fuori schermo, testi sovrapposti; obiettivo 0), maestria, perduti
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
# Roadmap 18, il bilancio (vedi «Il bilancio» in Struttura): la curva della difficoltà equipaggiamento × zona
# (`--abilita medio|attento|jon|bot`, `--nuda`, `--dettaglio strato vigore arma` = chi pesa in una zona) → prove/curva.txt
Godot_console.exe --headless --path . --script res://tools/curva.gd
# i tre giocatori simulati attraverso la partita (appassimenti all'ora, riposo, pressione) → prove/percorso.txt
Godot_console.exe --headless --path . --script res://tools/percorso.gd -- --giri 40
# Roadmap 32: i compagni di battaglia (livello di ogni zona, duelli alla pari, forma delle specie) → prove/compagni.txt;
# il percorso con un compagno alla pari: tools/percorso.gd -- --compagno
Godot_console.exe --headless --path . --script res://tools/compagni.gd
# armi e armature a confronto, boss, progressioni ed economia → prove/armi.txt, prove/boss.txt, prove/progressioni.txt
Godot_console.exe --headless --path . --script res://tools/armi.gd
# il bot in arena contro creature vere (tara il modello; ~3 minuti) → prove/arena.txt
Godot_console.exe --path . -- --prove --solo=arena
# quanto dura la partita a obiettivi (Albero-Madre, catena lunga, Seme Nero): conti sui dati, ~12 s → prove/durata.txt.
# Le stime del modello (minuti di un giro di mondo, ciò che un giro porta, quanto rende cercare apposta) sono in cima al file.
# Obiettivo dell'utente (29 set 2026): ~500 ore per il giocatore medio.
Godot_console.exe --headless --path . --script res://tools/durata.gd
# Roadmap 19: il bilancio della rete (sorgenti, macchine all'ora in Lumini, confronto con scavo e pesca) → prove/rete.txt
Godot_console.exe --headless --path . --script res://tools/rete.gd
# Roadmap 17: quanto dura imparare la lingua (un giocatore simulato in otto mondi) → prove/lingua.txt
Godot_console.exe --headless --path . --script res://tools/lingua.gd
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
  `IconTemplates`; icone tutte diverse con `IconVariety` (misura: `tools/icone.gd` + `tools/icone_simili.py`, da rifare
  dopo ogni oggetto o tavolozza nuova: 0 identiche); stati sopra le creature `StatusMarks`; pulsanti dei pannelli `PanelButtons`. Il metodo e le
  lezioni sui prompt sono in ROADMAP.md, Roadmap 13. Claude crea sempre la cartella prima di dare il prompt.
  **Le pose delle creature** (7 ott 2026): una tavola 4×2 di Nano Banana per creatura (`arte_ia/creature/`, con il
  riferimento `00_<nome>_riferimento.png` fatto da `tools/esporta_creatura.gd -- <id>`), ridotta da
  `tools/importa_creatura.py` (stessa finestra e tavolozza per tutte le pose; `--ancora occhio` per chi vola, `cella`
  per chi cammina o salta; `--schiarisci` per le creature quasi nere; `--luce` per le maschere di luce) in
  `arte/creature/<forma>_<n>.png`. La riga in `CreaturePosesData` (punto d'appoggio stampato dallo script, nomi delle
  pose) e `CreatureArt._posed` le caricano; `Creature._pose_name` sceglie la posa dallo stato (salto, carica, scatto,
  pascolo, colpita…) e il codice smette di schiacciare il disegno. Una chiave che è l'id di una creatura (i capi) vale
  solo per lei, senza i colori della variante; le pose «furia_…» le usa il boss infuriato. Icone dell'Erbario con
  `CreatureArt.of_creature`. **Per guardare una creatura: `sh tools/sprite.sh <id>`** (~25 s, gruppo «sprite»,
  `TestsSprite`: il mondo di prova salvato, la creatura subito, il foglio di tutte le pose con il nome in
  prove/sprite/<id>.png, gli stati che non scelgono mai una posa, la foto dal vivo). Il gruppo «grafica» resta la prova
  di tutte insieme (foto 163_pose_creature).
  **Le icone dipinte** (8 ott 2026, stile «A» scelto dall'utente): ogni forma d'icona ha due disegni dalla stessa tavola
  di Nano Banana, `arte/icone48/<forma>.png` (dipinta, 48 pixel: l'interfaccia, `ItemIcons.ui` → `IconVariety.of_ui` →
  `IconTemplates.make_ui`; `SlotView.icon`) e `arte/forme/<forma>.png` (pixel art da 16: il mondo, `ItemIcons.of`;
  `SlotView.world_icon` per l'attrezzo in mano, i lanci, le stelle). I grigi neutri prendono il materiale come prima.
  Il giro: descrizioni in `arte_ia/icone/aspetti.json` → `python tools/prompt_icone.py` (12 forme, le più usate prima,
  prompt negli appunti) → l'utente salva la tavola in `arte_ia/icone` → `python tools/installa_icone.py` (nome, taglio,
  scritte tolte, foglio prove/icone/<lotto>.png; `--salta forma` per le venute male). Elenco delle forme:
  `tools/scheda_icone.gd` → `arte_ia/icone/forme.json`.
  Gli oggetti che si piazzano (stazioni, macchine, costrutti, arredi, pareti) usano la forma dipinta dei loro dati
  (`IconVariety.of_ui`, `ItemIcons.ui`); trappole, totem, macchine, costrutti e mobili hanno forme loro («trappola_…»,
  «totem_…», «macchina_<id>», «costr_<forma>», «arredo_<mobile>») scelte dai dati solo se il disegno c'è
  (`ZonesData.icon_of`, `MachinesData.icon_of`, `BuildData.icon_of`, `FurnitureData._icon`); senza, resta il disegno
  del mondo ingrandito. Quali oggetti e con che disegno: `tools/icone_mondo.gd -- --cat <categoria di Creare>` →
  prove/icone/mondo_<cat>.png. Le luci e i vetri dipinti sul magenta vengono rosa: si rendono grigi o si tolgono.
  **Gli effetti** (8 ott 2026): Nano Banana li disegna BIANCHI su fondo NERO (sul magenta la luce sfumata si sporca), la
  luminosità diventa l'alfa e il gioco li colora e li somma come luce (`CanvasItemMaterial` ADD). Giro: descrizione in
  `arte_ia/effetti/aspetti.json` → `python tools/prompt_effetto.py <nome>` → l'utente salva in `arte_ia/effetti` →
  `python tools/installa_effetto.py` (`importa_effetto.py`: `arte/effetti/<nome>_<n>.png` + `<nome>.json` con la
  «base»; per gli aloni la prova su quattro creature, `sh tools/sprite.sh <id> <grado>`). Gli aloni dei gradi rari
  (`alone_<grado>`) li disegna `Halo` (`src/art/halo.gd`, da `Ancient.apply`): fotogrammi sfumati, misura sulla parte
  disegnata della figura (larghezza e altezza separate); un grado senza disegno tiene il contorno di `Ancient.ring`.
  Gli scoppi dei colpi (`colpo_<elemento>`, «fisico» = senza elemento; importati con `--centro`) li fa `HitFlash`
  (da `ImpactFx.hit`, sopra le scintille): al centro della parte disegnata della creatura (`HitFlash.aim`), grandi
  quanto lei; durate e grandezze per elemento in `LIFE_OF`/`SIZE_OF`; il colpo senza elemento solo la stella, piccolo e
  breve (scelta dell'utente). Prova: `sh tools/sprite.sh <id> colpo:<elemento>`.
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
    Collaudo (l'ultima). Un mondo 3000×1200 si genera in **~4,6 s** (28 set 2026, prima 10), in un thread suo con la
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
    Le categorie (30 set 2026: 15 in 4 gruppi, ognuna con sottocategorie) le decide `CraftCatsData.place_of`: un tipo
    d'oggetto o una stazione nuova si aggiunge lì. Distribuzione: `tools/categorie_creare.gd` → prove/categorie_creare.txt.
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
- **Roadmap 17 «La lingua dei Seminatori»** (voci 170-178, 29 set 2026; richiesta dell'utente: le stele si imparavano in
  un'ora; «tutte e tre le proposte, profonde, e il giocatore deve capire e poter consultare»): **si decifra**.
  - `LanguageData`: 114 parole in tre strati (comune 50, antica 40, nera 24; `WORDS` = [lingua, italiano, classe, strato]),
    `options(w)` (tre significati possibili fissi), le frasi `LORE`, `LORE_ANCIENT`, `LORE_BLACK` (ogni parola ne ha una:
    `tools/lingua.gd` e la prova lo controllano), le iscrizioni delle cripte `CRYPT_TRUTH`.
  - `Language`: `Character.lingua` = {parola: {s: 0 vista · 1 ipotesi · 2 certa, f: frasi viste, x: significati scartati,
    r: bloccata}}; `see` (ipotesi dopo 2 frasi diverse, 3 per le lingue alte, una in meno con gli Occhiali), `guess`
    (sbagliato: bloccata fino a una frase nuova; scartati due: dedotta), `confirm` (luoghi «forse» raggiunti, scrigni,
    tavolette, Stilo), `known` = certa. Stele colorate per stato; luoghi «forse» sulla mappa.
  - `LexiconPanel` (il Quaderno, tasto U), `WordChests` + `GlyphPanel` (gli scrigni a parola di `PassParole`, stazione
    `scrigno_parola`), `IncisionsData` (incisioni al Maglio: tratti in `TraitsData.TRAITS`, dati "incisione", non prendono
    un posto), `language_pack.gd` (ricette con il campo `parole`: `Crafting._discovered` con `Crafting.words`).
  - `PassStele` sceglie lo strato (osservatori e mondi di vigore 3+ antica, mondo del Seme Nero nera); `Chains.inscription`.
  - Prove: gruppo «lingua» (`TestsLanguage`: stati, Quaderno, strati, scrigni, incisioni, ricette; foto 127, 128, 221, 222).
    Misura: `tools/lingua.gd` (un giocatore simulato in otto mondi → prove/lingua.txt). Enciclopedia: capitoli della lingua,
    scrigni a parola, incisioni, ricette scritte (`EncyStoryData`).
- **Roadmap 18 «Il bilancio»** (voci 179-189, 29 set 2026; richiesta dell'utente: studiare tutto il gioco con i numeri e
  con bot che simulino lui o un umano medio, correggere in autonomia; curva voluta: inizio facile, poi sempre più
  sfidante, equipaggiarsi bene deve servire):
  - `FightModel` e `ZoneModel` (`src/game/balance/`): le formule del combattimento in un posto solo, usate da strumenti e
    prove. Le regole vere sono condivise: `Vitals.reduce` (la Scorza toglie SCORZA_K / (SCORZA_K + Scorza) di ogni
    ferita), `Creature.through` (difesa delle creature), `Creature.HIT_STUN`, `Combat.TOOL_HIT`. **Una regola nuova del
    combattimento si scrive una volta sola e la leggono entrambi.** Le abilità dei profili in `FightModel.SKILL`, tarate
    con `TestsArena` (bot vero contro creature vere: duello, sorpresa, gruppo) e con il Diario dell'utente («jon»).
  - Strumenti: `tools/curva.gd`, `tools/percorso.gd` (tre profili, a scontri uno a uno con il caso, riposo, pozioni),
    `tools/armi.gd`, `tools/boss.gd`, `tools/progressioni.gd`; `tools/bilancio.gd` usa il modello per le creature.
  - Le leve della difficoltà: `StrataData.STRATA[...]["danger"]`, `VigorData.CREATURE_STEP/_HIGH`, `DangerData.DAMAGE`,
    `CreaturesData.SURFACE_STRONG` + `now_vigor` (di giorno al vigore 1 in Superficie solo le creature leggere),
    `AncientData.DANGER_CAP`, `Creature.shot_k` (i proiettili crescono con la creatura), `Lords.strength`, la ricrescita
    della Vita in proporzione alla Vita massima, `DangerData.expected_scorza` (l'avviso entrando in uno strato).
    **Dopo ogni cambio a questi numeri si rifà `tools/percorso.gd`** e si guarda che «attento» resti a 0-2 appassimenti
    all'ora e «medio» sotto ~10.
  - `Vitals.cause` e il Diario (`morti_causa`): di che cosa appassisce l'utente nelle partite vere, per tarare ancora.
- **Roadmap 19 «La Linfa che scorre»** (voci 190-213, 29 set 2026; richiesta dell'utente dopo il prospetto: roadmap
  dettagliata eseguita in autonomia; scelte: due reti, lavoro mentre si è via a metà velocità per al più 2 ore, solo i
  Succhiavena bevono e solo le vene di radice, le vene si vedono sempre e i fili solo con la Pinza o l'Occhio):
  - Lo strato: `World.vein` (un byte per cella: bit 0-2 grado della vena, bit 3 isolata, bit 4-7 i quattro fili),
    `vein_at`/`set_vein`, salvato da `WorldSave`; `VeinsData` (gradi, fili, `joins`); disegno `VeinPainter` + strati di
    `WorldView` (vene z -8, bagliore z -7, fili z 2 solo con `set_show_wires`). La Pinza: `Veins` (`src/game/energy/`).
    L'indice delle stazioni in `World` (`station_at` veloce, `stations_rev()`, `stations_changed()`; durante la
    generazione `station_at` è lineare: il generatore non lo usa nei cicli).
  - Le macchine sono **righe di dati** (`MachinesData`: role sorgente/riserva/macchina/comando/nodo, size, bh, pulsi,
    colpo, cap/io, slots, fuel, light, porta, p, look, in, `gen` = solo del generatore, `fixed` = non si riprende) che
    diventano stazioni, oggetti (categoria «rete») e ricette; il comportamento è un file per `bh` in
    `src/game/energy/machines/` (`MachineBehavior.make`: produce, demand, tick, frame, on_impulse, touch, panel_rows,
    removed, state_text). Disegni in `MachineArt`/`MachineArtMore`. **Prima di dare un id si controlla che non sia già
    un oggetto o una stazione** (`verifica_dati._check_machines`: tre macchine avevano l'id di un oggetto).
  - `Energy` (il Flusso: reti per visita delle vene, `EnergyGraph` con la strada più larga fino a ogni macchina, conto
    ogni `TICK`, priorità, riserve, `spend`, `needs`, `charge`; stato in `world_meta["rete"]["m"]`), `EnergyView`
    (aspetto, luci, zone), `EnergyAway` (il lavoro mentre si è via), `EnergyStorm` (geni `linfa_*` e la Tempesta di
    Linfa), `EnergyGarden` (Aiuole alimentate, `stats.macchine`), `EnergyLinks` (casse, scudi, testi); `Impulse` (i fili:
    reti per colore, eventi su/giù/colpo, un nodo guida solo il filo della sua uscita con `drives`, i cambi con attesa
    sono eventi «stato», al più `MAX_EVENTS` per fotogramma). Pannello `MachinePanel`, schede `MachineTip`.
  - Il mondo: `PassCentrali` (le Centrali dei Seminatori; `build(…, intatta)` anche per la firma), Succhiavena
    (`BhSucchia` + `Wiles._suck`), Lucciole di vena (`BhLucciolaVena`), evento `tempesta_linfa`, la Tessitrice di vene,
    obiettivi, diario, Bacheca, il corredo del secondo stadio dell'Albero (`gives.items`) e il filo del primo circuito
    (`FiloRete`), progetti con le griglie «vene» e «fili» (`ProjectsData`, `BuilderTools._blueprint_veins`).
  - Prove: gruppo «energia» (`TestsEnergy`, `TestsEnergyMore`, `TestsEnergyLogic`, `TestsEnergyWorld`; foto 230-243).
    Misura: `tools/rete.gd`. Enciclopedia: `EncyEnergyData` + cataloghi `EncyEnergy`.
- **Roadmap 20 «Il motore comune»** (voci 214-219, 29 set 2026; il piano «Le dieci strade», scelte dell'utente: gradi
  numerati e visibili, nessun limite a chi insiste su una cosa sola):
  - `MasteryData` (i 10 pilastri in `ORDER`/`PILLARS` con le ore obiettivo; un punto ≈ un minuto di attività; curva
    quadratica `points_for`/`grade_of`; `STATS` = i conteggi del personaggio che nutrono ogni pilastro; `STATION`/`KIND`
    per ciò che si fabbrica; `REWARDS` = i 100 premi) e `Mastery` (`src/game/mastery.gd`: `add`, `grade`, `idle`,
    segnali `gained`/`graded`, `neglected` per il filo; i punti arrivano da `Objectives.bumped_n`, `Fauna.killed`,
    `MapReveal.on_new`, `Crafting.crafted`, `PlayerActions.placed`, `Language.confirmed`). `MasteryRewards` (oggetti e
    bonus per sempre sommati da `GearEffects`; bonus nuovi `grow`, `herd`, `pulsi`). `Character.maestria`.
    **Un conteggio nuovo (`bump`) di un'attività va legato al suo pilastro in `MasteryData.STATS`.**
  - `PillarsPanel` (il Libro dei pilastri, tasto P); la fonte «pilastro» del filo.
  - Le strade alternative dell'Albero-Madre: `{"any": [offerta, offerta]}` in `MotherTreeData`, lette con
    `AlberoMadre.progress/alt/offer_of` (mai `offers[i]["item"]` direttamente).
  - Prove: gruppo «maestria» (`TestsMastery`, foto 244). Misura: sezione 4 di `tools/durata.gd`. Enciclopedia:
    `EncyPillarsData`.
- **Roadmap 21 «Le radici del cosmo»** (voci 220-226, 29 set 2026; l'Atto II della storia):
  - `MotherTreeData.ACTS` (gli atti e `act_of`) e gli stadi 13-24; il dono `seed` = un Seme del cosmo.
  - `LostGardensData` (i quattro Giardini perduti: pilastro, vigore, geni, Seme del cosmo, Albero, tre cure con il loro
    compimento, doni; le stazioni «albero_<id>» e «albero_<id>_vivo») e il pacchetto `lost_gardens_pack.gd` (creature con
    `perduto`, i Custodi con `lost_boss`, famiglie, i Cervi di rovo da addomesticare, i pesci con `perduto`, oggetti).
  - Il parametro `perduto` del generatore passa da `Portal` a `MainBoot.gen_params` (come `nero`); `PassPerduto` (dopo le
    stele) fa il luogo; `LostGardens` (`src/game/lost_gardens.gd`) le cure, il Custode, la guarigione e
    `Fauna.lost_pool`; `Fishing.on_catch`; il filo ha la fonte «perduto». `tools/mappe.gd -- --perduto tutti`.
  - Prove: gruppo «perduti» (`TestsLostGardens`, foto 245); `--prova-giardino` fa tutti i 24 stadi. Enciclopedia:
    `EncyCosmosData`.
- **Roadmap 22 «Il Giardino vivo»** (voci 227-234, 29 set 2026; i pilastri Giardino e abitanti):
  - `GardenBeauty` (la bellezza, solo nel Giardino: `parts`, `update`, `best` = `stats.bellezza_max`, `home()`),
    `GardenIslandsData`/`GardenIslands` (quattro isole a soglie di bellezza; `grow_at` per l'orto), `Visitors` (abitanti
    di `NpcData` con `visitor` e `requires.bellezza`, uno al giorno, in `world_meta["visitatore"]`; `Villagers` li salta),
    `FestivalsData`/`Festivals` (la festa del primo giorno di stagione).
  - `NpcStoriesData` (70 capitoli, da `tools/gen_storie.py`; `FINAL` = la merce a storia finita): `NpcBonds.quest`
    continua con i capitoli (`capitolo`, `chiuso`), `story_done`; la scena con `LorePanel.show_text`. `NpcWork` (le
    botteghe con l'orologio vero, `world_meta["botteghe"]`), bottone in `TradePanel.work`.
  - Le grandi opere: progetti di `ProjectsData` con `opera` ed `extra` (solo nel Giardino); poteri in
    `ProjectsData.WORKS`/`works_built`, letti da `Aiuole.max_aiuole`, `GearEffects`, `Visitors`.
  - Prove: gruppo «giardino_vivo» (`TestsGardenLife`). Enciclopedia: `EncyGardenData`. `tools/durata.gd` misura anche
    la varietà (sezione 5: ore di cose diverse per pilastro).
- **Roadmap 23 «L'Atlante»** (voci 235-240, 29 set 2026; il pilastro dell'esplorazione, 90 ore):
  - `Atlas` (`src/game/atlas.gd`, tasto O) tiene insieme tutto e gira ogni 5 s: le stelle dei mondi (`AtlasData`,
    `Character.atlante`), le pagine dei biomi (`BiomePagesData` costruite dai dati, `BiomePages`: visite «visto_<bioma>»),
    le meraviglie (`Wonders`), le spedizioni (`ExpeditionsData`/`Expeditions`, `Character.spedizioni`, fonte «spedizione»
    del filo) e gli attrezzi (`ExplorerData`/`ExplorerTools`: Tenda con `Fauna.camp`, Cannocchiale, Bussola, Radice di
    ritorno). `AtlasPanel`: una scheda = una coppia `_rows_<scheda>`/`_text_<scheda>`.
  - Le meraviglie: `WondersData` (12, pesi, geni, ricordi e i tre accessori), `PassMeraviglie` e `WonderShapes`
    (`src/world/gen/`: una funzione `_b_<id>` per forma, `solid_enough` sotto terra), stazione `cuore_meraviglia`.
    `tools/meraviglie.gd -- --semi 30` ritaglia ogni forma dalla mappa in prove/meraviglie/.
  - I punti delle stelle e delle spedizioni sono bassi apposta: premiano cose già contate (firme, Guardiani, segreti).
  - Prove: gruppo «atlante» (`TestsAtlas`, foto 250-253). Enciclopedia: `EncyAtlasData`.
- **Roadmap 24 «Stirpi e semi»** (voci 241-246, 29 set 2026; mandria 70 ore, orto 30):
  - `Lineage` (le stirpi nelle doti: `padri`, `nonni`, `capo`, `pura`; `Breeding.mult` e `Breeding.sheet` le leggono; la
    collezione dei manti in `stats["manto_<famiglia>_<manto>"]`), `Fairs` (fiere nel Giardino ogni 3 giorni, `score`,
    medaglie), `HerdJobs` (`rec["lavoro"]`: aratura con `Pens.plows` letto da `Garden.grow`, cerca, canto; `Pens.tick`).
  - `OrchardData` e in `Garden` `quality`/`tier_of`/`_cross` (la qualità è il quarto campo di `World.crops`, salvato;
    semi scelti `scelto_<coltura>` riconosciuti da `CropsData.of_seed`; 12 varietà unite a `CropsData.CROPS`).
    `CookingData` (30 piatti, campo `boons` letto da `PlayerActions.drink`; `ricettario` in `Crafting._discovered`).
  - Prove: gruppo «stirpi» (`TestsLineage`). Enciclopedia: `EncyBreedData`.
- **Roadmap 25 «Le arti»** (voci 247-252, 30 set 2026; combattimento 75 ore):
  - `ArtsData` (dieci forme con maestria, ranghi, `TECHS`: le tecniche come dati, otto modi) e `WeaponArts` (punti in
    `stats["arte_<forma>"]` dalle creature sconfitte con l'arma in mano, `mult_now` letto da `Combat._boon`, `ArtsPanel`
    tasto I); `Techniques` (tasto X; una funzione `_<modo>` per ogni modo di `TECHS`).
  - `BountiesData`/`Bounties` (`Character.taglie`, il Cacciatore di taglie in `NpcData`), `Trials` (le prove a ondate
    al Cerchio «arena»: clic destro due volte).
  - Prove: gruppo «arti» (`TestsArts`, foto 254). Enciclopedia: `EncyArtsData`.
  - Gli strumenti senza finestra (`tools/durata.gd`) contano dai **dati**, non dagli script di gioco: questi tirano dentro
    `Portal` e `Session` e lo strumento non si carica («Compilation failed»). Per lo stesso motivo **un file di dati
    (`ItemsData`…) non nomina mai uno script di `src/game/`**: gli oggetti nuovi stanno in un file di `src/data/`.
- **Roadmap 26 «Memorie»** (voci 253-257, 30 set 2026; misteri 60 ore):
  - `MuseumData` (sale costruite dagli altri dati, la Vetrina, gli accessori dei traguardi) e `Museum` (vetrine del
    Giardino → `stats["museo_<oggetto>"]`, sale complete → `GearEffects`, bellezza in `GardenBeauty`); dentro `Museum`:
    `arch` (`Archaeology`: giacimenti di `PassGiacimenti`, Pennello, fossili e scheletri di `ArchaeologyData`), `chron`
    (`Chronicles`: le otto storie di `ChroniclesData`, frammenti nelle tabelle «rovina_N» di `LootData`), `goals`
    (`Milestones`: i dieci traguardi delle collezioni).
  - Prove: gruppo «memorie» (`TestsMemories`). Enciclopedia: `EncyMemoriesData`.
- **Roadmap 27 «Acque e correnti»** (voci 258-261, 30 set 2026; pesca 30 ore, rete 35):
  - `AnglerBook` (segnale `Fishing.fish_caught`: medaglie delle misure in `stats["record_<pesce>"]`, la gara del giorno
    con la serie `gara_serie`; `paused` nelle prove) e `NetContracts` (quattro contratti della Tessitrice con il grado in
    `stats["contratto_<tipo>"]`, letti dalla rete di `Energy`; nelle prove fermo).
  - Prove: gruppo «correnti» (`TestsCurrents`). Enciclopedia: `EncyCurrentsData`.
  - Una prova che dà premi o punti di maestria rimette com'erano Bisaccia (le quantità esatte) **e** `Character.maestria`:
    un grado della pesca in più cambiava la fortuna di pesca delle prove della pesca.
- **Roadmap 28 «Il Seme Primo»** (voci 262-266, 30 set 2026; l'Atto III e il finale):
  - `MotherTreeData`: `ACTS[2]` e gli stadi 25-34 (uno per pilastro), l'offerta `{"grado": pilastro, "n": g}` (letta da
    `AlberoMadre._progress_of`, contata da `tools/durata.gd`), il dono `primo` (→ `Legends.give_primo`); pagine `atto3_*`.
  - Il Primo Mondo: parametro `primo` del generatore (`MainBoot.gen_params`), `PassPrimo` (la radura dell'Albero Antico),
    `primo_pack.gd` (l'ultimo Seminatore, `primo_boss`), `PrimoGarden` (sveglia, seme, finale); `Finale` + `FinaleData` +
    `FinalePanel` (racconto, epilogo con i numeri, titoli; `stats["finale"]` ≥ 1 = Albero-Madre d'oro, `albero_madre_5`);
    `Evergreen` (stelle di maestria oltre il grado 10, Semi d'oro ogni sette giorni).
  - Prove: gruppo «primo» (`TestsPrimo`, foto 255); `--prova-giardino` percorre tutti i 34 stadi. Enciclopedia:
    `EncyEndingData`.
  - Un conteggio di `Objectives.bump` non fa da segno «fatto una volta» con `== 1`: il bump lo porta a 2. Si legge `>= 1`.
- **Roadmap 29 «Il volto vivo»** (voci 267-294, 30 set 2026, in autonomia; la guida è `ARTE.md`):
  - Il tema (`src/ui/theme/`): `UiPalette` (colori e misure del testo), `UiFrames` (cornici a 9 pezzi disegnate dal
    codice: riquadro, forte, suggerimento, casella, pulsante, principale, campo; `box`, `padded`, `button`), `UiTheme`
    (le scrive nel tema predefinito del motore), `UiScreen` (lo scheletro dei pannelli a schermo intero), `UiFx`
    (`appear`, `count`, `flash`; l'HUD fa comparire da solo ogni pannello). **Un pannello nuovo non crea StyleBoxFlat.**
  - (`PixelFont` e `PixelGlyphs`, il carattere di pixel, tolti nella Roadmap 55: ora `UiFonts`.)
  - Il mondo: `WindFx` (vento nelle piante e nelle chiome), lo shader di `LiquidView`, `AmbientFx` (`src/game/`: aria
    di ogni strato, polvere dei passi, vignettatura), `Juice` (scosse, pause d'impatto), l'alone degli oggetti a terra.
  - Le creature: `CreatureFx` (`src/art/`: `shade` = contorno colorato e luce, anche per le icone in `ItemIcons.of`;
    ombra, respiro, `fade_out` alla morte, `aura` dei boss); `BossBar` nuova.
  - Prove: gruppo «galleria» (`TestsGallery` + `LayoutCheck`: ogni pannello fotografato in prove/galleria/, problemi in
    problemi.txt, **obiettivo 0**); foto fedeli con `Photo.take`; `tools/cornici.gd`, `tools/volume_creature.gd`.
- **Roadmap 30 «Lo zaino e le grotte piene»** (voci 295-305, 30 set - 1 ott 2026, in autonomia; l'utente dopo un'ora di
  gioco: «poco da trovare, pochi mostri», e lo zaino troppo piccolo):
  - Lo zaino (`BackpackData` + `Backpack`): Bisacce a gradi (`Bisaccia.grow`, 40 → 100, `Character` salva quante
    caselle), tasche alla cintura (posti «tasca_1/2»; `Bisaccia.pouch(posto)` è una Bisaccia vera fatta dai dati `c`
    della tasca; `add` prova prima le tasche che accettano l'oggetto, poi la Bisaccia, poi i `carriers`; `count`,
    `remove`, `room_for` e `Crafting.counts` contano tutto con `all_bags()`), basto della mandria (`carriers`, aggiornati
    ogni secondo da `Backpack.update_carriers`), Dispensa del personaggio (`Character.dispensa`, `ChestPanel.personal`,
    pagine oltre 105 caselle), «Non raccogliere» (`Character.guida["scarta"]` → `Drops.rules`, pulsante in Esamina).
    Il pannello: `BisacciaPanel._views` (pagine, tasche, basto) e le schede accanto al titolo.
    **Chi scorre `bisaccia.slots` per contare ciò che si ha deve usare `all_bags()`**, o le tasche restano fuori.
    Gli **scomparti** (3 ott 2026, richiesta dell'utente): `Bisaccia.comps` (solo nella Bisaccia del personaggio, otto
    caselle per tipo: `BackpackData.COMPARTMENTS`, regole in `Compartments`): `add` completa la pila della barra rapida,
    poi lo scomparto; `take_one` riempie dallo scomparto la pila finita della barra rapida; `all_bags` li include;
    appassendo restano (il fagotto prende solo le caselle grandi); salvati in `Character` («scomparti»).
    Le **caselle bloccate** (Alt+clic, 3 ott 2026): la chiave «bloccato» nella casella (`Bisaccia.locked`/`toggle_lock`);
    chi sposta oggetti da solo (Q, depositi, Seme della Dispensa, `sort_bag`) salta le caselle bloccate.
  - Le grotte: `HarvestData` + `Harvest` (il raccolto di ogni pianta, sul segnale `decor_picked`), `PodsData` +
    `PassBaccelli` + `PodArt` (decorazioni 92-97 da rompere, `Harvest.open_pod`), `DangerData.SPAWN_TRIES` e
    `Fauna._room_below` (una nascita prova quattro punti già buoni: spazio, pavimento, buio, niente torce),
    `EncountersData` + `PassIncontri` + `Encounters` + `EncounterArt` (zaini, tane, vene madri, camere fungine come
    stazioni; stato in `world_meta["incontri"]`; il diario di Tessa), `CuriositiesData` (30 curiosità, cinque sale del
    Museo). Misura: `tools/densita.gd` (cose da raccogliere per 1000 celle d'aria, baccelli, nascite per strato),
    `tools/baccelli.gd` (il foglio dei disegni), `tools/categorie_creare.gd`.
  - Prove: gruppi «zaino» (`TestsBackpack`, foto 300-302) e «grotte» (`TestsCaves`, foto 303-305), «mappa».
    Enciclopedia: `EncyCavesData`.
- **Roadmap 31 «Il carattere dei materiali»** (voci 306-309, 1 ott 2026; l'utente: «oggetti dello stesso tipo e grado ma
  di materiali diversi danno gli stessi bonus»): `MaterialsData.TRAITS` (il carattere di ogni metallo e materiale dei
  geni; le leghe metà di ciascuno con `trait_of`), `trait_acc(mat, parte)`, `merge_acc`, `SHARE` (armatura 0,25,
  guanti/stivali/mantello 0,5, in mano 0,5, amuleto 0,5, anello 0,3). `FormsData.item` lo mette nell'`acc` dei pezzi
  indossati (`TRAIT_PART`) o nel campo `mano` di armi e attrezzi, letto da `GearEffects` per l'oggetto scelto nella
  barra rapida (`Hud.selected`). `SetsData.all()` ha un set per ogni lega (`blend` a metà dei due metalli) e per ogni
  materiale dei geni (`GENE_BONUS`), con la descrizione fatta da `describe`; `JewelsData` aggiunge il carattere della
  montatura. Prove: gruppo «carattere» (`TestsMaterials`). **Un materiale nuovo ha sempre un carattere** (la prova
  segnala quelli che ne sono senza).
- **Roadmap 32 «I compagni di battaglia»** (voci 310-318, 1-2 ott 2026; scelte dell'utente: ogni creatura tranne i
  Guardiani, una in campo e cinque in un'apposita sacca, segue senza restare indietro, combatte da sola con il suo stile,
  cresce con l'esperienza e con oggetti da trovare, KO torna nella sacca e guarisce solo nel Giardino):
  - Dati in `BondsData` (`src/data/bonds_data.gd`): lo stile (`style_of`: i comportamenti della specie meno `SKIP`),
    `bindable` (niente `boss`), le nature (`nature_of`: avvizzita, vuoto, spirito, mimo, costrutto), i lacci `LACCI`,
    `default_tame` e `aid_of` (ogni famiglia si lega e ha un dono), la crescita (`stats`, `level_of`, `xp_from`, `xp_for`,
    `scale_at`; `HP_K`/`DMG_K` e `power` = opzione «forza_compagni»), gli oggetti (`items()`: frutti, Seme del ricordo,
    14 istinti, pietre d'elemento, ciondoli; `creature_loot`, `pod_loot`), atteggiamenti e affiatamento (`STANCES`,
    `BOND_GRADES`, `aid_now`), il Libro dei legami (`BOOK_GOALS`, `all_species`).
  - Il compagno è una `Creature` della mandria (`Herd.beasts`, non in `Fauna.list`) con un `BhMandria` che usa lo stile
    contro `c.target` = il nemico; `BondFight` (`Herd.fight`) fa contatto, colpi amici ("ally" in `Projectiles`, smistati
    da `Combat.on_shot`), scoppi, fulmini (`SkyStrikes.bolt(…, uid)`), cure, ferite, `retarget` delle creature selvatiche
    e `release` (chi lo inseguiva torna sul Germogliato prima che sparisca). `Mind.sees` per i compagni.
  - La Sacca dei legami è lo stato «segue» della mandria (`HerdData.FOLLOW_MAX` 5) con "campo" e "ko": `BondBag`
    (`m.bonds`: tasti «compagno» T e «cambia_compagno» B, guarigione nel Giardino, `use_item`/`give` degli oggetti con un
    clic sul compagno, `bound` per il Libro), `BondBar` (in basso a destra), `BondsPanel` (tasto «compagni» Y).
    `HerdData.LVL_MAX` 50, `LVL_WORK` 20 per recinto, sella, basto, fiere e ruota.
  - Prove: gruppo «legami» (`TestsBonds`, foto 320-324). Misure: `tools/compagni.gd` (prove/compagni.txt: la creatura
    tipica di ogni zona e il suo livello, i duelli alla pari, la forma delle specie, quante creature per livello) e
    `tools/percorso.gd -- --compagno`. Enciclopedia: `EncyBondsData`.
  - **Una specie nuova o un comportamento nuovo** non chiedono nulla ai compagni: lo stile e il legame nascono dai dati.
    Un comportamento che danneggerebbe il Germogliato se usato da un compagno va in `BondsData.SKIP`.
- **Roadmap 33 «La luce e la profondità»** (voci 319-327, 2 ott 2026; la grafica solo dal codice, giudicata con nove
  foto fisse prima e dopo):
  - Le foto: gruppo «volto» (`TestsLook`: nove scene senza HUD né schede in prove/volto/, più la Caverna senza luce),
    `tools/foglio_volto.py` (il foglio 3×3), `tools/confronto_volto.py` (prima e dopo da prove/volto_prima/).
    **Ogni cambio alla grafica del mondo si guarda così**, non a occhio su una scena a caso.
  - La luce: `LightFx` (`src/art/light_fx.gd`: lo shader dell'immagine della luce, bicubico; il rilievo del terreno e
    l'ombra d'angolo sulle pareti da `LightMap.shape_tex`, la forma della finestra: rosso = pieno, verde = parete);
    `LightMap.SEEP` (la luce entra nella roccia solo per disegnarla). Le pareti: `WallFx` (macchie nello spazio del
    mondo) e `DecorPainter.WALL_CONTRAST`. La tinta delle zone: `GradeData` + `ZoneGrade` (livello 4, opzione
    «tinta_zone»; i toni si correggono come li vede l'occhio, il nero resta nero). Le creature: `Creature._life_motion`.
    I bordi: `OrnamentArt` + lo strato «orn» di `WorldView` (solo vista). Il pulviscolo in `AmbientFx` (sotto la luce).
  - Provati e scartati: il velo d'aria luminosa (la luce ridisegnata in somma: colonne di nebbia) e il filo di luce sul
    contorno delle creature (toglierebbe il nascondersi nel buio).
- **Roadmap 34 «Gli sfondi»** (voci 328-332, 2 ott 2026; scelta dell'utente: solo ciò che non tocca il generatore):
  - Le foto: gruppo «sfondi» (`TestsBackdrop`: la superficie di ogni bioma del mondo di prova, notte, i tempi, stormo,
    pipistrelli; prove/sfondi/, partenza in prove/sfondi_prima/), `tools/foglio_sfondi.py`,
    `python tools/confronto_volto.py prove/sfondi_prima prove/sfondi prove/sfondi_confronto.png`.
  - `BackdropData` (per ogni bioma il cielo a quattro colori e tre piani [disegno, parallasse, spostamento, larghezza,
    colore, accento]) e `BackdropArt` (i disegni); `Background` fa i piani di un bioma in un thread la prima volta
    (`_want`), li sfuma (`BackdropData.FADE`), `_snap_set` nei salti; le radici del cosmo restano di tutti. **Un bioma
    nuovo = una riga in `BackdropData.SETS`** (senza riga ha lo sfondo della foresta).
  - Le nuvole: `CloudArt` (le immagini: tono in R, turno in G) e `SkyClouds` (due piani, shader, campo `cloud` di
    `WeatherData` = [copertura, scurezza]; `Weather` passa il vento). Un tempo nuovo ha il suo campo `cloud`.
  - `SkyLife` (`src/game/sky_life.gd`): stormi, pipistrelli, faville dei biomi in `EMBERS`.
  - Il Giardino ha uno sfondo suo (2 ott 2026): `GardenBackdrop` + `GardenBackdropArt` (piani con parallasse verticale
    grande: con un salto lo sfondo resta nel mondo, non segue il Germogliato), acceso da `Background.set_void`.
  - `WorldView` dipinge un blocco nuovo a righe (`_make_chunk`, `_paint_rows`, `_job`, `BUDGET_US`): costava 17 ms in
    un fotogramma. Chi vuole tutti i blocchi pronti subito usa `set_view(…, true)`.
- **Roadmap 35 «Atmosfera»** (voci 333-340, 2 ott 2026; solo vista e suono, niente cambia le tessere né i salvataggi):
  - Le foto: gruppo «atmosfera» (`TestsAtmosphere`: dodici scene, partenza in prove/atmosfera_prima/; confronto con
    `python tools/confronto_volto.py prove/atmosfera_prima prove/atmosfera prove/atmosfera_confronto.png`), con le misure
    in testo (increspature, neve, suono, lucciole).
  - La luce: `LightMap.bolt` (il lampo del fulmine sul cielo aperto) e `LightMap.pulse` (luci brevi, strato «lampi»);
    `Projectiles.glow_of` (la luce dei colpi d'elemento).
  - I frammenti: ricette in `ImpactData` (`DIG`, `CHIP`, `HIT`, `DEATH`, `SPLASH`, `FOAM`), eseguite da `ImpactFx`
    (`src/art/`). **Un elemento o una natura nuova di creatura** ha la sua riga in `HIT`/`DEATH` (altrimenti quella vuota).
  - L'acqua: in `LiquidView` il riflesso del cielo e le cascate (riconosciuti dall'alfa: il corpo arriva al più a 0,98);
    `WaterFx` (increspature, spruzzi, schiuma, colore del cielo riflesso).
  - `WeatherCover` (neve, bagnato, cenere sulle cime che vedono il cielo), `SoundSpace` (`src/audio/`: bus «Spazio» con
    riverbero e filtro, il vento), `SurfaceLife` + `SurfaceLifeData` (lucciole, polline, foglie; l'erba che si piega con
    `WindFx.set_push`).
- **Roadmap 36 «La storia vera»** (voci 341-349, 3 ott 2026; il canone è in `UNIVERSO.md`, «La storia vera»: i
  Seminatori sono i Guardiani; tono cupo, poco testo). **Ogni testo nuovo di storia segue quel canone.**
  - `LoreConds` (`src/game/`): le condizioni della storia come dati (`stat`, `sower`, `spent`, `nero`, `albero`, `page`,
    `dream`, `echo`, `truth`, `truths`, `all`/`any`), lette da tutti i moduli qui sotto.
  - `SowersData` + `Sowers` (i Seminatori nei Cuori: `stats["risveglio_<id>"]`/`["spento_<id>"]`, da
    `Guardian.resolved` e dal `primo_boss`), `DreamsData` + `Dreams` (i sogni, da `Masonry.slept`), `EchoesData` +
    `Echoes` + `EchoFx` (gli echi, dal primo scrigno delle rovine aperto in `Interact`), `TruthData` + `Truth` (il
    Taccuino della verità), `MythsData` (le leggende dei biomi in `BiomePages.text_of`), `VoidVoiceData` + `VoidVoice`
    (la Bocca nei luoghi malati). Le pagine «storia:…» del Taccuino le dà `Chains._story_modules` (ogni modulo ha
    `rows(selected)` e `detail()`). Enciclopedia: `EncyLoreData` (senza svelare).
  - Prove: gruppo «storia» (`TestsLore`, anche nel giro intero; `refs` controlla che ogni condizione nomini cose che
    esistono: un sogno con un nome sbagliato sarebbe impossibile da trovare, in silenzio).
- **Roadmap 37 «Ciò che conta»** (dal 4 ott 2026; dalla prima partita vera dell'utente):
  - `ItemUses` (`src/game/item_uses.gd`): «A cosa serve» di ogni oggetto in Esamina, letto dai dati di ogni sistema.
    **Un sistema nuovo che consuma, chiede o mostra oggetti aggiunge la sua funzione `_from_…`**; un tipo d'oggetto
    nuovo con un uso al clic ha la sua frase in `KIND_USE` (la prova «guida» scrive prove/oggetti_senza_uso.txt: 0).
  - `HowToData` + `HowTo`: che cos'è e come si fa ogni conteggio che una richiesta chiede (Albero-Madre, Bacheca, filo).
    **Un conteggio nuovo chiesto dall'Albero = una riga in `HowToData`** (`verifica_dati` lo controlla).
  - `Combat.AMMO` nasce dai dati (ogni «munizione», dal danno più alto).
  - La Dispensa fino a 720 caselle (`BackpackData.DISPENSA_SLOTS`), le schede per tipo in ogni cassa (`ChestPanel._cats`,
    tipi di `StorageData`), «Dove ce l'hai» in Esamina (`Storage.where_text`, collegato con `ExaminePanel.where_fn`).
  - I servizi degli abitanti: `ServicesData` (una riga per servizio) + `Services` (una funzione `_<kind>`, "!" davanti =
    non riuscito e non si paga), mostrati a sinistra del commercio (`TradePanel._fill_services`).
  - Le regole del profondo: `DeepRulesData` (una riga per strato: udito, rare, branchi, imboscate, rigore, `spawn_dark`,
    materiale) + `DeepRules` (imboscate, materiali dalle rare, riga sopra l'orologio, `lit_by_player`). **Nel profondo la
    luce naturale non ripara dalle nascite**: prima Profondità e Fondo erano quasi vuoti (misura nel gruppo «profondo»).
  - Il risveglio: `AwakenData` (forma → effetto «ris_…» di `EffectsData`, costo dal grado del metallo) + `Crafting.awaken`;
    `Effects` legge "dati.risveglio" dell'oggetto in mano e dei pezzi indossati. **Una forma nuova = una riga in
    `AwakenData.FORM`** (la prova «profondo» segnala le forme senza modo).
- **Il piano «La vastità»** (`VASTITA.md`, Roadmap 38-51, dal 6 ott 2026; scelte dell'utente: niente estetica pura,
  calibrare tutti i numeri). **Regole per ogni voce del piano**: un oggetto, un gesto (un'arma o un accessorio nuovo
  senza un comportamento che lo distingua è una gemella); ogni fonte ha i suoi oggetti e ogni oggetto la sua fonte; ogni
  fase porta qualcosa a ogni stile; le soglie cambiano il mondo; quantità dalle tabelle, sapore dalla mano; i nostri
  sistemi (geni, ecologia, mandria, rete, lingua, pilastri) ricevono e danno. **Ogni Roadmap si chiude con
  `tools/vastita.gd`** (i buchi per blocco di fasi, accanto a Terraria + Calamity + Thorium), `tools/percorso.gd` e la
  calibrazione.
  - Roadmap 38 «Le fondamenta»: `GesturesData` (moduli dei colpi: rimbalzo, divisione, scoppio, ritorno, onda; il gesto
    di ogni materiale, effetti «mat_…»; le leghe portano i due gesti; `single_bonus` per `FightModel`), `PhasesData`
    (24 fasi provvisorie, fase calcolata dai dati con `of(id)`, 12 rarità con il colore del nome; il campo `fase` vince),
    `LootData.roll` con `group`/`w` («uno a scelta tra») e `first` («prima volta», `Fauna.first_hook`),
    `tools/vastita.gd`, `tools/confronto.gd` (lo stesso conteggio di Terraria), il generatore `tools/gen_comune.py` +
    `tools/gen_vastita.py` (un modulo per famiglia in `tools/vastita_gen/`, pacchetti in `src/data/vastita/` da
    aggiungere a `BiomesData.PACK_FILES`). Prove: gruppo «vastita».
  - Roadmap 39 «La spina della partita» (voci 362-366): `SpineData` (le curve: Vita delle creature ×1,3456 per vigore
    fino al vigore `SOFT` 11, il danno a parte `DMG_STEP`, la Vita dei Guardiani × `boss_time`; la fase di un vigore 2v-1 e
    di un grado di metallo 2t-1; il filo di ogni grado `filo_of_tier`; i sei **metalli del Risveglio** `METALS` con
    grezzo, vigore, strato e tessere, i loro `TRAITS`, `SETS`, `GESTURES`; la Linfa del Cuore `ITEMS`).
    `VigorData.creature_mult`/`creature_dmg`, `Portal.vigor_mult`/`vigor_dmg`/`boss_mult`, `Fauna.vigor_dmg`,
    `Fauna.boss_mult` e `Fauna.dmg_for(hp_mult)`: **ogni creatura nuova si rafforza con `strengthen(Vita, danno)`**, mai
    con un solo moltiplicatore. I metalli del Risveglio passano da `MaterialsData.all()` (campo "spina") e cadono con
    `GeneMaterials.spine_for`; `CuoreDesto` (`src/game/cuore_desto.gd`): il Risveglio (`stats["risveglio_cuore"]`,
    `Fauna.awake_rare`, un'Aiuola in più) e la pagina «La spina» del Taccuino. I Guardiani generati hanno una
    pericolosità comune (`GuardianGen.threat`, `GuardianGenData.THREAT`). Misure: `tools/percorso.gd` (fino al vigore 15),
    `tools/boss.gd`. Prove: gruppo «spina» (`TestsSpine`). Enciclopedia: capitolo «spina».
  - Roadmap 40 «Le armi» (voci 367-372): `StylesData` (otto stili, la risorsa di ognuno, lo stile di ogni forma
    `of_item`) e `Styles` (`src/game/styles.gd`: Slancio, Mira ferma, Ispirazione e canti, Rugiada, la riga sopra la barra
    rapida; i colpi con "style" tornano da `Combat.on_shot` in `note_hit`) + `StyleTurrets` (i semi-torre). 19 forme
    nuove in `FormsData` (`PURE`: niente leghe; `FORM_FX` effetti propri; `AMMO_OF` munizione), icone in `StyleShapes`.
    `AmmoData` (34 munizioni a tre tipi, `MODS`, danno che conta con l'arma `K`). Le armi firma e le linee d'arma sono il
    pacchetto generato `src/data/vastita/armi_firma.gd` (`tools/vastita_gen/armi_firma.py`): campo "firma" = i valori
    li fa `FormsData.firma_stats(forma, fase)` (il metallo virtuale della fase), "mods" = i loro moduli
    (`Combat.gesture_opts(…, extra)`), "power_mult" per le linee; tabelle «firma_f<fase>» tirate da `FirmaDrops`
    (Guardiani, capi) e dagli scrigni di `PassRovine`. Gli effetti dei pacchetti stanno in `EffectsData.PACK`; un effetto
    «colpo» o «ogni» può avere una "cond". **Un'arma nuova: si sceglie lo stile e si guarda `tools/armi.gd`.**
    Prove: gruppo «stili» (`TestsStyles`). Enciclopedia: capitolo «stili».
  - Roadmap 41 «I boss come tesori» (voci 373-377): due pacchetti generati. `src/data/vastita/guardiani.gd`
    (`tools/vastita_gen/guardiani.py`): nove Guardiani per i vigori 4-12 (campo «guardians» → `GuardiansData.LIST`, campo
    «calls» → `SummonData.CALLS`, il corpo da una specie con «body», due fasi con «fury» e «phase_elem»), i Sacchetti
    di tutti i Guardiani (tipo «sacchetto», `FirmaDrops.bag`/`open_bag`, tabella in «table»), gioielli, trofei, Richiami.
    `src/data/vastita/capi.gd` (`tools/vastita_gen/capi.py`): 24 capi erranti (campo «chiefs», li fa comparire `Chiefs`
    una volta per mondo nello strato giusto), 10 boss facoltativi e 3 superboss (esche al Cerchio con «free» e «vigor»
    in `SummonData.CALLS`: `Summons` li chiama senza averli affrontati, con la forza del loro vigore), la corsa dei
    Guardiani (`BossRush`, il Corno della corsa). La taratura del danno dei capi è in
    `tools/vastita_gen/capi_taratura.json`, scritta da `python tools/tara_capi.py` con `tools/boss.gd`.
    Prove: gruppo «tesori» (`TestsTreasures`). Enciclopedia: «Capi erranti e boss facoltativi».
  - Roadmap 42 «Le creature» (voci 378-382): 13 mattoni nuovi dei comportamenti (`onda`, `pioggia`, `raggio`, `spine`,
    `molla`, `rotola`, `tonfo`, `specchio`, `orbita` e `zigzag` dopo «vola», `arrampica`, `raffica`, `balzo`; parametri in
    cima a ogni file). Il pacchetto `src/data/vastita/bestiario.gd` (`tools/vastita_gen/bestiario.py`): 104 risvegliate
    (campo «awake»: nascono solo con `CreaturesData.awake_on`, acceso da `CuoreDesto.apply`; lo leggono anche
    `UnderBiomesData.pool_at`, `SkyData.pool_of` e `ZoneModel.pool` dal vigore 5) e 42 specie firma (una combinazione di
    comportamenti che hanno solo loro). `BannersData` + `Banners`: lo stendardo di ogni famiglia ogni 50 sconfitte
    (`stats["uccisi_fam_…"]`), issato per sempre (`stats["stendardo_…"]`; `Combat._strike` e `Fauna.guard_hook`), quello
    d'oro al Telaio con i trofei. Il pacchetto `eventi.gd` (`tools/vastita_gen/eventi.py`): otto eventi con «boss» (lo fa
    arrivare `Chiefs.place` all'obiettivo), «vmin», «awake» e il segnale (tipo «segnale», `Events.call_event`);
    `EventsData.EVENTS` ora unisce i pacchetti. Prove: gruppo «bestie» (`TestsCreatures42`).
  - Roadmap 43 «Gli accessori e il movimento» (voci 383-388): `Abilities` (`src/game/abilities.gd`: i «quando» del
    movimento salto, salto_aria, atterraggio, scatto, raccolta, volo, aggancio; le cose nuove scia, scudo
    `Vitals.ability_scorza`, magnete `Drops.ability_magnet`, slancio, ispira, mira; il resto passa da `Effects._do`).
    Il pacchetto `src/data/vastita/accessori.gd` (`tools/vastita_gen/accessori.py`): 138 accessori firma (tabelle
    «accessori_f<fase>», da `FirmaDrops` e dagli scrigni), 30 linee dell'Officina (120 passi al Maglio), 22 ali (campo
    «wings» → `FlightData.WINGS`, con «effects»), 22 rampini, 48 animaletti (campo «pets» → `CompanionsData.PETS`; il
    dono «acc» lo somma `GearEffects`; tabella «animaletti»). Prove: gruppo «accessori» (`TestsAccessories`).
  - Roadmap 44 «Le armature e i set» (voci 389-391): `ArmorData` (`src/data/armor_data.gd`): gli otto elmi degli stili
    (`HELMS`, forme pure di `FormsData` di tipo «elmo», bonus «st_<stile>»: chiavi di `GearEffects.MULT`; vale quello
    dell'arma in mano, `Combat.style_mult`, e `Combat.ally_mult` per gli alleati), i set degli stili («stile_<stile>_<mat>»
    in `SetsData.all()`), le abilità dei set (`SET_FX`, `STYLE_FX`, righe in `EFFECTS` lette da `EffectsData.info`;
    `Effects.refresh` le aggiunge per i set completi; le abilità «ferita» colpiscono `Effects._attacker()`; la cosa nuova
    «fulmine», `Effects._bolt`) e le essenze della forgia (`ESSENCES` → `TraitsData.TRAITS`, tabella «essenze_forgia»;
    `WORN_KEYS` = i tratti dei pezzi indossati letti da `GearEffects`). Le spoglie dei boss: il pacchetto
    `src/data/vastita/armature.gd` (`tools/vastita_gen/armature.py`): set di tre pezzi per Guardiani, capi, sfidanti,
    superboss ed eventi, tabelle «armatura_<creatura>» tirate da `FirmaDrops`. Icone in `HelmShapes`. Prove: gruppo
    «armature» (`TestsArmor`).
  - Roadmap 45 «I ritrovamenti» (voci 392-397): `Finds` (`src/game/finds.gd`: casse sigillate e chiavi, mimi, la Pozza,
    i guardiani delle strutture `guard`, il dono del Cuore dei mondi segreti) e `Rares` (`src/game/rares.gd`: il raro di
    ogni specie, campi «raro_di»/«raro_p»). I pacchetti generati: `rari.gd` (`tools/vastita_gen/rari.py`, dall'elenco
    `tools/vastita_gen/specie.json` scritto da `tools/specie.gd`: **da rifare dopo specie nuove**), `ritrovamenti.gd`
    (casse dei biomi: campo «chests» → `ChestsData.FOUND`, «mimics» → `ChestsData.MIMICS`; `ChestsData.biome_at` e
    `biome_roll` le mettono in `PassRovine` e `PassOsservatori`), `strutture.gd` (campi «places» e «grids» →
    `PlacesData.PLACES/GRIDS` con "struttura": true, messe da `PassStrutture`, appunti `notes["strutture"]` letti da
    `Places`), `segreti.gd` (cinque geni «segreto» con «combo», oggetti «segreto_<gene>»). La Pozza: `PassPozza`,
    `TransmuteData` (famiglie calcolate dagli altri dati). Prove: gruppo «ritrovamenti» (`TestsFinds`).
  - Roadmap 46 «Consumabili, pesca e cucina» (voci 398-400): `BoonsData` (`src/data/boons_data.gd`: gli effetti a tempo
    scritti come dati, campo «boons» dei pacchetti: "acc" sommati da `GearEffects` con `Boons.data_accs`, "effects" letti da
    `Effects` con `Boons.data_effects`, "special" = le viste di `Boons._visions`). Il pacchetto
    `src/data/vastita/consumabili.gd` (`tools/vastita_gen/consumabili.py`, ingredienti da `tools/vastita_gen/materiali.json`
    scritto da `tools/materiali.gd`): 40 linee × 3 gradi di pozioni, cinque cure, 14 fiale, otto fonti (campo «stations» →
    `StationsData`; la stazione con "boon" la tocca `Interact`, disegno `CompactArt._fonte`), 90 piatti, le casse da pesca
    (campo «crates» → `FishingData.CRATES`, `special_crate`; "table" e "firma_f" in `Fishing.open_crate`) e i premi del
    Pescatore (campo «angler», `AnglerBook._contest`). `tools/percorso.gd` beve la cura migliore della fase
    (`potion_for`). Prove: gruppo «consumabili» (`TestsConsumables`).
  - Roadmap 47 «Costruire con uno scopo» (voci 401-403): `RoomsData.boss_of_trophy` (il trofeo di ogni boss; quelli
    degli eventi nel pacchetto `costruire.gd`, da `FirmaDrops`) e `Rooms.trophy_vs` (letto da `Combat._strike`); le
    stanze nuove in `RoomsData.TYPES/ORDER` (forgia, alchimia, officina, serra calda, sala d'armi) con
    `Crafting.room_extra`/`room_temper` e `WeaponArts.room_mult`; le proprietà «blast» e «slow» dei materiali di
    `BuildData` (`Throwing.explode`, `Creature._floor_slow`). Prove: gruppo «scopo» (`TestsPurpose`).
  - Roadmap 48 «Il commercio e gli abitanti» (voce 404): `ShopsData` (`src/data/shops_data.gd`: le merci del momento
    `extra(npc, vigore, stagione, notte, evento)` e quelle a rotazione del Mercante dei mondi `rotating(giorno)`; dati nel
    pacchetto `commercio.gd` da `tools/vastita_gen/commercio.py`, che sceglie dal catalogo `tools/vastita_gen/catalogo.json`
    scritto da `tools/catalogo.gd`, secondo il mestiere `TRADES` e la fase). `TradePanel` a pagine (`pages`, `turn`);
    `Visitors` porta il Mercante un giorno sì e uno no. Prove: gruppo «commercio» (`TestsTrade`).
  - Roadmap 49 «La difficoltà come contenuto» (voce 405): `ModesData` (le tre modalità: Vita, danno, fase dei boss,
    oggetti in più, Furia, cimeli) e `Modes` (`src/game/modes.gd`: `world_meta["modalita"]` scelta nel menu creando il
    Giardino e passata dai portali; `Creature.mode_hp/mode_dmg/mode_phase` applicati da `strengthen` alle creature con
    `wild`, cioè nate da `Fauna.add`; la Furia sulle ferite, un effetto dei dati «furia_giardiniere»). Il pacchetto
    `modalita.gd` (`tools/vastita_gen/modalita.py`): 42 oggetti della Radice dura («modo_dura»), 10 del Vuoto
    («modo_vuoto») e 57 cimeli (tipo «cimelio», campo "cimelio" sommato da `GearEffects` dall'Erbario), dati da
    `FirmaDrops._mode_loot`. `tools/percorso.gd -- --modo 1|2`. Prove: gruppo «modalita» (`TestsModes`).
  - Roadmap 50 «La fabbricazione profonda» (voci 406-408): `GroupsData` (gli ingredienti «@gruppo», membri calcolati dagli
    altri dati; letti da `Crafting.have/take/counts`; oggetti finti di tipo «gruppo» per Creare ed Esamina; `verifica_dati`
    vuole almeno due membri). Il pacchetto `fabbricazione.gd` (`tools/vastita_gen/fabbricazione.py`): 20 stazioni in cinque
    famiglie × quattro gradi (campo «also» = le stazioni sotto, letto da `Crafting.stations_near`; disegno
    `CompactArt._banco` dal campo «bench»), 40 armi, 24 pezzi d'armatura in 8 set con abilità, 20 accessori, seconde
    ricette di Linfa antica, essenze, cure e chiavi. `ItemUses._from_purpose` (trofei dei boss, membri dei gruppi):
    0 oggetti senza uso. Prove: gruppo «fabbricazione» (`TestsDeepCraft`).
  - Roadmap 51 «Il dopo senza fine» (voci 409-411): i sei metalli del dopo stanno in `SpineData.METALS` (campo «dopo»,
    «keep» = per quanti vigori si scavano; carattere, set e gesto come gli altri; filo +15% e tenacia +8% per metallo,
    tarati con `tools/percorso.gd`, che ora arriva al vigore 40). Il pacchetto `dopo.gd` (`tools/vastita_gen/dopo.py`):
    60 armi del dopo, 24 leggendarie (campo «leggendaria», con la storia nella descrizione), i Sacchetti del dopo
    («sacchetto_dopo_<k>», da `FirmaDrops.bag` oltre il vigore 12; `FirmaDrops.after_phase`, `LEGEND`).
    `tools/vastita.gd` sezione 6: la misura finale. Prove: gruppo «dopo» (`TestsAfter`).
- **Roadmap 56 «Il cielo grande»** (voci 439-447, 8 ott 2026; prima del piano `GENERATORE.md`, Roadmap 56-61): il mondo
  alto 1200 (`ground_depth`); il cielo in tre fasce (`SkyData.BANDS`, `BAND_FRAC`, zone `{low, mid, high, base, split,
  split_mh}`, `band_biome`/`band_rows`/`band_level`; le zone salvate senza `mid` si leggono come prima); i continenti
  sospesi (`SkyContinents`, `SkyData.CONTINENT`, con il luogo dei Seminatori `SANCTUARY`), i mari di nuvole
  (`CLOUD_SEA`), le correnti fra le fasce (`PassCielo._link`: da un'isola, da terra o dalla cima di ciò che sta in mezzo),
  il Fagiolo che attraversa le isole (`SkyData.is_sky_tile`); i biomi del cielo di mezzo `cielo_selve.gd` e
  `cielo_fonti.gd`. Misure: `tools/mappe.gd -- --lista … --prima <cartella>` (vigore 1, rumore su più coppie, mappe e
  `numeri.txt`; riferimento in prove/generatore_prima/) e `tools/cielo.gd` (terra per fascia, raggiungibilità senza ali).
  **Un bioma del cielo nuovo** va anche in `tools/vastita_gen/ritrovamenti.py` (OF, PAL), `strutture.py` e `bestiario.py`,
  poi `tools/specie.gd` e `python tools/gen_vastita.py` finché i pacchetti non cambiano più.
- **Roadmap 57 «Le profondità vere»** (voci 448-454, 8 ott 2026): `CaveStylesData` (lo stile di grotta di ogni strato,
  letto da `PassGrotte` a fasce), `PassCaverne` (grandi caverne con un contenuto e voragini con le cenge; appunti
  "caverne", "voragini"), le regioni sotterranee (`PassSottosuolo._regions`, appunti "regioni"), i confini vivi
  (`PassStrati.LOBE`: cambia la roccia, non lo strato del gioco), le falde (`PassAcqua.FALDE`), la strada al Fondo
  (`PassStrade` con i ponti di passerelle, riaperta da `PassStradeRiapri`). Misura: `tools/sottosuolo.gd`.
- **Roadmap 58 «I tesori della roccia»** (voci 455-458, 8 ott 2026): i metalli in giacimenti (`TileDefs.DEPOSIT`, una
  maschera per metallo in `PassMinerali`), i segni (`PassAffioramenti`: affioramenti e sassi luccicanti), le grotte di
  cristallo (`PassCristalli.MASK`, la stessa maschera sceglie i posti delle gemme in `PassGemme`). Il parametro
  «senza_giacimenti» rifà la regola di prima per le misure: `tools/giacimenti.gd`, `tools/tesori.gd`,
  `tools/minatore.gd` (il minatore simulato: **dopo ogni cambio ai minerali** il cieco deve rendere come prima, ±15%).
- **Roadmap 59 «Mondi che non si somigliano»** (voci 459-464, 8-9 ott 2026): `WorldShapesData` (le sette sagome, scelte
  dal gene con "shape"; `has_sea`, `SEA_EDGE`), `PassSagoma` (canyon, terrazze, sprofondato: solo la superficie, mai più
  di 110 righe in giù perché gli strati la seguono), `PassPilastri` (pilastri e liane del canyon), `PassMari` (i mari ai
  bordi; l'acqua e il relitto in `PassAcqua._seas`; pesci con «sea», `Fishing.is_sea`), il carattere dei biomi
  (`BiomesData.WIDTHS`, `CLIMATE`, `mix_at` letto da `PassErba` e `PassAlberi`), `PassTracce` (radice cosmica, città,
  cratere; parametro «traccia»). Varietà: `tools/mappe.gd -- --semi 30 --caso --vigore 7` (gruppo «sagoma»); foglio
  delle sagome `tools/foglio_sagome.py`. **Un gene nuovo con un valore di testo** passa da `Genome.effects` (il caso
  String).
- **Roadmap 60 «La superficie da cartolina»** (voci 465-469, 9 ott 2026): `PassRilievo` (massicci a pareti e cenge,
  erosione; solo la superficie), `PassRocce` (archi, sporgenze e **tutte le liane**: va dopo `PassDecorazioni`, che
  riscrive ogni cella d'aria e cancella le decorazioni messe prima), `PassRiferimenti` (guglie, rovine sul colle, cerchi
  di pietre; appunti «riferimenti» → `world_meta` da `MapReveal` → la mappa), `EntrancesData` + `PassIngressi` (quattro
  forme d'ingresso), `PassAcqueSuperficie` (laghi nelle valli, fiumi; mai entro 150 colonne dalla partenza, dove le
  prove costruiscono). Foto prima e dopo: gruppi «sfondi» e «volto» con `tools/confronto_volto.py`.
- **Roadmap 61 «Il collaudo del generatore»** (voci 470-478, 9 ott 2026): `ReachMap` (`src/world/gen/reach_map.gd`: dove
  si arriva a piedi dalla partenza senza scavare; salti, cadute di corsa, passerelle, nuoto, liane, correnti),
  `tools/connettivita.gd`, `PassCollaudo.reach_of` (parametro «raggiungibile») e la prova `TestsWorld.reach` nel gruppo
  «base» (superficie ≥ 85%, oggi 97-99%). **Una struttura nuova costruita sopra la terra vuole le sue liane** (o la
  rimette il collaudatore con `PassRocce._wall_vines`, che parte dalla superficie e sale finché la roccia continua);
  dentro una corrente, tenendo il salto, vince la corrente sulla liana (`Player._step`). Misure nuove in
  `tools/mappe.gd` (con `--prima`), il riferimento finale in prove/generatore_61.
- **Roadmap 52 «La terra dei mondi»** (voci 412-418, 7 ott 2026; richiesta dell'utente: i blocchi a confronto con
  Terraria). Tutto nel pacchetto generato `src/data/vastita/terre.gd` (`tools/vastita_gen/terre.py`; tessere 59-119):
  - Campi nuovi delle tessere dei pacchetti: «kind» (suolo, roccia, comune, minerale, gemma, blocco), «look» (il disegno
    in `TerrainPainter._look`) e i comportamenti, letti in tabelle per numero di tessera di `TileDefs`: FALLS (frana,
    `LivingEarth`), SLIP e STICK (`Player._step`, `Creature._floor_slow`), SOFT (`Life._on_landed`), FERTILE (`Garden`),
    WARM (`Harshness.near_warm`), QUIET (`Senses`), BLAST (`Throwing`), FOSSIL (`GeneMaterials`), BOUNCE (`Player`),
    FRAGILE e SPIKE (`Grounds`), LIQ_PASS (`Liquids._solid`), DORMANT con `awake_on` e `drop_of` (le vene dei metalli
    dormono fino al Risveglio). **Chi rompe una tessera usa `TileDefs.drop_of`**, non `DROP`.
  - Campi nuovi dei pacchetti: «soils» (terra e roccia di ogni bioma, `PassTerre`), «veins» (vene e sacche, unite a
    `TileDefs.ORES`; «vmin»/«vmax» = i vigori, «oct» = ottave del rumore), «icon_pals» (`ItemIcons.MATERIALS`), «gems»
    (`JewelsData.GEMS`), «climbs» (le corde: decorazioni 98-100, `TileDefs.CLIMB_SPEED`), «plats» (le passerelle: il byte
    di `World.plats` è il tipo, `plat_kind`, `TileDefs.PLATS` e le tabelle `PLAT_*`).
  - Il disegno del terreno: la tavola è divisa in sorgenti da 8 righe (`TerrainPainter.source_of`) e ogni blocco crea lo
    strato di un materiale solo quando serve (`WorldView._terrain_layer`); una cella guarda solo gli strati delle sue
    quattro tessere. **Un materiale nuovo del terreno non costa più nulla a chi non lo vede.**
  - Le spine dei biomi e la ragnatela (voce 418): campo «thorns» → `TileDefs.THORNS` (decorazioni 101-105), lette da
    `Hazards._thorn` (mult, slow, poison, shatter, web), messe da `PassSpine`, disegnate da `ThornArt`. Le sacche e le
    vene nuove hanno «rich»: false (non si allargano con il vigore: nei mondi alti la pietra nera diventava enorme).
  - `Grounds` (`src/game/grounds.gd`): lastre che crollano, rovi che pungono, `place_rope`. L'arrampicata è
    `Player._climb_step` (`climbing`, `auto_down` per le prove). `PassLiane` (le liane del Sottobosco).
  - Misura: `tools/blocchi.gd` (prove/blocchi.txt: le categorie accanto a Terraria). Prove: gruppo «terre» (`TestsLands`,
    foto 260-263). Enciclopedia: capitolo «terre»; consigli «terra_viva» e «corde».
- **Roadmap 53 «La Bisaccia a scomparti»** (voci 419-422, 7 ott 2026; l'utente: «la bisaccia si riempie troppo spesso
  all'inizio»): `BagData` (i nove scomparti = i tipi di `StorageData.category_of`, `section_of`, `is_collection`, le
  grandezze `GRADES`, `POUCH_SECTION`). Nella Bisaccia del personaggio gli scomparti sono **tratti contigui di `slots`**
  dopo la barra rapida (`sections` = [[id, da, a]], `section_size`, `section_range`, `setup_sections(size, keep)`,
  `restore_sections`): chi scorre le caselle da `HOTBAR` in poi lavora già sugli scomparti. `add` con gli scomparti
  (`_add_sections`): la pila uguale della barra rapida, gli scomparti fissi (`comps`), la Raccolta o lo scomparto del tipo,
  poi la barra rapida, poi il basto. La Raccolta (`raccolta`) è una Bisaccia a parte in `all_bags`, senza limite.
  **Un oggetto nuovo non sceglie lo scomparto: lo decide il suo tipo** (`StorageData`), e ciò che si legge o si
  colleziona va nella Raccolta (`BagData.RACCOLTA_KINDS`). Le prove che vogliono un oggetto in mano usano `kit.hold`
  (prende anche dagli scomparti e dalla Raccolta). Pannello: schede in colonna (`BisacciaPanel._section_views`, `page`).
  Prove: gruppo «zaino» (`sections`, `stash`, foto 300, 301, 308).
- **Roadmap 54 «Il passo delle creature»** (voci 423-427, 8 ott 2026; l'utente: «a volte di punto in bianco scappano
  passando attraverso il terreno»): la misura è il gruppo «moto» (`TestsMotion`: recinti scavati sotto terra che rifanno
  ogni difetto, con salti a vuoto, tremolii, fotogrammi incastrate; foto 330). `Creature.can_hop(dir, v)` dice se un muro
  si supera con un salto vero (altezza e spazio): **chi salta contro un muro lo chiede prima**, altrimenti salta
  all'infinito; `Creature._unstick` toglie dalla roccia chi ci resta mezzo secondo; `Creature._ready` chiama `enter` dei
  comportamenti che lo hanno (`BhSbuca`: nasce nella terra). In `Mind` la fuga delle ferite dura finché la creatura ti
  vede, poi lo stato `REST` (si nasconde e si cura); all'angolo si difende (`_cornered`). `Behavior.may_attack`: **un
  comportamento d'attacco nuovo non comincia se la creatura fugge**; `Mind.after` non tocca chi è `busy`.
- **Roadmap 55 «Il volto chiaro»** (voci 428-438, 8 ott 2026; l'utente: pannelli e schede «poco eleganti, alcune confuse
  ed in generale molto pixellose… togli tutti i caratteri a pixel… hai carta bianca»). La guida è `ARTE.md` §2-5.
  - I caratteri: `UiFonts` (`src/ui/theme/`): Alegreya (titoli, nomi, pagine da leggere) e Alegreya Sans (il testo), in
    `arte/caratteri/` (OFL); ruoli `testo`, `chiaro`, `forte`, `corsivo`, `numeri`, `titolo`, `nome`, `libro`,
    `racconto`; `apply(l, k)` per i titoli (al posto di `PixelFont.apply`), `on_world` per l'HUD, `world` (MSDF) per le
    scritte dentro il mondo. La scala del testo in `UiPalette` (16 il testo).
  - Le cornici: `UiStyle` (uno StyleBox scritto in GDScript: base StyleBoxFlat, filo che sfuma, luce dall'alto, alone,
    gemma), fatte da `UiFrames.box` con la stessa chiamata di prima (tipi nuovi `sezione`, `chip`, `icona`).
    `UiTheme.smooth_layer`: filtro morbido per l'interfaccia (il mondo resta a pixel netti) e contorni ammorbiditi.
  - Il kit: `UiKit` (pezzi), e in `src/ui/kit/` `UiPage` (lo scheletro dei pannelli: `build_page`, `set_chips`,
    `set_tabs`/`select_tab`, `split`, `detail_w`, `set_hints`, `key_action` + `open/close/toggle/refresh/mark_dirty`,
    `shown_text` per le prove), `UiList`, `UiDetail` (anche `bbcode`: impagina i testi dei moduli), `UiTimeline`,
    `UiMedal`, `UiBar`, `UiRule`, `UiBackdrop`. **Un pannello nuovo a schermo intero estende `UiPage`.**
  - Rifatti sullo scheletro: Pilastri, Arti, Atlante, Albero-Madre, Bacheca, Semenzaio, Innesto, Erbario, Mandria,
    Compagni, Quaderno; letture «da libro»; la scheda del Germogliato a pezzi (`CharacterSheet.parts`); i suggerimenti
    (`TipView`) con gli stessi pezzi. Prove: la galleria (0 problemi), `prove/galleria_confronto.png` (prima e dopo).
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
  I segnali del giocatore (30 set 2026): clic destro sulla mappa → `MapSignals` (triangolo, 20 colori, nome), in
  `world_meta["segnali"]`; ogni segno disegnato ha il suo nome in `MapPanel._hits` e la scheda al passaggio del mouse.
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
- `src/game/crafting.gd` (`Crafting`) — regole della fabbricazione: stazioni a portata (`StationsData.craft_reach`, 10 tessere, opzione «raggio_banchi»), ricette usabili,
  materiali bastano?, fabbrica. Gli ingredienti vengono dalla Bisaccia e dalle casse
  vicine (`pool`, `have`, `take`): ogni nuovo costo va contato con `have` e tolto con `take`, non con `Bisaccia.count`.
- `src/game/storage.gd` (`Storage`, dati in `StorageData`) — le casse (26 set 2026, richiesta dell'utente): le casse
  entro `StorageData.craft_reach` tessere (20, opzione «raggio_casse») con «usa per creare» danno gli ingredienti (`Crafting.pool`); impostazioni per cassa in
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
  Anche la foto della finestra è lineare: salvata così viene molto più scura dello schermo. Si fotografa con
  `await Photo.take(viewport)` (`src/core/photo.gd`, voce 267), che converte con uno shader.
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

- Un riferimento statico a un dizionario del personaggio (`Crafting.words = character.lingua`) si perde quando il
  dizionario viene **sostituito** (salvataggi, prove che lo rimettono com'era): lo si riassegna dove il dato cambia
  (`Language._sync_stat`), non una volta sola all'avvio.
- Una meccanica «da decifrare» va misurata con un giocatore simulato (`tools/lingua.gd`): la prima misura ha trovato cinque
  parole che non comparivano in nessuna frase, cioè impossibili da imparare.
- Negli heredoc del Bash tool i caratteri come «—» possono arrivare rovinati e far fallire una sostituzione: per le
  modifiche con testo accentato, Edit o uno script scritto con Write.

- **I numeri si misurano con un giocatore, non a occhio** (Roadmap 18, 29 set 2026): il bot in arena ha mostrato che nel
  duello uno contro uno quasi non si è toccati (ogni colpo ferma la creatura 0,22 s) e che le ferite vengono da
  sorprese, gruppi e logoramento; il giocatore simulato ha mostrato che una Scorza «a sottrazione» smette di contare
  contro le creature forti, e che la ricrescita della Vita fissa rendeva inutili i doni di Vita. Un profilo si tara su
  dati veri (il Diario dell'utente), gli altri si definiscono come differenze di abitudini da quello.
- Un simulatore che combatte senza sosta fino alla morte sbaglia: una persona si ferma a riposare quando la Vita è bassa
  (`tools/percorso.gd`, soglia «rest» dei profili). Senza, anche i più attenti «morivano» 15 volte all'ora.
- Un difetto raro (3%) può restare nascosto a lungo: la cassa pescata fermava il gioco solo quando il caso della prova
  la sceglieva. Nei rami rari del codice si controlla che ogni valore usato esista per quel ramo.

- **Roadmap 19** (29 set 2026): non chiamare una funzione `_set` (è un metodo virtuale di Object: «The function
  signature doesn't match the parent»); `get_meta(k, null)` dà errore se la chiave manca: si usa `has_meta`.
- Un ridisegno «di tutto» a ogni cambio non scala: con 2 000 vene ogni vena posata ridisegnava tutte le celle (131 ms).
  Si ricorda che cosa è disegnato (`Energy.painted`) e si ridisegna solo ciò che cambia; nei cicli sulle celle si legge
  l'array direttamente e le regole piccole si scrivono in linea (`EnergyGraph`: da 25 a 6 ms).
- `rindex(']')` nelle patch Python ha colpito ancora (la parentesi di `c["id"]` in una funzione dopo la lista): la fine
  di una costante si cerca con `index('\n]\n', inizio_della_costante)`.
- Le prove che mettono liquidi o creature cercano un posto lontano dai laghi (una prova passava o no secondo il lago
  del mondo di prova) e creano le creature con `Fauna.add` (`spawn_at_nest` rifiuta vicino alle torce, a caso).
- Un comando con un'attesa (i nodi) cambia il filo un passo dopo: una prova che cambia due cose nello stesso fotogramma
  (abbassa una leva e ripara una vena) vede la porta aprirsi nel mezzo. Si aspetta che l'Impulso si assesti.

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
- **Una voce in più in una tabella di bottino usata dal generatore** (le casse delle rovine) cambia quanti numeri a caso
  usa quella passata, quindi sposta tutto ciò che la passata fa dopo: con le cronache della Roadmap 26 le rovine si sono
  spostate e una tana dei Custodi non trovava più posto. Le passate che piazzano cose obbligatorie devono avere un
  ripiego (meno distanza, più tentativi), non contare sulla fortuna del seme.
- `String(x)` con un numero è un errore: per un campo che può essere numero o testo («place» è un numero per i blocchi)
  si usa `str(x)`. Trappole e totem lo sbagliavano a ogni fotogramma con un blocco in mano.


- **Roadmap 29** (30 set 2026): con `hdr_2d` la fusione dei colori è lineare: uno sfondo nero al 97% lascia vedere il
  mondo come se fosse al 20%, e uno scuro al 78% scurisce appena a metà. Gli sfondi che devono coprire sono opachi.
- Un carattere a bitmap con un carattere di riserva (`fallbacks`) prende le misure della riserva: le righe si
  allargavano di un terzo e i titoli si sovrapponevano a ciò che stava sotto. `PixelFont` non ha riserva.
- Le prove chiamano `LayoutCheck`, ma un difetto si vede solo se la galleria apre il pannello **com'è in gioco**: un
  avviso rimasto a metà schermo, uno sfondo trasparente, un'insegna che la barra del boss raggiunge dopo. Si guardano
  sempre le foto, non solo il conteggio; ciò che si muove dopo la comparsa (la barra del boss scende quando il filo va
  a capo) si ricolloca a ogni fotogramma.
- Una funzione di un nodo non può avere il nome di una variabile già dichiarata (`ghost` in `Creature`): «has the same
  name as a previously declared variable».

- **Roadmap 34** (2 ott 2026): in uno shader `canvas_item` di Godot 4 il `COLOR` del fragment contiene già il colore
  dell'immagine (il colore del nodo si prende nel vertex con una `varying`); con `hdr_2d` l'immagine arriva in lineare,
  quindi i numeri scritti nei canali di un'immagine si rileggono con `pow(x, 1/2,2)`. Una prova che crea qualcosa
  «dove guarda la visuale» sposta prima la visuale: lo stormo nasceva nel bioma della foto di prima e veniva tolto.
- **Roadmap 30** (1 ott 2026): una prova veloce che sceglie un punto (la nascita delle creature) deve controllare le
  **stesse** condizioni del codice che poi lo usa (pavimento, buio, torce): altrimenti le prove si sprecano su punti che
  verranno scartati (33% → 50% → 77% solo allineando i controlli). Per trovarli: un contatore provvisorio per ogni
  `return null`, poi tolto. E le luci nuove (i baccelli che brillano) tolgono posti alle nascite al buio.
- Ancora `_set` (un metodo di Object) come nome di una funzione statica: «The function signature doesn't match the
  parent». E ancora i `\` a fine riga dentro un heredoc del Bash tool: anche le patch piccole con codice GDScript si
  scrivono con Write.
- Una patch che si ferma a metà (un'`assert` fallita) lascia i file già cambiati: si rimettono com'erano con
  `git checkout` prima di rilanciarla corretta.

- **Roadmap 55** (8 ott 2026): `ImageTexture.create_from_image` dentro un `_draw` sparisce prima di essere mostrata (la
  texture è liberata a fine funzione: quadrati bianchi): le texture si fanno prima e si tengono. L'ombra di uno
  StyleBoxFlat si vede anche **dentro** il riquadro se il fondo è trasparente: l'alone si disegna prima del riquadro.
  Svuotare un contenitore con `queue_free` libera anche i nodi riusati che ci stanno dentro (i comandi della Mandria):
  si staccano prima. Un campo nuovo in una classe base (`UiPage._close`, `tab`) si scontra con quelli delle classi
  figlie («already exists in parent class»): nomi lunghi e propri nella base. E ancora: **mai patch Python dentro un
  heredoc del Bash tool** con barre rovesciate (le espressioni regolari e i «\n» arrivavano rotti): sempre con Write.
- **Roadmap 52** (7 ott 2026): un campo nuovo dei pacchetti deve avere un nome che nessun tipo di pacchetto usa già: i
  biomi del cielo hanno «ores» (un elenco di elenchi), e le vene nuove con lo stesso nome rompevano `PassMinerali` in
  silenzio (la passata si fermava e il mondo nasceva senza minerali). Prima di scegliere il nome: `grep '"nome":' src/data`.
- `RecipesData.making` ora usa un indice per oggetto prodotto: prima scorreva tutte le ricette a ogni chiamata, e ogni
  scheda di un oggetto (il prezzo, `ValueData.value`) la chiamava per ogni ingrediente: 3,3 ms a scheda. Con migliaia di
  dati, **una ricerca lineare dentro una funzione chiamata per ogni oggetto va indicizzata**.
- Una prova che misura il movimento cerca un posto **asciutto**: nell'acqua si corre a 0,6 e i numeri cambiavano a seconda
  delle pozze lasciate dalle prove di prima (o dalla pioggia). E toglie i rigori (`Harshness.meters`): a barra piena il
  caldo ferisce e spinge, e la prova passava o no secondo il bioma. `kit.flat_spot` guarda la superficie generata: un
  tratto spianato da `kit.flatten` non lo vede più, lo si ricorda.
- **Roadmap 37** (4 ott 2026): una `static var` che tiene una funzione anonima con dentro un nodo (`Crafting.awakened_hook`)
  fa andare in crash il gioco **alla chiusura** (signal 11 dopo l'ultima prova): la si svuota in `_exit_tree` del nodo.
  Il crash si vede solo in fondo al registro: dopo un giro si cerca «signal 11», non solo «ATTENZIONE».
- **Il piano del generatore** (8-9 ott 2026): una ricerca di percorso sul mondo generato vale più di molte prove: ha
  trovato metà del mondo irraggiungibile a piedi per passaggi chiusi che nessuna prova vedeva. Le passate che scavano
  la cima del terreno (imbocchi, bocche, crateri, fiumi) lasciano `World.surface` vecchia: chi cerca la terra vera la
  cerca nelle tessere. E le prove che si costruiscono un posto devono chiuderlo (lati, liquidi, tempo, posizione del
  Germogliato): con il mondo nuovo una dozzina contava su com'era il mondo di prova prima.
- Una regola del mondo che dipende dalla luce va **misurata nel posto vero**: nelle Profondità e nel Fondo la luce di funghi
  e cristalli impediva quasi tutte le nascite (3 punti buoni su 300), e nessuna prova se n'era accorta per settimane.

