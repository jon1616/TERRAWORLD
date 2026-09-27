class_name NamesData
extends RefCounted
## I nomi dei mondi nati dai Semi (voce 44): «Paludi cave di Osrarim». Il paesaggio viene dal gene di superficie,
## l'aggettivo da un gene che cambia la forma del mondo (o da un altro, se manca), il nome proprio dal seme del mondo:
## stesso Seme, stesso nome. Solo dati e la funzione che li mette insieme.

## Paesaggi per gene di superficie: [nome, femminile?]. "" = senza gene di superficie (tutti i biomi).
const _LANDS := {
	"lanterna": [["Foreste", true], ["Selve", true], ["Boschi", false]],
	"sporangio": [["Paludi", true], ["Torbiere", true], ["Acquitrini", false]],
	"resina": [["Distese", true], ["Dune", true], ["Piani", false]],
	"brina": [["Nevai", false], ["Brume", true], ["Ghiacciai", false]],
	"cenere": [["Cenerarie", true], ["Lande", true], ["Roghi", false]],
	"mosaico": [["Mosaici", false], ["Arazzi", false], ["Contrade variegate", true]],
	"": [["Terre", true], ["Contrade", true], ["Giardini", false]],
}

## Aggettivi per gene: [maschile plurale, femminile plurale].
const _ADJ := {
	"pianure": ["aperti", "aperte"], "montagne": ["alti", "alte"], "altopiano": ["eccelsi", "eccelse"],
	"conca": ["bassi", "basse"], "frastagliato": ["spezzati", "spezzate"], "cavo": ["cavi", "cave"],
	"sommerso": ["sommersi", "sommerse"], "piovoso": ["piovosi", "piovose"], "ventoso": ["ventosi", "ventose"],
	"nebbioso": ["nebbiosi", "nebbiose"],
	"lieve": ["lievi", "lievi"], "giorni_brevi": ["fugaci", "fugaci"], "giorno_lento": ["lenti", "lente"],
	"notte_eterna": ["notturni", "notturne"], "senza_sole": ["spenti", "spente"], "radici_vive": ["radicati", "radicate"],
	"cristalli_vivi": ["cristallini", "cristalline"], "frane": ["franosi", "franose"], "guscio": ["racchiusi", "racchiuse"], "arcipelago": ["sparsi", "sparse"], "sorgenti": ["sorgivi", "sorgive"],
	"compatto": ["sordi", "sorde"], "gallerie": ["traforati", "traforate"], "alveare": ["alveolati", "alveolate"],
	"voragini": ["squarciati", "squarciate"], "abissale": ["abissali", "abissali"], "fungaie": ["fungosi", "fungose"],
	"geodi_brina": ["gelidi", "gelide"], "fiumi_brace": ["ardenti", "ardenti"], "radici_giganti": ["radicati", "radicate"],
	"laghi_linfa": ["lucenti", "lucenti"], "vene_ricche": ["ricchi", "ricche"], "vene_affioranti": ["venati", "venate"],
	"radicite_diffusa": ["rossi", "rosse"], "metalli_nobili": ["nobili", "nobili"], "gemme_ricche": ["ingemmati", "ingemmate"],
	"geodi_fitti": ["cristallini", "cristalline"], "cristalli_giganti": ["cristallini", "cristalline"],
	"rovine_fitte": ["antichi", "antiche"], "rovine_sepolte": ["sepolti", "sepolte"], "iridescente": ["iridati", "iridate"],
	"ancestrale": ["ancestrali", "ancestrali"], "brulicante": ["brulicanti", "brulicanti"],
	"quieto": ["quieti", "quiete"], "fertile": ["fertili", "fertili"], "rigoglioso": ["rigogliosi", "rigogliose"],
	"spoglio": ["spogli", "spoglie"], "stellato": ["stellati", "stellate"], "notti_lunghe": ["notturni", "notturne"],
	"giorni_lunghi": ["solari", "solari"], "avvizzito": ["malati", "malate"], "sano": ["puri", "pure"],
	"isole_sospese": ["sospesi", "sospese"], "cuore_cavo": ["cavernosi", "cavernose"], "citta_sepolta": ["murati", "murate"],
	"aurora": ["aurorali", "aurorali"], "pascoli": ["pascolivi", "pascolive"], "cacciatori": ["selvaggi", "selvagge"],
	"alveari": ["ronzanti", "ronzanti"], "cuore_nero": ["neri", "nere"], "vene_stellari": ["stellari", "stellari"],
	"fioritura_eterna": ["fioriti", "fiorite"], "eclissi": ["oscurati", "oscurate"], "eco_seminatori": ["antichissimi", "antichissime"],
	"cuore_stellare": ["stellanti", "stellanti"], "radice_madre": ["primigeni", "primigenie"],
}

const SYL_A := ["Vel", "Ar", "Os", "Ta", "Lu", "Mir", "Sel", "Dor", "An", "Ei", "Ul", "Tor", "Fa", "Ny", "Ka", "Ren",
	"Is", "Or", "Ula", "Za", "Bre", "Cal", "Esh", "Gil", "Iv", "Mae", "Nor", "Pel", "Sa", "Ve"]
const SYL_B := ["", "a", "e", "i", "o", "ri", "la", "ne", "sa", "mo", "ven", "ta", "lo"]
const SYL_C := ["rim", "na", "ra", "dor", "lis", "ven", "thar", "mè", "sca", "lume", "via", "nor", "sia", "ren", "to",
	"del", "nis", "ria", "mar", "sel"]


## Il nome di un mondo nato da un Seme.
static func world_name(genes: Array, world_seed: int) -> String:
	var rng := RandomNumberGenerator.new()
	rng.seed = world_seed ^ 0x4E4D
	var sg := Genome.surface_of(genes)
	var lands: Array = LANDS.get(sg, LANDS[""])
	var land: Array = lands[rng.randi_range(0, lands.size() - 1)]
	# l'aggettivo: prima un gene di forma, grotte o sottosuolo, poi uno qualunque
	var pool := []
	for g in genes:
		if ADJ.has(g) and GenesData.cat_of(String(g)) in Genome.SHAPE_CATS:
			pool.append(g)
	if pool.is_empty():
		for g in genes:
			if ADJ.has(g):
				pool.append(g)
	var adj := ""
	if not pool.is_empty():
		var a: Array = ADJ[pool[rng.randi_range(0, pool.size() - 1)]]
		adj = " " + String(a[1] if land[1] else a[0])
	var proper := String(SYL_A[rng.randi_range(0, SYL_A.size() - 1)]) + String(SYL_B[rng.randi_range(0, SYL_B.size() - 1)]) \
		+ String(SYL_C[rng.randi_range(0, SYL_C.size() - 1)])
	return "%s%s di %s" % [land[0], adj, proper]


## Voce 92: più i paesaggi dei pacchetti dei biomi (per il loro gene).
static var LANDS: Dictionary = _lands()


static func _lands() -> Dictionary:
	var out := _LANDS.duplicate()
	for b in BiomesData.BIOMES:
		if b.has("lands"):
			out[String(b["gene"])] = b["lands"]
	return out


## Voce 94: più gli aggettivi dei biomi del sottosuolo (campo `adj`, per il loro gene).
static var ADJ: Dictionary = _adj()


static func _adj() -> Dictionary:
	var out := _ADJ.duplicate()
	for u in BiomesData.UNDER:
		if u.has("adj"):
			for g in (u.get("genes", {}) as Dictionary):
				out[g] = u["adj"]
	return out
