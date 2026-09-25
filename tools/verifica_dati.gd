extends SceneTree
## Verifica dei contenuti (come `verifica_dati` di Inkblood): controlla che le tabelle di `src/data/` si reggano a
## vicenda e salva il foglio di tutte le icone in prove/oggetti.png per vederle a colpo d'occhio.
##   Godot_console.exe --headless --path . --script res://tools/verifica_dati.gd
## ERRORE = qualcosa di rotto (riferimento a un oggetto che non esiste…); AVVISO = probabilmente da sistemare
## (oggetto che non si può ottenere, materiale che non serve a nulla…).

const KINDS := ["materiale", "blocco", "piccone", "ascia", "spada", "arco", "munizione", "torcia", "stazione",
	"piattaforma", "elmo", "corazza", "gambali", "consumabile", "seme", "lanterna", "cura", "seme_mondo", "accessorio",
	"purifica", "essenza", "bastone", "dono", "specchio", "trofeo", "richiamo", "reliquia", "mappa", "rampino", "esplosivo", "ricurvo",
	"giavellotto", "coltura", "annaffiatoio", "parete", "martello"]
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
		_err(it.has("icon") and (it["icon"] as Array).size() == 2, "%s: icona non indicata" % id)
		if it.has("icon"):
			_err(ItemIcons.MATERIALS.has(String(it["icon"][1])), "%s: materiale dell'icona sconosciuto «%s»" % [id, it["icon"][1]])
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
		var ok: bool = made.has(id) or dropped.has(id) or ItemsData.OTHER_SOURCES.has(id)
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


func _err(ok: bool, msg: String) -> void:
	if not ok:
		errors += 1
		print("ERRORE: ", msg)


func _warn(ok: bool, msg: String) -> void:
	if not ok:
		warnings += 1
		print("AVVISO: ", msg)
