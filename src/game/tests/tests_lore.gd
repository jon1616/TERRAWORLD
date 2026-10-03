class_name TestsLore
extends RefCounted
## La storia vera (gruppo `storia`, Roadmap 36): i Seminatori nei Cuori, i sogni, gli echi, il Taccuino della verità, le
## leggende dei luoghi, la Bocca. Ogni prova rimette com'erano le statistiche del personaggio che tocca.

var kit: TestKit
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	var st0: Dictionary = (m.character.stats as Dictionary).duplicate(true)
	var ma0: Variant = m.character.maestria.duplicate(true)       # (i conteggi danno punti di maestria: si rimettono)
	await sowers()
	await dreams()
	await echoes()
	await truth()
	refs()
	myths()
	m.character.stats = st0
	m.character.maestria = ma0


## Voce 346: ogni bioma ha la sua leggenda, e la pagina dell'Atlante la mostra solo a bioma visitato.
func myths() -> void:
	var missing := []
	for b in BiomesData.BIOMES + BiomesData.UNDER + BiomesData.SKY:
		if MythsData.of(String(b["id"])) == "":
			missing.append(String(b["id"]))
	var shown_ok := true
	var pages: Array = BiomePagesData.pages()
	if not pages.is_empty():
		var p: Dictionary = pages[0]
		var bp: BiomePages = m.atlas.pages
		var key := bp.visit_key(p)
		var v0 := int(m.character.stats.get(key, 0))
		m.character.stats.erase(key)
		var before := bp.text_of(p).contains(MythsData.of(String(p["biome"])))
		m.character.stats[key] = 1
		var after := bp.text_of(p).contains(MythsData.of(String(p["biome"])))
		m.character.stats[key] = v0
		shown_ok = not before and after
	print("leggende: %d biomi senza leggenda %s; nella pagina solo a bioma visitato %s" % [missing.size(), str(missing),
		"sì" if shown_ok else "NO"])
	if not missing.is_empty() or not shown_ok:
		print("ATTENZIONE: le leggende dei luoghi non vanno")


## Ogni condizione della storia nomina cose che esistono (sogni, echi, domande, pagine, Seminatori): un nome sbagliato
## lascerebbe un sogno o una verità impossibili da trovare, in silenzio.
func refs() -> void:
	var bad := []
	var all := []
	for d in DreamsData.DREAMS:
		all.append(["sogno " + String(d[0]), d[3]])
	for e in EchoesData.ECHOES:
		all.append(["eco " + String(e[0]), e[2]])
		for l in e[1]:
			if String(l[0]) != "albero" and not SowersData.SOWERS.has(String(l[0])):
				bad.append("eco %s: chi è «%s»?" % [e[0], l[0]])
	for q in TruthData.QUESTIONS:
		all.append(["verità " + String(q["id"]), q["proof"]])
		for v in q["versions"]:
			all.append(["verità " + String(q["id"]), v[2]])
	for a in all:
		_check_cond(String(a[0]), a[1], bad)
	print("storia: %d condizioni controllate, %d nomi sbagliati %s" % [all.size(), bad.size(), str(bad) if not bad.is_empty() else ""])
	if not bad.is_empty():
		print("ATTENZIONE: condizioni della storia con nomi che non esistono")


func _check_cond(who: String, c: Dictionary, bad: Array) -> void:
	for k in ["all", "any"]:
		if c.has(k):
			for x in c[k]:
				_check_cond(who, x, bad)
	if c.has("dream") and DreamsData.index_of(String(c["dream"])) < 0:
		bad.append("%s: sogno %s" % [who, c["dream"]])
	if c.has("echo") and not EchoesData.ECHOES.any(func(e: Array) -> bool: return String(e[0]) == String(c["echo"])):
		bad.append("%s: eco %s" % [who, c["echo"]])
	if c.has("truth") and TruthData.get_q(String(c["truth"])).is_empty():
		bad.append("%s: verità %s" % [who, c["truth"]])
	if c.has("page") and not LoreData.PAGES.has(String(c["page"])):
		bad.append("%s: pagina %s" % [who, c["page"]])
	if c.has("sower") and not SowersData.SOWERS.has(String(c["sower"])):
		bad.append("%s: Seminatore %s" % [who, c["sower"]])


## Voce 345: la domanda «Come arrivò il Seme Nero?» compare con la prima versione, si risolve con la versione vera e la
## prova; il Taccuino dice allora quale era vera e quale falsa.
func truth() -> void:
	var tr: Truth = m.truth
	tr.paused = true
	var st: Dictionary = m.character.stats
	for k in st.keys():
		if String(k).begins_with("verita") or String(k).begins_with("eco_"):
			st.erase(k)
	for k in ["stele", "catene", "perduto_muto"]:
		st[k] = 0
	var q := TruthData.get_q("seme")
	var none := tr.known(q).is_empty()
	st["stele"] = 1                                  # la prima versione: «cadde dal cielo»
	var one := tr.known(q).size()
	var early := tr.check()
	st["eco_nome"] = 1                               # la versione vera (un eco)…
	var no_proof := tr.check()
	st["eco_bugia"] = 1                              # …e la prova
	var done := tr.check()
	var det := tr.detail()
	var ok: bool = none and one == 1 and not "seme" in early and not "seme" in no_proof and "seme" in done \
		and int(st.get("verita", 0)) >= 1 and det.contains("falsa") and det.contains("vera")
	print("verità: «%s» con %d versione, senza prova %s, con la prova %s; il Taccuino segna vera e falsa %s" % [
		q["q"], one, "aperta" if not "seme" in no_proof else "RISOLTA", "risolta" if "seme" in done else "NO",
		"sì" if det.contains("falsa") else "NO"])
	if not ok:
		print("ATTENZIONE: il Taccuino della verità non va")
	tr.paused = false


## Voce 344: un eco sopra uno scrigno (le sagome e la prima battuta), la pagina del Taccuino con le voci senza nome.
func echoes() -> void:
	var ec: Echoes = m.echoes
	var st: Dictionary = m.character.stats
	for e in EchoesData.ECHOES:
		st.erase("eco_" + String(e[0]))
	for k in SowersData.ORDER:
		st.erase("risveglio_" + k)
	m.fauna.clear()
	var hud0: bool = m.hud.visible
	m.hud.visible = false
	var at: Vector2i = kit.floor_near(kit.world.spawn + Vector2i(3, 0), 6)
	if at.x < 0:
		at = kit.world.spawn
	m.snap_to(kit.world.spawn)
	var id := ec.on_chest(at + Vector2i(0, -1), true)
	await kit.seconds(2.0)
	var fxs := 0
	for c in m.fx.get_children():
		if c is EchoFx:
			fxs += 1
	await kit.save("storia_eco")
	var det := ec.detail()
	var ok: bool = id == "conta" and fxs == 1 and int(st.get("eco_conta", 0)) == 1 and det.contains("una voce") \
		and ec.rows("").size() == 1
	print("echi: «%s» sopra lo scrigno (%d sagome in scena), nel Taccuino le voci senza nome %s" % [
		id, fxs, "sì" if det.contains("una voce") else "NO"])
	if not ok:
		print("ATTENZIONE: gli echi non vanno")
	m.hud.visible = hud0


## Voce 343: il primo sogno, poi solo quando la sua condizione è vera e l'attesa è passata; l'ultimo resta nascosto.
func dreams() -> void:
	var dr: Dreams = m.dreams
	dr.paused = true
	var st: Dictionary = m.character.stats
	for d in DreamsData.DREAMS:
		st.erase("sogno_" + String(d[0]))
	# un personaggio a cui non è ancora successo niente (le prove di prima hanno contato viaggi, catene, risvegli…)
	for k in ["viaggi", "guardiani", "cronache", "catene", "perduti", "ultimo_seminatore"]:
		st[k] = 0
	for k in SowersData.ORDER + ["senza_nome"]:
		st.erase("risveglio_" + k)
		st.erase("spento_" + k)
	var sn0: String = m.character.seme_nero
	m.character.seme_nero = ""
	var first := dr.sleep(true)
	await kit.frames(2)
	var shown: bool = m.guardian.lore.visible
	m.guardian.lore.visible = false
	var too_soon := dr.sleep()                       # subito dopo: niente (l'attesa)
	var none_ready := dr.sleep(true)                 # niente di nuovo è successo
	st["viaggi"] = 2
	var hands := dr.sleep(true)
	m.guardian.lore.visible = false
	var secret_hidden := dr.next() != "linfa"
	var ok: bool = first == "frutto" and shown and too_soon == "" and none_ready == "" and hands == "mani" and secret_hidden \
		and dr.rows("").size() == 1 and dr.detail().contains("Il ramo")
	print("sogni: il primo «%s» (pagina %s), subito dopo «%s», senza novità «%s», dopo due viaggi «%s»; il segreto nascosto %s" % [
		first, "sì" if shown else "NO", too_soon, none_ready, hands, "sì" if secret_hidden else "NO"])
	if not ok:
		print("ATTENZIONE: i sogni non vanno (prossimo pronto: «%s»)" % dr.next())
	m.character.seme_nero = sn0
	dr.paused = false


## Voce 342: curare risveglia (il nome, poi un ricordo alla volta), abbattere spegne; il Taccuino ne parla.
func sowers() -> void:
	var sw: Sowers = m.sowers
	sw.paused = true
	var st: Dictionary = m.character.stats
	for k in SowersData.ORDER + ["senza_nome"]:
		st.erase("risveglio_" + k)
		st.erase("spento_" + k)
	var none := sw.rows("").is_empty()
	var l1 := sw.on_resolved("nodo", "curato")
	var l2 := sw.on_resolved("nodo", "curato")
	sw.on_resolved("nodo", "sconfitto")
	sw.on_resolved("avvizzitore", "sconfitto")
	sw.on_resolved("generato", "curato")
	sw.on_resolved("colosso", "sconfitto")
	var det := sw.detail()
	var ok: bool = none and l1 == String(SowersData.SOWERS["odran"]["memories"][0]) \
		and l2 == String(SowersData.SOWERS["odran"]["memories"][1]) \
		and int(st.get("risveglio_odran", 0)) == 2 and int(st.get("spento_odran", 0)) == 1 \
		and int(st.get("spento_sareth", 0)) == 1 and det.contains("Odràn") and det.contains("Saréth") \
		and not det.contains("Varèk") and det.contains("?") and sw.rows("").size() == 1 \
		and m.chains.view("storia:seminatori")[2] == det
	print("Seminatori: Odràn risvegliato due volte («%s»), spento una; Saréth spenta; Varèk spento e ancora senza nome (%s); Taccuino %s" % [
		l2, "sì" if not det.contains("Varèk") else "NO", "sì" if sw.rows("").size() == 1 else "NO"])
	if not ok:
		print("ATTENZIONE: i Seminatori nei Cuori non vanno")
	sw.paused = false
