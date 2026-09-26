class_name SetsData
extends RefCounted
## I set di equipaggiamento (voce 26): chi indossa tutti i pezzi di un set riceve il suo bonus, in più degli effetti
## dei singoli pezzi. Le armature di metallo formano un set per metallo (elmo, corazza e gambali dello stesso metallo,
## generati da `ItemsData.METALS` in `all()`); poi le vesti di seta e alcune coppie di accessori che stanno bene
## insieme. Solo dati; li applica `GearEffects`, li mostrano la colonna dell'equipaggiamento e la casella Esamina.
##
## Campi: name (nome del bonus), pieces (oggetti da indossare tutti), bonus (stessi effetti degli accessori, vedi
## `GearEffects`, più `defense` = Scorza in più), desc (il bonus a parole).

## Il bonus di ogni set di metallo (i pezzi vengono da `ItemsData.METALS`).
const METAL_BONUS := {
	"radicite": {"name": "Radici salde", "bonus": {"defense": 2, "regen": 1.2}, "desc": "+2 Scorza, la Vita ricresce il 20% più in fretta"},
	"legnoferro": {"name": "Corteccia di ferro", "bonus": {"defense": 3, "damage": 1.05}, "desc": "+3 Scorza, +5% danno"},
	"pallidite": {"name": "Passo di luna", "bonus": {"run": 1.12, "atk_speed": 1.1}, "desc": "corsa +12%, colpi +10% più rapidi"},
	"ambra": {"name": "Luce fossile", "bonus": {"defense": 3, "halo": 1.4, "linfa_regen": 1.2}, "desc": "+3 Scorza, alone più ampio, Linfa +20%"},
	"tizzonite": {"name": "Brace viva", "bonus": {"damage": 1.12, "thorns": 10}, "desc": "+12% danno, chi ti tocca si brucia (10)"},
	"linfa": {"name": "Linfa che scorre", "bonus": {"defense": 3, "regen": 1.5, "linfa_regen": 1.5}, "desc": "+3 Scorza, Vita e Linfa ricrescono il 50% più in fretta"},
	"vuoto": {"name": "Ombra del Vuoto", "bonus": {"defense": 4, "damage": 1.1, "stealth": 0.7}, "desc": "+4 Scorza, +10% danno, le creature ti vedono più tardi"},
	"stellare": {"name": "Stella del Giardino", "bonus": {"defense": 6, "damage": 1.15, "run": 1.1, "luck": 0.2}, "desc": "+6 Scorza, +15% danno, corsa +10%, più fortuna"},
}

## Gli altri set: vesti e coppie di accessori.
const SETS := {
	"seta": {"name": "Tessitore di Linfa", "pieces": ["cappuccio_seta", "veste_seta", "calzari_seta"],
		"bonus": {"magic": 1.15, "linfa_regen": 1.3}, "desc": "incantesimi +15%, Linfa +30%"},
	"seta_vuoto": {"name": "Tessitore del Vuoto", "pieces": ["cappuccio_vuoto", "veste_vuoto", "calzari_vuoto"],
		"bonus": {"magic": 1.2, "stealth": 0.8, "linfa_regen": 1.3}, "desc": "incantesimi +20%, Linfa +30%, visto più tardi"},
	"scaglie": {"name": "Guscio di scarabeo", "pieces": ["corazza_scaglie", "corno_carica"],
		"bonus": {"defense": 4}, "desc": "+4 Scorza"},
	"notte": {"name": "Occhi della notte", "pieces": ["occhio_vuoto", "anello_nottilite"],
		"bonus": {"halo": 1.3, "luck": 0.25}, "desc": "alone più ampio, più fortuna"},
	"fuoco_gelo": {"name": "Fuoco e gelo", "pieces": ["anello_sanguinella", "anello_lagunite"],
		"bonus": {"damage": 1.05, "magic": 1.1}, "desc": "+5% danno, incantesimi +10%"},
	"riccio_resina": {"name": "Riccio e resina", "pieces": ["guscio_riccio", "pelle_resina"],
		"bonus": {"thorns": 10, "defense": 2}, "desc": "chi ti tocca si ferisce ancora di più (10), +2 Scorza"},
	"cielo": {"name": "Ali del cielo", "pieces": ["ali_membrana", "mantello_penne"],
		"bonus": {"run": 1.1, "jump": 1.1}, "desc": "corsa e salto +10%"},
	# voce 40: i set dei biomi nuovi
	"brina": {"name": "Passo di brina", "pieces": ["cappuccio_brina", "manto_brina", "gambali_brina"],
		"bonus": {"defense": 2, "run": 1.12, "fall_safe": true}, "desc": "+2 Scorza, corsa +12%, nessuna ferita da caduta"},
	"cenere": {"name": "Cuore di brace", "pieces": ["elmo_squame", "corazza_squame", "gambali_squame"],
		"bonus": {"defense": 3, "damage": 1.1, "thorns": 12}, "desc": "+3 Scorza, +10% danno, chi ti tocca si brucia (12)"},
}

static var _all := {}


## Tutti i set, quelli di metallo compresi (calcolati una volta).
static func all() -> Dictionary:
	if not _all.is_empty():
		return _all
	var out := SETS.duplicate(true)
	for m in METAL_BONUS:
		var mb: Dictionary = METAL_BONUS[m]
		out[m] = {"name": mb["name"], "pieces": ["elmo_" + m, "corazza_" + m, "gambali_" + m], "bonus": mb["bonus"],
			"desc": mb["desc"]}
	_all = out
	return _all


## I set di cui fa parte un oggetto.
static func of_item(id: String) -> Array:
	var out := []
	for s in all():
		if id in all()[s]["pieces"]:
			out.append(s)
	return out


## Quanti pezzi di un set sono indossati.
static func worn(set_id: String, equip: Dictionary) -> int:
	var n := 0
	for p in all()[set_id]["pieces"]:
		if p in equip.values():
			n += 1
	return n


## I set completi indossati.
static func complete(equip: Dictionary) -> Array:
	var out := []
	for s in all():
		if worn(s, equip) == (all()[s]["pieces"] as Array).size():
			out.append(s)
	return out
