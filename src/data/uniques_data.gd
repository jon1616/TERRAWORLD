class_name UniquesData
## Gli oggetti unici (voce 85 i primi, voce 98 la collezione intera): scritti a mano, con un nome, una storia e gli
## **effetti speciali** di `EffectsData` che li rendono diversi da tutto il resto. Solo dati; ognuno ha un posto preciso
## dove si trova (`source`), e `POOLS` dice da dove escono a caso (chi li lascia).
## Un unico si riconosce dal campo "unique": nella scheda ha il nome dorato e la sua storia.

const ITEMS := {
	# armi
	"lingua_tizzone": {"name": "Lingua del tizzone", "kind": "spada", "icon": ["spada", "tizzonite"], "unique": true,
		"damage": 20, "speed": 2.5, "knockback": 3.0, "stack": 1, "effects": ["brace_colpo", "slancio"],
		"story": "Forgiata in un fiume di brace da un Seminatore che non voleva più aver freddo.",
		"source": "a volte, un Guardiano evocato al Cerchio dei Seminatori"},
	"spina_inverno": {"name": "Spina d'inverno", "kind": "spada", "icon": ["pugnale", "brina"], "unique": true,
		"damage": 14, "speed": 3.4, "knockback": 1.5, "stack": 1, "effects": ["gelo_colpo", "stordisce_colpo"],
		"story": "Un ghiacciolo che non si scioglie mai: sotto la brina, un cuore di cristallo.",
		"source": "a volte, un Guardiano evocato al Cerchio dei Seminatori"},
	"campana_rovo": {"name": "Campana di rovo", "kind": "spada", "icon": ["martello", "radice"], "unique": true,
		"damage": 26, "speed": 1.6, "knockback": 5.0, "stack": 1, "effects": ["schegge", "stordisce_colpo"],
		"story": "Ogni colpo suona, e ogni suono lascia cadere spine.",
		"source": "a volte, un Guardiano evocato al Cerchio dei Seminatori"},
	"ramo_temporale": {"name": "Ramo del temporale", "kind": "spada", "icon": ["lancia", "brillaluce"], "unique": true,
		"damage": 18, "speed": 2.2, "knockback": 2.5, "stack": 1, "effects": ["fulmine_eco"],
		"story": "Un ramo colpito dal fulmine tre volte. Se lo ricorda.",
		"source": "a volte, un Guardiano evocato al Cerchio dei Seminatori"},
	"falce_sete": {"name": "Falce della sete", "kind": "spada", "icon": ["falce", "sanguinella"], "unique": true,
		"damage": 17, "speed": 2.3, "knockback": 2.0, "stack": 1, "effects": ["linfa_colpo", "furia_bassa"],
		"story": "Beve ciò che taglia, e più sei ferito più ha sete.",
		"source": "a volte, un Guardiano evocato al Cerchio dei Seminatori"},
	# accessori
	"occhio_gufo": {"name": "Occhio di gufo", "kind": "accessorio", "icon": ["occhio", "ambra"], "unique": true,
		"acc": {"halo": 1.2}, "effects": ["notturno"], "stack": 1,
		"story": "Vede di notte ciò che di giorno si nasconde.",
		"source": "a volte, un Guardiano evocato al Cerchio dei Seminatori"},
	"pinna_lago": {"name": "Pinna del lago", "kind": "accessorio", "icon": ["foglia", "lagunite"], "unique": true,
		"effects": ["anfibio", "respiro_lungo"], "stack": 1,
		"story": "La pinna di un Pesce lume grande come un uomo.",
		"source": "a volte, un Guardiano evocato al Cerchio dei Seminatori"},
	"muschio_ombra": {"name": "Muschio dell'ombra", "kind": "accessorio", "icon": ["velo", "muschio"], "unique": true,
		"effects": ["ombra_ferito"], "acc": {"stealth": 0.9}, "stack": 1,
		"story": "Si arrotola attorno a chi ha paura, e lo nasconde.",
		"source": "a volte, un Guardiano evocato al Cerchio dei Seminatori"},
	"seme_secondo": {"name": "Seme della seconda radice", "kind": "accessorio", "icon": ["seme", "cristallo"], "unique": true,
		"effects": ["seconda_vita"], "stack": 1,
		"story": "Un seme che ha già germogliato una volta, e sa come si fa.",
		"source": "a volte, un Guardiano evocato al Cerchio dei Seminatori"},
	"corno_cacciatore": {"name": "Corno del cacciatore", "kind": "accessorio", "icon": ["corno", "ambra"], "unique": true,
		"effects": ["caccia_lumini", "slancio"], "stack": 1,
		"story": "Chi lo porta non torna mai a mani vuote.",
		"source": "a volte, un Guardiano evocato al Cerchio dei Seminatori"},
	"cuore_inverno": {"name": "Cuore dell'inverno", "kind": "accessorio", "icon": ["cuore", "brina"], "unique": true,
		"effects": ["aura_gelo"], "acc": {"defense": 2}, "stack": 1,
		"story": "Batte piano, e attorno a lui l'aria si ferma.",
		"source": "a volte, un Guardiano evocato al Cerchio dei Seminatori"},
	"rovo_vivo": {"name": "Rovo vivo", "kind": "accessorio", "icon": ["radice_viaggio", "radice"], "unique": true,
		"effects": ["spine_vive", "rigenera_fermo"], "stack": 1,
		"story": "Un rovo che si è affezionato: ti difende, e ti cura quando ti fermi.",
		"source": "a volte, un Guardiano evocato al Cerchio dei Seminatori"},
}

## Da dove escono a caso: chi li lascia e con che probabilità.
const POOLS := {
	"evocati": {"chance": 0.3, "items": ["lingua_tizzone", "spina_inverno", "campana_rovo", "ramo_temporale", "falce_sete",
		"occhio_gufo", "pinna_lago", "muschio_ombra", "seme_secondo", "corno_cacciatore", "cuore_inverno", "rovo_vivo"]},
}


static func is_unique(id: String) -> bool:
	return bool(ItemsData.get_item(id).get("unique", false))
