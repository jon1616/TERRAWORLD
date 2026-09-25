class_name Hazards
extends Node
## I pericoli dell'ambiente toccati dal Germogliato (voce 20c, generati da `PassPericoli`):
##   rovo spinoso   punge (più forte scendendo); si può tagliare con un attrezzo come ogni decorazione
##   runa trappola  una scarica di spore: ferita e veleno, poi la runa si spegne
## Le ferite passano da `Combat.hurt_player` (con l'invulnerabilità breve dopo ogni colpo).

const S := 16
const ROVO_DMG := 6                    # più 4 per ogni strato sotto la superficie
const TRAP_DMG := 14
const TRAP_POISON := 5.0

var m: Node2D
var paused := false                    # le prove li fermano: le ferite falserebbero le altre misure


func setup(main: Node2D) -> void:
	m = main


func _process(_dt: float) -> void:
	if not m.built or m.life.dead or paused:
		return
	var p: Player = m.player
	var r := Rect2(p.position - Player.HALF, Player.HALF * 2.0).grow(-2.0)
	var x0 := floori(r.position.x / S)
	var x1 := floori(r.end.x / S)
	var y0 := floori(r.position.y / S)
	var y1 := floori(r.end.y / S)
	for y in range(y0, y1 + 1):
		for x in range(x0, x1 + 1):
			match m.world.decor_at(x, y):
				TileDefs.DECOR_ROVO:
					var st := StrataData.at(m.world, x, y)
					m.combat.hurt_player(ROVO_DMG + 4 * st, x * S + 8)
					return
				TileDefs.DECOR_TRAP:
					_spring(Vector2i(x, y))
					return


func _spring(c: Vector2i) -> void:
	m.world.set_decor(c.x, c.y, 0)
	m.view.refresh_around(c)
	m.light.dirty = true
	Fx.puff(m.fx, Vector2(c) * S + Vector2(8, 4), Color(1.2, 1.8, 0.6))
	m.sfx.play("spora", Vector2(c) * S)
	m.combat.hurt_player(TRAP_DMG, c.x * S + 8)
	m.vitals.poison_t = maxf(m.vitals.poison_t, TRAP_POISON)
	m.hud.toast("Una runa trappola dei Seminatori!")
