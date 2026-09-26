class_name Garden
extends Node
## Il giardino (voce 33, dati in `CropsData`): semina, crescita (anche lontano dalla visuale, ogni secondo),
## annaffiatura, raccolto con il clic destro o scavando la pianta, semi selvatici dalle decorazioni. Le colture stanno
## in `World.crops` (cella -> [coltura, secondi che mancano, annaffiata]) e si salvano con il mondo.

const S := 16

var m: Node2D
var _t := 1.0
var _rng := RandomNumberGenerator.new()
var paused := false                    # le prove fanno crescere a comando (`grow`)
var wild_mult := 1.0                   # la Fioritura (voce 34) fa trovare più semi selvatici
var grow_mult := 1.0                   # tratto «Fertile» del mondo (voce 39)


func setup(main: Node2D) -> void:
	m = main
	_rng.seed = m.world.world_seed ^ 0x6A4D
	m.actions.decor_picked.connect(_on_picked)


func _process(dt: float) -> void:
	if not m.built or paused:
		return
	_t -= dt
	if _t <= 0.0:
		_t = 1.0
		grow(grow_mult)


## Fa passare il tempo per tutte le colture: le mature cambiano aspetto.
func grow(secs: float) -> void:
	var w: World = m.world
	for c in w.crops:
		var e: Array = w.crops[c]
		if float(e[1]) <= 0.0:
			continue
		e[1] = float(e[1]) - secs
		if float(e[1]) <= 0.0:
			w.set_decor(c.x, c.y, int(CropsData.CROPS[String(e[0])]["decor"]))
			m.view.refresh_around(c)
			m.light.dirty = true


## Pianta un seme da giardino in una cella. True se l'ha fatto.
func plant(c: Vector2i, item: String) -> bool:
	var w: World = m.world
	var crop: String = CropsData.of_seed(item)
	if crop == "" or not m.actions.in_reach(c) or not w.inside(c.x, c.y) or w.solid(c.x, c.y) or w.crops.has(c):
		return false
	var d := w.decor_at(c.x, c.y)
	if d != 0 and not TileDefs.is_soft_decor(d):
		return false
	if not CropsData.soil_ok(crop, w.tile(c.x, c.y + 1)):
		m.hud.toast("%s vuole %s" % [CropsData.CROPS[crop]["name"], "muschio o erba" if CropsData.CROPS[crop]["soil"] == "erba" else "terra o roccia"])
		return false
	if CropsData.CROPS[crop].get("deep", false) and w.depth(c.x, c.y) < 20:
		m.hud.toast("I funghi luminosi crescono solo sotto terra, al buio")
		return false
	if not m.character.bisaccia.remove(item, 1):
		return false
	w.set_decor(c.x, c.y, CropsData.SPROUT)
	w.crops[c] = [crop, float(CropsData.CROPS[crop]["grow"]), false]
	m.view.refresh_around(c)
	m.sfx.play("posa", Vector2(c) * S)
	m.objectives.bump("semine")
	return true


## L'annaffiatoio: la coltura cresce il doppio più in fretta da qui in poi (una volta sola).
func water(c: Vector2i) -> bool:
	var e: Array = m.world.crops.get(c, [])
	if e.is_empty() or float(e[1]) <= 0.0 or bool(e[2]) or not m.actions.in_reach(c):
		return false
	e[1] = float(e[1]) * 0.5
	e[2] = true
	Fx.puff(m.fx, Vector2(c) * S + Vector2(8, 6), Color(0.6, 1.2, 1.6))
	m.sfx.play("pozione", Vector2(c) * S)
	return true


## Clic destro su una pianta matura: il raccolto. True se c'era qualcosa da raccogliere.
func harvest(c: Vector2i) -> bool:
	var e: Array = m.world.crops.get(c, [])
	if e.is_empty() or float(e[1]) > 0.0 or not m.actions.in_reach(c):
		return false
	m.world.set_decor(c.x, c.y, 0)
	m.view.refresh_around(c)
	m.light.dirty = true
	_on_picked(c, int(CropsData.CROPS[String(e[0])]["decor"]))
	return true


## Una decorazione tolta (scavata o raccolta): il raccolto delle colture, il seme dei germogli, i semi selvatici.
func _on_picked(c: Vector2i, d: int) -> void:
	var at := Vector2(c) * S + Vector2(8, 8)
	var w: World = m.world
	if w.crops.has(c):
		var crop := String(w.crops[c][0])
		var cd: Dictionary = CropsData.CROPS[crop]
		w.crops.erase(c)
		if d == CropsData.SPROUT:
			m.drops.spawn(String(cd["seed"]), 1, at)         # un germoglio strappato ridà il suo seme
			return
		for id in cd["harvest"]:
			var span: Array = cd["harvest"][id]
			m.drops.spawn(String(id), _rng.randi_range(int(span[0]), int(span[1])), at)
		m.drops.spawn(String(cd["seed"]), _rng.randi_range(int(cd["seeds"][0]), int(cd["seeds"][1])), at)
		m.objectives.bump("raccolti")
		m.sfx.play("raccogli", at)
		return
	for wd in CropsData.WILD:
		if d in wd[0] and _rng.randf() < float(wd[2]) * wild_mult:
			m.drops.spawn(String(wd[1]), 1, at)
