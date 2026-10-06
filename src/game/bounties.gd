class_name Bounties
extends Node
## Le taglie (Roadmap 25, voce 249; dati in `BountiesData`). In `Character.taglie` = {"open": [taglia], "fatte": n,
## "registro": [[nome, specie, vigore]]}; una taglia: {"cr", "nome", "tratto", "strato", "bioma", "vigore"}.
## Ogni `CHECK` secondi: se nel mondo di adesso (vigore abbastanza) il Germogliato è nello strato (e nel bioma) di una
## taglia e la sua preda non c'è, la preda nasce poco lontano, ancestrale con il suo tratto e più forte. Sconfitta:
## premio, registro, conteggio «taglie», e il Cacciatore ne propone un'altra.

var m: Node2D
var prey: Creature = null
var prey_i := -1
var _t := 2.0
var _rng := RandomNumberGenerator.new()


func setup(main: Node2D) -> void:
	m = main
	_rng.randomize()
	m.fauna.killed.connect(_on_kill)
	fill()


func data() -> Dictionary:
	var d: Dictionary = m.character.taglie
	if not d.has("open"):
		d["open"] = []
	return d


func open_list() -> Array:
	return data()["open"]


func fill() -> void:
	if int(m.character.stats.get("guardiani", 0)) < 1:
		return                                  # il Cacciatore arriva dopo il primo Guardiano
	var tries := 0
	while open_list().size() < BountiesData.OPEN and tries < 40:
		tries += 1
		var b := _make()
		if not b.is_empty():
			open_list().append(b)


## Una taglia nuova: una creatura comune (non boss) di uno strato che ha, del vigore di adesso o poco più.
func _make() -> Dictionary:
	var ids := CreaturesData.CREATURES.keys()
	for tries in 60:
		var cid := String(ids[_rng.randi_range(0, ids.size() - 1)])
		var c: Dictionary = CreaturesData.CREATURES[cid]
		var strata: Array = c.get("strata", [])
		if int(c.get("weight", 0)) <= 0 or c.get("boss", false) or c.has("lord") or c.has("perduto") or c.has("sky") \
				or c.has("water") or strata.is_empty() or c.get("docile", false):
			continue
		var st := int(strata[_rng.randi_range(0, strata.size() - 1)])
		var biome := ""
		if st == 0:
			var bs: Array = c.get("biomes", [])
			if bs.is_empty():
				continue
			biome = String(bs[_rng.randi_range(0, bs.size() - 1)])
		var tr := String(AncientData.TRAITS.keys()[_rng.randi_range(0, AncientData.TRAITS.size() - 1)])
		var vig := maxi(1, int(m.world_meta.get("vigore", 1)) + _rng.randi_range(0, 2))
		return {"cr": cid, "nome": "%s %s" % [BountiesData.NAMES[_rng.randi_range(0, BountiesData.NAMES.size() - 1)],
			BountiesData.TITLES.get(tr, "")], "tratto": tr, "strato": st, "bioma": biome, "vigore": vig}
	return {}


## Dove cercarla, a parole.
func where_text(b: Dictionary) -> String:
	var t := String(StrataData.STRATA[int(b["strato"])]["name"])
	if String(b["bioma"]) != "":
		t += ", " + BiomesData.name_of(String(b["bioma"]))
	return "%s, in un mondo di vigore %d o più" % [t, int(b["vigore"])]


func title(b: Dictionary) -> String:
	return "%s (%s)" % [b["nome"], String(CreaturesData.get_data(String(b["cr"]))["name"]).to_lower()]


## Il Germogliato è nel posto di questa taglia?
func here(b: Dictionary) -> bool:
	if int(m.world_meta.get("vigore", 1)) < int(b["vigore"]) or (m.get("beauty") != null and m.beauty.home()):
		return false
	if m.depth_watch.stratum != int(b["strato"]):
		return false
	if String(b["bioma"]) != "":
		var bi: int = m.depth_watch.biome
		return bi >= 0 and bi < BiomesData.BIOMES.size() and String(BiomesData.BIOMES[bi]["id"]) == String(b["bioma"])
	return true


func _process(dt: float) -> void:
	if m == null or not m.built:
		return
	_t -= dt
	if _t > 0.0:
		return
	_t = BountiesData.CHECK
	if prey != null and (not is_instance_valid(prey) or not m.fauna.list.has(prey)):
		prey = null
	if prey != null:
		return
	for i in open_list().size():
		if here(open_list()[i]):
			spawn(i)
			return


## Fa nascere la preda della taglia i, poco lontano dal Germogliato.
func spawn(i: int) -> Creature:
	var b: Dictionary = open_list()[i]
	var pc: Vector2i = m.player_cell()
	for tries in 30:
		var dx := _rng.randi_range(BountiesData.SPAWN_DIST[0], BountiesData.SPAWN_DIST[1]) * (1 if _rng.randf() < 0.5 else -1)
		var c := pc + Vector2i(dx, 0)
		for dy in range(-8, 9):
			var q := c + Vector2i(0, dy)
			if m.fauna._free(q.x, q.y) and m.world.solid(q.x, q.y + 1):
				var cr: Creature = m.fauna.add(String(b["cr"]), Vector2(q.x * 16 + 8, (q.y + 1) * 16 - CreaturesData.get_data(String(b["cr"]))["half"][1] - 0.1))
				m.fauna.make_ancient(cr, "ancestrale", [String(b["tratto"])])
				var vm: float = m.fauna.vigor_mult           # come le altre creature del mondo
				cr.strengthen(BountiesData.HP * vm, BountiesData.DAMAGE * float(m.fauna.vigor_dmg))
				cr.set_meta("taglia", String(b["nome"]))
				if cr.ancient and cr.ancient.get("_label") != null:
					cr.ancient._label.text = "Taglia · %s" % b["nome"]
				prey = cr
				prey_i = i
				m.hud.toast("La taglia è qui vicino: %s" % title(b))
				m.sfx.play("presenza")
				return cr
	return null


func _on_kill(c: Creature) -> void:
	if not c.has_meta("taglia"):
		return
	var name := String(c.get_meta("taglia"))
	for b in open_list().duplicate():
		if String(b["nome"]) != name:
			continue
		open_list().erase(b)
		data()["fatte"] = int(data().get("fatte", 0)) + 1
		var reg: Array = data().get("registro", [])
		reg.append([String(b["nome"]), String(b["cr"]), int(b["vigore"])])
		data()["registro"] = reg
		var gift := BountiesData.REWARD.duplicate()
		gift["scheggia_vigore"] = int(gift["scheggia_vigore"]) + mini(int(data()["fatte"]) / 5 * BountiesData.REWARD_STEP, 4)
		m.hud.toast("Taglia riscossa: %s · %s" % [b["nome"], Lineage._give(m, gift)])
		m.objectives.bump("taglie")
		m.sfx.play("dono")
		fill()
		break
	prey = null
