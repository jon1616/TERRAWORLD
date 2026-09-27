class_name Fauna
extends Node2D
## Le creature vive attorno al Germogliato: le fa comparire secondo il **pericolo** della zona (`DangerData`: strato,
## notte, Avvizzimento, vigore) con un tetto di creature e un ritmo che crescono con il pericolo; sotto terra solo nel
## buio (le torce sono un riparo). Le toglie quando ci si allontana molto, raccoglie i loro spari e, quando muoiono,
## lascia il bottino.
## Chi colpisce chi lo decide `Combat`; qui c'è solo la popolazione.

const S := 16

var world: World
var player: Player
var drops: Drops
var shots: Projectiles
var enabled := true                    # le prove lo spengono per non essere disturbate
var night := false                     # lo aggiorna `DayCycle`: di notte la superficie è più pericolosa
var sfx: Sfx
var light: LightMap                    # per nascere solo al buio
var vigor := 1                         # vigore del mondo (voce 12)
var vigor_mult := 1.0                  # creature più forti nei mondi oltre i portali
var danger := 1.0                      # pericolo attorno al giocatore, aggiornato a ogni tentativo
var luck := 0.0                        # tratto Fortuna dell'equipaggiamento: probabilità di un giro di bottino in più
var boon_luck := 0.0                   # Pozione di fortuna
var rare_mult := 1.0                   # Pozione dell'esca: creature rare più frequenti
# eventi del mondo (voce 34, vedi `Events`)
var event_danger := 0.0
var world_danger := 0.0                # tratti del mondo (voce 39, `WorldTraits`)
var world_lumini := 1.0
var world_rare := 1.0
var event_rare := 1.0
var event_pool: Array = []
var _light_t := 0.0

signal rare_spawned(c: Creature)
var list: Array[Creature] = []
var kills := 0
var _t := 0.0
var _rng := RandomNumberGenerator.new()

signal killed(c: Creature)
signal hunted(prey: Creature, predator: Creature)      # voce 57: una preda presa da un predatore (niente bottino)
signal grazed(c: Creature, cell: Vector2i)           # voce 57: erba o coltura mangiata
## voce 57: quanto una famiglia nasce in un punto (popolazioni per zona, `Ecology.factor`): (x in px, famiglia) -> float
var pop_factor: Callable
## voce 66: la stagione (`Seasons`): pesi dei ruoli e delle famiglie, la creatura che c'è solo adesso
var season_roles := {}
var season_families := {}
var season_creature := ""
## voce 58: (cella del Germogliato) -> [specie, cella del nido] o []: le nascite dai nidi (`Ecology.nest_spawn`)
var nest_hook: Callable
var migration := {}                    # voce 58: famiglia -> direzione (-1/1) mentre migra
signal vanished(c: Creature)


## Voce 56: la fauna di questo mondo. Dal seme: tre famiglie favorite (×2,5) e due assenti; dai geni: la frequenza dei
## ruoli (`GenesData` "roles") e l'elemento più comune delle varianti.
var family_mult := {}
var role_mult := {}
var world_elem := ""
const GENE_ELEM := {"fungaie": "spora", "geodi_brina": "gelo", "fiumi_brace": "brace", "laghi_linfa": "linfa",
	"cuore_nero": "vuoto", "avvizzito": "vuoto", "stellato": "luce", "aurora": "luce", "cuore_stellare": "luce"}


func set_world(sd: int, genes: Array, roles: Dictionary) -> void:
	family_mult = family_weights(sd)
	role_mult = roles
	world_elem = ""
	for g in genes:
		if GENE_ELEM.has(g):
			world_elem = String(GENE_ELEM[g])


## Le famiglie favorite e assenti di un mondo (sempre le stesse per lo stesso seme).
static func family_weights(sd: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = sd ^ 0xFA0A
	var fams := FamiliesData.FAMILIES.keys()
	var out := {}
	for k in 5:
		var f := String(fams[rng.randi_range(0, fams.size() - 1)])
		fams.erase(f)
		out[f] = 2.5 if k < 3 else 0.0
	return out


## Il peso di una specie in questo mondo (famiglia favorita o assente, ruolo reso più frequente dai geni) e, se si sa
## dove (x in px), la popolazione della sua famiglia in quella zona (voce 57).
func weight_of(id: String, x := -1.0) -> float:
	var f := FamiliesData.family_of(id)
	if f == "":
		return 1.0
	var role := String(FamiliesData.FAMILIES[f].get("role", ""))
	var w := float(family_mult.get(f, 1.0)) * float(role_mult.get(role, 1.0)) * float(season_roles.get(role, 1.0)) \
		* float(season_families.get(f, 1.0))
	if x >= 0.0 and pop_factor.is_valid():
		w *= float(pop_factor.call(x, f))
	return w


## Una creatura della specie nasce davanti a un nido (voce 58), se il posto è libero e al buio (sotto terra).
func spawn_at_nest(species: String, cell: Vector2i) -> Creature:
	if world.torch_near(cell, 8.0):
		return null
	var stratum := StrataData.at(world, cell.x, cell.y)
	if stratum > 0 and not _dark(cell):
		return null
	var biome := String(BiomesData.BIOMES[BiomesData.at(world, cell.x)]["id"])
	var id := FamiliesData.roll_variant(species, _rng, elem_bias(stratum, biome), danger)
	var cd := CreaturesData.get_data(id)
	var x := cell.x + (2 if _rng.randf() < 0.5 else -1)
	if world.solid(x, cell.y) or world.solid(x, cell.y - 1):
		x = cell.x
	var cr := add(id, Vector2(x * S + 8, (cell.y + 1) * S - float(cd["half"][1]) - 0.1))
	var mult := float(StrataData.STRATA[stratum]["danger"]) * vigor_mult
	cr.strengthen(mult, mult * DangerData.DAMAGE)
	_group(cr, id, mult)
	return cr


## Una preda presa da un predatore (voce 57): sparisce senza bottino.
func kill_by_predator(prey: Creature, predator: Creature) -> void:
	if not list.has(prey):
		return
	list.erase(prey)
	Fx.puff(self, prey.position, Color(1.1, 0.7, 0.6))
	hunted.emit(prey, predator)
	prey.queue_free()


## Un erbivoro ha mangiato l'erba (o una coltura) di una cella (voce 57).
func graze(c: Creature, cell: Vector2i) -> void:
	grazed.emit(c, cell)


func setup(w: World, p: Player, d: Drops, pr: Projectiles) -> void:
	world = w
	player = p
	drops = d
	shots = pr
	_rng.seed = w.world_seed ^ 0x5EED
	z_index = 3
	for k in w.creatures.size():
		var sd: Dictionary = w.creatures[k]
		var sc: Vector2i = sd["cell"]
		add(String(sd["id"]), Vector2(sc.x * S + 8, sc.y * S + 8), w.world_seed + k)


## Fa nascere una creatura in un punto (centro del corpo).
func add(id: String, pos: Vector2, sd: int = -1) -> Creature:
	var c := Creature.new()
	c.setup(id, world, player, sd if sd >= 0 else _rng.randi())
	c.position = pos
	add_child(c)
	list.append(c)
	return c


## Toglie tutte le creature (le prove; `keep_boss` lascia il Guardiano).
func clear(keep_boss := false) -> void:
	for c in list.duplicate():
		if keep_boss and c.boss:
			continue
		c.queue_free()
		list.erase(c)


## La creatura muore: sbuffo, bottino a terra, via dalla scena.
func kill(c: Creature) -> void:
	if not list.has(c):
		return
	list.erase(c)
	kills += 1
	if is_instance_valid(c.master):
		c.master.minions -= 1
	# bottino: più giri per le rare e con la Fortuna, e un'Essenza per ogni tratto di una creatura antica
	var rolls := 1
	if c.ancient:
		rolls = int(AncientData.RARITIES[c.ancient.rarity]["loot_rolls"])
	if _rng.randf() < (luck + boon_luck) * 0.5:
		rolls += 1
	# i Lumini (voce 36): quanti secondo quanto era forte, di più per le rare e i boss
	var lum := maxi(1, roundi(c.hp_max / 18.0))
	if c.ancient:
		lum *= {"antica": 3, "ancestrale": 10, "capobranco": 3, "iridata": 8}[c.ancient.rarity]
	if c.boss:
		lum = maxi(lum, roundi(c.hp_max / 6.0))
	lum = maxi(1, roundi(lum * world_lumini))
	drops.spawn("lumino", lum, c.position + Vector2(_rng.randf_range(-6, 6), -4))
	for r in rolls:
		var loot := LootData.roll(String(c.data["loot"]), _rng)
		for id in loot:
			drops.spawn(id, int(loot[id]), c.position)
	if c.ancient:
		for t in c.ancient.traits:
			drops.spawn(String(AncientData.TRAITS[t]["essence"]), 1, c.position + Vector2(_rng.randf_range(-8, 8), -6))
		# il trofeo della specie: bottino che lasciano solo le rare (voce 23)
		var rd: Dictionary = AncientData.RARITIES[c.ancient.rarity]
		var trophy := String(TrophyItemsData.TROPHY_OF.get(c.base, ""))
		if trophy != "" and _rng.randf() < float(rd.get("trophy", 0.0)):
			drops.spawn(trophy, 1, c.position + Vector2(0, -10))
		if rd.has("dust"):
			drops.spawn("polvere_iridata", _rng.randi_range(int(rd["dust"][0]), int(rd["dust"][1])), c.position)
	Fx.puff(self, c.position, Color(1.3, 1.2, 1.0))
	killed.emit(c)
	c.queue_free()


## Toglie una creatura senza bottino (il Guardiano che torna a dormire o che se ne va guarito).
func kill_quietly(c: Creature) -> void:
	if list.has(c):
		list.erase(c)
		Fx.puff(self, c.position, Color(0.8, 1.6, 1.5))
		c.queue_free()


func _process(dt: float) -> void:
	for c in list.duplicate():
		if c.hp <= 0:
			kill(c)                            # avvelenata a morte (tratto Veleno)
			continue
		if c.ancient and c.ancient.gone:
			kill_quietly(c)                    # un'iridata che nessuno ha preso in tempo
			vanished.emit(c)
			continue
		for f in c.fire:
			shots.fire(f["from"], f["vel"], f["grav"], f["damage"], false, 1.0,
				{"look": f.get("look", "spora"), "slow": f.get("slow", 0.0)})
			if sfx:
				sfx.play("spora", f["from"])
		c.fire.clear()
		for id in c.summons:
			var mn := add(id, c.position + Vector2(_rng.randf_range(-30, 30), c.half.y))
			mn.master = c
			c.minions += 1
			Fx.puff(self, mn.position, Color(1.4, 0.9, 1.8))
		c.summons.clear()
	for i in range(list.size() - 1, -1, -1):
		var c := list[i]
		if c.boss:
			continue                           # i Guardiani non spariscono
		if c.position.distance_to(player.position) > CreaturesData.DESPAWN * S or c.position.y > world.h * S:
			c.queue_free()
			list.remove_at(i)
	# le creature Luminose fanno luce attorno a sé
	_light_t -= dt
	if _light_t <= 0.0 and light:
		_light_t = 0.25
		var ls := []
		for c in list:
			if c.ancient and c.ancient.has("luminosa"):
				ls.append([Vector2i(floori(c.position.x / S), floori(c.position.y / S)), Color(1.4, 1.2, 0.7)])
		light.set_extra("antiche", ls)
	if not enabled:
		return
	_t -= dt
	if _t > 0.0:
		return
	# pericolo dove si trova il giocatore: decide il tetto di creature e il ritmo delle nascite
	var pc := Vector2i(floori(player.position.x / S), floori(player.position.y / S))
	danger = maxf(DangerData.at(world, pc, night, vigor) + event_danger + world_danger, 0.3)
	_t = DangerData.SPAWN_EVERY / maxf(danger, 0.5)
	if _alive() < DangerData.cap(danger):
		try_spawn()


## Le creature che contano per il tetto (non i Guardiani e non quelle chiamate in aiuto).
func _alive() -> int:
	var n := 0
	for c in list:
		if not c.boss and c.master == null and not c.extra:
			n += 1
	return n


## Prova a far nascere una creatura in un punto a caso attorno al giocatore (fuori dalla visuale). Restituisce la
## creatura o null se il punto scelto non andava bene (si riprova al giro dopo).
func try_spawn() -> Creature:
	var pc := Vector2i(floori(player.position.x / S), floori(player.position.y / S))
	if nest_hook.is_valid():
		var ns: Array = nest_hook.call(pc)
		if not ns.is_empty():
			return spawn_at_nest(String(ns[0]), ns[1])
	var ang := _rng.randf() * TAU
	var dist := _rng.randf_range(DangerData.SPAWN_MIN, DangerData.SPAWN_MAX)
	var c := pc + Vector2i(roundi(cos(ang) * dist), roundi(sin(ang) * dist * 0.6))
	if not world.inside(c.x, c.y) or c.y < 2:
		return null
	var stratum := StrataData.at(world, c.x, c.y)
	if world.liq(c.x, c.y) >= 6 and world.liq_type(c.x, c.y) != LiquidsData.BRACE:
		return _spawn_water(c)                          # voce 73: nell'acqua nascono le creature d'acqua
	var biome := "avvizzito" if Blight.surface_blighted(world, c.x) else String(BiomesData.BIOMES[BiomesData.at(world, c.x)]["id"])
	var choices := CreaturesData.of_stratum(stratum, night, biome)
	var weighted := []
	for e in choices:
		var wgt := int(round(float(e[1]) * weight_of(String(e[0]), c.x * S) * 10.0))
		if wgt > 0:
			weighted.append([e[0], wgt])
	choices = weighted if not weighted.is_empty() else choices
	if choices.is_empty():
		return null
	var id := _pick(choices)
	if stratum == 0 and season_creature != "" and _rng.randf() < SeasonsData.SEASONAL_CHANCE:
		id = season_creature                           # voce 66: la creatura della stagione
	if not event_pool.is_empty() and _rng.randf() < 0.6:
		id = String(event_pool[_rng.randi_range(0, event_pool.size() - 1)])   # l'evento sceglie le sue creature
	# voce 55: una variante della specie (taglia, elemento e indole), con l'elemento del luogo più probabile
	id = FamiliesData.roll_variant(id, _rng, elem_bias(stratum, biome), danger)
	var fly: bool = CreaturesData.get_data(id).get("fly", false)
	# uno spazio d'aria di 2×2; chi non vola ha bisogno anche del terreno sotto (lo si cerca scendendo un poco)
	for k in 12:
		var y := c.y + (k if not fly else 0)
		if _free(c.x, y) and (fly or world.solid(c.x, y + 1)):
			if world.torch_near(Vector2i(c.x, y), 8.0):
				return null                # la luce delle torce tiene lontane le creature
			if stratum > 0 and not _dark(Vector2i(c.x, y)):
				return null                # sotto terra si nasce solo al buio
			var cr := add(id, Vector2(c.x * S + 8, (y + 1) * S - CreaturesData.get_data(id)["half"][1] - 0.1))
			var mult := float(StrataData.STRATA[stratum]["danger"]) * vigor_mult
			cr.strengthen(mult, mult * DangerData.DAMAGE)
			var grouped: bool = CreaturesData.get_data(id).has("group")
			var rarity := AncientData.roll_rarity(DangerData.at(world, Vector2i(c.x, y), night, vigor) + event_danger, _rng,
				grouped, rare_mult * event_rare * world_rare)
			if rarity != "":
				make_ancient(cr, rarity)
			if rarity == "capobranco":
				pack(cr, id, mult)
			_group(cr, id, mult)
			return cr
		if fly:
			break
	return null


## Voce 73: una creatura d'acqua in una cella piena di liquido (solo al buio sotto terra, come le altre).
func _spawn_water(c: Vector2i) -> Creature:
	if world.torch_near(c, 8.0) or (StrataData.at(world, c.x, c.y) > 0 and not _dark(c)):
		return null
	var choices := []
	for id in CreaturesData.CREATURES:
		if CreaturesData.CREATURES[id].get("water", false):
			choices.append([id, int(CreaturesData.CREATURES[id]["weight"])])
	if choices.is_empty():
		return null
	var cr := add(_pick(choices), Vector2(c.x * S + 8, c.y * S + 8))
	var mult := float(StrataData.STRATA[StrataData.at(world, c.x, c.y)]["danger"]) * vigor_mult
	cr.strengthen(mult, mult * DangerData.DAMAGE)
	return cr


## Gli sciami (campo `group` in `CreaturesData`): con la prima nascono le compagne, che non contano nel tetto.
func _group(first: Creature, id: String, mult: float) -> void:
	var g: Array = CreaturesData.get_data(id).get("group", [])
	if g.is_empty():
		return
	for k in _rng.randi_range(int(g[0]), int(g[1])) - 1:
		var o := first.position + Vector2(_rng.randf_range(-24, 24), _rng.randf_range(-16, 0))
		var q := Vector2i(floori(o.x / S), floori(o.y / S))
		if world.solid(q.x, q.y):
			continue
		var mb := add(id, o)
		mb.strengthen(mult, mult * DangerData.DAMAGE)
		mb.extra = true


## Il branco di un capobranco: compagne della stessa specie attorno a lui (non contano nel tetto).
func pack(leader: Creature, id: String, mult: float) -> void:
	var span: Array = AncientData.RARITIES["capobranco"]["pack"]
	for k in _rng.randi_range(int(span[0]), int(span[1])):
		var o := leader.position + Vector2(_rng.randf_range(-40, 40), -4)
		if world.solid(floori(o.x / S), floori(o.y / S)):
			o = leader.position
		var mb := add(id, o)
		mb.strengthen(mult, mult * DangerData.DAMAGE)
		mb.extra = true


## Rende rara una creatura (e la annuncia se ancestrale o iridata e vicina).
func make_ancient(cr: Creature, rarity: String, traits: Array = []) -> void:
	cr.ancient = Ancient.new()
	var rd: Dictionary = AncientData.RARITIES[rarity]
	cr.ancient.apply(cr, rarity, traits if not traits.is_empty() or rd["traits"][1] == 0 else AncientData.roll_traits(rarity, _rng))
	if rd.get("iride", false):
		# non attacca e scappa: gli altri comportamenti non servono più
		var fl := BhFugge.new()
		cr.behaviors.clear()
		cr.behaviors.append(fl)
		cr.damage = 0
	if rarity in ["ancestrale", "iridata"] and cr.position.distance_to(player.position) < AncientData.ANNOUNCE * S:
		rare_spawned.emit(cr)


## L'elemento più probabile delle varianti in un luogo (voce 55): dal bioma in superficie, dallo strato sotto terra.
func elem_bias(stratum: int, biome: String) -> String:
	if world_elem != "" and _rng.randf() < 0.5:
		return world_elem                      # l'elemento dei geni del mondo (voce 56)
	if stratum == 0:
		return {"brina": "gelo", "cenere": "brace", "palude": "spora", "ambra": "luce", "foresta": "linfa"}.get(biome, "")
	return ["", "spora", "gelo", "linfa", "vuoto"][clampi(stratum, 0, 4)]


## Una cella è al buio? Fuori dalla finestra della luce si considera buia (è lontana da ogni torcia vista).
func _dark(c: Vector2i) -> bool:
	if light == null:
		return true
	var v := light.value_at(c)
	return v < 0.0 or v < DangerData.DARK


func _free(x: int, y: int) -> bool:
	return not world.solid(x, y) and not world.solid(x, y - 1) and not world.solid(x + 1, y) \
			and not world.solid(x + 1, y - 1)


func _pick(choices: Array) -> String:
	var tot := 0
	for e in choices:
		tot += int(e[1])
	var r := _rng.randi_range(1, tot)
	for e in choices:
		r -= int(e[1])
		if r <= 0:
			return String(e[0])
	return String(choices[0][0])
