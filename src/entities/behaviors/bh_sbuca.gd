class_name BhSbuca
extends Behavior
## Sbuca da sotto (voce 130): aspetta nella terra, scivola sotto il Germogliato, la terra trema e si solleva polvere
## (il segnale: ci si sposta), poi salta fuori; dopo un po' torna a scavare. Parametri: sight, windup, out_time.
## Roadmap 54, voce 424 (l'utente: «di punto in bianco scappano passando attraverso il terreno»): non si immerge più
## all'improvviso. Nasce già nella terra (`enter`); per tornare giù si ferma, trema e scava (polvere) per `DIG` secondi;
## ferita e in fuga scava subito per scappare, e sotto terra nuota lontano da te invece di puntarti; nella terra non
## esce mai da un lato che dà sul vuoto (le isole del cielo, i soffitti sottili): ci resta dentro.

const DIG := 0.7                      # secondi in cui trema e scava prima di sparire nella terra
const OUT_MIN := 1.2                  # fuori resta almeno tanto prima di poter tornare giù per fuggire

var phase := 0                        # 0 sotto terra · 1 annuncia · 2 fuori · 3 scava per tornare giù
var timer := 0.0
var _dust := 0.0
var _out := 0.0
var _sink := 0.0                      # sta affondando nella terra (dopo aver scavato)


## Appena nata (Roadmap 54): se c'è terra sotto i piedi ci sta già dentro, così non la si vede affondare.
func enter(c: Creature) -> void:
	var fx := floori(c.position.x / 16.0)
	var fy := floori((c.position.y + c.half.y + 2.0) / 16.0)
	if c.wild and _can_dig(c):
		c.position.y = (fy + 1) * 16.0
		c.ghost = true
		c.buried = true
		c.busy = true
		phase = 0
	else:
		phase = 2                         # niente terra sotto: cammina finché non la trova
		timer = 0.0


func tick(c: Creature, dt: float) -> void:
	var cell := Vector2i(floori(c.position.x / 16.0), floori(c.position.y / 16.0))
	var inside := c.world.solid(cell.x, cell.y)
	var fleeing := c.mind.state == Mind.FLEE
	match phase:
		0:
			c.ghost = true
			c.buried = inside
			c.busy = true
			if not inside:
				if _sink > 0.0:
					_sink -= dt                  # sta ancora affondando nel buco che ha scavato
					return
				# fuori dalla terra mentre nuota (non dovrebbe): esce come se sbucasse, senza cadere nel vuoto
				_surface(c, 0.0)
				return
			_sink = 0.0
			var goal := Vector2.INF
			if fleeing and c.target != null:
				var away := signf(c.position.x - c.target.position.x)
				goal = c.position + Vector2((away if away != 0.0 else 1.0) * 64.0, 8.0)
			elif Behavior.sees(c, float(c.p.get("sight", 14))):
				goal = Vector2(c.target.position.x, c.target.position.y + 40.0)
			if goal == Vector2.INF:
				c.want_fly = Vector2.ZERO
				c.vel = Vector2.ZERO
				return
			var to := goal - c.position
			c.want_fly = to.normalized() * c.speed * 1.3 if to.length() > 6.0 else Vector2.ZERO
			_stay_in(c)
			if not fleeing and absf(to.x) < 10.0:
				phase = 1
				timer = 0.7 * float(c.p.get("windup", 1.0))
				c.telegraph(timer)
				c.want_fly = Vector2.ZERO
				c.vel = Vector2.ZERO
		1:
			c.want_fly = Vector2.ZERO
			c.vel = Vector2.ZERO
			timer -= dt
			_dust_above(c, cell, dt)
			if timer <= 0.0:
				phase = 2
				_out = 0.0
				timer = float(c.p.get("out_time", 5.0))
				c.want_fly = Vector2(0, -420)
				c.vel = Vector2(0, -420)
		2:
			if inside and c.ghost:
				c.want_fly = Vector2(0, -420)
				return
			c.ghost = false
			c.buried = false
			c.busy = false
			_out += dt
			timer -= dt
			if c.on_floor and _can_dig(c) and (timer <= 0.0 or (fleeing and _out > OUT_MIN)):
				phase = 3                    # torna giù: prima si ferma e scava
				timer = DIG
				c.busy = true
		3:
			c.busy = true
			c.want_x = 0.0
			c.vel.x = 0.0
			c.shake = 1.0
			timer -= dt
			_dust -= dt
			if _dust <= 0.0 and c.get_parent():
				_dust = 0.1
				var feet := Vector2i(cell.x, floori((c.position.y + c.half.y + 2.0) / 16.0))
				Fx.dust(c.get_parent(), c.position + Vector2(0, c.half.y), TileDefs.dust_colors(c.world.tile(feet.x, feet.y)))
			if timer <= 0.0:
				c.shake = 0.0
				phase = 0
				c.ghost = true
				_sink = 0.6
				c.vel = Vector2(0, 160)
				c.want_fly = Vector2(0, 160)


## Esce dalla terra (o non c'è terra dove nuotare): torna una creatura che cammina.
func _surface(c: Creature, t: float) -> void:
	phase = 2
	timer = t
	_out = 0.0
	c.ghost = false
	c.buried = false
	c.busy = false


## C'è terra da scavare sotto i piedi (spessa almeno due tessere: non una passerella o un ponte sottile)?
func _can_dig(c: Creature) -> bool:
	var fx := floori(c.position.x / 16.0)
	var fy := floori((c.position.y + c.half.y + 2.0) / 16.0)
	return c.world.solid(fx, fy) and c.world.solid(fx, fy + 1)


## Nuotando non esce dalla terra da un lato che dà sull'aria (ci si ferma contro il bordo).
func _stay_in(c: Creature) -> void:
	if c.want_fly == Vector2.ZERO:
		return
	var ahead := c.position + c.want_fly.normalized() * 12.0
	if not c.world.solid(floori(ahead.x / 16.0), floori(ahead.y / 16.0)):
		c.want_fly = Vector2.ZERO
		c.vel = Vector2.ZERO


func _dust_above(c: Creature, cell: Vector2i, dt: float) -> void:
	_dust -= dt
	if _dust > 0.0 or not c.get_parent():
		return
	_dust = 0.12                         # la terra trema sopra di lei
	var up := cell
	for i in 6:
		if not c.world.solid(up.x, up.y - 1):
			break
		up.y -= 1
	Fx.dust(c.get_parent(), Vector2(up) * 16.0 + Vector2(8, 0), TileDefs.dust_colors(c.world.tile(up.x, up.y)))
