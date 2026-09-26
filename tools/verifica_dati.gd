extends SceneTree
## Verifica dei contenuti (come `verifica_dati` di Inkblood): controlla che le tabelle di `src/data/` si reggano a
## vicenda e salva il foglio di tutte le icone in prove/oggetti.png per vederle a colpo d'occhio.
##   Godot_console.exe --headless --path . --script res://tools/verifica_dati.gd
## ERRORE = qualcosa di rotto (riferimento a un oggetto che non esiste…); AVVISO = probabilmente da sistemare
## (oggetto che non si può ottenere, materiale che non serve a nulla…).

const KINDS := ["materiale", "blocco", "piccone", "ascia", "spada", "arco", "munizione", "torcia", "stazione",
	"piattaforma", "elmo", "corazza", "gambali", "consumabile", "seme", "lanterna", "cura", "seme_mondo", "accessorio",
	"purifica", "essenza", "bastone", "dono", "specchio", "trofeo", "richiamo", "reliquia", "mappa", "rampino", "esplosivo", "ricurvo",
	"giavellotto", "coltura", "annaffiatoio", "parete", "martello", "moneta", "compagno", "evocatore", "ricordo", "provetta", "fiala"]
## Forza di piccone oltre cui una tessera è voluta indistruttibile (i nodi avvizziti: si curano, non si scavano).
const UNBREAKABLE := 999

var errors := 0
var warnings := 0


func _init() -> void:
	var items := ItemsData.all()
	var recipes := RecipesData.all()
	# 1. oggetti ben formati, icone disegnabili
	for id in items:
		var it: Dictionary = items[id]
		_err(String(it.get("name", "")) != "", "%s senza nome" % id)
		_err(String(it.get("kind", "")) in KINDS, "%s: tipo sconosciuto «%s»" % [id, it.get("kind", "")])
		# voci 37 e 39: compagni, alleati e specie dei Semi devono esistere nelle loro tabelle
		_err(not it.has("pet") or CompanionsData.PETS.has(it["pet"]), "%s: compagno sconosciuto «%s»" % [id, it.get("pet", "")])
		_err(not it.has("ally") or CompanionsData.ALLIES.has(it["ally"]), "%s: alleato sconosciuto «%s»" % [id, it.get("ally", "")])
		_err(not it.has("species") or GenesData.cat_of(String(it["species"])) == "superficie", "%s: gene di superficie sconosciuto «%s»" % [id, it.get("species", "")])
		_err(it.has("icon") and (it["icon"] as Array).size() == 2, "%s: icona non indicata" % id)
		if it.has("icon"):
			_err(ItemIcons.has_palette(String(it["icon"][1])), "%s: materiale dell'icona sconosciuto «%s»" % [id, it["icon"][1]])
		if it.get("kind") == "blocco":
			_err(it.get("place", -1) is int and int(it["place"]) > 0 and int(it["place"]) <= TileDefs.TYPES, "%s: blocco senza tessera valida" % id)
		if it.get("kind") == "stazione":
			_err(StationsData.STATIONS.has(String(it.get("place", ""))), "%s: stazione sconosciuta" % id)
		if it.get("kind") == "bastone":
			_err(SpellsData.SPELLS.has(String(it.get("spell", ""))) and int(it.get("linfa", 0)) > 0, "%s: bastone senza incantesimo o costo" % id)
		if it.get("kind") == "dono":
			_err(it.has("gift") and int(it.get("gift_max", 0)) > 0, "%s: dono senza effetto" % id)
		if it.get("kind") in ["piccone", "ascia"]:
			_err(int(it.get("power", 0)) > 0, "%s: attrezzo senza forza" % id)
	# 2. ricette
	var made := {}
	for r in recipes:
		var out: String = r["out"]
		_err(items.has(out), "ricetta per un oggetto inesistente: %s" % out)
		_err(int(r.get("qty", 0)) > 0, "ricetta di %s con quantità nulla" % out)
		_err(String(r["station"]) == "" or StationsData.STATIONS.has(String(r["station"])), "ricetta di %s: stazione sconosciuta «%s»" % [out, r["station"]])
		for k in r["in"]:
			_err(items.has(k), "ricetta di %s usa un oggetto inesistente: %s" % [out, k])
			_err(k != out, "ricetta di %s usa sé stesso" % out)
		made[out] = true
	# 3. stazioni
	for s in StationsData.STATIONS:
		var st: Dictionary = StationsData.STATIONS[s]
		if st.get("fixed", false):
			continue                           # Cuore e portale: nascono dal mondo, non da una ricetta
		_err(items.has(String(st["item"])), "stazione %s: oggetto inesistente %s" % [s, st["item"]])
		_warn(made.has(String(st["item"])) or ItemsData.OTHER_SOURCES.has(String(st["item"])),
			"stazione %s: nessuna ricetta la costruisce" % s)
	# 4. tessere, decorazioni, creature, bottino
	var dropped := {}
	for t in TileDefs.DROP:
		_err(items.has(String(TileDefs.DROP[t])), "la tessera %d lascia un oggetto inesistente: %s" % [t, TileDefs.DROP[t]])
		dropped[TileDefs.DROP[t]] = true
	for d in TileDefs.DECOR_DROP:
		_err(items.has(String(TileDefs.DECOR_DROP[d])), "la decorazione %d lascia un oggetto inesistente" % d)
		dropped[TileDefs.DECOR_DROP[d]] = true
	for t in range(1, TileDefs.TYPES + 1):
		_err(TileDefs.DROP.has(t), "la tessera %d non lascia nulla" % t)
		_err(TileDefs.POWER.has(t) and TileDefs.HARD.has(t), "la tessera %d non ha durezza o forza richiesta" % t)
	for c in CreaturesData.CREATURES:
		var cr: Dictionary = CreaturesData.CREATURES[c]
		_err(LootData.TABLES.has(String(cr["loot"])), "creatura %s: tabella di bottino inesistente %s" % [c, cr["loot"]])
		_err(int(cr.get("hp", 0)) > 0, "creatura %s senza vita" % c)
	for tb in LootData.TABLES:
		for e in LootData.TABLES[tb]:
			_err(items.has(String(e["item"])), "bottino %s: oggetto inesistente %s" % [tb, e["item"]])
			_err(float(e["chance"]) > 0.0 and float(e["chance"]) <= 1.0, "bottino %s: probabilità fuori da 0-1" % tb)
			_err(int(e["min"]) <= int(e["max"]), "bottino %s: min maggiore di max" % tb)
			dropped[e["item"]] = true
	# Custodi (voce 27): creatura, richiamo e pagina esistono
	for k in KeepersData.KEEPERS:
		var kd: Dictionary = KeepersData.KEEPERS[k]
		_err(CreaturesData.CREATURES.has(String(kd["creature"])), "Custode %s: creatura inesistente" % k)
		_err(items.has(String(kd["summon"])), "Custode %s: richiamo inesistente" % k)
		_err(LoreData.PAGES.has(String(kd["page"])), "Custode %s: pagina di storia inesistente" % k)
		_err(StationsData.STATIONS.has("bozzolo_" + k), "Custode %s: bozzolo inesistente" % k)
	# giardino (voce 33): semi e raccolti esistono
	for k in CropsData.CROPS:
		var cd: Dictionary = CropsData.CROPS[k]
		_err(items.has(String(cd["seed"])), "coltura %s: seme inesistente" % k)
		for h in cd["harvest"]:
			_err(items.has(String(h)), "coltura %s: raccolto inesistente %s" % [k, h])
			dropped[h] = true
	for wd in CropsData.WILD:
		dropped[wd[1]] = true
	# abitanti (voce 36): le merci esistono e hanno un prezzo
	for nid in NpcData.NPCS:
		for g in NpcData.NPCS[nid]["goods"]:
			_err(items.has(String(g[0])), "abitante %s: merce inesistente %s" % [nid, g[0]])
	# trofei (voce 23): ogni creatura non Guardiano ne ha uno, esiste e serve a qualcosa
	for cid in CreaturesData.CREATURES:
		if not CreaturesData.CREATURES[cid].get("boss", false):
			_warn(TrophyItemsData.TROPHY_OF.has(cid), "la creatura %s non ha un trofeo" % cid)
	for cid in TrophyItemsData.TROPHY_OF:
		var tid := String(TrophyItemsData.TROPHY_OF[cid])
		_err(CreaturesData.CREATURES.has(cid), "trofeo di una creatura inesistente: %s" % cid)
		_err(items.has(tid), "trofeo inesistente: %s" % tid)
		_warn(not RecipesData.using(tid).is_empty(), "il trofeo %s non serve a nessuna ricetta" % tid)
		dropped[tid] = true
	dropped["polvere_iridata"] = true
	dropped["stellina"] = true                  # cade dal cielo durante la Pioggia di stelle (voce 34)
	for k in EventsData.EVENTS:
		var ev: Dictionary = EventsData.EVENTS[k]
		_err(not ev.has("reward") or LootData.TABLES.has(String(ev["reward"])), "evento %s: bottino inesistente" % k)
		for cid in ev.get("pool", []):
			_err(CreaturesData.CREATURES.has(String(cid)), "evento %s: creatura inesistente %s" % [k, cid])
	for c in RelicsData.COLLECTIONS:
		for p in RelicsData.COLLECTIONS[c]["pieces"]:
			_err(items.has(String(p)), "reliquia inesistente: %s" % p)
			dropped[p] = true
	for id in items:
		if items[id].has("spell"):
			_err(SpellsData.SPELLS.has(String(items[id]["spell"])), "%s: incantesimo sconosciuto" % id)
	# 5. ogni oggetto si può ottenere; ogni materiale serve a qualcosa
	for id in items:
		var ok: bool = made.has(id) or dropped.has(id) or ItemsData.OTHER_SOURCES.has(id) or items[id].has("source")
		_warn(ok, "%s non si può ottenere (né ricetta, né scavo, né bottino)" % id)
		if items[id].get("kind") == "materiale":
			_warn(not RecipesData.using(id).is_empty(), "il materiale %s non serve a nessuna ricetta" % id)
	# 6. progressione: ogni minerale si stacca con un piccone che si può fabbricare con minerali più facili
	var best_power := {}
	for id in items:
		if items[id].get("kind") == "piccone":
			best_power[id] = int(items[id]["power"])
	for t in TileDefs.POWER:
		var need := int(TileDefs.POWER[t])
		if need >= UNBREAKABLE:
			continue
		var any := false
		for id in best_power:
			if best_power[id] >= need:
				any = true
		_err(any, "nessun piccone riesce a scavare la tessera %d (serve forza %d)" % [t, need])
	# 7. obiettivi: oggetti, stazioni e creature citati esistono, le ricompense pure
	for o in ObjectivesData.LIST:
		var c: Dictionary = o["check"]
		_err(not c.has("item") or items.has(String(c["item"])), "obiettivo %s: oggetto sconosciuto" % o["id"])
		_err(not c.has("station") or StationsData.STATIONS.has(String(c["station"])), "obiettivo %s: stazione sconosciuta" % o["id"])
		_err(not c.has("kill") or CreaturesData.CREATURES.has(String(c["kill"])), "obiettivo %s: creatura sconosciuta" % o["id"])
		for a in c.get("any", []):
			_err(items.has(String(a)), "obiettivo %s: oggetto sconosciuto %s" % [o["id"], a])
		for r in o["reward"]:
			_err(items.has(String(r)), "obiettivo %s: ricompensa sconosciuta %s" % [o["id"], r])
	_icon_sheet(items)
	_creature_sheet()
	_station_sheet()
	print("oggetti %d · ricette %d · stazioni %d · creature %d · tabelle di bottino %d" % [items.size(), recipes.size(),
		StationsData.STATIONS.size(), CreaturesData.CREATURES.size(), LootData.TABLES.size()])
	_check_species()
	_check_materials()
	print("ESITO: %d errori, %d avvisi" % [errors, warnings])
	quit()


func _icon_sheet(items: Dictionary) -> void:
	var cols := 10
	var ids := items.keys()
	var cell := 56
	var rows := ceili(ids.size() / float(cols))
	var sheet := Image.create_empty(cols * cell, rows * cell, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("#0c1a20"))
	for i in ids.size():
		var ic := ItemIcons.of(ids[i])
		ic.resize(48, 48, Image.INTERPOLATE_NEAREST)
		sheet.blend_rect(ic, Rect2i(0, 0, 48, 48), Vector2i((i % cols) * cell + 4, (i / cols) * cell + 4))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://prove"))
	sheet.save_png(ProjectSettings.globalize_path("res://prove/oggetti.png"))
	var order := ""
	for i in ids.size():
		order += ("\n" if i % cols == 0 else " · ") + String(ids[i])
	print("foglio delle icone in prove/oggetti.png, in ordine:", order)


## Il foglio di tutte le creature (ogni fotogramma, ingrandito ×3, con la parte luminosa sopra) in prove/creature.png.
func _creature_sheet() -> void:
	var cell := Vector2i(160, 90)
	var ids := CreaturesData.CREATURES.keys()
	var cols := 6
	var sheet := Image.create_empty(cols * cell.x, ceili(ids.size() / float(cols)) * cell.y, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("#2a4a50"))
	for i in ids.size():
		var art: Array = CreaturesData.CREATURES[ids[i]]["art"]
		var fr := CreatureArt.frames(String(art[0]), int(art[1]))
		var x := (i % cols) * cell.x + 4
		for k in (fr["frames"] as Array).size():
			var im: Image = (fr["frames"][k] as Image).duplicate()
			im.blend_rect(fr["glow"][k], Rect2i(Vector2i.ZERO, im.get_size()), Vector2i.ZERO)
			var sc := 3 if im.get_width() <= 26 else 1
			im.resize(im.get_width() * sc, im.get_height() * sc, Image.INTERPOLATE_NEAREST)
			if x + im.get_width() < (i % cols + 1) * cell.x:
				sheet.blend_rect(im, Rect2i(Vector2i.ZERO, im.get_size()), Vector2i(x, (i / cols) * cell.y + 4))
			x += im.get_width() + 2
	sheet.save_png(ProjectSettings.globalize_path("res://prove/creature.png"))


## Il foglio di tutte le stazioni (ingrandite ×3, con la parte luminosa sopra) in prove/stazioni.png.
func _station_sheet() -> void:
	var ids := StationsData.STATIONS.keys()
	var cell := Vector2i(160, 110)
	var cols := 6
	var sheet := Image.create_empty(cols * cell.x, ceili(ids.size() / float(cols)) * cell.y, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("#2a4a50"))
	for i in ids.size():
		var r := StationArt.make(String(ids[i]))
		var im: Image = r["img"]
		im.blend_rect(r["glow"], Rect2i(Vector2i.ZERO, im.get_size()), Vector2i.ZERO)
		var sc := mini(3, mini((cell.x - 8) / im.get_width(), (cell.y - 8) / im.get_height()))
		im.resize(im.get_width() * sc, im.get_height() * sc, Image.INTERPOLATE_NEAREST)
		sheet.blend_rect(im, Rect2i(Vector2i.ZERO, im.get_size()), Vector2i((i % cols) * cell.x + 4, (i / cols) * cell.y + 4))
	sheet.save_png(ProjectSettings.globalize_path("res://prove/stazioni.png"))


## I geni (voce 42): categoria, rarità, dominanza e campi giusti; ogni gene di superficie cresce solo biomi che
## esistono e ha il suo oggetto Seme; ogni gene si può ottenere (a caso, per mutazione, per combinazione o dalla firma).
func _check_species() -> void:
	var run_keys: Dictionary = GenesData.DEFAULTS["run"]
	for g in GenesData.GENES:
		var d: Dictionary = GenesData.GENES[g]
		_err(String(d.get("cat", "")) in GenesData.CATEGORIES, "gene %s: categoria sconosciuta «%s»" % [g, d.get("cat", "")])
		_err(int(d.get("rar", -1)) >= 0 and int(d.get("rar", -1)) < GenesData.RARITY.size(), "gene %s: rarità sbagliata" % g)
		_err(int(d.get("dom", 0)) >= 1 and int(d.get("dom", 0)) <= 5, "gene %s: dominanza fuori da 1-5" % g)
		_err(String(d.get("name", "")) != "" and String(d.get("desc", "")) != "", "gene %s senza nome o descrizione" % g)
		_err(d.has("gen") or d.has("run"), "gene %s: non fa nulla" % g)
		for k in d.get("run", {}):
			_err(run_keys.has(k), "gene %s: effetto in gioco sconosciuto «%s»" % [g, k])
		for k in d.get("gen", {}):
			_err((GenesData.DEFAULTS["gen"] as Dictionary).has(k) or k == "biomes", "gene %s: effetto sul generatore sconosciuto «%s»" % [g, k])
		for f in d.get("gen", {}).get("under", []):
			_err(f in ["fungaie", "geodi_brina", "fiumi_brace", "laghi_linfa", "cuore_cavo"], "gene %s: bioma del sottosuolo sconosciuto «%s»" % [g, f])
		_err(not d.has("only") or String(d["only"]) in ["mutazione", "firma"], "gene %s: «only» sconosciuto" % g)
		for x in d.get("combo", []):
			_err(GenesData.GENES.has(x), "gene %s: combinazione con un gene inesistente «%s»" % [g, x])
		if d.get("cat") == "superficie":
			_err(ItemsData.has(String(d.get("item", ""))), "gene %s: oggetto Seme inesistente «%s»" % [g, d.get("item", "")])
			for b in d["gen"]["biomes"]:
				_err(BiomesData.index_of(String(b)) >= 0 and BiomesData.BIOMES[BiomesData.index_of(String(b))]["id"] == b,
					"gene %s: bioma sconosciuto «%s»" % [g, b])
	for cat in GenesData.CATEGORIES:
		_err(GenesData.CAT_INFO.has(cat), "categoria di geni %s senza nome" % cat)
	# voce 48: ogni gene della firma è davvero dato da una firma; i geni solo per mutazione o combinazione sono almeno 8
	var only_mut := 0
	for g in GenesData.GENES:
		var d: Dictionary = GenesData.GENES[g]
		if String(d.get("only", "")) == "firma":
			_err(SignaturesData.SIGNATURES.values().any(func(s: Dictionary) -> bool: return s.get("gene", "") == g),
				"gene %s: nessuna firma lo dà" % g)
		if String(d.get("only", "")) == "mutazione":
			only_mut += 1
	_err(only_mut >= 8, "geni solo per mutazione o combinazione: %d (ne servono almeno 8)" % only_mut)
	# voce 44: le firme (ricordo esistente, geni graditi esistenti), i nomi dei mondi (un paesaggio per ogni gene di
	# superficie, aggettivi per geni che esistono, e un aggettivo per ogni gene di forma, grotte e sottosuolo)
	for id in SignaturesData.SIGNATURES:
		var sd: Dictionary = SignaturesData.SIGNATURES[id]
		_err(ItemsData.has(String(sd["ricordo"])), "firma %s: ricordo inesistente" % id)
		_err(String(GenesData.GENES.get(String(sd.get("gene", "")), {}).get("only", "")) == "firma", "firma %s: il suo gene non è un gene della firma" % id)
		_err(PassFirma.new().has_method("_" + id), "firma %s: nessun costruttore in PassFirma" % id)
		for g in sd["likes"]:
			_err(GenesData.GENES.has(g), "firma %s: gene gradito inesistente «%s»" % [id, g])
	for g in NamesData.ADJ:
		_err(GenesData.GENES.has(g), "nomi dei mondi: aggettivo per un gene inesistente «%s»" % g)
	for g in GenesData.GENES:
		if GenesData.cat_of(g) == "superficie":
			_err(NamesData.LANDS.has(g), "nomi dei mondi: nessun paesaggio per «%s»" % g)
		elif GenesData.cat_of(g) in Genome.SHAPE_CATS:
			_warn(NamesData.ADJ.has(g), "nomi dei mondi: nessun aggettivo per «%s»" % g)


## Voce 49: gli oggetti di metallo, ora nati dalle proprietà dei materiali, devono valere come prima (i valori della
## tabella scritta a mano fino alla voce 48): entro il 10%, o di un punto sui numeri piccoli.
const OLD_METALS := {
	"radicite": [35, 9, 2.2, [1, 2, 1]], "legnoferro": [45, 12, 2.3, [2, 3, 2]], "ambra": [55, 16, 2.4, [3, 4, 3]],
	"linfa": [65, 21, 2.6, [4, 6, 4]], "vuoto": [75, 27, 2.7, [5, 8, 5]], "pallidite": [42, 11, 2.7, [2, 2, 2]],
	"tizzonite": [60, 18, 2.4, [3, 5, 3]], "stellare": [85, 34, 2.8, [6, 10, 6]],
}


func _check_materials() -> void:
	var worst := 0.0
	for m in OLD_METALS:
		var o: Array = OLD_METALS[m]
		_err(MaterialsData.all().has(m), "materiale %s sparito" % m)
		if not MaterialsData.all().has(m):
			continue
		var pairs := [[ItemsData.get_item("piccone_" + m)["power"], o[0]], [ItemsData.get_item("spada_" + m)["damage"], o[1]],
			[ItemsData.get_item("spada_" + m)["speed"], o[2]], [ItemsData.get_item("piccone_" + m)["damage"], int(o[1] * 0.6)],
			[ItemsData.get_item("arco_" + m)["damage"], int(o[1] * 0.55)], [ItemsData.get_item("elmo_" + m)["defense"], o[3][0]],
			[ItemsData.get_item("corazza_" + m)["defense"], o[3][1]], [ItemsData.get_item("gambali_" + m)["defense"], o[3][2]]]
		for p in pairs:
			var a := float(p[0])
			var b := float(p[1])
			var diff := absf(a - b)
			worst = maxf(worst, diff / maxf(b, 0.001))
			_err(diff <= maxf(b * 0.1, 1.0), "%s: valore %s invece di %s (prima della voce 49)" % [m, a, b])
	for m in MaterialsData.all():
		var md: Dictionary = MaterialsData.all()[m]
		_err(ItemsData.has(String(md["bar"])), "materiale %s: lingotto inesistente «%s»" % [m, md["bar"]])
		_err(ItemIcons.has_palette(MaterialsData.icon_of(m)), "materiale %s: tavolozza dell'icona sconosciuta" % m)
		for p in MaterialsData.PROPS:
			_err(md.has(p), "materiale %s senza la proprietà %s" % [m, p])
	for f in FormsData.FORMS:
		var im := ItemIcons.make(f, "radicite")
		_err(im.get_pixel(8, 8) != Color("#ff2080"), "forma %s: nessuna icona" % f)
		for m in MaterialsData.all():
			_err(ItemsData.has(FormsData.item_id(f, m)), "manca %s" % FormsData.item_id(f, m))
	# voce 51: elementi validi, ogni creatura con debolezze e resistenze scritte
	for m in MaterialsData.all():
		var e := String(MaterialsData.get_mat(m)["elemento"])
		for part in e.split("+"):            # le leghe con due elementi (voce 52)
			_err(part == "" or ElementsData.ELEMENTS.has(part), "materiale %s: elemento sconosciuto «%s»" % [m, part])
	for s in SpellsData.SPELLS:
		_err(not SpellsData.SPELLS[s].has("elem") or ElementsData.ELEMENTS.has(String(SpellsData.SPELLS[s]["elem"])), "incantesimo %s: elemento sconosciuto" % s)
	for cid in CreaturesData.CREATURES:
		_err(ElementsData.AFFINITY.has(cid), "creatura %s senza debolezze e resistenze (ElementsData.AFFINITY)" % cid)
	for cid in ElementsData.AFFINITY:
		_err(CreaturesData.CREATURES.has(cid), "debolezze di una creatura inesistente: %s" % cid)
		for k in ["weak", "resist"]:
			for e in ElementsData.AFFINITY[cid][k]:
				_err(ElementsData.ELEMENTS.has(String(e)), "creatura %s: elemento sconosciuto «%s»" % [cid, e])
	# voce 52: 28 leghe, ognuna con lingotto, ricetta e famiglia; nessuna lega è la migliore in tutte le proprietà
	var alloys := 0
	var best_all := 0
	for m in MaterialsData.all():
		var md: Dictionary = MaterialsData.get_mat(m)
		if not md.has("alloy"):
			continue
		alloys += 1
		_err(ItemsData.has(String(md["bar"])) and not RecipesData.making(String(md["bar"])).is_empty(), "lega %s senza lingotto o ricetta" % m)
		var beats := true
		for other in MaterialsData.MATERIALS:
			for p in ["durezza", "filo", "tenacia", "conduzione"]:
				if float(md[p]) < float(MaterialsData.MATERIALS[other][p]):
					beats = false
		if beats:
			best_all += 1
	_err(alloys == 28, "leghe: %d invece di 28" % alloys)
	# voce 53: i materiali dei geni hanno geni esistenti e un grezzo che si fonde
	for g in MaterialsData.GENE_MATERIALS:
		var gd: Dictionary = MaterialsData.GENE_MATERIALS[g]
		for x in gd["genes"]:
			_err(GenesData.GENES.has(x), "materiale %s: gene inesistente «%s»" % [g, x])
		_err(ItemsData.has(String(gd["raw"]["id"])) and not RecipesData.making("lingotto_" + g).is_empty(), "materiale %s senza grezzo o lingotto" % g)
		_err(gd["raw"].has("tiles") or gd["raw"].has("kill"), "materiale %s: da dove viene?" % g)
	_err(best_all == 0, "%d leghe battono tutti i metalli in tutto" % best_all)
	# voce 55: le famiglie
	for f in FamiliesData.FAMILIES:
		for s in FamiliesData.FAMILIES[f]["members"]:
			_err(CreaturesData.CREATURES.has(s), "famiglia %s: specie inesistente %s" % [f, s])
		var s0 := String(FamiliesData.FAMILIES[f]["members"][0])
		var names := {}
		for sz in ["", "piccolo", "grande"]:
			for el in [""] + FamiliesData.ELEM_ADJ.keys():
				for tp in ["", "docile", "feroce"]:
					names[String(CreaturesData.get_data(FamiliesData.variant_id(s0, sz, el, tp))["name"])] = true
		_err(names.size() >= 6, "famiglia %s: solo %d varianti" % [f, names.size()])
	for cid in CreaturesData.CREATURES:
		var cd: Dictionary = CreaturesData.CREATURES[cid]
		_warn(cd.get("boss", false) or FamiliesData.family_of(cid) != "", "creatura %s senza famiglia" % cid)
	for f in FamiliesData.FAMILIES:
		_err(String(FamiliesData.FAMILIES[f].get("role", "")) in FamiliesData.ROLES, "famiglia %s: ruolo sconosciuto" % f)
		for pf in FamiliesData.FAMILIES[f].get("prey", []):
			_err(FamiliesData.FAMILIES.has(pf), "famiglia %s: preda inesistente %s" % [f, pf])
	for fa in FormsData.FASCE:
		_err(ItemsData.has(String(FormsData.FASCE[fa]["item"])), "fascia %s: materiale inesistente" % fa)
	print("materiali %d × forme %d; scarto massimo dai valori di prima %d%%" % [MaterialsData.all().size(),
		FormsData.FORMS.size(), roundi(worst * 100.0)])


func _err(ok: bool, msg: String) -> void:
	if not ok:
		errors += 1
		print("ERRORE: ", msg)


func _warn(ok: bool, msg: String) -> void:
	if not ok:
		warnings += 1
		print("AVVISO: ", msg)
