extends SceneTree
## Lo strumento della vastità (voce 359, Roadmap 38; piano in `VASTITA.md`): quanti oggetti di ogni tipo arrivano in
## ogni blocco di fasi della partita, quanti gesti diversi, quante gemelle; quante creature per bioma e per strato;
## quanti oggetti propri ha ogni fonte. Li mette accanto alle curve di Terraria + Calamity + Thorium (misurate il 6 ott
## 2026 dai dati della cartella TERRARIA MOD) e scrive in cima i **buchi**. Ogni Roadmap del piano si chiude con questa
## misura. Solo dati. → prove/vastita.txt

## Terraria + 2 mod, per blocchi di sei fasi della spina dei boss (0-5, 6-11, 12-17, 18-23).
const TR_WEAPONS := [554, 583, 433, 215]
const TR_ACCESSORIES := [427, 320, 149, 53]
const TR_ARMOR := [229, 172, 135, 46]
const BANDS := ["fasi 0-5", "fasi 6-11", "fasi 12-17", "fasi 18-23"]
const LOW := 0.3                        # sotto il 30% di Terraria in un blocco: buco

var _lines: Array[String] = []


func _init() -> void:
	var all: Dictionary = ItemsData.all()
	var bands := []
	for b in 4:
		bands.append({"armi": 0, "accessori": 0, "armature": 0, "consumabili": 0, "altro": 0, "gesti": {}, "per_forma": {}})
	var phase_count := {}
	for id in all:
		var it: Dictionary = all[id]
		var f := PhasesData.of(String(id))
		phase_count[f] = int(phase_count.get(f, 0)) + 1
		var b: Dictionary = bands[clampi(f / 6, 0, 3)]
		var cat := _cat(it)
		b[cat] = int(b.get(cat, 0)) + 1
		if cat == "armi":
			var form := String(it.get("form", it.get("kind", "")))
			(b["per_forma"] as Dictionary)[form] = int(b["per_forma"].get(form, 0)) + 1
			var g := "%s|%s|%s|%s" % [form, String(it.get("spell", "")), ",".join(it.get("effects", [])),
				String(GesturesData.of_mat(String(it.get("mat", ""))).get("name", ""))]
			(b["gesti"] as Dictionary)[g] = true
	# i buchi
	var holes := []
	for i in 4:
		var b: Dictionary = bands[i]
		for pair in [["armi", TR_WEAPONS], ["accessori", TR_ACCESSORIES], ["armature", TR_ARMOR]]:
			var have := int(b[pair[0]])
			var want := int(pair[1][i])
			if have < want * LOW:
				holes.append("%s: %s %d contro %d di Terraria (%d%%)" % [BANDS[i], pair[0], have, want, roundi(100.0 * have / maxf(want, 1))])
	_p("LO STRUMENTO DELLA VASTITÀ (voce 359): TERRAWORLD per blocchi di fasi, accanto a Terraria + Calamity + Thorium")
	_p("")
	_p("1. I BUCHI (sotto il %d%% di Terraria)" % roundi(LOW * 100))
	if holes.is_empty():
		_p("   nessuno")
	for h in holes:
		_p("   " + h)
	_p("")
	_p("2. PER BLOCCO DI FASI")
	for i in 4:
		var b: Dictionary = bands[i]
		_p("   %-11s armi %4d (Terraria %4d) · gesti diversi %4d · accessori %4d (%4d) · armature %4d (%4d) · consumabili %4d" % [
			BANDS[i], int(b["armi"]), TR_WEAPONS[i], (b["gesti"] as Dictionary).size(), int(b["accessori"]), TR_ACCESSORIES[i],
			int(b["armature"]), TR_ARMOR[i], int(b["consumabili"])])
	_p("")
	_p("3. OGGETTI PER FASE (tutti i tipi)")
	var keys := phase_count.keys()
	keys.sort()
	for f in keys:
		_p("   fase %2d %-24s %5d  %s" % [int(f), PhasesData.phase_name(int(f)), int(phase_count[f]), "#".repeat(mini(int(phase_count[f]) / 10, 60))])
	_p("")
	_p("4. LE CREATURE PER STRATO E PER BIOMA (senza boss)")
	var per_stratum := [0, 0, 0, 0, 0]
	var per_biome := {}
	for cid in CreaturesData.CREATURES:
		var cd: Dictionary = CreaturesData.CREATURES[cid]
		if cd.get("boss", false):
			continue
		for s in cd.get("strata", []):
			per_stratum[clampi(int(s), 0, 4)] += 1
		for bi in cd.get("biomes", []):
			per_biome[String(bi)] = int(per_biome.get(String(bi), 0)) + 1
	for s in 5:
		_p("   %-24s %3d specie" % [StrataData.STRATA[s]["name"], per_stratum[s]])
	var thin := []
	for bi in per_biome:
		if int(per_biome[bi]) < 8:
			thin.append("%s %d" % [bi, int(per_biome[bi])])
	_p("   biomi con meno di 8 specie proprie (Terraria: mediana 8): %s" % (", ".join(thin) if not thin.is_empty() else "nessuno"))
	_p("")
	_p("5. LE FONTI: oggetti diversi che lascia un Guardiano (Terraria: ~20 a boss)")
	for g in GuardiansData.LIST:
		var cd: Dictionary = CreaturesData.CREATURES.get(String(g["creature"]), {})
		var items := {}
		# la tabella della creatura, il suo Sacchetto e le spoglie (Roadmap 41 e 44)
		var bag := ItemsData.get_item("sacchetto_" + String(g["id"]))
		for t in [String(cd.get("loot", "")), String(bag.get("table", "")), "armatura_" + String(g["id"])]:
			for e in LootData.TABLES.get(t, []):
				items[String(e["item"])] = true
		_p("   %-28s %2d oggetti" % [String(cd.get("name", g["creature"])), items.size()])
	var f := FileAccess.open("res://prove/vastita.txt", FileAccess.WRITE)
	f.store_string("\n".join(_lines) + "\n")
	f.close()
	quit()


func _p(s: String) -> void:
	_lines.append(s)
	print(s)


static func _cat(it: Dictionary) -> String:
	var k := String(it.get("kind", ""))
	if k in ["spada", "arco", "bastone", "evocatore", "esplosivo", "giavellotto", "ricurvo", "lancio", "strumento", "ramo",
			"semeguerra"] or String(it.get("form", "")) in ["spada", "pugnale", "spadone", "lancia", "martello", "falcione", "frusta", "arco", "balestra", "verga"]:
		return "armi"
	if k in ["accessorio", "amuleto", "anello", "tasca"]:
		return "accessori"
	if k in ["elmo", "corazza", "gambali", "guanti", "stivali", "mantello"]:
		return "armature"
	if k in ["consumabile", "cura", "dono"]:
		return "consumabili"
	return "altro"
