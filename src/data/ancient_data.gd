class_name AncientData
extends RefCounted
## Le creature antiche (voce 20b): ogni creatura che nasce può essere **antica** o, molto più di rado, **ancestrale**,
## tanto più spesso quanto più la zona è pericolosa (`DangerData`). Hanno tratti propri che le rendono diverse da
## affrontare, un'aura e il nome in vista, e lasciano **Essenze**: al Maglio si innestano sull'equipaggiamento e gli
## danno un tratto che non esce mai a caso (`TraitsData`, campo `essence`). Solo dati e due funzioni.
## Richiesta dell'utente (25 set 2026): le creature rare e forti come parte fondamentale del gioco.

## Rarità: probabilità = base + per_danger × pericolo; quanti tratti; moltiplicatori; colore dell'aura; bottino tirato
## più volte.
const RARITIES := {
	"antica": {"label": "Creatura antica", "short": "Antica", "base": 0.02, "per_danger": 0.018, "traits": [1, 1], "hp": 3.0,
		"damage": 1.4, "scale": 1.25, "aura": Color(1.6, 1.1, 0.4), "loot_rolls": 2},
	"ancestrale": {"label": "Creatura ancestrale", "short": "Ancestrale", "base": 0.0, "per_danger": 0.003, "traits": [2, 3], "hp": 7.0,
		"damage": 1.8, "scale": 1.5, "aura": Color(1.3, 0.6, 2.0), "loot_rolls": 4},
}

## Tratti delle creature (aggettivi al femminile: si legge «Creatura antica · Furiosa, Corazzata»). Ognuno lascia la sua
## Essenza. Campi: name, desc, essence (oggetto), weight, e gli effetti letti da `Creature.make_ancient` e da `Combat`.
const TRAITS := {
	"furiosa": {"name": "Furiosa", "desc": "colpisce molto più forte", "essence": "essenza_furia", "weight": 10, "damage": 1.5},
	"corazzata": {"name": "Corazzata", "desc": "guscio durissimo, non si lascia spingere", "essence": "essenza_guscio",
		"weight": 10, "defense": 10, "knock": 0.8},
	"rapida": {"name": "Rapida", "desc": "si muove molto più in fretta", "essence": "essenza_fulmine", "weight": 10, "speed": 1.6},
	"gigante": {"name": "Gigante", "desc": "enorme e resistente", "essence": "essenza_vastita", "weight": 6, "hp": 1.6, "size": 1.35},
	"velenosa": {"name": "Velenosa", "desc": "il suo tocco avvelena", "essence": "essenza_veleno", "weight": 8, "poison": 5.0},
	"spinosa": {"name": "Spinosa", "desc": "chi la colpisce da vicino si ferisce", "essence": "essenza_spine", "weight": 7, "thorns": 0.3},
	"rigenerante": {"name": "Rigenerante", "desc": "ricresce se non la finisci in fretta", "essence": "essenza_linfa",
		"weight": 7, "regen": 0.025},
	"evocatrice": {"name": "Evocatrice", "desc": "chiama altre creature come lei", "essence": "essenza_richiamo", "weight": 5,
		"summon": 3},
	"luminosa": {"name": "Luminosa", "desc": "brilla nel buio e acceca", "essence": "essenza_luce", "weight": 6, "light": true},
	"esplosiva": {"name": "Esplosiva", "desc": "morendo scoppia", "essence": "essenza_scoppio", "weight": 6, "explode": 30},
	"evanescente": {"name": "Evanescente", "desc": "quasi invisibile finché non è vicina", "essence": "essenza_ombra",
		"weight": 5, "fade": true},
}

## Un'ancestrale si annuncia (avviso e suono) se nasce entro questa distanza (tessere).
const ANNOUNCE := 60


## Che rarità ha una creatura che nasce con questo pericolo ("" = comune).
static func roll_rarity(danger: float, rng: RandomNumberGenerator) -> String:
	var r := rng.randf()
	var a: Dictionary = RARITIES["ancestrale"]
	if r < float(a["base"]) + float(a["per_danger"]) * danger:
		return "ancestrale"
	var b: Dictionary = RARITIES["antica"]
	if r < float(b["base"]) + float(b["per_danger"]) * danger:
		return "antica"
	return ""


## I tratti di una creatura rara (diversi tra loro).
static func roll_traits(rarity: String, rng: RandomNumberGenerator) -> Array:
	var span: Array = RARITIES[rarity]["traits"]
	var n := rng.randi_range(int(span[0]), int(span[1]))
	var pool := TRAITS.keys()
	var out := []
	while out.size() < n and not pool.is_empty():
		var tot := 0
		for t in pool:
			tot += int(TRAITS[t]["weight"])
		var v := rng.randi_range(1, tot)
		for t in pool:
			v -= int(TRAITS[t]["weight"])
			if v <= 0:
				out.append(t)
				pool.erase(t)
				break
	return out
