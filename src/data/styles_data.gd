class_name StylesData
## Gli stili del Giardiniere (Roadmap 40, voce 367; piano in `VASTITA.md`). Solo dati: li usano `Styles` (le risorse in
## partita), `Combat`, `FormsData` (lo stile di ogni forma) ed Esamina.
## Otto modi di combattere, ognuno con la sua **risorsa**: una cosa che cresce mentre lo si usa e cambia il gioco.
##   mischia     Slancio: ogni giro che colpisce ne dà uno; pieno, il colpo dopo vale doppio e scuote attorno
##   distanza    le munizioni: dardi, sassi e spore, ognuna con il suo modo (voce 372)
##   linfa       la Linfa, come sempre (verghe, tomi, sfere)
##   evocazione  gli alleati: lo scettro ne richiama uno forte come il suo metallo
##   lancio      Mira ferma: stando fermi (o senza tirare) per `MIRA_T` secondi il lancio dopo è perfetto
##   canto       Ispirazione: ogni nota che colpisce ne dà una; piena, parte il canto dello strumento (te e i compagni)
##   cura        Rugiada: ogni `RUGIADA_EVERY` colpi del virgulto un'onda cura te e i compagni
##   radice      le piante da combattimento: i semi-torre crescono sul campo e tirano spine da sole

const STYLES := {
	"mischia": {"name": "Mischia", "res": "Slancio", "color": "#ff9a6a",
		"desc": "colpi da vicino; lo Slancio carica un colpo doppio"},
	"distanza": {"name": "Distanza", "res": "Munizioni", "color": "#e0d070",
		"desc": "archi, balestre, fionde e cerbottane; la munizione decide il modo del colpo"},
	"linfa": {"name": "Linfa", "res": "Linfa", "color": "#5cf0d8",
		"desc": "verghe, tomi e sfere: incantesimi che spendono Linfa"},
	"evocazione": {"name": "Evocazione", "res": "Alleati", "color": "#c89aff",
		"desc": "scettri che richiamano alleati: combattono per te"},
	"lancio": {"name": "Lancio", "res": "Mira ferma", "color": "#8ad8ff",
		"desc": "dischi e girandole; stare fermi un attimo rende perfetto il lancio dopo"},
	"canto": {"name": "Canto", "res": "Ispirazione", "color": "#ffd08a",
		"desc": "buccine, flauti e tamburi: le note feriscono, e piena l'Ispirazione rinforza te e i compagni"},
	"cura": {"name": "Cura", "res": "Rugiada", "color": "#9fe070",
		"desc": "virgulti: ferire cura, e la Rugiada cura anche i compagni"},
	"radice": {"name": "Radice", "res": "Piante", "color": "#7ac860",
		"desc": "semi da combattimento: torri che crescono sul campo e semi che scoppiano"},
}
const ORDER := ["mischia", "distanza", "linfa", "evocazione", "lancio", "canto", "cura", "radice"]

## Lo stile di ogni forma (le forme non scritte qui seguono il loro tipo, `KIND_STYLE`).
const FORM_STYLE := {
	"spada": "mischia", "pugnale": "mischia", "spadone": "mischia", "lancia": "mischia", "martello": "mischia",
	"falcione": "mischia", "frusta": "mischia", "falcelunga": "mischia", "manopole": "mischia", "egida": "mischia",
	"bipenne": "mischia", "randello": "mischia",
	"arco": "distanza", "balestra": "distanza", "fionda": "distanza", "cerbottana": "distanza", "lanciaspore": "distanza",
	"verga": "linfa", "tomo": "linfa", "sfera": "linfa",
	"scettro": "evocazione",
	"dischi": "lancio", "girandola": "lancio",
	"buccina": "canto", "flauto": "canto", "tamburo": "canto",
	"virgulto": "cura",
	"semetorre": "radice", "semebomba": "radice",
}
const KIND_STYLE := {"spada": "mischia", "arco": "distanza", "bastone": "linfa", "evocatore": "evocazione",
	"esplosivo": "lancio", "ricurvo": "lancio", "giavellotto": "lancio", "lancio": "lancio", "strumento": "canto",
	"ramo": "cura", "semeguerra": "radice"}

## Mischia: lo Slancio.
const SLANCIO_MAX := 5
const SLANCIO_MULT := 2.0
const SLANCIO_SHAKE := 3.0                # tessere attorno che la scossa del colpo pieno ferisce (metà del danno)
## Lancio: la Mira ferma.
const MIRA_T := 1.0
const MIRA_MULT := 1.8
const MIRA_PIERCE := 2
## Canto: l'Ispirazione e i canti di ogni strumento (durata in secondi; li prendono anche i compagni della mandria).
const ISPIRAZIONE_MAX := 12
const SONGS := {
	"buccina": {"name": "Canto di guerra", "t": 12.0, "damage": 1.25, "desc": "+25% danno"},
	"flauto": {"name": "Canto del ristoro", "t": 12.0, "heal": 0.15, "regen": 1.6, "desc": "cura il 15% della Vita, poi la fa ricrescere più in fretta"},
	"tamburo": {"name": "Canto della scorza", "t": 12.0, "defense": 0.6, "desc": "Scorza in più (sei decimi della tenacia ×10)"},
}
## Cura: la Rugiada.
const RUGIADA_EVERY := 6
const RUGIADA_HEAL := 0.06                # della Vita massima, a te e a ogni compagno vicino
const HEAL_ON_HIT := 0.05                 # ogni colpo del virgulto cura questa parte del danno fatto
## Radice: i semi-torre.
const TURRET_TIME := 12.0
const TURRET_EVERY := 0.8
const TURRET_RANGE := 11.0               # tessere
const TURRET_MAX := 2
const TURRET_MAX_HIGH := 3               # dal grado 7 del metallo (i metalli del Risveglio)


## Lo stile di un oggetto ("" se non è un'arma).
static func of_item(it: Dictionary) -> String:
	var f := String(it.get("form", ""))
	if FORM_STYLE.has(f):
		return String(FORM_STYLE[f])
	return String(KIND_STYLE.get(String(it.get("kind", "")), ""))


static func name_of(style: String) -> String:
	return String(STYLES.get(style, {}).get("name", ""))
