class_name TestsConsumables
extends RefCounted
## Consumabili, pesca e cucina (Roadmap 46, voci 398-400). Gruppo «consumabili».
## I dati (le pozioni a gradi, la cura, le fiale, le fonti, i piatti, le casse da pesca, i premi del Pescatore) e in
## gioco: una pozione dei dati cambia i valori finché dura e poi li rimette, una fiala fa bruciare i colpi, una vista fa
## brillare uno scrigno, una fonte dà il suo effetto, una cassa da pesca del bioma ha i suoi oggetti.

var kit: TestKit
var m: Node2D
var res := {}


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	data()
	await potion()
	await flask_and_vision()
	fountain()
	crate()
	print("consumabili: %s" % str(res))
	if not res.values().all(func(x: Variant) -> bool: return x == true):
		print("ATTENZIONE: consumabili, pesca e cucina non vanno come dovrebbero")


func data() -> void:
	var potions := 0
	var dishes := 0
	var heal := 0
	for id in ItemsData.all():
		var it: Dictionary = ItemsData.all()[id]
		if String(it.get("kind", "")) != "consumabile":
			continue
		potions += 1
		if it.has("boons"):
			dishes += 1
		heal = maxi(heal, int(it.get("heal", 0)))
	var no_recipe := []
	for id in ItemsData.all():
		if String(id).begins_with("pz_") and RecipesData.making(String(id)).is_empty():
			no_recipe.append(id)
	res["dati"] = potions >= 230 and dishes >= 110 and heal >= 350 and no_recipe.is_empty() and FishingData.CRATES.size() >= 18 \
		and FishingData.ANGLER_PRIZES.size() >= 5
	print("consumabili, i dati: consumabili %d, piatti %d, la cura più forte %d, senza ricetta %s, casse da pesca nuove %d, premi del Pescatore %d" % [
		potions, dishes, heal, str(no_recipe), FishingData.CRATES.size(), FishingData.ANGLER_PRIZES.size()])


## La Pozione della corsa: la corsa sale finché dura e poi torna com'era.
func potion() -> void:
	var run0: float = m.player.run_mult
	m.boons.add("bz_corsa_2", 0.4)
	await kit.frames(1)
	var up: float = m.player.run_mult
	await kit.seconds(0.6)
	var back: float = m.player.run_mult
	res["pozione"] = up > run0 * 1.15 and is_equal_approx(back, run0)
	print("consumabili, la pozione della corsa: %.2f → %.2f → %.2f" % [run0, up, back])


## Una fiala di brace: i colpi bruciano finché dura; la vista dei tesori fa brillare uno scrigno vicino.
func flask_and_vision() -> void:
	m.boons.add("bz_fiala_brace_1", 0.5)
	await kit.frames(1)
	var on: bool = m.effects.has("fiala_brace_1")
	var at: Vector2i = m.player_cell() + Vector2i(6, -1)
	m.world.stations[at] = "scrigno"
	var v0: int = m.boons.visions
	m.boons.add("bz_tesori_0", 2.0)
	m.boons._vis_t = 0.0
	await kit.frames(2)
	var seen: bool = m.boons.visions > v0
	m.world.stations.erase(at)
	m.world.chests.erase(at)
	await kit.seconds(2.2)
	var off: bool = not m.effects.has("fiala_brace_1")
	res["fiala_vista"] = on and off and seen
	print("consumabili, la fiala di brace: accesa %s, poi spenta %s; la vista dei tesori %s" % [on, off, seen])


## Una fonte posata: toccandola, il suo effetto per un'ora.
func fountain() -> void:
	var at: Vector2i = m.player_cell() + Vector2i(3, -1)
	m.world.stations[at] = "fonte_passo"
	m.world.stations_changed()
	m.interact.touch(at)
	var ok: bool = float(m.boons.active.get("bz_corsa_2", 0.0)) > 3000.0
	m.world.stations.erase(at)
	m.boons.active.erase("bz_corsa_2")
	m.boons._refresh()
	res["fonte"] = ok
	print("consumabili, la Fonte del passo: un'ora di corsa %s" % ok)


## Una cassa da pesca del bioma: aperta, dà uno dei suoi oggetti.
func crate() -> void:
	var b: Bisaccia = m.character.bisaccia
	kit.hold("cassa_pesca_foresta")
	m.fishing.open_crate("cassa_pesca_foresta")
	var got: Dictionary = m.fishing.last_crate
	var own := got.has("pesca_foresta_amuleto") or got.has("pesca_foresta_arpione")
	for k in got:
		b.remove(String(k), int(got[k]))
	res["cassa"] = own
	print("consumabili, la cassa da pesca della foresta: %s" % str(got))
