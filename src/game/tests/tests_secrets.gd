class_name TestsSecrets
extends RefCounted
## Prove dei segreti (voce 95): il mondo di prova ne ha un elenco (dai posti nascosti del generatore); entrando nel
## riquadro di uno lo si trova, con il premio e il conteggio; la bacchetta rabdomante vibra di più vicino a un segreto;
## l'Eco segna sulla mappa; il contatore arriva alla mappa e alla scheda del portale. Foto 167_bacchetta.

var kit: TestKit
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	var res := {}
	var se: Secrets = m.secrets
	var c0: Array = se.counts()
	var kinds := {}
	for s in se.list:
		kinds[s["k"]] = int(kinds.get(s["k"], 0)) + 1
	res["elenco"] = int(c0[1]) >= 5
	print("segreti nel mondo di prova: %d (%s), trovati %d" % [c0[1], kinds, c0[0]])
	# il primo non trovato: la bacchetta lontano e vicino, poi ci si entra
	var target: Dictionary = {}
	for s in se.list:
		if not s.get("f", false) and String(s["k"]) != "isola_sospesa":
			target = s
			break
	if target.is_empty():
		print("ATTENZIONE: nessun segreto da provare nel mondo di prova")
		return
	var r := Secrets.rect_of(target)
	var b: Bisaccia = m.character.bisaccia
	var eq0: Dictionary = b.equip.duplicate()
	b.equip["accessorio_1"] = "bacchetta_rabdomante"
	b.changed.emit()
	# lontano (fuori portata) e vicino
	var far := r.get_center() + Vector2i(SecretsData.R_ROD + 20, 0)
	m.snap_to(Vector2i(clampi(far.x, 5, m.world.w - 5), clampi(far.y, 5, m.world.h - 5)))
	await kit.seconds(0.5)
	var rod_far: float = se.rod
	var near := r.get_center() + Vector2i(r.size.x / 2 + 6, 0)
	m.snap_to(near)
	await kit.seconds(0.5)
	var rod_near: float = se.rod
	res["bacchetta"] = rod_near > rod_far and rod_near > 0.5
	m.boons.add("bagliore", 3.0)
	await kit.save("167_bacchetta")
	# l'Eco
	b.add("eco_seminatori", 1)
	var marks0 := (m.world_meta.get("segni", []) as Array).size()
	res["eco"] = se.use_echo("eco_seminatori") and (m.world_meta.get("segni", []) as Array).size() > marks0
	# dentro
	var lum0: int = b.count("lumino") + _ground("lumino")
	var stat0 := int(m.character.stats.get("segreti", 0))
	m.snap_to(r.get_center())
	await kit.seconds(0.6)
	res["trovato"] = target.get("f", false) and int(se.counts()[0]) == int(c0[0]) + 1
	res["premio"] = b.count("lumino") + _ground("lumino") > lum0 and int(m.character.stats.get("segreti", 0)) == stat0 + 1
	res["conteggio_salvato"] = int(Secrets.counts_of(m.world_meta)[0]) == int(c0[0]) + 1
	b.equip = eq0
	b.changed.emit()
	m.snap_to(m.world.spawn)
	var bad := res.keys().filter(func(k: String) -> bool: return not res[k])
	print("segreti: bacchetta lontano %.2f, vicino %.2f; %s; non vanno: %s" % [rod_far, rod_near, res, bad])
	if not bad.is_empty():
		print("ATTENZIONE: i segreti non funzionano come dovrebbero")


func _ground(id: String) -> int:
	var n := 0
	for d in m.drops._items:
		if d["id"] == id:
			n += int(d["n"])
	return n
