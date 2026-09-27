#!/usr/bin/env bash
# Le prove, nel modo sicuro (28 set 2026): prima il controllo di sintassi dei .gd cambiati (se uno non compila, niente
# prove: il giro resterebbe fermo), poi le prove con un tempo massimo e il riassunto (avvisi, errori, corsa, tempi).
#   tools/prove.sh base,casse        il gruppo «base» (~1 minuto) più quelli della parte toccata
#   tools/prove.sh tutto             il giro intero (~8 minuti): solo quando serve davvero (vedi CLAUDE.md)
set -u
cd "$(dirname "$0")/.."
G=/c/Users/Principale/Desktop/GODOT/Godot_v4.6.1-stable_win64_console.exe
"$G" --headless --path . --import > /dev/null 2>&1      # prima: le classi nuove devono essere registrate
bad=0
for f in $( (git diff --name-only --diff-filter=d; git ls-files --others --exclude-standard) | grep '\.gd$' | sort -u); do
	out=$("$G" --headless --path . --check-only --script "res://$f" 2>&1 | grep -a "ERROR" \
		| grep -v "Session\|Musica\|depended\|Compilation failed")
	if [ -n "$out" ]; then
		echo "$f: $out"
		bad=1
	fi
done
if [ $bad -ne 0 ]; then
	echo "Controllo di sintassi: errori, prove NON lanciate."
	exit 1
fi
log=$(mktemp)
start=$(date +%s)
if [ "${1:-base}" = "tutto" ]; then
	timeout 1200 "$G" --path . -- --prove > "$log" 2>&1
else
	timeout 900 "$G" --path . -- --prove --solo="${1:-base}" > "$log" 2>&1
fi
echo "durata $(( $(date +%s) - start )) s"
grep -aE "ATTENZIONE|SCRIPT ERROR|^corsa:|tempi del giro" "$log" | cut -c1-300
echo "registro completo: $log"
