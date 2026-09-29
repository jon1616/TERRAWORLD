class_name CraftCatsData
extends RefCounted
## Le categorie del pannello «Creare» (26 set 2026, richiesta dell'utente: ricette colorate per tipo): nome, colore e
## tipi di oggetto (`kind` in `ItemsData`) di ognuna. Il colore tinge la riga della ricetta (striscia, riquadro
## dell'icona, bordo), il bottone della categoria e l'intestazione del gruppo. «Altro» prende ciò che non sta altrove.

const CATS := [
	["armi", "Armi", Color("#ff6f5e"), ["spada", "arco", "bastone", "munizione", "esplosivo", "ricurvo", "giavellotto",
		"evocatore"]],
	["attrezzi", "Attrezzi", Color("#ffb84a"), ["piccone", "ascia", "martello", "annaffiatoio", "rampino", "lanterna",
		"specchio", "mappa"]],
	["armature", "Armature", Color("#6ab4ff"), ["elmo", "corazza", "gambali", "guanti", "stivali", "mantello"]],
	["accessori", "Accessori", Color("#c890ff"), ["accessorio", "compagno", "amuleto", "anello"]],
	["pozioni", "Pozioni e cibo", Color("#ff86c8"), ["consumabile", "cura", "purifica", "dono"]],
	["materiali", "Materiali", Color("#d8b070"), ["materiale", "essenza"]],
	["costruzione", "Costruzione", Color("#7ed67a"), ["blocco", "piattaforma", "parete", "torcia", "stazione"]],
	["giardino", "Giardino e mandria", Color("#5ee0c8"), ["seme", "coltura", "seme_mondo", "fiala", "provetta", "uovo",
		"vasetto", "laccio", "creatura"]],
	["rete", "Linfa e macchine", Color("#8ef0e8"), ["pinza", "vena", "filo", "isolante"]],   # Roadmap 19
	["altro", "Altro", Color("#a0b4b0"), []],
]
const WORK := Color("#ffd24a")         # le lavorazioni del Maglio e del Telaio (tratti, innesti, fasce)

static var _of := {}


## L'indice in `CATS` della categoria di un oggetto.
static func of(id: String) -> int:
	if _of.has(id):
		return _of[id]
	var it := ItemsData.get_item(id)
	var kind := String(it.get("kind", ""))
	var k := CATS.size() - 1
	for i in CATS.size():
		# Roadmap 19: le macchine sono stazioni, ma stanno con la rete («cat»: "rete")
		if kind in CATS[i][3] or String(it.get("cat", "")) == String(CATS[i][0]):
			k = i
			break
	_of[id] = k
	return k


static func color_of(id: String) -> Color:
	return CATS[of(id)][2]


## Il nome breve di una stazione per la riga della ricetta: «Maglio dei Seminatori» → «Maglio».
static func short_station(sid: String) -> String:
	if sid == "":
		return "a mano"
	var n := String(StationsData.STATIONS[sid]["name"])
	for cut in [" dei ", " del ", " della ", " dell'", " di "]:
		var i := n.find(cut)
		if i > 0:
			return n.substr(0, i)
	return n
