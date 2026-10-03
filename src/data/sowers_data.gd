class_name SowersData
extends RefCounted
## I Seminatori (Roadmap 36, voce 342; il canone in `UNIVERSO.md`, «La storia vera»). Non se ne sono mai andati: ognuno
## si è diviso nei Cuori dei mondi ed è diventato il loro Guardiano. Curare un Guardiano ne risveglia una parte (il nome,
## poi un ricordo alla volta); abbatterlo ne spegne una. Solo dati: le regole in `Sowers`.
##   guardian   l'id del Guardiano (`GuardiansData`, «generato» per i Guardiani dei mondi forti, «nero» per
##              l'Avvizzitore, «primo» per l'ultimo Seminatore)
##   memories   i ricordi, nell'ordine in cui tornano (uno a ogni Guardiano curato)
##   spent      ciò che resta quando una sua parte si spegne (la prima volta)
## Frasi brevi: il giocatore ricompone, non legge.

const SOWERS := {
	"odran": {"name": "Odràn", "title": "il Custode che non dormiva", "guardian": "nodo", "color": "#9ad87a",
		"memories": [
			"Guardavo il Vuoto mentre gli altri dormivano. Qualcosa, laggiù, guardava me.",
			"Lo dissi a tutti. Mi risposero che nel Vuoto non si muove niente.",
			"Fui il primo a toccare la malattia. Sapeva di un nome dimenticato.",
			"Mi divisi in tanti pezzi quanti erano i Cuori. Ogni pezzo ricorda meno.",
			"Se mi trovi ancora, non svegliarmi del tutto. Qualcuno deve restare a guardare.",
		],
		"spent": "Odràn ha smesso di guardare, in quel Cuore."},
	"ilvenna": {"name": "Ilvenna", "title": "la Giardiniera delle serre", "guardian": "regina", "color": "#e0a0d0",
		"memories": [
			"Davo un nome a ogni seme, prima di lasciarlo andare. Anche a te.",
			"Nelle serre i semi cantavano. Una notte smisero, tutti insieme.",
			"Saréth veniva ad ascoltarli con me. Diceva che sentiva cantare anche il buio.",
			"Le spore sono ciò che resta di me quando dimentico. Ne resta sempre di più.",
			"Il nome che ti diedi era il suo. Non chiedermi perché.",
		],
		"spent": "In quel Cuore nessuno darà più un nome ai semi."},
	"varek": {"name": "Varèk", "title": "il Costruttore", "guardian": "colosso", "color": "#a2b0c2",
		"memories": [
			"Costruii i Sigilli, le Centrali, i corpi che adesso abitiamo.",
			"Volevo far cantare insieme i quattro Alberi, più forte della chiamata. Li ho rotti.",
			"Chi ha fatto ammalare anche loro? Io. Con queste mani.",
			"Dietro i Sigilli ho chiuso ciò che amavamo e ciò che temevamo. Non ricordo più quale fosse quale.",
			"La pietra non dimentica. Per questo ho scelto la pietra.",
		],
		"spent": "Una parte di Varèk è tornata soltanto pietra."},
	"sareth": {"name": "Saréth", "title": "la Voce", "guardian": "avvizzitore", "color": "#b070ff",
		"memories": [
			"Mi chiamava per nome. Nessuno lo faceva più. Gli diedi un mondo, e lui li volle tutti.",
		],
		"spent": "Il seme si è spezzato. Con lui l'unica che sapeva che cosa promise la Bocca."},
	"maesh": {"name": "Maesh", "title": "l'Ultimo", "guardian": "primo", "color": "#ffd88a",
		"memories": [
			"Ho aspettato da solo, davanti alla radice più lunga. Sapevo che saresti venuto. Non sapevo che avresti la sua voce.",
		],
		"spent": ""},
}

## I senza nome: i Guardiani dei mondi forti, divisi in troppi pezzi per ricordarsi chi erano.
const NAMELESS := {"name": "Senza nome", "title": "i Guardiani dei mondi forti", "guardian": "generato", "color": "#8a8478",
	"memories": [
		"Avevo un nome. Era corto. Finiva con una vocale, credo.",
		"Siamo così tanti pezzi che non sappiamo più di chi.",
		"Non svegliarci tutti. Il Vuoto aspetta dietro di noi.",
		"Grazie. Non so chi sei. Non so chi sono.",
		"Uno di noi rideva sempre. Forse ero io.",
	],
	"spent": "Un altro pezzo senza nome si è spento."}

## Ordine nel Taccuino.
const ORDER := ["odran", "ilvenna", "varek", "sareth", "maesh"]


## Il Seminatore di un Guardiano ("" se nessuno; «avvizzitore» = Saréth, spezzato o curato).
static func of_guardian(gid: String) -> String:
	if gid == "generato":
		return "senza_nome"
	for k in SOWERS:
		if String(SOWERS[k]["guardian"]) == gid:
			return k
	return ""


static func get_sower(k: String) -> Dictionary:
	return NAMELESS if k == "senza_nome" else SOWERS.get(k, {})
