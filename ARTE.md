# TERRAWORLD — La guida di stile («Radici e Linfa»)

Voce 269 della Roadmap 29 «Il volto vivo» (30 set 2026). Vale per **tutto ciò che si disegna**: interfaccia, mondo,
creature, icone, effetti. Chi aggiunge una schermata o un effetto legge qui prima di scegliere colori, misure e
movimenti. I valori stanno nel codice in un posto solo (`UiPalette`, `UiFrames`, `UiStyle`, `UiTheme`, `UiFonts`, `UiKit`, `UiPage`, `UiFx`, e per il
mondo `WindFx`, `CreatureFx`, `AmbientFx`, `Juice`): questa pagina spiega il perché.

## 1. L'idea
Un mondo scuro dove **la luce viene dalle cose vive**: Linfa turchese, ambra calda, lucciole, braci. L'interfaccia è
fatta della stessa materia: **legno di radice, ardesia, un filo di Linfa**, mai plastica o metallo lucido. Non è
Terraria: niente riquadri blu, niente bordi dorati ovunque, niente testo bianco su nero puro.

- **Calma sotto, luce sopra.** Fondi scuri e poco saturi; il colore acceso è riservato a ciò che conta adesso (ciò che
  si può fare, ciò che si è scelto, ciò che è raro).
- **Vivo ma sobrio** (scelta dell'utente): tutto risponde, niente fa aspettare. Le animazioni durano un attimo.
- **Nessun taglio, nessuna sovrapposizione** (scelta dell'utente): ogni testo sta nel suo spazio o va a capo; lo
  controlla `LayoutCheck` (gruppo di prove «galleria», obiettivo 0 problemi).

## 2. I colori (`UiPalette`)
Rivisti nella Roadmap 55 «Il volto chiaro» (8 ott 2026): inchiostro verde-notte per i fondi, un filo di Linfa per i
bordi, l'ambra per ciò che conta. **Tre colori hanno un significato fisso in tutto il gioco**: `buono` (ti aiuta, ce
l'hai, si può fare), `pericolo` (ti nuoce, ti manca, cancellare), `ambra` (il nome, il titolo, la cosa da guardare). Il
resto è testo in tre toni.

| Nome | Colore | Dove |
|---|---|---|
| `fondo` | #081011 | lo sfondo dei pannelli a schermo intero (opaco), con una luce morbida del loro colore (`UiBackdrop`) |
| `pannello` | #0f1a1b | il corpo dei riquadri |
| `pannello_alto` | #152325 | i pulsanti, le sezioni dentro i riquadri |
| `pannello_vivo` | #1c2f30 | al passaggio del mouse, ciò che è scelto |
| `bordo` | #2b4e4b | il bordo sottile normale |
| `bordo_chiaro` | #4d9c90 | bordo al passaggio, righe sottili |
| `linfa` | #7fe6d2 | il filo dei riquadri, ciò che è attivo |
| `ambra` | #f0b45c | titoli, selezione, il pulsante che conta |
| `ambra_chiara` | #ffd59a | nomi scelti, numeri importanti |
| `testo` | #e8efe9 | il testo |
| `testo_spento` | #a9bdb6 | le spiegazioni |
| `testo_muto` | #71877f | le note, i titoletti delle sezioni |
| `buono` | #8fe0a4 | vedi sopra |
| `pericolo` | #ff7a66 | vedi sopra |

**Tipi d'oggetto**: il colore di `TipWordsData.KIND_COLORS` (armi, attrezzi, armature…) tinge lievemente il fondo
della casella (10-14%), così la Bisaccia si legge a colpo d'occhio. **Rarità dei geni**: `GenesData.RARITY`.
**Gradi dei materiali**: una tacca in basso nella casella, più accesa ai gradi alti.

## 3. Le misure
- **Griglia di 4 pixel** (`UiPalette.SPAZIO`, `RIGA` 6, `SEZIONE` 18, `MARGINE` 20).
- **Il testo** (`UiPalette`): 13 mini (titoletti in maiuscoletto) · 14 note · 16 testo · 18 testo grande · 22
  sottotitoli · 32 titoli. Alegreya Sans ha l'occhio piccolo: mai sotto 13.
- **Caselle**: 56 px (Bisaccia, casse, barra rapida), icona 48.
- **Pulsanti**: alti almeno 36 (42 i principali), larghi quanto il testo più 28.
- **Lo schermo** è 1600×900: i pannelli a schermo intero hanno 48 px di margine; niente fuori.

## 4. Le cornici (`UiFrames`, `UiStyle`, `UiTheme`)
Roadmap 55: **disegnate a vettori** (`UiStyle`, uno StyleBox scritto da noi), nitide a ogni grandezza dello schermo:
fondo d'inchiostro, bordo di un pixel, angoli morbidi (8-12 px), un'ombra che le stacca dal fondo, il **filo** luminoso
sul bordo alto che sfuma ai lati (Linfa; ambra con una piccola gemma al centro nei riquadri principali) e, nei riquadri
alti, una luce appena accennata che scende dall'alto. Prima erano immagini a pixel doppi stirate: sgranate.
`UiTheme.apply` le scrive nel tema predefinito del motore: ogni Panel, pulsante, campo, cursore e menu le ha già. Un
pannello che vuole una cornice diversa usa `UiFrames.box(tipo, stato, accento)` (l'alfa dell'accento è la forza della
tinta), `UiFrames.padded` (margini diversi) o `UiFrames.button(b, accento, scelto, tipo)`. **Mai `StyleBoxFlat.new()` in
un pannello nuovo** (tranne i disegni piccoli dentro un `_draw`). Tipi: `riquadro`, `forte`, `suggerimento`, `sezione`
(un riquadro dentro un pannello, senza ombra), `chip` (etichetta tonda), `casella`, `pulsante`, `icona` (un pulsante
con la sola icona), `principale` (il pulsante che conta, d'ambra), `campo`.
- **L'interfaccia ha il filtro morbido**, il mondo il suo a pixel netti: `UiTheme.smooth_layer` lo mette agli strati
  dell'HUD e dei suggerimenti. Un disegno a pixel piccolo (un'icona di 16 px) si ingrandisce di numeri interi con il
  filtro netto (`UiKit.icon_rect` e `UiMedal` lo fanno da soli).
- **Le caselle** hanno il fondo tinto del tipo dell'oggetto o della qualità; i posti vuoti dell'equipaggiamento mostrano
  la sagoma di ciò che ci va.
- **Gli avvisi** stanno dove non coprono nulla: al centro sul mondo, in fondo a Esamina con la Bisaccia aperta, sulla
  fascia del piede con un pannello a schermo intero aperto (allora la barra rapida si nasconde).

### I pannelli a schermo intero: lo scheletro `UiPage` (Roadmap 55)
Tutti uguali, così il giocatore sa sempre dove guardare:
- **Intestazione**: il medaglione della meccanica (`UiMedal`), il titolo in Alegreya, una riga che dice a cosa serve; a
  destra i **numeri chiave in etichette tonde** (`set_chips`), mai dentro il titolo; sotto, una riga sottile che sfuma.
- **Schede** (`set_tabs`) tutte della stessa forma; **corpo** `body`: di solito `split()` = a sinistra l'elenco a
  schedine (`UiList`: striscia del colore, icona, nome, riga sotto, etichetta a destra, barra; titoletti e scelte
  multiple), a destra il dettaglio (`UiDetail`).
- **Il dettaglio** si racconta sempre con gli stessi pezzi e in quest'ordine: intestazione (medaglione, nome, che cos'è,
  un numero grande a destra), etichette, barra di avanzamento, il **prossimo passo in evidenza** (`callout`), le sezioni
  con il loro **titoletto in maiuscoletto** (valori in colonna, elenchi con lo stato ✓ ➤ · ✕, **tappe** con `UiTimeline`,
  testo), le note. I testi dei moduli in BBCode si impaginano da soli con `UiDetail.bbcode` (titolo, sezioni «[b]…[/b]»,
  righe con ✓ e ·).
- **Il vuoto si spiega** (`UiKit.empty`): un'icona, che cosa manca e i modi per cominciare. Mai un riquadro nero.
- **Piede**: i comandi come **tasti disegnati** (`UiKit.hint`: il tasto e che cosa fa), «Esc chiudi» sempre a destra.

## 5. Il carattere (`UiFonts`)
Roadmap 55: **niente più caratteri a pixel**. Due famiglie sorelle di Huerta Tipográfica (licenza OFL, `arte/caratteri/`):
- **Alegreya** (calligrafica, con il tratto della penna) per i titoli (`titolo`, 700) e i nomi (`nome`, 600); a peso di
  libro (`libro`) e in corsivo (`racconto`) per le **pagine da leggere**: stele, storia, scrigni a parola, finale
  (`UiKit.book`).
- **Alegreya Sans** per tutto il testo: `testo` (Medium, il predefinito del tema), `chiaro` (Regular, le spiegazioni),
  `forte` (Bold), `corsivo`, `numeri` (Bold con le cifre della stessa larghezza, che non ballano).
- Le cifre sono sempre allineate («lnum»). I simboli che i caratteri non hanno (★ ✦ ⚔) li prende il carattere del motore.
- **Sopra il mondo** (HUD): un contorno sottile e un'ombra morbida (`UiFonts.on_world`; `UiTheme` ammorbidisce da sé i
  contorni spessi di chi entra nell'HUD). **Dentro il mondo** (numeri dei colpi, nomi degli abitanti e delle casse,
  creature antiche): `UiFonts.world`, Alegreya Sans a campo di distanza (MSDF), nitida anche ingrandita dalla telecamera.
- I pezzi pronti stanno in `UiKit`: `title`, `name_label`, `label`, `para`, `caps` (titoletto), `rich`, `chip`,
  `keycap`, `hint`/`hints`, `callout`, `section`, `stats`, `bar`, `icon_rect`, `empty`.

## 6. Il movimento (`UiFx`)
| Cosa | Durata | Come |
|---|---|---|
| Aprire un pannello | 0,14 s | dissolvenza e 6 px dal basso, curva «esce veloce» |
| Chiudere | 0,10 s | dissolvenza |
| Passaggio del mouse | 0,08 s | il fondo e il bordo si accendono |
| Clic | 0,10 s | il pulsante si abbassa di 1 px e torna |
| Avviso | 0,18 entrare, 0,30 uscire | scorre dall'alto |
| Numeri che cambiano | 0,25 s | contano verso il valore nuovo |
| Colpo che va a segno | 0,8 s | numero (carattere del mondo, `UiFonts.world`) che salta fuori e sale (`Fx.float_text`) |
| Ferita | 0,2 s | la visuale trema di 1-5 px interi (`Juice`, opzione «scosse») |
| Creatura che cade | 0,035 s | pausa d'impatto (`Juice`) |
| Casella scelta nella barra | 0,14 s | si solleva un attimo |

Mai un'animazione che blocca un comando; tutto si può saltare cliccando di nuovo. L'HUD fa comparire ogni pannello
(`UiFx.appear`) da solo; opzione «animazioni». Nelle prove le animazioni sono spente (`UiFx.enabled`, `Juice.enabled`),
la galleria le riaccende e aspetta che finiscano.

## 7. Il mondo
- **Il vento** (`WindFx`): l'erba, i fiori e le piante dei biomi stanno in uno strato a parte con uno shader che ne
  piega la cima di pixel interi; le chiome degli alberi e i loro baccelli si piegano nel terzo alto. Il vento di
  `Weather` spinge tutto dalla sua parte; sotto terra solo una brezza. Una decorazione nuova «morbida» (che deve
  muoversi) va in `TileDefs.is_soft_decor`.
- **I liquidi** (shader di `LiquidView`): bande di luce lente dentro, luccichii che corrono sulla superficie (la riga
  di superficie ha l'alfa pieno), la brace tremola.
- **Le particelle**: `Fx` (scavo, sbuffi, numeri) e `AmbientFx` (l'aria di ogni strato: polline, lucciole di notte,
  spore, scintille di Linfa, braci; la polvere dei passi e degli atterraggi; la vignettatura). Poche e brevi; opzione
  «particelle».
- **Gli oggetti a terra** ondeggiano a pixel interi; quelli che contano hanno un alone del loro colore.
- **La luce** resta quella di `LightMap`: il buio è buio, la leggibilità viene dalle cose che brillano.
- **Gli oggetti posati** affondano 2 px nel terreno con un'ombra di contatto (`StationGround`).

## 8. Le creature
- `CreatureFx.shade`, per ogni disegno (del codice o di Nano Banana) e anche per le icone degli oggetti: il contorno
  nero diventa il colore del corpo molto scurito con un velo prugna, e il corpo prende la luce da sinistra in alto.
  Foglio prima/dopo: `tools/volume_creature.gd`.
- `CreatureFx`: ombra di contatto sotto chi sta a terra, respiro da ferme (la metà alta scende di un pixel), la
  dissolvenza alla morte (`Creature.fade_out`), la presenza dei boss (alone che pulsa, scintille, rosse nell'ira).

## 9. Come si controlla
- `--solo=galleria`: ogni pannello fotografato in prove/galleria/ e il controllo dell'impaginazione (0 problemi).
- Le foto delle prove sono fedeli ai colori dello schermo (`Photo.take`, voce 267).
- Prima e dopo: le foto della galleria si confrontano a ogni voce.
