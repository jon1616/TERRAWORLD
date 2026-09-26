class_name WorldTraits
extends Node
## Gli effetti dei geni del mondo mentre si gioca (voce 39, geni dalla voce 42: dati in `GenesData`, la parte `run`).
## I geni stanno in `world_meta["geni"]`, scritti quando il mondo nasce da un portale; il mondo casa non ne ha.
## Entrando in un mondo il personaggio **vede** i suoi geni (`Character.genario`: poi le schede dei Semi li mostrano
## per nome); la prima volta una scritta li presenta.

var m: Node2D
var genes: Array = []


func setup(main: Node2D) -> void:
	m = main
	genes = m.world_meta.get("geni", [])
	Genome.local_vigor = int(m.world_meta.get("vigore", 1)) + 1   # i Semi raccolti qui portano al mondo dopo
	for g in genes:
		if Genome.state(String(g)) == 0:
			Genome.known[String(g)] = 1
	apply()
	if not genes.is_empty() and not m.world_meta.get("tratti_visti", false):
		m.world_meta["tratti_visti"] = true
		m.depth_watch.banner.show_stratum(_surface_name(), _names(), Color("#8ef0d8"))


func apply() -> void:
	var e := Genome.effects(genes, "run")
	m.fauna.world_danger = float(e["danger"])
	m.fauna.world_lumini = float(e["lumini"])
	m.fauna.world_rare = float(e["rare"])
	m.garden.grow_mult = float(e["grow"])
	m.day.night_extra = float(e["night"])
	m.events.chance_mult = float(e["events"])
	m.blight.spread_mult = float(e["blight"])
	m.day.night_floor = float(e["aurora"])
	m.fauna.set_world(m.world.world_seed, genes, e["roles"])     # voce 56: le famiglie di questo mondo


func _surface_name() -> String:
	var sg := Genome.surface_of(genes)
	return "Seme di " + String(GenesData.info(sg).get("name", "")).to_lower() if sg != "" else "Seme del Giardino"


func _names() -> String:
	var out := []
	for g in genes:
		var d := GenesData.info(String(g))
		if not d.is_empty() and d["cat"] != "superficie":
			out.append("%s: %s" % [d["name"], d["desc"]])
	return " · ".join(out) if not out.is_empty() else "nessun gene particolare"


## Una riga per la scheda del personaggio.
func sheet_line() -> String:
	if genes.is_empty():
		return ""
	return "Questo mondo: " + Genome.describe({"geni": genes}, true)
