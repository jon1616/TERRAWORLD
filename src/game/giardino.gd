class_name Giardino
extends Node
## Il Giardino vero (voce 62, Roadmap 8): il mondo casa di ogni partita nuova, un'isola sospesa nel Vuoto attorno
## all'**Albero-Madre** addormentato (generatore: `PassGiardino`; `world_meta["giardino"] = true`).
## - Nel Giardino non nascono creature e non c'è Avvizzimento, firma né Cuore: è la base, non un mondo da esplorare.
## - Chi cade dall'isola nel Vuoto viene respinto verso l'Albero (un po' di Vita in meno).
## - Il primo tocco all'Albero gli fa lasciar cadere il **primo Seme di mondo** (con il gene scelto nel menu, vigore 1):
##   piantato nell'Aiuola apre il portale verso il primo mondo, che è un mondo come quelli di sempre (il «mondo di
##   partenza» di prima della Roadmap 8). Dal secondo tocco l'Albero parla dei suoi stadi (`AlberoMadre`, voce 63).
## Nei mondi nati dai Semi questo modulo non fa nulla (`active` falso).

const S := 16
const FALL := 30                       # tessere sotto il fondo dell'isola: lì il Vuoto ti respinge
const FALL_HURT := 0.1                 # frazione della Vita che si perde

var m: Node2D
var active := false
var tree_o := Vector2i(-1, -1)
var _lowest := 0


func setup(main: Node2D) -> void:
	m = main
	active = bool(m.world_meta.get("giardino", false))
	if not active:
		return
	for o in m.world.stations:
		if String(m.world.stations[o]).begins_with("albero_madre"):
			tree_o = o
	if m.world.gen_notes.has("isola"):
		m.world_meta["isola_fondo"] = int(m.world.gen_notes["isola"][2])
	_lowest = int(m.world_meta.get("isola_fondo", m.world.h - 40))
	m.fauna.enabled = false
	m.fauna.clear()
	m.character.stats["giardino"] = 1        # il personaggio ha un Giardino: l'Albero-Madre guida la sua partita
	m.background.set_void()


func _process(_dt: float) -> void:
	if not active or not m.built or m.life.dead:
		return
	if m.player.position.y > (_lowest + FALL) * S:
		m.snap_to(m.world.spawn)
		m.vitals.hp = maxi(1, m.vitals.hp - roundi(m.vitals.hp_max * FALL_HURT))
		m.vitals.changed.emit()
		Fx.puff(m.fx, m.player.position, Color(0.8, 1.6, 1.5))
		m.hud.toast("Il Vuoto ti respinge verso l'Albero-Madre")


## Clic destro sull'Albero-Madre (da `Interact`).
func touch_tree(_o: Vector2i) -> bool:
	if not bool(m.world_meta.get("primo_seme", false)):
		give_first_seed()
		return true
	if "albero" in m and m.albero != null:
		return m.albero.open()
	m.hud.toast("L'Albero-Madre dorme ancora")
	return true


## Il primo Seme di mondo: il gene scelto nel menu (o uno a caso), vigore 1.
func give_first_seed() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = m.world.world_seed ^ 0x5EED1
	var first: Array = m.world_meta.get("primo_geni", [])
	var g := Genome.roll(rng, 1, String(first[0]) if not first.is_empty() else "")
	g["vigore"] = 1
	var item := Genome.item_of(g)
	if m.character.bisaccia.add_stack({"id": item, "n": 1, "dati": g}) > 0:
		m.drops.spawn(item, 1, m.player.position + Vector2(0, -20), g)
	m.world_meta["primo_seme"] = true
	Fx.puff(m.fx, Vector2(tree_o) * S + Vector2(72, 80), Color(1.2, 1.6, 1.4))
	m.sfx.play("dono")
	m.guardian.lore.show_page("albero_addormentato")
	m.hud.toast("L'Albero-Madre si muove nel sonno e lascia cadere un Seme: piantalo nell'Aiuola")
