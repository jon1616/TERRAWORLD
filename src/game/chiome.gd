class_name Chiome
extends Node
## Le Chiome del cielo in partita (Roadmap 16): le zone del cielo (`World.sky`, fatte da `PassCielo`) si salvano in
## `world_meta["cielo"]` e si rimettono nel mondo a ogni ingresso; entrando in un bioma del cielo compare la sua scritta
## (come gli strati, `DepthWatch.banner`); `stats["cielo_max"]` ricorda la fascia più alta raggiunta (1 basso, 2 alto)
## per i consigli, il filo e gli obiettivi.

const EVERY := 0.25

var m: Node2D
var here := ""                         # il bioma del cielo dove si trova il Germogliato ("" = non in cielo)
var _t := 0.0


func setup(main: Node2D) -> void:
	m = main
	if m.world.sky.is_empty() and m.world_meta.has("cielo"):
		m.world.sky = (m.world_meta["cielo"] as Array).duplicate(true)
	elif not m.world.sky.is_empty():
		m.world_meta["cielo"] = m.world.sky.duplicate(true)


func _process(dt: float) -> void:
	if m == null or not m.built:
		return
	_t -= dt
	if _t > 0.0:
		return
	_t = EVERY
	var c: Vector2i = m.player_cell()
	var id := SkyData.zone_at(m.world, c.x, c.y)
	# un piccolo margine sul confine: si cambia solo se anche 4 tessere più in là è lo stesso
	if id != here and SkyData.zone_at(m.world, c.x, c.y + (4 if id != "" else -4)) != here:
		here = id
		if id != "":
			var b := SkyData.get_biome(id)
			var band := String(b["band"])
			m.depth_watch.banner.show_stratum(String(b["name"]), String(b["desc"]), Color(String(b["color"])))
			var st: Dictionary = m.character.stats
			st["cielo_max"] = maxi(int(st.get("cielo_max", 0)), 2 if band == "alto" else 1)
			var seen: Dictionary = st.get("cieli_visti", {})
			seen[id] = true
			st["cieli_visti"] = seen
