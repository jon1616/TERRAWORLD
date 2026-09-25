class_name Character
extends RefCounted
## Un personaggio, separato dai mondi: può entrare in qualunque mondo portando con sé la sua Bisaccia.
## Equipaggiamento, vita e Linfa arrivano con la voce 4d della Roadmap.

const FORMAT := 1

var id := ""
var name := ""
var created := ""
var last_save := ""
var play_time := 0.0                   # secondi
var hotbar := 0                        # casella scelta nella barra rapida
var last_world := ""
var bisaccia: Bisaccia
var hp := Vitals.HP_MAX
var linfa := Vitals.LINFA_MAX
var vita_extra := 0                    # Vita massima in più, per sempre (doni dei Guardiani curati)
var erbario := {}                      # scoperte (vedi `Erbario`): creature sconfitte, oggetti, pagine di storia
var guardiani_curati: Array = []       # mondi in cui ha curato il Guardiano (il dono vale una volta per mondo)


func to_dict() -> Dictionary:
	return {"formato": FORMAT, "nome": name, "creato": created, "ultimo_salvataggio": last_save,
		"tempo_di_gioco": play_time, "barra": hotbar, "ultimo_mondo": last_world,
		"bisaccia": bisaccia.to_array() if bisaccia else [], "equipaggiamento": bisaccia.equip if bisaccia else {},
		"vita": hp, "linfa": linfa, "vita_extra": vita_extra, "guardiani_curati": guardiani_curati,
		"erbario": erbario}


static func from_dict(cid: String, d: Dictionary) -> Character:
	var c := Character.new()
	c.id = cid
	c.name = String(d.get("nome", cid))
	c.created = String(d.get("creato", ""))
	c.last_save = String(d.get("ultimo_salvataggio", ""))
	c.play_time = float(d.get("tempo_di_gioco", 0.0))
	c.hotbar = int(d.get("barra", 0))
	c.last_world = String(d.get("ultimo_mondo", ""))
	# i personaggi salvati prima della Bisaccia ricevono il corredo iniziale
	c.bisaccia = Bisaccia.from_array(d["bisaccia"]) if d.has("bisaccia") else Bisaccia.starter()
	var eq: Dictionary = d.get("equipaggiamento", {})
	for k in eq:
		if k in Bisaccia.EQUIP_SLOTS and ItemsData.has(String(eq[k])):
			c.bisaccia.equip[k] = String(eq[k])
	c.vita_extra = int(d.get("vita_extra", 0))
	c.guardiani_curati = d.get("guardiani_curati", [])
	# il JSON rilegge i numeri come decimali: nell'Erbario sono conteggi interi
	var eb: Dictionary = d.get("erbario", {})
	for sec in eb:
		var part: Dictionary = eb[sec]
		for k in part:
			part[k] = int(part[k])
	c.erbario = eb
	c.hp = clampi(int(d.get("vita", Vitals.HP_MAX)), 1, Vitals.HP_MAX + c.vita_extra)
	c.linfa = clampi(int(d.get("linfa", Vitals.LINFA_MAX)), 0, Vitals.LINFA_MAX)
	return c


static func create(char_name: String) -> Character:
	var c := Character.new()
	c.name = char_name
	c.id = SavePaths.new_id(char_name)
	c.created = SavePaths.now_text()
	c.bisaccia = Bisaccia.starter()
	return c


func save() -> Error:
	SavePaths.ensure(SavePaths.characters_dir())
	last_save = SavePaths.now_text()
	return SavePaths.write_json(SavePaths.characters_dir() + "/" + id + ".json", to_dict())


static func load_id(cid: String) -> Character:
	var d := SavePaths.read_json(SavePaths.characters_dir() + "/" + cid + ".json")
	return null if d.is_empty() else from_dict(cid, d)


## Tutti i personaggi salvati, dal più recente.
static func list() -> Array[Character]:
	var out: Array[Character] = []
	SavePaths.ensure(SavePaths.characters_dir())
	for f in DirAccess.get_files_at(SavePaths.characters_dir()):
		if f.ends_with(".json"):
			var c := load_id(f.get_basename())
			if c:
				out.append(c)
	out.sort_custom(func(a: Character, b: Character) -> bool: return a.last_save > b.last_save)
	return out
