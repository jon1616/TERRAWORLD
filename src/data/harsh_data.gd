class_name HarshData
## I rigori delle terre estreme (voce 93, Roadmap 12). Solo dati: le regole in `Harshness`. Un bioma estremo ha il
## campo `harsh` ({kind, rate, night}): allo scoperto in superficie una barra di quel rigore sale (piena in 1/rate
## secondi, di notte × night); piena, ferisce e toglie qualcosa. Scende altrove, al riparo sotto un tetto, accanto a un
## Rifugio del viandante (totem, `ZonesData`) o con il rimedio giusto. Ci si **prepara**: l'equipaggiamento che
## protegge (campo `acc` con la chiave `ripara`) si fa con materiali di altri biomi, e i rimedi sono pozioni a tempo.
##
##   name, color, desc   la barra e le schede
##   acc                 la chiave degli accessori che protegge (0-1, si sommano fino a 1)
##   boon                il rimedio che protegge del tutto finché dura (`Boons`)
##   hurt, every         la ferita quando la barra è piena, ogni quanti secondi
##   penalty             cosa toglie a barra piena: run (corsa ×), regen (niente ricrescita), linfa (la Linfa cala),
##                       jump (salto ×)

const KINDS := {
	"freddo": {"name": "Freddo", "color": "#9ad8ff", "acc": "caldo", "boon": "riparo_freddo", "hurt": 4, "every": 2.0,
		"penalty": {"run": 0.7}, "desc": "il gelo ti entra nelle ossa: a barra piena corri più piano e ti ferisci"},
	"sete": {"name": "Sete", "color": "#ffd070", "acc": "acqua", "boon": "riparo_sete", "hurt": 3, "every": 2.0,
		"penalty": {"regen": 0.0}, "desc": "la sabbia di vetro asciuga tutto: a barra piena la Vita non ricresce"},
	"calore": {"name": "Calore", "color": "#ff7a3a", "acc": "fresco", "boon": "riparo_calore", "hurt": 5, "every": 2.0,
		"penalty": {"linfa": 1.0}, "desc": "l'aria brucia: a barra piena la Linfa cala e ti scotti"},
	"polvere": {"name": "Polvere di pietra", "color": "#b8b0a0", "acc": "filtro", "boon": "riparo_polvere", "hurt": 3, "every": 2.5,
		"penalty": {"jump": 0.7, "run": 0.85}, "desc": "la polvere pietrifica: a barra piena salti e corri meno"},
	# Roadmap 16, voce 158: nel cielo alto (campo `thin` dei biomi del cielo, `QUOTA_RATE` × thin)
	"quota": {"name": "Aria sottile", "color": "#c8d0ff", "acc": "quota", "boon": "respiro_alto", "hurt": 4, "every": 2.5,
		"boon_name": "Respiro alto", "penalty": {"jump": 0.8, "linfa": 0.6},
		"desc": "lassù l'aria manca: a barra piena salti meno, la Linfa cala e il fiato ferisce"},
	# voce 354: nel Fondo, lontano dalla luce (`DeepRulesData`: rigor, rate, lit)
	"vuoto": {"name": "Peso del Vuoto", "color": "#c08aff", "acc": "quieto", "boon": "riparo_vuoto", "hurt": 5, "every": 2.5,
		"boon_name": "Quiete del Vuoto", "penalty": {"regen": 0.0, "linfa": 0.5},
		"desc": "nel Fondo il buio pesa: a barra piena la Vita non ricresce, la Linfa cala e fa male. La luce lo tiene lontano"},
}

const QUOTA_RATE := 1.0 / 45.0         # voce 158: nel cielo alto la barra si riempie in 45 s (× `thin` del bioma)

const DECAY := 1.0 / 20.0              # quanto scende la barra al secondo fuori dal rigore (vuota in 20 s)
const ROOF := 0.25                     # sotto un tetto sale a un quarto
const HURT_TILE_EVERY := 1.0           # il terreno che ferisce: ogni quanti secondi


## Il nome del rimedio (per `Boons.NAMES`).
static func boon_names() -> Dictionary:
	var out := {}
	for k in KINDS:
		if KINDS[k].has("boon_name"):
			out[String(KINDS[k]["boon"])] = String(KINDS[k]["boon_name"])
			continue
		out[String(KINDS[k]["boon"])] = "Riparo dal " + String(KINDS[k]["name"]).to_lower() if k != "sete" \
			else "Riparo dalla sete"
	return out
