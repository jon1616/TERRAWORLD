class_name DeepRulesData
## Le regole del profondo (voce 354, Roadmap 37, 4 ott 2026). L'utente, dopo sei ore: «il sottosuolo è poco stimolante,
## non si avverte nessun aumento di pericolo scendendo verso il fondo». Prima ogni strato era lo stesso gioco con numeri
## più alti (la forza delle creature da 1 a 1,9 volte, che l'armatura migliore pareggiava). Ora **ogni strato ha una
## regola sua**, che cambia il modo di muoversi, e **un materiale che esiste solo lì**, lasciato dalle sue creature rare.
## Campi di ogni strato (indice = `StrataData`):
##   name, desc   la regola, come la legge il giocatore (insegna entrando, riga sotto le scritte in alto)
##   hear         le creature sentono i rumori fino a tante volte più lontano (`Mind.hear_mult`)
##   rare         le creature rare nascono tante volte più spesso (`Fauna.try_spawn`)
##   pack, pack_n con questa probabilità una creatura comune nasce con [min, max] compagne della sua specie
##   ambush       {every: [s, s], n: [min, max], dist: [min, max]}: ogni tanto, al buio, un gruppo sbuca alle spalle
##                (`DeepRules`), annunciato da un fruscio e da un avviso un attimo prima
##   rigor, rate  un rigore (`HarshData`) che sale lontano dalle torce e dalle lampade posate (`DeepRules.lit_by_player`)
##   spawn_dark   (voce 354, misurato) la luce sotto cui si nasce in questo strato: funghi e cristalli rendono il profondo
##                luminoso quasi ovunque, e con la soglia comune (`DangerData.DARK`, 0,15) nelle Profondità e nel Fondo
##                nasceva quasi niente (3 punti buoni su 300 contro 98 nelle Caverne). La luce naturale non ripara: solo
##                le torce e le lampade posate (`DeepRules.lit_by_player`).
##   loot, loot_n, loot_common   il materiale dello strato: le rare ne lasciano [min, max] (le ancestrali il triplo), le
##                comuni uno con questa probabilità
## Uno strato nuovo = una riga qui.

const RULES := [
	{},
	{"name": "Le radici ascoltano", "color": "#ffb070",
		"desc": "Nel Sottobosco le creature sentono da lontano: correre, scavare e combattere le chiama.",
		"hear": 1.7, "rare": 1.05, "loot": "midollo_radice", "loot_n": [1, 2], "loot_common": 0.03},
	{"name": "Il buio caccia", "color": "#8298bc",
		"desc": "Nelle Caverne le creature girano in branchi, e ti sentono più lontano.",
		"hear": 1.4, "rare": 1.1, "pack": 0.35, "pack_n": [1, 2], "loot": "cuore_ardesia", "loot_n": [1, 2], "loot_common": 0.03},
	{"name": "Le imboscate della Linfa", "color": "#5cc8cc",
		"desc": "Lontano dalle tue torce qualcosa aspetta: a volte un gruppo sbuca alle tue spalle (un fruscio lo annuncia). La luce dei funghi non ripara.",
		"hear": 1.5, "rare": 1.15, "pack": 0.3, "pack_n": [1, 2],
		"ambush": {"every": [75, 130], "n": [2, 3], "dist": [9, 14]}, "spawn_dark": 0.6,
		"loot": "linfa_nera", "loot_n": [1, 2], "loot_common": 0.04},
	{"name": "Il Vuoto preme", "color": "#c08aff",
		"desc": "Nel Fondo, lontano da torce e lampade, il peso del Vuoto cresce (la barra): a barra piena la Vita non ricresce e fa male. Imboscate e creature scelte ovunque.",
		"hear": 1.6, "rare": 1.25, "pack": 0.4, "pack_n": [1, 3],
		"ambush": {"every": [55, 95], "n": [2, 4], "dist": [9, 13]}, "spawn_dark": 0.6,
		"rigor": "vuoto", "rate": 1.0 / 50.0,
		"loot": "frammento_vuoto", "loot_n": [1, 2], "loot_common": 0.05},
]


static func of(stratum: int) -> Dictionary:
	return RULES[clampi(stratum, 0, RULES.size() - 1)]


## I materiali del profondo e ciò che se ne fa subito (la voce 355 li usa anche per risvegliare le armi).
const ITEMS := {
	"midollo_radice": {"name": "Midollo di radice", "kind": "materiale", "icon": ["radice", "radice"], "stack": 999,
		"desc": "Il cuore morbido delle radici del Sottobosco: lo lasciano le sue creature rare. Ascolta ancora.",
		"source": "le creature rare del Sottobosco di radici (e qualche volta le altre)"},
	"cuore_ardesia": {"name": "Cuore d'ardesia", "kind": "materiale", "icon": ["gemma", "ardesia"], "stack": 999,
		"desc": "Una pietra che batte piano, dal buio delle Caverne d'ardesia.",
		"source": "le creature rare delle Caverne d'ardesia (e qualche volta le altre)"},
	"linfa_nera": {"name": "Linfa nera", "kind": "materiale", "icon": ["goccia", "vuotite"], "stack": 999,
		"desc": "Linfa che non brilla: viene dalle Profondità, dove la luce non arriva.",
		"source": "le creature rare delle Profondità della Linfa (e qualche volta le altre)"},
	"frammento_vuoto": {"name": "Frammento di Vuoto", "kind": "materiale", "icon": ["scaglia", "vuotite"], "stack": 999,
		"desc": "Un pezzo di niente, freddo in mano. Solo nel Fondo.",
		"source": "le creature rare del Fondo (e qualche volta le altre)"},
	"calzari_muti": {"name": "Calzari di radice muta", "kind": "accessorio", "icon": ["stivali", "radice"], "stack": 1,
		"acc": {"stealth": 0.75}, "desc": "Le creature ti sentono e ti vedono molto più tardi: passi senza rumore."},
	"lanterna_ardesia": {"name": "Cuore-lanterna d'ardesia", "kind": "accessorio", "icon": ["amuleto", "ardesia"], "stack": 1,
		"acc": {"halo": 1.35, "defense": 2}, "desc": "Alone più ampio e +2 Scorza: il cuore della pietra fa un po' di luce."},
	"tonico_nero": {"name": "Tonico di Linfa nera", "kind": "consumabile", "icon": ["pozione", "vuotite"], "stack": 30,
		"heal": 30, "boon": ["riparo_vuoto", 300],
		"desc": "Cura 30 e per cinque minuti il peso del Vuoto non ti tocca."},
	"amuleto_quiete": {"name": "Amuleto della quiete", "kind": "accessorio", "icon": ["amuleto", "vuotite"], "stack": 1,
		"acc": {"quieto": 0.7, "linfa_regen": 1.1}, "desc": "Il peso del Vuoto sale molto più piano (protezione 70%); Linfa un poco più svelta."},
}

const RECIPES := [
	{"out": "calzari_muti", "qty": 1, "in": {"midollo_radice": 8, "seta_radice": 6, "lingotto_legnoferro": 3}, "station": "telaio"},
	{"out": "lanterna_ardesia", "qty": 1, "in": {"cuore_ardesia": 6, "lingotto_ambra": 3, "fungo_luminoso": 4}, "station": "maglio"},
	{"out": "tonico_nero", "qty": 2, "in": {"linfa_nera": 2, "fungo_luminoso": 2, "gelatina": 1}, "station": "alambicco"},
	{"out": "amuleto_quiete", "qty": 1, "in": {"frammento_vuoto": 8, "linfa_nera": 4, "lingotto_ambra": 4}, "station": "maglio"},
]


static func items() -> Dictionary:
	return ITEMS.duplicate(true)


static func recipes() -> Array:
	return RECIPES.duplicate(true)
