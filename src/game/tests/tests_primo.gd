class_name TestsPrimo
extends RefCounted
## Roadmap 28 «Il Seme Primo»: il Giardino oltre il Vuoto, il finale, il dopo (gruppo `primo`).

var kit: TestKit
var m: Node


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	await place()
	await guardian()


## Voce 263: con il parametro «primo» il generatore fa la radura con l'Albero Antico; senza, no.
func place() -> void:
	var ws: Array[World] = await kit.gen_many([[8080, 1600, 900, {"geni": ["lanterna"], "vigore": 6, "primo": true}],
		[8080, 1600, 900, {"geni": ["lanterna"], "vigore": 6}]])
	var with := ws[0].gen_notes.get("primo", {}) as Dictionary
	var tree_ok := false
	if with.has("tree"):
		tree_ok = String(ws[0].stations.get(with["tree"], "")) == "albero_antico"
	var col: Array = (ws[0].gen_notes.get("collaudo", {}) as Dictionary).get("problemi", [])
	var ok: bool = tree_ok and not ws[1].gen_notes.has("primo") and col.is_empty()
	print("Giardino oltre il Vuoto: Albero Antico %s a %s; senza il Seme Primo niente %s; collaudo %s" % [tree_ok, str(with.get("tree", "")),
		not ws[1].gen_notes.has("primo"), str(col)])
	if not ok:
		print("ATTENZIONE: il Giardino oltre il Vuoto non nasce come dovrebbe")


## Voce 263: il primo tocco sveglia l'ultimo Seminatore; sconfitto lascia il suo seme; portato all'Albero, il finale.
func guardian() -> void:
	var pg: PrimoGarden = m.primo
	var o: Vector2i = m.player_cell() + Vector2i(6, -12)
	m.world.stations[o] = "albero_antico"
	var had: Variant = m.world_meta.get("primo", null)
	var had_state: Variant = m.world_meta.get("primo_luogo", null)
	m.world_meta["primo"] = true
	m.world_meta.erase("primo_luogo")
	var active: bool = pg.active()
	pg.touch(o)
	var boss: Creature = pg.boss
	var woke: bool = boss != null and pg.state().get("sveglio", false)
	var hp: int = boss.hp_max if boss != null else 0
	if boss != null:
		m.fauna.kill(boss)
	var won: bool = pg.state().get("vinto", false)
	m.guardian.lore.visible = false
	var no_seed: bool = pg.touch(o) and not pg.state().get("finale", false)
	kit.hold("seme_seminatore")
	pg.touch(o)
	var finale: bool = pg.state().get("finale", false)
	m.guardian.lore.visible = false
	if m.get("finale") != null:
		m.finale.close()
	var ok: bool = active and woke and hp >= 4000 and won and no_seed and finale
	print("ultimo Seminatore: attivo %s; sveglio %s (Vita %d); sconfitto %s; senza seme aspetta %s; finale %s" % [active, woke, hp, won,
		no_seed, finale])
	if not ok:
		print("ATTENZIONE: l'ultimo Seminatore e l'Albero Antico non vanno")
	m.world.stations.erase(o)
	if had == null:
		m.world_meta.erase("primo")
	else:
		m.world_meta["primo"] = had
	if had_state == null:
		m.world_meta.erase("primo_luogo")
	else:
		m.world_meta["primo_luogo"] = had_state
