class_name SaveMigrations
extends RefCounted
## Le versioni dei salvataggi (voce 41). Il piano «Il Giardiniere dei mondi» cambia la forma di Semi, oggetti e mondi:
## ogni file salvato porta il suo "formato", e alla lettura una catena di passi lo porta alla forma di oggi (da 1 a 2,
## da 2 a 3…), così i personaggi e i mondi già salvati restano giocabili. Ogni cambio di forma = un passo nuovo qui,
## mai una lettura che «indovina».
## Un file con un formato più nuovo di quello che il gioco conosce non si apre (non lo si rovinerebbe risalvandolo).
##
## Passi del mondo: 1 → 2 (voce 42) specie e tratti diventano geni (`world_meta["geni"]`, e così in ogni portale).
## I Semi di mondo salvati senza genoma non hanno bisogno di un passo: lo ricevono la prima volta che servono
## (`Bisaccia.data_at`), con il vigore del mondo in cui ci si trova.

const CHARACTER := 1
const WORLD := 2
const TOO_NEW := "_troppo_nuovo"       # segno lasciato su un dizionario che viene da una versione più nuova


## Porta i dati di un personaggio alla forma di oggi. Falso se vengono da una versione più nuova del gioco.
static func character(d: Dictionary) -> bool:
	return _run(d, CHARACTER, _character_step)


## Porta i dati leggibili di un mondo (`mondo.json`) alla forma di oggi. Falso se vengono da una versione più nuova.
static func world_meta(m: Dictionary) -> bool:
	return _run(m, WORLD, _world_step)


static func _run(d: Dictionary, current: int, step: Callable) -> bool:
	if d.is_empty():
		return true
	var v := int(d.get("formato", 1))
	if v > current:
		d[TOO_NEW] = true
		return false
	while v < current:
		step.call(d, v)
		v += 1
	d["formato"] = current
	return true


static func _character_step(_d: Dictionary, v: int) -> void:
	match v:
		_:
			push_error("manca il passo del personaggio da %d a %d" % [v, v + 1])


static func _world_step(m: Dictionary, v: int) -> void:
	match v:
		1:
			_species_to_genes(m, int(m.get("vigore", 1)))
			var ps: Dictionary = m.get("portali", {})
			for k in ps:
				var e: Dictionary = ps[k]
				if not e.get("ritorno", false) and e.has("specie"):
					_species_to_genes(e, 0)
		_:
			push_error("manca il passo del mondo da %d a %d" % [v, v + 1])


## Specie e tratti della voce 39 → geni della voce 42 (stessi nomi: la specie è il gene di superficie).
static func _species_to_genes(d: Dictionary, vigor: int) -> void:
	if d.has("specie") or d.has("tratti"):
		d["geni"] = Genome.genes(Genome.from_legacy(String(d.get("specie", "")), d.get("tratti", []), vigor))
	d.erase("specie")
	d.erase("tratti")


## Il JSON rilegge ogni numero come decimale: nei dati propri delle caselle (genomi, componenti) i numeri interi
## tornano interi, anche dentro array e dizionari annidati.
static func ints(v: Variant) -> Variant:
	if v is float and is_equal_approx(v, roundf(v)) and absf(v) < 1e15:
		return int(v)
	if v is Array:
		var out := []
		for e in v:
			out.append(ints(e))
		return out
	if v is Dictionary:
		var out := {}
		for k in v:
			out[k] = ints(v[k])
		return out
	return v
