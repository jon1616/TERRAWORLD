class_name FlightData
## Il volo (voce 90, Roadmap 12). Solo dati: le regole in `Player._step` (volo) e `Flight` (ali indossate, barra,
## disegno). Le ali si indossano nel posto del **mantello**: o un mantello di metallo o le ali, una scelta.
## Quattro valori:
##   speed     velocità in orizzontale mentre si vola (× la corsa)
##   rise      salita in px/s tenendo Salto dopo il salto
##   time      autonomia in secondi (la barra); in un mondo leggero dura di più (consumo × il peso)
##   recharge  quanta barra torna ogni secondo a terra (1 = piena in un secondo); nelle correnti ascensionali il doppio
## Le prime (Ali di foglia, a metà gioco: scelta dell'utente) sono **deboli**: poco più di un lungo salto. Poi i gradi
## dei biomi e del profondo, fino alle stellari: un volo vero. Finita la barra si cade: la planata e il rampino restano
## utili per scendere e agganciarsi.

## Roadmap 43, voce 385: più le ali dei pacchetti (campo «wings», con le loro abilità in «effects»).
static var WINGS: Dictionary = _WINGS.merged(BiomesData.pack("wings"))

const _WINGS := {
	"ali_foglia": {"name": "Ali di foglia", "speed": 1.05, "rise": 90.0, "time": 0.5, "recharge": 0.9, "mat": "muschio",
		"color": "#7ed67a", "in": {"foglia_planante": 1, "seta_radice": 8, "lingotto_legnoferro": 4}, "station": "maglio",
		"desc": "Tenendo Salto dopo il salto si sale ancora un poco: più un lungo salto che un volo."},
	"ali_nuvola": {"name": "Ali di nuvola", "speed": 1.08, "rise": 115.0, "time": 0.7, "recharge": 1.0, "mat": "nuvola",
		"color": "#e4eefa", "in": {"ali_foglia": 1, "nuvola": 30, "cristallo_celeste": 3}, "station": "maglio",
		"desc": "Fatte con le nuvole del cielo basso: leggere, e nelle correnti si ricaricano in un attimo."},
	"ali_brina": {"name": "Ali di brina", "speed": 1.12, "rise": 140.0, "time": 0.9, "recharge": 0.9, "mat": "brina",
		"color": "#bfe8ff", "in": {"ali_foglia": 1, "piuma_gelo": 6, "vello_brina": 4}, "station": "maglio",
		"desc": "Piume di gelo dei Boschi di brina: un volo breve ma vero."},
	"ali_brace": {"name": "Ali di brace", "speed": 1.2, "rise": 170.0, "time": 1.2, "recharge": 1.0, "mat": "brace",
		"color": "#ff9a4a", "in": {"ali_foglia": 1, "squama_brace": 6, "cenere_viva": 4, "lingotto_ambra": 3}, "station": "maglio",
		"desc": "Squame di salamandra delle Cenerarie: salgono svelte sull'aria calda."},
	"ali_vuoto": {"name": "Ali del Vuoto", "speed": 1.3, "rise": 200.0, "time": 1.8, "recharge": 1.1, "mat": "vuotite",
		"color": "#b070ff", "in": {"ali_brina": 1, "scheggia_vuoto": 12, "cristallo_linfa": 4}, "station": "maglio",
		"desc": "Fatte del nulla del Fondo: lunghe, silenziose."},
	"ali_tempesta": {"name": "Ali della tempesta", "speed": 1.38, "rise": 225.0, "time": 2.3, "recharge": 1.3, "mat": "folgorite",
		"color": "#c0d0ff", "in": {"ali_nuvola": 1, "cuore_tempesta": 1, "vento_imprigionato": 10}, "station": "maglio",
		"desc": "Il vento dell'Occhio della Tempesta, cucito in due ali: lunghe e svelte."},
	"ali_stellari": {"name": "Ali stellari", "speed": 1.45, "rise": 240.0, "time": 2.8, "recharge": 1.5, "mat": "brillaluce",
		"color": "#fff08a", "in": {"ali_vuoto": 1, "polvere_iridata": 6, "brillaluce": 4}, "station": "maglio",
		"desc": "Il volo dei Seminatori: alto, lungo, veloce."},
}

## Roadmap 16, voce 165: il volo delle cavalcature che volano (campo `mount_wings` della mandria): non sono oggetti,
## non si disegnano sul Germogliato (vola la creatura sotto di lui).
const MOUNT_WINGS := {
	"balena": {"name": "In sella alla Balena delle stelle", "speed": 1.0, "rise": 150.0, "time": 4.0, "recharge": 0.8,
		"mat": "stelle", "color": "#6a78c0", "hidden": true},
}

const CURRENT_RECHARGE := 2.0          # nelle correnti ascensionali la barra torna il doppio


static func get_wings(id: String) -> Dictionary:
	return WINGS.get(id, MOUNT_WINGS.get(id, {}))


static func items() -> Dictionary:
	var out := {}
	for id in WINGS:
		var w: Dictionary = WINGS[id]
		out[id] = {"name": w["name"], "kind": "mantello", "icon": ["ali", String(w["mat"])], "wings": id,
			"desc": "%s Salita %d, autonomia %s s, velocità in volo ×%s." % [w["desc"], int(w["rise"]),
				String.num(float(w["time"]), 2), String.num(float(w["speed"]), 2)]}
		if w.has("effects"):
			out[id]["effects"] = (w["effects"] as Array).duplicate()     # voce 385: l'abilità in volo
	return out


static func recipes() -> Array:
	var out := []
	for id in WINGS:
		out.append({"out": id, "qty": 1, "in": WINGS[id]["in"], "station": WINGS[id]["station"]})
	# le Ali del Vuoto nascono anche dalle ali di brace: il bioma scelto non chiude la strada
	out.append({"out": "ali_vuoto", "qty": 1, "in": {"ali_brace": 1, "scheggia_vuoto": 12, "cristallo_linfa": 4}, "station": "maglio"})
	return out


## Il riassunto dei quattro valori (schede ed Enciclopedia).
static func line(id: String) -> String:
	var w: Dictionary = WINGS.get(id, {})
	if w.is_empty():
		return ""
	return "salita %d px/s · autonomia %s s · velocità ×%s · ricarica %s al secondo" % [int(w["rise"]),
		String.num(float(w["time"]), 2), String.num(float(w["speed"]), 2), String.num(float(w["recharge"]), 1)]
