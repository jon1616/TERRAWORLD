class_name BhMimetico
extends Behavior
## Mimetico (voce 130): immobile, sembra una cosa del mondo (l'icona di `p.look`: una cassa, un blocco, una pianta)
## finché non ti avvicini (`p.wake` tessere) o non lo colpisci; la Vista della Linfa lo scopre da lontano
## (`reveal`, lo accende `Wiles` finché la Vista dura). Sveglio, fanno gli altri comportamenti.

static var reveal := false
var awake := false
var _mask: Sprite2D


func tick(c: Creature, _dt: float) -> void:
	if awake:
		return
	if _mask == null:
		_mask = Sprite2D.new()
		_mask.texture = ImageTexture.create_from_image(ItemIcons.of(String(c.p.get("look", "cassa"))))
		_mask.position = Vector2(0, c.half.y - 8.0)
		c.add_child(_mask)
	c.anchored = true
	c.buried = true                              # il corpo non si vede: si vede la maschera
	var near := c.target != null and c.target.position.distance_to(c.position) < float(c.p.get("wake", 3.0)) * 16.0
	var seen := reveal and c.target != null and c.target.position.distance_to(c.position) < 24.0 * 16.0
	if c.hp < c.hp_max or near or seen:
		awake = true
		c.anchored = false
		c.buried = false
		_mask.queue_free()
		c.telegraph(0.4)
		c.vel = Vector2(0, -160)
		if c.get_parent():
			Fx.puff(c.get_parent(), c.position, Color(1.4, 1.2, 1.6))
