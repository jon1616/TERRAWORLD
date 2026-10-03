class_name LoreConds
extends RefCounted
## Le condizioni della storia (Roadmap 36): «è già successo questo?», scritte come dati e lette da sogni, echi e Taccuino
## della verità. Una condizione è un dizionario con una chiave sola (o `all`/`any` con un elenco):
##   {}                       sempre
##   {"stat": k, "n": n}      un conteggio del personaggio ≥ n
##   {"sower": k, "n": n}     parti risvegliate di un Seminatore ≥ n (`Sowers`)
##   {"spent": n}             parti spente in tutto ≥ n
##   {"nero": "curato"|"spezzato"|"si"}   la scelta sul Seme Nero
##   {"albero": n}            stadio dell'Albero-Madre ≥ n
##   {"page": id}             una pagina di storia già letta (Erbario)
##   {"dream": id} {"echo": id} {"truth": id}   un sogno visto, un eco visto, una domanda risolta
##   {"truths": n}            domande risolte ≥ n
##   {"all": [c, …]} {"any": [c, …]}


static func ok(m: Node2D, c: Dictionary) -> bool:
	if c.is_empty():
		return true
	var st: Dictionary = m.character.stats
	if c.has("all"):
		for x in c["all"]:
			if not ok(m, x):
				return false
		return true
	if c.has("any"):
		for x in c["any"]:
			if ok(m, x):
				return true
		return false
	if c.has("stat"):
		return int(st.get(String(c["stat"]), 0)) >= int(c.get("n", 1))
	if c.has("sower"):
		return int(st.get("risveglio_" + String(c["sower"]), 0)) >= int(c.get("n", 1))
	if c.has("spent"):
		var n := 0
		for k in SowersData.ORDER + ["senza_nome"]:
			n += int(st.get("spento_" + k, 0))
		return n >= int(c["spent"])
	if c.has("nero"):
		var sn := String(m.character.seme_nero)
		return sn != "" if String(c["nero"]) == "si" else sn == String(c["nero"])
	if c.has("albero"):
		return m.albero.stage() >= int(c["albero"])
	if c.has("page"):
		return m.erbario.known("pagine", String(c["page"]))
	if c.has("dream"):
		return int(st.get("sogno_" + String(c["dream"]), 0)) >= 1
	if c.has("echo"):
		return int(st.get("eco_" + String(c["echo"]), 0)) >= 1
	if c.has("truth"):
		return int(st.get("verita_" + String(c["truth"]), 0)) >= 1
	if c.has("truths"):
		return int(st.get("verita", 0)) >= int(c["truths"])
	return false
