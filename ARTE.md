# TERRAWORLD — La guida di stile («Radici e Linfa»)

Voce 269 della Roadmap 29 «Il volto vivo» (30 set 2026). Vale per **tutto ciò che si disegna**: interfaccia, mondo,
creature, icone, effetti. Chi aggiunge una schermata o un effetto legge qui prima di scegliere colori, misure e
movimenti. I valori stanno nel codice in un posto solo (`UiPalette`, `UiTheme`, `UiFx`): questa pagina spiega il perché.

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

## 4. Le cornici (`UiTheme`)
Tre pesi, disegnati dal codice come cornici a 9 pezzi (si allungano senza deformare gli angoli):
- **Riquadro**: bordo `bordo` di 2 px, angoli di radice intrecciata, un filo di Linfa lungo il bordo alto, ombra morbida.
- **Riquadro forte** (i pannelli principali): bordo più spesso, angoli con una foglia, testata più chiara.
- **Casella**: più semplice, angoli arrotondati; la selezione è un bordo `ambra` con un alone.
Pulsanti: fondo `pannello_alto`, bordo sottile, si accendono al passaggio; il pulsante principale ha il bordo ambra.

## 5. Il carattere
- **Testo lungo** (schede, Enciclopedia, spiegazioni): il carattere morbido di Godot, leggibile a ogni misura.
- **Titoli e numeri**: un carattere di pixel disegnato dal codice (`PixelFont`), nitido a 2× e 3×, con le lettere
  accentate. Si usa solo dove serve carattere (titoli dei pannelli, numeri della barra rapida, danno), mai per il
  testo lungo.
- Contorno scuro solo sul testo che sta sopra il mondo (HUD); dentro i pannelli niente contorno.

## 6. Il movimento (`UiFx`)
| Cosa | Durata | Come |
|---|---|---|
| Aprire un pannello | 0,14 s | dissolvenza e 6 px dal basso, curva «esce veloce» |
| Chiudere | 0,10 s | dissolvenza |
| Passaggio del mouse | 0,08 s | il fondo e il bordo si accendono |
| Clic | 0,10 s | il pulsante si abbassa di 1 px e torna |
| Avviso | 0,18 entrare, 0,30 uscire | scorre dall'alto |
| Numeri che cambiano | 0,25 s | contano verso il valore nuovo |
Mai un'animazione che blocca un comando; tutto si può saltare cliccando di nuovo.

## 7. Il mondo
- **Il vento** muove erba, cespugli, fronde e baccelli (shader), più forte con il vento di `Weather`.
- **Le particelle** (`FxLib`): poche e brevi; ogni azione ha le sue (scavo per materiale, colpo, raccolta, passo).
- **La luce** resta quella di `LightMap`: il buio è buio, la leggibilità viene dalle cose che brillano.
- **Gli oggetti posati** affondano 2 px nel terreno con un'ombra di contatto (`StationGround`).

## 8. Le creature
- Contorno scuro colorato (non nero puro), luce da sinistra in alto, occhi che brillano al buio.
- Movimento con gli shader: respiro, passo, lampo del colpo, dissolvenza alla morte.

## 9. Come si controlla
- `--solo=galleria`: ogni pannello fotografato in prove/galleria/ e il controllo dell'impaginazione (0 problemi).
- Le foto delle prove sono fedeli ai colori dello schermo (`Photo.take`, voce 267).
- Prima e dopo: le foto della galleria si confrontano a ogni voce.
