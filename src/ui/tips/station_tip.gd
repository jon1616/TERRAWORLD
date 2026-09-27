class_name StationTip
extends RefCounted
## Le schede delle stazioni del mondo (26 set 2026): banchi (quante ricette, se sei abbastanza vicino), casse e scrigni
## (nome, caselle, che cosa contengono), portali (`PortalInfo`), l'Albero-Madre (lo stadio e che cosa chiede), la
## Bacheca, i nidi, i bozzoli dei Custodi, il Cuore del mondo. La riga di ciò che fa: `TipWordsData.STATION_USE`.

const CHESTS := ["cesta", "scrigno", "reliquiario", "fagotto"]

static var _recipes := {}              # stazione -> quante ricette (contate una volta)


static func card(m: Node2D, o: Vector2i, id: String) -> TipCard:
	if id == "portale":
		return portal(m, o)
	if id.begins_with("albero_madre"):
		return mother_tree(m)
	if id.begins_with("nido_"):
		var e: Dictionary = m.ecology.nests.get("%d,%d" % [o.x, o.y], {})
		if not e.is_empty():
			return WorldTip.nest(m, e)
	var sd: Dictionary = StationsData.STATIONS.get(id, {})
	var c := TipCard.new()
	var item := String(sd.get("item", ""))
	c.title(String(sd.get("name", id)), Color("#e0b878"), item if ItemsData.get_item(item).has("name") else null)
	if id in CHESTS or ChestsData.is_chest(id):
		return _chest(m, c, o, id)
	if id.begins_with("braciere") or id.begins_with("leva") or id.begins_with("piastra") or id.begins_with("cristallo_eco"):
		var e: Dictionary = m.mechanisms.place_of(o)
		c.sub("un meccanismo dei Seminatori")
		if not e.is_empty():
			if id.begins_with("cristallo_eco") and e["enigma"].has("elementi"):
				var el := String(e["enigma"]["elementi"].get(m.mechanisms._key_of(e, o), ""))
				if el != "":
					c.pair("Risuona con", ElementsData.tag(el), Color("#8ef0d8"))
			c.line(m.mechanisms.hint(e), TipCard.GOLD)
		c.hint("Clic destro" if not id.begins_with("piastra") else "Salici sopra")
		return c
	if id == "maglio":
		c.line(m.vigor.hint(), TipCard.GOLD)             # voce 79
		c.hint("Clic destro con un attrezzo in mano: tempra")
	if id == "leggio":
		var open := false
		for e in m.world_meta.get("cripte", []):
			if int(e["x"]) == o.x and int(e["y"]) == o.y and m.chains.is_open(String(e["catena"]), int(e["tappa"])):
				open = true
				c.sub("la cripta di «%s»" % m.chains.title_of(String(e["catena"])), TipCard.GOLD)
		var pl: Dictionary = m.places.at(o) if m.places != null else {}
		if not open and not pl.is_empty():
			c.sub(String(PlacesData.PLACES[String(pl["id"])]["name"]), TipCard.GOLD)
			c.line("La storia di questo luogo", TipCard.TEXT)
		else:
			c.line("Una tappa della catena: storia, premio e l'indizio dopo" if open else "Già letto", TipCard.TEXT if open else TipCard.DIM)
		c.hint("Clic destro: leggi")
		return c
	if id == "stele":
		var e: Dictionary = m.language.stele().get(Language._key(o), {})
		if not e.is_empty():
			var words: Array = e["words"]
			c.sub("una frase nella lingua dei Seminatori")
			c.text("[color=#6ff0b8]%s[/color]" % Language.line_sem(words))
			c.text(m.language.line_it(words))
			c.bar("Capisci %d parole su %d" % [m.language.understood(e), words.size()], float(m.language.understood(e)) / maxf(words.size(), 1),
				Color("#6ff0b8"))
			if not (e.get("hint", []) as Array).is_empty():
				c.line("Indica un luogo di questo mondo" if not e.get("segnata", false) else "Il luogo che indica è sulla mappa", TipCard.GOLD)
		c.hint("Clic destro: leggi")
		return c
	if id.begins_with("bozzolo_") and id != "bozzolo_rotto":
		c.sub("tana di un Custode")
		c.line("Dentro dorme un Custode: si sveglia quando ti avvicini", Color("#ff8a6a"))
		return c
	var n := recipes_at(id)
	if n > 0:
		c.sub("banco · %d ricette" % n)
	c.line(String(TipWordsData.STATION_USE.get(id, "")), TipCard.TEXT)
	if n > 0:
		var near: bool = Crafting.stations_near(m.world, m.player_cell()).has(id)
		c.line("Sei abbastanza vicino: le sue ricette sono nel pannello Creare" if near
			else "Avvicinati (5 tessere) per usarlo nel pannello Creare", TipCard.GOOD if near else TipCard.SOFT)
	match id:
		"bacheca":
			var open: Array = m.board.open_list() if not m.character.bacheca.is_empty() else []
			var ready := open.filter(func(r: Dictionary) -> bool: return m.board.can_deliver(r)).size()
			c.line("Richieste aperte: %d · pronte da consegnare: %d · fatte: %d" % [open.size(), ready,
				int(m.character.bacheca.get("fatte", 0))], TipCard.GOOD if ready > 0 else TipCard.SOFT)
			c.hint("Clic destro: apri la Bacheca")
		"cuore_mondo":
			c.line("Guardiano: %s" % String(m.world_meta.get("guardiano", "dorme")), Color("#ff8a6a"))
	var desc := String(ItemsData.get_item(item).get("desc", ""))
	if desc != "" and not TipWordsData.STATION_USE.has(id):
		c.text("[i][color=#%s]%s[/color][/i]" % [TipCard.SOFT.to_html(false), desc])
	return c


static func recipes_at(id: String) -> int:
	if _recipes.is_empty():
		for r in RecipesData.all():
			var st := String(r.get("station", ""))
			_recipes[st] = int(_recipes.get(st, 0)) + 1
	return int(_recipes.get(id, 0))


static func _chest(m: Node2D, c: TipCard, o: Vector2i, id: String) -> TipCard:
	var b: Bisaccia = m.world.chest_at(o)
	var cfg: Dictionary = m.storage.settings(o)
	if String(cfg["nome"]) != "":
		c.sub("«%s»" % cfg["nome"], TipCard.GOLD)
	if b == null:
		c.line("Vuota", TipCard.SOFT)
		return c
	var used := 0
	var counts := {}
	for i in b.slots.size():
		var it: String = b.id_at(i)
		if it != "":
			used += 1
			counts[it] = int(counts.get(it, 0)) + b.count_at(i)
	c.bar("%d caselle su %d" % [used, b.slots.size()], float(used) / maxf(b.slots.size(), 1), Color("#e0b878"))
	var ids := counts.keys()
	ids.sort_custom(func(a: String, bb: String) -> bool: return int(counts[a]) > int(counts[bb]))
	var rows := []
	for k in ids.slice(0, 6):
		rows.append([String(ItemsData.get_item(String(k)).get("name", k)), "×%d" % int(counts[k])])
	c.stats(rows)
	if ids.size() > 6:
		c.line("… e altri %d" % (ids.size() - 6), TipCard.DIM)
	if ChestsData.is_chest(id):
		c.line("Usata per creare" if bool(cfg["creare"]) else "Non usata per creare", TipCard.GOOD if bool(cfg["creare"]) else TipCard.DIM)
	c.hint("Clic destro: apri")
	return c


static func portal(m: Node2D, o: Vector2i) -> TipCard:
	var c := TipCard.new()
	c.accent = Color("#6ff0d0")
	c.width = 420.0
	c.text(PortalInfo.text(m.portal, o))
	return c


static func mother_tree(m: Node2D) -> TipCard:
	var al: AlberoMadre = m.albero
	var c := TipCard.new()
	c.title("Albero-Madre", Color("#8ef0d8"))
	if al.done():
		c.sub("sveglio: il Giardino è compiuto")
		return c
	var st: Dictionary = al.current()
	c.sub("stadio %d di %d · %s" % [al.stage() + 1, MotherTreeData.STAGES.size(), st.get("name", "")])
	var offers: Array = st["offers"]
	for i in offers.size():
		var of: Dictionary = offers[i]
		var p := al.progress(i)
		var what := String(of.get("text", ItemsData.get_item(String(of.get("item", ""))).get("name", "")))
		c.bar("%s  %d/%d" % [what, int(p[0]), int(p[1])], float(p[0]) / maxf(float(p[1]), 1.0),
			TipCard.GOOD if int(p[0]) >= int(p[1]) else Color("#8ef0d8"))
	c.hint("Clic destro: offri e guarda gli stadi")
	return c
