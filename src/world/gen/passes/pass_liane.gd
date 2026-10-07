class_name PassLiane
extends GenPass
## Roadmap 52, voce 415: le liane che pendono dai soffitti delle grotte del Sottobosco (lo strato delle radici): fili
## verdi lunghi da `MIN_LEN` a `MAX_LEN` tessere su cui ci si arrampica (`TileDefs.CLIMB_SPEED`), che si riprendono e si
## appendono altrove come corde. Si fermano due tessere sopra il pavimento, e solo dove non c'è già una decorazione.

const TRIES := 9000
const WANT := 160                      # liane per mondo
const MIN_LEN := 3
const MAX_LEN := 10
const LIANA := 99                      # la decorazione della liana (`tools/vastita_gen/terre.py`, CLIMBS)
const STRATUM := 1                     # il Sottobosco di radici


func title() -> String:
	return "Liane"


func run(w: World, c: GenContext) -> void:
	var rng := c.rng
	var top := StrataData.top(STRATUM)
	var bottom := StrataData.top(STRATUM + 1)
	var placed := 0
	for _k in TRIES:
		if placed >= WANT:
			break
		var x := rng.randi_range(20, w.w - 21)
		var y := w.surface[x] + rng.randi_range(top, bottom)
		if not w.inside(x, y) or w.solid(x, y):
			continue
		var up := 0
		while up < 24 and w.inside(x, y - 1) and not w.solid(x, y - 1):
			y -= 1                             # si sale fino al soffitto
			up += 1
		if not w.solid(x, y - 1) or w.decor_at(x, y) != 0 or w.liq(x, y) > 0:
			continue
		if StrataData.at(w, x, y) != STRATUM:
			continue
		var want := rng.randi_range(MIN_LEN, MAX_LEN)
		var n := 0
		while n < want and w.inside(x, y + n + 2) and not w.solid(x, y + n + 2) and w.decor_at(x, y + n) == 0 \
				and w.liq(x, y + n) == 0 and not w.plat(x, y + n):
			n += 1
		if n < MIN_LEN:
			continue
		for k in n:
			w.set_decor(x, y + k, LIANA)
		placed += 1
	c.notes["liane"] = placed
