class_name TestsAtlas
extends RefCounted
## Roadmap 23 «L'Atlante»: le stelle dei mondi, le pagine dei biomi, le meraviglie, le spedizioni, gli attrezzi
## dell'esploratore (gruppo `atlante`).

var kit: TestKit
var m: Node


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	await stars()
	await pages()
	await wonders()
	await expeditions()
	await tools()


## Voce 235: le stelle si segnano da sole quando il mondo le dà; ogni cinque stelle un premio; il pannello le mostra.
func stars() -> void:
	var at: Atlas = m.atlas
	var saved_atlas: Dictionary = m.character.atlante.duplicate(true)
	var keys := ["firma", "guardiano", "sigilli", "sigilli_aperti", "segreti"]
	var saved := {}
	for k in keys:
		saved[k] = m.world_meta.get(k, null)
	m.character.atlante = {"altro_mondo": {"nome": "Un altro mondo", "vigore": 2, "stelle": {"firma": 1}, "meraviglie": {}}}
	var f0: Dictionary = (m.world_meta.get("firma", {}) as Dictionary).duplicate()
	f0["trovata"] = false                          # le prove di prima possono aver già trovato la firma o curato il Guardiano
	m.world_meta["firma"] = f0
	m.world_meta["guardiano"] = "dorme"
	m.world_meta["sigilli"] = []
	m.world_meta["segreti"] = []
	at._record()
	var here: bool = at.here()
	var none := at.check()
	var dust0: int = m.character.bisaccia.count("polvere_iridata")
	var st0 := int(m.character.stats.get("stelle", 0))
	var f: Dictionary = (m.world_meta.get("firma", {}) as Dictionary).duplicate()
	f["trovata"] = true
	m.world_meta["firma"] = f
	m.world_meta["guardiano"] = "curato"
	m.world_meta["sigilli"] = [["vista", 1, 1], ["canto", 2, 2]]
	m.world_meta["sigilli_aperti"] = 1
	m.world_meta["segreti"] = [{"k": "x", "r": [0, 0, 1, 1], "g": 1, "f": true}]
	var fresh := at.check()
	var dust: int = m.character.bisaccia.count("polvere_iridata") - dust0
	var st := int(m.character.stats.get("stelle", 0)) - st0
	at.panel.open()
	await kit.frames(3)
	await kit.save("250_atlante")
	var shown: bool = "★" in at.panel._body.text and at.panel._rows.size() == 2
	at.panel.close()
	var four: bool = "firma" in fresh and "guardiano" in fresh and "sigilli" in fresh and "segreti" in fresh
	var roomy: bool = m.character.bisaccia.room_for("polvere_iridata") >= 2    # con la Bisaccia piena il premio cade a terra
	var ok: bool = here and not "firma" in none and four and st == fresh.size() and at.total() >= 5 and (dust >= 2 or not roomy) and shown
	print("atlante: stelle nuove %s (conteggio +%d, in tutto %d); premio delle cinque stelle: polvere iridata +%d; pannello %s" % [
		str(fresh), st, at.total(), dust, shown])
	if not ok:
		print("ATTENZIONE: le stelle dell'Atlante non vanno")
	m.character.bisaccia.remove("polvere_iridata", maxi(dust, 0))
	m.character.bisaccia.remove("mappa_seminatori", 1)
	m.character.stats["stelle"] = st0
	for k in keys:
		if saved[k] == null:
			m.world_meta.erase(k)
		else:
			m.world_meta[k] = saved[k]
	m.character.atlante = saved_atlas


## Voce 236: le pagine dei biomi nascono dai dati; una si completa con le creature e i pesci nell'Erbario e la visita.
func pages() -> void:
	var at: Atlas = m.atlas
	var all := BiomePagesData.pages()
	var p: Dictionary = all[0]
	var er: Dictionary = m.character.erbario
	var saved_cr: Dictionary = (er.get("creature", {}) as Dictionary).duplicate()
	var saved_fi: Dictionary = (er.get("pesci", {}) as Dictionary).duplicate()
	var st: Dictionary = m.character.stats
	var key := BiomePages.visit_key(p)
	var saved_visit := int(st.get(key, 0))
	st.erase(key)
	st.erase("pagina_" + String(p["id"]))
	var before := at.pages.progress(p)
	for cid in p["creature"]:
		(er["creature"] as Dictionary)[String(cid)] = 1
	if not er.has("pesci"):
		er["pesci"] = {}
	for fid in p["pesci"]:
		(er["pesci"] as Dictionary)[String(fid)] = {"n": 1, "max": 10}
	var half := at.pages.check()
	st[key] = 1
	var dust0: int = m.character.bisaccia.count("polvere_iridata")
	var full := at.pages.check()
	var dust: int = m.character.bisaccia.count("polvere_iridata") - dust0
	at.panel.open()
	at.panel.pick_tab("biomi")
	await kit.frames(3)
	await kit.save("251_atlante_biomi")
	var shown: bool = at.panel._rows.size() == all.size()
	at.panel.close()
	var ok: bool = all.size() >= 20 and not String(p["id"]) in half and String(p["id"]) in full and dust == 2 and shown
	print("pagine dei biomi: %d pagine (la prima «%s»: %d creature, %d pesci; prima %s); completa %s, premio polvere +%d" % [
		all.size(), p["name"], (p["creature"] as Array).size(), (p["pesci"] as Array).size(), str(before), String(p["id"]) in full, dust])
	if not ok:
		print("ATTENZIONE: le pagine dei biomi non vanno")
	m.character.bisaccia.remove("polvere_iridata", maxi(dust, 0))
	m.character.bisaccia.remove("linfa_antica", 1)
	er["creature"] = saved_cr
	er["pesci"] = saved_fi
	st.erase("pagina_" + String(p["id"]))
	if saved_visit == 1:
		st[key] = 1
	else:
		st.erase(key)


## Voce 237: il mondo di prova ha le sue meraviglie con il cuore; vista quando la mappa ne scopre il centro, il cuore dà
## il ricordo una volta sola.
func wonders() -> void:
	var wd: Wonders = m.atlas.wonders
	var list: Array = wd.list()
	if list.is_empty():
		print("ATTENZIONE: il mondo di prova non ha meraviglie")
		return
	var e: Dictionary = list[0]
	var k := String(e["k"])
	var o := Vector2i(int(e["o"][0]), int(e["o"][1]))
	var st_ok := true
	for x in list:
		var ox := Vector2i(int(x["o"][0]), int(x["o"][1]))
		st_ok = st_ok and String(m.world.stations.get(ox, "")) == "cuore_meraviglia"
	var saved_seen := int(m.character.stats.get("mer_" + k, 0))
	e["vista"] = false
	var c := Vector2i(int(e["c"][0]), int(e["c"][1]))
	m.map_reveal.reveal_area(c, 3)
	var fresh := wd.check()
	var id := WondersData.memento_id(k)
	var n0: int = m.character.bisaccia.count(id)
	e["preso"] = false
	var t1 := wd.touch(o)
	var t2 := wd.touch(o)
	var got: int = m.character.bisaccia.count(id) - n0
	m.snap_to(o + Vector2i(0, 1))
	await kit.seconds(0.6)
	await kit.save("252_meraviglia_" + k)
	var kinds := []
	for x in list:
		kinds.append(String(x["k"]))
	var ok := st_ok and k in fresh and t1 and t2 and got == 1
	print("meraviglie: %s; cuori al loro posto %s; vista %s; ricordo %d (una volta sola)" % [str(kinds), st_ok, k in fresh, got])
	if not ok:
		print("ATTENZIONE: le meraviglie non vanno")
	m.character.bisaccia.remove(id, maxi(got, 0))
	if saved_seen == 0:
		m.character.stats.erase("mer_" + k)


## Voce 238: tre spedizioni di tipi diversi; una di conteggio si compie facendo salire il conteggio, dà il premio e ne
## apre un'altra; il Seme del premio porta il gene chiesto.
func expeditions() -> void:
	var ex: Expeditions = m.atlas.expeditions
	var saved: Dictionary = m.character.spedizioni.duplicate(true)
	m.character.spedizioni = {}
	ex.fill()
	var kinds := []
	for e in ex.open_list():
		kinds.append(String(e["k"]))
	var distinct: bool = kinds.size() == 3 and kinds[0] != kinds[1] and kinds[1] != kinds[2] and kinds[0] != kinds[2]
	var e := {"k": "segreti", "base": int(m.character.stats.get("segreti", 0))}
	ex.open_list().clear()                         # una sola spedizione di segreti: quella della prova
	ex.open_list().append(e)
	var seg0 := int(m.character.stats.get("segreti", 0))
	var map0: int = m.character.bisaccia.count("mappa_seminatori")
	m.character.stats["segreti"] = seg0 + 4
	var done := ex.check()
	var map_got: int = m.character.bisaccia.count("mappa_seminatori") - map0
	var g := ex.seed_genome("cristalli_giganti")
	var has_gene: bool = "cristalli_giganti" in (g["geni"] as Array)
	m.atlas.panel.open()
	m.atlas.panel.pick_tab("spedizioni")
	await kit.frames(3)
	await kit.save("253_atlante_spedizioni")
	m.atlas.panel.close()
	var ok: bool = distinct and done.size() == 1 and map_got >= 1 and ex.open_list().size() == 3 and has_gene
	print("spedizioni: aperte %s; compiuta %s (mappa +%d), di nuovo %d aperte; Seme con il gene chiesto %s" % [str(kinds), str(done),
		map_got, ex.open_list().size(), has_gene])
	if not ok:
		print("ATTENZIONE: le spedizioni non vanno")
	m.character.stats["segreti"] = seg0
	m.character.bisaccia.remove("mappa_seminatori", maxi(map_got, 0))
	m.character.bisaccia.remove("tavoletta_seminatori", 2)
	m.character.spedizioni = saved


## Voce 239: la Tenda pianta il campo (rinascita e niente nascite attorno), il cannocchiale scopre la mappa lontano, la
## bussola indica una meraviglia non vista.
func tools() -> void:
	var ex: ExplorerTools = m.atlas.explorer
	var pc: Vector2i = m.player_cell()
	var saved_camp: Vector2i = m.fauna.camp
	var saved_meta: Variant = m.world_meta.get("campo", null)
	var saved_beds: Dictionary = (m.world_meta.get("letti", {}) as Dictionary).duplicate()
	var o := pc + Vector2i(-1, -1)
	m.world.stations[o] = "tenda_campo"
	var camped := ex.camp(o)
	var respawn: Vector2i = m.masonry.respawn_point()
	var safe: bool = m.fauna.near_camp(pc) and not m.fauna.near_camp(pc + Vector2i(40, 0))
	m.world.stations.erase(o)
	var far := pc + Vector2i(100, 30)
	var i: int = far.y * m.world.w + far.x
	var was: int = m.world.explored[i]
	m.world.explored[i] = 0
	m.vitals.linfa = m.vitals.linfa_max
	var seen: bool = ex.scope(far) and m.world.explored[i] == 1
	m.world.explored[i] = was
	var list: Array = m.atlas.wonders.list()
	var vis := []
	for e in list:
		vis.append(e.get("vista", false))
		e["vista"] = false
	var k := ex.compass()
	for j in list.size():
		list[j]["vista"] = vis[j]
	var ok: bool = camped and respawn == o + Vector2i(1, 1) and safe and seen and (k != "" or list.is_empty())
	print("attrezzi dell'esploratore: campo %s (rinascita %s, niente nascite attorno %s); cannocchiale %s; bussola «%s»" % [
		camped, str(respawn), safe, seen, k])
	if not ok:
		print("ATTENZIONE: gli attrezzi dell'esploratore non vanno")
	m.fauna.camp = saved_camp
	if saved_meta == null:
		m.world_meta.erase("campo")
	else:
		m.world_meta["campo"] = saved_meta
	m.world_meta["letti"] = saved_beds
