class_name TrapsData
## Le trappole (voce 88, Roadmap 12). Solo dati: le regole in `Traps`. Pezzi da costruire che feriscono le creature (e
## il Germogliato sbadato, se "hurts"): si attivano da soli quando una creatura entra nella loro **area**, poi aspettano
## ("cool" secondi per creatura). Clic destro su una trappola la disarma e la riarma. Tre **gradi** come i totem.
##   area   "cella" (la tessera della trappola), "attorno" (entro "r" tessere), "sotto" ("r" tessere in giù),
##          "linea" (a destra e a sinistra entro "r" tessere, alla stessa altezza)
##   dmg    danno di base (× il grado)          elem   l'elemento del colpo (debolezze, stati, reazioni)
##   shot   tira un colpo verso la creatura (getti): "knock" = spinta
##   chill  rallenta (la rete) per questi secondi

const TIERS := [
	{"mat": "radicite", "name": "", "k": 1.0, "bar": "lingotto_radicite", "bars": 2},
	{"mat": "legnoferro", "name": " di legnoferro", "k": 1.7, "bar": "lingotto_legnoferro", "bars": 3},
	{"mat": "ambra", "name": " d'ambra", "k": 2.6, "bar": "lingotto_ambra", "bars": 4},
]

const TYPES := {
	"spuntoni": {"name": "Spuntoni", "area": "cella", "dmg": 8, "cool": 0.6, "hurts": true, "color": "#c8c0b0",
		"desc": "feriscono chi ci passa sopra (anche te)", "extra": {"aculeo": 3}},
	"lama": {"name": "Lama rotante", "area": "attorno", "r": 1.6, "dmg": 12, "cool": 0.45, "hurts": true, "color": "#e0e8f0",
		"desc": "gira e taglia tutto ciò che le passa accanto (anche te)", "extra": {"legno": 4}},
	"runa_brace": {"name": "Runa di brace", "area": "cella", "dmg": 9, "cool": 2.0, "elem": "brace", "color": "#ff7a3a",
		"desc": "una scarica di brace: la creatura brucia", "extra": {"polvere_brace": 3}},
	"runa_gelo": {"name": "Runa di gelo", "area": "cella", "dmg": 7, "cool": 2.0, "elem": "gelo", "color": "#8ad8ff",
		"desc": "una scarica di gelo: la creatura rallenta", "extra": {"vello_brina": 2}},
	"runa_spora": {"name": "Runa di spora", "area": "cella", "dmg": 7, "cool": 2.0, "elem": "spora", "color": "#b070f0",
		"desc": "una scarica di spore: la creatura si avvelena", "extra": {"sacca_spore": 2}},
	"runa_vuoto": {"name": "Runa del Vuoto", "area": "cella", "dmg": 7, "cool": 2.0, "elem": "vuoto", "color": "#8a50e0",
		"desc": "una scarica di Vuoto: la creatura diventa vulnerabile", "extra": {"scheggia_vuoto": 2}},
	"pressa": {"name": "Pressa di pietra", "area": "sotto", "r": 4, "dmg": 30, "cool": 3.0, "hurts": true, "color": "#8298bc",
		"desc": "cade su chi passa sotto (fino a 4 tessere) e schiaccia", "extra": {"ardesia": 20}},
	"getto_brace": {"name": "Getto di brace", "area": "linea", "r": 7, "dmg": 6, "cool": 1.0, "elem": "brace", "shot": true,
		"knock": 1.0, "color": "#ff9a4a", "desc": "sputa brace verso le creature in linea", "extra": {"polvere_brace": 4}},
	"getto_acqua": {"name": "Getto d'acqua", "area": "linea", "r": 8, "dmg": 1, "cool": 0.6, "shot": true, "knock": 7.0,
		"color": "#6ab4ff", "desc": "spinge via le creature in linea: per portarle dove vuoi", "extra": {"secchio": 1}},
	"rete": {"name": "Rete di radici", "area": "cella", "dmg": 0, "cool": 0.5, "chill": 3.0, "color": "#9fe070",
		"desc": "trattiene chi ci passa: rallenta molto", "extra": {"seta_radice": 4}},
}


const LEVER_R := 10                    # la Leva delle trappole arma e ferma quelle entro 10 tessere


static func id_of(type: String, tier: int) -> String:
	return "trappola_%s_%d" % [type, tier + 1]


## I dati di una trappola piazzata: {type, k} (vuoto se non è una trappola).
static func info(id: String) -> Dictionary:
	if not id.begins_with("trappola_"):
		return {}
	var parts := id.trim_prefix("trappola_").rsplit("_", true, 1)
	if parts.size() != 2 or not TYPES.has(parts[0]) or not parts[1].is_valid_int():
		return {}
	return {"type": parts[0], "k": float(TIERS[clampi(int(parts[1]) - 1, 0, TIERS.size() - 1)]["k"]), "tier": int(parts[1])}


static func is_trap(id: String) -> bool:
	return not info(id).is_empty()


static func items() -> Dictionary:
	var out := {"leva_trappole": {"name": "Leva delle trappole", "kind": "stazione", "icon": ["martello", "radicite"],
		"place": "leva_trappole_su", "stack": 20,
		"desc": "Clic destro: ferma o arma insieme tutte le trappole entro %d tessere." % LEVER_R}}
	for type in TYPES:
		var td: Dictionary = TYPES[type]
		for i in TIERS.size():
			var t: Dictionary = TIERS[i]
			out[id_of(type, i)] = {"name": String(td["name"]) + String(t["name"]), "kind": "stazione",
				"icon": ["trappola_" + type, String(t["mat"])],     # 8 ott 2026: la forma dipinta di ogni trappola
				"place": id_of(type, i), "stack": 50,
				"desc": "%s. Danno ×%.1f. Clic destro: disarma e riarma." % [String(td["desc"]).capitalize(), float(t["k"])]}
	return out


static func recipes() -> Array:
	var out := [{"out": "leva_trappole", "qty": 1, "in": {"lingotto_radicite": 1, "legno": 4}, "station": "ceppo"}]
	for type in TYPES:
		for i in TIERS.size():
			var t: Dictionary = TIERS[i]
			var need := {String(t["bar"]): int(t["bars"])}
			for k in TYPES[type].get("extra", {}):
				need[k] = int(TYPES[type]["extra"][k])
			out.append({"out": id_of(type, i), "qty": 2, "in": need, "station": "maglio" if i > 0 else "ceppo"})
	return out
