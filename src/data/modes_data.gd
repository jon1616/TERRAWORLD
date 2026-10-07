class_name ModesData
## Le modalità (Roadmap 49, voce 405; piano in `VASTITA.md`): si scelgono creando il Giardino e valgono per tutti i
## mondi che nascono da lui (`world_meta["modalita"]`, passato dai portali). Solo dati: le applica `Modes`.
##   hp, dmg     Vita e danno delle creature selvatiche (× quelli della zona)
##   phase       la seconda fase dei boss arriva prima (× la soglia di `p.phase2`, al più `PHASE_MAX`)
##   bag         oggetti in più in ogni Sacchetto e dai capi: uno dalla tabella «modo_dura» (e dal Vuoto «modo_vuoto»)
##   fury        la Furia del Giardiniere (solo il Vuoto)
##   cimeli      i boss lasciano il loro cimelio (solo il Vuoto)
## Le modalità dure **danno oggetti propri** (pacchetto `src/data/vastita/modalita.gd`): 42 della Radice dura, 10 del Vuoto
## e 57 cimeli, uno per boss.

const MODES := [
	{"id": "normale", "name": "Normale", "hp": 1.0, "dmg": 1.0, "phase": 1.0, "bag": 0,
		"desc": "La partita com'è pensata: chi esplora e si equipaggia bene appassisce di rado."},
	{"id": "radice_dura", "name": "Radice dura", "hp": 1.35, "dmg": 1.25, "phase": 1.35, "bag": 1,
		"desc": "Creature più robuste e più cattive, boss che si infuriano prima; ogni Sacchetto e ogni capo lascia un oggetto in più, e ci sono armi e accessori che si trovano solo qui."},
	{"id": "vuoto", "name": "Vuoto", "hp": 1.7, "dmg": 1.5, "phase": 1.6, "bag": 2, "fury": true, "cimeli": true,
		"desc": "Come la Radice dura, ma di più: in cambio la Furia del Giardiniere (le ferite la caricano, piena si scatena) e il cimelio di ogni boss, un piccolo bonus per sempre."},
]
const PHASE_MAX := 0.85
## La Furia del Giardiniere: quanto la carica ogni ferita (in parti della Vita massima × questo), quanto dura scatenata.
const FURY_GAIN := 160.0
const FURY_TIME := 10.0
const FURY_BOON := "furia_giardiniere"
const BAG_CHANCE := 0.5                  # dai capi (i Sacchetti sempre)


static func of(i: int) -> Dictionary:
	return MODES[clampi(i, 0, MODES.size() - 1)]


static func name_of(i: int) -> String:
	return String(of(i)["name"])
