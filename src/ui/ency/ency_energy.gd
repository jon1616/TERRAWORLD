class_name EncyEnergy
extends RefCounted
## Roadmap 19, voce 210: i cataloghi della rete per l'Enciclopedia, nati dai dati (`MachinesData`, `VeinsData`):
## {cat_rete_sorgenti}, {cat_rete_riserve}, {cat_rete_macchine}, {cat_rete_comandi}, {cat_rete_nodi}, {cat_rete_vene}.
## Li chiama `EncyCatalogs.inline` per le chiavi che cominciano con «cat_rete_».

const ROLES := {"cat_rete_sorgenti": "sorgente", "cat_rete_riserve": "riserva", "cat_rete_macchine": "macchina",
	"cat_rete_comandi": "comando", "cat_rete_nodi": "nodo"}


static func inline(key: String) -> String:
	var rows := []
	if key == "cat_rete_vene":
		for i in range(1, VeinsData.TIERS.size()):
			var td: Dictionary = VeinsData.TIERS[i]
			rows.append(EncyCatalogs._b("[url=item:%s]%s[/url]" % [td["item"], td["name"]], "porta fino a %d pulsi" % int(td["cap"])))
		return "\n".join(rows)
	var role := String(ROLES.get(key, ""))
	for id in MachinesData.MACHINES:
		var d: Dictionary = MachinesData.MACHINES[id]
		if String(d.get("role", "")) != role or d.get("gen", false):
			continue
		var what := ""
		match role:
			"sorgente":
				what = "fino a %d pulsi · " % int(d.get("pulsi", 0))
			"riserva":
				what = "%d gocce · " % int(d.get("cap", 0))
			"macchina":
				if int(d.get("pulsi", 0)) > 0:
					what = "%d pulsi · " % int(d["pulsi"])
		rows.append(EncyCatalogs._b("[url=item:%s]%s[/url]" % [id, d["name"]], what + String(d["desc"])))
	return "\n".join(rows)
