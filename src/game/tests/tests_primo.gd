class_name TestsPrimo
extends RefCounted
## Roadmap 28 «Il Seme Primo»: il Giardino oltre il Vuoto, il finale, il dopo (gruppo `primo`).

var kit: TestKit
var m: Node


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	await place()
	await guardian()
	await ending()
	await after()


## Voce 263: con il parametro «primo» il generatore fa la radura con l'Albero Antico; senza, no.
func place() -> void:
	var ws: Array[World] = await kit.gen_many([[8080, 1600, 900, {"geni": ["lanterna"], "vigore": 6, "primo": true}],
		[8080, 1600, 900, {"geni": ["lanterna"], "vigore": 6}]])
	var with := ws[0].gen_notes.get("primo", {}) as Dictionary
	var tree_ok := false
	if with.has("tree"):
		tree_ok = String(ws[0].stations.get(with["tree"], "")) == "albero_antico"
	var col: Array = (ws[0].gen_notes.get("collaudo", {}) as Dictionary).get("problemi", [])
	var ok: bool = tree_ok and not ws[1].gen_notes.has("primo") and col.is_empty()
	print("Giardino oltre il Vuoto: Albero Antico %s a %s; senza il Seme Primo niente %s; collaudo %s" % [tree_ok, str(with.get("tree", "")),
		not ws[1].gen_notes.has("primo"), str(col)])
	if not ok:
		print("ATTENZIONE: il Giardino oltre il Vuoto non nasce come dovrebbe")


## Voce 263: il primo tocco sveglia l'ultimo Seminatore; sconfitto lascia il suo seme; portato all'Albero, il finale.
func guardian() -> void:
	var pg: PrimoGarden = m.primo
	var o: Vector2i = m.player_cell() + Vector2i(6, -12)
	m.world.stations[o] = "albero_antico"
	var had: Variant = m.world_meta.get("primo", null)
	var had_state: Variant = m.world_meta.get("primo_luogo", null)
	m.world_meta["primo"] = true
	m.world_meta.erase("primo_luogo")
	var active: bool = pg.active()
	pg.touch(o)
	var boss: Creature = pg.boss
	var woke: bool = boss != null and pg.state().get("sveglio", false)
	var hp: int = boss.hp_max if boss != null else 0
	if boss != null:
		m.fauna.kill(boss)
	var won: bool = pg.state().get("vinto", false)
	m.guardian.lore.visible = false
	var no_seed: bool = pg.touch(o) and not pg.state().get("finale", false)
	kit.hold("seme_seminatore")
	pg.touch(o)
	var finale: bool = pg.state().get("finale", false)
	m.guardian.lore.visible = false
	if m.get("finale") != null:
		m.finale.close()
	var ok: bool = active and woke and hp >= 4000 and won and no_seed and finale
	print("ultimo Seminatore: attivo %s; sveglio %s (Vita %d); sconfitto %s; senza seme aspetta %s; finale %s" % [active, woke, hp, won,
		no_seed, finale])
	if not ok:
		print("ATTENZIONE: l'ultimo Seminatore e l'Albero Antico non vanno")
	m.world.stations.erase(o)
	if had == null:
		m.world_meta.erase("primo")
	else:
		m.world_meta["primo"] = had
	if had_state == null:
		m.world_meta.erase("primo_luogo")
	else:
		m.world_meta["primo_luogo"] = had_state


## Voce 264: il finale mostra il racconto, l'epilogo con i numeri e i titoli; poi l'Albero-Madre è d'oro.
func ending() -> void:
	var fi: Finale = m.finale
	var st: Dictionary = m.character.stats
	var had := int(st.get("finale", 0))
	st.erase("finale")                             # (la prova di prima può averlo già visto)
	fi.start()
	await kit.frames(3)
	await kit.save("255_finale")
	var pages: int = fi.panel.pages.size()
	var epi := fi.epilogue()
	for k in pages:
		fi.panel.next()
	var closed: bool = not fi.panel.visible
	var gold := int(st.get("finale", 0)) >= 1
	var ph := 5 if gold else 0
	var ok: bool = pages == FinaleData.STORY.size() + 2 and epi.contains("Ore di gioco") and closed and gold \
		and StationsData.STATIONS.has("albero_madre_%d" % ph)
	print("finale: %d pagine, epilogo con i numeri %s, chiuso %s; Albero-Madre d'oro %s" % [pages, epi.contains("Ore di gioco"), closed, gold])
	if not ok:
		print("ATTENZIONE: il finale non va")
	if had == 0:
		st.erase("finale")
	else:
		st["finale"] = had


## Voce 265: oltre il grado 10 le stelle di maestria (senza limite); dopo il finale, nel Giardino, un Seme d'oro ogni sette
## giorni, più vigoroso del mondo più forte.
func after() -> void:
	var ev: Evergreen = m.evergreen
	var p := "pesca"
	var top := MasteryData.points_for(p, MasteryData.GRADES)
	var step := float(MasteryData.PILLARS[p]["hours"]) * 60.0 * Evergreen.STAR_FRAC
	var s0 := Evergreen.stars_of(p, top - 1.0)
	var s1 := Evergreen.stars_of(p, top + step * 2.5)
	var s2 := Evergreen.stars_of(p, top + step * 50.0)
	var g := ev.golden_genome()
	var stellar := false
	for x in g["geni"]:
		stellar = stellar or int(GenesData.info(String(x)).get("rar", 0)) == 3
	var ok: bool = s0 == 0 and s1 == 2 and s2 == 50 and int(g["vigore"]) >= 3 and stellar
	print("il dopo: stelle oltre il 10 %d/%d/%d (nessun limite); Seme d'oro vigore %d, gene stellare %s" % [s0, s1, s2, int(g["vigore"]), stellar])
	if not ok:
		print("ATTENZIONE: il dopo non va")
