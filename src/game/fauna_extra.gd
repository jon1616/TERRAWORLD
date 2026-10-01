class_name FaunaExtra
extends RefCounted
## Pezzi di `Fauna` messi a parte (pulizia del 28 set 2026: fauna.gd aveva passato le 460 righe): il bottino di una
## creatura sconfitta (giri di bottino, Lumini, Essenze, trofei, Polvere iridata), le compagne che nascono con la
## prima (sciami e branchi), come una creatura diventa rara, e le famiglie favorite e assenti di un mondo. Stesso codice di prima, con `f` al posto di `Fauna` e lo stesso generatore di numeri.

const S := 16


## Il bottino di una creatura sconfitta: più giri per le rare e con la Fortuna, e un'Essenza per ogni tratto.
## Voce 187 (Roadmap 18): un Lumino ogni 10 punti di Vita della creatura (erano 18): cacciare rendeva 66 Lumini all'ora
## in Superficie e un quarto della pesca dello stesso momento (`tools/progressioni.gd`).
const LUMINI_HP := 10.0


static func drop(f: Fauna, c: Creature, _rng: RandomNumberGenerator) -> void:
	# bottino: più giri per le rare e con la Fortuna, e un'Essenza per ogni tratto di una creatura antica
	var rolls := 1
	if c.ancient:
		rolls = int(AncientData.RARITIES[c.ancient.rarity]["loot_rolls"])
	if _rng.randf() < (f.luck + f.boon_luck + f._za(c.position, "fortuna")) * 0.5:
		rolls += 1
	rolls += int(f._za(c.position, "bottino"))            # voce 87: lo Stendardo del saccheggio
	# i Lumini (voce 36): quanti secondo quanto era forte, di più per le rare e i boss
	var lum := maxi(1, roundi(c.hp_max / LUMINI_HP))
	if c.ancient:
		lum *= {"antica": 3, "ancestrale": 10, "capobranco": 3, "iridata": 8}[c.ancient.rarity]
	if c.boss:
		lum = maxi(lum, roundi(c.hp_max / 6.0))
	lum = maxi(1, roundi(lum * f.world_lumini))
	f.drops.spawn("lumino", lum, c.position + Vector2(_rng.randf_range(-6, 6), -4))
	for r in rolls:
		var loot := LootData.roll(String(c.data["loot"]), _rng)
		for id in loot:
			f.drops.spawn(id, int(loot[id]), c.position)
	# Roadmap 32, voce 314: frutti, semi, istinti, pietre e ciondoli per i compagni
	for e in BondsData.creature_loot(c.data.get("behaviors", []), String(FamiliesData.parts(c.id)[2]),
			c.ancient.rarity if c.ancient else "", _rng):
		f.drops.spawn(String(e[0]), int(e[1]), c.position + Vector2(_rng.randf_range(-6, 6), -6))
	if c.ancient:
		for t in c.ancient.traits:
			f.drops.spawn(String(AncientData.TRAITS[t]["essence"]), 1, c.position + Vector2(_rng.randf_range(-8, 8), -6))
		# il trofeo della specie: bottino che lasciano solo le rare (voce 23)
		var rd: Dictionary = AncientData.RARITIES[c.ancient.rarity]
		var trophy := String(TrophyItemsData.TROPHY_OF.get(c.base, ""))
		if trophy != "" and _rng.randf() < float(rd.get("trophy", 0.0)):
			f.drops.spawn(trophy, 1, c.position + Vector2(0, -10))
		if rd.has("dust"):
			f.drops.spawn("polvere_iridata", _rng.randi_range(int(rd["dust"][0]), int(rd["dust"][1])), c.position)


## Gli sciami (campo `group` in `CreaturesData`): con la prima nascono le compagne, che non contano nel tetto.
static func group(f: Fauna, first: Creature, id: String, mult: float, _rng: RandomNumberGenerator) -> void:
	var g: Array = CreaturesData.get_data(id).get("group", [])
	if g.is_empty():
		return
	for k in _rng.randi_range(int(g[0]), int(g[1])) - 1:
		var o := first.position + Vector2(_rng.randf_range(-24, 24), _rng.randf_range(-16, 0))
		var q := Vector2i(floori(o.x / S), floori(o.y / S))
		if f.world.solid(q.x, q.y):
			continue
		var mb := f.add(id, o)
		mb.strengthen(mult, mult * DangerData.DAMAGE)
		mb.extra = true
		mb.set_meta("grp", first.get_instance_id())   # voce 131: un gruppo (`Tactics`)
	first.set_meta("grp", first.get_instance_id())


## Il branco di un capobranco: compagne della stessa specie attorno a lui (non contano nel tetto).
static func pack(f: Fauna, leader: Creature, id: String, mult: float, _rng: RandomNumberGenerator) -> void:
	var span: Array = AncientData.RARITIES["capobranco"]["pack"]
	for k in _rng.randi_range(int(span[0]), int(span[1])):
		var o := leader.position + Vector2(_rng.randf_range(-40, 40), -4)
		if f.world.solid(floori(o.x / S), floori(o.y / S)):
			o = leader.position
		var mb := f.add(id, o)
		mb.strengthen(mult, mult * DangerData.DAMAGE)
		mb.extra = true
		mb.set_meta("grp", leader.get_instance_id())  # voce 131: il branco segue il capo; se cade, fugge
		mb.mind.lead = leader
	leader.set_meta("grp", leader.get_instance_id())


## Rende rara una creatura (e la annuncia se ancestrale o iridata e vicina).
static func make_ancient(f: Fauna, cr: Creature, rarity: String, traits: Array, _rng: RandomNumberGenerator) -> void:
	cr.ancient = Ancient.new()
	var rd: Dictionary = AncientData.RARITIES[rarity]
	cr.ancient.apply(cr, rarity, traits if not traits.is_empty() or rd["traits"][1] == 0 else AncientData.roll_traits(rarity, _rng))
	if rd.get("iride", false):
		# non attacca e scappa: gli altri comportamenti non servono più
		var fl := BhFugge.new()
		cr.behaviors.clear()
		cr.behaviors.append(fl)
		cr.damage = 0
	if rarity in ["ancestrale", "iridata"] and cr.position.distance_to(f.player.position) < AncientData.ANNOUNCE * S:
		f.rare_spawned.emit(cr)


## Le famiglie favorite e assenti di un mondo (sempre le stesse per lo stesso seme).
static func family_weights(sd: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = sd ^ 0xFA0A
	var fams := FamiliesData.FAMILIES.keys()
	fams.sort()                                  # (in ordine alfabetico: non dipende da dove sono scritte)
	var out := {}
	for k in 5:
		var f := String(fams[rng.randi_range(0, fams.size() - 1)])
		fams.erase(f)
		out[f] = 2.5 if k < 3 else 0.0
	return out
