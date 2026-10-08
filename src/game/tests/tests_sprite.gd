class_name TestsSprite
extends RefCounted
## La prova veloce delle pose di una creatura (8 ott 2026, richiesta dell'utente: «centinaia di creature da fare, il
## test è lungo»). Su un tratto spianato vicino alla partenza fa comparire subito la creatura, mostra ogni sua posa una
## alla volta (ferma, con il nome sopra) e ne fa un foglio, poi la lascia vivere qualche secondo e la fotografa dal vivo.
## Controlla anche che ogni stato (salto, carica, colpo, furia…) dia una posa che esiste.
##   tools/sprite.sh capo_cinghiale            (una o più creature, separate da virgole; senza nome: tutte le pose)
## Risultato: prove/sprite/<id>.png (il foglio delle pose) e prove/sprite/<id>_vivo.png.

var kit: TestKit
var m: Node2D


func _init(k: TestKit) -> void:
	kit = k
	m = k.m


func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://prove/sprite"))
	var ids := _ids()
	print("pose da guardare: %s" % ", ".join(ids))
	m.combat.god = true
	var hud_was: bool = m.hud.visible
	m.hud.visible = false                       # l'interfaccia copriva chi vola (sta più in alto sullo schermo)
	var mk: Node = m.filo.get("_marker") if m.get("filo") != null else null
	if mk is CanvasItem:
		(mk as CanvasItem).visible = false        # il rombo del filo copriva le creature nelle foto
		(mk as Node).set_process(false)
	var w: World = kit.world
	var c := kit.flat_spot(w.spawn + Vector2i(20, 0), 10)
	if c.x < 0:
		c = Vector2i(w.spawn.x + 20, w.surface[w.spawn.x + 20] - 1)
	kit.flatten(c, 10)
	var rara := _arg("--rara=")
	for id in ids:
		if rara.begins_with("colpo:"):
			await _flash(id, c, rara.trim_prefix("colpo:"))
		elif rara != "":
			await _halo(id, c, rara)
		else:
			await _one(id, c)
	m.combat.god = false
	m.hud.visible = hud_was


func _arg(k: String) -> String:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with(k):
			return arg.trim_prefix(k)
	return ""


## Con `--rara=<grado>` (8 ott 2026): la creatura rara di quel grado (senza tratti, che la cambierebbero), l'alone in
## quattro momenti del ciclo di giorno e altri quattro di notte → prove/sprite/<id>_<grado>.png.
func _halo(id: String, c: Vector2i, rara: String) -> void:
	m.fauna.clear()
	m.snap_to(c + Vector2i(-6, 0))
	await kit.seconds(0.3)
	var cd: Dictionary = CreaturesData.get_data(id)
	var lift := 3 * 16 if cd.get("fly", false) else 0
	var cr: Creature = m.fauna.add(id, Vector2((c.x + 2) * 16 + 8, (c.y - 2) * 16 - lift))
	if cr == null:
		print("ATTENZIONE: %s non compare" % id)
		return
	cr.ancient = Ancient.new()
	cr.ancient.apply(cr, rara, [])
	await kit.seconds(1.0)
	var t0: float = m.day.time
	var shots: Array[Image] = []
	for night in [false, true]:
		m.day.time = 0.95 if night else 0.5
		m.day.apply(true)
		for k in 4:
			await kit.seconds(0.27)
			if not is_instance_valid(cr):
				break
			cr.set_process(false)
			shots.append(await _crop(cr, 1.5))
			cr.set_process(true)
	m.day.time = t0
	m.day.apply(true)
	_sheet(shots, "res://prove/sprite/%s_%s.png" % [id, rara])
	print("%s %s: alone %s → prove/sprite/%s_%s.png" % [id, rara,
		"dipinto" if cr.ancient._halo != null else "di prima (contorno)", id, rara])
	m.fauna.clear()


## Con `--rara=colpo:<elemento>` (8 ott 2026): lo scoppio del colpo sulla creatura, sei momenti di un colpo, di
## giorno e di notte → prove/sprite/<id>_colpo_<elemento>.png («fisico» = senza elemento).
func _flash(id: String, c: Vector2i, elem: String) -> void:
	m.fauna.clear()
	m.snap_to(c + Vector2i(-6, 0))
	await kit.seconds(0.3)
	var cd: Dictionary = CreaturesData.get_data(id)
	var lift := 3 * 16 if cd.get("fly", false) else 0
	var cr: Creature = m.fauna.add(id, Vector2((c.x + 2) * 16 + 8, (c.y - 2) * 16 - lift))
	if cr == null:
		print("ATTENZIONE: %s non compare" % id)
		return
	await kit.seconds(0.8)
	cr.set_process(false)
	var e := "" if elem == "fisico" else elem
	var t0: float = m.day.time
	var shots: Array[Image] = []
	for night in [false, true]:
		m.day.time = 0.95 if night else 0.5
		m.day.apply(true)
		await kit.seconds(0.2)
		ImpactFx.hit(m.fx, cr.position, e, cr.half.y * 2.0)
		for k in 6:
			shots.append(await _crop(cr, 1.2))
			await kit.seconds(0.035)
	m.day.time = t0
	m.day.apply(true)
	_sheet(shots, "res://prove/sprite/%s_colpo_%s.png" % [id, elem])
	print("%s colpo %s: %s → prove/sprite/%s_colpo_%s.png" % [id, elem,
		"dipinto" if not Halo.frames_of("colpo_" + elem).is_empty() else "solo scintille", id, elem])
	m.fauna.clear()


## Le creature da guardare: quelle di `--creatura=`, altrimenti una per ogni riga di `CreaturePosesData`.
func _ids() -> Array:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--creatura="):
			return Array(arg.trim_prefix("--creatura=").split(",", false))
	var out := []
	for key in CreaturePosesData.POSES:
		if CreaturesData.CREATURES.has(key):
			out.append(key)
			continue
		for cid in CreaturesData.CREATURES:
			var art: Array = CreaturesData.CREATURES[cid].get("art", [])
			if art.size() == 2 and String(art[0]) == key and int(art[1]) == 0:
				out.append(cid)
				break
	return out


func _one(id: String, c: Vector2i) -> void:
	m.fauna.clear()
	m.snap_to(c + Vector2i(-6, 0))
	await kit.seconds(0.3)
	var cd: Dictionary = CreaturesData.get_data(id)
	var lift := 3 * 16 if cd.get("fly", false) else 0
	var cr: Creature = m.fauna.add(id, Vector2((c.x + 2) * 16 + 8, (c.y - 2) * 16 - lift))
	if cr == null:
		print("ATTENZIONE: %s non compare" % id)
		return
	if cr._poses.is_empty():
		print("ATTENZIONE: %s non ha pose disegnate (manca la riga in CreaturePosesData o i file in arte/creature)" % id)
	await kit.seconds(0.6)                      # che tocchi terra (chi cammina: finché non appoggia, al più 3 s)
	var waited := 0.0
	while not cd.get("fly", false) and is_instance_valid(cr) and not cr.on_floor and waited < 3.0:
		await kit.seconds(0.1)
		waited += 0.1
	_check_states(cr, id)
	# ogni posa, ferma, con il suo nome sopra
	cr.set_process(false)
	cr.facing = 1
	for ch in cr.get_children():
		if ch is TeleMark:
			(ch as CanvasItem).visible = false   # il «!» acceso dalla prova degli stati copriva la creatura
	var label := Label.new()
	label.add_theme_font_size_override("font_size", 8)
	label.add_theme_color_override("font_color", Color("#ffe8a0"))
	label.add_theme_constant_override("outline_size", 3)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	cr.add_child(label)
	var shots: Array[Image] = []
	var names: Array = (cr._poses.get("poses", {"fermo": [0]}) as Dictionary).keys() if not cr._poses.is_empty() \
		else ["fermo"]
	for nm in names:
		var list: Array = cr._poses["poses"][nm] if not cr._poses.is_empty() else [0]
		var fps: float = float((cr._poses.get("fps", {}) as Dictionary).get(nm, 8.0))
		var seen_f := {}
		var uniq := {}
		for f in list:
			uniq[f] = true
		for k in list.size():
			if seen_f.has(list[k]):
				continue                              # un fotogramma ripetuto nel ciclo si fotografa una volta
			seen_f[list[k]] = true
			if not cr._poses.is_empty():
				cr.force_pose = String(nm)
				cr._pose = String(nm)
				cr._pose_t = (k + 0.5) / fps
				cr._hurt_t = 0.0
				cr._animate(0.0)
			label.text = "%s %d/%d" % [nm, seen_f.size(), uniq.size()] if uniq.size() > 1 else String(nm)
			label.position = Vector2(-label.get_minimum_size().x / 2.0, -cr.half.y - 34.0)
			shots.append(await _crop(cr))
	label.queue_free()
	_sheet(shots, "res://prove/sprite/%s.png" % id)
	print("%s: %d fotogrammi in %d pose → prove/sprite/%s.png" % [id, shots.size(), names.size(), id])
	# dal vivo: la creatura fa ciò che fa, il Germogliato le sta davanti
	cr.force_pose = ""
	cr.set_process(true)
	await kit.seconds(2.5)
	if is_instance_valid(cr):
		var img: Image = await Photo.take(m.get_viewport())
		img.save_png(ProjectSettings.globalize_path("res://prove/sprite/%s_vivo.png" % id))
		print("%s dal vivo: posa «%s»" % [id, cr._pose])
	m.fauna.clear()


## Ogni stato deve dare una posa che esiste (i ripieghi di `Creature.POSE_FALLBACK` compresi).
func _check_states(cr: Creature, id: String) -> void:
	if cr._poses.is_empty():
		return
	var n: int = cr._frames.size()
	var seen := {}
	var bad := []
	# [a terra, velocità, crouch, colpita, «!», busy, furia]; con le pose della furia, tutto di nuovo infuriata
	var states := [[true, Vector2.ZERO, 0.0, 0.0, 0.0, false, false], [true, Vector2(cr.speed * 0.8, 0), 0.0, 0.0, 0.0, false, false],
			[true, Vector2(cr.speed * 1.3, 0), 0.0, 0.0, 0.0, false, false], [false, Vector2(0, -200), 0.0, 0.0, 0.0, false, false],
			[false, Vector2(0, 200), 0.0, 0.0, 0.0, false, false], [true, Vector2.ZERO, 0.6, 0.0, 0.0, false, false],
			[true, Vector2.ZERO, -0.6, 0.0, 0.0, false, false], [true, Vector2.ZERO, 0.0, 0.3, 0.0, false, false],
			[true, Vector2.ZERO, 0.0, 0.0, 0.4, true, false], [true, Vector2.ZERO, 0.0, 0.0, 0.4, false, false],
			[true, Vector2(cr.speed * 2.0, 0), 0.0, 0.0, 0.0, true, false]]
	if (cr._poses["poses"] as Dictionary).keys().any(func(k: Variant) -> bool: return String(k).begins_with("furia_")):
		for st in states.duplicate():
			var e: Array = (st as Array).duplicate()
			e[6] = true
			states.append(e)
	for st in states:
		cr.on_floor = st[0]
		cr.vel = st[1]
		cr.crouch = st[2]
		cr._hurt_t = st[3]
		cr.tele = st[4]
		cr.busy = st[5]
		cr.enraged = st[6]
		var f := cr._pose_frame(0.05)
		seen[cr._pose] = true
		if f < 0 or f >= n:
			bad.append("fotogramma %d su %d" % [f, n])
	# l'allerta: ferma, che ha sentito qualcosa
	cr.on_floor = true
	cr.vel = Vector2.ZERO
	var was_state: String = cr.mind.state
	cr.mind.state = Mind.ALERT
	cr._pose_frame(0.05)
	seen[cr._pose] = true
	cr.mind.state = was_state
	cr.vel = Vector2.ZERO
	cr.crouch = 0.0
	cr._hurt_t = 0.0
	cr.tele = 0.0
	cr.busy = false
	cr.enraged = false
	var unused := []
	for nm in cr._poses["poses"]:
		if not seen.has(nm):
			unused.append(nm)
	print("%s: pose usate %s%s" % [id, seen.keys(), "" if unused.is_empty() else ", mai scelte %s" % [unused]])
	if not bad.is_empty():
		print("ATTENZIONE: %s: %s" % [id, bad])


## Un ritaglio della finestra attorno alla creatura (con il nome della posa sopra).
func _crop(cr: Creature, wide := 1.0) -> Image:
	await kit.frames(3)
	RenderingServer.force_draw(false)
	var img: Image = await Photo.take(m.get_viewport())
	var p: Vector2 = cr.get_global_transform_with_canvas().origin
	var z: float = (m.cam as Camera2D).zoom.x
	var fw: float = (cr._frames[0] as Texture2D).get_width() * z
	var fh: float = (cr._frames[0] as Texture2D).get_height() * z
	var half_w := int(maxf(fw * 0.75 * wide, 70.0 * wide))
	var top := fh * wide + 40.0 * z
	var r := Rect2i(int(p.x) - half_w, int(p.y - top), half_w * 2, int(top + fh * 0.6 + 10.0 * z))
	r = r.intersection(Rect2i(Vector2i.ZERO, img.get_size()))
	return img.get_region(r)


func _sheet(shots: Array[Image], path: String) -> void:
	if shots.is_empty():
		return
	var cw := 0
	var ch := 0
	for s in shots:
		cw = maxi(cw, s.get_width())
		ch = maxi(ch, s.get_height())
	# le creature piccole: il foglio raddoppiato, a pixel pieni (si vede ogni pixel del disegno)
	if cw < 220:
		for s in shots:
			s.resize(s.get_width() * 2, s.get_height() * 2, Image.INTERPOLATE_NEAREST)
		cw *= 2
		ch *= 2
	var cols := mini(shots.size(), 6)
	var rows := ceili(shots.size() / float(cols))
	var out := Image.create_empty(cols * (cw + 6) + 6, rows * (ch + 6) + 6, false, Image.FORMAT_RGBA8)
	out.fill(Color("#141019"))
	for i in shots.size():
		var s := shots[i]
		s.convert(Image.FORMAT_RGBA8)
		out.blit_rect(s, Rect2i(Vector2i.ZERO, s.get_size()), Vector2i(6 + (i % cols) * (cw + 6), 6 + (i / cols) * (ch + 6)))
	out.save_png(ProjectSettings.globalize_path(path))
