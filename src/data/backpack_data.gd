class_name BackpackData
extends RefCounted
## Lo zaino (Roadmap 30, 30 set 2026; l'utente: «aumentando gli oggetti raccoglibili lo zaino è troppo poco capiente»).
## Solo dati; le regole stanno in `Bisaccia` (caselle, tasche) e in `Backpack` (`src/game/`).
##   BAGS      le Bisacce a gradi (voce 295): usarne una porta la Bisaccia a `slots` caselle, per sempre; il contenuto
##             resta. Si fanno al Telaio con i materiali di strati sempre più profondi.

const BASE := 40                       # la Bisaccia di partenza (`Bisaccia.SIZE`)
const PAGE := 30                       # caselle per pagina nel pannello (sopra la barra rapida)

const BAGS := [
	{"id": "bisaccia_seta", "name": "Bisaccia di seta", "slots": 50, "mat": "seta",
		"in": {"seta_radice": 12, "legno": 20, "gelatina": 6}},
	{"id": "bisaccia_radicite", "name": "Bisaccia cucita di radicite", "slots": 60, "mat": "radicite",
		"in": {"seta_radice": 16, "lingotto_radicite": 8, "corda_liana": 4}},
	{"id": "bisaccia_legnoferro", "name": "Bisaccia di legnoferro", "slots": 72, "mat": "legnoferro",
		"in": {"seta_radice": 20, "lingotto_legnoferro": 10, "corda_liana": 6}},
	{"id": "bisaccia_ambra", "name": "Bisaccia d'ambra", "slots": 84, "mat": "ambra",
		"in": {"seta_radice": 24, "lingotto_ambra": 10, "cristallo_linfa": 4}},
	{"id": "bisaccia_linfa", "name": "Bisaccia della Linfa", "slots": 100, "mat": "linfa",
		"in": {"seta_radice": 30, "lingotto_linfa": 10, "polvere_iridata": 2, "linfa_antica": 1}},
]


static func bag_of(id: String) -> Dictionary:
	for b in BAGS:
		if String(b["id"]) == id:
			return b
	return {}


static func items() -> Dictionary:
	var out := {}
	for b in BAGS:
		out[b["id"]] = {"name": b["name"], "kind": "bisaccia", "icon": ["sacca", b["mat"]], "stack": 1, "slots": b["slots"],
			"desc": "Usala: la tua Bisaccia diventa di %d caselle, per sempre (ciò che contiene resta)." % int(b["slots"])}
	return out


static func recipes() -> Array:
	var out := []
	for b in BAGS:
		out.append({"out": b["id"], "qty": 1, "in": b["in"], "station": "telaio"})
	return out
