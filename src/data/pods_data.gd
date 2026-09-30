class_name PodsData
extends RefCounted
## I baccelli dormienti (Roadmap 30, voce 301): piccole cose da rompere sparse nelle grotte e in superficie, a decine
## per strato, con un bottino piccolo (l'utente: «poco da trovare»). Sono decorazioni (id da 92): le piazza
## `PassBaccelli`, le disegna `PodArt`, le apre `Harvest` quando vengono tolte. Solo costanti (nessun'altra classe).
##   KINDS    decorazione -> nome, strati dove nasce (0 = superficie, 4 = il Fondo), peso, luce, bottino in più
##   COMMON   il bottino di tutti, per strato: [oggetto, peso, quanti al meno, quanti al più]
##   RARE     una volta su `RARE_CHANCE`, in più: le cose preziose, dallo strato indicato in giù

const KINDS := {
	92: {"name": "Baccello dormiente", "strata": [0, 1, 2], "w": 3, "light": Color(0.1, 0.3, 0.25),
		"extra": [["seme_lanterna", 3, 1, 2], ["bacche_lanterna", 3, 1, 3], ["torcia", 3, 2, 4]]},
	93: {"name": "Nido di radice", "strata": [1, 2], "w": 3,
		"extra": [["seta_radice", 4, 1, 3], ["fibra_radice", 3, 2, 4], ["gelatina", 3, 1, 3]]},
	94: {"name": "Urna dei Seminatori", "strata": [2, 3, 4], "w": 2, "light": Color(0.3, 0.2, 0.05),
		"extra": [["lumino", 6, 5, 15], ["pozione_bagliore", 2, 1, 1], ["pietra_seminatori", 2, 2, 5]]},
	95: {"name": "Geode dormiente", "strata": [2, 3, 4], "w": 2, "light": Color(0.25, 0.1, 0.35),
		"extra": [["brillaluce", 2, 1, 2], ["sanguinella", 2, 1, 2], ["lagunite", 2, 1, 2], ["nottilite", 2, 1, 2],
			["cristallo_linfa", 2, 1, 2]]},
	96: {"name": "Bozzolo di Linfa", "strata": [3, 4], "w": 3, "light": Color(0.1, 0.4, 0.45),
		"extra": [["goccia_linfa_viva", 4, 1, 3], ["cristallo_linfa", 2, 1, 2], ["rugiada_linfa", 2, 1, 1]]},
	97: {"name": "Ceppo cavo", "strata": [0], "w": 1, "surface": true,
		"extra": [["bacche_lanterna", 3, 2, 4], ["legno", 4, 3, 8], ["seme_lanterna", 3, 1, 3], ["lumino", 2, 2, 6]]},
}
const FIRST := 92
const LAST := 97

## Il bottino di tutti, per strato (indice = strato).
const COMMON := [
	[["lumino", 30, 1, 4], ["torcia", 12, 2, 4], ["dardo", 10, 4, 8], ["gelatina", 8, 1, 2], ["pozione_rugiada", 6, 1, 1],
		["minerale_radicite", 10, 2, 4], ["humus", 4, 2, 5]],
	[["lumino", 30, 2, 6], ["torcia", 12, 2, 5], ["dardo", 10, 5, 10], ["gelatina", 8, 1, 3], ["pozione_rugiada", 6, 1, 1],
		["minerale_radicite", 10, 3, 6], ["seta_radice", 6, 1, 2]],
	[["lumino", 30, 3, 9], ["torcia", 10, 3, 6], ["dardo", 10, 6, 12], ["pozione_rugiada", 8, 1, 2],
		["minerale_legnoferro", 12, 2, 5], ["pozione_bagliore", 4, 1, 1], ["scisto", 4, 2, 5]],
	[["lumino", 30, 5, 14], ["torcia", 8, 3, 6], ["dardo", 8, 8, 14], ["pozione_rugiada", 8, 1, 2],
		["minerale_ambra", 12, 2, 4], ["cristallo_linfa", 6, 1, 2], ["pozione_bagliore", 5, 1, 1]],
	[["lumino", 30, 8, 20], ["dardo", 8, 10, 18], ["pozione_rugiada", 8, 1, 3], ["minerale_ambra", 8, 3, 5],
		["minerale_tizzonite", 10, 2, 4], ["vuotite", 6, 3, 6], ["cristallo_linfa", 6, 1, 3]],
]
const RARE_CHANCE := 0.04
const RARE := [["polvere_iridata", 0, 1, 1], ["scheggia_vigore", 2, 1, 1], ["linfa_antica", 3, 1, 1]]

## Quanti ne nascono: la probabilità per ogni cella di pavimento libera, per strato; in superficie per colonna.
const DENSITY := [0.006, 0.02, 0.022, 0.026, 0.05]          # (il Fondo ha pochi pavimenti: di più)
const SURFACE_DENSITY := 0.006


## I tipi che nascono in uno strato ([id, peso]); `surface` = sul pavimento della superficie all'aperto.
static func kinds_for(stratum: int, surface: bool) -> Array:
	var out := []
	for id in KINDS:
		var k: Dictionary = KINDS[id]
		if stratum in (k["strata"] as Array) and bool(k.get("surface", false)) == surface:
			out.append([int(id), int(k["w"])])
	return out


## Il bottino di un baccello aperto: [[oggetto, quanti], …] (uno o due tiri dalla tabella dello strato e del tipo, a
## volte una cosa rara).
static func roll(id: int, stratum: int, rng: RandomNumberGenerator) -> Array:
	var s := clampi(stratum, 0, COMMON.size() - 1)
	var table: Array = (COMMON[s] as Array) + (KINDS.get(id, {}).get("extra", []) as Array)
	var out := []
	for k in (2 if rng.randf() < 0.35 else 1):
		out.append(_pick(table, rng))
	if rng.randf() < RARE_CHANCE:
		var rare := RARE.filter(func(e: Array) -> bool: return s >= int(e[1]))
		if not rare.is_empty():
			var e: Array = rare[rng.randi_range(0, rare.size() - 1)]
			out.append([String(e[0]), rng.randi_range(int(e[2]), int(e[3]))])
	return out


static func _pick(table: Array, rng: RandomNumberGenerator) -> Array:
	var tot := 0
	for e in table:
		tot += int(e[1])
	var r := rng.randi_range(1, tot)
	for e in table:
		r -= int(e[1])
		if r <= 0:
			return [String(e[0]), rng.randi_range(int(e[2]), int(e[3]))]
	return [String(table[0][0]), 1]
