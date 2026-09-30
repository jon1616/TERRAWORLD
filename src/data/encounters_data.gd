class_name EncountersData
extends RefCounted
## I piccoli incontri delle grotte (Roadmap 30, voce 303; l'utente: «rendi l'esplorazione sempre più interessante,
## stimolante e varia»). Li piazza `PassIncontri`, li disegna `EncounterArt`, li fa vivere `Encounters` (`src/game/`):
## si annunciano da lontano (una scritta, un suono, una luce), le bestie delle tane e delle vene si svegliano quando ti
## avvicini, i premi si prendono una volta. Ogni incontro è una stazione (si salva con il mondo).
##   KINDS   id della stazione -> nome, strati, quanti per mondo, annuncio, luce, guardiani (quanti, più forti di ×)
##   DIARY   le pagine del diario di Tessa la Cercatrice, che si leggono in ordine (una per Pagina strappata)

const KINDS := {
	"zaino_perduto": {"name": "Zaino di un esploratore", "strata": [1, 2, 3, 4], "n": 12, "size": [2, 1], "slots": 12,
		"hint": "Laggiù qualcosa luccica tra le ossa: uno zaino dimenticato", "light": Color(0.35, 0.28, 0.12)},
	"osso_tana": {"name": "Tana", "strata": [1, 2, 3, 4], "n": 10, "size": [2, 1], "slots": 16,
		"hint": "Un odore di tana e un respiro nel buio: qualcosa custodisce un mucchio d'ossa", "guards": [2, 4], "mult": 1.3},
	"vena_madre": {"name": "Vena madre", "strata": [2, 3, 4], "n": 8, "size": [1, 2], "fixed": true,
		"hint": "La roccia qui canta piano: una vena madre, e qualcosa che la sorveglia", "guards": [2, 3], "mult": 1.5,
		"light": Color(0.3, 0.45, 0.55)},
	"fungo_re": {"name": "Fungo re", "strata": [1, 2, 3], "n": 6, "size": [2, 2], "fixed": true,
		"hint": "Una luce morbida e un profumo di spore: una camera fungina", "light": Color(0.2, 0.5, 0.6)},
}
const ANNOUNCE_R := 34                 # tessere: da qui l'incontro si annuncia
const WAKE_R := 13                     # tessere: da qui i guardiani si svegliano

## Ciò che dà il cristallo di una vena madre, per strato (il minerale attorno lo mette `PassIncontri._ore`).
const VEIN_GIFT := {2: [["minerale_legnoferro", 18, 30], ["cristallo_linfa", 2, 4]],
	3: [["minerale_ambra", 16, 26], ["cristallo_linfa", 3, 6], ["polvere_iridata", 1, 1]],
	4: [["minerale_tizzonite", 16, 26], ["cristallo_linfa", 4, 8], ["linfa_antica", 1, 1]]}
const MUSHROOM_GIFT := [["fungo_luminoso", 6, 12], ["fungo_brace", 4, 8], ["cappello_lucente", 3, 6], ["funghetti_cappello", 4, 8],
	["spore_luminose", 4, 8]]

const PAGE_ITEM := "pagina_tessa"
const PAGE_REWARD := "lanterna_tessa"
const ITEMS := {
	"pagina_tessa": {"name": "Pagina strappata", "kind": "pagina", "icon": ["tavoletta", "seta"], "stack": 20,
		"desc": "Una pagina del diario di Tessa la Cercatrice. Usala per leggerla: le pagine si leggono in ordine."},
	"lanterna_tessa": {"name": "Lanterna di Tessa", "kind": "accessorio", "icon": ["lanterna", "ambra"], "stack": 1,
		"acc": {"luck": 0.08, "halo": 1.3}, "desc": "La lanterna della Cercatrice: +8% di fortuna nel bottino, il tuo alone più ampio."},
}

const DIARY := [
	["Il primo giorno", "Mi chiamo Tessa, e cerco. Il vecchio Giardiniere dice che sotto ogni mondo c'è un altro mondo, fatto di radici. Stamattina sono scesa per la prima volta con una torcia sola. Ho paura, ma la paura fa luce anche lei."],
	["Le radici parlano", "Nel Sottobosco le radici si muovono quando non le guardi. Ho appoggiato l'orecchio a una di esse: scorreva qualcosa, piano, come un fiume sotto la pelle. Linfa, credo. Tutto qui sotto beve la stessa Linfa."],
	["I baccelli", "Ho trovato dei baccelli chiusi, sparsi come semi dimenticati. Dentro, lumini e piccole cose perdute. Qualcuno li ha lasciati lì apposta, per chi sarebbe venuto dopo. Ne lascerò anch'io, se torno."],
	["La tana", "Non avvicinarti ai mucchi d'ossa: c'è sempre qualcuno che li custodisce. Io l'ho imparato tardi. Ho perso la mappa e metà delle provviste, ma ho visto brillare, sotto le ossa, un anello d'ambra."],
	["La vena che canta", "Più giù la roccia canta. Segui il suono e trovi una vena madre, un cuore di minerale che pulsa. Le bestie la difendono come una madre difende il nido. Credo che la vena le nutra, e loro nutrano lei."],
	["I Seminatori", "Oggi ho visto le loro stanze. Porte che nessuna mano apre, scritte che nessuno legge più. I Seminatori piantavano mondi come io pianto fagioli. Mi chiedo se sapessero che qualcuno avrebbe camminato nei loro semi."],
	["La camera dei funghi", "Una grotta intera che respira luce. Funghi alti come me, spore che danzano. In mezzo, un fungo più grande degli altri, il re. Ho dormito lì, e ho sognato un albero enorme che mi chiamava per nome."],
	["Il Fondo", "Il Fondo è freddo e vuoto, e il vuoto ha fame. Le schegge brillano viola. Ho sentito un battito lontano: il Cuore di questo mondo. È malato, lo sento. Qualcuno dovrà curarlo, un giorno."],
	["La lanterna", "La mia lanterna è l'unica cosa che non ho mai perso. Chi la trova, la tenga accesa: la fortuna ama chi fa luce. Io comincio a essere stanca, e le gambe non mi portano più in fretta come prima."],
	["L'ultima pagina", "Lascio qui lo zaino e questo diario, a pezzi, sparsi dove sono passata. Se li hai trovati tutti, hai fatto la mia strada. Ora è tua. Io torno su, al Giardino, a guardare l'Albero crescere. Buona ricerca, Germogliato."],
]


static func items() -> Dictionary:
	return ITEMS.duplicate(true)


## I tipi di incontro che nascono in uno strato.
static func kinds_for(stratum: int) -> Array:
	var out := []
	for k in KINDS:
		if stratum in (KINDS[k]["strata"] as Array):
			out.append(String(k))
	return out


static func stations() -> Dictionary:
	var out := {}
	for k in KINDS:
		var e: Dictionary = KINDS[k]
		var st := {"name": e["name"], "size": e["size"], "item": "", "fixed": true}     # (sono luoghi del mondo)
		if e.has("slots"):
			st["slots"] = e["slots"]
		if e.has("light"):
			st["light"] = true
			st["light_color"] = e["light"]
		out[k] = st
	return out
