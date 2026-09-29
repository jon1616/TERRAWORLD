class_name Character
extends RefCounted
## Un personaggio, separato dai mondi: può entrare in qualunque mondo portando con sé la sua Bisaccia.
## Equipaggiamento, vita e Linfa arrivano con la voce 4d della Roadmap.

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
var vita_extra := 0                    # Vita massima in più, per sempre (Guardiani curati, Cuori di bocciolo)
var linfa_extra := 0                   # Linfa massima in più, per sempre (Stille perenni)
var stats := {}                        # conteggi per gli obiettivi (vedi `Objectives`): notti, scrigni, viaggi, strato_max, cuore
var obiettivi: Array = []              # obiettivi raggiunti (id di `ObjectivesData`)
var erbario := {}                      # scoperte (vedi `Erbario`): creature sconfitte, oggetti, pagine di storia
var guardiani_curati: Array = []       # mondi in cui ha curato il Guardiano (il dono vale una volta per mondo)
var mandria: Array = []                # voce 59: le schede delle creature addomesticate (vedi `Herd`)
var seme_nero := ""                    # voce 72: "" · "spezzato" · "curato" (vale per tutti i mondi)
var leggende := {}                     # voce 81: leggende compiute (id → 1), "primo_dato", "primo_fatto"
var sfide := {}                        # voce 82: i record delle sfide (id → {vinte, livello, record})
var diario := {}                       # voce 83: il diario della partita (tappe e conteggi, vedi `Diary`)
var maestria := {}                     # Roadmap 20: pilastro → {"p": punti, "t": tempo di gioco dell'ultimo punto}
var guida := {}                        # 28 set 2026: la guida (lista della spesa, filo scelto, consigli visti)
var guardiani := {}                    # voce 84: i Guardiani affrontati (creatura → {volte, nome}): si possono evocare
var catene := {}                       # voce 69: le catene di ricerca (tappa della lunga, brevi aperte, fatte)
var lingua := {}                       # voce 68: le parole dei Seminatori che conosce (parola -> 1)
var bacheca := {}                      # voce 67: le richieste aperte della Bacheca dei Giardinieri e quante fatte
var albero := {}                       # voce 63: stadio dell'Albero-Madre e offerte già date (vedi `AlberoMadre`)
var genario := {}                      # voce 42: geni conosciuti, gene → 1 visto (in un mondo), 2 imparato (voce 46)


func to_dict() -> Dictionary:
	return {"formato": SaveMigrations.CHARACTER, "nome": name, "creato": created, "ultimo_salvataggio": last_save,
		"tempo_di_gioco": play_time, "barra": hotbar, "ultimo_mondo": last_world,
		"bisaccia": bisaccia.to_array() if bisaccia else [], "equipaggiamento": bisaccia.equip if bisaccia else {},
		"tratti_equip": bisaccia.equip_traits if bisaccia else {}, "dati_equip": bisaccia.equip_data if bisaccia else {},
		"vita": hp, "linfa": linfa, "vita_extra": vita_extra, "linfa_extra": linfa_extra, "guardiani_curati": guardiani_curati,
		"erbario": erbario, "stats": stats, "obiettivi": obiettivi, "genario": genario, "mandria": mandria,
		"albero": albero, "bacheca": bacheca, "lingua": lingua, "catene": catene, "seme_nero": seme_nero,
		"leggende": leggende, "sfide": sfide, "diario": diario,
		"guardiani": guardiani, "guida": guida, "maestria": maestria}


## Null se i dati vengono da una versione più nuova del gioco (vedi `SaveMigrations`).
static func from_dict(cid: String, d: Dictionary) -> Character:
	if not SaveMigrations.character(d):
		push_error("il personaggio %s viene da una versione più nuova del gioco" % cid)
		return null
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
	var et: Dictionary = d.get("tratti_equip", {})
	for k in et:
		if c.bisaccia.equip.has(k) and TraitsData.TRAITS.has(String(et[k])):
			c.bisaccia.equip_traits[k] = String(et[k])
	var ed: Dictionary = d.get("dati_equip", {})
	for k in ed:
		if c.bisaccia.equip.has(k) and ed[k] is Dictionary:
			c.bisaccia.equip_data[k] = SaveMigrations.ints(ed[k])
	c.vita_extra = int(d.get("vita_extra", 0))
	c.linfa_extra = int(d.get("linfa_extra", 0))
	c.guardiani_curati = d.get("guardiani_curati", [])
	# il JSON rilegge i numeri come decimali: nell'Erbario sono conteggi interi
	var eb: Dictionary = d.get("erbario", {})
	for sec in eb:
		var part: Dictionary = eb[sec]
		for k in part:
			part[k] = SaveMigrations.ints(part[k]) if part[k] is Dictionary else int(part[k])
	c.erbario = eb
	var st: Dictionary = d.get("stats", {})
	for k in st:
		st[k] = int(st[k])
	c.stats = st
	c.obiettivi = d.get("obiettivi", [])
	var gn: Dictionary = d.get("genario", {})
	for k in gn:
		if GenesData.GENES.has(k):
			c.genario[k] = int(gn[k])
	for r in d.get("mandria", []):
		# il JSON rilegge i numeri come decimali; una specie che non esiste più si lascia fuori
		if r is Dictionary and CreaturesData.CREATURES.has(CreaturesData.base_of(String(r.get("specie", "")))):
			for k in ["uid", "lvl", "xp"]:
				r[k] = int(r.get(k, 0))
			c.mandria.append(r)
	c.seme_nero = String(d.get("seme_nero", ""))
	var lgd: Variant = d.get("leggende", {})
	if lgd is Dictionary:
		c.leggende = SaveMigrations.ints(lgd)
	var gua: Variant = d.get("guardiani", {})
	if gua is Dictionary:
		c.guardiani = gua
	var ms: Variant = d.get("maestria", {})
	if ms is Dictionary:
		for k in ms:
			if MasteryData.PILLARS.has(k) and ms[k] is Dictionary:
				c.maestria[k] = {"p": float(ms[k].get("p", 0.0)), "t": float(ms[k].get("t", 0.0))}
	var gd: Variant = d.get("guida", {})
	if gd is Dictionary:
		c.guida = gd
	var dia: Variant = d.get("diario", {})
	if dia is Dictionary:
		c.diario = dia
	var sf: Variant = d.get("sfide", {})
	if sf is Dictionary:
		for k in sf:
			var r: Dictionary = sf[k]
			c.sfide[k] = {"vinte": int(r.get("vinte", 0)), "livello": int(r.get("livello", 0)), "record": float(r.get("record", 0.0))}
	var cat: Variant = d.get("catene", {})
	if cat is Dictionary and not (cat as Dictionary).is_empty():
		c.catene = SaveMigrations.ints(cat)
	var lg: Variant = d.get("lingua", {})
	if lg is Dictionary:
		c.lingua = SaveMigrations.ints(lg)
	var bc: Dictionary = d.get("bacheca", {})
	if not bc.is_empty():
		c.bacheca = SaveMigrations.ints(bc)
	var al: Dictionary = d.get("albero", {})
	if not al.is_empty():
		var off := {}
		for k in (al.get("offerte", {}) as Dictionary):
			off[str(k)] = int(al["offerte"][k])
		c.albero = {"stadio": int(al.get("stadio", 0)), "offerte": off}
	c.hp = clampi(int(d.get("vita", Vitals.HP_MAX)), 1, Vitals.HP_MAX + c.vita_extra)
	c.linfa = clampi(int(d.get("linfa", Vitals.LINFA_MAX)), 0, Vitals.LINFA_MAX + c.linfa_extra)
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


## Cancella per sempre un personaggio (dal menu, dopo la conferma).
static func delete(cid: String) -> void:
	SavePaths.delete_file(SavePaths.characters_dir() + "/" + cid + ".json")


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
