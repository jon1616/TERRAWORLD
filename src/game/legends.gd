class_name Legends
extends Node
## I Semi leggendari e il Seme Primo (voce 81, dati in `LegendsData`). Una leggenda si riconosce dai geni (`of_genes`),
## quindi un Seme e il suo mondo sono leggendari senza nient'altro da salvare; il mondo lo scrive in
## `world_meta["leggenda"]`. Le leggende compiute e il Seme Primo stanno in `Character.leggende`
## (id della leggenda → 1; "primo_dato", "primo_fatto").

var m: Node2D
var legend := ""
var _t := 2.0


## La leggenda di questi geni ("" se nessuna).
static func of_genes(gs: Array) -> String:
	for k in LegendsData.LEGENDS:
		var ok := true
		for g in LegendsData.LEGENDS[k]["needs"]:
			if not g in gs:
				ok = false
		if ok:
			return String(k)
	return ""


static func name_of(k: String) -> String:
	return String(LegendsData.LEGENDS.get(k, {}).get("name", ""))


func setup(main: Node2D) -> void:
	m = main
	if m.giardino != null and m.giardino.active:
		return
	legend = of_genes(m.world_meta.get("geni", []))
	if legend != "":
		m.world_meta["leggenda"] = legend
		m.fauna.world_rare *= LegendsData.RARE
		m.fauna.world_lumini *= LegendsData.LUMINI
		if not m.world_meta.get("leggenda_vista", false):
			m.world_meta["leggenda_vista"] = true
			m.depth_watch.banner.show_stratum("Mondo leggendario", "%s: %s" % [name_of(legend),
				LegendsData.LEGENDS[legend]["desc"]], Color("#ffd08a"))
	if m.world_meta.get("primo", false) and not m.world_meta.get("primo_visto", false):
		m.world_meta["primo_visto"] = true
		m.depth_watch.banner.show_stratum("Il Primo Mondo", "Il mondo del Seme Primo: tutti i biomi, il vigore più alto",
			Color("#ffe8a0"))
	m.guardian.resolved.connect(_on_resolved)


func _on_resolved(_how: String) -> void:
	var ch: Character = m.character
	var at: Vector2 = m.guardian.heart_pos() + Vector2(0, -3 * 16)
	if legend != "" and not ch.leggende.has(legend):
		ch.leggende[legend] = 1
		m.drops.spawn(String(LegendsData.LEGENDS[legend]["gift"]), 1, at)
		m.drops.spawn("linfa_antica", LegendsData.ANCIENT_SAP, at)
		m.hud.toast("Leggenda compiuta: %s" % name_of(legend))
		m.objectives.bump("leggende")
	if m.world_meta.get("primo", false) and not ch.leggende.has("primo_fatto"):
		ch.leggende["primo_fatto"] = 1
		m.drops.spawn("germoglio_primo", 1, at)
		m.guardian.lore.show_page("primo_compiuto")
		m.objectives.bump("seme_primo")


## A che punto è il Seme Primo: {"albero": [fatto?], "genario": [imparati, servono], "leggende": [compiute, servono]}.
func progress() -> Dictionary:
	var ch: Character = m.character
	var total := 0
	var learned := 0
	for g in GenesData.GENES:
		var d := GenesData.info(String(g))
		if String(d.get("cat", "")) == "superficie":
			continue
		total += 1
		if Genome.state(String(g)) >= 2:
			learned += 1
	var done := 0
	for k in LegendsData.LEGENDS:
		if ch.leggende.has(k):
			done += 1
	return {"albero": m.albero.done(), "genario": [learned, ceili(total * LegendsData.PRIMO_GENARIO)],
		"leggende": [done, LegendsData.PRIMO_LEGENDS]}


func ready_for_primo() -> bool:
	var p := progress()
	return bool(p["albero"]) and int(p["genario"][0]) >= int(p["genario"][1]) and int(p["leggende"][0]) >= int(p["leggende"][1])


func _process(dt: float) -> void:
	if not m.built:
		return
	_t -= dt
	if _t > 0.0:
		return
	_t = 3.0
	if not m.character.leggende.has("primo_dato") and ready_for_primo():
		give_primo()


## Il Seme Primo nella Bisaccia: Mosaico (tutti i biomi) e geni stellari, il vigore più alto conosciuto più cinque.
func give_primo() -> Dictionary:
	var ch: Character = m.character
	ch.leggende["primo_dato"] = 1
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([ch.name, "primo"])
	var gs := ["mosaico"]
	var cats := {"superficie": true}
	var pool := []
	for g in GenesData.GENES:
		var d := GenesData.info(String(g))
		if int(d.get("rar", 0)) == 3 and String(d.get("only", "")) != "stagione" and String(d.get("cat", "")) != "ombra":
			pool.append(String(g))
	pool.sort()
	while gs.size() < 1 + LegendsData.PRIMO_EXTRA and not pool.is_empty():
		var g := String(pool[rng.randi_range(0, pool.size() - 1)])
		pool.erase(g)
		var cat := GenesData.cat_of(g)
		if cats.has(cat):
			continue
		cats[cat] = true
		gs.append(g)
	var genome := {"geni": Genome.sort(gs), "vigore": maxi(Genome.local_vigor, int(m.world_meta.get("vigore", 1))) + LegendsData.PRIMO_VIGOR,
		"primo": true}
	var item := Genome.item_of(genome)
	if m.character.bisaccia.add_stack({"id": item, "n": 1, "dati": genome}) > 0:
		m.drops.spawn(item, 1, m.player.position, genome)
	m.hud.toast("L'Albero-Madre ti dona il Seme Primo")
	m.guardian.lore.show_page("seme_primo")
	return genome
