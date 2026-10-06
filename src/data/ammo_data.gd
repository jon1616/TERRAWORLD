class_name AmmoData
## Le munizioni (Roadmap 40, voce 372; piano in `VASTITA.md`). Solo dati: li legge `Combat._bow`.
## Tre famiglie, una per tipo d'arma (`FormsData.AMMO_OF`): **dardi** (archi e balestre), **sassi** (fionde) e
## **spore** (cerbottane e lanciaspore). Ogni munizione ha un **modo** suo (`MODS`: i moduli dei colpi di
## `GesturesData` e un elemento), che si somma al gesto del metallo dell'arma; e un danno che conta un poco da solo e
## un poco con l'arma (`K`): così all'inizio un dardo buono vale come prima e alla fine fa ancora la differenza.
## L'arco tira la munizione del suo tipo che fa più danno (le caselle bloccate restano dove sono).

const K := 0.015                         # danno in più = arma × danno della munizione × K (oltre al danno della munizione)

## I modi delle munizioni, anche di quelle scritte altrove (i dardi dei biomi e del cielo).
const MODS := {
	"dardo_piumato": {"speed": 1.15}, "dardo_aculeo": {"pierce": 1}, "dardo_libellula": {"speed": 1.2},
	"dardo_gelo": {"elem": "gelo", "chill": 1.5}, "dardo_vuoto": {"elem": "vuoto", "split": [2, 0.35]},
	"dardo_folgore": {"bounce": 2, "speed": 1.2}, "dardo_prisma": {"pierce": 1, "homing": 1.0},
	"dardo_nubi": {"speed": 1.3}, "dardo_falco": {"speed": 1.4, "pierce": 1}, "dardo_stella": {"elem": "luce", "homing": 2.0},
	# voce 372
	"dardo_corallite": {"elem": "linfa", "split": [2, 0.35]}, "dardo_sanguinite": {"elem": "brace", "boom": [1.5, 0.4]},
	"dardo_eterite": {"elem": "gelo", "speed": 1.4, "pierce": 2}, "dardo_astrite": {"elem": "luce", "homing": 2.5, "split": [2, 0.3]},
	"dardo_primambra": {"elem": "luce", "boom": [2.0, 0.5], "pierce": 1},
	"sasso_ardesia": {"bounce": 1}, "sasso_ambra": {"boom": [1.5, 0.3]}, "sasso_brace": {"elem": "brace"},
	"sasso_brina": {"elem": "gelo", "chill": 1.5}, "sasso_vuoto": {"elem": "vuoto", "split": [2, 0.4]},
	"sasso_stella": {"elem": "luce", "homing": 2.0}, "sasso_corallo": {"elem": "linfa", "split": [3, 0.3]},
	"sasso_primo": {"elem": "luce", "boom": [2.0, 0.5], "pierce": 1},
	"spora_muffa": {"elem": "spora"}, "spora_brace": {"elem": "brace"}, "spora_gelo": {"elem": "gelo", "chill": 2.0},
	"spora_linfa": {"elem": "linfa", "homing": 3.0}, "spora_vuoto": {"elem": "vuoto", "split": [2, 0.35]},
	"spora_stella": {"elem": "luce", "homing": 2.0, "pierce": 1}, "spora_corallo": {"elem": "linfa", "boom": [1.5, 0.4]},
	"spora_prima": {"elem": "luce", "boom": [2.0, 0.5], "homing": 2.0},
}

## Le munizioni nuove: [id, nome, tipo, danno, icona [forma, tavolozza], ingrediente (oltre alla base), descrizione].
## Le basi (sasso, spora da soffio) si fanno al Ceppo da una pietra o una spora; le altre da venti basi e un ingrediente.
const NEW := [
	["sasso", "Sasso da fionda", "sasso", 3, ["gemma", "ardesia"], {"ardesia": 1}, "Un sasso tondo. La fionda lo tira svelta."],
	["sasso_ardesia", "Sasso d'ardesia", "sasso", 5, ["gemma", "cenere"], {"ciottolo": 2}, "Piatto e duro: rimbalza sulla roccia."],
	["sasso_ambra", "Sasso d'ambra", "sasso", 8, ["gemma", "ambra"], {"lingotto_ambra": 1}, "Si spacca colpendo: ferisce attorno."],
	["sasso_brace", "Sasso di brace", "sasso", 10, ["gemma", "tizzonite"], {"lingotto_tizzonite": 1}, "Ancora caldo: brucia."],
	["sasso_brina", "Sasso di brina", "sasso", 10, ["gemma", "pallidite"], {"lingotto_pallidite": 1}, "Freddo come il gelo: rallenta."],
	["sasso_vuoto", "Sasso di vuotite", "sasso", 13, ["gemma", "vuotite"], {"lingotto_vuoto": 1}, "Si divide in due colpendo."],
	["sasso_stella", "Sasso di stella", "sasso", 16, ["gemma", "stelle"], {"lingotto_stellare": 1}, "Cerca la creatura da solo."],
	["sasso_corallo", "Sasso di corallite", "sasso", 20, ["gemma", "corallite"], {"lingotto_corallite": 1}, "Si apre in tre schegge."],
	["sasso_primo", "Sasso di primambra", "sasso", 26, ["gemma", "primambra"], {"lingotto_primambra": 1}, "Esplode di luce e attraversa."],
	["spora_soffio", "Spora da soffio", "spora", 2, ["polvere", "muschio"], {"sacca_spore": 1}, "Leggera: la cerbottana la soffia lontano."],
	["spora_muffa", "Spora di muffa", "spora", 5, ["polvere", "nottilite"], {"gelatina": 1}, "Porta le spore: avvelena."],
	["spora_brace", "Spora di brace", "spora", 8, ["polvere", "tizzonite"], {"lingotto_tizzonite": 1}, "Si accende colpendo."],
	["spora_gelo", "Spora del gelo", "spora", 8, ["polvere", "brina"], {"lingotto_pallidite": 1}, "Gela a lungo."],
	["spora_linfa", "Spora di Linfa", "spora", 11, ["polvere", "lagunite"], {"lingotto_linfa": 1}, "Insegue la creatura."],
	["spora_vuoto", "Spora del Vuoto", "spora", 14, ["polvere", "vuotite"], {"lingotto_vuoto": 1}, "Si divide in due."],
	["spora_stella", "Spora di stella", "spora", 18, ["polvere", "stelle"], {"lingotto_stellare": 1}, "Insegue e attraversa."],
	["spora_corallo", "Spora di corallite", "spora", 22, ["polvere", "corallite"], {"lingotto_corallite": 1}, "Scoppia piano attorno."],
	["spora_prima", "Spora di primambra", "spora", 28, ["polvere", "primambra"], {"lingotto_primambra": 1}, "Insegue ed esplode di luce."],
	["dardo_corallite", "Dardo di corallite", "dardo", 15, ["freccia", "corallite"], {"lingotto_corallite": 1}, "Si divide in due colpendo."],
	["dardo_sanguinite", "Dardo di sanguinite", "dardo", 18, ["freccia", "sanguinite"], {"lingotto_sanguinite": 1}, "Brucia e scoppia."],
	["dardo_eterite", "Dardo d'eterite", "dardo", 22, ["freccia", "eterite"], {"lingotto_eterite": 1}, "Velocissimo: attraversa due creature."],
	["dardo_astrite", "Dardo d'astrite", "dardo", 26, ["freccia", "astrite"], {"lingotto_astrite": 1}, "Insegue e si divide."],
	["dardo_primambra", "Dardo di primambra", "dardo", 32, ["freccia", "primambra"], {"lingotto_primambra": 1}, "Esplode di luce e attraversa."],
]


static func items() -> Dictionary:
	var out := {}
	for r in NEW:
		var it := {"name": r[1], "kind": "munizione", "ammo": r[2], "damage": r[3], "icon": r[4], "stack": 999, "desc": r[6]}
		out[String(r[0])] = it
	return out


static func recipes() -> Array:
	var out := []
	var base := {"sasso": "sasso", "spora": "spora_soffio", "dardo": "dardo"}
	for r in NEW:
		var id := String(r[0])
		var ins: Dictionary = (r[5] as Dictionary).duplicate()
		if id == "sasso" or id == "spora_soffio":
			out.append({"out": id, "qty": 20, "in": ins, "station": "ceppo"})
		else:
			ins[String(base[String(r[2])])] = 20
			out.append({"out": id, "qty": 20, "in": ins, "station": "maglio" if (r[5] as Dictionary).keys()[0].begins_with("lingotto_") else "ceppo"})
	return out


## Il tipo di una munizione (dardo, sasso, spora).
static func type_of(it: Dictionary) -> String:
	return String(it.get("ammo", "dardo"))
