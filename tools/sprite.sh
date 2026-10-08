#!/usr/bin/env bash
# La prova veloce delle pose delle creature (8 ott 2026): sul mondo di prova già salvato (--carica, niente generazione)
# fa comparire la creatura, fotografa ogni posa e la guarda dal vivo. Circa 20 secondi invece dei minuti del gruppo base.
#   tools/sprite.sh capo_cinghiale           una creatura (o più, separate da virgole)
#   tools/sprite.sh lupo_lunare antica       la creatura rara di quel grado: l'alone (prove/sprite/<id>_<grado>.png)
#   tools/sprite.sh                          tutte quelle con le pose disegnate
# Risultato: prove/sprite/<id>.png (foglio delle pose) e prove/sprite/<id>_vivo.png
set -u
cd "$(dirname "$0")/.."
G=/c/Users/Principale/Desktop/GODOT/Godot_v4.6.1-stable_win64_console.exe
"$G" --headless --path . --import > /dev/null 2>&1
log=$(mktemp)
start=$(date +%s)
arg=""
[ -n "${1:-}" ] && arg="--creatura=$1"
[ -n "${2:-}" ] && arg="$arg --rara=$2"
timeout 300 "$G" --path . -- --prove --carica --solo=sprite $arg > "$log" 2>&1
echo "durata $(( $(date +%s) - start )) s"
grep -aE "alone|colpo|pose|dal vivo|fotogrammi|ATTENZIONE|SCRIPT ERROR" "$log" | cut -c1-300
echo "registro completo: $log"
