class_name SetsData
extends RefCounted
## I set di equipaggiamento (voce 26): chi indossa tutti i pezzi di un set riceve il suo bonus, in più degli effetti
## dei singoli pezzi. Le armature di metallo formano un set per metallo (elmo, corazza e gambali dello stesso metallo,
## generati da `MaterialsData` in `all()`); poi le vesti di seta e alcune coppie di accessori che stanno bene
## insieme. Solo dati; li applica `GearEffects`, li mostrano la colonna dell'equipaggiamento e la casella Esamina.
##
## Campi: name (nome del bonus), pieces (oggetti da indossare tutti), bonus (stessi effetti degli accessori, vedi
## `GearEffects`, più `defense` = Scorza in più), desc (il bonus a parole).

## Il bonus di ogni set di metallo (i pezzi vengono da `MaterialsData`).
const METAL_BONUS := {
	"radicite": {"name": "Radici salde", "bonus": {"defense": 2, "regen": 1.2}, "desc": "+2 Scorza, la Vita ricresce il 20% più in fretta"},
	"legnoferro": {"name": "Corteccia di ferro", "bonus": {"defense": 3, "damage": 1.05}, "desc": "+3 Scorza, +5% danno"},
	"pallidite": {"name": "Passo di luna", "bonus": {"run": 1.12, "atk_speed": 1.1}, "desc": "corsa +12%, colpi +10% più rapidi"},
	"ambra": {"name": "Luce fossile", "bonus": {"defense": 3, "halo": 1.4, "linfa_regen": 1.2}, "desc": "+3 Scorza, alone più ampio, Linfa +20%"},
	"tizzonite": {"name": "Brace viva", "bonus": {"damage": 1.12, "thorns": 10}, "desc": "+12% danno, chi ti tocca si brucia (10)"},
	"linfa": {"name": "Linfa che scorre", "bonus": {"defense": 3, "regen": 1.5, "linfa_regen": 1.5}, "desc": "+3 Scorza, Vita e Linfa ricrescono il 50% più in fretta"},
	"vuoto": {"name": "Ombra del Vuoto", "bonus": {"defense": 4, "damage": 1.1, "stealth": 0.7}, "desc": "+4 Scorza, +10% danno, le creature ti vedono più tardi"},
	"nimbite": {"name": "Passo di nembo", "bonus": {"jump": 1.15, "run": 1.06, "quota": 0.5},
		"desc": "salto +15%, corsa +6%, l'aria sottile protegge a metà"},
	"stellare": {"name": "Stella del Giardino", "bonus": {"defense": 6, "damage": 1.15, "run": 1.1, "luck": 0.2}, "desc": "+6 Scorza, +15% danno, corsa +10%, più fortuna"},
}

## Roadmap 31, voce 307: i set dei **materiali dei geni** (cinque pezzi come quelli dei metalli), scritti apposta.
const GENE_BONUS := {
	"ferro_brina": {"name": "Brina d'acciaio", "bonus": {"fresco": 0.5, "regen": 1.15, "defense": 2}},
	"ossidiana_brace": {"name": "Cuore d'ossidiana", "bonus": {"caldo": 0.5, "damage": 1.08, "thorns": 6}},
	"micelio_duro": {"name": "Trama di micelio", "bonus": {"filtro": 0.5, "regen": 1.25, "defense": 1}},
	"linfite": {"name": "Vena di linfite", "bonus": {"magic": 1.15, "linfa_regen": 1.3}},
	"radicite_pura": {"name": "Radice pura", "bonus": {"dig": 1.2, "defense": 3}},
	"ambra_dorata": {"name": "Oro fossile", "bonus": {"luck": 0.15, "halo": 1.3, "defense": 2}},
	"ferro_stellato": {"name": "Cielo di ferro", "bonus": {"luck": 0.15, "run": 1.08, "defense": 4}},
	"vuoto_cavo": {"name": "Guscio vuoto", "bonus": {"stealth": 0.7, "magic": 1.1, "defense": 3}},
	"sospesite": {"name": "Passo sospeso", "bonus": {"jump": 1.2, "glide": true, "quota": 0.5}},
	"nerume": {"name": "Ombra avvizzita", "bonus": {"damage": 1.12, "thorns": 8, "defense": 3}},
	"chitina": {"name": "Guscio brulicante", "bonus": {"defense": 6, "thorns": 6}},
	"osso_antico": {"name": "Ossa degli antichi", "bonus": {"damage": 1.08, "atk_speed": 1.08, "defense": 3}},
}
## I set delle **leghe**: i bonus dei set dei due metalli insieme, ridotti a questa parte.
const ALLOY_SHARE := 0.5                 # (metà di ciascuno: insieme valgono quanto un set di metallo puro)
const ARMOR_FORMS := ["elmo", "corazza", "gambali", "guanti", "stivali"]

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
}

static var _all := {}


## Tutti i set, quelli di metallo compresi (calcolati una volta).
static func all() -> Dictionary:
	if not _all.is_empty():
		return _all
	var out := SETS.duplicate(true)
	out.merge(BiomesData.pack("sets"))                  # voce 92: i set dei biomi
	for m in METAL_BONUS:
		var mb: Dictionary = METAL_BONUS[m]
		# voce 86: i set dei metalli sono di cinque pezzi (con guanti e stivali)
		out[m] = {"name": mb["name"], "pieces": _pieces(m), "bonus": mb["bonus"], "desc": mb["desc"]}
	# voce 307: una lega ha il set dei suoi due metalli insieme (ridotti), un materiale dei geni il suo
	for mat in MaterialsData.all():
		var md: Dictionary = MaterialsData.all()[mat]
		var bonus := {}
		var name := ""
		if md.has("alloy"):
			bonus = blend(METAL_BONUS[md["alloy"][0]]["bonus"], METAL_BONUS[md["alloy"][1]]["bonus"], ALLOY_SHARE)
			name = String(md["short"]).substr(0, 1).to_upper() + String(md["short"]).substr(1)
		elif GENE_BONUS.has(mat):
			bonus = GENE_BONUS[mat]["bonus"]
			name = String(GENE_BONUS[mat]["name"])
		else:
			continue
		out[String(mat)] = {"name": name, "pieces": _pieces(String(mat)), "bonus": bonus, "desc": describe(bonus)}
	_all = out
	return _all


static func _pieces(mat: String) -> Array:
	return ARMOR_FORMS.map(func(f: String) -> String: return "%s_%s" % [f, mat])


## Due bonus di set in uno, ciascuno ridotto a `share` (i moltiplicatori verso 1, le somme in proporzione; la Scorza a
## numeri interi; ciò che c'è o non c'è resta).
static func blend(a: Dictionary, b: Dictionary, share: float) -> Dictionary:
	var out := {}
	for src in [a, b]:
		for k in src:
			var v: Variant = src[k]
			if v is bool:
				out[k] = bool(out.get(k, false)) or bool(v)
			elif k in MaterialsData.ADDITIVE:
				out[k] = float(out.get(k, 0.0)) + float(v) * share
			else:
				out[k] = float(out.get(k, 1.0)) * (1.0 + (float(v) - 1.0) * share)
	for k in out:
		if out[k] is float:
			out[k] = float(roundi(float(out[k]))) if k in ["defense", "thorns"] else snappedf(float(out[k]), 0.01)
	return out


## Un bonus in parole: «+3 Scorza, corsa +12%…» (dalle righe delle schede, `TipWordsData.acc_line`).
static func describe(bonus: Dictionary) -> String:
	var parts := []
	for k in bonus:
		parts.append(String(TipWordsData.acc_line(String(k), bonus[k])[0]))
	return ", ".join(parts)


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
