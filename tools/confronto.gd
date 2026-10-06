extends SceneTree
## Il confronto con Terraria + Calamity + Thorium (6 ott 2026, richiesta dell'utente: «confronta tutto, analizza le
## differenze in termini di profondità»). Conta dai **dati** di TERRAWORLD le stesse cose che lo script dei dati di
## Terraria conta dai suoi file grezzi (cartella TERRARIA MOD): scala, armi con un comportamento proprio, accessori ed
## effetti, creature e loro comportamenti, boss, ricette e catene, economia. Scrive prove/confronto.json.
## Solo dati: niente script di `src/game/` (gli strumenti senza finestra non li caricano).

const WEAPON_KINDS := ["spada", "arco", "bastone", "evocatore", "esplosivo", "giavellotto", "ricurvo"]
const TOOL_KINDS := ["piccone", "ascia", "martello", "trivella"]
const ARMOR_KINDS := ["elmo", "corazza", "gambali", "guanti", "stivali", "mantello"]
const ACC_KINDS := ["accessorio", "amuleto", "anello", "tasca"]


func _init() -> void:
	var out := {}
	var all: Dictionary = ItemsData.all()
	var kinds := {}
	var cats := {}
	for id in all:
		var it: Dictionary = all[id]
		var k := String(it.get("kind", ""))
		kinds[k] = int(kinds.get(k, 0)) + 1
		cats[_cat(it)] = int(cats.get(_cat(it), 0)) + 1
	out["oggetti_totale"] = all.size()
	out["oggetti_per_categoria"] = cats
	out["generati_forma_materiale"] = all.keys().filter(func(id: String) -> bool: return all[id].has("form")).size()
	# ---------------------------------------------------------------- le armi e i loro comportamenti
	var weapons := []
	for id in all:
		if _cat(all[id]) == "arma":
			weapons.append(String(id))
	out["armi"] = weapons.size()
	var forms := {}
	var behaviours := {}
	var twins := {}
	for id in weapons:
		var it: Dictionary = all[id]
		var f := String(it.get("form", it.get("kind", "")))
		forms[f] = int(forms.get(f, 0)) + 1
		# il comportamento: la forma (o il tipo), l'incantesimo, gli effetti speciali propri
		var b := "%s|%s|%s|%s" % [f, String(it.get("spell", "")), ",".join(it.get("effects", [])),
			String(GesturesData.of_mat(String(it.get("mat", ""))).get("name", ""))]      # voce 356: il gesto del materiale
		behaviours[b] = int(behaviours.get(b, 0)) + 1
		var sig := "%s|%s|%s|%s" % [f, str(it.get("damage", 0)), str(it.get("speed", 0)), String(GesturesData.of_mat(String(it.get("mat", ""))).get("name", ""))]
		twins[sig] = int(twins.get(sig, 0)) + 1
	out["armi_per_forma"] = forms
	out["armi_comportamenti_diversi"] = behaviours.size()
	out["armi_comportamento_unico"] = behaviours.values().filter(func(n: int) -> bool: return n == 1).size()
	var tw := 0
	for s in twins:
		if int(twins[s]) > 1:
			tw += int(twins[s])
	out["armi_gemelle"] = tw
	out["armi_con_effetti"] = weapons.filter(func(id: String) -> bool: return not (all[id].get("effects", []) as Array).is_empty()).size()
	out["incantesimi"] = SpellsData.SPELLS.size()
	out["effetti_speciali"] = EffectsData.EFFECTS.size()
	out["modi_del_risveglio"] = AwakenData.FORM.size()
	out["tratti"] = TraitsData.TRAITS.size()
	out["incisioni"] = IncisionsData.LIST.size()
	out["fasce"] = FormsData.FASCE.size()
	out["materiali"] = MaterialsData.all().size()
	# ---------------------------------------------------------------- accessori ed effetti
	var accs := []
	for id in all:
		if _cat(all[id]) == "accessorio":
			accs.append(String(id))
	out["accessori"] = accs.size()
	var acc_sig := {}
	for id in accs:
		var a: Dictionary = all[id].get("acc", {})
		var keys := a.keys()
		keys.sort()
		acc_sig[",".join(keys) + "|" + ",".join(all[id].get("effects", []))] = true
	out["accessori_combinazioni_diverse"] = acc_sig.size()
	var acc_keys := {}
	for id in all:
		for k in (all[id].get("acc", {}) as Dictionary):
			acc_keys[k] = true
	out["chiavi_di_effetto_degli_accessori"] = acc_keys.size()
	out["pezzi_armatura"] = all.keys().filter(func(id: String) -> bool: return _cat(all[id]) == "armatura").size()
	out["set"] = SetsData.all().size()
	out["unici"] = UniqueSeriesData.ITEMS.size() + UniquesData.ITEMS.size()
	out["macchine"] = MachinesData.MACHINES.size()
	out["parole"] = LanguageData.WORDS.size()
	out["stazioni_totali"] = StationsData.STATIONS.size()
	# ---------------------------------------------------------------- creature
	var cr: Dictionary = CreaturesData.CREATURES
	var bosses := 0
	var bh_sigs := {}
	var bh_used := {}
	var hp := []
	var dmg := []
	for id in cr:
		var cd: Dictionary = cr[id]
		if cd.get("boss", false):
			bosses += 1
			continue
		var bl: Array = []
		for b in cd.get("behaviors", cd.get("bh", [])):
			bl.append(str(b if not b is Dictionary else b.get("id", "")))
		bl.sort()
		bh_sigs[",".join(bl)] = true
		for b in bl:
			bh_used[b] = true
		if float(cd.get("hp", 0)) > 0:
			hp.append(float(cd["hp"]))
			dmg.append(float(cd.get("damage", 0)))
	out["creature"] = cr.size()
	out["creature_boss"] = bosses
	out["creature_comportamenti_diversi"] = bh_used.size()
	out["creature_combinazioni_di_comportamenti"] = bh_sigs.size()
	hp.sort()
	dmg.sort()
	out["creature_vita_quartili"] = [hp[hp.size() / 4], hp[hp.size() / 2], hp[hp.size() * 3 / 4]] if not hp.is_empty() else []
	out["creature_danno_quartili"] = [dmg[dmg.size() / 4], dmg[dmg.size() / 2], dmg[dmg.size() * 3 / 4]] if not dmg.is_empty() else []
	out["famiglie"] = FamiliesData.FAMILIES.size()
	out["biomi"] = BiomesData.BIOMES.size()
	out["geni"] = GenesData.GENES.size()
	# ---------------------------------------------------------------- ricette
	var recs: Array = RecipesData.all()
	out["ricette"] = recs.size()
	var stations := {}
	var ning := 0
	var made := {}
	for r in recs:
		stations[String(r.get("station", ""))] = true
		ning += (r["in"] as Dictionary).size()
		if not made.has(String(r["out"])):
			made[String(r["out"])] = (r["in"] as Dictionary).keys()
	out["stazioni_diverse"] = stations.size()
	out["ingredienti_per_ricetta_media"] = snappedf(float(ning) / maxf(recs.size(), 1), 0.01)
	var depths := []
	var memo := {}
	for id in weapons:
		if made.has(id):
			depths.append(_depth(String(id), made, memo, []))
	var tot := 0
	var mx := 0
	for d in depths:
		tot += int(d)
		mx = maxi(mx, int(d))
	out["profondita_ricette_armi_media"] = snappedf(float(tot) / maxf(depths.size(), 1), 0.01)
	out["profondita_ricette_armi_max"] = mx
	out["armi_da_ricetta"] = depths.size()
	# ---------------------------------------------------------------- economia
	var vals := []
	for id in all:
		var v := ValueData.value(String(id))
		if v > 0:
			vals.append(v)
	vals.sort()
	out["valore_quartili_lumini"] = [vals[vals.size() / 4], vals[vals.size() / 2], vals[vals.size() * 3 / 4]]
	var goods := 0
	for n in NpcData.NPCS:
		goods += (NpcData.NPCS[n].get("goods", []) as Array).size()
	out["abitanti"] = NpcData.NPCS.size()
	out["voci_negozi"] = goods
	out["servizi"] = ServicesData.SERVICES.size()
	var f := FileAccess.open("res://prove/confronto.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(out, " "))
	f.close()
	print(JSON.stringify(out, " "))
	quit()


func _depth(id: String, made: Dictionary, memo: Dictionary, seen: Array) -> int:
	if memo.has(id):
		return int(memo[id])
	if not made.has(id) or id in seen:
		return 0
	var best := 0
	for x in made[id]:
		best = maxi(best, _depth(String(x), made, memo, seen + [id]))
	memo[id] = best + 1
	return best + 1


static func _cat(it: Dictionary) -> String:
	var k := String(it.get("kind", ""))
	if k in WEAPON_KINDS or (it.has("form") and String(it.get("form", "")) in ["spada", "pugnale", "spadone", "lancia", "martello", "falcione", "frusta", "arco", "balestra", "verga"]):
		return "arma"
	if k in TOOL_KINDS or String(it.get("form", "")) in ["piccone", "ascia", "trivella"]:
		return "attrezzo"
	if k == "munizione":
		return "munizione"
	if k in ARMOR_KINDS:
		return "armatura"
	if k in ACC_KINDS:
		return "accessorio"
	if k in ["consumabile", "cura", "dono"]:
		return "pozione/cibo"
	if k in ["blocco", "parete", "piattaforma", "stazione", "torcia"] or it.has("place"):
		return "blocco/arredo"
	if k == "materiale":
		return "materiale"
	return "altro"
