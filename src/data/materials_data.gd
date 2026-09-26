class_name MaterialsData
extends RefCounted
## I materiali dell'equipaggiamento e le loro **proprietà** (voce 49, Roadmap 6 «La materia viva»). Solo dati.
## Gli attrezzi, le armi e le armature di ogni materiale non sono scritti a mano: nascono da forma × materiale
## (`FormsData.item`), e i loro valori vengono dalle proprietà pesate dalla forma. Un materiale nuovo = una riga qui
## (più il suo lingotto): compare con tutta la sua famiglia di oggetti, le ricette e le icone.
##
## Proprietà:
##   tier        grado (0-6): quanto è avanti nel gioco
##   durezza     forza di scavo di picconi e asce (vedi `TileDefs.POWER`)
##   filo        danno di taglio delle armi
##   peso        colpi più lenti, spinta più forte (le mazze ne fanno danno)
##   tenacia     la Scorza delle armature
##   conduzione  quanto porta la Linfa: il danno delle verghe e il loro costo (voce 50)
##   elemento    l'elemento dei colpi (voce 51): "" · brace · gelo · spora · linfa · vuoto · luce
##   risonanza   0-2: posti d'innesto in più (voce 54)
##   label       «di radicite» (label_pl per i nomi al plurale), icon = tavolozza di `ItemIcons`, bar = il lingotto
## I valori dei metalli sono scelti perché le armi e le armature di prima restassero quelle (la prova sta in
## `tools/verifica_dati.gd`).

const MATERIALS := {
	"radicite": {"label": "di radicite", "tier": 1, "durezza": 35, "filo": 9, "peso": 20.0, "tenacia": 1.2, "conduzione": 4,
		"elemento": "", "risonanza": 0, "bar": "lingotto_radicite"},
	"legnoferro": {"label": "di legnoferro", "tier": 2, "durezza": 45, "filo": 12, "peso": 17.5, "tenacia": 2.0, "conduzione": 3,
		"elemento": "", "risonanza": 0, "bar": "lingotto_legnoferro"},
	"ambra": {"label": "d'ambra", "tier": 3, "durezza": 55, "filo": 16, "peso": 15.0, "tenacia": 2.8, "conduzione": 8,
		"elemento": "luce", "risonanza": 1, "bar": "lingotto_ambra"},
	"linfa": {"label": "di Linfa", "tier": 4, "durezza": 65, "filo": 21, "peso": 10.0, "tenacia": 3.8, "conduzione": 14,
		"elemento": "linfa", "risonanza": 1, "bar": "lingotto_linfa", "icon": "cristallo"},
	"vuoto": {"label": "di vuotite forgiata", "tier": 5, "durezza": 75, "filo": 27, "peso": 7.5, "tenacia": 5.0, "conduzione": 10,
		"elemento": "vuoto", "risonanza": 1, "bar": "lingotto_vuoto", "icon": "vuotite"},
	# voce 24: metalli laterali, per chi vuole una strada diversa (più veloce, o più forte prima della Linfa)
	"pallidite": {"label": "di pallidite", "tier": 2, "durezza": 42, "filo": 11, "peso": 7.5, "tenacia": 1.6, "conduzione": 6,
		"elemento": "gelo", "risonanza": 0, "bar": "lingotto_pallidite"},
	"tizzonite": {"label": "di tizzonite", "tier": 3, "durezza": 60, "filo": 18, "peso": 15.0, "tenacia": 3.1, "conduzione": 5,
		"elemento": "brace", "risonanza": 0, "bar": "lingotto_tizzonite"},
	"stellare": {"label": "stellare", "label_pl": "stellari", "tier": 6, "durezza": 85, "filo": 34, "peso": 5.0, "tenacia": 6.0,
		"conduzione": 16, "elemento": "luce", "risonanza": 2, "bar": "lingotto_stellare", "icon": "ambra"},
}

## Le proprietà numeriche (per le leghe e per le schede).
const PROPS := ["durezza", "filo", "peso", "tenacia", "conduzione"]
const PROP_NAMES := {"durezza": "Durezza", "filo": "Filo", "peso": "Peso", "tenacia": "Tenacia", "conduzione": "Conduzione",
	"risonanza": "Risonanza"}


static func all() -> Dictionary:
	return MATERIALS


static func get_mat(id: String) -> Dictionary:
	return all().get(id, {})


## La tavolozza dell'icona di un materiale.
static func icon_of(id: String) -> String:
	return String(get_mat(id).get("icon", id))


## «Durezza 45 · Filo 12 · Peso 17 · Tenacia 2 · Conduzione 3» (per la scheda in Esamina).
static func describe(id: String) -> String:
	var md := get_mat(id)
	var parts := []
	for p in PROPS:
		parts.append("%s %s" % [PROP_NAMES[p], str(md[p]) if not md[p] is float else ("%.1f" % md[p]).trim_suffix(".0")])
	return " · ".join(parts)
