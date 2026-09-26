class_name TipCard
extends RefCounted
## Il contenuto di un suggerimento (richiesta dell'utente, 26 set 2026: «un sistema di tooltips generale, vasto,
## completo e bello»). Chi vuole un suggerimento compone una scheda con pochi pezzi e `Tips` la disegna con `TipView`:
##   title(nome, colore, icona)   la riga in alto, con l'icona (id di un oggetto o una Texture2D)
##   sub(testo)                   la riga sotto il nome: che cos'è («Spada · grado 2»)
##   stats([[nome, valore, colore?], …])   valori in colonna, allineati
##   text(bbcode) / line(testo, colore)    righe libere (con i colori)
##   pair(nome, testo, colore)     «Nome: testo» con il nome colorato (tratti, set, elementi)
##   bar(etichetta, 0-1, colore)   una barra (Vita di una creatura, crescita, avanzamento)
##   sep()                         una riga sottile
##   hint(testo)                   in fondo, piccolo e spento (comandi: «Maiusc: confronta»)
## `accent` colora il bordo e il nome; `width` la larghezza (in pixel del testo).
## Una scheda è solo dati: si può costruire anche negli script senza finestra (prove, strumenti).

const DIM := Color("#6a8a84")
const SOFT := Color("#9fc8c0")
const TEXT := Color("#e4f6ee")
const GOOD := Color("#8ff0a0")
const BAD := Color("#ff8a7a")
const GOLD := Color("#ffd08a")

var accent := Color("#8ef0d8")
var width := 340.0
var blocks: Array = []


func title(name: String, col := Color(0, 0, 0, 0), icon: Variant = null) -> TipCard:
	if col.a > 0.0:
		accent = col
	blocks.append({"t": "title", "text": name, "icon": icon})
	return self


func sub(s: String, col := SOFT) -> TipCard:
	if s != "":
		blocks.append({"t": "sub", "text": s, "color": col})
	return self


func stats(rows: Array) -> TipCard:
	if not rows.is_empty():
		blocks.append({"t": "stats", "rows": rows})
	return self


func text(bb: String) -> TipCard:
	if bb.strip_edges() != "":
		blocks.append({"t": "text", "text": bb})
	return self


func line(s: String, col := TEXT) -> TipCard:
	if s != "":
		blocks.append({"t": "text", "text": "[color=#%s]%s[/color]" % [col.to_html(false), s]})
	return self


func pair(name: String, s: String, col := GOLD) -> TipCard:
	blocks.append({"t": "text", "text": "[color=#%s]%s[/color]  [color=#%s]%s[/color]" % [col.to_html(false), name,
		TEXT.to_html(false), s]})
	return self


func bar(label: String, frac: float, col := GOOD) -> TipCard:
	blocks.append({"t": "bar", "text": label, "frac": clampf(frac, 0.0, 1.0), "color": col})
	return self


func sep() -> TipCard:
	if not blocks.is_empty() and String(blocks[-1]["t"]) != "sep":
		blocks.append({"t": "sep"})
	return self


func hint(s: String) -> TipCard:
	if s != "":
		blocks.append({"t": "hint", "text": s})
	return self


## Tutto il testo della scheda (per le prove e per chi la vuole in una riga).
func plain() -> String:
	var out := []
	for b in blocks:
		match String(b["t"]):
			"stats":
				for r in b["rows"]:
					out.append("%s %s" % [r[0], r[1]])
			"sep":
				pass
			_:
				out.append(String(b.get("text", "")))
	return "\n".join(out)


## Una scheda di sole parole (i vecchi `tooltip_text`).
static func simple(s: String) -> TipCard:
	var c := TipCard.new()
	var lines := s.strip_edges().split("\n")
	if lines.size() == 1 and s.length() < 60:
		c.line(s)
		c.width = 0.0                          # si stringe al testo
		return c
	c.text("\n".join(lines))
	return c


## Un numero con il segno e il colore della differenza (per i confronti con Maiusc).
static func delta(v: float, fmt := "%+d", better_high := true) -> String:
	if absf(v) < 0.005:
		return "[color=#%s]=[/color]" % DIM.to_html(false)
	var good := (v > 0.0) == better_high
	var s := fmt % (roundi(v) if fmt.contains("d") else v)
	return "[color=#%s]%s[/color]" % [(GOOD if good else BAD).to_html(false), s]
