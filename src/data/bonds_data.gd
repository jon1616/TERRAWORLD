class_name BondsData
extends RefCounted
## I compagni di battaglia (Roadmap 32, dal 1 ott 2026; richiesta dell'utente: «ogni creatura, Guardiani esclusi, una
## in campo che combatte con il suo stile»). Solo dati; le regole vive stanno in `BondFight` (il combattimento),
## `BhMandria` (seguire e scegliere il nemico) e `Herd` (le schede).
##
## Lo **stile** di un compagno sono i comportamenti della sua specie (`CreaturesData`, campo "behaviors"), usati contro
## le creature nemiche: un lupo carica, uno sputaspore spara, un talpone sbuca da sotto. Qui si dice quali
## comportamenti un compagno non usa (danneggerebbero il Germogliato o lo farebbero restare indietro) e come si
## sostituiscono quelli che non hanno senso fuori dal loro posto (chi nuota, nell'aria nuota dentro una bolla).

## I comportamenti che un compagno non usa: rubano o bevono dal Germogliato, rosicchiano le porte, scappano, si
## travestono e restano fermi, chiamano altre creature selvatiche, curano le creature selvatiche.
const SKIP := ["fugge", "ladro", "rosicchia", "succhia", "lucciola_vena", "parassita", "pastore", "mimo", "mimetico",
	"fotofobo", "richiamo", "evoca", "guaritore", "tessitore", "divide", "deriva", "nuota", "fermo"]
## I comportamenti che muovono la creatura: se lo stile non ne ha nessuno, prende «vola» o «cammina».
const MOVERS := ["cammina", "vola", "salta_verso", "scava", "sbuca", "picchiata", "teletrasporto", "agguato", "carica",
	"scatto"]

## Seguire il Germogliato e combattere (tessere e secondi).
const SIGHT := 12.0                    # il compagno difende entro questa distanza dal Germogliato
const LEASH := 18.0                    # oltre questa distanza dal Germogliato lascia il nemico e torna
const FAR := 22.0                      # più lontano di così (fuori dalla visuale) ricompare accanto al Germogliato
const STUCK_TIME := 1.4                # secondi senza avvicinarsi (lontano più di `STUCK_FROM` tessere): ricompare
const STUCK_FROM := 5.0
const SIGHT_MULT := 1.3                # il compagno vede un poco più lontano del suo stile selvatico (non ha paura del buio)
const HIT_EVERY := 0.7                 # secondi tra due colpi al contatto sullo stesso nemico
const AGGRO_TIME := 4.0                # secondi in cui una creatura colpita dal compagno lo prende di mira
const AGGRO_NEAR := 0.7                # o se il compagno le è più vicino di così (rispetto al Germogliato)
const SHOT_MIN := 0.6                  # i colpi a distanza valgono tra queste frazioni del danno del compagno
const SHOT_MAX := 1.4
const BLAST_MULT := 2.5                # lo scoppio di un compagno (non muore: lo rifà dopo `PAUSE`)
const PAUSE := 6.0


## Lo stile di una specie: i suoi comportamenti senza quelli di `SKIP`, più un modo di muoversi se manca.
static func style_of(cid: String) -> Array[String]:
	var d := CreaturesData.get_data(cid)
	var out: Array[String] = []
	var moves := false
	for b in d.get("behaviors", []):
		var s := String(b)
		if s in SKIP or s in out:
			continue
		out.append(s)
		if s in MOVERS:
			moves = true
	if not moves:
		out.push_front("vola" if flies(cid) else "cammina")
	return out


## Vola in campo? Chi vola, e chi nuota (fuori dall'acqua nuota nell'aria, dentro una bolla).
static func flies(cid: String) -> bool:
	var d := CreaturesData.get_data(cid)
	return bool(d.get("fly", false)) or bool(d.get("water", false)) or "nuota" in d.get("behaviors", [])


## Si può legare? Tutte le creature tranne Guardiani, Custodi e Signori (le `boss`).
static func bindable(cid: String) -> bool:
	var d := CreaturesData.get_data(cid)
	return not d.is_empty() and not bool(d.get("boss", false))
