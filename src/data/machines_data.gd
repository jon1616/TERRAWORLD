class_name MachinesData
extends RefCounted
## Roadmap 19 «La Linfa che scorre»: le macchine della rete (sorgenti, riserve, macchine, sensori, nodi). Solo dati;
## da ogni riga nascono la stazione (`StationsData.STATIONS`), l'oggetto e la ricetta; il disegno è `MachineArt`, le
## regole `Energy` e i comportamenti in `src/game/energy/machines/` (`MachineBehavior.make(bh)`).
##
## Campi:
##   name, size [w, h], desc
##   role    "sorgente" (dà pulsi), "riserva" (tiene gocce), "macchina" (chiede pulsi), "comando" (manda l'Impulso),
##           "nodo" (logica dell'Impulso)
##   bh      il comportamento; p = i suoi parametri
##   pulsi   sorgente: quanti ne dà al massimo; macchina: quanti ne chiede mentre lavora
##   colpo   gocce che costa un'azione (una porta che si apre)
##   cap, io riserva: gocce che tiene e pulsi al più in entrata e in uscita
##   light   la luce che fa quando lavora (colore)
##   look    la forma del disegno in `MachineArt`; icon = [forma, materiale] dell'icona
##   in, station, qty  la ricetta (al banco `station`)
##   tier    in che momento della partita arriva (per l'Enciclopedia e il bilancio): 1 inizio … 5 fine

const MACHINES := {
	# ---------------------------------------------------------------- sorgenti (voce 192)
	"tamburo_radice": {"name": "Tamburo di radice", "role": "sorgente", "size": [2, 1], "bh": "tamburo", "pulsi": 10,
		"look": "tamburo", "icon": ["banco", "legno"], "in": {"legno": 14, "lingotto_radicite": 2}, "station": "ceppo", "tier": 1,
		"desc": "Una sorgente: chi ci cammina sopra (tu, o una creatura della tua mandria) lo fa girare e dà 10 pulsi."},
	"foglia_lanterna": {"name": "Foglia-lanterna", "role": "sorgente", "size": [2, 2], "bh": "sole", "pulsi": 12,
		"look": "foglia", "icon": ["foglia", "linfa"], "in": {"legno": 8, "gelatina": 4, "fungo_luminoso": 2}, "station": "ceppo",
		"tier": 1, "desc": "Una sorgente: beve la luce del giorno, fino a 12 pulsi a mezzogiorno (di più nel cielo). Di notte e sotto un tetto niente."},
	# ---------------------------------------------------------------- riserve
	"otre_linfa": {"name": "Otre di Linfa", "role": "riserva", "size": [1, 1], "bh": "riserva", "cap": 3000, "io": 30,
		"look": "otre", "icon": ["goccia", "linfa"], "in": {"legno": 4, "gelatina": 6, "lingotto_radicite": 1}, "station": "ceppo",
		"tier": 1, "desc": "Una riserva: tiene 3000 gocce di Linfa (un pulso per un secondo è una goccia), ne prende e ne dà al più 30 al secondo."},
	# ---------------------------------------------------------------- macchine
	"lampada_baccello": {"name": "Lampada a baccello", "role": "macchina", "size": [1, 1], "bh": "lampada", "pulsi": 1,
		"light": Color(0.7, 1.5, 1.4), "look": "lampada", "icon": ["lanterna", "linfa"], "in": {"legno": 2, "gelatina": 1},
		"station": "ceppo", "qty": 2, "tier": 1,
		"desc": "Una luce che si accende e si spegne con l'Impulso (o sempre accesa, se nessun filo la tocca). Chiede 1 pulso."},
}


## I dati di una macchina ({} se l'id non è una macchina).
static func get_machine(id: String) -> Dictionary:
	return MACHINES.get(id, {})


static func is_machine(id: String) -> bool:
	return MACHINES.has(id)


static var _stations := {}


## Le stazioni delle macchine (le unisce `StationsData.STATIONS`).
static func stations() -> Dictionary:
	if _stations.is_empty():
		for id in MACHINES:
			var d: Dictionary = MACHINES[id]
			var e := {"name": d["name"], "size": d["size"], "item": id, "macchina": true}
			if d.has("light"):
				e["light_rete"] = d["light"]           # la luce la accende la rete (`Energy`), non la stazione da sola
			_stations[id] = e
	return _stations


## Gli oggetti delle macchine (li unisce `ItemsData.all()`).
static func items() -> Dictionary:
	var out := {}
	for id in MACHINES:
		var d: Dictionary = MACHINES[id]
		out[id] = {"name": d["name"], "kind": "stazione", "cat": "rete", "place": id, "icon": d.get("icon", ["banco", "linfa"]),
			"stack": 99, "desc": d["desc"]}
	return out


## Le ricette delle macchine (le unisce `RecipesData.all()`).
static func recipes() -> Array:
	var out := []
	for id in MACHINES:
		var d: Dictionary = MACHINES[id]
		if d.has("in"):
			out.append({"out": id, "qty": int(d.get("qty", 1)), "in": d["in"], "station": d.get("station", "ceppo")})
	return out
