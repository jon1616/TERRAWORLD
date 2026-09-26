class_name SpeciesData
extends RefCounted
## Specie e tratti dei Semi di mondo (voce 39). Solo dati; li usano `Portal` (quando il Seme si pianta), il generatore
## (`GenContext.params["specie"]` e `["tratti"]`) e `WorldTraits` (gli effetti mentre si gioca).
##
## SPECIES   la specie del Seme decide quali biomi crescono in superficie (`biomes`: id di `BiomesData` → peso; il
##           primo è quello attorno alla partenza). Il Seme di mondo del Cuore ha una specie a caso; al Seme si può
##           dare una specie all'Altare, con i materiali del suo bioma (gli oggetti con `species` in `ItemsData`).
## TRAITS    i tratti di un mondo: `gen` agisce sul generatore, `run` mentre si gioca:
##   gen.ore      vene più grandi (soglia dei rumori delle vene abbassata di tanto)
##   gen.ruins    rovine × · gen.gems  grappoli di gemme ×
##   run.danger   pericolo in più (o in meno) ovunque · run.lumini  Lumini dalle creature ×
##   run.rare     creature rare × · run.grow  colture ×  · run.night  notti più lunghe (frazione del giorno)
##   run.events   eventi più frequenti × · run.blight  l'Avvizzimento si allarga ×
##   good         true = un dono, false = una prova (colore della scritta)
## Quanti tratti: uno, più uno ogni due punti di vigore (al massimo `MAX_TRAITS`).

const SPECIES := {
	"lanterna": {"name": "Seme di salice-lanterna", "short": "salice-lanterna",
		"biomes": {"foresta": 6, "palude": 2, "ambra": 2}, "desc": "foreste di alberi-lanterna a perdita d'occhio"},
	"sporangio": {"name": "Seme di sporangio", "short": "sporangio",
		"biomes": {"palude": 6, "foresta": 2, "ambra": 1}, "desc": "paludi di spore quasi ovunque"},
	"resina": {"name": "Seme di resina", "short": "resina",
		"biomes": {"ambra": 6, "foresta": 2, "palude": 1}, "desc": "distese d'ambra, calde e aperte"},
	# voce 40
	"brina": {"name": "Seme di brina", "short": "brina",
		"biomes": {"brina": 6, "foresta": 2, "ambra": 1}, "desc": "boschi gelati e cieli chiari"},
	"cenere": {"name": "Seme di cenere", "short": "cenere",
		"biomes": {"cenere": 6, "ambra": 2, "palude": 1}, "desc": "pianure di cenere e braci"},
}

const TRAITS := {
	"vene_ricche": {"name": "Vene ricche", "desc": "minerali più abbondanti", "gen": {"ore": 0.035}, "good": true},
	"rovine_fitte": {"name": "Rovine fitte", "desc": "molte più stanze dei Seminatori", "gen": {"ruins": 1.6}, "good": true},
	"gemme_ricche": {"name": "Gemme ricche", "desc": "il doppio dei grappoli di gemme", "gen": {"gems": 2.0}, "good": true},
	"iridescente": {"name": "Iridescente", "desc": "creature rare molto più frequenti", "run": {"rare": 2.0}, "good": true},
	"fertile": {"name": "Fertile", "desc": "le colture crescono il 60% più in fretta", "run": {"grow": 1.6}, "good": true},
	"stellato": {"name": "Stellato", "desc": "eventi del cielo molto più frequenti", "run": {"events": 2.2}, "good": true},
	"brulicante": {"name": "Brulicante", "desc": "più creature e più forti, ma il doppio dei Lumini", "run": {"danger": 1.0, "lumini": 2.0}, "good": false},
	"notti_lunghe": {"name": "Notti lunghe", "desc": "la notte dura molto di più", "run": {"night": 0.08}, "good": false},
	"avvizzito": {"name": "Avvizzito", "desc": "l'Avvizzimento si allarga il doppio più in fretta", "run": {"blight": 2.0, "danger": 0.3}, "good": false},
	"quieto": {"name": "Quieto", "desc": "meno creature, e meno Lumini", "run": {"danger": -0.6, "lumini": 0.7}, "good": true},
}

const MAX_TRAITS := 4


## Una specie a caso (per il Seme del Cuore).
static func random_species(rng: RandomNumberGenerator) -> String:
	var keys := SPECIES.keys()
	return String(keys[rng.randi_range(0, keys.size() - 1)])


## I tratti di un mondo nuovo con quel vigore: diversi tra loro, mai «brulicante» e «quieto» insieme.
static func roll_traits(rng: RandomNumberGenerator, vigor: int) -> Array:
	var n := mini(1 + maxi(vigor - 1, 0) / 2, MAX_TRAITS)
	var pool := TRAITS.keys()
	var out := []
	while out.size() < n and not pool.is_empty():
		var t := String(pool[rng.randi_range(0, pool.size() - 1)])
		pool.erase(t)
		if (t == "quieto" and "brulicante" in out) or (t == "brulicante" and "quieto" in out):
			continue
		out.append(t)
	return out


## La somma degli effetti di alcuni tratti in una sezione ("gen" o "run"): i moltiplicatori si moltiplicano, gli altri
## si sommano.
static func effects(traits: Array, section: String) -> Dictionary:
	var e := {"ore": 0.0, "ruins": 1.0, "gems": 1.0, "danger": 0.0, "lumini": 1.0, "rare": 1.0, "grow": 1.0,
		"night": 0.0, "events": 1.0, "blight": 1.0}
	for t in traits:
		var d: Dictionary = TRAITS.get(String(t), {}).get(section, {})
		for k in d:
			if k in ["ore", "danger", "night"]:
				e[k] = float(e[k]) + float(d[k])
			else:
				e[k] = float(e[k]) * float(d[k])
	return e


## «Seme di sporangio · Vene ricche, Notti lunghe» (per la scritta del portale e la scheda).
static func describe(species: String, traits: Array, colored := false) -> String:
	var s := String(SPECIES[species]["name"]) if SPECIES.has(species) else "Seme del Giardino"
	var names := []
	for t in traits:
		if TRAITS.has(String(t)):
			var d: Dictionary = TRAITS[String(t)]
			names.append(("[color=%s]%s[/color]" % ["#8ef0d8" if d["good"] else "#ff9a7a", d["name"]]) if colored else String(d["name"]))
	return s + (" · " + ", ".join(names) if not names.is_empty() else "")
