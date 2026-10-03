class_name BiomePages
extends RefCounted
## Le pagine dei biomi dell'Atlante (Roadmap 23, voce 236; le pagine in `BiomePagesData`). Una pagina si riempie da
## sola: le creature sconfitte e i pesci pescati li sa l'Erbario, la visita la segna `visit` (lo chiama `Atlas` a ogni
## giro: in superficie il bioma della colonna, sotto terra il pavimento di un bioma del sottosuolo, in cielo la zona).
## Pagina completa: premio, conteggio «pagine_biomi» (maestria dell'esplorazione), `Character.stats["pagina_<id>"]`.

var m: Node2D


func _init(main: Node2D) -> void:
	m = main


## La chiave della visita di un bioma (quella del cielo è la stessa che scrive `Chiome`).
static func visit_key(p: Dictionary) -> String:
	return ("cielo_" if String(p["kind"]) == "cie" else "visto_") + String(p["biome"])


## Segna il bioma in cui si trova adesso il Germogliato.
func visit() -> void:
	var st: Dictionary = m.character.stats
	var c: Vector2i = m.player_cell()
	if m.depth_watch.stratum == 0 and m.depth_watch.biome >= 0 and m.depth_watch.biome < BiomesData.BIOMES.size():
		st["visto_" + String(BiomesData.BIOMES[m.depth_watch.biome]["id"])] = 1
	elif m.depth_watch.stratum > 0:
		for dy in 6:
			if m.world.solid(c.x, c.y + dy):
				var t: int = m.world.tile(c.x, c.y + dy)
				for u in BiomesData.UNDER:
					if int(u["floor"]) == t:
						st["visto_" + String(u["id"])] = 1
				break


func visited(p: Dictionary) -> bool:
	return int(m.character.stats.get(visit_key(p), 0)) == 1


## [presi, tutti] di una pagina.
func progress(p: Dictionary) -> Array:
	var got := 1 if visited(p) else 0
	var tot := 1
	for cid in p["creature"]:
		tot += 1
		if m.erbario.known("creature", String(cid)):
			got += 1
	for fid in p["pesci"]:
		tot += 1
		if m.erbario.known("pesci", String(fid)):
			got += 1
	return [got, tot]


func done(p: Dictionary) -> bool:
	return int(m.character.stats.get("pagina_" + String(p["id"]), 0)) == 1


## Le pagine appena completate (e ne dà il premio). Restituisce i loro id.
func check() -> Array:
	var fresh := []
	for p in BiomePagesData.pages():
		if done(p):
			continue
		var pr := progress(p)
		if int(pr[0]) >= int(pr[1]):
			m.character.stats["pagina_" + String(p["id"])] = 1
			fresh.append(String(p["id"]))
			var parts := []
			for it in BiomePagesData.REWARD:
				var rest: int = m.character.bisaccia.add(String(it), int(BiomePagesData.REWARD[it]))
				if rest > 0:
					m.drops.spawn(String(it), rest, m.player.position)
				parts.append("%s ×%d" % [String(ItemsData.get_item(String(it)).get("name", it)), int(BiomePagesData.REWARD[it])])
			m.objectives.bump("pagine_biomi")
			m.hud.toast("Atlante: la pagina «%s» è completa · %s" % [p["name"], ", ".join(parts)])
			m.sfx.play("dono")
	return fresh


func done_count() -> int:
	var n := 0
	for p in BiomePagesData.pages():
		if done(p):
			n += 1
	return n


## La pagina in BBCode: che cosa c'è, che cosa manca e dove cercarlo.
func text_of(p: Dictionary) -> String:
	var pr := progress(p)
	var t := "[font_size=26][color=#8ef0a0]%s[/color][/font_size]\n%s · %d su %d%s\n\n" % [p["name"], p["where"], int(pr[0]),
		int(pr[1]), " · [color=#ffd24a]completa[/color]" if done(p) else ""]
	t += "%s [color=%s]Visitare il bioma[/color]\n" % ["✓" if visited(p) else "·", "#cfeee4" if visited(p) else "#9a8aa4"]
	# Roadmap 36, voce 346: la leggenda del luogo, a bioma visitato
	if visited(p) and MythsData.of(String(p["biome"])) != "":
		t += "\n[i][color=#c8b8e8]%s[/color][/i]\n" % MythsData.of(String(p["biome"]))
	if not (p["creature"] as Array).is_empty():
		t += "\n[b]Le creature[/b] (da sconfiggere almeno una volta)\n"
		for cid in p["creature"]:
			var k: bool = m.erbario.known("creature", String(cid))
			var name := String(CreaturesData.get_data(String(cid))["name"]) if k else "???"
			var hint := BiomePagesData.hint_of(String(cid))
			t += "%s [color=%s]%s[/color]%s\n" % ["✓" if k else "·", "#cfeee4" if k else "#9a8aa4", name,
				"" if k or hint == "" else "  [color=#6a7a84](%s)[/color]" % hint]
	if not (p["pesci"] as Array).is_empty():
		t += "\n[b]I pesci[/b]\n"
		for fid in p["pesci"]:
			var k: bool = m.erbario.known("pesci", String(fid))
			t += "%s [color=%s]%s[/color]\n" % ["✓" if k else "·", "#cfeee4" if k else "#9a8aa4",
				String(FishData.info(String(fid)).get("name", fid)) if k else "???"]
	var gift := []
	for it in BiomePagesData.REWARD:
		gift.append("%s ×%d" % [String(ItemsData.get_item(String(it)).get("name", it)), int(BiomePagesData.REWARD[it])])
	t += "\n[color=#9a8aa4]Completa: %s[/color]" % ", ".join(gift)
	return t
