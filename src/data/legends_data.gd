class_name LegendsData
## I Semi leggendari e il Seme Primo (voce 81, Roadmap 11 «Senza fine»). Solo dati: le regole in `Legends`.
## Un Seme è **leggendario** quando porta insieme i tre geni di una leggenda (sempre di categorie diverse, almeno uno
## stellare: si ottengono innestando, dalle firme dei mondi, dalle catene). Il mondo che ne nasce è leggendario: creature
## rare e Lumini doppi, e il suo Cuore, risolto il Guardiano, dona un oggetto unico (`gift`) e tre Linfe antiche.
## Il **Seme Primo** è il traguardo finale: lo dona l'Albero-Madre quando è sveglio del tutto, il Genario conosce buona
## parte dei geni e almeno due leggende sono compiute. Nasce un mondo di tutti i biomi, più vigoroso di ogni altro; dopo,
## il gioco continua (il vigore non ha tetto, le leggende restano, le sfide dei Semi).

const LEGENDS := {
	"aurora_sospesa": {"name": "Seme dell'Aurora sospesa", "needs": ["isole_sospese", "stellato", "aurora"],
		"desc": "isole nel cielo sotto notti che non si spengono", "gift": "corona_aurora"},
	"arcipelago_eco": {"name": "Seme dell'Arcipelago dei venti", "needs": ["arcipelago", "eco_seminatori", "ventoso"],
		"desc": "pilastri, venti forti e le voci dei Seminatori", "gift": "ali_venti"},
	"cuore_cristallo": {"name": "Seme del Cuore di cristallo", "needs": ["cuore_cavo", "vene_stellari", "cristalli_vivi"],
		"desc": "una caverna immensa dove il cristallo cresce da solo", "gift": "cuore_cristallo"},
	"citta_viva": {"name": "Seme della Città viva", "needs": ["sorgenti", "citta_sepolta", "radice_madre"],
		"desc": "la città dei Seminatori attraversata dalla Radice madre", "gift": "sigillo_seminatori"},
	"abisso": {"name": "Seme dell'Abisso sommerso", "needs": ["sommerso", "abissale", "radice_madre"],
		"desc": "un mare sopra caverne senza fondo", "gift": "cuore_abisso"},
	"notte_stellata": {"name": "Seme della Notte stellata", "needs": ["ancestrale", "cuore_stellare", "notte_eterna"],
		"desc": "una notte che non finisce, piena di stelle e di creature antiche", "gift": "occhio_notte"},
}

const RARE := 2.0                      # creature rare e Lumini nei mondi leggendari
const LUMINI := 2.0
const ANCIENT_SAP := 3                 # Linfe antiche in più dal Cuore di un mondo leggendario

## Il Seme Primo: le tre condizioni.
const PRIMO_GENARIO := 0.6             # frazione dei geni imparati (Genario)
const PRIMO_LEGENDS := 2               # leggende compiute
const PRIMO_VIGOR := 5                 # vigore in più del mondo più vigoroso conosciuto
const PRIMO_EXTRA := 4                 # geni stellari in più del Mosaico

const ITEMS := {
	"corona_aurora": {"name": "Corona dell'aurora", "kind": "accessorio", "icon": ["corona", "brillaluce"], "stack": 1,
		"acc": {"halo": 2.0, "regen": 1.4}, "source": "il Cuore di un mondo del Seme dell'Aurora sospesa",
		"desc": "Luce che non si spegne: un alone enorme e la Vita che ricresce."},
	"ali_venti": {"name": "Ali dei venti", "kind": "accessorio", "icon": ["ali", "muschio"], "stack": 1,
		"acc": {"glide": true, "air_jumps": 2, "vento": 0.2}, "source": "il Cuore di un mondo del Seme dell'Arcipelago dei venti",
		"desc": "Due salti in aria, si plana, e il vento non ti porta via."},
	"cuore_cristallo": {"name": "Cuore di cristallo", "kind": "accessorio", "icon": ["cuore", "cristallo"], "stack": 1,
		"acc": {"dig": 1.5, "damage": 1.1}, "source": "il Cuore di un mondo del Seme del Cuore di cristallo",
		"desc": "Si scava la metà più in fretta, e si colpisce più forte."},
	"sigillo_seminatori": {"name": "Sigillo dei Seminatori", "kind": "accessorio", "icon": ["anello", "ambra"], "stack": 1,
		"acc": {"luck": 0.3, "magic": 1.2}, "source": "il Cuore di un mondo del Seme della Città viva",
		"desc": "L'anello di chi seminò i mondi: fortuna e incantesimi."},
	"cuore_abisso": {"name": "Cuore dell'abisso", "kind": "accessorio", "icon": ["cuore", "lagunite"], "stack": 1,
		"acc": {"respiro": 6.0, "run": 1.12}, "source": "il Cuore di un mondo del Seme dell'Abisso sommerso",
		"desc": "Sott'acqua quasi senza fine, e un passo più lungo."},
	"occhio_notte": {"name": "Occhio della notte", "kind": "accessorio", "icon": ["occhio", "nottilite"], "stack": 1,
		"acc": {"halo": 1.8, "stealth": 0.7, "damage": 1.1}, "source": "il Cuore di un mondo del Seme della Notte stellata",
		"desc": "Vedi nel buio e il buio non vede te."},
	"germoglio_primo": {"name": "Germoglio del Primo", "kind": "accessorio", "icon": ["foglia", "brillaluce"], "stack": 1,
		"acc": {"run": 1.1, "damage": 1.1, "regen": 1.3, "halo": 1.4, "luck": 0.15, "magic": 1.1},
		"source": "il Cuore del Primo Mondo, nato dal Seme Primo",
		"desc": "Il primo germoglio dell'Albero-Madre, rinato: un po' di tutto, per sempre."},
}
