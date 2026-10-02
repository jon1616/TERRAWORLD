class_name AmbientFx
extends Node
## L'aria viva e i passi (voce 286, guida `ARTE.md` §7: poche particelle, brevi). Un solo emettitore segue la visuale e
## lascia nel mondo ciò che nasce (`local_coords` spento): polline di giorno in superficie, lucciole di notte, spore nel
## Sottobosco e nelle Caverne, scintille di Linfa nelle Profondità, braci nel Fondo. E la polvere del terreno sotto i
## piedi del Germogliato quando corre e quando atterra. Tutto si spegne con l'opzione «particelle».

const KINDS := {
	"polline": {"col": Color(1.25, 1.15, 0.8), "amount": 18, "life": 7.0, "grav": Vector2(6, 4), "vel": [4.0, 12.0], "size": [1.0, 1.0]},
	"lucciole": {"col": Color(1.6, 2.1, 0.7), "amount": 16, "life": 5.0, "grav": Vector2(0, -2), "vel": [3.0, 10.0], "size": [1.0, 2.0]},
	"spore": {"col": Color(0.7, 1.5, 1.35), "amount": 20, "life": 8.0, "grav": Vector2(0, -3), "vel": [2.0, 7.0], "size": [1.0, 1.0]},
	"linfa": {"col": Color(0.6, 1.9, 1.8), "amount": 22, "life": 6.0, "grav": Vector2(0, -5), "vel": [3.0, 9.0], "size": [1.0, 2.0]},
	"braci": {"col": Color(2.2, 0.9, 0.35), "amount": 22, "life": 4.0, "grav": Vector2(0, -14), "vel": [6.0, 16.0], "size": [1.0, 2.0]},
}
const VIGNETTE := """
shader_type canvas_item;
void fragment() {
	vec2 d = (UV - 0.5) * vec2(1.0, 0.72);
	COLOR = vec4(0.0, 0.01, 0.02, smoothstep(0.34, 0.72, length(d)) * 0.42);
}
"""
const STEP := 0.28                      # secondi tra due sbuffi di polvere correndo
## Roadmap 33, voce 323: il pulviscolo sotto terra. È disegnato **sotto** l'immagine della luce (z 15, la luce è a 20):
## si vede solo dove c'è luce, come polvere in un raggio, e al buio sparisce da sé.
const DUST := {"col": Color(1.0, 0.92, 0.78, 0.55), "amount": 46, "life": 9.0}

var m: Node2D
var _air: CPUParticles2D
var _dust: CPUParticles2D
var _kind := ""
var _t := 0.0
var _step_t := 0.0


func setup(main: Node2D) -> void:
	m = main
	_air = CPUParticles2D.new()
	_air.local_coords = false
	_air.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_air.direction = Vector2(0, -1)
	_air.spread = 180.0
	_air.z_as_relative = false
	_air.z_index = 24
	_air.emitting = false
	m.fx.add_child(_air)
	_dust = CPUParticles2D.new()
	_dust.local_coords = false
	_dust.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_dust.direction = Vector2(1, 0)
	_dust.spread = 180.0
	_dust.gravity = Vector2(0, 1.5)
	_dust.initial_velocity_min = 1.5
	_dust.initial_velocity_max = 5.0
	_dust.amount = int(DUST["amount"])
	_dust.lifetime = float(DUST["life"])
	_dust.preprocess = float(DUST["life"])            # c'è già quando si scende, non nasce davanti agli occhi
	_dust.scale_amount_min = 1.0
	_dust.scale_amount_max = 1.0
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.2, 0.8, 1.0])
	var dc: Color = DUST["col"]
	g.colors = PackedColorArray([Color(dc, 0.0), dc, dc, Color(dc, 0.0)])
	_dust.color_ramp = g
	_dust.z_as_relative = false
	_dust.z_index = 15
	_dust.emitting = false
	m.fx.add_child(_dust)
	m.player.landed.connect(_on_landed)
	# (voce 287) la vignettatura: gli angoli dello schermo appena più scuri, sotto l'interfaccia; lo sguardo va al centro
	var layer := CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	var v := ColorRect.new()
	v.set_anchors_preset(Control.PRESET_FULL_RECT)
	v.size = Vector2(1600, 900)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sh := Shader.new()
	sh.code = VIGNETTE
	var mat := ShaderMaterial.new()
	mat.shader = sh
	v.material = mat
	layer.add_child(v)


func _process(dt: float) -> void:
	var on := bool(Settings.v("particelle"))
	_t -= dt
	if _t <= 0.0:
		_t = 0.5
		_update_air(on)
	if on:
		_steps(dt)


## Ogni mezzo secondo: l'emettitore si mette sulla visuale e sceglie che cosa c'è nell'aria qui.
func _update_air(on: bool) -> void:
	var view: Vector2 = get_viewport().get_visible_rect().size / (m.cam as Camera2D).zoom
	_air.position = m.cam.get_screen_center_position()
	_air.emission_rect_extents = view * 0.55
	_dust.position = _air.position
	_dust.emission_rect_extents = view * 0.55
	var under := on and StrataData.at(m.world, floori(m.player.position.x / 16.0), floori(m.player.position.y / 16.0)) >= 1
	if _dust.emitting != under:
		_dust.emitting = under
	var kind := _kind_here() if on else ""
	if kind == _kind:
		return
	_kind = kind
	if kind == "":
		_air.emitting = false
		return
	var k: Dictionary = KINDS[kind]
	_air.amount = int(k["amount"])
	_air.lifetime = float(k["life"])
	_air.gravity = k["grav"]
	_air.initial_velocity_min = float((k["vel"] as Array)[0])
	_air.initial_velocity_max = float((k["vel"] as Array)[1])
	_air.scale_amount_min = float((k["size"] as Array)[0])
	_air.scale_amount_max = float((k["size"] as Array)[1])
	_air.color_ramp = Fx.fade(k["col"])
	_air.emitting = true


func _kind_here() -> String:
	var c: Vector2i = (m.player.position / 16.0).floor()
	var s := StrataData.at(m.world, c.x, c.y)
	match s:
		0:
			return "lucciole" if m.day.is_night() else "polline"
		1, 2:
			return "spore"
		3:
			return "linfa"
	return "braci"


## La polvere sotto i piedi: correndo, uno sbuffo piccolo ogni `STEP` secondi.
func _steps(dt: float) -> void:
	var p: Player = m.player
	if not p.on_floor or absf(p.vel.x) < 50.0:
		_step_t = 0.0
		return
	_step_t -= dt
	if _step_t > 0.0:
		return
	_step_t = STEP
	_kick(p.position + Vector2(-signf(p.vel.x) * 3.0, Player.HALF.y), 4)


func _on_landed(tiles: float) -> void:
	if tiles >= 1.5 and bool(Settings.v("particelle")):
		_kick(m.player.position + Vector2(0, Player.HALF.y), mini(6 + int(tiles * 1.5), 16))


## Qualche granello del terreno sotto un punto, che salta e ricade.
func _kick(feet: Vector2, n: int) -> void:
	var c: Vector2i = ((feet + Vector2(0, 2)) / 16.0).floor()
	var t: int = m.world.tile(c.x, c.y)
	if t <= 0:
		return
	var cols := TileDefs.dust_colors(t)
	if cols.size() < 3:
		return
	var p := CPUParticles2D.new()
	p.position = feet
	p.one_shot = true
	p.explosiveness = 1.0
	p.amount = n
	p.lifetime = 0.45
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(4, 1)
	p.direction = Vector2(0, -1)
	p.spread = 70.0
	p.gravity = Vector2(0, 300)
	p.initial_velocity_min = 20.0
	p.initial_velocity_max = 55.0
	p.scale_amount_min = 1.0
	p.scale_amount_max = 2.0
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 1.0])
	g.colors = PackedColorArray([cols[1], Color(cols[2], 0.0)])
	p.color_ramp = g
	m.fx.add_child(p)
	p.emitting = true
	p.finished.connect(p.queue_free)
