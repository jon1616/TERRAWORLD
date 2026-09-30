class_name Backpack
extends Node
## Lo zaino (Roadmap 30; dati in `BackpackData`). Voce 295: le Bisacce a gradi. Usarne una allarga la Bisaccia del
## Germogliato a tante caselle quante ne ha (per sempre, il contenuto resta); una più piccola della Bisaccia di adesso non
## si consuma. Il conteggio «bisaccia_caselle» dice fin dove si è arrivati.
## Voce 297: «Non raccogliere» e «Dritto nel Cestino», un segno per oggetto (`Character.guida["scarta"]`) che `Drops`
## legge; lo si cambia con il pulsante di Esamina.

const RULES := ["", "lascia", "cestino"]
const RULE_TEXT := {"": "Raccogli", "lascia": "Non raccogliere", "cestino": "Dritto nel Cestino"}

var m: Node2D


func setup(main: Node2D) -> void:
	m = main
	_sync_rules()
	var bp: BisacciaPanel = m.hud.panel
	bp.pick_rule = rule
	bp.pick_rule_next = next_rule


## Voce 297: che cosa si fa di un oggetto a terra: "" (raccoglierlo), "lascia", "cestino".
func rule(id: String) -> String:
	return String(_rules().get(id, ""))


func set_rule(id: String, r: String) -> void:
	if r == "":
		_rules().erase(id)
	else:
		_rules()[id] = r
	_sync_rules()


## Il segno dopo (Raccogli → Non raccogliere → Dritto nel Cestino → Raccogli); restituisce il nuovo.
func next_rule(id: String) -> String:
	var r := String(RULES[(RULES.find(rule(id)) + 1) % RULES.size()])
	set_rule(id, r)
	var name := String(ItemsData.get_item(id).get("name", id))
	m.hud.toast({"": "%s: lo raccogli di nuovo", "lascia": "%s: resta a terra, non lo raccogli più",
		"cestino": "%s: raccolto finisce subito nel Cestino"}[r] % name)
	return r


func _rules() -> Dictionary:
	if not m.character.guida.has("scarta"):
		m.character.guida["scarta"] = {}
	return m.character.guida["scarta"]


func _sync_rules() -> void:
	m.drops.rules = _rules()                    # (il dizionario si riassegna: un salvataggio può averlo sostituito)


func use_bag(id: String) -> bool:
	var bd := BackpackData.bag_of(id)
	if bd.is_empty():
		return false
	var b: Bisaccia = m.character.bisaccia
	var n := int(bd["slots"])
	if n <= b.slots.size():
		m.hud.toast("La tua Bisaccia ha già %d caselle: questa ne ha %d" % [b.slots.size(), n])
		return false
	if not b.remove(id, 1):
		return false
	b.grow(n)
	m.character.stats["bisaccia_caselle"] = n
	m.hud.toast("%s: ora la Bisaccia ha %d caselle (le pagine in alto, accanto al titolo)" % [bd["name"], n])
	m.sfx.play("dono")
	return true
