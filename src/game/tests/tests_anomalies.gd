class_name TestsAnomalies
extends RefCounted
## Prove dei segreti della voce 97: nel mondo di prova ci sono le quattro camere-enigma (luoghi con porta e tre
## meccanismi) e le visioni; risolvendo una camera la porta si apre; entrando in una visione si legge; i mondi hanno
## un'anomalia (su più semi: almeno tre tipi diversi); le creature nascoste escono solo con la loro condizione.
## Foto 169_visione.

var kit: TestKit
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


## I mondi che la prova genera (sei mondi più stretti: bastano per contare le anomalie; li prepara il giro intero).
static func jobs() -> Array:
	var out := []
	for k in 6:
		out.append([1500 + k, 1600, WorldGen.HEIGHT, {"vigore": 2, "geni": ["lanterna"]}])
	return out


func run() -> void:
	var res := {}
	var w: World = m.world
	var se: Secrets = m.secrets
	var kinds := {}
	for s in se.list:
		kinds[s["k"]] = int(kinds.get(s["k"], 0)) + 1
	res["camere"] = int(kinds.get("camera_enigma", 0)) >= 3
	res["visioni"] = int(kinds.get("visione", 0)) >= 2
	print("segreti della voce 97 nel mondo di prova: %s" % kinds)
	# una camera: si risolve (i meccanismi messi a posto) e la porta si apre
	var cam: Dictionary = {}
	for e in m.places.list():
		if String(e["id"]) == "camera_bracieri":
			cam = e
	if cam.is_empty():
		print("ATTENZIONE: nessuna Camera dei bracieri nel mondo di prova")
		res["camera_si_apre"] = false
	else:
		for k in cam["mecc"]:
			var o: Vector2i = Vector2i(int(cam["mecc"][k][0]), int(cam["mecc"][k][1]))
			m.mechanisms._set_st(o, "braciere_acceso")
		m.mechanisms.check(cam)
		var door_open := true
		for d in cam["porta"]:
			door_open = door_open and w.tile(int(d[0]), int(d[1])) == TileDefs.AIR
		res["camera_si_apre"] = cam["enigma"].get("risolto", false) and door_open
	# una visione
	for s in se.list:
		if String(s["k"]) == "visione" and not s.get("f", false):
			m.snap_to(Secrets.rect_of(s).get_center())
			m.boons.add("bagliore", 3.0)
			await kit.seconds(0.6)
			res["visione_letta"] = s.get("f", false) and m.language.panel.visible
			await kit.save("169_visione")
			m.language.panel.hide()
			break
	# le anomalie su più semi
	var worlds: Array[World] = await kit.gen_many(jobs())
	var seen := {}
	var with := 0
	for ww in worlds:
		var an: Array = ww.gen_notes.get("anomalie", [])
		if not an.is_empty():
			with += 1
			seen[String(an[0][4])] = true
	res["anomalie"] = with >= 3 and seen.size() >= 2
	print("anomalie in 6 mondi: %d, tipi %s" % [with, seen.keys()])
	# le creature nascoste: con la condizione sì, senza no
	m.fauna.clear()
	m.snap_to(w.spawn)
	await kit.seconds(0.3)
	var rng := RandomNumberGenerator.new()
	var none := HiddenCreatures.try_spawn(m, rng, true)          # mezzogiorno, sereno, in superficie: nessuna condizione
	var t0: float = m.day.time
	m.day.time = 0.95                                            # notte fonda
	await kit.seconds(0.2)
	var one := HiddenCreatures.try_spawn(m, rng, true)
	res["nascoste"] = none == null and one != null
	m.day.time = t0
	m.fauna.clear()
	var bad := res.keys().filter(func(k: String) -> bool: return not res[k])
	print("camere, visioni, anomalie, nascoste: %s; non vanno: %s" % [res, bad])
	if not bad.is_empty():
		print("ATTENZIONE: i segreti della voce 97 non funzionano come dovrebbero")
