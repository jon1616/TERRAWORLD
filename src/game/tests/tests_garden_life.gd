class_name TestsGardenLife
extends RefCounted
## Roadmap 22 «Il Giardino vivo»: bellezza, isole, visitatori, feste, storie, mestieri, grandi opere (gruppo `giardino_vivo`).

var kit: TestKit
var m: Node


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	await beauty()
	await islands()
	await visitors()
	await festival()
	await stories()
	await workshop()
	await works()


## Voce 227: la bellezza nasce dalle stanze, dai tipi di stanza, dalla felicità degli abitanti; salire dà maestria.
func beauty() -> void:
	var saved := {"stanze": m.world_meta.get("stanze", []), "felicita": m.world_meta.get("felicita", {})}
	var best0 := int(m.character.stats.get("bellezza_max", 0))
	var pts0: float = m.mastery.points("giardino")
	m.world_meta["stanze"] = [{"comfort": 20, "type": "casa"}, {"comfort": 10, "type": "serra"}, {"comfort": 4, "type": "stanza"}]
	m.world_meta["felicita"] = {"mercante_semi": 80, "mandriano": 60}
	m.character.stats["bellezza_max"] = 0
	var p: Dictionary = m.beauty.parts()
	var v: int = m.beauty.update()
	var gained: float = m.mastery.points("giardino") - pts0
	var ok := int(p["stanze"]) == 34 and int(p["tipi"]) == 16 and int(p["abitanti"]) == 14 and v >= 64 and gained >= 64.0
	print("bellezza del Giardino: %d (%s); maestria del Giardino +%.0f" % [v, str(p), gained])
	if not ok:
		print("ATTENZIONE: la bellezza del Giardino non si calcola come deve")
	m.world_meta["stanze"] = saved["stanze"]
	m.world_meta["felicita"] = saved["felicita"]
	m.character.stats["bellezza_max"] = best0


## Voce 228: un'isola nasce (tessere, ponte, recinto), le colture sull'isola dell'orto crescono di più, la miniera viva
## rimette i minerali. Nel mondo di prova le isole si costruiscono a mano (le soglie valgono nel Giardino).
func islands() -> void:
	var gi: GardenIslands = m.garden_islands
	var saved: Variant = m.world_meta.get("isole", null)
	m.world_meta["isole"] = {}
	gi.build("orto")
	gi.build("bottega")
	var e: Dictionary = gi.built()["orto"]
	var on := gi.grow_at(Vector2i(int(e["x"]), int(e["y"]) - 1))
	var off := gi.grow_at(Vector2i(int(e["x"]) + 200, int(e["y"])))
	var ground: bool = m.world.solid(int(e["x"]) + 10, int(e["y"]) + 2)
	var b: Dictionary = gi.built()["bottega"]
	var ores := 0
	gi._mine(b)
	for x in range(int(b["x"]) - int(b["half"]), int(b["x"]) + int(b["half"])):
		for y in range(int(b["y"]), int(b["y"]) + 14):
			if m.world.tile(x, y) in [TileDefs.RADICITE, TileDefs.LEGNOFERRO, TileDefs.AMBRA, TileDefs.CRYSTAL]:
				ores += 1
	var ok := is_equal_approx(on, GardenIslandsData.ORTO_GROW) and is_equal_approx(off, 1.0) and ground and ores >= 10
	print("isole del Giardino: orto nata %s (crescita ×%.1f sull'isola, ×%.1f fuori), bottega con %d minerali" % [ground, on, off, ores])
	if not ok:
		print("ATTENZIONE: le isole del Giardino non vanno")
	if saved == null:
		m.world_meta.erase("isole")
	else:
		m.world_meta["isole"] = saved


## Voce 229: la bellezza apre i visitatori; uno arriva (presente, non salvato tra gli abitanti) e se ne va.
func visitors() -> void:
	var vs: Visitors = m.visitors
	var best0 := int(m.character.stats.get("bellezza_max", 0))
	m.character.stats["bellezza_max"] = 120
	var el := vs.eligible()
	vs.arrive("collezionista")
	await kit.frames(2)
	var here: bool = "collezionista" in m.villagers.present()
	var saved_as_resident: bool = (m.world_meta.get("abitanti", {}) as Dictionary).has("collezionista")
	vs.leave()
	await kit.frames(2)
	var gone: bool = not "collezionista" in m.villagers.present()
	m.character.stats["bellezza_max"] = best0
	var ok := "mercante_mondi" in el and "collezionista" in el and not "pellegrino" in el and here and not saved_as_resident and gone
	print("visitatori: con bellezza 120 %s; il Collezionista arriva %s e se ne va %s" % [str(el), here, gone])
	if not ok:
		print("ATTENZIONE: i visitatori non vanno")


## Voce 230: la festa comincia, il compito sale con il conteggio, alla fine i premi e l'oggetto della festa.
func festival() -> void:
	var fs: Festivals = m.festivals
	var had := int(m.character.stats.get("festa_germoglio", 0))
	m.character.stats["festa_germoglio"] = 0
	var crown0: int = m.character.bisaccia.count("corona_fiori")
	fs.start("germoglio")
	var p0: Array = fs.progress()
	m.objectives.bump("semine", 20)
	fs.check()
	var crown: bool = m.character.bisaccia.count("corona_fiori") == crown0 + 1
	var done: bool = bool(fs.active().get("fatta", false))
	if m.depth_watch.banner.visible:
		m.depth_watch.banner.visible = false
	m.world_meta.erase("festa")
	m.character.stats["festa_germoglio"] = had + 1
	var ok := int(p0[0]) == 0 and int(p0[1]) == 20 and done and crown
	print("feste: la Fioritura dei semi 0/20 → compiuta %s, corona di fiori %s" % [done, crown])
	if not ok:
		print("ATTENZIONE: le feste di stagione non vanno")


## Voce 231: la storia della Viandante: il capitolo 1 chiuso senza affetto, aperto con l'affetto, consegnato; a storia
## finita la merce in più.
func stories() -> void:
	var ch: Character = m.character
	var keep := {"richiesta_viandante": ch.stats.get("richiesta_viandante", 0), "affetto_viandante": ch.stats.get("affetto_viandante", 0)}
	ch.stats["richiesta_viandante"] = 0
	ch.stats["affetto_viandante"] = 0
	var locked: bool = NpcBonds.quest(ch, "viandante").get("chiuso", false)
	NpcBonds.add(ch, "viandante", 30)
	var q := NpcBonds.quest(ch, "viandante")
	ch.bisaccia.add("torcia", 30)
	var rw := NpcBonds.deliver(ch, "viandante")
	var next := int(NpcBonds.quest(ch, "viandante").get("capitolo", 0))
	ch.stats["richiesta_viandante"] = 5
	var tp: TradePanel = m.villagers.panel
	tp.npc = "viandante"
	var goods: Array = tp._goods()
	tp.npc = ""
	var final_ok: bool = NpcBonds.story_done(ch, "viandante") and goods.any(func(g: Array) -> bool: return String(g[0]) == String(NpcStoriesData.FINAL["viandante"][0]))
	for k in keep:
		ch.stats[k] = keep[k]
	var ok: bool = locked and int(q.get("capitolo", 0)) == 1 and not q.get("chiuso", false) and rw.has("lumino") and next == 2 and final_ok
	var n := 0
	for id in NpcStoriesData.STORIES:
		n += (NpcStoriesData.STORIES[id] as Array).size()
	print("storie degli abitanti: %d capitoli; la Viandante: chiuso senza affetto %s, capitolo 1 consegnato %s, poi il %d; merce finale %s" % [
		n, locked, rw.has("lumino"), next, final_ok])
	if not ok:
		print("ATTENZIONE: le storie degli abitanti non vanno")


## Voce 232: la bottega del Forgiatore: lascia i minerali, il tempo passa (qui: si sposta la fine), si ritirano i lingotti.
func workshop() -> void:
	var meta: Dictionary = m.world_meta
	var ch: Character = m.character
	var ing0: int = ch.bisaccia.count("lingotto_legnoferro")
	ch.bisaccia.add("minerale_legnoferro", 12)
	var msg := NpcWork.start(meta, ch, "forgiatore")
	var waiting: bool = NpcWork.left(meta, "forgiatore") > 0.0
	var early := NpcWork.collect(meta, "forgiatore")
	(meta["botteghe"]["forgiatore"] as Dictionary)["fine"] = Time.get_unix_time_from_system() - 1.0
	var got := NpcWork.collect(meta, "forgiatore")
	var n := int(got.get("lingotto_legnoferro", 0))
	var ok := msg != "" and waiting and early.is_empty() and n == 6
	print("botteghe: «%s»; aspetta %s; ritirati %d lingotti" % [msg, waiting, n])
	if not ok:
		print("ATTENZIONE: le botteghe degli abitanti non vanno")
	ch.bisaccia.remove("lingotto_legnoferro", maxi(ch.bisaccia.count("lingotto_legnoferro") - ing0, 0))


## Voce 233: le grandi opere vogliono i materiali di tutti i pilastri, si costruiscono solo nel Giardino e, fatte, danno
## Aiuole, crescita, Vita e visitatori per sempre (qui le opere si segnano a mano: il mondo di prova non è il Giardino).
func works() -> void:
	var st: Dictionary = m.character.stats
	var need := ProjectsData.needs("torre_albero")
	var extra_ok := int(need.get("frammento_albero", 0)) == 2 and int(need.get("perla_maree", 0)) == 1
	var refused: bool = not m.builder.build_blueprint("torre_albero", m.player_cell() + Vector2i(3, -12))
	var a0: int = m.aiuole.max_aiuole()
	var g0: float = m.garden.gear_grow
	var r0: float = m.vitals.regen_mult
	var saved := {}
	for k in ProjectsData.WORKS:
		saved[k] = int(st.get("opera_" + k, 0))
		st["opera_" + k] = 1
	m.gear.refresh()
	var a1: int = m.aiuole.max_aiuole()
	var g1: float = m.garden.gear_grow
	var r1: float = m.vitals.regen_mult
	for k in saved:
		st["opera_" + k] = saved[k]
	m.gear.refresh()
	var ok := extra_ok and refused and a1 == a0 + 3 and g1 > g0 * 1.2 and r1 > r0 * 1.05
	print("grandi opere: materiali in più %s; fuori dal Giardino rifiutata %s; Aiuole %d → %d, crescita ×%.2f → ×%.2f, Vita ×%.2f → ×%.2f" % [
		extra_ok, refused, a0, a1, g0, g1, r0, r1])
	if not ok:
		print("ATTENZIONE: le grandi opere del Giardino non vanno")
