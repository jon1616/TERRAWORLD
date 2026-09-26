class_name TestsEncy
extends RefCounted
## Prove dell'Enciclopedia (27 set 2026): ogni capitolo e ogni catalogo si fa senza segnaposti rimasti e con tutti i
## collegamenti che portano a una pagina vera; la ricerca trova; senza anticipazioni ciò che non si conosce resta
## nascosto; il pannello si apre con il suo tasto e mette in pausa. Foto 124-126.

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func run() -> void:
	var t0 := Time.get_ticks_msec()
	var addrs := []
	for c in EncyPages.chapters():
		addrs.append("cap:" + String(c["id"]))
	for k in EncyPages.CATALOGS:
		addrs.append("cat:" + String(k[0]))
	var re := RegEx.create_from_string("\\[url=([^\\]]+)\\]")
	var left := RegEx.create_from_string("\\{[a-z_0-9]+\\}")
	var bad := []
	var links := 0
	for sa in [false, true]:
		EncyPages.show_all = sa
		for a in addrs:
			var p := EncyPages.page(String(a))
			var txt := String(p[1])
			if String(p[0]) == "?" or txt.strip_edges() == "":
				bad.append("%s vuota" % a)
			if left.search(txt) != null:
				bad.append("%s: segnaposto %s" % [a, left.search(txt).get_string()])
			for mt in re.search_all(txt):
				links += 1
				var to := mt.get_string(1)
				var q := EncyPages.page(to)
				if String(q[0]) == "?" or String(q[1]).strip_edges() == "":
					bad.append("%s → %s" % [a, to])
	EncyPages.show_all = false
	var ms := Time.get_ticks_msec() - t0
	# la ricerca e ciò che resta nascosto
	var found := EncyPages.search("radicite")
	var hidden: bool = String(EncyCatalogs.catalog("creature")[1]).contains("???")
	# il pannello in gioco
	var ev := InputEventKey.new()
	ev.keycode = int(Settings.keys_of("enciclopedia")[0])
	ev.pressed = true
	Input.parse_input_event(ev)
	var up := InputEventKey.new()
	up.keycode = ev.keycode
	Input.parse_input_event(up)
	await kit.frames(4)
	var ep: EncyPanel = m.encyclopedia.panel
	var opened := ep.visible
	ep.go("cap:inizio")
	await kit.frames(3)
	await kit.save("124_enciclopedia")
	EncyPages.show_all = true
	ep.go("cat:oggetti")
	await kit.frames(3)
	await kit.save("125_enciclopedia_oggetti")
	ep._search.text = "legnoferro"
	ep._fill_index()
	ep.go("cap:elementi")
	await kit.frames(3)
	await kit.save("126_enciclopedia_ricerca")
	ep._search.text = ""
	EncyPages.show_all = false
	ep.close_panel()
	await kit.frames(3)
	print("Enciclopedia: %d capitoli, %d cataloghi, %d collegamenti controllati in %d ms; problemi %d %s; «radicite» %d risultati; nascosto senza anticipazioni %s; si apre con il tasto %s" % [
		EncyPages.chapters().size(), EncyPages.CATALOGS.size(), links, ms, bad.size(), bad.slice(0, 6), found.size(),
		"sì" if hidden else "NO", "sì" if opened else "NO"])
	if not bad.is_empty() or found.is_empty() or not opened:
		print("ATTENZIONE: l'Enciclopedia ha pagine o collegamenti sbagliati")
