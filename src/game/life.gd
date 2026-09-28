class_name Life
extends Node
## La vita del Germogliato nella scena: ferite da caduta, lampi sullo schermo, appassire e rinascere alla partenza.
## Le regole dei numeri stanno in `Vitals`; qui c'è ciò che succede attorno.

const FALL_SAFE := 12.0                # tessere di caduta senza ferite
const FALL_HURT := 6                   # punti di Vita per ogni tessera in più

var m: Node2D                          # la scena di gioco
var dead := false
var fall_safe := false
var bundle := Vector2i(-1, -1)         # dove è rimasto l'ultimo fagotto (per le prove)                 # un accessorio (Foglia planante) toglie le ferite da caduta


func setup(main: Node2D) -> void:
	m = main
	m.vitals.died.connect(_on_died)
	m.player.landed.connect(_on_landed)


func _on_landed(tiles: float) -> void:
	if tiles > FALL_SAFE and SkyData.soft_under(m.world, m.player.position):
		return                                 # Roadmap 16: la nuvola accoglie chi ci cade sopra
	if tiles > FALL_SAFE and not dead and not fall_safe:
		var lost: int = m.vitals.hurt(int((tiles - FALL_SAFE) * FALL_HURT))
		m.hud.toast("Caduta: -%d Vita" % lost)
		m.player.hurt_t = HeroSprites.HURT_TIME
		flash(Color(1.0, 0.4, 0.3, 0.35))


## Il Germogliato appassisce: si ferma, lo schermo si scurisce, e dopo un momento rinasce alla partenza.
func _on_died() -> void:
	if dead:
		return
	dead = true
	var had_control: bool = m.player.control
	m.player.control = false
	m.actions.enabled = false
	# le pose dell'appassire (vedi `HeroAnimator.hurt`); il colore si spegne solo un poco, la posa dice già tutto
	m.player.wilting = true
	m.player.wilt_t = 0.0
	m.player.modulate = Color(0.8, 0.72, 0.62)
	m.hud.toast("Il Germogliato appassisce…")
	_drop_bundle()
	flash(Color(0.0, 0.0, 0.0, 0.6), 2.5)
	await get_tree().create_timer(3.0).timeout
	m.player.modulate = Color.WHITE
	m.player.wilting = false
	m.vitals.refill()
	m.snap_to(m.masonry.respawn_point())
	m.player.control = had_control
	m.actions.enabled = true
	dead = false
	m.hud.toast("Rinasci alla partenza. La tua Bisaccia è rimasta in un fagotto dove sei appassito (è sulla mappa)" if bundle.x >= 0 and m.world.stations.has(bundle) else "Rinasci alla partenza")


## Appassire costa (voce 20): la parte grande della Bisaccia (non la barra rapida, non ciò che si indossa) resta in
## un fagotto di foglie dove si è caduti, segnato sulla mappa; bisogna tornare a prenderla.
func _drop_bundle() -> void:
	var b: Bisaccia = m.character.bisaccia
	var any := false
	for i in range(Bisaccia.HOTBAR, b.slots.size()):
		if not b.slots[i].is_empty():
			any = true
	if not any:
		return
	var c: Vector2i = m.player_cell()
	var w: World = m.world
	# una cella libera vicina (niente stazioni, niente roccia)
	for r in 6:
		var found := false
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				var q := c + Vector2i(dx, dy)
				if not found and w.inside(q.x, q.y) and not w.solid(q.x, q.y) and w.station_at(q).is_empty():
					c = q
					found = true
		if found:
			break
	w.stations[c] = "fagotto"
	var bag := w.chest_at(c)
	for i in range(Bisaccia.HOTBAR, b.slots.size()):
		if not b.slots[i].is_empty():
			bag.add_stack(b.slots[i])
			b.slots[i] = {}
	b.changed.emit()
	m.view.add_station(c)
	m.light.dirty = true
	bundle = c


## Un lampo colorato su tutto lo schermo che svanisce.
func flash(c: Color, secs := 0.4) -> void:
	var r := ColorRect.new()
	r.color = c
	r.set_anchors_preset(Control.PRESET_FULL_RECT)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	m.hud.add_child(r)
	var tw := create_tween()
	tw.tween_property(r, "modulate:a", 0.0, secs)
	tw.tween_callback(r.queue_free)
