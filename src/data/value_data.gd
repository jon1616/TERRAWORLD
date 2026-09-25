class_name ValueData
extends RefCounted
## Quanto vale un oggetto, in **Lumini** (voce 36): serve agli abitanti per vendere e comprare. Solo dati e un
## calcolo: il valore dei materiali grezzi è scritto qui, quello di ciò che si fabbrica nasce dagli ingredienti della
## sua ricetta (un quarto in più per il lavoro), il resto va a valori per tipo. Chi vende agli abitanti riceve un terzo
## del valore; chi compra paga il doppio.

## I materiali grezzi e le cose che non si fabbricano.
const BASE := {
	"legno": 1, "humus": 1, "ardesia": 1, "radice_antica": 1, "scisto": 1, "vuotite": 2, "pietra_seminatori": 2,
	"minerale_radicite": 3, "minerale_legnoferro": 5, "minerale_pallidite": 4, "minerale_ambra": 8,
	"minerale_tizzonite": 10, "cristallo_linfa": 12, "gelatina": 1, "fungo_brace": 2, "fungo_luminoso": 4,
	"polvere_brace": 3, "scaglia_ardesia": 4, "scheggia_vuoto": 8, "cenere_avvizzita": 2, "sacca_spore": 4,
	"seme_lanterna": 2, "stellina": 10, "polvere_iridata": 80, "gelatina_regale": 50, "seta_regale": 50,
	"scaglia_madre": 60, "nucleo_cavo": 70, "frammento_nodo": 30, "linfa_guardiano": 30, "velo_spora": 40,
	"polline_regina": 40, "nucleo_colosso": 50, "pietra_battente": 50, "brillaluce": 15, "sanguinella": 12,
	"lagunite": 18, "nottilite": 22, "cuore_bocciolo": 150, "stilla_perenne": 150, "seme_mondo": 500,
}
## Per tipo, quando non c'è altro modo di saperlo.
const KIND := {"materiale": 6, "trofeo": 60, "essenza": 40, "accessorio": 60, "consumabile": 10, "coltura": 3,
	"blocco": 1, "munizione": 1, "stazione": 20, "reliquia": 0, "moneta": 1}

static var _memo := {}
static var _busy := {}


## Il valore di un oggetto in Lumini (almeno 1, tranne le reliquie che non si vendono).
static func value(id: String) -> int:
	if _memo.has(id):
		return _memo[id]
	var it := ItemsData.get_item(id)
	var v := 0
	if it.has("value"):
		v = int(it["value"])
	elif BASE.has(id):
		v = int(BASE[id])
	elif not _busy.has(id) and not RecipesData.making(id).is_empty():
		_busy[id] = true
		var best := 1 << 30
		for r in RecipesData.making(id):
			var cost := 0.0
			for k in r["in"]:
				cost += value(String(k)) * int(r["in"][k])
			best = mini(best, ceili(cost * 1.25 / int(r["qty"])))
		_busy.erase(id)
		v = best
	else:
		v = int(KIND.get(String(it.get("kind", "")), 8)) * (1 + int(it.get("tier", 0)))
	if String(it.get("kind", "")) == "reliquia":
		v = 0
	v = maxi(v, 1) if String(it.get("kind", "")) != "reliquia" else 0
	_memo[id] = v
	return v


## Quanto dà un abitante per una pila (un terzo del valore, almeno 1 Lumino se vale qualcosa).
static func sell_price(id: String, n: int) -> int:
	var v := value(id)
	return 0 if v <= 0 else maxi(1, (v * n) / 3)


## Quanto costa comprare da un abitante.
static func buy_price(id: String, n: int) -> int:
	return value(id) * n * 2
