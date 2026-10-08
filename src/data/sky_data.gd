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
##   bolts, gusts            voce 164: fulmini che cadono da soli (Nidi di tempesta), raffiche che spingono (Giardini)
##   ores                    voce 159: [[tessera, quota delle celle]] le vene nel corpo delle isole (nimbite, folgorite)
##   thin                    voce 158: quanto svelta sale la barra dell'aria sottile (0 = niente)
##   elem                    l'elemento più probabile delle varianti che nascono qui
##   adj                     gli aggettivi dei nomi dei mondi per il gene del bioma: [maschile, femminile] (`NamesData`)

const LOW_GAP := 25                    # tessere tra la superficie più alta della zona e il fondo del cielo basso
const TOP := 10                        # righe libere in cima al mondo
## Voce 442 (8 ott 2026, «Il cielo grande»): tre fasce, in frazione del cielo di una zona (da `TOP` al fondo del cielo
## basso): il **basso** (raggiungibile dal primo giorno), il **medio** (il cuore del cielo: i continenti), l'**alto** (il
## resto fino al bordo: l'aria sottile, le creature forti). In un mondo da 1200 righe sono ~90, ~165 e ~120 righe; nei
## mondi più bassi delle prove si accorciano insieme.
const BANDS := ["basso", "medio", "alto"]
const BAND_FRAC := {"basso": 0.24, "medio": 0.44}
const SKY_MIN := 60                    # righe di cielo che servono a una zona (altrimenti niente cielo lì)
const ZONE_MIN := 300                  # lunghezza di una zona, in colonne
const ZONE_MAX := 520
const SPAWN_FREE := 24                 # colonne sopra la partenza senza isole (voce 442: prima 60, un buco nel cielo)
const SPAWN_NEAR := 140                # entro tante colonne dalla partenza le isole basse sono piccole e facili
## Voce 443: i continenti sospesi del cielo di mezzo (`SkyContinents`): quanti per zona, mezza larghezza, spessore della
## chiglia, soglie delle grotte (sale e gallerie), ogni quante colonne della cima alberi e pozze; sotto `min_zone`
## colonne di zona uno solo.
## Voce 444: i mari di nuvole (strisce di tessera 52 su cui si cammina e si cade morbidi): probabilità per fascia
## (nel Mare di nuvole sempre), lunghezza, spessore.
const CLOUD_SEA := {"basso": 0.65, "medio": 0.35, "len": [50, 140], "thick": [2, 4]}
## Voce 445: il luogo dei Seminatori sulla cima di ogni continente: un progetto di `ProjectsData` secondo il bioma
## ("_" = gli altri), con uno scrigno del cielo e una stele.
const SANCTUARY := {"selve_pensili": "serra", "fonti_sospese": "pozzo", "scogliere_cristallo": "faro", "_": "torre"}
const CONTINENT := {"per_zone": [1, 2], "min_zone": 380, "half": [50, 140], "thick": [30, 62], "cave": 0.4,
	"worm": 0.03, "extras_every": 26}
const SKY_SHARE := 0.85                # voce 160: quante nascite in cielo sono creature del cielo

const CLOUDS := [52, 53]               # le tessere di nuvola: attutiscono le cadute (`Life._on_landed`)
const BEAN_STEP := 3                   # voce 157: righe tra due passerelle della liana del Fagiolo
const BEAN_H := 120                    # quanto sale al più una liana, in tessere (voce 444: prima 40; attraversa le isole)
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


## La zona del cielo di una colonna ({x0, x1, low, mid, high, base, split, split_mh} oppure vuoto). `base` = la riga
## sotto cui finisce il cielo basso; `split` = il confine tra basso e medio; `split_mh` tra medio e alto. Le zone salvate
## prima della voce 442 non hanno `mid` né `split_mh`: lì `split` divide il basso dall'alto, come allora.
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
	if z.has("mid") and y > int(z["split_mh"]):
		return String(z["mid"])
	return String(z["high"])


## Voce 442: il bioma di una fascia in una zona ("" se la zona non ha quella fascia: le zone di prima non hanno il medio).
static func band_biome(z: Dictionary, band: String) -> String:
	match band:
		"basso":
			return String(z.get("low", ""))
		"medio":
			return String(z.get("mid", ""))
	return String(z.get("high", ""))


## Voce 442: le righe di una fascia in una zona, [la più alta, la più bassa] (vuoto se la zona non l'ha).
static func band_rows(z: Dictionary, band: String) -> Array:
	match band:
		"basso":
			return [int(z["split"]) + 1, int(z["base"])]
		"medio":
			return [int(z["split_mh"]) + 1, int(z["split"])] if z.has("mid") else []
	return [TOP, int(z["split_mh"]) if z.has("mid") else int(z["split"])]


## Voce 442: quanto è in alto una fascia (1 basso, 2 medio, 3 alto; 0 = non è cielo).
static func band_level(band: String) -> int:
	return BANDS.find(band) + 1


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


## Le zone di un mondo: tratti di ZONE_MIN-ZONE_MAX colonne con un bioma per fascia; `base` dalla superficie più alta
## del tratto, le fasce in frazione del cielo che resta (`BAND_FRAC`). Nessuna zona se il cielo non ci sta (montagne fino
## al cielo). `scale` (gene «Cieli alti») allunga la fascia bassa; `mult` i pesi dei biomi.
static func make_zones(w: Object, rng: RandomNumberGenerator, scale: float = 1.0, mult: Dictionary = {}) -> Array:
	var out := []
	var x := 0
	var last_low := ""
	var last_mid := ""
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
		var sky := base - TOP
		if sky >= SKY_MIN:
			var split := base - int(sky * minf(float(BAND_FRAC["basso"]) * scale, 0.4))
			var split_mh := split - int(sky * float(BAND_FRAC["medio"]))
			var low := _roll_not("basso", rng, mult, last_low)        # due zone vicine con lo stesso bioma: si ritira
			var mid := _roll_not("medio", rng, mult, last_mid)
			var high := _roll_not("alto", rng, mult, last_high)
			out.append({"x0": x, "x1": x1, "low": low, "mid": mid, "high": high, "base": base, "split": split,
				"split_mh": split_mh})
			last_low = low
			last_mid = mid
			last_high = high
		x = x1
	return out


static func _roll_not(band: String, rng: RandomNumberGenerator, mult: Dictionary, last: String) -> String:
	var id := roll(band, rng, mult)
	for tries in 4:
		if id != last:
			break
		id = roll(band, rng, mult)
	return id


static var _sky_tiles := {}


## Voce 444: una tessera del cielo (le isole, le nuvole, i continenti): il Fagiolo di nuvola ci passa attraverso.
static func is_sky_tile(t: int) -> bool:
	if _sky_tiles.is_empty():
		for b in BIOMES:
			for k in ["floor", "body", "rock"]:
				if b.has(k):
					_sky_tiles[int(b[k])] = true
			for t2 in (b.get("tiles", {}) as Dictionary):
				_sky_tiles[int(t2)] = true
		for o in [57, 58]:                        # nimbite e folgorite, le vene delle isole
			_sky_tiles[o] = true
	return _sky_tiles.has(t)


## Voce 157: sotto i piedi (posizione del corpo di chi atterra) c'è una nuvola?
static func soft_under(w: Object, feet_pos: Vector2) -> bool:
	var y := floori((feet_pos.y + 15.0 + 2.0) / 16.0)
	for dx in [-4.0, 0.0, 4.0]:
		var x := floori((feet_pos.x + dx) / 16.0)
		if w.tile(x, y) in CLOUDS:
			return true
	return false


static var _pools := {}


## Voce 160: le creature che nascono in un bioma del cielo: [[id, peso]] (quelle della notte solo di notte).
static func pool_of(id: String, night: bool) -> Array:
	if _pools.is_empty():
		var all_cr := BiomesData.pack("creatures")
		for cid in all_cr:
			var cd: Dictionary = all_cr[cid]
			var sid := String(cd.get("sky", ""))
			if sid != "":
				if not _pools.has(sid):
					_pools[sid] = []
				(_pools[sid] as Array).append([cid, int(cd.get("sw", 1)), bool(cd.get("night", false))])
	var out := []
	for e in _pools.get(id, []):
		if (night or not bool(e[2])) and (CreaturesData.awake_on or not bool(CreaturesData.CREATURES.get(String(e[0]), {}).get("awake", false))):
			out.append([e[0], e[1]])
	return out

