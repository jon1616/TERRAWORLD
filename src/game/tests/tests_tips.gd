class_name TestsTips
extends RefCounted
## Prove dei suggerimenti (26 set 2026): le schede degli oggetti (arma con qualità, tratto e innesto; armatura con il
## confronto di Maiusc; Seme di mondo; accessorio; pozione), un vecchio `tooltip_text` che diventa scheda, il mouse
## vero sopra una casella della barra rapida, e quanto costa fare una scheda (tutti gli oggetti del gioco).
## Nel mondo: una creatura antica, una cassa, un minerale, il Sigillo velato che resta nascosto, e il mouse vero sopra
## una creatura. L'interfaccia: Vita e Linfa (col mouse vero), orologio, obiettivi, una riga di Creare. Foto 110-120.

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func _first(pred: Callable) -> String:
	var all := ItemsData.all()
	for id in all:
		if pred.call(all[id]):
			return String(id)
	return ""


func _ctx() -> Dictionary:
	return (SlotView.context.call() as Dictionary).duplicate()


func run() -> void:
	var b: Bisaccia = m.character.bisaccia
	var at := Vector2(620, 160)
	# un'arma di legnoferro, fine, con un tratto e un innesto
	var sword := _first(func(it: Dictionary) -> bool: return String(it.get("form", "")) == "spada" and String(it.get("mat", "")) == "legnoferro")
	var t1 := TraitsData.roll(sword)
	var t2 := TraitsData.roll(sword, null, t1)
	var ws := {"id": sword, "n": 1, "tratto": t1, "dati": {"q": 2, "innesti": [t2] if t2 != "" else []}}
	var wc := ItemTip.card(ws, _ctx())
	Tips.show_at(wc, at)
	await kit.frames(4)
	await kit.save("110_scheda_arma")
	# un'armatura contro quella indossata, con Maiusc
	var chest := _first(func(it: Dictionary) -> bool: return String(it.get("kind", "")) == "corazza" and String(it.get("mat", "")) == "ambra")
	var worn := _first(func(it: Dictionary) -> bool: return String(it.get("kind", "")) == "corazza" and String(it.get("mat", "")) == "radicite")
	var had: Dictionary = b.equip.duplicate()
	var had_d: Dictionary = b.equip_data.duplicate()
	b.equip["corazza"] = worn
	b.equip_data["corazza"] = {"q": 1}
	Tips.shift = true
	var ac := ItemTip.card({"id": chest, "n": 1, "dati": {"q": 3}}, _ctx())
	Tips.shift = false
	var ac_plain := ItemTip.card({"id": chest, "n": 1, "dati": {"q": 3}}, _ctx())
	Tips.show_at(ac, at)
	await kit.frames(4)
	await kit.save("111_scheda_confronto")
	b.equip = had
	b.equip_data = had_d
	# un Seme di mondo (geni mai visti = «?»), un accessorio, una pozione
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var g := Genome.roll(rng, 3)
	var sc := ItemTip.card({"id": Genome.item_of(g), "n": 1, "dati": g}, _ctx())
	Tips.show_at(sc, at)
	await kit.frames(4)
	await kit.save("112_scheda_seme")
	var acc := _first(func(it: Dictionary) -> bool: return String(it.get("kind", "")) == "accessorio" and (it.get("acc", {}) as Dictionary).size() >= 2)
	var cc := ItemTip.card({"id": acc, "n": 1}, _ctx())
	Tips.show_at(cc, at)
	await kit.frames(4)
	await kit.save("113_scheda_accessorio")
	var pc := ItemTip.card({"id": "pozione_bagliore", "n": 3}, _ctx())
	# un vecchio suggerimento di sole parole
	var btn := Button.new()
	btn.tooltip_text = "Mette in ordine la Bisaccia"
	var simple := Tips.card_of(btn)
	btn.free()
	Tips.unpin()
	print("schede: arma «%s» (%s), confronto %s, senza Maiusc niente confronto %s, seme %s, accessorio «%s» (%s), pozione %s, parole %s" % [
		ws["id"], "valori sì" if wc.plain().contains("Danno") and wc.plain().contains("Posti d'innesto") else "NO",
		"sì" if ac.plain().contains("Rispetto a") else "NO", "sì" if not ac_plain.plain().contains("Rispetto a") else "NO",
		"sì" if sc.plain().contains("Vigore") else "NO", acc, "effetti sì" if cc.plain().contains("Indossato") else "NO",
		"sì" if pc.plain().contains("Effetto") else "NO", "sì" if simple != null and simple.plain().contains("ordine") else "NO"])
	if not (wc.plain().contains("Danno") and ac.plain().contains("Rispetto a") and sc.plain().contains("Vigore")
			and cc.plain().contains("Indossato") and simple != null):
		print("ATTENZIONE: una scheda degli oggetti è incompleta")
	# il mouse vero sopra la prima casella della barra rapida
	var slot: Control = m.hud._slots[0]
	await kit.hover(slot.get_global_rect().get_center())
	await kit.seconds(0.6)
	var shown: bool = Tips.inst.view.visible
	await kit.save("114_scheda_col_mouse")
	print("col mouse sopra la barra rapida: scheda %s (%s)" % ["sì" if shown else "NO", m.hud.current().get("name", "")])
	if not shown and m.character.bisaccia.id_at(0) != "":
		print("ATTENZIONE: la scheda non compare con il mouse sopra una casella")
	# quanto costa: la scheda di ogni oggetto del gioco, e il disegno di qualcuna
	var t0 := Time.get_ticks_usec()
	var nall := 0
	for id in ItemsData.all():
		if ItemTip.card({"id": String(id), "n": 1}, _ctx()) != null:
			nall += 1
	var per := (Time.get_ticks_usec() - t0) / 1000.0 / maxf(nall, 1)
	var v := TipView.new()
	m.hud.add_child(v)
	t0 = Time.get_ticks_usec()
	for k in 20:
		v.show_card(wc)
	var draw := (Time.get_ticks_usec() - t0) / 1000.0 / 20.0
	v.queue_free()
	print("schede di tutti i %d oggetti: %.3f ms l'una; disegno di una scheda %.2f ms" % [nall, per, draw])
	if per > 2.0 or draw > 8.0:
		print("ATTENZIONE: le schede costano troppo")
	await world_tips()
	await hud_tips()


func world_tips() -> void:
	var at := Vector2(620, 160)
	var spot := kit.flat_spot(world.spawn + Vector2i(30, 0), 10)
	if spot.x < 0:
		print("ATTENZIONE: nessun posto per le prove delle schede del mondo")
		return
	kit.flatten(spot, 8)
	m.snap_to(spot)
	await kit.frames(6)
	# una creatura antica
	var cr: Creature = m.fauna.add("grumo_muschio", m.player.position + Vector2(64, -4))
	m.fauna.make_ancient(cr, "antica", ["spinosa"])
	cr.stun = 30.0
	var cc := WorldTip.creature(m, cr)
	Tips.show_at(cc, at)
	await kit.frames(4)
	await kit.save("115_scheda_creatura")
	# una cassa o uno scrigno del mondo (le rovine ne hanno), un minerale, il Sigillo velato
	var chest_card: TipCard = null
	for o in world.stations:
		if String(world.stations[o]) in StationTip.CHESTS:
			chest_card = StationTip.card(m, o, String(world.stations[o]))
			break
	if chest_card != null:
		Tips.show_at(chest_card, at)
		await kit.frames(4)
		await kit.save("116_scheda_scrigno")
	var ore := WorldTip.tile(m, TileDefs.LEGNOFERRO)
	Tips.show_at(ore, at)
	await kit.frames(4)
	await kit.save("117_scheda_minerale")
	var veiled := WorldTip.tile(m, TileDefs.SIG_VELATO).plain()
	var bench := StationTip.card(m, Vector2i.ZERO, "maglio").plain()
	Tips.unpin()
	print("schede del mondo: creatura %s, scrigno %s, minerale %s, Sigillo velato nascosto %s, banco %s" % [
		"sì" if cc.plain().contains("Vita") and cc.plain().contains("Debole") or cc.plain().contains("Vita") else "NO",
		"sì" if chest_card != null and chest_card.plain().contains("caselle") else "NO (nessuno scrigno)",
		"sì" if ore.plain().contains("Forza richiesta") else "NO", "sì" if not veiled.contains("Sigillo") else "NO",
		"sì" if bench.contains("ricette") else "NO"])
	if not cc.plain().contains("Vita") or not ore.plain().contains("Forza richiesta") or veiled.contains("Sigillo"):
		print("ATTENZIONE: una scheda del mondo è sbagliata")
	# il mouse vero sopra la creatura (prima si lasciano i tasti del mouse: le prove di prima possono averli premuti,
	# e con un tasto premuto le schede del mondo non compaiono, perché si sta scavando)
	for bt in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT]:
		var up := InputEventMouseButton.new()
		up.button_index = bt
		up.pressed = false
		Input.parse_input_event(up)
	await kit.seconds(0.5)                     # la mappa esplorata segna le celle attorno
	var shown := false
	var sp := Vector2.ZERO
	for attempt in 3:                          # nel giro lungo il primo movimento a volte non arriva
		sp = m.get_viewport().get_canvas_transform() * cr.position
		Tips.mouse_at = sp                     # il mouse vero del sistema può muoversi: un punto fisso
		await kit.seconds(0.9)
		shown = Tips.inst.view.visible
		if shown:
			break
	await kit.save("118_mouse_sulla_creatura")
	Tips.mouse_at = Vector2.INF
	print("col mouse sulla creatura: scheda %s" % ("sì" if shown else "NO"))
	if not shown:
		var cc2 := Vector2i(floori(cr.position.x / 16.0), floori(cr.position.y / 16.0))
		var r: Array = Tips._world.call(sp) if Tips._world.is_valid() else ["nessuno"]
		print("ATTENZIONE: la scheda non compare con il mouse sopra una creatura (mondo: %s, mouse nel mondo %s, creatura %s, sotto il mouse: %s, tasti %s/%s, cella vista %d, pannello aperto %s)" % [
			r.slice(0, 1), m.get_viewport().get_canvas_transform().affine_inverse() * sp, cr.position,
			m.get_viewport().gui_get_hovered_control(), Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT),
			Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT), world.explored[cc2.y * world.w + cc2.x], m.hud.is_open()])
	m.fauna.kill_quietly(cr)


func hud_tips() -> void:
	var vc := HudTips.vitals(m)
	var ck := HudTips.clock(m)
	var ob := HudTips.objectives(m)
	# una riga di Creare: la scheda di ciò che nasce con gli ingredienti
	var row := RecipeRow.new()
	row.setup(RecipesData.all()[0], m.character.bisaccia)
	var rc: TipCard = Tips.card_of(row)
	row.free()
	Tips.show_at(rc, Vector2(620, 160))
	await kit.frames(4)
	await kit.save("119_scheda_ricetta")
	Tips.unpin()
	# il mouse vero sopra le barre di Vita e Linfa
	var vv: Control = null
	for ch in m.hud.get_children():
		if ch is VitalsView:
			vv = ch
	await kit.hover(vv.get_global_rect().get_center() if vv != null else Vector2.ZERO)
	await kit.seconds(0.6)
	var shown: bool = Tips.inst.view.visible
	await kit.save("120_scheda_vita")
	print("schede dell'interfaccia: Vita %s, orologio %s, obiettivi %s, ricetta %s; col mouse sulle barre %s" % [
		"sì" if vc.plain().contains("Scorza") else "NO", "sì" if ck.plain().contains("Stagione") else "NO",
		"sì" if ob.plain().contains("Premio") else "NO", "sì" if rc != null and rc.plain().contains("Serve") else "NO",
		"sì" if shown else "NO"])
	if not (vc.plain().contains("Scorza") and rc != null and rc.plain().contains("Serve") and shown):
		print("ATTENZIONE: una scheda dell'interfaccia manca")
