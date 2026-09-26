class_name TestsForms
extends RefCounted
## Prove della Roadmap 6 «La materia viva». Voce 50: ogni forma colpisce nella sua area (la lancia a tre tessere dove
## il pugnale non arriva, la falce anche dietro), la balestra trafigge, la verga tira saette con la Linfa, la trivella
## scava più in fretta, la fascia del Telaio cambia i valori e resta salvando; il foglio di tutte le forme in tutti i
## materiali (prove/89_forme.png).

const S := 16

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func run() -> void:
	await forms()


func _feet(c: Vector2i, id: String) -> Vector2:
	return Vector2(c.x * S + 8, (c.y + 1) * S - float(CreaturesData.CREATURES[id]["half"][1]) - 0.1)


## Tiene in mano l'oggetto, mette una strisciaradice ferma a `dx` tessere e colpisce per `secs` secondi: vero se è stata
## ferita.
func _hits(id: String, spot: Vector2i, dx: int, secs := 1.2) -> bool:
	m.fauna.clear()
	kit.bisaccia().add(id, 1)
	kit.hold(id)
	m.snap_to(spot)
	m.player.facing = 1
	await kit.frames(3)
	var c: Creature = m.fauna.add("strisciaradice", _feet(spot + Vector2i(dx, 0), "strisciaradice"))
	c.set_process(false)
	var hp0 := c.hp
	m.player.force_swing = true
	await kit.seconds(secs)
	m.player.force_swing = false
	var hit: bool = not is_instance_valid(c) or not m.fauna.list.has(c) or c.hp < hp0
	m.fauna.clear()
	await kit.frames(3)
	return hit


func forms() -> void:
	var spot := kit.flat_spot(world.spawn + Vector2i(-24, 0), 8)
	if spot.x < 0:
		print("ATTENZIONE: nessun posto piano per le prove delle forme")
		return
	kit.flatten(spot, 8)
	kit.make_room()
	var far_lance: bool = await _hits("lancia_radicite", spot, 4)
	var far_dagger: bool = await _hits("pugnale_radicite", spot, 4)
	var back_scythe: bool = await _hits("falcione_radicite", spot, -2)
	var back_sword: bool = await _hits("spada_radicite", spot, -2)
	var far_whip: bool = await _hits("frusta_radicite", spot, 5)
	print("forme: lancia a 4 tessere %s, pugnale a 4 tessere %s (giusto: no); falce dietro %s, spada dietro %s (giusto: no); frusta a 5 tessere %s" % [
		"colpisce" if far_lance else "NO", "colpisce" if far_dagger else "no", "colpisce" if back_scythe else "NO",
		"colpisce" if back_sword else "no", "colpisce" if far_whip else "NO"])
	if not far_lance or far_dagger or not back_scythe or back_sword or not far_whip:
		print("ATTENZIONE: una forma non colpisce nella sua area")
	# i valori: pesante contro leggero, trivella, balestra
	var sh := Gear.stats({"id": "spadone_legnoferro"})
	var dg := Gear.stats({"id": "pugnale_legnoferro"})
	var ham := Gear.stats({"id": "martello_legnoferro"})
	var tri := Gear.stats({"id": "trivella_legnoferro"})
	var pic := Gear.stats({"id": "piccone_legnoferro"})
	print("legnoferro: spadone %d danno a %.2f colpi/s, pugnale %d a %.2f, martello spinta %.0f; trivella forza %d scavo ×%.1f (piccone %d); balestra trafigge %d" % [
		roundi(float(sh["damage"])), float(sh["speed"]), roundi(float(dg["damage"])), float(dg["speed"]), float(ham["knockback"]),
		int(tri["power"]), float(tri["dig"]), int(pic["power"]), int(Gear.stats({"id": "balestra_legnoferro"})["pierce"])])
	# la verga: saette con la Linfa
	kit.bisaccia().add("verga_ambra", 1)
	kit.hold("verga_ambra")
	m.vitals.refill()
	var l0: int = m.vitals.linfa
	var casts: int = m.spells.casts
	m.spells.auto_aim = m.player.position + Vector2(120, -10)
	m.spells.auto_fire = true
	await kit.seconds(0.8)
	m.spells.auto_fire = false
	m.spells.auto_aim = Vector2.INF
	print("verga d'ambra: saette %d, Linfa %d → %d, danno %d" % [m.spells.casts - casts, l0, m.vitals.linfa,
		roundi(float(Gear.stats({"id": "verga_ambra"})["damage"]))])
	# la fascia al Telaio
	var b := kit.bisaccia()
	b.add("seta_radice", 3)
	var ws := kit.hold("lancia_radicite")
	var before := Gear.stats({"id": "lancia_radicite", "dati": b.slots[ws].get("dati", {})})
	var wrapped := Crafting.wrap(b, ws, "seta")
	var after := Gear.stats({"id": "lancia_radicite", "dati": b.data_at(ws)})
	m.character.save()
	var again := Character.load_id(m.character.id)
	var kept := again != null and String(again.bisaccia.data_at(ws).get("fascia", "")) == "seta"
	print("fascia di seta al Telaio: %s, velocità %.2f → %.2f, nome «%s», salvata e ricaricata %s" % ["sì" if wrapped else "NO",
		float(before["speed"]), float(after["speed"]), Gear.full_name(b.slots[ws]), "sì" if kept else "NO"])
	# il foglio delle forme: una riga per forma, una colonna per materiale
	var mats := MaterialsData.all().keys()
	var sheet := Image.create_empty(mats.size() * 36 + 4, FormsData.FORMS.size() * 36 + 4, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("#141820"))
	var r := 0
	for f in FormsData.FORMS:
		for k in mats.size():
			var ic := ItemIcons.of(FormsData.item_id(f, String(mats[k])))
			ic.resize(32, 32, Image.INTERPOLATE_NEAREST)
			sheet.blend_rect(ic, Rect2i(0, 0, 32, 32), Vector2i(4 + k * 36, 4 + r * 36))
		r += 1
	sheet.save_png(ProjectSettings.globalize_path("res://prove/89_forme.png"))
	print("salvato 89_forme (%d forme × %d materiali = %d oggetti)" % [FormsData.FORMS.size(), mats.size(),
		FormsData.FORMS.size() * mats.size()])
