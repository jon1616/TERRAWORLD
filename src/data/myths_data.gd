class_name MythsData
extends RefCounted
## Le leggende dei luoghi (Roadmap 36, voce 346): una riga di mito per ogni bioma, nella sua pagina dell'Atlante
## (`BiomePages.text_of`) appena lo si è visitato. Tono cupo, poche parole; chi ha letto il canone (`UNIVERSO.md`)
## riconosce i Seminatori dietro ogni luogo. Chiave: l'id del bioma (superficie, sottosuolo, cielo).

const MYTHS := {
	"foresta": "Si dice che le lanterne degli alberi siano accese per qualcuno che deve tornare. Nessuno ricorda chi.",
	"palude": "Le spore nascono dove Ilvenna pianse sui semi che non volevano più cantare.",
	"ambra": "L'ambra è Linfa che ha avuto paura e si è fermata. Dentro, a volte, c'è ancora la paura.",
	"brina": "La brina scende sugli alberi che hanno visto qualcosa nel Vuoto, per non farglielo ricordare.",
	"cenere": "Qui il primo seme malato fu bruciato. La cenere non ha mai smesso di cadere.",
	"prati": "Il vento dei prati porta le voci da un mondo all'altro. Di notte porta anche quelle che non dovrebbe.",
	"rossa": "Le cortecce sono rosse perché gli alberi qui ricordano una ferita. Non dicono di chi.",
	"funghi": "I cappelli crescono sopra le cose sepolte. Più sono grandi, più è grande ciò che coprono.",
	"torba": "La torba beve la Linfa che cade e la tiene per sé, come una bocca piccola e paziente.",
	"vetro": "Il deserto era una serra. Qualcuno ruppe i vetri dall'interno.",
	"ghiacciaio": "Varèk gelò la Linfa per conservarla. Il freddo conserva anche le voci, e le voci sotto il ghiaccio parlano.",
	"pietra": "Gli alberi di pietra non sono morti: hanno scelto di non sentire più niente.",
	"brace": "La terra brucia da sola, come se qualcosa sotto cercasse di uscire scaldandosi.",
	"iridato": "Ogni colore dei prati è un nome che qualcuno ha detto ad alta voce. Poi l'ha dimenticato.",
	"stellare": "Le radure guardano il cielo. Odràn diceva che anche il cielo, a volte, guarda in basso.",
	"sussurri": "Nei boschi dei sussurri le foglie ripetono parole che nessuno ha insegnato loro.",
	"canto": "I cristalli cantano la stessa nota da un'era. È una nota sola perché le altre sono state mangiate.",
	"giungla": "Le radici qui si intrecciano come mani che non vogliono lasciarsi.",
	"lago": "L'acqua dei laghi sotterranei è ferma da quando i Seminatori ci si specchiarono l'ultima volta.",
	"catacombe": "Le catacombe non hanno morti. Hanno nomi incisi e, sotto, niente.",
	"radici_sospese": "Le radici del cielo pendono da qualcosa che non si vede. Qualcuno dice: da Maesh.",
	"mare_nubi": "Le nuvole sono il respiro dei mondi addormentati. Quando un Cuore si ferma, il mare si abbassa.",
	"giardini_vento": "Erano gli orti dei Seminatori. Il vento li cura ancora, perché nessuno gli ha detto di smettere.",
	"scogliere_cristallo": "Le scogliere sono fatte di Linfa caduta dall'alto. Qualcuno, lassù, ha sanguinato a lungo.",
	"nidi_tempesta": "I fulmini cercano sempre la stessa cosa e non la trovano.",
	"firmamento": "Lassù il buio è più vicino. Se tendi l'orecchio, senti l'aria che va dentro e non torna.",
}


static func of(bid: String) -> String:
	return String(MYTHS.get(bid, ""))
