class_name SkyClouds
extends RefCounted
## Roadmap 34, voce 330: due piani di nuvole nello sfondo (`Background` li monta tra le radici del cosmo e i piani del
## bioma). Scorrono con il vento (`Weather` passa `wind`); quante sono e quanto sono scure lo dice il tempo che fa
## (campo `cloud` di `WeatherData`: [copertura, scurezza]); il colore viene dal cielo del bioma e di notte dalla luna.
## La copertura cambia piano (mezzo minuto per passare dal sereno alla pioggia): le nuvole compaiono una alla volta.

const SHADER := """
shader_type canvas_item;
uniform vec4 lit : source_color = vec4(1.0);
uniform vec4 shade : source_color = vec4(0.6, 0.65, 0.75, 1.0);
uniform float cover = 0.3;
varying vec4 tint;
void vertex() {
	tint = COLOR;
}
void fragment() {
	vec4 t = texture(TEXTURE, UV);
	t.rg = pow(t.rg, vec2(1.0 / 2.2));    // con hdr_2d l'immagine arriva in lineare: si rileggono le misure com'erano
	float a = t.a * clamp((cover - t.g) * 14.0, 0.0, 1.0);
	COLOR = vec4(mix(shade.rgb, lit.rgb, t.r), a * lit.a) * tint;
}
"""
## I due piani: [parallasse, spostamento verticale, larghezza, altezza, grandezza delle nuvole, velocità]
const PLANES := [
	[0.08, -60.0, 1024, 150, 0.7, 0.5],
	[0.2, -10.0, 1280, 170, 1.15, 1.0],
]
const CHANGE := 0.035                  # copertura per secondo
const DEFAULT := [0.3, 0.0]

var layers: Array[Dictionary] = []
var mats: Array[ShaderMaterial] = []
var wind := 0.0                        # px/s² del tempo (con il segno)
var goal := DEFAULT.duplicate()        # [copertura, scurezza] del tempo che fa
var cover := 0.3
var dark := 0.0
var night := 0.0
var moon := Color.WHITE                # la luce della luna (compensa il buio che moltiplica anche lo sfondo)


## Crea i piani dentro `bg` (con la sua funzione dei piani, così seguono la visuale come gli altri).
func build(bg: Node2D, sd: int) -> Array[Dictionary]:
	var sh := Shader.new()
	sh.code = SHADER
	for k in PLANES.size():
		var p: Array = PLANES[k]
		var im := CloudArt.layer(int(p[2]), int(p[3]), sd + 900 + k * 31, float(p[4]))
		var L: Dictionary = bg._make_layer(bg, im, float(p[0]), float(p[1]), int(p[2]))
		L["drift"] = 0.0
		L["speed"] = float(p[5])
		var mat := ShaderMaterial.new()
		mat.shader = sh
		for sp in L["sprites"]:
			(sp as Sprite2D).material = mat
		layers.append(L)
		mats.append(mat)
	return layers


## Il tempo cambia (da `Weather.apply`).
func set_weather(st: Dictionary) -> void:
	goal = st.get("cloud", DEFAULT)


## Subito il cielo del tempo che fa, senza passaggio (ingresso nel mondo, prove).
func snap() -> void:
	cover = float(goal[0])
	dark = float(goal[1])


func update(dt: float, sky: Color) -> void:
	cover = move_toward(cover, float(goal[0]), CHANGE * dt)
	dark = move_toward(dark, float(goal[1]), CHANGE * dt)
	# scorrono sempre un poco (verso destra quando non c'è vento), il vento le spinge di più
	var v := 5.0 + wind * 0.14 if wind >= 0.0 else -5.0 + wind * 0.14
	for L in layers:
		L["drift"] = fposmod(float(L["drift"]) + v * float(L["speed"]) * dt, float(L["w"]))
	# il colore: bianco sporcato dal cielo del bioma; più scure con la pioggia; di notte il chiarore della luna
	var lit := Color(1, 1, 1).lerp(sky, 0.22).lerp(Color(0.5, 0.53, 0.6), dark)
	var shd := sky.darkened(0.3).lerp(Color(0.2, 0.22, 0.28), dark)
	var g := minf((moon.r + moon.g + moon.b) / 3.0, 2.5)      # quanto va compensato il buio (uguale nei tre colori)
	var nl := (Color(0.56, 0.6, 0.68) * g * 0.5).lerp(Color(0.56, 0.6, 0.68) * g * 0.28, dark)
	lit = lit.lerp(nl, night * 0.85)
	shd = shd.lerp(Color(0.2, 0.21, 0.26) * g * 0.4, night * 0.85)
	lit.a = 0.95
	for i in mats.size():
		mats[i].set_shader_parameter("lit", lit)
		mats[i].set_shader_parameter("shade", shd)
		# il piano lontano ha qualche nuvola in meno
		mats[i].set_shader_parameter("cover", cover * (0.8 if i == 0 else 1.0))
