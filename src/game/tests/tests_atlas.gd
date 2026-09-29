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


## Voce 235: le stelle si segnano da sole quando il mondo le dà; ogni cinque stelle un premio; il pannello le mostra.
func stars() -> void:
	var at: Atlas = m.atlas
	var saved_atlas: Dictionary = m.character.atlante.duplicate(true)
	var keys := ["firma", "guardiano", "sigilli", "sigilli_aperti", "segreti"]
	var saved := {}
	for k in keys:
		saved[k] = m.world_meta.get(k, null)
	m.character.atlante = {"altro_mondo": {"nome": "Un altro mondo", "vigore": 2, "stelle": {"firma": 1}, "meraviglie": {}}}
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
	var ok: bool = here and not "firma" in none and fresh.size() == 4 and st == 4 and at.total() == 5 and dust >= 2 and shown
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
