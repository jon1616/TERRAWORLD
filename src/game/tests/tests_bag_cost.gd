class_name TestsBagCost
extends RefCounted
## Quanto costa raccogliere (il fotogramma lento del giro lungo, trovato il 26 set 2026): ogni oggetto che entra nella
## Bisaccia la cambia, e i pannelli si ridisegnavano a ogni cambio anche chiusi (~4 ms, di più con oggetti mai visti).
## Passando su un mucchio di 15 oggetti la corsa aveva un fotogramma da 60-120 ms. Ora i pannelli si segnano solo e
## si ridisegnano una volta per fotogramma, a pannello aperto. La prova misura il tempo di ogni ascoltatore del
## segnale `Bisaccia.changed` e, raccogliendo un mucchio di 20 oggetti diversi, il tempo degli script nel fotogramma
## peggiore (obiettivo < 8 ms; il resto è disegno e attesa dello schermo, che ha scatti da ~30 ms anche senza oggetti).

var kit: TestKit
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func _measure() -> String:
	var b: Bisaccia = m.character.bisaccia
	var parts := []
	var total := 0.0
	for c in b.changed.get_connections():
		var cb: Callable = c["callable"]
		var t0 := Time.get_ticks_usec()
		cb.call()
		var ms := (Time.get_ticks_usec() - t0) / 1000.0
		total += ms
		var o := cb.get_object()
		var who := String(o.get_script().get_global_name()) if o != null and o.get_script() != null else "?"
		parts.append("%s %.1f" % [who, ms])
	return "%.1f ms (%s)" % [total, ", ".join(parts)]


func run() -> void:
	kit.make_room()
	# lontano dalla partenza: lì le prove di prima hanno già occupato il terreno con le loro stazioni
	var spot := kit.flat_spot(kit.world.spawn + Vector2i(-220, 0), 4)
	if spot.x < 0:
		print("ATTENZIONE: nessun terreno per il mucchio da raccogliere")
		return
	m.snap_to(spot)
	await kit.frames(5)
	# un mucchio di oggetti diversi, mai visti prima (le loro icone vanno ancora disegnate)
	var ids := ItemsData.all().keys().filter(func(id: String) -> bool:
		return m.character.bisaccia.count(id) == 0 and String(ItemsData.get_item(id).get("kind", "")) == "materiale")
	var n := mini(20, ids.size())
	# il mucchio si posa a terra lontano dal Germogliato (come la legna degli alberi abbattuti da un'altra prova);
	# poi il Germogliato ci arriva sopra in un colpo, come nella corsa, e li raccoglie tutti nello stesso fotogramma
	var pile_cell := kit.floor_near(spot + Vector2i(30, -1), 6)
	# attorno al mucchio tutti i banchi, come alla base del giocatore (e alla partenza nel giro lungo delle prove): il
	# pannello Creare, anche chiuso, rifaceva a ogni raccolta l'elenco di tutte le loro ricette
	kit.flatten(pile_cell, 14)
	var placed := 0
	for sid in ["ceppo", "baccello_ardente", "maglio", "alambicco", "telaio", "mola", "paiolo", "altare"]:
		m.character.bisaccia.add(sid, 1)
		m.snap_to(pile_cell + Vector2i(-6 + placed * 2, 0))
		if kit.place_station_near(sid, pile_cell + Vector2i(-9 + placed * 3, 0)):
			placed += 1
	m.snap_to(spot)
	await kit.frames(3)
	var pile := Vector2(pile_cell) * 16.0 + Vector2(8, 4)
	for i in n:
		m.drops.spawn(String(ids[i * 3 % ids.size()]), 1, pile)
	for d in m.drops._items:
		d["vel"] = Vector2.ZERO
	await kit.seconds(1.5)
	m.snap_to(pile_cell)
	var one := _measure()                    # un cambio qui, con tutti i banchi a portata
	var worst := 0.0
	var worst_split := []
	var scripts := 0.0                        # il tempo degli script (tutto tranne disegno, fisica e attesa)
	var scripts_split := []
	var probe := FrameProbe.new()
	probe.attach(m)
	await kit.node.get_tree().process_frame
	for f in 40:
		var t0 := Time.get_ticks_usec()
		probe.mark()
		await kit.node.get_tree().process_frame
		var dt := (Time.get_ticks_usec() - t0) / 1000.0
		var split := probe.split(40)
		var own := dt
		for e in split:
			if String(e[0]).begins_with("disegno"):
				own -= float(e[1])
		if own > scripts:
			scripts = own
			scripts_split = split.filter(func(e: Array) -> bool: return not String(e[0]).begins_with("disegno")).slice(0, 3)
		split = split.slice(0, 3)
		if dt > worst:
			worst = dt
			worst_split = split
	probe.detach()
	var left := 0
	for d in m.drops._items:
		if (d["node"] as Node2D).position.distance_to(m.player.position) < 24.0:
			left += 1
	print("raccolta, con %d banchi attorno: un cambio della Bisaccia costa %s; un mucchio di %d oggetti raccolto (a terra ne restano %d), fotogramma peggiore %.1f ms, script al massimo %.1f ms" % [
		placed, one, n, left, worst, scripts])
	print("  il fotogramma peggiore: %s; il più caro per gli script: %s; oggetti a terra nel mondo %d" % [
		", ".join(worst_split.map(func(e: Array) -> String: return "%s %.1f ms" % [e[0], e[1]])),
		", ".join(scripts_split.map(func(e: Array) -> String: return "%s %.1f ms" % [e[0], e[1]])), m.drops.count()])
	if scripts > 8.0:
		print("ATTENZIONE: raccogliere un mucchio di oggetti costa ancora troppo agli script")
	# la Bisaccia aperta si ridisegna con ciò che è stato raccolto
	m.hud.panel.toggle()
	await kit.frames(3)
	var shown := false
	for s in m.hud.panel._slots:
		if s._icon.texture != null and s.index >= Bisaccia.HOTBAR:
			shown = true
	m.hud.panel.toggle()
	print("Bisaccia aperta dopo la raccolta: oggetti nelle caselle %s" % ("sì" if shown else "NO"))
	# centinaia di oggetti lasciati a terra (Bisaccia piena, giri lunghi): quanto costano fermi, a ogni fotogramma
	var base := kit.world.spawn + Vector2i(-400, 0)
	for k in 300:
		var x := base.x + (k % 150) * 2
		m.drops.spawn("ardesia", 1, Vector2(x * 16 + 8, (kit.world.surface[x] - 2) * 16) + Vector2(0, -16.0 * (k / 150)))
	await kit.seconds(2.0)
	var probe2 := FrameProbe.new()
	probe2.attach(m)
	await kit.node.get_tree().process_frame
	var cost := 0.0
	for f in 30:
		probe2.mark()
		await kit.node.get_tree().process_frame
		for e in probe2.split(40):
			if String(e[0]).contains("(Drops)"):
				cost += float(e[1])
	probe2.detach()
	print("oggetti a terra: %d, Drops costa %.2f ms per fotogramma" % [m.drops.count(), cost / 30.0])
	if cost / 30.0 > 2.0:
		print("ATTENZIONE: gli oggetti fermi a terra costano troppo")

