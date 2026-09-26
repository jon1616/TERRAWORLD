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
## Voce 42: ogni portale porta i **geni** del Seme piantato ("geni") e il **vigore** del mondo che nascerà ("vigore":
## quello del Seme, o quello di questo mondo più uno per i Semi che non lo fissano). Il primo clic destro sul portale li
## dice, il secondo parte.

const GAME_SCENE := "res://src/game/main.tscn"
const VIGOR_STEP := 0.35               # ogni punto di vigore in più: +35% a Vita e danno delle creature

var m: Node2D
var _armed := Vector2i(-1, -1)         # il portale toccato una volta (il secondo tocco entro ARM secondi parte)
var _armed_t := 0.0

const ARM := 6.0


var tip: PortalTip                     # la scheda del mondo con il mouse sopra il portale


func setup(main: Node2D) -> void:
	m = main
	tip = PortalTip.new()
	m.hud.add_child(tip)
	tip.setup(m)


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


## Pianta il Seme di mondo in un'Aiuola del Giardino (voce 45: il mouse su una qualunque cella dell'Aiuola): l'Aiuola
## diventa un portale. Un Seme dormiente (con "mondo" nel genoma) riapre il suo mondo.
func plant(c: Vector2i, id: String) -> bool:
	var o: Vector2i = m.aiuole.aiuola_at(c)
	if o.x < 0:
		m.hud.toast("I Semi di mondo si piantano in un'Aiuola del Giardino" if m.aiuole.is_home()
			else "I Semi di mondo si piantano nelle Aiuole del Giardino, il tuo mondo di partenza")
		return false
	if not m.actions.in_reach(c):
		m.hud.toast("Avvicinati all'Aiuola")
		return false
	var b: Bisaccia = m.character.bisaccia
	var i: int = m.hud.sel if b.id_at(m.hud.sel) == id else _slot_of(b, id)
	if i < 0:
		return false
	var g := b.data_at(i).duplicate(true)
	b.take_one(i)
	m.view.remove_station(o)
	_add_station(o)
	# il seme del mondo nuovo: dal mondo, dall'Aiuola e da quanti Semi vi sono stati piantati (la stessa Aiuola ne ospita
	# molti, uno dopo l'altro); scritto nel portale, resta quello
	m.world_meta["semi_piantati"] = int(m.world_meta.get("semi_piantati", 0)) + 1
	var sd := hash([m.world.world_seed, "portale", o.x, o.y, int(m.world_meta["semi_piantati"])]) & 0x7fffffff
	var v := Genome.vigor(g)
	_portals()[_key(o)] = {"mondo": String(g.get("mondo", "")), "seme": sd, "ritorno": false, "geni": Genome.genes(g),
		"vigore": v if v > 0 else vigor() + 1, "aiuola": true}
	m.guardian.lore.show_page("portale")
	m.sfx.play("portale", Vector2(o) * 16.0)
	return true


func _add_station(o: Vector2i) -> void:
	m.world.stations[o] = "portale"
	m.view.add_station(o)
	m.light.dirty = true


static func _slot_of(b: Bisaccia, id: String) -> int:
	for k in b.slots.size():
		if b.id_at(k) == id:
			return k
	return -1


## I geni del mondo dietro un portale di prima dei genomi (nati dal suo seme: stesso portale, stessi geni).
func _roll(e: Dictionary) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(e["seme"]) ^ 0x5EED
	e["geni"] = Genome.genes(Genome.roll(rng, vigor() + 1))


## Il vigore del mondo dietro un portale.
func _dest_vigor(e: Dictionary) -> int:
	return int(e.get("vigore", 0)) if int(e.get("vigore", 0)) > 0 else vigor() + 1


## Primo clic destro: dice dove porta; il secondo (entro `ARM` secondi) parte.
func touch(o: Vector2i) -> void:
	var now := Time.get_ticks_msec() / 1000.0
	if _armed == o and now - _armed_t < ARM:
		_armed = Vector2i(-1, -1)
		travel(o)
		return
	_armed = o
	_armed_t = now
	m.hud.toast(describe(o) + " — clic destro di nuovo per partire")


## «Verso «Radura, vigore 3» · Seme di sporangio · Vene ricche, Notti lunghe».
func describe(o: Vector2i) -> String:
	var dest := destination(o)
	var e: Dictionary = _portals()[_key(o)]
	if e.get("ritorno", false):
		return "Ritorno a «%s»" % dest[1]
	return "Verso «%s», vigore %d · %s" % [dest[1], int(dest[3]), Genome.describe({"geni": e.get("geni", [])})]


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
	if not e.get("ritorno", false) and not e.has("geni"):
		_roll(e)                               # portale piantato prima della voce 39
	var id := String(e["mondo"])
	if id != "" and WorldSave.read_meta(id).is_empty():
		id = ""                                # il mondo è stato cancellato
	if e.get("ritorno", false):
		var back := WorldSave.read_meta(id)
		return [id, String(back.get("nome", "")), 0, int(back.get("vigore", 1))]
	# voce 44: il mondo nuovo ha un nome suo, nato dai geni e dal seme («Paludi cave di Osrarim»)
	return [id, NamesData.world_name(e.get("geni", []), int(e["seme"])), int(e["seme"]), _dest_vigor(e)]


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
		Session.start_new_world(String(dest[1]), int(dest[2]), nid, {"vigore": int(dest[3]), "ritorno": m.world_id,
			"geni": e.get("geni", []), "casa": m.aiuole.home_id()})
	m.objectives.bump("viaggi")
	m.save_game()
	get_tree().change_scene_to_file(GAME_SCENE)
