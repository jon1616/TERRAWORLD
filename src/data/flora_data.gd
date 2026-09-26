class_name FloraData
extends RefCounted
## Alberi e germogli: quanto ci mettono a crescere, i semi. Specie, grandezze, robustezza e legno di ogni albero
## stanno in `TreesData` (26 set 2026: un albero per bioma, in quattro grandezze).

## Legno che cade da un albero abbattuto, dal più piccolo al più grande (il valore vero è in `TreesData.SIZES`).
const WOOD := [3, 20]
## Probabilità che cada un seme d'albero-lanterna, e quanti.
const SEED_CHANCE := 0.6
const SEEDS := [1, 2]
## Secondi di gioco perché un germoglio diventi albero (minimo, massimo).
const GROW := [150.0, 300.0]
## Spazio libero sopra un germoglio perché possa crescere (tessere): quanto l'albero più piccolo, più una.
const ROOM := 5
## Area occupata da un albero rispetto alla sua base: colonne x-1..x+1, righe da y-HEIGHT a y (il più alto, «antico»).
const HEIGHT := 12
