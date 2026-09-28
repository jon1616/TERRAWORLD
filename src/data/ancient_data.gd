class_name AncientData
extends RefCounted
## Le creature antiche (voce 20b): ogni creatura che nasce può essere **antica** o, molto più di rado, **ancestrale**,
## tanto più spesso quanto più la zona è pericolosa (`DangerData`). Hanno tratti propri che le rendono diverse da
## affrontare, un'aura e il nome in vista, e lasciano **Essenze**: al Maglio si innestano sull'equipaggiamento e gli
## danno un tratto che non esce mai a caso (`TraitsData`, campo `essence`). Solo dati e due funzioni.
## Richiesta dell'utente (25 set 2026): le creature rare e forti come parte fondamentale del gioco.

## Rarità: probabilità = base + per_danger × pericolo; quanti tratti; moltiplicatori; colore dell'aura; bottino tirato
## più volte; trophy = probabilità del **trofeo** della specie (voce 23, `TrophyItemsData`).
## Voce 23: il **capobranco** guida un branco della sua specie (`pack` compagne); l'**iridata** ha i colori che
## cambiano, non attacca e fugge, e svanisce dopo `life` secondi: lascia la Polvere iridata.
const RARITIES := {
	"antica": {"label": "Creatura antica", "short": "Antica", "base": 0.02, "per_danger": 0.018, "traits": [1, 1], "hp": 3.0,
		"damage": 1.4, "scale": 1.25, "aura": Color(1.6, 1.1, 0.4), "loot_rolls": 2, "trophy": 0.35},
	"ancestrale": {"label": "Creatura ancestrale", "short": "Ancestrale", "base": 0.0, "per_danger": 0.003, "traits": [2, 3], "hp": 7.0,
		"damage": 1.8, "scale": 1.5, "aura": Color(1.3, 0.6, 2.0), "loot_rolls": 4, "trophy": 1.0},
	"capobranco": {"label": "Capobranco", "short": "Capobranco", "base": 0.01, "per_danger": 0.006, "traits": [0, 1], "hp": 2.5,
		"damage": 1.3, "scale": 1.3, "aura": Color(0.45, 1.15, 0.5), "loot_rolls": 2, "trophy": 1.0, "pack": [2, 4]},
	"iridata": {"label": "Creatura iridata", "short": "Iridata", "base": 0.003, "per_danger": 0.0012, "traits": [0, 0], "hp": 2.0,
		"damage": 0.0, "scale": 1.1, "aura": Color(1.7, 1.7, 1.7), "loot_rolls": 3, "trophy": 1.0, "iride": true,
		"life": 75.0, "dust": [2, 4]},
}
## Voce 185 (Roadmap 18): oltre questo pericolo le rare non crescono più (al vigore 12 nel Fondo erano quasi metà
## delle creature: una rara deve restare un incontro speciale). Con 7: al più ~22% di rare, come nel Fondo del primo mondo.
const DANGER_CAP := 7.0
## L'ordine in cui si tirano (la più rara per prima).
const ORDER := ["ancestrale", "iridata", "capobranco", "antica"]

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


## Che rarità ha una creatura che nasce con questo pericolo ("" = comune). `grouped` = la specie nasce già in sciame
## (niente capobranco).
static func roll_rarity(danger: float, rng: RandomNumberGenerator, grouped := false, mult := 1.0) -> String:
	danger = minf(danger, DANGER_CAP)
	var r := rng.randf()
	var acc := 0.0
	for k in ORDER:
		var d: Dictionary = RARITIES[k]
		if k == "capobranco" and grouped:
			continue
		acc += (float(d["base"]) + float(d["per_danger"]) * danger) * mult
		if r < acc:
			return k
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
