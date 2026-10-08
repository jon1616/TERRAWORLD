class_name WorldShapesData
extends RefCounted
## Le sagome dei mondi (voce 459, Roadmap 59 «Mondi che non si somigliano»): la grande scala di un mondo, quella che si
## riconosce a colpo d'occhio sulla mappa. La sceglie il genoma: un gene di forma con "shape" nel suo "gen" (i vecchi
## «guscio» e «arcipelago» hanno "roof" e "archi"); senza, il mondo è un continente. Le applica `PassSagoma` (canyon,
## terrazze, sprofondato, pilastri), `PassArcipelago` e `PassGuscio`; `PassMari` mette i mari ai bordi dove "sea" è vero
## (voce 461, scelta dell'utente: «mari ai bordi in quasi tutte», non nel guscio e nei pilastri).
## Ogni riga: name, desc (per la scheda del portale e l'Enciclopedia), sea, e i numeri della ricetta.
## Questo file non nomina altre classi (lo legge anche il generatore nei thread).

const SHAPES := {
	"continente": {"name": "Continente", "desc": "una terra sola tra due mari", "sea": true},
	"arcipelago": {"name": "Arcipelago", "desc": "pilastri di terra tra voragini allagate", "sea": true},
	"guscio": {"name": "Guscio", "desc": "la superficie chiusa sotto un tetto di roccia", "sea": false},
	"canyon": {"name": "Canyon", "desc": "una gola immensa taglia il mondo, a gradoni coperti di liane", "sea": true,
		"w": [230, 330], "depth": [95, 110], "gap": [680, 1080], "ledge": 9},
	"terrazze": {"name": "Terrazze", "desc": "la terra sale e scende a gradoni, con lunghi ripiani", "sea": true,
		"step": [16, 26], "hills": 2.4},
	"sprofondato": {"name": "Sprofondato", "desc": "la terra è sprofondata in una conca immensa: il cielo altissimo",
		"sea": true, "depth": [45, 65], "rim": [300, 420], "ridge": [110, 160]},
	"pilastri": {"name": "Pilastri", "desc": "colonne di roccia salgono dalla terra fino al cielo", "sea": false,
		"n": [6, 9], "w": [14, 22], "gap": 260, "rise": [40, 90]},
}
## Voce 461: entro tante colonne da un bordo un'acqua grande di superficie è mare (`Fishing.is_sea`).
const SEA_EDGE := 260
const ORDER := ["continente", "arcipelago", "guscio", "canyon", "terrazze", "sprofondato", "pilastri"]


## La sagoma di un mondo dagli effetti dei geni (`GenContext.genes()` o `Genome.effects`).
static func of(g: Dictionary) -> String:
	var s := str(g.get("shape", ""))
	if SHAPES.has(s):
		return s
	if bool(g.get("roof", false)):
		return "guscio"
	if bool(g.get("archi", false)):
		return "arcipelago"
	return "continente"


static func has_sea(g: Dictionary) -> bool:
	return bool(SHAPES[of(g)]["sea"]) and not bool(g.get("sea", false))
