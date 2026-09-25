class_name Portal
extends Node
## Il Seme di mondo e i portali (voci 8 e 12); i clic li smista `Interact`.
## Il Seme si pianta sul terreno: cresce un arco di radici con un vortice di Linfa. Toccandolo (clic destro) si salva e
## si passa al mondo nato da quel seme, con un **vigore** in più (creature e Guardiano più forti, minerali più ricchi):
## la prima volta viene generato, poi si torna sempre allo stesso. Nel mondo nuovo, accanto alla partenza, nasce un
## **portale di ritorno** verso il mondo da cui si è venuti.
## Ogni portale ha la sua destinazione in `world_meta["portali"]`: "x,y" → {"mondo": id ("" = da creare),
## "seme": int, "ritorno": bool}. Il seme del mondo nuovo nasce dal seme di questo mondo e dall'angolo del portale:
## stesso portale, stesso mondo, su ogni computer.
## Più avanti (Roadmap 2) i semi avranno specie e tratti, e si pianteranno nelle Aiuole del Giardino.

const GAME_SCENE := "res://src/game/main.tscn"
const VIGOR_STEP := 0.35               # ogni punto di vigore in più: +35% a Vita e danno delle creature

var m: Node2D


func setup(main: Node2D) -> void:
	m = main


## Il vigore di questo mondo (1 = il primo).
func vigor() -> int:
	return int(m.world_meta.get("vigore", 1))


## Moltiplicatore delle creature per un certo vigore.
static func vigor_mult(v: int) -> float:
	return 1.0 + VIGOR_STEP * (v - 1)


static func _key(o: Vector2i) -> String:
	return "%d,%d" % [o.x, o.y]


func _portals() -> Dictionary:
	if not m.world_meta.has("portali"):
		m.world_meta["portali"] = {}
	return m.world_meta["portali"]


## Pianta il Seme di mondo con il mouse sul punto più basso al centro dell'arco (3×4 tessere, pavimento sotto).
func plant(c: Vector2i, id: String) -> bool:
	var o := c - Vector2i(1, 3)
	if not m.actions.in_reach(c) or not m.world.station_fits("portale", o):
		m.hud.toast("Serve spazio libero (3×4) e un pavimento sotto")
		return false
	var b: Bisaccia = m.character.bisaccia
	if not b.remove(id, 1):
		return false
	_add_station(o)
	_portals()[_key(o)] = {"mondo": "", "seme": hash([m.world.world_seed, "portale", o.x, o.y]) & 0x7fffffff, "ritorno": false}
	m.guardian.lore.show_page("portale")
	m.sfx.play("portale", Vector2(o) * 16.0)
	return true


func _add_station(o: Vector2i) -> void:
	m.world.stations[o] = "portale"
	m.view.add_station(o)
	m.light.dirty = true


## Nel mondo appena nato dal portale: un portale di ritorno accanto alla partenza, verso il mondo d'origine.
func place_return(back_id: String) -> Vector2i:
	var sp: Vector2i = m.world.spawn
	var o := Vector2i(-1, -1)
	for r in range(4, 80):
		for side in [1, -1]:
			var x: int = sp.x + side * r
			var q := Vector2i(x - 1, m.world.surface[x] - 4)
			if o.x < 0 and m.world.station_fits("portale", q):
				o = q
	if o.x < 0:
		# nessun posto libero: si ricava uno spiazzo accanto alla partenza (aria sopra, terra sotto)
		var x0 := sp.x + 4
		var gy: int = m.world.surface[x0]
		for dx in 3:
			for dy in range(1, 5):
				m.world.set_tile(x0 - 1 + dx, gy - dy, TileDefs.AIR)
			m.world.set_tile(x0 - 1 + dx, gy, TileDefs.GRASS)
			m.view.refresh_around(Vector2i(x0 - 1 + dx, gy - 2))
		o = Vector2i(x0 - 1, gy - 4)
	_add_station(o)
	_portals()[_key(o)] = {"mondo": back_id, "seme": 0, "ritorno": true}
	return o


## Dove porta il portale con l'angolo in o: [id, nome, seme, vigore]; l'id è vuoto se il mondo va ancora creato.
func destination(o: Vector2i) -> Array:
	var e: Dictionary = _portals().get(_key(o), {})
	if e.is_empty():
		# portale piantato prima della voce 12: la vecchia destinazione unica
		e = {"mondo": String(m.world_meta.get("portale_mondo", "")), "seme": hash([m.world.world_seed, "portale"]) & 0x7fffffff,
			"ritorno": false}
		_portals()[_key(o)] = e
	var id := String(e["mondo"])
	if id != "" and WorldSave.read_meta(id).is_empty():
		id = ""                                # il mondo è stato cancellato
	if e.get("ritorno", false):
		var back := WorldSave.read_meta(id)
		return [id, String(back.get("nome", "")), 0, int(back.get("vigore", 1))]
	# «Radura, vigore 2», poi «Radura, vigore 3»…: il nome del primo mondo resta, cresce il vigore
	var base := String(m.world_meta.get("nome", "Mondo")).get_slice(", vigore", 0)
	return [id, "%s, vigore %d" % [base, vigor() + 1], int(e["seme"]), vigor() + 1]


func travel(o: Vector2i) -> void:
	var dest := destination(o)
	var e: Dictionary = _portals()[_key(o)]
	if String(dest[0]) != "":
		Session.start_saved_world(String(dest[0]))
	elif e.get("ritorno", false):
		m.hud.toast("Il mondo dall'altra parte non esiste più")
		return
	else:
		var nid := SavePaths.new_id(String(dest[1]))
		e["mondo"] = nid
		Session.start_new_world(String(dest[1]), int(dest[2]), nid, {"vigore": int(dest[3]), "ritorno": m.world_id})
	m.objectives.bump("viaggi")
	m.save_game()
	get_tree().change_scene_to_file(GAME_SCENE)
