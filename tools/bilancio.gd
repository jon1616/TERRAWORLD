extends SceneTree
## Il bilancio su una pagina (voce 83): le curve di potenza del gioco, per vedere salti e buchi. Senza finestra:
##   Godot_console.exe --headless --path . --script res://tools/bilancio.gd
## Scrive prove/bilancio.txt e lo stampa:
##   1. armi: danno medio per forma e per grado del materiale (dal Telaio al fine gioco)
##   2. armature: Scorza del set completo per materiale
##   3. creature: Vita e danno medi per strato, per vigore (1, 2, 3, 5, 10, 20), con i colpi per sconfiggerle con l'arma
##      del grado atteso in quello strato, e i colpi che il Germogliato regge
##   4. ricette: quanti materiali grezzi servono in media per grado
## I segni «!» indicano un salto oltre il doppio tra un grado e il successivo.

var out := ""
const VIGOR_STEP := 0.35               # come `Portal.VIGOR_STEP` (Portal non si carica senza finestra: usa `Session`)


func _init() -> void:
	_weapons()
	_armor()
	_creatures()
	_recipes()
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
			var mult: float = danger * (1.0 + VIGOR_STEP * (int(v) - 1))
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
