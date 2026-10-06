class_name GeneMaterials
extends Node
## I materiali dei geni mentre si gioca (voce 53, dati in `MaterialsData.GENE_MATERIALS`): nei mondi con il gene giusto,
## scavando certe tessere (o in cielo) o sconfiggendo creature, a volte cade il materiale grezzo.
## Roadmap 39, voce 363: lo stesso per i metalli del Risveglio (`SpineData.METALS`): dopo il Risveglio del Cuore
## (`stats["risveglio_cuore"]`), nei mondi di vigore giusto (da `vigor` per `SpineData.KEEP` vigori; l'ultimo per
## sempre), scavando la roccia dello strato giusto o sconfiggendo creature antiche.

const S := 16

var m: Node2D
var active: Array = []                 # i materiali dei geni di questo mondo
var spine: Array = []                  # voce 363: i metalli del Risveglio di questo mondo
var found := 0                         # quanti ne sono caduti (per le prove)
var _rng := RandomNumberGenerator.new()


func setup(main: Node2D) -> void:
	m = main
	_rng.randomize()
	m.actions.dig_hook = on_dig
	m.fauna.killed.connect(on_kill)
	refresh()


## Quali materiali dei geni ci sono in questo mondo (da `WorldTraits.genes`).
func refresh() -> void:
	active.clear()
	var genes: Array = m.world_traits.genes
	for g in MaterialsData.GENE_MATERIALS:
		for x in MaterialsData.GENE_MATERIALS[g]["genes"]:
			if x in genes and not g in active:
				active.append(g)
	spine = spine_for(int(m.world_meta.get("vigore", 1)), int(m.character.stats.get("risveglio_cuore", 0)) >= 1)


## I metalli del Risveglio che si trovano in un mondo di questo vigore.
static func spine_for(v: int, awake: bool) -> Array:
	var out := []
	if not awake:
		return out
	var last := ""
	for g in SpineData.METALS:
		last = String(g)
	for g in SpineData.METALS:
		var v0 := int(SpineData.METALS[g]["raw"]["vigor"])
		if v >= v0 and (v < v0 + SpineData.KEEP or g == last):
			out.append(String(g))
	return out


func on_dig(t: int, c: Vector2i) -> void:
	var dep: int = c.y - m.world.surface[clampi(c.x, 0, m.world.w - 1)]
	for g in active:
		var raw: Dictionary = MaterialsData.GENE_MATERIALS[g]["raw"]
		if not raw.has("tiles") or not t in raw["tiles"]:
			continue
		if raw.get("sky", false):
			if dep > -12:
				continue
		elif dep < int(raw.get("min_depth", 0)):
			continue
		if _rng.randf() < float(raw["chance"]):
			_drop(String(raw["id"]), Vector2(c) * S + Vector2(8, 8))
	if spine.is_empty():
		return
	var st := StrataData.at(m.world, c.x, c.y)
	for g in spine:
		var sr: Dictionary = SpineData.METALS[g]["raw"]
		if t in sr["tiles"] and st >= int(sr["stratum"]) and _rng.randf() < float(sr["chance"]):
			_drop(String(sr["id"]), Vector2(c) * S + Vector2(8, 8))


func on_kill(c: Creature) -> void:
	if not spine.is_empty() and c.ancient:
		var g := String(spine[_rng.randi_range(0, spine.size() - 1)])
		var sr: Dictionary = SpineData.METALS[g]["raw"]
		if _rng.randf() < float(sr["ancient"]):
			_drop(String(sr["id"]), c.position)
	for g in active:
		var raw: Dictionary = MaterialsData.GENE_MATERIALS[g]["raw"]
		var k := String(raw.get("kill", ""))
		if k == "" or (k == "ancient" and not c.ancient):
			continue
		if _rng.randf() < float(raw["chance"]):
			_drop(String(raw["id"]), c.position)


func _drop(id: String, at: Vector2) -> void:
	m.drops.spawn(id, 1, at)
	found += 1
