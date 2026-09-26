class_name Genario
extends RefCounted
## Il Genario (voce 46): la collezione dei geni del personaggio, seconda scheda del Semenzaio (tasto K). Ogni gene è
## mai visto («?»), **visto** (in un mondo o in un Seme: si conosce il nome) o **imparato** (se ne è avuta la Fiala:
## si possono prevedere gli innesti). Si impara con la Provetta, dalle piante-seme, dalle creature e dagli scrigni.
## Dati in `Character.genario` (letti da `Genome.known`).


## Percentuale dei geni imparati.
static func percent() -> float:
	var n := 0
	for g in GenesData.GENES:
		if Genome.state(g) >= 2:
			n += 1
	return 100.0 * n / GenesData.GENES.size()


static func learned() -> int:
	var n := 0
	for g in GenesData.GENES:
		if Genome.state(g) >= 2:
			n += 1
	return n


## Il contenuto della scheda nel Semenzaio: [titolo, righe [id, testo, colore], testo della scheda a destra].
static func view(selected: String) -> Array:
	var rows := []
	for cat in GenesData.CATEGORIES:
		var ci: Dictionary = GenesData.CAT_INFO[cat]
		for g in GenesData.of_cat(cat):
			var st := _state(g)
			var d: Dictionary = GenesData.GENES[g]
			var text := "%s   ·   %s" % [ci["name"], "?" if st == 0 else String(d["name"])]
			if st == 1:
				text += "   (visto)"
			var col := "#6a8a84" if st == 0 else ("#9fb0a8" if st == 1 else String(GenesData.RARITY[int(d["rar"])]["color"]))
			rows.append([g, text, "#ffd08a" if g == selected else col])
	var title := "Genario — %d geni imparati su %d (%d%%)" % [learned(), GenesData.GENES.size(), roundi(percent())]
	return [title, rows, detail(selected)]


## Come `Genome.state`, ma i geni di superficie si conoscono sempre per nome (sono scritti sugli oggetti Seme).
static func _state(g: String) -> int:
	var st := Genome.state(g)
	return 1 if st == 0 and GenesData.cat_of(g) == "superficie" else st


static func detail(g: String) -> String:
	if g == "":
		return "[color=#9fc8c0]Il Genario raccoglie i geni dei Semi di mondo. Un gene si [b]vede[/b] entrando in un mondo che lo porta o in un Seme; si [b]impara[/b] avendone la Fiala: con la Provetta di Linfa (clic su ciò che lo porta), raccogliendo le piante-seme, dalle creature e negli scrigni. I geni imparati si possono fissare negli innesti.[/color]"
	var st := _state(g)
	var d: Dictionary = GenesData.GENES[g]
	var ci: Dictionary = GenesData.CAT_INFO[String(d["cat"])]
	if st == 0:
		return "[color=%s]%s[/color]\n\n[color=#6a8a84]Un gene mai visto. Si preleva in %s.%s[/color]" % [ci["color"], ci["name"], ci["where"],
			_how(d)]
	var t := "[font_size=24]%s[/font_size]\n" % GenesData.tag(g)
	t += "[color=%s]%s[/color] · [color=#9fc8c0]%s, dominanza %d[/color]\n\n" % [ci["color"], ci["name"],
		GenesData.RARITY[int(d["rar"])]["name"], int(d["dom"])]
	t += "%s\n\n" % d["desc"]
	t += "[color=#8ef0d8]Dove si preleva:[/color] %s.%s\n" % [ci["where"], _how(d)]
	t += "[color=#8ef0d8]Stato:[/color] %s\n" % ("imparato: se ne può fissare la Fiala negli innesti" if st >= 2
		else "visto: ne conosci il nome, ma non ne hai ancora avuto la Fiala")
	return t


static func _how(d: Dictionary) -> String:
	match String(d.get("only", "")):
		"mutazione":
			return " Non nasce in nessun Seme trovato: solo per mutazione, innestando"
		"firma":
			return " Solo dalla firma di certi mondi"
	if d.has("combo"):
		return " Nasce per mutazione, più spesso quando i genitori portano due geni precisi"
	if int(d.get("vmin", 0)) > 1:
		return " Solo nei mondi di vigore %d o più" % int(d["vmin"])
	return ""
