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
	var mk: Node = m.filo.get("_marker") if m.get("filo") != null else null
	if mk is CanvasItem:
		(mk as CanvasItem).visible = false        # il rombo del filo copriva le creature nelle foto
		(mk as Node).set_process(false)
	var w: World = kit.world
	var c := kit.flat_spot(w.spawn + Vector2i(20, 0), 10)
	if c.x < 0:
		c = Vector2i(w.spawn.x + 20, w.surface[w.spawn.x + 20] - 1)
	kit.flatten(c, 10)
	for id in ids:
		await _one(id, c)
	m.combat.god = false


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
	await kit.seconds(0.6)                      # che tocchi terra
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
func _crop(cr: Creature) -> Image:
	await kit.frames(3)
	RenderingServer.force_draw(false)
	var img: Image = await Photo.take(m.get_viewport())
	var p: Vector2 = cr.get_global_transform_with_canvas().origin
	var z: float = (m.cam as Camera2D).zoom.x
	var fw: float = (cr._frames[0] as Texture2D).get_width() * z
	var fh: float = (cr._frames[0] as Texture2D).get_height() * z
	var half_w := int(maxf(fw * 0.75, 70.0))
	var r := Rect2i(int(p.x) - half_w, int(p.y - fh - 40.0 * z), half_w * 2, int(fh * 1.6 + 50.0 * z))
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
