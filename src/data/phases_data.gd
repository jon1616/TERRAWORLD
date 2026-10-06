class_name PhasesData
## Le fasi della partita e le rarità (voce 357, Roadmap 38; piano in `VASTITA.md`). In Terraria ogni oggetto sta in un
## punto preciso della spina dei boss, e il colore del nome dice subito «quanto vale e quando arriva». Qui la **fase**
## di ogni oggetto (0-23, la spina della partita della Roadmap 39) si **calcola dai dati**, come fa lo strumento dei
## dati di Terraria: dal materiale, poi dalle ricette (un oggetto non viene prima dei suoi ingredienti), poi da chi lo
## lascia (strato delle creature, Guardiano del vigore). Un campo `fase` nell'oggetto vince su tutto.
## La **rarità** (12 colori) viene dalla fase, due fasi per rarità; gli unici e le leggende hanno il loro colore.
## Le fasi dei metalli e degli strati sono provvisorie finché la Roadmap 39 non scrive la spina (24 fasi, 16 metalli).

## Le fasi: [nome, che cosa la chiude] (per il Diario della spina e lo strumento della vastità).
const PHASES := [
	["Il Giardino", "il primo Seme"], ["Le prime radici", "la radicite"], ["Il Sottobosco", "il Nodo Avvizzito"],
	["Le Caverne", "il legnoferro"], ["Il legnoferro", "la Regina delle Spore"], ["Le spore", "le Profondità"],
	["Le Profondità", "il Colosso d'Ardesia"], ["L'ambra", "l'ambra fossile"], ["Il Fondo", "il Risveglio del Cuore"],
	["Il Cuore risvegliato", "la Linfa cristallina"], ["I mondi vivi", "i Giardini perduti"], ["La Linfa", "il Giardino sommerso"],
	["Il Giardino di ferro", "il cielo alto"], ["Il cielo alto", "il Giardino selvatico"], ["Il Giardino selvatico", "la vuotite"],
	["La vuotite", "il Giardino muto"], ["Il Giardino muto", "la Radice del cosmo"], ["Le radici del cosmo", "le stelle"],
	["Le stelle", "il Seme Nero"], ["Il Seme Nero", "il Primo Mondo"], ["Il Primo Mondo", "l'Albero Antico"],
	["L'Albero Antico", "l'ultimo Seminatore"], ["L'ultimo Seminatore", "il Seme Primo"], ["Il dopo", ""],
]

## Le rarità: [nome, colore]. Indice = fase / 2.
const RARITIES := [
	["Comune", "#cfc8bc"], ["Germoglio", "#9fe070"], ["Radice", "#d8a070"], ["Muschio", "#5ee0c8"],
	["Ardesia", "#8eb4ff"], ["Ambra", "#ffb84a"], ["Brace", "#ff7a4a"], ["Linfa", "#5cf0e8"],
	["Vuoto", "#c08aff"], ["Stelle", "#fff08a"], ["Cosmo", "#ff86c8"], ["Primo", "#ffffff"],
]
const UNIQUE := ["Unico", "#ffd24a"]

## Provvisorie fino alla Roadmap 39: la fase di ogni grado di metallo, di ogni strato (creature) e di ogni vigore.
const TIER_PHASE := {0: 0, 1: 1, 2: 4, 3: 7, 4: 11, 5: 15, 6: 19}
const STRATUM_PHASE := [0, 2, 4, 6, 8]
const VIGOR_PHASE := {1: 3, 2: 5, 3: 8}

static var _memo := {}


## La fase di un oggetto (0-23).
static func of(id: String) -> int:
	if _memo.has(id):
		return int(_memo[id])
	_memo[id] = 0                             # (contro i giri: un oggetto che si fa da sé)
	var f := _compute(id)
	_memo[id] = f
	return f


static func _compute(id: String) -> int:
	var it := ItemsData.get_item(id)
	if it.is_empty():
		return 0
	if it.has("fase"):
		return int(it["fase"])
	if it.has("mat"):
		return int(TIER_PHASE.get(int(MaterialsData.get_mat(String(it["mat"])).get("tier", 1)), 1))
	if it.has("tier"):
		return int(TIER_PHASE.get(clampi(int(it["tier"]), 0, 6), 1))
	var best := 99
	# dalle ricette: la più presto tra le ricette, e ognuna non prima del suo ingrediente più avanzato
	for r in RecipesData.making(id):
		var top := 0
		for k in (r["in"] as Dictionary):
			top = maxi(top, of(String(k)))
		best = mini(best, top)
	# da chi lo lascia: lo strato più alto in cui vive la creatura più facile da trovare
	var from := _drop_phase(id)
	best = mini(best, from)
	return best if best < 99 else 0


static var _drops := {}


static func _drop_phase(id: String) -> int:
	if _drops.is_empty():
		_build_drops()
	return int(_drops.get(id, 99))


static func _build_drops() -> void:
	_drops["__"] = 0
	var guard := {}
	for i in GuardiansData.LIST.size():
		guard[String(GuardiansData.LIST[i]["creature"])] = int(VIGOR_PHASE.get(i + 1, 8))
	for cid in CreaturesData.CREATURES:
		var cd: Dictionary = CreaturesData.CREATURES[cid]
		var p := 0
		if guard.has(cid):
			p = int(guard[cid])
		else:
			var st: Array = cd.get("strata", [0])
			var low := 4
			for s in st:
				low = mini(low, int(s))
			p = int(STRATUM_PHASE[clampi(low, 0, 4)])
			if cd.get("boss", false):
				p += 2
		for e in LootData.TABLES.get(String(cd.get("loot", "")), []):
			var item := String(e["item"])
			_drops[item] = mini(int(_drops.get(item, 99)), p)


## La rarità di un oggetto: [nome, Color].
static func rarity(id: String) -> Array:
	var it := ItemsData.get_item(id)
	if it.get("unique", false):
		return [UNIQUE[0], Color(UNIQUE[1])]
	var r: Array = RARITIES[clampi(of(id) / 2, 0, RARITIES.size() - 1)]
	return [r[0], Color(r[1])]


static func phase_name(f: int) -> String:
	return String(PHASES[clampi(f, 0, PHASES.size() - 1)][0])
