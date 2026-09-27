class_name LiquidsData
## I liquidi dei mondi (voci 73-74, Roadmap 10): acqua, Linfa e brace. Solo dati: come scorrono lo decide `Liquids`,
## come si vedono `LiquidView`. Un liquido è un livello 0-8 per cella (8 = cella piena) e un tipo.
##   color/alpha  colore nel mondo; light: la luce che fa (Linfa e brace brillano); flow: ogni quanti passi scorre (la
##   brace è densa e lenta); dps/heal: che cosa fa a chi ci sta dentro; swim: si nuota (la brace no: brucia e basta).

const ACQUA := 0
const LINFA := 1
const BRACE := 2

const TYPES := [
	{"id": "acqua", "name": "Acqua", "color": Color("#2f6ec8"), "alpha": 0.55, "top": Color("#8ec8ff"), "light": Color(0, 0, 0),
		"flow": 1, "swim": true, "dps": 0.0, "heal": 0.0},
	{"id": "linfa", "name": "Linfa", "color": Color("#1fb8a0"), "alpha": 0.55, "top": Color("#b8fff0"), "light": Color(0.35, 1.3, 1.1),
		"flow": 2, "swim": true, "dps": 0.0, "heal": 3.0},
	{"id": "brace", "name": "Brace liquida", "color": Color("#d84a14"), "alpha": 0.86, "top": Color("#ffd070"), "light": Color(1.6, 0.7, 0.25),
		"flow": 4, "swim": false, "dps": 14.0, "heal": 0.0},
]

## Ogni quanti secondi si fa un passo della simulazione, e al più quante celle per passo.
const STEP := 0.05
const MAX_UPDATES := 1400
## Le celle più lontane di così dal Germogliato non scorrono (restano in attesa, ferme).
const WINDOW := Vector2i(110, 70)

## Il nuoto (voce 73): gravità, caduta massima, spinta verso l'alto tenendo il salto, corsa in acqua.
const SWIM_GRAV := 0.25
const SWIM_FALL := 70.0
const SWIM_UP := 115.0
const SWIM_RUN := 0.6
## Gli oggetti dei liquidi: il secchio (raccoglie una cella piena di liquido e la versa altrove), i materiali delle
## creature d'acqua e le Branchie di muschio (respiro più lungo).
const ITEMS := {
	"secchio": {"name": "Secchio di radice", "kind": "secchio", "icon": ["vasetto", "legno"], "stack": 1,
		"desc": "Clic su un liquido: lo raccoglie (una cella piena). Poi clic dove vuoi versarlo."},
	"secchio_acqua": {"name": "Secchio d'acqua", "kind": "secchio_pieno", "icon": ["vasetto", "cristallo"], "stack": 1, "liquid": 0,
		"source": "un secchio di radice immerso nell'acqua", "desc": "Clic: versa l'acqua. Il secchio torna vuoto."},
	"secchio_linfa": {"name": "Secchio di Linfa", "kind": "secchio_pieno", "icon": ["vasetto", "linfa"], "stack": 1, "liquid": 1,
		"source": "un secchio di radice immerso nella Linfa", "desc": "Clic: versa la Linfa. Cura chi ci sta dentro."},
	"secchio_brace": {"name": "Secchio di brace", "kind": "secchio_pieno", "icon": ["vasetto", "brace"], "stack": 1, "liquid": 2,
		"source": "un secchio di radice immerso nella brace liquida", "desc": "Clic: versa la brace. Brucia chi ci cade dentro."},
	# voce 119: spostare i liquidi (contenitori grandi e fonti, vedi `LiquidTools`)
	"otre_legnoferro": {"name": "Otre di legnoferro", "kind": "contenitore", "cap": 6, "icon": ["vasetto", "legnoferro"], "stack": 1,
		"desc": "Raccoglie fino a sei celle di un liquido (clic sul liquido) e le versa dove vuoi (clic altrove). Per riempire o svuotare un bacino."},
	"anfora_ambra": {"name": "Anfora d'ambra", "kind": "contenitore", "cap": 20, "icon": ["vasetto", "ambra"], "stack": 1,
		"desc": "Raccoglie fino a venti celle di un liquido e le versa dove vuoi: basta per un laghetto."},
	"fonte_acqua": {"name": "Fonte di muschio", "kind": "stazione", "place": "fonte_acqua", "icon": ["vasetto", "muschio"], "stack": 9,
		"desc": "Una pietra che gocciola acqua senza fine: la versa accanto a sé finché il bacino non sale fino alla sua bocca."},
	"fonte_linfa": {"name": "Fonte di Linfa", "kind": "stazione", "place": "fonte_linfa", "icon": ["vasetto", "linfa"], "stack": 9,
		"desc": "Un cristallo che piange Linfa: la versa accanto a sé finché il bacino non sale fino alla sua bocca."},
	"fonte_brace": {"name": "Bocca di brace", "kind": "stazione", "place": "fonte_brace", "icon": ["vasetto", "brace"], "stack": 9,
		"desc": "Una roccia che trabocca di brace liquida: la versa accanto a sé. Attenzione a dove la metti."},
	"pietra_brace": {"name": "Pietra di brace", "kind": "blocco", "icon": ["zolla", "brace"], "place": TileDefs.PIETRA_BRACE,
		"desc": "Nasce dove l'acqua spegne la brace liquida: scura, dura, calda al tatto. Un blocco da costruzione."},
	"squama_lume": {"name": "Squama di lume", "kind": "materiale", "icon": ["foglia", "cristallo"], "stack": 99,
		"desc": "Una squama che brilla piano, dai pesci lume."},
	"dente_anguilla": {"name": "Dente d'anguilla", "kind": "materiale", "icon": ["aculeo", "linfa"], "stack": 99,
		"desc": "Aguzzo e un po' velenoso, dalle anguille di Linfa."},
	"branchie_muschio": {"name": "Branchie di muschio", "kind": "accessorio", "icon": ["foglia", "muschio"], "stack": 1,
		"acc": {"respiro": 3.0}, "desc": "Muschio che trattiene l'aria: sott'acqua respiri tre volte più a lungo."},
	"amuleto_anguilla": {"name": "Amuleto d'anguilla", "kind": "accessorio", "icon": ["amuleto", "linfa"], "stack": 1,
		"acc": {"respiro": 1.5, "run": 1.05, "thorns": 3}, "desc": "Scivoli nell'acqua come un'anguilla, e morde chi ti tocca."},
}

const RECIPES := [
	{"out": "secchio", "qty": 1, "in": {"legno": 8, "lingotto_radicite": 2}, "station": "ceppo"},
	{"out": "otre_legnoferro", "qty": 1, "in": {"lingotto_legnoferro": 3, "seta_radice": 3}, "station": "telaio"},
	{"out": "anfora_ambra", "qty": 1, "in": {"lingotto_ambra": 4, "cristallo_linfa": 2}, "station": "maglio"},
	{"out": "fonte_acqua", "qty": 1, "in": {"ardesia": 20, "gelatina": 5, "lingotto_radicite": 2}, "station": "ceppo"},
	{"out": "fonte_linfa", "qty": 1, "in": {"ardesia": 20, "cristallo_linfa": 6, "lingotto_legnoferro": 2}, "station": "maglio"},
	{"out": "fonte_brace", "qty": 1, "in": {"pietra_brace": 15, "polvere_brace": 10, "lingotto_ambra": 2}, "station": "baccello_ardente"},
	{"out": "branchie_muschio", "qty": 1, "in": {"squama_lume": 8, "seta_radice": 2}, "station": "telaio"},
	{"out": "amuleto_anguilla", "qty": 1, "in": {"dente_anguilla": 6, "squama_lume": 4, "lingotto_legnoferro": 2}, "station": "maglio"},
]

## Voce 74: quando due liquidi si toccano. [tipo a, tipo b] (in ordine) -> che cosa succede:
##   tile: la cella di contatto diventa questa tessera (il liquido lì sparisce); consume: livelli persi da chi scorre;
##   become: il liquido di tipo b diventa di questo tipo.
const REACTIONS := {
	"0,2": {"tile": TileDefs.PIETRA_BRACE, "consume": 2, "name": "L'acqua spegne la brace: pietra di brace"},
	"1,2": {"tile": TileDefs.CRYSTAL, "consume": 2, "name": "La Linfa cristallizza sulla brace"},
	"0,1": {"become": 0, "name": "L'acqua annacqua la Linfa"},
}
## La Linfa fa crescere più in fretta le colture a questa distanza (in tessere).
const LINFA_GROW_R := 3
const LINFA_GROW := 2.0

## Il respiro: secondi sott'acqua prima di cominciare a perdere Vita, e quanta al secondo dopo.
const BREATH := 12.0
const DROWN := 6.0
