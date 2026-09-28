class_name HomesData
extends RefCounted
## Le case degli abitanti (voce 143, Roadmap 15): ognuno vuole la sua stanza (un letto dentro una stanza, voce 142) e ha
## i suoi **gusti**: i materiali e gli arredi che ama, gli abitanti che vuole vicini e quelli che no. La **felicità**
## (0-100) cambia i prezzi, porta regali e, con una casa bella libera, fa arrivare gli abitanti da più lontano. La
## logica sta in `Homes`.

const TASTES := {
	"viandante": {"mats": ["lanterna", "radice"], "arredi": ["tappeto", "lanterna"], "friends": ["cartografo", "mercante_semi"], "rivals": []},
	"erborista": {"mats": ["radice", "linfa"], "arredi": ["vaso", "scaffale"], "friends": ["mandriano"], "rivals": ["forgiatore"]},
	"forgiatore": {"mats": ["legnoferro", "ardesia"], "arredi": ["camino", "armadio"], "friends": ["pescatore"], "rivals": ["erborista"]},
	"mercante_semi": {"mats": ["ambra", "lanterna"], "arredi": ["armadio", "quadro"], "friends": ["viandante", "innestatrice"], "rivals": []},
	"mandriano": {"mats": ["lanterna", "radice"], "arredi": ["camino", "tappeto"], "friends": ["erborista", "pescatore"], "rivals": []},
	"pescatore": {"mats": ["ardesia", "lanterna"], "arredi": ["finestra", "quadro"], "friends": ["mandriano", "forgiatore"], "rivals": ["cartografo"]},
	"innestatrice": {"mats": ["linfa", "ambra"], "arredi": ["vaso", "lampada"], "friends": ["mercante_semi"], "rivals": []},
	"cartografo": {"mats": ["seminatori", "stellare"], "arredi": ["scaffale", "tavolo"], "friends": ["viandante"], "rivals": ["pescatore"]},
}

const NEAR := 24                         # tessere: così vicini sono «vicini di casa»
const BASE_NO_ROOM := 20                 # un letto fuori da una stanza
const BASE_ROOM := 40
const PER_COMFORT := 0.3
const PER_ARREDO := 8                    # per ogni arredo che ama (al più due)
const PER_MAT := 8                       # arredi del materiale che ama
const PER_FRIEND := 6
const PER_RIVAL := 8
const SHARED := 12                       # una stanza con due letti di due abitanti: ognuno la vuole sua
const HAPPY := 70
const SAD := 40
const PRICE := {"felice": 0.9, "contento": 1.0, "scontento": 1.15}
const GIFT_EVERY := 1200.0               # secondi di gioco tra due regali (un giorno)
const NICE_HOUSE := 40                   # comfort di una casa che attira abitanti da lontano


static func mood(h: int) -> String:
	return "felice" if h >= HAPPY else ("contento" if h >= SAD else "scontento")
