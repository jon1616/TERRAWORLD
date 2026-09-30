class_name TestsCaves
extends RefCounted
## Roadmap 30 «Le grotte piene»: raccolti delle piante, baccelli dormienti, nascite delle creature, piccoli incontri,
## curiosità degli strati (gruppo `grotte`). Ogni prova rimette com'erano Bisaccia e conteggi.

var kit: TestKit
var m: Node


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	await harvest()
	await pods()
	await spawns()


func _counts(ids: Array) -> Dictionary:
	var out := {}
	for id in ids:
		out[id] = m.character.bisaccia.count(String(id))
	return out


func _give_back(before: Dictionary) -> void:
	for id in before:
		var extra: int = m.character.bisaccia.count(String(id)) - int(before[id])
		if extra > 0:
			m.character.bisaccia.remove(String(id), extra)


## Voce 300: una pianta dei biomi tolta lascia il suo raccolto; una bacca si mangia, una fibra fa corda.
func harvest() -> void:
	var st: Dictionary = m.character.stats
	var n0 := int(st.get("piante_raccolte", 0))
	var before := _counts(["bacche_lanterna", "cardo_ambra"])
	var c: Vector2i = m.player_cell() + Vector2i(1, 0)
	var w: World = m.world
	var old := w.decor_at(c.x, c.y)
	w.set_decor(c.x, c.y, 33)
	m.actions.pick_decor(c)
	w.set_decor(c.x, c.y, 38)
	m.actions.pick_decor(c)
	await kit.seconds(1.5)
	var got_b: int = m.character.bisaccia.count("bacche_lanterna") - int(before["bacche_lanterna"])
	var got_c: int = m.character.bisaccia.count("cardo_ambra") - int(before["cardo_ambra"])
	var bumped := int(st.get("piante_raccolte", 0)) - n0
	var food := ItemsData.get_item("bacche_lanterna")
	var rope := false
	for r in RecipesData.making("corda_liana"):
		if (r["in"] as Dictionary).has("fronda_felce"):
			rope = true
	var dye := not RecipesData.making("tintura_arancio").filter(func(r: Dictionary) -> bool: return (r["in"] as Dictionary).has("cardo_ambra")).is_empty()
	var plants := 0
	for d in HarvestData.DECOR:
		if d >= 33:
			plants += 1
	var ok: bool = got_b >= 1 and got_c == 1 and bumped == 2 and String(food.get("kind", "")) == "consumabile" and rope and dye \
		and plants >= 55
	print("raccolti delle piante: %d piante dei biomi con un raccolto; bacche-lanterna +%d, cardo d'ambra +%d, conteggio +%d, le bacche si mangiano %s, la felce fa corda %s, il cardo tinge %s" % [
		plants, got_b, got_c, bumped, String(food.get("kind", "")) == "consumabile", rope, dye])
	if not ok:
		print("ATTENZIONE: i raccolti delle piante non vanno")
	w.set_decor(c.x, c.y, old)
	_give_back(before)
	st["piante_raccolte"] = n0


## Voce 301: il mondo ha i suoi baccelli dormienti (a centinaia per strato); aperto, uno lascia il bottino del suo strato;
## ogni tipo ha il suo disegno.
func pods() -> void:
	var w: World = m.world
	var st: Dictionary = m.character.stats
	var n0 := int(st.get("baccelli_aperti", 0))
	var count := 0
	var near := Vector2i(-1, -1)
	var best := 1e9
	var sp := Vector2(w.spawn)
	for y in range(0, w.h):
		for x in range(0, w.w):
			var d := w.decor_at(x, y)
			if d >= PodsData.FIRST and d <= PodsData.LAST:
				count += 1
				var dist := Vector2(x, y).distance_to(sp)
				if dist < best and StrataData.at(w, x, y) >= 1:
					best = dist
					near = Vector2i(x, y)
	var drawn := true
	for id in range(PodsData.FIRST, PodsData.LAST + 1):
		var img: Image = DecorPainter.decor(id)["img"]
		drawn = drawn and not img.get_used_rect().size.x < 4
	var ids := ["lumino", "torcia", "dardo", "gelatina", "pozione_rugiada", "minerale_radicite", "humus", "seta_radice",
		"fibra_radice", "minerale_legnoferro", "pozione_bagliore", "scisto", "pietra_seminatori", "polvere_iridata",
		"scheggia_vigore", "linfa_antica", "seme_lanterna", "bacche_lanterna"]
	var before := _counts(ids)
	var loot := []
	if near.x >= 0:
		m.snap_to(near + Vector2i(-2, 0))
		await kit.seconds(0.5)
		await kit.save("303_baccello")
		var d := w.decor_at(near.x, near.y)
		m.actions.pick_decor(near)
		loot = m.harvest.last_loot
		await kit.seconds(1.5)
		w.set_decor(near.x, near.y, d)
		m.view.refresh_around(near)
	var gained := 0
	for id in ids:
		gained += m.character.bisaccia.count(String(id)) - int(before[id])
	var opened := int(st.get("baccelli_aperti", 0)) - n0
	var ok: bool = count >= 300 and near.x >= 0 and drawn and opened == 1 and not loot.is_empty() and gained >= 1
	print("baccelli dormienti: %d nel mondo di prova, disegni %s, aperto il più vicino (%s): %s → nella Bisaccia +%d" % [count, drawn,
		near, loot, gained])
	if not ok:
		print("ATTENZIONE: i baccelli dormienti non vanno")
	_give_back(before)
	st["baccelli_aperti"] = n0
	m.snap_to(w.spawn)


## Voce 302: in una grotta delle Caverne d'ardesia le prove di nascita riescono quasi sempre (quattro punti per prova), e
## il tetto di creature è più alto di prima.
func spawns() -> void:
	var w: World = m.world
	var fa: Fauna = m.fauna
	var spot := Vector2i(-1, -1)
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	for t in 4000:
		var x := rng.randi_range(40, w.w - 40)
		var y := rng.randi_range(40, w.h - 40)
		if StrataData.at(w, x, y) == 2 and not w.solid(x, y) and not w.solid(x, y - 1) and w.solid(x, y + 1) 				and not w.torch_near(Vector2i(x, y), 50.0) and Vector2(x, y).distance_to(Vector2(w.spawn)) > 120.0:
			spot = Vector2i(x, y)
			break
	var made := 0
	var tries := 60
	if spot.x >= 0:
		m.snap_to(spot)
		await kit.seconds(1.0)                        # (la luce si ricalcola attorno al posto nuovo: si nasce solo al buio)
		fa.clear(true)
		for k in tries:
			var cr := fa.try_spawn()
			if cr != null:
				made += 1
		fa.clear(true)
		m.snap_to(w.spawn)
	var rate := float(made) / tries
	var ok: bool = spot.x >= 0 and rate >= 0.5 and DangerData.cap(1.0) == 3 and DangerData.SPAWN_TRIES >= 4
	print("nascite nelle Caverne d'ardesia: %d su %d prove (%.0f%%; prima ~33%%), tetto di giorno in superficie %d" % [made, tries,
		rate * 100.0, DangerData.cap(1.0)])
	if not ok:
		print("ATTENZIONE: le nascite delle creature non vanno")
