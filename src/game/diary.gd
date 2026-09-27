class_name Diary
extends Node
## Il diario della partita (voce 83, Roadmap 12): un registro automatico di **quando** succedono le cose che contano
## (prime volte, Guardiani, gradi di vigore, stadi dell'Albero, primi metalli…) e dei **conteggi** (appassimenti e dove,
## cosa si fabbrica, tempo passato in ogni strato). Serve al giocatore per rileggere la sua storia (scheda «Storia» del
## Semenzaio) e a Claude per bilanciare il ritmo: «Esporta» scrive un file di testo.
## Dati in `Character.diario` = {"tappe": [[secondi di gioco, testo, tipo]], "conti": {…}}; testi delle prime volte in
## `DiaryData`.

var m: Node2D
var _t := 0.0
var _deaths_here := 0                  # appassimenti in questo mondo (per la tappa del Guardiano)
var _arrived := 0.0                    # quando si è entrati in questo mondo (secondi di gioco)


func setup(main: Node2D) -> void:
	m = main
	var d := data()
	if not d.has("tappe"):
		d["tappe"] = []
	if not d.has("conti"):
		d["conti"] = {}
	m.objectives.bumped.connect(_on_bump)
	m.guardian.resolved.connect(_on_guardian)
	m.vitals.died.connect(_on_died)
	m.hud.panel.crafting.crafted.connect(_on_crafted)
	if m.albero != null:
		m.albero.grew.connect(func(stage: int) -> void: note("L'Albero-Madre cresce: stadio %d" % (stage + 1), "albero"))
	_arrived = now()
	for c in m.hud.get_children():
		if c is SemenzaioPanel:
			(c as SemenzaioPanel).diary_view = view
			(c as SemenzaioPanel).diary_export = export
	_on_enter()


func data() -> Dictionary:
	return m.character.diario


## Secondi di gioco del personaggio, adesso (quelli salvati più quelli di questa sessione).
func now() -> float:
	return float(m.character.play_time) + float(m.get("_session_time"))


## Una tappa nel diario.
func note(text: String, kind := "") -> void:
	(data()["tappe"] as Array).append([roundi(now()), text, kind])


## Un conteggio (`add("morti")`, `add("fatti", "spada_radicite", 2)`).
func add(key: String, sub := "", n := 1) -> void:
	var c: Dictionary = data()["conti"]
	if sub == "":
		c[key] = int(c.get(key, 0)) + n
		return
	var d: Dictionary = c.get(key, {})
	d[sub] = int(d.get(sub, 0)) + n
	c[key] = d


func count(key: String, sub := "") -> int:
	var c: Dictionary = data()["conti"]
	if sub == "":
		return int(c.get(key, 0))
	return int((c.get(key, {}) as Dictionary).get(sub, 0))


## Entrando in un mondo: il primo mondo di un grado di vigore nuovo, il primo viaggio in un mondo leggendario…
func _on_enter() -> void:
	var v := int(m.world_meta.get("vigore", 1))
	if bool(m.world_meta.get("giardino", false)):
		return
	var best := count("vigore_max")
	if v > best:
		(data()["conti"] as Dictionary)["vigore_max"] = v
		note("Primo mondo di vigore %d: «%s»" % [v, m.world_meta.get("nome", "")], "vigore")
	if m.world_meta.has("leggenda") and count("leggende_viste", String(m.world_meta["leggenda"])) == 0:
		add("leggende_viste", String(m.world_meta["leggenda"]))
		note("In un mondo leggendario: %s" % Legends.name_of(String(m.world_meta["leggenda"])), "leggenda")


func _on_bump(stat: String) -> void:
	var n := int(m.character.stats.get(stat, 0))
	var first: String = DiaryData.FIRSTS.get(stat, "")
	if first != "" and n == 1:
		note(first, stat)
	elif DiaryData.EVERY.has(stat):
		note(String(DiaryData.EVERY[stat]) % n, stat)


func _on_guardian(how: String) -> void:
	var g: Dictionary = m.guardian.info()
	var name := String(CreaturesData.get_data(String(g["creature"])).get("name", "?"))
	var mins := roundi((now() - _arrived) / 60.0)
	note("Guardiano %s: %s, nel mondo «%s» (vigore %d), dopo %d minuti e %d appassimenti" % [
		"curato" if how == "curato" else "sconfitto", name, m.world_meta.get("nome", ""), int(m.world_meta.get("vigore", 1)),
		mins, _deaths_here], "guardiano")
	add("guardiani_" + how)


func _on_died() -> void:
	_deaths_here += 1
	add("morti")
	var st: int = m.depth_watch.stratum if m.depth_watch != null else 0
	add("morti_strato", StrataData.STRATA[clampi(st, 0, StrataData.STRATA.size() - 1)]["name"])
	if count("morti") == 1:
		note("Primo appassimento (%s)" % StrataData.STRATA[clampi(st, 0, StrataData.STRATA.size() - 1)]["name"], "morte")


func _on_crafted(id: String, n: int) -> void:
	add("fatti", id, n)
	if id.begins_with("lingotto_") and count("fatti", id) == n:
		note("Primo %s" % String(ItemsData.get_item(id).get("name", id)).to_lower(), "metallo")


func _process(dt: float) -> void:
	if not m.built:
		return
	_t += dt
	if _t < 1.0:
		return
	var st: int = m.depth_watch.stratum if m.depth_watch != null else 0
	add("tempo_strato", StrataData.STRATA[clampi(st, 0, StrataData.STRATA.size() - 1)]["name"], roundi(_t))
	_t = 0.0


static func clock(secs: float) -> String:
	var s := int(secs)
	return "%d:%02d" % [s / 3600, (s / 60) % 60] if s >= 3600 else "%d min" % (s / 60)


## La scheda del Semenzaio: [titolo, righe [id, testo, colore], testo a destra].
func view(_selected: String) -> Array:
	var rows := []
	var tappe: Array = data()["tappe"]
	for i in range(tappe.size() - 1, -1, -1):
		var e: Array = tappe[i]
		rows.append([str(i), "%s   ·   %s" % [clock(float(e[0])), e[1]], String(DiaryData.COLORS.get(String(e[2]), "#cfeee4"))])
	return ["La tua storia — %s di gioco, %d tappe" % [clock(now()), tappe.size()], rows, summary(true)]


## Il riassunto dei conteggi (con i colori per la scheda, senza per il file).
func summary(colored: bool) -> String:
	var c: Dictionary = data()["conti"]
	var h := func(t: String) -> String: return ("\n[color=#ffd08a]%s[/color]\n" % t) if colored else "\n%s\n" % t.to_upper()
	var t := ""
	t += h.call("Appassimenti: %d" % int(c.get("morti", 0)))
	for k in (c.get("morti_strato", {}) as Dictionary):
		t += "• %s: %d\n" % [k, int(c["morti_strato"][k])]
	t += h.call("Tempo per strato")
	var tot := 0
	for k in (c.get("tempo_strato", {}) as Dictionary):
		tot += int(c["tempo_strato"][k])
	for k in (c.get("tempo_strato", {}) as Dictionary):
		var s := int(c["tempo_strato"][k])
		t += "• %s: %s (%d%%)\n" % [k, clock(s), roundi(100.0 * s / maxf(tot, 1.0))]
	t += h.call("Guardiani: %d curati, %d sconfitti" % [int(c.get("guardiani_curato", 0)), int(c.get("guardiani_sconfitto", 0))])
	var made: Dictionary = c.get("fatti", {})
	var ids := made.keys()
	ids.sort_custom(func(a: String, b: String) -> bool: return int(made[a]) > int(made[b]))
	t += h.call("Più fabbricati (%d oggetti diversi)" % ids.size())
	for id in ids.slice(0, 12):
		t += "• %s ×%d\n" % [ItemsData.get_item(String(id)).get("name", id), int(made[id])]
	if colored:
		t += "\n[color=#6a8a84]«Esporta» scrive il diario in un file di testo, da rileggere o da mandare a chi ti aiuta a bilanciare il gioco.[/color]"
	return t


## Il diario in un file di testo; restituisce il percorso.
func export() -> String:
	var path := "%s/diario_%s.txt" % [SavePaths.root, String(m.character.id)]
	var t := "Diario di %s — %s di gioco\n" % [m.character.name, clock(now())]
	for e in data()["tappe"]:
		t += "%s\t%s\n" % [clock(float(e[0])), e[1]]
	t += summary(false)
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return ""
	f.store_string(t)
	f.close()
	return ProjectSettings.globalize_path(path)
