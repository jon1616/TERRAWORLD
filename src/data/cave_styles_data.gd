class_name CaveStylesData
extends RefCounted
## Gli stili delle grotte, uno per strato (voce 448, Roadmap 57 «Le profondità vere»): prima ogni strato aveva le stesse
## macchie tonde, ora dalla forma delle grotte si riconosce dove si è. Li legge `PassGrotte` (a fasce); fra uno strato e
## il successivo lo stile si sfuma su `BLEND` righe. I geni «grotte» li moltiplicano (worm ×, room +, big +).
## Campi (le soglie sono sul rumore -1…1):
##   worm      larghezza delle gallerie a verme (|rumore| sotto questa soglia = aria)
##   worm_sy   stiramento verticale del rumore delle gallerie: > 1 = gallerie più orizzontali e lunghe
##   room      soglia delle sale (rumore sopra = aria): più bassa = più sale
##   room_sy   come worm_sy, per le sale
##   shaft     larghezza dei pozzi verticali (0 = niente): un rumore stirato in x, dritto in giù
##   ledge     ogni quante righe una cenga (una riga di roccia lasciata nei pozzi; 0 = niente)
##   big       le grandi caverne (soglia; 2 = mai)

const BLEND := 24

const STYLES := [
	# 0 Superficie: cunicoli stretti, qualche tana
	{"worm": 0.030, "worm_sy": 1.4, "room": 0.62, "room_sy": 1.2, "shaft": 0.0, "ledge": 0, "big": 2.0},
	# 1 Sottobosco di radici: gallerie lunghe, orizzontali, intrecciate (corrono con le radici giganti)
	{"worm": 0.060, "worm_sy": 2.2, "room": 0.56, "room_sy": 1.8, "shaft": 0.0, "ledge": 0, "big": 2.0},
	# 2 Caverne d'ardesia: sale e cunicoli, le grandi caverne più giù
	{"worm": 0.040, "worm_sy": 1.2, "room": 0.30, "room_sy": 1.1, "shaft": 0.0, "ledge": 0, "big": 0.48},
	# 3 Profondità della Linfa: pozzi verticali con le cenge, poche sale
	{"worm": 0.032, "worm_sy": 1.0, "room": 0.40, "room_sy": 0.8, "shaft": 0.055, "ledge": 9, "big": 0.44},
	# 4 Il Fondo: i grandi vuoti (li scava `PassVuoti`) e sale ampie fra i pilastri
	{"worm": 0.035, "worm_sy": 1.0, "room": 0.28, "room_sy": 1.0, "shaft": 0.02, "ledge": 0, "big": 0.4},
]


## Lo stile di una cella come numeri, sfumato fra lo strato `k` e il successivo a `t` (0-1).
static func mix(k: int, t: float) -> Dictionary:
	var a: Dictionary = STYLES[clampi(k, 0, STYLES.size() - 1)]
	var b: Dictionary = STYLES[clampi(k + 1, 0, STYLES.size() - 1)]
	var out := {}
	for key in a:
		out[key] = lerpf(float(a[key]), float(b[key]), t)
	return out
