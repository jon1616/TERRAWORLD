class_name Board
extends Node
## La Bacheca dei Giardinieri (voce 67, Roadmap 8): richieste generate senza fine, costruite da ciò che il personaggio
## **conosce già** (geni visti, famiglie incontrate, materiali trovati, poteri): ci sono sempre `OPEN` richieste
## aperte, e ognuna si può fare con ciò che si è imparato (o quasi). Tipi:
##   gene       portare un materiale dei geni da un mondo con quel gene (gene visto nel Genario)
##   caccia     sconfiggere creature di una famiglia già incontrata
##   mandria    addomesticare una creatura di una famiglia addomesticabile già incontrata
##   prodotto   portare un prodotto della mandria (lana, seta, miele…) di una famiglia incontrata
##   firma      trovare le firme di mondi nuovi
##   viaggio    visitare mondi (piantare Semi nelle Aiuole)
##   sigillo    aprire Sigilli (quando si ha un potere che li apre)
##   fornitura  portare un materiale già trovato (sempre possibile: il filo che non si spezza mai)
## I traguardi contano da quando la richiesta è stata presa (`base`). Ricompense: Semi di mondo con un gene raro,
## Fiale, Linfa antica, Lumini, Polvere iridata. Stato nel personaggio (`Character.bacheca`): le richieste seguono
## chi le ha prese in ogni mondo; la Bacheca sta nel Giardino (clic destro).

const OPEN := 4

var m: Node2D
var panel: BoardPanel
var _rng := RandomNumberGenerator.new()


func setup(main: Node2D) -> void:
	m = main
	_rng.randomize()
	if m.character.bacheca.is_empty():
		m.character.bacheca = {"aperte": [], "fatte": 0}
	panel = BoardPanel.new()
	m.hud.add_child(panel)
	panel.setup(m, self)
	m.hud.overlays.append(panel)


func open_list() -> Array:
	return m.character.bacheca["aperte"]


## Riempie la bacheca fino a `OPEN` richieste.
func fill() -> void:
	var tries := 0
	while open_list().size() < OPEN and tries < 40:
		tries += 1
		var r := make()
		if not r.is_empty() and not _dup(r):
			open_list().append(r)


func _dup(r: Dictionary) -> bool:
	for o in open_list():
		if o["tipo"] == r["tipo"] and o.get("cosa", "") == r.get("cosa", ""):
			return true
	return false


## Una richiesta nuova, di un tipo a caso tra quelli che il personaggio può fare.
func make() -> Dictionary:
	var ch: Character = m.character
	var kinds := ["fornitura", "viaggio", "firma"]
	var seen_genes := _seen_gene_materials()
	if not seen_genes.is_empty():
		kinds.append("gene")
	var fams := _families()
	if not fams.is_empty():
		kinds.append_array(["caccia", "caccia"])
	var tame := fams.filter(func(f: String) -> bool: return HerdData.TAME.has(f))   # (le famiglie con un prodotto scritto)
	if not tame.is_empty():
		kinds.append_array(["mandria", "prodotto"])
	if m.powers.has("canto") or m.powers.has("vista") or m.powers.has("passo") or m.powers.has("brace"):
		kinds.append("sigillo")
	var fished: Array = (ch.erbario.get("pesci", {}) as Dictionary).keys().filter(func(f: String) -> bool:
		return String(FishData.info(f).get("rar", "")) in ["comune", "non_comune"])
	if not fished.is_empty():
		kinds.append("pesce")                       # voce 124: pesci che si sono già pescati (mai obbligatori)
	# Roadmap 15: una stanza di un tipo, un Signore, una marea, una specie da studiare
	kinds.append("stanza")
	if int(ch.stats.get("signori", 0)) > 0 or ch.bisaccia.count("lingotto_ambra") > 0:
		kinds.append("signore")
	if int(ch.stats.get("maree", 0)) > 0:
		kinds.append("marea")
	if not (ch.erbario.get("creature", {}) as Dictionary).is_empty():
		kinds.append("studio")
	if int(ch.stats.get("cielo_max", 0)) > 0:
		kinds.append("cielo")                       # Roadmap 16: una richiesta dal cielo
	if int(ch.stats.get("macchine", 0)) > 0:
		kinds.append("rete")                        # Roadmap 19: vene, fili e ciò che vive attorno alla rete
	var k := String(kinds[_rng.randi_range(0, kinds.size() - 1)])
	var r := {"tipo": k}
	match k:
		"gene":
			var e: Array = seen_genes[_rng.randi_range(0, seen_genes.size() - 1)]
			r["cosa"] = e[0]
			r["n"] = _rng.randi_range(4, 10)
			r["testo"] = "Portami %d %s: si trovano nei mondi con il gene %s" % [r["n"], ItemsData.get_item(String(e[0]))["name"],
				GenesData.GENES[e[1]]["name"]]
			r["premio"] = {GenesData.vial_of(String(e[1])): 1, "lumino": 60}
		"caccia":
			var f := String(fams[_rng.randi_range(0, fams.size() - 1)])
			r["cosa"] = f
			r["n"] = _rng.randi_range(4, 12)
			r["base"] = _kills(f)
			r["testo"] = "Sconfiggi %d %s" % [r["n"], String(FamiliesData.FAMILIES[f]["name"]).to_lower()]
			r["premio"] = {"lumino": 40 + int(r["n"]) * 8, "pozione_rugiada": 1}
		"mandria":
			var f := String(tame[_rng.randi_range(0, tame.size() - 1)])
			r["cosa"] = f
			r["n"] = 1
			r["base"] = int((ch.erbario.get("addomesticate", {}) as Dictionary).get(f, 0))
			r["testo"] = "Addomestica un'altra creatura della famiglia dei %s" % String(FamiliesData.FAMILIES[f]["name"]).to_lower()
			r["premio"] = {"linfa_antica": 1, "lumino": 80}
		"prodotto":
			var f := String(tame[_rng.randi_range(0, tame.size() - 1)])
			var item := String(HerdData.tame_of(f)["produce"][0])
			r["cosa"] = item
			r["n"] = _rng.randi_range(4, 10)
			r["testo"] = "Portami %d %s (lo danno i %s del recinto)" % [r["n"], ItemsData.get_item(item)["name"],
				String(FamiliesData.FAMILIES[f]["name"]).to_lower()]
			r["premio"] = {"lumino": 50 + int(r["n"]) * 6, "vasetto": 1}
		"pesce":
			var fid := String(fished[_rng.randi_range(0, fished.size() - 1)])
			r["cosa"] = fid
			r["n"] = _rng.randi_range(2, 5)
			r["testo"] = "Portami %d %s: %s" % [r["n"], FishData.info(fid)["name"], FishData.where(fid)]
			r["premio"] = {"lumino": 40 + int(r["n"]) * 10, "esca_petali": 5}
		"firma":
			r["n"] = 1
			r["base"] = int(ch.stats.get("firme", 0))
			r["testo"] = "Trova la firma di un mondo nuovo"
			r["premio"] = {"seme": 1, "lumino": 60}
		"viaggio":
			r["n"] = _rng.randi_range(1, 2)
			r["base"] = int(ch.stats.get("viaggi", 0))
			r["testo"] = "Visita %s" % ("un mondo" if int(r["n"]) == 1 else "due mondi")
			r["premio"] = {"lumino": 50, "provetta": 2}
		"stanza":
			var types := ["casa", "laboratorio", "serra", "cantina", "biblioteca", "osservatorio", "stalla", "acquario", "trofei"]
			var t := String(types[_rng.randi_range(0, types.size() - 1)])
			r["cosa"] = t
			r["n"] = 1
			r["base"] = int(ch.stats.get("stanza_" + t, 0))
			r["testo"] = "Costruisci una stanza: %s (%s)" % [String(RoomsData.TYPES[t]["name"]).to_lower(), RoomsData.TYPES[t]["need"]]
			r["premio"] = {"lumino": 80, FurnitureData.id_of("vaso", "lanterna"): 1}
		"signore":
			r["n"] = 1
			r["base"] = int(ch.stats.get("signori", 0))
			r["testo"] = "Sconfiggi un Signore dei luoghi (con la sua esca rituale, all'Altare)"
			r["premio"] = {"lumino": 150, "linfa_antica": 1}
		"marea":
			r["n"] = 1
			r["base"] = int(ch.stats.get("maree_vinte", 0))
			r["testo"] = "Respingi una marea fino al suo capo"
			r["premio"] = {"lumino": 150, "pozione_rigoglio": 2}
		"cielo":
			var asks := [["nuvola", 40], ["cristallo_celeste", 12], ["lingotto_nimbite", 5], ["polvere_stelle", 20], ["lana_nuvola", 6],
				["petali_vento", 6]]
			var a: Array = asks[_rng.randi_range(0, asks.size() - 1)]
			r["cosa"] = String(a[0])
			r["n"] = int(a[1])
			r["testo"] = "Porta %d %s dal cielo" % [int(a[1]), String(ItemsData.get_item(String(a[0]))["name"])]
			r["premio"] = {"lumino": 60 + int(a[1]) * 2, "fagiolo_nuvola": 2}
		"rete":
			if _rng.randf() < 0.3:
				r["tipo"] = "centrale"
				r["n"] = 1
				r["base"] = int(ch.stats.get("centrali", 0))
				r["testo"] = "Risveglia una Centrale dei Seminatori (nelle Caverne e più giù)"
				r["premio"] = {"lumino": 150, "vena_ambra": 20}
			else:
				var asks := [["vena_legnoferro", 30], ["filo_turchese", 40], ["linfa_rappresa", 5], ["luce_vena", 6],
					["polvere_legnoferro", 12]]
				var a: Array = asks[_rng.randi_range(0, asks.size() - 1)]
				r["cosa"] = String(a[0])
				r["n"] = int(a[1])
				r["testo"] = "Portami %d %s per la rete del Giardino" % [int(a[1]), String(ItemsData.get_item(String(a[0]))["name"])]
				r["premio"] = {"lumino": 50 + int(a[1]) * 2, "isolante_resina": 3}
		"studio":
			r["n"] = 1
			r["base"] = int(ch.stats.get("studiate", 0))
			r["testo"] = "Studia a fondo una specie (sconfitte o Provetta)"
			r["premio"] = {"lumino": 60, "provetta": 2}
		"sigillo":
			r["n"] = 1
			r["base"] = int(ch.stats.get("sigilli", 0))
			r["testo"] = "Apri un Sigillo con un potere dell'Albero-Madre"
			r["premio"] = {"seme": 1, "polvere_iridata": 1}
		_:
			var item := _known_material()
			r["tipo"] = "fornitura"
			r["cosa"] = item
			r["n"] = _rng.randi_range(10, 30)
			r["testo"] = "Portami %d %s" % [r["n"], ItemsData.get_item(item)["name"]]
			r["premio"] = {"lumino": 30 + int(r["n"]) * 2}
	return r


## [materiale grezzo, gene] dei materiali dei geni che il personaggio ha già visto.
func _seen_gene_materials() -> Array:
	var out := []
	for g in MaterialsData.GENE_MATERIALS:
		var md: Dictionary = MaterialsData.GENE_MATERIALS[g]
		for gene in md.get("genes", []):
			if GenesData.GENES.has(gene) and Genome.state(String(gene)) >= 1:
				out.append([String(md["raw"]["id"]), String(gene)])
				break
	return out


func _families() -> Array:
	return (m.character.erbario.get("famiglie", {}) as Dictionary).keys()


func _kills(f: String) -> int:
	var n := 0
	for s in FamiliesData.FAMILIES[f]["members"]:
		n += int((m.character.erbario.get("creature", {}) as Dictionary).get(s, 0))
	return n


## Un materiale che il personaggio ha già trovato (Erbario degli oggetti), o legno.
func _known_material() -> String:
	var pool := []
	for id in (m.character.erbario.get("oggetti", {}) as Dictionary):
		var it := ItemsData.get_item(String(id))
		if String(it.get("kind", "")) == "materiale" and not it.get("gen", false) and String(id) != "linfa_antica" \
				and String(id) != "frammento_albero":
			pool.append(String(id))
	return String(pool[_rng.randi_range(0, pool.size() - 1)]) if not pool.is_empty() else "legno"


## Quanto manca: [fatto, serve].
func progress(r: Dictionary) -> Array:
	var ch: Character = m.character
	var n := int(r["n"])
	match String(r["tipo"]):
		"gene", "prodotto", "fornitura", "pesce", "cielo":
			return [mini(Crafting.have(ch.bisaccia, String(r["cosa"])), n), n]
		"caccia":
			return [mini(_kills(String(r["cosa"])) - int(r["base"]), n), n]
		"mandria":
			return [mini(int((ch.erbario.get("addomesticate", {}) as Dictionary).get(String(r["cosa"]), 0)) - int(r["base"]), n), n]
		"firma":
			return [mini(int(ch.stats.get("firme", 0)) - int(r["base"]), n), n]
		"viaggio":
			return [mini(int(ch.stats.get("viaggi", 0)) - int(r["base"]), n), n]
		"sigillo":
			return [mini(int(ch.stats.get("sigilli", 0)) - int(r["base"]), n), n]
		"stanza":
			return [mini(int(ch.stats.get("stanza_" + String(r["cosa"]), 0)) - int(r["base"]), n), n]
		"signore":
			return [mini(int(ch.stats.get("signori", 0)) - int(r["base"]), n), n]
		"marea":
			return [mini(int(ch.stats.get("maree_vinte", 0)) - int(r["base"]), n), n]
		"studio":
			return [mini(int(ch.stats.get("studiate", 0)) - int(r["base"]), n), n]
		"centrale":
			return [mini(int(ch.stats.get("centrali", 0)) - int(r["base"]), n), n]
	return [0, n]


func can_deliver(r: Dictionary) -> bool:
	var p := progress(r)
	return int(p[0]) >= int(p[1])


## Consegna la richiesta i: toglie gli oggetti, dà il premio, ne arriva una nuova.
func deliver(i: int) -> bool:
	var r: Dictionary = open_list()[i]
	if not can_deliver(r):
		return false
	if String(r["tipo"]) in ["gene", "prodotto", "fornitura", "cielo", "rete"]:
		Crafting.take(m.character.bisaccia, String(r["cosa"]), int(r["n"]))
	for k in r["premio"]:
		if k == "seme":
			_rare_seed()
		else:
			var rest: int = m.character.bisaccia.add(String(k), int(r["premio"][k]))
			if rest > 0:
				m.drops.spawn(String(k), rest, m.player.position)
	open_list().remove_at(i)
	m.character.bacheca["fatte"] = int(m.character.bacheca.get("fatte", 0)) + 1
	m.objectives.bump("bacheca")
	m.sfx.play("dono")
	fill()
	return true


## Cambia la richiesta i con un'altra (se non piace).
func swap(i: int) -> void:
	open_list().remove_at(i)
	fill()


## Un Seme di mondo con un gene raro in più: il premio più ambito della bacheca.
func _rare_seed() -> void:
	var g := _rare_seed_genome()
	var item := Genome.item_of(g)
	if m.character.bisaccia.add_stack({"id": item, "n": 1, "dati": g}) > 0:
		m.drops.spawn(item, 1, m.player.position, g)


## Il genoma di un Seme con un gene raro in più (anche le catene brevi lo danno in premio, voce 69).
func _rare_seed_genome() -> Dictionary:
	var v := maxi(int(m.world_meta.get("vigore", 1)), 1) + 1
	var g := Genome.roll(_rng, v)
	var rares := []
	for k in GenesData.GENES:
		var d: Dictionary = GenesData.GENES[k]
		if int(d["rar"]) >= 1 and not d.has("only") and not k in g["geni"] and String(d["cat"]) != "superficie" \
				and v >= int(d.get("vmin", 0)):
			rares.append(k)
	if not rares.is_empty():
		(g["geni"] as Array).append(rares[_rng.randi_range(0, rares.size() - 1)])
		g["geni"] = Genome.sort(g["geni"])
	return g


func open() -> bool:
	fill()
	panel.open()
	return true
