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
	# ---------------------------------------------------------------- le sorgenti del mondo (voce 195)
	"mulino_semi": {"name": "Mulino di semi", "role": "sorgente", "size": [2, 3], "bh": "mulino", "pulsi": 35,
		"look": "mulino", "icon": ["pappo", "legno"], "in": {"legno": 20, "lingotto_radicite": 4, "seta_radice": 4}, "station": "ceppo",
		"tier": 2, "desc": "Una sorgente: le pale di pappo girano con il vento. Più vento e più in alto, più pulsi (fino a 35; nel cielo di più). Sotto terra non c'è vento."},
	"ruota_acqua": {"name": "Ruota d'acqua", "role": "sorgente", "size": [2, 2], "bh": "ruota", "pulsi": 40,
		"look": "ruota", "icon": ["mola", "legnoferro"], "in": {"legno": 16, "lingotto_legnoferro": 3}, "station": "baccello_ardente",
		"tier": 2, "desc": "Una sorgente: l'acqua che la bagna la fa girare, 5 pulsi per ogni cella d'acqua che la tocca (ai lati o sopra), fino a 40; l'acqua che scorre il 50% in più."},
	"baccello_brace": {"name": "Baccello di brace", "role": "sorgente", "size": [2, 2], "bh": "fuoco", "pulsi": 40, "slots": 4,
		"fuel": {"legno": 20.0, "polvere_brace": 90.0, "pietra_brace": 60.0, "fungo_brace": 45.0, "tizzone_quieto": 240.0},
		"hot": 2, "look": "brace", "icon": ["fornace", "brace"], "in": {"ardesia": 20, "lingotto_legnoferro": 4, "polvere_brace": 4},
		"station": "baccello_ardente", "tier": 2,
		"desc": "Una sorgente: brucia ciò che le metti nella cassetta (legno, polvere e pietra di brace…) e dà 40 pulsi, il doppio accanto a un lago di brace. Brucia solo quando la rete ne ha bisogno."},
	"pozzo_linfa": {"name": "Pozzo di Linfa", "role": "sorgente", "size": [2, 2], "bh": "pozzo", "pulsi": 80,
		"look": "pozzo", "icon": ["goccia", "cristallo"], "sul_liquido": true, "in": {"lingotto_ambra": 4, "cristallo_linfa": 3, "seta_radice": 4},
		"station": "maglio", "tier": 3,
		"desc": "Una sorgente: posato sopra un lago di Linfa beve la Linfa del mondo, 80 pulsi senza combustibile (meno se il lago è piccolo)."},
	"cuore_cristallo": {"name": "Cuore di cristallo", "role": "sorgente", "size": [2, 2], "bh": "fuoco", "pulsi": 120, "slots": 4,
		"fuel": {"cristallo_linfa": 120.0}, "look": "cuore_cristallo", "icon": ["cristallo", "linfa"],
		"in": {"cristallo_linfa": 8, "lingotto_ambra": 4, "gelatina": 6}, "station": "maglio", "tier": 3,
		"desc": "Una sorgente: consuma un cristallo di Linfa ogni 2 minuti di lavoro e dà 120 pulsi. Brucia solo quando la rete ne ha bisogno."},
	# ---------------------------------------------------------------- riserve
	"otre_linfa": {"name": "Otre di Linfa", "role": "riserva", "size": [1, 1], "bh": "riserva", "cap": 3000, "io": 30,
		"look": "otre", "icon": ["goccia", "linfa"], "in": {"legno": 4, "gelatina": 6, "lingotto_radicite": 1}, "station": "ceppo",
		"tier": 1, "desc": "Una riserva: tiene 3000 gocce di Linfa (un pulso per un secondo è una goccia), ne prende e ne dà al più 30 al secondo."},
	# ---------------------------------------------------------------- macchine
	"lampada_baccello": {"name": "Lampada a baccello", "role": "macchina", "size": [1, 1], "bh": "lampada", "pulsi": 1,
		"light": Color(0.7, 1.5, 1.4), "look": "lampada", "icon": ["lanterna", "linfa"], "in": {"legno": 2, "gelatina": 1},
		"station": "ceppo", "qty": 2, "tier": 1,
		"desc": "Una luce che si accende e si spegne con l'Impulso (o sempre accesa, se nessun filo la tocca). Chiede 1 pulso."},
	# ---------------------------------------------------------------- l'Impulso: comandi e porta (voce 193)
	"leva_radice": {"name": "Leva di radice", "role": "comando", "size": [1, 1], "bh": "leva", "look": "leva",
		"icon": ["chiave", "legno"], "in": {"legno": 3, "lingotto_radicite": 1}, "station": "ceppo", "tier": 1,
		"desc": "Un comando: clic destro la alza o la abbassa. Alzata accende i fili dell'Impulso che la toccano."},
	"pulsante_radice": {"name": "Pulsante di radice", "role": "comando", "size": [1, 1], "bh": "pulsante", "look": "pulsante",
		"icon": ["gemma", "linfa"], "in": {"legno": 2, "gelatina": 1}, "station": "ceppo", "tier": 1,
		"desc": "Un comando: clic destro manda un colpo sui fili che lo toccano (una porta si apre o si chiude, una lampada si alterna)."},
	"piastra_radice": {"name": "Piastra di radice", "role": "comando", "size": [1, 1], "bh": "piastra", "look": "piastra",
		"frame": true, "icon": ["mattoni", "legno"], "in": {"legno": 3, "ardesia": 2}, "station": "ceppo", "tier": 1,
		"desc": "Un comando: accesa finché qualcuno ci sta sopra (nel pannello: tu, le creature, o tutti)."},
	"porta_viva": {"name": "Porta di radice viva", "role": "macchina", "size": [1, 2], "bh": "porta", "pulsi": 0, "colpo": 20,
		"porta": true, "frame": true, "look": "porta", "icon": ["porta", "linfa"],
		"in": {"legno": 10, "lingotto_radicite": 2, "gelatina": 2}, "station": "ceppo", "tier": 1,
		"desc": "Una porta che le creature non aprono. Senza fili si apre da sola quando arrivi; con un filo la comanda l'Impulso. Ogni volta che si muove costa 20 gocce della sua rete."},
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
			if d.has("slots"):
				e["slots"] = int(d["slots"])             # la cassetta del combustibile (la apre il pannello)
			if d.get("sul_liquido", false):
				e["sul_liquido"] = true                  # si posa sopra un lago (il Pozzo di Linfa)
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
