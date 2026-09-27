class_name WorldTimeData
## Il tempo dei mondi (voce 78, Roadmap 10). Solo dati: li usano `DayCycle` e `Garden`. I geni del tempo (in
## `GenesData`, parte `run`):
##   day_len   quanto dura un giorno rispetto ai 20 minuti normali (Giorni brevi 0,4; Giorno lento 2,5)
##   eternal   Notte eterna: l'ora resta ferma a mezzanotte, le creature della notte sempre, la luna sola a far luce
##   sunless   Senza sole: il cielo non fa luce mai (nemmeno la luna); di giorno però le creature sono quelle del giorno
##   eclipse   Eclissi: ogni giorno a mezzogiorno il sole si oscura per un po', escono le creature della notte, e chi
##             si sconfigge durante l'eclissi può lasciare la Polvere d'eclissi
## Nei mondi bui (notte eterna, senza sole) le colture crescono piano, tranne vicino a una torcia o alla Linfa.

const ECLIPSE := [0.46, 0.54]          # ora di inizio e di fine dell'eclissi (mezzogiorno = 0,5): ~2 minuti
const ECLIPSE_LIGHT := 0.06            # quanta luce resta durante l'eclissi
const ECLIPSE_DUST := 0.35             # probabilità che una creatura sconfitta nell'eclissi lasci la Polvere
const DARK_GROW := 0.3                 # crescita delle colture al buio
const TORCH_GROW_R := 4.0              # una torcia così vicina (tessere) basta a far crescere normalmente

const ITEMS := {
	"polvere_eclissi": {"name": "Polvere d'eclissi", "kind": "materiale", "icon": ["polvere", "nottilite"], "stack": 99,
		"value": 45, "source": "creature sconfitte durante un'eclissi (gene Eclissi, vigore 4+)",
		"desc": "Cenere d'ombra caduta dal sole spento. Pesa meno dell'aria."},
	"amuleto_eclissi": {"name": "Amuleto dell'eclissi", "kind": "accessorio", "icon": ["amuleto", "nottilite"], "stack": 1,
		"acc": {"halo": 1.7, "stealth": 0.85}, "desc": "Il tuo alone si allarga, e le creature ti vedono meno."},
	"lanterna_eterna": {"name": "Lanterna della notte eterna", "kind": "accessorio", "icon": ["lanterna", "brillaluce"],
		"stack": 1, "acc": {"halo": 1.35, "regen": 1.2}, "desc": "Una luce che non ha bisogno del giorno."},
}

const RECIPES := [
	{"out": "amuleto_eclissi", "qty": 1, "in": {"polvere_eclissi": 8, "lingotto_ambra": 2}, "station": "maglio"},
	{"out": "lanterna_eterna", "qty": 1, "in": {"polvere_eclissi": 4, "cristallo_linfa": 6, "torcia": 10}, "station": "baccello_ardente"},
]
