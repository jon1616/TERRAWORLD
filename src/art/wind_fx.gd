class_name WindFx
extends RefCounted
## Il vento nella vegetazione (voce 284, guida `ARTE.md` §7): un solo materiale per l'erba, i fiori, le felci e le piante
## dei biomi (lo strato «morbido» delle decorazioni in `WorldView`) e uno per le chiome degli alberi. La parte alta di ogni
## pianta ondeggia di uno o due pixel interi (niente sfocature: resta pixel art), la base resta ferma; il vento di
## `Weather` spinge tutto dalla sua parte e allarga l'oscillazione. Sotto terra una brezza appena percettibile.

## Le piante: ogni cella è una tessera da 16; la posizione nella tessera viene dal vertice (`wpos`), così funziona anche
## con il bordo che il motore aggiunge alle tessere dell'atlante. Il campione spostato non esce mai dalla sua tessera.
const PLANT_SHADER := """
shader_type canvas_item;
uniform float wind = 0.0;       // -2..2: il vento di Weather (segno = verso)
uniform float breeze = 1.0;     // 0..1: quanto si muove anche senza vento
uniform vec3 push[8];           // voce 339: chi passa (x, y dei piedi nel mondo, forza): l'erba si piega via da lui
varying vec2 wpos;
void vertex() {
	wpos = VERTEX;
}
void fragment() {
	vec2 local = fract(wpos / 16.0);
	float up = 1.0 - local.y;                       // 1 in cima alla tessera, 0 alla base
	float phase = TIME * (1.4 + abs(wind) * 0.8) + floor(wpos.x / 16.0) * 0.83;
	float sway = (sin(phase) * (0.55 + abs(wind) * 0.45) * breeze + wind * 0.9) * up * up * 2.0;
	vec2 tc = floor(wpos / 16.0) * 16.0 + vec2(8.0);
	float bend = 0.0;
	for (int i = 0; i < 8; i++) {
		float ddx = tc.x - push[i].x;
		if (abs(ddx) < 14.0 && abs(tc.y - push[i].y) < 14.0) {
			bend += (ddx >= 0.0 ? 1.0 : -1.0) * (1.0 - abs(ddx) / 14.0) * push[i].z;
		}
	}
	sway += clamp(bend, -1.2, 1.2) * 3.0 * up;
	float dx = floor(sway + 0.5);                   // pixel interi
	float sx = local.x * 16.0 - dx;
	if (sx < 0.0 || sx >= 16.0) {
		COLOR = vec4(0.0);
	} else {
		COLOR = texture(TEXTURE, UV - vec2(dx * TEXTURE_PIXEL_SIZE.x, 0.0)) * COLOR;
	}
}
"""

## Le chiome: l'immagine dell'albero (una per specie × grandezza × forma) ha la base in basso; si piega solo il terzo
## alto, di al più `amp` pixel, e il campione resta dentro l'immagine.
const TREE_SHADER := """
shader_type canvas_item;
uniform float wind = 0.0;
uniform float seed = 0.0;
uniform float amp = 2.0;
void fragment() {
	float up = clamp((0.62 - UV.y) / 0.62, 0.0, 1.0);
	float sway = (sin(TIME * (0.9 + abs(wind) * 0.5) + seed) * (0.6 + abs(wind) * 0.4) + wind * 0.8) * up * up * amp;
	float dx = floor(sway + 0.5);
	vec2 uv = UV - vec2(dx * TEXTURE_PIXEL_SIZE.x, 0.0);
	if (uv.x < 0.0 || uv.x > 1.0) {
		COLOR = vec4(0.0);
	} else {
		COLOR = texture(TEXTURE, uv) * COLOR;
	}
}
"""

static var plants: ShaderMaterial
static var _tree_shader: Shader
static var _trees: Array[ShaderMaterial] = []


static func plant_material() -> ShaderMaterial:
	if plants == null:
		var sh := Shader.new()
		sh.code = PLANT_SHADER
		plants = ShaderMaterial.new()
		plants.shader = sh
	return plants


## Un materiale per albero (la fase diversa li fa muovere ognuno per conto suo); pochi, riusati per fase.
static func tree_material(x: int) -> ShaderMaterial:
	if _tree_shader == null:
		_tree_shader = Shader.new()
		_tree_shader.code = TREE_SHADER
	var k := posmod(x * 7, 8)
	while _trees.size() <= k:
		var m := ShaderMaterial.new()
		m.shader = _tree_shader
		m.set_shader_parameter("seed", float(_trees.size()) * 0.79)
		_trees.append(m)
	return _trees[k]


## Voce 339: chi spinge l'erba (al più 8: x, y dei piedi, forza), da `SurfaceLife` a ogni fotogramma.
static func set_push(arr: Array[Vector3]) -> void:
	plant_material().set_shader_parameter("push", arr)


## Il vento di `Weather` (px/s², 0-200) diventa la spinta degli shader; `under` = sotto terra (solo brezza leggera).
static func set_wind(px: float, under: bool) -> void:
	var w := 0.0 if under else clampf(px / 100.0, -2.0, 2.0)
	plant_material().set_shader_parameter("wind", w)
	plant_material().set_shader_parameter("breeze", 0.35 if under else 1.0)
	for m in _trees:
		m.set_shader_parameter("wind", w)
