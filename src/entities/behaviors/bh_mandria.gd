class_name BhMandria
extends Behavior
## Una creatura della mandria (voce 59, `Herd`): prende il posto dei comportamenti selvatici. I modi:
##   segue      sta accanto al Germogliato (ognuna al suo posto), salta gli ostacoli; se resta indietro, si blocca o
##              esce dalla visuale ricompare accanto a lui. Roadmap 32, voce 310: combatte **con il suo stile**, cioè
##              con i comportamenti della sua specie (`BondsData.style_of`) puntati sulla creatura nemica (`c.target`);
##              i colpi, il contatto e le ferite li fa `BondFight`. Se la sua Vita finisce: `Herd.faint`
##   recinto    gironzola dentro il suo recinto (non si fa male)
##   cavalcata  sta sotto il Germogliato e si muove con lui
##   guardia    voce 148: resta alla sua cuccia (`home` = il punto) e attacca chi ostile le si avvicina entro `GUARD`
##              tessere (le ondate delle maree comprese), con il suo stile anche lei

var herd: Node2D                       # il modulo `Herd`
var rec: Dictionary                    # la sua scheda (in `Character.mandria`)
var mode := "segue"
var slot := 0
var home := Vector2.ZERO               # recinto: da x a y in pixel
var foe: Creature
var style: Array[Behavior] = []        # voce 310: i comportamenti della sua specie (lo stile)
var pause := {}                        # comportamento -> secondi in cui tace (lo scoppio, voce 310)
var _hurt_cd := 0.0
var _jump_cd := 0.0
var _look := 0.0
var _best := INF                       # la distanza più corta dal posto accanto al Germogliato da quando è lontano
var _stuck := 0.0
var _fighting := false

const GUARD := 14.0                    # tessere attorno alla cuccia che la creatura di guardia difende


## Lo stile della specie (lo chiama `Herd.spawn`).
func setup_style(cid: String) -> void:
	style.clear()
	for b in BondsData.style_of(cid):
		style.append(Behavior.make(b))


func tick(c: Creature, dt: float) -> void:
	var m: Node2D = herd.m
	var p: Player = m.player
	_hurt_cd -= dt
	_jump_cd -= dt
	_look -= dt
	for b in pause.keys():
		pause[b] = float(pause[b]) - dt
		if float(pause[b]) <= 0.0:
			pause.erase(b)
	match mode:
		"cavalcata":
			c.position = p.position + Vector2(0, Player.HALF.y - c.half.y)
			c.vel = p.vel
			c.facing = p.facing
			return
		"recinto":
			c._wander(dt)
			if c.position.x < home.x:
				c.want_x = 0.5
				c.facing = 1
			elif c.position.x > home.y:
				c.want_x = -0.5
				c.facing = -1
			if c.fly:
				c.want_fly.y = clampf((m.pens.pen_y(rec) - 24.0 - c.position.y) * 2.0, -40.0, 40.0)
			return
	if mode == "guardia":
		_hurt(c, m)
		if not is_instance_valid(c) or c.tame != self:
			return
		if _look <= 0.0:
			_look = 0.35
			foe = _guard_foe(c, m)
		if not _alive(m, foe):
			foe = null
		if foe != null:
			_fight(c, m, dt)
		else:
			_calm(c, m)
			_go(c, home)
		return
	_catch_up(c, p, dt)
	_hurt(c, m)
	if not is_instance_valid(c) or c.tame != self:
		return
	if _look <= 0.0:
		_look = 0.35
		foe = _find_foe(c, m) if herd.fights(rec) else null
	if not _alive(m, foe) or (foe != null and foe.position.distance_to(p.position) > BondsData.LEASH * 16.0):
		foe = null
	if foe != null:
		_fight(c, m, dt)
		return
	_calm(c, m)
	_go(c, p.position + Vector2((-22.0 - slot * 16.0) * p.facing, 0.0))


## Il nemico è ancora vivo e nel mondo?
static func _alive(m: Node2D, o) -> bool:
	return o != null and is_instance_valid(o) and m.fauna.list.has(o) and o.hp > 0


## Voce 310: combatte con il suo stile. Il bersaglio dei comportamenti diventa il nemico; il contatto ferisce, gli
## spari e le richieste al mondo li raccoglie `BondFight`.
func _fight(c: Creature, m: Node2D, dt: float) -> void:
	_fighting = true
	c.target = foe
	for b in style:
		if not pause.has(b):
			b.tick(c, dt)
	var fight: BondFight = herd.fight
	fight.contact(c, rec)
	if is_instance_valid(c) and c.tame == self:
		fight.collect(c, rec)


## Finito lo scontro: torna una creatura che segue (niente cariche a metà, niente travestimenti, fuori dalla terra).
func _calm(c: Creature, m: Node2D) -> void:
	c.target = m.player
	if not _fighting:
		return
	_fighting = false
	c.busy = false
	c.shake = 0.0
	c.mouth = false
	c.crouch = 0.0
	c.anchored = false
	c.upside = false
	c.buried = false
	c.shell = 0.0
	c.fire.clear()
	c.acts.clear()
	c.summons.clear()


## Voce 310: non resta mai indietro. Lontano (fuori dalla visuale) ricompare accanto al Germogliato; se non si
## avvicina al suo obiettivo (il posto accanto al Germogliato, o il nemico) per un po', anche: una carica finita in
## una buca, un muro che non sa saltare. In lotta aspetta di più (`STUCK_FIGHT`).
func _catch_up(c: Creature, p: Player, dt: float) -> void:
	var d := c.position.distance_to(p.position)
	if d > BondsData.FAR * 16.0:
		_reset_stuck(c, true)
		return
	var goal: Vector2 = foe.position if _alive(herd.m, foe) else p.position
	var g := c.position.distance_to(goal)
	if g < BondsData.STUCK_FROM * 16.0:
		_reset_stuck(c, false)
		return
	if g < _best - 8.0:
		_best = g
		_stuck = 0.0
	else:
		_stuck += dt
		if _stuck > (BondsData.STUCK_FIGHT if foe != null else BondsData.STUCK_TIME):
			_reset_stuck(c, true)


func _reset_stuck(c: Creature, move: bool) -> void:
	if move:
		_calm(c, herd.m)
		herd.fight.beside(c)
	_best = INF
	_stuck = 0.0


## Va verso un punto: chi vola (o scava) ci vola, un po' sopra; chi cammina corre e salta muri e dislivelli.
func _go(c: Creature, goal: Vector2) -> void:
	var catch_up := maxf(1.0, 115.0 / maxf(c.speed, 1.0))
	var far := c.position.distance_to(goal) > 6.0 * 16.0
	if far:
		catch_up *= 1.5                                # molto indietro: corre di più
	if c.fly or c.ghost:
		var to := goal + Vector2(0, -18) - c.position
		c.want_fly = to.normalized() * c.speed * catch_up if to.length() > 10.0 else Vector2.ZERO
		return
	var dx := goal.x - c.position.x
	c.want_x = clampf(dx / 30.0, -1.0, 1.0) * catch_up if absf(dx) > 10.0 else 0.0
	if c.want_x != 0.0:
		c.facing = int(signf(c.want_x))
	if c.on_floor and _jump_cd <= 0.0 and absf(dx) > 8.0 and (c.wall_ahead(c.facing) or goal.y < c.position.y - 36.0):
		c.vel.y = -330.0
		c.on_floor = false
		_jump_cd = 0.5


## La creatura più vicina che minaccia il Germogliato (entro `BondsData.SIGHT` tessere da lui).
func _find_foe(c: Creature, m: Node2D) -> Creature:
	if _alive(m, foe) and foe.position.distance_to(m.player.position) < BondsData.SIGHT * 16.0:
		return foe                                      # non cambia nemico a ogni passo
	var best := BondsData.SIGHT * 16.0
	var out: Creature = null
	for o in m.fauna.list:
		if o.calm or o.damage <= 0 or o.buried:
			continue
		var d: float = o.position.distance_to(m.player.position)
		if d < best and o.position.distance_to(c.position) < (BondsData.SIGHT + 6.0) * 16.0:
			best = d
			out = o
	return out


## Le creature selvatiche che la toccano la feriscono; se la Vita finisce si ritira (`Herd.faint`).
func _hurt(c: Creature, m: Node2D) -> void:
	if _hurt_cd > 0.0:
		return
	for o in m.fauna.list:
		if o.damage > 0 and not o.calm and not o.buried and o.rect().intersects(c.rect()):
			_hurt_cd = 0.9
			herd.fight.hurt(c, rec, o.damage, o.position.x)
			return


## Voce 148: il nemico più vicino alla cuccia, entro `GUARD` tessere.
func _guard_foe(c: Creature, m: Node2D) -> Creature:
	var best := GUARD * 16.0
	var out: Creature = null
	for o in m.fauna.list:
		if o == c or o.tame != null or o.calm or o.damage <= 0 or o.buried or o.docile:
			continue
		var d: float = o.position.distance_to(home)
		if d < best:
			best = d
			out = o
	return out
