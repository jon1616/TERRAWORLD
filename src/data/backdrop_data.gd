class_name BackdropData
extends RefCounted
## Roadmap 34, voce 329: gli sfondi di ogni bioma di superficie. Solo dati; i disegni li fa `BackdropArt`, li monta e li
## sfuma `Background`.
##   sky     i quattro colori del cielo, dall'alto all'orizzonte
##   layers  tre piani dietro il terreno, dal più lontano al più vicino: [disegno, parallasse, spostamento in basso,
##           larghezza dell'immagine, colore, colore d'accento (baccelli, cappelli, crateri…)]. Il più lontano ha un colore
##           vicino a quello del cielo (la distanza), il più vicino è il più scuro. Le radici del cosmo, più lontane di
##           tutto, sono di tutti i biomi.
## Disegni: "creste" (colline o monti), "mesa" (altipiani piatti), "picchi" (punte di cristallo o di ghiaccio), "dune",
## "archi" (archi di vetro), "coni" (coni fumanti), e le file di alberi della forma del bioma: "lanterne", "pini",
## "secchi", "pagode", "ombrelli", "canne", "cactus", "funghi".

const SKY := ["#1d5670", "#4a9aa6", "#f0ae88", "#ffe2b4"]

const SETS := {
	"foresta": {"sky": SKY, "layers": [
		["creste", 0.14, -20.0, 512, "#4f8a98", ""],
		["lanterne", 0.28, 30.0, 640, "#2e6474", "#ffd49a"],
		["lanterne", 0.5, 70.0, 640, "#1a4252", "#ffc070"]]},
	"sussurri": {"sky": ["#1a3a5a", "#3a7088", "#c89aa0", "#f0d8c8"], "layers": [
		["creste", 0.14, -20.0, 512, "#4a6a88", ""],
		["lanterne", 0.28, 30.0, 640, "#2a4a68", "#d8b0ff"],
		["secchi", 0.5, 70.0, 640, "#182a40", "#b090e0"]]},
	"funghi": {"sky": ["#3a3a68", "#7a6aa0", "#f0a0a0", "#ffd8c0"], "layers": [
		["creste", 0.14, -10.0, 512, "#8a78a8", ""],
		["funghi", 0.28, 30.0, 640, "#5a4a78", "#e86060"],
		["funghi", 0.5, 70.0, 768, "#2e2440", "#c84848"]]},
	"prati": {"sky": ["#2a6a8a", "#5ab0b8", "#f8c098", "#fff0c8"], "layers": [
		["creste", 0.14, 10.0, 512, "#6aaa98", ""],
		["ombrelli", 0.28, 30.0, 640, "#3e7a68", "#f8e088"],
		["ombrelli", 0.5, 70.0, 768, "#24503e", "#f0c060"]]},
	"iridato": {"sky": ["#3a5a90", "#7aa8d0", "#f0b8d8", "#fff0c0"], "layers": [
		["creste", 0.14, 10.0, 512, "#8aa8c8", ""],
		["ombrelli", 0.28, 30.0, 640, "#5a6a98", "#ff9ad8"],
		["ombrelli", 0.5, 70.0, 768, "#2e3a60", "#88e8ff"]]},
	"ambra": {"sky": ["#2a5a70", "#6aa0a8", "#f8c070", "#ffe8b0"], "layers": [
		["mesa", 0.14, -10.0, 640, "#c89a68", ""],
		["ombrelli", 0.28, 30.0, 640, "#8a6440", "#ffc048"],
		["ombrelli", 0.5, 70.0, 768, "#4a3420", "#ffb030"]]},
	"brace": {"sky": ["#3a2a40", "#8a4a50", "#f08a50", "#ffd090"], "layers": [
		["coni", 0.14, -30.0, 768, "#7a4a50", "#ff8a30"],
		["creste", 0.28, 30.0, 640, "#4a2a30", ""],
		["secchi", 0.5, 70.0, 640, "#22141a", "#ff6a20"]]},
	"cenere": {"sky": ["#3a3a48", "#6a6a78", "#c09a80", "#e8d0b0"], "layers": [
		["coni", 0.14, -30.0, 768, "#7a7480", "#ff9a50"],
		["creste", 0.28, 30.0, 640, "#4a4650", ""],
		["secchi", 0.5, 70.0, 640, "#22202a", "#ff8a40"]]},
	"rossa": {"sky": ["#2a4a60", "#6a8aa0", "#f09a70", "#ffd8a8"], "layers": [
		["creste", 0.14, -10.0, 512, "#a06a68", ""],
		["pagode", 0.28, 30.0, 640, "#6a3a30", "#ff8a48"],
		["pagode", 0.5, 70.0, 768, "#3a1c18", "#ff6a30"]]},
	"brina": {"sky": ["#2a4a78", "#6a9ac8", "#c8e0f0", "#f0f8ff"], "layers": [
		["picchi", 0.14, -40.0, 640, "#a8c8e0", "#f0f8ff"],
		["pini", 0.28, 30.0, 640, "#4a6a90", "#e8f4ff"],
		["pini", 0.5, 70.0, 768, "#1e3450", "#d8ecff"]]},
	"ghiacciaio": {"sky": ["#1e4a70", "#5aa0c8", "#bfe8f0", "#f0ffff"], "layers": [
		["picchi", 0.14, -50.0, 640, "#a0d0e0", "#f0ffff"],
		["picchi", 0.28, 10.0, 768, "#5a90b0", "#c8f0ff"],
		["pini", 0.5, 70.0, 768, "#1a3448", "#a0e8f0"]]},
	"pietra": {"sky": ["#2a3a50", "#5a7088", "#b8a8b0", "#e8dcd8"], "layers": [
		["creste", 0.14, -20.0, 512, "#7a8090", ""],
		["secchi", 0.28, 30.0, 640, "#4a4a5a", "#c0b0d8"],
		["secchi", 0.5, 70.0, 768, "#24242e", "#a090c0"]]},
	"palude": {"sky": ["#1a4a48", "#3a7a6a", "#a8b888", "#d8e0b0"], "layers": [
		["creste", 0.14, 20.0, 512, "#5a8878", ""],
		["canne", 0.28, 40.0, 640, "#2e5a4a", "#c8b070"],
		["canne", 0.5, 70.0, 768, "#163028", "#d8a858"]]},
	"torba": {"sky": ["#1a4a58", "#3a8088", "#9ac0a8", "#d0e8c8"], "layers": [
		["creste", 0.14, 20.0, 512, "#4a8888", ""],
		["canne", 0.28, 40.0, 640, "#265a58", "#5cf0d8"],
		["lanterne", 0.5, 70.0, 640, "#143034", "#5cf0d8"]]},
	"vetro": {"sky": ["#3a6a8a", "#8ac0c8", "#f4e0a0", "#fff4d0"], "layers": [
		["dune", 0.14, 10.0, 768, "#d8c890", "#fff8d8"],
		["archi", 0.28, 30.0, 768, "#a8b8a0", "#e8fff0"],
		["cactus", 0.5, 70.0, 768, "#4a5a48", "#c8f0d0"]]},
	"stellare": {"sky": ["#101a40", "#2a3a78", "#8a70b0", "#e0b8d8"], "layers": [
		["creste", 0.14, -20.0, 512, "#4a4a80", ""],
		["ombrelli", 0.28, 30.0, 640, "#2a2a58", "#fff0a0"],
		["lanterne", 0.5, 70.0, 640, "#161634", "#fff4c0"]]},
}

const FADE := 1.6                      # secondi per passare dallo sfondo di un bioma a quello di un altro


## Lo sfondo di un bioma (quello della foresta per i biomi che non ne hanno uno scritto).
static func of(biome_id: String) -> Dictionary:
	return SETS.get(biome_id, SETS["foresta"])
