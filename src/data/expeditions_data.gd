class_name ExpeditionsData
extends RefCounted
## Le spedizioni del Cartografo (Roadmap 23, voce 238): sempre `OPEN` spedizioni aperte, di tipi diversi, costruite da ciò
## che il personaggio non ha ancora (le regole in `Expeditions`). Ogni tipo:
##   name     il titolo (con %s: la cosa da trovare)
##   hint     dove cercare, a grandi linee
##   stat     per i tipi «conta»: il conteggio del personaggio che deve salire di `need`
##   need     quanto (i tipi «meraviglia» e «pagina» chiedono una cosa sola)
##   reward   gli oggetti del premio; `seed`: in più un Seme di mondo con il gene che aiuta (vedi `Expeditions._seed`)

const OPEN := 3
const KINDS := {
	"meraviglia": {"name": "Vedere %s", "hint": "un mondo con uno dei geni che la chiamano: il Seme del premio della spedizione prima aiuta",
		"reward": {"polvere_iridata": 2}, "seed": true},
	"pagina": {"name": "Completare la pagina «%s»", "hint": "l'Atlante (scheda «I biomi») dice che cosa manca e dove",
		"reward": {"linfa_antica": 2}, "seed": true},
	"stelle": {"name": "Guadagnare %s stelle nell'Atlante", "hint": "firme, Guardiani, Sigilli, segreti e mappe dei mondi",
		"stat": "stelle", "need": 3, "reward": {"mappa_firma": 1, "polvere_iridata": 2}},
	"segreti": {"name": "Trovare %s segreti", "hint": "la Bacchetta rabdomante e l'Eco dei Seminatori aiutano",
		"stat": "segreti", "need": 4, "reward": {"mappa_seminatori": 1, "tavoletta_seminatori": 2}},
	"sigilli": {"name": "Aprire %s Sigilli", "hint": "i luoghi sigillati: servono i poteri dell'Albero-Madre",
		"stat": "sigilli", "need": 2, "reward": {"linfa_antica": 2, "mappa_sigilli": 1}},
	"firme": {"name": "Trovare la firma di %s mondi", "hint": "ogni mondo ha una cosa che c'è solo lì: la Mappa della firma la indica",
		"stat": "firme", "need": 1, "reward": {"polvere_iridata": 3}, "seed": true},
}
