"""Rifà tutti i pacchetti generati del piano «La vastità» (voce 360).

Ogni modulo di `tools/vastita_gen/` ha una funzione `build()` che restituisce [(nome del file, intestazione, dati)].
Questo script li chiama in ordine alfabetico e scrive i pacchetti in `src/data/vastita/` con `gen_comune.write_pack`.
Un pacchetto nuovo va poi aggiunto **una volta** a `BiomesData.PACK_FILES` (lo segnala la verifica dei dati).

    python tools/gen_vastita.py            tutti
    python tools/gen_vastita.py armi       solo i moduli il cui nome contiene «armi»
"""
import importlib
import os
import sys

HERE = os.path.dirname(__file__)
sys.path.insert(0, HERE)
import gen_comune  # noqa: E402


def main():
    want = sys.argv[1] if len(sys.argv) > 1 else ''
    folder = os.path.join(HERE, 'vastita_gen')
    os.makedirs(folder, exist_ok=True)
    mods = sorted(f[:-3] for f in os.listdir(folder) if f.endswith('.py') and not f.startswith('_'))
    if not mods:
        print('nessun generatore in tools/vastita_gen/')
    for name in mods:
        if want and want not in name:
            continue
        mod = importlib.import_module('vastita_gen.' + name)
        for fname, header, data in mod.build():
            gen_comune.write_pack(fname, header, data, 'tools/vastita_gen/%s.py' % name)


if __name__ == '__main__':
    main()
