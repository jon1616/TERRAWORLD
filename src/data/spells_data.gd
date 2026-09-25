class_name SpellsData
extends RefCounted
## I colpi dei bastoni di Linfa (voce 21): la Linfa del Germogliato diventa qualcosa che vola. Solo dati; li tira
## `Spells`, li muove `Projectiles`, chi colpiscono lo decide `Combat.on_shot`.
##
## Campi:
##   look     aspetto del colpo in `Projectiles` (brace, spora_amica, scheggia, orbita)
##   speed    velocità in px/s; grav = gravità
##   n        quanti colpi insieme; spread = apertura del ventaglio (radianti)
##   pierce   quante creature attraversa prima di fermarsi (0 = la prima lo ferma)
##   homing   quanto segue la creatura più vicina (0 = dritto)
##   through  attraversa la roccia
##   light    luce che porta con sé (nel buio vero un colpo di brace illumina la grotta)

const SPELLS := {
	"brace": {"look": "brace", "speed": 330.0, "grav": 0.0, "n": 1, "spread": 0.0, "pierce": 0, "homing": 0.0,
		"light": Color(1.4, 0.8, 0.35)},
	"spore": {"look": "spora_amica", "speed": 250.0, "grav": 140.0, "n": 3, "spread": 0.32, "pierce": 0, "homing": 0.0,
		"light": Color(0.5, 0.3, 0.8)},
	"cristallo": {"look": "scheggia", "speed": 480.0, "grav": 0.0, "n": 1, "spread": 0.0, "pierce": 3, "homing": 0.0,
		"light": Color(0.4, 1.0, 1.1)},
	"vuoto": {"look": "orbita", "speed": 230.0, "grav": 0.0, "n": 1, "spread": 0.0, "pierce": 1, "homing": 5.0,
		"through": true, "light": Color(0.8, 0.4, 1.3)},
}
