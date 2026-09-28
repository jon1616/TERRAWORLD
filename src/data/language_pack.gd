extends RefCounted
## Le parole che svelano (Roadmap 17, voce 176): ricette **scritte nella lingua dei Seminatori**. Ognuna ha il campo
## `parole`: si vede (e si fa) solo quando tutte quelle parole sono certe (`Crafting._discovered`); il Quaderno dice
## quante ne mancano. Strumenti per decifrare e premi forti. Un pacchetto come quelli dei biomi (`BiomesData.PACK_FILES`);
## questo file non nomina altre classi.

const DATA := {
	"items": {
		"bussola_stele": {"name": "Bussola delle stele", "kind": "mappa", "icon": ["mappa", "sem"], "stack": 1,
			"desc": "Usala: segna sulla mappa le stele di questo mondo che non hai ancora letto. Non si consuma."},
		"occhiali_decifratore": {"name": "Occhiali del decifratore", "kind": "accessorio", "icon": ["specchio", "celeste"], "stack": 1,
			"acc": {"halo": 1.1}, "desc": "Indossati, basta vedere una parola in una frase in meno per farsene un'ipotesi."},
		"stilo_seminatori": {"name": "Stilo dei Seminatori", "kind": "stilo", "icon": ["penna", "sem"], "stack": 10,
			"desc": "Usalo: una delle tue ipotesi diventa certa (prima quelle delle lingue più alte)."},
		"corona_seminatori": {"name": "Corona dei Seminatori", "kind": "accessorio", "icon": ["corona", "sem"], "stack": 1,
			"acc": {"defense": 4, "magic": 1.1, "luck": 0.05}, "desc": "+4 Scorza; incantesimi +10%; un po' di fortuna. Il nome inciso dentro protegge chi la porta."},
		"mantello_canto": {"name": "Mantello del canto", "kind": "accessorio", "icon": ["mantello", "cielo"], "stack": 1,
			"acc": {"glide": true, "air_jumps": 1, "run": 1.05}, "desc": "Un salto in aria in più; si plana; corsa +5%. Canta piano quando c'è vento."},
		"amuleto_patto": {"name": "Amuleto del patto", "kind": "accessorio", "icon": ["amuleto", "nottilite"], "stack": 1,
			"acc": {"damage": 1.12, "stealth": 0.8}, "desc": "Danno +12%; le creature ti notano più tardi. Il prezzo del patto, pagato in silenzio."},
		"talismano_rinascita": {"name": "Talismano della rinascita", "kind": "accessorio", "icon": ["amuleto", "linfa"], "stack": 1,
			"acc": {"regen": 1.5, "defense": 2}, "desc": "La Vita ricresce il 50% più in fretta; +2 Scorza."},
	},
	"recipes": [
		{"out": "bussola_stele", "qty": 1, "in": {"legno": 5, "lingotto_radicite": 2}, "station": "ceppo", "parole": ["pietra", "segno", "cerca"]},
		{"out": "occhiali_decifratore", "qty": 1, "in": {"cristallo_celeste": 2, "lingotto_legnoferro": 2}, "station": "maglio",
			"parole": ["occhio", "luce", "memoria"]},
		{"out": "stilo_seminatori", "qty": 2, "in": {"tavoletta_seminatori": 1, "lingotto_ambra": 1}, "station": "maglio",
			"parole": ["scrive", "nome"]},
		{"out": "corona_seminatori", "qty": 1, "in": {"lingotto_nimbite": 4, "cristallo_celeste": 4}, "station": "maglio",
			"parole": ["corona", "seminatori", "sempre", "protegge"]},
		{"out": "mantello_canto", "qty": 1, "in": {"seta_cielo": 6, "piuma_nubi": 6}, "station": "telaio", "parole": ["canto", "vento", "vola", "ala"]},
		{"out": "amuleto_patto", "qty": 1, "in": {"linfa_antica": 2, "lingotto_vuoto": 3}, "station": "maglio",
			"parole": ["patto", "prezzo", "silenzio", "verita"]},
		{"out": "talismano_rinascita", "qty": 1, "in": {"linfa_antica": 2, "polvere_iridata": 2}, "station": "maglio",
			"parole": ["rinascita", "guarisce", "ogni", "ferita"]},
	],
}
