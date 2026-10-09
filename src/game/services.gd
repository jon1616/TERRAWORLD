class_name Services
extends Node
## I servizi degli abitanti (voce 353, dati in `ServicesData`): ciò che ogni abitante sa fare, pagato in Lumini. Il
## pannello del commercio (`TradePanel`) li mostra con `rows(npc)` e li chiama con `use(id)`.
## Quante volte si è usato un servizio oggi: `world_meta["servizi"]` = {"giorno", "usi": {servizio: volte}} (i servizi
## si usano dove abita l'abitante, quasi sempre nel Giardino). Ogni `kind` è una funzione `_<kind>` che restituisce ""
## se è andata, altrimenti il perché (e allora i Lumini non si spendono).

var m: Node2D
var _rng := RandomNumberGenerator.new()


func setup(main: Node2D) -> void:
	m = main
	_rng.randomize()


func _uses() -> Dictionary:
	var day: int = m.day.day if m.get("day") != null else 0
	var s: Dictionary = m.world_meta.get("servizi", {})
	if int(s.get("giorno", -1)) != day:
		s = {"giorno": day, "usi": {}}
		m.world_meta["servizi"] = s
	return s["usi"]


## Il prezzo di adesso (alcuni crescono con il livello dell'oggetto o della creatura).
func cost(id: String) -> int:
	var d: Dictionary = ServicesData.SERVICES[id]
	var c := int(d["cost"])
	var step := int(d.get("step", 0))
	if step > 0:
		match String(d["kind"]):
			"qualita":
				c += step * Gear.quality(_held())
			"tempra":
				c += step * Vigor.level(_held())
			"addestra":
				var rec := _pupil()
				c += step * (int(rec.get("lvl", 1)) - 1)
	return roundi(NpcBonds.price(m.character, String(d["npc"]), c))


## Perché adesso non si può ("" se si può): affetto, volte di oggi, Lumini.
func blocked(id: String) -> String:
	var d: Dictionary = ServicesData.SERVICES[id]
	var npc := String(d["npc"])
	if NpcBonds.level(m.character, npc) < int(d.get("lvl", 0)):
		return "serve più affetto (livello %d)" % int(d["lvl"])
	var day := int(d.get("day", 0))
	if day > 0 and int(_uses().get(id, 0)) >= day:
		return "per oggi basta: torna domani"
	if m.character.bisaccia.count("lumino") < cost(id):
		return "servono %d Lumini" % cost(id)
	return ""


## Le righe per il pannello: [id, nome, prezzo, descrizione, perché no ("" = si può), usi rimasti oggi (-1 = senza limite)].
func rows(npc: String) -> Array:
	var out := []
	for id in ServicesData.of_npc(npc):
		var d: Dictionary = ServicesData.SERVICES[id]
		var day := int(d.get("day", 0))
		out.append([id, String(d["name"]), cost(id), String(d["desc"]), blocked(id),
			day - int(_uses().get(id, 0)) if day > 0 else -1])
	return out


## Usa un servizio: paga se va. Restituisce il messaggio da mostrare.
func use(id: String) -> String:
	if not ServicesData.SERVICES.has(id):
		return ""
	var why := blocked(id)
	if why != "":
		return "Non si può: %s." % why
	var d: Dictionary = ServicesData.SERVICES[id]
	var price := cost(id)
	var res := String(call("_" + String(d["kind"]), d.get("p", {})))
	if res.begins_with("!"):
		return res.substr(1)                              # non è andata: niente da pagare
	m.character.bisaccia.remove("lumino", price)
	var u := _uses()
	u[id] = int(u.get(id, 0)) + 1
	m.objectives.bump("servizi")
	var gifts := NpcBonds.add(m.character, String(d["npc"]), 1)   # chi ti serve ti conosce un po' meglio
	for g in gifts:
		var rest: int = m.character.bisaccia.add(String(g), int(gifts[g]))
		if rest > 0:
			m.drops.spawn(String(g), rest, m.player.position)
	m.sfx.play("dono")
	return res


# ---------------------------------------------------------------- l'oggetto in mano e il compagno

func _held() -> Dictionary:
	if m.get("hud") == null:
		return {}
	return m.character.bisaccia.slots[m.hud.sel]


func _pupil() -> Dictionary:
	var f: Dictionary = m.bonds.field() if m.get("bonds") != null else {}
	if not f.is_empty():
		return f
	for r in m.herd.followers():
		return r
	return {}


# ---------------------------------------------------------------- i servizi (un `kind` = una funzione)

## I tre segreti più vicini, segnati sulla mappa (come l'Eco dei Seminatori, senza consumarne uno).
func _segreti(_p: Dictionary) -> String:
	var pc: Vector2i = m.player_cell()
	var open: Array = m.secrets.list.filter(func(s: Dictionary) -> bool: return not s.get("f", false))
	if open.is_empty():
		return "!In questo mondo non resta nessun segreto da trovare."
	open.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return Vector2(m.secrets.rect_of(a).get_center() - pc).length() < Vector2(m.secrets.rect_of(b).get_center() - pc).length())
	for k in mini(3, open.size()):
		var s: Dictionary = open[k]
		var gd: Dictionary = SecretsData.GRADES[clampi(int(s.get("g", 0)), 0, 3)]
		m.language.add_mark(m.secrets.rect_of(s).get_center(), "segreto", Color(gd["color"]))
	return "Sulla mappa (M) ci sono %d segni: i segreti più vicini di questo mondo." % mini(3, open.size())


## (9 ott 2026, l'utente: «lei sta sempre nel Giardino, che non ha una firma») Dove il mondo ha una firma ancora da
## trovare la segna subito; nel Giardino, dove abita, dà una Mappa della firma da usare nel prossimo mondo.
func _firma(_p: Dictionary) -> String:
	var f: Dictionary = m.signature.info()
	if f.is_empty():
		var rest: int = m.character.bisaccia.add("mappa_firma", 1)
		if rest > 0:
			m.drops.spawn("mappa_firma", rest, m.player.position)
		return "Il Giardino non ha una firma, ma ascolto i mondi che ci nascono: ecco una Mappa della firma. Usala nel mondo in cui la cerchi."
	if f.get("trovata", false):
		return "!La firma di questo mondo l'hai già trovata."
	var c := Vector2i(int(f["x"]), int(f["y"]))
	m.map_reveal.reveal_area(c, 8)
	m.language.add_mark(c, "firma", Color("#ffd24a"))
	return "La firma di questo mondo è a %d tessere: l'ho segnata sulla mappa (M)." % roundi(Vector2(c).distance_to(m.player.position / 16.0))


func _boon(p: Dictionary) -> String:
	var names := []
	for b in p.get("boons", []):
		m.boons.add(String(b[0]), float(b[1]))
		names.append(String(Boons.NAMES.get(String(b[0]), b[0])))
	if p.has("herd"):
		for r in m.herd.records():
			r["felice"] = minf(float(r.get("felice", 0.7)) + float(p["herd"]), 1.0)
	return "Ora hai: %s." % ", ".join(names)


func _qualita(_p: Dictionary) -> String:
	var slot := _held()
	if slot.is_empty() or not Bisaccia.is_gear(String(slot["id"])):
		return "!Tieni in mano (nella barra rapida) l'attrezzo, l'arma o il pezzo d'armatura da rifinire."
	var q := Gear.quality(slot)
	if q >= TraitsData.QUALITY.size() - 1:
		return "!È già un capolavoro: meglio di così non si può."
	var dati: Dictionary = slot.get("dati", {})
	dati["q"] = q + 1
	slot["dati"] = dati
	m.character.bisaccia.changed.emit()
	return "%s ora è di qualità %s." % [Gear.full_name(slot), TraitsData.QUALITY[q + 1]["name"]]


func _tempra(_p: Dictionary) -> String:
	var slot := _held()
	var it := ItemsData.get_item(String(slot.get("id", "")))
	if slot.is_empty() or not (it.has("form") or it.get("kind", "") in ["guanti", "stivali", "mantello", "piccone", "ascia", "spada", "arco", "elmo", "corazza", "gambali", "bastone"]):
		return "!Tieni in mano l'attrezzo, l'arma o il pezzo d'armatura da temprare."
	var lv := Vigor.level(slot) + 1
	var cap := VigorData.temper_cap(m.vigor.grade)
	if lv > cap:
		return "!In questo mondo si tempra fino a +%d: serve un mondo più vigoroso." % cap
	var dati: Dictionary = slot.get("dati", {})
	dati["tempra"] = lv
	slot["dati"] = dati
	m.character.bisaccia.changed.emit()
	return "Temprato a mano: %s +%d." % [String(it.get("name", "")), lv]


func _seme_fiala(_p: Dictionary) -> String:
	var slot := _held()
	var gene := GenesData.gene_of_vial(String(slot.get("id", "")))
	if gene == "" or not GenesData.GENES.has(gene):
		return "!Tieni in mano la Fiala del gene che vuoi nel Seme."
	var gd: Dictionary = GenesData.GENES[gene]
	if gd.has("only"):
		return "!Questo gene non nasce in un Seme ordinato: arriva solo da sé."
	var v := maxi(maxi(int(m.world_meta.get("vigore", 1)), 1), int(gd.get("vmin", 0)))
	var g := Genome.roll(_rng, v, gene if String(gd["cat"]) == "superficie" else "")
	if not gene in g["geni"]:
		(g["geni"] as Array).append(gene)
		g["geni"] = Genome.sort(g["geni"])
	var item := Genome.item_of(g)
	if m.character.bisaccia.add_stack({"id": item, "n": 1, "dati": g}) > 0:
		m.drops.spawn(item, 1, m.player.position, g)
	return "Ecco un %s con il gene %s." % [Genome.describe(g), gd["name"]]


func _analisi(_p: Dictionary) -> String:
	var slot := _held()
	var dati: Dictionary = slot.get("dati", {})
	if not dati.has("geni"):
		return "!Tieni in mano il Seme di mondo da leggere."
	var news := 0
	for g in Genome.genes(dati):
		if Genome.state(String(g)) == 0:
			Genome.known[String(g)] = 1
			news += 1
	m.character.bisaccia.changed.emit()
	return "Il Seme dice: %s%s." % [Genome.describe(dati), (" (%d geni nuovi nel Genario)" % news) if news > 0 else ""]


func _fiala(_p: Dictionary) -> String:
	var dati: Dictionary = _held().get("dati", {})
	var gs := Genome.genes(dati).filter(func(x: String) -> bool: return GenesData.cat_of(x) != "superficie")
	if gs.is_empty():
		return "!Tieni in mano un Seme di mondo con almeno un gene oltre la superficie."
	var g := String(gs[_rng.randi_range(0, gs.size() - 1)])
	var vial := GenesData.vial_of(g)
	if m.character.bisaccia.add(vial, 1) > 0:
		m.drops.spawn(vial, 1, m.player.position)
	return "Dal Seme esce la %s." % String(ItemsData.get_item(vial).get("name", vial))


func _addestra(_p: Dictionary) -> String:
	var rec := _pupil()
	if rec.is_empty():
		return "!Nessun compagno con te: mettine uno nella Sacca dei legami."
	if int(rec["lvl"]) >= HerdData.LVL_MAX:
		return "!%s è già al livello più alto." % rec["nome"]
	m.herd.gain_xp(rec, HerdData.xp_for(int(rec["lvl"])) - int(rec["xp"]), true)
	m.herd.changed_now()
	return "%s ora è al livello %d." % [rec["nome"], int(rec["lvl"])]


func _sfama(_p: Dictionary) -> String:
	var n := 0
	for r in m.herd.records():
		r["fame"] = 0.0
		r["felice"] = minf(float(r.get("felice", 0.7)) + 0.1, 1.0)
		n += 1
	if n == 0:
		return "!Non hai ancora una mandria."
	m.herd.changed_now()
	return "Tutta la mandria ha mangiato (%d creature)." % n


func _pesca(p: Dictionary) -> String:
	m.fishing.service_luck = float(p.get("luck", 0.5))
	m.fishing.service_until = m.character.play_time + float(p.get("secs", 600))
	return "Per %d minuti di gioco la tua canna ha più fortuna." % roundi(float(p.get("secs", 600)) / 60.0)


func _mappa(p: Dictionary) -> String:
	m.map_reveal.reveal_area(m.player_cell(), int(p.get("r", 100)))
	return "Sulla mappa (M) ora c'è tutto ciò che sta entro %d tessere." % int(p.get("r", 100))


func _sigilli(_p: Dictionary) -> String:
	var pc := Vector2(m.player_cell())
	var found := []
	var best := Vector2i(-1, -1)
	var bd := 1e18
	for e in m.world_meta.get("sigilli", []):
		var c := Vector2i(int(e[1]), int(e[2]))
		var shell := c + Vector2i(-PassSigilli.W / 2 - 1, 0)
		if String(e[0]) != "alto" and not TileDefs.SEAL_KIND.has(m.world.tile(shell.x, shell.y)):
			continue
		if Vector2(c).distance_squared_to(pc) < bd:
			bd = Vector2(c).distance_squared_to(pc)
			best = c
	if best.x >= 0:
		m.language.add_mark(best, "Sigillo", Color("#6ff0b8"))
		found.append("un Sigillo")
	var seen: Array = m.world_meta.get("reliquiari_aperti", [])
	best = Vector2i(-1, -1)
	bd = 1e18
	for o in m.world.stations:
		if m.world.stations[o] != "reliquiario" or "%d,%d" % [o.x, o.y] in seen:
			continue
		if Vector2(o).distance_squared_to(pc) < bd:
			bd = Vector2(o).distance_squared_to(pc)
			best = o
	if best.x >= 0:
		m.language.add_mark(best, "Reliquiario", Color("#6ff0b8"))
		found.append("un reliquiario")
	if found.is_empty():
		return "!In questo mondo non resta nessun Sigillo né reliquiario chiuso."
	return "Sulla mappa (M): %s." % " e ".join(found)


func _taglia(_p: Dictionary) -> String:
	if int(m.character.stats.get("guardiani", 0)) < 1:
		return "!Le taglie si aprono dopo il primo Guardiano."
	m.bounties.open_list().clear()
	m.bounties.fill()
	return "Taglie nuove: le trovi nel pannello delle Arti (%s)." % Keys.label("arti")


func _parola(p: Dictionary) -> String:
	var layer := String(p.get("layer", "comune"))
	var pick := ""
	var best := -1
	for w in m.character.lingua:
		var info: Array = LanguageData.WORDS.get(String(w), [])
		if info.size() < 4 or String(info[3]) != layer or m.language.state(String(w)) >= 2:
			continue
		var s: int = m.language.state(String(w))
		if s > best:
			best = s
			pick = String(w)
	if pick == "":
		return "!Non hai parole della lingua %s da tradurre: leggi prima qualche stele." % layer
	m.language.confirm([pick], "servizio")
	return "«%s» vuol dire %s: ora è certa nel Quaderno." % [pick, LanguageData.WORDS[pick][1]]


func _museo(_p: Dictionary) -> String:
	var parts := []
	var missing := ""
	for h in MuseumData.HALLS:
		var pcs := MuseumData.pieces(String(h))
		var have := 0
		for id in pcs:
			if int(m.character.stats.get("museo_" + String(id), 0)) == 1:
				have += 1
			elif missing == "":
				missing = String(id)
		if have < pcs.size():
			parts.append("%s %d/%d" % [MuseumData.HALLS[h]["name"].trim_prefix("Sala "), have, pcs.size()])
	if parts.is_empty():
		return "Il tuo Museo è completo. Non ho niente da insegnarti."
	var how := ItemInfo.how_to_get(missing)
	return "%s. Ti manca, per esempio, %s%s." % [", ".join(parts.slice(0, 6)), String(ItemsData.get_item(missing).get("name", missing)),
		(": " + how) if how != "" else ""]


func _rete(_p: Dictionary) -> String:
	var n := 0
	for mc in m.energy.machines.values():
		if String(mc.d.get("role", "")) == "riserva":
			mc.st["g"] = float(mc.d.get("cap", 0))
			n += 1
	if n == 0:
		return "!In questo mondo la tua rete non ha riserve."
	return "%d riserve piene di Linfa." % n
