class_name GuardianGenData
## I Guardiani generati (voce 80, Roadmap 11). Solo dati: li compone `GuardianGen`. Oltre i tre Guardiani scritti a
## mano (vigore 1, 2 e 3) ogni mondo ha un Guardiano suo, nato dal seme del mondo: il **corpo** di una specie delle
## famiglie (resa gigante, dell'elemento del Guardiano, con le spine), un **titolo**, due o tre **attacchi** scelti dalla
## libreria `ATTACKS` (solo quelli che il corpo sa fare: chi vola non carica, chi cammina non scatta in aria) e una
## **seconda fase** a metà Vita in cui cambia elemento (debolezze comprese) e diventa più svelto.
## Sconfitto lascia il **Nucleo** del suo elemento (`ITEMS`), curato la **Linfa** del suo elemento: con entrambi si
## fanno i talismani dei Guardiani (`RECIPES`).

const SCALE := 3.0                     # quanto è più grande della specie da cui nasce
const HP := [1500, 2100]               # Vita di base (poi `Portal.vigor_mult`)
const DAMAGE := [24, 32]
const DEFENSE := [10, 16]
const PHASE2 := 0.5
const DROP := 14                       # Nuclei o Linfe che lascia
## Voce 186 (Roadmap 18): gli attacchi che tirano; con due o più la loro cadenza si allunga, senza nessuno il contatto
## ferisce di più (la stessa difficoltà per ogni seme).
const SHOOTERS := ["ventaglio", "spara", "bombarda"]
const MANY_SHOTS_SLOW := 1.6
const NO_SHOTS_DAMAGE := 1.4
## Roadmap 39, voce 365: la pericolosità comune (`GuardianGen.threat`, danno al secondo stimato) e quanto ci si può
## allontanare; quanto arriva a segno di ogni attacco (frazioni a occhio, tarate con `tools/boss.gd`).
const THREAT := 12.0
const THREAT_K := [0.55, 1.4]
const HIT := {"contatto": 0.25, "move": 0.35, "ventaglio": 0.2, "spara": 0.45, "bombarda": 0.4, "evoca": 8.0}

## Le specie che non fanno da corpo: troppo piccole per leggersi, o fatte per l'acqua.
const NO_BODY := ["pesce_lume", "anguilla_linfa", "sciame_schegge", "geomimo"]

const TITLES := [["Il Patriarca", "La Matriarca"], ["Il Sovrano", "La Sovrana"], ["L'Antico", "L'Antica"],
	["Il Custode", "La Custode"], ["Il Tiranno", "La Tiranna"], ["Il Primo", "La Prima"], ["Il Gigante", "La Gigante"],
	["Il Signore", "La Signora"]]

## La libreria degli attacchi: comportamento, per chi (fly: true = solo chi vola, false = solo chi cammina, assente =
## tutti) e i parametri, con [min, max] per quelli che variano da un Guardiano all'altro.
const ATTACKS := {
	"ventaglio": {"bh": "ventaglio", "p": {"fan_rate": [2.0, 3.0], "fan_n": [5, 9], "fan_spread": [0.8, 1.4],
		"shot_speed": [150.0, 190.0], "shot_grav": 40.0, "shot_damage": [16, 22]}},
	"scatto": {"bh": "scatto", "fly": true, "p": {"dash_every": [4.5, 6.5], "dash_speed": [290.0, 340.0], "dash_time": 0.5}},
	"carica": {"bh": "carica", "fly": false, "p": {"charge": [260.0, 320.0], "charge_range": 20, "charge_time": 1.0,
		"charge_cool": [3.5, 5.0]}},
	"spara": {"bh": "spara", "p": {"rate": [2.0, 3.0], "shot_speed": [200.0, 240.0], "shot_grav": [60.0, 400.0],
		"shot_damage": [20, 26]}},
	"bombarda": {"bh": "bombarda", "fly": true, "p": {"rate": [1.8, 2.6], "shot_damage": [20, 28], "shot_grav": 420.0}},
	"salto": {"bh": "salta_verso", "fly": false, "p": {"jump": [280.0, 340.0]}},
	"lampo": {"bh": "teletrasporto", "p": {"blink_every": [4.0, 6.0]}},
	"evoca": {"bh": "evoca", "p": {"summon_every": [7.0, 10.0], "summon_max": [2, 4]}},
	# voce 136: le mosse dei tre Guardiani scritti a mano diventano pezzi dei Guardiani generati
	"pilastri": {"bh": "rimodella", "fly": false, "p": {"pillar_every": [5.5, 8.0], "pillars": [2, 3]}},
	"correnti": {"bh": "correnti", "fly": true, "p": {"gust_every": [6.0, 9.0]}},
}

## Il proiettile secondo l'elemento (aspetto di `Projectiles`).
const SHOT_LOOK := {"gelo": "gelo", "spora": "spora", "luce": "polline", "linfa": "polline", "brace": "spora", "vuoto": "spora"}

const ELEMENTS := ["brace", "gelo", "spora", "linfa", "vuoto", "luce"]
const ELEM_NAME := {"brace": "ardente", "gelo": "del gelo", "spora": "delle spore", "linfa": "della Linfa",
	"vuoto": "del Vuoto", "luce": "della luce"}

const ITEMS := {
	"nucleo_brace": {"name": "Nucleo ardente", "kind": "materiale", "icon": ["cuore", "tizzonite"], "stack": 99, "value": 120,
		"source": "un Guardiano generato di brace, sconfitto", "desc": "Il cuore di un Guardiano, ancora caldo."},
	"nucleo_gelo": {"name": "Nucleo del gelo", "kind": "materiale", "icon": ["cuore", "lagunite"], "stack": 99, "value": 120,
		"source": "un Guardiano generato del gelo, sconfitto", "desc": "Il cuore di un Guardiano, freddo come la brina."},
	"nucleo_spora": {"name": "Nucleo delle spore", "kind": "materiale", "icon": ["cuore", "nottilite"], "stack": 99, "value": 120,
		"source": "un Guardiano generato delle spore, sconfitto", "desc": "Il cuore di un Guardiano, gonfio di spore."},
	"nucleo_linfa": {"name": "Nucleo della Linfa", "kind": "materiale", "icon": ["cuore", "cristallo"], "stack": 99, "value": 120,
		"source": "un Guardiano generato della Linfa, sconfitto", "desc": "Il cuore di un Guardiano, pieno di Linfa."},
	"nucleo_vuoto": {"name": "Nucleo del Vuoto", "kind": "materiale", "icon": ["cuore", "vuotite"], "stack": 99, "value": 120,
		"source": "un Guardiano generato del Vuoto, sconfitto", "desc": "Il cuore di un Guardiano: dentro non c'è niente."},
	"nucleo_luce": {"name": "Nucleo della luce", "kind": "materiale", "icon": ["cuore", "brillaluce"], "stack": 99, "value": 120,
		"source": "un Guardiano generato della luce, sconfitto", "desc": "Il cuore di un Guardiano, che brilla da solo."},
	"linfa_gg": {"name": "Linfa dei Guardiani", "kind": "materiale", "icon": ["goccia", "cristallo"], "stack": 99, "value": 100,
		"source": "un Guardiano generato, curato", "desc": "La Linfa di un Guardiano guarito: ricorda il suo elemento."},
	"talismano_brace": {"name": "Talismano ardente", "kind": "accessorio", "icon": ["amuleto", "tizzonite"], "stack": 1,
		"acc": {"damage": 1.1, "thorns": 6}, "desc": "Danno +10%, e chi ti tocca si scotta."},
	"talismano_gelo": {"name": "Talismano del gelo", "kind": "accessorio", "icon": ["amuleto", "lagunite"], "stack": 1,
		"acc": {"regen": 1.3, "run": 1.05}, "desc": "Vita che ricresce più in fretta, passo più lungo."},
	"talismano_spora": {"name": "Talismano delle spore", "kind": "accessorio", "icon": ["amuleto", "nottilite"], "stack": 1,
		"acc": {"stealth": 0.75}, "desc": "Le creature ti vedono molto meno."},
	"talismano_linfa": {"name": "Talismano della Linfa", "kind": "accessorio", "icon": ["amuleto", "cristallo"], "stack": 1,
		"acc": {"linfa_regen": 1.5, "magic": 1.1}, "desc": "Linfa che torna più in fretta, incantesimi +10%."},
	"talismano_vuoto": {"name": "Talismano del Vuoto", "kind": "accessorio", "icon": ["amuleto", "vuotite"], "stack": 1,
		"acc": {"air_jumps": 1, "glide": true}, "desc": "Un salto in aria in più, e si plana."},
	"talismano_luce": {"name": "Talismano della luce", "kind": "accessorio", "icon": ["amuleto", "brillaluce"], "stack": 1,
		"acc": {"halo": 1.6, "luck": 0.1}, "desc": "Un alone grande, e un po' di fortuna."},
}

const RECIPES := [
	{"out": "talismano_brace", "qty": 1, "in": {"nucleo_brace": 6, "linfa_gg": 4}, "station": "maglio"},
	{"out": "talismano_gelo", "qty": 1, "in": {"nucleo_gelo": 6, "linfa_gg": 4}, "station": "maglio"},
	{"out": "talismano_spora", "qty": 1, "in": {"nucleo_spora": 6, "linfa_gg": 4}, "station": "maglio"},
	{"out": "talismano_linfa", "qty": 1, "in": {"nucleo_linfa": 6, "linfa_gg": 4}, "station": "maglio"},
	{"out": "talismano_vuoto", "qty": 1, "in": {"nucleo_vuoto": 6, "linfa_gg": 4}, "station": "maglio"},
	{"out": "talismano_luce", "qty": 1, "in": {"nucleo_luce": 6, "linfa_gg": 4}, "station": "maglio"},
]
