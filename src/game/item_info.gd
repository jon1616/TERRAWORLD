class_name ItemInfo
extends RefCounted
## Tutto ciò che si sa di un oggetto, in testo per la casella «Esamina» della Bisaccia (`ExaminePanel`): tratto,
## descrizione, valori, a cosa serve (le ricette che lo usano, con la stazione) e come si ottiene.
## Richiesta dell'utente (25 set 2026): uno spazio apposito dove mettere un oggetto per sapere a cosa serve — non nel
## suggerimento.

const STATS := [["damage", "Danno"], ["speed", "Colpi al secondo"], ["defense", "Scorza"], ["power", "Forza"],
	["heal", "Cura"], ["linfa", "Linfa"]]


## Testo con i colori (BBCode) per un RichTextLabel.
static func bbcode(id: String, tratto := "", dati := {}) -> String:
	var it := ItemsData.get_item(id)
	if it.is_empty():
		return ""
	var slot := {"id": id, "tratto": tratto, "dati": dati}
	var t := "[font_size=20][color=#ffd08a]%s[/color][/font_size]\n" % Gear.full_name(slot)
	if dati.has("geni"):
		t += Genome.sheet(dati)
	if id == "creatura" and dati.has("specie"):
		t += HerdInfo.sheet(dati)                  # voce 59
	if id == "uovo" and dati.has("genitori"):
		t += "[color=#ffd08a]Figlio di %s e %s[/color]\n" % [dati["genitori"][0], dati["genitori"][1]]
		t += Breeding.sheet(dati.get("doti", {}))
	if id == "uovo" and dati.has("specie"):
		t += "[color=#9fc8c0]Nell'Incubatrice si schiude in %d secondi (anche se sei lontano): nasce già tua.[/color]\n" % int(HerdData.HATCH)
	if tratto != "":
		t += "[color=#ffd08a]Tratto %s:[/color] %s\n" % [TraitsData.TRAITS[tratto]["name"], TraitsData.TRAITS[tratto]["desc"]]
	if String(it.get("desc", "")) != "":
		t += "[color=#cfeee4]%s[/color]\n" % it["desc"]
	if it.get("unique", false):
		t += "[color=#ffd24a]Oggetto unico.[/color] [color=#c8b890][i]%s[/i][/color]\n" % it.get("story", "")
	for e in it.get("effects", []):
		t += "[color=#ffd24a]✦ %s[/color]\n" % EffectsData.line(String(e))          # voce 85
	var stats := []
	for s in STATS:
		if it.has(s[0]) and not s[0] in ["damage", "speed", "defense", "power"]:
			stats.append("%s %s" % [s[1], it[s[0]]])
	var gl := Gear.line(slot)                  # voce 50: i valori veri, con tratto e fascia
	if gl != "":
		stats.push_front(gl)
	if not stats.is_empty():
		t += "[color=#9fc8c0]%s[/color]\n" % " · ".join(stats)
	if it.has("mat"):
		# voce 49: di che materiale è fatto, e le proprietà da cui nascono i suoi valori
		t += "[color=#8ef0d8]Materiale:[/color] [color=#9fc8c0]%s[/color]\n" % MaterialsData.describe(String(it["mat"]))
		var md := MaterialsData.get_mat(String(it["mat"]))
		if md.has("alloy"):
			t += "[color=#9fc8c0]Lega di %s e %s, risonanza %d.[/color]\n" % [md["alloy"][0], md["alloy"][1], int(md["risonanza"])]
		# voce 306: il carattere del materiale (per un pezzo intero: ogni forma ne prende la sua parte)
		var ct := MaterialsData.trait_text(String(it["mat"]))
		if ct != "":
			t += "[color=#8ef0d8]Carattere del materiale:[/color] [color=#9fc8c0]%s[/color] [color=#6a8a84](un'armatura ne prende un quarto per pezzo, guanti, stivali e mantelli metà, in mano metà)[/color]\n" % ct
	if Bisaccia.is_gear(id) and AwakenData.effect_of(id) != "":
		# voce 355: il risveglio (fatto, o che cosa darebbe e quanto costa)
		var fx := EffectsData.info(AwakenData.effect_of(id))
		if String(dati.get("risveglio", "")) != "":
			t += "[color=#ffd24a]✦ Risvegliato — %s:[/color] [color=#d8f0e8]%s[/color]\n" % [fx.get("name", ""), fx.get("desc", "")]
		else:
			var parts := []
			var c := AwakenData.cost_of(id)
			for k in c:
				parts.append("%d %s" % [int(c[k]), ItemsData.get_item(String(k)).get("name", k)])
			t += "[color=#b8a0d8]Si può risvegliare al Maglio[/color] [color=#9fc8c0](%s): «%s», %s.[/color]\n" % [", ".join(parts),
				fx.get("name", ""), fx.get("desc", "")]
	if Bisaccia.is_gear(id):
		# voce 54: qualità e posti d'innesto
		var q := Gear.quality(slot)
		var qd: Dictionary = TraitsData.QUALITY[q]
		var inn := []
		for x in (dati.get("innesti", []) as Array):
			inn.append("%s (%s)" % [TraitsData.TRAITS[x]["name"], TraitsData.TRAITS[x]["desc"]])
		t += "[color=%s]Qualità %s[/color] · [color=#9fc8c0]posti d'innesto %d su %d%s[/color]\n" % [qd["color"], qd["name"],
			Gear.traits(slot).size(), Gear.slots(slot), (": " + ", ".join(inn)) if not inn.is_empty() else ""]
	var fascia := String(dati.get("fascia", ""))
	if FormsData.FASCE.has(fascia):
		t += "[color=#ffd08a]Fascia di %s:[/color] %s\n" % [FormsData.FASCE[fascia]["name"], FormsData.FASCE[fascia]["desc"]]
	for sid in SetsData.of_item(id):
		var sd: Dictionary = SetsData.all()[sid]
		var names := []
		for p in sd["pieces"]:
			names.append(String(ItemsData.get_item(String(p))["name"]))
		t += "[color=#ffd08a]Set «%s»:[/color] [color=#9fc8c0]%s[/color]\n[color=#6a8a84]con %s[/color]\n" % [sd["name"],
			sd["desc"], ", ".join(names)]
	var col := RelicsData.collection_of(id)
	if col != "":
		var cd: Dictionary = RelicsData.COLLECTIONS[col]
		t += "[color=#ffd24a]Collezione «%s»:[/color] [color=#9fc8c0]completa, per sempre: %s[/color]\n" % [cd["name"], cd["desc"]]
	# (voce 351) a cosa serve: prima gli usi fuori dalle ricette (il clic, l'Albero, gli abitanti, il Maglio…), poi le
	# ricette. Un oggetto senza nessun uso lo dice chiaro: è da vendere o da collezione.
	var other := ItemUses.lines(id)
	var uses := uses_of(id)
	t += "\n[color=#8ef0d8]A cosa serve:[/color]\n"
	for u in other:
		t += "• [color=#d8f0e8]%s[/color]\n" % u
	if not uses.is_empty():
		t += "[color=#9fc8c0]Negli ingredienti di %d ricett%s:[/color]\n" % [uses.size(), "a" if uses.size() == 1 else "e"]
	for u in uses.slice(0, 12):
		t += "• %s\n" % u
	if uses.size() > 12:
		t += "[color=#6a8a84]… e altre %d ricette (cercale in Creare scrivendo il suo nome)[/color]\n" % (uses.size() - 12)
	if other.is_empty() and uses.is_empty():
		t += "[color=#6a8a84]Per ora niente: si tiene come ricordo o si vende.[/color]\n"
	var how := how_to_get(id)
	if how != "":
		t += "\n[color=#8ef0d8]Come si ottiene:[/color] %s" % how
	return t


## Le ricette che usano l'oggetto, con quanti ne servono e dove: «Torcia di resina ×3 (1 · a mano)».
static func uses_of(id: String) -> Array:
	var out := []
	var seen := {}
	for r in RecipesData.using(id):
		var o := String(r["out"])
		if seen.has(o):
			continue
		seen[o] = true
		var n := int(r["qty"])
		var st := String(r["station"])
		var where := "a mano" if st == "" else String(StationsData.STATIONS[st]["name"])
		out.append("%s%s  [color=#6a8a84](%d · %s)[/color]" % [ItemsData.get_item(o)["name"], (" ×%d" % n) if n > 1 else "",
			int(r["in"][id]), where])
	return out


## Come si ottiene, in breve: fabbricato (dove), scavando, dalle creature, dagli scrigni o da altro.
static func how_to_get(id: String) -> String:
	if ItemsData.get_item(id).has("source"):
		return String(ItemsData.get_item(id)["source"])
	var rs := RecipesData.making(id)
	if not rs.is_empty():
		var st := String(rs[0]["station"])
		return "si fabbrica %s" % ("a mano" if st == "" else "al %s" % StationsData.STATIONS[st]["name"])
	for t in TileDefs.DROP:
		if TileDefs.DROP[t] == id:
			return "scavando %s" % TileDefs.NAMES.get(t, "")
	var from := []
	for cid in CreaturesData.CREATURES:
		for e in LootData.TABLES.get(String(CreaturesData.CREATURES[cid]["loot"]), []):
			if e["item"] == id:
				from.append(String(CreaturesData.CREATURES[cid]["name"]))
	for cid in TrophyItemsData.TROPHY_OF:
		if TrophyItemsData.TROPHY_OF[cid] == id:
			from.append("solo le rare: %s" % CreaturesData.CREATURES[cid]["name"])
	if RelicsData.collection_of(id) != "":
		from.append("in un reliquiario murato dei Seminatori, nel profondo")
	if id == "polvere_iridata":
		from.append("solo le creature iridate")
	var chests := false
	for tb in LootData.TABLES:
		if String(tb).begins_with("rovina_"):
			for e in LootData.TABLES[tb]:
				if e["item"] == id:
					chests = true
	var parts := []
	if not from.is_empty():
		# (voce 351) al più cinque nomi: un elenco lungo copriva il resto
		var more := from.size() - 5
		parts.append("dalle creature (%s%s)" % [", ".join(from.slice(0, 5)), (" e altre %d" % more) if more > 0 else ""])
	if chests:
		parts.append("negli Scrigni dei Seminatori")
	if ItemsData.OTHER_SOURCES.has(id):
		parts.append(String(ItemsData.OTHER_SOURCES[id]))
	return "; ".join(parts)
