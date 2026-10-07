class_name TestsAfter
extends RefCounted
## Il dopo senza fine (Roadmap 51, voci 409-410). Gruppo «dopo».
## Sei metalli del dopo (vigore 13-38) con tutta la loro famiglia, carattere, set e gesto, che si scavano nei mondi giusti;
## dieci armi e un Sacchetto per ogni fase del dopo; 24 armi leggendarie con una storia; i Guardiani dei mondi oltre la
## spina lasciano il Sacchetto della loro fase.

var kit: TestKit
var m: Node2D
var res := {}


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	data()
	drops()
	print("dopo: %s" % str(res))
	if not res.values().all(func(x: Variant) -> bool: return x == true):
		print("ATTENZIONE: il dopo senza fine non va come dovrebbe")


func data() -> void:
	var metals := ["aurorite", "sognite", "abissite", "memorite", "crepuscolite", "seminite"]
	var fam_ok := true
	var prev := 236
	for mt in metals:
		var sw := ItemsData.get_item("spada_" + mt)
		if sw.is_empty() or not SetsData.all().has(mt) or MaterialsData.trait_of(mt).is_empty() or GesturesData.of_mat(mt).is_empty():
			fam_ok = false
		elif int(sw["damage"]) <= prev:
			fam_ok = false
		else:
			prev = int(sw["damage"])
	var legends := 0
	var stories := true
	for id in ItemsData.all():
		var it: Dictionary = ItemsData.all()[id]
		if it.get("leggendaria", false):
			legends += 1
			stories = stories and String(it.get("desc", "")).length() > 30 and (it.get("mods", {}) as Dictionary).size() >= 3
	var weapons := 0
	for k in 6:
		for i in 10:
			if ItemsData.has("dopo_%d_%d" % [k, i]):
				weapons += 1
	res["dati"] = fam_ok and legends == 24 and stories and weapons == 60
	print("dopo, i dati: metalli in crescita %s (spada di seminite %d), leggendarie %d con storia %s, armi del dopo %d" % [
		fam_ok, prev, legends, stories, weapons])


## Nei mondi del dopo: si scava il metallo della fase e il Guardiano lascia il Sacchetto del dopo.
func drops() -> void:
	var at15 := GeneMaterials.spine_for(15, true)
	var at40 := GeneMaterials.spine_for(40, true)
	var v0 := int(m.world_meta.get("vigore", 1))
	m.world_meta["vigore"] = 15
	var bag: String = m.firma.bag("gg~prova", m.player.position + Vector2(0, -20))
	m.world_meta["vigore"] = v0
	res["cadute"] = at15.has("aurorite") and at40.has("seminite") and not at40.has("aurorite") and bag == "sacchetto_dopo_0" \
		and FirmaDrops.after_phase(12) == -1 and FirmaDrops.after_phase(99) == 5
	print("dopo, nei mondi: al vigore 15 si scava %s, al 40 %s; il Guardiano lascia «%s»" % [str(at15), str(at40), bag])
