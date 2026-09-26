class_name TipsHook
extends Node
## Collega i suggerimenti (`Tips`) alla partita: dice alle caselle chi è il personaggio (per i set, il confronto con
## ciò che si ha in mano e i prezzi del mercante) e dà al sistema le schede delle cose del mondo (`WorldTip`,
## `StationTip`): che cosa c'è sotto il mouse, dalla più importante (creature) alla meno (piante).
## Solo dove il Germogliato ha già visto (la mappa esplorata): i suggerimenti non svelano il buio.

## Le tessere comuni non hanno scheda: sarebbe rumore mentre si scava.
const PLAIN := [TileDefs.DIRT, TileDefs.GRASS, TileDefs.GRASS_SPORE, TileDefs.GRASS_AMBRA, TileDefs.GRASS_BRINA,
	TileDefs.GRASS_CENERE, TileDefs.STONE, TileDefs.ASSI, TileDefs.MATTONI, TileDefs.VETRO, TileDefs.PORTA]

var m: Node2D
var _hud_done := false


func setup(main: Node2D) -> void:
	m = main
	SlotView.context = _context
	Tips.set_world(_world_tip)


func _context() -> Dictionary:
	var ctx := {"bag": m.character.bisaccia, "hand": m.hud.current()}
	if m.villagers != null and m.villagers.panel != null and m.villagers.panel.visible:
		ctx["price"] = "sell"                  # con il mercante aperto, le caselle dicono quanto ti dà
	return ctx


## [chiave, costruttore] della cosa sotto il mouse, o [].
func _world_tip(screen: Vector2) -> Array:
	if not m.built or (m.hud.map != null and m.hud.map.visible):
		return []
	for o in m.hud.overlays:
		if o.visible:
			return []
	var wp: Vector2 = m.get_viewport().get_canvas_transform().affine_inverse() * screen
	var c := Vector2i(floori(wp.x / 16.0), floori(wp.y / 16.0))
	var w: World = m.world
	if not w.inside(c.x, c.y) or w.explored[c.y * w.w + c.x] == 0:
		return []
	for cr in m.fauna.list:
		if is_instance_valid(cr) and not cr.buried and absf(cr.position.x - wp.x) <= cr.half.x + 3.0 \
				and absf(cr.position.y - wp.y) <= cr.half.y + 3.0:
			return [cr, func() -> Variant: return WorldTip.creature(m, cr) if is_instance_valid(cr) else null]
	for n in m.villagers.list:
		if is_instance_valid(n) and n.rect().grow(2.0).has_point(wp):
			return [n, func() -> Variant: return WorldTip.npc(m, n) if is_instance_valid(n) else null]
	var d: Dictionary = m.drops.at(wp, 10.0)
	if not d.is_empty():
		return [d["key"], func() -> Variant: return WorldTip.drop(d)]
	var st: Dictionary = w.station_at(c)
	if not st.is_empty():
		var o: Vector2i = st["origin"]
		var sid := String(st["id"])
		return ["st%d,%d,%s" % [o.x, o.y, sid], func() -> Variant: return StationTip.card(m, o, sid)]
	if w.crops.has(c):
		return ["cr%d,%d" % [c.x, c.y], func() -> Variant: return WorldTip.crop(w.crops[c]) if w.crops.has(c) else null]
	var t := w.tile(c.x, c.y)
	if t != TileDefs.AIR:
		if t in PLAIN:
			return []
		return ["t%d,%d,%d" % [c.x, c.y, t], func() -> Variant: return WorldTip.tile(m, t)]
	var tr := w.tree_at(c)
	if tr.x >= 0:
		return ["tr%d,%d" % [tr.x, tr.y], func() -> Variant: return WorldTip.tree(tr)]
	var dc := w.decor_at(c.x, c.y)
	if TileDefs.DECOR_DROP.has(dc):
		return ["dc%d,%d" % [c.x, c.y], func() -> Variant: return WorldTip.decor(dc)]
	return []


func _process(_dt: float) -> void:
	if not _hud_done and m.built:
		_hud_done = true
		HudTips.attach(m)                      # a gioco pronto: tutti i moduli dell'interfaccia esistono
		set_process(false)


func _exit_tree() -> void:
	SlotView.context = Callable()
	Tips.clear_world()
	Tips.hide_now()
