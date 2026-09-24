class_name ItemDefs
extends RefCounted
## Dati degli oggetti. Per ora solo quelli della barra rapida di prova; inventario, ricette e statistiche
## arriveranno con la voce 3 della Roadmap.

const METALS := {"rame": ItemIcons.M_COPPER, "ferro": ItemIcons.M_IRON, "oro": ItemIcons.M_GOLD, "cristallo": ItemIcons.M_CRYSTAL}

## use: "scava" (piccone), "colpo" (arma da mischia), "torcia" (si piazza), "" (nessun uso per ora)
const HOTBAR := [
	{"id": "piccone_rame", "name": "Piccone di rame", "icon": "pickaxe", "metal": "rame", "use": "scava"},
	{"id": "spada_rame", "name": "Spada di rame", "icon": "sword", "metal": "rame", "use": "colpo"},
	{"id": "spada_ferro", "name": "Spada di ferro", "icon": "sword", "metal": "ferro", "use": "colpo"},
	{"id": "spada_oro", "name": "Spada d'oro", "icon": "sword", "metal": "oro", "use": "colpo"},
	{"id": "lama_cristallo", "name": "Lama di cristallo", "icon": "sword", "metal": "cristallo", "use": "colpo"},
	{"id": "arco_legno", "name": "Arco di legno", "icon": "bow", "use": ""},
	{"id": "torcia", "name": "Torcia", "icon": "torch", "use": "torcia"},
	{"id": "lingotto_rame", "name": "Lingotto di rame", "icon": "bar", "metal": "rame", "use": ""},
	{"id": "lingotto_oro", "name": "Lingotto d'oro", "icon": "bar", "metal": "oro", "use": ""},
	{"id": "pozione_cura", "name": "Pozione di cura", "icon": "potion", "use": ""},
]


static func icon(item: Dictionary) -> Image:
	var metal: Array = METALS.get(item.get("metal", "rame"), ItemIcons.M_COPPER)
	match String(item["icon"]):
		"pickaxe":
			return ItemIcons.icon_pickaxe(metal)
		"sword":
			return ItemIcons.icon_sword(metal)
		"bow":
			return ItemIcons.icon_bow()
		"torch":
			return ItemIcons.icon_torch()
		"bar":
			return ItemIcons.icon_bar(metal)
	return ItemIcons.icon_potion()
