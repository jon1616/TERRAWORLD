class_name FormsData
extends RefCounted
## Le **forme** degli attrezzi, delle armi e delle armature (voce 49; nuove forme nella voce 50). Solo dati e le
## formule che, da una forma e un materiale (`MaterialsData`), fanno l'oggetto: nome, tipo, icona, valori, ricetta.
## L'id dell'oggetto è «forma_materiale» (`spada_radicite`, `corazza_ambra`…).
##
## Campi di una forma:
##   name, plural   nome («Gambali», al plurale)          kind   il tipo di oggetto (`ItemsData`)
##   bars, wood     lingotti e legno della ricetta (al Maglio)
##   stats          come la forma pesa le proprietà del materiale (vedi `stats`)

const FORMS := {
	"piccone": {"name": "Piccone", "kind": "piccone", "bars": 12, "wood": 4},
	"ascia": {"name": "Ascia", "kind": "ascia", "bars": 9, "wood": 3},
	"spada": {"name": "Spada", "kind": "spada", "bars": 8, "wood": 0},
	"elmo": {"name": "Elmo", "kind": "elmo", "bars": 15, "wood": 0},
	"corazza": {"name": "Corazza", "kind": "corazza", "bars": 25, "wood": 0},
	"gambali": {"name": "Gambali", "kind": "gambali", "bars": 20, "wood": 0, "plural": true},
	"arco": {"name": "Arco", "kind": "arco", "bars": 10, "wood": 3},
}

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
	return out


## L'oggetto di una forma e un materiale, come le voci di `ItemsData.ITEMS`.
static func item(form: String, mat: String) -> Dictionary:
	var fd: Dictionary = FORMS[form]
	var md := MaterialsData.get_mat(mat)
	var label := String(md.get("label_pl", md["label"])) if fd.get("plural", false) else String(md["label"])
	var it := {"name": "%s %s" % [fd["name"], label], "kind": fd["kind"], "icon": [form, MaterialsData.icon_of(mat)],
		"tier": md["tier"], "form": form, "mat": mat}
	it.merge(stats(form, mat))
	return it


## La ricetta di una forma e un materiale (al Maglio).
static func recipe(form: String, mat: String) -> Dictionary:
	var fd: Dictionary = FORMS[form]
	var needs := {String(MaterialsData.get_mat(mat)["bar"]): int(fd["bars"])}
	if int(fd["wood"]) > 0:
		needs["legno"] = int(fd["wood"])
	return {"out": item_id(form, mat), "qty": 1, "in": needs, "station": "maglio"}
