class_name BeastItemsData
extends RefCounted
## Gli oggetti nati con il bestiario della voce 22: i materiali che lasciano le creature nuove e ciò che se ne fa
## (dardi, accessori, bende, pozioni, lo Specchio del guizzo, la Falce del Vuoto). Solo dati; stessi campi di
## `ItemsData`, che li unisce a tutti gli altri in `ItemsData.all()`.

const ITEMS := {
	# materiali delle creature
	"penna_corteccia": {"name": "Penna di corteccia", "kind": "materiale", "icon": ["penna", "legno"], "desc": "Dal Corvo di corteccia: leggera, e dura come il legno."},
	"aculeo": {"name": "Aculeo d'ambra", "kind": "materiale", "icon": ["aculeo", "ambra"], "desc": "Dal dorso di uno Spinoriccio. Punge anche da staccato."},
	"polvere_lucciola": {"name": "Polvere di lucciola", "kind": "materiale", "icon": ["polvere", "lucciola"], "desc": "Le Lucciole voraci ne lasciano un pizzico: fa luce fredda."},
	"seta_radice": {"name": "Seta di radice", "kind": "materiale", "icon": ["seta", "seta"], "desc": "Il filo dei Tessiradice: sottile, fortissimo."},
	"artiglio_talpone": {"name": "Artiglio di talpone", "kind": "materiale", "icon": ["artiglio", "legnoferro"], "desc": "Scava la roccia come fosse humus."},
	"lamella_fungo": {"name": "Lamella di saltafungo", "kind": "materiale", "icon": ["fungo", "fungo"], "desc": "Dal cappello di un Saltafungo: sa di pioggia."},
	"membrana_ardesia": {"name": "Membrana d'ardesia", "kind": "materiale", "icon": ["membrana", "ardesia"], "desc": "Pelle di pietra sottile come una foglia, dalle Ali d'ardesia."},
	"guscio_cristallo": {"name": "Guscio di cristallo", "kind": "materiale", "icon": ["guscio", "cristallo"], "desc": "Un pezzo di guscio a spirale di una Chiocciola di cristallo."},
	"cuore_geode": {"name": "Cuore di geode", "kind": "materiale", "icon": ["geode", "vuotite"], "desc": "Ciò che teneva sveglio un Geomimo: una pietra cava piena di punte viola."},
	"scaglia_linfa": {"name": "Scaglia di serpe", "kind": "materiale", "icon": ["scaglia", "cristallo"], "desc": "Una scaglia della Serpe di Linfa: scivola via da ogni cosa."},
	"polline_luminoso": {"name": "Polline luminoso", "kind": "materiale", "icon": ["polvere", "ambra"], "desc": "Quello che piove dalle Campanule erranti. Brilla per giorni."},
	"occhio_guizzo": {"name": "Occhio di guizzo", "kind": "materiale", "icon": ["occhio", "cristallo"], "desc": "Il Guizzalinfa vede dove andare prima di sparire: con questo occhio."},
	"lama_vuoto": {"name": "Lama del Mietivuoto", "kind": "materiale", "icon": ["lama", "vuotite"], "desc": "Un braccio a falce del Mietivuoto. Taglia anche la luce."},
	"seta_vuoto": {"name": "Seta del Vuoto", "kind": "materiale", "icon": ["seta", "vuotite"], "desc": "Filo nero dei Tessivuoto: chi la indossa si confonde con il buio."},
	# ciò che se ne fa
	"dardo_piumato": {"name": "Dardo piumato", "kind": "munizione", "icon": ["freccia", "muschio"], "damage": 6, "stack": 999, "desc": "Penne di corteccia: vola più dritto del dardo di spina."},
	"dardo_aculeo": {"name": "Dardo d'aculeo", "kind": "munizione", "icon": ["freccia", "ambra"], "damage": 8, "stack": 999, "desc": "Un aculeo di Spinoriccio in punta."},
	"mantello_penne": {"name": "Mantello di penne", "kind": "accessorio", "icon": ["mantello", "legno"], "acc": {"glide": true, "run": 1.08}, "desc": "Si plana tenendo Spazio in caduta, e si corre un poco più svelti."},
	"collana_aculei": {"name": "Collana d'aculei", "kind": "accessorio", "icon": ["collana", "ambra"], "acc": {"thorns": 8}, "desc": "Chi ti tocca si punge: 8 danni a ogni contatto."},
	"benda_seta": {"name": "Benda di seta", "kind": "consumabile", "icon": ["benda", "seta"], "heal": 30, "cure": true, "stack": 30, "desc": "Fa ricrescere 3 foglie di Vita e toglie il veleno."},
	"guanti_talpone": {"name": "Guanti del talpone", "kind": "accessorio", "icon": ["guanti", "humus"], "acc": {"dig": 1.35}, "desc": "Si scava e si abbatte più di un terzo più in fretta."},
	"pozione_rigoglio": {"name": "Pozione di rigoglio", "kind": "consumabile", "icon": ["pozione", "muschio"], "boon": ["rigoglio", 180.0], "stack": 30, "desc": "Per tre minuti la Vita ricresce tre volte più in fretta."},
	"ali_membrana": {"name": "Ali di membrana", "kind": "accessorio", "icon": ["ali", "ardesia"], "acc": {"glide": true, "jump": 1.12, "fall_safe": true}, "desc": "Salto più alto, planata tenendo Spazio, nessuna ferita da caduta."},
	"scudo_guscio": {"name": "Scudo di guscio", "kind": "accessorio", "icon": ["scudo", "cristallo"], "defense": 6, "desc": "+6 Scorza."},
	"anello_geode": {"name": "Anello del geode", "kind": "accessorio", "icon": ["anello", "vuotite"], "acc": {"luck": 0.4}, "desc": "Fortuna: le creature lasciano più spesso un giro di bottino in più."},
	"stivali_serpe": {"name": "Stivali della serpe", "kind": "accessorio", "icon": ["stivali", "cristallo"], "acc": {"run": 1.4}, "desc": "Si corre il 40% più veloci."},
	"specchio_guizzo": {"name": "Specchio del guizzo", "kind": "specchio", "icon": ["specchio", "cristallo"], "desc": "Guardaci dentro: torni al punto di partenza del mondo."},
	"falce_vuoto": {"name": "Falce del Vuoto", "kind": "spada", "icon": ["falce", "vuotite"], "tier": 5, "damage": 30, "speed": 2.6, "knockback": 4.5, "desc": "Fatta con le braccia dei Mietivuoto."},
	"velo_ombra": {"name": "Velo d'ombra", "kind": "accessorio", "icon": ["velo", "vuotite"], "acc": {"stealth": 0.6}, "desc": "Le creature ti notano molto più tardi."},
}
