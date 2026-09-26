class_name FormsData
extends RefCounted
## Le **forme** degli attrezzi, delle armi e delle armature (voce 49; nuove forme nella voce 50). Solo dati e le
## formule che, da una forma e un materiale (`MaterialsData`), fanno l'oggetto: nome, tipo, icona, valori, ricetta.
## L'id dell'oggetto è «forma_materiale» (`spada_radicite`, `corazza_ambra`…).
## Voce 50: nove forme nuove, ognuna con il suo modo di colpire (`AREA`: l'area del colpo in mischia), e le **fasce**
## (`FASCE`) che il Telaio avvolge sul manico di un'arma o di un attrezzo (nei "dati" della casella: `Gear`).
##
## Campi di una forma:
##   name, plural   nome («Gambali», al plurale)          kind   il tipo di oggetto (`ItemsData`)
##   bars, wood     lingotti e legno della ricetta (al Maglio); extra = altri materiali
##   icon           la forma dell'icona, se non ha lo stesso nome (il martello: «mazza»)
##   stats          come la forma pesa le proprietà del materiale (vedi `stats`)

const FORMS := {
	"piccone": {"name": "Piccone", "kind": "piccone", "bars": 12, "wood": 4},
	"ascia": {"name": "Ascia", "kind": "ascia", "bars": 9, "wood": 3},
	"spada": {"name": "Spada", "kind": "spada", "bars": 8, "wood": 0},
	"elmo": {"name": "Elmo", "kind": "elmo", "bars": 15, "wood": 0},
	"corazza": {"name": "Corazza", "kind": "corazza", "bars": 25, "wood": 0},
	"gambali": {"name": "Gambali", "kind": "gambali", "bars": 20, "wood": 0, "plural": true},
	"arco": {"name": "Arco", "kind": "arco", "bars": 10, "wood": 3},
	# voce 50
	"pugnale": {"name": "Pugnale", "kind": "spada", "bars": 5, "wood": 1, "desc": "corto e rapidissimo"},
	"spadone": {"name": "Spadone", "kind": "spada", "bars": 14, "wood": 0, "desc": "lento, largo e pesante"},
	"lancia": {"name": "Lancia", "kind": "spada", "bars": 8, "wood": 6, "desc": "colpisce lontano, in linea"},
	"martello": {"name": "Martello", "kind": "spada", "bars": 16, "wood": 4, "icon": "mazza", "desc": "il peso fa il danno; spinge lontanissimo"},
	"falcione": {"name": "Falce", "kind": "spada", "bars": 11, "wood": 4, "desc": "un giro largo: colpisce davanti e dietro"},
	"frusta": {"name": "Frusta", "kind": "spada", "bars": 5, "wood": 0, "extra": {"seta_radice": 4}, "desc": "lunghissima e svelta, ma spinge poco"},
	"balestra": {"name": "Balestra", "kind": "arco", "bars": 10, "wood": 5, "desc": "lenta, ma il dardo trafigge due creature"},
	"trivella": {"name": "Trivella", "kind": "piccone", "bars": 14, "wood": 2, "desc": "scava molto più in fretta"},
	"verga": {"name": "Verga", "kind": "bastone", "bars": 7, "wood": 3, "extra": {"cristallo_linfa": 2},
		"desc": "tira saette di Linfa: la conduzione del metallo fa il danno"},
}

## L'area del colpo in mischia: [larghezza, altezza, spostamento in avanti, anche dietro?]. Le forme non elencate
## usano l'area di sempre (`Combat.MELEE_REACH`).
const AREA := {
	"pugnale": [22, 30, 4, false], "spadone": [40, 44, 10, false], "lancia": [60, 22, 26, false],
	"martello": [30, 46, 6, false], "falcione": [64, 38, 0, true], "frusta": [76, 20, 34, false],
}

## Le fasce del Telaio: il materiale che si avvolge (quanti) e cosa cambia (moltiplicatori come i tratti).
const FASCE := {
	"seta": {"name": "seta", "item": "seta_radice", "n": 3, "speed": 1.08, "desc": "+8% velocità del colpo"},
	"membrana": {"name": "membrana", "item": "membrana_ardesia", "n": 2, "knock": 1.3, "desc": "+30% spinta"},
	"scaglie": {"name": "scaglie di serpe", "item": "scaglia_linfa", "n": 2, "damage": 1.06, "desc": "+6% danno"},
	"penne": {"name": "penne", "item": "penna_corteccia", "n": 3, "speed": 1.04, "damage": 1.03, "desc": "+4% velocità, +3% danno"},
	"regale": {"name": "gelatina regale", "item": "gelatina_regale", "n": 1, "speed": 1.05, "damage": 1.08,
		"desc": "+5% velocità, +8% danno"},
}
## Le forme che prendono una fascia (armi e attrezzi con il manico).
const WRAPPABLE := ["piccone", "ascia", "spada", "pugnale", "spadone", "lancia", "martello", "falcione", "frusta", "trivella",
	"verga", "arco", "balestra"]

## La Scorza di un pezzo d'armatura = tenacia del materiale × questo.
const ARMOR := {"elmo": 1.0, "corazza": 1.6, "gambali": 1.0}
## Velocità dei colpi di una spada = SPEED_BASE − SPEED_PESO × peso (più pesante = più lenta).
const SPEED_BASE := 3.0
const SPEED_PESO := 0.04


static func item_id(form: String, mat: String) -> String:
	return "%s_%s" % [form, mat]


## I valori di una forma fatta di un materiale.
static func stats(form: String, mat: String) -> Dictionary:
	var md := MaterialsData.get_mat(mat)
	var filo := float(md["filo"])
	var peso := float(md["peso"])
	var out := {}
	match form:
		"piccone", "ascia":
			out["power"] = int(md["durezza"])
			out["damage"] = int(filo * 0.6)
			out["speed"] = 2.6
		"spada":
			out["damage"] = roundi(filo)
			out["speed"] = snappedf(SPEED_BASE - SPEED_PESO * peso, 0.01)
			out["knockback"] = 4.0
		"elmo", "corazza", "gambali":
			out["defense"] = roundi(float(md["tenacia"]) * float(ARMOR[form]))
		"arco":
			out["damage"] = int(filo * 0.55)
			out["speed"] = snappedf(1.6 + 0.15 * float(md["tier"]), 0.01)
			out["knockback"] = 1.2
		"pugnale":
			out["damage"] = roundi(filo * 0.7)
			out["speed"] = snappedf((SPEED_BASE - SPEED_PESO * peso) * 1.55, 0.01)
			out["knockback"] = 1.5
		"spadone":
			out["damage"] = roundi(filo * 1.45 + peso * 0.2)
			out["speed"] = snappedf((SPEED_BASE - SPEED_PESO * peso) * 0.62, 0.01)
			out["knockback"] = 6.0
		"lancia":
			out["damage"] = roundi(filo * 1.1)
			out["speed"] = snappedf((SPEED_BASE - SPEED_PESO * peso) * 0.85, 0.01)
			out["knockback"] = 2.5
		"martello":
			out["damage"] = roundi(filo * 0.8 + peso * 0.6)
			out["speed"] = snappedf((SPEED_BASE - SPEED_PESO * peso) * 0.55, 0.01)
			out["knockback"] = 9.0
		"falcione":
			out["damage"] = roundi(filo * 1.1)
			out["speed"] = snappedf((SPEED_BASE - SPEED_PESO * peso) * 0.75, 0.01)
			out["knockback"] = 3.0
		"frusta":
			out["damage"] = roundi(filo * 0.75)
			out["speed"] = snappedf((SPEED_BASE - SPEED_PESO * peso) * 1.1, 0.01)
			out["knockback"] = 0.5
		"balestra":
			out["damage"] = roundi(filo * 0.85)
			out["speed"] = snappedf((1.6 + 0.15 * float(md["tier"])) * 0.55, 0.01)
			out["knockback"] = 2.5
			out["pierce"] = 2
		"trivella":
			out["power"] = int(md["durezza"]) + 5
			out["damage"] = int(filo * 0.4)
			out["speed"] = 2.6
			out["dig"] = 1.6
		"verga":
			out["damage"] = roundi(float(md["conduzione"]) * 1.6 + 2.0)
			out["speed"] = 2.2
			out["knockback"] = 1.0
			out["spell"] = "saetta"
			out["linfa"] = 2 + int(md["tier"]) / 2
	return out


## L'oggetto di una forma e un materiale, come le voci di `ItemsData.ITEMS`.
static func item(form: String, mat: String) -> Dictionary:
	var fd: Dictionary = FORMS[form]
	var md := MaterialsData.get_mat(mat)
	var label := String(md.get("label_pl", md["label"])) if fd.get("plural", false) else String(md["label"])
	var it := {"name": "%s %s" % [fd["name"], label], "kind": fd["kind"], "icon": [String(fd.get("icon", form)), MaterialsData.icon_of(mat)],
		"tier": md["tier"], "form": form, "mat": mat}
	if fd.has("desc"):
		it["desc"] = "%s %s: %s." % [fd["name"], label, fd["desc"]]
	it.merge(stats(form, mat))
	return it


## La ricetta di una forma e un materiale (al Maglio).
static func recipe(form: String, mat: String) -> Dictionary:
	var fd: Dictionary = FORMS[form]
	var needs := {String(MaterialsData.get_mat(mat)["bar"]): int(fd["bars"])}
	if int(fd["wood"]) > 0:
		needs["legno"] = int(fd["wood"])
	for k in fd.get("extra", {}):
		needs[k] = int(fd["extra"][k])
	return {"out": item_id(form, mat), "qty": 1, "in": needs, "station": "maglio"}
