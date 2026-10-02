class_name ImpactData
extends RefCounted
## Roadmap 35, voce 335: i frammenti dei colpi e dello scavo, come dati. Li esegue `ImpactFx` (`src/art/impact_fx.gd`).
## Ogni effetto è un elenco di getti di particelle; un getto:
##   n      quante                        life   secondi
##   v      [min, max] velocità (px/s)    g      gravità verso il basso (negativa = salgono)
##   spread ventaglio in gradi (180 = tutto attorno), dir = [x, y] la direzione di mezzo (verso l'alto se manca)
##   size   [min, max] grandezza          rect   [x, y] metà del riquadro da cui partono
##   cols   colori (testo) oppure "pal" = i colori del blocco; glow = moltiplica i colori (oltre 1 = brilla)
##   lit    true = sopra il buio (scintille, braci: si vedono anche senza luce); senza = la luce le scurisce
##   damp   quanto rallentano

const SPARK := ["#ffe8b0", "#ffc070"]

## Lo scavo: che cosa fa il blocco quando si rompe (e un pizzico a ogni colpo di piccone: `CHIP`).
const DIG := {
	"terra": [
		{"n": 16, "life": 0.8, "v": [25.0, 95.0], "g": 520.0, "spread": 160.0, "size": [1.0, 2.6], "rect": [6, 6], "cols": "pal"},
		{"n": 7, "life": 1.1, "v": [6.0, 22.0], "g": -12.0, "spread": 180.0, "size": [2.0, 4.0], "rect": [6, 4], "cols": "pal", "fade": 0.45, "damp": 10.0},
	],
	"roccia": [
		{"n": 12, "life": 0.6, "v": [45.0, 130.0], "g": 620.0, "spread": 150.0, "size": [1.0, 2.2], "rect": [6, 6], "cols": "pal"},
		{"n": 6, "life": 0.28, "v": [90.0, 180.0], "g": 260.0, "spread": 170.0, "size": [1.0, 1.0], "rect": [3, 3], "cols": SPARK, "glow": 2.6, "lit": true},
	],
	"minerale": [
		{"n": 12, "life": 0.6, "v": [45.0, 130.0], "g": 620.0, "spread": 150.0, "size": [1.0, 2.2], "rect": [6, 6], "cols": "pal"},
		{"n": 9, "life": 0.55, "v": [30.0, 100.0], "g": 320.0, "spread": 180.0, "size": [1.0, 1.6], "rect": [5, 5], "cols": "bright", "glow": 2.2, "lit": true},
	],
	"cristallo": [
		{"n": 14, "life": 0.75, "v": [50.0, 150.0], "g": 460.0, "spread": 170.0, "size": [1.0, 2.6], "rect": [6, 6], "cols": "pal", "glow": 1.5, "lit": true},
		{"n": 8, "life": 0.9, "v": [10.0, 35.0], "g": -6.0, "spread": 180.0, "size": [1.0, 1.0], "rect": [7, 7], "cols": ["#d8fff8"], "glow": 2.4, "lit": true, "damp": 8.0},
	],
	"legno": [
		{"n": 12, "life": 0.7, "v": [40.0, 120.0], "g": 540.0, "spread": 140.0, "size": [1.0, 3.0], "rect": [5, 6], "cols": "pal"},
	],
}
## A ogni colpo di piccone: qualche briciola (uguale per tutti, del colore del blocco); la roccia una scintilla.
const CHIP := {"n": 4, "life": 0.45, "v": [30.0, 80.0], "g": 560.0, "spread": 120.0, "size": [1.0, 1.8], "rect": [4, 4], "cols": "pal"}
const CHIP_SPARK := {"n": 2, "life": 0.2, "v": [70.0, 140.0], "g": 200.0, "spread": 150.0, "size": [1.0, 1.0], "rect": [2, 2], "cols": SPARK, "glow": 2.6, "lit": true}

## Voce 336: lo spruzzo di chi entra o esce da un liquido (i colori del liquido) e la schiuma ai piedi delle cascate.
const SPLASH := {"n": 16, "life": 0.6, "v": [60.0, 150.0], "g": 520.0, "spread": 40.0, "size": [1.0, 2.0], "rect": [6, 1], "cols": "pal", "glow": 1.1}
const FOAM := {"n": 3, "life": 0.4, "v": [20.0, 60.0], "g": 300.0, "spread": 70.0, "size": [1.0, 1.6], "rect": [3, 1], "cols": "pal", "fade": 0.8}

## Il colpo: uno schizzo dell'elemento (senza elemento: due scintille).
const HIT := {
	"": [{"n": 5, "life": 0.22, "v": [60.0, 130.0], "g": 200.0, "spread": 120.0, "size": [1.0, 1.0], "rect": [3, 3], "cols": SPARK, "glow": 2.2, "lit": true}],
	"brace": [{"n": 10, "life": 0.6, "v": [20.0, 70.0], "g": -60.0, "spread": 120.0, "size": [1.0, 2.0], "rect": [5, 5], "cols": ["#ffd070", "#ff7a30", "#c83a1a"], "glow": 2.4, "lit": true, "damp": 30.0}],
	"gelo": [{"n": 9, "life": 0.55, "v": [40.0, 110.0], "g": 420.0, "spread": 160.0, "size": [1.0, 2.0], "rect": [4, 4], "cols": ["#e8fbff", "#8ad8ff"], "glow": 1.6, "lit": true}],
	"spora": [{"n": 10, "life": 0.9, "v": [8.0, 30.0], "g": -8.0, "spread": 180.0, "size": [1.5, 3.0], "rect": [6, 6], "cols": ["#d8b0ff", "#9a6ad8", "#7ac870"], "glow": 1.3, "lit": true, "damp": 12.0, "fade": 0.7}],
	"linfa": [{"n": 9, "life": 0.6, "v": [30.0, 90.0], "g": 520.0, "spread": 140.0, "size": [1.0, 2.0], "rect": [4, 4], "cols": ["#b8fff0", "#5cf0d8"], "glow": 2.0, "lit": true}],
	"vuoto": [{"n": 10, "life": 0.5, "v": [40.0, 90.0], "g": 0.0, "spread": 180.0, "size": [1.0, 2.0], "rect": [8, 8], "cols": ["#e0b0ff", "#b070ff", "#5a2a9a"], "glow": 2.0, "lit": true, "damp": 160.0}],
	"luce": [{"n": 12, "life": 0.3, "v": [90.0, 200.0], "g": 0.0, "spread": 180.0, "size": [1.0, 1.4], "rect": [2, 2], "cols": ["#ffffff", "#fff08a"], "glow": 3.0, "lit": true, "damp": 200.0}],
}

## La sconfitta: la creatura si disfa secondo la sua natura (`BondsData.nature_of`) o il suo elemento; le altre in
## frammenti del loro verde e uno sbuffo.
const DEATH := {
	"": [
		{"n": 14, "life": 0.8, "v": [30.0, 100.0], "g": 380.0, "spread": 160.0, "size": [1.0, 2.6], "rect": [7, 6], "cols": ["#8ad870", "#4a9a5a", "#c8e8a0"]},
		{"n": 10, "life": 0.7, "v": [10.0, 40.0], "g": -20.0, "spread": 180.0, "size": [2.0, 3.5], "rect": [7, 6], "cols": ["#f0e8d0"], "glow": 1.2, "fade": 0.5, "lit": true, "damp": 20.0},
	],
	"avvizzita": [
		{"n": 18, "life": 1.2, "v": [10.0, 45.0], "g": 60.0, "spread": 180.0, "size": [1.5, 3.0], "rect": [8, 8], "cols": ["#8a8478", "#5a544c", "#3a3430"], "fade": 0.8, "damp": 15.0},
	],
	"vuoto": [
		{"n": 18, "life": 0.9, "v": [20.0, 60.0], "g": -30.0, "spread": 180.0, "size": [1.0, 2.0], "rect": [8, 8], "cols": ["#e0b0ff", "#b070ff", "#5a2a9a"], "glow": 2.0, "lit": true, "damp": 25.0},
	],
	"spirito": [
		{"n": 16, "life": 1.4, "v": [8.0, 30.0], "g": -40.0, "spread": 120.0, "size": [1.0, 2.0], "rect": [7, 8], "cols": ["#f0fff8", "#a8f0e0"], "glow": 2.0, "lit": true, "damp": 6.0},
	],
	"costrutto": [
		{"n": 16, "life": 0.7, "v": [40.0, 120.0], "g": 620.0, "spread": 150.0, "size": [1.0, 2.6], "rect": [7, 7], "cols": ["#8a92a0", "#5a6070", "#b8c0c8"]},
		{"n": 6, "life": 0.3, "v": [80.0, 170.0], "g": 260.0, "spread": 170.0, "size": [1.0, 1.0], "rect": [4, 4], "cols": SPARK, "glow": 2.6, "lit": true},
	],
	"brace": [
		{"n": 16, "life": 1.0, "v": [15.0, 60.0], "g": -50.0, "spread": 140.0, "size": [1.0, 2.0], "rect": [7, 6], "cols": ["#ffd070", "#ff7a30", "#c83a1a"], "glow": 2.4, "lit": true, "damp": 20.0},
		{"n": 10, "life": 1.2, "v": [8.0, 30.0], "g": 30.0, "spread": 180.0, "size": [1.5, 3.0], "rect": [7, 6], "cols": ["#4a4440", "#2a2624"], "fade": 0.7, "damp": 10.0},
	],
	"gelo": [
		{"n": 16, "life": 0.8, "v": [40.0, 120.0], "g": 480.0, "spread": 160.0, "size": [1.0, 2.4], "rect": [7, 6], "cols": ["#e8fbff", "#8ad8ff", "#4a8ab8"], "glow": 1.5, "lit": true},
	],
	"spora": [
		{"n": 18, "life": 1.4, "v": [6.0, 28.0], "g": -10.0, "spread": 180.0, "size": [1.5, 3.2], "rect": [8, 7], "cols": ["#d8b0ff", "#9a6ad8", "#7ac870"], "glow": 1.3, "lit": true, "damp": 10.0, "fade": 0.7},
	],
	"linfa": [
		{"n": 16, "life": 0.8, "v": [30.0, 100.0], "g": 520.0, "spread": 150.0, "size": [1.0, 2.2], "rect": [7, 6], "cols": ["#b8fff0", "#5cf0d8", "#2a9a90"], "glow": 1.8, "lit": true},
	],
	"luce": [
		{"n": 20, "life": 0.5, "v": [60.0, 160.0], "g": 0.0, "spread": 180.0, "size": [1.0, 1.6], "rect": [3, 3], "cols": ["#ffffff", "#fff08a"], "glow": 3.0, "lit": true, "damp": 160.0},
	],
}
