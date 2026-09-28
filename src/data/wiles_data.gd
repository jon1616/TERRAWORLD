class_name WilesData
extends RefCounted
## Le astuzie delle creature (voce 130, Roadmap 15): i comportamenti nuovi con il loro nome, il segnale che danno prima
## e la **contromossa**. La scheda della creatura e l'Enciclopedia li leggono da qui; la logica sta in
## `src/entities/behaviors/` (un file per comportamento) e in `Wiles` (ciò che tocca il mondo).
## Regola dell'utente: le creature non distruggono nulla (blocchi, terra, colture) fuori dagli assedi; negli assedi
## rodono solo le porte.

const WILES := {
	"sbuca": {"name": "Sbuca da sotto", "tell": "la terra trema e fa polvere sotto i tuoi piedi",
		"counter": "spostati appena la terra trema; sulle passerelle o sui blocchi costruiti è più lenta a trovarti"},
	"divide": {"name": "Si divide", "tell": "si gonfia quando è colpita",
		"counter": "il fuoco o un colpo solo molto forte le impediscono di dividersi"},
	"ladro": {"name": "Ladro", "tell": "si ferma un attimo accanto a te",
		"counter": "tienilo lontano; se ti ruba qualcosa inseguilo: preso, lo restituisce"},
	"mimetico": {"name": "Mimetico", "tell": "sembra una cassa, un blocco o una pianta",
		"counter": "la Vista della Linfa (V) lo scopre da lontano; o colpiscilo prima di avvicinarti"},
	"scudo": {"name": "Scudo frontale", "tell": "si gira lentamente verso di te",
		"counter": "colpiscilo da dietro o dall'alto: davanti para quasi tutto"},
	"guaritore": {"name": "Guaritore", "tell": "si ferma e si illumina",
		"counter": "abbattilo per primo, o interrompilo mentre si prepara"},
	"richiamo": {"name": "Richiamo", "tell": "si ferma e chiama a lungo",
		"counter": "colpiscilo mentre chiama: zittito, i rinforzi non arrivano"},
	"parassita": {"name": "Parassita", "tell": "ti salta addosso",
		"counter": "salta per scrollartelo di dosso, o bruciala"},
	"tuffatore": {"name": "Tuffatore", "tell": "fa le bolle vicino alla riva",
		"counter": "stai lontano dalla riva, pescalo, o prosciuga lo specchio"},
	"tessitore": {"name": "Tessitore", "tell": "si ferma e fila",
		"counter": "una torcia in mano brucia le ragnatele; le torce vicine le disfano"},
	"rosicchia": {"name": "Rosicchiatore", "tell": "negli assedi rode le porte",
		"counter": "negli assedi difendi le porte: una porta regge qualche morso, poi cade (mura e luce lo tengono lontano)"},
	"fotofobo": {"name": "Fotofobo", "tell": "si aggira nel buio",
		"counter": "accendi le torce: alla luce forte è più debole e fugge"},
	"pastore": {"name": "Pastore", "tell": "le compagne lo seguono",
		"counter": "abbatti lui: il gregge si sbanda e fugge"},
	"scoppia": {"name": "Scoppiante", "tell": "si gonfia e trema quando è vicina",
		"counter": "abbattila da lontano: presa in tempo non scoppia"},
}

## Le ragnatele dei tessitori: quante celle, quanto durano, quanto rallentano.
const WEB_W := 3
const WEB_H := 2
const WEB_TIME := 25.0
const WEB_SLOW := 0.6
## I rosicchiatori: quanti morsi regge una porta durante un assedio.
const DOOR_HITS := 6


static func of(c_behaviors: Array) -> Array:
	var out := []
	for b in c_behaviors:
		if WILES.has(String(b)):
			out.append(WILES[String(b)])
	return out
