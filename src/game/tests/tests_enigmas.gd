class_name TestsEnigmas
extends RefCounted
## Prove degli enigmi (voce 71): gli otto luoghi costruiti nel mondo di prova, ognuno risolto come lo farebbe il
## giocatore (torce nei bracieri, leve secondo il codice del leggio, piastre, cristalli con l'arma dell'elemento giusto,
## parole della porta a glifi, chiave): ogni porta dei Seminatori si apre. Foto 133_enigma e 134_porta_aperta.

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func _c(v: Variant) -> Vector2i:
	return Vector2i(int(v[0]), int(v[1]))


func _open(e: Dictionary) -> bool:
	for d in e["porta"]:
		if world.tile(int(d[0]), int(d[1])) != TileDefs.AIR:
			return false
	return true


## Un'arma dell'elemento indicato (per i cristalli).
func _weapon_of(elem: String) -> String:
	var all := ItemsData.all()
	for id in all:
		var it: Dictionary = all[id]
		if String(it.get("kind", "")) == "spada" and String(Gear.stats({"id": String(id)})["elem"]).contains(elem):
			return String(id)
	return ""


func run() -> void:
	var mech: Mechanisms = m.mechanisms
	var built: Array = TestsPlaces.new(kit).build_row(PlacesData.PLACES.keys(), 70)
	for e in built:
		e["enigma"] = Mechanisms.make(e, world.world_seed)
	(m.world_meta["luoghi"] as Array).append_array(built)
	var b := kit.bisaccia()
	kit.make_room()
	var had_lingua: Dictionary = m.character.lingua.duplicate()
	var res := {}
	var obs: Dictionary = {}
	for e in built:
		if String(e["id"]) == "osservatorio":
			obs = e
	# la foto prima: l'osservatorio con i bracieri spenti e la porta chiusa
	m.boons.add("bagliore", 30.0)
	m.snap_to(Vector2i(int(obs["x"]) + 6, int(obs["y"]) + int(obs["h"]) - 3))
	await kit.seconds(1.0)
	await kit.save("133_enigma")
	for e in built:
		var en: Dictionary = e["enigma"]
		var tipo := String(en["tipo"])
		match tipo:
			"bracieri":
				b.add("torcia", 5)
				for k in e["mecc"]:
					mech.touch(_c(e["mecc"][k]), String(world.stations.get(_c(e["mecc"][k]), "")))
			"leve":
				for k in e["mecc"]:
					if bool(en["codice"][k]):
						mech.touch(_c(e["mecc"][k]), "leva")
			"piastre":
				var st := {}
				for k in e["mecc"]:
					mech.press(e, String(k), st)
			"cristalli":
				for k in e["mecc"]:
					var wid := _weapon_of(String(en["elementi"][k]))
					if wid != "":
						b.add(wid, 1)
						kit.hold(wid)
					mech.touch(_c(e["mecc"][k]), "cristallo_eco")
			"glifi":
				m.language.learn(en["parole"])
				mech.touch_door(_c(e["porta"][0]))
				m.language.panel.visible = false
			"chiave":
				mech.touch_door(_c(e["porta"][0]))           # senza chiave resta chiusa
				var closed_before := not _open(e)
				b.add("chiave_seminatori", 1)
				mech.touch_door(_c(e["porta"][0]))
				res["chiave_prima_chiusa"] = closed_before
		res[String(e["id"])] = _open(e)
	await kit.seconds(0.8)
	await kit.save("134_porta_aperta")
	m.snap_to(world.spawn)
	m.character.lingua = had_lingua
	var opened: int = PlacesData.PLACES.keys().filter(func(k: String) -> bool: return bool(res.get(k, false))).size()
	var lever_hint: String = mech.lore_extra(built[1])
	print("enigmi: porte aperte %d su %d %s; senza chiave resta chiusa %s; il leggio della serra scrive le leve %s" % [
		opened, built.size(), res, "sì" if res.get("chiave_prima_chiusa", false) else "NO",
		"sì" if lever_hint.contains("inciso") else "NO"])
	if opened != built.size() or not res.get("chiave_prima_chiusa", false) or not lever_hint.contains("inciso"):
		print("ATTENZIONE: gli enigmi dei Seminatori non funzionano come dovrebbero")
