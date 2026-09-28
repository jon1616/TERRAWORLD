extends SceneTree
## Il bilancio su una pagina (voce 83): le curve di potenza del gioco, per vedere salti e buchi. Senza finestra:
##   Godot_console.exe --headless --path . --script res://tools/bilancio.gd
## Scrive prove/bilancio.txt e lo stampa:
##   1. armi: danno medio per forma e per grado del materiale (dal Telaio al fine gioco)
##   2. armature: Scorza del set completo per materiale
##   3. creature: Vita e danno medi per strato, per vigore (1, 2, 3, 5, 10, 20), con i colpi per sconfiggerle con l'arma
##      del grado atteso in quello strato, e i colpi che il Germogliato regge
##   4. ricette: quanti materiali grezzi servono in media per grado
##   5. pesca (voce 125): per alcuni specchi e canne, con e senza esca: attesa, pesci all'ora, quanti rari, Lumini all'ora
## I segni «!» indicano un salto oltre il doppio tra un grado e il successivo.

var out := ""
const VIGOR_STEP := 0.35               # come `Portal.VIGOR_STEP` (Portal non si carica senza finestra: usa `Session`)


func _init() -> void:
	_weapons()
	_armor()
	_creatures()
	_recipes()
	_fishing()
	_world15()
	var f := FileAccess.open("res://prove/bilancio.txt", FileAccess.WRITE)
	if f:
		f.store_string(out)
		f.close()
	print(out)
	print("scritto in prove/bilancio.txt")
	quit()


func _p(t: String) -> void:
	out += t + "\n"


## Il danno medio delle armi di un grado (per forma).
func _weapons() -> void:
	_p("1. ARMI: danno medio per forma e grado del materiale")
	var table := {}                    # forma -> grado -> [somma, n]
	for id in ItemsData.all():
		var it: Dictionary = ItemsData.get_item(String(id))
		if not it.has("form") or not it.has("mat") or float(it.get("damage", 0)) <= 0.0:
			continue
		var tier := int(MaterialsData.get_mat(String(it["mat"])).get("tier", 0))
		var d := float(Gear.stats({"id": String(id)})["damage"])
		var f := String(it["form"])
		if not table.has(f):
			table[f] = {}
		var e: Array = table[f].get(tier, [0.0, 0])
		table[f][tier] = [float(e[0]) + d, int(e[1]) + 1]
	for f in table:
		var tiers: Array = (table[f] as Dictionary).keys()
		tiers.sort()
		var row := "   %-12s" % f
		var prev := 0.0
		for t in tiers:
			var e: Array = table[f][t]
			var avg := float(e[0]) / int(e[1])
			row += "  g%d %5.1f%s" % [t, avg, "!" if prev > 0.0 and avg > prev * 2.0 else " "]
			prev = avg
		_p(row)
	_p("")


func _armor() -> void:
	_p("2. ARMATURE: Scorza del set (elmo, corazza, gambali) per materiale")
	for mat in MaterialsData.MATERIALS:
		var tot := 0.0
		for piece in ["elmo", "corazza", "gambali"]:
			tot += float(ItemsData.get_item("%s_%s" % [piece, mat]).get("defense", 0))
		_p("   %-12s grado %d   Scorza %5.1f" % [mat, int(MaterialsData.MATERIALS[mat]["tier"]), tot])
	_p("")


## L'arma attesa in uno strato: la spada del grado dello strato (strato 0 → grado 1 …).
func _sword(tier: int) -> float:
	for mat in MaterialsData.MATERIALS:
		if int(MaterialsData.MATERIALS[mat]["tier"]) == tier:
			var it := ItemsData.get_item("spada_" + mat)
			if not it.is_empty():
				return float(Gear.stats({"id": "spada_" + mat})["damage"])
	return 0.0


func _creatures() -> void:
	_p("3. CREATURE: media per strato × vigore — Vita, danno, colpi per sconfiggerle (spada del grado atteso), colpi che reggi (Vita 100)")
	for s in StrataData.STRATA.size():
		var hp := 0.0
		var dmg := 0.0
		var n := 0
		for cid in CreaturesData.CREATURES:
			var c: Dictionary = CreaturesData.CREATURES[cid]
			if c.get("boss", false) or not s in c.get("strata", []):
				continue
			hp += float(c["hp"])
			dmg += float(c["damage"])
			n += 1
		if n == 0:
			continue
		hp /= n
		dmg /= n
		var danger := float(StrataData.STRATA[s]["danger"])
		var sword := _sword(s + 1)
		var row := "   %-26s (%d specie)" % [StrataData.STRATA[s]["name"], n]
		for v in [1, 2, 3, 5, 10, 20]:
			var mult: float = danger * VigorData.creature_mult(int(v))
			var h: float = hp * mult
			var d: float = dmg * mult * DangerData.DAMAGE
			row += "  v%d: %d/%d %s|%s" % [v, roundi(h), roundi(d), str(ceili(h / sword)) if sword > 0.0 else "?", str(ceili(100.0 / maxf(d, 1.0)))]
		_p(row)
	_p("   (v = vigore; Vita/danno; colpi per sconfiggerla | colpi che il Germogliato regge senza Scorza)")
	_p("")


func _recipes() -> void:
	_p("4. RICETTE: materiali grezzi medi per oggetto, per grado del materiale")
	var sums := {}
	for r in RecipesData.all():
		var it := ItemsData.get_item(String(r["out"]))
		if not it.has("mat"):
			continue
		var tier := int(MaterialsData.get_mat(String(it["mat"])).get("tier", 0))
		var tot := 0
		for k in r["in"]:
			tot += int(r["in"][k])
		var e: Array = sums.get(tier, [0, 0])
		sums[tier] = [int(e[0]) + tot, int(e[1]) + 1]
	var tiers := sums.keys()
	tiers.sort()
	for t in tiers:
		_p("   grado %d: %.1f materiali per oggetto (%d ricette)" % [t, float(sums[t][0]) / int(sums[t][1]), int(sums[t][1])])


## Voce 125: i numeri della pesca (senza fatica dello specchio né tempo atmosferico). Un lancio costa l'attesa media, la
## presa e un paio di secondi per rilanciare; il valore è quello del commercio (`FishData.RARITY`).
func _fishing() -> void:
	_p("5. PESCA: attesa media, pesci all'ora, rari e leggendari su cento, Lumini all'ora (il Pescatore paga un terzo)")
	var spots := [
		["stagno della foresta", {"liq": 0, "stratum": 0, "biome": "foresta", "depth": 5, "volume": 60.0}],
		["stagno delle torbiere", {"liq": 0, "stratum": 0, "biome": "torba", "depth": 4, "volume": 60.0}],
		["grotta delle Caverne", {"liq": 0, "stratum": 2, "biome": "foresta", "depth": 4, "volume": 60.0}],
		["lago di Linfa", {"liq": 1, "stratum": 3, "biome": "foresta", "depth": 5, "volume": 80.0}],
		["lago di brace", {"liq": 2, "stratum": 4, "biome": "foresta", "depth": 5, "volume": 80.0}],
	]
	var rods := [["canna_radice", ""], ["canna_radicite", ""], ["canna_ambra", "esca_squama"], ["canna_stellare", "esca_iridata"]]
	for sp in spots:
		var ctx: Dictionary = sp[1]
		ctx.merge({"night": false, "season": "germoglio", "weather": "sereno", "genes": []})
		var line := "   %-22s" % sp[0]
		for rb in rods:
			var it := ItemsData.get_item(String(rb[0]))
			if not int(ctx["liq"]) in (it.get("fish_liq", [0]) as Array):
				line += " | %s: —" % rb[0]
				continue
			var luck := float(it.get("fish", 0.0))
			var wait := (Fishing.WAIT[0] + Fishing.WAIT[1]) / 2.0 * float(it.get("fish_speed", 1.0))
			if String(rb[1]) != "":
				var bt: Dictionary = ItemsData.get_item(String(rb[1]))["bait"]
				luck += float(bt["luck"])
				wait *= float(bt["wait"])
			var pool := FishData.pool(ctx, luck)
			var tot := 0.0
			var rare := 0.0
			var value := 0.0
			for e in pool:
				tot += float(e[1])
			for e in pool:
				var r := String(FishData.info(String(e[0]))["rar"])
				var p := float(e[1]) / tot
				if r in ["raro", "leggendario"]:
					rare += p
				value += p * float(FishData.RARITY[r]["value"])
			var per_hour := 3600.0 / (wait + Fishing.BITE + 2.0)
			line += " | %s%s: %.1f s, %d/h, rari %.1f%%, %d Lumini/h" % [String(rb[0]).trim_prefix("canna_"),
				("+" + String(rb[1]).trim_prefix("esca_")) if String(rb[1]) != "" else "", wait, roundi(per_hour), rare * 100.0,
				roundi(per_hour * value / 3.0)]
		_p(line)
	_p("   (con uno specchio stanco l'attesa arriva a ×%.1f; la fatica scende di 1 ogni %d s)" % [1.0 + FishingData.TIRE_WAIT * FishingData.TIRE_MAX,
		roundi(FishingData.TIRE_RECOVER)])


## Roadmap 15 «Il mondo abitato»: i Signori e i tre Guardiani contro la spada del grado atteso (colpi per sconfiggerli,
## secondi a 2,5 colpi al secondo), le maree, i costrutti, gli arredi, le stanze.
func _world15() -> void:
	_p("6. IL MONDO ABITATO (Roadmap 15)")
	var lords := 0
	var rows := []
	for cid in CreaturesData.CREATURES:
		var c: Dictionary = CreaturesData.CREATURES[cid]
		if not (c.has("lord") or c.has("great")):
			continue
		lords += 1
		var hp := float(c["hp"])
		var sword := _sword(3 if int(c["hp"]) < 1000 else 4)
		var hits := ceili(hp / maxf(sword, 1.0))
		rows.append("   %-34s Vita %4d  danno %2d  colpi %3d (~%d s)  furia: %s" % [c["name"], int(c["hp"]), int(c["damage"]), hits,
			roundi(hits / 2.5), ", ".join(c.get("fury", []))])
	rows.sort()
	for r in rows:
		_p(r)
	_p("   Signori e Guardiani: %d. Le maree: %d (%s)" % [lords, TidesData.TIDES.size(), ", ".join(TidesData.TIDES.keys())])
	_p("   costrutti: %d (%d materiali × %d forme); arredi: %d; progetti dei Seminatori: %d; tipi di stanza: %d" % [
		BuildData.kinds().size(), BuildData.MATERIALS.size(), BuildData.FORMS.size(), FurnitureData.stations().size(),
		ProjectsData.PROJECTS.size(), RoomsData.ORDER.size()])
	var n_species := 0
	for f in BiomesData.PACK_FILES:
		n_species += ((f.DATA as Dictionary).get("creatures", {}) as Dictionary).size()
	_p("   creature in tutto: %d (dei pacchetti: %d); famiglie: %d; astuzie: %d" % [CreaturesData.CREATURES.size(), n_species,
		FamiliesData.FAMILIES.size(), WilesData.WILES.size()])
	_p("")

