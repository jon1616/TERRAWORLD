class_name GroupsData
## Gli ingredienti a gruppi (Roadmap 50, voce 407): in una ricetta un ingrediente «@nome» si soddisfa con qualsiasi
## oggetto del gruppo (come le ricette di Terraria con «qualsiasi legno»). Solo dati: li usa `Crafting` (`have`, `take`,
## `counts`); i gruppi sono anche oggetti finti (`items`, tipo «gruppo») perché Creare ed Esamina ne mostrino nome e icona.
## I membri si calcolano dagli altri dati (una volta).

const GROUPS := {
	"@pesce": {"name": "Qualsiasi pesce", "icon": ["pesce", "lagunite"]},
	"@gemma": {"name": "Qualsiasi gemma", "icon": ["gemma", "iride"]},
	"@essenza_creatura": {"name": "Qualsiasi essenza di creatura", "icon": ["essenza", "iride"]},
	"@trofeo_creatura": {"name": "Qualsiasi trofeo di creatura", "icon": ["corona", "ambra"]},
	"@raccolto": {"name": "Qualsiasi raccolto dell'orto", "icon": ["foglia", "muschio"]},
	"@minerale": {"name": "Qualsiasi minerale grezzo", "icon": ["minerale", "ardesia"]},
	"@parte_rara": {"name": "Qualsiasi parte di creatura risvegliata o firma", "icon": ["essenza", "sanguinite"]},
}

static var _members := {}


static func is_group(id: String) -> bool:
	return id.begins_with("@")


## Gli oggetti di un gruppo.
static func members(gid: String) -> Array:
	if _members.is_empty():
		_build()
	return _members.get(gid, [])


static func _build() -> void:
	for g in GROUPS:
		_members[g] = []
	var crops := {}
	for c in CropsData.CROPS:
		for k in (CropsData.CROPS[c].get("harvest", {}) as Dictionary):
			crops[String(k)] = true
	var all := ItemsData.all()
	for id in all:
		var s := String(id)
		var it: Dictionary = all[id]
		var kind := String(it.get("kind", ""))
		var icon: Array = it.get("icon", ["", ""])
		if kind == "pesce":
			(_members["@pesce"] as Array).append(s)
		if kind == "materiale" and String(icon[0]) == "gemma" and not s.begins_with("frammento"):
			(_members["@gemma"] as Array).append(s)
		if s.begins_with("essenza_ris_") or s.begins_with("essenza_firma_"):
			(_members["@essenza_creatura"] as Array).append(s)
		if kind == "trofeo" and RoomsData.boss_of_trophy(s) == "":
			(_members["@trofeo_creatura"] as Array).append(s)
		if crops.has(s):
			(_members["@raccolto"] as Array).append(s)
		if kind == "materiale" and (s.contains("_ris_") or s.contains("_firma_")) and not s.begins_with("essenza_"):
			(_members["@parte_rara"] as Array).append(s)
		if kind == "materiale" and (s.begins_with("minerale_") or s.ends_with("_grezzo") or s.ends_with("_grezza")):
			(_members["@minerale"] as Array).append(s)


## I gruppi come oggetti finti (per i nomi e le icone di Creare ed Esamina).
static func items() -> Dictionary:
	var out := {}
	for g in GROUPS:
		out[g] = {"name": GROUPS[g]["name"], "kind": "gruppo", "icon": (GROUPS[g]["icon"] as Array).duplicate(), "stack": 1,
			"desc": "Un ingrediente a scelta: va bene qualsiasi oggetto del gruppo che hai (prima quelli di cui ne hai di più)."}
	return out
