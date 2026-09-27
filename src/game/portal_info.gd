class_name PortalInfo
## La scheda di un portale (richiesta dell'utente, 26 set 2026): che mondo c'è dall'altra parte. Nome, vigore e cosa
## significa, Guardiano del Cuore, stagione, geni (quelli mai visti restano «?»), e per un mondo già visitato quanto
## se n'è esplorato, il tempo passato, la firma e il Guardiano. La mostra `StationTip.portal` con il mouse sopra il portale.

const GUARD_STATE := {"dorme": "dorme ancora", "sconfitto": "sconfitto", "curato": "curato"}


static func text(portal: Portal, o: Vector2i) -> String:
	var dest := portal.destination(o)
	var e: Dictionary = portal._portals().get(Portal._key(o), {})
	var back: bool = e.get("ritorno", false)
	var meta: Dictionary = WorldSave.read_meta(String(dest[0])) if String(dest[0]) != "" else {}
	var genes: Array = meta.get("geni", e.get("geni", [])) if back else e.get("geni", [])
	var vigor := int(meta.get("vigore", dest[3])) if back else int(dest[3])
	var t := "[font_size=20][color=#ffd08a]%s «%s»[/color][/font_size]\n" % ["Ritorno a" if back else "Verso", dest[1]]
	if meta.get("giardino", false):
		t += "[color=#9fc8c0]Il tuo Giardino, dove dorme l'Albero-Madre.[/color]\n"
		return t + _footer()
	# vigore
	var pct := roundi((Portal.vigor_mult(vigor) - 1.0) * 100.0)
	t += "[color=#8ef0d8]Vigore %d[/color] · %s\n" % [vigor, ("creature con il %d%% di Vita e danno in più, vene più ricche" % pct)
		if pct > 0 else "il vigore più basso: creature come quelle del Giardino"]
	# voce 81: i Semi leggendari e il Seme Primo
	if e.get("primo", false):
		t += "[color=#ffe8a0]Il Primo Mondo[/color]: tutti i biomi, i geni stellari, il vigore più alto
"
	elif Legends.of_genes(genes) != "":
		t += "[color=#ffd08a]Mondo leggendario[/color]: %s
" % Legends.name_of(Legends.of_genes(genes))
	# Guardiano del Cuore
	var g := GuardiansData.for_vigor(vigor)
	if vigor > GuardiansData.LIST.size() and not e.get("nero", false):
		g = GuardianGen.info(int(meta.get("seme", dest[2])))     # voce 80: oltre il terzo, un Guardiano generato
	var gname := String(CreaturesData.get_data(String(g["creature"])).get("name", "?"))
	var gstate := String(GUARD_STATE.get(String(meta.get("guardiano", "")), "")) if not meta.is_empty() else ""
	t += "[color=%s]Guardiano del Cuore[/color]: %s%s\n" % [g["color"], gname, (" — " + gstate) if gstate != "" else ""]
	# stagione (all'arrivo per un mondo nuovo, quella di adesso per uno già visitato)
	var fixed := int(Genome.effects(genes, "run").get("season", 0))
	var day := int(meta.get("giorno", 1))
	var sd: Dictionary = SeasonsData.SEASONS[SeasonsData.index(day, int(meta.get("seme", dest[2])), fixed)]
	t += "[color=#c8d8a0]Stagione[/color]: %s%s — %s\n" % [sd["name"], " (eterna)" if fixed > 0 else "", sd["desc"]]
	# già visitato?
	if meta.is_empty():
		t += "[color=#d8b070]Mondo mai visitato[/color]: la sua firma è ancora da scoprire.\n"
	else:
		var mins := roundi(float(meta.get("tempo_di_gioco", 0.0)) / 60.0)
		t += "[color=#d8b070]Visitato[/color]: esplorato il %d%%, %s di gioco\n" % [int(meta.get("esplorato", 0)),
			("%d h %02d min" % [mins / 60, mins % 60]) if mins >= 60 else "%d min" % mins]
		var f: Dictionary = meta.get("firma", {})
		if not f.is_empty():
			var sig: Dictionary = SignaturesData.SIGNATURES.get(String(f.get("id", "")), {})
			t += "[color=#c8a0ff]Firma[/color]: %s\n" % (("%s — trovata" % sig.get("name", "?")) if f.get("trovata", false)
				else "non ancora trovata (%s)" % _where(String(sig.get("where", ""))))
	# geni
	t += "\n" + Genome.sheet({"geni": genes, "vigore": vigor})
	return t + _footer()


static func _where(w: String) -> String:
	match w:
		"superficie":
			return "è in superficie"
		"":
			return "chissà dove"
	return "è sotto terra"


static func _footer() -> String:
	return "\n[color=#6a8a84]Clic destro: descrizione · clic destro di nuovo: parti[/color]"
