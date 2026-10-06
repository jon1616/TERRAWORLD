class_name Abilities
extends Node
## Il motore delle abilità (Roadmap 43, voce 383; piano in `VASTITA.md`). Gli effetti di `EffectsData` che portano
## accessori, ali e rampini scattano anche dal **movimento**, non solo dai colpi:
##   salto · salto_aria (il doppio salto) · atterraggio (da almeno "da" tessere) · scatto (la schivata) ·
##   raccolta (un oggetto preso da terra) · volo (ogni secondo mentre si vola) · aggancio (il rampino fa presa)
## Fanno le cose di `Effects._do` (sulla creatura più vicina, entro `NEAR` tessere) e quattro cose nuove:
##   scia (t: per qualche secondo chi ti sta attorno si ferisce, frazione "dmg" del colpo dell'arma in mano) ·
##   scudo (n, t: Scorza in più per qualche secondo) · magnete (mult, t: gli oggetti arrivano da più lontano) ·
##   slancio / ispira / mira (le risorse degli stili, `Styles`: +n Slancio, +n Ispirazione, Mira ferma pronta)
## Ogni abilità ha un'attesa minima ("cool", di base `COOL`) perché i salti a raffica non la ripetano all'infinito.

const NEAR := 8.0
const COOL := 0.6

var m: Node2D
var fired := 0                           # per le prove
var _cool := {}
var _scia := 0.0
var _scia_k := 0.0
var _scia_t := 0.0
var _shield := 0.0
var _magnet := 0.0
var _magnet_k := 1.0
var _fly_t := 0.0
var _dash_was := 0.0


func setup(main: Node2D) -> void:
	m = main
	var p: Player = m.player
	p.jumped.connect(func() -> void: trigger("salto"))
	p.air_jumped.connect(func() -> void: trigger("salto_aria"))
	p.landed.connect(func(tiles: float) -> void: trigger("atterraggio", tiles))
	m.drops.picked.connect(func(_id: String, _n: int) -> void: trigger("raccolta"))


func _process(dt: float) -> void:
	if not m.built:
		return
	for k in _cool.keys():
		_cool[k] = float(_cool[k]) - dt
	var p: Player = m.player
	# lo scatto: comincia quando il tempo dello scatto riparte
	if p.dash_t > 0.0 and _dash_was <= 0.0:
		trigger("scatto")
	_dash_was = p.dash_t
	if p.flying:
		_fly_t += dt
		if _fly_t >= 1.0:
			_fly_t = 0.0
			trigger("volo")
	else:
		_fly_t = 0.0
	# le cose che durano
	if _scia > 0.0:
		_scia -= dt
		_scia_t -= dt
		if _scia_t <= 0.0:
			_scia_t = 0.25
			var dmg := maxi(roundi(_weapon_dmg() * _scia_k), 1)
			for c in m.fauna.list.duplicate():
				if is_instance_valid(c) and c.tame == null and c.position.distance_to(p.position) < 1.8 * 16.0:
					if c.take_hit(dmg, p.position.x, 0.2):
						m.fauna.kill(c)
	if _shield > 0.0:
		_shield -= dt
		if _shield <= 0.0:
			m.vitals.ability_scorza = 0
	if _magnet > 0.0:
		_magnet -= dt
		if _magnet <= 0.0:
			m.drops.ability_magnet = 1.0


## Uno degli eventi del movimento: fa scattare gli effetti attivi con quel «quando».
func trigger(when: String, value := 0.0) -> void:
	if m.get("effects") == null:
		return
	for id in m.effects.active:
		var e := EffectsData.info(String(id))
		if String(e.get("when", "")) != when or float(_cool.get(id, 0.0)) > 0.0:
			continue
		if when == "atterraggio" and value < float(e.get("da", 0.0)):
			continue
		if e.has("cond") and not m.effects._cond(String(e["cond"])):
			continue
		if randf() > float(e.get("chance", 1.0)):
			continue
		_cool[id] = float(e.get("cool", COOL))
		run(e)


## Esegue un'abilità.
func run(e: Dictionary) -> void:
	fired += 1
	var amount := roundi(_weapon_dmg())
	match String(e["do"]):
		"scia":
			_scia = maxf(_scia, float(e.get("t", 2.0)))
			_scia_k = maxf(_scia_k if _scia > 0.0 else 0.0, float(e.get("dmg", 0.3)))
			Fx.puff(m.fx, m.player.position, Color(1.4, 1.6, 0.8))
		"scudo":
			_shield = maxf(_shield, float(e.get("t", 3.0)))
			m.vitals.ability_scorza = maxi(m.vitals.ability_scorza, int(e.get("n", 5)))
			Fx.puff(m.fx, m.player.position, Color(0.8, 1.4, 2.0))
		"magnete":
			_magnet = maxf(_magnet, float(e.get("t", 5.0)))
			_magnet_k = float(e.get("mult", 2.5))
			m.drops.ability_magnet = _magnet_k
		"slancio":
			if m.get("styles") != null:
				m.styles.slancio = mini(m.styles.slancio + int(e.get("n", 1)), StylesData.SLANCIO_MAX)
		"ispira":
			if m.get("styles") != null and m.styles.song == "":
				m.styles.ispirazione = mini(m.styles.ispirazione + int(e.get("n", 2)), StylesData.ISPIRAZIONE_MAX - 1)
		"mira":
			if m.get("styles") != null:
				m.styles.mira_ready = true
		_:
			m.effects._do(e, _nearest(), amount)


func _nearest() -> Creature:
	var best: Creature = null
	var bd := NEAR * 16.0
	for c in m.fauna.list:
		if is_instance_valid(c) and c.tame == null and not c.calm:
			var d: float = c.position.distance_to(m.player.position)
			if d < bd:
				bd = d
				best = c
	return best


func _weapon_dmg() -> float:
	var st := Gear.stats(m.hud.current())
	return maxf(float(st["damage"]), 4.0) * m.combat._boon()
