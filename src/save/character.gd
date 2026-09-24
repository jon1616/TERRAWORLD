class_name Character
extends RefCounted
## Un personaggio, separato dai mondi come in Terraria: può entrare in qualunque mondo. Per ora conserva poco;
## inventario, equipaggiamento, vita e Linfa arriveranno con la voce 4 della Roadmap.

const FORMAT := 1

var id := ""
var name := ""
var created := ""
var last_save := ""
var play_time := 0.0                   # secondi
var hotbar := 0                        # casella scelta nella barra rapida
var last_world := ""


func to_dict() -> Dictionary:
	return {"formato": FORMAT, "nome": name, "creato": created, "ultimo_salvataggio": last_save,
		"tempo_di_gioco": play_time, "barra": hotbar, "ultimo_mondo": last_world}


static func from_dict(cid: String, d: Dictionary) -> Character:
	var c := Character.new()
	c.id = cid
	c.name = String(d.get("nome", cid))
	c.created = String(d.get("creato", ""))
	c.last_save = String(d.get("ultimo_salvataggio", ""))
	c.play_time = float(d.get("tempo_di_gioco", 0.0))
	c.hotbar = int(d.get("barra", 0))
	c.last_world = String(d.get("ultimo_mondo", ""))
	return c


static func create(char_name: String) -> Character:
	var c := Character.new()
	c.name = char_name
	c.id = SavePaths.new_id(char_name)
	c.created = SavePaths.now_text()
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
