# TERRAWORLD — La guida di stile («Radici e Linfa»)

Voce 269 della Roadmap 29 «Il volto vivo» (30 set 2026). Vale per **tutto ciò che si disegna**: interfaccia, mondo,
creature, icone, effetti. Chi aggiunge una schermata o un effetto legge qui prima di scegliere colori, misure e
movimenti. I valori stanno nel codice in un posto solo (`UiPalette`, `UiFrames`, `UiTheme`, `UiScreen`, `UiFx`, `PixelFont`, e per il
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
| Nome | Colore | Dove |
|---|---|---|
| `fondo` | #07100f | lo sfondo che copre il mondo quando si apre un pannello (all'85%) |
| `pannello` | #0c1817 | il corpo dei riquadri |
| `pannello_alto` | #12211f | le testate, le caselle, i campi |
| `pannello_vivo` | #1a2e2a | al passaggio del mouse |
| `bordo` | #2f7a70 | il bordo normale (radice bagnata di Linfa) |
| `bordo_chiaro` | #4fb8a4 | bordo al passaggio, divisori |
| `linfa` | #8ef0d8 | titoli secondari, collegamenti, ciò che è attivo |
| `ambra` | #ffb84a | titoli, selezione, ciò che si sta scegliendo |
| `ambra_chiara` | #ffd08a | numeri importanti, prezzi |
| `testo` | #e4f3ec | il testo |
| `testo_spento` | #9fc8c0 | le spiegazioni |
| `testo_muto` | #6a8a84 | le note, i suggerimenti dei tasti |
| `buono` | #9ff0b8 | ciò che si può fare, i guadagni |
| `pericolo` | #ff6a5a | ciò che manca, le perdite, cancellare |

**Tipi d'oggetto**: il colore di `TipWordsData.KIND_COLORS` (armi, attrezzi, armature…) tinge lievemente il fondo
della casella (10-14%), così la Bisaccia si legge a colpo d'occhio. **Rarità dei geni**: `GenesData.RARITY`.
**Gradi dei materiali**: una tacca in basso nella casella, più accesa ai gradi alti.

## 3. Le misure
- **Griglia di 4 pixel**: margini interni 12 o 16, spazi tra elementi 8, tra gruppi 16.
- **Il testo** (5 gradini): 12 note · 14 testo · 16 testo grande ed etichette · 20 sottotitoli · 28 titoli. Mai sotto 12.
- **Caselle**: 56 px (Bisaccia, casse, barra rapida), icona 48 (16 × 3, pixel netti).
- **Pulsanti**: alti almeno 32 (40 i principali), larghi quanto il testo più 24.
- **Lo schermo** è 1600×900: i pannelli stanno a 12 px dai bordi; niente fuori.

## 4. Le cornici (`UiFrames`, `UiTheme`)
Disegnate dal codice come cornici a 9 pezzi a pixel doppi (si allungano senza deformare gli angoli; il centro si
ripete). `UiTheme.apply` le scrive nel tema predefinito del motore: ogni Panel, pulsante, campo, cursore e menu le ha
già. Un pannello che vuole una cornice diversa usa `UiFrames.box(tipo, stato, accento)` (l'alfa dell'accento è la
forza della tinta), `UiFrames.padded` (margini diversi) o `UiFrames.button(b, accento, scelto, tipo)`.
**Mai `StyleBoxFlat.new()` in un pannello nuovo.** Il foglio di tutte le cornici: `tools/cornici.gd` → prove/cornici.png.
- **Riquadro**: bordo `bordo` di 2 px, angoli di radice intrecciata, un filo di Linfa lungo il bordo alto, ombra morbida.
- **Riquadro forte** (i pannelli principali): bordo più spesso, angoli con una foglia, testata più chiara.
- **Casella**: più semplice, angoli arrotondati; la selezione è un bordo `ambra` con un alone.
Pulsanti: fondo `pannello_alto`, bordo sottile, si accendono al passaggio; il pulsante principale (`principale`:
Crea, Conferma, le ipotesi del Quaderno) è d'ambra scura con il bordo ambra.
- **I pannelli a schermo intero** usano lo scheletro `UiScreen`: sfondo `fondo` **opaco** (la fusione è lineare: al 97%
  il mondo si vedeva ancora), titolo in alto a sinistra, contenuto in riquadri tra y 90 e 830, riga dei tasti in fondo.
- **Le caselle** hanno il fondo tinto del tipo dell'oggetto (trofei, semi, fiale…) o della qualità (fine, capolavoro);
  materiali e blocchi restano neutri, così il colore segna ciò che conta (`SlotView.tint_of`). I posti vuoti
  dell'equipaggiamento mostrano la sagoma di ciò che ci va.
- **Gli avvisi** sono cartoline che stanno dove non coprono nulla: al centro sul mondo, in fondo a Esamina con la
  Bisaccia aperta, in alto a destra sui pannelli a schermo intero.

## 5. Il carattere
- **Testo lungo** (schede, Enciclopedia, spiegazioni): il carattere morbido di Godot, leggibile a ogni misura.
- **Titoli e numeri**: un carattere di pixel disegnato dal codice (`PixelFont`, lettere in `PixelGlyphs`), alto 11,
  usato solo a misure intere: `PixelFont.apply(etichetta, k, colore, ombra)` con k = 1 (numeri nel mondo, che la
  visuale ingrandisce 2×), 2 (numeri, nomi, sottotitoli), 3 (titoli), 4 (insegne degli strati). Mai per il testo lungo.
  Non ha carattere di riserva (le sue misure allargavano le righe): una lettera che manca si aggiunge a `PixelGlyphs`.
- Il carattere di pixel non ha contorno: ha un'ombra netta di k pixel. Il testo morbido sopra il mondo ha il contorno.

## 6. Il movimento (`UiFx`)
| Cosa | Durata | Come |
|---|---|---|
| Aprire un pannello | 0,14 s | dissolvenza e 6 px dal basso, curva «esce veloce» |
| Chiudere | 0,10 s | dissolvenza |
| Passaggio del mouse | 0,08 s | il fondo e il bordo si accendono |
| Clic | 0,10 s | il pulsante si abbassa di 1 px e torna |
| Avviso | 0,18 entrare, 0,30 uscire | scorre dall'alto |
| Numeri che cambiano | 0,25 s | contano verso il valore nuovo |
| Colpo che va a segno | 0,8 s | numero nel carattere di pixel che salta fuori e sale (`Fx.float_text`) |
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
