class_name TipWordsData
## Le parole e i colori dei suggerimenti (26 set 2026): come si chiama ogni tipo di oggetto, di che colore è il suo nome,
## come si leggono gli effetti degli accessori. Solo dati: le schede le compongono `ItemTip` e `WorldTip`.

## Nome di ogni `kind` di `ItemsData` (le forme generate che non ci sono qui prendono il nome della forma).
const KINDS := {
	"materiale": "Materiale", "blocco": "Blocco", "piccone": "Piccone", "ascia": "Ascia", "spada": "Arma da mischia",
	"arco": "Arco", "munizione": "Munizione", "torcia": "Torcia", "stazione": "Banco o mobile", "piattaforma": "Passerella",
	"elmo": "Elmo", "corazza": "Corazza", "gambali": "Gambali", "accessorio": "Accessorio", "essenza": "Essenza da innestare",
	"consumabile": "Da bere o mangiare", "seme": "Seme d'albero", "lanterna": "Lanterna", "cura": "Cura",
	"seme_mondo": "Seme di mondo", "bastone": "Bastone di Linfa", "dono": "Dono da assorbire", "specchio": "Specchio",
	"richiamo": "Richiamo di un Custode", "reliquia": "Reliquia dei Seminatori", "mappa": "Mappa", "trofeo": "Trofeo",
	"rampino": "Rampino", "esplosivo": "Esplosivo", "ricurvo": "Da lanciare (torna)", "giavellotto": "Giavellotto",
	"coltura": "Seme da giardino", "annaffiatoio": "Annaffiatoio", "parete": "Parete di fondo", "martello": "Martello",
	"moneta": "Moneta", "ricordo": "Ricordo di un mondo", "evocatore": "Bastone evocatore", "compagno": "Compagno",
	"vasetto": "Vasetto", "uovo": "Uovo", "purifica": "Purifica l'Avvizzimento", "provetta": "Provetta",
	"laccio": "Laccio", "fiala": "Fiala di un gene", "creatura": "Creatura della mandria",
	"tavoletta": "Tavoletta da leggere", "chiave": "Chiave", "secchio": "Secchio", "secchio_pieno": "Secchio pieno",
}

## Colore del nome secondo il tipo (le armi e le armature prendono quello della qualità).
const KIND_COLORS := {
	"materiale": "#d8eadf", "blocco": "#c8b8a8", "trofeo": "#ffd24a", "reliquia": "#ffd24a", "ricordo": "#c8a0ff",
	"seme_mondo": "#6ff0d0", "essenza": "#d890ff", "accessorio": "#80c8ff", "dono": "#ff9ab8", "richiamo": "#ff8a6a",
	"consumabile": "#b8f080", "cura": "#b8f080", "fiala": "#8ef0d8", "stazione": "#e0b878", "moneta": "#ffd24a",
	"creatura": "#b8e070", "uovo": "#f0e0a0", "mappa": "#c8a0ff", "bastone": "#6ff0d8", "evocatore": "#6ff0d8",
}

## Gli effetti di un accessorio o di un set (`acc`, vedi `GearEffects`): [nome, modo]. Modo: "pct" = moltiplica
## (1.1 → +10%), "add" = si somma, "pct_add" = si somma come percentuale (0.15 → +15%), "flag" = c'è o non c'è,
## "less" = moltiplica ma meno è meglio.
const ACC := {
	"run": ["Corsa", "pct"], "jump": ["Salto", "pct"], "halo": ["Alone di luce", "pct"], "regen": ["Ricrescita della Vita", "pct"],
	"dig": ["Scavo e taglio", "pct"], "stealth": ["Le creature ti vedono", "less"], "damage": ["Danno", "pct"],
	"atk_speed": ["Colpi più rapidi", "pct"], "linfa_regen": ["Ricrescita della Linfa", "pct"], "magic": ["Incantesimi", "pct"],
	"luck": ["Fortuna nel bottino", "pct_add"], "thorns": ["Spine: danno a chi ti tocca", "add"], "defense": ["Scorza", "add"],
	"air_jumps": ["Salti in aria", "add"], "allies": ["Alleati in più", "add"], "glide": ["Plani tenendo Spazio", "flag"],
	"wall": ["Scivoli e salti sulle pareti", "flag"], "fall_safe": ["Nessuna ferita da caduta", "flag"],
	"resist": ["Resistenza", "pct_add"], "weak": ["Indebolisce chi colpisci", "flag"], "respiro": ["Respiro sott'acqua", "pct"],
}


static func kind_name(kind: String, form := "") -> String:
	if KINDS.has(kind):
		return String(KINDS[kind])
	if form != "" and FormsData.FORMS.has(form):
		return String(FormsData.FORMS[form].get("name", form.capitalize()))
	return kind.capitalize()


static func kind_color(kind: String) -> Color:
	return Color(String(KIND_COLORS.get(kind, "#e4f6ee")))


## Una riga leggibile per un effetto: [testo, buono?]. «Corsa +10%», «Nessuna ferita da caduta».
static func acc_line(k: String, v: Variant) -> Array:
	var d: Array = ACC.get(k, [k.capitalize(), "add"])
	match String(d[1]):
		"pct":
			var p := roundi((float(v) - 1.0) * 100.0)
			return ["%s %+d%%" % [d[0], p], p >= 0]
		"less":
			var p2 := roundi((float(v) - 1.0) * 100.0)
			return ["%s %+d%%" % [d[0], p2], p2 <= 0]
		"pct_add":
			return ["%s %+d%%" % [d[0], roundi(float(v) * 100.0)], float(v) >= 0.0]
		"flag":
			return [String(d[0]), true]
	return ["%s %+d" % [d[0], roundi(float(v))], float(v) >= 0.0]

## Che cosa fa ogni stazione, in una riga (le schede delle stazioni in `StationTip`).
const STATION_USE := {
	"ceppo": "Il banco di tutto: attrezzi, mobili, stazioni",
	"baccello_ardente": "Fonde i minerali in lingotti",
	"maglio": "Forgia armi e armature; rinnova i tratti e fa gli innesti",
	"alambicco": "Pozioni e rimedi",
	"telaio": "Vesti, sete e fasce per i manici",
	"mola": "Taglia le gemme",
	"paiolo": "Cucina: cibi che saziano",
	"porta": "Clic destro: apri o chiudi",
	"porta_aperta": "Clic destro: chiudi",
	"lampada": "Luce di lanterna",
	"tavolo": "Arredo: rende una stanza una casa per gli abitanti",
	"sedia": "Arredo: rende una stanza una casa per gli abitanti",
	"letto": "Clic destro: rinasci qui quando appassisci",
	"radice_viandante": "Clic destro: viaggia tra le radici viandanti di questo mondo",
	"focolare": "Chiama gli abitanti, se ci sono letti liberi in una casa",
	"altare": "Col richiamo giusto risveglia un Custode già sconfitto",
	"bozzolo_rotto": "Il suo Custode è stato sconfitto",
	"cuore_mondo": "Il Cuore del mondo, malato: il Guardiano lo difende",
	"cuore_vivo": "Il Cuore guarito: clic destro per il Seme di mondo",
	"recinto": "La mandria vi riposa e mangia",
	"incubatrice": "Le uova vi si schiudono, anche se sei lontano",
	"banco_innesti": "Innesta i Semi: due Semi, Fiale e Linfa antica",
	"pianta_seme": "Clic destro: raccogli il suo Seme selvatico",
	"aiuola": "Pianta qui un Seme di mondo: nasce un portale",
	"fagotto": "Ciò che avevi addosso quando sei appassito",
}
