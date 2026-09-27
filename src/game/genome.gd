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
## Probabilità di mutazione: di un Seme selvatico (da una pianta-seme) e di un innesto (voce 47).
const WILD_MUTATION := 0.08
const MUTATION := 0.08
## Peso in più, nelle mutazioni, dei geni che nascono solo così.
const ONLY_BOOST := 3
## Innesto (voce 47): quando i due genitori hanno geni diversi nella stessa categoria il figlio ne eredita uno (secondo
## la dominanza) con `INHERIT_BOTH`, altrimenti nessuno; se ce l'ha un solo genitore, lo eredita con `INHERIT_ONE`.
const INHERIT_BOTH := 0.9
const INHERIT_ONE := 0.65
## Voce 48: se i genitori portano insieme i due geni di una combinazione, la mutazione è più probabile e dà quel gene.
const COMBO_CHANCE := 0.35


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


## Un gene a caso fuori dalla superficie, tra quelli che si trovano (per gli scrigni delle rovine).
static func random_gene(rng: RandomNumberGenerator, vigor_v: int) -> String:
	var pool := []
	for g in GenesData.GENES:
		if GenesData.cat_of(g) != "superficie":
			pool.append(g)
	return _pick(rng, pool, vigor_v)


## Forse una mutazione (con probabilità `chance`): un gene che nessuno dei genitori aveva prende il posto di quello
## della sua categoria. I geni che nascono solo per mutazione pesano `ONLY_BOOST` volte di più; quelli della firma no.
## Il gene mutato resta scritto nel Seme ("mutato") per la scheda. Voce 48: le combinazioni segrete.
## `locked`: categorie che non si toccano (quelle fissate da una Fiala nell'innesto).
static func mutate(g: Dictionary, rng: RandomNumberGenerator, chance: float, forced := "", locked := []) -> Dictionary:
	var out := g.duplicate(true)
	var x := forced
	if x != "" and GenesData.cat_of(x) in locked:
		x = ""
	if x == "":
		if rng.randf() >= chance:
			return out
		var tot := 0
		var pool := []
		for k in GenesData.GENES:
			var d: Dictionary = GenesData.GENES[k]
			if String(d.get("only", "")) in ["firma", "stagione"] or k in genes(g) or String(d["cat"]) in locked:
				continue
			var wgt: int = int(GenesData.RARITY[int(d["rar"])]["weight"]) * (ONLY_BOOST if d.has("only") or d.has("combo") else 1)
			pool.append([k, wgt])
			tot += wgt
		if pool.is_empty():
			return out
		var v := rng.randi_range(1, tot)
		for p in pool:
			v -= int(p[1])
			if v <= 0:
				x = String(p[0])
				break
	var cat := GenesData.cat_of(x)
	var kept := genes(g).filter(func(k: String) -> bool: return GenesData.cat_of(k) != cat)
	kept.append(x)
	out["geni"] = sort(kept)
	out["mutato"] = x
	return out


static func _in_cat(gs: Array, cat: String) -> String:
	for g in gs:
		if GenesData.cat_of(String(g)) == cat:
			return String(g)
	return ""


## Le probabilità dell'innesto di a e b, con le Fiale `fixed` (geni): per ogni categoria che può avere un gene,
## [[gene o "" (nessuno), probabilità], …], che sommano a 1. La mutazione si aggiunge dopo (`mutation_chance`).
static func odds(a: Dictionary, b: Dictionary, fixed: Array) -> Dictionary:
	var out := {}
	var fix := {}
	for v in fixed:
		fix[GenesData.cat_of(String(v))] = String(v)
	for cat in GenesData.CATEGORIES:
		if fix.has(cat):
			out[cat] = [[fix[cat], 1.0]]
			continue
		var ga := _in_cat(genes(a), cat)
		var gb := _in_cat(genes(b), cat)
		if ga == "" and gb == "":
			continue
		if ga == gb:
			out[cat] = [[ga, 1.0]]
		elif ga != "" and gb != "":
			var da := float(GenesData.GENES[ga]["dom"])
			var db := float(GenesData.GENES[gb]["dom"])
			var keep := 1.0 if cat == "superficie" else INHERIT_BOTH
			out[cat] = [[ga, keep * da / (da + db)], [gb, keep * db / (da + db)]]
			if keep < 1.0:
				out[cat].append(["", 1.0 - keep])
		else:
			var one := ga if ga != "" else gb
			out[cat] = [[one, 1.0]] if cat == "superficie" else [[one, INHERIT_ONE], ["", 1.0 - INHERIT_ONE]]
	return out


## [probabilità di mutazione, gene della combinazione dei genitori o ""].
static func mutation_chance(a: Dictionary, b: Dictionary) -> Array:
	var both := genes(a) + genes(b)
	for g in GenesData.GENES:
		var combo: Array = GenesData.GENES[g].get("combo", [])
		if combo.size() == 2 and combo[0] in both and combo[1] in both and not g in both:
			return [COMBO_CHANCE, g]
	return [MUTATION, ""]


## Il vigore del figlio: quello del genitore più forte (i Semi senza vigore fissato valgono quello di qui).
static func child_vigor(a: Dictionary, b: Dictionary) -> int:
	var va := vigor(a) if vigor(a) > 0 else local_vigor
	var vb := vigor(b) if vigor(b) > 0 else local_vigor
	return maxi(va, vb)


## L'innesto: il Seme figlio di a e b (con le Fiale `fixed`), forse mutato.
static func cross(a: Dictionary, b: Dictionary, fixed: Array, rng: RandomNumberGenerator) -> Dictionary:
	var od := odds(a, b, fixed)
	var out := []
	for cat in od:
		var r := rng.randf()
		for e in od[cat]:
			r -= float(e[1])
			if r < 0.0:
				if String(e[0]) != "":
					out.append(String(e[0]))
				break
	var child := {"geni": sort(out), "vigore": child_vigor(a, b)}
	var mc := mutation_chance(a, b)
	if rng.randf() < float(mc[0]):
		var locked := fixed.map(func(v: String) -> String: return GenesData.cat_of(v))
		child = mutate(child, rng, 1.0, String(mc[1]), locked)
	return child


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
static func fresh_for_item(id: String, from: RandomNumberGenerator = null) -> Dictionary:
	if String(ItemsData.get_item(id).get("kind", "")) != "seme_mondo":
		return {}
	var rng := from
	if rng == null:
		rng = RandomNumberGenerator.new()
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
	var lg := Legends.of_genes(gs)                # voce 81: i Semi leggendari e il Seme Primo
	if g.get("primo", false):
		s = "[color=#ffe8a0]Seme Primo[/color]" if colored else "Seme Primo"
	elif lg != "":
		s = ("[color=#ffd08a]%s[/color]" if colored else "%s") % Legends.name_of(lg)
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
	if g.has("mutato"):
		t += "[color=#d890ff]Mutato: porta un gene che i genitori non avevano (%s)[/color]\n" % GenesData.tag(String(g["mutato"]))
	if g.get("primo", false):
		t += "[color=#ffe8a0]Il Seme Primo: il mondo di tutti i biomi, il più vigoroso[/color]\n"
	elif Legends.of_genes(genes(g)) != "":
		t += "[color=#ffd08a]Seme leggendario: %s[/color]\n" % LegendsData.LEGENDS[Legends.of_genes(genes(g))]["desc"]
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
