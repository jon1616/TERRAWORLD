class_name Grounds
extends Node
## Roadmap 52, voce 415: i blocchi con una fisica che vivono nel tempo e le corde.
##   - la **Lastra fragile** (`TileDefs.FRAGILE`): poco dopo che il Germogliato o una creatura ci sale sopra, crolla
##     (senza lasciare niente: è una trappola a buca);
##   - il **Rovo murato** (`TileDefs.SPIKE`): punge le creature selvatiche che lo toccano (non il Germogliato né la
##     mandria);
##   - le **corde** (`place_rope`): una corda si appende sotto un blocco, una passerella o un'altra corda, e cliccando
##     sulla corda la si allunga verso il basso. L'arrampicata la fa `Player._climb_step`.
## Il rimbalzo, il ghiaccio, la resina, la neve e la grata li leggono direttamente `Player`, `Life` e `Liquids`.

const S := 16
const NEAR := 48.0                     # tessere: le creature più lontane non si guardano
const SPIKE_EVERY := 0.45              # secondi tra due punture

var m: Node2D
var crumbled := 0                      # per le prove: lastre crollate, punture date
var pricks := 0
var _crumble := {}                     # cella -> secondi che restano prima che crolli
var _spike_t := 0.0


func setup(main: Node2D) -> void:
	m = main


func _process(dt: float) -> void:
	if m == null or not m.built:
		return
	var w: World = m.world
	var p: Player = m.player
	if p.on_floor:
		_step_on(_feet(p.position, Player.HALF))
	var reach := NEAR * S
	for c in m.fauna.list:
		var cr := c as Creature
		if cr == null or cr.position.distance_to(p.position) > reach:
			continue
		_step_on(_feet(cr.position, cr.half))
	for q in _crumble.keys():
		var left := float(_crumble[q]) - dt
		if left > 0.0:
			_crumble[q] = left
			continue
		_crumble.erase(q)
		var t := w.tile(q.x, q.y)
		if TileDefs.FRAGILE[t] > 0.0:
			w.set_tile(q.x, q.y, TileDefs.AIR)
			m.view.refresh_around(q)
			m.light.dirty = true
			Fx.dust(m.fx, Vector2(q) * S + Vector2(8, 8), TileDefs.dust_colors(t))
			m.sfx.play("rompi", Vector2(q) * S)
			m.actions.dug.emit(t, q)              # ciò che stava sopra (sabbie) frana come dopo uno scavo
			crumbled += 1
	_spike_t -= dt
	if _spike_t <= 0.0:
		_spike_t = SPIKE_EVERY
		_spikes(reach)


## La cella sotto i piedi di un corpo (centro `pos`, mezza misura `half`).
static func _feet(pos: Vector2, half: Vector2) -> Vector2i:
	return Vector2i(floori(pos.x / S), floori((pos.y + half.y + 2.0) / S))


func _step_on(q: Vector2i) -> void:
	var t: int = m.world.tile(q.x, q.y)
	if TileDefs.FRAGILE[t] > 0.0 and not _crumble.has(q):
		_crumble[q] = TileDefs.FRAGILE[t]


## Le creature selvatiche che toccano un Rovo murato (sotto i piedi o ai fianchi) si pungono.
func _spikes(reach: float) -> void:
	var w: World = m.world
	for c in m.fauna.list.duplicate():
		var cr := c as Creature
		if cr == null or cr.tame != null or cr.position.distance_to(m.player.position) > reach:
			continue
		var f := _feet(cr.position, cr.half)
		var mid := floori(cr.position.y / S)
		var best := 0.0
		for q in [f, Vector2i(floori((cr.position.x - cr.half.x - 2.0) / S), mid), Vector2i(floori((cr.position.x + cr.half.x + 2.0) / S), mid)]:
			best = maxf(best, TileDefs.SPIKE[w.tile(q.x, q.y)])
		if best > 0.0:
			m.combat._strike(cr, int(best), cr.position.x, 0.3)
			pricks += 1


## Appende una corda (o una liana, o una catena) nella cella c, o in fondo alla corda che c'è in c. Vero se l'ha messa.
func place_rope(c: Vector2i, id: String) -> bool:
	var w: World = m.world
	var decor := int(ItemsData.get_item(id).get("decor", 0))
	if decor == 0 or not m.actions.in_reach(c):
		return false
	var q := c
	if TileDefs.CLIMB_SPEED[w.decor_at(q.x, q.y)] > 0.0:
		while w.inside(q.x, q.y) and TileDefs.CLIMB_SPEED[w.decor_at(q.x, q.y)] > 0.0:
			q.y += 1
	if not w.inside(q.x, q.y) or w.solid(q.x, q.y) or w.decor_at(q.x, q.y) != 0 or w.plat(q.x, q.y):
		return false
	var up := q + Vector2i(0, -1)
	if not (w.solid(up.x, up.y) or w.plat(up.x, up.y) or TileDefs.CLIMB_SPEED[w.decor_at(up.x, up.y)] > 0.0):
		m.hud.toast("Una corda si appende sotto un blocco, una passerella o un'altra corda")
		return false
	w.set_decor(q.x, q.y, decor)
	m.character.bisaccia.remove(id, 1)
	m.view.refresh_around(q)
	return true
