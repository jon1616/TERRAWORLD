class_name Sowers
extends Node
## I Seminatori nei Cuori (Roadmap 36, voce 342; dati in `SowersData`, il canone in `UNIVERSO.md`). Ogni Guardiano
## curato risveglia una parte del suo Seminatore: la prima volta il nome, poi un ricordo alla volta. Ogni Guardiano
## abbattuto ne spegne una: si conta, non si punisce. Saréth (l'Avvizzitore) si risveglia o si spegne una volta sola;
## Maesh (l'ultimo Seminatore) si ricorda di te mentre muore.
## Nel personaggio: `stats["risveglio_<id>"]` e `stats["spento_<id>"]` (anche «senza_nome»), e «risvegli» in tutto.
## Nel Taccuino del Semenzaio, la pagina «I Seminatori» (`rows`/`detail`, chiamate da `Chains.view`).

const DELAY := 2.5                       # secondi dopo la pagina del Guardiano: prima il Cuore, poi il nome

var m: Node2D
var paused := false                      # (le prove chiamano `on_resolved` a mano)


func setup(main: Node2D) -> void:
	m = main
	m.guardian.resolved.connect(func(how: String) -> void:
		if not paused:
			on_resolved(String(m.guardian.info().get("id", "")), how))
	m.fauna.killed.connect(_on_killed)


func _on_killed(c: Creature) -> void:
	if paused or not bool(CreaturesData.get_data(c.id).get("primo_boss", false)):
		return
	on_resolved("primo", "curato")               # Maesh: non era un nemico; muore ricordandoti


## Un Guardiano è finito (`how`: «curato» o «sconfitto»). Restituisce il ricordo tornato ("" se nessuno).
func on_resolved(gid: String, how: String) -> String:
	var k := SowersData.of_guardian(gid)
	if k == "":
		return ""
	var sw := SowersData.get_sower(k)
	var st: Dictionary = m.character.stats
	if how == "curato":
		var n := int(st.get("risveglio_" + k, 0))
		var mems: Array = sw["memories"]
		st["risveglio_" + k] = n + 1
		m.objectives.bump("risvegli")
		if n >= mems.size():
			return ""                                    # ha già detto tutto quello che ricordava
		var line := String(mems[n])
		_later(func() -> void:
			m.depth_watch.banner.show_stratum(String(sw["name"]) if n == 0 or k == "senza_nome" else "%s ricorda" % sw["name"],
				"«%s»" % line, Color(String(sw["color"]))))
		if m.get("diary") != null:
			m.diary.note("%s: «%s»" % [sw["name"], line], "storia")
		return line
	var s := int(st.get("spento_" + k, 0))
	st["spento_" + k] = s + 1
	if s == 0 and String(sw["spent"]) != "":
		var known := int(st.get("risveglio_" + k, 0)) > 0 or k == "sareth"
		var txt := String(sw["spent"]) if known else "Qualcosa, nel Cuore, ha smesso di ricordare."
		_later(func() -> void: m.hud.toast(txt))
	return ""


func _later(f: Callable) -> void:
	get_tree().create_timer(DELAY).timeout.connect(f)


## Quanti Seminatori con nome hanno almeno una parte risvegliata.
func named_awake() -> int:
	var n := 0
	for k in SowersData.ORDER:
		if int(m.character.stats.get("risveglio_" + k, 0)) > 0:
			n += 1
	return n


## Nel Taccuino: una riga sola, «I Seminatori», appena c'è qualcosa da dire.
func rows(selected: String) -> Array:
	var st: Dictionary = m.character.stats
	var any := false
	for k in SowersData.ORDER + ["senza_nome"]:
		if int(st.get("risveglio_" + k, 0)) + int(st.get("spento_" + k, 0)) > 0:
			any = true
	if not any:
		return []
	return [["storia:seminatori", "I Seminatori   ·   %d nomi ricordati" % named_awake(),
		"#ffd08a" if selected == "storia:seminatori" else "#d8c8ff"]]


func detail() -> String:
	var st: Dictionary = m.character.stats
	var t := "[color=#b8a8e8]Chi custodisce i Cuori. Curare un Guardiano gli restituisce un ricordo; abbatterlo ne spegne una parte.[/color]\n"
	var unknown := 0
	for k in SowersData.ORDER + ["senza_nome"]:
		var sw := SowersData.get_sower(k)
		var a := int(st.get("risveglio_" + k, 0))
		var s := int(st.get("spento_" + k, 0))
		if a == 0 and s == 0:
			unknown += 1
			continue
		var name := String(sw["name"]) if a > 0 or k == "sareth" else "?"
		var title := String(sw["title"]) if a > 0 or k == "sareth" else "un nome che non ricordi"
		t += "\n[color=%s]%s[/color] [color=#8a9a98]— %s · risvegliato %d, spento %d[/color]\n" % [String(sw["color"]), name, title, a, s]
		var mems: Array = sw["memories"]
		for i in mini(a, mems.size()):
			t += "   [color=#cfeee4]«%s»[/color]\n" % String(mems[i])
		if s > 0 and a == 0 and k != "sareth":
			t += "   [color=#6a7a78]…[/color]\n"
	if unknown > 0:
		t += "\n[color=#6a8a84]Altri Cuori aspettano. %d nomi non sono ancora tornati.[/color]" % unknown
	return t
