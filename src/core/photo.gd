class_name Photo
extends RefCounted
## Foto della finestra con i colori dello schermo (voce 267). Con `hdr_2d` l'immagine della finestra è lineare e, salvata
## così, veniva molto più scura di ciò che si vede (lo sfondo del menu 66,146,149 diventava 13,73,76). La conversione
## pixel per pixel costava un secondo a foto: qui la fa la scheda video, con uno shader su una finestra invisibile che
## rilegge l'immagine del gioco. Le usano le prove (`TestKit.save`) e le foto del menu.

const SHADER := """
shader_type canvas_item;
render_mode unshaded;
void fragment() {
	vec3 c = clamp(texture(TEXTURE, UV).rgb, 0.0, 1.0);
	vec3 lo = c * 12.92;
	vec3 hi = 1.055 * pow(c, vec3(1.0 / 2.4)) - 0.055;
	COLOR = vec4(mix(lo, hi, step(vec3(0.0031308), c)), 1.0);
}
"""

static var _sv: SubViewport
static var _rect: Sprite2D


## L'immagine della finestra `vp` in sRGB, come la si vede. Aspetta due fotogrammi: si chiama con `await`.
static func take(vp: Viewport) -> Image:
	# l'immagine lineare (a virgola mobile) diventa una texture da rileggere: la finestra invisibile non può leggere
	# direttamente quella della finestra che la contiene (usciva tutta grigia)
	var raw := vp.get_texture().get_image()
	var tex := ImageTexture.create_from_image(raw)
	var size := raw.get_size()
	if _sv == null or not is_instance_valid(_sv) or _sv.get_parent() == null:
		_sv = SubViewport.new()
		_sv.transparent_bg = false
		_sv.use_hdr_2d = false
		_sv.disable_3d = true
		_rect = Sprite2D.new()
		_rect.centered = false
		var mat := ShaderMaterial.new()
		var sh := Shader.new()
		sh.code = SHADER
		mat.shader = sh
		_rect.material = mat
		_sv.add_child(_rect)
		vp.add_child(_sv)
	_sv.size = size
	_rect.texture = tex
	_sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	# la finestra invisibile si disegna con i fotogrammi veri (force_draw non la aggiorna)
	await vp.get_tree().process_frame
	await vp.get_tree().process_frame
	var out := _sv.get_texture().get_image()
	_sv.render_target_update_mode = SubViewport.UPDATE_DISABLED
	return out
