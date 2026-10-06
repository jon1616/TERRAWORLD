class_name Companions
extends Node
## I compagni (voce 37, dati in `CompanionsData`): il compagno che segue il Germogliato (uno alla volta, si chiama e
## si congeda con il clic sul suo oggetto; resta con il personaggio, `Character.stats["compagno"]`) e le
## creature alleate dei bastoni evocatori (fino a `MAX_ALLIES`, più gli accessori con `allies`; il richiamo costa
## Linfa, il più vecchio lascia il posto al nuovo). Se il Germogliato appassisce gli alleati se ne vanno.

const S := 16

var m: Node2D
var pet: Ally
var allies: Array[Ally] = []
var _light_t := 0.0


func setup(main: Node2D) -> void:
	m = main
	# nei conteggi del personaggio stanno solo numeri (al caricamento diventano interi): il compagno è il suo posto
	# in `PETS` più uno, 0 = nessuno
	var k := int(m.character.stats.get("compagno", 0))
	if k > 0 and k <= CompanionsData.PETS.size():
		call_pet(String(CompanionsData.PETS.keys()[k - 1]))


## Clic con l'oggetto di un compagno: arriva (o, se c'è già, se ne va).
func toggle_pet(item: String) -> bool:
	var pid := String(ItemsData.get_item(item).get("pet", ""))
	if pid == "":
		return false
	if pet != null and pet.id == pid:
		dismiss_pet()
		m.hud.toast("%s torna a riposare" % CompanionsData.PETS[pid]["name"])
		return true
	call_pet(pid)
	m.hud.toast("%s ti segue" % CompanionsData.PETS[pid]["name"])
	return true


func call_pet(pid: String) -> void:
	dismiss_pet()
	pet = _make(pid, true, 0)
	m.character.stats["compagno"] = CompanionsData.PETS.keys().find(pid) + 1
	_apply_pet()


func dismiss_pet() -> void:
	if pet != null:
		pet.queue_free()
		pet = null
	m.character.stats.erase("compagno")
	_apply_pet()


## I doni del compagno: la luce la manda avanti `_process`, gli altri valgono finché c'è.
func _apply_pet() -> void:
	var pd: Dictionary = CompanionsData.PETS.get(pet.id, {}) if pet != null else {}
	m.drops.magnet_mult = float(pd.get("magnet", 1.0))
	m.vitals.pet_linfa = float(pd.get("linfa", 1.0))
	if m.get("gear") != null:
		m.gear.refresh()                             # voce 388: il dono in «acc»


## Un bastone evocatore: una creatura alleata in più (il richiamo costa Linfa).
func summon(item: String) -> bool:
	var aid := String(ItemsData.get_item(item).get("ally", ""))
	if aid == "":
		return false
	if m.vitals.linfa < CompanionsData.SUMMON_LINFA:
		m.hud.toast("Serve Linfa per richiamare un alleato")
		return false
	m.vitals.linfa -= CompanionsData.SUMMON_LINFA
	m.vitals.changed.emit()
	var cap := CompanionsData.MAX_ALLIES + int(m.gear.allies)
	while allies.size() >= cap:
		var old: Ally = allies.pop_front()
		Fx.puff(m.fx, old.position, Color(0.8, 1.6, 1.4))
		old.queue_free()
	var a := _make(aid, false, allies.size() + 1)
	a.power = float(ItemsData.get_item(item).get("ally_power", 1.0))     # voce 367: lo scettro del branco
	allies.append(a)
	Fx.puff(m.fx, a.position, Color(0.8, 1.6, 1.4))
	m.sfx.play("incanto", a.position)
	m.objectives.bump("alleati")
	return true


func dismiss_allies() -> void:
	for a in allies:
		a.queue_free()
	allies.clear()


func _make(aid: String, is_pet: bool, slot: int) -> Ally:
	var a := Ally.new()
	a.setup(aid, is_pet, m, slot)
	a.position = m.player.position + Vector2(-20, -12)
	a.z_index = 4
	m.add_child(a)
	return a


func _process(dt: float) -> void:
	if not m.built:
		return
	if m.life.dead and not allies.is_empty():
		dismiss_allies()
	_light_t -= dt
	if _light_t <= 0.0:
		_light_t = 0.15
		var ls := []
		if pet != null and CompanionsData.PETS[pet.id].has("light"):
			ls.append([Vector2i(floori(pet.position.x / S), floori(pet.position.y / S)), CompanionsData.PETS[pet.id]["light"]])
		m.light.set_extra("compagno", ls)
