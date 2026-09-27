class_name VigorData
## Il vigore senza tetto (voce 79, Roadmap 11). Solo dati: li usano `Vigor`, `FamiliesData` e `Gear`.
## Il vigore di un mondo sale per sempre (ogni Seme raccolto porta al mondo dopo); ogni `STEP` punti arriva un **grado**,
## e ogni grado porta cose nuove, non solo numeri più alti:
##   una **indole** nuova delle creature (`TEMPERS`: corazzate, rigeneranti, gemelle, voraci; dal quinto grado tutte più
##   frequenti), che si aggiunge a docile, feroce e timida;
##   le **Schegge di vigore**, che solo le creature dei mondi di grado 1+ lasciano (di più più alto è il grado);
##   la **tempra** al Maglio dei Seminatori: ogni livello rafforza un attrezzo, un'arma o un'armatura, e ogni
##   `TEMPER_SLOT` livelli apre un posto d'innesto in più; il Maglio tempra fino a `TEMPER_PER_GRADE` livelli per grado
##   del mondo in cui si trova, quindi le tempre alte si fanno solo nei mondi più vigorosi.

const STEP := 5
## Voce 99, il bilancio: quanto crescono Vita e danno delle creature con il vigore. Fino al vigore 5 +35% per punto,
## poi +20%: con la sola crescita lineare a vigore 20 una creatura della Superficie voleva 32 colpi e ne bastavano 2
## per appassire (`tools/bilancio.gd`). La usano `Portal.vigor_mult`, i testi e lo strumento del bilancio.
const CREATURE_STEP := 0.35
const CREATURE_SOFT := 5
const CREATURE_STEP_HIGH := 0.2


static func creature_mult(v: int) -> float:
	return 1.0 + CREATURE_STEP * mini(v - 1, CREATURE_SOFT - 1) + CREATURE_STEP_HIGH * maxi(v - CREATURE_SOFT, 0)

## Le indoli dei gradi (le legge `FamiliesData.make`): hp, damage, speed, sight moltiplicano; regen = Vita al secondo
## (frazione della Vita piena); split = sconfitta, si divide in due piccole.
const TEMPERS := {
	"corazzata": {"grade": 1, "hp": 1.9, "speed": 0.85, "adj": ["corazzato", "corazzata"],
		"desc": "Vita quasi doppia, ma più lenta"},
	"rigenerante": {"grade": 2, "hp": 1.2, "regen": 0.04, "adj": ["rigenerante", "rigenerante"],
		"desc": "si rimargina da sola: va finita in fretta"},
	"gemella": {"grade": 3, "split": true, "adj": ["gemello", "gemella"],
		"desc": "sconfitta, si divide in due creature piccole"},
	"vorace": {"grade": 4, "damage": 1.55, "speed": 1.3, "sight": 2.0, "adj": ["vorace", "vorace"],
		"desc": "colpisce forte, corre e ti vede da lontano"},
}
## Probabilità che una creatura nasca con un'indole di grado (per grado del mondo, fino a `TEMPER_MAX`).
const TEMPER_CHANCE := 0.07
const TEMPER_MAX := 0.45

## Le Schegge: probabilità per creatura sconfitta (per grado, fino a 0,6) e quante ne lascia un boss per grado.
const SHARD_CHANCE := 0.06
const SHARD_BOSS := 4

## La tempra: +`TEMPER_MULT` a danno e Scorza per livello, +`TEMPER_POWER` alla forza del piccone, un posto d'innesto
## ogni `TEMPER_SLOT` livelli. Costo del livello n: n × `TEMPER_COST` Schegge.
const TEMPER_MULT := 0.08
const TEMPER_POWER := 4
const TEMPER_SLOT := 3
const TEMPER_PER_GRADE := 2
const TEMPER_COST := 4

const ITEMS := {
	"scheggia_vigore": {"name": "Scheggia di vigore", "kind": "materiale", "icon": ["scaglia", "brillaluce"], "stack": 999,
		"value": 30, "used_for": "la tempra al Maglio dei Seminatori", "source": "creature dei mondi di vigore 5 e oltre (di più più il mondo è vigoroso), e i loro Guardiani",
		"desc": "Un frammento della forza di un mondo vigoroso. Al Maglio dei Seminatori tempra gli attrezzi."},
}


static func grade(vigor: int) -> int:
	return maxi(vigor, 0) / STEP


## Le indoli di grado che un mondo di questo grado può avere.
static func tempers_for(g: int) -> Array:
	var out := []
	for t in TEMPERS:
		if int(TEMPERS[t]["grade"]) <= g:
			out.append(t)
	return out


## Fino a che livello tempra il Maglio in un mondo di questo grado.
static func temper_cap(g: int) -> int:
	return g * TEMPER_PER_GRADE


## Il nome del grado per le schede: «grado 3 (vigore 15-19)».
static func grade_name(g: int) -> String:
	return "grado %d (vigore %d-%d)" % [g, g * STEP, g * STEP + STEP - 1]
