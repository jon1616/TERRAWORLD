class_name VeinsData
extends RefCounted
## Roadmap 19 «La Linfa che scorre» (voce 191): le vene del Flusso e i fili dell'Impulso. Solo dati; lo strato è
## `World.vein` (un byte per cella), il disegno `VeinPainter`, la posa `Veins` (la Pinza delle vene), le reti `Energy`.
##
## Un byte per cella:
##   bit 0-2  grado della vena del Flusso (0 nessuna, 1-4 = `TIERS`)
##   bit 3    isolata: non si collega alle vene vicine di un altro grado (per incrociare due reti)
##   bit 4-7  i quattro fili dell'Impulso (`WIRES`), uno per bit: passano nella stessa cella senza toccarsi

const TIER_MASK := 7
const INSULATED := 8
const WIRE_SHIFT := 4

## I gradi delle vene: portata in pulsi, l'oggetto che si posa, i colori del disegno (corpo, ombra, anima luminosa).
const TIERS := [
	{},
	{"id": "radice", "name": "Vena di radice", "cap": 30, "item": "vena_radice", "body": Color("#b08a5a"),
		"dark": Color("#4a3020"), "core": Color("#8ef0d8"), "gnaw": true},
	{"id": "legnoferro", "name": "Vena di legnoferro", "cap": 100, "item": "vena_legnoferro", "body": Color("#6a5652"),
		"dark": Color("#2a1e22"), "core": Color("#5cc8cc")},
	{"id": "ambra", "name": "Vena d'ambra", "cap": 300, "item": "vena_ambra", "body": Color("#8a5a2a"),
		"dark": Color("#3a2410"), "core": Color("#ffb84a")},
	{"id": "cristallo", "name": "Vena di cristallo", "cap": 1000, "item": "vena_cristallo", "body": Color("#3a8a8e"),
		"dark": Color("#123a40"), "core": Color("#c0ffff")},
]

## I quattro fili dell'Impulso.
const WIRES := [
	{"id": "turchese", "name": "Filo turchese", "item": "filo_turchese", "color": Color("#5cf0e0")},
	{"id": "ambra", "name": "Filo d'ambra", "item": "filo_ambra", "color": Color("#ffc050")},
	{"id": "corallo", "name": "Filo corallo", "item": "filo_corallo", "color": Color("#ff8a6a")},
	{"id": "viola", "name": "Filo viola", "item": "filo_viola", "color": Color("#c090ff")},
]

## I modi della Pinza: prima i quattro gradi di vena, poi i quattro fili.
const MODES := 8


static func tier(b: int) -> int:
	return b & TIER_MASK


static func has_wire(b: int, color: int) -> bool:
	return b & (1 << (WIRE_SHIFT + color)) != 0


## Il nome di un modo della Pinza (0-3 vene, 4-7 fili).
static func mode_name(mode: int) -> String:
	return String(TIERS[mode + 1]["name"]) if mode < 4 else String(WIRES[mode - 4]["name"])


## L'oggetto che un modo posa.
static func mode_item(mode: int) -> String:
	return String(TIERS[mode + 1]["item"]) if mode < 4 else String(WIRES[mode - 4]["item"])


## Il modo che posa un oggetto (-1 se non è una vena né un filo).
static func mode_of_item(id: String) -> int:
	for k in MODES:
		if mode_item(k) == id:
			return k
	return -1


## Due celle di vena vicine si collegano? Stesso grado sempre; gradi diversi solo se nessuna delle due è isolata.
static func joins(a: int, b: int) -> bool:
	var ta := a & TIER_MASK
	var tb := b & TIER_MASK
	if ta == 0 or tb == 0:
		return false
	if ta == tb:
		return true
	return a & INSULATED == 0 and b & INSULATED == 0
