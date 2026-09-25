extends SceneTree
## Verifica dei contenuti (come `verifica_dati` di Inkblood): controlla che le tabelle di `src/data/` si reggano a
## vicenda e salva il foglio di tutte le icone in prove/oggetti.png per vederle a colpo d'occhio.
##   Godot_console.exe --headless --path . --script res://tools/verifica_dati.gd
## ERRORE = qualcosa di rotto (riferimento a un oggetto che non esiste…); AVVISO = probabilmente da sistemare
## (oggetto che non si può ottenere, materiale che non serve a nulla…).

const KINDS := ["materiale", "blocco", "piccone", "ascia", "spada", "arco", "munizione", "torcia", "stazione",
	"piattaforma", "elmo", "corazza", "gambali", "consumabile", "seme", "lanterna", "cura", "seme_mondo", "accessorio",
	"purifica", "essenza", "bastone", "dono"]
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
		for r in o["reward"]:
			_err(items.has(String(r)), "obiettivo %s: ricompensa sconosciuta %s" % [o["id"], r])
	_icon_sheet(items)
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


func _err(ok: bool, msg: String) -> void:
	if not ok:
		errors += 1
		print("ERRORE: ", msg)


func _warn(ok: bool, msg: String) -> void:
	if not ok:
		warnings += 1
		print("AVVISO: ", msg)
