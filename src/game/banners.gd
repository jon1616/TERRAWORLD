class_name Banners
extends Node
## Gli stendardi in partita (Roadmap 42, voce 381; dati in `BannersData`). Conta le sconfitte di ogni famiglia
## (`stats["uccisi_fam_<famiglia>"]`): ogni `BannersData.EVERY` cade il suo stendardo. Issato (clic), vale per sempre in
## ogni mondo (`stats["stendardo_<famiglia>"]`: 1 lo stendardo, 2 quello d'oro): più danno contro quella famiglia
## (`mult`, letto da `Combat._strike`) e meno ferite (`guard`, al contatto e dai colpi: `Fauna.guard_hook`).

var m: Node2D
var dropped := 0                          # per le prove


func setup(main: Node2D) -> void:
	m = main
	m.fauna.killed.connect(_on_killed)
	m.fauna.guard_hook = guard


func _exit_tree() -> void:
	if m != null and m.get("fauna") != null:
		m.fauna.guard_hook = Callable()


func _on_killed(c: Creature) -> void:
	if not is_instance_valid(c) or c.tame != null or c.family == "":
		return
	var key := "uccisi_fam_" + c.family
	var n := int(m.character.stats.get(key, 0)) + 1
	m.character.stats[key] = n
	if n % BannersData.EVERY == 0 and ItemsData.has(BannersData.item_of(c.family)):
		m.drops.spawn(BannersData.item_of(c.family), 1, c.position)
		dropped += 1
		m.hud.toast("Uno stendardo: %s" % String(ItemsData.get_item(BannersData.item_of(c.family))["name"]))


## Issa uno stendardo dalla mano. True se l'ha fatto.
func raise(id: String) -> bool:
	var it := ItemsData.get_item(id)
	var fam := String(it.get("family", ""))
	var lvl := 2 if bool(it.get("gold", false)) else 1
	var key := "stendardo_" + fam
	if int(m.character.stats.get(key, 0)) >= lvl:
		m.hud.toast("Questo stendardo è già issato")
		return false
	if not m.character.bisaccia.remove(id, 1):
		return false
	m.character.stats[key] = lvl
	m.objectives.bump("stendardi")
	m.sfx.play("dono")
	m.hud.toast("Issato: %s. Vale per sempre, in ogni mondo" % String(it["name"]))
	return true


func level(fam: String) -> int:
	return int(m.character.stats.get("stendardo_" + fam, 0)) if fam != "" else 0


func mult(fam: String) -> float:
	match level(fam):
		1:
			return BannersData.DAMAGE
		2:
			return BannersData.GOLD_DAMAGE
	return 1.0


func guard(fam: String) -> float:
	match level(fam):
		1:
			return BannersData.GUARD
		2:
			return BannersData.GOLD_GUARD
	return 1.0
