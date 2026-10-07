class_name TestsDeepCraft
extends RefCounted
## La fabbricazione profonda (Roadmap 50, voci 406-408). Gruppo «fabbricazione».
## Le stazioni a gradi (un grado alto fa anche le ricette di quelli sotto), gli ingredienti a gruppi (qualsiasi pesce va
## bene, si prende prima quello di cui se ne ha di più), le seconde strade per gli oggetti importanti.

var kit: TestKit
var m: Node2D
var res := {}


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	data()
	groups()
	stations()
	print("fabbricazione: %s" % str(res))
	if not res.values().all(func(x: Variant) -> bool: return x == true):
		print("ATTENZIONE: la fabbricazione profonda non va come dovrebbe")


func data() -> void:
	var st := {}
	for r in RecipesData.all():
		st[String(r.get("station", ""))] = true
	var sizes := {}
	for g in GroupsData.GROUPS:
		sizes[g] = GroupsData.members(String(g)).size()
	var keys2 := RecipesData.making("chiave_foresta").size()
	var sap := RecipesData.making("linfa_antica").size()
	res["dati"] = st.size() >= 30 and sizes.values().all(func(n: int) -> bool: return n >= 2) and keys2 >= 1 and sap >= 2
	print("fabbricazione, i dati: %d stazioni con ricette; gruppi %s; ricette della chiave della foresta %d, della Linfa antica %d" % [
		st.size(), str(sizes), keys2, sap])


## «Qualsiasi pesce»: si contano tutti, si toglie prima quello di cui se ne ha di più.
func groups() -> void:
	var b: Bisaccia = m.character.bisaccia
	kit.make_room()
	var fish: Array = GroupsData.members("@pesce")
	var a := String(fish[0])
	var c := String(fish[1])
	b.add(a, 3)
	b.add(c, 1)
	var n: int = Crafting.have(b, "@pesce")
	var counted: int = int(Crafting.counts(b).get("@pesce", 0))
	Crafting.take(b, "@pesce", 2)
	var left_a := b.count(a)
	var left_c := b.count(c)
	b.remove(a, left_a)
	b.remove(c, left_c)
	res["gruppi"] = n >= 4 and counted == n and left_a == 1 and left_c == 1
	print("fabbricazione, «qualsiasi pesce»: ne hai %d (contati %d); presi 2 → restano %d e %d" % [n, counted, left_a, left_c])


## Un banco di grado III fa anche le ricette dei gradi I e II.
func stations() -> void:
	var w: World = m.world
	var at: Vector2i = m.player_cell() + Vector2i(2, -1)
	w.stations[at] = "forgia_cuore_3"
	w.stations_changed()
	var near := Crafting.stations_near(w, m.player_cell())
	w.stations.erase(at)
	w.stations_changed()
	res["gradi"] = near.has("forgia_cuore_3") and near.has("forgia_cuore_1") and near.has("forgia_cuore_2") and not near.has("forgia_cuore_4")
	print("fabbricazione, la Forgia del Cuore III vicina: %s" % str(near.keys().filter(func(k: String) -> bool: return k.begins_with("forgia_cuore"))))
