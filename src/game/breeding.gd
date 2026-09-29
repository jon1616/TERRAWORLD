class_name Breeding
extends RefCounted
## L'allevamento (voce 60, dati in `BreedData`): le doti delle creature della mandria e come passano ai figli.
## Due creature della stessa famiglia, messe in coppia nel pannello della mandria (livello `MIN_LVL` o più), nello
## stesso recinto, sazie e contente: dopo `BREED_TIME` secondi c'è un uovo nella mangiatoia (`Pens.breed`). Il figlio
## (`child`) prende la specie, la taglia, l'elemento e l'indole da uno dei due, i numeri dalla media più un poco di
## caso, il manto secondo le regole di `BreedData`. `odds` fa nascere 400 figli di prova per mostrare che cosa può
## uscire da una coppia (il pannello lo scrive prima di decidere).


## Le doti di una creatura presa in natura: numeri vicini a 1, a volte un manto comune.
static func wild(rng: RandomNumberGenerator) -> Dictionary:
	var d := {"gen": 0, "manto": ""}
	for k in BreedData.STATS:
		d[k] = snappedf(rng.randf_range(0.9, 1.1), 0.01)
	if rng.randf() < 0.15:
		d["manto"] = ["chiaro", "scuro", "fulvo", "muschiato"][rng.randi_range(0, 3)]
	return d


## Si possono mettere in coppia? "" se sì, altrimenti il perché.
static func can_pair(a: Dictionary, b: Dictionary) -> String:
	if int(a["uid"]) == int(b["uid"]):
		return "Serve un'altra creatura"
	if Herd.family_of(a) != Herd.family_of(b):
		return "Solo creature della stessa famiglia fanno coppia"
	if int(a["lvl"]) < BreedData.MIN_LVL or int(b["lvl"]) < BreedData.MIN_LVL:
		return "Per fare coppia servono creature di livello %d o più" % BreedData.MIN_LVL
	return ""


## Un figlio: {specie (con la variante), doti}.
static func child(a: Dictionary, b: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var ga: Dictionary = a.get("doti", {})
	var gb: Dictionary = b.get("doti", {})
	var gen := maxi(int(ga.get("gen", 0)), int(gb.get("gen", 0))) + 1
	var d := {"gen": gen}
	for k in BreedData.STATS:
		var v := (float(ga.get(k, 1.0)) + float(gb.get(k, 1.0))) * 0.5 + rng.randf_range(-BreedData.DRIFT, BreedData.DRIFT)
		if rng.randf() < BreedData.JUMP:
			v += BreedData.JUMP_SIZE
		d[k] = snappedf(clampf(v, float(BreedData.STATS[k]["min"]), float(BreedData.STATS[k]["max"])), 0.01)
	d["manto"] = _coat(String(ga.get("manto", "")), String(gb.get("manto", "")), gen, rng)
	var giant: bool = ga.get("gigante", false) or gb.get("gigante", false)
	if rng.randf() < (0.3 if giant else BreedData.GIANT * (1.0 + 0.2 * gen)):
		d["gigante"] = true
	# la specie e la variante: ogni parte da uno dei due, a volte nuova
	var pa := FamiliesData.parts(String(a["specie"]))
	var pb := FamiliesData.parts(String(b["specie"]))
	var parts := []
	var pools := [[], FamiliesData.SIZES.keys(), FamiliesData.ELEM_ADJ.keys(), FamiliesData.TEMPERS.keys()]
	for i in 4:
		var p: String = pa[i] if rng.randf() < 0.5 else pb[i]
		if i > 0 and rng.randf() < BreedData.PART_MUT:
			var pool: Array = pools[i].duplicate()
			pool.append("")
			p = String(pool[rng.randi_range(0, pool.size() - 1)])
		parts.append(p)
	var sp := FamiliesData.variant_id(parts[0], parts[1], parts[2], parts[3])
	d.merge(Lineage.of_child(a, b, sp))              # voce 241: la stirpe
	return {"specie": sp, "doti": d}


static func _coat(ca: String, cb: String, gen: int, rng: RandomNumberGenerator) -> String:
	# un genitore raro passa il suo manto (di più se lo hanno tutti e due)
	for c in [ca, cb]:
		if BreedData.is_rare(c) and rng.randf() < BreedData.RARE_INHERIT * (1.6 if ca == cb else 1.0):
			return c
	# un manto raro nuovo: più facile nelle stirpi lunghe
	for c in BreedData.COATS:
		var cd: Dictionary = BreedData.COATS[c]
		if cd.get("rare", false) and gen >= int(cd.get("min_gen", 0)) \
				and rng.randf() < float(cd["chance"]) * (1.0 + BreedData.RARE_GEN * gen):
			return c
	# i comuni: da un genitore, o nuovo
	var common := [ca, cb].filter(func(c: String) -> bool: return c != "" and not BreedData.is_rare(c))
	if not common.is_empty() and rng.randf() < 0.7:
		return String(common[rng.randi_range(0, common.size() - 1)])
	for c in BreedData.COATS:
		var cd: Dictionary = BreedData.COATS[c]
		if c != "" and not cd.get("rare", false) and rng.randf() < float(cd["chance"]):
			return c
	return ""


## Una dote con i bonus del manto e del gigante (1 = come la specie).
static func mult(g: Dictionary, k: String) -> float:
	var v := float(g.get(k, 1.0))
	v *= float(BreedData.coat(String(g.get("manto", ""))).get("bonus", {}).get(k, 1.0))
	if g.get("gigante", false):
		v *= float(BreedData.GIANT_BONUS.get(k, 1.0))
	return v * Lineage.mult(g)                        # voce 241: la stirpe pura


## Il disegno: manto e grandezza per `VariantArt`.
static func mods(g: Dictionary) -> Dictionary:
	var out := {}
	if String(g.get("manto", "")) != "":
		out["manto"] = String(g["manto"])
	if g.get("gigante", false):
		out["gigante"] = true
	return out


## 400 figli di prova (sempre gli stessi per la stessa coppia): manti, giganti, varianti, numeri.
static func odds(a: Dictionary, b: Dictionary) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(str(a["uid"]) + "~" + str(b["uid"]))
	var coats := {}
	var species := {}
	var giants := 0
	var lo := {}
	var hi := {}
	const N := 400
	for i in N:
		var c := child(a, b, rng)
		var g: Dictionary = c["doti"]
		coats[g["manto"]] = int(coats.get(g["manto"], 0)) + 1
		species[c["specie"]] = int(species.get(c["specie"], 0)) + 1
		if g.get("gigante", false):
			giants += 1
		for k in BreedData.STATS:
			lo[k] = minf(float(lo.get(k, 9.0)), float(g[k]))
			hi[k] = maxf(float(hi.get(k, 0.0)), float(g[k]))
	return {"n": N, "manti": coats, "specie": species, "giganti": giants, "min": lo, "max": hi}


## Che cosa può nascere da una coppia, in BBCode (per il pannello).
static func preview(a: Dictionary, b: Dictionary) -> String:
	var o := odds(a, b)
	var n := float(o["n"])
	var t := "[color=#ffd08a]Figli di %s e %s[/color]\n" % [a["nome"], b["nome"]]
	var parts := []
	for k in BreedData.STATS:
		parts.append("%s ×%.2f–%.2f" % [BreedData.STATS[k]["name"], float(o["min"][k]), float(o["max"][k])])
	t += "[color=#9fc8c0]%s[/color]\n" % " · ".join(parts)
	var coats := []
	var keys: Array = (o["manti"] as Dictionary).keys()
	keys.sort_custom(func(x: String, y: String) -> bool: return int(o["manti"][x]) > int(o["manti"][y]))
	for c in keys:
		var p := 100.0 * int(o["manti"][c]) / n
		var col := "#ffd24a" if BreedData.is_rare(c) else "#cfeee4"
		coats.append("[color=%s]%s %s[/color]" % [col, BreedData.coat(c)["name"], _pct(p)])
	t += "[color=#9fc8c0]Manto:[/color] %s\n" % ", ".join(coats)
	if int(o["giganti"]) > 0:
		t += "[color=#ffd24a]Gigante %s[/color]\n" % _pct(100.0 * int(o["giganti"]) / n)
	var sp := []
	for s in o["specie"]:
		if int(o["specie"][s]) >= n * 0.05:
			sp.append("%s %s" % [String(CreaturesData.get_data(String(s))["name"]).to_lower(), _pct(100.0 * int(o["specie"][s]) / n)])
	t += "[color=#6a8a84]Più probabili: %s[/color]\n" % ", ".join(sp)
	return t


static func _pct(p: float) -> String:
	return "%d%%" % roundi(p) if p >= 1.0 else "<1%"


## Le doti in BBCode (scheda della creatura).
static func sheet(g: Dictionary) -> String:
	var parts := []
	for k in BreedData.STATS:
		parts.append("%s ×%.2f" % [BreedData.STATS[k]["name"], mult(g, k)])
	var c := String(g.get("manto", ""))
	var t := "[color=#8ef0d8]Doti:[/color] [color=#9fc8c0]%s[/color]\n" % " · ".join(parts)
	var extra := []
	if c != "":
		extra.append(("[color=#ffd24a]manto %s (raro)[/color]" if BreedData.is_rare(c) else "manto %s") % BreedData.coat(c)["name"])
	if g.get("gigante", false):
		extra.append("[color=#ffd24a]gigante[/color]")
	extra.append("generazione %d" % int(g.get("gen", 0)))
	return t + "[color=#9fc8c0]%s[/color]\n" % " · ".join(extra) + Lineage.sheet(g)
