class_name LiquidView
extends Node2D
## Il disegno dei liquidi (voce 73): un nodo per blocco da 32×32 vicino alla visuale (gli stessi di `WorldView`), che
## disegna le sue celle d'acqua, Linfa e brace come rettangoli trasparenti alti quanto il livello, con la superficie più
## chiara. Un blocco si ridisegna solo quando `Liquids` tocca una delle sue celle. Sta sopra il terreno e sopra il
## Germogliato (chi nuota si vede dentro l'acqua).

## (voce 285) i liquidi vivi: riflessi che scorrono dentro, luccichii che corrono sulla superficie (la riga di superficie
## ha l'alfa pieno: così lo shader la riconosce), la brace che tremola. Pixel interi, niente sfocature.
## Roadmap 35, voce 336: due disegni in più, riconosciuti dall'alfa (il corpo del liquido arriva al più a 0,98):
##   0,983-0,992  il riflesso del cielo sotto la superficie, in quattro righe (più chiaro in alto); solo all'aperto
##   0,996        una cella che cade (cascata): strisce che scendono
const SHADER := """
shader_type canvas_item;
uniform vec4 sky_tint : source_color = vec4(0.55, 0.78, 0.86, 1.0);
varying vec2 wpos;
void vertex() {
	wpos = VERTEX;
}
void fragment() {
	vec2 p = floor(wpos);
	vec4 c = COLOR;
	float heat = clamp(c.r - c.b, 0.0, 1.0);
	if (c.a > 0.999) {
		// la superficie: un luccichio che corre, a tratti
		float g = step(0.82, sin(p.x * 0.35 - TIME * 2.6) * 0.5 + sin(p.x * 0.11 + TIME * 1.3) * 0.5);
		c.rgb = mix(c.rgb, vec3(1.0), g * 0.45);
	} else if (c.a > 0.994) {
		// la cascata: strisce chiare che scendono, ogni corsia alla sua velocità
		float lane = floor(p.x / 2.0);
		float h = fract(sin(lane * 12.9898) * 43758.5453);
		float s = step(0.58, fract(p.y * 0.06 - TIME * (2.0 + h * 1.5) + h));
		c = vec4(c.rgb * 1.3, 0.1 + 0.32 * s);
	} else if (c.a > 0.9815) {
		// il riflesso del cielo: quattro righe dalla superficie in giù, che ondeggiano appena
		float row = clamp((c.a - 0.983) / 0.003, 0.0, 3.0);
		float sh = 0.7 + 0.3 * sin(p.x * 0.31 + TIME * 1.6 + row * 2.0);
		c = vec4(sky_tint.rgb, (1.0 - row / 4.0) * 0.5 * sh);
	} else {
		// dentro: bande di luce lente che si incrociano (caustiche), più calde e veloci nella brace
		float w = sin(p.x * 0.19 + p.y * 0.07 + TIME * (1.1 + heat * 2.5)) + sin(p.x * 0.07 - p.y * 0.23 - TIME * 0.8);
		c.rgb *= 1.0 + (0.07 + heat * 0.12) * step(0.9, w) - 0.04 * step(w, -1.2);
	}
	COLOR = c;
}
"""

var world: World
var nodes := {}                         # blocco -> LiquidChunk
var _dirty := {}


func _ready() -> void:
	z_as_relative = false
	z_index = 12
	var sh := Shader.new()
	sh.code = SHADER
	material = ShaderMaterial.new()
	(material as ShaderMaterial).shader = sh


func touch(c: Vector2i) -> void:
	_dirty[World.chunk_of(c)] = true


func _process(_dt: float) -> void:
	var want: Rect2i = get_parent().get("_want")
	if want.size == Vector2i.ZERO:
		return
	for k in nodes.keys():
		if not want.grow(1).has_point(k):
			(nodes[k] as Node).queue_free()
			nodes.erase(k)
	for y in range(want.position.y, want.end.y):
		for x in range(want.position.x, want.end.x):
			var k := Vector2i(x, y)
			if not nodes.has(k) and x >= 0 and y >= 0 and x * World.CHUNK < world.w and y * World.CHUNK < world.h:
				var n := LiquidChunk.new()
				n.use_parent_material = true
				n.world = world
				n.chunk = k
				add_child(n)
				nodes[k] = n
	for k in _dirty:
		if nodes.has(k):
			(nodes[k] as Node2D).queue_redraw()
	_dirty.clear()


class LiquidChunk extends Node2D:
	var world: World
	var chunk := Vector2i.ZERO

	func _draw() -> void:
		var x0 := chunk.x * World.CHUNK
		var y0 := chunk.y * World.CHUNK
		for y in range(y0, mini(y0 + World.CHUNK, world.h)):
			for x in range(x0, mini(x0 + World.CHUNK, world.w)):
				var v := world.liquid[y * world.w + x]
				var lv := v & 15
				if lv == 0:
					continue
				var ty := (v >> 4) & 3
				var td: Dictionary = LiquidsData.TYPES[ty]
				var above := world.liq(x, y - 1) > 0
				var hgt := 16.0 if above else 16.0 * lv / 8.0
				# più scuro in profondità (fino a tre celle sotto la superficie), un filo diverso da una cella all'altra
				var depth := 0
				while depth < 3 and world.liq(x, y - depth - 1) > 0:
					depth += 1
				# (voce 285: la variazione per cella faceva una scacchiera; la vita la dà lo shader)
				var col: Color = (td["color"] as Color).darkened(0.12 * depth)
				col.a = minf(float(td["alpha"]), 0.98)
				var r := Rect2(x * 16.0, y * 16.0 + 16.0 - hgt, 16.0, hgt)
				draw_rect(r, col)
				if ty == LiquidsData.BRACE:
					# le braci che galleggiano
					var h2 := (x * 31 + y * 17) % 11
					if h2 < 4:
						draw_rect(Rect2(x * 16.0 + 2.0 + h2 * 3, r.position.y + 3.0 + h2 * 2, 2.0, 2.0), Color("#ffd070"))
				if not above:
					var top: Color = td["top"]
					top.a = 1.0                            # alfa pieno = superficie, per lo shader
					draw_rect(Rect2(r.position, Vector2(16.0, 2.0)), top)
					# voce 336: il cielo si riflette sotto la superficie, all'aperto (non nella brace)
					if ty != LiquidsData.BRACE and world.wall(x, y) == 0 and hgt >= 6.0:
						for row in 4:
							draw_rect(Rect2(r.position + Vector2(0, 2 + row), Vector2(16.0, 1.0)), Color(1, 1, 1, 0.983 + row * 0.003))
				elif _falling(x, y):
					var fc: Color = td["top"]
					fc.a = 0.996                           # voce 336: una cascata (le strisce le fa lo shader)
					draw_rect(r, fc)

	## Voce 336: una cella che cade: liquido sopra, e né a destra né a sinistra (un filo che scende, non un lago).
	func _falling(x: int, y: int) -> bool:
		return world.liq(x - 1, y) == 0 and world.liq(x + 1, y) == 0
