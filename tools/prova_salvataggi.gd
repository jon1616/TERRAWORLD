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
	# voce 41: una casella con i suoi dati (numeri interi annidati) torna identica, e non si unisce ad altre pile
	var dati := {"geni": ["cavo", "vene_ricche"], "vigore": 3, "note": {"n": [1, 2]}}
	c.bisaccia.slots[20] = {"id": "legno", "n": 1, "dati": dati}
	c.bisaccia.add("legno", 5)
	c.save()
	var c3 := Character.load_id(c.id)
	_check(c3 != null and c3.bisaccia.data_at(20) == dati and typeof(c3.bisaccia.data_at(20)["vigore"]) == TYPE_INT
		and c3.bisaccia.count_at(20) == 1, "casella con i suoi dati identica")
	c3.bisaccia.sort_bag()
	var kept := false
	for i in c3.bisaccia.slots.size():
		kept = kept or c3.bisaccia.data_at(i) == dati
	_check(kept, "riordinando la Bisaccia i dati restano alla loro casella")
	# un salvataggio di una versione più nuova non si apre (né personaggio né mondo)
	var future := c.to_dict()
	future["formato"] = SaveMigrations.CHARACTER + 1
	_check(Character.from_dict("futuro", future) == null, "personaggio di una versione più nuova rifiutato")
	WorldSave.save(w, id, {"nome": "Prova"})
	var meta := SavePaths.read_json(WorldSave.dir_of(id) + "/mondo.json")
	meta["formato"] = SaveMigrations.WORLD + 1
	SavePaths.write_json(WorldSave.dir_of(id) + "/mondo.json", meta)
	_check(WorldSave.load_world(id) == null, "mondo di una versione più nuova rifiutato")
	meta["formato"] = SaveMigrations.WORLD
	SavePaths.write_json(WorldSave.dir_of(id) + "/mondo.json", meta)
	# voce 42: un mondo salvato con il formato 1 (specie e tratti della voce 39) migra ai geni, anche nei portali
	meta["formato"] = 1
	meta["specie"] = "sporangio"
	meta["tratti"] = ["vene_ricche", "brulicante", "quieto"]
	meta["portali"] = {"10,20": {"mondo": "", "seme": 5, "ritorno": false, "specie": "brina", "tratti": ["stellato"]},
		"30,20": {"mondo": "x", "seme": 0, "ritorno": true}}
	SavePaths.write_json(WorldSave.dir_of(id) + "/mondo.json", meta)
	var mig := WorldSave.read_meta(id)
	_check(mig.get("geni", []) == ["sporangio", "vene_ricche", "brulicante"] and not mig.has("specie")
		and int(mig["formato"]) == SaveMigrations.WORLD, "mondo del formato 1 migrato ai geni: %s" % [mig.get("geni", [])])
	_check(mig["portali"]["10,20"].get("geni", []) == ["brina", "stellato"] and not mig["portali"]["30,20"].has("geni"),
		"portali migrati ai geni")
	_check(WorldSave.load_world(id) != null, "mondo migrato si apre")
	WorldSave.save(w, id, mig)
	_check(WorldSave.read_meta(id).get("geni", []) == mig["geni"], "mondo migrato risalvato identico")
	# un Seme di mondo nella Bisaccia ha il suo genoma, che resta identico salvando e ricaricando
	var c4 := Character.create("Seme")
	c4.bisaccia.add("seme_mondo_brina", 2)
	var gk := -1
	for i in c4.bisaccia.slots.size():
		if c4.bisaccia.id_at(i) == "seme_mondo_brina":
			gk = i
			break
	var g0 := c4.bisaccia.data_at(gk).duplicate(true)
	c4.save()
	var c5 := Character.load_id(c4.id)
	_check(c4.bisaccia.count("seme_mondo_brina") == 2 and c4.bisaccia.count_at(gk) == 1, "due Semi, due caselle")
	_check(Genome.surface_of(Genome.genes(g0)) == "brina" and c5.bisaccia.data_at(gk) == g0, "genoma del Seme salvato identico: %s" % [g0])
	Character.delete(c4.id)
	# cancellare: il personaggio (con la sua copia di sicurezza) e il mondo spariscono dagli elenchi
	c.save()
	Character.delete(c.id)
	var still := Character.list().any(func(x: Character) -> bool: return x.id == c.id)
	_check(not still and not FileAccess.file_exists(SavePaths.characters_dir() + "/" + c.id + ".json.bak"), "personaggio cancellato")
	WorldSave.delete(id)
	_check(WorldSave.read_meta(id).is_empty() and not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(WorldSave.dir_of(id))), "mondo cancellato")
	_nested(w)
	print("generazione %d ms · salvataggio %d ms · caricamento %d ms · file %.2f MB" % [t_gen, t_save, t_load, size / 1048576.0])
	print("ESITO: %s" % ("tutto a posto" if errors == 0 else "%d errori" % errors))
	quit()


## 28 set 2026: i mondi nati dai Semi si salvano dentro il loro Giardino; nel menu solo il Giardino; quelli salvati
## prima in cima alla cartella si spostano dentro; cancellando il Giardino se ne vanno anche loro.
func _nested(w: World) -> void:
	var g := "giardino_prova_semi"
	var c1 := "figlio_prova_semi"
	var c2 := "figlio_vecchio_prova_semi"
	WorldSave.save(w, g, {"nome": "Giardino", "giardino": true})
	WorldSave.save(w, c1, {"nome": "Figlio", "casa": g})
	var root := SavePaths.worlds_dir()
	_check(WorldSave.dir_of(c1) == root + "/" + g + "/semi/" + c1, "mondo del Seme dentro il Giardino (%s)" % WorldSave.dir_of(c1))
	# un figlio salvato prima, in cima alla cartella
	SavePaths.ensure(root + "/" + c2)
	SavePaths.write_json(root + "/" + c2 + "/mondo.json", {"nome": "Figlio vecchio", "casa": g})
	var all := WorldSave.list().map(func(m: Dictionary) -> String: return String(m["id"]))
	var main := WorldSave.list_main().map(func(m: Dictionary) -> String: return String(m["id"]))
	_check(g in all and c1 in all and c2 in all, "la rete vede tutti i mondi")
	_check(g in main and not c1 in main and not c2 in main, "nel menu solo il Giardino %s" % [main])
	_check(DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(root + "/" + g + "/semi/" + c2)), "il figlio vecchio spostato dentro il Giardino")
	_check(WorldSave.load_world(c1) != null and WorldSave.read_meta(c2).get("nome", "") == "Figlio vecchio", "i figli si leggono dal loro posto")
	WorldSave.delete(g)
	_check(WorldSave.read_meta(c1).is_empty() and WorldSave.read_meta(c2).is_empty(), "cancellato il Giardino, spariti i suoi mondi")


func _same(a: World, b: World) -> void:
	_check(a.w == b.w and a.h == b.h, "dimensioni")
	_check(a.tiles == b.tiles, "tessere identiche")
	_check(a.walls == b.walls, "pareti identiche")
	_check(a.decor == b.decor, "decorazioni identiche")
	_check(a.surface == b.surface, "superficie identica")
	_check(a.torches.size() == b.torches.size(), "torce (%d)" % a.torches.size())
	_check(a.explored == b.explored, "mappa esplorata")
	_check(a.biomes == b.biomes, "biomi")
	_check(a.stations == b.stations, "stazioni (%d)" % a.stations.size())
	_check(a.chests_key() == b.chests_key(), "scrigni e ceste (%d)" % a.chests.size())
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
