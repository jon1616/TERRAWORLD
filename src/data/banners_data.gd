class_name BannersData
## Gli stendardi (Roadmap 42, voce 381; piano in `VASTITA.md`). Solo dati: li usa `Banners`.
## Ogni famiglia di creature (`FamiliesData`) ha il suo **stendardo**: ogni `EVERY` sconfitte della famiglia ne cade uno.
## Issato (clic con lo stendardo in mano) vale per sempre, ovunque: contro quella famiglia si fa più danno e se ne prende
## meno. Lo **stendardo d'oro** si fa al Telaio con lo stendardo e un trofeo di ogni specie della famiglia (i trofei li
## lasciano le rare): vale di più. Lo studio delle creature dà la conoscenza, lo stendardo il dominio.

const EVERY := 50
const DAMAGE := 1.1                      # stendardo: +10% danno contro la famiglia
const GUARD := 0.9                       # e −10% delle ferite che ti fa
const GOLD_DAMAGE := 1.2
const GOLD_GUARD := 0.82

static var _items := {}
static var _recipes: Array = []


static func item_of(fam: String, gold := false) -> String:
	return ("stendardo_oro_" if gold else "stendardo_") + fam


## I trofei delle specie di una famiglia (quelli che esistono).
static func trophies(fam: String) -> Array:
	var out := []
	for s in FamiliesData.FAMILIES.get(fam, {}).get("members", []):
		var t := String(CreaturesData.CREATURES.get(String(s), {}).get("trophy", ""))
		if t == "":
			t = String(TrophyItemsData.TROPHY_OF.get(String(s), ""))
		if t != "" and not t in out:
			out.append(t)
	return out


static func items() -> Dictionary:
	if not _items.is_empty():
		return _items
	for f in FamiliesData.FAMILIES:
		var fd: Dictionary = FamiliesData.FAMILIES[f]
		var nm := String(fd.get("name", f))
		_items[item_of(f)] = {"name": "Stendardo: %s" % nm, "kind": "stendardo", "icon": ["velo", "seta"], "stack": 10,
			"family": f, "source": "ogni %d %s sconfitti" % [EVERY, nm.to_lower()],
			"desc": "Issalo (clic): per sempre, contro %s fai il 10%% di danno in più e prendi il 10%% di ferite in meno." % nm.to_lower()}
		if not trophies(f).is_empty():
			_items[item_of(f, true)] = {"name": "Stendardo d'oro: %s" % nm, "kind": "stendardo", "icon": ["velo", "brillaluce"],
				"stack": 10, "family": f, "gold": true,
				"desc": "Issalo (clic): per sempre, contro %s fai il 20%% di danno in più e prendi il 18%% di ferite in meno." % nm.to_lower()}
	return _items


## Lo stendardo d'oro: al Telaio, lo stendardo e un trofeo di ogni specie della famiglia.
static func recipes() -> Array:
	if not _recipes.is_empty():
		return _recipes
	for f in FamiliesData.FAMILIES:
		var tr := trophies(String(f))
		if tr.is_empty():
			continue
		var ins := {item_of(String(f)): 1}
		for t in tr:
			ins[String(t)] = 1
		_recipes.append({"out": item_of(String(f), true), "qty": 1, "in": ins, "station": "telaio"})
	return _recipes
