class_name TestsTreasures
extends RefCounted
## I boss come tesori (Roadmap 41). Gruppo «tesori».
## Voce 373: i dodici Guardiani della spina (tre di prima e nove nuovi) in ordine di vigore, ognuno con il corpo, due fasi
## (la furia a metà Vita aggiunge attacchi, l'elemento cambia), il Richiamo al Cerchio e le pagine di storia.
## Voce 374: il Sacchetto: si apre, dà un'arma firma della fase del Guardiano, il Richiamo e (la prima volta) il gioiello.

var kit: TestKit
var m: Node2D
var res := {}


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	spine_list()
	await second_phase()
	bags()
	await chiefs()
	optional()
	print("tesori: %s" % str(res))
	if not res.values().all(func(x: Variant) -> bool: return x == true):
		print("ATTENZIONE: i boss come tesori non vanno come dovrebbero")


func spine_list() -> void:
	var bad := []
	var last := 0
	for g in GuardiansData.LIST:
		var v := int(g.get("vigor", GuardiansData.LIST.find(g) + 1))
		if v <= last:
			bad.append("ordine %s" % g["id"])
		last = v
		var d := CreaturesData.get_data(String(g["creature"]))
		if d.is_empty() or not d.has("art"):
			bad.append("creatura %s" % g["creature"])
		for k in g["pages"]:
			if not LoreData.PAGES.has(String(g["pages"][k])):
				bad.append("pagina %s" % g["pages"][k])
		if not ItemsData.has("sacchetto_" + String(g["id"])) or not ItemsData.has("gioiello_" + String(g["id"])):
			bad.append("sacchetto o gioiello %s" % g["id"])
		if int(g.get("vigor", 1)) >= 4 and (not d.has("fury") or not d.has("phase_elem")
				or not SummonData.CALLS.has("richiamo_" + String(g["id"]))):
			bad.append("fasi o richiamo %s" % g["id"])
	res["spina"] = GuardiansData.LIST.size() == 12 and bad.is_empty()
	print("tesori, i Guardiani della spina: %d; problemi %s" % [GuardiansData.LIST.size(), str(bad)])


## A metà Vita la Marea muta arriva alla furia: nuovi attacchi e un altro elemento.
func second_phase() -> void:
	var gd: Guardian = m.guardian
	var old_boss: Creature = gd.boss
	var cr: Creature = m.fauna.add("guardiano_marea", m.player.position + Vector2(140, -60))
	cr.set_process(true)
	gd.boss = cr
	gd._phased = false
	var n0 := cr.behaviors.size()
	var e0 := String(cr.data["elem"])
	cr.hp = int(cr.hp_max * 0.4)
	await kit.seconds(0.6)
	var ok := cr.behaviors.size() > n0 and String(cr.data["elem"]) != e0
	gd.boss = old_boss
	gd._phased = false
	if is_instance_valid(cr):
		m.fauna.kill_quietly(cr)
	m.vitals.refill()
	res["fasi"] = ok
	print("tesori, la seconda fase della Marea muta: comportamenti %d → %d, elemento %s → %s" % [n0,
		cr.behaviors.size() if is_instance_valid(cr) else -1, e0, String(cr.data["elem"]) if is_instance_valid(cr) else "?"])


## Il Sacchetto della Falena: un'arma firma della fase 9, il Richiamo, il gioiello la prima volta.
func bags() -> void:
	var b: Bisaccia = m.character.bisaccia
	var keep: Array = b.slots.duplicate(true)
	for i in range(Bisaccia.HOTBAR, b.slots.size()):
		b.slots[i] = {}
	var st0 := int(m.character.stats.get("aperti_sacchetto_falena", 0))
	m.character.stats.erase("aperti_sacchetto_falena")
	b.add("sacchetto_falena", 1)
	var ok: bool = m.firma.open_bag("sacchetto_falena")
	var firma := 0
	for i in b.slots.size():
		var id := b.id_at(i)
		if id.begins_with("firma_f9_"):
			firma += 1
	var got_call := b.count("richiamo_falena") == 1
	var got_gem := b.count("gioiello_falena") >= 1
	for i in keep.size():
		b.slots[i] = keep[i]
	b.changed.emit()
	if st0 > 0:
		m.character.stats["aperti_sacchetto_falena"] = st0
	else:
		m.character.stats.erase("aperti_sacchetto_falena")
	res["sacchetto"] = ok and firma >= 1 and got_call and got_gem
	print("tesori, il Sacchetto della Falena: aperto %s, armi firma della fase 9: %d, Richiamo %s, gioiello %s" % [ok, firma, got_call, got_gem])


## Voce 375: i capi erranti: 24, uno compare nello strato giusto del mondo del suo vigore, una volta per mondo; la prima
## volta lascia di sicuro la sua arma.
func chiefs() -> void:
	var list: Array = Chiefs.LIST
	var v0: Variant = m.world_meta.get("vigore", null)
	var seen0: Variant = m.world_meta.get("capi", null)
	m.world_meta["vigore"] = 1
	m.world_meta.erase("capi")
	var pc: Vector2i = m.player_cell()
	var s := StrataData.at(m.world, pc.x, pc.y)
	var c: Dictionary = m.chiefs.candidate()
	var right := c.is_empty() or (int(c["vigor"]) <= 1 and int(c["stratum"]) == s)
	var cr: Creature = null
	if not c.is_empty():
		cr = m.chiefs.spawn(c)
	var spawned := cr != null
	var once: bool = m.chiefs.candidate().is_empty() or String(m.chiefs.candidate().get("id", "")) != String(c.get("id", ""))
	if cr != null and is_instance_valid(cr):
		m.fauna.kill_quietly(cr)
	m.chiefs.active = null
	m.lords.bar.follow(null)
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var first := LootData.roll("capo_cinghiale", rng, true)
	if v0 == null:
		m.world_meta.erase("vigore")
	else:
		m.world_meta["vigore"] = v0
	if seen0 == null:
		m.world_meta.erase("capi")
	else:
		m.world_meta["capi"] = seen0
	await kit.frames(2)
	res["capi"] = list.size() == 24 and right and (c.is_empty() or (spawned and once)) and first.has("arma_capo_cinghiale")
	print("tesori, i capi erranti: %d; qui (strato %d, vigore 1): %s; compare %s, una volta sola %s; la prima volta l'arma %s" % [
		list.size(), s, String(c.get("id", "nessuno")), spawned, once, first.has("arma_capo_cinghiale")])


## Voci 376-377: i boss facoltativi e i superboss si chiamano senza averli affrontati, con un'esca fatta al Cerchio;
## lasciano il loro Sacchetto; la corsa dei Guardiani ha il suo Corno e il suo premio.
func optional() -> void:
	var bad := []
	var n := 0
	for k in SummonData.CALLS:
		var cd: Dictionary = SummonData.CALLS[k]
		if not bool(cd.get("free", false)):
			continue
		n += 1
		if RecipesData.making(String(k)).is_empty():
			bad.append("esca %s" % k)
		if not ItemsData.has("sacchetto_" + String(cd["creature"])):
			bad.append("sacchetto %s" % cd["creature"])
	var rng := RandomNumberGenerator.new()
	rng.seed = 9
	var prize := LootData.roll("premio_corsa", rng, true)
	res["facoltativi"] = n == 13 and bad.is_empty() and not RecipesData.making("corno_corsa").is_empty() 		and prize.has("corona_corsa") and m.get("rush") != null
	print("tesori, boss facoltativi e superboss: %d; problemi %s; la corsa: Corno %s, premio %s" % [n, str(bad),
		not RecipesData.making("corno_corsa").is_empty(), str(prize.keys())])

