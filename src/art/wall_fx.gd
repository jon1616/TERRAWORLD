class_name WallFx
extends RefCounted
## Roadmap 33, voce 322: le pareti di fondo non sono più una carta da parati. La loro trama è la stessa di 64 pixel
## (quattro tessere) del terreno, e ripetuta su tutta la visuale si vedeva il motivo. Lo shader (sullo strato delle
## pareti di `WorldView`) la copre con macchie grandi di tono e di colore che cambiano su decine di tessere, da un rumore
## nello spazio del mondo: la stessa parete, ogni grotta un po' diversa. `DecorPainter` le disegna anche con meno
## contrasto (`WALL_CONTRAST`).

const DARK := 0.62                     # il tono più scuro delle macchie…
const LIGHT := 1.18                    # …e il più chiaro

static var _mat: ShaderMaterial


static func material() -> ShaderMaterial:
	if _mat != null:
		return _mat
	var sh := Shader.new()
	sh.code = """
shader_type canvas_item;
uniform float dark = 0.7;
uniform float light = 1.15;
varying vec2 wpos;

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	vec2 t = wpos / 16.0;
	float n = noise(t / 7.0) * 0.4 + noise(t / 19.0 + 3.1) * 0.3 + noise(t / 2.3 + 9.7) * 0.18 + noise(t / 1.1 + 5.3) * 0.12;
	float m = mix(dark, light, n);
	float h = noise(t / 29.0 + 17.0);
	vec3 tint = mix(vec3(0.9, 0.97, 1.08), vec3(1.07, 1.0, 0.9), h);
	c.rgb *= m * tint;
	COLOR = c;
}
"""
	_mat = ShaderMaterial.new()
	_mat.shader = sh
	_mat.set_shader_parameter("dark", DARK)
	_mat.set_shader_parameter("light", LIGHT)
	return _mat
