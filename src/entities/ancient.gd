class_name Ancient
extends RefCounted
## Ciò che rende una creatura **antica** o **ancestrale** (voce 20b, dati in `AncientData`): statistiche più alte,
## tratti propri, un'aura del colore della rarità, il nome e i tratti scritti sopra, la barra della Vita sempre in
## vista. Gli effetti che riguardano solo lei (rigenerarsi, chiamare aiuto, svanire) li fa `tick`; quelli che toccano
## il Germogliato (veleno, spine, scoppio) li legge `Combat`.

var rarity := ""
var traits: Array = []
var size := 1.0
var _summon_t := 6.0
var life := -1.0                       # le iridate svaniscono quando arriva a zero
var gone := false                      # svanita: la fauna la toglie senza bottino
var _hue := 0.0
var _label: Label
var _aura: Sprite2D
var _halo: Halo                        # 8 ott 2026: l'alone animato del grado (se ha il disegno), al posto del contorno


## Rende rara una creatura appena nata. `mult` = forza della zona (pericolo × vigore) già applicata a Vita e danno.
func apply(c: Creature, r: String, tr: Array) -> void:
	rarity = r
	traits = tr
	var rd: Dictionary = AncientData.RARITIES[r]
	var hp_mult: float = rd["hp"]
	var dmg_mult: float = rd["damage"]
	size = float(rd["scale"])
	for t in traits:
		var td: Dictionary = AncientData.TRAITS[t]
		hp_mult *= float(td.get("hp", 1.0))
		dmg_mult *= float(td.get("damage", 1.0))
		size *= float(td.get("size", 1.0))
		c.defense += int(td.get("defense", 0))
		c.knock = maxf(c.knock, float(td.get("knock", 0.0)))
		c.speed *= float(td.get("speed", 1.0))
	c.hp_max = int(round(c.hp_max * hp_mult))
	c.hp = c.hp_max
	c.damage = int(round(c.damage * dmg_mult))
	# più grande anche nel corpo: si alza un poco perché i piedi restino sul terreno
	var grow := c.half * (size - 1.0)
	c.half *= size
	c.position.y -= grow.y
	# l'aura: un contorno acceso attorno alla figura, sopra il buio (si vede anche nelle grotte senza coprire la
	# creatura: la prima versione era una copia colorata sopra e la nascondeva)
	_aura = Sprite2D.new()
	_halo = Halo.make("alone_" + r)
	if _halo != null:
		# l'alone dipinto, sommato come luce sopra il buio (z 25 come il contorno) e colorato con la rarità
		_halo.modulate = Color(rd["aura"]) * 0.75
		_halo.z_as_relative = false
		_halo.z_index = 25
		c.add_child(_halo)
		_halo.step(c._spr, 0.0)
	_aura.texture = ring(c._spr.texture)
	_aura.offset = c._spr.offset
	_aura.position = c._spr.position
	_aura.modulate = Color(rd["aura"]) * 1.6
	_aura.z_as_relative = false
	_aura.z_index = 25
	c.add_child(_aura)
	# nome e tratti sopra la testa, e la Vita sempre in vista
	_label = Label.new()
	var names := []
	for t in traits:
		names.append(String(AncientData.TRAITS[t]["name"]))
	_label.text = String(rd["short"]) if names.is_empty() else "%s · %s" % [String(rd["short"]), ", ".join(names)]
	life = float(rd.get("life", -1.0))
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.size = Vector2(160, 12)
	_label.position = Vector2(-80, -c.half.y - 24)
	UiFonts.world(_label, 7, Color(rd["aura"]).lightened(0.2))      # (Roadmap 55) nitido anche ingrandito
	_label.z_as_relative = false
	_label.z_index = 28
	c.add_child(_label)
	c._bar.position = Vector2(0, -c.half.y - 10)
	c._bar.set_value(1.0)
	c._bar.visible = true
	c._bar.always = true


static var _rings := {}


## Il contorno di una figura: i pixel trasparenti che toccano la figura (una volta per fotogramma, poi riusato).
## L'immagine ha la stessa misura della figura: il contorno sul bordo dell'immagine si perde, ma le figure delle
## creature hanno sempre un pixel vuoto attorno (il contorno scuro di `Px.outline`).
static func ring(tex: Texture2D) -> Texture2D:
	var key := tex.get_instance_id()
	if _rings.has(key):
		return _rings[key]
	var src := tex.get_image()
	var w := src.get_width()
	var h := src.get_height()
	var out := Image.create_empty(w, h, false, Image.FORMAT_RGBA8)
	for y in h:
		for x in w:
			if src.get_pixel(x, y).a > 0.5:
				continue
			for o in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var q: Vector2i = Vector2i(x, y) + o
				if q.x >= 0 and q.y >= 0 and q.x < w and q.y < h and src.get_pixelv(q).a > 0.5:
					out.set_pixel(x, y, Color.WHITE)
					break
	var t := ImageTexture.create_from_image(out)
	_rings[key] = t
	return t


func has(t: String) -> bool:
	return t in traits


## Un effetto numerico dei tratti (il primo che lo ha; 0 se nessuno).
func value(key: String) -> float:
	for t in traits:
		var td: Dictionary = AncientData.TRAITS[t]
		if td.has(key):
			return float(td[key])
	return 0.0


func tick(c: Creature, dt: float) -> void:
	var scale := Vector2(size, size)
	c._spr.scale *= scale
	if c._glow:
		c._glow.scale = c._spr.scale
	if _halo != null:
		_aura.visible = false
		_halo.step(c._spr, dt)
	else:
		_aura.texture = ring(c._spr.texture)
		_aura.scale = c._spr.scale
		_aura.position = c._spr.position
	# iridata: i colori cambiano di continuo; se non la si prende in tempo svanisce
	if life > 0.0:
		life -= dt
		_hue = fmod(_hue + dt * 0.35, 1.0)
		var col := Color.from_hsv(_hue, 0.5, 1.0)
		c._spr.self_modulate = col * 1.35
		_aura.modulate = Color.from_hsv(fmod(_hue + 0.5, 1.0), 0.6, 1.0) * 1.8
		if _halo != null:
			_halo.modulate = Color.from_hsv(fmod(_hue + 0.5, 1.0), 0.6, 1.0) * 1.2
		if life <= 0.0:
			gone = true
	# rigenerante: la Vita ricresce se non la si finisce
	if has("rigenerante") and c.hp < c.hp_max:
		c.regen_acc += c.hp_max * value("regen") * dt
		var k := int(c.regen_acc)
		if k > 0:
			c.regen_acc -= k
			c.hp = mini(c.hp + k, c.hp_max)
			c._bar.set_value(float(c.hp) / c.hp_max)
	# evocatrice: chiama altre creature come lei
	if has("evocatrice") and c.target and c.position.distance_to(c.target.position) < 30 * 16:
		_summon_t -= dt
		if _summon_t <= 0.0:
			_summon_t = 8.0
			if c.minions < int(value("summon")):
				c.summons.append(c.id)
	# evanescente: quasi invisibile finché non è vicina
	if has("evanescente") and c.target:
		var d := c.position.distance_to(c.target.position) / 16.0
		c.modulate.a = clampf(1.2 - d / 8.0, 0.12, 1.0)
