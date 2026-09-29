class_name MbTamburo
extends MachineBehavior
## Il Tamburo di radice: gira quando qualcuno ci corre dentro (il Germogliato, o una creatura della mandria che si
## muove), e allora dà i suoi pulsi.

const SPEED := 25.0                    # px/s: chi va più piano di così non lo fa girare


func produce(mc: Machine, e: Energy) -> float:
	var r := Rect2(Vector2(mc.o) * 16.0, Vector2(mc.size()) * 16.0).grow(2.0)
	var p: Player = e.m.player
	if r.has_point(p.position + Vector2(0, Player.HALF.y - 2.0)) and absf(p.vel.x) > SPEED:
		return float(mc.d["pulsi"])
	for c in e.m.fauna.list:
		if c.tame != null and r.has_point(c.position) and absf(c.vel.x) > SPEED:
			return float(mc.d["pulsi"])
	return 0.0
