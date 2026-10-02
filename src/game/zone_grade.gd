class_name ZoneGrade
extends Node
## Roadmap 33, voce 324: la tinta delle zone. Un rettangolo a tutto schermo (sopra il mondo, sotto la vignettatura e
## l'interfaccia) rilegge lo schermo e lo corregge: ombre colorate, luci, saturazione e contrasto della zona dove si
## trova il Germogliato (`GradeData`), sfumati in `GradeData.FADE` secondi al cambio di strato o di bioma. Le ombre si
## colorano moltiplicando: il nero resta nero (la scelta dell'utente sul buio). Si spegne con l'opzione «tinta_zone».

const SHADER := """
shader_type canvas_item;
uniform sampler2D screen : hint_screen_texture, filter_linear;
uniform vec3 shadow = vec3(1.0);
uniform vec3 gain = vec3(1.0);
uniform float sat = 1.0;
uniform float contrast = 1.0;

void fragment() {
	vec3 lin = texture(screen, SCREEN_UV).rgb;
	vec3 c = pow(max(lin, vec3(0.0)), vec3(1.0 / 2.2));          // i toni come li vede l'occhio
	float l = dot(c, vec3(0.2126, 0.7152, 0.0722));
	c = mix(vec3(l), c, sat);
	c = (c - 0.5) * contrast + 0.5;
	vec3 st = shadow / max(dot(shadow, vec3(0.2126, 0.7152, 0.0722)), 0.001);   // tinta senza togliere luce
	c *= mix(st, vec3(1.0), smoothstep(0.0, 0.55, l));
	c *= gain;
	c = pow(max(c, vec3(0.0)), vec3(2.2)) * step(0.0005, dot(lin, vec3(0.3333)));  // il nero resta nero
	COLOR = vec4(c, 1.0);
}
"""

var m: Node2D
var _rect: ColorRect
var _mat: ShaderMaterial
var _cur := GradeData.NEUTRAL.duplicate()
var _goal := GradeData.NEUTRAL.duplicate()
var _t := 0.0


func setup(main: Node2D) -> void:
	m = main
	var layer := CanvasLayer.new()
	layer.layer = 4                          # sopra il mondo, sotto la vignettatura (5) e l'interfaccia (10)
	add_child(layer)
	_rect = ColorRect.new()
	_rect.size = Vector2(1600, 900)
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sh := Shader.new()
	sh.code = SHADER
	_mat = ShaderMaterial.new()
	_mat.shader = sh
	_rect.material = _mat
	layer.add_child(_rect)
	_apply()


func _process(dt: float) -> void:
	if m == null or not m.built:
		return
	_rect.visible = bool(Settings.v("tinta_zone"))
	_t -= dt
	if _t <= 0.0:
		_t = 0.5
		var c: Vector2i = (m.player.position / 16.0).floor()
		var s := StrataData.at(m.world, c.x, c.y)
		var elem := ""
		if s <= 0 and c.x >= 0 and c.x < m.world.biomes.size():
			var bi := int(m.world.biomes[c.x])
			if bi < BiomesData.BIOMES.size():
				elem = String((BiomesData.BIOMES[bi] as Dictionary).get("elem", ""))
		_goal = GradeData.of(s, elem)
	var k := clampf(dt / GradeData.FADE, 0.0, 1.0)
	for key in ["shadow", "gain"]:
		_cur[key] = (_cur[key] as Color).lerp(_goal[key], k)
	for key in ["sat", "contrast"]:
		_cur[key] = lerpf(float(_cur[key]), float(_goal[key]), k)
	_apply()


## Subito la tinta della zona (all'ingresso nel mondo e nelle foto delle prove).
func snap() -> void:
	_t = 0.0
	_process(0.0)
	_cur = _goal.duplicate()
	_apply()


func _apply() -> void:
	var sh: Color = _cur["shadow"]
	var gn: Color = _cur["gain"]
	_mat.set_shader_parameter("shadow", Vector3(sh.r, sh.g, sh.b))
	_mat.set_shader_parameter("gain", Vector3(gn.r, gn.g, gn.b))
	_mat.set_shader_parameter("sat", float(_cur["sat"]))
	_mat.set_shader_parameter("contrast", float(_cur["contrast"]))
