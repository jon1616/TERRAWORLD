class_name FarmData
## Le farm (voce 89, Roadmap 12). Solo dati: le regole in `Farms`. I pezzi si danno al giocatore, la farm la progetta
## lui (scelta dell'utente): niente farm già pronte.
##   esche        una casella: ci si posa un pezzo di bottino e l'esca chiama le creature che lo lasciano (se vivono
##                in quello strato), entro `r` tessere, al buio, lontano dalle torce e da te; consuma un'esca ogni
##                `per` creature; tetto di creature chiamate vive insieme
##   tramogge     casse che aspirano gli oggetti caduti entro `r` tessere
##   ancora       la Radice-ancora tiene viva la farm anche quando sei lontano (creature, trappole, esche)
##   nastri       spingono gli oggetti caduti a destra o a sinistra (clic destro: cambia verso)
## Il tetto di rendita: in ogni zona di `ZONE` tessere, al più `ZONE_CAP` creature chiamate lasciano bottino ogni
## `ZONE_TIME` secondi; oltre, la zona è «stanca» e lasciano solo qualche Lumino. Resta un gioco, non un rubinetto.

const BAITS := {
	"esca": {"name": "Esca di radice", "r": 10, "every": 10.0, "cap": 4, "per": 3, "mat": "radicite",
		"in": {"lingotto_radicite": 2, "legno": 6, "lumino": 10}, "station": "ceppo"},
	"esca_legnoferro": {"name": "Esca di legnoferro", "r": 13, "every": 7.0, "cap": 6, "per": 4, "mat": "legnoferro",
		"in": {"lingotto_legnoferro": 3, "legno": 6, "lumino": 25}, "station": "maglio"},
	"esca_ambra": {"name": "Esca d'ambra", "r": 16, "every": 5.0, "cap": 8, "per": 5, "mat": "ambra",
		"in": {"lingotto_ambra": 3, "legno": 6, "lumino": 50}, "station": "maglio"},
}

const HOPPERS := {
	"tramoggia": {"name": "Tramoggia di radice", "r": 6, "slots": 20, "mat": "radicite",
		"in": {"lingotto_radicite": 3, "legno": 10}, "station": "ceppo"},
	"tramoggia_ambra": {"name": "Tramoggia d'ambra", "r": 10, "slots": 40, "mat": "ambra",
		"in": {"lingotto_ambra": 3, "tramoggia": 1}, "station": "maglio"},
}

const ANCHOR_R := 24                   # la Radice-ancora tiene viva la farm entro 24 tessere
const BELT_SPEED := 70.0               # px/s dei nastri
const AWAY := 14                       # le creature chiamate non nascono entro 14 tessere da te
const TORCH := 8.0                     # né entro 8 tessere da una torcia
const ZONE := 64
const ZONE_CAP := 60
const ZONE_TIME := 600.0


static func is_bait(id: String) -> bool:
	return BAITS.has(id)


static func is_hopper(id: String) -> bool:
	return HOPPERS.has(id)


static func items() -> Dictionary:
	var out := {}
	for id in BAITS:
		var b: Dictionary = BAITS[id]
		out[id] = {"name": b["name"], "kind": "stazione", "icon": ["trappola_esca", String(b["mat"])], "place": id, "stack": 20,
			"desc": "Posaci un pezzo di bottino: chiama le creature che lo lasciano entro %d tessere (una ogni %d s, al più %d insieme)." % [
				int(b["r"]), int(b["every"]), int(b["cap"])]}
	for id in HOPPERS:
		var h: Dictionary = HOPPERS[id]
		out[id] = {"name": h["name"], "kind": "stazione", "icon": ["trappola_tramoggia", String(h["mat"])], "place": id, "stack": 20,
			"desc": "Una cassa da %d caselle che aspira gli oggetti caduti entro %d tessere." % [int(h["slots"]), int(h["r"])]}
	out["radice_ancora"] = {"name": "Radice-ancora", "kind": "stazione", "icon": ["torcia", "legnoferro"], "place": "radice_ancora",
		"stack": 10, "desc": "Tiene viva la farm entro %d tessere anche quando sei lontano: creature, trappole ed esche." % ANCHOR_R}
	out["nastro"] = {"name": "Nastro di radici", "kind": "stazione", "icon": ["piattaforma", "radicite"], "place": "nastro_dx",
		"stack": 99, "desc": "Spinge gli oggetti caduti. Clic destro: cambia verso."}
	return out


static func recipes() -> Array:
	var out := []
	for tb in [BAITS, HOPPERS]:
		for id in tb:
			out.append({"out": id, "qty": 1, "in": tb[id]["in"], "station": tb[id]["station"]})
	out.append({"out": "radice_ancora", "qty": 1, "in": {"lingotto_legnoferro": 5, "cristallo_linfa": 2, "legno": 10}, "station": "maglio"})
	out.append({"out": "nastro", "qty": 6, "in": {"lingotto_radicite": 1, "legno": 3}, "station": "ceppo"})
	return out
