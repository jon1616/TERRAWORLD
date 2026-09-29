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
var gear_grow := 1.0                   # Roadmap 20: il grado dell'orto (`GearEffects`, chiave «grow»)
var season_mult := 1.0                 # voce 66: la stagione
var weather_mult := 1.0                # voce 75: la pioggia


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
		grow(grow_mult * season_mult * weather_mult * gear_grow)


## Fa passare il tempo per tutte le colture: le mature cambiano aspetto.
func grow(secs: float) -> void:
	var w: World = m.world
	for c in w.crops:
		var e: Array = w.crops[c]
		if float(e[1]) <= 0.0:
			continue
		var lf := _near_linfa(c)
		e[1] = float(e[1]) - secs * (LiquidsData.LINFA_GROW if lf else m.day.dark_grow(c)) \
			* m.zones.mult_at((Vector2(c) + Vector2(0.5, 0.5)) * 16.0, "crescita") \
			* (m.rooms.grow_at(c) if m.rooms else 1.0) \
			* (m.garden_islands.grow_at(c) if m.get("garden_islands") != null else 1.0) \
			* (HerdJobs.plow_at(m.pens.plows, c) if m.get("pens") != null else 1.0)   # voci 74, 78, 87, 142, 228 e 243
		if float(e[1]) <= 0.0:
			w.set_decor(c.x, c.y, int(CropsData.CROPS[String(e[0])]["decor"]))
			m.view.refresh_around(c)
			m.light.dirty = true


## Voce 74: c'è Linfa liquida vicino a questa cella?
func _near_linfa(c: Vector2i) -> bool:
	var w: World = m.world
	var r := LiquidsData.LINFA_GROW_R
	for y in range(c.y - r, c.y + r + 1):
		for x in range(c.x - r, c.x + r + 1):
			if w.liq(x, y) > 0 and w.liq_type(x, y) == LiquidsData.LINFA:
				return true
	return false


var _last_e: Array = []                  # voce 244: la coltura appena tolta (la qualità si calcola dopo)


## Voce 244: i punti di qualità di una coltura (le cure che ha avuto; il seme scelto ne vale due).
func quality(c: Vector2i, e: Array) -> int:
	if e.is_empty():
		return 0
	var q := int(e[3]) if e.size() > 3 else 0
	if bool(e[2]):
		q += 1
	if m.get("pens") != null and HerdJobs.plow_at(m.pens.plows, c) > 1.0:
		q += 1
	if m.rooms != null and m.rooms.grow_at(c) > 1.0:
		q += 1
	if _near_linfa(c):
		q += 1
	if m.get("garden_islands") != null and m.garden_islands.grow_at(c) > 1.0:
		q += 1
	return q


static func tier_of(q: int) -> int:
	return 2 if q >= OrchardData.GREAT else (1 if q >= OrchardData.GOOD else 0)


func e_of(c: Vector2i, _crop: String) -> Array:
	return m.world.crops.get(c, _last_e)


## Voce 244: un incrocio con una pianta matura di un'altra coltura accanto.
func _cross(c: Vector2i, crop: String, tier: int, at: Vector2) -> void:
	for dy in range(-1, 2):
		for dx in range(-OrchardData.NEAR, OrchardData.NEAR + 1):
			var o := c + Vector2i(dx, dy)
			var e: Array = m.world.crops.get(o, [])
			if o == c or e.is_empty() or float(e[1]) > 0.0 or String(e[0]) == crop:
				continue
			var v := OrchardData.hybrid(crop, String(e[0]))
			if v == "" or _rng.randf() >= (OrchardData.CROSS_GREAT if tier == 2 else OrchardData.CROSS):
				continue
			m.drops.spawn(OrchardData.seed_of(v), 1, at)
			var st: Dictionary = m.character.stats
			if int(st.get("ibrido_" + v, 0)) == 0:
				st["ibrido_" + v] = 1
				m.objectives.bump("ibridi")
				m.hud.toast("Un incrocio! Un seme di %s, una varietà nuova" % String(OrchardData.VARIETIES[v][0]).to_lower())
			return


## Voce 244: la riga dell'orto nel Libro dei pilastri.
func line() -> String:
	var n := 0
	for v in OrchardData.VARIETIES:
		n += int(m.character.stats.get("ibrido_" + v, 0))
	var dishes := 0
	for r in CookingData.recipes():
		if Crafting._discovered(r):
			dishes += 1
	return "Varietà scoperte: %d su %d · raccolti ottimi: %d · Ricettario: %d piatti su %d (cucinati %d)" % [n, OrchardData.VARIETIES.size(),
		int(m.character.stats.get("ottimi", 0)), dishes, CookingData.DISHES.size(), int(m.character.stats.get("piatti", 0))]


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
	w.crops[c] = [crop, float(CropsData.CROPS[crop]["grow"]), false, OrchardData.CHOSEN if item.begins_with("scelto_") else 0]
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
		_last_e = w.crops[c]
		var crop := String(w.crops[c][0])
		var cd: Dictionary = CropsData.CROPS[crop]
		w.crops.erase(c)
		if d == CropsData.SPROUT:
			m.drops.spawn(String(cd["seed"]), 1, at)         # un germoglio strappato ridà il suo seme
			return
		var tier := tier_of(quality(c, e_of(c, crop)))      # voce 244: la qualità
		var mult: float = [1.0, OrchardData.GOOD_MULT, OrchardData.GREAT_MULT][tier]
		for id in cd["harvest"]:
			var span: Array = cd["harvest"][id]
			m.drops.spawn(String(id), roundi(_rng.randi_range(int(span[0]), int(span[1])) * mult), at)
		m.drops.spawn(String(cd["seed"]), _rng.randi_range(int(cd["seeds"][0]), int(cd["seeds"][1])), at)
		if tier == 2:
			m.drops.spawn("scelto_" + crop, 1, at)
			m.objectives.bump("ottimi")
		if tier > 0:
			m.hud.toast("Raccolto %s: %s" % [OrchardData.NAMES[tier], cd["name"]])
		_cross(c, crop, tier, at)
		_last_e = []
		m.objectives.bump("raccolti")
		m.sfx.play("raccogli", at)
		return
	for wd in CropsData.WILD:
		if d in wd[0] and _rng.randf() < float(wd[2]) * wild_mult:
			m.drops.spawn(String(wd[1]), 1, at)
