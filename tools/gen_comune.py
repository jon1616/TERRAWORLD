"""Il generatore di contenuti del piano «La vastità» (voce 360, Roadmap 38; piano in VASTITA.md).

Le famiglie grandi (armi, set, accessori a gradi, creature, stendardi, trofei, pesci, arredi funzionali) si scrivono
come **tabelle compatte** in uno script di `tools/vastita_gen/`, e questo modulo le trasforma in un **pacchetto** di
dati GDScript in `src/data/vastita/` (lo stesso formato dei pacchetti dei biomi: un `const DATA := {...}` con le chiavi
creatures, families, loot, items, recipes, …, unito al gioco da `BiomesData.PACK_FILES`).

Regole:
- ogni file generato dice in cima da quale script nasce: **non si tocca a mano**, si cambia la tabella e si rilancia;
- prima di scrivere, ogni id nuovo è controllato contro tutti gli id già presenti nei dati del gioco
  (`existing_ids`): un id doppio farebbe sparire in silenzio l'oggetto o la creatura (lezione della Roadmap 15);
- i pacchetti non nominano altre classi (valori scritti per esteso), come i file dei biomi.

Uso:  python tools/gen_vastita.py            (rifà tutti i pacchetti del piano)
"""
import os
import re

ROOT = os.path.normpath(os.path.join(os.path.dirname(__file__), '..'))
DATA = os.path.join(ROOT, 'src', 'data')
OUT = os.path.join(DATA, 'vastita')
KEYS = ('creatures', 'families', 'loot', 'items', 'recipes', 'sets', 'effects', 'calls', 'guardians', 'chiefs', 'events', 'wings', 'pets', 'chests', 'mimics', 'places', 'grids', 'genes', 'gene_adj', 'boons', 'stations', 'crates', 'angler', 'shops', 'merchant', 'tiles', 'veins', 'soils', 'icon_pals', 'gems')


def gd(v):
    """Un valore Python scritto come GDScript."""
    if isinstance(v, bool):
        return 'true' if v else 'false'
    if isinstance(v, (int, float)):
        return repr(v)
    if isinstance(v, str):
        if v.startswith('Color('):
            return v
        return '"%s"' % v.replace('\\', '\\\\').replace('"', '\\"')
    if isinstance(v, (list, tuple)):
        return '[' + ', '.join(gd(x) for x in v) + ']'
    if isinstance(v, dict):
        return '{' + ', '.join('%s: %s' % (gd(k), gd(x)) for k, x in v.items()) + '}'
    raise TypeError(v)


_ID = re.compile(r'^\s*"([a-z0-9_~]+)":\s*\{"name"', re.M)


def existing_ids(skip=()):
    """Gli id di oggetti, creature e stazioni scritti nei dati (righe «"id": {"name": …»), tranne i file in `skip`."""
    out = {}
    for base, _dirs, files in os.walk(DATA):
        for f in files:
            if not f.endswith('.gd'):
                continue
            path = os.path.join(base, f)
            if os.path.normpath(path) in {os.path.normpath(s) for s in skip}:
                continue
            with open(path, encoding='utf-8') as fh:
                for m in _ID.finditer(fh.read()):
                    out.setdefault(m.group(1), path)
    return out


def write_pack(fname, header, data, generator):
    """Scrive `src/data/vastita/<fname>`. Restituisce il percorso. Si ferma se un id nuovo esiste già altrove."""
    os.makedirs(OUT, exist_ok=True)
    path = os.path.join(OUT, fname)
    have = existing_ids(skip=[path])
    clash = []
    for key in ('items', 'creatures'):
        for k in data.get(key, {}):
            if k in have:
                clash.append('%s (già in %s)' % (k, os.path.relpath(have[k], ROOT)))
    if clash:
        raise SystemExit('id già usati, il pacchetto %s non è stato scritto:\n  %s' % (fname, '\n  '.join(clash)))
    out = ['extends RefCounted', '## ' + header.replace('\n', '\n## '),
           '## Fatto da `%s` (non a mano): si cambia la tabella là e si rilancia `python tools/gen_vastita.py`.' % generator,
           '## Non nomina altre classi.', '', 'const DATA := {']
    for key in KEYS:
        if key not in data:
            continue
        v = data[key]
        if isinstance(v, dict):
            out.append('\t%s: {' % gd(key))
            for k, x in v.items():
                out.append('\t\t%s: %s,' % (gd(k), gd(x)))
            out.append('\t},')
        else:
            out.append('\t%s: [' % gd(key))
            for x in v:
                out.append('\t\t%s,' % gd(x))
            out.append('\t],')
    out.append('}')
    with open(path, 'w', encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(out) + '\n')
    n = {k: len(data[k]) for k in KEYS if k in data}
    print('%s: %s' % (fname, ', '.join('%s %d' % (k, c) for k, c in n.items())))
    return path
