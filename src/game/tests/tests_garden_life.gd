class_name TestsGardenLife
extends RefCounted
## Roadmap 22 «Il Giardino vivo»: bellezza, isole, visitatori, feste, storie, mestieri, grandi opere (gruppo `giardino_vivo`).

var kit: TestKit
var m: Node


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	await beauty()
	await islands()


## Voce 227: la bellezza nasce dalle stanze, dai tipi di stanza, dalla felicità degli abitanti; salire dà maestria.
func beauty() -> void:
	var saved := {"stanze": m.world_meta.get("stanze", []), "felicita": m.world_meta.get("felicita", {})}
	var best0 := int(m.character.stats.get("bellezza_max", 0))
	var pts0: float = m.mastery.points("giardino")
	m.world_meta["stanze"] = [{"comfort": 20, "type": "casa"}, {"comfort": 10, "type": "serra"}, {"comfort": 4, "type": "stanza"}]
	m.world_meta["felicita"] = {"mercante_semi": 80, "mandriano": 60}
	m.character.stats["bellezza_max"] = 0
	var p: Dictionary = m.beauty.parts()
	var v: int = m.beauty.update()
	var gained: float = m.mastery.points("giardino") - pts0
	var ok := int(p["stanze"]) == 34 and int(p["tipi"]) == 16 and int(p["abitanti"]) == 14 and v >= 64 and gained >= 64.0
	print("bellezza del Giardino: %d (%s); maestria del Giardino +%.0f" % [v, str(p), gained])
	if not ok:
		print("ATTENZIONE: la bellezza del Giardino non si calcola come deve")
	m.world_meta["stanze"] = saved["stanze"]
	m.world_meta["felicita"] = saved["felicita"]
	m.character.stats["bellezza_max"] = best0


## Voce 228: un'isola nasce (tessere, ponte, recinto), le colture sull'isola dell'orto crescono di più, la miniera viva
## rimette i minerali. Nel mondo di prova le isole si costruiscono a mano (le soglie valgono nel Giardino).
func islands() -> void:
	var gi: GardenIslands = m.garden_islands
	var saved: Variant = m.world_meta.get("isole", null)
	m.world_meta["isole"] = {}
	gi.build("orto")
	gi.build("bottega")
	var e: Dictionary = gi.built()["orto"]
	var on := gi.grow_at(Vector2i(int(e["x"]), int(e["y"]) - 1))
	var off := gi.grow_at(Vector2i(int(e["x"]) + 200, int(e["y"])))
	var ground: bool = m.world.solid(int(e["x"]) + 10, int(e["y"]) + 2)
	var b: Dictionary = gi.built()["bottega"]
	var ores := 0
	gi._mine(b)
	for x in range(int(b["x"]) - int(b["half"]), int(b["x"]) + int(b["half"])):
		for y in range(int(b["y"]), int(b["y"]) + 14):
			if m.world.tile(x, y) in [TileDefs.RADICITE, TileDefs.LEGNOFERRO, TileDefs.AMBRA, TileDefs.CRYSTAL]:
				ores += 1
	var ok := is_equal_approx(on, GardenIslandsData.ORTO_GROW) and is_equal_approx(off, 1.0) and ground and ores >= 10
	print("isole del Giardino: orto nata %s (crescita ×%.1f sull'isola, ×%.1f fuori), bottega con %d minerali" % [ground, on, off, ores])
	if not ok:
		print("ATTENZIONE: le isole del Giardino non vanno")
	if saved == null:
		m.world_meta.erase("isole")
	else:
		m.world_meta["isole"] = saved
