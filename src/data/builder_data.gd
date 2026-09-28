class_name BuilderData
extends RefCounted
## Gli strumenti del costruttore (voce 140, Roadmap 15): le **tinture** (colorano costrutti e pareti costruite; la
## sbiadente toglie il colore), la **Tavola del progetto** (copia un'area costruita e la rifà altrove portando i
## materiali) e le misure del posare in linea e ad area. La logica sta in `BuilderTools`.

const LINE_MAX := 24                     # celle al più in una linea trascinata
const AREA_MAX := 64                     # celle al più in un'area (tasto «area» tenuto)
const PLAN_W := 16                       # la Tavola del progetto copia al più 16 × 12 celle
const PLAN_H := 12
const PLAN_REACH := 14.0                 # tessere: quanto lontano si rifà un progetto

## Le tinture: indice (1-8, 0 = nessuna) → colore che moltiplica il disegno (sopra 1 schiarisce).
const DYES := [
	{"id": "tintura_rossa", "name": "Tintura rossa", "col": Color(1.35, 0.62, 0.55), "icon": "sanguinella", "in": {"fungo_brace": 1}, "qty": 8},
	{"id": "tintura_arancio", "name": "Tintura arancio", "col": Color(1.4, 0.95, 0.5), "icon": "brace", "in": {"polvere_brace": 1}, "qty": 8},
	{"id": "tintura_gialla", "name": "Tintura gialla", "col": Color(1.35, 1.25, 0.55), "icon": "ambra", "in": {"polvere_lucciola": 1}, "qty": 8},
	{"id": "tintura_verde", "name": "Tintura verde", "col": Color(0.7, 1.3, 0.6), "icon": "muschio", "in": {"fiore_germoglio": 1}, "qty": 8},
	{"id": "tintura_turchese", "name": "Tintura turchese", "col": Color(0.55, 1.25, 1.25), "icon": "linfa", "in": {"fungo_luminoso": 1}, "qty": 8},
	{"id": "tintura_blu", "name": "Tintura blu", "col": Color(0.6, 0.8, 1.45), "icon": "lagunite", "in": {"lagunite": 1}, "qty": 16},
	{"id": "tintura_viola", "name": "Tintura viola", "col": Color(1.1, 0.65, 1.4), "icon": "nottilite", "in": {"nottilite": 1}, "qty": 16},
	{"id": "tintura_bianca", "name": "Tintura bianca", "col": Color(1.55, 1.55, 1.5), "icon": "brillaluce", "in": {"brillaluce": 1}, "qty": 16},
]
const BLEACH := "tintura_sbiadente"


static func dye_index(id: String) -> int:
	for i in DYES.size():
		if String(DYES[i]["id"]) == id:
			return i + 1
	return 0


static func color(t: int) -> Color:
	return DYES[t - 1]["col"] if t >= 1 and t <= DYES.size() else Color.WHITE


static func items() -> Dictionary:
	var out := {}
	for d in DYES:
		out[d["id"]] = {"name": d["name"], "kind": "tintura", "icon": ["goccia", d["icon"]], "stack": 999,
			"desc": "Con la tintura in mano, un clic su un blocco costruito lo colora (clic destro: la parete dietro). Una goccia per cella."}
	out[BLEACH] = {"name": "Tintura sbiadente", "kind": "tintura", "icon": ["goccia", "humus"], "stack": 999,
		"desc": "Toglie il colore a un blocco costruito (clic) o alla sua parete (clic destro)."}
	out["tavola_progetto"] = {"name": "Tavola del progetto", "kind": "progetto", "icon": ["mappa", "legno"], "stack": 1,
		"desc": "Vuota: trascina su un'area costruita per copiarla (fino a 16 × 12). Piena: un clic la rifà dove punti, se nella Bisaccia hai i blocchi e le pareti che servono. Clic destro: la svuota."}
	return out


static func recipes() -> Array:
	var out := []
	for d in DYES:
		out.append({"out": d["id"], "qty": int(d["qty"]), "in": d["in"], "station": ""})
	out.append({"out": BLEACH, "qty": 8, "in": {"humus": 2}, "station": ""})
	out.append({"out": "tavola_progetto", "qty": 1, "in": {"legno": 6, "seta_radice": 2}, "station": "scalpellino"})
	return out
