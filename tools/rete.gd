extends SceneTree
## Roadmap 19, voce 211: il bilancio della rete. Quanto rende all'ora ciò che si costruisce con la Linfa, confrontato con
## ciò che il Germogliato fa a mano (scavare, pescare): una macchina deve risparmiare fatica, non creare ricchezza senza
## fine. Le rese in Lumini sono al prezzo di vendita pieno (`ValueData.value`). Scrive prove/rete.txt.
##   Godot_console.exe --headless --path . --script res://tools/rete.gd

var out := PackedStringArray()


func _p(s: String) -> void:
	out.append(s)
	print(s)


func _init() -> void:
	_p("IL BILANCIO DELLA RETE (Roadmap 19, voce 211)")
	_p("")
	_sources()
	_p("")
	_machines()
	_p("")
	_manual()
	var f := FileAccess.open("res://prove/rete.txt", FileAccess.WRITE)
	f.store_string("\n".join(out))
	f.close()
	quit()


## Le sorgenti: pulsi medi in un giorno del mondo (la Foglia solo di giorno, il Mulino con il vento medio…).
func _sources() -> void:
	_p("1. SORGENTI: pulsi al massimo e in media (un giorno del mondo), costo in materiali grezzi")
	var avg := {"tamburo_radice": [0.0, "a mano: 10 pulsi solo mentre lo batti"], "foglia_lanterna": [0.5, "metà del giorno col sole"],
		"mulino_semi": [0.55, "vento medio (0,8 con «Vento perenne»)"], "ruota_acqua": [1.0, "con l'acqua che cade, sempre"],
		"baccello_brace": [1.0, "brucia combustibile"], "pozzo_linfa": [1.0, "sopra un lago di Linfa, sempre"],
		"nucleo_cristallo": [1.0, "un cristallo ogni 2 minuti di lavoro"], "ruota_mandria": [0.6, "con la mandria che corre"],
		"radice_madre": [1.0, "accanto al Cuore curato"], "radice_giardino": [1.0, "solo nel Giardino"]}
	for id in MachinesData.MACHINES:
		var d: Dictionary = MachinesData.MACHINES[id]
		if String(d.get("role", "")) != "sorgente" or d.get("gen", false):
			continue
		var a: Array = avg.get(id, [1.0, ""])
		_p("   %-24s %4d pulsi · media %5.1f · %-44s · costo %d" % [d["name"], int(d.get("pulsi", 0)), float(d.get("pulsi", 0)) * float(a[0]),
			String(a[1]), _cost(d.get("in", {}))])


## Le macchine che producono: all'ora, in Lumini, e quante Foglie-lanterna servono a tenerle accese.
func _machines() -> void:
	_p("2. MACCHINE CHE PRODUCONO: resa all'ora (lavorando senza sosta), Lumini all'ora, Foglie-lanterna necessarie (media 6 pulsi)")
	var rows := [
		["forno_linfa", 3600.0 / 4.0, "lingotto_legnoferro", "lingotti (3 minerali l'uno)"],
		["frantoio", 3600.0 / 3.0 * 4.0, "polvere_legnoferro", "polveri (+33% metallo)"],
		["telaio_linfa", 3600.0 / 6.0, "seta_radice", "tessuti a scelta"],
		["distillatore", 3600.0 / MbDistillatore.EVERY, MbDistillatore.OUT, "pozioni di Linfa"],
		["trivella_radice", MbTrivella.DAY_CAP * 3.0, "ardesia", "blocchi (tetto %d al giorno del mondo)" % MbTrivella.DAY_CAP],
		["falciatrice_radice", 3600.0 / MbMietitrice.EVERY, "", "colture mature raccolte (tante quante ne crescono)"],
		["mungitrice", 3600.0 / MbMungitrice.EVERY, "", "prodotti della mandria (tanti quanti ne fa)"],
	]
	for r in rows:
		var d: Dictionary = MachinesData.get_machine(String(r[0]))
		var per_h := float(r[1])
		var val := ValueData.value(String(r[2])) if String(r[2]) != "" else 0
		var lum := "%6d Lumini/h" % roundi(per_h * val) if val > 0 else "      (dipende)"
		_p("   %-24s %6d/h %-44s %s · %d pulsi = %.1f Foglie" % [d["name"], roundi(per_h), String(r[3]), lum, int(d.get("pulsi", 0)),
			float(d.get("pulsi", 0)) / 6.0])
	_p("   (il Forno e il Frantoio lavorano quanto minerale gli si dà: la resa vera la decide lo scavo; la Trivella ha il tetto)")


## A mano, per confronto: scavo con i picconi, la pesca (da tools/bilancio.gd), la fusione.
func _manual() -> void:
	_p("3. A MANO, PER CONFRONTO")
	for pk in [["piccone_radicite", 35], ["piccone_legnoferro", 45], ["piccone_ambra", 55]]:
		var secs := float(TileDefs.HARD.get(TileDefs.STONE, 1.0)) * 35.0 / float(pk[1])
		_p("   scavo con %-20s ardesia %5.2f s a blocco → %5d/h senza muoversi, ~%d/h scavando davvero (×0,4)" % [
			ItemsData.get_item(String(pk[0])).get("name", pk[0]), secs, roundi(3600.0 / secs), roundi(3600.0 / secs * 0.4)])
	_p("   la Trivella di radice (con lo stesso piccone): come il Germogliato che scava fermo, ma al più %d blocchi al giorno del mondo" % MbTrivella.DAY_CAP)
	_p("   pesca (tools/bilancio.gd): 318-604 pesci/h, 500-3000 Lumini/h secondo la canna e l'acqua")
	_p("   il Distillatore rende %d Lumini/h: meno della pesca, e lavora mentre fai altro" % [
		roundi(3600.0 / MbDistillatore.EVERY * ValueData.value(MbDistillatore.OUT))])
	_p("   mentre sei via: al più 2 ore reali, a metà velocità (piena con l'Aiuola alimentata): un'ora di lavoro al massimo")


## Il costo di una ricetta in materiali (somma delle quantità).
func _cost(inp: Dictionary) -> int:
	var n := 0
	for k in inp:
		n += int(inp[k])
	return n
