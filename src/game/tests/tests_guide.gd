class_name TestsGuide
extends RefCounted
## La guida del giocatore (28 set 2026): il filo da seguire (`Filo`), la lista della spesa (`Spesa`, con il pulsante
## «Segna» di Esamina cliccato davvero) e i consigli alla prima volta (`Consigli`). Gruppo «guida».

var kit: TestKit
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	var w: World = m.world
	var b: Bisaccia = m.character.bisaccia
	var guida0: Dictionary = m.character.guida.duplicate(true)
	m.character.guida = {}
	m.snap_to(w.spawn)
	await kit.frames(3)
	# 1. il filo, senza lista: qualcosa da fare c'è sempre
	m.filo.refresh()
	var first := String(m.filo.current.get("src", ""))
	print("filo senza lista: %s «%s»" % [first, m.filo.current.get("text", "")])
	# 2. la lista: una ricetta con un ingrediente che manca e si fabbrica (così ci sono le righe sotto)
	var r := _recipe_with_sub(b)
	var rows := []
	var list_ok := false
	var filo_list := false
	if r.is_empty():
		print("ATTENZIONE: nessuna ricetta con un ingrediente da fabbricare per la prova della lista")
	else:
		m.spesa.toggle(r)
		rows = m.spesa.needs(r)
		var deep := rows.any(func(x: Array) -> bool: return int(x[3]) > 0)
		m.filo.refresh()
		filo_list = String(m.filo.current.get("src", "")) == "lista"
		var lt: String = m.spesa.text()
		list_ok = deep and lt.contains(String(ItemsData.get_item(String(r["out"]))["name"])) and m.spesa.is_marked(r)
		print("lista: «%s», righe %d (anche gli ingredienti degli ingredienti %s); il filo la segue %s: «%s» — %s" % [
			ItemsData.get_item(String(r["out"]))["name"], rows.size(), "sì" if deep else "NO", "sì" if filo_list else "NO",
			m.filo.current.get("text", ""), m.filo.current.get("hint", "")])
		m.filo._t = 0.0
		m.spesa._dirty = true
		await kit.frames(4)
		await kit.save("170_filo_e_lista")
	# 3. «Segna» in Esamina, con un clic vero; poi fatta la ricetta esce dalla lista
	var clicked := false
	var auto_out := false
	if not r.is_empty():
		m.spesa.toggle(r)                                 # tolta: il clic deve rimetterla
		var bp: BisacciaPanel = m.hud.panel
		if not bp.visible:
			bp.toggle()
		bp.crafting.pick(r)
		await kit.frames(4)
		await kit.click(bp.examine._mark.get_global_rect().get_center())
		clicked = m.spesa.is_marked(r) and bp.examine._mark.text == "Segnata"
		bp.toggle()
		await kit.frames(2)
		m.spesa._on_crafted(String(r["out"]), 1)
		auto_out = not m.spesa.is_marked(r)
	print("Segna in Esamina (clic vero) %s; fatta la ricetta esce dalla lista %s" % ["sì" if clicked else "NO",
		"sì" if auto_out else "NO"])
	# 4. il segno: un minerale già visto vicino al Germogliato
	var mark_ok := false
	var ore_t := int(TileDefs.ORES[0]["type"])
	var ore_id := String(TileDefs.DROP.get(ore_t, ""))
	var pc: Vector2i = m.player_cell()
	var q := pc + Vector2i(9, 3)
	var old_t := w.tile(q.x, q.y)
	var old_e := w.explored[q.y * w.w + q.x]
	w.tiles[q.y * w.w + q.x] = ore_t
	w.explored[q.y * w.w + q.x] = 1
	if ore_id != "":
		var tg: Dictionary = m.filo._target({"item": ore_id})
		mark_ok = tg.get("cell", Vector2i(-1, -1)) == q or (tg.has("cell") and Vector2(tg["cell"] - pc).length() <= Vector2(q - pc).length())
		print("segno del filo per %s: %s (posto a %s)" % [ItemsData.get_item(ore_id)["name"], tg, q])
	w.tiles[q.y * w.w + q.x] = old_t
	w.explored[q.y * w.w + q.x] = old_e
	# 5. i consigli: il benvenuto una volta sola, il tasto dell'Enciclopedia apre il suo capitolo
	var cs: Consigli = m.consigli
	cs.paused = false
	cs._built_t = 10.0
	var got := cs.check()
	await kit.frames(3)
	var card := cs.card_text()
	await kit.save("171_consiglio")
	var addr: String = m.encyclopedia.next_addr
	cs.hide_card()
	var again := cs.check()
	cs.hide_card()
	var once := got == "benvenuto" and again != "benvenuto" and cs.seen().has("benvenuto")
	print("consigli: primo «%s» (%s), il capitolo col tasto %s; il secondo è un altro (%s) %s" % [got, card.left(70), addr,
		again, "sì" if once else "NO"])
	cs.paused = true
	m.character.guida = guida0
	if first == "" or not list_ok or not filo_list or not clicked or not auto_out or not mark_ok or not once \
			or addr != "cap:inizio":
		print("ATTENZIONE: la guida del giocatore non funziona come dovrebbe")
	await howto()


## Una ricetta con un ingrediente che manca e che si fabbrica a sua volta (niente leghe, che vanno scoperte).
static func _recipe_with_sub(b: Bisaccia) -> Dictionary:
	for r in RecipesData.all():
		for id in r["in"]:
			if Crafting.have(b, String(id)) < int(r["in"][id]) and not RecipesData.making(String(id)).is_empty():
				return r
	return {}


## Voce 351 (Roadmap 37): ogni richiesta dice che cos'è e come si fa. Ogni offerta dell'Albero-Madre fatta di un
## conteggio o di un grado ha la sua spiegazione con un capitolo vero dell'Enciclopedia; ogni tipo di richiesta della
## Bacheca ha la sua riga «dove / come»; il pannello dell'Albero la mostra (foto 350_albero_spiega).
func howto() -> void:
	var missing := []
	for st in MotherTreeData.STAGES:
		for o in st["offers"]:
			var alts: Array = o["any"] if (o as Dictionary).has("any") else [o]
			for a in alts:
				var ad: Dictionary = a
				if not (ad.has("stat") or ad.has("grado")):
					continue
				var t := HowTo.offer_text(m, ad)
				var cap := String(HowToData.of(String(ad.get("stat", ""))).get("cap", "pilastri"))
				if t == "" or not t.contains("Enciclopedia") or EncyPages.chapter(cap).is_empty():
					missing.append(String(ad.get("stat", ad.get("grado", "?"))))
	var fam := String(FamiliesData.FAMILIES.keys()[0])
	var reqs := [{"tipo": "caccia", "cosa": fam}, {"tipo": "mandria", "cosa": fam}, {"tipo": "fornitura", "cosa": "lingotto_radicite"},
		{"tipo": "prodotto", "cosa": "seta_radice"}, {"tipo": "cielo", "cosa": "nuvola"}, {"tipo": "rete", "cosa": "vena_legnoferro"}]
	for k in HowTo.BOARD_STAT:
		reqs.append({"tipo": k})
	var empty := []
	for r in reqs:
		if HowTo.board_text(r) == "":
			empty.append(String(r["tipo"]))
	# il pannello dell'Albero sullo stadio dei segreti
	var al: Dictionary = m.character.albero
	var stadio0 := int(al.get("stadio", 0))
	var idx := 0
	for i in MotherTreeData.STAGES.size():
		if str(MotherTreeData.STAGES[i]["offers"]).contains("\"segreti\""):
			idx = i
			break
	al["stadio"] = idx
	var ap: AlberoPanel = m.albero.panel
	ap.open()
	await kit.frames(4)
	var shown: String = ap.shown_text()
	var panel_ok := shown.contains("pareti finte") and shown.contains("Bacchetta rabdomante")
	await kit.save("350_albero_spiega")
	ap.visible = false
	al["stadio"] = stadio0
	# «a cosa serve»: gli oggetti che non servono a niente (né clic, né ricette, né richieste) finiscono in un file
	var useless := []
	var all: Dictionary = ItemsData.all()
	for id in all:
		if all[id].has("gen"):
			continue
		var other := ItemUses.lines(String(id)).filter(func(x: String) -> bool: return not x.begins_with("Si vende"))
		if other.is_empty() and ItemInfo.uses_of(String(id)).is_empty():
			useless.append("%s (%s, %s)" % [id, all[id].get("name", id), all[id].get("kind", "?")])
	var f := FileAccess.open("res://prove/oggetti_senza_uso.txt", FileAccess.WRITE)
	if f != null:
		f.store_string("Oggetti senza nessun uso (né clic, né ricette, né richieste): %d su %d\n\n%s\n" % [useless.size(), all.size(),
			"\n".join(useless)])
		f.close()
	var info := ItemInfo.bbcode("seta_radice")
	var esamina_ok := info.contains("A cosa serve") and info.contains("Al Telaio")
	m.hud.panel.toggle()
	m.hud.panel.examine.show_item("seta_radice")
	await kit.frames(4)
	await kit.save("351_esamina_serve")
	m.hud.panel.toggle()
	print("spiegazioni: offerte dell'Albero senza spiegazione %s; tipi della Bacheca senza riga %s; pannello dell'Albero %s; Esamina %s; oggetti senza uso %d su %d (prove/oggetti_senza_uso.txt)" % [
		str(missing), str(empty), panel_ok, esamina_ok, useless.size(), all.size()])
	if not missing.is_empty() or not empty.is_empty() or not panel_ok or not esamina_ok:
		print("ATTENZIONE: qualche richiesta non spiega che cos'è o come si fa")

