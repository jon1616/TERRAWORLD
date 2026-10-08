class_name Fishing
extends Node2D
## La pesca (voce 121, Roadmap 14 «Le acque vive»). Il gesto è **banale, quasi automatico** (scelta dell'utente): con
## una canna in mano, clic su uno specchio di liquido (o sopra di lui); la lenza parte, il galleggiante si posa sul
## pelo del liquido e, dopo un'attesa (la canna, e poi esche e tempo: voce 122), un pesce **abbocca e sale da solo**
## nella Bisaccia. Spostarsi, cambiare oggetto o togliere il liquido ritira la lenza. Il pesce viene da `FishData`
## secondo lo specchio (`WaterBody`) e il mondo (notte, stagione, tempo, geni); la sua taglia va nell'Erbario.

const RANGE := 14                        # tessere: fin dove arriva il lancio
const WAIT := [4.0, 11.0]                # secondi d'attesa (× la rapidità della canna)
const BITE := 0.7                        # secondi tra l'abboccata e la presa
const LEAVE := 4                         # tessere: allontanandosi di più la lenza si ritira
const DOWN := 8                          # tessere sotto il clic in cui si cerca il liquido
const STEAL_R := 7.0                     # voce 133: tessere dal galleggiante entro cui un ladro di pesci ruba
const STEAL_CHANCE := 0.5

var on_catch := Callable()               # Roadmap 21: chi vuole sapere che pesce si è preso (`LostGardens`)
signal fish_caught(id: String, size: int)  # Roadmap 27: il pesce preso e la sua misura (`AnglerBook`)
var m: Node2D
var line := {}                           # la lenza in acqua: {cell, from, rod, ctx, t, bite}
var caught := 0                          # quanti pesci (per le prove)
var stolen := 0                          # voce 133: quanti rubati dai ladri di pesci
var last := {}                           # l'ultimo pescato: {id, size, record, n, bait}
var last_crate := {}                     # l'ultima cassa aperta: {oggetto: quanti} (per le prove)
## Voce 122: gli effetti di ciò che si indossa (li scrive `GearEffects`): luck +, wait ×, size +, double +, any.
var gear := {"luck": 0.0, "wait": 1.0, "size": 0.0, "double": 0.0, "any": false}
var _rng := RandomNumberGenerator.new()
var _time := 0.0


func setup(main: Node2D) -> void:
	m = main
	z_index = 14
	_rng.randomize()


## Il lancio. Restituisce vero se la lenza è in acqua (altrimenti un avviso dice perché no).
func cast(c: Vector2i, rod: String) -> bool:
	var w: World = m.world
	var q := c
	for k in DOWN:
		if w.liq(q.x, q.y) > 0 or w.solid(q.x, q.y):
			break
		q.y += 1
	if w.liq(q.x, q.y) == 0:
		m.hud.toast("Lancia la lenza in un liquido")
		return false
	var pc: Vector2i = m.player_cell()
	if Vector2(q - pc).length() > RANGE:
		m.hud.toast("Troppo lontano per lanciare")
		return false
	var body := WaterBody.at(w, q)
	var it := ItemsData.get_item(rod)
	var liqs: Array = it.get("fish_liq", [0])
	if not int(body["type"]) in liqs and not bool(gear["any"]):
		m.hud.toast("Questa canna non regge la %s: serve una canna di un altro materiale" % String(LiquidsData.TYPES[int(body["type"])]["name"]).to_lower())
		return false
	if not body["ok"]:
		m.hud.toast("Troppo poco liquido: in una pozza così non vive nessun pesce")
		return false
	var ctx := context(body)
	if FishData.pool(ctx).is_empty():
		m.hud.toast("Qui, adesso, non abbocca niente")
		return false
	while w.liq(q.x, q.y - 1) > 0:
		q.y -= 1                                  # il galleggiante sta sul pelo del liquido
	var key := spot_key(body)
	line = {"cell": q, "from": pc, "rod": rod, "ctx": ctx, "bite": -1.0, "key": key,
		"t": _rng.randf_range(WAIT[0], WAIT[1]) * wait_mult(rod) * (1.0 + FishingData.TIRE_WAIT * tiredness(key))}
	if tiredness(key) >= FishingData.TIRE_MAX * 0.6:
		m.hud.toast("Qui hai pescato tanto: i pesci sono diffidenti, abboccano più piano")
	m.sfx.play("tira", Vector2(q) * 16.0)
	queue_redraw()
	return true


## Quanto dura l'attesa (× quella di base): la canna, la migliore esca, gli accessori, il tempo (voce 122).
func wait_mult(rod: String) -> float:
	var k := float(ItemsData.get_item(rod).get("fish_speed", 1.0)) * float(gear["wait"])
	var bi := FishingData.best_bait(m.character.bisaccia)
	if bi >= 0:
		k *= float(ItemsData.get_item(m.character.bisaccia.id_at(bi))["bait"]["wait"])
	var dl: float = m.day.daylight()
	return k * FishingData.weather_wait(String(m.weather.id), m.day.is_night(), dl > 0.08 and dl < 0.92)


## La fortuna di pesca: la canna, la migliore esca e gli accessori (voce 122).
## (Voce 353) Il segreto dello stagno del Pescatore: fortuna in più fino a `service_until` (secondi di gioco).
var service_luck := 0.0
var service_until := 0.0


func luck_now(rod: String) -> float:
	var k: float = float(ItemsData.get_item(rod).get("fish", 0.0)) + float(gear["luck"]) + (m.rooms.fish_luck() if m.rooms else 0.0)   # voce 142
	if m.character.play_time < service_until:
		k += service_luck
	var bi := FishingData.best_bait(m.character.bisaccia)
	if bi >= 0:
		k += float(ItemsData.get_item(m.character.bisaccia.id_at(bi))["bait"]["luck"])
	return k


## Voce 125: la chiave di uno specchio (il suo angolo, a blocchi di 16 tessere) e la sua fatica (0 - `TIRE_MAX`).
static func spot_key(body: Dictionary) -> String:
	return "%d,%d" % [int(body["x0"]) / 16, int(body["top"]) / 16]


func tiredness(key: String) -> float:
	var e: Array = (m.world_meta.get("pesca", {}) as Dictionary).get(key, [0.0, 0.0])
	var now := Time.get_unix_time_from_system()
	return maxf(float(e[0]) - (now - float(e[1])) / FishingData.TIRE_RECOVER, 0.0)


func _tire(key: String) -> void:
	var all: Dictionary = m.world_meta.get("pesca", {})
	all[key] = [minf(tiredness(key) + 1.0, FishingData.TIRE_MAX), Time.get_unix_time_from_system()]
	m.world_meta["pesca"] = all


## Il mondo attorno allo specchio, per `FishData`.
func context(body: Dictionary) -> Dictionary:
	return {"liq": int(body["type"]), "stratum": int(body["stratum"]), "biome": String(BiomesData.BIOMES[int(body["biome"])]["id"]),
		"depth": int(body["depth"]), "volume": float(body["volume"]), "night": m.day.is_night(),
		"season": String(m.seasons.info().get("id", "")), "weather": String(m.weather.id),
		"genes": m.world_meta.get("geni", []),
		"perduto": String((m.world_meta.get("perduto", {}) as Dictionary).get("id", "")) if m.world_meta.get("perduto") is Dictionary else "",
		"sky": SkyData.zone_at(m.world, (body["center"] as Vector2i).x, (body["center"] as Vector2i).y),
		"sea": is_sea(body)}


## Voce 461: uno specchio è mare se è acqua di superficie grande e tocca la fascia dei mari ai bordi (o il mondo ha il
## gene Sommerso).
func is_sea(body: Dictionary) -> bool:
	if int(body["type"]) != 0 or int(body["stratum"]) != 0 or float(body["volume"]) < 400.0:
		return false
	if "sommerso" in (m.world_meta.get("geni", []) as Array):
		return true
	return int(body["x0"]) < WorldShapesData.SEA_EDGE or int(body["x1"]) > m.world.w - WorldShapesData.SEA_EDGE


func stop() -> void:
	line = {}
	queue_redraw()


func _process(dt: float) -> void:
	_time += dt
	if line.is_empty():
		return
	var w: World = m.world
	var q: Vector2i = line["cell"]
	var pc: Vector2i = m.player_cell()
	if String(m.hud.current().get("id", "")) != String(line["rod"]) or Vector2(pc - (line["from"] as Vector2i)).length() > LEAVE \
			or w.liq(q.x, q.y) == 0:
		stop()
		return
	queue_redraw()
	if float(line["bite"]) < 0.0:
		line["t"] = float(line["t"]) - dt
		if float(line["t"]) <= 0.0:
			line["bite"] = BITE                   # abbocca: il galleggiante va sotto
			m.sfx.play("soffio", Vector2(q) * 16.0)
		return
	line["bite"] = float(line["bite"]) - dt
	if float(line["bite"]) <= 0.0:
		catch()


## Il pesce sale: nella Bisaccia (o a terra se è piena), nell'Erbario, un avviso con la taglia.
func catch() -> String:
	if line.is_empty():
		return ""
	var g := gear.duplicate()                    # (consumare l'esca cambia la Bisaccia e fa ricalcolare `gear`)
	var luck := luck_now(String(line["rod"]))
	var id := FishData.roll(line["ctx"], _rng, luck)
	var q: Vector2i = line["cell"]
	var ctx: Dictionary = line["ctx"]
	_tire(String(line.get("key", "")))
	stop()
	if id == "":
		return ""
	# voce 123: a volte abbocca una cassa al posto del pesce
	if _rng.randf() < FishingData.CRATE + luck * FishingData.CRATE_LUCK:
		id = FishingData.crate_for(ctx)
		var sp := FishingData.special_crate(ctx, int(m.world_meta.get("vigore", 1)), _rng)   # voce 400
		if sp != "":
			id = sp
	# l'esca migliore si consuma (voce 122)
	var b: Bisaccia = m.character.bisaccia
	var bi := FishingData.best_bait(b)
	var bait := ""
	if bi >= 0:
		bait = b.id_at(bi)
		b.take_one(bi)
	# voce 133: un ladro di pesci vicino al galleggiante (lontra, luccio) può portarlo via: preso, lo restituisce
	for cr in m.fauna.list:
		if bool(cr.p.get("steal_fish", false)) and cr.position.distance_to(Vector2(q) * 16.0) < STEAL_R * 16.0 \
				and not cr.has_meta("rubato") and _rng.randf() < STEAL_CHANCE:
			cr.set_meta("rubato", [id, 1])
			cr.mind.force_flee(10.0)
			stolen += 1
			m.hud.toast("%s ti ha rubato il pesce dalla lenza! Prendilo per riaverlo" % String(cr.data.get("name", "")))
			Fx.puff(m.fx, Vector2(q) * 16.0 + Vector2(8, 4), Color(1.4, 1.2, 0.8))
			return ""
	if not FishData.all().has(id):
		# una cassa: niente taglia, niente Erbario dei pesci
		if b.add(id, 1) > 0:
			m.drops.spawn(id, 1, m.player.position)
		caught += 1
		last = {"id": id, "size": 0, "record": false, "n": 1, "bait": bait}
		m.hud.toast("Hai pescato: %s! (clic per aprirla)" % ItemsData.get_item(id)["name"])
		m.sfx.play("apri", Vector2(q) * 16.0)
		return id
	# la taglia solo per i pesci (voce 187: calcolata prima della cassa, con una cassa il gioco si fermava)
	var size := FishData.roll_size(id, _rng, luck * 0.05 + float(g["size"]))
	var n := 2 if _rng.randf() < float(g["double"]) else 1
	var rest: int = b.add(id, n)
	if rest > 0:
		m.drops.spawn(id, rest, m.player.position)
	if _rng.randf() < FishingData.PEARL:
		if b.add("perla_stagno", 1) > 0:
			m.drops.spawn("perla_stagno", 1, m.player.position)
		m.hud.toast("Attaccata alla lenza: una Perla di stagno!")
	var first: bool = not m.erbario.known("pesci", id)
	var better: bool = m.erbario.add_fish(id, size)
	caught += 1
	last = {"id": id, "size": size, "record": better and not first, "n": n, "bait": bait}
	m.objectives.bump("pesci")
	if on_catch.is_valid():
		on_catch.call(id)                        # Roadmap 21: le cure del Giardino sommerso
	fish_caught.emit(id, size)
	if first:
		m.objectives.bump("specie_pescate")      # voce 124: obiettivi e Pescatore
	if String(FishData.info(id)["rar"]) == "leggendario":
		m.objectives.bump("pesci_leggendari")
	var f := FishData.info(id)
	m.hud.toast("Hai pescato: %s%s, %d cm%s" % [f["name"], " (due!)" if n == 2 else "", size,
		" — il più grande finora!" if better and not first else ""])
	m.sfx.play("raccogli", Vector2(q) * 16.0)
	Fx.puff(m.fx, Vector2(q) * 16.0 + Vector2(8, 4), Color(0.8, 1.2, 1.6))
	return id


func _draw() -> void:
	if line.is_empty():
		return
	var q: Vector2i = line["cell"]
	var bite := float(line["bite"]) >= 0.0
	var bob := Vector2(q) * 16.0 + Vector2(8, 3 + (6.0 if bite else sin(_time * 3.0) * 1.2))
	var p: Player = m.player
	var hand := p.hand_world if p.hand_world.x < INF else p.position + Vector2(10 * p.facing, -14)
	# la lenza: una curva che pende un poco
	var pts := PackedVector2Array()
	for k in 13:
		var t := k / 12.0
		pts.append(hand.lerp(bob, t) + Vector2(0, sin(t * PI) * 10.0))
	draw_polyline(pts, Color(0.9, 0.95, 1.0, 0.7), 1.0)
	draw_circle(bob, 3.0, Color("#f04040"))
	draw_circle(bob + Vector2(0, -1.5), 1.6, Color.WHITE)


## Voce 123: aprire una cassa pescata (clic con la cassa in mano): il bottino delle rovine del suo strato, a volte una
## perla, e di rado un unico della serie «Tesori delle acque».
func open_crate(id: String) -> bool:
	var b: Bisaccia = m.character.bisaccia
	var i: int = m.hud.sel if b.id_at(m.hud.sel) == id else Portal._slot_of(b, id)
	if i < 0:
		return false
	var cr: Array = ItemsData.get_item(id)["crate"]
	b.take_one(i)
	var got := LootData.roll_chest("rovina_%d" % _rng.randi_range(int(cr[0]), int(cr[1])), _rng, 1)
	var cit := ItemsData.get_item(id)
	if cit.has("table"):                                   # voce 400: le casse dei biomi e dei gradi
		var tl := LootData.roll(String(cit["table"]), _rng)
		for k in tl:
			got[k] = int(got.get(k, 0)) + int(tl[k])
	if cit.has("firma_f") and _rng.randf() < 0.4:
		for k in LootData.roll("firma_f%d" % int(cit["firma_f"]), _rng):
			got[k] = int(got.get(k, 0)) + 1
	if _rng.randf() < 0.25:
		got["perla_stagno"] = int(got.get("perla_stagno", 0)) + 1
	if _rng.randf() < float(FishingData.UNIQUE_IN_CRATE.get(id, 0.0)):
		var u := UniquesData.roll("pesca", _rng, m.character.erbario.get("oggetti", {}))
		if u != "":
			got[u] = 1
	var names := []
	for k in got:
		var rest := b.add(String(k), int(got[k]))
		if rest > 0:
			m.drops.spawn(String(k), rest, m.player.position)
		names.append("%s ×%d" % [ItemsData.get_item(String(k)).get("name", k), int(got[k])])
	m.hud.toast("Dentro: %s" % ", ".join(names))
	m.sfx.play("apri", m.player.position)
	last_crate = got
	return true

