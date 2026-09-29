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
