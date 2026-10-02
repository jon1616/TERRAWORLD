class_name SurfaceLifeData
extends RefCounted
## Roadmap 35, voce 339: la vita minuta della superficie (la disegna `SurfaceLife`). Solo dati.
##   FIREFLIES  i biomi dove al tramonto e di notte si accendono le lucciole, e il loro colore
##   POLLEN     i biomi dove di giorno il polline galleggia nell'aria, e il suo colore
##   LEAVES     ogni quanto (secondi, in media) un albero lascia cadere una foglia; i colori vengono dall'erba del bioma
##   NO_LEAVES  i biomi i cui alberi non perdono foglie (il tizzone lascia cadere cenere: `ASH_TREES`)

const FIREFLIES := {
	"foresta": "#d8ff8a", "sussurri": "#c8b0ff", "funghi": "#ff9ad8", "prati": "#f0ff9a", "iridato": "#9af0ff",
	"palude": "#b8ff70", "torba": "#5cf0d8", "stellare": "#fff4c0", "rossa": "#ffc070",
}
const POLLEN := {"prati": "#fff4b0", "iridato": "#ffd8f0", "foresta": "#e8ffd0", "ambra": "#ffe0a0", "funghi": "#ffd0e8"}
const LEAVES := 3.5
const NO_LEAVES := ["ghiacciaio", "vetro"]
const ASH_TREES := ["brace", "cenere"]
const MAX_FIREFLIES := 22
const MAX_POLLEN := 30
const MAX_LEAVES := 40
## L'erba che si piega: chi la spinge (il Germogliato e le creature più vicine), entro quanti pixel, quanto.
const PUSHERS := 8
const PUSH_R := 14.0
