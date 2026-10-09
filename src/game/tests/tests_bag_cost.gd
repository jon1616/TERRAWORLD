class_name TestsBagCost
extends RefCounted
## Quanto costa raccogliere (il fotogramma lento del giro lungo, trovato il 26 set 2026): ogni oggetto che entra nella
## Bisaccia la cambia, e il pannello Creare, anche chiuso, rifaceva a ogni cambio l'elenco delle ricette dei banchi a
## portata (103 ms con tutti i banchi vicini). Ora i pannelli si segnano solo e si ridisegnano una volta per
## fotogramma, a pannello aperto; e l'elenco riusa le sue righe invece di ricrearle (con la Bisaccia aperta costava
## ancora ~100 ms a ogni fotogramma in cui si raccoglieva). La prova misura, con tutti i banchi attorno:
## - il tempo di ogni ascoltatore del segnale `Bisaccia.changed`;
## - l'elenco Creare rifatto la prima volta e poi a regime;
## - un mucchio di 20 oggetti mai visti raccolto a Bisaccia chiusa e poi a Bisaccia aperta: il tempo degli script nel
##   fotogramma peggiore (obiettivo < 8 ms; il resto è disegno e attesa dello schermo, con scatti da ~30 ms anche senza
##   oggetti);
## - 300 oggetti fermi a terra: quanto costano a ogni fotogramma (obiettivo < 2 ms).

const STATIONS := ["ceppo", "baccello_ardente", "maglio", "alambicco", "telaio", "mola", "paiolo", "altare"]

var kit: TestKit
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func _listeners() -> String:
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


func _ms(f: Callable) -> float:
	var t0 := Time.get_ticks_usec()
	f.call()
	return (Time.get_ticks_usec() - t0) / 1000.0


## Un mucchio di n oggetti mai visti, posato a terra lontano; poi il Germogliato ci arriva sopra in un colpo, come
## nella corsa, e li raccoglie. Restituisce [fotogramma peggiore, script al massimo, i tre moduli più cari, rimasti].
func _pile(at: Vector2i, n: int) -> Array:
	var ids := ItemsData.all().keys().filter(func(id: String) -> bool:
		return m.character.bisaccia.count(id) == 0 \
			and String(ItemsData.get_item(id).get("kind", "")) in ["materiale", "trofeo", "essenza", "munizione"])
	n = mini(n, ids.size())
	m.snap_to(at + Vector2i(-40, 0))
	await kit.frames(2)
	var pile := Vector2(at) * 16.0 + Vector2(8, 4)
	for i in n:
		m.drops.spawn(String(ids[i]), 1, pile)
	for d in m.drops._items:
		d["vel"] = Vector2.ZERO
	await kit.seconds(1.5)
	# prima accanto, fuori dalla calamita (5 tessere): liquidi e mappa si svegliano nel posto nuovo (8 ott 2026: il loro
	# risveglio cadeva nello stesso fotogramma della raccolta e la prova lo contava come costo della Bisaccia)
	m.snap_to(at + Vector2i(-7, 0))
	await kit.seconds(0.5)
	m.snap_to(at)
	var worst := 0.0
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
			# (9 ott 2026) fuori anche il lavoro del mondo che non dipende dalla raccolta (i liquidi vicini, la mappa, la
			# neve sulle cime): nel giro intero cadeva nel fotogramma misurato e la prova sbagliava colpevole
			var nm := String(e[0])
			if nm.begins_with("disegno") or nm.contains("Liquids") or nm.contains("MapReveal") or nm.contains("WeatherCover"):
				own -= float(e[1])
		if own > scripts:
			scripts = own
			scripts_split = split.filter(func(e: Array) -> bool: return not String(e[0]).begins_with("disegno")).slice(0, 3)
		worst = maxf(worst, dt)
	probe.detach()
	var left := 0
	for d in m.drops._items:
		if (d["node"] as Node2D).position.distance_to(m.player.position) < 24.0:
			left += 1
	return [worst, scripts, ", ".join(scripts_split.map(func(e: Array) -> String: return "%s %.1f ms" % [e[0], e[1]])), left, n]


func run() -> void:
	kit.make_room()
	# lontano dalla partenza: lì le prove di prima hanno già occupato il terreno con le loro stazioni
	var spot := kit.flat_spot(kit.world.spawn + Vector2i(-220, 0), 4)
	if spot.x < 0:
		print("ATTENZIONE: nessun terreno per il mucchio da raccogliere")
		return
	var pile_cell := kit.floor_near(spot + Vector2i(30, -1), 6)
	# attorno al mucchio tutti i banchi, come alla base del giocatore (e alla partenza nel giro lungo delle prove)
	kit.flatten(pile_cell, 14)
	var placed := 0
	for sid in STATIONS:
		m.character.bisaccia.add(sid, 1)
		m.snap_to(pile_cell + Vector2i(-6 + placed * 2, 0))
		if kit.place_station_near(sid, pile_cell + Vector2i(-9 + placed * 3, 0)):
			placed += 1
	m.snap_to(pile_cell)
	await kit.frames(3)
	var listen := _listeners()
	await kit.seconds(1.5)                   # le righe dell'elenco si preparano da sole a Bisaccia chiusa
	# l'elenco Creare con tutti i banchi: la prima volta (righe da costruire) e poi a regime
	var cp: CraftingPanel = m.hud.panel.crafting
	# (8 ott 2026) si aspetta che le caselle siano tutte pronte: la prima icona di un oggetto costa 10-25 ms, e nel
	# gruppo da solo la preparazione cadeva nel fotogramma della raccolta
	var tw := 0.0
	while not cp.warm_done() and tw < 30.0:
		await kit.seconds(0.5)
		tw += 0.5
	var first := _ms(cp.refresh)
	var again := _ms(cp.refresh)
	print("raccolta, con %d banchi attorno: un cambio della Bisaccia costa %s; l'elenco Creare (%d righe) si rifà in %.1f ms la prima volta (righe già preparate), %.1f ms poi" % [
		placed, listen, cp.shown_rows(), first, again])
	# a Bisaccia chiusa
	var a: Array = await _pile(pile_cell, 20)
	print("  mucchio di %d oggetti a Bisaccia chiusa: fotogramma peggiore %.1f ms, script al massimo %.1f ms (%s), a terra ne restano %d" % [
		a[4], a[0], a[1], a[2], a[3]])
	# a Bisaccia aperta: l'elenco si rifà nei fotogrammi in cui si raccoglie
	m.hud.panel.toggle()
	await kit.frames(3)
	var r0 := cp.refreshes
	var c: Array = await _pile(pile_cell, 20)
	var redone := cp.refreshes - r0
	var shown := false
	for s in m.hud.panel._slots:
		if s._icon.texture != null and s.index >= Bisaccia.HOTBAR:
			shown = true
	m.hud.panel.toggle()
	print("  mucchio di %d oggetti a Bisaccia aperta: fotogramma peggiore %.1f ms, script al massimo %.1f ms (%s), a terra ne restano %d; elenco Creare rifatto %d volte; oggetti nelle caselle %s" % [
		c[4], c[0], c[1], c[2], c[3], redone, "sì" if shown else "NO"])
	if float(a[1]) > 8.0 or float(c[1]) > 8.0:
		print("ATTENZIONE: raccogliere un mucchio di oggetti costa ancora troppo agli script")
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
