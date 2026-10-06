class_name SpineData
## La spina della partita (Roadmap 39, voci 362-366; piano in `VASTITA.md`). Solo dati: le curve dei numeri, la fase di
## ogni vigore e i metalli che arrivano dopo il Risveglio del Cuore.
##
## **La scala.** Una fase = +16% al danno delle armi; un vigore = due fasi. Così il metallo di grado t ha la fase 2t-1 e
## il suo filo è 9 × 1,16^(2t-2): dal 9 della radicite al 236 della primambra (×26 sulla spina). Le creature seguono:
## Vita ×1,3456 per vigore fino al vigore `SOFT`, poi poco (il dopo: lì crescono la tempra e i Semi d'oro); il danno
## cresce meno della Vita (`DMG_STEP`), perché la Vita del Germogliato non può crescere come le armi. Dentro un mondo gli
## strati aggiungono ancora fino a ×1,9 (`StrataData`): il Fondo di un mondo vale la Superficie di due vigori dopo.
## Il metallo migliore di un mondo di vigore v è di grado v+1 dal vigore 5 (lo stellare con le Schegge dei mondi di vigore
## 5, poi un metallo del Risveglio per vigore, fino alla primambra del vigore 11); prima i metalli dei Guardiani.
## I Guardiani hanno in più `BOSS_TIME` per vigore: gli scontri crescono da un minuto a tre-quattro.
## Misure: `tools/percorso.gd` (appassimenti all'ora), `tools/armi.gd`, `tools/boss.gd`.

const HP_STEP := 1.3456                 # 1,16²: la Vita delle creature per ogni vigore
const DMG_STEP := 1.2                     # il danno delle creature per ogni vigore (tarato con `tools/percorso.gd`)
const SOFT := 11                         # oltre questo vigore la crescita rallenta (il dopo: la primambra arriva qui)
const HIGH_HP := 1.04
const HIGH_DMG := 1.03
const BOSS_TIME := 0.12                  # Vita dei Guardiani: +12% per vigore oltre a quella delle creature
const BOSS_TIME_MAX := 2.4


## La Vita delle creature in un mondo di questo vigore (1 = il primo mondo).
static func creature_hp(v: int) -> float:
	v = maxi(v, 1)
	return pow(HP_STEP, mini(v, SOFT) - 1) * pow(HIGH_HP, maxi(v - SOFT, 0))


## Il danno delle creature in un mondo di questo vigore.
static func creature_dmg(v: int) -> float:
	v = maxi(v, 1)
	return pow(DMG_STEP, mini(v, SOFT) - 1) * pow(HIGH_DMG, maxi(v - SOFT, 0))


## Quanto più a lungo dura uno scontro con un Guardiano di questo vigore.
static func boss_time(v: int) -> float:
	return minf(1.0 + BOSS_TIME * (maxi(v, 1) - 1), BOSS_TIME_MAX)


## La fase della Superficie di un mondo di questo vigore (0-23; gli strati ne aggiungono fino a 4).
static func phase_of_vigor(v: int) -> int:
	return clampi(2 * maxi(v, 1) - 1, 0, 23)


## La fase di un grado di metallo (1 radicite … 12 primambra).
static func phase_of_tier(t: int) -> int:
	return 0 if t <= 0 else clampi(2 * t - 1, 1, 23)


## Il filo che un metallo di questo grado dovrebbe avere (la verifica dei dati confronta).
static func filo_of_tier(t: int) -> float:
	return 9.0 * pow(HP_STEP, maxi(t, 1) - 1)


## **I metalli del Risveglio** (voce 363). Dopo il Risveglio del Cuore (voce 364) compaiono nelle rocce dei mondi
## abbastanza vigorosi, come i materiali dei geni: scavando le tessere `tiles` dallo strato `stratum` in giù, nei mondi
## di vigore da `vigor` (e fino a `KEEP` vigori dopo: poi c'è di meglio), con probabilità `chance`; e dalle creature
## antiche di quei mondi (`ancient`). Si fondono al Baccello ardente (3 grezzi, un lingotto) e danno tutta la famiglia
## di oggetti come ogni metallo (niente leghe: sarebbero centinaia di oggetti in più senza un gesto nuovo).
## Tessere: 3 ardesia, 5 legnoferro, 6 ambra, 8 radice gigante, 9 scisto, 10 vuotite (valori di `TileDefs`, scritti
## per esteso: i file di dati non nominano altre classi che si caricano dopo).
const KEEP := 4
const METALS := {
	"corallite": {"label": "di corallite", "short": "corallite", "tier": 7, "durezza": 95, "filo": 53, "peso": 9.0,
		"tenacia": 7.2, "conduzione": 12, "elemento": "linfa", "risonanza": 2, "icon": "corallite",
		"raw": {"id": "corallite_grezza", "name": "Corallite grezza", "shape": "minerale", "tiles": [3, 9], "stratum": 2,
			"vigor": 6, "chance": 0.05, "ancient": 0.5},
		"desc": "Cresce come un corallo nelle rocce bagnate di Linfa, dopo che il Cuore si è risvegliato."},
	"sanguinite": {"label": "di sanguinite", "short": "sanguinite", "tier": 8, "durezza": 105, "filo": 72, "peso": 12.0,
		"tenacia": 8.4, "conduzione": 7, "elemento": "brace", "risonanza": 1, "icon": "sanguinite",
		"raw": {"id": "sanguinite_grezza", "name": "Sanguinite grezza", "shape": "gemma", "tiles": [3, 9, 10], "stratum": 2,
			"vigor": 7, "chance": 0.045, "ancient": 0.5},
		"desc": "Una vena scura che pulsa: il Cuore risvegliato le manda il suo calore."},
	"cuorelegno": {"label": "di cuorelegno", "short": "cuorelegno", "tier": 9, "durezza": 115, "filo": 97, "peso": 14.0,
		"tenacia": 9.8, "conduzione": 9, "elemento": "spora", "risonanza": 2, "icon": "cuorelegno",
		"raw": {"id": "cuorelegno_grezzo", "name": "Nodo di cuorelegno", "shape": "zolla", "tiles": [8, 5], "stratum": 1,
			"vigor": 8, "chance": 0.12, "ancient": 0.5},
		"desc": "Il cuore delle radici giganti, duro come il ferro e ancora vivo."},
	"eterite": {"label": "d'eterite", "short": "eterite", "tier": 10, "durezza": 125, "filo": 130, "peso": 3.0,
		"tenacia": 10.5, "conduzione": 20, "elemento": "gelo", "risonanza": 3, "icon": "eterite",
		"raw": {"id": "eterite_grezza", "name": "Eterite grezza", "shape": "cristallo", "tiles": [9, 7], "stratum": 3,
			"vigor": 9, "chance": 0.045, "ancient": 0.5},
		"desc": "Un cristallo leggerissimo che si forma dove lo scisto tocca il Vuoto."},
	"astrite": {"label": "d'astrite", "short": "astrite", "tier": 11, "durezza": 135, "filo": 175, "peso": 6.0,
		"tenacia": 12.0, "conduzione": 18, "elemento": "luce", "risonanza": 3, "icon": "astrite",
		"raw": {"id": "astrite_grezza", "name": "Astrite grezza", "shape": "stella", "tiles": [10], "stratum": 4,
			"vigor": 10, "chance": 0.05, "ancient": 0.5},
		"desc": "Stelle cadute dentro la vuotite all'inizio del mondo, risvegliate dal Cuore."},
	"primambra": {"label": "di primambra", "short": "primambra", "tier": 12, "durezza": 150, "filo": 236, "peso": 8.0,
		"tenacia": 14.0, "conduzione": 24, "elemento": "luce", "risonanza": 3, "icon": "primambra",
		"raw": {"id": "primambra_grezza", "name": "Primambra", "shape": "gemma", "tiles": [6, 10], "stratum": 3,
			"vigor": 11, "chance": 0.04, "ancient": 0.5},
		"desc": "L'ambra della prima linfa, colata quando l'Albero-Madre era un seme."},
}

## Il carattere (`MaterialsData.TRAITS`) e il set (`SetsData`) dei metalli del Risveglio.
const TRAITS := {
	"corallite": {"regen": 0.10, "linfa_regen": 0.06},
	"sanguinite": {"damage": 0.05, "thorns": 4.0},
	"cuorelegno": {"defense": 2.0, "regen": 0.06},
	"eterite": {"atk_speed": 0.06, "run": 0.04},
	"astrite": {"luck": 0.06, "magic": 0.06},
	"primambra": {"damage": 0.04, "defense": 1.5, "halo": 0.1},
}
const SETS := {
	"corallite": {"name": "Barriera di corallo", "bonus": {"defense": 6, "regen": 1.3, "acqua": 0.5}},
	"sanguinite": {"name": "Sangue del Cuore", "bonus": {"damage": 1.12, "thorns": 12}},
	"cuorelegno": {"name": "Corteccia viva", "bonus": {"defense": 10, "regen": 1.25}},
	"eterite": {"name": "Passo d'etere", "bonus": {"atk_speed": 1.14, "run": 1.12, "jump": 1.1}},
	"astrite": {"name": "Cielo stellato", "bonus": {"magic": 1.18, "luck": 0.1, "defense": 6}},
	"primambra": {"name": "Prima luce", "bonus": {"damage": 1.12, "defense": 10, "halo": 1.3}},
}

## Il gesto di ogni metallo del Risveglio (`GesturesData.MATERIAL`, effetti «mat_…» in `EffectsData`).
const GESTURES := {
	"corallite": {"name": "Corallo che cresce", "fx": ["mat_corallite", "mat_corallite_b"], "mods": {"split": [3, 0.35], "homing": 2.0},
		"desc": "ogni colpo rende Vita e a volte fa crescere schegge di corallo attorno; i colpi a distanza si aprono in tre e cercano"},
	"sanguinite": {"name": "Sangue che bolle", "fx": ["mat_sanguinite", "mat_sanguinite_b"], "mods": {"boom": [2.5, 0.5], "pierce": 1},
		"desc": "spesso incendia e rende vulnerabile; i colpi a distanza attraversano e scoppiano"},
	"cuorelegno": {"name": "Radice che lega", "fx": ["mat_cuorelegno", "mat_cuorelegno_b"], "mods": {"bounce": 3},
		"desc": "spesso trattiene e avvelena; i colpi a distanza rimbalzano tre volte"},
	"eterite": {"name": "Etere che taglia", "fx": ["mat_eterite", "mat_eterite_b"], "mods": {"wave": 12.0, "speed": 1.4, "pierce": 2},
		"desc": "ogni terzo colpo un'onda gelida vola davanti; i colpi a distanza volano velocissimi e attraversano"},
	"astrite": {"name": "Costellazione", "fx": ["mat_astrite", "mat_astrite_b"], "mods": {"homing": 3.0, "split": [4, 0.3]},
		"desc": "ogni quarto colpo cade una pioggia di stelle e un fulmine salta su tre creature; i colpi a distanza inseguono e si aprono in quattro"},
	"primambra": {"name": "Prima luce", "fx": ["mat_primambra", "mat_primambra_b"], "mods": {"ret": 0.5, "boom": [3.0, 0.5]},
		"desc": "ogni colpo acceca un attimo e ogni quinto colpo esplode di luce; i colpi tornano indietro e scoppiano"},
}

## Il dono dei Guardiani dopo il Risveglio (voce 364): Vita per sempre, perché la Vita del Germogliato segua la spina.
const ITEMS := {
	"linfa_cuore": {"name": "Linfa del Cuore", "kind": "dono", "icon": ["cuore", "primambra"], "stack": 20,
		"gift": ["vita", 15], "gift_max": 12, "value": 400,
		"source": "i Guardiani dei mondi di vigore 5 e oltre, dopo il Risveglio del Cuore (due per Guardiano)",
		"desc": "Una goccia densa che il Cuore lascia quando torna a battere. Assorbila: +15 Vita massima, per sempre (fino a 12)."},
}

