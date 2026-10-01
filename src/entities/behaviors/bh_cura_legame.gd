class_name BhCuraLegame
extends Behavior
## L'Istinto della cura (Roadmap 32, voce 314): solo per i compagni. In lotta, ogni `EVERY` secondi si illumina un
## attimo (il segnale) e chiede una cura (`acts` «cura»): `BondFight.collect` cura il compagno e il Germogliato.

const EVERY := 8.0
var t := 4.0


func tick(c: Creature, dt: float) -> void:
	t -= dt
	if t > 0.0:
		return
	t = EVERY
	c.telegraph(0.3)
	c.acts.append({"kind": "cura"})
