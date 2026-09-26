class_name Genome
extends RefCounted
## Le regole del genoma dei Semi di mondo (voce 42; dati in `GenesData`). Un genoma è un dizionario
## {"geni": [id…], "vigore": n}: un gene di superficie, al più un gene per ogni altra categoria, e il vigore del mondo
## che nascerà (0 = «quello del mondo dove si pianta, più uno», per i Semi di prima delle Aiuole).
## Il genoma sta nei "dati" della casella della Bisaccia (voce 41) e, piantato, nel portale (`world_meta["portali"]`);
## il mondo nato lo porta in `world_meta["geni"]`, il generatore in `GenContext.params["geni"]`.
## Un solo motore per tutto il piano: lo stesso codice servirà alle creature allevate e ai Guardiani generati.

## Il vigore dei Semi che nascono in questo mondo (quello del mondo più uno): lo imposta `main` quando il mondo si
## carica. Un Seme raccolto qui porta al mondo successivo.
static var local_vigor := 2
## I geni conosciuti dal personaggio (`Character.genario`: gene → 1 visto, 2 imparato), per le schede.
static var known := {}
## Le categorie che cambiano la forma del mondo: un Seme trovato ne ha sempre una.
const SHAPE_CATS := ["forma", "grotte", "sottosuolo"]


## Un genoma a caso per un Seme trovato: la superficie data (o a caso), sempre un gene che cambia la forma del mondo
## (forma, grotte o sottosuolo: due mondi non devono mai sembrare lo stesso con numeri diversi), più alcuni geni
## secondo il vigore.
static func roll(rng: RandomNumberGenerator, vigor: int, surface := "") -> Dictionary:
	if GenesData.cat_of(surface) != "superficie":
		surface = _pick(rng, GenesData.of_cat("superficie"), vigor)
	var out := [surface]
	var cats := GenesData.CATEGORIES.duplicate()
	cats.erase("superficie")
	var shape := String(SHAPE_CATS[rng.randi_range(0, SHAPE_CATS.size() - 1)])
	var sg := _pick(rng, GenesData.of_cat(shape), vigor)
	if sg != "":
		out.append(sg)
		cats.erase(shape)
	var n := mini(1 + maxi(vigor - 1, 0) / 2, GenesData.MAX_EXTRA) + out.size() - 1
	while out.size() < n + 1 and not cats.is_empty():
		var cat := String(cats[rng.randi_range(0, cats.size() - 1)])
		cats.erase(cat)
		var g := _pick(rng, GenesData.of_cat(cat), vigor)
		if g != "":
			out.append(g)
	return {"geni": sort(out), "vigore": vigor}


## Un gene a caso tra quelli dati, pesato dalla rarità; mai quelli che si ottengono solo in altri modi, mai quelli
## che vogliono un vigore più alto.
static func _pick(rng: RandomNumberGenerator, pool: Array, vigor: int) -> String:
	var tot := 0
	var ok := []
	for g in pool:
		var d := GenesData.info(String(g))
		if d.has("only") or vigor < int(d.get("vmin", 0)):
			continue
		ok.append(g)
		tot += int(GenesData.RARITY[int(d["rar"])]["weight"])
	if ok.is_empty():
		return ""
	var v := rng.randi_range(1, tot)
	for g in ok:
		v -= int(GenesData.RARITY[int(GenesData.info(String(g))["rar"])]["weight"])
		if v <= 0:
			return String(g)
	return String(ok[-1])


## I geni in ordine di categoria (la superficie per prima): due genomi uguali si confrontano con ==.
static func sort(genes: Array) -> Array:
	var out := genes.duplicate()
	out.sort_custom(func(a: String, b: String) -> bool:
		return GenesData.CATEGORIES.find(GenesData.cat_of(a)) < GenesData.CATEGORIES.find(GenesData.cat_of(b)))
	return out


static func genes(g: Dictionary) -> Array:
	return g.get("geni", [])


static func vigor(g: Dictionary) -> int:
	return int(g.get("vigore", 0))


## Il gene di superficie ("" se manca).
static func surface_of(genes: Array) -> String:
	for x in genes:
		if GenesData.cat_of(String(x)) == "superficie":
			return String(x)
	return ""


## L'oggetto Seme che porta questo genoma (il Seme della sua superficie; «Seme di mondo» se non ce n'è uno suo).
static func item_of(g: Dictionary) -> String:
	var it := String(GenesData.info(surface_of(genes(g))).get("item", ""))
	return it if it != "" else "seme_mondo"


## Specie e tratti di prima (voce 39) come geni: la specie è già il gene di superficie; dei tratti resta il primo di
## ogni categoria.
static func from_legacy(species: String, traits: Array, vigor_v: int) -> Dictionary:
	var out := []
	if GenesData.cat_of(species) == "superficie":
		out.append(species)
	var used := {}
	for t in traits:
		var cat := GenesData.cat_of(String(t))
		if cat != "" and not used.has(cat):
			used[cat] = true
			out.append(String(t))
	return {"geni": sort(out), "vigore": vigor_v}


## Il genoma nuovo di un oggetto appena entrato nella Bisaccia ({} se non è un Seme di mondo).
static func fresh_for_item(id: String) -> Dictionary:
	if String(ItemsData.get_item(id).get("kind", "")) != "seme_mondo":
		return {}
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	return roll(rng, local_vigor, GenesData.of_item(id))


## La somma degli effetti di alcuni geni in una sezione ("gen" o "run"), partendo dai valori neutri.
static func effects(gs: Array, section: String) -> Dictionary:
	var e: Dictionary = (GenesData.DEFAULTS[section] as Dictionary).duplicate(true)
	for g in gs:
		var d: Dictionary = GenesData.info(String(g)).get(section, {})
		for k in d:
			var v: Variant = d[k]
			if k in GenesData.MUL:
				e[k] = float(e.get(k, 1.0)) * float(v)
			elif v is bool:
				e[k] = bool(e.get(k, false)) or v
			elif v is Array:
				e[k] = (e.get(k, []) as Array) + v
			elif v is Dictionary:
				var merged: Dictionary = (e.get(k, {}) as Dictionary).duplicate()
				merged.merge(v, true)
				e[k] = merged
			else:
				e[k] = float(e.get(k, 0.0)) + float(v)
	return e


## Stato di un gene per il personaggio: 0 mai visto, 1 visto (in un mondo o in un Seme), 2 imparato (voce 46).
static func state(g: String) -> int:
	return int(known.get(g, 0))


## «Seme di sporangio · Vene ricche, Notti lunghe»: i geni non ancora visti sono «?».
static func describe(g: Dictionary, colored := false) -> String:
	var gs := genes(g)
	var s := String(ItemsData.get_item(item_of(g)).get("name", "Seme di mondo"))
	var names := []
	for x in gs:
		if GenesData.cat_of(String(x)) == "superficie":
			continue
		if state(String(x)) == 0:
			names.append("[color=#6a8a84]?[/color]" if colored else "?")
		else:
			names.append(GenesData.tag(String(x)) if colored else String(GenesData.info(String(x))["name"]))
	return s + (" · " + ", ".join(names) if not names.is_empty() else "")


## La scheda di un genoma per la casella Esamina: vigore e una riga per gene (categoria, nome, cosa fa).
static func sheet(g: Dictionary) -> String:
	var v := vigor(g)
	var t := ""
	if g.has("mondo"):
		t += "[color=#ffd24a]Seme dormiente: ripiantato, riapre «%s»[/color]\n" % g.get("nome", "il suo mondo")
	t += "[color=#8ef0d8]Genoma[/color] · [color=#9fc8c0]%s[/color]\n" % (("vigore %d" % v) if v > 0
		else "vigore del mondo dove lo pianti, più uno")
	for x in genes(g):
		var d := GenesData.info(String(x))
		var ci: Dictionary = GenesData.CAT_INFO[String(d["cat"])]
		if state(String(x)) == 0 and d["cat"] != "superficie":
			t += "[color=%s]%s[/color]: [color=#6a8a84]? — un gene mai visto[/color]\n" % [ci["color"], ci["name"]]
		else:
			t += "[color=%s]%s[/color]: %s [color=#6a8a84](%s)[/color] — %s\n" % [ci["color"], ci["name"], GenesData.tag(String(x)),
				GenesData.RARITY[int(d["rar"])]["name"], d["desc"]]
	return t
