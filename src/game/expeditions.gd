class_name Expeditions
extends RefCounted
## Le spedizioni del Cartografo (Roadmap 23, voce 238; tipi in `ExpeditionsData`). Sempre tre aperte, di tipi diversi,
## scelte fra ciò che il personaggio non ha ancora: una meraviglia mai vista, la pagina di bioma più avanti, e i conteggi
## (stelle, segreti, Sigilli, firme) da far salire di poco. Stato in `Character.spedizioni` = {"open": [spedizione],
## "fatte": n}; una spedizione: {"k", "t" (la cosa: meraviglia o pagina), "base" (il conteggio all'inizio), "gene"}.
## `check` (lo chiama `Atlas`) dà il premio e ne apre un'altra. I premi con `seed` portano un Seme di mondo con il gene
## che aiuta la spedizione: la meraviglia che chiama quel gene, o il bioma del suo gene di superficie.

var m: Node2D
var _rng := RandomNumberGenerator.new()


func _init(main: Node2D) -> void:
	m = main
	_rng.randomize()


func data() -> Dictionary:
	var d: Dictionary = m.character.spedizioni
	if not d.has("open"):
		d["open"] = []
	return d


func open_list() -> Array:
	return data()["open"]


## Tiene aperte `OPEN` spedizioni.
func fill() -> void:
	var tries := 0
	while open_list().size() < ExpeditionsData.OPEN and tries < 20:
		tries += 1
		var e := _make()
		if not e.is_empty():
			open_list().append(e)


func _kinds_open() -> Array:
	var out := []
	for e in open_list():
		out.append(String(e["k"]))
	return out


func _make() -> Dictionary:
	var kinds := ExpeditionsData.KINDS.keys().filter(func(k: String) -> bool: return not k in _kinds_open())
	if kinds.is_empty():
		return {}
	var k := String(kinds[_rng.randi_range(0, kinds.size() - 1)])
	var st: Dictionary = m.character.stats
	match k:
		"meraviglia":
			var unseen := WondersData.WONDERS.keys().filter(func(w: String) -> bool: return int(st.get("mer_" + w, 0)) == 0)
			if unseen.is_empty():
				return {}
			var w := String(unseen[_rng.randi_range(0, unseen.size() - 1)])
			var gs: Array = WondersData.WONDERS[w]["genes"]
			return {"k": k, "t": w, "gene": String(gs[_rng.randi_range(0, gs.size() - 1)])}
		"pagina":
			var best := {}
			var best_f := -1.0
			for p in BiomePagesData.pages():
				if int(st.get("pagina_" + String(p["id"]), 0)) == 1:
					continue
				var pr: Array = m.atlas.pages.progress(p)
				var f := float(pr[0]) / float(pr[1]) + _rng.randf() * 0.05
				if f > best_f:
					best_f = f
					best = p
			if best.is_empty():
				return {}
			var gene := ""
			if String(best["kind"]) == "sup":
				gene = String(BiomesData.by_id(String(best["biome"])).get("gene", ""))
			return {"k": k, "t": String(best["id"]), "gene": gene}
	var d: Dictionary = ExpeditionsData.KINDS[k]
	return {"k": k, "base": int(st.get(String(d["stat"]), 0))}


## [fatto, tutto] di una spedizione.
func progress(e: Dictionary) -> Array:
	var st: Dictionary = m.character.stats
	match String(e["k"]):
		"meraviglia":
			return [int(st.get("mer_" + String(e["t"]), 0)), 1]
		"pagina":
			return [int(st.get("pagina_" + String(e["t"]), 0)), 1]
	var d: Dictionary = ExpeditionsData.KINDS[String(e["k"])]
	return [clampi(int(st.get(String(d["stat"]), 0)) - int(e["base"]), 0, int(d["need"])), int(d["need"])]


func title(e: Dictionary) -> String:
	var d: Dictionary = ExpeditionsData.KINDS[String(e["k"])]
	match String(e["k"]):
		"meraviglia":
			return String(d["name"]) % String(WondersData.WONDERS[String(e["t"])]["name"]).to_lower()
		"pagina":
			return String(d["name"]) % String(BiomePagesData.page(String(e["t"])).get("name", e["t"]))
	return String(d["name"]) % str(d["need"])


## Le spedizioni finite (e i premi); poi riempie. Restituisce i titoli delle finite.
func check() -> Array:
	var done := []
	for e in open_list().duplicate():
		var p := progress(e)
		if int(p[0]) < int(p[1]):
			continue
		open_list().erase(e)
		done.append(title(e))
		_reward(e)
	fill()
	return done


func _reward(e: Dictionary) -> void:
	var d: Dictionary = ExpeditionsData.KINDS[String(e["k"])]
	var parts := []
	for it in d["reward"]:
		var rest: int = m.character.bisaccia.add(String(it), int(d["reward"][it]))
		if rest > 0:
			m.drops.spawn(String(it), rest, m.player.position)
		parts.append("%s ×%d" % [String(ItemsData.get_item(String(it)).get("name", it)), int(d["reward"][it])])
	if d.get("seed", false):
		var g := seed_genome(String(e.get("gene", "")))
		var item := Genome.item_of(g)
		if m.character.bisaccia.add_stack({"id": item, "n": 1, "dati": g}) > 0:
			m.drops.spawn(item, 1, m.player.position, g)
		parts.append("un Seme di mondo")
	data()["fatte"] = int(data().get("fatte", 0)) + 1
	m.objectives.bump("spedizioni")
	m.hud.toast("Spedizione compiuta: %s · %s" % [title(e), ", ".join(parts)])
	m.sfx.play("dono")


## Un Seme di mondo con il gene dato (o con un gene raro se non c'è), del vigore più alto visto più uno.
func seed_genome(gene: String) -> Dictionary:
	var v := 2
	for wid in m.character.atlante:
		v = maxi(v, int(m.character.atlante[wid].get("vigore", 1)) + 1)
	if gene == "" or not GenesData.GENES.has(gene):
		return m.board._rare_seed_genome()
	if GenesData.cat_of(gene) == "superficie":
		return Genome.roll(_rng, v, gene)
	var g := Genome.roll(_rng, v)
	var keep := []
	for x in g["geni"]:
		if GenesData.cat_of(String(x)) != GenesData.cat_of(gene):
			keep.append(x)
	keep.append(gene)
	g["geni"] = Genome.sort(keep)
	return g
