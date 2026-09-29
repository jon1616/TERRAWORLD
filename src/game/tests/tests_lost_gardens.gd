class_name TestsLostGardens
extends RefCounted
## Roadmap 21 «Le radici del cosmo»: gli Atti dell'Albero e i Giardini perduti (gruppo `perduti`).

var kit: TestKit
var m: Node


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	await seeds()


## Voci 220-221: l'Atto II comincia dopo lo stadio 12; un Seme del cosmo piantato in un'Aiuola apre un portale verso il
## suo Giardino perduto (nome del Giardino, vigore e geni del Giardino, parametro «perduto» per il generatore).
func seeds() -> void:
	var acts_ok := MotherTreeData.act_of(0) == 0 and MotherTreeData.act_of(11) == 0 and MotherTreeData.act_of(12) == 1
	var b: Bisaccia = m.character.bisaccia
	var spot := kit.flat_spot(m.world.spawn + Vector2i(30, 0), 4)
	if spot.x < 0:
		spot = m.player_cell() + Vector2i(6, 0)
	m.snap_to(spot + Vector2i(-3, 0))
	await kit.frames(4)
	var gen := LostGardensData.genome("sommerso")
	b.add_stack({"id": "seme_cosmo_sommerso", "n": 1, "dati": gen})
	kit.hold("seme_cosmo_sommerso")
	kit.aiuola(spot)
	var planted: bool = m.portal.plant(spot, "seme_cosmo_sommerso")
	var o := spot - Vector2i(1, 3)
	var dest: Array = m.portal.destination(o)
	var e: Dictionary = m.portal._portals()[Portal._key(o)]
	var params: Dictionary = MainBoot.gen_params(dest[3], e.get("geni", []), false, m.character, false, String(e.get("perduto", "")))
	if m.guardian.lore.visible:
		m.guardian.lore.visible = false
	var ok := acts_ok and planted and String(dest[1]) == "Il Giardino sommerso" and int(dest[3]) == 4 \
		and String(params.get("perduto", "")) == "sommerso" and "sommerso" in (e.get("geni", []) as Array)
	print("Giardini perduti: atti %s; Seme del cosmo piantato %s → «%s», vigore %d, parametro «%s»" % [acts_ok, planted, dest[1],
		int(dest[3]), params.get("perduto", "")])
	if not ok:
		print("ATTENZIONE: gli Atti o i Semi del cosmo non vanno")
	m.view.remove_station(o)
	m.world.stations.erase(o)
