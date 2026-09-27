class_name ZonesData
## Totem, stendardi e altari: gli oggetti di zona (voce 87, Roadmap 12). Solo dati: le regole in `Zones`.
## Ogni **tipo** dà un effetto in un raggio attorno a sé; i **gradi** (legno e radicite, legnoferro, ambra) allargano
## il raggio e rafforzano l'effetto. Due totem dello stesso tipo non si sommano: vale il più forte che ti copre.
## I tipi con "costo" sono **scambi**: un bonus e un malus insieme. Alcuni si trovano solo (`FOUND`, nelle rovine).
##
## Chiavi dell'effetto ("fx"), lette da chi le usa:
##   crescita   le colture crescono × (`Garden`)             rigenera  la Vita ricresce × (`Vitals.zone_regen`)
##   fortuna    fortuna in più per il bottino (`Fauna.kill`)  quiete    niente creature nascono qui (`Fauna.try_spawn`)
##   guardia    le creature qui prendono danno × (`Combat`)   rare      creature rare × (`Fauna`)
##   pericolo   pericolo in più (creature più forti e più numerose qui)    bottino   giri di bottino in più (`Fauna.kill`)
##   forza      Vita e danno delle creature nate qui ×        puro      l'Avvizzimento qui non si allarga (`Blight`)
##   esca       le creature di una famiglia nascono qui (voce 89: le farm)
##   riparo     voce 93: i rigori delle terre estreme non salgono (`Harshness`)

const TIERS := [
	{"mat": "radicite", "name": "", "r": 10, "k": 1.0, "bar": "lingotto_radicite", "bars": 3},
	{"mat": "legnoferro", "name": " di legnoferro", "r": 16, "k": 1.5, "bar": "lingotto_legnoferro", "bars": 4},
	{"mat": "ambra", "name": " d'ambra", "r": 24, "k": 2.0, "bar": "lingotto_ambra", "bars": 5},
]

## fx con il grado: "valore base" e "passo" per grado (grado 1 = base, 2 = base + passo…).
const TYPES := {
	"germoglio": {"name": "Totem del germoglio", "icon": "torcia", "color": "#7ed67a", "fx": {"crescita": [1.4, 0.3]},
		"desc": "le colture attorno crescono più in fretta", "extra": {"seme_lanterna": 2}},
	"riposo": {"name": "Stendardo del riposo", "icon": "velo", "color": "#ff86c8", "fx": {"rigenera": [1.6, 0.4]},
		"desc": "la Vita ricresce più in fretta qui", "extra": {"seta_radice": 4}},
	"fortuna": {"name": "Altarino della fortuna", "icon": "altare", "color": "#ffd24a", "fx": {"fortuna": [0.1, 0.08]},
		"desc": "le creature sconfitte qui lasciano più bottino", "extra": {"brillaluce": 1}},
	"luce": {"name": "Lanterna-totem", "icon": "lanterna", "color": "#fff08a", "fx": {}, "light": true,
		"desc": "una luce forte e ferma: nel buio vero illumina un bel tratto", "extra": {"torcia": 6}},
	"quiete": {"name": "Totem della quiete", "icon": "torcia", "color": "#8ef0d8", "fx": {"quiete": [1.0, 0.0]},
		"desc": "attorno non nasce nessuna creatura", "extra": {"cristallo_linfa": 2}},
	"guardia": {"name": "Stendardo di guardia", "icon": "velo", "color": "#ff6f5e", "fx": {"guardia": [1.15, 0.1]},
		"desc": "le creature qui prendono più danno", "extra": {"aculeo": 4}},
	"rifugio": {"name": "Rifugio del viandante", "icon": "lanterna", "color": "#ffd8a0", "fx": {"riparo": [1.0, 0.0]},
		"desc": "attorno i rigori delle terre estreme non si sentono (freddo, sete, calore, polvere)", "extra": {"cristallo_linfa": 2}},
	# scambi: un bonus e un malus insieme
	"stirpi": {"name": "Altare delle stirpi", "icon": "altare", "color": "#c890ff", "cost": true,
		"fx": {"rare": [2.5, 1.0], "pericolo": [0.5, 0.25]},
		"desc": "creature rare molto più spesso, ma tutte più pericolose", "extra": {"lumino": 30}},
	"saccheggio": {"name": "Stendardo del saccheggio", "icon": "velo", "color": "#e0c080", "cost": true,
		"fx": {"bottino": [1.0, 0.0], "forza": [1.3, 0.15]},
		"desc": "un giro di bottino in più, ma le creature nascono più forti", "extra": {"lumino": 25}},
	"purezza": {"name": "Totem della radice pura", "icon": "torcia", "color": "#9fe070", "cost": true,
		"fx": {"puro": [1.0, 0.0], "crescita": [0.0, 0.0]},
		"desc": "qui l'Avvizzimento non si allarga, ma niente cresce", "extra": {"seme_muschio": 3}},
}

## I totem che si trovano soltanto: nelle rovine del profondo (tabelle «rovina_3» e «rovina_4»), più forti del grado 3.
const FOUND := {
	"totem_antico_germoglio": {"name": "Totem antico del germoglio", "type": "germoglio", "r": 34, "k": 3.0},
	"totem_antico_quiete": {"name": "Totem antico della quiete", "type": "quiete", "r": 40, "k": 1.0},
	"totem_antico_stirpi": {"name": "Altare antico delle stirpi", "type": "stirpi", "r": 30, "k": 3.0},
}

const MAX_R := 40


static func id_of(type: String, tier: int) -> String:
	return "totem_%s_%d" % [type, tier + 1]


## I dati di un totem piazzato: {type, r, k} (vuoto se non è un totem).
static func info(id: String) -> Dictionary:
	if FOUND.has(id):
		return FOUND[id]
	if not id.begins_with("totem_"):
		return {}
	var parts := id.trim_prefix("totem_").rsplit("_", true, 1)
	if parts.size() != 2 or not TYPES.has(parts[0]) or not parts[1].is_valid_int():
		return {}
	var t: Dictionary = TIERS[clampi(int(parts[1]) - 1, 0, TIERS.size() - 1)]
	return {"type": parts[0], "r": int(t["r"]), "k": float(t["k"]), "tier": int(parts[1])}


static func is_totem(id: String) -> bool:
	return not info(id).is_empty()


## Il valore di un effetto per un totem di questo grado ("k": 1 = grado 1, 1,5 = grado 2, 2 = grado 3, 3 = antico).
static func value(type: String, key: String, k: float) -> float:
	var f: Array = TYPES[type]["fx"].get(key, [])
	if f.is_empty():
		return 0.0
	return float(f[0]) + float(f[1]) * (k - 1.0) * 2.0


static func items() -> Dictionary:
	var out := {}
	for type in TYPES:
		var td: Dictionary = TYPES[type]
		for i in TIERS.size():
			var t: Dictionary = TIERS[i]
			out[id_of(type, i)] = {"name": String(td["name"]) + String(t["name"]), "kind": "stazione",
				"icon": [String(td["icon"]), String(t["mat"])], "place": id_of(type, i), "stack": 20,
				"desc": "%s (raggio %d tessere)." % [String(td["desc"]).capitalize(), int(t["r"])]}
	for id in FOUND:
		var fd: Dictionary = FOUND[id]
		out[id] = {"name": fd["name"], "kind": "stazione", "icon": [String(TYPES[fd["type"]]["icon"]), "brillaluce"],
			"place": id, "stack": 5, "source": "le rovine dei Seminatori nel profondo",
			"desc": "%s (raggio %d tessere). Più forte di qualunque totem che si fabbrica." % [
				String(TYPES[fd["type"]]["desc"]).capitalize(), int(fd["r"])]}
	return out


static func recipes() -> Array:
	var out := []
	for type in TYPES:
		for i in TIERS.size():
			var t: Dictionary = TIERS[i]
			var need := {String(t["bar"]): int(t["bars"]), "legno": 6}
			for k in TYPES[type].get("extra", {}):
				need[k] = int(TYPES[type]["extra"][k]) * (i + 1)
			out.append({"out": id_of(type, i), "qty": 1, "in": need, "station": "maglio" if i > 0 else "ceppo"})
	return out
