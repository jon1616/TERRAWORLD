extends SceneTree
## Prova dei salvataggi, senza finestra: genera un mondo, lo modifica, lo salva, lo ricarica e controlla che sia
## identico; poi rovina il file principale e verifica che si recuperi dalla copia di sicurezza. Stampa tempi e pesi.
##   Godot_console.exe --headless --path . --script res://tools/prova_salvataggi.gd

var errors := 0


func _init() -> void:
	SavePaths.root = "user://prove_salvataggi"
	var w := World.new()
	var t0 := Time.get_ticks_msec()
	WorldGen.generate(w, 777)
	var t_gen := Time.get_ticks_msec() - t0
	# modifiche: un buco, una torcia nuova
	for x in range(w.spawn.x - 3, w.spawn.x + 4):
		w.set_tile(x, w.spawn.y + 3, TileDefs.AIR)
	w.add_torch(w.spawn + Vector2i(5, 0))
	var id := "mondo_prova_salvataggi"
	t0 = Time.get_ticks_msec()
	var err := WorldSave.save(w, id, {"nome": "Prova"})
	var t_save := Time.get_ticks_msec() - t0
	_check(err == OK, "salvataggio riuscito")
	var size := FileAccess.get_file_as_bytes(WorldSave.dir_of(id) + "/mondo.bin").size()
	t0 = Time.get_ticks_msec()
	var l := WorldSave.load_world(id)
	var t_load := Time.get_ticks_msec() - t0
	_check(l != null, "caricamento riuscito")
	if l:
		_same(w, l)
	# secondo salvataggio (crea la copia di sicurezza), poi si rovina il file principale
	WorldSave.save(w, id, {"nome": "Prova"})
	var path := ProjectSettings.globalize_path(WorldSave.dir_of(id) + "/mondo.bin")
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string("rovinato")
	f.close()
	var r := WorldSave.load_world(id)
	_check(r != null, "recupero dalla copia di sicurezza")
	if r:
		_same(w, r)
	# personaggio
	var c := Character.create("Prova Personaggio")
	c.play_time = 123.5
	c.hotbar = 4
	_check(c.save() == OK, "salvataggio personaggio")
	var c2 := Character.load_id(c.id)
	_check(c2 != null and c2.name == c.name and c2.hotbar == 4 and is_equal_approx(c2.play_time, 123.5), "personaggio identico")
	print("generazione %d ms · salvataggio %d ms · caricamento %d ms · file %.2f MB" % [t_gen, t_save, t_load, size / 1048576.0])
	print("ESITO: %s" % ("tutto a posto" if errors == 0 else "%d errori" % errors))
	quit()


func _same(a: World, b: World) -> void:
	_check(a.w == b.w and a.h == b.h, "dimensioni")
	_check(a.tiles == b.tiles, "tessere identiche")
	_check(a.walls == b.walls, "pareti identiche")
	_check(a.decor == b.decor, "decorazioni identiche")
	_check(a.surface == b.surface, "superficie identica")
	_check(a.torches.size() == b.torches.size(), "torce (%d)" % a.torches.size())
	_check(a.spawn == b.spawn and a.world_seed == b.world_seed, "partenza e seme")
	var ta := 0
	var tb := 0
	for k in a.trees:
		ta += (a.trees[k] as Array).size()
	for k in b.trees:
		tb += (b.trees[k] as Array).size()
	_check(ta == tb, "alberi (%d)" % ta)


func _check(ok: bool, what: String) -> void:
	if not ok:
		errors += 1
		print("ERRORE: ", what)
