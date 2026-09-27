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


## Una ricetta con un ingrediente che manca e che si fabbrica a sua volta (niente leghe, che vanno scoperte).
static func _recipe_with_sub(b: Bisaccia) -> Dictionary:
	for r in RecipesData.all():
		for id in r["in"]:
			if Crafting.have(b, String(id)) < int(r["in"][id]) and not RecipesData.making(String(id)).is_empty():
				return r
	return {}
