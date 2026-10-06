class_name Styles
extends Node
## Gli stili del Giardiniere in partita (Roadmap 40, voce 367; dati in `StylesData`). Le risorse di ogni stile e le armi
## dei quattro stili nuovi (lancio, canto, cura, radice), che tenendo premuto il clic sinistro tirano verso il mouse come
## le verghe; la mischia (lo Slancio) passa da `Combat._melee`, la distanza dalle munizioni, la Linfa da `Spells`,
## l'evocazione da `Companions`. I colpi di questo modulo portano "style" e li riconosce `Combat.on_shot` (`on_hit`).
## Le piante da combattimento (semi-torre) stanno in `StyleTurrets`.

var m: Node2D
var auto_aim := Vector2.INF              # per le prove
var auto_fire := false
var fired := 0                           # colpi tirati (per le prove)
var slancio := 0                         # mischia
var mira_ready := false                  # lancio
var ispirazione := 0                     # canto
var song := ""                           # il canto in corso (id dello strumento)
var song_t := 0.0
var rugiada := 0                         # cura: colpi verso la prossima onda
var turrets: StyleTurrets
var _t := 0.0
var _still := 0.0
var _regen_acc := 0.0
var _label: Label


func setup(main: Node2D) -> void:
	m = main
	turrets = StyleTurrets.new()
	turrets.styles = self
	m.fx.add_child(turrets)
	_label = Label.new()
	_label.add_theme_font_size_override("font_size", 13)
	_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_label.add_theme_constant_override("outline_size", 4)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	m.hud.add_child(_label)


func _process(dt: float) -> void:
	_t = maxf(_t - dt, 0.0)
	if not m.built:
		return
	_songs(dt)
	var item: Dictionary = m.hud.current()
	var it := ItemsData.get_item(String(item["id"]))
	var style := StylesData.of_item(it)
	# la Mira ferma: si carica stando fermi a terra senza tirare
	if style == "lancio":
		if m.player.vel.length() < 8.0 and _t <= 0.0:
			_still += dt
			if _still >= StylesData.MIRA_T and not mira_ready:
				mira_ready = true
				Fx.puff(m.fx, m.player.position + Vector2(0, -20), Color(0.8, 1.6, 2.0))
		else:
			_still = 0.0
	_show(style, it)
	var use := String(item["use"])
	if not use in ["scaglia", "suona", "risana", "pianta"]:
		return
	var active: bool = m.actions.enabled and not m.hud.is_open()
	if not (auto_fire or (active and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT))):
		return
	var target: Vector2 = auto_aim if auto_aim != Vector2.INF else m.fx.get_global_mouse_position()
	var from: Vector2 = m.player.position + Vector2(0, -6)
	var d := target - from
	m.player.facing = 1 if d.x >= 0.0 else -1
	m.player.aim = atan2(absf(d.x), d.y)
	if _t > 0.0:
		return
	var st := Gear.stats(item)
	_t = 1.0 / (maxf(float(st["speed"]), 0.1) * m.combat.spd_mult)
	var dmg := roundi(float(st["damage"]) * m.combat._boon())
	var opts := {"elem": String(st["elem"]), "pierce": int(st.get("pierce", 0)), "style": style}
	var go := Combat.gesture_opts(opts, String(st["mat"]))      # voce 356: il gesto del materiale
	var o: Dictionary = go[0]
	var sp := float(go[1])
	var form := String(it.get("form", ""))
	match use:
		"scaglia":
			_throw(form, from, d, dmg, o, sp)
		"suona":
			_play(form, from, d, dmg, o, sp, st)
		"risana":
			o["look"] = "polline"
			o["homing"] = maxf(float(o.get("homing", 0.0)), 2.0)
			m.shots.fire(from + d.normalized() * 8.0, d.normalized() * 340.0 * sp, 0.0, dmg, true, 1.0, o)
		"pianta":
			if form == "semetorre":
				turrets.plant(target, dmg, o, int(MaterialsData.get_mat(String(st["mat"])).get("tier", 1)), String(item["id"]))
			else:
				o["look"] = "spora_amica"
				o["boom"] = [3.0, 1.0]
				o["homing"] = maxf(float(o.get("homing", 0.0)), 1.5)
				var v := d.normalized() * 300.0 * sp
				v.y -= 120.0
				m.shots.fire(from + d.normalized() * 8.0, v, 380.0, dmg, true, 2.0, o)
	fired += 1
	m.sfx.play("tira", from)


## Lancio: tre dischi a ventaglio o una girandola che torna. Con la Mira ferma il lancio è perfetto.
func _throw(form: String, from: Vector2, d: Vector2, dmg: int, o: Dictionary, sp: float) -> void:
	if mira_ready:
		mira_ready = false
		_still = 0.0
		dmg = roundi(dmg * StylesData.MIRA_MULT)
		o["pierce"] = int(o.get("pierce", 0)) + StylesData.MIRA_PIERCE
		Fx.float_text(m.fx, m.player.position + Vector2(0, -26), "Perfetto!", Color("#8ad8ff"))
	o["look"] = "scheggia"
	if form == "girandola":
		o["ret"] = maxf(float(o.get("ret", 0.0)), 0.45)
		o["pierce"] = int(o.get("pierce", 0)) + 2
		m.shots.fire(from + d.normalized() * 8.0, d.normalized() * 320.0 * sp, 0.0, dmg, true, 2.0, o)
		return
	for k in 3:
		m.shots.fire(from + d.normalized() * 8.0, d.normalized().rotated((k - 1) * 0.12) * 420.0 * sp, 60.0, dmg, true, 1.0, o)


## Canto: le note della buccina attraversano, quelle del flauto inseguono, il tamburo rimbomba attorno.
func _play(form: String, from: Vector2, d: Vector2, dmg: int, o: Dictionary, sp: float, st: Dictionary) -> void:
	match form:
		"buccina":
			o["look"] = "polline"
			o["pierce"] = int(o.get("pierce", 0)) + 3
			o["wave"] = maxf(float(o.get("wave", 0.0)), 8.0)
			m.shots.fire(from + d.normalized() * 8.0, d.normalized() * 300.0 * sp, 0.0, dmg, true, 1.5, o)
		"flauto":
			o["look"] = "iride"
			o["homing"] = maxf(float(o.get("homing", 0.0)), 3.0)
			m.shots.fire(from + d.normalized() * 8.0, d.normalized() * 360.0 * sp, 0.0, dmg, true, 0.5, o)
		_:
			# il tamburo: un colpo tutto attorno, entro quattro tessere
			Fx.puff(m.fx, m.player.position + Vector2(0, 8), Color(1.4, 1.2, 0.8))
			if m.get("juice") != null:
				m.juice.shake(1.5, 0.08)
			for c in m.fauna.list.duplicate():
				if is_instance_valid(c) and c.tame == null and c.position.distance_to(m.player.position) < 4.0 * 16.0:
					m.combat._strike(c, dmg, m.player.position.x, float(st["knockback"]) / 3.0, String(st["elem"]))
					note_hit("canto", c, dmg)


## Un colpo di uno stile ha preso una creatura (da `Combat.on_shot` e dal tamburo).
func note_hit(style: String, _c: Creature, dmg: int) -> void:
	match style:
		"canto":
			if song == "":
				ispirazione += 1
				if ispirazione >= StylesData.ISPIRAZIONE_MAX:
					_start_song(String(ItemsData.get_item(String(m.hud.current()["id"])).get("form", "buccina")))
		"cura":
			m.vitals.heal(maxi(roundi(dmg * StylesData.HEAL_ON_HIT), 1))
			rugiada += 1
			if rugiada >= StylesData.RUGIADA_EVERY:
				rugiada = 0
				_heal_all(StylesData.RUGIADA_HEAL)
				Fx.puff(m.fx, m.player.position, Color(0.9, 1.8, 1.0))


func _start_song(form: String) -> void:
	if not StylesData.SONGS.has(form):
		form = "buccina"
	ispirazione = 0
	song = form
	var sd: Dictionary = StylesData.SONGS[form]
	song_t = float(sd["t"])
	if sd.has("heal"):
		_heal_all(float(sd["heal"]))
	if sd.has("defense"):
		var md := MaterialsData.get_mat(String(ItemsData.get_item(String(m.hud.current()["id"])).get("mat", "radicite")))
		m.vitals.song_scorza = roundi(float(md.get("tenacia", 1.0)) * 10.0 * float(sd["defense"]))
	m.depth_watch.banner.show_stratum(String(sd["name"]), String(sd["desc"]), Color("#ffd08a"))
	m.sfx.play("dono")


func _songs(dt: float) -> void:
	if song == "":
		return
	song_t -= dt
	var sd: Dictionary = StylesData.SONGS[song]
	if sd.has("regen"):
		_regen_acc += float(m.vitals.hp_max) * 0.01 * (float(sd["regen"]) - 1.0) * dt * 2.0
		if _regen_acc >= 1.0:
			m.vitals.heal(int(_regen_acc))
			_regen_acc -= floorf(_regen_acc)
	if song_t <= 0.0:
		song = ""
		m.vitals.song_scorza = 0


## Il danno in più del canto in corso (lo legge `Combat._boon`).
func dmg_now() -> float:
	return float(StylesData.SONGS[song].get("damage", 1.0)) if song != "" else 1.0


## Cura il Germogliato e i compagni in campo di una parte della loro Vita massima.
func _heal_all(frac: float) -> void:
	m.vitals.heal(maxi(roundi(m.vitals.hp_max * frac), 1))
	if m.get("herd") != null:
		for c in m.herd.beasts:
			if is_instance_valid(c) and c.hp > 0:
				c.hp = mini(c.hp + maxi(roundi(c.hp_max * frac), 1), c.hp_max)


## Mischia: un giro che ha colpito qualcosa carica lo Slancio; pieno, il giro dopo vale doppio (lo chiede `Combat`).
func melee_mult() -> float:
	return StylesData.SLANCIO_MULT if slancio >= StylesData.SLANCIO_MAX else 1.0


func melee_cycle(hit: bool, dmg: int) -> void:
	if slancio >= StylesData.SLANCIO_MAX:
		slancio = 0
		if hit:
			# la scossa del colpo pieno: metà del danno a chi sta attorno
			Fx.puff(m.fx, m.player.position + Vector2(m.player.facing * 16, 0), Color(1.8, 1.2, 0.8))
			for c in m.fauna.list.duplicate():
				if is_instance_valid(c) and c.tame == null and c.position.distance_to(m.player.position) < StylesData.SLANCIO_SHAKE * 16.0:
					if c.take_hit(maxi(dmg / 2, 1), m.player.position.x, 1.0):
						m.fauna.kill(c)
		return
	if hit:
		slancio += 1


## La riga della risorsa sopra la barra rapida.
func _show(style: String, it: Dictionary) -> void:
	var t := ""
	match style:
		"mischia":
			t = "Slancio  " + "●".repeat(slancio) + "○".repeat(StylesData.SLANCIO_MAX - slancio)
		"lancio":
			t = "Mira ferma: pronta" if mira_ready else "Mira ferma: resta fermo un attimo"
		"canto":
			t = ("%s · %d s" % [StylesData.SONGS[song]["name"], ceili(song_t)]) if song != "" \
				else "Ispirazione %d/%d" % [ispirazione, StylesData.ISPIRAZIONE_MAX]
		"cura":
			t = "Rugiada %d/%d" % [rugiada, StylesData.RUGIADA_EVERY]
		"radice":
			t = "Piante sul campo %d/%d" % [turrets.count(), turrets.cap(int(it.get("tier", 1)))] if String(it.get("form", "")) == "semetorre" else ""
	if song != "" and style != "canto":
		t = (t + "   " if t != "" else "") + "%s · %d s" % [StylesData.SONGS[song]["name"], ceili(song_t)]
	_label.text = t
	_label.visible = t != ""
	if _label.visible:
		var vs := m.get_viewport_rect().size
		_label.position = Vector2(vs.x * 0.5 - _label.size.x * 0.5, vs.y - 92.0)
