class_name ShopsData
## Le merci degli abitanti secondo il momento e il Mercante dei mondi (Roadmap 48, voce 404; dati nel pacchetto generato
## `src/data/vastita/commercio.gd`, `tools/vastita_gen/commercio.py`). Solo dati: le legge `TradePanel._goods`.
##   SHOPS     abitante → {bands: [4 fasce di vigore], seasons: [4 stagioni], night, event}: [oggetto, quantità]
##   MERCHANT  {pool: le merci rare del Mercante dei mondi, uniques: i suoi oggetti unici}

static var SHOPS: Dictionary = BiomesData.pack("shops")
static var MERCHANT: Dictionary = BiomesData.pack("merchant")
const MERCHANT_ID := "mercante_mondi"
const ROT_POOL := 7                      # merci dal suo catalogo, ogni giorno diverse
const ROT_UNIQUE := 3                    # e oggetti solo suoi


## La fascia di un mondo: vigori 1-3, 4-6, 7-9, 10 e oltre.
static func band_of(vigor: int) -> int:
	return clampi((vigor - 1) / 3, 0, 3)


## Le merci in più di un abitante adesso: quelle della fascia del mondo, della stagione (0-3, -1 = nessuna), della notte
## e di un evento in corso.
static func extra(npc: String, vigor: int, season: int, night: bool, event_on: bool) -> Array:
	var s: Dictionary = SHOPS.get(npc, {})
	if s.is_empty():
		return []
	var out: Array = ((s["bands"] as Array)[band_of(vigor)] as Array).duplicate()
	if season >= 0:
		out.append_array((s["seasons"] as Array)[season % 4])
	if night:
		out.append_array(s["night"])
	if event_on:
		out.append_array(s["event"])
	return out


## Le merci del Mercante dei mondi in un giorno: sempre le stesse per quel giorno, diverse il giorno dopo.
static func rotating(day: int) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["mercante", day])
	var pool: Array = (MERCHANT.get("pool", []) as Array).duplicate()
	var uni: Array = (MERCHANT.get("uniques", []) as Array).duplicate()
	var out := []
	for k in mini(ROT_UNIQUE, uni.size()):
		out.append([uni.pop_at(rng.randi_range(0, uni.size() - 1)), 1])
	for k in mini(ROT_POOL, pool.size()):
		out.append(pool.pop_at(rng.randi_range(0, pool.size() - 1)))
	return out


## Quante voci hanno i negozi in tutto (per lo strumento della vastità e le prove).
static func count() -> int:
	var n := 0
	for npc in SHOPS:
		var s: Dictionary = SHOPS[npc]
		for b in s["bands"]:
			n += (b as Array).size()
		for b in s["seasons"]:
			n += (b as Array).size()
		n += (s["night"] as Array).size() + (s["event"] as Array).size()
	return n + (MERCHANT.get("pool", []) as Array).size() + (MERCHANT.get("uniques", []) as Array).size()
