class_name BhCorrenti
extends Behavior
## Le correnti (voce 136, la Signora delle correnti): ogni tanto (`p.gust_every`) chiama il vento: una raffica spinge
## via il Germogliato, e per qualche secondo nascono colonne d'aria che fanno salire e passerelle di nuvola su cui
## combattere (`GreatGuardians`). Contromossa: le correnti portano in alto, dove lei vola.

var t := 3.0
var tell := -1.0


func tick(c: Creature, dt: float) -> void:
	if tell >= 0.0:
		tell -= dt
		if tell < 0.0 and c.target:
			c.acts.append({"kind": "correnti", "at": c.target.position, "from": c.position})
		return
	t -= dt * (1.4 if c.enraged else 1.0)
	if t > 0.0 or not Behavior.sees(c, float(c.p.get("sight", 30))):
		return
	t = float(c.p.get("gust_every", 7.0))
	tell = 0.7
	c.telegraph(tell)
