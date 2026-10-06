class_name BhSpecchio
extends Behavior
## Specchio (voce 378): a metà Vita si sdoppia: chiama due copie di sé, più piccole (le fa nascere la fauna). Una
## volta sola. Parametri: mirror_n.

var done := false


func tick(c: Creature, _dt: float) -> void:
	if done or not c.enraged:
		return
	done = true
	c.telegraph(0.5)
	for k in int(c.p.get("mirror_n", 2)):
		c.summons.append(c.id)
