class_name LightFx
extends RefCounted
## Roadmap 33, voce 320: come si stende la luce sul mondo. L'immagine della luce (`LightMap`, un pixel per tessera) si
## legge con un filtro bicubico (una B-spline fatta con quattro letture bilineari): la luce sfuma morbida e non mostra più
## gli angoli delle tessere. Moltiplica i colori come prima (`blend_mul`).
## Voce 321: dalla forma della finestra (`LightMap.shape_tex`: pieno e pareti, letta anche lei morbida) il rilievo: il
## terreno che ha aria sopra prende un filo di luce in più (`RIM`), quello che ha aria sotto un'ombra (`SHADE`); le
## pareti di fondo si scuriscono dove toccano il terreno (`AO`, un'ombra d'angolo). Tutto moltiplica la luce: al buio
## resta buio.
const RIM := 0.38
const SHADE := 0.32
const AO := 0.5

static var _shader: Shader


static func overlay_material() -> ShaderMaterial:
	if _shader == null:
		_shader = Shader.new()
		_shader.code = """
shader_type canvas_item;
render_mode blend_mul;
uniform sampler2D shape : filter_linear, repeat_disable;
uniform float rim = 0.38;
uniform float shade = 0.32;
uniform float ao = 0.5;

vec4 cubic(float v) {
	vec4 n = vec4(1.0, 2.0, 3.0, 4.0) - v;
	vec4 s = n * n * n;
	float x = s.x;
	float y = s.y - 4.0 * s.x;
	float z = s.z - 4.0 * s.y + 6.0 * s.x;
	float w = 6.0 - x - y - z;
	return vec4(x, y, z, w) * (1.0 / 6.0);
}

vec4 bicubic(sampler2D tex, vec2 uv, vec2 size) {
	vec2 inv = 1.0 / size;
	uv = uv * size - 0.5;
	vec2 fxy = fract(uv);
	uv -= fxy;
	vec4 xc = cubic(fxy.x);
	vec4 yc = cubic(fxy.y);
	vec4 c = uv.xxyy + vec2(-0.5, 1.5).xyxy;
	vec4 s = vec4(xc.xz + xc.yw, yc.xz + yc.yw);
	vec4 off = c + vec4(xc.yw, yc.yw) / s;
	off *= inv.xxyy;
	vec4 s0 = texture(tex, off.xz);
	vec4 s1 = texture(tex, off.yz);
	vec4 s2 = texture(tex, off.xw);
	vec4 s3 = texture(tex, off.yw);
	float sx = s.x / (s.x + s.y);
	float sy = s.z / (s.z + s.w);
	return mix(mix(s3, s2, sx), mix(s1, s0, sx), sy);
}

vec4 bicubic_shape(vec2 uv, vec2 size) {
	vec2 inv = 1.0 / size;
	uv = uv * size - 0.5;
	vec2 fxy = fract(uv);
	uv -= fxy;
	vec4 xc = cubic(fxy.x);
	vec4 yc = cubic(fxy.y);
	vec4 c = uv.xxyy + vec2(-0.5, 1.5).xyxy;
	vec4 s = vec4(xc.xz + xc.yw, yc.xz + yc.yw);
	vec4 off = c + vec4(xc.yw, yc.yw) / s;
	off *= inv.xxyy;
	vec4 s0 = texture(shape, off.xz);
	vec4 s1 = texture(shape, off.yz);
	vec4 s2 = texture(shape, off.xw);
	vec4 s3 = texture(shape, off.yw);
	float sx = s.x / (s.x + s.y);
	float sy = s.z / (s.z + s.w);
	return mix(mix(s3, s2, sx), mix(s1, s0, sx), sy);
}

void fragment() {
	vec2 sz = 1.0 / TEXTURE_PIXEL_SIZE;
	vec3 light = bicubic(TEXTURE, UV, sz).rgb;
	vec4 sh = bicubic_shape(UV, sz);
	float s0 = sh.r;
	float rel = 1.0;
	if (s0 > 0.42) {
		float up = bicubic_shape(UV - vec2(0.0, TEXTURE_PIXEL_SIZE.y * 0.45), sz).r;
		float dn = bicubic_shape(UV + vec2(0.0, TEXTURE_PIXEL_SIZE.y * 0.45), sz).r;
		rel = 1.0 + rim * clamp((s0 - up) * 2.4, 0.0, 1.0) - shade * clamp((s0 - dn) * 2.4, 0.0, 1.0);
	} else {
		rel = 1.0 - ao * smoothstep(0.04, 0.42, s0) * sh.g;
	}
	COLOR = vec4(light * rel, 1.0);
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = _shader
	mat.set_shader_parameter("rim", RIM)
	mat.set_shader_parameter("shade", SHADE)
	mat.set_shader_parameter("ao", AO)
	return mat
