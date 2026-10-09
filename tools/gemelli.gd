extends SceneTree
## I gemelli (voce 487, 9 ott 2026; dall'analisi: «migliaia di oggetti nascono da tabelle, molti rischiano di essere
## gemelli con un nome diverso»). La regola del piano «La vastità»: un oggetto, un gesto. Qui si misura chi la rompe:
##   identici   stessi dati in tutto tranne nome, descrizione, icona e provenienza: lo stesso oggetto due volte;
##   gemelli    stesso tipo, stessa forma, stessa fase, stesse chiavi degli effetti (`acc`, `effects`, `mods`, `boons`),
##              solo i numeri diversi: si distinguono soltanto leggendo la scheda;
##   per tipo   quanti oggetti, quante «firme» diverse (tipo + chiavi): più firme = più gesti.
## Le armi e le armature di forma × materiale (`gen`) e i blocchi non contano: lì il materiale è il gesto (carattere).
##   Godot_console.exe --headless --path . --script res://tools/gemelli.gd   → prove/gemelli.txt

const SKIP_KINDS := ["blocco", "parete", "materiale", "minerale", "lingotto", "gemma", "seme", "coltura", "pesce",
	"trofeo", "pagina", "tavoletta", "curiosita", "ricordo", "reliquia", "gruppo", "moneta", "stazione", "costrutto"]
const LOOSE := ["name", "desc", "icon", "source", "story", "linea", "value", "fase", "rar", "unique", "stack"]


func _init() -> void:
	var items := ItemsData.all()
	var ident := {}
	var twins := {}
	var kinds := {}
	for id in items:
		var it: Dictionary = items[id]
		var kind := String(it.get("kind", ""))
		if kind in SKIP_KINDS or it.has("gen"):
			continue
		var same := {}
		for k in it:
			if not (String(k) in LOOSE):
				same[k] = it[k]
		var ik := kind + "|" + JSON.stringify(same, "", true)
		if not ident.has(ik):
			ident[ik] = []
		(ident[ik] as Array).append(String(id))
		var sig := "%s|%s|%s|%s" % [kind, String(it.get("form", "")), str(it.get("fase", "")), ",".join(_keys(it))]
		if not twins.has(sig):
			twins[sig] = []
		(twins[sig] as Array).append(String(id))
		if not kinds.has(kind):
			kinds[kind] = {"n": 0, "sig": {}}
		kinds[kind]["n"] += 1
		kinds[kind]["sig"][sig.get_slice("|", 0) + "|" + sig.get_slice("|", 1) + "|" + sig.get_slice("|", 3)] = true
	var out := []
	out.append("I GEMELLI (voce 487) — %s" % Time.get_datetime_string_from_system())
	out.append("")
	var n_ident := 0
	out.append("Attenzione: «identici nei dati» non vuol dire identici in gioco. Richiami, Semi, mappe, vene e fili fanno")
	out.append("cose diverse secondo il loro id (le tabelle che li leggono stanno altrove). I veri doppioni sono quelli dove")
	out.append("nessun'altra tabella usa l'id: le spoglie dei boss con gli stessi numeri, i piatti con gli stessi effetti.")
	out.append("Togliere o unire è una scelta di design, da fare con l'utente.")
	out.append("")
	out.append("== Identici nei dati")
	for k in ident:
		var l: Array = ident[k]
		if l.size() > 1:
			n_ident += l.size() - 1
			out.append("  %s" % ", ".join(l))
	out.append("  totale: %d oggetti in più" % n_ident)
	out.append("")
	out.append("== Gemelli (stesso tipo, forma, fase e chiavi; solo i numeri diversi), i gruppi più grandi")
	var groups := []
	var n_twins := 0
	for k in twins:
		var l: Array = twins[k]
		if l.size() > 1:
			groups.append([k, l])
			n_twins += l.size() - 1
	groups.sort_custom(func(a: Array, b: Array) -> bool: return (a[1] as Array).size() > (b[1] as Array).size())
	for g in groups.slice(0, 40):
		var l: Array = g[1]
		out.append("  %3d × %s: %s%s" % [l.size(), g[0], ", ".join(l.slice(0, 6)), " …" if l.size() > 6 else ""])
	out.append("  gruppi: %d, oggetti che hanno un gemello: %d" % [groups.size(), n_twins])
	out.append("")
	out.append("== Per tipo: oggetti e firme diverse (tipo, forma, chiavi)")
	var ks := kinds.keys()
	ks.sort_custom(func(a: String, b: String) -> bool: return int(kinds[a]["n"]) > int(kinds[b]["n"]))
	for k in ks:
		out.append("  %-14s %5d oggetti  %4d firme" % [k, int(kinds[k]["n"]), (kinds[k]["sig"] as Dictionary).size()])
	var f := FileAccess.open("res://prove/gemelli.txt", FileAccess.WRITE)
	f.store_string("\n".join(out) + "\n")
	f.close()
	print("gemelli: identici %d, gruppi di gemelli %d (%d oggetti con un gemello) → prove/gemelli.txt" % [n_ident, groups.size(), n_twins])
	quit()


## Le chiavi di ciò che l'oggetto fa (non i numeri).
static func _keys(it: Dictionary) -> Array:
	var out := []
	for field in ["acc", "mano", "boons"]:
		if it.get(field) is Dictionary:
			for k in it[field]:
				out.append("%s.%s" % [field, k])
	for field in ["effects", "mods"]:
		if it.get(field) is Array:
			for e in it[field]:
				out.append("%s.%s" % [field, str(e)])
	for k in ["damage", "defense", "use", "spell", "ammo", "place", "slots", "wings", "pet"]:
		if it.has(k):
			out.append(k)
	# ciò che distingue per valore (non per numero): l'effetto a tempo, il gene della Fiala, il liquido, la famiglia
	if it.get("boon") is Array and not (it["boon"] as Array).is_empty():
		out.append("boon." + str(it["boon"][0]))
	for k in ["gene", "liquid", "fam", "family", "spell"]:
		if it.has(k) and not (it[k] is Dictionary or it[k] is Array):
			out.append("%s=%s" % [k, str(it[k])])
	out.sort()
	return out
