class_name SkyData
extends RefCounted
## Le Chiome del cielo (Roadmap 16, voce 154): il cielo sopra la superficie di ogni mondo, diviso in **zone** lungo la
## larghezza. Ogni zona ha un bioma del **cielo basso** (le isole a portata dal primo giorno) e uno del **cielo alto**
## (sopra, fino al bordo: l'aria sottile, le creature forti). I biomi sono file in `src/data/biomes/cielo_*.gd`
## (`BiomesData.SKY_FILES`, uniti ai pacchetti); le zone le decide `PassCielo` e stanno in `World.sky` (dagli appunti
## del generatore; si salvano in `world_meta["cielo"]`, `Sky.setup` le rimette nel mondo).
## Campi dei file del cielo (oltre al pacchetto, come i biomi del sottosuolo):
##   id, name, desc, color   la scritta entrando e l'Enciclopedia
##   band                    "basso" o "alto"
##   weight                  quanto spesso tocca a una zona (i geni del cielo lo moltiplicano)
##   floor                   la tessera del pavimento delle isole (la vegetazione `veg` ci cresce sopra)
##   body                    la tessera sotto il pavimento; rock: quella del cuore delle isole grandi
##   tiles, veg, decor       come i biomi del sottosuolo (tessere nuove, vegetazione, decorazioni con la luce); in più
##                           le tessere hanno "pass" (quanta luce le attraversa, la roccia 0,5) ed "emit" (luce propria)
##   isle                    la forma delle isole in `PassCielo` (zolla, nuvola, giardino, scoglio, tempesta, stelle)
##   isles                   quante isole per 100 colonne di zona
##   pools                   probabilità di una pozza d'acqua su un'isola (la pesca)
##   trees                   probabilità di un albero sulle isole (la specie del bioma di superficie sotto)
##   danger                  × il pericolo delle creature che nascono qui
##   dark                    quanto il cielo si fa notte anche di giorno stando qui (il Firmamento)
##   thin                    voce 158: quanto svelta sale la barra dell'aria sottile (0 = niente)
##   elem                    l'elemento più probabile delle varianti che nascono qui
##   adj                     gli aggettivi dei nomi dei mondi (`NamesData`)

const LOW_GAP := 28                    # tessere tra la superficie più alta della zona e il fondo del cielo basso
const LOW_H := 62                      # altezza della fascia bassa
const TOP := 10                        # righe libere in cima al mondo
const HIGH_MIN := 36                   # la fascia alta ha almeno queste righe (altrimenti niente cielo alto)
const ZONE_MIN := 300                  # lunghezza di una zona, in colonne
const ZONE_MAX := 520
const SPAWN_FREE := 60                 # colonne attorno alla partenza senza isole

const CLOUDS := [52, 53]               # le tessere di nuvola: attutiscono le cadute (`Life._on_landed`)
const BEAN_STEP := 3                   # voce 157: righe tra due passerelle della liana del Fagiolo
const BEAN_H := 40                     # quanto sale una liana, in tessere
const BEAN_EVERY := 4.0                # secondi tra una passerella e l'altra (una liana intera in ~52 s)

static var BIOMES: Array = BiomesData.SKY


static func index_of(id: String) -> int:
	for k in BIOMES.size():
		if String(BIOMES[k]["id"]) == id:
			return k
	return -1


static func get_biome(id: String) -> Dictionary:
	var k := index_of(id)
	return BIOMES[k] if k >= 0 else {}


static func of_band(band: String) -> Array:
	var out := []
	for b in BIOMES:
		if String(b["band"]) == band:
			out.append(b)
	return out


## La zona del cielo di una colonna ({x0, x1, low, high, base, split} oppure vuoto). `base` = la riga sotto cui finisce
## il cielo basso; `split` = il confine tra basso e alto.
static func zone_of(w: Object, x: int) -> Dictionary:
	for z in w.sky:
		if x >= int(z["x0"]) and x < int(z["x1"]):
			return z
	return {}


## L'id del bioma del cielo di una cella ("" se non è cielo).
static func zone_at(w: Object, x: int, y: int) -> String:
	var z := zone_of(w, x)
	if z.is_empty() or y > int(z["base"]) or y < TOP:
		return ""
	if y > int(z["split"]):
		return String(z["low"])
	return String(z["high"])


## La fascia di una cella: "basso", "alto" o "".
static func band_at(w: Object, x: int, y: int) -> String:
	var id := zone_at(w, x, y)
	return "" if id == "" else String(get_biome(id)["band"])


## Un bioma a caso per una fascia, secondo i pesi (e i geni: {id: moltiplicatore}).
static func roll(band: String, rng: RandomNumberGenerator, mult: Dictionary = {}) -> String:
	var tot := 0.0
	var list := of_band(band)
	for b in list:
		tot += float(b.get("weight", 1)) * float(mult.get(String(b["id"]), 1.0))
	var r := rng.randf() * tot
	for b in list:
		r -= float(b.get("weight", 1)) * float(mult.get(String(b["id"]), 1.0))
		if r <= 0.0:
			return String(b["id"])
	return String(list[list.size() - 1]["id"]) if not list.is_empty() else ""


## Le zone di un mondo: tratti di ZONE_MIN-ZONE_MAX colonne con un bioma basso e uno alto; `base` dalla superficie più
## alta del tratto. Nessuna zona se il cielo non ci sta (mondi a Guscio, montagne fino al cielo). `scale` (gene «Cieli
## alti») allunga la fascia bassa; `mult` i pesi dei biomi.
static func make_zones(w: Object, rng: RandomNumberGenerator, scale: float = 1.0, mult: Dictionary = {}) -> Array:
	var out := []
	var x := 0
	var last_low := ""
	var last_high := ""
	while x < w.w:
		var len := rng.randi_range(ZONE_MIN, ZONE_MAX)
		var x1 := mini(x + len, w.w)
		if w.w - x1 < ZONE_MIN / 2:
			x1 = w.w
		var top_ground: int = w.h
		for xx in range(x, x1):
			top_ground = mini(top_ground, int(w.surface[xx]))
		var base := top_ground - LOW_GAP
		var split := base - int(LOW_H * scale)
		if split - TOP >= HIGH_MIN * 0.5 and base > TOP + 20:
			var low := roll("basso", rng, mult)
			var high := roll("alto", rng, mult)
			for tries in 4:                           # due zone vicine con lo stesso bioma: si ritira
				if low != last_low:
					break
				low = roll("basso", rng, mult)
			for tries in 4:
				if high != last_high:
					break
				high = roll("alto", rng, mult)
			out.append({"x0": x, "x1": x1, "low": low, "high": high, "base": base, "split": maxi(split, TOP + 18)})
			last_low = low
			last_high = high
		x = x1
	return out


## Voce 157: sotto i piedi (posizione del corpo di chi atterra) c'è una nuvola?
static func soft_under(w: Object, feet_pos: Vector2) -> bool:
	var y := floori((feet_pos.y + 15.0 + 2.0) / 16.0)
	for dx in [-4.0, 0.0, 4.0]:
		var x := floori((feet_pos.x + dx) / 16.0)
		if w.tile(x, y) in CLOUDS:
			return true
	return false

