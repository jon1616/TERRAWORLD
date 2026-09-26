class_name WorldTraits
extends Node
## Gli effetti dei tratti del mondo mentre si gioca (voce 39, dati in `SpeciesData`): la specie e i tratti stanno in
## `world_meta` ("specie", "tratti"), scritti quando il mondo nasce da un portale; il mondo casa non ne ha. Entrando
## la prima volta in un mondo con dei tratti, una scritta li presenta.

var m: Node2D
var species := ""
var traits: Array = []


func setup(main: Node2D) -> void:
	m = main
	species = String(m.world_meta.get("specie", ""))
	traits = m.world_meta.get("tratti", [])
	apply()
	if (species != "" or not traits.is_empty()) and not m.world_meta.get("tratti_visti", false):
		m.world_meta["tratti_visti"] = true
		m.depth_watch.banner.show_stratum(SpeciesData.describe(species, []), _names(), Color("#8ef0d8"))


func apply() -> void:
	var e := SpeciesData.effects(traits, "run")
	m.fauna.world_danger = float(e["danger"])
	m.fauna.world_lumini = float(e["lumini"])
	m.fauna.world_rare = float(e["rare"])
	m.garden.grow_mult = float(e["grow"])
	m.day.night_extra = float(e["night"])
	m.events.chance_mult = float(e["events"])
	m.blight.spread_mult = float(e["blight"])


func _names() -> String:
	var out := []
	for t in traits:
		if SpeciesData.TRAITS.has(String(t)):
			out.append("%s: %s" % [SpeciesData.TRAITS[t]["name"], SpeciesData.TRAITS[t]["desc"]])
	return " · ".join(out) if not out.is_empty() else "nessun tratto"


## Una riga per la scheda del personaggio.
func sheet_line() -> String:
	if species == "" and traits.is_empty():
		return ""
	return "Questo mondo: " + SpeciesData.describe(species, traits, true)
