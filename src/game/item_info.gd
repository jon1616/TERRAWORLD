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
	var t := "[font_size=20][color=#ffd08a]%s[/color][/font_size]\n" % TraitsData.full_name(id, tratto)
	if dati.has("geni"):
		t += Genome.sheet(dati)
	if tratto != "":
		t += "[color=#ffd08a]Tratto %s:[/color] %s\n" % [TraitsData.TRAITS[tratto]["name"], TraitsData.TRAITS[tratto]["desc"]]
	if String(it.get("desc", "")) != "":
		t += "[color=#cfeee4]%s[/color]\n" % it["desc"]
	var stats := []
	for s in STATS:
		if it.has(s[0]):
			stats.append("%s %s" % [s[1], it[s[0]]])
	if not stats.is_empty():
		t += "[color=#9fc8c0]%s[/color]\n" % " · ".join(stats)
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
	var uses := uses_of(id)
	t += "\n[color=#8ef0d8]Serve per:[/color]\n"
	if uses.is_empty():
		t += "[color=#6a8a84]nessuna ricetta[/color]\n"
	for u in uses:
		t += "• %s\n" % u
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
		parts.append("dalle creature (%s)" % ", ".join(from))
	if chests:
		parts.append("negli Scrigni dei Seminatori")
	if ItemsData.OTHER_SOURCES.has(id):
		parts.append(String(ItemsData.OTHER_SOURCES[id]))
	return "; ".join(parts)
