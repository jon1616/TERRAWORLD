class_name TestsDiary
extends RefCounted
## Prove del diario della partita (voce 83): le prime volte diventano tappe, gli appassimenti si contano per strato,
## gli oggetti fabbricati per nome (il primo lingotto è una tappa), il tempo si conta per strato, la scheda «Storia» del
## Semenzaio mostra tappe e riassunto, «Esporta» scrive il file. Foto 150_diario.

var kit: TestKit
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	var dy: Diary = m.diary
	var ch: Character = m.character
	var saved: Dictionary = ch.diario.duplicate(true)
	var stats0: Dictionary = ch.stats.duplicate(true)
	ch.diario = {"tappe": [], "conti": {}}
	ch.stats.erase("viaggi")
	ch.stats.erase("leggende")
	m.objectives.bump("viaggi")
	m.objectives.bump("viaggi")                  # la seconda volta non è una tappa
	m.objectives.bump("leggende")
	m.vitals.cause = "Grumo di muschio"            # voce 188: di che cosa si appassisce
	dy._on_died()
	dy._on_crafted("lingotto_radicite", 2)
	dy._on_crafted("lingotto_radicite", 3)
	dy._on_crafted("torcia", 5)
	await kit.seconds(1.3)
	var tappe: Array = ch.diario["tappe"]
	var texts := tappe.map(func(e: Array) -> String: return String(e[1]))
	var first_trip := texts.count(DiaryData.FIRSTS["viaggi"]) == 1
	var legend := texts.any(func(t: String) -> bool: return t.begins_with("Leggenda compiuta"))
	var ingot := texts.any(func(t: String) -> bool: return t.begins_with("Primo lingotto"))
	var dead := dy.count("morti") == 1 and texts.any(func(t: String) -> bool: return t.begins_with("Primo appassimento"))
	var made := dy.count("fatti", "lingotto_radicite") == 5 and dy.count("fatti", "torcia") == 5
	var time_ok := not (ch.diario["conti"].get("tempo_strato", {}) as Dictionary).is_empty()
	var cause_ok := dy.count("morti_causa", "Grumo di muschio") == 1 and dy.summary(false).contains("Grumo di muschio 1")
	# la scheda e il file
	var sp: SemenzaioPanel = null
	for c in m.hud.get_children():
		if c is SemenzaioPanel:
			sp = c
	var view: Array = dy.view("")
	var tab_ok := sp != null and sp.diary_view.is_valid() and (view[1] as Array).size() == tappe.size()
	if sp != null:
		sp.tab = "storia"
		sp.toggle()
		await kit.frames(4)
		await kit.save("150_diario")
		sp.toggle()
		sp.tab = "mondi"
	var path := dy.export()
	var file_ok := path != "" and FileAccess.file_exists(path) and FileAccess.get_file_as_string(path).contains("Primo viaggio")
	ch.diario = saved
	ch.stats = stats0
	print("diario: %d tappe (primo viaggio una volta %s, leggenda %s, primo lingotto %s), appassimenti %s (di che cosa %s), fabbricati %s, tempo per strato %s, scheda %s, file %s" % [
		tappe.size(), "sì" if first_trip else "NO", "sì" if legend else "NO", "sì" if ingot else "NO", "sì" if dead else "NO",
		"sì" if cause_ok else "NO", "sì" if made else "NO", "sì" if time_ok else "NO", "sì" if tab_ok else "NO", path])
	if not cause_ok:
		print("ATTENZIONE: il diario non conta di che cosa si appassisce")
	# voce 188: l'avviso della Scorza bassa (Caverne senza armatura sì, con il legnoferro no; nei mondi forti di più)
	var warn_bare := DangerData.scorza_warning(0, 2, 1) != ""
	var warn_ok := DangerData.scorza_warning(12, 2, 1) == ""
	var want_v5 := DangerData.expected_scorza(4, 5)
	var warn_v5 := DangerData.scorza_warning(16, 4, 5) != ""
	print("Scorza attesa: Caverne %d (senza armatura avviso %s, con 12 niente %s), Fondo al vigore 5 %d (con 16 avviso %s)" % [
		DangerData.expected_scorza(2, 1), "sì" if warn_bare else "NO", "sì" if warn_ok else "NO", want_v5, "sì" if warn_v5 else "NO"])
	if not (warn_bare and warn_ok and warn_v5):
		print("ATTENZIONE: l'avviso della Scorza bassa non va come dovrebbe")
	if not (first_trip and legend and ingot and dead and made and time_ok and tab_ok and file_ok):
		print("ATTENZIONE: il diario non funziona come dovrebbe")
