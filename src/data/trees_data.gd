class_name TreesData
extends RefCounted
## Gli alberi (26 set 2026, richiesta dell'utente: «alberi di varie grandezze, e ogni bioma con la sua vegetazione»).
## Ogni bioma di superficie ha la sua **specie** (disegno in `TreeArt`) e ogni albero ha una **grandezza** e una
## **forma**; i tre numeri stanno in un intero solo, la variante che `World.trees` salva per ogni albero
## (`encode`/`decode`). Solo dati; li usano il generatore (`PassAlberi`), la crescita dei germogli (`Growth`), l'ascia
## (`PlayerActions`) e la vista (`ViewProps`, che disegna ogni combinazione una volta sola).

## Le specie, nell'ordine dei biomi di `BiomesData` (foresta, palude, ambra, brina, cenere).
const SPECIES := [
	{"id": "lanterna", "name": "Albero-lanterna", "biome": "foresta", "glow": Color(1.6, 1.5, 1.3)},
	{"id": "fungo", "name": "Fungo-albero", "biome": "palude", "glow": Color(1.5, 1.2, 1.8)},
	{"id": "acacia", "name": "Acacia d'ambra", "biome": "ambra", "glow": Color(1.7, 1.4, 0.9)},
	{"id": "abete", "name": "Abete di brina", "biome": "brina", "glow": Color(1.2, 1.5, 1.8)},
	{"id": "tizzone", "name": "Tizzone", "biome": "cenere", "glow": Color(1.9, 1.2, 0.8)},
]

## Le grandezze: altezza del disegno in pixel, robustezza (ogni colpo d'ascia toglie la forza dell'ascia: radicite 35),
## legno che lasciano, peso nel tiro a caso. «Antico» è raro e altissimo.
const SIZES := [
	{"name": "piccolo", "h": 64, "hp": 60, "wood": [3, 5], "weight": 30},
	{"name": "medio", "h": 96, "hp": 100, "wood": [6, 9], "weight": 40},
	{"name": "grande", "h": 128, "hp": 150, "wood": [9, 13], "weight": 24},
	{"name": "antico", "h": 164, "hp": 230, "wood": [14, 20], "weight": 6},
]
const FORMS := 3                       # forme diverse per specie e grandezza


static func encode(species: int, size: int, form: int) -> int:
	return species * 64 + size * 8 + form


## [specie, grandezza, forma] di una variante.
static func decode(v: int) -> Array:
	return [clampi(v / 64, 0, SPECIES.size() - 1), clampi((v % 64) / 8, 0, SIZES.size() - 1), (v % 8) % FORMS]


static func size_of(v: int) -> Dictionary:
	return SIZES[decode(v)[1]]


## Quante tessere è alto un albero di questa variante (per lo spazio che serve e per colpirlo con l'ascia).
static func tiles_high(v: int) -> int:
	return ceili(float(size_of(v)["h"]) / 16.0)


## La specie di un bioma (indice di `BiomesData.BIOMES`).
static func species_of_biome(biome: int) -> int:
	var id := String(BiomesData.BIOMES[clampi(biome, 0, BiomesData.BIOMES.size() - 1)]["id"])
	for i in SPECIES.size():
		if SPECIES[i]["biome"] == id:
			return i
	return 0


## Una variante a caso per un bioma, con al più `room` tessere di spazio libero in altezza.
static func roll(rng: RandomNumberGenerator, biome: int, room := 99) -> int:
	var tot := 0
	for s in SIZES:
		tot += int(s["weight"])
	var v := rng.randi_range(1, tot)
	var size := 0
	for i in SIZES.size():
		v -= int(SIZES[i]["weight"])
		if v <= 0:
			size = i
			break
	while size > 0 and ceili(float(SIZES[size]["h"]) / 16.0) > room:
		size -= 1
	return encode(species_of_biome(biome), size, rng.randi_range(0, FORMS - 1))
