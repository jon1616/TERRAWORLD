class_name Sampling
extends Node
## Trovare i geni (voce 46). Tre strade in ogni mondo:
## - la **Provetta di Linfa**: clic su ciò che porta un gene (erba, terra, aria delle grotte, rocce profonde, vene,
##   gemme, pietra dei Seminatori, alberi, cielo aperto, terra avvizzita; vicino alla firma, un gene della firma) →
##   la **Fiala** di quel gene del mondo (`GenesData.CAT_INFO[cat]["where"]`). Se il mondo non ha geni di quella
##   categoria la Provetta non si consuma;
## - le **piante-seme** selvatiche (stazione `pianta_seme`, `PassPianteSeme`): clic destro = una Fiala di un gene del
##   mondo, o un **Seme selvatico** figlio del mondo (a volte mutato);
## - le creature: una sconfitta può lasciare la Fiala del gene di fauna del mondo, una rara quella delle stirpi.
## Ogni Fiala che entra nella Bisaccia fa **imparare** il suo gene (`Character.genario` = 2, il Genario lo conta).

const S := 16
const WILD_SEED := 0.3                 # probabilità che una pianta-seme dia un Seme selvatico invece di una Fiala
const DROP_FAUNA := 0.04               # Fiala di fauna da una creatura sconfitta
const DROP_SEASON := 0.2               # voce 66: Fiala del gene di stagione dalla creatura di quella stagione
const DROP_STIRPI := 0.3               # Fiala delle stirpi da una creatura rara

const SEASON_CHANCE := 0.4           # voce 66: quante Provette nell'aria prendono il gene della stagione
var m: Node2D
var _rng := RandomNumberGenerator.new()


func setup(main: Node2D) -> void:
	m = main
	_rng.randomize()
	m.character.bisaccia.changed.connect(_learn_from_bag)
	m.fauna.killed.connect(_on_kill)
	_learn_from_bag()


## I geni del mondo in cui si è.
func genes() -> Array:
	return m.world_traits.genes


## Il gene del mondo in una categoria ("" se non ne ha).
func gene_of(cat: String) -> String:
	for g in genes():
		if GenesData.cat_of(String(g)) == cat:
			return String(g)
	return ""


## Quale categoria di gene si preleva in una cella (e perché), secondo ciò che c'è.
func category_at(c: Vector2i) -> String:
	var w: World = m.world
	var t := w.tile(c.x, c.y)
	var dep := c.y - w.surface[clampi(c.x, 0, w.w - 1)]
	if m.signature.center().x >= 0 and Vector2(c).distance_to(Vector2(m.signature.center())) < 14.0:
		return "firma"
	if w.tree_at(c).x >= 0:
		return "flora"
	if t in TileDefs.BLIGHTED:
		return "ombra"
	if t == TileDefs.PIETRA_SEM:
		return "rovine"
	if t in [TileDefs.RADICITE, TileDefs.LEGNOFERRO, TileDefs.AMBRA, TileDefs.PALLIDITE, TileDefs.TIZZONITE]:
		return "minerali"
	if t == TileDefs.CRYSTAL or w.decor_at(c.x, c.y) in TileDefs.DECOR_GEMS:
		return "gemme"
	if TileDefs.is_grass(t) and dep < 6:
		return "superficie"
	if t == TileDefs.AIR:
		if dep > 8:
			return "grotte"
		return "cielo" if _rng.randf() < 0.5 or gene_of("tempo") == "" else "tempo"
	if dep < 30:
		return "forma"
	return "sottosuolo"


## La Provetta usata sulla cella c. Vero se ha preso un gene (e la Provetta si consuma).
func use_vial(id: String, c: Vector2i) -> bool:
	if not m.actions.in_reach(c):
		return false
	var cat := category_at(c)
	var g := ""
	if cat == "firma":
		g = String(SignaturesData.SIGNATURES.get(String(m.signature.info().get("id", "")), {}).get("gene", ""))
		if g == "" or not GenesData.GENES.has(g):
			cat = "rovine"
	# voce 66: nell'aria della superficie, a volte, l'aria della stagione (se il mondo non ne ha una fissa)
	if g == "" and cat in ["cielo", "tempo"] and m.seasons.fixed == 0 and _rng.randf() < SEASON_CHANCE:
		g = String(SeasonsData.SEASONS[m.seasons.current]["gene"])
	if g == "":
		g = gene_of(cat)
	if g == "":
		m.hud.toast("Nessun gene di %s in questo mondo (cercavi in %s)" % [String(GenesData.CAT_INFO[cat]["name"]).to_lower(),
			GenesData.CAT_INFO[cat]["where"]])
		return false
	if not m.character.bisaccia.remove(id, 1):
		return false
	give(g, Vector2(c) * S + Vector2(8, 8))
	m.hud.toast("La Provetta si riempie: Fiala di %s" % GenesData.GENES[g]["name"])
	m.sfx.play("pozione", Vector2(c) * S)
	return true


## Una Fiala del gene g, nella Bisaccia o a terra.
func give(g: String, at: Vector2) -> void:
	var fid := GenesData.vial_of(g)
	if m.character.bisaccia.add(fid, 1) > 0:
		m.drops.spawn(fid, 1, at)


## Una pianta-seme raccolta (clic destro): una Fiala di un gene del mondo, o un Seme selvatico.
func harvest(o: Vector2i) -> void:
	var at := Vector2(o) * S + Vector2(8, 8)
	m.world.stations.erase(o)
	m.view.remove_station(o)
	m.light.dirty = true
	var gs := genes()
	if gs.is_empty() or _rng.randf() < WILD_SEED:
		var child := wild_seed()
		m.drops.spawn(Genome.item_of(child), 1, at, child)
		m.hud.toast("La pianta-seme lascia cadere un Seme selvatico")
	else:
		give(String(gs[_rng.randi_range(0, gs.size() - 1)]), at)
		m.hud.toast("La pianta-seme si apre: dentro, una Fiala di gene")
	m.sfx.play("raccogli", at)


## Un Seme selvatico: figlio del mondo in cui cresce (ogni gene del mondo resta con il 70%, poi qualche gene a caso) e
## a volte mutato (voce 48, `Genome.mutate`).
func wild_seed() -> Dictionary:
	var base := Genome.roll(_rng, Genome.local_vigor, Genome.surface_of(genes()))
	var out: Array = []
	var cats := {}
	for g in genes():
		if GenesData.cat_of(String(g)) == "superficie" or _rng.randf() < 0.7:
			out.append(g)
			cats[GenesData.cat_of(String(g))] = true
	for g in Genome.genes(base):
		if not cats.has(GenesData.cat_of(String(g))):
			out.append(g)
			cats[GenesData.cat_of(String(g))] = true
	var child := {"geni": Genome.sort(out), "vigore": Genome.local_vigor}
	return Genome.mutate(child, _rng, Genome.WILD_MUTATION)


func _on_kill(c: Creature) -> void:
	var g := gene_of("fauna")
	if g != "" and _rng.randf() < DROP_FAUNA:
		m.drops.spawn(GenesData.vial_of(g), 1, c.position)
	# voce 66: la creatura di una stagione porta il gene che la ferma
	if c.data.has("season") and _rng.randf() < DROP_SEASON:
		for sd in SeasonsData.SEASONS:
			if sd["id"] in (c.data["season"] if c.data["season"] is Array else [c.data["season"]]):   # voce 134: anche elenchi
				m.drops.spawn(GenesData.vial_of(String(sd["gene"])), 1, c.position)
	var s := gene_of("stirpi")
	if s != "" and c.ancient and _rng.randf() < DROP_STIRPI:
		m.drops.spawn(GenesData.vial_of(s), 1, c.position)


## Le Fiale nella Bisaccia fanno imparare i loro geni (le schede dei Semi li mostrano; il Genario li conta).
func _learn_from_bag() -> void:
	var b: Bisaccia = m.character.bisaccia
	for i in b.slots.size():
		var g := GenesData.gene_of_vial(b.id_at(i))
		if g != "" and Genome.state(g) < 2:
			Genome.known[g] = 2
			m.objectives.bump("geni_imparati")
			m.hud.toast("Gene imparato: %s (Genario, tasto K)" % GenesData.GENES[g]["name"])
