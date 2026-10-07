class_name TransmuteData
## Le trasformazioni della Pozza di Linfa antica (Roadmap 45, voce 396; le fa `Finds`). Solo dati, calcolati dagli
## altri dati: un oggetto gettato nella Pozza diventa il **seguente della sua famiglia**, in giro. Così chi ha un'arma
## firma che non usa la cambia con un'altra della stessa fase, chi ha due elmi uguali delle spoglie di un boss ne fa la
## corazza che manca, e i rari, le casse dei biomi, gli accessori firma, gli elmi degli stili e le essenze girano allo
## stesso modo. Le famiglie (`_group`):
##   firma_<fase>   le armi firma di una fase           acc_<fase>     gli accessori firma di una fase
##   raro_<fase>    i rari dei nemici di una fase       cassa_<fase>   gli oggetti delle casse dei biomi di una fase
##   spoglie_<chi>  i tre pezzi delle spoglie di un boss
##   stile_<mat>    gli otto elmi degli stili di un materiale
##   essenze        le essenze della forgia

static var _map := {}
static var _groups := {}


## In che cosa si trasforma un oggetto ("" = la Pozza non lo cambia).
static func of(id: String) -> String:
	if _map.is_empty():
		_build()
	return String(_map.get(id, ""))


## Quante trasformazioni ci sono in tutto.
static func count() -> int:
	if _map.is_empty():
		_build()
	return _map.size()


static func _build() -> void:
	_groups.clear()
	var all := ItemsData.all()
	for id in all:
		var g := _group(String(id), all[id])
		if g != "":
			if not _groups.has(g):
				_groups[g] = []
			(_groups[g] as Array).append(String(id))
	for g in _groups:
		var l: Array = _groups[g]
		if l.size() < 2:
			continue
		l.sort()
		for i in l.size():
			_map[l[i]] = l[(i + 1) % l.size()]


static func _group(id: String, it: Dictionary) -> String:
	var ph := int(it.get("fase", 0))
	if id.begins_with("firma_f") and it.has("firma"):
		return "firma_%d" % ph
	if id.begins_with("acc_f"):
		return "acc_%d" % ph
	if id.begins_with("raro_") and it.has("raro_di"):
		return "raro_%d" % ph
	if id.begins_with("cassa_") and it.has("fase"):
		return "cassa_%d" % ph
	if id.begins_with("spoglie_"):
		return id.substr(0, id.rfind("_"))
	if ArmorData.HELMS.has(String(it.get("form", ""))):
		return "stile_" + String(it.get("mat", ""))
	if String(it.get("kind", "")) == "essenza" and ArmorData.ESSENCES.has(String(it.get("graft", ""))):
		return "essenze"
	return ""
