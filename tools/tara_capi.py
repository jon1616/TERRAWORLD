"""Tara il danno dei capi erranti, dei boss facoltativi e dei superboss (voci 375-377) con `tools/boss.gd`.

Lancia lo strumento, legge le Vite perse dal giocatore attento per ogni creatura del pacchetto `capi.gd`, corregge il
suo fattore del danno verso l'obiettivo (`TARGET`) e rifà il pacchetto; tre giri. Il risultato in
`tools/vastita_gen/capi_taratura.json` (lo legge `vastita_gen/capi.py`).

    python tools/tara_capi.py [giri]
"""
import json
import os
import re
import subprocess
import sys

HERE = os.path.dirname(__file__)
ROOT = os.path.normpath(os.path.join(HERE, '..'))
GODOT = r'C:\Users\Principale\Desktop\GODOT\Godot_v4.6.1-stable_win64_console.exe'
TUNE = os.path.join(HERE, 'vastita_gen', 'capi_taratura.json')
sys.path.insert(0, os.path.join(HERE))
from vastita_gen import capi  # noqa: E402


def target(cid):
    if cid.startswith('capo_'):
        return 1.0
    sup = [b[0] for b in capi.SUPER]
    if cid.replace('sfidante_', '') in sup:
        return 5.0
    v = next(c[5] for c in capi.CHALLENGERS if 'sfidante_' + c[0] == cid)
    return 2.5 if v <= 5 else 3.5


def names():
    out = {}
    for c in capi.CHIEFS:
        out[c[1]] = 'capo_' + c[0]
    for c in capi.CHALLENGERS + capi.SUPER:
        out[c[1]] = 'sfidante_' + c[0]
    return out


def main():
    rounds = int(sys.argv[1]) if len(sys.argv) > 1 else 3
    tune = json.load(open(TUNE, encoding='utf-8')) if os.path.exists(TUNE) else {}
    byname = names()
    for r in range(rounds):
        subprocess.run([sys.executable, os.path.join(HERE, 'gen_vastita.py'), 'capi'], cwd=ROOT, check=True,
                       stdout=subprocess.DEVNULL)
        subprocess.run([GODOT, '--headless', '--path', '.', '--script', 'res://tools/boss.gd'], cwd=ROOT,
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=600)
        text = open(os.path.join(ROOT, 'prove', 'boss.txt'), encoding='utf-8').read()
        worst = 0.0
        for line in text.splitlines():
            m = re.match(r'\s+v\d+\s+(.+?)\s+Vita\s+\d+\s+\|\s+\d+s\s+([\d.]+)', line)
            if not m:
                continue
            nm = m.group(1).strip()
            cid = next((c for n, c in byname.items() if n.startswith(nm) or nm.startswith(n[:30])), None)
            if cid is None:
                continue
            lives = max(float(m.group(2)), 0.05)
            want = target(cid)
            k = float(tune.get(cid, 1.0)) * max(min(want / lives, 3.0), 0.33)
            tune[cid] = round(max(min(k, 6.0), 0.08), 3)
            worst = max(worst, abs(lives - want) / want)
        json.dump(tune, open(TUNE, 'w', encoding='utf-8'), indent=1, sort_keys=True)
        print('giro %d: scarto peggiore %.0f%%' % (r + 1, worst * 100))
    subprocess.run([sys.executable, os.path.join(HERE, 'gen_vastita.py'), 'capi'], cwd=ROOT, check=True)


if __name__ == '__main__':
    main()
