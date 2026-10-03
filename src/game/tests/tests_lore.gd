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
	m.character.stats = st0
	m.character.maestria = ma0


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
