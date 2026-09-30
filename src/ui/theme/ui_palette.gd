class_name UiPalette
extends RefCounted
## I colori dell'interfaccia (voce 270, guida `ARTE.md` §2): un posto solo, così un ritocco cambia tutto il gioco.

const FONDO := Color("#07100f")
const PANNELLO := Color("#0c1817")
const PANNELLO_ALTO := Color("#12211f")
const PANNELLO_VIVO := Color("#1a2e2a")
const BORDO := Color("#2f7a70")
const BORDO_CHIARO := Color("#4fb8a4")
const RADICE := Color("#3a2630")          # i nodi di radice agli angoli delle cornici
const RADICE_CHIARA := Color("#6a4a52")
const FOGLIA := Color("#3aa08a")
const LINFA := Color("#8ef0d8")
const AMBRA := Color("#ffb84a")
const AMBRA_CHIARA := Color("#ffd08a")
const TESTO := Color("#e4f3ec")
const TESTO_SPENTO := Color("#9fc8c0")
const TESTO_MUTO := Color("#6a8a84")
const BUONO := Color("#9ff0b8")
const PERICOLO := Color("#ff6a5a")
const OMBRA := Color(0.0, 0.0, 0.0, 0.45)

## Le misure del testo (§3): cinque gradini.
const NOTA := 12
const TESTO_PX := 14
const GRANDE := 16
const SOTTOTITOLO := 20
const TITOLO := 28
